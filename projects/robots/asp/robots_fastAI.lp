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
step(1..n).

% ===============================================================
% A. static information (computed once by the grounder)
% ===============================================================

edge(Y,X) :- edge(X,Y).                 % undirected closure

node(N) :- edge(N,_).
node(N) :- robot(_,_,N).
node(N) :- operation(_,_,N).

% "key" nodes: the only ones we ever need distances from
key(N) :- robot(_,_,N).
key(N) :- operation(_,_,N).

% BFS from every key node.
% within(X,Y,K): Y is reachable from X in at most K steps (positive recursion,
% so the grounder evaluates it completely); dist is then defined on top of it
% by *stratified* negation -- both stay facts and never reach the solver.
within(X,X,0)   :- key(X).
within(X,Y,K+1) :- within(X,Y,K), K < n.
within(X,Y,K+1) :- within(X,Z,K), edge(Z,Y), K < n.
dist(X,X,0)     :- key(X).
dist(X,Y,K+1)   :- within(X,Y,K+1), not within(X,Y,K).

% ---- jobs ----

lastop(J,O)    :- job(J,_,_), O = #max{ O1 : operation(J,O1,_) }.
firstnode(J,N) :- operation(J,1,N).
lastnode(J,N)  :- lastop(J,O), operation(J,O,N).

% gap(J,O,G):  minimal number of *time steps* between operation O-1 and O
% mgap(J,O,D): minimal number of *movements* between operation O-1 and O
mgap(J,O,D) :- operation(J,O-1,N1), operation(J,O,N2), dist(N1,N2,D).
gap(J,O,D)  :- mgap(J,O,D), D >= 1.
gap(J,O,1)  :- mgap(J,O,0).             % two operations at the same node: 2 steps there

jobtime(J,S) :- job(J,_,_), S = #sum{ G,O :  gap(J,O,G) }.   % steps  from 1st to last op
jobmove(J,S) :- job(J,_,_), S = #sum{ D,O : mgap(J,O,D) }.   % moves  from 1st to last op

% deadline, capped by the horizon
dl(J,D) :- job(J,_,D), D <= n.
dl(J,n) :- job(J,_,D), D >  n.

% latest / earliest time at which operation O of J can possibly be executed
latest(J,O,L)   :- lastop(J,O), dl(J,L).
latest(J,O,L-G) :- latest(J,O+1,L), gap(J,O+1,G), operation(J,O,_).

earliest(J,1,E)   :- operation(J,1,N), job(J,C,_),
                     E = #min{ D : robot(_,C,S), dist(S,N,D) }, E <= n.
earliest(J,O,E+G) :- earliest(J,O-1,E), gap(J,O,G), operation(J,O,_), E+G <= n.

% window of the possible execution times of an operation
opwin(J,O,T)  :- earliest(J,O,E), latest(J,O,L), T = E..L.
haswin(J,O)   :- opwin(J,O,_).
:- operation(J,O,_), not haswin(J,O).   % the operation cannot be executed at all

% ===============================================================
% B. movement of the robots
% ===============================================================

% the movements themselves are the decision variables of the optimization,
% staying is the default (this is what the branch and bound works on)
{ moved(R,T) } :- robot(R,_,_), step(T).

% nodes robot R can possibly occupy at time T
reach(R,M,T) :- robot(R,_,S), dist(S,M,D), time(T), D <= T.

at(R,N,0) :- robot(R,_,N).
at(R,N,T) :- at(R,N,T-1), step(T), not moved(R,T).
1 { at(R,M,T) : edge(N,M), reach(R,M,T) } 1 :- at(R,N,T-1), moved(R,T).

% two robots cannot occupy the same node at the same time
:- node(N), time(T), #count{ R : at(R,N,T) } > 1.

% two robots cannot swap their positions
:- at(R1,N1,T-1), at(R1,N2,T), at(R2,N2,T-1), at(R2,N1,T), R1 < R2, edge(N1,N2).

% ===============================================================
% C. assignment of jobs to robots
% ===============================================================

class(C)   :- job(_,C,_).
njobs(C,M) :- class(C), M = #count{ J : job(J,C,_) }.

1 { assign(R,J,I) : robot(R,C,_), I = 1..M } 1 :- job(J,C,_), njobs(C,M).

:- assign(R,J1,I), assign(R,J2,I), J1 < J2.       % one job per index
used(R,I) :- assign(R,_,I).
:- used(R,I), I > 1, not used(R,I-1).             % indexes form 1,2,3,...

% ---- lower bounds implied by the assignment (redundant, but strong) ----
% chain(R,J,I,TimeLB,MoveLB): time / movements needed by R for the job at index I
chain(R,J,1,D+W1,D+W2) :- assign(R,J,1), robot(R,_,S), firstnode(J,N), dist(S,N,D),
                          jobtime(J,W1), jobmove(J,W2).
chain(R,J2,I,D+W1,D+W2) :- assign(R,J1,I-1), assign(R,J2,I),
                           lastnode(J1,N1), firstnode(J2,N2), dist(N1,N2,D), D >= 1,
                           jobtime(J2,W1), jobmove(J2,W2).
