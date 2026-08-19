% Please insert the names and email addresses of the group members:
%
%

%
% Input:
%   #const n: the time steps range from 0 to n
%   edge(N1,N2): there is an (undirected) edge between nodes N1 and N2
%   robot(R,C,N): robot R is of class C and starts at node N
%   job(J,C,D): job J is of class C and its deadline is D 
%   operation(J,O,N): J's operation O takes place at node N (O >= 1)
%
% Output:
%   at(R,N,T): robot R is at node N at time step T
%   assign(R,J,I): assign to R the job J at index I (in the sequence of jobs assigned to R) (I >= 1)
%

time(0..n).

% Your encoding please...


%
% show
%
#show at/3.
#show assign/3.

at(R,N,0) :- robot(R,C,N).
edge(Y,X) :- edge(X,Y).

% --------- robots movement --------------
% rob(R,C) :- robot(R,C,N). % name, class,
class(C)        :- job(_,C,_).
classjobs(C,M)  :- class(C), M = #count { J : job(J,C,_) }.

1 { at(R,Y,T+1) : edge(X,Y); at(R,X,T+1) } 1 :- at(R,X,T), time(T+1).
:- at(R1,X,T-1), at(R2,Y,T-1), at(R1,Y,T), at(R2,X,T),
   R1 != R2, X != Y, time(T).

moved(R,X,T+1) :- at(R,X,T), at(R,Y,T+1), X != Y.

:- at(R1,X,T), at(R2,X,T), R1 != R2.

% ============== assigning ==================

1 { assign(R,J,I) : robot(R,C,_), I = 1..COUNT } 1 :- job(J,C,D), classjobs(C,COUNT).

:- assign(R,J1,I), assign(R,J2,I), J1 != J2.
:- assign(R,_,I), not assign(R,_,I-1), I>1. %, rob_assigned(R).

% =========== job completion ===============

solving(R,J,0) :- assign(R,J,1).
solving(R,J,T+1) :- solving(R,J,T), lastop(J,O), not completed_op(J,O,T), time(T+1).
solving(R,JN,T+1) :- solving(R,J,T), lastop(J,O), completed_op(J,O,T), assign(R,J,I), assign(R,JN,I+1), time(T+1).

lastop(J,O) :- job(J,_,_), O = #max { O1 : operation(J,O1,_) }.

completed_op(J,1,T) :- at(R,X,T), operation(J,1,X), solving(R,J,T).
completed_op(J,O,T) :- at(R,X,T), operation(J,O,X), solving(R,J,T), completed_op(J,O-1,T1), T1<T.

:- completed_op(J,O,T), lastop(J,O), job(J,_,D), D<T.
:- lastop(J,O), not completed_op(J,O,_).

% ------ optimization -----------
#minimize { 1,X,R,T : moved(R,X,T) }.
