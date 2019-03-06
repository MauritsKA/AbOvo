%% Truck Scheduling MIP
% Group 5 - OR - Erasmus University Rotterdam

%% Initialize
clear all; clc;
clock.totalTime = tic;

load ../NewData/TruckJobs
load ../NewData/Linkingmatrices
load ../NewData/Truck_Tank_info
load ../DataHS/CostsPerKmPerTrucks
load initial_particles2
load ../NewData/TankSchedule

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
jobsW(jobsW(:,1) == 545 | jobsW(:,1) == 549,:) = []; % Remove infeasible repositioning
jobsT(jobsT(:,1) == 545 | jobsT(:,1) == 549,:) = [];
jobsKM(jobsKM(:,1) == 545 | jobsKM(:,1) == 549,:) = [];

% Add costs for charters
truckCost = [CostsPerKm; 3*ones(size(jobsW,1),1)];

%% Lower and upper bound given this specific tank handling
bounds.minTimeWindow = jobsW(sub2ind(size(jobsW),(1:size(jobsW,1))',sum(jobsW > 0,2)-1)) - jobsW(:,6);
bounds.minServiceTime = sum(jobsT(:,2:end),2);

bounds.minTimeCost = sum(max(bounds.minTimeWindow,bounds.minServiceTime))*20/60;
bounds.minDistCostCharter = sum(sum(jobsKM(:,2:end)))*3;
bounds.minDistCostTrucks = sum(sum(jobsKM(:,2:end)))*0.44;
bounds.fixedCost = size(jobsW,1)*20;
bounds.lowerBound = bounds.minTimeCost + bounds.minDistCostTrucks;

%% Get initial solutions
routeIndex = 1:size(particle(1).X,2);

% Calculate all initial fitness
for i = 1:size(particle,2) % For each particle
    particle(i).routeCost = zeros(1,length(routeIndex));
    particle(i).minutesLate = zeros(1,length(routeIndex));
    
    for j=routeIndex(sum(particle(i).X,1) > 0) % For all routes with at least one job
        
        routes = particle(i).X;
        routeID = j;
        [departureTimes,minutesLate,duration,totalDistance] = getRouteProperties(routes,routeID,jobsW,jobsT,jobsKM,truckHomes,DistanceMatrix,TimeMatrix);
        
        particle(i).routeCost(j) = duration*20/60 + totalDistance*truckCost(j) + alpha*minutesLate; % Ommited gamma costs
        particle(i).minutesLate(j) = minutesLate;
    end
    
    particle(i).totalCost = sum(particle(i).routeCost);
    particle(i).Late = sum(particle(i).minutesLate) > 0.001;
    particle(i).k = 1;
    objectives(i,1) = particle(i).totalCost;
end


%% Run the algorithm
iterations = 20;
similarityLevel= zeros(size(particle,2),size(particle,2));

for i = 1:iterations
    i
    %clock.iterationTime(i) = tic;
    
    for j = 1:size(particle,2) % For each particle
        
        % Retrieve neighborhood by similarity matrix
        for l = j+1:size(particle,2)
            similarityLevel(j,l) = getSimilarity(particle(j).X,particle(l).X);
        end
        similarityLevel(:,j) = similarityLevel(j,:);
        
        % Select k closest neighbours
        [~,neighbourIndex] = sort(similarityLevel(j,:),'descend');
        
        pickedNeighbours = neighbourIndex(1:3*particle(j).k);
        neighbourCosts=[];
        for l = 1:length(pickedNeighbours)
            neighbourCosts(l) = particle(pickedNeighbours(l)).totalCost;
        end
        
        [~,bestNeighbourIndex] = min(neighbourCosts);
        bestNeighbour = pickedNeighbours(bestNeighbourIndex);
        
        % IF any close neighbour better: DO pathrelinking
        if particle(bestNeighbour).totalCost < particle(j).totalCost
            numberOfIter = max(5,3*particle(j).k);
            numberOfBranches = ceil(particle(j).k/2)+2;
            
            guide = particle(bestNeighbour).X;
            c = particle(j).X;
            cRoutecosts = particle(j).routeCost;
            cMinutesLate = particle(j).minutesLate;
            [cFinal, cFinalRouteCosts,cFinalMinutesLate] = relinkPath(guide,c,cRoutecosts,cMinutesLate,numberOfBranches,numberOfIter,jobsW,jobsT,jobsKM,truckHomes,DistanceMatrix,TimeMatrix,truckCost,alpha);
            
            particle(j).X = cFinal;
            particle(j).routeCost = cFinalRouteCosts;
            particle(j).totalCost = sum(cFinalRouteCosts);
            particle(j).minutesLate = cFinalMinutesLate;
            particle(j).Late = sum(particle(j).minutesLate) > 0.001;
            
            particle(j).k = 1; %max(1,k-1);
            
        else % ELSE IF local best: DO crossexchange
            minOwnFleet = 0.4;
            particle(j).k = min(11, particle(j).k +1);
            crossWeight =ceil( 1.5*particle(j).k);
            [Xnew,selectedTrucksID] = CROSS_Exchange(particle(j).X,crossWeight,minOwnFleet);
            
            % Update cost
            newRouteCost = particle(j).routeCost; % Initialize with old
            newMinutesLate = particle(j).minutesLate;
            for l = 1:length(selectedTrucksID) % Get cost of affected routes
                routes = Xnew;
                routeID = selectedTrucksID(l);
                
                if sum(routes(:,routeID)) ~= 0 % If route contains no jobs anymore, set costs to zero
                    [departureTimes,minutesLate,duration,totalDistance] = getRouteProperties(routes,routeID,jobsW,jobsT,jobsKM,truckHomes,DistanceMatrix,TimeMatrix);
                    newRouteCost(routeID) = duration*20/60 + totalDistance*truckCost(routeID) + alpha*minutesLate; % Ommited gamma costs
                    newMinutesLate(routeID) = minutesLate;
                else
                    newRouteCost(routeID) = 0;
                    newMinutesLate(routeID) = 0;
                end
            end
            
            if sum(newRouteCost) < particle(j).totalCost*0.999 % If costs smaller then numeric error set new objective
                particle(j).routeCost = newRouteCost;
                particle(j).totalCost = sum(newRouteCost);
                particle(j).minutesLate = newMinutesLate;
                particle(j).Late = sum(newMinutesLate) > 0.001;
                particle(j).X = Xnew;
            end
        
        end 
        objectives(j,i+1) = particle(j).totalCost;
    end
    
    %clock.iterationTime(i) = toc(clock.iterationTime(i));
end
improvement = 100*(objectives(:,end)-objectives(:,1))./objectives(:,1);
mean(improvement);
min(objectives(:,1));
min(objectives(:,end));

clock.totalTime = toc(clock.totalTime);