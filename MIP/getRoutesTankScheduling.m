function [routesTankScheduling]  = getRoutesTankScheduling(Ds, Ws, I, U, O, Wt, Dt, X)

load ../NewData/CheapestCleaning
load ../NewData/AddressInfo
load ../NewData/CheapestDepot

X = logical(X);
n.Ds = size(Ds,1);
n.Dt = size(Dt,1);
n.I = size(I,1);
n.O = size(O,1);
n.U = size(U,1);
n.Ws = size(Ws,1);
n.Wt = size(Wt,1);
n.X = size(X,1);
indexList = 1:1:n.X;

fromIndex.Ds = 1;
fromIndex.Dt = 1;
fromIndex.Ws = 1;
fromIndex.Wt = 1;
fromIndex.O = 1;
fromIndex.U = 1;
fromIndex.I = 1;

for i = 1:n.X
    if i <= n.Ds
        routes(i).nodeFromType = 'Ds';
        routes(i).nodeFromData = Ds(fromIndex.Ds,:);
        fromIndex.Ds = fromIndex.Ds +1;
    end
    if n.Ds < i && i <= n.Ds + n.Ws
        routes(i).nodeFromType = 'Ws';
        routes(i).nodeFromData = Ws(fromIndex.Ws,:);
        fromIndex.Ws = fromIndex.Ws +1;
    end
    if n.Ds + n.Ws < i && i <= n.Ds + n.Ws + n.I
        routes(i).nodeFromType = 'I';
        routes(i).nodeFromData = I(fromIndex.I,:);
        fromIndex.I = fromIndex.I +1;
    end
    if n.Ds + n.Ws + n.I < i && i <= n.Ds + n.Ws + n.I + n.U
        routes(i).nodeFromType = 'U';
        routes(i).nodeFromData = U(fromIndex.U,:);
        fromIndex.U = fromIndex.U +1;
    end
    if n.Ds + n.Ws + n.I + n.U < i && i <= n.Ds + n.Ws + n.I + n.U + n.O
        routes(i).nodeFromType = 'O';
        routes(i).nodeFromData = O(fromIndex.O,:);
        fromIndex.O = fromIndex.O +1;
    end
    if n.Ds + n.Ws + n.I + n.U + n.O < i && i <= n.Ds + n.Ws + n.I + n.U + n.O + n.Wt
        routes(i).nodeFromType = 'Wt';
        routes(i).nodeFromData = Wt(fromIndex.Wt,:);
        fromIndex.Wt = fromIndex.Wt +1;
    end
    if n.Ds + n.Ws + n.I + n.U + n.O + n.Wt < i && i <= n.Ds + n.Ws + n.I + n.U + n.O + n.Wt + n.Dt
        routes(i).nodeFromType = 'Dt';
        routes(i).nodeFromData = Dt(fromIndex.Dt,:);
        fromIndex.Dt = fromIndex.Dt +1;
    end
end

for i = 1:n.Ds + n.Ws + n.I
    
    colIndex = indexList(X(i,:));
    if colIndex <= n.Ds
        routes(i).Ds = routes(colIndex).nodeFromData;
    end
    if n.Ds < colIndex && colIndex <= n.Ds + n.Ws
        routes(i).Ws = routes(colIndex).nodeFromData;
    end
    if n.Ds + n.Ws < colIndex && colIndex <= n.Ds + n.Ws + n.I
        routes(i).I = routes(colIndex).nodeFromData;
    end
    if n.Ds + n.Ws + n.I < colIndex && colIndex <= n.Ds + n.Ws + n.I + n.U
        tempcount = 1;
        routes(i).U = routes(colIndex).nodeFromData;
        newColIndex = indexList(X(colIndex,:));
        while n.Ds + n.Ws + n.I < newColIndex && newColIndex <= n.Ds + n.Ws + n.I + n.U
            routes(i).U(tempcount+1,:) = routes(newColIndex).nodeFromData;
            newColIndex = indexList(X(newColIndex,:));
            tempcount = tempcount+1;
        end
        
        if n.Ds + n.Ws + n.I + n.U < newColIndex && newColIndex <= n.Ds + n.Ws + n.I + n.U + n.O
            routes(i).O = routes(newColIndex).nodeFromData;
        end
        if n.Ds + n.Ws + n.I + n.U + n.O < newColIndex && newColIndex <= n.Ds + n.Ws + n.I + n.U + n.O + n.Wt
            routes(i).Wt = routes(newColIndex).nodeFromData;
        end
        if n.Ds + n.Ws + n.I + n.U + n.O + n.Wt < newColIndex && newColIndex <= n.Ds + n.Ws + n.I + n.U + n.O + n.Wt + n.Dt
            routes(i).Dt = routes(newColIndex).nodeFromData;
        end
        
    end
    if n.Ds + n.Ws + n.I + n.U < colIndex && colIndex <= n.Ds + n.Ws + n.I + n.U + n.O
        routes(i).O = routes(colIndex).nodeFromData;
    end
    if n.Ds + n.Ws + n.I + n.U + n.O < colIndex && colIndex <= n.Ds + n.Ws + n.I + n.U + n.O + n.Wt
        routes(i).Wt = routes(colIndex).nodeFromData;
    end
    if n.Ds + n.Ws + n.I + n.U + n.O + n.Wt < colIndex && colIndex <= n.Ds + n.Ws + n.I + n.U + n.O + n.Wt + n.Dt
        routes(i).Dt = routes(colIndex).nodeFromData;
    end
    
    
end

routesTankScheduling(1:n.Ds+n.Ws+n.I) = routes(1:n.Ds+n.Ws+n.I);

