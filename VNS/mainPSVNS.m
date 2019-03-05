%% Truck Scheduling MIP
% Group 5 - OR - Erasmus University Rotterdam

%% Initialize
clear all; clc;
clock.totalTime = tic;

load ../NewData/TruckJobs
load ../NewData/Linkingmatrices
load ../NewData/Truck_Tank_info
load ../DataHS/CostsPerKmPerTrucks

t_0 = datetime(2018,03,0,00,00,00);
alpha = 100; % Tuning parameters for cost function
gamma = 100;

% Select trucks, remove table and pre convert tank adresses
trucks = Truck_Tank(Truck_Tank.ResourceType == "Truck",:); clear Truck_Tank
truckHomes = getIndex(trucks.HomeAddressID);

% Convert tanktaniner schedules to Job schedule
% Run getJobs.m

% Convert job schedule to job matrix
[jobsW, jobsT, jobsKM] = getJobsMatrix(jobs,t_0);

truckCost = [CostsPerKm; 3*ones(size(jobsW,1),1)];

%% Lower and upper bound given this specific tank handling
bounds.minTimeWindow = jobsW(sub2ind(size(jobsW),(1:size(jobsW,1))',sum(jobsW > 0,2)-1)) - jobsW(:,6);
bounds.minServiceTime = sum(jobsT(:,2:end),2);

bounds.minTimeCost = sum(max(bounds.minTimeWindow,bounds.minServiceTime))*20/60;
bounds.minDistCostCharter = sum(sum(jobsKM(:,2:end)))*3;
bounds.minDistCostTrucks = sum(sum(jobsKM(:,2:end)))*0.44;
bounds.fixedCost = size(jobsW,1)*20;
bounds.upperBound = bounds.minTimeCost + bounds.minDistCostCharter + bounds.fixedCost;
bounds.lowerBound = bounds.minTimeCost + bounds.minDistCostTrucks;

%% Get initial solutions
% load or call script.

% Particle (with charter initial solution)
for i = 1:10
    particle(i).X = [zeros(size(jobsW,1),size(trucks,1)) eye(size(jobsW,1))];
    particle(i).routeCost = zeros(1,671);
end

routeIndex = 1:size(particle(1).X,2);

% Calculate all initial fitness
for i = 1:size(particle,2) % For each particle
    for j=routeIndex(sum(particle(i).X,1) > 0) % For all routes with at least one job
        
        subsetJobs = logical(particle(i).X(:,j));
        
        jobsWS = jobsW(subsetJobs,:); % Pick subsets
        jobsTS = jobsT(subsetJobs,:);
        jobsKMS = jobsKM(subsetJobs,:);
        
        [~,In] = sort(jobsWS(:,4)); % Sort based on mean times 
        routeW = jobsWS(In,:); % Sort job subset 
        routeT = jobsTS(In,:); % Equally sort corresponding service times
        
        if j <= size(particle(1).X,2)-size(jobsW,1) % FIRST TRUCKS ARE DEEMED CHARTER
            idTruck = j; % If the truck is not a charter, get truck id
            travelTime = TimeMatrix(sub2ind(size(TimeMatrix),[truckHomes(idTruck);routeW(:,3)],[routeW(:,2);truckHomes(idTruck)]));
            travelDistance = DistanceMatrix(sub2ind(size(DistanceMatrix),[truckHomes(idTruck);routeW(:,3)],[routeW(:,2);truckHomes(idTruck)]));
            travelTime(travelTime == 0) = 1;
        else
            travelTime = [1;TimeMatrix(sub2ind(size(TimeMatrix),routeW(2:end,3),routeW(1:end-1,2)));1]; % Add artificial traveling minutes for charters
            travelDistance = DistanceMatrix(sub2ind(size(DistanceMatrix),routeW(2:end,3),routeW(1:end-1,2)));
            travelTime(travelTime == 0) = 1;
        end
        
        totalDistance = sum(sum(jobsKMS(:,2:end))) + sum(travelDistance);
        
        % Retrieve lateness and duration 
        [realArr,minutesLate,duration]  = getDuration(routeW(:,5:end),routeT(:,2:end),travelTime);
        
        particle(i).routeCost(j) = duration*20/60 + totalDistance*truckCost(j) + alpha*minutesLate; % Ommited gamma costs
    end
    particle(i).totalCost = sum(particle(i).routeCost);
end



%%
% FOR EACH PARTICLE
% Initialize decision variable x_ij - Job i belonging to truck j

% Retrieve initial solutions x_ij
% Sort routes -> retrieve lateness & waiting time
% Calculate costs

% LOOP
% Retrieve neighborhood
% shake and escalate or select local optimum
% Move in direction of local optimum by path relinking
% (CROSS-exchange affected)
% Sort routes -> retrieve lateness & waiting time
% Calculate costs
% Move if new solution is improvement compared to old

clock.totalTime = toc(clock.totalTime);