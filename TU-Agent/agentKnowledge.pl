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
%The indicator percepts
:- dynamic bouwhoogindicator/1.
:- dynamic bouwtudelftindicator/1.
:- dynamic groenindicator/1.
:- dynamic budgetindicator/1.
:- dynamic slopenindicator/1.
%The goals and how to achieve them.
%once we see one indicatorgoal we can assume we've adopted them all.
getindicatorgoals :- indicatorgoal(_,_).
%Other beliefs
:- dynamic indicatorlink/1.
:- dynamic indicator/4.
:- dynamic indicatorgoal/2.

%this believe ensures that indicatorlink gets generated only once
%it gets deleted after indicatorlink is inserted as believe
readIndicatorlink.

demolished(none).
demolishewi :- demolished(ewi).
