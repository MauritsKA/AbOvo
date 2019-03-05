function [q_final] = relinkPath(p,q,pTotal,qTotal,pRoutecosts, qRoutecosts,k,numberOfIter)

indexVec = (1:size(p,1))';
indexCol = (1:size(p,2))';
qbest = q;

bestvalue = inf(numberOfIter+1,1);
val_temp = zeros(k,1);
switches = zeros(numberOfIter,1);

bestvalue(1) = qTotal;

bestRouteCost(1,:) = qRoutecosts;

for j = 1:numberOfIter
    
    qbest_and_p = qbest & p;
    q_not_p = logical(1 - sum(qbest_and_p,2));
    
    
    if sum(q_not_p) == 0
        [~,indexBestValue] = min(bestvalue);
        
        q_final = q;
        if indexBestValue > 1
            switchesDone = switches(1:indexBestValue-1);
            q_final(switchesDone,:) = p(switchesDone,:);
        end
        return
    end
    index_possible_switches = indexVec(q_not_p);
    index_possible_switches_random = index_possible_switches(randperm(length(index_possible_switches)));
    
    maxSwitches = min(k,length(index_possible_switches_random));
    row_switches = index_possible_switches_random(1:maxSwitches);
    
    for i = 1:maxSwitches
        qtemp = qbest;
        oldRow = qtemp(row_switches(i),:) > 0;
        oldCol = indexCol(oldRow);
        
        newRow = p(row_switches(i),:) > 0;
        newCol = indexCol(newRow);
        
        qtemp(row_switches(i),:) = p(row_switches(i),:);
        
        routes = qtemp;
        colID = [oldCol newCol];
        for l = 1:2 % Reset costs for 2 affected columns by ith switch in jth iteration
            routeID = colID(l);
            if sum(routes(:,routeID)) ~= 0 % If route contains no jobs anymore, set costs to zero
                [departureTimes,minutesLate,duration,totalDistance] = getRouteProperties(routes,routeID,jobsW,jobsT,jobsKM,truckHomes,DistanceMatrix,TimeMatrix);
                tempRouteCost(routeID) = duration*20/60 + totalDistance*truckCost(routeID) + alpha*minutesLate; % Ommited gamma costs
            else
                tempRouteCost(routeID) = 0;
            end
        end
        
        val_temp(i) = sum(tempRouteCost);
    end
    
    [bestvalue(j+1),id_best] = min(val_temp);
    qtemp = qbest; % Previous best solution
    qtemp(row_switches(id_best),:) = p(row_switches(id_best),:);
    
    oldRow = qtemp(row_switches(id_best),:) > 0;
    oldCol = indexCol(oldRow);
    
    newRow = p(row_switches(id_best),:) > 0;
    newCol = indexCol(newRow);
        
    routes = qtemp;
    colID = [oldCol newCol];
    for l = 1:2 % Reset costs for 2 affected columns by ith switch in jth iteration
        routeID = colID(l);
        if sum(routes(:,routeID)) ~= 0 % If route contains no jobs anymore, set costs to zero
            [departureTimes,minutesLate,duration,totalDistance] = getRouteProperties(routes,routeID,jobsW,jobsT,jobsKM,truckHomes,DistanceMatrix,TimeMatrix);
            bestRouteCost(j+1,routeID) = duration*20/60 + totalDistance*truckCost(routeID) + alpha*minutesLate; % Ommited gamma costs
        else
            bestRouteCost(j+1,routeID) = 0;
        end
    end
    
    switches(j) = row_switches(id_best);
    qbest = qtemp; % New best solution in this stage
    
end

[~,indexBestValue] = min(bestvalue);

q_final = q;
if indexBestValue > 1
    switchesDone = switches(1:indexBestValue-1);
    q_final(switchesDone,:) = p(switchesDone,:);
    q_finalRouteCost = bestRouteCost(indexBestValue-1,:);
end


end