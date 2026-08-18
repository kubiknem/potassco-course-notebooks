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
%   assign(R,J,I): assign to R the job J at index I (in the sequence of jobs assigned to R)
%

% this file computes EXCESSIVE models

time(0..n).

% ---------------------------------------------------------------
% domain / helper predicates
% ---------------------------------------------------------------

edge(Y,X) :- edge(X,Y).                 % undirected closure

node(N) :- edge(N,_).
node(N) :- robot(_,_,N).
node(N) :- operation(_,_,N).

class(C)        :- job(_,C,_).
classjobs(C,M)  :- class(C), M = #count { J : job(J,C,_) }.
lastop(J,O)     :- job(J,_,_), O = #max { O1 : operation(J,O1,_) }.

% nodes reachable by robot R within T steps (used only to restrict the
% domain of the "at" choice below -- any real trajectory stays inside it)
reach(R,N,0)     :- robot(R,_,N).
reach(R,N2,T+1)  :- reach(R,N,T), edge(N,N2), time(T+1).
reach(R,N,T+1)   :- reach(R,N,T), time(T+1).

% ---------------------------------------------------------------
% movement of the robots
% ---------------------------------------------------------------

at(R,N,0) :- robot(R,_,N).

1 { at(R,N,T) : node(N), reach(R,N,T) } 1 :- robot(R,_,_), time(T), T > 0.

% a robot can only move to an adjacent node (or stay)
:- at(R,N,T), at(R,N2,T+1), N != N2, not edge(N,N2), time(T), time(T+1).

% two robots cannot occupy the same node at the same time
:- at(R1,N,T), at(R2,N,T), R1 != R2.

% two robots cannot swap positions
:- at(R1,N1,T), at(R2,N2,T), at(R1,N2,T+1), at(R2,N1,T+1),
   R1 < R2, N1 != N2, time(T), time(T+1).

% ---------------------------------------------------------------
% assignment of jobs to robots
% ---------------------------------------------------------------

% every job of class C is given to exactly one robot of class C,
% at exactly one index I (I bounded by the number of jobs of class C)
1 { assign(R,J,I) : robot(R,C,_), I = 1..M } 1 :- job(J,C,_), classjobs(C,M).

% two different jobs assigned to the same robot cannot share an index
:- assign(R,J1,I), assign(R,J2,I), J1 != J2.

% the indices used by a robot must form a gap-free sequence 1,2,3,...
hasindex(R,I) :- assign(R,_,I).
:- hasindex(R,I), I > 1, not hasindex(R,I-1).

% ---------------------------------------------------------------
% completion of the jobs
% ---------------------------------------------------------------

% "does(R,J,O,T)" : robot R performs operation O of job J at time T.
% Its domain is restricted to time steps where R is actually located
% at the node required by that operation.
1 { does(R,J,O,T) : time(T), at(R,N,T), not at(R,N,T-1) } 1 :- assign(R,J,_), operation(J,O,N).

% operations of the same job must be performed in increasing order of time
:- does(R,J,O,T), does(R,J,O-1,T2), O > 1, T <= T2.

% the first operation of a job assigned at index I>1 must happen strictly
% after the last operation of the job assigned (to the same robot) at index I-1
:- does(R,J,1,T), assign(R,J,I), I > 1,
   assign(R,J2,I-1), lastop(J2,O2), does(R,J2,O2,T2), T <= T2.

% the last operation of a job must be performed before or at its deadline
:- does(R,J,O,T), lastop(J,O), job(J,_,D), T > D.

% ---------------------------------------------------------------
% optimization: minimize the total number of robot movements
% ---------------------------------------------------------------

moved(R,T) :- at(R,N,T), at(R,N2,T+1), N != N2, time(T), time(T+1).

#minimize { 1,R,T : moved(R,T) }.

%
% show
%
#show at/3.
#show assign/3.
% #show does/4.
