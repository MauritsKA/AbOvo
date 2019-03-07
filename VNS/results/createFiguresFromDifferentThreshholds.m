clear all;
clc;
close all;

load differentThreshHoldsExample

lowestCostsAndFeasible = zeros(size(results_different_threshholds));
bestParticle = zeros(size(results_different_threshholds));
%% add dummy 0 to late, delete for real results

for i = 1:size(results_different_threshholds,1)
    for j = 1:size(results_different_threshholds,2)
        results_different_threshholds(i,j).particle(i+j).Late = 0;
    end
end

%% Retrieve best (feasible) costs 
for i = 1:size(results_different_threshholds,1)
    for j = 1:size(results_different_threshholds,2)
        
        tempCost = zeros(size(results_different_threshholds(i,j).particle,2),1);
        tempLate = zeros(size(results_different_threshholds(i,j).particle,2),1);
        
        for k = 1:size(results_different_threshholds(i,j).particle,2)
            tempCost(k,1) = results_different_threshholds(i,j).particle(k).totalCost;
            tempLate(k,1) = results_different_threshholds(i,j).particle(k).Late;
        end
        
        if sum(tempLate) ~= size(results_different_threshholds(i,j).particle,2)
            Index = (1:1:size(results_different_threshholds(i,j).particle,2))';
            tempIndex = Index(tempLate == 0);
            tempCost = tempCost(tempLate == 0);
            [lowestCostsAndFeasible(i,j),tempIndexBestParticle] = min(tempCost);
            bestParticle(i,j) = tempIndex(tempIndexBestParticle);
        else
            row = i
            col = j
            'No feasible route exists!'
            lowestCostsAndFeasible(i,j) = inf;
        end
        
    end
end

%% Retrieve threshold settings
for i = 1:size(results_different_threshholds,1)
        DepotThreshold(i,1) = results_different_threshholds(i,1).COST_TRESHHOLD_DEPOT;
        CleaningThreshold(i,1) = results_different_threshholds(i,2).CHARTER_COSTS_HOUR_PARAMETER;
end

%% Create costs plots for best particle
figure(1)
subplot(1,2,1)
plot(DepotThreshold,lowestCostsAndFeasible(:,1),'-*','LineWidth',2)
ylabel('Costs [euros]','fontsize',20,'interpreter','latex')
xlabel('Depot threshhold parameter','fontsize',20,'interpreter','latex')
axis([0 max(DepotThreshold) min(min(lowestCostsAndFeasible))-10^5 max(max(lowestCostsAndFeasible))+10^5])
title('Cleaning threshhold parameter = 2','fontsize',20,'interpreter','latex')

subplot(1,2,2)
plot(CleaningThreshold,lowestCostsAndFeasible(:,2),'-*','LineWidth',2)
xlabel('Cleaning threshhold parameter','fontsize',20,'interpreter','latex')
axis([0 max(CleaningThreshold) min(min(lowestCostsAndFeasible))-10^5 max(max(lowestCostsAndFeasible))+10^5])
title('Depot threshhold parameter = 1.5','fontsize',20,'interpreter','latex')

%% Create objectives plot of best particles
objectivesVariableDepot = zeros(size(results_different_threshholds,1), size(results_different_threshholds(1, 1).objectives,2));
objectivesVariableClean = zeros(size(results_different_threshholds,1), size(results_different_threshholds(1, 1).objectives,2));

for i = 1:size(results_different_threshholds,1)
    objectivesVariableDepot(i,:) = results_different_threshholds(i,1).objectives(bestParticle(i,1),:); 
    objectivesVariableClean(i,:) = results_different_threshholds(i,2).objectives(bestParticle(i,2),:); 
end

itterations = 1:size(objectivesVariableClean,2);

figure(2)
subplot(1,2,1)
plot(itterations,objectivesVariableDepot)
xlabel('Iterations','fontsize',20,'interpreter','latex')
ylabel('Costs [euros]','fontsize',20,'interpreter','latex')
title('Cleaning threshhold parameter = 2','fontsize',20,'interpreter','latex')
axis([1 max(itterations) 2e5 max(max([objectivesVariableDepot;objectivesVariableClean]))])

subplot(1,2,2)
plot(itterations,objectivesVariableClean)
xlabel('Iterations','fontsize',20,'interpreter','latex')
title('Depot threshhold parameter = 1.5','fontsize',20,'interpreter','latex')
axis([1 max(itterations) 2e5 max(max([objectivesVariableDepot;objectivesVariableClean]))])
