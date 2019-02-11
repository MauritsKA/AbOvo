%% Tanktainer Scheduling MIP
% Group 5 - OR - Erasmus University Rotterdam

% Initialization
clear; clc; close all; yalmip('clear');
TotalTime = tic;
load NewData/AddressInfo
load NewData/LinkingMatrices
load NewData/Truck_Tank_Info
load NewData/Orders
load NewData/InterModals
load NewData/Orderlists
load NewData/CostMatrix
load NewData/CheapestCleaning

Tanks = Truck_Tank(Truck_Tank.ResourceType == 'Tank',1:end);
Terminals = AddressInfo(AddressInfo.IsTerminal == 1,:);

% Select Region
ID = 24;
Region = string(Countries(ID));

t_start = datetime(2018,03,20,00,00,00); % Set appropriate time window
t_end = datetime(2018,03,21,00,00,00);

[U,I,O,Ws,Wt] = SelectOrders(OrderLists,ID,t_start,t_end);
tic
Dstart = [Tanks.ID Tanks.HomeAddressID zeros(size(Tanks,1),1)];
Dstart(:,3) = [1:1:size(Dstart,1)]'-ones(size(Dstart,1),1)*7400; %Release times go in 3 column, now random times generated
[Ds] = SelectResourcesDs(U,O,Wt,Dstart,t_start,CostTravelViaCleaning,...
                        timeViaCleaning,AddressInfo);
[Dt] = SelectResourcesDt(U,I,Ws,AddressInfo,Ds,CostMatrix);                    
toc
% Order: Ds Ws I U O Wt Dt

A = GetArcs(U,I,O,Ws,Wt,Ds,Dt,t_start,AddressInfo,TimeMatrix); % Compatible arcs

s_cl = 120; % Cleaning [Minutes] - NEEDS VERIFICATION
s_m = 36; % (Dis)mounting [Minutes]
s_l_fix = 18; % Fixed (un)loading [Minutes]
s_l_var = 1; % (Un)loading per gravity unit [Minutes]

%% Optimization - NOW USING YALMIP, CAN BE DIRECTLY IMPLEMENTED IN GUROBI /CPLEX
% STILL MISSING TIME CONSTRAINTS 

% DUMMY PROBLEM:
% Declaration of variables
X = sdpvar(size(AddressInfo,1),size(AddressInfo,1),'full');

% Building the model
cons = [];
cons = [cons, X >= 0];
cons = [cons, X <= 1];

obj = -sum(X(1,:));

ops = sdpsettings('solver','gurobi','verbose',1);
res = optimize(cons, obj, ops);

if res.problem == 0
    disp('Solution found!');
    obj = -value(obj)
else
    disp('Something went wrong!');
    res.info
    yalmiperror(res.problem)
end

TotalTime = toc(TotalTime);
