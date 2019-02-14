%% Generating Order Lists for all regions
% Group 5 - OR - Erasmus University Rotterdam

% Initialization
clear vars; clc; close all;
load ../NewData/AddressInfo
load ../NewData/Orders
load ../NewData/InterModals

% Create empty copy of regular order table for Ingoing, Outgoing and Transit orders
I  = cell2table(cell(0,12), 'VariableNames', {'CustomerID','OrderID','Quantity1','PickupWindowStart','PickupWindowEnd','DeliveryWindowStart','DeliveryWindowEnd','FromAddressID','ToAddressID','FromCountry','ToCountry','ConnectionName'});
O  = I;
T = I;
Ws  = cell2table(cell(0,4), 'VariableNames', {'PickupWindowStart','FromAddressID','FromCountry','ConnectionName'});
Wt  = cell2table(cell(0,4), 'VariableNames', {'DeliveryWindowEnd','ToAddressID','ToCountry','ConnectionName'});

% Create Order lists structure and add regular orders
for k = 1:length(Countries)
    Region = Countries(k); % Set next country as new region
    RegionOrders = Orders(Orders.FromCountry== Region | Orders.ToCountry == Region,:); % Select all corresponding orders
    OrderLists(k).Name = string(Region);
    OrderLists(k).U = RegionOrders(RegionOrders.DirectShipment == 1,[1 5 9 8 7 3 2 4 11 12 13]); % Add regular orders
    OrderLists(k).O = O;
    OrderLists(k).I = I;
    OrderLists(k).T = T;
    OrderLists(k).Ws = Ws;
    OrderLists(k).Wt = Wt;
end

% Loop again, but now add all orders with intermodal connections
for k = 1:length(Countries)
    Region = Countries(k); % Set next country as new region
    RegionOrders = Orders(Orders.FromCountry== Region,:); % Select all orders 'from', as jobs are generated for all regions at once
    
    INT = RegionOrders(RegionOrders.DirectShipment == 0,[1 5 9 8 7 3 2 4 11 12 13]); % All intermodal orders
    
    for i = 1:length(INT.OrderID) % For each intermodal order
        Connections = Intermodals(Intermodals.OrderID == INT.OrderID(i),:); % Corresponding Connections
        
        for j = 1:size(Connections,1)
            
            if j == 1 % Then Supplier to departure of connection 1: Outgoing order from region k
                PickupWindowStart = INT.PickupWindowStart(i);
                PickupWindowEnd = INT.PickupWindowEnd(i);
                DeliveryWindowEnd = Connections.DepartureDate(j) + hours(Connections.DepartureTime(j)*24); % Departure of connection
                if DeliveryWindowEnd < PickupWindowEnd
                    PickupWindowEnd = DeliveryWindowEnd - minutes(1);
                end 
                DeliveryWindowStart = INT.PickupWindowStart(i) + minutes(1); % Pickup at supplier, because earlier makes no sense
                Outgoing = [table2cell(INT(i,1:3)), {PickupWindowStart,PickupWindowEnd,DeliveryWindowStart,DeliveryWindowEnd,INT.FromAddressID(i),Connections.DepartureAddressID(j),INT.FromCountry(i),Connections.DepartureCountry(j),Connections.ConnectionName(j)}]; % Set the right info
                OrderLists(k).O = [OrderLists(k).O;Outgoing]; % Add to the list of outgoing orders of this region.
            end
            
            if j > 1 && j <= size(Connections,1) % Then arrival at j-1 to departure at j: Transit order for any region
                PickupWindowStart = Connections.ArrivalDate(j-1) + hours(Connections.ArrivalTime(j-1)*24);
                DeliveryWindowEnd = Connections.DepartureDate(j) + hours(Connections.DepartureTime(j)*24);
                PickupWindowEnd = DeliveryWindowEnd - minutes(1); % Later or sooner makes no sense
                DeliveryWindowStart = PickupWindowStart + minutes(1); % One minute of difference to keep timing
                Transit = [table2cell(INT(i,1:3)), {PickupWindowStart,PickupWindowEnd,DeliveryWindowStart,DeliveryWindowEnd,Connections.ArrivalAddressID(j-1),Connections.DepartureAddressID(j),Connections.ArrivalCountry(j-1),Connections.DepartureCountry(j),Connections.ConnectionName(j)}];
                FromRegion = Connections.ArrivalCountry(j-1);
                ToRegion = Connections.DepartureCountry(j);
                kFrom = find(Countries == FromRegion);
                kTo = find(Countries == ToRegion);
                if kFrom ~= kTo
                    OrderLists(kTo).T = [OrderLists(kTo).T;Transit]; % Add the transit to both regions
                    OrderLists(kFrom).T = [OrderLists(kFrom).T;Transit];
                else
                    OrderLists(kTo).T = [OrderLists(kTo).T;Transit];
                end
            end
            
            if j == size(Connections,1) % Then arrival at j to Customer: Incoming order for any region
                PickupWindowStart = Connections.ArrivalDate(j) + hours(Connections.ArrivalTime(j)*24); % Arrival of connection
                DeliveryWindowEnd = INT.DeliveryWindowEnd(i);
                PickupWindowEnd = DeliveryWindowEnd-minutes(1); % End of time window at customer, because later makes no sense
                DeliveryWindowStart = INT.DeliveryWindowStart(i);
                Incoming = [table2cell(INT(i,1:3)),{PickupWindowStart,PickupWindowEnd,DeliveryWindowStart,DeliveryWindowEnd,Connections.ArrivalAddressID(j),INT.ToAddressID(i),Connections.ArrivalCountry(j),INT.ToCountry(i),Connections.ConnectionName(j)}];
                ToRegion = Connections.ArrivalCountry(j);
                kTo = find(Countries == ToRegion);
                OrderLists(kTo).I = [OrderLists(kTo).I;Incoming];
            end
        end
    end
