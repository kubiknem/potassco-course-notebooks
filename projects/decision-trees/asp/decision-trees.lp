% Please insert the names and email addresses of the group members:
%
%

% ============ tree gen ================

node(1..n).

{ edge(N,N1) : node(N1), N1>N } 2 :- node(N).

:- edge(N,N1), node(N1+1), not edge(N,N1+1), N1\2==0.

% used(N) :- edge(N,_).
% :- edge(N1,N2), node(N), N<N1, not used(N).

:- node(N), N>1, not edge(_,N).
:- edge(N1,N2), edge(N3,N4), N1<N3, N4<=N2.

% ============== decision gen ========================

1 { decision(N,A) : holds(_,A) } 1 :- node(N), edge(N,_).
{ positive(N) } :- node(N), not edge(N,_).

% =============== tree traversal =====================

path(E,1) :- example(E,_).
path(E,NEXT) :- path(E,START), decision(START,A), edge(START,NEXT), NEXT\2==0, not holds(E,A).
path(E,NEXT) :- path(E,START), decision(START,A), edge(START,NEXT), NEXT\2==1, holds(E,A).

res(E,pos) :- path(E,N), positive(N).
res(E,neg) :- example(E,_), not res(E,pos).

:- example(E,pos), res(E,neg).
:- example(E,neg), res(E,pos).
:- example(E,_), not res(E,_).


% Your encoding please...

#show edge/2.
#show decision/2.
#show positive/1.


