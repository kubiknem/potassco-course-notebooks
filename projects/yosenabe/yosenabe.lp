% Please insert the names and email addresses of the group members:
%
%

dir(0,1). dir(0,-1). dir(1,0). dir(-1,0).

% HINTS:
% - You may use the gaps of adjacent cells' coordinates to denote directions.
% - Develop your encoding incrementally and check the additions.
% - You can use the "--text" option of clingo to inspect the ground program.
%   For this it is better to use small instances.


% Your encoding please...

% ======== target moves generation ===============
1 { target(X,Y,X,YY) : area(X,YY,_); target(X,Y,XX,Y) : area(XX,Y,_) } 1 :- number(X,Y,N). 

% ------------ line covers calculation -----------------
covers(C,X..XX,Y..YY) :- target(X,Y,XX,YY), C=(X,Y).
covers(C,XX..X,Y..YY) :- target(X,Y,XX,YY), C=(X,Y).
covers(C,X..XX,YY..Y) :- target(X,Y,XX,YY), C=(X,Y).
covers(C,XX..X,YY..Y) :- target(X,Y,XX,YY), C=(X,Y).

% ----------- solution check ---------------
:- goal(A,G), #sum{ N,X,Y : target(X,Y,AX,AY), number(X,Y,N), area(AX,AY,A) } != G.
:- covers(C1,X,Y), covers(C2,X,Y), C1!=C2.

area_occupied(A) :- target(_,_,XX,YY), area(XX,YY,A).
area_id(A) :- area(_,_,A).
:- area_id(A), not area_occupied(A).

#show target/4.
