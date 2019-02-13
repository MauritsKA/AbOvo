function [new_route1,new_route2] = CROSS_exchange(route1,route2,a,b,c,d) 
% The CROSS_exchange uses as input 2 routes (can be vectors with ID's or  
% complete matrices). a is the amount that we cut from route 1 b is from 
% which customers we start cutting from route1. c and d are the same as a 
% and b but for route 2. example: a = 1 b = 2 c = 3 d = 4. this would mean 
% we cut 1 customer from the first route and we start cutting from customer 
% 2 (this customer is included). from route2 we cut 3 customers and we 
% start cutting from customer 4 (cut customers 4,5 and 6). afterwards those 
% cut pieces will be exchanged.  
% for the vectors/matrices route every row represents a customer(job) 
 
 
begin1 = route1(1:b-1,:); 
mid1 = route1(b:b-1+a,:); 
if b-1+a == size(route1,1) 
    end1 = []; 
else 
    end1 = route1(b+a:end,:); 
end 
begin2 = route2(1:d-1,:); 
mid2 = route2(d:d-1+c,:); 
if d-1+c == size(route2,1) 
    end2 = []; 
else 
    end2 = route2(d+c:end,:); 
end 
new_route1 = [begin1;mid2;end1]; 
new_route2 = [begin2;mid1;end2]; 
end