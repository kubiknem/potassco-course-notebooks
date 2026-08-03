% Please insert the names and email addresses of the group members:
%
%

subgrid_size(3).

% Hints:
% - For subgrid_size(s), subgrids can be identified by labels 0..s*s-1
% - A cell (x,y) can be mapped to the subgrid labeled (((x-1)/s)*s + (y-1)/s)

% Your implementation please...

#show sudoku/3.

#const size=9.

subgrid(0..(S*S)-1) :- subgrid_size(S).
cell(X,Y) :- X = 1..size, Y = 1..size.

% :- cell(X, Y), not sudoku(X,Y,_).
:- Y != Z, S1 = S2, sudoku(X,Y,S1), sudoku(X,Z,S2).
:- Y != Z, S1 = S2, sudoku(Y,X,S1), sudoku(Z,X,S2).
:- S1 = S2, sudoku(X1,Y1,S1), sudoku(X2,Y2,S2), X1 != X2, (((X1-1)/S)*S + (Y1-1)/S) = (((X2-1)/S)*S + (Y2-1)/S), subgrid_size(S).

sudoku(X,Y,S) :- initial(X,Y,S).
% initial(1,1,1).
% initial(1,2,2).

% sol(1..2).
1 { sudoku(X,Y,S) : S = 1..size } 1 :- cell(X,Y).
