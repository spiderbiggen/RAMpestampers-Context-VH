
:- dynamic stakeholders/1.
:- dynamic settings/1.
:- dynamic functions/1.
:- dynamic buildings/1.
:- dynamic indicators/1.

% we have a building if the building list has exactly 3 elements
havebuilding :- buildings([X|T]).
isdestroyed :- destroy(X), X \= none.

% demolish
% demolish :- buildings(none).

% initialize built believe
built(none).

% initialize destroy believe
destroy(none).

% initialize land believe
land(none).