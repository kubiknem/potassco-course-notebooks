% INSERT NAMES AND EMAIL ADDRESSES OF YOUR GROUP MEMBERS:
%
%

% Your implementation please...

% obstacles and field boundaring
cell(1..R,1..C) :- rows(R), cols(C).
obstacle(X,Y) :- digit(X,Y,_).
obstacle(X,Y) :- empty(X,Y).
obstacle(0,1..C) :- cols(C).
obstacle(R+1,1..C) :- cols(C), rows(R).
obstacle(1..R,0) :- cols(C), rows(R).
obstacle(1..R,C+1) :- cols(C), rows(R).
% #show obstacle/2.

diff(0,1). diff(0,-1). diff(1,0). diff(-1,0).


% ================= light placement generation ============
{ light(X,Y) : cell(X,Y), not obstacle(X,Y) }.
N { light(X+DX,Y+DY) : diff(DX,DY), cell(X+DX,Y+DY), not obstacle(X+DX,Y+DY) } N :- digit(X,Y,N).

% ========== enlightenment check ================

% light doenst enlight itself
enlights((DX+1)..LX-1,Y) :- light(LX,Y), DX = #max{ OX : obstacle(OX,Y), OX < LX  }.
enlights(LX+1..(DX-1),Y) :- light(LX,Y), DX = #min{ OX : obstacle(OX,Y), OX > LX  }.

enlights(X,(DY+1)..LY-1) :- light(X,LY), DY = #max{ OY : obstacle(X,OY), OY < LY  }.
enlights(X,LY+1..(DY-1)) :- light(X,LY), DY = #min{ OY : obstacle(X,OY), OY > LY  }.

% every cell must be enlighted
:- cell(X,Y), not obstacle(X,Y), not light(X,Y), not enlights(X,Y).
% other light cannot enlight another light 
:- enlights(X,Y), light(X,Y).

#show light/2.
% #show enlights/2.
