% this script makes jobs
load('NewData/RoutesTest')
load('NewData/AddressInfo')
load('NewData/CheapestCleaning')
% load loadingtimes
j = 1;
job = zeros(1,6);
for i = 1:size(routesTankScheduling,2)
    if ~isempty(routesTankScheduling(i,1)) % if starting at Ds
        if ~isempty(routesTankScheduling(i,4)) % if from Ds to U
            k = 1;
            while k <= size(routesTankScheduling(i).U.FromAddressID,1)
                if routesTankScheduling(j).U.directCleaning(k) == 0
                    if k == 1
                        startloc = GetIndex(AddressInfo,routesTankScheduling(i).Ds.HomeAddressID);
                        job(j,3) = routesTankScheduling(j).Ds.ReleaseTime;
                        % start of opening window job j
                    else
                        startloc = GetIndex(AddressInfo,routesTankScheduling(i).U.ToAddressID(k-1));
                        if isempty(routesTankScheduling(j).U.usedepot(k-1))
                            job(j,3) = routesTankScheduling.U.DeliveryWindowStart(k-1)...
                                +loading(routesTankScheduling.U.OrderID(1))...
                                +TimeMatrix(routesTankScheduling.U.ToAddressID(k-1),routesTankScheduling.U.CleaningAddress(k))+36;
                            % pick up at cleaning
                        else
                            job(j,3) = [];% pick up at depot
                        end
                        % this needs to be fixed!!! 
                        % start of opening window job j
                    end
                    job(j,1) = startloc; % start location job j
                    suploc = GetIndex(AddressInfo,routesTankScheduling(i).U.FromAddressID(k));
                    job(j,2) = routesTankScheduling(j).U.cleaningAddress(k); % end location job j
                    job(j,4) = routesTankScheduling(j).U.PickupWindowStart(k)...
                        -(TimeMatrix(startloc,job(j,2))+192+TimeMatrix(job(j,2),suploc))-36;
                    % end of opening window job j this includes mounting and
                    % dismounting at cleaning for the next truck and the
                    % mounting time to pick up the tank at Ds/cus
                    job(j,5) = job(j,3)+36; % earliest ending time of job j
                    job(j,6) = job(j,4)+36; % latest ending time of job j
                    j = j+1;
                    k = k+1;
                else
                end
            end
        end
    else
    end
end