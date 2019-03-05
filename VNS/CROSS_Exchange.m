function [X,selectedTrucksID] = CROSS_Exchange(X,k,charter,minPercentageOwnFleet)
% This function performs at most k CROSS-exchanges between k+1 trucks on the matrix X. 
% X is a truck schedule where the rows represent jobs and the columns 
% represent trucks.
% charter is the column number of matrix X from which the list of trucks is
% chartered.

% determine how many own fleet trucks and how many charters perform cross
% exchange
maxPercentageCharters = 1-minPercentageOwnFleet;
amountOwnFleet = ceil((k+1)*(minPercentageOwnFleet+rand()*maxPercentageCharters));
amountCharters = k+1-amountOwnFleet;

selectedOwnFleetID = randperm(charter-1,amountOwnFleet);
selectedChartersID = charter+randperm(size(X,2)-charter,amountCharters);
selectedTrucksID = [selectedOwnFleetID, selectedChartersID];

trucksWithJobs = sum(X,1) > 0;
if sum(trucksWithJobs(selectedTrucksID)) == 0 % in case all selected routes are empty
    truckIDs = 1:size(X,2);
    trucksWithJobsID = truckIDs(trucksWithJobs); % list of trucks that have a job
    selectedTrucksID(1) = trucksWithJobsID(randi(numel(trucksWithJobsID),1));
end

nrJobsToExchange = sum(X(:,selectedTrucksID),1); % nr of jobs each selected truck can exchange
maxToExchange = randi([1,k+1],1,k+1)-1; % max number of jobs to exchange for each selected truck

toExchange = min(nrJobsToExchange,maxToExchange);% nr of jobs that each truck will exchange
if sum(toExchange) == 0
    toExchange = min(nrJobsToExchange,k);
end

affectedRoutes = X(:,selectedTrucksID); % boolean vector for jobs for each selected truck
rowIndex = (1:size(X,1))'; 
jobIDVector = ones(1,numel(selectedTrucksID));
jobIDMatrix = rowIndex*jobIDVector;
jobIDMatrixTrue = jobIDMatrix.*affectedRoutes;

hussleRows = randperm(size(X,1)); % new order of rows
hussledJobs = jobIDMatrixTrue(hussleRows',:);

rowsToMove = zeros(max(toExchange),k+1);
for i = 1:k+1 % for every truck where we exchange a route 
    temp = hussledJobs(:,i); 
    temp = temp(temp~=0); % make vector of jobs to exchange
    temp = full(temp(1:toExchange(i)));
    temp = [temp; zeros(size(rowsToMove,1)-numel(temp),1)];
    rowsToMove(:,i) = temp;
end
rowsToMove = rowsToMove(:);
rowsToMove = rowsToMove(rowsToMove >0);

newRoutes = affectedRoutes;
newRoutes(rowsToMove,:) = [affectedRoutes(rowsToMove,end) affectedRoutes(rowsToMove,1:end-1)];

X(:,selectedTrucksID) = newRoutes;
