clear all; clc;
load NewData/AddressInfo
load NewData/LinkingMatrices
load NewData/Intermodals
load NewData/Orders

for i = 1:length(Orders.OrderID)
    OrderConnections(i).OrderID = Orders.OrderID(i);
    OrderConnections(i).Intermodals = Intermodals(Intermodals.OrderID == Orders.OrderID(i),1:end);
end 

