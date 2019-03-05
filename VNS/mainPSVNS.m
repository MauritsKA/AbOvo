%% Truck Scheduling MIP
% Group 5 - OR - Erasmus University Rotterdam

%% Initialize
clear all; clc;
clock.totalTime = tic;

load ../NewData/TruckJobs
load ../NewData/Linkingmatrices
load ../NewData/Truck_Tank_info
load ../DataHS/CostsPerKmPerTrucks
load initial_particles

t_0 = datetime(2018,03,0,00,00,00);
alpha = 100; % Tuning parameters for cost function
gamma = 100;

% Select trucks, remove table and pre convert tank adresses
trucks = Truck_Tank(Truck_Tank.ResourceType == "Truck",:);
truckHomes = getIndex(trucks.HomeAddressID); clear Truck_Tank trucks

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
%bounds.upperBound = bounds.minTimeCost + bounds.minDistCostCharter + bounds.fixedCost;
bounds.lowerBound = bounds.minTimeCost + bounds.minDistCostTrucks;

%% Get initial solutions
% load or call script.

% Particle (with charter initial solution)
% for i = 1:2
%     particle(i).X = [zeros(size(jobsW,1),size(trucks,1)) eye(size(jobsW,1))];
%     particle(i).routeCost = zeros(1,671);
% end

routeIndex = 1:size(particle(1).X,2);

% Calculate all initial fitness
for i = 1:size(particle,2) % For each particle
    for j=routeIndex(sum(particle(i).X,1) > 0) % For all routes with at least one job
        
        routes = particle(i).X;
        routeID = j;
        [departureTimes,minutesLate,duration,totalDistance] = getRouteProperties(routes,routeID,jobsW,jobsT,jobsKM,truckHomes,DistanceMatrix,TimeMatrix);
        
        particle(i).routeCost(j) = duration*20/60 + totalDistance*truckCost(j) + alpha*minutesLate; % Ommited gamma costs
    end
    
    particle(i).totalCost = sum(particle(i).routeCost);
    particle(i).k = 7;
    Objectives(i,1) = particle(i).totalCost;
end


%% Run the algorithm
iterations = 10000;


for i = 1:iterations
    clock.iterationTime(i) = tic;
    
    % Retrieve neighborhood by similarity matrix
    % getsimilarity()
    
    for j = 1:size(particle,2) % For each particle
        % Select k closest neighbours
        
        % IF any close neighbour better
        % DO pathrelinking
        
        % ELSE IF local best
        % DO crossexchange
        [Xnew,selectedTrucksID] = CROSS_Exchange(particle(j).X,particle(j).k,0.3);
        newRouteCost = particle(j).routeCost;
        
        for l = 1:length(selectedTrucksID) % Get cost of affected routes
            routes = Xnew;
            routeID = selectedTrucksID(l); 
            
            if sum(routes(:,routeID)) ~= 0 % If route contains no jobs anymore, set costs to zero
            [departureTimes,minutesLate,duration,totalDistance] = getRouteProperties(routes,routeID,jobsW,jobsT,jobsKM,truckHomes,DistanceMatrix,TimeMatrix);
            newRouteCost(routeID) = duration*20/60 + totalDistance*truckCost(routeID) + alpha*minutesLate; % Ommited gamma costs
            else
                newRouteCost(routeID) = 0;
            end 
        end
        
        Objectives(j,i) = particle(j).totalCost;
        if sum(newRouteCost) < particle(j).totalCost*0.999 % If costs smaller then numeric error set new objective 
            particle(j).routeCost = newRouteCost;
            particle(j).totalCost = sum(newRouteCost);
            particle(j).X = Xnew;
            Objectives(j,i) = particle(j).totalCost;
        end 
        
        % k = k+1
        
        % IF any solution improved own cost
        % DO update solution
        
    end
    
    clock.iterationTime(i) = toc(clock.iterationTime(i));
end
improvement = 100*(Objectives(:,end)-Objectives(:,1))./Objectives(:,1);
mean(improvement)
min(Objectives(:,1))
min(Objectives(:,end))

clock.totalTime = toc(clock.totalTime);