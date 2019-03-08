function [particle,objectives] = getInitialFitness(particle,routeIndex,jobsW,jobsT,jobsKM,setTrucks,truckHomes,truckCost,alpha,gamma)
load ../NewData/Linkingmatrices

for i = 1:size(particle,2) % For each particle
    particle(i).routeCost = zeros(1,length(routeIndex));
    particle(i).minutesLate = zeros(1,length(routeIndex));
    particle(i).latePerTruck = zeros(1,length(truckHomes));
    particle(i).departureTimes = cell(1,length(routeIndex));
    particle(i).departureTimes(1,:) = {0};
    particle(i).meanDeparture = zeros(1,length(routeIndex));
    
    for j=routeIndex(sum(particle(i).X,1) > 0) % For all routes with at least one job
        
        routes = particle(i).X;
        routeID = j;
        [departureTimes,minutesLate,duration,totalDistance] = getRouteProperties(routes,routeID,jobsW,jobsT,jobsKM,truckHomes,DistanceMatrix,TimeMatrix);
        
        particle(i).routeCost(j) = duration*20/60 + totalDistance*truckCost(j) + (j>size(routes,2)-size(routes,1))*20 + alpha*minutesLate;
        particle(i).minutesLate(j) = minutesLate;
        particle(i).departureTimes{j} = departureTimes;
        particle(i).meanDeparture(j) = mean(departureTimes);
    end
    
    [particle(i).latePerTruck, particle(i).lateViaHome] = getHomeSlack(setTrucks,truckHomes,particle(i).meanDeparture,particle(i).departureTimes,jobsW);
    particle(i).totalCost = sum(particle(i).routeCost)+gamma*particle(i).lateViaHome;
    particle(i).late = sum(particle(i).minutesLate) > 0.001;
    particle(i).k = 1;
    objectives(i,1) = particle(i).totalCost;
end

end 