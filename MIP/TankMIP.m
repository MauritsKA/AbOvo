%% Tanktainer Scheduling MIP
% Group 5 - OR - Erasmus University Rotterdam

% Initialization
clear vars; clc; close all; yalmip('clear');
TotalTime = tic;
load ../NewData/AddressInfo
load ../NewData/LinkingMatrices
load ../NewData/Truck_Tank_Info
load ../NewData/Orders
load ../NewData/InterModals
load ../NewData/Orderlists
load ../NewData/CostMatrix
load ../NewData/CheapestCleaning

Tanks = Truck_Tank(Truck_Tank.ResourceType == 'Tank',1:end);
Terminals = AddressInfo(AddressInfo.IsTerminal == 1,:);

% Select Region & Time
IDS = [2 7 24]; % BE DEU NL
Region = string(Countries(IDS));

t_start = datetime(2018,03,01,00,00,00); % Set appropriate time window
t_end = datetime(2018,04,01,00,00,00);

% Generate applicable jobs & orders
[U,I,O,Ws,Wt] = SelectOrders(OrderLists,IDS,t_start,t_end);

% Total tanktainer availability 
Dstart = [Tanks.ID Tanks.HomeAddressID zeros(size(Tanks.ID,1),1)]; %Release times in 3 column

% Select maximum applicable tanktainers and maximum amount of depot sinks
Ds = SelectResourcesDs(U,O,Wt,Dstart,t_start,CostTravelViaCleaning,timeViaCleaning,AddressInfo);
Dt = SelectResourcesDt(U,I,Ws,AddressInfo,Ds,CostMatrix);                    

% Get Arc & Cost matrix in order of: Ds Ws I U O Wt Dt
A = GetArcs(U,I,O,Ws,Wt,Ds,Dt,t_start,AddressInfo,TimeMatrix); % Compatible arcs
[C,T] = GetCosts(CostMatrix,CostTravelViaCleaning,Ds,Ws,I,U,O,Wt,Dt,AddressInfo,timeViaCleaning,TimeMatrix); %Replace costs to supplier with costs via a cleaning to supplier
% A = [zeros(size(Ds,1)+size(Ws,1)+size(I,1)) ones(size(Ds,1)+size(Ws,1)+size(I,1),size(U,1)+size(O,1)+size(Wt,1)+size(Dt,1));
%      zeros(size(U,1),size(Ds,1)+size(Ws,1)+size(I,1)) ones(size(U,1),size(U,1)+size(O,1)+size(Wt,1)+size(Dt,1))
%      zeros(size(O,1)+size(Wt,1)+size(Dt,1),size(A,1))];

% Get internal travel & service times
t_U = diag(TimeMatrix(GetIndex(AddressInfo,U.FromAddressID),GetIndex(AddressInfo,U.ToAddressID))); % sup - cus in U
t_I = diag(TimeMatrix(GetIndex(AddressInfo,I.FromAddressID),GetIndex(AddressInfo,I.ToAddressID))); % ter - cus in I
t_O = diag(TimeMatrix(GetIndex(AddressInfo,O.FromAddressID),GetIndex(AddressInfo,O.ToAddressID))); % sup - ter in O

scl = 120; % Cleaning [Minutes] 
sm = 36; % (Dis)mounting [Minutes]
sl_fix = 18; % Fixed (un)loading [Minutes]
sl_var = 1; % (Un)loading per gravity unit [Minutes]
[sl_I,sl_U,sl_O] = GetLoadingTimes(I,U,O,sl_fix,sl_var); % Cleaning times per order

% Time windows & availability 
at_I = minutes(I.PickupWindowStart-t_start); % Tanktainer availability at terminals of Incoming arcs
at_Ds = Ds.ReleaseTime; % Tanktainer availability at source depots
at_Ws = minutes(Ws.PickupWindowStart-t_start); % Tanktainer availability at terminals of Incoming empty arcs
es = minutes([U.PickupWindowStart; O.PickupWindowStart]-t_start); % Opening supplier at set U and O 
ls = minutes([U.PickupWindowEnd; O.PickupWindowEnd]-t_start); % Closing supplier at set U and O 
ec = minutes([I.DeliveryWindowStart; U.DeliveryWindowStart]-t_start); % Opening supplier at set I and U 
lc = minutes([I.DeliveryWindowEnd; U.DeliveryWindowEnd]-t_start); % Closing supplier at set I and U 
lt = minutes(Wt.DeliveryWindowEnd-t_start); % Closing terminal at set Wt

