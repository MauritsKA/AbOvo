function [particle] = createInitialSolutions(jobsW,setTrucks,truckCost,type1,type2,type3,type4)

load ../NewData/Truck_Tank_info
load ../NewData/LinkingMatrices
%% Created solutions
num.RANDOM_SOLUTIONS_OWN_FLEET = type1; %create random solution with own fleet only
num.RANDOM_SOLUTIONS = type2;           %create random solution using charters and own fleet
num.RANDOM_SOLUTIONS_OWN_FLEET_MAX_1_PER_TRUCK = type3;
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

multipleUse = (length(truckHomes)*(randi(setTrucks,1,size(jobsW,1))-1))'; % add random extra indices for re use of truck
minStartTruck = minStartTruck+multipleUse;

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

%% Create random solution based on truck costs
baseNrOfJobs = floor(size(jobsW,1)/10); % 10 cheapest trucks
remainingJobs = mod(size(jobsW,1),10);
[~, sortedTruckIDS]= sort(truckCost);
cheapTruckIDS = sortedTruckIDS(1:10);

 initSolution.CheapTrucks(:,:,:)  = zeros(num.Jobs,num.Cols,type4);
 
for i = 1:type4
    allJobs = randperm(size(jobsW,1));
    
    for j=1:10
        if j==1
            initSolution.CheapTrucks(allJobs(1:baseNrOfJobs+remainingJobs),cheapTruckIDS(j),i) = 1;
        else 
            initSolution.CheapTrucks(allJobs((j-1)*baseNrOfJobs+remainingJobs+1:j*baseNrOfJobs+remainingJobs),cheapTruckIDS(j),i) = 1;
        end
        
    end     
end

%% create all charter
SolutionTemp = zeros(num.Jobs,num.Cols);
SolutionTemp(:,num.Trucks+1:end) = eye(num.Jobs);
initSolution.allCharters = SolutionTemp;

%% create particle format

for i = 1:num.RANDOM_SOLUTIONS_OWN_FLEET
    particle(i).X = sparse(initSolution.RandomOwnFleet(:,:,i));
end
i(isempty(i))=0;

for j = i+1:i+num.RANDOM_SOLUTIONS
    particle(j).X = sparse(initSolution.Random(:,:,j-num.RANDOM_SOLUTIONS_OWN_FLEET));
end
j(isempty(j))=i;

for k = j+1:j+num.RANDOM_SOLUTIONS_OWN_FLEET_MAX_1_PER_TRUCK
    particle(k).X = sparse(initSolution.RandomMax1OwnFleet(:,:,k-num.RANDOM_SOLUTIONS-num.RANDOM_SOLUTIONS_OWN_FLEET));
end
k(isempty(k))=j;

for l = k+1:k+type4
    particle(l).X = sparse(initSolution.CheapTrucks(:,:,l-num.RANDOM_SOLUTIONS-num.RANDOM_SOLUTIONS_OWN_FLEET-num.RANDOM_SOLUTIONS_OWN_FLEET_MAX_1_PER_TRUCK));
end
l(isempty(l))=k;

particle(l+1).X = sparse(initSolution.ClosestOwnTruck);
particle(l+2).X = sparse(initSolution.ClosestOwnTruckAndCharters);
particle(l+3).X = sparse(initSolution.allCharters);




