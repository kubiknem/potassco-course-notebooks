% Please insert the names and email addresses of the group members:
%
%

head(1,1).

% ---------- rule generation -----------------

{ head(R+1,H); head(R+1,H+1) } 1 :- head(R,H), R < program_max_size.

% atom(H) :- head(R,H).
atom(1..program_max_size).
atom(A) :- attribute(A).
sign(1). sign(-1).

{ body(R,S,A) : attribute(A), sign(S); body(R,S,A) : head(_,A), sign(S), A>H } body_max_size :- head(R,H).

% old version
% has(Example,Head) :- example(Example,_), head(R,Head), not body(R,_,_).
% has(E,Head) :- head(R,Head), body(R,S,A), S=1, has(E,A).
% has(E,Head) :- head(R,Head), body(R,S,A), S=-1, example(E,_), not has(E,A).

% ----------- pruning ----------------------

% A body containing both A and -A will never fire
:- body(R,1,A), body(R,-1,A).

% can delete rules that will not be used
used(A) :- body(_,_,A).
:- head(_,H), H>1, not used(H).

% For any given example, each rule must be the ONLY rule with that head.
% "not fails(E,R)" = rule R is triggered for example E. If, every time
% R is triggered, another rule with the same head is also triggered, deleting R does not change
% has(E,H) for any E or H—that is, neither fails nor the classification—but the program has
% one fewer rule, so the original model was not optimal.
%
% nfire(E,H,N): For instance E, exactly N rules with head H are triggered.
nfire(E,H,N) :- example(E,_), head(_,H), N = #count{ R : head(R,H), not fails(E,R) }.
needed(R) :- head(R,H), example(E,_), not fails(E,R), nfire(E,H,1).
:- head(R,_), not needed(R).

% ------------ example validation ------------------

fails(E,R) :- body(R,S,A), S = 1, not has(E,A), example(E,_).
fails(E,R) :- body(R,S,A), S = -1, has(E,A).
has(E,Head) :- head(R,Head), example(E,_), not fails(E,R).

:- example(E,pos), not has(E,1).
:- example(E,neg), has(E,1).

% ---------- optimization -----------------

#minimize{ 1@20, 1,R : head(R,H) }.
#minimize{ 1@10, 1,R,S,A : body(R,S,A) }.

% ------------- symmetry=1 ----------------

% position(A,X): atom A has position X among all atoms in clingo's lexicographical order 
position(A,X) :- atom(A), symmetry=1, X = { B <= A : atom(B) }.

% old -- doesnt cover all cases
% :- head(R,H), body(R,_,A), head(R2,H), body(R2,_,A2), R2>R, position(A,X), position(A2,X2), X2<X.

position(A,X) :- atom(A), symmetry=1, X = { B <= A : atom(B) }.
pos(X)     :- position(_,X). % all positions in instance
inpos(R,X) :- body(R,_,A), position(A,X).      % body R contains atom on position X

length_at_least(R,X) :- inpos(R,X). % We create an array of positions up to where the word ends -> length
length_at_least(R,X) :- length_at_least(R,X+1), pos(X).

pair(R,R+1) :- head(R,H), head(R+1,H), symmetry=1.

% gt(R,X): sufix of body R from position X (doesnt need to be present in words) is lexicographicaly BIGGER than sufix of body R+1
gt(R,X) :- pair(R,R2), gt(R,X+1), inpos(R,X), inpos(R2,X).                  % match -> propagate
gt(R,X) :- pair(R,R2), gt(R,X+1), pos(X), not inpos(R,X), not inpos(R2,X).  % match -> propagate
gt(R,X) :- pair(R,R2), inpos(R,X),  not inpos(R2,X), not length_at_least(R2,X+1).        % R2 is prefix of R
gt(R,X) :- pair(R,R2), inpos(R2,X), not inpos(R,X),  length_at_least(R,X+1).             % R2 contains lexicographicaly lower char

:- gt(R,1). % No rule can have a lexicographic rank higher than the first position of its successor R2 - pair(R, R2)

%
% Display
%
#show head/2.
#show body/3.
% #show position/2.
