function [minutesLate,duration] = duration_route2(windows,workingTime,travelTime)
% windows is a matrix with on the rows the jobs and on the columns the
% timestamps of the locations (might be easier to split in 2 matrices opening times and closing times per
% location)

% travelTime is a column vector with the travel time between initial
% location and job 1, travel time between jobs, travel time between job n
% and initial location

n = size(windows,1); % number of jobs
r = sum(windows~=0,2); % number of timestamps. for example job 1 has 6 timestamps
% (open1 close1 open2 close2 open3 close3) job 2 has 4 timestamps
departure = zeros(n,1); % departure times from job so departure from initial truck location
% to the first job is not included!
departure(n,1) = windows(n,end-1); % we set the departure time at job n equal to its earliest finishing time
slack = zeros(n,1); % amount of time that you need to wait between job i and the next job
minutesLate = 0;
infeas = 0;
x = windows(2:end,r(2:end)-1)-travelTime(2:end-1); % preferred departure time at job i from the point of view
% of job i+1. x is n-1 by 1

% this part of the code creates the departure times at every job
for i = 1:n-1
    j = n-i; % we want to work from right to left
    if windows(j,r(j)-1) <= x(j) && x(j) <= windows(j,r(j))
        departure(j) = x(j);
    elseif windows(j,r(j)) < x(j) % depart later than latest departing time
        departure(j) = windows(j,r(j));
        % slack(j) = x-route(j,4); might be unneccesary to compute
    else
        departure(j) = windows(j,r(j)-1); % might be unneccesary to compute
        % preferred departure time is too early thus we set it to earliest
        % feasible departure time
        slack(j) = x(j)-window(j,r(j)-1); % negative slack!
    end
end


% positive slack: you want to depart after the "ideal" departure time of job
% j from the point of view of j meaning that you need to wait next to the road

% negative slack: you want to depart before the ideal departure time of job
% j in terms of job j meaning that the driving time takes longer than the planned
% time to drive from job j to j+1

% this part of the code deals with the negative slack by adjusting the
% departure times
if slack ~= 0 % negative slack between jobs means route is infeasible as
    % the departure times are scheduled too close to each other. Thus we
    % will correct this by adjusting the schedule from left to right
    for i = 1:n-1
        if slack(i) < 0
            departure(i+1) = departure(i+1)-slack(i); % slack is negative thus we move the next
            % departure to the right!
            if departure(i+1) > windows(i+1,r(i)) % if departure i+1 takes place after
                % latest finishing time of that job
                infeas = 1;
            end
            slack(i) = 0;
            if i < n-1
                slack(i+1) = min(departure(i+2)-(departure(i+1)+travelTime(i+2)),0);
                % recalculate slack(i+1) since we moved departure i+1
            end
        end
    end
    % route is infeasible now check how infeasible it is!
    % might be (very) usefull to include INDEPENDENCE here!
    if infeas == 1 
        time = zeros(sum(r)/2,1); % number of locations
        for i = 1:n % number of jobs
            for j = 1:r(i)/2
                if j == 1
                    time(k+1) = departure(i);
                else
                    if time(k)+workingTime(i,j) < windows(i,j*2-1)
                        time(k+1) = windows(i,j*2-1); % if too early at a location we need to wait
                    else
                        time(k+1) = time(k)+workingTime(i,j);
                    end
                end
                x = max(time(k+1)-windows(i,j*2),0); % ending window of a job
                minutesLate = minutesLate + x;
            end
        end
    end
end
if slack == 0
    minutesLate = 0;
end
% determine time that first trip takes

time = departure(1);
for i =1:r(1)/2
    j = r(1/2)-i+1;
    if windows(1,j*2-1) <= time && time <= windows(1,j*2)
        time = time-workingTime;
    elseif windows(1,j*2-1)>= time
        time = windows(1,j*2-1);
    end
end
startTime = time; % start time of the first job 
duration = travelTime(1)+departure(n)-startTime+travelTime(n+1);
% relevant to return departures of jobs? it is jobs not all locations
end