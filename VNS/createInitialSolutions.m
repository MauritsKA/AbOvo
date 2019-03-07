function [particle] = createInitialSolutions(jobsW,setTrucks)

load ../NewData/Truck_Tank_info
load ../NewData/LinkingMatrices
%% Created solutions
num.RANDOM_SOLUTIONS_OWN_FLEET = 10; %create random solution with own fleet only
num.RANDOM_SOLUTIONS = 10;           %create random solution using charters and own fleet
num.RANDOM_SOLUTIONS_OWN_FLEET_MAX_1_PER_TRUCK = 10;
%num.RANDOM_SOLUTIONS_MAX_1_PER_TRUCK = 10;     

%%
trucks = Truck_Tank(Truck_Tank.ResourceType == "Truck",:);
truckHomes = getIndex(trucks.HomeAddressID);

num.Jobs = size(jobsW,1);
num.Charters = num.Jobs;
num.Trucks = setTrucks*size(trucks,1);

num.Rows = num.Jobs;
num.Cols = num.Trucks + num.Charters;

%% Create Random Initial Solutions (own fleet only)
randomTrucks = randi([1,num.Trucks],num.Jobs,num.RANDOM_SOLUTIONS_OWN_FLEET);
jobsIndex = [1:1:num.Jobs]';

for i = 1:num.RANDOM_SOLUTIONS_OWN_FLEET
    randomSolutionTemp = zeros(num.Jobs,num.Trucks);
    randomSolutionTemp(sub2ind(size(randomSolutionTemp),jobsIndex, randomTrucks(:,i))) = 1;
    
    initSolution.RandomOwnFleet(:,:,i) = [randomSolutionTemp, zeros(num.Jobs, num.Charters)];
end
clear randomTrucks randomSolutionTemp i

%% Create Random Initial Solution
randomTrucks = randi([1,num.Cols],num.Jobs,num.RANDOM_SOLUTIONS);
jobsIndex = [1:1:num.Jobs]';

for i = 1:num.RANDOM_SOLUTIONS
    randomSolutionTemp = zeros(num.Jobs,num.Cols);
    randomSolutionTemp(sub2ind(size(randomSolutionTemp),jobsIndex, randomTrucks(:,i))) = 1;
    
    initSolution.Random(:,:,i) = randomSolutionTemp;
end
clear randomTrucks randomSolutionTemp i

%% HEURISTIC 1: closest own truck performs job
jobStartIndex = jobsW(:,2);
TimeMatrixJobsTrucksCombi = TimeMatrix(jobStartIndex, truckHomes);
TimeMatrixJobsTrucksCombiTrans = TimeMatrixJobsTrucksCombi';
[~,minStartTruck] = min(TimeMatrixJobsTrucksCombiTrans);
minStartTruck = minStartTruck';

SolutionTemp = zeros(num.Jobs,num.Cols);
SolutionTemp(sub2ind(size(SolutionTemp),jobsIndex,minStartTruck)) = 1;

initSolution.ClosestOwnTruck = SolutionTemp;

%% HEURISTIC 2: closest own truck performs 1 job, rest charter

jobsPerColumn = sum(SolutionTemp,1);
ownTrucksUsed = sum(jobsPerColumn > 0);
chartersUsed = num.Jobs - ownTrucksUsed;
trucksBooleanUsed = jobsPerColumn > 0;
tempVec = 1:1:num.Cols;
trucksIndexUsed = tempVec(trucksBooleanUsed)';

for i = 1:size(SolutionTemp,2)
    if sum(SolutionTemp(:,i)) > 0
        temp = find(SolutionTemp(:,i) == 1);
        temp2(i) = temp(1);
    end
end
temp2(temp2==0)=[];

SolutionTemp = zeros(num.Jobs,num.Cols);
SolutionTemp(sub2ind(size(SolutionTemp),temp2,trucksIndexUsed')) = 1;

jobsNotAssigned = sum(SolutionTemp,2) == 0;
tempVec2 = 1:1:num.Rows;
jobsNotAssignedID = tempVec2(jobsNotAssigned);
chartersIDs = num.Trucks+1:1:num.Trucks+chartersUsed;

SolutionTemp(sub2ind(size(SolutionTemp),jobsNotAssignedID,chartersIDs)) = 1;

initSolution.ClosestOwnTruckAndCharters = SolutionTemp;

%% Create random max 1 per truck
for i = 1:num.RANDOM_SOLUTIONS_OWN_FLEET_MAX_1_PER_TRUCK
randomJob = randperm(num.Jobs);
randomTruck = randperm(num.Trucks);
randomJobAssigned = randomJob(1:min(num.Trucks,num.Jobs));
randomTruckAssigned = randomTruck(1:length(randomJobAssigned));
%tempVec = 1:1:num.Trucks;

SolutionTemp = zeros(num.Jobs,num.Cols);
SolutionTemp(sub2ind(size(SolutionTemp),randomJobAssigned,randomTruckAssigned)) = 1;

chartersUsed = num.Jobs - num.Trucks;

jobsNotAssigned = sum(SolutionTemp,2) == 0;
tempVec2 = 1:1:num.Rows;
jobsNotAssignedID = tempVec2(jobsNotAssigned);
chartersIDs = num.Trucks+1:1:num.Trucks+chartersUsed;

SolutionTemp(sub2ind(size(SolutionTemp),jobsNotAssignedID,chartersIDs)) = 1;

initSolution.RandomMax1OwnFleet(:,:,i) = SolutionTemp;
end

%% create all charter
SolutionTemp = zeros(num.Jobs,num.Cols);
SolutionTemp(:,num.Trucks+1:end) = eye(num.Jobs);
initSolution.allCharters = SolutionTemp;

%% create particle format

for i = 1:num.RANDOM_SOLUTIONS_OWN_FLEET
    particle(i).X = sparse(initSolution.RandomOwnFleet(:,:,i));
end

for j = i+1:2*num.RANDOM_SOLUTIONS
      particle(j).X = sparse(initSolution.Random(:,:,j-num.RANDOM_SOLUTIONS_OWN_FLEET));
end
 
for k = j+1:3*num.RANDOM_SOLUTIONS_OWN_FLEET_MAX_1_PER_TRUCK
      particle(k).X = sparse(initSolution.RandomMax1OwnFleet(:,:,k-2*num.RANDOM_SOLUTIONS));
end

particle(k+1).X = sparse(initSolution.ClosestOwnTruck);
particle(k+2).X = sparse(initSolution.ClosestOwnTruckAndCharters);
particle(k+3).X = sparse(initSolution.allCharters);

 
 

