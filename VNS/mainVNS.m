%% Truck Scheduling MIP
% Group 5 - OR - Erasmus University Rotterdam

clear all; clc;
totalTime = tic;

load ../NewData/TankSchedule
load ../NewData/TruckJobs
load ../NewData/Linkingmatrices
load ../NewData/Truck_Tank_info
load ../NewData/AddressInfo
load ../DataHS/CostsPerKmPerTrucks

CostsPerKm = [CostsPerKm;1.06; 1.06];

t_0 = datetime(2018,03,0,00,00,00);

trucks = Truck_Tank(Truck_Tank.ResourceType == "Truck",:);
truckHomes = getIndex(trucks.HomeAddressID);

% Convert job schedule to job matrix
[jobsW, jobsT, jobsKM] = getJobsMatrix(jobs,t_0);

% Lower and upper bound given this specific tank handling
minTimeCost = sum(sum(jobsT(:,2:end)))*20/60;
minDistCostCharter = sum(sum(jobsKM(:,2:end)))*3;
minDistCostTrucks = sum(sum(jobsKM(:,2:end)))*0.44;
fixedCost = size(jobsW,1)*20;
upperBound = minTimeCost + minDistCostCharter + fixedCost;
lowerBound = minTimeCost + minDistCostTrucks;

rng(1)
iter = 1000000;

result =zeros(iter,6);
jobList = 1:size(jobsW,1);
truckList = 1:size(trucks,1);

sortingTime = tic;
j=1;
for i = 1:iter
    if ~isempty(jobList)
        nrOfJobs = min(randi(6,1,1)+1,length(jobList));
        pickJobs = randi(length(jobList),nrOfJobs,1)';
        pickTruck = randi(length(truckList),1,1);
        
        idt = truckList(pickTruck); % Select a truck
        idj = jobList(pickJobs); % Select a few jobs
                
        jobWS = jobsW(idj,:); % Pick subsets
        jobsTS = jobsT(idj,:);
        jobsKMS = jobsT(idj,:);
        
        %reorder_route(jobsM);
        [routeW, In] = sortrows(jobWS,4); % same
        routeT = jobsTS(In,:); % same
        
        travelTime = TimeMatrix(sub2ind(size(TimeMatrix),[truckHomes(idt);routeW(:,3)],[routeW(:,2);truckHomes(idt)]));
        travelDistance = DistanceMatrix(sub2ind(size(TimeMatrix),[truckHomes(idt);routeW(:,3)],[routeW(:,2);truckHomes(idt)]));
        travelTime(travelTime == 0) = 5;
        
        totalDistance = sum(sum(jobsKMS(:,2:end))) + sum(travelDistance);
        homeDistance =  travelDistance(1) + travelDistance(end); 

        
        [realArr,minutesLate,duration,CHECKearly,CHECKdur]  = getDuration(routeW(:,5:end),routeT(:,2:end),travelTime);
        if minutesLate == 0 && homeDistance < 60
        truckList(pickTruck)=[]; % Remove used trucks
        jobList(pickJobs) = []; % Remove used jobs
        
        jobCosts = duration*20/60 + totalDistance*CostsPerKm(idt); 
       
        result(j,:) = [idt, minutesLate, duration, totalDistance, homeDistance, jobCosts];
        j=j+1;
        if isempty(jobList)
            neededIters = i 
        end 
        end 
    end
end
nrOfFeas = sum(result(:,2) > 0)/iter
sortingTime = toc(sortingTime)

extraTimeCost = sum(sum(jobsT(jobList,2:end)))*20/60;
extraDistCost = sum(sum(jobsKM(jobList,2:end)))*3;
extraFixedCost = length(jobList)*20;

totalExtra = extraTimeCost+extraDistCost+extraFixedCost
totalRegular = sum(result(:,end))
totalSchedule = totalExtra+totalRegular

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

totalTime = toc(totalTime)