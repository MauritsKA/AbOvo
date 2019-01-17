% This script appends usefull columns in certain tables. For example it adds the
% country of origin when only the origin addressID is given, adds whether
% an order uses directshipment or not etc

%%
clear;
clc;
load('Table_files');    % (mostly unedited) tables which were imported from excel
load('AddressInfo');    %  Table which was created by us and contains all locations that 
                        %  we have distances off
%%
flag = 0;

FromAddressID = Orders.FromAddressID;
ToAddressID = Orders.ToAddressID;
AddressID = Locations.AddressID;
Country = Locations.Country;


for i = 1:numel(FromAddressID) % country of origin is added to orders table
    for j = 1:numel(AddressID)
        if FromAddressID(i) == AddressID(j)
            FromCountry(i,1) = Country(j);
            flag = 1;
        end
        if flag == 1
            flag = 0;
            break
        end
    end
end


for i = 1:numel(ToAddressID)% country of destination is added to orders table
    for j = 1:numel(AddressID)
        if ToAddressID(i) == AddressID(j)
            ToCountry(i,1) = Country(j);
            flag = 1;
        end
        if flag == 1
            flag = 0;
            break
        end
    end
end

Orders.FromCountry = FromCountry;
Orders.ToCountry = ToCountry;

OrderID = Orders.OrderID;
OrderIDcon = ConUsed.OrderID;
DirectShipment = ones(size(OrderID));
flag = 0;

for i = 1:numel(OrderID) % added to orders table whether an order uses intermodal connections
    for j = 1:size(ConUsed,1)
        if OrderID(i) == OrderIDcon(j)
            DirectShipment(i,1) = 0;
            flag = 1;
        end
        if flag == 1
            flag = 0;
            break
        end
    end
end

Orders.DirectShipment = DirectShipment;

DepartureAddressID = ConUsed.DepartureAddressId;
ArrivalAddressID = ConUsed.ArrivalAddressId;

for i = 1:numel(DepartureAddressID) % add to connection table what thestarting country is 
    for j = 1:numel(AddressID)      % of the connection
        if DepartureAddressID(i) == AddressID(j)
            DepartureCountry(i,1) = Country(j);
            flag = 1;
        end
        if flag == 1
            flag = 0;
            break
        end
    end
end
ConUsed.DepartureCountry = DepartureCountry;

for i = 1:numel(ArrivalAddressID) % add to connection table what the arrival country is
    for j = 1:numel(AddressID)
        if ArrivalAddressID(i) == AddressID(j)
            ArrivalCountry(i,1) = Country(j);
            flag = 1;
        end
        if flag == 1
            flag = 0;
            break
        end
    end
end
ConUsed.ArrivalCountry = ArrivalCountry;


Address_with_Info = AddressInfo.AddressID; % add the starting location of the truck and tanks
Country_Name = AddressInfo.Country;
Truck_TankID = Truck_Tank.HomeAddressID;
Truck_Tank_Country = NaN(size(Truck_TankID ));
Truck_Tank_Country = categorical(Truck_Tank_Country);

for i = 1:size(Truck_Tank,1)
    for j = 1:size(AddressInfo,1)
        if Truck_TankID(i) == Address_with_Info(j)
            Truck_Tank_Country(i,1) =  Country_Name(j,1);
        end
    end
end

Truck_Tank.Truck_Tank_Country = Truck_Tank_Country;
        
        
        
        