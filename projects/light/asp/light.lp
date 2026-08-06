% INSERT NAMES AND EMAIL ADDRESSES OF YOUR GROUP MEMBERS:
%
%

% Your implementation please...

cell(1..R,1..C) :- rows(R), cols(C).
obstacle(X,Y) :- digit(X,Y,_).
obstacle(X,Y) :- empty(X,Y).
obstacle(0,1..C) :- cols(C).
obstacle(R+1,1..C) :- cols(C), rows(R).
obstacle(1..R,0) :- cols(C), rows(R).
obstacle(1..R,C+1) :- cols(C), rows(R).
% #show obstacle/2.

diff(0,1). diff(0,-1). diff(1,0). diff(-1,0).


{ light(X,Y) : cell(X,Y), not obstacle(X,Y) }.
N { light(X+DX,Y+DY) : diff(DX,DY), cell(X+DX,Y+DY), not obstacle(X+DX,Y+DY) } N :- digit(X,Y,N).

% light(1,2).
% covers(LX,Y,(DX+1)..LX,Y) :- light(LX,Y), DX = #max{ OX : obstacle(OX,Y), OX < LX  }.
% covers(LX,Y,LX..(DX-1),Y) :- light(LX,Y), DX = #min{ OX : obstacle(OX,Y), OX > LX  }.

% covers(X,LY,X,DY+1..LY) :- light(X,LY), DY = #max{ OY : obstacle(X,OY), OY < LY  }.
% covers(X,LY,X,LY..DY-1) :- light(X,LY), DY = #min{ OY : obstacle(X,OY), OY > LY  }.

covers((DX+1)..LX-1,Y) :- light(LX,Y), DX = #max{ OX : obstacle(OX,Y), OX < LX  }.
covers(LX+1..(DX-1),Y) :- light(LX,Y), DX = #min{ OX : obstacle(OX,Y), OX > LX  }.

covers(X,(DY+1)..LY-1) :- light(X,LY), DY = #max{ OY : obstacle(X,OY), OY < LY  }.
covers(X,LY+1..(DY-1)) :- light(X,LY), DY = #min{ OY : obstacle(X,OY), OY > LY  }.

:- cell(X,Y), not obstacle(X,Y), not light(X,Y), not covers(X,Y).
:- covers(X,Y), light(X,Y).

#show light/2.
% #show covers/2.

% query :- light(2,1), light(3,4), light(4,3).
% :- not query.
% :- #count{ 1,X,Y : light(X,Y) } > 3.
