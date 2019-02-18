%% Truck Scheduling MIP
% Group 5 - OR - Erasmus University Rotterdam

clear all; clc;
TotalTime = tic;
load ../NewData/TankSchedule
load ../NewData/TruckJobs

t_0 = datetime(2018,03,0,00,00,00);

% Convert job schedule to job matrix
jobsM = getJobsMatrix(jobs,t_0);

%reorder_route(jobsM);
[route] = sortrows(jobsM,4); % same
%%
% FOR EACH PARTICLE
% Initialize decision variable x_ij - Job i belonging to truck j

% Retrieve initial solutions x_ij
% Sort routes -> retrieve lateness & waiting time
% Make use of independence
% Calculate costs

% LOOP
% Retrieve neighborhood
% shake and escalate or select local optimum
% Move in direction of local optimum by path relinking
% (CROSS-exchange affected)
% Sort routes -> retrieve lateness & waiting time
% Calculate costs
% Move if new solution is improvement compared to old


TotalTime = toc(TotalTime)