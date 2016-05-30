:- dynamic stakeholders/1.
:- dynamic settings/1.
:- dynamic functions/1.
:- dynamic buildings/1.
:- dynamic indicators/1.
:- dynamic bouwhoogindicator/1.
:- dynamic bouwtudelftindicator/1.
:- dynamic groenindicator/1.
:- dynamic budgetindicator/1.
:- dynamic slopenindicator/1.
:- dynamic oldbuildings/1.

buildhigh :- bouwhoogindicator(100).
buildeducation :- bouwtudelftindicator(100).
buildgreen :- groenindicator(100).

% Takes all buildings of L that return from iseducation
get_old_buildings(Bag,L):-
	findall(Building, (member(Building, L), iseducation(Building)), Bag).

% Is true for all buildings that have the EDUCATION Category and are owned by the TU Delft
iseducation(building(_,_,3,_,['EDUCATION'|_],_)).

demolished(none).
demolishewi :- demolished(ewi).

