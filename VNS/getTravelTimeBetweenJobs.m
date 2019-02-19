function [travelTime] = getTravelTimeBetweenJobs(initialLocationTruck,jobSequence)
load ../NewData/LinkingMatrices
travelTime = TimeMatrix(sub2ind(size(TimeMatrix),[initialLocationTruck;jobSequence(:,1)],[jobSequence(:,2);initialLocationTruck]));

