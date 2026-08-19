% Please insert the names and email addresses of the group members:
%
%

% Tips:
% - You may include the facts below to represent the differences
%   between the coordinates of neighboring cells
%
diff(0,1). diff(0,-1). diff(1,0). diff(-1,0).

% Your encoding please...

% translations
_first((X,Y)) :- first(X,Y).
_final((X,Y)) :- final(X,Y).
_hint((X,Y),H) :- hint(X,Y,H).
_cell((X,Y)) :- cell(X,Y).

% positions along the path: 1 = first cell, M = final cell
maxTime(M) :- M = #count{ X,Y : cell(X,Y) }.
time(1..M) :- maxTime(M).

{ path(C,C') : diff(DX,DY), C=(X,Y), C'=(X+DX,Y+DY), _cell(C') } = 1 :- _cell(C), not _final(C).

% every cell except first has exactly one incoming edge; first has none
:- _cell(C), not _first(C), #count{ P : path(P,C) } != 1.
:- path(_,C), _first(C).

% every cell must be reachable from first
reached(C) :- _first(C).
reached(C') :- reached(C), path(C,C').
:- _cell(C), not reached(C).

% position of each cell along the path
pos(C,1) :- _first(C).
pos(C',T+1) :- path(C,C'), pos(C,T), time(T+1).

% bends
diag(1,1). diag(1,-1). diag(-1,1). diag(-1,-1).
bend(T) :- path(C,C'), path(C',C''), pos(C',T), not reach_hint(T,_),
    C = (X,Y), C''=(X'',Y''),
    diag(DX,DY), DX=X''-X, DY=Y''-Y.

% ========= hint logic ================
reach_hint(T,B) :- pos(C',T),
    C' = (X,Y), hint(X,Y,B).

reach_hint(0,0).
reach_hint(M,0) :- maxTime(M).

next_hint_reached(T,T1) :- reach_hint(T,_), T1 = #min{ T' : reach_hint(T',_), T' > T }.

hint_succ(T) :- reach_hint(T,B), B = #count{ T1 : bend(T1), T1>T, T1<=T', next_hint_reached(T,T') }.
:- not hint_succ(T), reach_hint(T,_), next_hint_reached(T,T').

% convert path/2 to path/4.
path(X,Y,X1,Y1) :- path(C,C'), C=(X,Y), C'=(X1,Y1).

#show path/4.
