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

{ shift(S1..S2,L1..L2,D,1..B) } M :- type(S1,S2,L1,L2), day(D), emp(D,S,E), max_Emp(B), maxshifts(M), S1<=S, S<=S2+L2.
:- shift(S, L, D, E1), shift(S, L, D, E2), E1 != E2. % THIS

abs_shift(S,L,E) :- shift(S1,L,D,E), maxSlot(M), S=(D-1)*M+S1.

% malo(2).
% moc(6).
% { pokus(S..L) } 4 :- malo(S), moc(L).

% c :- 0 { a;b }.
% % a.
% #show c/0.

%
% Check solution candidates
%

% prevDay(D,P) :- day(D), D>1, P=D-1.
% prevDay(1,M) :- maxDay(M).

% slot_staff(D,S,C) :- day(D), slot(S), C = #sum{ E,S1,L,D : shift(S1,L,D,E), S = S1..S1+L-1; E,S1,L,D : prevDay(D,PD), shift(S1,L,PD,E), maxSlot(M), S=S1-M..S1-M+L-1 }.
slot_staff(D,S,C) :- day(D), slot(S),
    C = #sum{ E,S1,L : abs_shift(S1,L,E), maxSlot(M), (D-1)*M+S = S1..S1+L-1;
    E,S1,L : abs_shift(S1,L,E), maxSlot(M), maxAbsSlot(N), (D-1)*M+S = S1-N..S1-N+L-1 }.



staff_ok(D,S) :- emp(D,S,E), shorten(M), exceed(P), slot_staff(D,S,C), C = E-M..E+P.
:- day(D), slot(S), not staff_ok(D,S). % THIS

% shift_in_day(D,C) :- day(D), C = #count{ 1,S,L,D,E : shift(S,L,D,E) }.
% shifts_ok(D) :- shift_in_day(D,C), maxshifts(M), C=0..M.
% :- day(D), not shifts_ok(D).

shift_count(C) :- C = #count{ 1,S,L : shift(S,L,D,E) }.
shifts_ok :- shift_count(C), maxshifts(M), C=0..M.
:- not shifts_ok. % THIS

% day_missed :- shift(S,L,D,_), day(DD), D != DD. % does no work
% #show day_missed/0.

days_shift(S,L,C) :- shift(S,L,_,_), C = #count{ 1,D : shift(S,L,D,E) }.
day_missed :- days_shift(S,L,C), maxDay(M), C!=M.
:- day_missed. % THIS
% :- day(D), not shifts_ok(D).

%
% Display
%

#show shift/4.
% #show abs_shift/3.


% query :- shift(8,16,1,3), shift(8,16,2,1), shift(8,16,3,1), shift(8,16,4,1).
% :- not query.
