function [Index] = getIndex(IDS)
% Get Addressinfo Index for given list of location IDS
load ../NewData/AddressInfo
I = [1:size(AddressInfo,1)]';
II = repmat(I,1,length(IDS));
Select = AddressInfo.AddressID == IDS';

Index = II(Select);
end 