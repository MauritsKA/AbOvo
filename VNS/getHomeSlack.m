function [latenessViaHome] = getHomeSlack(setTrucks,truckHomes,meanDeparture,departureTimes)
if setTrucks > 1
    ind = repmat((1:length(meanDeparture)/setTrucks)',1,setTrucks); % All truck indices
    A = reshape(meanDeparture',[length(meanDeparture)/setTrucks setTrucks]); % Get all mean truck times on each row
    [~, OrigColIdx] = sort(A,2); % Sort the rows individually;
    col=length(meanDeparture)/setTrucks*(OrigColIdx-1); % Add for every multiple of the trucks the last index as base
    ind2 = ind+col;
    
%     departures2 = cellfun(@(x) x(1), departureTimes(:,ind2(:,2:end)))';
%     arrivals2 = cellfun(@(x) x(end), departureTimes(:,ind2(:,1:end-1)))';
    
    evenCol = ind2(:,2:end);
    countDep = 1;
    departures = zeros(size(evenCol,1),1);
    for i = evenCol(:)'
        departures(countDep) = departureTimes{:,i}(1);
        countDep = countDep+1;
    end
    
    oddCol = ind2(:,1:end-1);
    countArr = 1;
    arrivals = zeros(size(oddCol,1),1);
    for i = oddCol(:)'
        arrivals(countArr,1) = departureTimes{:,i}(end);
        countArr = countArr+1;
    end
        
    departures = reshape(departures, [length(meanDeparture)/setTrucks setTrucks-1]);
    arrivals = reshape(arrivals, [length(meanDeparture)/setTrucks setTrucks-1]);
    
    routeSlack = departures - arrivals;
    latenessViaHome = sum(-(routeSlack.*(routeSlack < 0)),2)';
else
    latenessViaHome = zeros(1,length(meanDeparture)/setTrucks);
end