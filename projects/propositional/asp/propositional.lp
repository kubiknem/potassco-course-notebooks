% Please insert the names and email addresses of the group members:
%
%


%
% Guess solution candidates
%

type(neg;or;and).
logic(or;and).
id(1..size).

% ------------- formula generation -----------------
1 { for(I,neg,J) : id(J), J>I;
    for(I,T,J) : logic(T), J=1..size-1, J>I;
    for(I,atom,A) : attribute(A) } 1 :- id(I).

seen(1).

seen(N) :- seen(I), for(I,neg,N).
seen(N) :- seen(I), for(I,T,N), logic(T).
seen(N+1) :- seen(I), for(I,T,N), logic(T).
:- id(I), not seen(I).

:- for(1, T, J), type(T), J != 2.

%------ restrictions -----
:- for(I,T1,I1), for(J,T2,I2), I<J, logic(T1), type(T2), I1+1>=I2.
:- for(I,T1,I1), for(J,T2,I2), I<J, type(T1), type(T2), I1>=I2.

:- for(I,T,J), logic(T), for(J,atom,A1), for(J+1,atom,A2), A2<=A1.

:- for(I,T,J), logic(T), for(J,T1,J1), for(J+1,atom,J2), type(T1).
:- for(I,T,J), logic(T), for(J,T1,J1), for(J+1,neg,J2), logic(T1).
:- for(I,T,J), logic(T), for(J,and,J1), for(J+1,or,J2).

% ----------------------

%
% Check solution candidates
%

% is example satisfiable?
sat(E) :- example(E,_), sat(E,1).

% atom
sat(E,I) :- for(I,atom,A), has(E,A).

% or 
sat(E,I) :- for(I,or,J), sat(E,J).
sat(E,I) :- for(I,or,J), sat(E,J+1).

% and
sat(E,I) :- for(I,and,J), sat(E,J), sat(E,J+1).

% neg
sat(E,I) :- for(I,neg,J), not sat(E,J), example(E,_).

good(E) :- example(E,pos), sat(E).
good(E) :- example(E,neg), not sat(E).


%
% Optimize solutions
%

% opt in examples solved
#maximize{ 1,E : good(E) }.

%
% Display
%

#show for/3.
