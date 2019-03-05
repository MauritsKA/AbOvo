%% Convert tank schedule to truck jobs
% Group 5 - OR - Erasmus University Rotterdam

clear all;
clc;
load ../NewData/TankSchedule
load ../NewData/Linkingmatrices
load ../NewData/TankSets

t_0 = datetime(2018,03,01,00,00,00); % Set appropriate time window
j = 1;
sm = 36;
sc = 120;

nr_sources = size(routesTankScheduling,2);
times_to_cut = 0;
for i = 1:nr_sources
    times_to_cut = times_to_cut +sum(routesTankScheduling(i).directCleaning == 0) + sum(routesTankScheduling(i).depotUsed == 1);
end
nr_jobs = times_to_cut + nr_sources + size(Tfull,1);
jobs(1:nr_jobs) = struct('addressIndex',[],'windowOpen',[],'windowClose',[],'workingKM',[],'workingT',[],'tasks',[],'sets',[],'tankRouteID',[]);

for i = 1:size(routesTankScheduling,2)
    %% SOURCES
    if ~isempty(routesTankScheduling(i).Ds) % If starting at Ds
        jobs(j).addressIndex = getIndex(routesTankScheduling(i).Ds.HomeAddressID);
        jobs(j).windowOpen = t_0; % RoutesTankScheduling(i).Ds.ReleaseTime;
        jobs(j).windowClose = t_0; % Dummy time to initialize datetime object, updated later
        jobs(j).workingKM = 0;
        jobs(j).workingT = 0;
        jobs(j).tasks = "dep";
        jobs(j).sets = "Ds";
        jobs(j).tankRouteID = i;
        
    elseif ~isempty(routesTankScheduling(i).Ws)
        jobs(j).addressIndex = getIndex(routesTankScheduling(i).Ws.FromAddressID);
        jobs(j).windowOpen = routesTankScheduling(i).Ws.PickupWindowStart; % RutesTankScheduling(i).Ds.ReleaseTime;
        jobs(j).windowClose = routesTankScheduling(i).Ws.PickupWindowStart; % Dummy time to initialize datetime object, updated later
        jobs(j).workingKM = 0;
        jobs(j).workingT = 0;
        jobs(j).tasks = "ter";
        jobs(j).sets = "Ws";
        jobs(j).tankRouteID = i;
        
    elseif ~isempty(routesTankScheduling(i).I)
        jobs(j).addressIndex = getIndex(routesTankScheduling(i).I.FromAddressID);
        jobs(j).windowOpen = routesTankScheduling(i).I.PickupWindowStart;
        jobs(j).windowClose = routesTankScheduling(i).I.PickupWindowEnd;
        jobs(j).workingKM = 0;
        jobs(j).workingT = 0;
        jobs(j).tasks = "ter";
        jobs(j).sets = "I";
        jobs(j).tankRouteID = i;
        
        jobs(j).addressIndex(end+1) = getIndex(routesTankScheduling(i).I.ToAddressID);
        jobs(j).windowOpen(end+1) = routesTankScheduling(i).I.DeliveryWindowStart;
        jobs(j).windowClose(end+1) = routesTankScheduling(i).I.DeliveryWindowEnd;
        jobs(j).workingKM(end+1) = DistanceMatrix(jobs(j).addressIndex(end-1),jobs(j).addressIndex(end));
        jobs(j).workingT(end+1) = sm+TimeMatrix(jobs(j).addressIndex(end-1),jobs(j).addressIndex(end));
        jobs(j).tasks(end+1) = "cus";
        jobs(j).sets(end+1) = "I";
    end
    
    %% ORDERS
    if ~isempty(routesTankScheduling(i).U) % If from Ds to U
        for k = 1:size(routesTankScheduling(i).U,1)
            
            if routesTankScheduling(i).directCleaning(k) == 0 % If indirect cleaning
                % Closing previous job at cleaning. Origin can be order or depot
                jobs(j).addressIndex(end+1) = getIndex(routesTankScheduling(i).cleaningAddress(k)); % huidige cleaninglocatie aan de laatste job
                jobs(j).workingT(end+1) = sm+TimeMatrix(jobs(j).addressIndex(end-1),jobs(j).addressIndex(end));
                if strcmp(jobs(j).tasks(end),"dep") || strcmp(jobs(j).tasks(end),"ter")
                    jobs(j).workingT(end) = jobs(j).workingT(end)+sm;
                    jobs(j).windowClose(end) = routesTankScheduling(i).U.PickupWindowEnd(k)-minutes(2); % closing time van cleaning locatie is closing time sup - 2min
                end
                if strcmp(jobs(j).tasks(end),"cus")
                    if k > 1 % At previous customer
                        jobs(j).workingT(end) = jobs(j).workingT(end)+routesTankScheduling(i).U.loadTime(k-1);
                    else % Or at incoming order
                        jobs(j).workingT(end) = jobs(j).workingT(end)+routesTankScheduling(i).I.loadTime;
                    end
                end
                jobs(j).windowOpen(end+1) = jobs(j).windowOpen(end)+minutes(1);
                jobs(j).windowClose(end+1) = routesTankScheduling(i).U.PickupWindowEnd(k)-minutes(2);
                jobs(j).workingKM(end+1) = DistanceMatrix(jobs(j).addressIndex(end-1),jobs(j).addressIndex(end));
                jobs(j).tasks(end+1) = "cl";
                jobs(j).sets(end+1) = "U";
                
                % Open new job from cleaning
                j = j+1;
                jobs(j).addressIndex = jobs(j-1).addressIndex(end);
                jobs(j).windowOpen = jobs(j-1).windowOpen(end)+minutes(1);
                jobs(j).windowClose = routesTankScheduling(i).U.PickupWindowEnd(k)-minutes(1);
                jobs(j).workingKM = 0;
                jobs(j).workingT = 0;
                jobs(j).tasks = "cl";
                jobs(j).sets = "U";
                jobs(j).tankRouteID = i;
            else
                if strcmp(jobs(j).tasks(end),"dep") || strcmp(jobs(j).tasks(end),"ter") % Alleen vorige eindtijd aanpassen als het een depot is
                    jobs(j).windowClose(end) = routesTankScheduling(i).U.PickupWindowEnd(k)-minutes(1); % closing time van depot locatie is closing time sup - 1min
                end
            end
            
            % Continue with job. Origin can be both new job from indirect cleaning, previous customer or depot
            jobs(j).addressIndex(end+1) = getIndex(routesTankScheduling(i).U.FromAddressID(k));
            jobs(j).windowOpen(end+1) = routesTankScheduling(i).U.PickupWindowStart(k);
            jobs(j).windowClose(end+1) = routesTankScheduling(i).U.PickupWindowEnd(k);
            if strcmp(jobs(j).tasks(end),"dep") || strcmp(jobs(j).tasks(end),"cus") || strcmp(jobs(j).tasks(end),"ter") % Time via direct cleaning
                jobs(j).workingT(end+1) = sc+TimeMatrix(jobs(j).addressIndex(end-1),getIndex(routesTankScheduling(i).cleaningAddress(k))) ...
                    +TimeMatrix(getIndex(routesTankScheduling(i).cleaningAddress(k)),jobs(j).addressIndex(end));
                if strcmp(jobs(j).tasks(end),"dep") || strcmp(jobs(j).tasks(end),"ter") % Add previous mounting time
                    jobs(j).workingT(end) = jobs(j).workingT(end)+sm;
                elseif strcmp(jobs(j).tasks(end),"cus") % Or add loading time
                    if k > 1 % At previous customer
                        jobs(j).workingT(end) = jobs(j).workingT(end)+routesTankScheduling(i).U.loadTime(k-1);
                    else % Or at incoming order
                        jobs(j).workingT(end) = jobs(j).workingT(end)+routesTankScheduling(i).I.loadTime;
                    end
                end
            elseif strcmp(jobs(j).tasks(end),"cl")
                jobs(j).workingT(end+1) = sm+TimeMatrix(jobs(j).addressIndex(end-1),jobs(j).addressIndex(end));
            end
            jobs(j).tasks(end+1) = "sup";
            jobs(j).sets(end+1) = "U";
            jobs(j).workingKM(end+1) = DistanceMatrix(jobs(j).addressIndex(end-1),jobs(j).addressIndex(end));
            
            if routesTankScheduling(i).depotUsed(k) == 1 % If via depot
                % End previous job at depot
                jobs(j).addressIndex(end+1) = getIndex(routesTankScheduling(i).depotAddress(k));
                jobs(j).windowOpen(end+1) = routesTankScheduling(i).U.PickupWindowStart(k)+minutes(1);
                jobs(j).windowClose(end+1) = routesTankScheduling(i).U.DeliveryWindowEnd(k)-minutes(2);
                jobs(j).workingT(end+1) = routesTankScheduling(i).U.loadTime(k)+sm+TimeMatrix(jobs(j).addressIndex(end-1),jobs(j).addressIndex(end));
                jobs(j).workingKM(end+1) = DistanceMatrix(jobs(j).addressIndex(end-1),jobs(j).addressIndex(end));
                jobs(j).tasks(end+1) = "dep";
                jobs(j).sets(end+1) = "U";
                
                % Start new job at depot
                j=j+1;
                jobs(j).addressIndex = getIndex(routesTankScheduling(i).depotAddress(k));
                jobs(j).windowOpen = routesTankScheduling(i).U.PickupWindowStart(k)+minutes(2);
                jobs(j).windowClose = routesTankScheduling(i).U.DeliveryWindowEnd(k)-minutes(1);
                jobs(j).workingT = 0;
                jobs(j).workingKM = 0;
                jobs(j).tasks = "dep";
                jobs(j).sets = "U";
                jobs(j).tankRouteID = i;
            end
            
            % Continue with job. Origin is supplier or depot
            jobs(j).addressIndex(end+1) = getIndex(routesTankScheduling(i).U.ToAddressID(k));
            jobs(j).windowOpen(end+1) = routesTankScheduling(i).U.DeliveryWindowStart(k);
            jobs(j).windowClose(end+1) = routesTankScheduling(i).U.DeliveryWindowEnd(k);
            jobs(j).workingT(end+1) = TimeMatrix(jobs(j).addressIndex(end-1),jobs(j).addressIndex(end));
            if strcmp(jobs(j).tasks(end),"dep")
                jobs(j).workingT(end) = jobs(j).workingT(end)+sm;
            end
            if strcmp(jobs(j).tasks(end),"cus")
                jobs(j).workingT(end) = jobs(j).workingT(end)+routesTankScheduling(i).U.loadTime(k);
            end
            jobs(j).workingKM(end+1) = DistanceMatrix(jobs(j).addressIndex(end-1),jobs(j).addressIndex(end));
            jobs(j).tasks(end+1) = "cus";
            jobs(j).sets(end+1) = "U";
        end
    end
    
    %% SINKS
    if ~isempty(routesTankScheduling(i).O)
        % ERROR
        %jobs(j).windowClose(end) = routesTankScheduling(i).O.PickupWindowEnd-minutes(1); % closing time van cleaning locatie is closing time sup - 1min
        if routesTankScheduling(i).directCleaning(end) == 0 % If indirect cleaning
            % Closing previous job at cleaning. Origin can be order or depot
            jobs(j).addressIndex(end+1) = getIndex(routesTankScheduling(i).cleaningAddress(k)); % huidige cleaninglocatie aan de laatste job
            jobs(j).workingT(end+1) = sm+TimeMatrix(jobs(j).addressIndex(end-1),jobs(j).addressIndex(end));
            if strcmp(jobs(j).tasks(end),"dep") || strcmp(jobs(j).tasks(end),"ter")
                jobs(j).workingT(end) = jobs(j).workingT(end)+sm;
                jobs(j).windowClose(end) = routesTankScheduling(i).O.PickupWindowEnd-minutes(2); % closing time van cleaning locatie is closing time sup - 2min
            end
            if strcmp(jobs(j).tasks(end),"cus")
                if size(routesTankScheduling(i).U,1) > 0 % At previous customer (certain if any order present)
                    jobs(j).workingT(end) = jobs(j).workingT(end)+routesTankScheduling(i).U.loadTime(end);
                else % Or at incoming order
                    jobs(j).workingT(end) = jobs(j).workingT(end)+routesTankScheduling(i).I.loadTime;
                end
            end
            jobs(j).windowOpen(end+1) = jobs(j).windowOpen(end)+minutes(1);
            jobs(j).windowClose(end+1) = routesTankScheduling(i).O.PickupWindowEnd-minutes(2);
            jobs(j).workingKM(end+1) = DistanceMatrix(jobs(j).addressIndex(end-1),jobs(j).addressIndex(end));
            jobs(j).tasks(end+1) = "cl";
            jobs(j).sets(end+1) = "O";
            
            % Open new job from cleaning
            j = j+1;
            jobs(j).addressIndex = jobs(j-1).addressIndex(end);
            jobs(j).windowOpen = jobs(j-1).windowOpen(end)+minutes(1);
            jobs(j).windowClose = routesTankScheduling(i).O.PickupWindowEnd-minutes(1);
            jobs(j).workingKM = 0;
            jobs(j).workingT = 0;
            jobs(j).tasks = "cl";
            jobs(j).sets = "O";
            jobs(j).tankRouteID = i;
        else
            if strcmp(jobs(j).tasks(end),"dep") || strcmp(jobs(j).tasks(end),"ter") % Alleen vorige eindtijd aanpassen als het een depot is
                jobs(j).windowClose(end) = routesTankScheduling(i).O.PickupWindowEnd-minutes(1); % closing time van depot locatie is closing time sup - 1min
            end
        end
        
        % Continue with job. Origin can be both new job from indirect cleaning, previous customer or depot
        jobs(j).addressIndex(end+1) = getIndex(routesTankScheduling(i).O.FromAddressID);
        jobs(j).windowOpen(end+1) = routesTankScheduling(i).O.PickupWindowStart;
        jobs(j).windowClose(end+1) = routesTankScheduling(i).O.PickupWindowEnd;
        if strcmp(jobs(j).tasks(end),"dep") || strcmp(jobs(j).tasks(end),"cus") || strcmp(jobs(j).tasks(end),"ter") % Time via direct cleaning
            jobs(j).workingT(end+1) = sc+TimeMatrix(jobs(j).addressIndex(end-1),getIndex(routesTankScheduling(i).cleaningAddress(end))) ...
                +TimeMatrix(getIndex(routesTankScheduling(i).cleaningAddress(end)),jobs(j).addressIndex(end));
            if strcmp(jobs(j).tasks(end),"dep") || strcmp(jobs(j).tasks(end),"ter") % Add previous mounting time
                jobs(j).workingT(end) = jobs(j).workingT(end)+sm;
            elseif strcmp(jobs(j).tasks(end),"cus") % Or add loading time
                if size(routesTankScheduling(i).U,1) > 0 % At previous customer (certain if any order present)
                    jobs(j).workingT(end) = jobs(j).workingT(end)+routesTankScheduling(i).U.loadTime(end);
                else % Or at incoming order
                    jobs(j).workingT(end) = jobs(j).workingT(end)+routesTankScheduling(i).I.loadTime;
                end
            end
        elseif strcmp(jobs(j).tasks(end),"cl")
            jobs(j).workingT(end+1) = sm+TimeMatrix(jobs(j).addressIndex(end-1),jobs(j).addressIndex(end));
        end
        jobs(j).tasks(end+1) = "sup";
        jobs(j).sets(end+1) = "O";
        jobs(j).workingKM(end+1) = DistanceMatrix(jobs(j).addressIndex(end-1),jobs(j).addressIndex(end));
        
        % Continue with job. Origin is supplier
        jobs(j).addressIndex(end+1) = getIndex(routesTankScheduling(i).O.ToAddressID);
        jobs(j).windowOpen(end+1) = routesTankScheduling(i).O.DeliveryWindowStart;
        jobs(j).windowClose(end+1) = routesTankScheduling(i).O.DeliveryWindowEnd;
        jobs(j).workingT(end+1) = routesTankScheduling(i).O.loadTime+TimeMatrix(jobs(j).addressIndex(end-1),jobs(j).addressIndex(end));
        jobs(j).workingKM(end+1) = DistanceMatrix(jobs(j).addressIndex(end-1),jobs(j).addressIndex(end));
        jobs(j).tasks(end+1) = "ter";
        jobs(j).sets(end+1) = "O";
        
    elseif ~isempty(routesTankScheduling(i).Wt)
        jobs(j).addressIndex(end+1) = getIndex(routesTankScheduling(i).Wt.ToAddressID);
        jobs(j).windowOpen(end+1) = jobs(j).windowOpen(end) + minutes(1);
        jobs(j).windowClose(end+1) = routesTankScheduling(i).Wt.DeliveryWindowEnd;
        jobs(j).workingT(end+1) = TimeMatrix(jobs(j).addressIndex(end-1),jobs(j).addressIndex(end));
        if strcmp(jobs(j).tasks(end),"dep") || strcmp(jobs(j).tasks(end),"ter") % Add previous and current mounting time
            jobs(j).workingT(end) = jobs(j).workingT(end)+2*sm;
            jobs(j).windowClose(end-1) = jobs(j).windowClose(end)-minutes(1); % closing time van cleaning locatie is closing time sup - 1min
        elseif strcmp(jobs(j).tasks(end),"cus") % Or add loading time
            if size(routesTankScheduling(i).U,1) > 0 % At previous customer (certain if any order present)
                jobs(j).workingT(end) = jobs(j).workingT(end)+sm+routesTankScheduling(i).U.loadTime(end);
            else % Or at incoming order
                jobs(j).workingT(end) = jobs(j).workingT(end)+sm+routesTankScheduling(i).I.loadTime;
            end
        end
        jobs(j).workingKM(end+1) = DistanceMatrix(jobs(j).addressIndex(end-1),jobs(j).addressIndex(end));
        jobs(j).tasks(end+1) = "ter";
        jobs(j).sets(end+1) = "Wt";
        
    else % Ends at depot sink
        jobs(j).addressIndex(end+1) = getIndex(routesTankScheduling(i).Dt);
        jobs(j).windowOpen(end+1) = jobs(j).windowOpen(end) + minutes(1);
        jobs(j).windowClose(end+1) = jobs(j).windowOpen(end) + years(1); % No closing time
        jobs(j).workingT(end+1) = TimeMatrix(jobs(j).addressIndex(end-1),jobs(j).addressIndex(end));
        if strcmp(jobs(j).tasks(end),"dep") || strcmp(jobs(j).tasks(end),"ter") % Add previous and current mounting time
            jobs(j).workingT(end) = jobs(j).workingT(end)+2*sm;
        elseif strcmp(jobs(j).tasks(end),"cus") % Or add loading time
            if size(routesTankScheduling(i).U,1) > 0 % At previous customer (certain if any order present)
                jobs(j).workingT(end) = jobs(j).workingT(end)+sm+routesTankScheduling(i).U.loadTime(end);
            else % Or at incoming order
                jobs(j).workingT(end) = jobs(j).workingT(end)+sm+routesTankScheduling(i).I.loadTime;
            end
        end
        jobs(j).workingKM(end+1) = DistanceMatrix(jobs(j).addressIndex(end-1),jobs(j).addressIndex(end));
        jobs(j).tasks(end+1) = "dep";
        jobs(j).sets(end+1) = "Dt";
    end
    j = j+1; % Start new job if using new source
end
tempLength = size(jobs,2)-size(Tfull,1);

for i = 1:size(Tfull,1)
    j=tempLength+i;
    jobs(j).addressIndex = getIndex(Tfull.FromAddressID(i));
    jobs(j).windowOpen = Tfull.PickupWindowStart(i);
    jobs(j).windowClose = Tfull.PickupWindowEnd(i);
    jobs(j).workingKM = 0;
    jobs(j).workingT = 0;
    jobs(j).tasks = "ter";
    jobs(j).sets = "T";
    jobs(j).tankRouteID = [];
    
    jobs(j).addressIndex(end+1) = getIndex(Tfull.ToAddressID(i));
    jobs(j).windowOpen(end+1) = Tfull.DeliveryWindowStart(i);
    jobs(j).windowClose(end+1) = Tfull.DeliveryWindowEnd(i);
    jobs(j).workingKM(end+1) = DistanceMatrix(jobs(j).addressIndex(end-1),jobs(j).addressIndex(end));
    jobs(j).workingT(end+1) = TimeMatrix(jobs(j).addressIndex(end-1),jobs(j).addressIndex(end));
    jobs(j).tasks(end+1) = "ter";
    jobs(j).sets(end+1) = "T";
end
