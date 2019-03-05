function [realArr,minutesLate,duration] = getDuration(windows,workingTime,travelTime)

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
s(s == 0) = 1;

% Push back 
trianRev = fliplr(triu(ones(size(wd,2)))); % Upper left triangle for reverse
applicableSRev = repmat(s(1:end-1),size(wd,2),1).*trianRev; % All service times for task i (row), from task j (column)  
cumSRev = cumsum(applicableSRev,2,'reverse').*trianRev; % Cumulative sum reversed, from last (j) to first job (i)
fromWd = repmat([wd(1,end); fliplr(wd(2,1:end-1))'],1,size(wd,2)).*trianRev; % Possible moments to reset, with all closing and last opening
posArrivalsRev = fromWd - cumSRev; % Moments that you would arrive, starting in task j, doing all service up to task i
closingT = repmat(wd(2,:),size(wd,2),1).*trianRev; % Repetition of closing times

tooLate = posArrivalsRev(:,2:end) > closingT(:,1:end-1); % Given you start in i, are you later than the closing of task j (i-1) 
index = 1:size(wd,2)-1; 

[~,Iupper] = max(~tooLate,[],1);

backtrackRow = max(repmat(Iupper,size(wd,2)-1,1).*triu(ones(size(wd,2)-1)),[],2)';

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

maxSlack = wd(2,1:first) - realArr(1:first); % Check all slack time every task has up to close window 
initialSlack = realArr(first+1) - s(first+1) - realArr(first); % Check slack created by first pushed forward task (for feasibility)
appliedRepull = min([initialSlack maxSlack]); % Check from complete task list the minimum slack of all 
realArr(1:first) = realArr(1:first)+appliedRepull; % Apply on all up to first, because their windows are already tight

minArr = [realArr(1) realArr(1:end-1)+s(2:end-1)]; % Earliest time you could arrive at next destination given time now
feas = minArr > realArr*1.001; % Check if any next arrival is earlier then earliest possible
CHECKfeas = sum(feas); 

late = realArr > wd(2,:); % Check all task that are late
minutesLate = sum(realArr(late) - wd(2,late)); % Calculate lateness

minDuration = (wd(1,end)-wd(2,1))+s(1)+s(end); % Min duration is latest opening - first closing + travel times from and to home
duration= realArr(end)+s(end) - (realArr(1)-s(1)); % Actual duraction is first arrival minus home to, up to last arrival plus to home
CHECKdur = duration < minDuration; % Duration should never be smaller than minimum
end 