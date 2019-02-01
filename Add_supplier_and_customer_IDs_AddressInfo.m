load NewData/Orders
load NewData/AddressInfo

%% Retrieve unique supplier ID's from Order matrix
FromAddressVec = unique(Orders.FromAddressID);
ToAddressVec = unique(Orders.ToAddressID);

%% Check if i'th id in AddressInfo is To/From address of Order Matrix

IsFromAddressVec = zeros(length(AddressInfo.AddressID),1);
IsToAdressVec = zeros(length(AddressInfo.AddressID),1);

for i = 1:length(AddressInfo.AddressID)
   if find(FromAddressVec == AddressInfo.AddressID(i)) > 0
       IsFromAddressVec(i) = 1;
   else
       IsFromAddressVec(i) = 0;
   end
   
   if find(ToAddressVec == AddressInfo.AddressID(i)) > 0
       IsToAdressVec(i) = 1;
   else
       IsToAdressVec(i) = 0;
   end
   
end

%% Add new vectors to AddressInfo table
AddressInfo.IsSupplier = IsFromAddressVec;
AddressInfo.IsCustomer = IsToAdressVec;