chain(R,J2,I,1+W1,W2)   :- assign(R,J1,I-1), assign(R,J2,I),
                           lastnode(J1,N1), firstnode(J2,N2), dist(N1,N2,0),
                           jobtime(J2,W1), jobmove(J2,W2).

% the whole chain up to index I must fit into the deadline of the job at index I
:- assign(R,J,I), dl(J,D), #sum{ V,K,JK : chain(R,JK,K,V,_), K <= I } > D.

% a robot moves at least as much as its chain of jobs requires
:- robot(R,_,_), #sum{ V,K,JK : chain(R,JK,K,_,V) ; -1,T : moved(R,T) } > 0.

% ===============================================================
% D. execution of the jobs
% ===============================================================

% solving(R,J,T): at time T robot R is working on job J
solving(R,J,T)  :- assign(R,J,1), T = 0.
solving(R,J,T)  :- solving(R,J,T-1), lastop(J,O), not done(J,O,T-1), step(T).
solving(R,J2,T) :- solving(R,J1,T-1), lastop(J1,O), done(J1,O,T-1),
                   assign(R,J1,I), assign(R,J2,I+1), step(T).

% done(J,O,T): operation O of J can be considered completed at time T
done(J,O,T)   :- solving(R,J,T), at(R,N,T), operation(J,O,N), O = 1, opwin(J,O,T).
done(J,O,T)   :- solving(R,J,T), at(R,N,T), operation(J,O,N), O > 1, opwin(J,O,T),
                 doneby(J,O-1,T-1).
doneby(J,O,T) :- done(J,O,T).
doneby(J,O,T) :- doneby(J,O,T-1), time(T).

% every job must be completed before or at its deadline
:- lastop(J,O), dl(J,D), not doneby(J,O,D).

% ===============================================================
% E. redundant constraints on the nodes used by the operations
%    (every operation occupies one (node,time) slot of its own)
% ===============================================================

first_done(J,O,T) :- done(J,O,T), not doneby(J,O,T-1).
opslot(N,T)       :- first_done(J,O,T), operation(J,O,N).

:- node(N), time(T), #count{ J,O : first_done(J,O,T), operation(J,O,N) } > 1.

% all operations of node N with latest time <= B need their own slot up to B
needbefore(N,B,K) :- node(N), time(B), K > 0,
                     K = #count{ J,O : operation(J,O,N), latest(J,O,L), L <= B }.
:- needbefore(N,B,K), #count{ T : opslot(N,T), T <= B } < K.

% all operations of node N with earliest time >= A need their own slot from A on
needafter(N,A,K) :- node(N), time(A), K > 0,
                    K = #count{ J,O : operation(J,O,N), earliest(J,O,E), E >= A }.
:- needafter(N,A,K), #count{ T : opslot(N,T), T >= A } < K.

% ===============================================================
% F. optimization
% ===============================================================

#minimize { 1,R,T : moved(R,T) }.

%
% show
%
#show at/3.
#show assign/3.

% Proč byla původní verze pomalá (hlavní body)

% 1. Pohyb byl generován jako volba pozice, ne jako volba pohybu. 1 { at(R,N,T) : node(N), reach(R,N,T) } 1 nechá solver zvolit libovolný dosažitelný uzel a teprve integritní omezení :- at(R,N,T), at(R,N2,T+1), not edge(N,N2) to zpětně zakáže — to je O(R·N²·T) pravidel a slabá propagace. Nová verze volí { moved(R,T) } a pozici odvozuje (stání je default). Vedlejší efekt: literály v #minimize jsou přímo rozhodovací atomy, což hodně pomáhá branch & bound.
% 2. completed_op(J,O-1,T1), T1<T se grounduje kvadraticky v čase; nahrazeno monotónním doneby/3.
% 3. Chyběly statické vzdálenosti. BFS v grounderu dá zadarmo: dosažitelnostní okno pro at, časová okna opwin(J,O,T) pro každou operaci (earliest/latest z deadlinu) a dolní odhady na čas i na počet pohybů pro celý řetězec přiřazených jobů — ty odříznou nesmys vůbec začne řešit pohyb.
% 4. Redundantní „slotové" omezení (sekce E): každá operace zabere vlastní   dvojici (uzel, čas). Právální — na uzel 1 je potřeba 12 operací, ale je k dispozici jen 11 časů (v čase 0 tam žádný robot       nestojí), takže UNSAT padezení místo prohledávání.
%                                                                            Jedna past, na kterou jseapamatování: první verzeBFS měla dist(X,Y,K+1) :- dist(X,Z,K), edge(Z,Y), not seen(X,Y,K) — negace uvnitř rekurzivní komponeyhodnotit staticky, dist se stane solverovým atomem a všechno, co na něm visí, se nafoukne (15M řádků
% groundu místo 13k, simpleení je rozdělit to namonotónní within/3 a stratifikovanou definici dist/3 nad ním.
