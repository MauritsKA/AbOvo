function [C] = GetCosts(CostMatrix,CostTravelViaCleaning)

toSupplierIndex = sum(CostTravelViaCleaning,1) > 0;
toSupplierLog = repmat(toSupplierIndex,size(CostTravelViaCleaning,1),1);

tempCosts = CostMatrix;
tempCosts(toSupplierLog) = 0;

C = tempCosts+CostTravelViaCleaning;

end

