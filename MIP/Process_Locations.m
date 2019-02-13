%% Creating location matrix from data
clear vars; clc;
load ../DataHS/LocationInfo % All locations
load ../DataHS/UsedDistancesComplete % All distances
load ../NewData/AddressInfo % All adresses we have to know (small set + 50 missing)

AddressFromID = UsedDistancesComplete.AddressFromID;
AddressToID = UsedDistancesComplete.AddressToID;
DistanceKM = UsedDistancesComplete.DistanceKM; 
DistanceSeconds = UsedDistancesComplete.DistanceSeconds;

Addresses= AddressInfo.AddressID; % All unique adresses, checked and corresponds - unique(AddressFromID)
Indices = 1:length(AddressFromID);

DistanceMatrix = zeros(length(Addresses));
TimeMatrix = zeros(length(Addresses));
for i = 1:length(Addresses)
    AddressFrom = Addresses(i); % Select next from address ID
    IndFrom = Indices(AddressFromID==AddressFrom); % Take all indices where this ID occurs
    for j = 1:length(Addresses)
        AddressTo = Addresses(j); % Select next to address ID
        IndTo = IndFrom(AddressToID(IndFrom) == AddressTo); % Check if to address ID occurs in the selected from Indices
        if ~isempty(IndTo) % If connection exists
            DistanceMatrix(i,j) = DistanceKM(IndTo);
            TimeMatrix(i,j) = DistanceSeconds(IndTo)/60;
        end
    end
end
%%
AddressInfo = NewAddressInfo;
Countries = unique(AddressInfo.Country);

%% Processing Address info
load DataHS/TerminalAddresses

TerminalAddresses = [FromAddressID;ToAddressID]; % Select all arrival & departure locations
TerminalAddresses = unique(TerminalAddresses); % Select unique terminals

IsTerminal=zeros(length(Addresses),1);
for i = 1:length(Addresses) % Build new vectors marking cleaning and/or terminal
    IsCleaningNew(i,1) = IsCleaning(AddressID == Addresses(i)); 
    CountryNew(i,1) = Country(AddressID == Addresses(i));
    IsTerminal(i,1) = sum(TerminalAddresses == Addresses(i));
end 

AddressID = Addresses;
Country = CountryNew;
IsCleaning = logical(IsCleaningNew);
IsTerminal = logical(IsTerminal);

% Saving to table 
AddressInfo = table(AddressID,Country,IsCleaning,IsTerminal);




