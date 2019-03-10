%% Truck Scheduling MIP
% Group 5 - OR - Erasmus University Rotterdam

%% Initialize
clear all; clc;
clock.totalTime = tic;

load ../NewData/Linkingmatrices
load ../NewData/Truck_Tank_info
load ../DataHS/CostsPerKmPerTrucks
load ../NewData/TankSchedule

t_0 = datetime(2018,03,0,00,00,00);

%% Parameters
alpha = 100; % Tuning parameters for cost function
gamma = 100;
setTrucks = 2; % Allowed tours per truck
stageCode = "max(5,2*particle(j).k)";
branchCode = "ceil(particle(j).k/2)+2";
crossWeightCode = "particle(j).k";
minOwnFleet = 0.3; % Set percentage of minimum own fleet used in crossover

kDecreaseCode = "1"; % If better neighbor found, reset neighborhood to 1
kIncreaseCode = "min(11, particle(j).k +1)"; % If no better neighborhood found, increase with one up to 11
pickNeighborCode =  "neighborIndex(1:3*particle(j).k)"; % 33 initial solutions, 11 neighborhoods, so each k adds 3 neighbors

iterations = 3000;
breakIteration = 300;
breakpoints = 0:breakIteration:iterations; 

%% Generating schedules
% Select trucks, remove table and pre convert tank adresses
trucks = Truck_Tank(Truck_Tank.ResourceType == "Truck",:);
truckHomes = getIndex(trucks.HomeAddressID); clear Truck_Tank trucks

% Convert tanktaniner schedules to Job schedule
load ../NewData/TruckJobs 
%jobs = getJobs(routesTankScheduling); % !! Either use original saved job schedule, or generate new one !!

% Convert job schedule to job matrix
[jobsW, jobsT, jobsKM] = getJobsMatrix(jobs,t_0);
jobsW(jobsW(:,1) == 545 | jobsW(:,1) == 549,:) = []; % Remove infeasible repositioning
jobsT(jobsT(:,1) == 545 | jobsT(:,1) == 549,:) = [];
jobsKM(jobsKM(:,1) == 545 | jobsKM(:,1) == 549,:) = [];

% Add costs for charters and duplicate costs for multiple use of trucks
truckCost = [repmat(CostsPerKm,setTrucks,1); 3*ones(size(jobsW,1),1)];

%% Creating initial solutions
particle = createInitialSolutions(jobsW,setTrucks);
particle(size(particle,2)+1).X = particle(size(particle,2)).X;

