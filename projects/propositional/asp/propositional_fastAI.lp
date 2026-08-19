% Please insert the names and email addresses of the group members:
%
%


%
% Guess solution candidates
%

type(neg;or;and).
logic(or;and).
id(1..size).

% Every node is either an atom (and then we guess the attribute directly),
% or an inner node of type neg/or/and.  The *children* of an inner node are
% never guessed: the canonical layout required by the project determines them.
1 { for(I,atom,A) : attribute(A);
    node(I,neg);
    node(I,or);
    node(I,and)                    } 1 :- id(I).

node(I,atom) :- for(I,atom,_).

% number of children
ar(I,0) :- node(I,atom).
ar(I,1) :- node(I,neg).
ar(I,2) :- node(I,T), logic(T).

% free(I,N): N is the smallest index that is not yet used as a child
% by the nodes 1,...,I-1.  The canonical order (children of smaller nodes
% come before children of bigger nodes, without gaps and without overlap)
% forces the children of I to be exactly N (and N+1 for or/and).
free(1,2).
free(I+1,N+K) :- free(I,N), ar(I,K), N+K <= size+1.

:- free(I,N), ar(I,K), N+K > size+1.    % a child would be outside 1..size
:- free(I,N), id(I),   N <= I.          % a child must be bigger than its parent
:- free(size+1,N),     N != size+1.     % every node is a child of exactly one node

for(I,T,N) :- node(I,T), type(T), free(I,N), N <= size.

% J and J+1 are the two children of some or/and node
sib(J) :- node(I,T), logic(T), free(I,J).

%
% Restrictions on the form of the formulas
%

:- sib(J), for(J,atom,A1), for(J+1,atom,A2), A2 <= A1.
:- sib(J), node(J,T), type(T),  node(J+1,atom).
:- sib(J), node(J,T), logic(T), node(J+1,neg).
:- sib(J), node(J,and), node(J+1,or).

%
% Check solution candidates
%

sat(E,I) :- for(I,atom,A), has(E,A).
sat(E,I) :- for(I,or,J),   sat(E,J).
sat(E,I) :- for(I,or,J),   sat(E,J+1).
sat(E,I) :- for(I,and,J),  sat(E,J), sat(E,J+1).
sat(E,I) :- for(I,neg,J),  example(E,_), not sat(E,J).

good(E) :- example(E,pos),     sat(E,1).
good(E) :- example(E,neg), not sat(E,1).

%
% Optimize solutions
%

#maximize{ 1,E : good(E) }.

%
% Display
%

#show for/3.
