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
indicatorgoal(Name, Target) :- indicator(Id, Name, Current, _), Current >= Target.
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

%creates a list of all available upgrades.
get_useable_upgrades(Buildings, Functions, UpgradeTypes, Bag):-
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








