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

buildhigh :- bouwhoogindicator(100).
buildeducation :- bouwtudelftindicator(100).
buildgreen :- groenindicator(100).

findbuildings([],L,L).

findbuildings([H|T],L,L2) :- iseducation(H),
		append(L,H,N),
		findbuildings(T,N,L2).

	
findbuildings([H|T],L,L2) :- findbuildings(T,L,L2).



findbuilding([H|T],B) :- iseducation(H),
	B is H.
	
findbuilding([H|T],B) :- findbuilding(T,B).

iseducation(building(A,B,C,['EDUCATION'|C],D)).