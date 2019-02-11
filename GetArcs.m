function [A] = GetArcs(U,I,O,Ws,Wt,Ds,Dt,t_start,AddressInfo,TimeMatrix)

% Create (feasible) arc matrix
% A: From all s to all t or U, except if time doesn't allow
% A: From All U to all t or U, except if time doesn't allow
% Order: Ds Ws I U O Wt Dt

Ds_l = size(Ds,1); % Short all lengths
Ws_l = size(Ws,1); 
I_l =size(I,1); 
U_l = size(U,1); 
O_l =size(O,1); 
Wt_l = size(Wt,1); 
Dt_l =size(Dt,1);

%% Availability 
Ds_open = Ds.ReleaseTime; % Time of availability D from t_start
Ws_open = minutes(Ws.PickupWindowStart-t_start); % Time of availability Ws from t_start
I_open = minutes(I.DeliveryWindowStart-t_start); % Time of availability I from t_start
U_open = minutes(U.DeliveryWindowStart-t_start); % Time of availability at U cus from t_start

%% Closure of time windows
Wt_close = minutes(Wt.DeliveryWindowEnd-t_start); % Time to complete Wt from t_start
O_close = minutes(O.PickupWindowEnd-t_start); % Time to complete O from t_start
U_close = minutes(U.PickupWindowEnd-t_start); % Time to complete U sup from t_start (perform U)

%% Initial locations (per index, not ID)
Ds_loc= GetIndex(AddressInfo,Ds.HomeAddressID); % Starting location (@ Customer)
Ws_loc=GetIndex(AddressInfo,Ws.FromAddressID); % Starting location (@ Terminal)
I_loc= GetIndex(AddressInfo,I.ToAddressID); % Starting location (@ Customer)
U_cus= GetIndex(AddressInfo,U.ToAddressID); % Starting location (@ Customer)

%% Ending locations (per index, not ID)
Wt_loc= GetIndex(AddressInfo,Wt.ToAddressID); % Ending location (@ Terminal)
O_loc= GetIndex(AddressInfo,O.FromAddressID); % Ending location (@ Supplier)
U_sup= GetIndex(AddressInfo,U.FromAddressID); % Ending location (@ Supplier)

%% Feasible arcs
% From any s to every Dt
S_DT = ones(Ds_l+Ws_l+I_l,Dt_l);

% From any s to Wt if time allows
T = TimeMatrix([Ds_loc; Ws_loc; I_loc],Wt_loc); % Travel times from all S to Wt 
BWT = repmat(Wt_close',Ds_l+Ws_l+I_l,1); % Big Wt: repeat Wt for all rows S
BS = repmat([Ds_open; Ws_open; I_open],1,Wt_l);  % Big S: repeat S for all columns Wt
S_WT = BWT-T > BS; % All instances where S is compatible with Wt

% From any s to O if time allows
T = TimeMatrix([Ds_loc; Ws_loc; I_loc],O_loc); % Travel times from all S to O 
BO = repmat(O_close',Ds_l+Ws_l+I_l,1); % Big Wt: repeat O for all rows S
BS = repmat([Ds_open; Ws_open; I_open],1,O_l);  % Big S: repeat S for all columnds O
S_O = BO-T > BS; % All instances where S is compatible with O

% From any s to U if time allows
T = TimeMatrix([Ds_loc; Ws_loc; I_loc],U_sup); % Travel times from all S to O 
BU_close = repmat(U_close',Ds_l+Ws_l+I_l,1); % Big Wt: repeat O for all rows S
BS = repmat([Ds_open; Ws_open; I_open],1,U_l);  % Big S: repeat S for all columnds O
S_U = BU_close-T > BS; % All instances where S is compatible with O

% From u to u if time allows
T = TimeMatrix(U_cus,U_sup); % Time from Customer to Supplier
BU_close = repmat(U_close',U_l,1); % Big U sup: repeat supplier for all rows of U
BU_open = repmat(U_open,1,U_l); % Big U cus: repeat U cus for all columns of U
U_U = BU_close-T > BU_open; % All instances where U (cus) is compatible with U (sup)

% From u to O if time allows
T = TimeMatrix(U_cus,O_loc); % Time from Customer to Supplier
BO = repmat(O_close',U_l,1); % Big Wt: repeat Wt for all rows S
BU_open = repmat(U_open,1,O_l); % Big U cus: repeat U cus for all columns of U
U_O = BO-T > BU_open; 

% From u to Wt if time allows
T = TimeMatrix(U_cus,Wt_loc); % Time from Customer to Supplier
BWT = repmat(Wt_close',U_l,1); % Big Wt: repeat Wt for all rows S
BU_open = repmat(U_open,1,Wt_l); % Big U cus: repeat U cus for all columns of U
U_WT = BWT-T > BU_open; 

% From u to any Dt
U_DT = ones(U_l,Dt_l);

%% Combine
S_S = zeros(Ds_l+Ws_l+I_l); % Non existing arcs
U_S = zeros(U_l,Ds_l+Ws_l+I_l);
T_SUT = zeros(O_l+Wt_l+Dt_l,Ds_l+Ws_l+I_l+U_l+O_l+Wt_l+Dt_l);

A = [S_S S_U S_O S_WT S_DT; U_S U_U U_O U_WT U_DT;T_SUT];
% Order: Ds Ws I U O Wt Dt

end 