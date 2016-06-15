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
:- dynamic requestAnswered/2.
:- dynamic upgrades/1.
:- dynamic landToSell/3.
:- dynamic sold/1.

%Believes
:- dynamic oldBuildings/1.
:- dynamic emptySpace/3.

%Custom actions beliefs
:- dynamic relevant_areas/2.

%The goals and how to achieve them.
%we have to retrieve this only once and the goal will be dropped by hand
getIndicatorGoals :- false.
%an indicatorgoal is met if the current score is the target score
indicatorGoal(Name, Target) :- indicator(_, Name, Current, _), Target > 0, Current >= Target.
indicatorGoal(Name, Target) :- indicator(_, Name, Current, _), Target =< 0, Current =< Target.
%createLandToBuild needs a demolished polygon
createLandToBuild :- relevant_areas(0, MPList), not(empty(MPList)).
%Land we want to sell
sell(MultiPolygon) :- sold(MultiPolygon).


%Other beliefs
:- dynamic indicatorlink/1.
:- dynamic indicator/4.
:- dynamic indicatorGoal/2.


%Knowledge for answering a request
answerRequest(Category, PopupID) :- requestAnswered(Category, PopupID).

%The agent finds a price to be acceptable when the offered price is at least 50 euro higher than the ground price for offices in Delft (252)
acceptablePrice(Price, Areasize) :- Areasize * 252 + 50 < Price.

%When selling our land we'll use a generous price to please other stakeholders.
generousPrice(Price, Areasize) :- Price is round(round(Areasize) * 400).

% Takes all buildings of L that return from iseducation and removes all duplicates
getOldBuildings(Bag,List):-
	findall(Building, (member(Building, List), isEducation(Building)), Bag1),
	sort(Bag1,Bag).

% Is true for all buildings that have the EDUCATION Category and are owned by the TU Delft
isEducation(building(_,_,3,_,_,884,_,_,_)).

%creates a list of all available upgrades.
getUseableUpgrades(Buildings, Functions, UpgradeTypes, Bag):-
	findall([Multipolygon, UpgradeID, SrcID], 
		( member(building(_, _, 3, _, _, SrcID, _, Multipolygon, _), Buildings), 
		member(upgrade_type(UpgradeID, UpgradePairs), UpgradeTypes), 
		member(upgrade_pair(SrcID, TrgtID), UpgradePairs), 
		member([Name, TrgtID, _], Functions),
		sub_string(Name, _, _, _, 'groen')),
		Bag1),
	sort(Bag1, Bag).
% Beliefs for upgrades.	
upgraded([]).
% Knowledge about the size of a list
isNumber(X) :- number(X).
empty(List) :- length(List, 0).

%Gets a random number between 20 and 40
randomFloor(Floors) :- Floors is random(20)+20.

%Filters the list of areas for only large areas
getLargeAreas(OldList, NewList):- findall([MultiPolygon, Area], (member([MultiPolygon, Area], OldList), Area>200), NewList).

%List of available stakeholders
allStakeholders([0, 1, 2, 3, 4]).

%keep track of the current cycle
cycle(0).

%Every 5 cycles we want to do something, we use modulo for this.
modulo(X) :- cycle(Y), X is Y mod 5.
%Increase a number by one
increase(OldNumber, NewNumber) :- NewNumber is OldNumber+1.
%adjust the price we're selling for
adjustSellPrice(OldPrice, NewPrice) :- NewPrice is round(OldPrice/2).