load ../NewData/LinkingMatrices
load ../NewData/AddressInfo
load ../DataHS/CostsPerKmPerTrucks

%%
C_km = mean(CostsPerKm);
C_min = 20/60;

%% Calculate cost matrix
CostMatrix = DistanceMatrix * C_km + TimeMatrix * C_min;

%% Calculate nearest cleaning facility
cheapestDepot =  zeros(size(DistanceMatrix));
TotalBest = 1e12;

nTotal = length(AddressInfo.AddressID);

for i = 1:nTotal
    if AddressInfo.IsSupplier(i) == 1
        
        for j = 1:nTotal
            if AddressInfo.IsCustomer(j) == 1
                
                for k = 1:nTotal
                    if AddressInfo.IsTerminal(k) == 1
                        
                        TotalTemp = CostMatrix(i,k) + CostMatrix(k,j);
                        
                        if TotalTemp < TotalBest
                            cheapestDepot(i,j) = k;
                            TotalBest  = TotalTemp;
                        end
                        
                    end
                end
                TotalBest = 1e12;
            end
        end
    end
    i
end