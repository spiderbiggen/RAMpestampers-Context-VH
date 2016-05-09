/*******************************************************************************
 * Copyright 2006-2016 TyTech B.V., Saturnusstraat 60, 2516 AH, The Hague, The Netherlands All rights reserved. This software is proprietary
 * information of TyTech B.V..
 ******************************************************************************/
package nl.tytech.data.editor.event;

import java.util.Arrays;
import java.util.List;
import nl.tytech.core.event.Event.EventTypeEnum;
import nl.tytech.core.item.annotations.EventIDField;

/**
 *
 * @author Jeroen Warmerdam
 *
 */
public enum EditorSoundEventType implements EventTypeEnum {

    ADD(),

    @EventIDField(links = { "SOUNDS" }, params = { 0 })
    REMOVE(Integer[].class),

    @EventIDField(links = { "SOUNDS" }, params = { 0 })
    SET_LOOP(Integer.class, Boolean.class),

    @EventIDField(links = { "SOUNDS" }, params = { 0 })
    SET_NAME(Integer.class, String.class),

    @EventIDField(links = { "SOUNDS" }, params = { 0 })
    SET_FILENAME(Integer.class, String.class),

    @EventIDField(links = { "SOUNDS" }, params = { 0 })
    SET_VOLUME(Integer.class, Double.class);

    private List<Class<?>> classes;

    private EditorSoundEventType(Class<?>... classes) {
        this.classes = Arrays.asList(classes);
    }

    @Override
    public boolean canBePredefined() {
        return false;
    }

    @Override
    public List<Class<?>> getClasses() {
        return classes;
    }

    @Override
    public Class<?> getResponseClass() {
        return null;
    }

    @Override
    public boolean isServerSide() {
        return true;
    }

}
