% Please insert the names and email addresses of the group members:
%
%

% Tips:
% - You may include the facts below to represent the differences
%   between the coordinates of neighboring cells
%
diff(0,1). diff(0,-1). diff(1,0). diff(-1,0).

% Your encoding please...

% #show path/4.

% num_of_cells(N) :- N = #count{ 1,X,Y : cell(X,Y) }.

% N-1 = { go(X,Y,X,Y+1,0,1); go(X,Y,X,Y-1,0,-1); go(X,Y,X+1,Y,1,0); go(X,Y,X-1,Y,-1,0) } = N-1 :- cell(X,Y), num_of_cells(N).

% { go(X,Y,X+DX,Y+DY,DX,DY) : diff(DX,DY), cell(X+DX,Y+DY) } 1 :- first(X,Y).
% { go(X,Y,X+DX,Y+DY,DX,DY) : diff(DX,DY), cell(X+DX,Y+DY) } 1 :- path(_,_,X,Y).
% path(X,Y,X1,Y2) :- go(X,Y,X1,Y2,_,_).

% % 1 { path(X,Y,X1,Y1) : cell(X1,Y1), not firts(X1,Y1) } 1 :- cell(X1,Y1), cell(X,Y).

% % do I have to write X1 = X3, Y1 = Y3 or can i just use X1/Y1 twice?
% :- path(X1,Y1,X2,Y2), path(X3,Y3,X4,Y4), X1 != X3, Y1 != Y3, X2=X4, Y2=Y4.
% :- path(X,Y,X1,Y1), final(X,Y).
% % not needed
% % :- path(X1,Y1,X2,Y2), path(X3,Y3,X4,Y4), X1 = X3, Y1 = Y3, X2!=X4, Y2!=Y4.
% % I have to cover all cells
% :- cell(X,Y), not first(X,Y), not path(X1,Y1,X,Y), cell(X1,Y1).


% ======================== new start ===========================
% Please insert the names and email addresses of the group members:
%
%

% Tips:
% - You may include the facts below to represent the differences
% between the coordinates of neighboring cells
%
diff(0,1). diff(0,-1). diff(1,0). diff(-1,0).

% Your encoding please...

% translations
_first((X,Y)) :- first(X,Y).
_final((X,Y)) :- final(X,Y).
_hint((X,Y),H) :- hint(X,Y,H).
_cell((X,Y)) :- cell(X,Y).

% time
maxTime(M) :- M = #count{ X,Y : cell(X,Y) }.
time(1..M-1) :- maxTime(M).

maxHint(H) :- H = #count{ X,Y : hint(X,Y,_) }.
hint_c(1..H) :- maxHint(H).

{ path(C,C',1) : _cell(C') } = 1 :- _first(C).
{ path(C,C',T) : _cell(C') } = 1 :- time(T), T > 1, path(_,C,T-1).

% paths must be between neighboring cells 3000
:- path(C,C',_), not diff(DX,DY),
    C=(X1,Y1), C'=(X2,Y2),
    DX = X2-X1, DY = Y2-Y1.

% path must end in the final cell 500
:- _final(C), not path(_,C,M-1), maxTime(M).

% paths cannot intersect 2
:- path(C,_,T), path(C,_,T'), T > T'.
:- path(_,C,T), path(_,C,T'), T > T'.

% bends
diag(1,1). diag(1,-1). diag(-1,1). diag(-1,-1).
bend(T) :- path(C,C',T-1), path(C',C'',T), not reach_hint(T-1,_),
    C = (X,Y), C''=(X'',Y''),
    diag(DX,DY), DX=X''-X, DY=Y''-Y.

% { reach_hint(T,B,P) } 1 :- path(C, C', T),
%     C' = (X,Y), hint(X,Y,B), reach_hint(TX,_,P-1), hint_c(P).

reach_hint(T,B) :- path(C, C', T),
    C' = (X,Y), hint(X,Y,B).

% :- reach_hint(T,B,P'), reach_hint(T,B,P), P' > P.
% :- path(_,C,T), path(_,C,T'), T > T'.

% reach_hint(0,0,0).
reach_hint(0,0).
reach_hint(T-1,0) :- maxTime(T).

next_hint_reached(T,T1) :- reach_hint(T,_), T1 = #min{ T' : reach_hint(T',_), T' > T }.
% { next_hint_reached(T,T1) : maxTime(T1) } 1 :- reach_hint(T,_).

% next_hint_reached(T,T1) :- reach_hint(T,_), reach_hint(T1,_), not reach_hint(T2,_), T2 < T1, time(T2).


% :- reach_hint(T,_), next_hint_reached(T,T1), next_hint_reached(T,T2), T2>T1.
% :- next_hint_reached(T,T1), next_hint_reached(T,T2), T2!=T1.
% :- next_hint_reached(T,T1), T1<=T.

% next_hint_reached(T,T') :- reach_hint(T,_), reach_hint(T',_).
% next_hint_reached(T,T') :- reach_hint(T,_), maxTime(T').

hint_succ(T) :- reach_hint(T,B), B = #count{ T1 : bend(T1), T1>T, T1<=T', next_hint_reached(T,T') }.
:- not hint_succ(T), reach_hint(T,_), next_hint_reached(T,T').

% hint_succ(T) :- reach_hint(T,B), B = #count{ T1 : bend(T1), T1>T, T1<=T', next_hint_reached(T,T') }.

% convert path/3. to path/4.

path(X,Y,X1,Y1) :- path(C,C',_), C=(X,Y), C'=(X1,Y1).

% #show bend/1.
% #show path/3.
#show path/4.
