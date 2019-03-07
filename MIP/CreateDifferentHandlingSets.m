clear all; clc; close all;

load ..//NewData/TankSets
load ..//NewData/LinkingMatrices
load ..//NewData/AddressInfo

%% create all combinations of thresholds
% C_min = 20/60;
% C_km = 0.9320;
% C_charter = 20;
% mountingTime = 36;
% routesTankScheduling  = getRoutesTankScheduling(Ds, Ws, I, U, O, Wt, Dt, value(X));
% 
% COST_TRESHHOLD_DEPOT = [0.5 1 1.2 1.5 2 3 5 10];
% CHARTER_COSTS_HOUR_PARAMETER = [0 0.5 1 3 5 10 20];
% CHARTER_COSTS_HOUR = CHARTER_COSTS_HOUR_PARAMETER*(C_charter/C_min) + 2*mountingTime;
% 
% for i = 1:length(COST_TRESHHOLD_DEPOT)
%     for j = 1:length(CHARTER_COSTS_HOUR)
%         varTreshholdRouteTankScheduling(i,j).routesTankScheduling = getDirectness(routesTankScheduling, AddressInfo, TimeMatrix, DistanceMatrix,COST_TRESHHOLD_DEPOT(i),CHARTER_COSTS_HOUR(j));
%         varTreshholdRouteTankScheduling(i,j).COST_TRESHHOLD_DEPOT = COST_TRESHHOLD_DEPOT(i);
%         varTreshholdRouteTankScheduling(i,j).CHARTER_COSTS_HOUR_PARAMETER = CHARTER_COSTS_HOUR_PARAMETER(j);
%     end
%     i
% end

%% fix one threshhold, vary the other
C_min = 20/60;
C_km = 0.9320;
C_charter = 20;
mountingTime = 36;
routesTankScheduling  = getRoutesTankScheduling(Ds, Ws, I, U, O, Wt, Dt, value(X));

COST_TRESHHOLD_DEPOT = [0.5 1 1.2 1.5 2 3 5 10];
CHARTER_COSTS_HOUR_PARAMETER = [0 0.5 1 2 3 5 10 20];
CHARTER_COSTS_HOUR = CHARTER_COSTS_HOUR_PARAMETER*(C_charter/C_min) + 2*mountingTime;

% vary depot threshold
for i = 1:length(COST_TRESHHOLD_DEPOT)
        varTreshholdRouteTankScheduling(i,1).routesTankScheduling = getDirectness(routesTankScheduling, AddressInfo, TimeMatrix, DistanceMatrix,COST_TRESHHOLD_DEPOT(i),CHARTER_COSTS_HOUR(4));
        varTreshholdRouteTankScheduling(i,1).COST_TRESHHOLD_DEPOT = COST_TRESHHOLD_DEPOT(i);
        varTreshholdRouteTankScheduling(i,1).CHARTER_COSTS_HOUR_PARAMETER = CHARTER_COSTS_HOUR_PARAMETER(4);
end

% vary cleaning threshold threshold
for i = 1:length(CHARTER_COSTS_HOUR)
        varTreshholdRouteTankScheduling(i,2).routesTankScheduling = getDirectness(routesTankScheduling, AddressInfo, TimeMatrix, DistanceMatrix,COST_TRESHHOLD_DEPOT(4),CHARTER_COSTS_HOUR(i));
        varTreshholdRouteTankScheduling(i,2).COST_TRESHHOLD_DEPOT = COST_TRESHHOLD_DEPOT(4);
        varTreshholdRouteTankScheduling(i,2).CHARTER_COSTS_HOUR_PARAMETER = CHARTER_COSTS_HOUR_PARAMETER(i);
end








