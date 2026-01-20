
% Testing the function with the example from class:
A = [1 0 0 1 1 0; 0 1 1 0 0 0; 1 0 1 0 0 0; 0 0 1 1 1 0; 1 0 0 0 1 1; 1 0 0 0 1 1];

B = PageRank(A,0.15,0);
disp("Example from class (non-normalized): ")
disp(B)

% Testing the function with the normalized example from class:

A = [1/4 0 0 1/2 1/4 0; 
       0 1 1/3 0 0 0; 
     1/4 0 1/3 0 0 0; 
       0 0 1/3 1/2 1/4 0; 
     1/4 0 0 0 1/4 1/2; 
     1/4 0 0 0 1/4 1/2];

B = PageRank(A,0.15,1);
disp("Example from class (normalized): ")
disp(B)


% Testing the function with a 7x7 matrix:

A = [1 0 0 1 1 0 1; 0 1 1 0 0 0 1; 1 0 1 0 0 0 0; 0 0 1 1 1 0 1; 1 0 0 0 1 1 0; 1 0 0 0 1 1 0; 1 1 1 0 0 0 0];

B = PageRank(A,0.15, 0);

disp("7x7 Test: ")
disp(B)

% Testing the function with a 3x3 matrix:

A = [1 0 0; 0 1 1; 1 0 1];

B = PageRank(A,0.15, 0);

disp("3x3 Test: ")
disp(B)

%% External Functions
%
% <include>PageRank.m</include>
%