end

EmptyIntermodals = Intermodals(Intermodals.IsEmpty == 1,:);
for i = 1:size(EmptyIntermodals,1)
    DeliveryWindowEnd = EmptyIntermodals.DepartureDate(i) + hours(EmptyIntermodals.DepartureTime(i)*24);
    PickupWindowStart = EmptyIntermodals.ArrivalDate(i) + hours(EmptyIntermodals.ArrivalTime(i)*24);
    Outgoing = {DeliveryWindowEnd, EmptyIntermodals.DepartureAddressID(i),EmptyIntermodals.DepartureCountry(i),EmptyIntermodals.ConnectionName(i)};
    Incoming = {PickupWindowStart, EmptyIntermodals.ArrivalAddressID(i),EmptyIntermodals.ArrivalCountry(i),EmptyIntermodals.ConnectionName(i)};
    FromRegion = EmptyIntermodals.ArrivalCountry(i);
    ToRegion = EmptyIntermodals.DepartureCountry(i);
    kFrom = find(Countries == FromRegion);
    kTo = find(Countries == ToRegion);
    OrderLists(kTo).Ws = [OrderLists(kTo).Ws;Outgoing]; % Add the source and sink for every empty reposition 
    OrderLists(kFrom).Wt = [OrderLists(kFrom).Wt;Incoming];
end

%% add loading times

SL_VAR = 1; % (Un)loading per gravity unit [Minutes]
SL_FIX = 18; % Fixed (un)loading [Minutes]
UNIT = 1000; %[L]

for i = 1:size(OrderLists,2)
   if size(OrderLists(i).U,1) > 0
       OrderLists(i).U.loadTime = OrderLists(i).U.Quantity1 / UNIT * SL_VAR + SL_FIX;
   end
   
   if size(OrderLists(i).O,1) > 0
       OrderLists(i).O.loadTime = OrderLists(i).O.Quantity1 / UNIT * SL_VAR + SL_FIX;
   end
   
   if size(OrderLists(i).I,1) > 0
       OrderLists(i).I.loadTime = OrderLists(i).I.Quantity1 / UNIT * SL_VAR + SL_FIX;
   end
    
end
