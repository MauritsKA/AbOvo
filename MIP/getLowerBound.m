function [LB] = getLowerBound(U,I,O,T, AddressInfo, CheapestClean, CostMatrix, DistanceMatrix, TimeMatrix)

C_km = 0.9320;
C_min = 20/60;
cleaningTime = 120;
mountingTime = 36;
%% Retrieve U, O, I, T from orderlists
% for i = 1:size(OrderLists,2)
%     if size(OrderLists(i).U,1) > 0
%         for j = 1:size(OrderLists(i).U.FromCountry,1)
%             if OrderLists(i).U.FromCountry(j) == categorical(OrderLists(i).Name)
%                 Utemp = OrderLists(i).U(j,:);
%                 U = [U; Utemp];
%             end
%         end
%     end
%     
%      if size(OrderLists(i).O,1) > 0
%         for j = 1:size(OrderLists(i).O.FromCountry,1)
%             if OrderLists(i).O.FromCountry(j) == categorical(OrderLists(i).Name)
%                 Otemp = OrderLists(i).O(j,:);
%                 O = [O; Otemp];
%             end
%         end
%      end
%     
%       if size(OrderLists(i).I,1) > 0
%         for j = 1:size(OrderLists(i).I.FromCountry,1)
%             if OrderLists(i).I.FromCountry(j) == categorical(OrderLists(i).Name)
%                 Itemp = OrderLists(i).I(j,:);
%                 I = [I; Itemp];
%             end
%         end
%       end
%     
%     if size(OrderLists(i).T,1) > 0
%         for j = 1:size(OrderLists(i).T.FromCountry,1)
%             if OrderLists(i).T.FromCountry(j) == categorical(OrderLists(i).Name)
%                 Ttemp = OrderLists(i).T(j,:);
%                 T = [T; Ttemp];
%             end
%         end
%     end
% end

%% Terminal to terminal
% Distance/time costs between terminals
% 2x dismounting costs (unless terminal 1 = terminal 2)

T.FromAddressIndex = GetIndex(AddressInfo,T.FromAddressID);
T.ToAddressIndex = GetIndex(AddressInfo,T.ToAddressID);
T.DistanceCosts = DistanceMatrix(sub2ind(size(DistanceMatrix), T.FromAddressIndex, T.ToAddressIndex)) * C_km;
T.TimeCosts = TimeMatrix(sub2ind(size(DistanceMatrix), T.FromAddressIndex, T.ToAddressIndex)) * C_min;
T.MountingCosts = ones(size(T,1),1)*2*mountingTime*C_min;
T.MountingCosts(T.DistanceCosts == 0) = 0;

T.TotalCosts = T.DistanceCosts + T.TimeCosts + T.MountingCosts;

%% Terminal to customer
% Distance/time costs between terminal and customer
% 1x dismounting costs
% 1x unloading costs
% Distance/time costs between customer and cheapest cleaning/terminal
I.FromAddressIndex = GetIndex(AddressInfo,I.FromAddressID);
I.ToAddressIndex = GetIndex(AddressInfo,I.ToAddressID);
I.DistanceCostsToCus = DistanceMatrix(sub2ind(size(DistanceMatrix), I.FromAddressIndex, I.ToAddressIndex)) * C_km;
I.TimeCostsToCus = TimeMatrix(sub2ind(size(DistanceMatrix), I.FromAddressIndex, I.ToAddressIndex)) * C_min;
I.MountingCosts = ones(size(I,1),1) * mountingTime*C_min;
I.LoadingTimeCost = I.loadTime * C_min;

% calculate cheapest depot to leave tank
CostMatrix(CostMatrix == 0) = inf;
IsSupplier = AddressInfo.IsSupplier == 1 & AddressInfo.IsTerminal == 0 & AddressInfo.IsCleaning == 0;
IsCustomer = AddressInfo.IsSupplier == 1 & AddressInfo.IsTerminal == 0 & AddressInfo.IsCleaning == 0;
CostMatrix(IsSupplier,:) = inf;
CostMatrix(IsCustomer,:) = inf;
for i = 1:size(CostMatrix,2)
    [~,cheapDepotForCus(1,i)] = min(CostMatrix(:,i));
