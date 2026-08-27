% Please insert the names and email addresses of the group members:
%
%


%
% Guess solution candidates
%

maxSlot(M) :- M = #max{ S : slot(S) }.
maxDay(D) :- D = #max{ S : day(S) }.
maxAbsSlot(M) :- maxSlot(S), maxDay(D), M=D*S.
max_Emp(M) :- M = #max{ E : emp(_,_,E) }.
% #show maxAbsSlot/1.

% ========== shift generation ==============

{ shift(S1..S2,L1..L2,D,1..B) } M :- type(S1,S2,L1,L2), day(D), max_Emp(B), emp(D,S,E), maxshifts(M), S1<=S, S<=S2+L2.
:- shift(S, L, D, E1), shift(S, L, D, E2), E1 != E2. % THIS

abs_shift(S,L,E) :- shift(S1,L,D,E), maxSlot(M), S=(D-1)*M+S1.

% =========== which timepoint does the shift cover =============

covers(D+1,S,S2,L,C) :- abs_shift(S2,L,C), maxSlot(M), maxAbsSlot(N), S1=S2..S2+L-1, S1<=N, D=(S1-1)/M, S=S1-D*M.
covers(D+1,S,S2,L,C) :- abs_shift(S2,L,C), maxSlot(M), maxAbsSlot(N), S2+L-1>N, S1=S2..S2+L-1, S1>N, D=(S1-N-1)/M, S=S1-N-D*M.
slot_staff(D,S,C) :- day(D), slot(S),
    C = #sum{ E,S,D,L,S2 : covers(D,S,S2,L,E) }.

% #show covers/5.

% ========== Check solution candidates ==========

staff_ok(D,S) :- emp(D,S,E), shorten(M), exceed(P), slot_staff(D,S,C), E-M<=C, C<=E+P.
:- day(D), slot(S), not staff_ok(D,S).

shift_count(C) :- C = #count{ 1,S,L : shift(S,L,D,E) }.
shifts_ok :- shift_count(C), maxshifts(M), C<=M.
:- not shifts_ok.

days_shift(S,L,C) :- shift(S,L,_,_), C = #count{ 1,D : shift(S,L,D,E) }.
day_missed :- days_shift(S,L,C), maxDay(M), C!=M.
:- day_missed.

% ==================================

%
% Display
%

#show shift/4.
% #show abs_shift/3.
