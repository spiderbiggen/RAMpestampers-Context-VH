% Global Variables
% Define callIDs for the different get_relevant_area actions
callIDAreaBuild(0).
callIDAreaBuy(1).
% List of available stakeholders.
allStakeholders([0, 1, 2, 3, 4]).

% These are the percepts we receive.
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

% Believes.
:- dynamic oldBuildings/1.
:- dynamic emptySpace/3.
:- dynamic budget/1.
:- dynamic landToSell/4.
:- dynamic sold/1.
:- dynamic requestAnswered/2.
:- dynamic upgrades/1.
:- dynamic budgetChange/1.
:- dynamic cycle/1.
:- dynamic indicatorlink/1.
:- dynamic indicator/4.
:- dynamic indicatorGoal/2.
:- dynamic landBought/1.
:- dynamic land/0.

% Custom actions believes.
:- dynamic relevant_areas/2.

% Goals and their conditions.
% IndicatorGoal is met if the current score is the target score.
% In some special cases the Target is 0 and the current should be lower.
indicatorGoal(Name, Target) :- indicator(_, Name, Current, _), Target > 0, Current >= Target.
indicatorGoal(Name, Target) :- indicator(_, Name, Current, _), Target =< 0, Current =< Target.
% CreateLandToBuild needs relevant areas to build on.
createLandToBuild :- relevant_areas(0, MPList), not(empty(MPList)).
% Land we want to sell should be sold.
sell(MultiPolygon) :- sold(MultiPolygon).
% A request is answered when we believe it is.
answerRequest(Category, PopupID) :- requestAnswered(Category, PopupID).

% Knowledge about lists.
% See if a list is empty.
empty(List) :- length(List, 0).

% Logic on numbers.
isNumber(Var) :- number(Var).
% Every 5 cycles we want to do something, we use modulo for this.
modulo(Rest) :- cycle(CycleNumber), Rest is CycleNumber mod 5.
% Increase a number by one.
increase(OldNumber, NewNumber) :- NewNumber is OldNumber+1.
% adjust the price we're selling for.
adjustSellPrice(OldPrice, NewPrice) :- NewPrice is round(OldPrice/2).
% Reduce the first number with the value of the second.
minus(FirstNumber, SecondNumber, Change) :- Change is FirstNumber-SecondNumber.
% Multiply the first number with the second number.
multiply(FirstNumber, SecondNumber, Result) :- result is FirstNumber*SecondNumber.

% General knowledge we need.
% The agent finds a price to be acceptable when the offered price is at least 50 euro higher than the ground price for offices in Delft (252).
acceptablePrice(Price, Areasize) :- Areasize * 252 + 50 < Price.
% Since we're selling land when we have no use for it, we'll use a generous price.
generousPrice(Price) :- Price is 400.
% Takes all buildings of L that return from iseducation and removes all duplicates.
getOldBuildings(Bag,List):-
	findall(Building, (member(Building, List), isEducation(Building)), Bag1),
	sort(Bag1,Bag).
% Is true for all buildings that have the EDUCATION Category and are owned by the TU Delft.
isEducation(building(_,_,3,_,_,884,_,_,_)).
%creates a list of all available upgrades.
getUseableUpgrades(Buildings, Functions, UpgradeTypes, Bag):-
	findall([Multipolygon, UpgradeID, SourceID], 
		( member(building(_, _, 3, _, _, SourceID, _, Multipolygon, _), Buildings), 
		member(upgrade_type(UpgradeID, UpgradePairs), UpgradeTypes), 
		member(upgrade_pair(SourceID, TargetID), UpgradePairs), 
		member([Name, TargetID, _], Functions),
		sub_string(Name, _, _, _, 'luxe')),
		Bag1),
	sort(Bag1, Bag).
% List of applied upgrades.	
upgraded([]).
% Gets a random number between 20 and 40.
randomFloor(Floors) :- Floors is random(20)+20.
% Filters the list of areas for only large areas.
getLargeAreas(OldList, NewList):- findall([MultiPolygon, Area], (member([MultiPolygon, Area], OldList), Area>200), NewList).

