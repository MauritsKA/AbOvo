clear;
clc;
load('NewData/AddressInfo')
load('NewData/Truck_Tank_Info')
%%
Countries = unique(AddressInfo.Country);
Truck_Tank_Country = Truck_Tank.Truck_Tank_Country;
Truck = Truck_Tank_Country(1:257,1);
Tank = Truck_Tank_Country(258:size(Truck_Tank_Country,1),1);
Cleaning_boolean = AddressInfo.IsCleaning;
Location_Country = AddressInfo.Country;

Number_Trucks = zeros(size(Countries));
Number_Tanks = zeros(size(Countries));
Number_Cleaning = zeros(size(Countries));

for i = 1:numel(Countries)
    Number_Trucks(i) = sum(Truck == Countries(i));
    Number_Tanks(i) = sum(Tank == Countries(i));
    Number_Cleaning(i) = sum(Location_Country == Countries(i) & Cleaning_boolean == 1);
end

Countries_Recource_Info = table(Countries,Number_Trucks,Number_Tanks,Number_Cleaning);