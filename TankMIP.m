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

% Selecting appropriate data
Tanks = Truck_Tank(Truck_Tank.ResourceType == 'Tank',1:end);
Region = Countries(24); 
RegionOrders = Orders(Orders.FromCountry==Region | Orders.ToCountry ==Region,:);

INT = RegionOrders(RegionOrders.DirectShipment == 0,:);
count=0;
for i = 1:length(INT.OrderID)
    B= Intermodals(Intermodals.OrderID == INT.OrderID(i),:);
    if size(B,1) > 1
          count = i;
    end 
      
end 

% Parameters
U = RegionOrders(RegionOrders.DirectShipment == 1,:).OrderID; % Orders
O = ones(5,1); % Outgoing Orders
I = ones(5,1); % Incoming Orders
Ws = ones(5,1); % Incoming empty tanks - part of Source
Wt = ones(5,1); % Outgoing empty tanks - part of Sink
Ds = [table2array(Tanks(:,1)) zeros(size(Tanks,1),1)]; % Tanktainer Sources
A = ones(5,5); % Compatible arcs

s_cl = 120; % Cleaning [Minutes] - NEEDS VERIFICATION
s_m = 36; % (Dis)mounting [Minutes]
s_l_fix = 18; % Fixed (un)loading [Minutes]
s_l_var = 1; % (Un)loading per gravity unit [Minutes]

TankAddresses = unique(Tanks.HomeAddressID);
for i = 1:length(TankAddresses)
    Counts(i,1) = sum(Tanks.HomeAddressID == TankAddresses(i));
end 
%% Optimization
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
