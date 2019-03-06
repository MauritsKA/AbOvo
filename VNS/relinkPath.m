function [cFinal, cFinalRouteCosts,cFinalMinutesLate] = relinkPath(guide,c,cRoutecosts,cMinutesLate,k,numberOfIter,jobsW,jobsT,jobsKM,truckHomes,DistanceMatrix,TimeMatrix,truckCost,alpha)
% g = Guiding solution
% c = Current solution

indexJob = (1:size(guide,1))'; % Index for every job
indexRoute = (1:size(guide,2))'; % Index for every route

cStageTotalCosts = inf(numberOfIter+1,1);
cStageRouteCosts = inf(numberOfIter+1,size(guide,2));
cStageMinutesLate = inf(numberOfIter+1,size(guide,2));
switches = zeros(numberOfIter,1); 

cStage = c; % Set first stage to current solution
cStageRouteCosts(1,:) = cRoutecosts; % Set first stage route costs to current solution
cStageTotalCosts(1,:) = sum(cRoutecosts);
cStageMinutesLate(1,:) = cMinutesLate;

for i = 1:numberOfIter % Number of stages
    
    % Get all possible switches and permute to random order
    cStage_and_g = cStage & guide; % Where current stage and guiding solution both have values
    g_not_cStage =  logical(1 - sum(cStage_and_g,2)); % All jobs that are not performed on same route in g and c
    
    index_possible_switches = indexJob(g_not_cStage); % Indices for jobs
    index_possible_switches_random = index_possible_switches(randperm(length(index_possible_switches)));
    
    maxSwitches = min(k,length(index_possible_switches_random));
    row_switches = index_possible_switches_random(1:maxSwitches); % Select all indices for switches in this stage
    
    % If no switch possible, break all pathrelinking and return overall best
    if maxSwitches == 0       
        break 
    end 
    
    cBranchRouteCosts = repmat(cStageRouteCosts(i,:),maxSwitches,1); % Initialize branch route costs to stage route costs
    cBranchMinutesLate = repmat(cStageMinutesLate(i,:),maxSwitches,1);
    
    for j = 1:maxSwitches % Max number of branches, try all switches
        cBranch = cStage; % First branch is initial stage
        
        % Get two affected routes / columns
        oldRow = cBranch(row_switches(j),:);
        oldCol = indexRoute(logical(oldRow)); % Route ID of route from q where job is removed
        newRow = guide(row_switches(j),:);
        newCol = indexRoute(logical(newRow)); % Route ID of route from q where job is added
        
        % Perform switch
        cBranch(row_switches(j),:) = newRow; % Create new branch solution with ith switch
        
        % Calculate new costs of routes / columns and update branch route costs for jth switch
        routes = cBranch;
        routeID = oldCol;
        if sum(routes(:,routeID)) ~= 0 % If route contains no jobs anymore, set costs to zero
            [~,minutesLate,duration,totalDistance] = getRouteProperties(routes,routeID,jobsW,jobsT,jobsKM,truckHomes,DistanceMatrix,TimeMatrix);
            cBranchRouteCosts(j,routeID) = duration*20/60 + totalDistance*truckCost(routeID) + alpha*minutesLate; % Ommited gamma costs
            cBranchMinutesLate(j,routeID) = minutesLate;
        else
            cBranchRouteCosts(j,routeID) = 0;
            cBranchMinutesLate(j,routeID) = 0;
        end
        
        routeID = newCol;
        if sum(routes(:,routeID)) ~= 0 % If route contains no jobs anymore, set costs to zero
            [~,minutesLate,duration,totalDistance] = getRouteProperties(routes,routeID,jobsW,jobsT,jobsKM,truckHomes,DistanceMatrix,TimeMatrix);
            cBranchRouteCosts(j,routeID) = duration*20/60 + totalDistance*truckCost(routeID) + alpha*minutesLate; % Ommited gamma costs
            cBranchMinutesLate(j,routeID) = minutesLate;
        else
            cBranchRouteCosts(j,routeID) = 0;
            cBranchMinutesLate(j,routeID) = 0;
        end
    end
    
    % Compare total costs of all branches, select best branch and update stage route costs
    [cStageTotalCosts(i+1), branchBestIndex] = min(sum(cBranchRouteCosts,2));
    cStageRouteCosts(i+1,:) = cBranchRouteCosts(branchBestIndex,:);
    cStageMinutesLate(i+1,:) = cBranchMinutesLate(branchBestIndex,:);
    
    % Update stage with best branch switch
    cStage(row_switches(branchBestIndex),:) = guide(row_switches(branchBestIndex),:);
    
    % Save all stage switches
    switches(i) = row_switches(branchBestIndex);
end

% Find the best overall stage
[~,stageBestIndex] = min(cStageTotalCosts);

% Perform all row switches up to overall best stage, and return final solution and route costs
cFinal = c;
if stageBestIndex > 1 % If original solution is not the best found
    switchesDone = switches(1:stageBestIndex-1); % Amount of stages up to overall best
    cFinal(switchesDone,:) = guide(switchesDone,:);
    cFinalRouteCosts = cStageRouteCosts(stageBestIndex,:);
    cFinalMinutesLate = cStageMinutesLate(stageBestIndex,:);
else
    cFinalRouteCosts = cRoutecosts;
    cFinalMinutesLate = cMinutesLate;
end

end
