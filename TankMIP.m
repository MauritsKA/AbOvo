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

Tanks = Truck_Tank(Truck_Tank.ResourceType == 'Tank',1:end);

% Select Region
ID = 24;
Region = string(Countries(ID));

t_start = datetime(2018,03,20,00,00,00); % Set appropriate time window
t_end = t_start + day(1);

[U,I,O,Ws,Wt] = SelectOrders(OrderLists,ID,t_start,t_end);

Ds = [table2array(Tanks(:,1)) zeros(size(Tanks,1),1)]; % Tanktainer Sources & times STILL MATRIC - NOT TABLE

% Sources: Ds, Ws, I
% Sinks: O, Wt, Dt(?)
% Set Dt to all terminals (433) * all tanktainers (1001) = 433433

% A: From all S to all T or U, except if time doesn't allow
% A: From All U to all T or U, except if time doesn't allow
A = ones(5,5); % Compatible arcs

s_cl = 120; % Cleaning [Minutes] - NEEDS VERIFICATION
s_m = 36; % (Dis)mounting [Minutes]
s_l_fix = 18; % Fixed (un)loading [Minutes]
s_l_var = 1; % (Un)loading per gravity unit [Minutes]

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
