load NewData/LinkingMatrices
load NewData/AddressInfo
load DataHS/CostsPerKmPerTrucks

%%
C_km = mean(CostsPerKm);
C_h = 20/60;

%%
CheapestClean =  zeros(size(DistanceMatrix));
TotalPrev = 1e12;

for i = 1:length(AddressInfo.AddressID)
    if AddressInfo.IsCustomer(i) == 1 || AddressInfo.IsTerminal(i) == 1
        
        for j = 1:length(AddressInfo.AddressID)
            if AddressInfo.IsSupplier(j) == 1
                
                for k = 1:length(AddressInfo.AddressID)
                    if AddressInfo.IsCleaning(k) == 1
                        
                        TotalTemp = C_km * (DistanceMatrix(i,k) + DistanceMatrix(k,j)) + C_h * (TimeMatrix(i,k) + TimeMatrix(k,j));
                        
                        if TotalTemp < TotalPrev
                            CheapestClean(i,j) = k;
                            TotalPrev  = TotalTemp;
                        end
                        
                    end
                end
                TotalPrev = 1e12;
            end
        end
    end
    
end

