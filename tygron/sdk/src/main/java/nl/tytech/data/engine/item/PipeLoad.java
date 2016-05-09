/*******************************************************************************
 * Copyright 2006-2016 TyTech B.V., Saturnusstraat 60, 2516 AH, The Hague, The Netherlands All rights reserved. This software is proprietary
 * information of TyTech B.V..
 ******************************************************************************/
package nl.tytech.data.engine.item;

import java.util.ArrayList;
import java.util.List;
import nl.tytech.core.item.annotations.ItemIDField;
import nl.tytech.core.item.annotations.ListOfClass;
import nl.tytech.core.item.annotations.XMLValue;
import nl.tytech.core.net.serializable.MapLink;
import nl.tytech.data.core.item.Item;
import nl.tytech.data.engine.item.Building.Detail;
import nl.tytech.data.engine.serializable.Address;
import nl.tytech.data.engine.serializable.Category;
import nl.tytech.data.engine.serializable.CategoryValue;
import nl.tytech.data.engine.serializable.MapType;
import nl.tytech.data.engine.serializable.TimeState;
import nl.tytech.util.JTSUtils;
import nl.tytech.util.MathUtils;
import nl.tytech.util.StringUtils;
import nl.tytech.util.logger.TLogger;
import com.vividsolutions.jts.geom.MultiPolygon;
import com.vividsolutions.jts.geom.Point;

/**
 * End point of a pipe that has a load (consumes or produces e.g. energy)
 * @author Maxim Knepfle
 *
 */
public class PipeLoad extends Item {

    private static class LoadCostSegment {
        private double baseCost;
        private double incrCost;
        private int minConnections;

        public LoadCostSegment(double baseCost, double incrCost, int minConnections) {
            this.baseCost = baseCost;
            this.incrCost = incrCost;
            this.minConnections = minConnections;
        }

        public double getCost(int amountOfConnections) {
            if (!isValidSegment(amountOfConnections)) {
                return 0;
            }
            return baseCost + incrCost * amountOfConnections;
        }

        public boolean isValidSegment(int amountOfConnections) {
            return amountOfConnections >= minConnections;
        }
    }

    public enum LoadParameterType {
        FLOW, //
        POWER, //
        CONNECTION_COST, //
        CONNECTION, //
        FLOOR_SPACE_M2, //
        ;
        public final static LoadParameterType[] VALUES = values();

    }

    public enum LoadType {

        UNKNOWN("Onbekend", new LoadCostSegment[] { new LoadCostSegment(0, 2500, 1) }),

        // , meerdere (stijg)strangen per woning, individueel tapwater"),
        COLLECTIVE("Collectieve ketel", new LoadCostSegment[] { new LoadCostSegment(19250, 1100, 2), new LoadCostSegment(34500, 1100, 62),
                new LoadCostSegment(41500, 1100, 139) }),

        // , meerdere (stijg)strangen per woning, collectief tapwater"),
        COLLECTIVE_TAP("Collectieve ketel", new LoadCostSegment[] { new LoadCostSegment(19250, 500, 2),
                new LoadCostSegment(34500, 500, 62), new LoadCostSegment(41500, 500, 139) }),

        // , verdeling naar radiatoren per woning, individueel tapwater"),
        COLLECTIVE_RADIATOR("Collectieve ketel", new LoadCostSegment[] { new LoadCostSegment(11250, 1800, 2),
                new LoadCostSegment(26500, 1800, 62), new LoadCostSegment(33500, 1800, 139) }),

        // , verdeling naar radiatoren per woning, collectief tapwater"),
        COLLECTIVE_RADIATOR_TAP("Collectieve ketel", new LoadCostSegment[] { new LoadCostSegment(11250, 1800, 2),
                new LoadCostSegment(26500, 1800, 62), new LoadCostSegment(33500, 1800, 139) }),

        INDIVIDUAL("Individuele (combi)ketel", new LoadCostSegment[] { new LoadCostSegment(2500, 0, 1),
                new LoadCostSegment(11250, 2200, 2), new LoadCostSegment(26500, 2200, 62), new LoadCostSegment(33500, 2200, 139) }),

        LARGE_SCALE_CONSUMER("Grootverbruiker", new LoadCostSegment[] { new LoadCostSegment(11250, 0, 6),
                new LoadCostSegment(26500, 0, 62), new LoadCostSegment(33500, 0, 139) }),

        ;

        public static final LoadType[] VALUES = LoadType.values();

        private String text;

        private LoadCostSegment[] segments;

        private LoadType(String text, LoadCostSegment[] loadCostSegments) {
            this.text = text;
            this.segments = loadCostSegments;
        }

        public double getConnectionCost(int amountOfConnections) {
            LoadCostSegment loadCostSegment = null;
            for (int i = 0; i < segments.length; i++) {
                if (segments[i].isValidSegment(amountOfConnections)) {
                    loadCostSegment = segments[i];
                } else {
                    break;
                }
            }
            if (loadCostSegment == null) {
                return 0;
            }
            return loadCostSegment.getCost(amountOfConnections);
        }

