
:- dynamic stakeholders/1.
:- dynamic settings/1.
:- dynamic functions/1.
:- dynamic buildings/1.

% we have a building if the building list has at least 1 element.
havebuilding :- buildings([X,Y,Z]).

% demolish
% demolish :- buildings(none).

% initialize built believe
built(none).

destroy(none).

% initialize land believe
land(none).