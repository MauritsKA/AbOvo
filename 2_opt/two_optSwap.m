function [new_route] = two_optSwap(order,i,j)
%this function creates the new route based on 2_opt swap
a = order(1:i-1,:);
b = order(i:j,:);
c = order(j+1:size(order,1),:);

new_route = [a;flipud(b);c];
end

