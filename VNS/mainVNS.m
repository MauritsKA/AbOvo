%% Truck Scheduling MIP
% Group 5 - OR - Erasmus University Rotterdam

clear all; clc;
TotalTime = tic;
load ../NewData/TankSchedule
load ../NewData/TruckJobs
load ../NewData/Linkingmatrices
load ../NewData/Truck_Tank_info

t_0 = datetime(2018,03,0,00,00,00);

Trucks = Truck_Tank(Truck_Tank.ResourceType == "Truck",:);

% Convert job schedule to job matrix
[jobsW, jobsT] = getJobsMatrix(jobs,t_0);
%%
idt = 5; % Select a truck
idj = [13 17]; % Select a few jobs 
jobWS = jobsW(idj,:);
jobsTS = jobsT(idj,:);

%reorder_route(jobsM);
[routeW, In] = sortrows(jobWS,4); % same
routeT = jobsTS(In,:); % same

travelTime = TimeMatrix(sub2ind(size(TimeMatrix),[getIndex(Trucks.HomeAddressID(idt));routeW(:,3)],[routeW(:,2);getIndex(Trucks.HomeAddressID(idt))]));
travelTime(travelTime == 0) = 5; 

[minutesLate,duration] = getDuration(routeW(:,5:end),routeT(:,2:end),travelTime);
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