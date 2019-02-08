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

% Initialize
A = zeros(Ds_l+Ws_l+I_l+U_l+O_l+Wt_l+Dt_l);

%% Availability 
Ds_open = Ds(:,3); % Time of availability D from t_start
Ws_open = minutes(Ws.PickupWindowStart-t_start); % Time of availability Ws from t_start
I_open = minutes(I.DeliveryWindowStart-t_start); % Time of availability I from t_start

%% Initial locations (per index, not ID)
Ds_loc= GetIndex(AddressInfo,Ds(:,2)); % Starting location (@ Customer)
Ws_loc=GetIndex(AddressInfo,Ws.FromAddressID); % Starting location (@ Terminal)
I_loc= GetIndex(AddressInfo,I.ToAddressID); % Starting location (@ Customer)

%% Feasible arcs
% From any s to every Dt
SDT = ones(Ds_l+Ws_l+I_l,Dt_l);

% From any s to Wt if time allows
Wt_close = minutes(Wt.DeliveryWindowEnd-t_start); % Time to complete Wt from t_start
Wt_loc= GetIndex(AddressInfo,Wt.ToAddressID); % Ending location (@ Terminal)
T = TimeMatrix([Ds_loc; Ws_loc; I_loc],Wt_loc); % Travel times from all S to Wt 
BWt = repmat(Wt_close',Ds_l+Ws_l+I_l,1); % Big Wt: repeat Wt for all rows S
BS = repmat([Ds_open; Ws_open; I_open],1,Wt_l);  % Big S: repeat S for all columnds Wt
S_WT = BWt-T > BS; % All instances where S is compatible with Wt

% Order: Ds Ws I U O Wt Dt
% From any s to O if time allows
O_close = minutes(O.PickupWindowEnd-t_start); % Time to complete O from t_start
O_loc= GetIndex(AddressInfo,O.FromAddressID); % Ending location (@ Supplier)
T = TimeMatrix([Ds_loc; Ws_loc; I_loc],O_loc); % Travel times from all S to Wt 
BO = repmat(O_close',Ds_l+Ws_l+I_l,1); % Big Wt: repeat Wt for all rows S
BS = repmat([Ds_open; Ws_open; I_open],1,O_l);  % Big S: repeat S for all columnds Wt
S_O = BO-T > BS; % All instances where S is compatible with Wt

% From u to u if time allows
U_open = minutes(U.DeliveryWindowStart-t_start); % Time of availability at U cus from t_start
U_close = minutes(U.PickupWindowEnd-t_start); % Time to complete U sup from t_start (perform U)
U_cus= GetIndex(AddressInfo,U.ToAddressID); % Ending location (@ Customer)
U_sup= GetIndex(AddressInfo,U.FromAddressID); % Starting location (@ Supplier)
T = TimeMatrix(U_cus,U_sup); % Time from Customer to Supplier
BU_close = repmat(U_close',U_l,1); % Big U sup: repeat supplier for all rows of U
BU_open = repmat(U_open,1,U_l); % Big U cus: repeat U cus for all columns of U
U_U = BU_close-T > BU_open;

% From u to any Dt

% From u to O or Wt if time allows
end 