M = 2*max([ls;lc;lt]);
%% Optimization - Solving with Gurobi, implemented with Yalmip

% Selection Logicals - Order: Ds Ws I U O Wt Dt
Ds_b = ones(size(Ds,1),1);
Ws_b = ones(size(Ws,1),1);
I_b = ones(size(I,1),1);
U_b = ones(size(U,1),1);
O_b = ones(size(O,1),1);
Wt_b = ones(size(Wt,1),1);
Dt_b = ones(size(Dt,1),1);
B = logical(blkdiag(Ds_b, Ws_b, I_b, U_b, O_b, Wt_b, Dt_b));

% Declaration of variables
X = intvar(size(A,1),size(A,2),'full'); % Decision variable for coupling job i with j
as_U = sdpvar(size(U,1),1,'full'); % Arrival at regular supplier
as_O = sdpvar(size(O,1),1,'full'); % Arrival at outgoing supplier
ac_I = sdpvar(size(I,1),1,'full'); % Arrival at incoming customer
ac_U = sdpvar(size(U,1),1,'full'); % Arrival at regular customer
at_Wt = sdpvar(size(Wt,1),1,'full'); % Arrival at scheduled terminal
at_Dt = sdpvar(size(Dt,1),1,'full'); % Arrival at depot sink
w_U = sdpvar(size(U,1),1,'full'); % Waiting within regular order
w_I = sdpvar(size(I,1),1,'full'); % Waiting within incoming order
wb_UO = sdpvar(size(U,1)+size(O,1),1,'full'); % Waiting within regular order
wb_WD = sdpvar(size(Wt,1)+size(Dt,1),1,'full'); % Waiting within regular order

acs = sdpvar(size(I,1)+size(U,1),size(U,1)+size(O,1),'full'); % Arrival from any customer in I,U to any supplier in U,O
ads = sdpvar(size(Ds,1)+size(Ws,1),size(U,1)+size(O,1),'full'); % Arrival from any depot in Ds,Ws to any supplier in U,O
act = sdpvar(size(I,1)+size(U,1),size(Wt,1)+size(Dt,1),'full'); % Arrival from any customer in I,U to any depot in Wt,Dt
adt = sdpvar(size(Ds,1)+size(Ws,1),size(Wt,1)+size(Dt,1),'full'); % Arrival from any depot in Ds,Ws to any depot in Wt,Dt

% Building the model
cons = [];
cons = [cons, X <= A]; % Limit X on feasible arcs
cons = [cons, sum(X(:,B(:,4)|B(:,5)|B(:,6)),1) == 1]; % Sum over all i for set U,O,Wt (indegree)
cons = [cons, sum(X(:,B(:,7)),1) <= 1]; % Sum over all i for set Dt (indegree)
cons = [cons, sum(X(B(:,1)|B(:,2)|B(:,3)|B(:,4),:),2) == 1];  % Sum over all j for set Ds,Ws,I,U (outdegree)
cons = [cons, sum(sum(X(B(:,1)|B(:,2)|B(:,3),:),1)) == sum(sum(X(:,B(:,5)|B(:,6)|B(:,7)),2))]; % Sum of outdegree S is equal to sum of indegree T (sink/source balance)

cons = [cons, at_I + sl_I + t_I + w_I == ac_I]; % Arrival time at customer from terminal in I
cons = [cons, as_U + sl_U + t_U + w_U == ac_U]; % Arrival time at customer from supplier in U
cons = [cons, es <= [as_U;as_O] <= ls]; % Applying customer time window for set U,O
cons = [cons, ec <= [ac_I;ac_U] <= lc]; % Applying customer time window for set I,U
cons = [cons, at_Wt <= lt]; % Applying terminal time window for set Wt

