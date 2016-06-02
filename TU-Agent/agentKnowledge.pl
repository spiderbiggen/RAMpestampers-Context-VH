%These are the percepts we receive.
:- dynamic stakeholders/1.
:- dynamic settings/1.
:- dynamic functions/1.
:- dynamic buildings/1.
:- dynamic indicators/1.
:- dynamic lands/1.
:- dynamic zones/1.
:- dynamic requests/1.
:- dynamic actions/1.
:- dynamic upgrade_types/1.
%The indicator percepts
:- dynamic bouwhoogindicator/1.
:- dynamic bouwtudelftindicator/1.
:- dynamic groenindicator/1.
:- dynamic budgetindicator/1.
:- dynamic slopenindicator/1.
:- dynamic oldbuildings/1.
:- dynamic demolishedPolygon/1.
:- dynamic no_old_buildings/0.

%The goals and how to achieve them.
%we have to retrieve this only once and the goal will be dropped by hand
getindicatorgoals :- false.
%an indicatorgoal is met if the current score is the target score
indicatorgoal(Name, Target) :- indicator(Id, Name, Target, _).
%createLandToBuild needs a demolished polygon
createLandToBuild :- demolishedPolygon(_).
%Other beliefs
:- dynamic indicatorlink/1.
:- dynamic indicator/4.
:- dynamic indicatorgoal/2.

%this believe ensures that indicatorlink gets generated only once
%it gets deleted after indicatorlink is inserted as believe
readIndicatorlink.

% Takes all buildings of L that return from iseducation and removes all duplicates
get_old_buildings(Bag,L):-
	findall(Building, (member(Building, L), iseducation(Building)), Bag1),
	sort(Bag1,Bag).

% Is true for all buildings that have the EDUCATION Category and are owned by the TU Delft
iseducation(building(_,_,3,_,_,884,_,_)).

% Beliefs for upgrades.
get_useable_upgrades(Buildings, Functions, UpgradeTypes, Bag):-
	findall(Name, 
		(	
			member(building(ID,_, 3, _, _, SrcID, _, MultiPolygon), Buildings), 
			member(upgrade_type(UpgradeID, Z), UpgradeTypes), 
			member(upgrade_pair(SrcID, TrgtID), Z), 
			member([Name,TrgtID,L], Functions)
		), 
		Bag).
	
upgradebuilding :- upgrades([H|T]).
upgrades([]).
readUpgrades.







