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
:- dynamic upgradeTypes/1.
:- dynamic noBuildings/0.

%Believes
:- dynamic oldBuildings/1.
:- dynamic availableLandPolygon/1.
:- dynamic noOldBuildings/0.

%The goals and how to achieve them.
%we have to retrieve this only once and the goal will be dropped by hand
getIndicatorGoals :- false.
%an indicatorgoal is met if the current score is the target score
indicatorGoal(Name, Target) :- indicator(_, Name, Current, _), Target > 0, Current >= Target.
indicatorGoal(Name, Target) :- indicator(_, Name, Current, _), Target =< 0, Current =< Target.
%createLandToBuild needs a demolished polygon
createLandToBuild :- availableLandPolygon(_).
%Other beliefs
:- dynamic indicatorlink/1.
:- dynamic indicator/4.
:- dynamic indicatorGoal/2.

%this believe ensures that indicatorlink gets generated only once
%it gets deleted after indicatorlink is inserted as believe
readIndicatorlink.

% Takes all buildings of L that return from iseducation and removes all duplicates
getOldBuildings(Bag,List):-
	findall(Building, (member(Building, List), isEducation(Building)), Bag1),
	sort(Bag1,Bag).

% Is true for all buildings that have the EDUCATION Category and are owned by the TU Delft
isEducation(building(_,_,3,_,_,884,_,_)).

%creates a list of all available upgrades.
getUseableUpgrades(Buildings, Functions, UpgradeTypes, Bag):-
	findall([Multipolygon, UpgradeID, SrcID], 
		( member(building(_, _, 3, _, _, SrcID, _, Multipolygon), Buildings), 
		member(upgrade_type(UpgradeID, UpgradePairs), UpgradeTypes), 
		member(upgrade_pair(SrcID, TrgtID), UpgradePairs), 
		member([Name, TrgtID, _], Functions),
		sub_string(Name, _, _, _, 'groen')),
		Bag1),
	sort(Bag1, Bag).
% to ensure we only create one upgrades list 
readUpgrades.
% Beliefs for upgrades.	
upgrades([]).
upgraded([]).








