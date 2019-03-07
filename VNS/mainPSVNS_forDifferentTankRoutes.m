%% Truck Scheduling MIP
% Group 5 - OR - Erasmus University Rotterdam

%% Initialize
clear all; clc;
clock.totalTime = tic;

load ../NewData/Linkingmatrices
load ../NewData/Truck_Tank_info
load ../DataHS/CostsPerKmPerTrucks
load initial_particles
load ../NewData/DifferentThresholds_RouteTankScheduling

t_0 = datetime(2018,03,0,00,00,00);
alpha = 100; % Tuning parameters for cost function
gamma = 100;
setTrucks = 1; % Allowed tours per truck

% Select trucks, remove table and pre convert tank adresses
trucks = Truck_Tank(Truck_Tank.ResourceType == "Truck",:);
truckHomes = getIndex(trucks.HomeAddressID); clear Truck_Tank trucks

for iRow = 1:8
    for jCol = 1:2
        routesTankScheduling = varTreshholdRouteTankScheduling(iRow, jCol).routesTankScheduling;
    
        % Convert tanktaniner schedules to Job schedule
        %load ../NewData/TruckJobs
        jobs = getJobs(routesTankScheduling); % !! Either use original saved job schedule, or generate new one !!
        
        % Convert job schedule to job matrix
        [jobsW, jobsT, jobsKM] = getJobsMatrix(jobs,t_0);
        jobsW(jobsW(:,1) == 545 | jobsW(:,1) == 549,:) = []; % Remove infeasible repositioning
        jobsT(jobsT(:,1) == 545 | jobsT(:,1) == 549,:) = [];
        jobsKM(jobsKM(:,1) == 545 | jobsKM(:,1) == 549,:) = [];
        
        % Create initial solutions
        particle = createInitialSolutions(jobsW,setTrucks);
        
        % Add costs for charters
        copiedCost = repmat(CostsPerKm',setTrucks,1);
        truckCost = [copiedCost(:); 3*ones(size(jobsW,1),1)];
        
        %% Lower bound given this specific tank handling
        bounds.minTimeWindow = jobsW(sub2ind(size(jobsW),(1:size(jobsW,1))',sum(jobsW > 0,2)-1)) - jobsW(:,6);
        bounds.minServiceTime = sum(jobsT(:,2:end),2);
        bounds.minTimeCost = sum(max(bounds.minTimeWindow,bounds.minServiceTime))*20/60;
        bounds.minDistCostTrucks = sum(sum(jobsKM(:,2:end)))*0.44;
        bounds.lowerBound = bounds.minTimeCost + bounds.minDistCostTrucks;
        
        %% Get initial solutions
        routeIndex = 1:size(particle(1).X,2);
        
        % Calculate all initial fitness
        for i = 1:size(particle,2) % For each particle
            particle(i).routeCost = zeros(1,length(routeIndex));
            particle(i).minutesLate = zeros(1,length(routeIndex));
            
            for j=routeIndex(sum(particle(i).X,1) > 0) % For all routes with at least one job
                
                routes = particle(i).X;
                routeID = j;
                [departureTimes,minutesLate,duration,totalDistance] = getRouteProperties(routes,routeID,jobsW,jobsT,jobsKM,truckHomes,DistanceMatrix,TimeMatrix);
                
                particle(i).routeCost(j) = duration*20/60 + totalDistance*truckCost(j) + alpha*minutesLate + (j>size(routes,2)-size(routes,1))*20; % Ommited gamma costs
                particle(i).minutesLate(j) = minutesLate;
            end
            
            particle(i).totalCost = sum(particle(i).routeCost);
            particle(i).Late = sum(particle(i).minutesLate) > 0.001;
            particle(i).k = 1;
            objectives(i,1) = particle(i).totalCost;
        end
        
        
        %% Run the algorithm
        iterations = 2;
        similarityLevel= zeros(size(particle,2),size(particle,2));
        
        fprintf('Running iteration:  ');
        for i = 1:iterations
            iterationTime = tic;
            
            fprintf(repmat('\b', 1, numel(num2str(i-1)))); fprintf('%d',i);
            
            for j = 1:size(particle,2) % For each particle
                
                % Retrieve neighborhood by similarity matrix
                for l = j+1:size(particle,2)
                    similarityLevel(j,l) = getSimilarity(particle(j).X,particle(l).X);
                end
                similarityLevel(:,j) = similarityLevel(j,:);
                
                % Select k closest neighbours
                [~,neighbourIndex] = sort(similarityLevel(j,:),'descend');
                
                pickedNeighbours = neighbourIndex(1:3*particle(j).k);
                neighbourCosts=[];
                for l = 1:length(pickedNeighbours)
                    neighbourCosts(l) = particle(pickedNeighbours(l)).totalCost;
                end
                
                [~,bestNeighbourIndex] = min(neighbourCosts);
                bestNeighbour = pickedNeighbours(bestNeighbourIndex);
                
                % IF any close neighbour better: DO pathrelinking
                if particle(bestNeighbour).totalCost < particle(j).totalCost
                    numberOfIter = max(5,3*particle(j).k);
                    numberOfBranches = ceil(particle(j).k/2)+2;
                    
                    guide = particle(bestNeighbour).X;
                    c = particle(j).X;
                    cRoutecosts = particle(j).routeCost;
                    cMinutesLate = particle(j).minutesLate;
                    [cFinal, cFinalRouteCosts,cFinalMinutesLate] = relinkPath(guide,c,cRoutecosts,cMinutesLate,numberOfBranches,numberOfIter,jobsW,jobsT,jobsKM,truckHomes,DistanceMatrix,TimeMatrix,truckCost,alpha);
                    
                    particle(j).X = cFinal;
                    particle(j).routeCost = cFinalRouteCosts;
                    particle(j).totalCost = sum(cFinalRouteCosts);
                    particle(j).minutesLate = cFinalMinutesLate;
                    particle(j).Late = sum(particle(j).minutesLate) > 0.001;
                    
                    particle(j).k = 1; %max(1,k-1);
                    
                else % ELSE IF local best: DO crossexchange
                    minOwnFleet = 0.3;
                    particle(j).k = min(11, particle(j).k +1);
                    crossWeight = particle(j).k;
                    [Xnew,selectedTrucksID] = CROSS_Exchange(particle(j).X,crossWeight,minOwnFleet);
                    
                    % Update cost
                    newRouteCost = particle(j).routeCost; % Initialize with old
                    newMinutesLate = particle(j).minutesLate;
                    for l = 1:length(selectedTrucksID) % Get cost of affected routes
                        routes = Xnew;
                        routeID = selectedTrucksID(l);
                        
                        if sum(routes(:,routeID)) ~= 0 % If route contains no jobs anymore, set costs to zero
                            [departureTimes,minutesLate,duration,totalDistance] = getRouteProperties(routes,routeID,jobsW,jobsT,jobsKM,truckHomes,DistanceMatrix,TimeMatrix);
                            newRouteCost(routeID) = duration*20/60 + totalDistance*truckCost(routeID) + alpha*minutesLate + (routeID>size(routes,2)-size(routes,1))*20; % Ommited gamma costs
                            newMinutesLate(routeID) = minutesLate;
                        else
                            newRouteCost(routeID) = 0;
                            newMinutesLate(routeID) = 0;
                        end
                    end
                    
                    if sum(newRouteCost) < particle(j).totalCost*0.999 % If costs smaller then numeric error set new objective
                        particle(j).routeCost = newRouteCost;
                        particle(j).totalCost = sum(newRouteCost);
                        particle(j).minutesLate = newMinutesLate;
                        particle(j).Late = sum(newMinutesLate) > 0.001;
                        particle(j).X = Xnew;
                    end
                    
                end
                objectives(j,i+1) = particle(j).totalCost;
            end
            
            clock.iterationTime(i) = toc(iterationTime);
        end
        fprintf('\n \n')
        
        fprintf('Mean iteration time: %.4f seconds \n',mean(clock.iterationTime));
        improvement = 100*(objectives(:,end)-objectives(:,1))./objectives(:,1);
        fprintf('Mean improvement over all particles: %.2f%% \n',mean(improvement));
        fprintf('Best initial particle cost: %.0f \n',min(objectives(:,1)));
        fprintf('Best optimized particle cost: %.0f \n',min(objectives(:,end)));
        fprintf('Improvement optimal solution: %.2f%% \n',100*(min(objectives(:,end))-min(objectives(:,1)))/min(objectives(:,1)));
        fprintf('Lower bound for this tank handling: %.0f \n',bounds.lowerBound);
        fprintf('Optimality gap optimal solution: %.2f%% \n',100*(min(objectives(:,end))-bounds.lowerBound)/bounds.lowerBound);
        fprintf('\n')
        
        results_different_threshholds(iRow, jCol).particle = particle;
        results_different_threshholds(iRow, jCol).objectives = objectives;
        results_different_threshholds(iRow, jCol).COST_TRESHHOLD_DEPOT = varTreshholdRouteTankScheduling(iRow, jCol).COST_TRESHHOLD_DEPOT;
        results_different_threshholds(iRow, jCol).CHARTER_COSTS_HOUR_PARAMETER = varTreshholdRouteTankScheduling(iRow, jCol).CHARTER_COSTS_HOUR_PARAMETER;
    end
end
clock.totalTime = toc(clock.totalTime);
fprintf('Total clock time: %.4f seconds \n',clock.totalTime);

