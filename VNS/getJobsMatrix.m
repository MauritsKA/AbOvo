function [jobsW,jobsT] = getJobsMatrix(jobs,t_0)

tasksLength = zeros(size(jobs,2),1);
for i= 1:size(jobs,2)
    tasksLength(i,1) = length(jobs(i).tasks);  
    sourceLink(i,1) = strcmp(jobs(i).sets(1),"Ds") | strcmp(jobs(i).sets(1),"Ws") | strcmp(jobs(i).sets(1),"I");
    DtLink(i,1) = jobs(i).sets(end) ==  "Dt";
end
maxLength = max(tasksLength); 
jobsT = zeros(size(jobs,2),maxLength);

for i= 1:size(jobs,2)
    jobsW(i,1) = jobs(i).addressIndex(1);
    jobsW(i,2) = jobs(i).addressIndex(end);
    for j=1:length(jobs(i).tasks)
        jobsW(i,3+2*(j-1):3+2*j-1) = [minutes(jobs(i).windowOpen(j)-t_0) minutes(jobs(i).windowClose(j)-t_0)];
    end
    
    if sourceLink(i) == true && DtLink(i) == true
        routeMean(i,1) = mean(jobsW(i,5:4+2*(tasksLength(i)-2)));
    elseif  sourceLink(i) == true && DtLink(i) ~= true
        routeMean(i,1) = mean(jobsW(i,5:4+2*(tasksLength(i)-1)));
    elseif sourceLink(i) ~= true && DtLink(i) == true
        routeMean(i,1) = mean(jobsW(i,3:2+2*(tasksLength(i)-1)));
    elseif sourceLink(i) ~= true && DtLink(i) ~= true
        routeMean(i,1) = mean(jobsW(i,3:2+2*tasksLength(i)));
    end  
    
    jobsT(i,1:length(jobs(i).workingT))= jobs(i).workingT;
end

jobsW = [jobsW(:,1:2) routeMean jobsW(:,3:end)];
INDEX = 1:size(jobs,2);

% Remove (empty) jobs with equal start & end location and just 4 timewindows
INDEX = INDEX(~(jobsW(:,1) == jobsW(:,2) & sum(jobsW(:,3:end) > 0,2) == 4))';
jobsW = jobsW(~(jobsW(:,1) == jobsW(:,2) & sum(jobsW(:,3:end) > 0,2) == 4),:);

jobsW(isnan(jobsW(:,3)),3) = inf; % Set empty repositioning to inf mean time -> always perform as last task
jobsW = [INDEX jobsW];
jobsT = [INDEX jobsT(INDEX,:)];

end

