load NewData/LinkingMatrices
load NewData/AddressInfo
load DataHS/CostsPerKmPerTrucks

%%
C_km = mean(CostsPerKm);
C_min = 20/60;
cleaningTime = 120;
mountingTime = 36;

%% Calculate cost matrix
CostMatrix = DistanceMatrix * C_km + TimeMatrix * C_min;

%% Calculate nearest cleaning facility
CheapestClean =  zeros(size(DistanceMatrix));
TotalBest = 1e12;

for i = 1:length(AddressInfo.AddressID)
    if AddressInfo.IsCustomer(i) == 1 || AddressInfo.IsTerminal(i) == 1
        
        for j = 1:length(AddressInfo.AddressID)
            if AddressInfo.IsSupplier(j) == 1
                
                for k = 1:length(AddressInfo.AddressID)
                    if AddressInfo.IsCleaning(k) == 1
                        
                        TotalTemp = CostMatrix(i,k) + CostMatrix(k,j);
                        
                        if TotalTemp < TotalBest
                            CheapestClean(i,j) = k;
                            TotalBest  = TotalTemp;
                        end
                        
                    end
                end
                TotalBest = 1e12;
            end
        end
    end
    
end

%% Calculate time it takes to drive via nearest cleaning facility
% Times include driving, 2x mounting and cleaning (2h). Times in minutes

n = size(CheapestClean,2);
timeViaCleaning = zeros(size(CheapestClean));

for i = 1:n
    for j = 1:n
        if CheapestClean(i,j) > 0
            timeViaCleaning(i,j) = TimeMatrix(i, CheapestClean(i,j)) + TimeMatrix(CheapestClean(i,j),j) + cleaningTime + 2*mountingTime;
        end
    end
end


%% clear variables
clear i j k n TotalPrev TotalTemp


