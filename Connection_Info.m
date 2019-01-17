clear all; clc;
load NewData/AddressInfo
load NewData/LinkingMatrices
load NewData/Intermodals
load NewData/Orders

for i = 1:length(Orders.OrderID)
    OrderConnections(i).OrderID = Orders.OrderID(i);
    OrderConnections(i).Intermodals = Intermodals(Intermodals.OrderID == Orders.OrderID(i),1:end);
end

Countries = unique(AddressInfo.Country);

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
    DomesticOrders(i,1) = sum(Orders.ToCountry == Countries(i) & Orders.FromCountry == Countries(i));
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
    
end