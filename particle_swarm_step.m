function [new_routes_particle] =  particle_swarm_step(route_from_local,routes_particle) 
% route_from_lcoal is a matrix which contains on its rows the information 
% of a job. routes_particle is a matrix that has all the jobs as it rows 
% and each job is assigned to a route/truck. Both matrices have all jobs 
% assigend. however from route_from_local we will select only 1 route 
 
% this part of the code selects at random 1 route of the local optimum 
% solution. Afterwards both matrices are sorted on job ID. 
temp = unique(route_from_local(:,6)); 
j = randi([1 size(temp,1)],1,1);% choose a random route while giving all  
% routes an equal chance to be chosen. 
route_ID = temp(j); % need this specific line since the route numbers might be  
% 1 3 5 clearly you can not select route 2 as it does not exist in this 
% solution route to copy 
 
logic_route_ID = route_from_local(:,6) == route_ID; 
route_from_local = route_from_local(logic_route_ID,:); 
% route_from_local = sortrows(route_from_local,5); 
% routes_particle = sortrows(routes_particle,5); 
% this part of the code finds all the affected routes/trucks if we add the new 
% route 
n = size(route_from_local,1); % number of jobs in the new route/truck 
matrix_rel_jobID = ones(size(routes_particle,1),1)*route_from_local(:,5)'; 
matrix_all_jobID = routes_particle(:,5)*ones(1,n); 
affected_routes = unique(sum(matrix_rel_jobID == matrix_all_jobID,2).*routes_particle(:,6)); 
if affected_routes(1) == 0 
    affected_routes(1) = []; 
end 
route_ID = ones(size(routes_particle,1),1)*route_ID; 
if sum(route_ID == routes_particle(:,6)) >= 1 % if we already use the truck/route ID in this particle 
    % we need to transfer all the current jobs on the route/truck to a new 
    % one before copying the new route to this particle. 
    A = routes_particle(:,6) == route_from_local(1,6); 
    % new_routeID = choose_new_truck(); % this function still needs to be made! 
    new_routeID = max(routes_particle(:,6))+1; 
    % choose cheapest/closest truck (might be charter) 
    routes_particle(A,6) = new_routeID; % how to choose this new truck? assign jobs to new truck 
    affected_routes(affected_routes == route_from_local(1,6)) = []; % remove the new route/truck ID from 
    % affected route list as this should not be affected by the 
    % CROSS-exchange in the next step 
end 
routes_particle(route_from_local(:,5),6) = route_from_local(:,6); % change the route/truck ID 
% to the new route/truck ID. All the affected routes are now a bit shorter 
% or empty. if empty it already dissappeared in the last line of code. 
% routes_particle = sortrows(routes_particle,6); 
% affected routes now need to be randomized using cross exchange 
m = numel(affected_routes); 
if m > 1 
    for i = 1:m-1 
        k = sum(routes_particle(:,6) == affected_routes(i)); % number of jobs on this route 
        a = randi([0 k],1,1); % number of jobs to exchange 
        if a == 0 
            b = randi([1 k],1,1); 
        else 
            b = randi([1 k-a+1],1,1); % from which job onwards we wish to exchange; 
        end 
        l = sum(routes_particle(:,6) == affected_routes(i+1)); % number of jobs on this route 
        c = randi([0 l],1,1); % number of jobs to exchange 
        if c == 0 
            d = randi([1 l],1,1); 
        else 
            d = randi([1 l-c+1],1,1); % from which job onwards we wish to exchange; 
        end 
        route1 = routes_particle(routes_particle(:,6) == affected_routes(i),:); 
        % select all the jobs on this route 
        route2 = routes_particle(routes_particle(:,6) == affected_routes(i+1),:); 
        % select all the jobs on this route 
        [new_route1,new_route2] = CROSS_exchange(route1,route2,a,b,c,d); 
        routes_particle(routes_particle(:,6) == affected_routes(i),:) = []; 
        routes_particle(routes_particle(:,6) == affected_routes(i+1),:) = []; 
        routes_particle = [routes_particle; new_route1;new_route2]; 
    end 
    if m > 2 
        k = sum(routes_particle(:,6) == affected_routes(1)); % number of jobs on this route 
        a = randi([0 k],1,1); % number of jobs to exchange 
        if a == 0 
            b = randi([1 k],1,1); 
        else 
            b = randi([1 k-a+1],1,1); % from which job onwards we wish to exchange; 
        end 
        l = sum(routes_particle(:,6) == affected_routes(m)); % number of jobs on this route 
        c = randi([0 l],1,1); % number of jobs to exchange 
        if c == 0 
            d = randi([1 l],1,1); 
        else 
            d = randi([1 l-c+1],1,1); % from which job onwards we wish to exchange; 
        end 
        route1 = routes_particle(routes_particle(:,6) == affected_routes(1),:); 
        % select all the jobs on this route 
        route2 = routes_particle(routes_particle(:,6) == affected_routes(m),:); 
        [new_route1,new_route2] = CROSS_exchange(route1,route2,a,b,c,d); 
        routes_particle(routes_particle(:,6) == affected_routes(1),:) = []; 
        routes_particle(routes_particle(:,6) == affected_routes(m),:) = []; 
        routes_particle = [routes_particle; new_route1;new_route2]; 
    end 
end 
% routes_particle = sortrows(routes_particle,6); 
new_routes_particle = routes_particle; 
end