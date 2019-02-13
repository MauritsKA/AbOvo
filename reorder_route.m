function [route] = reorder_route(route)
% find best(?) route by ordering the jobs on chronological order of average
% opening time
open_av = mean(route(:,1:2),2);
route = [open_av,route];
sortrows(route,1);
route(:,1) = [];
end

