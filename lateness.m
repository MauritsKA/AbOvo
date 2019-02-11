function [late] = lateness(start,departure,windows,t_s_time,numbers)
% departure are the departure time at the jobs
% windows represents the relevant time windows in the job
% for now only the ending of the time window is relevant????
% t_s_time are the travel and service times between consecutive relevant
% locations
% numbers that are non zero represent the starting points of the jobs
% 1 0 0 2 0 0 0 3 0 4 5 0 0 for example shows that the fourth element
% stands for job 2 and this number we want to use later in this function
n = size(t_s_time,1);
time = zeros(n+1,1);
time(1) = start; % this is the arrival at the initial location of the 
% truck. Assumption is made that the truck can leave immediately after
% arrival
for i = 1:n
    time(i+1) = max(time(i),departure(numbers(i)))+t_s_time(i);
    % take max as we never depart too early from a job only on time or too
    % late
end
late = sum(max(time(2:end)-windows,0)); % we take the maximum since if 
% a truck is too early for a deadline the truck can just wait next to the 
% road. The penalty for being early is of course the extra waiting time
% which is already "penalised" by costing more time
end