cons = [cons, acs <= repmat([ac_I;ac_U] + [sl_I;sl_U],1,size(acs,2)) + T(B(:,3)|B(:,4),B(:,4)|B(:,5))]; % From any customer in I,U to any supplier in U,O
cons = [cons, act <= repmat([ac_I;ac_U] + [sl_I;sl_U],1,size(act,2)) + T(B(:,3)|B(:,4),B(:,6)|B(:,7))]; % From any customer in I,U to any depot in Wt,Dt
cons = [cons, ads <= repmat([at_Ds;at_Ws] + sm ,1,size(ads,2)) + T(B(:,1)|B(:,2),B(:,4)|B(:,5))]; % From any depot in Ds,Ws to any supplier in U,O
cons = [cons, adt <= repmat([at_Ds;at_Ws] + 2*sm ,1,size(adt,2)) + T(B(:,1)|B(:,2),B(:,6)|B(:,7))]; % From any depot in Ds,Ws to any depot in Wt,Dt

cons = [cons, acs >= repmat([ac_I;ac_U] + [sl_I;sl_U],1,size(acs,2)) + T(B(:,3)|B(:,4),B(:,4)|B(:,5)) - M*(1-X(B(:,3)|B(:,4),B(:,4)|B(:,5)))]; % From any customer in I,U to any supplier in U,O
cons = [cons, act >= repmat([ac_I;ac_U] + [sl_I;sl_U],1,size(act,2)) + T(B(:,3)|B(:,4),B(:,6)|B(:,7)) - M*(1-X(B(:,3)|B(:,4),B(:,6)|B(:,7)))]; % From any customer in I,U to any depot in Wt,Dt
cons = [cons, ads >= repmat([at_Ds;at_Ws] + sm ,1,size(ads,2)) + T(B(:,1)|B(:,2),B(:,4)|B(:,5)) - M*(1-X(B(:,1)|B(:,2),B(:,4)|B(:,5)))]; % From any depot in Ds,Ws to any supplier in U,O
cons = [cons, adt >= repmat([at_Ds;at_Ws] + 2*sm ,1,size(adt,2)) + T(B(:,1)|B(:,2),B(:,6)|B(:,7)) - M*(1-X(B(:,1)|B(:,2),B(:,6)|B(:,7)))]; % From any depot in Ds,Ws to any depot in Wt,Dt
 
cons = [cons, [as_U;as_O] == wb_UO + sum(acs,1)' + sum(ads,1)'];
cons = [cons, [at_Wt;at_Dt] == wb_WD + sum(act,1)' + sum(adt,1)'];

% In order: Ds Ws I U O Wt Dt
cons = [cons, acs <= M*X(B(:,3)|B(:,4),B(:,4)|B(:,5))]; % From any customer in I,U to any supplier in U,O
cons = [cons, act <= M*X(B(:,3)|B(:,4),B(:,6)|B(:,7))]; % From any customer in I,U to any depot in Wt,Dt
cons = [cons, ads <= M*X(B(:,1)|B(:,2),B(:,4)|B(:,5))]; % From any depot in Ds,Ws to any supplier in U,O
cons = [cons, adt <= M*X(B(:,1)|B(:,2),B(:,6)|B(:,7))]; % From any depot in Ds,Ws to any depot in Wt,Dt

cons = [cons, 0 <= X <= 1]; % Limit X on domain
cons = [cons, w_U >= 0]; % Positive waiting times
cons = [cons, w_I >= 0]; 
cons = [cons, wb_UO >= 0]; 
cons = [cons, wb_WD >= 0]; 
cons = [cons, acs >= 0]; % Positive arrival times
cons = [cons, act >= 0]; 
cons = [cons, adt >= 0]; 
cons = [cons, ads >= 0]; 

obj = sum(sum(C.*X));

ops = sdpsettings('solver','gurobi','verbose',1);
res = optimize(cons, obj, ops);

if res.problem == 0
    disp('Solution found!');
    obj = value(obj)
else
    disp('Something went wrong!');
    res.info
    yalmiperror(res.problem)
end

TotalTime = toc(TotalTime)

routesTankScheduling  = getRoutesTankScheduling(Ds, Ws, I, U, O, Wt, Dt, value(X));
