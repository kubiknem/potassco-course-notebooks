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

edge(Y,X) :- edge(X,Y).                 % undirected closure

node(N) :- edge(N,_).
node(N) :- robot(_,_,N).
node(N) :- operation(_,_,N).

class(C)        :- job(_,C,_).
classjobs(C,M)  :- class(C), M = #count { J : job(J,C,_) }.
lastop(J,O)     :- job(J,_,_), O = #max { O1 : operation(J,O1,_) }.

% nodes reachable by robot R within T steps
reach(R,N,0)     :- robot(R,_,N).
reach(R,N2,T+1)  :- reach(R,N,T), edge(N,N2), time(T+1).
reach(R,N,T+1)   :- reach(R,N,T), time(T+1).

% --------- robots movement --------------

at(R,N,0) :- robot(R,_,N).

1 { at(R,N,T) : node(N), reach(R,N,T) } 1 :- robot(R,_,_), time(T), T > 0.

:- at(R,N,T), at(R,N2,T+1), N != N2, not edge(N,N2), time(T), time(T+1).
:- at(R1,N,T), at(R2,N,T), R1 != R2.

% two robots cannot swap positions
:- at(R1,N1,T), at(R2,N2,T), at(R1,N2,T+1), at(R2,N1,T+1),
   R1 < R2, N1 != N2, time(T), time(T+1).

moved(R,X,T+1) :- at(R,X,T), at(R,Y,T+1), X != Y.

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

% #show completed_job/2.
% #show completed_op/3.
% #show solving/3.

:- completed_op(J,O,T), lastop(J,O), job(J,_,D), D<T.
:- lastop(J,O), not completed_op(J,O,_).

#minimize { 1,X,R,T : moved(R,X,T) }.

