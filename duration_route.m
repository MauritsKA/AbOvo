function [minutes_late,duration] = duration_route(route,windows,travel_time,t_s_time,best_is_feas)
% the rows of route represent the jobs. The first 2 columns represent the
% opening time of the job and the columns 3 and 4 represent the finishing time
% of the job. Note that these windows are given such that waiting within
% the job is as small as possible and are not the real feasible time
% windows since these can be larger!
% the matrix windows consists of all the real time windows where being late
% results in infeasibility. The first column represents the opening time 
% and the second column represents the closing time of the location
% travel_time is a column vector with the travel time between initial
% location and job 1, travel time between jobs, travel time between job n
% and initial location
% t_s_time is a matrix with the travel and service time between location j
% and j+1 between every relevant time window location
% best_is_feas logical that indicaties if there already is a feasible route
% this logical might be unneccesary if we always want to calculate minutes
% late!
n = size(route,1); % number of jobs
departure = zeros(n,1); % departure from job so initial truck location is not included!
departure(n,1) = route(n,3); % we set the departure time at job n equal to its earliest finishing time
slack = zeros(n,1); % amount of time that you need to wait between job i and the next job
% slack n is therefore 0
minutes_late = inf;
infeas = 0;
x = route(2:end,1)-flip(travel_time(2:end-1));
% preferred departure time at job i from the point of view of job i+1
% x is n-1 by 1
for i = 1:n-1
    j = n-i;
    if route(j,3) <= x(j) && x(j) <= route(j,4)
        departure(j) = x(j);
    elseif route(j,4) < x(j) % depart later than latest departing time
        departure(j) = route(j,4);
        % slack(j) = x-route(j,4); might be unneccesary to compute
    else
        % departure(j) = route(j,3); might be unneccesary to compute
        % preferred departure time is too early thus we set it to earliest
        % feasible departure time
        slack(j) = x(j)-route(j,3); % negative slack!
    end
end
% positive slack: you want to depart after the "ideal" departure time of job
% j from the point of view of j meaning that you need to wait next to the road
% negative slack: you want to depart before the ideal departure time of job
% j in terms of job j meaning that the driving time takes longer than the planned
% time to drive from job j to j+1
if slack ~= 0 % negative slack between jobs means route is infeasible as
    % the departure times are scheduled too close to each other. Thus we
    % will correct this by adjusting the schedule from left to right
    for i = 1:n-1
        if slack(i) < 0
            departure(i+1) = departure(i+1)-slack(i);
            if departure(i+1) > route(i+1,4)
                infeas = 1;
            end
            slack(i) = 0;
            if i < n-1
                slack(i+1) = min(departure(i+2)-(departure(i+1)+travel_time(i+2)),0);
            end
        end
    end
    if infeas == 1 && best_is_feas == 0
        % algorithm to calculate cummulative lateness of the truck using
        % this route with these departure times
        % need to know what the input of this function looks like! Discuss
        % with group
        % if this route is gaurenteed to be infeasible dont bother cheking
        % if you already have a feasible solution?
        % dicuss with group!
        % minutes_late = lateness(departure,windows,t_s_time);
        m = size(t_s_time,1);
        time = zeros(m+1,1);
        time(1) = start;
        for i = 1:m
            time(i+1) = max(window(i,1),max(time(i),departure(numbers(i)))+t_s_time(i));
            % within a job we also can not start with part of a job earlier
            % than planned. We need to take care of this since we now start
            % outside our "ideal" time windows!
        end
        minutes_late = sum(max(time(2:end)-windows(:,2),0));
    elseif slack ~= 0 && best_is_feas == 1
        minutes_late = inf;
        %departure = inf;
        duration = inf;
        return
    end
end
if slack == 0
    minutes_late = 0;
end
duration = travel_time(1)+route(1,3)-route(1,1)+departure(n)-...
    departure(1)+travel_time(n+1);
% relevant to return departures of jobs? it is jobs not all locations
end