%% Lower bound given this specific tank handling
bounds.minTimeWindow = jobsW(sub2ind(size(jobsW),(1:size(jobsW,1))',sum(jobsW > 0,2)-1)) - jobsW(:,6);
bounds.minServiceTime = sum(jobsT(:,2:end),2);
bounds.minTimeCost = sum(max(bounds.minTimeWindow,bounds.minServiceTime))*20/60;
bounds.minDistCostTrucks = sum(sum(jobsKM(:,2:end)))*0.44;
bounds.lowerBound = bounds.minTimeCost + bounds.minDistCostTrucks;

%% Evaluate initial solutions
routeIndex = 1:size(particle(1).X,2);

% Calculate all initial fitness
[particle,objectives] = getInitialFitness(particle,routeIndex,jobsW,jobsT,jobsKM,setTrucks,truckHomes,truckCost,alpha,gamma);

%% Run the algorithm
similarityLevel = zeros(size(particle,2),size(particle,2));
meanSimilarity = zeros(iterations,1);
truckRepeats = 0:length(truckHomes):(setTrucks-1)*length(truckHomes); % Every index the trucks repeat

fprintf('Running iteration:  ');
for i = 1:iterations
    iterationTime = tic;
    
    fprintf(repmat('\b', 1, numel(num2str(i-1)))); fprintf('%d',i);
    
    for j = 1:size(particle,2) % For each particle
        
        % Retrieve neighborhood by similarity matrix
        for l = j+1:size(particle,2)
            similarityLevel(j,l) = getSimilarity(particle(j).X,particle(l).X);
        end
        similarityLevel(:,j) = similarityLevel(j,:);
        
        % Select k closest neighbors
        [~,neighborIndex] = sort(similarityLevel(j,:),'descend');
        
        pickedneighbors = eval(pickNeighborCode); % compare to neighborhood
        neighborCosts=zeros(length(pickedneighbors),1);
        for l = 1:length(pickedneighbors)
            neighborCosts(l) = particle(pickedneighbors(l)).totalCost;
        end
        
        [~,bestneighborIndex] = min(neighborCosts);
        bestneighbor = pickedneighbors(bestneighborIndex);
        
        % IF any close neighbor better: DO pathrelinking
        if particle(bestneighbor).totalCost < particle(j).totalCost
            numberOfStages = eval(stageCode);
            numberOfBranches = eval(branchCode); 
            
            guide = particle(bestneighbor).X;
            c = particle(j).X;
            cRoutecosts = particle(j).routeCost;
            cTotalcosts = particle(j).totalCost;
            cMinutesLate = particle(j).minutesLate;
            cDepartureTimes = particle(j).departureTimes;
            cMeanDeparture = particle(j).meanDeparture;
            cLatePerTruck = particle(j).latePerTruck;
            [cFinal, cFinalRouteCosts,cFinalMinutesLate,cFinaldepartureTimes,cFinalMeanDeparture,cFinalLatePerTruck] = relinkPath(guide,c,cRoutecosts,cTotalcosts,cMinutesLate,cDepartureTimes,cMeanDeparture,cLatePerTruck,numberOfBranches,numberOfStages,jobsW,jobsT,jobsKM,truckHomes,DistanceMatrix,TimeMatrix,truckCost,alpha,gamma,setTrucks);
            
            particle(j).X = cFinal;
            particle(j).routeCost = cFinalRouteCosts;
            particle(j).minutesLate = cFinalMinutesLate;
            particle(j).departureTimes = cFinaldepartureTimes;
            particle(j).meanDeparture = cFinalMeanDeparture;
            particle(j).latePerTruck = cFinalLatePerTruck;
            particle(j).lateViaHome = sum(cFinalLatePerTruck);
            particle(j).totalCost = sum(particle(j).routeCost)+gamma*particle(j).lateViaHome;
            particle(j).late = sum(cFinalMinutesLate) > 0.001;
            
            particle(j).k = eval(kDecreaseCode); % Update k - decrease
            
        else % ELSE IF local best: DO crossexchange
            
            particle(j).k = eval(kIncreaseCode); % Update k - increase
            
            crossWeight = eval(crossWeightCode); 
            [Xnew,selectedTrucksID] = CROSS_Exchange(particle(j).X,crossWeight,minOwnFleet);
            
            % Update cost
            newRouteCost = particle(j).routeCost; % Initialize with old
            newMinutesLate = particle(j).minutesLate;
            newDepartureTimes = particle(j).departureTimes;
            newMeanDeparture = particle(j).meanDeparture;
            newLatePerTruck = particle(j).latePerTruck;
            for l = 1:length(selectedTrucksID) % Get cost of affected routes
                routes = Xnew;
                routeID = selectedTrucksID(l);
                baseTruckID = mod(routeID,length(truckHomes));
                baseTruckID(baseTruckID == 0) = length(truckHomes);
                truckIDS = truckRepeats+baseTruckID; % Get all truck columns associated to affected route
        
                if sum(routes(:,routeID)) ~= 0 % If route contains no jobs anymore, set costs to zero
                    [departureTimes,minutesLate,duration,totalDistance] = getRouteProperties(routes,routeID,jobsW,jobsT,jobsKM,truckHomes,DistanceMatrix,TimeMatrix);
                    newRouteCost(routeID) = duration*20/60 + totalDistance*truckCost(routeID) + alpha*minutesLate + (routeID>size(routes,2)-size(routes,1))*20; % Ommited gamma costs
                    newMinutesLate(routeID) = minutesLate;
                    newDepartureTimes{routeID} = departureTimes;
                    newMeanDeparture(routeID) = mean(departureTimes);
                    
                    newLatePerTruck(baseTruckID) = getHomeSlack(setTrucks,truckHomes,newMeanDeparture(truckIDS),newDepartureTimes(truckIDS));
                    newLateViaHome = sum(newLatePerTruck);
                else
                    newRouteCost(routeID) = 0;
                    newMinutesLate(routeID) = 0;
                    newDepartureTimes{routeID} = 0;
                    newMeanDeparture(routeID) = 0;
                    
                    newLatePerTruck(baseTruckID) = getHomeSlack(setTrucks,truckHomes,newMeanDeparture(truckIDS),newDepartureTimes(truckIDS));
                    newLateViaHome = sum(newLatePerTruck);
                end
            end
                        
            %[newLatePerTruck, newLateViaHome] = getHomeSlack(setTrucks,truckHomes,particle(j).meanDeparture,particle(j).departureTimes,jobsW);
           
            if (sum(newRouteCost)+gamma*newLateViaHome) < particle(j).totalCost % If costs smaller then numeric error set new objective
                particle(j).routeCost = newRouteCost;
                particle(j).minutesLate = newMinutesLate;
                particle(j).departureTimes = newDepartureTimes;
                particle(j).meanDeparture = newMeanDeparture;
                particle(j).latePerTruck = newLatePerTruck;
                particle(j).lateViaHome = newLateViaHome;
                particle(j).totalCost = sum(newRouteCost)+gamma*newLateViaHome;
                particle(j).late = sum(newMinutesLate) > 0.001;
                particle(j).X = Xnew;
            end
        
        end 
        objectives(j,i+1) = particle(j).totalCost;
    end
    
    meanSimilarity(i) = mean(similarityLevel(:));
    
    if sum(breakpoints == i) > 0 
      [~,iBest] = min(objectives(:,end));
      Xopt = particle(iBest).X; 
      particle = createInitialSolutions(jobsW,setTrucks);
      particle(size(particle,2)+1).X = Xopt;
      [particle,~] = getInitialFitness(particle,routeIndex,jobsW,jobsT,jobsKM,setTrucks,truckHomes,truckCost,alpha,gamma);
    end 
    
    clock.iterationTime(i) = toc(iterationTime);
end
fprintf('\n \n')

inc = -100*diff(objectives(34,:))./objectives(34,1:end-1);
out = accumarray(ceil((1:numel(inc))/50)',inc(:),[],@mean);
out = resample(out,50,1);
plot(out);

improvement = 100*(objectives(:,end)-objectives(:,1))./objectives(:,1);
fprintf('Mean improvement over all particles: %.2f%% \n',mean(improvement));
fprintf('Best initial particle cost: %.0f \n',min(objectives(:,1)));
fprintf('Best optimized particle cost: %.0f \n',min(objectives(:,end)));
fprintf('Improvement optimal solution: %.2f%% \n',100*(min(objectives(:,end))-min(objectives(:,1)))/min(objectives(:,1)));
fprintf('Lower bound for this tank handling: %.0f \n',bounds.lowerBound);
fprintf('Optimality gap optimal solution: %.2f%% \n',100*(min(objectives(:,end))-bounds.lowerBound)/bounds.lowerBound);
fprintf('\n')

RESULTS.particle = particle;
RESULTS.objectives = objectives;
RESULTS.meanSimilarity = meanSimilarity;
RESULTS.alpha = alpha;
RESULTS.gamma = gamma;
RESULTS.breakpoints = breakpoints; 
RESULTS.iterations = iterations; 
RESULTS.branchCode = branchCode;
RESULTS.stageCode = stageCode;
RESULTS.setTrucks = setTrucks;
RESULTS.minOwnFleet = minOwnFleet;
RESULTS.crossWeightCode = crossWeightCode;
RESULTS.kDecreaseCode = kDecreaseCode;
RESULTS.kIncreaseCode = kIncreaseCode;
RESULTS.pickNeighborCode =  pickNeighborCode;

clock.totalTime = toc(clock.totalTime);
RESULTS.clock = clock;

fprintf('Mean iteration time: %.4f seconds \n',mean(clock.iterationTime));
fprintf('Total clock time: %.4f seconds \n',clock.totalTime);

