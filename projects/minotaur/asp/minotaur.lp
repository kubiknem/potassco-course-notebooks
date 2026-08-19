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

% deterministic pre-calculation of steps
mino_step(MX,MY,TX,TY,MX+1,MY) :- field(MX,MY), field(TX,TY), MX<TX, not wall(MX,MY,MX+1,MY).
mino_step(MX,MY,TX,TY,MX-1,MY) :- field(MX,MY), field(TX,TY), MX>TX, not wall(MX,MY,MX-1,MY).

mino_can_hoz(MX,MY,TX) :- mino_step(MX,MY,TX,_,MX+DX,MY), onediff(DX).

mino_step(MX,MY,TX,TY,MX,MY+1) :- field(MX,MY), field(TX,TY), MY<TY, not wall(MX,MY,MX,MY+1), not mino_can_hoz(MX,MY,TX).
mino_step(MX,MY,TX,TY,MX,MY-1) :- field(MX,MY), field(TX,TY), MY>TY, not wall(MX,MY,MX,MY-1), not mino_can_hoz(MX,MY,TX).


mino_mid_step(NMX,NMY,S) :- at(TX,TY,S), minoat(MX,MY,S-1), mino_step(MX,MY,TX,TY,NMX,NMY).
mino_mid_step(MX,MY,S) :- at(TX,TY,S), minoat(MX,MY,S-1), not mino_step(MX,MY,TX,TY,_,_).
minoat(NMX,NMY,S) :- at(TX,TY,S), mino_mid_step(MX,MY,S), mino_step(MX,MY,TX,TY,NMX,NMY).
minoat(MX,MY,S) :- at(TX,TY,S), mino_mid_step(MX,MY,S), not mino_step(MX,MY,TX,TY,_,_).

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
