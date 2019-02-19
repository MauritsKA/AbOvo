function [minutesLate,duration] = getDuration(windows,workingTime,travelTime)

% Permute timewindows [open; close] in chronological order
a=windows(:,1:2:end)';
a= a(:)';
a = a(a>0);
a2 = windows(:,2:2:end)';
a2= a2(:)';
a2 = a2(a2>0);
wd=[a ;a2];

workingTime(:,1) = travelTime(1:end-1);
c = workingTime';
c = c(:)';
s=[c(c>0) travelTime(end)];
s(s == 0) = 5;

% Push back 
trianRev = fliplr(triu(ones(size(wd,2)))); % Upper left triangle for reverse
applicableSRev = repmat(s(1:end-1),size(wd,2),1).*trianRev; % All service times for task i (row), from task j (column)  
cumSRev = cumsum(applicableSRev,2,'reverse').*trianRev; % Cumulative sum reversed, from last (j) to first job (i)
fromWd = repmat([wd(1,end); fliplr(wd(2,1:end-1))'],1,size(wd,2)).*trianRev; % Possible moments to reset, with all closing and last opening
posArrivalsRev = fromWd - cumSRev; % Moments that you would arrive, starting in task j, doing all service up to task i
closingT = repmat(wd(2,:),size(wd,2),1).*trianRev; % Repetition of closing times

tooLate = posArrivalsRev(:,2:end) > closingT(:,1:end-1); % Given you start in i, are you later than the closing of task j (i-1) 
index = 1:size(wd,2)-1; 

backtrackRow = max(repmat(sum(tooLate,1)+1,size(wd,2)-1,1).*triu(ones(size(wd,2)-1)),[],2)';

tempArr = posArrivalsRev(sub2ind(size(posArrivalsRev),backtrackRow,2:size(wd,2))); % Take all possible arrivals that are selected (backtracking)
tempArr(index(tempArr == 0)) =wd(2,index(tempArr == 0)); % Replace all reset point with closing time windows
tempArr(end+1) = wd(1,end); % Except last task, for which opening is selected 

% Pull forward
trian = triu(ones(size(wd,2)));
applicableS = repmat(s(1:end-1),size(wd,2),1).*triu(ones(size(wd,2)),1); % Service time from i to j upwards
cumS = cumsum(applicableS,2).*trian; % Cumulative service time
openWd = repmat(wd(1,:),size(wd,2),1)'.*trian; % Opening times of each job
posArrivals = openWd+cumS; % Possible earliest arrivals

% Earliest pos arrival van zichzelf naar zichzelf geeft automatisch minimum,dus dan is smaller then zeker 0! 
smallerThenArr = posArrivals <= repmat(tempArr,size(wd,2),1); % Check if earliest arrival smaller than pushed back times (opt for wait)
selectedTimes = smallerThenArr.*repmat(tempArr,size(wd,2),1) + ~smallerThenArr.*posArrivals;
% select pushed back als arrival kleiner - pushed back is al opt
% Kies earliest arrival als feasibility gerepareerd moet worden 

open = repmat(wd(1,:),size(wd,2),1); % Opening times
feas = selectedTimes >= open; % Geef mogelijke routes (switch point naar opening window) 
[~, I] = max(feas,[],1); 
fixedI = fliplr(max(repmat(I,size(wd,2),1).*trianRev,[],2)'); % Get first index 1 and continue on that row
realArr = selectedTimes(sub2ind(size(posArrivals),fixedI,1:size(wd,2))); % Set new feasible path 

index2=1:size(wd,2);
first = min(index2(diff(fixedI) > 0)); % First index before first pulled forward feasibility repair
temp = flipud(cumSRev);

repullcumSRev=flipud(temp(1:first+1,1:first+1)); % Select rev cum service time up to first feasibility repair
repullClose=[repmat(realArr(first+1),1,first+1); repmat(flipud(wd(2,1:first)'),1,first+1)]; % first row opening, other rows close
possiblePulls = (repullClose-repullcumSRev).*fliplr(triu(ones(first+1))); % Maximum time you can leave to make repair
% Check if repull delivers a later departure then current, but if it is still within windows
repullOnTime = possiblePulls(1:end-1,2:end) > repmat(realArr(1:first),first,1) & possiblePulls(1:end-1,2:end) <= fliplr(repullClose(2:end,2:end)');

satisfyAll = sum(repullOnTime,2) == sum(triu(ones(first)),2); % Check if any row has a complete feasible repull
newStart = min(possiblePulls(satisfyAll,1));
keep = isempty(newStart); % Check if any new optimal start found
newStart(isempty(newStart)) = 0; 
realArr(1) = realArr(1)*keep + newStart*(1-keep); % Then replace that value

realArr
minArr = realArr(1:end-1)+s(2:end-1);
Exists = minArr > realArr(2:end)

duration=1;
late = realArr > wd(2,:)
minutesLate = sum(realArr(late) - wd(2,late))
end 