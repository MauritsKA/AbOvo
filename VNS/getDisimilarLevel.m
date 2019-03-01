function [disimilarLevel] = getDisimilarLevel(q,p)
% input: 2 solutions of the truck scheduling. Where the input matrices are
% the same size with the truckIDs on the rows and jobID's on the columns
% this code computes the dissimalarity level of 2 solutions
disimilarMatrix = p + q == 1;
disimilarLevel = sum(sum(disimilarMatrix));

end