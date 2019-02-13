function [U,I,O,Ws,Wt] = SelectOrders(OrderLists,IDS,t_start,t_end)
% Select complete region, Exclude transfers of full tanktainers
U_c =[]; O_c=[]; I_c = []; Ws_c =[]; Wt_c =[];
for i = 1:length(IDS)
U_c = [U_c; OrderLists(IDS(i)).U]; % Orders
O_c = [O_c; OrderLists(IDS(i)).O]; % Outgoing Orders
I_c = [I_c; OrderLists(IDS(i)).I]; % Incoming Orders
Ws_c = [Ws_c; OrderLists(IDS(i)).Ws]; % Incoming empty tanks - part of Source
Wt_c = [Wt_c; OrderLists(IDS(i)).Wt]; % Outgoing empty tanks - part of Sink
end 

% Filter on time
 U_i =1; I_i =1; O_i=1; Ws_i=1; Wt_i=1;
for i = 1:max([size(U_c,1),size(O_c,1),size(I_c,1),size(Ws_c,1),size(Wt_c,1)]) % Iterate over all
    if i <= size(U_c,1)
        Midp = U_c.PickupWindowStart(i)+diff([U_c.PickupWindowStart(i) U_c.PickupWindowEnd(i)])/2;
        Midd = U_c.DeliveryWindowStart(i)+diff([U_c.DeliveryWindowStart(i) U_c.DeliveryWindowEnd(i)])/2;
        if or(Midp >= t_start & Midp < t_end, Midd >= t_start & Midd < t_end)
         U(U_i,:) =U_c(i,:);
         U_i= U_i+1;
        end
    end
    if i <= size(O_c,1)
        Mid = O_c.PickupWindowStart(i)+diff([O_c.PickupWindowStart(i) O_c.PickupWindowEnd(i)])/2;
        if Mid >= t_start && Mid < t_end
         O(O_i,:) =O_c(i,:);
         O_i= O_i+1;
        end
    end
    if i <= size(I_c,1)
       Mid = I_c.DeliveryWindowStart(i)+diff([I_c.DeliveryWindowStart(i) I_c.DeliveryWindowEnd(i)])/2;
        if Mid >= t_start && Mid < t_end
         I(I_i,:) =I_c(i,:);
         I_i= I_i+1;
        end
    end
    if i <= size(Ws_c,1)
        if Ws_c.PickupWindowStart(i) >= t_start && Ws_c.PickupWindowStart(i) < t_end
         Ws(Ws_i,:) =Ws_c(i,:);
         Ws_i= Ws_i+1;
        end
    end
    if i <= size(Wt_c,1)
        if Wt_c.DeliveryWindowEnd(i) >= t_start && Wt_c.DeliveryWindowEnd(i) < t_end
         Wt(Wt_i,:) =Wt_c(i,:);
         Wt_i= Wt_i+1;
        end
    end
end
end 