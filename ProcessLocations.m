%% Creating location matrix from data
clear all; clc;
load DataHS/Distances
load DataHS/LocationInfo
load DataHS/TerminalAddresses

Addresses= unique(AddressFromID); % All unique adresses, checked and correpsonds with AdressesTo
Indices = 1:length(AddressFromID);

DistanceMatrix = zeros(length(Addresses));
TimeMatrix = zeros(length(Addresses));
for i = 1:length(Addresses)
    AddressFrom = Addresses(i); % Select next from address ID
    IndFrom = Indices(AddressFrom==AddressFromID); % Take all indices where this ID occurs
    
    for j = 1:length(Addresses)
        AddressTo = Addresses(j); % Select next to address ID
        IndTo = IndFrom(AddressToID(IndFrom) == AddressTo); % Check if to address ID occurs in the selected from Indices
        if ~isempty(IndTo) % If connection exists
            DistanceMatrix(i,j) = DistanceKM(IndTo);
            TimeMatrix(i,j) = DistanceSeconds(IndTo);
        end
    end
end

%% Processing Address info 
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




