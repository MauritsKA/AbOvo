function [travelTime] = getTravelTimeBetweenJobs(initialLocationTruck,jobSequence)

travelTime = TimeMatrix(sub2ind(size(TimeMatrix),[initialLocationTruck;jobSequence(:,1)],[jobSequence(:,2);initialLocationTruck]));

