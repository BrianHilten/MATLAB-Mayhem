% PageRank.m
% Function to return the eigenvector "ranking" of an adjacency matrix
% Inputs: 
%   -Adjacency Matrix A (Square Matrix)
%   -Damping Factor d (a number between 0 and 1)
%   -Normalized norm (1 or 0, representing if matrix A is already normalized or not.
% Outputs:
%   -Eigenvector P (Column Vector)

% I added a normalization argument so that the function could be applied to
% any adjacency matrix, even if it isn't normalized yet.

function [P] = PageRank(A,d,norm)
    [sizeA,~]= size(A); % So we can generalize to any size matrix A (square)
    if norm == 0
        % Normalize our adjacency matrix:
        for i = 1:1:sizeA
            column = A(:,i); % Put each column of A into a vector so we can sum it
            A(:,i) = column./sum(column); % Replace each column of A with a normalized version
        end
    end
    % Page Rank:
    O = 1/sizeA.*ones(sizeA); % Create our random probability matrix
    M = (1-d).*A + d.*O;
    [P,~] = eigs(M,1); % Find our eigenvector
    P = P/sum(P); % Ensure P sums to 1
end