end
I.BestDepot = cheapDepotForCus(I.ToAddressIndex)';

I.DistanceCostsToDep = DistanceMatrix(sub2ind(size(DistanceMatrix), I.FromAddressIndex, I.BestDepot)) * C_km;
I.TimeCostsToDep = TimeMatrix(sub2ind(size(DistanceMatrix), I.FromAddressIndex, I.BestDepot)) * C_min;

I.TotalCosts = I.DistanceCostsToCus + I.TimeCostsToCus + I.MountingCosts + I.LoadingTimeCost + I.DistanceCostsToDep + I.TimeCostsToDep;

%% Supplier to terminal
% Distance/time costs between cheapest cleaning and supplier
% 1x dismounting costs
% 1x unloading costs
% Distance/time costs between supplier and terminal
O.FromAddressIndex = GetIndex(AddressInfo,O.FromAddressID);
O.ToAddressIndex = GetIndex(AddressInfo,O.ToAddressID);
O.CheapestCleaningIndex = CheapestClean(sub2ind(size(DistanceMatrix), O.FromAddressIndex, O.FromAddressIndex));
O.DistanceCostsToSup = DistanceMatrix(sub2ind(size(DistanceMatrix), O.CheapestCleaningIndex, O.FromAddressIndex)) * C_km;
O.DistanceCostsToTer = DistanceMatrix(sub2ind(size(DistanceMatrix), O.FromAddressIndex, O.ToAddressIndex)) * C_km;
O.TimeCostsToSup = TimeMatrix(sub2ind(size(DistanceMatrix), O.CheapestCleaningIndex, O.FromAddressIndex)) * C_min;
O.TimeCostsToTer = TimeMatrix(sub2ind(size(DistanceMatrix), O.FromAddressIndex, O.ToAddressIndex)) * C_min;
O.LoadingTimeCost = O.loadTime * C_min;
O.MountingCosts = ones(size(O,1),1) * mountingTime * C_min;

O.TotalCosts = O.DistanceCostsToSup + O.DistanceCostsToTer + O.TimeCostsToSup + O.TimeCostsToTer + O.LoadingTimeCost + O.MountingCosts; 
 
%% Supplier to customer
% Distance/time costs between supplier and customer
% Distance/time costs between cheapest cleaning and supplier
% 2x unloading costs
% Distance/time costs between customer and cheapest depot
U.FromAddressIndex = GetIndex(AddressInfo,U.FromAddressID);
U.ToAddressIndex = GetIndex(AddressInfo,U.ToAddressID);
U.DistanceCostsToCus = DistanceMatrix(sub2ind(size(DistanceMatrix), U.FromAddressIndex, U.ToAddressIndex)) * C_km;
U.TimeCostsToCus = TimeMatrix(sub2ind(size(DistanceMatrix), U.FromAddressIndex, U.ToAddressIndex)) * C_min;
U.LoadingTimeCost = 2 * U.loadTime * C_min;
U.BestDepot = cheapDepotForCus(U.ToAddressIndex)';
U.DistanceCostsToDep = DistanceMatrix(sub2ind(size(DistanceMatrix), U.ToAddressIndex,U.BestDepot)) * C_km;
U.TimeCostsToDep = TimeMatrix(sub2ind(size(DistanceMatrix), U.ToAddressIndex,U.BestDepot)) * C_min;
U.CheapestCleaningIndex = CheapestClean(sub2ind(size(DistanceMatrix), U.FromAddressIndex, U.FromAddressIndex));
U.DistanceCostsToSup = DistanceMatrix(sub2ind(size(DistanceMatrix), U.CheapestCleaningIndex, U.FromAddressIndex)) * C_km;
U.TimeCostsToSup = TimeMatrix(sub2ind(size(DistanceMatrix), U.CheapestCleaningIndex, U.FromAddressIndex)) * C_min;

U.TotalCosts = U.DistanceCostsToCus +U.TimeCostsToCus+ U.LoadingTimeCost+ U.DistanceCostsToDep+ U.TimeCostsToDep+ U.DistanceCostsToSup+ U.TimeCostsToSup;

%%

LB = sum([U.TotalCosts;O.TotalCosts;I.TotalCosts;T.TotalCosts]);


end