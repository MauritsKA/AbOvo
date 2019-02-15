% this script makes jobs
% job consists of 6 columns 1 start location 2 end location 3 4 opening
% window to start job 5 6 ending window when job can be finished
clear vars;
clc;
load('RoutesTest.mat')
load ../NewData/AddressInfo
load ../NewData/LinkingMatrices
% load loadingtimes
for i = 1:size(routesTankScheduling,2)
    routesTankScheduling(i).directCleaning = zeros(5,1);
end 

t_start = datetime(2018,03,01,00,00,00); % Set appropriate time window
j = 1;
sm = 36;
sc = 120;

for i = 1:size(routesTankScheduling,2)
    if ~isempty(routesTankScheduling(i).Ds) % if starting at Ds
        jobs(j).addressIndex = GetIndex(AddressInfo,routesTankScheduling(i).Ds.HomeAddressID);
        jobs(j).windowOpen = t_start;%routesTankScheduling(i).Ds.ReleaseTime;
        jobs(j).windowClose = t_start;
        jobs(j).ind = 1;
        jobs(j).workingT = 0;
        jobs(j).task = "dep";
        
        if ~isempty(routesTankScheduling(i).U) % If from Ds to U
            for k = 1:size(routesTankScheduling(i).U,1)
                
                if routesTankScheduling(i).directCleaning(k) == 0 % If indirect cleaning
                    % Closing previous job at cleaning. Origin can be order or depot
                    jobs(j).addressIndex(end+1) = GetIndex(AddressInfo,routesTankScheduling(i).cleaningAddress(k)); % huidige cleaninglocatie aan de laatste job
                    jobs(j).windowClose(end) = routesTankScheduling(i).U.PickupWindowEnd(k)-minutes(1); % closing time van cleaning locatie is closing time sup - 1min
                    jobs(j).workingT(end+1) = sm+TimeMatrix(jobs(j).addressIndex(end-1),jobs(j).addressIndex(end));
                    if strcmp(jobs(j).task(end),"dep")
                        jobs(j).workingT(end) = jobs(j).workingT(end)+sm;
                    end
                    if strcmp(jobs(j).task(end),"cus")
                        jobs(j).workingT(end) = jobs(j).workingT(end)+routesTankScheduling(i).U.loadTime(k);
                    end
                    jobs(j).windowOpen(end+1) = jobs(j).windowOpen(end)+minutes(1);
                    jobs(j).windowClose(end+1) = jobs(j).windowClose(end);
                    jobs(j).ind(end+1) = 0;
                    jobs(j).task(end) = "cl";
                    
                    % Open new job from cleaning
                    j = j+1;
                    jobs(j).addressIndex = jobs(j-1).addressIndex(end);
                    jobs(j).windowOpen = jobs(j-1).windowOpen(end)+minutes(1);
                    jobs(j).windowClose = jobs(j-1).windowClose(end);
                    jobs(j).ind = 1;
                    jobs(j).workingT = 0;
                    jobs(j).task = "cl";
                end
                
                % Continue with job. Origin can be both new job from indirect cleaning, previous customer or depot
                jobs(j).addressIndex(end+1) = GetIndex(AddressInfo,routesTankScheduling(i).U.FromAddressID(k));
                jobs(j).windowOpen(end+1) = routesTankScheduling(i).U.PickupWindowStart(k);
                jobs(j).windowClose(end+1) = routesTankScheduling(i).U.PickupWindowEnd(k);
                if strcmp(jobs(j).task(end),"dep") || strcmp(jobs(j).task(end),"cus")
                    jobs(j).workingT(end+1) = sc+sm+TimeMatrix(jobs(j).addressIndex(end-1),GetIndex(AddressInfo,routesTankScheduling(i).cleaningAddress(k))) ...
                        +TimeMatrix(GetIndex(AddressInfo,routesTankScheduling(i).cleaningAddress(k)),jobs(j).addressIndex(end));
                end
                if strcmp(jobs(j).task(end),"cl")
                    jobs(j).workingT(end+1) = sm+TimeMatrix(jobs(j).addressIndex(end-1),jobs(j).addressIndex(end));
                end
                jobs(j).task = "sup";
                jobs(j).ind = 1; % SHOULD BE ASSESED - CURRENTLY ASSUMPTION
                
                % Continue with job. Origin is supplier
                jobs(j).addressIndex(end+1) = GetIndex(AddressInfo,routesTankScheduling(i).U.ToAddressID(k));
                jobs(j).windowOpen(end+1) = routesTankScheduling(i).U.DeliveryWindowStart(k);
                jobs(j).windowClose(end+1) = routesTankScheduling(i).U.DeliveryWindowEnd(k);
                jobs(j).workingT(end+1) = TimeMatrix(jobs(j).addressIndex(end-1),jobs(j).addressIndex(end))+routesTankScheduling(i).U.loadTime(k);
                jobs(j).ind = 1; % SHOULD BE ASSESED - CURRENTLY ASSUMPTION
                jobs(j).task = "cus";
            end
        end
    end 
