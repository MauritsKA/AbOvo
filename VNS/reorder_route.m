function [X] = reorder_route(TimeMatrix)
% find moste likely feasible route by ordering the jobs on chronological order of mean time windows
for i = 1:200000
X = TimeMatrix(sub2ind(size(TimeMatrix),randi(1136,500,1),randi(1136,500,1)));
end 

end

