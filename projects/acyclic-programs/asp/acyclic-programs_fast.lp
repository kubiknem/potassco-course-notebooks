% Please insert the names and email addresses of the group members:
%
%
%
% Varianta acyclic-programs.lp s dodatecnymi omezenimi, ktera nemeni mnozinu
% optimalnich modelu, ale odriznou velkou cast neoptimalnich kandidatu.
% Argument je u vsech stejny: model, ktery omezeni porusi, lze zmensit smazanim
% pravidla (nebo literalu), takze existuje striktne lepsi reseni - porusujici
% model tedy nebyl optimalni. Testuje se shoda jen optimalnich modelu.

head(1,1).

{ head(R+1,H); head(R+1,H+1) } 1 :- head(R,H), R < program_max_size.

atom(1..program_max_size).
atom(A) :- attribute(A).
sign(1). sign(-1).

{ body(R,S,A) : attribute(A), sign(S); body(R,S,A) : head(_,A), sign(S), A>H } body_max_size :- head(R,H).

fails(E,R) :- body(R,S,A), S = 1, not has(E,A), example(E,_).
fails(E,R) :- body(R,S,A), S = -1, has(E,A).
has(E,Head) :- head(R,Head), example(E,_), not fails(E,R).

:- example(E,pos), not has(E,1).
:- example(E,neg), has(E,1).

#minimize{ 1@20, 1,R : head(R,H) }.
#minimize{ 1@10, 1,R,S,A : body(R,S,A) }.

%
% Prorezavani
%

% (1) telo obsahujici A i -A se nikdy nespusti -> pravidlo je smazatelne
:- body(R,1,A), body(R,-1,A).

% (2) pomocny atom, ktery se v zadnem tele nepouzije, nema vliv na klasifikaci
%     -> vsechna jeho pravidla jsou smazatelna
used(A) :- body(_,_,A).
:- head(_,H), H>1, not used(H).

% (3) kazde pravidlo musi byt pro nejaky priklad JEDINOU oporou sve hlavy.
%     "not fails(E,R)" = pravidlo R se pro priklad E spusti. Pokud se pri kazdem
%     spusteni R spusti i jine pravidlo se stejnou hlavou, smazani R nezmeni
%     has(E,H) pro zadne E ani H, tedy ani fails a ani klasifikaci - program ma
%     ale o pravidlo min, takze puvodni model nebyl optimalni.
% other_fires(E,H,R) :- head(R,H), head(R2,H), R2!=R, example(E,_), not fails(E,R2).
% needed(R) :- head(R,H), example(E,_), not fails(E,R), not other_fires(E,H,R).
% :- head(R,_), not needed(R).

%
% Omezeni pro symmetry=1 (shodne s acyclic-programs.lp)
%

% position(A,X): atom A ma pozici X mezi vsemi atomy v lexikografickem poradi clinga
position(A,X) :- atom(A), symmetry=1, X = { B <= A : atom(B) }.
pos(X)     :- position(_,X).
inpos(R,X) :- body(R,_,A), position(A,X).

% retez pozic: kam az saha slovo -> delka
length_at_least(R,X) :- inpos(R,X).
length_at_least(R,X) :- length_at_least(R,X+1), pos(X).

pair(R,R+1) :- head(R,H), head(R+1,H), symmetry=1.

% gt(R,X): sufix tela R od pozice X je lexikograficky VETSI nez sufix tela R+1
gt(R,X) :- pair(R,R2), gt(R,X+1), inpos(R,X), inpos(R2,X).                            % shoda -> zded
gt(R,X) :- pair(R,R2), gt(R,X+1), pos(X), not inpos(R,X), not inpos(R2,X).            % shoda -> zded
gt(R,X) :- pair(R,R2), inpos(R,X),  not inpos(R2,X), not length_at_least(R2,X+1).     % R2 je prefix R
gt(R,X) :- pair(R,R2), inpos(R2,X), not inpos(R,X),  length_at_least(R,X+1).          % R2 ma mensi znak

:- gt(R,1).

%
% Display
%
#show head/2.
#show body/3.