for i = 1:n.Ds + n.Ws + n.I
   if i <= n.Ds
        routesTankScheduling(i).Ds = routesTankScheduling(i).nodeFromData;
    end
    if n.Ds < i && i <= n.Ds + n.Ws
        routesTankScheduling(i).Ws = routesTankScheduling(i).nodeFromData;
    end
    if n.Ds + n.Ws < i && i <= n.Ds + n.Ws + n.I
        routesTankScheduling(i).I = routesTankScheduling(i).nodeFromData;
    end    
end

%%
test = orderfields(routesTankScheduling, {'Ds','Ws','I','U','O','Wt','Dt','nodeFromData','nodeFromType'});

routesTankScheduling = rmfield(test,{'nodeFromData','nodeFromType'});

for i = 1:size(routesTankScheduling,2)
    if size(routesTankScheduling(i).Ds,1)  > 0
        Addresses(i).S = routesTankScheduling(i).Ds.HomeAddressID;
        Indexes(i).S = find(AddressInfo.AddressID == Addresses(i).S);
    end
    if size(routesTankScheduling(i).Ws ,1) > 0
        Addresses(i).S = routesTankScheduling(i).Ws.FromAddressID;
        Indexes(i).S = find(AddressInfo.AddressID == Addresses(i).S);
    end
    if size(routesTankScheduling(i).I ,1) > 0
        Addresses(i).S = routesTankScheduling(i).I.FromAddressID;
        Indexes(i).S = find(AddressInfo.AddressID == Addresses(i).S);
    end
    if size(routesTankScheduling(i).U ,1) > 0 && size(routesTankScheduling(i).O ,1) > 0
        Addresses(i).Supplier = [routesTankScheduling(i).U.FromAddressID; routesTankScheduling(i).O.FromAddressID];
        Addresses(i).Customer = routesTankScheduling(i).U.ToAddressID;
        for j = 1:(size(routesTankScheduling(i).U ,1) + size(routesTankScheduling(i).O ,1)) 
            Indexes(i).Supplier(j,1) = find(AddressInfo.AddressID == Addresses(i).Supplier(j));
        end
        for j = 1:size(routesTankScheduling(i).U ,1)         
            Indexes(i).Customer(j,1) = find(AddressInfo.AddressID == Addresses(i).Customer(j));
        end
    elseif size(routesTankScheduling(i).O ,1) > 0
        Addresses(i).Supplier = routesTankScheduling(i).O.FromAddressID;
        for j = 1:size(routesTankScheduling(i).O ,1) 
            Indexes(i).Supplier(j,1) = find(AddressInfo.AddressID == Addresses(i).Supplier(j));
        end
    elseif size(routesTankScheduling(i).U ,1) > 0
        Addresses(i).Supplier = routesTankScheduling(i).U.FromAddressID;
        Addresses(i).Customer = routesTankScheduling(i).U.ToAddressID;
        for j = 1:size(routesTankScheduling(i).U ,1)  
            Indexes(i).Supplier(j,1) = find(AddressInfo.AddressID == Addresses(i).Supplier(j));
            Indexes(i).Customer(j,1) = find(AddressInfo.AddressID == Addresses(i).Customer(j));
        end
    end
end


Addresses = orderfields(Addresses, {'S','Supplier','Customer'});
Indexes = orderfields(Indexes, {'S','Supplier','Customer'});

%% Calculate pairs of pickup - supplier routes
for i = 1:size(routesTankScheduling,2)
    if size(Indexes(i).Supplier ,1) == 1
        Indexes(i).Pairs = [Indexes(i).S, Indexes(i).Supplier];
    end
    if size(Indexes(i).Supplier ,1) > 1
        Indexes(i).Pairs(1,1:2) = [Indexes(i).S, Indexes(i).Supplier(1,1)];
        for j = 2:size(Indexes(i).Supplier ,1)
            Indexes(i).Pairs(j,1:2) = [Indexes(i).Customer(j-1), Indexes(i).Supplier(j,1)];
        end
    end
end

%% Assign Cleanings
for i = 1:size(routesTankScheduling,2)
    if size(Indexes(i).Pairs ,1) > 0
        for j = 1:size(Indexes(i).Pairs ,1)
            Indexes(i).Cleaning(j,1) = CheapestClean(Indexes(i).Pairs(j,1),Indexes(i).Pairs(j,2));
        end
    end
end

for i = 1:size(routesTankScheduling,2)
    if size(Indexes(i).Cleaning ,1) > 0
        for j = 1:size(Indexes(i).Cleaning ,1)
            routesTankScheduling(i).cleaningAddress(j,1) = AddressInfo.AddressID(Indexes(i).Cleaning(j));
        end
    end
    routesTankScheduling(i).directCleaning = false;
end

%% Assign Depots
for i = 1:size(routesTankScheduling,2)
    if size(routesTankScheduling(i).U ,1) > 0
        for j = 1:size(routesTankScheduling(i).U ,1)
            tempSupplierID = routesTankScheduling(i).U.FromAddressID(j);
            tempSupplierIndex = find(AddressInfo.AddressID == tempSupplierID);
            tempCustomerID = routesTankScheduling(i).U.ToAddressID(j);
            tempCustomerIndex = find(AddressInfo.AddressID == tempCustomerID);
            tempDepotIndex = cheapestDepot(tempSupplierIndex, tempCustomerIndex);
            routesTankScheduling(i).depotAddress(j,1) = AddressInfo.AddressID(tempDepotIndex);
        end
    end
    routesTankScheduling(i).depotUsed = false;
end


end






