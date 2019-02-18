function [routesTankScheduling] = getDirectness(routesTankScheduling, AddressInfo, TimeMatrix, DistanceMatrix)

C_min = 20/60;
C_km = 0.9320;
C_charter = 20;
cleaningTime = 120;
mountingTime = 36;

COST_TRESHHOLD_DEPOT = 1.2;
CHARTER_COSTS_HOUR = 3*(C_charter/C_min) + 2*mountingTime;

%% Calculate if depot is used
for i = 1:size(routesTankScheduling,2)
    if size(routesTankScheduling(i).depotAddress,1) > 0
        for j = 1:size(routesTankScheduling(i).depotAddress,1)
            SupAddresID = routesTankScheduling(i).U.FromAddressID(j);
            CusAddresID = routesTankScheduling(i).U.ToAddressID(j);
            SupAddresIndex = find(AddressInfo.AddressID == SupAddresID);
            CusAddresIndex = find(AddressInfo.AddressID == CusAddresID);
            SupEndTime = routesTankScheduling(i).U.PickupWindowEnd(j);
            CusStartTime = routesTankScheduling(i).U.DeliveryWindowStart(j);
            timeWindowDelta = minutes(CusStartTime - SupEndTime);
            directCosts = C_min * timeWindowDelta + C_km * DistanceMatrix(SupAddresIndex, CusAddresIndex);
            
            depotAddressID = routesTankScheduling(i).depotAddress(j);
            depotAddressIndex = find(AddressInfo.AddressID == depotAddressID);
            indirectDistance = DistanceMatrix(SupAddresIndex, depotAddressIndex) + DistanceMatrix(depotAddressIndex, CusAddresIndex);
            indirectDistanceCosts = C_km * indirectDistance;
            indirectTime = 2*mountingTime + TimeMatrix(SupAddresIndex, depotAddressIndex) + TimeMatrix(depotAddressIndex, CusAddresIndex);
            indirectTimeCost = C_min * indirectTime;
            indirectCost = indirectDistanceCosts + indirectTimeCost;
            
            if indirectTime < timeWindowDelta && COST_TRESHHOLD_DEPOT*indirectCost < directCosts
                routesTankScheduling(i).depotUsed(j) = true;
            else
                routesTankScheduling(i).depotUsed(j) = false;
            end
        end
    else
        routesTankScheduling(i).depotUsed = [];
    end
    routesTankScheduling(i).directCleaning = [];
end

%% Calculate (in)direct cleaning

