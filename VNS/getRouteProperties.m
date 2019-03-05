function [departureTimes,minutesLate,duration,totalDistance] = getRouteProperties(routes,routeID,jobsW,jobsT,jobsKM,truckHomes,DistanceMatrix,TimeMatrix)

subsetJobs = logical(routes(:,routeID));

jobsWS = jobsW(subsetJobs,:); % Pick subsets
jobsTS = jobsT(subsetJobs,:);
jobsKMS = jobsKM(subsetJobs,:);

[~,In] = sort(jobsWS(:,4)); % Sort based on mean times
routeW = jobsWS(In,:); % Sort job subset
routeT = jobsTS(In,:); % Equally sort corresponding service times

if routeID <= size(routes,2)-size(jobsW,1) % FIRST TRUCKS ARE DEEMED REGULAR
    idTruck = routeID; % If the truck is not a charter, get truck id
    travelTime = TimeMatrix(sub2ind(size(TimeMatrix),[truckHomes(idTruck);routeW(:,3)],[routeW(:,2);truckHomes(idTruck)]));
    travelDistance = DistanceMatrix(sub2ind(size(DistanceMatrix),[truckHomes(idTruck);routeW(:,3)],[routeW(:,2);truckHomes(idTruck)]));
    travelTime(travelTime == 0) = 1;
else
    travelTime = [1;TimeMatrix(sub2ind(size(TimeMatrix),routeW(2:end,3),routeW(1:end-1,2)));1]; % Add artificial traveling minutes for charters
    travelDistance = DistanceMatrix(sub2ind(size(DistanceMatrix),routeW(2:end,3),routeW(1:end-1,2)));
    travelTime(travelTime == 0) = 1;
end

totalDistance = sum(sum(jobsKMS(:,2:end))) + sum(travelDistance);

% Retrieve lateness and duration
[departureTimes,minutesLate,duration]  = getDuration(routeW(:,5:end),routeT(:,2:end),travelTime);

end