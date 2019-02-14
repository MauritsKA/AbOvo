function [existing_route,feas] = best_route_2_opt(existing_route)
% route is depot(trucks) job1 jobi jobn depot(trucks)
% as every job can have a different starting and ending location
% route is a nx5 matrix where in column 1 we have the starting location
% and in column 2 the ending location column 3 denotes the time it takes
% before a truck can drive again column 4 is the opening time column 5 is
% the closing time of that job
% in this programm we always start and end in the depot! thus the first
% and last node always remain the same
% load('test_2opt') % load the distance matrix
load('test_2opt2');
n = size(existing_route,1);
[feas,duration] = feasible_route(existing_route);
if feas
    best_cost = distance_route(existing_route,Test_matrix_2_opt2)*cost_km + duration*cost_hour;
else
    best_cost = inf;
end
%this part of the program goes over all the possible 2_opt swaps
for i = 2:n-2
    for j =i+1:n-1
        new_route = two_optSwap(existing_route,i,j);
        [feas,duration] = feasible_route(new_route);
        if feas % only if feasible we should check whether the new route is cheaper than the current one
            new_cost = distance_route(new_route,Test_matrix_2_opt2)*cost_km + duration*cost_hour;
            if (new_cost < best_cost)
                best_cost = new_cost;
                existing_route = new_route;
                i = 2;
                j = i+1;
            end
        end
    end
end
feas = feasible_route(existing_route);