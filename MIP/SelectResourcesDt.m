function [Dt] = SelectResourcesDt(U,I,Ws,AddressInfo,Ds,CostMatrix)
% SelectResourcesDt All addresses from which a tank can go to a depot:
% U.Cus, I.Cus, Ws and Ds. All depots: IsTerminal. Find pairs with lowest
% costs between them. Program goes from AddressID - AddressIndex -
% DepotIndex - DepotID. Finally all Ds Addresses are added.

FromAddressessID = [U.ToAddressID; I.ToAddressID; Ws.FromAddressID];
IndexList = [1:1:length(AddressInfo.AddressID)]';
IndexMatrix = repmat(IndexList,1,length(FromAddressessID));
temp = logical(AddressInfo.AddressID == FromAddressessID');
FromAddressessIndex = IndexMatrix(temp);

CostMatrix(AddressInfo.IsTerminal == 0,:) = inf;
[~,minIndex] = min(CostMatrix);

DepotIndex = minIndex([FromAddressessIndex])';
DepotID = AddressInfo.AddressID(DepotIndex);

Dt = [DepotID; Ds.HomeAddressID];
end

