% Please insert the names and email addresses of the group members:
%
%

head(1,1).

{ head(R+1,H); head(R+1,H+1) } 1 :- head(R,H), R < program_max_size.

% atom(H) :- head(R,H).
atom(1..program_max_size).
atom(A) :- attribute(A).
sign(1). sign(-1).

{ body(R,S,A) : attribute(A), sign(S); body(R,S,A) : head(_,A), sign(S), A>H } body_max_size :- head(R,H).

% has(Example,Head) :- example(Example,_), head(R,Head), not body(R,_,_).
% has(E,Head) :- head(R,Head), body(R,S,A), S=1, has(E,A).
% has(E,Head) :- head(R,Head), body(R,S,A), S=-1, example(E,_), not has(E,A).

fails(E,R) :- body(R,S,A), S = 1, not has(E,A), example(E,_).
fails(E,R) :- body(R,S,A), S = -1, has(E,A).
has(E,Head) :- head(R,Head), example(E,_), not fails(E,R).

% has(E,A) :- example_contains(E,A).

:- example(E,pos), not has(E,1).
:- example(E,neg), has(E,1).

#minimize{ 1@20, 1,R : head(R,H) }.
#minimize{ 1@10, 1,R,S,A : body(R,S,A) }.

% position(A,X): atom A has position X among all atoms in clingo's lexicographical order 
position(A,X) :- atom(A), symmetry=1, X = { B <= A : atom(B) }.

% :- head(R,H), body(R,_,A), head(R2,H), body(R2,_,A2), R2>R, position(A,X), position(A2,X2), X2<X.

position(A,X) :- atom(A), symmetry=1, X = { B <= A : atom(B) }.
pos(X)     :- position(_,X). % vsechny pozice v instanci
inpos(R,X) :- body(R,_,A), position(A,X).      % tělo R obsahuje atom na pozici X

length_at_least(R,X) :- inpos(R,X).                        % delame retez pozic kam az saha slovo -> delka
length_at_least(R,X) :- length_at_least(R,X+1), pos(X).

pair(R,R+1) :- head(R,H), head(R+1,H), symmetry=1.

% gt(R,X): sufix těla R od pozice X (nemusi byt soucasti ani jednoho slova) je lexikograficky VĚTŠÍ než sufix těla R+1
gt(R,X) :- pair(R,R2), gt(R,X+1), inpos(R,X), inpos(R2,X).                  % shoda -> zděd
gt(R,X) :- pair(R,R2), gt(R,X+1), pos(X), not inpos(R,X), not inpos(R2,X).  % shoda -> zděd
gt(R,X) :- pair(R,R2), inpos(R,X),  not inpos(R2,X), not length_at_least(R2,X+1).        % R2 je kratsi jak R (prefix)
gt(R,X) :- pair(R,R2), inpos(R2,X), not inpos(R,X),  length_at_least(R,X+1).             % R2 má menší znak

:- gt(R,1). % zadne pravidlo nemuze byt lexikograficky vyssi od prvni pozice nez jeho nastupce R2 - pair(R,R2)

% pokus :- a < 4.
% #show pokus/0.

%
% Display
%
#show head/2.
#show body/3.
% #show position/2.
