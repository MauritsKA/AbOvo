function [latenessViaHome, totalLateness] = getHomeSlack(setTrucks,truckHomes,meanDeparture,departureTimes,jobsW)
if setTrucks > 1
    ind = repmat((1:length(truckHomes))',1,setTrucks); % All truck indices
    A = reshape(meanDeparture(1:end-size(jobsW,1))',[length(truckHomes) setTrucks]); % Get all mean truck times on each row
    [~, OrigColIdx] = sort(A,2); % Sort the rows individually;
    col=length(truckHomes)*(OrigColIdx-1); % Add for every multiple of the trucks the last index as base
    ind2 = ind+col;
    
    departures = cellfun(@(x) x(1), departureTimes(:,ind2(:,2:end)))';
    arrivals = cellfun(@(x) x(end), departureTimes(:,ind2(:,1:end-1)))';
    
    departures = reshape(departures, [length(truckHomes) setTrucks-1]);
    arrivals = reshape(arrivals, [length(truckHomes) setTrucks-1]);
    
    routeSlack = departures - arrivals;
    latenessViaHome = sum(-(routeSlack.*(routeSlack < 0)),2)';
    totalLateness = sum(latenessViaHome);
else
    latenessViaHome = zeros(1,length(truckHomes));
    totalLateness = 0;
end