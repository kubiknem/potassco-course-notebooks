% Please insert the names and email addresses of the group members:
%
%

%
% Guess solution candidates
%

% -------- movement of the Theseus ------------

step(0..M) :- maxsteps(M).
wall(X2,Y2,X1,Y1) :- wall(X1,Y1,X2,Y2).

diff(0,1). diff(0,-1). diff(1,0). diff(-1,0). diff(0,0).
onediff(1). onediff(-1).
at(X,Y,0) :- start(X,Y).
{ at(X+DX,Y+DY,S+1) : diff(DX,DY), field(X+DX,Y+DY), not wall(X,Y,X+DX,Y+DY) } 1 :- at(X,Y,S), not goal(X,Y), maxsteps(M), S<M.

% we must reach our goal
:- not at(X,Y,_), goal(X,Y).

% -------- movement of the Minotaurus ------------

minoat(X,Y,0) :- mino(X,Y).

% ================== slower ================================
% each mino step is decided in corresponding current step

minogohoz1(MX+DX,MY,S) :- not wall(MX,MY,MX+DX,MY), onediff(DX), |TX-(MX+DX)| < |TX-MX|, at(TX,TY,S), minoat(MX,MY,S-1).
minogovec1(MX,MY+DY,S) :- not wall(MX,MY,MX,MY+DY), onediff(DY), |TY-(MY+DY)| < |TY-MY|, at(TX,TY,S), minoat(MX,MY,S-1), not minogohoz1(_,_,S).
minostay1(MX,MY,S) :- at(TX,TY,S), minoat(MX,MY,S-1), not minogohoz1(_,_,S), not minogovec1(_,_,S).

minoat(X,Y,S) :- minostay1(X,Y,S).
minogohoz2(MX+DX,MY,S) :-
    not wall(MX,MY,MX+DX,MY), onediff(DX),
    |TX-(MX+DX)| < |TX-MX|, at(TX,TY,S),
    minogohoz1(MX,MY,S).

minogohoz2(MX+DX,MY,S) :-
    not wall(MX,MY,MX+DX,MY), onediff(DX),
    |TX-(MX+DX)| < |TX-MX|, at(TX,TY,S),
    minogovec1(MX,MY,S).

minoat(X,Y,S) :- minogohoz2(X,Y,S).

minogovec2(MX,MY+DY,S) :-
    not wall(MX,MY,MX,MY+DY), onediff(DY),
    |TY-(MY+DY)| < |TY-MY|, at(TX,TY,S),
    minogohoz1(MX,MY,S), not minogohoz2(_,_,S).

minogovec2(MX,MY+DY,S) :-
    not wall(MX,MY,MX,MY+DY), onediff(DY),
    |TY-(MY+DY)| < |TY-MY|, at(TX,TY,S),
    minogovec1(MX,MY,S), not minogohoz2(_,_,S).

minoat(X,Y,S) :- minogovec2(X,Y,S).

minoat(MX,MY,S) :- minogohoz1(MX,MY,S), not minogohoz2(_,_,S), not minogovec2(_,_,S).
minoat(MX,MY,S) :- minogovec1(MX,MY,S), not minogohoz2(_,_,S), not minogovec2(_,_,S).
% ========================================================

%
% Check solution candidates
%

% Theseus is eaten by Minotaurus
:- minoat(X,Y,S), at(X,Y,S).

%
% Optimize solutions
%

#minimize{ 1,S : at(X,Y,S) }.

%
% Display
%

#show at/3.