        public String getText() {
            return text;
        }
    }

    /**
     *
     */
    private static final long serialVersionUID = 7992398125463026642L;

    public final static double FLOW_TO_POWER = 3.5d;

    @ItemIDField("PIPE_JUNCTIONS")
    @XMLValue
    private Integer junctionID = Item.NONE;

    @XMLValue
    @ItemIDField("BUILDINGS")
    private Integer buildingID = Item.NONE;

    @XMLValue
    @ItemIDField("PIPE_CLUSTERS")
    private Integer clusterID = Item.NONE;

    @XMLValue
    private LoadType type = LoadType.UNKNOWN;

    @XMLValue
    private TimeState connectionState = TimeState.NOTHING;

    @XMLValue
    private Double overrideConnectionCost = null;

    @XMLValue
    private Double overrideFlow = null;

    @XMLValue
    private Double overridePower = null;

    @XMLValue
    private Integer overrideConnectionCount = null;

    @XMLValue
    @ListOfClass(Address.class)
    private ArrayList<Address> addresses = new ArrayList<>();

    @XMLValue
    private Point point = null;

    public PipeLoad() {

    }

    public void addAddress(Address address) {
        if (!addresses.contains(address)) {
            addresses.add(address);
        }
    }

    public List<Address> getAddresses() {
        return addresses;
    }

    public Building getBuilding() {
        return this.getItem(MapLink.BUILDINGS, buildingID);
    }

    public Integer getBuildingID() {
        return buildingID;
    }

    public double getCalculatedConnectionCosts() {
        return this.getType().getConnectionCost(this.getConnectionCount());
    }

    public int getCalculatedConnectionCount() {

        Building building = getBuilding();
        if (building == null) {
            return 0;
        }
        int houseCount;
        if (addresses.size() > 0) {
            houseCount = addresses.size();
        } else {
            houseCount = (int) Math.round(building.getBuildingDetail(MapType.CURRENT, Detail.NUMBER_OF_HOUSES));
        }
        // always at least 1
        return Math.max(1, houseCount);
    }

    public double getCalculatedFlow() {

        Building building = getBuilding();
        if (building == null) {
            return 0;
        }
        double flowPerm2 = 0;
        for (Category category : building.getCategories()) {
            double startValue = building.getValue(category, CategoryValue.HEAT_FLOW_M2_START_VALUE);
            double startYear = building.getValue(category, CategoryValue.HEAT_FLOW_M2_START_YEAR);
            if (startValue == 0 && startYear == 0) {
                continue;
            }

            double yearDifference = MathUtils.clamp(building.getConstructionYear() - startYear, 0, Double.MAX_VALUE);
            flowPerm2 += building.getCategoryPercentage(category)
                    * (startValue + yearDifference * building.getValue(category, CategoryValue.HEAT_FLOW_M2_CHANGE_PER_YEAR));
        }
        double floorSizeM2 = getFloorspaceM2(MapType.CURRENT);
        return flowPerm2 * floorSizeM2;
    }

    public double getCalculatedPower() {
        Building building = getBuilding();
        if (building == null) {
            return 0;
        }
        double flowToPower = building.getValue(CategoryValue.HEAT_POWER_TO_FLOW_MULTIPLIER);
        return this.getCalculatedFlow() / flowToPower;
    }

    public PipeCluster getCluster() {
        return this.getItem(MapLink.PIPE_CLUSTERS, this.clusterID);
    }

    public Integer getClusterID() {
        return clusterID;
    }

    public double getConnectionCosts() {

        if (overrideConnectionCost != null) {
            return overrideConnectionCost;
        }
        return getCalculatedConnectionCosts();
    }

    public int getConnectionCount() {

        if (overrideConnectionCount != null) {
            return overrideConnectionCount;
        }
        return getCalculatedConnectionCount();
    }

    public TimeState getConnectionState() {
        return connectionState;
    }

    public double getFloorspaceM2(MapType mapType) {

        Building building = getBuilding();
        if (building == null) {
            return 0;
        }

        if (addresses.size() > 0) {
            double sumSurfaceSize = 0;
            for (Address address : addresses) {
                sumSurfaceSize += address.getSurfaceSizeM2();
            }
            return sumSurfaceSize;
        }

        return building.getBuildingDetail(MapType.CURRENT, Detail.SELLABLE_FLOORSPACE_M2);
    }

    public double getFlow() {

        if (this.overrideFlow != null) {
            return overrideFlow;
        }
        return getCalculatedFlow();
    }

    public PipeJunction getJunction() {
        return this.getItem(MapLink.PIPE_JUNCTIONS, this.getJunctionID());
    }

    public Point getJunctionCoordinate() {
        PipeJunction junction = this.getJunction();
        if (junction == null) {
            return null;
        }
        return junction.getPoint();
    }

    public Integer getJunctionID() {
        return junctionID;
    }

    public Address getMainAddress() {
        if (addresses.size() > 0) {
            return addresses.get(0);
        }
        return null;
    }