%         if ~isempty(routesTankScheduling(i).O)
%             if routesTankScheduling(i).directCleaning(end) == 0
%                 job(j,2) = GetIndex(AddressInfo,routesTankScheduling(i).O.cleaningAddress);
%                 job(j,6) = routesTankScheduling(i).O.DeliveryWindowEnd...
%                     -TimeMatrix(job(j,2),GetIndex(AddressInfo,routesTankScheduling(i).O.ToAddressID))-sm;
%                 latest time at supplier - driving to terminal -mounting
%                 for next truck
%                 if ~isempty(routesTankScheduling(i).U)
%                 else
%                     job(j,4) = minutes(routesTankScheduling(i).O.DeliveryWindowEnd-t_start)...
%                         -TimeMatrix(getInfo(AddressInfo,routesTankScheduling(i).O.FromAddress),job(j,2))...
%                         -routesTankScheduling(i).O.loading...
%                         -TimeMatrix(GetInfo(AddressInfo,routesTankScheduling(i).cleaningAddress),getInfo(AddressInfo,routesTankScheduling(i).O.FromAddress))...
%                         -192;
%                     closing time terminal - workingTime (sup-ter) - loading
%                     - workingTime (clean-sup) -mounting - cleaningtime - dismounting
%                     job(j,5) = max(minutes(routesTankScheduling.O.PickupWindowStart-t_start),job(j,3)...
%                         +TimeMatrix(job(j,1),routesTankScheduling(i).cleaningAddress+72));
%                     earliest finish is max(open sup,release + travel to
%                     clean+ mount +dismount)
%                 end
%                 j = j+1; % we know that after the indirect cleaning the last part of the order is bringing
%                 the tank to the supplier and then directly to the
%                 terminal
%                 job(j,1) = job(j-1,2); % cleaning location is starting point for this job
%                 job(j,2) = GetIndex(AddressInfo,routesTankScheduling(i).O.ToAddressID);
%                 job(j,3) = job(j-1,5)+120; % earliest ending time of previous part of the order
%                 job(j,4) = job(j-1,4)+120; % latest ending time of previous part of the order
%                 job(j,5) = job(j,3)+TimeMatrix(job(j,1),job(j,2))+72; % earliest starting time + driving time
%                 + mounting and dismounting
%                 job(j,6) = minutes(routesTankScheduling(i).O.DeliveryEndWindow-t_start);
%             else
%                 job(j,2) = GetIndex(AddressInfo,routesTankScheduling(i).O.ToAddressID);
%                 if isempty(routesTankScheduling(i).U) % direct cleaning and straight from depot
%                     job(j,4) = minutes(routesTankScheduling(i).O.DeliveryWindowEnd-t_start)...
%                         -TimeMatrix(job(j,1),GetIndex(AddressInfo,routesTankScheduling(i).cleaningAddress))...
%                         -TimeMatrix(GetIndex(AddressInfo,routesTankScheduling(i).cleaningAddress),job(j,2))...
%                         -192-routesTankScheduling(i).O.loadingTime;
%                     latest starting time if no U is deadline at terminal
%                     minus travel time via direct cleaning cleaning itself
%                     loading and mounting at depot and dismounting at
%                     terminal
%                     job(j,5) = max(minutes(routesTankScheduling(i).O.PickupWindowStart-t_start),...
%                         job(j,3)+TimeMatrix(job(j,1),GetIndex(AddressInfo,routesTankScheduling(i).cleaningAddress))...
%                         +36+120+TimeMatrix(GetIndex(AddressInfo,routesTankScheduling(i).cleaningAddress),...
%                         Getinfo(AddressInfo,routesTankScheduling.O.FromAddressID)))+...
%                         TimeMatrix(GetInfo(AddressInfo,routesTankScheduling(i).O.ToAddressID),job(j,2));
%                     earliest ending time is max between earliest arrival at sup
%                     and opening of sup + loading +travel time to terminal
%                     + dismounting at terminal
%                 else % direct cleaning and via U
%                     aansluiting met vorig gedeelte van de tanktainer
%                     route
%                 end
%                 job(j,6) = minutes(routesTankScheduling(i).O.DeliveryWindowEnd-t_start);
%             end
%         elseif ~isempty(routesTankScheduling(i).Wt)
%             job(j,2) = GetIndex(AddressInfo,routesTankScheduling(i).Wt.ToAddressID);
%             job(j,6) = minutes(routesTankScheduling(i).Wt.DeliveryWindowEnd-t_start);
%         else
%             job(j,2) = GetIndex(AddressInfo,routesTankScheduling(i).Dt);
%             job(j,6) = inf;
%         end
%     elseif ~isempty(routesTankScheduling(i).Ws) % if starting at
%         job(j,1) = GetIndex(AddressInfo,routesTankScheduling(i).Ws.FromAddressID);
%         job(j,3) = minutes(routesTankScheduling(i).Ws.PickupWindowStart-t_start);
%     else
%         job(j,1) = GetIndex(AddressInfo,routesTankScheduling(i).I.FromAddressID);
%         job(j,3) = minutes(routesTankScheduling(i).I.PickupWindowStart-t_start);
%     end
    j = j+1;
end

%%
