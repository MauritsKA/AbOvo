function [C,T] = GetCosts(CostMatrix,CostTravelViaCleaning,Ds,Ws,I,U,O,Wt,Dt,AddressInfo,timeViaCleaning,TimeMatrix)

toSupplierIndex = sum(CostTravelViaCleaning,1) > 0;
toSupplierLog = repmat(toSupplierIndex,size(CostTravelViaCleaning,1),1);

tempCosts = CostMatrix;
tempCosts(toSupplierLog) = 0;

C_complete = tempCosts+CostTravelViaCleaning;

FromAddressesID = [Ds.HomeAddressID; Ws.FromAddressID; I.ToAddressID];
FromAddressesID_U = U.ToAddressID;
ToAddressesID = [O.FromAddressID; Wt.ToAddressID; Dt];
ToAddressesID_U = U.FromAddressID;

FromAddressesIndex = GetIndex(AddressInfo, FromAddressesID);
FromAddressesIndex_U = GetIndex(AddressInfo, FromAddressesID_U);
ToAddressesIndex = GetIndex(AddressInfo, ToAddressesID);
ToAddressesIndex_U = GetIndex(AddressInfo, ToAddressesID_U);

C_SUT = C_complete(FromAddressesIndex,[ToAddressesIndex_U;ToAddressesIndex]);
C_UUT = C_complete(FromAddressesIndex_U,[ToAddressesIndex_U;ToAddressesIndex]);

C = [zeros(length(FromAddressesIndex)), C_SUT;...
     zeros(length(FromAddressesIndex_U),length(FromAddressesIndex)), C_UUT;...
     zeros(length(ToAddressesIndex),length([FromAddressesIndex;FromAddressesIndex_U;ToAddressesIndex]))];
 
%% Same for Time
tempTime = TimeMatrix;
tempTime(toSupplierLog) = 0;
T_complete = tempTime + timeViaCleaning;

T_SUT = T_complete(FromAddressesIndex,[ToAddressesIndex_U;ToAddressesIndex]);
T_UUT = T_complete(FromAddressesIndex_U,[ToAddressesIndex_U;ToAddressesIndex]);

T = [zeros(length(FromAddressesIndex)), T_SUT;...
     zeros(length(FromAddressesIndex_U),length(FromAddressesIndex)), T_UUT;...
     zeros(length(ToAddressesIndex),length([FromAddressesIndex;FromAddressesIndex_U;ToAddressesIndex]))];

end

