clear all; clc;
load NewData/AddressInfo
load NewData/LinkingMatrices
load NewData/Intermodals
load NewData/Orders

for i = 1:length(Orders.OrderID)
    OrderConnections(i).OrderID = Orders(i,1:end);
    OrderConnections(i).Intermodals = Intermodals(Intermodals.OrderID == Orders.OrderID(i),1:end);
end

Countries = unique(AddressInfo.Country);

% Total orders country
for i = 1:length(Countries) % for each country
    TotalOrders(i,1) = sum(Orders.FromCountry == Countries(i) | Orders.ToCountry == Countries(i));
end

% Count Orders from
for i = 1:length(Countries) % for each country
    OrdersFrom(i,1) = sum(Orders.FromCountry == Countries(i));
end

% Count Orders to
for i = 1:length(Countries) % for each country
    OrdersTo(i,1) = sum(Orders.ToCountry == Countries(i));
end

% Total domestic orders
for i = 1:length(Countries) % for each country
    I = Orders.ToCountry == Countries(i) & Orders.FromCountry == Countries(i);
    DomesticOrders(i,1) = sum(I);
    IndirectDomesticOrders(i,1) = 0;
    for j = 1:length(I)
        if I(j) == true
            if ~isempty(OrderConnections(j).Intermodals(:,10:11))
                 IndirectDomesticOrders(i,1) =  IndirectDomesticOrders(i,1) +1;
            end
        end
    end
end

% Total cross border orders
for i = 1:length(Countries) % for each country
    I = Orders.ToCountry ~= Countries(i) & Orders.FromCountry == Countries(i) | Orders.ToCountry == Countries(i) & Orders.FromCountry ~= Countries(i);
    J = I == true & Orders.DirectShipment == 1; % Cross border & direct
    K = I == true & Orders.DirectShipment == 0; % Cross border but indirect
    CrossBorderOrders(i,1) = sum(I);
    DirectCrossBorderOrders(i,1) = sum(J);
    IndirectCrossborderOrders_basic(i,1) =0;
    IndirectCrossborderOrders_domestic(i,1) =0;
    IndirectCrossborderOrders_multiple(i,1) =0;
    IndirectCrossborderOrders_complex(i,1) =0;
    
     for j = 1:length(K)
        if K(j) == true
            if ~isempty(OrderConnections(j).Intermodals(:,10:11))
                 C= OrderConnections(j).Intermodals(:,10:11);
                 if length(C.DepartureCountry) == 1 && C.DepartureCountry ~= C.ArrivalCountry
                    IndirectCrossborderOrders_basic(i,1) =  IndirectCrossborderOrders_basic(i,1) +1;
                 elseif length(C.DepartureCountry) == 1 && C.DepartureCountry == C.ArrivalCountry
                    IndirectCrossborderOrders_domestic(i,1) =  IndirectCrossborderOrders_domestic(i,1) +1;
                 else
                     Seperated = true; % Countries are seperated by intermodals
                     for l=1:length(C.DepartureCountry)-1 % Check 
                        Linked = C.ArrivalCountry(l) == C.DepartureCountry(l+1); 
                        if Linked ~= true
                            Seperated = false;
                        end 
                     end 
                     if Seperated == true % multiple intermodals, but all cross border
                         IndirectCrossborderOrders_multiple(i,1) =  IndirectCrossborderOrders_multiple(i,1) +1;
                     else  % multiple intermodals, including crossing border by truck
                         IndirectCrossborderOrders_complex(i,1) =  IndirectCrossborderOrders_complex(i,1) +1;
                     end 
                 end
            end
        end
    end
end

% Count total domestic and cross border intermodal connections used
for i = 1:length(Countries) % for each country
    UsedCountryIntermodals(i).name = string(Countries(i));
    UsedCountryIntermodals(i).Connections = Intermodals(Intermodals.DepartureCountry == Countries(i) | Intermodals.ArrivalCountry == Countries(i),1:end);
    UsedCountryIntermodals(i).Domestic = sum(Intermodals.DepartureCountry == Countries(i) & Intermodals.ArrivalCountry == Countries(i));
    UsedCountryIntermodals(i).CrossingFrom = sum(Intermodals.DepartureCountry == Countries(i) & Intermodals.ArrivalCountry ~= Countries(i));
    UsedCountryIntermodals(i).CrossingTo = sum(Intermodals.DepartureCountry ~= Countries(i) & Intermodals.ArrivalCountry == Countries(i));
end

% Count total existing domestic and cross border intermodal connections
for i = 1:length(Countries) % for each country
    ExistingCountryIntermodals(i).name = string(Countries(i));
    Nodes = [UsedCountryIntermodals(i).Connections.DepartureAddressID UsedCountryIntermodals(i).Connections.ArrivalAddressID]; % Select adresses
    [~,I,~] = unique(Nodes,'rows'); % Return indices of unique arrival /departure combinations
    [~,IN,~] = unique(UsedCountryIntermodals(i).Connections.ConnectionName); % Return indices of unique connection names
    J = false(length(Nodes),1); J(I) = true; I = J; % Convert to logical vector
    JN = false(length(Nodes),1); JN(IN) = true; IN = JN; % Convert to logical vector
    ExistingCountryIntermodals(i).Connections = UsedCountryIntermodals(i).Connections(I,[5,6,7,10,11]); % Select all unique combinations
    ExistingCountryIntermodals(i).UniqueNames = UsedCountryIntermodals(i).Connections(IN,[5,6,7,10,11]); % Select all unique names
    ExistingCountryIntermodals(i).Domestic = sum(I == true & UsedCountryIntermodals(i).Connections.DepartureCountry == Countries(i) & UsedCountryIntermodals(i).Connections.ArrivalCountry == Countries(i)); % Check if domestic & unique
    ExistingCountryIntermodals(i).CrossingFrom = sum(I == true & UsedCountryIntermodals(i).Connections.DepartureCountry == Countries(i) & UsedCountryIntermodals(i).Connections.ArrivalCountry ~= Countries(i));
    ExistingCountryIntermodals(i).CrossingTo = sum(I == true & UsedCountryIntermodals(i).Connections.DepartureCountry ~= Countries(i) & UsedCountryIntermodals(i).Connections.ArrivalCountry == Countries(i));
end

for i = 1:length(Countries) % Rebuild columns in structures as array
    ExistingDomesticIntermodals(i,1) = ExistingCountryIntermodals(i).Domestic;
    ExistingCrossingFromIntermodals(i,1) = ExistingCountryIntermodals(i).CrossingFrom;
    ExistingCrossingToIntermodals(i,1) = ExistingCountryIntermodals(i).CrossingTo;
end
    
    Countries_Connections_Info = table(Countries,TotalOrders, OrdersFrom, OrdersTo,DomesticOrders,IndirectDomesticOrders,...
    CrossBorderOrders,DirectCrossBorderOrders,IndirectCrossborderOrders_basic,IndirectCrossborderOrders_domestic,IndirectCrossborderOrders_multiple,IndirectCrossborderOrders_complex,...
    ExistingDomesticIntermodals, ExistingCrossingFromIntermodals, ExistingCrossingToIntermodals);