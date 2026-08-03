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

rob(R,C) :- robot(R,C,N). % name, class,
job_count(C) :- C = #count { 1,J : job(J,_,_) }.

edge(Y,X) :- edge(X,Y).
{ moved(R,Y,T) } 1 :- edge(X,Y), at(R,X,T-1), time(T), T>0. % this shows where the robot will be in next step
% :- moved(R,Y,T), at(R1,Y,T-1), time(T).
:- at(R1,X,T-1), at(R2,Y,T-1), at(R1,Y,T), at(R2,X,T),
   R1 != R2, X != Y, time(T).
at(R,X,T) :- moved(R,X,T).
{ at(R,X,T) } 1 :- at(R,X,T-1), time(T).

:- at(R,X,T), at(R,Y,T), X != Y.
:- at(R1,X,T), at(R2,X,T), R1 != R2.
:- time(T), not at(R,_,T), rob(R,_).

{ assign(R,J,I) : rob(R,C), I = 1..COUNT } 1 :- job(J,C,D), job_count(COUNT).
:- assign(R,J1,I), assign(R,J2,I), J1 != J2.
% :- assign(_,J1,_), assign(_,J2,_), J1 != J2.
% min_ass(I,R) :- I = #minimize{ A,R : assign(R,J,A), rob(R,:- I != 1, #min{ I,}
rob_assigned(R) :- assign(R,_,_).
:- assign(R,_,I), not assign(R,_,I-1), I>1, rob_assigned(R).

%, jcounter(R,I,T1), not jcounter(R,I+1,T2), T1 != T2, time(T2).
% jcounter(R,0,0) :- robot(R,C,N).
% jcounter(R,I,T+1) :- assign(R,J,I), jcounter(R,I-1,T), I<=C, I>=0, job_count(C).

{ completed_op(J,O,T) } :- at(R,X,T), operation(J,O,X), assign(R,J,_).
incompleted_op(J,O,T1) :- not completed_op(J,O,T2), operation(J,O,_), time(T1), time(T2), T1<T2.

:- completed_op(J,O,T2), completed_op(J,O,T1), T1 != T2.

% :- completed_op(J,O1,T1), not completed_op(J,O1-1,T2), O1>1, T2<T1, time(T2).
prev_done(J,O1,T1) :- operation(J,O1,_), O1>1, time(T1),
                       completed_op(J,O1-1,T2), T2 < T1.
:- completed_op(J,O1,T1), O1>1, not prev_done(J,O1,T1).

:- completed_op(J,O1,T1), completed_op(J,O2,T2), O1 != O2, T1 = T2.

completed_job(J,T) :- { incompleted_op(J,O,T2) : operation(J,O,_), T2<T } = 0, job(J,_,D), T = #max{ T1 : completed_op(J,_,T1) }.

% :- not completed_op(J,O,T), operation(J,O,_).
:- not completed_job(J,_), job(J,_,_). %, time(T).
:- completed_job(J,T), job(J,_,D), D<T.



#minimize { 1,X,R,T : moved(R,X,T) }.

% { assign(R,J,)}