for i = 1:size(routesTankScheduling,2)
    if size(routesTankScheduling(i).cleaningAddress,1) > 0
        
        if size(routesTankScheduling(i).Ds,1) > 0 || size(routesTankScheduling(i).Ws,1) > 0
            if size(routesTankScheduling(i).U,1) > 0
                routesTankScheduling(i).directCleaning(1) = true;
            elseif size(routesTankScheduling(i).O,1) > 0
                routesTankScheduling(i).directCleaning(1) = true;
            end
        end
        
        if size(routesTankScheduling(i).I,1) > 0
            
            if size(routesTankScheduling(i).U,1) > 0
                startTime = routesTankScheduling(i).I.DeliveryWindowEnd;
                startIndex = find(AddressInfo.AddressID == routesTankScheduling(i).I.ToAddressID);
                cleanIndex = find(AddressInfo.AddressID == routesTankScheduling(i).cleaningAddress(1));
                endIndex = find(AddressInfo.AddressID == routesTankScheduling(i).U.FromAddressID(1));
                travelTimeToClean = TimeMatrix(startIndex,cleanIndex);
                travelTimeToSup = TimeMatrix(cleanIndex, endIndex);
                endTime = routesTankScheduling(i).U.PickupWindowStart(1);
                timeDelta = minutes(endTime - startTime);
                tooMuchTime = timeDelta - cleaningTime - travelTimeToClean - travelTimeToSup;
                
                if tooMuchTime > CHARTER_COSTS_HOUR && tooMuchTime > 2*mountingTime
                    routesTankScheduling(i).directCleaning(1) = true;
                else
                    routesTankScheduling(i).directCleaning(1) = false;
                end
            elseif size(routesTankScheduling(i).O,1) > 0
                startTime = routesTankScheduling(i).I.DeliveryWindowEnd;
                startIndex = find(AddressInfo.AddressID == routesTankScheduling(i).I.ToAddressID);
                cleanIndex = find(AddressInfo.AddressID == routesTankScheduling(i).cleaningAddress(1));
                endIndex = find(AddressInfo.AddressID == routesTankScheduling(i).O.ToAddressID(1));
                travelTimeToClean = TimeMatrix(startIndex,cleanIndex);
                travelTimeToSup = TimeMatrix(cleanIndex, endIndex);
                endTime = routesTankScheduling(i).O.PickupWindowStart(1);
                timeDelta = minutes(endTime - startTime);
                tooMuchTime = timeDelta - cleaningTime - travelTimeToClean - travelTimeToSup;
                
                if tooMuchTime > CHARTER_COSTS_HOUR && tooMuchTime > 2*mountingTime
                    routesTankScheduling(i).directCleaning(1) = true;
                else
                    routesTankScheduling(i).directCleaning(1) = false;
                end
                
            end
            
            
        end
        
        
        if  size(routesTankScheduling(i).U,1) > 1
            for j = 2:size(routesTankScheduling(i).U,1)
                startTime = routesTankScheduling(i).U.DeliveryWindowEnd(j);
                startIndex = find(AddressInfo.AddressID == routesTankScheduling(i).U.ToAddressID(j));
                cleanIndex = find(AddressInfo.AddressID == routesTankScheduling(i).cleaningAddress(j));
                endIndex = find(AddressInfo.AddressID == routesTankScheduling(i).U.FromAddressID(j));
                travelTimeToClean = TimeMatrix(startIndex,cleanIndex);
                travelTimeToSup = TimeMatrix(cleanIndex, endIndex);
                endTime = routesTankScheduling(i).U.PickupWindowStart(j);
                timeDelta = minutes(endTime - startTime);
                tooMuchTime = timeDelta - cleaningTime - travelTimeToClean - travelTimeToSup;
                
                if tooMuchTime > CHARTER_COSTS_HOUR && tooMuchTime > 2*mountingTime
                    routesTankScheduling(i).directCleaning(j) = true;
                else
                    routesTankScheduling(i).directCleaning(j) = false;
                end
            end
        end
        
        
        
        if size(routesTankScheduling(i).U,1) > 0 && size(routesTankScheduling(i).O,1) > 0
            startTime = routesTankScheduling(i).U.DeliveryWindowEnd(end);
            startIndex = find(AddressInfo.AddressID == routesTankScheduling(i).U.ToAddressID(end));
            cleanIndex = find(AddressInfo.AddressID == routesTankScheduling(i).cleaningAddress(end));
            endIndex = find(AddressInfo.AddressID == routesTankScheduling(i).O.FromAddressID);
            travelTimeToClean = TimeMatrix(startIndex,cleanIndex);
            travelTimeToSup = TimeMatrix(cleanIndex, endIndex);
            endTime = routesTankScheduling(i).O.PickupWindowStart;
            timeDelta = minutes(endTime - startTime);
            tooMuchTime = timeDelta - cleaningTime - travelTimeToClean - travelTimeToSup;
            
            endInd = size(routesTankScheduling(i).U,1) + 1;
            
            if tooMuchTime > CHARTER_COSTS_HOUR && tooMuchTime > 2*mountingTime
                routesTankScheduling(i).directCleaning(endInd) = true;
            else
                routesTankScheduling(i).directCleaning(endInd) = false;
            end
        end
    end
end

end