    public MultiPolygon getMultiPolygon(MapType mapType) {

        if (getPoint() != null) {
            return JTSUtils.createMP(JTSUtils.bufferSimple(getPoint(), Pipe.DEFAULT_PIPE_SQUARE_SIZE));
        }

        /**
         * When I have no buildings, set me next to junction
         */
        if (this.getJunctionCoordinate() != null) {
            return JTSUtils.createMP(JTSUtils.bufferSimple(this.getJunctionCoordinate(), Pipe.DEFAULT_PIPE_SQUARE_SIZE));
        }
        return JTSUtils.EMPTY;
    }

    public String getName() {

        // return id name
        return this.getClass().getSimpleName() + StringUtils.WHITESPACE + this.getID();
    }

    public Double getOverrideConnectionCost() {
        return overrideConnectionCost;
    }

    public Integer getOverrideConnectionCount() {
        return overrideConnectionCount;
    }

    public Double getOverrideFlow() {
        return overrideFlow;
    }

    public Double getOverridePower() {
        return overridePower;
    }

    public Integer getOwnerID() {
        PipeCluster cluster = this.getCluster();
        if (cluster == null) {
            return Item.NONE;
        }
        return cluster.getOwnerID();
    }

    public double getParameterValue(MapType mapType, LoadParameterType param) {
        switch (param) {
            case CONNECTION:
                return this.getConnectionCount();
            case CONNECTION_COST:
                return this.getConnectionCosts();
            case FLOOR_SPACE_M2:
                return getFloorspaceM2(mapType);
            case FLOW:
                return this.getFlow();
            case POWER:
                return this.getPower();
        }
        return 0;
    }

    public double getPercentageActive() {
        return 1;
    }

    public Point getPoint() {

        // try point first
        if (point != null) {
            return point;
        }

        // try address
        Address address = getMainAddress();
        if (address != null && address.getPoint() != null) {
            return address.getPoint();
        }

        // try center of buildings
        Building building = getBuilding();
        if (building != null) {
            Point center = JTSUtils.getCenterPoint(building.getMultiPolygon(null));
            if (center != null) {
                return center;
            }
        }

        // try junction
        if (this.getJunction() != null) {
            return this.getJunction().getPoint();
        }
        return null;
    }

    public double getPower() {

        if (this.overridePower != null) {
            return overridePower;
        }
        return getCalculatedPower();
    }

    public LoadType getType() {
        return type;
    }

    public boolean hasAddress(Address address) {
        return addresses.contains(address);
    }

    public boolean hasCluster() {
        return !Item.NONE.equals(clusterID);
    }

    /**
     * Active when both owner and connecter agree.
     * @return
     */
    public boolean isActive() {
        return TimeState.READY.equals(getConnectionState());
    }

    public boolean isDemand() {
        return getFlow() < 0;
    }

    public boolean isLocated() {
        return getJunction() != null && getJunctionCoordinate() != null && getBuilding() != null;
    }

    public boolean isSupply() {
        return getFlow() > 0;
    }

    public boolean removeAddress(Address address) {
        return addresses.remove(address);
    }

    public void replaceAddress(Address oldAddress, Address newAddress) {
        int oldIndex = addresses.indexOf(oldAddress);
        if (oldIndex >= 0 && oldIndex < addresses.size()) {
            addresses.remove(oldIndex);
            addresses.add(oldIndex, newAddress);
        } else {
            TLogger.warning("Old address " + oldAddress.getAddressCode() + " was not present in the addresses of "
                    + PipeLoad.class.getSimpleName() + StringUtils.WHITESPACE + getName());
        }

    }

    public void setBuildingID(Integer buildingID) {
        this.buildingID = buildingID;
    }

    public void setClusterID(Integer clusterID) {
        this.clusterID = clusterID;
    }

    public void setConnectionState(TimeState newTimeState) {
        this.connectionState = newTimeState;
    }

    public void setJunctionID(Integer junctionID) {
        this.junctionID = junctionID;
    }

    public void setMainAddress(Address address) {
        addresses.remove(address);
        addresses.add(0, address);
    }

    public void setOverrideConnectionCost(Double overrideConnectionCost) {
        this.overrideConnectionCost = overrideConnectionCost;
    }

    public void setOverrideConnectionCount(Integer overrideConnections) {
        this.overrideConnectionCount = overrideConnections;
    }

    public void setOverrideFlow(Double overrideFlow) {
        this.overrideFlow = overrideFlow;
    }

    public void setOverridePower(Double overridePower) {
        this.overridePower = overridePower;
    }

    public void setPoint(Point point) {
        this.point = point;
    }

    public void setType(LoadType type) {
        this.type = type;
    }

    @Override
    public String toString() {
        return this.getClass().getSimpleName() + StringUtils.WHITESPACE + this.getID();
    }

    @Override
    public String validated(boolean startNewGame) {

        // showstopper, stop check if it fails.
        if (this.getJunction() == null) {
            return "\nPipe Load: " + this + " is not connected to a valid junction!";
        }
        return super.validated(startNewGame);
    }
}
