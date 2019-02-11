function [Ds] = SelectResourcesDs(U,O,Wt,Dstart,t_start,CostTravelViaCleaning,...
                        timeViaCleaning,AddressInfo)
%SelectResourcesDs Calculate Ds for U, O and Wt
%   Ask Pieter, genius program needs verbal explanation.
U = sortrows(U,4); %sort by pickupdate
O = sortrows(O,4);
Wt = sortrows(Wt,1);

D_temp = [Dstart(:,1), Dstart(:,2), zeros(size(Dstart,1),1), Dstart(:,3), zeros(size(Dstart,1),2)];
indexlist = [1:1:length(AddressInfo.AddressID)]';
D_temp(:,3) = GetIndex(AddressInfo,D_temp(:,2));
D_temp = sortrows(D_temp,4,'descend');

%% Create Ds for supplier nodes in U
DsU = zeros(length(U.FromAddressID),6);
for i = 1:length(U.FromAddressID)
    GoalIndex = indexlist(AddressInfo.AddressID == U.FromAddressID(i));
    deadLine = minutes(U.PickupWindowEnd(i)-t_start);
    idx = sub2ind(size(timeViaCleaning),D_temp(:,3),GoalIndex*ones(length(D_temp(:,3)),1));
    D_temp(:,5) = timeViaCleaning(idx);
    D_tempOnTimeLogical = D_temp(:,4) + D_temp(:,5) < deadLine;
    D_temp_OnTime = D_temp(D_tempOnTimeLogical,:);    
    idx2 = sub2ind(size(CostTravelViaCleaning), D_temp_OnTime(:,3), GoalIndex*ones(length(D_temp_OnTime(:,3)),1));
    D_temp_OnTime(:,6) = CostTravelViaCleaning(idx2);   
    [~,TempMinId] = min(D_temp_OnTime(:,6));
    DsU(i,:) = D_temp_OnTime(TempMinId,:);
    NewD_tempLogical = D_temp(:,1) ~= DsU(i,1);
    D_temp = D_temp(NewD_tempLogical,:);
end

%% Create Ds for supplier nodes in O
DsO = zeros(length(U.FromAddressID),6);
for i = 1:length(O.FromAddressID)
    GoalIndex = indexlist(AddressInfo.AddressID == O.FromAddressID(i));
    deadLine = minutes(O.PickupWindowEnd(i)-t_start);
    idx = sub2ind(size(timeViaCleaning),D_temp(:,3),GoalIndex*ones(length(D_temp(:,3)),1));
    D_temp(:,5) = timeViaCleaning(idx);
    D_tempOnTimeLogical = D_temp(:,4) + D_temp(:,5) < deadLine;
    D_temp_OnTime = D_temp(D_tempOnTimeLogical,:);    
    idx2 = sub2ind(size(CostTravelViaCleaning), D_temp_OnTime(:,3), GoalIndex*ones(length(D_temp_OnTime(:,3)),1));
    D_temp_OnTime(:,6) = CostTravelViaCleaning(idx2);   
    [~,TempMinId] = min(D_temp_OnTime(:,6));
    DsO(i,:) = D_temp_OnTime(TempMinId,:);
    NewD_tempLogical = D_temp(:,1) ~= DsO(i,1);
    D_temp = D_temp(NewD_tempLogical,:);
end

%% Create Ds for Wt
DsWt = zeros(length(Wt.ToAddressID),6);
for i = 1:length(Wt.ToAddressID)
    GoalIndex = indexlist(AddressInfo.AddressID == Wt.ToAddressID(i));
    deadLine = minutes(Wt.DeliveryWindowEnd(i)-t_start);
    idx = sub2ind(size(timeViaCleaning),D_temp(:,3),GoalIndex*ones(length(D_temp(:,3)),1));
    D_temp(:,5) = timeViaCleaning(idx);
    D_tempOnTimeLogical = D_temp(:,4) + D_temp(:,5) < deadLine;
    D_temp_OnTime = D_temp(D_tempOnTimeLogical,:);    
    idx2 = sub2ind(size(CostTravelViaCleaning), D_temp_OnTime(:,3), GoalIndex*ones(length(D_temp_OnTime(:,3)),1));
    D_temp_OnTime(:,6) = CostTravelViaCleaning(idx2);   
    [~,TempMinId] = min(D_temp_OnTime(:,6));
    DsWt(i,:) = D_temp_OnTime(TempMinId,:);
    NewD_tempLogical = D_temp(:,1) ~= DsWt(i,1);
    D_temp = D_temp(NewD_tempLogical,:);
end

%%
DsTemp = [DsU; DsO; DsWt];
D = table(DsTemp(:,1), DsTemp(:,2), DsTemp(:,4), DsTemp(:,3), DsTemp(:,5), DsTemp(:,6) );
D.Properties.VariableNames = {'TankID','HomeAddressID','ReleaseTime','TankAddressIndex','TravelTime','TravelCost'};
Ds = D(:,1:3);


end

