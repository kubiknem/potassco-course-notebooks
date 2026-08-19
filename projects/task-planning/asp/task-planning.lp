% Please insert the names and email addresses of the group members:
%
%

%
% Display
%

#show starts/2.
#show assign/2.

day(1..M) :- final(M).

% ======= generation =====================
1 { starts(T,Day) : Day=1..D-(L-1) } 1 :- task(T,L,Deadline), final(M), D=#min{ M;Deadline }.
N { assign(T,W) : worker(W,C) } :- task(T,_,_), requires(T,N,C).
M { assign(T,W) : worker(W,_) } M :- task(T,_,_), requires(T,M).

% ======== solution check ================
finishes(T,D) :- starts(T,Day), task(T,L,_), D=Day+(L-1).
:- finishes(T1,D1), before(T1,T2), starts(T2,D2), D1>=D2.

covers(T,Day) :- task(T,L,_), starts(T,D), Day=D..D+(L-1).
:- at_most(R,M), day(Day), #count{ T : covers(T,Day), uses(T,R) } > M.

:- holiday(W,D), assign(T,W), covers(T,D).
:- assign(T1,W), assign(T2,W), covers(T1,D), covers(T2,D), T1 != T2.