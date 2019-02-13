function [routesTankScheduling]  = getRoutesTankScheduling(Ds, Ws, I, U, O, Wt, Dt, Xtest)
Xtest = logical(Xtest);
n.Ds = size(Ds,1);
n.Dt = size(Dt,1);
n.I = size(I,1);
n.O = size(O,1);
n.U = size(U,1);
n.Ws = size(Ws,1);
n.Wt = size(Wt,1);
n.Xtest = size(Xtest,1);
indexList = 1:1:n.Xtest;

fromIndex.Ds = 1;
fromIndex.Dt = 1;
fromIndex.Ws = 1;
fromIndex.Wt = 1;
fromIndex.O = 1;
fromIndex.U = 1;
fromIndex.I = 1;

for i = 1:n.Xtest
    if i <= n.Ds
        routes(i).nodeFromType = 'Ds';
        routes(i).data = Ds(fromIndex.Ds,:);
        fromIndex.Ds = fromIndex.Ds +1;
    elseif i <= n.Ds + n.Ws
        routes(i).nodeFromType = 'Ws';
        routes(i).data = Ws(fromIndex.Ws,:);
        fromIndex.Ws = fromIndex.Ws +1;
    elseif i <= n.Ds + n.Ws + n.I
        routes(i).nodeFromType = 'I';
        routes(i).data = I(fromIndex.I,:);
        fromIndex.I = fromIndex.I +1;
    elseif i <= n.Ds + n.Ws + n.I + n.U
        routes(i).nodeFromType = 'U';
        routes(i).data = U(fromIndex.U,:);
        fromIndex.U = fromIndex.U +1;
    elseif i <= n.Ds + n.Ws + n.I + n.U + n.O
        routes(i).nodeFromType = 'O';
        routes(i).data = O(fromIndex.O,:);
        fromIndex.O = fromIndex.O +1;
    elseif i <= n.Ds + n.Ws + n.I + n.U + n.O + n.Wt
        routes(i).nodeFromType = 'Wt';
        routes(i).data = Wt(fromIndex.Wt,:);
        fromIndex.Wt = fromIndex.Wt +1;
    elseif i <= n.Ds + n.Ws + n.I + n.U + n.O + n.Wt + n.Dt
        routes(i).nodeFromType = 'Dt';
        routes(i).data = Dt(fromIndex.Dt,:);
        fromIndex.Dt = fromIndex.Dt +1;
    end
end

for i = 1:n.Xtest
    if i <= n.Ds
        colIndex = indexList(Xtest(i,:));
        if colIndex <= n.Ds
            routes(i).Ds = routes(colIndex).data;
        elseif colIndex <= n.Ds + n.Ws
            routes(i).Ws = routes(colIndex).data;
        elseif colIndex <= n.Ds + n.Ws + n.I
            routes(i).I = routes(colIndex).data;
        elseif colIndex <= n.Ds + n.Ws + n.I + n.U
            routes(i).U = routes(colIndex).data;
        elseif colIndex <= n.Ds + n.Ws + n.I + n.U + n.O
            routes(i).O = routes(colIndex).data;
        elseif colIndex <= n.Ds + n.Ws + n.I + n.U + n.O + n.Wt
            routes(i).Wt = routes(colIndex).data;
        elseif colIndex <= n.Ds + n.Ws + n.I + n.U + n.O + n.Wt + n.Dt
            routes(i).Dt = routes(colIndex).data;
        end
    elseif i <= n.Ds + n.Ws
        colIndex = indexList(Xtest(i,:));
        if colIndex <= n.Ds
            routes(i).Ds = routes(colIndex).data;
        elseif colIndex <= n.Ds + n.Ws
            routes(i).Ws = routes(colIndex).data;
        elseif colIndex <= n.Ds + n.Ws + n.I
            routes(i).I = routes(colIndex).data;
        elseif colIndex <= n.Ds + n.Ws + n.I + n.U
            routes(i).U = routes(colIndex).data;
        elseif colIndex <= n.Ds + n.Ws + n.I + n.U + n.O
            routes(i).O = routes(colIndex).data;
        elseif colIndex <= n.Ds + n.Ws + n.I + n.U + n.O + n.Wt
            routes(i).Wt = routes(colIndex).data;
        elseif colIndex <= n.Ds + n.Ws + n.I + n.U + n.O + n.Wt + n.Dt
            routes(i).Dt = routes(colIndex).data;
        end
    elseif i <= n.Ds + n.Ws + n.I
        colIndex = indexList(Xtest(i,:));
        if colIndex <= n.Ds
            routes(i).Ds = routes(colIndex).data;
        elseif colIndex <= n.Ds + n.Ws
            routes(i).Ws = routes(colIndex).data;
        elseif colIndex <= n.Ds + n.Ws + n.I
            routes(i).I = routes(colIndex).data;
        elseif colIndex <= n.Ds + n.Ws + n.I + n.U
            routes(i).U = routes(colIndex).data;
        elseif colIndex <= n.Ds + n.Ws + n.I + n.U + n.O
            routes(i).O = routes(colIndex).data;
        elseif colIndex <= n.Ds + n.Ws + n.I + n.U + n.O + n.Wt
            routes(i).Wt = routes(colIndex).data;
        elseif colIndex <= n.Ds + n.Ws + n.I + n.U + n.O + n.Wt + n.Dt
            routes(i).Dt = routes(colIndex).data;
        end
    elseif i <= n.Ds + n.Ws + n.I + n.U
        colIndex = indexList(Xtest(i,:));
        if colIndex <= n.Ds
            routes(i).Ds = routes(colIndex).data;
        elseif colIndex <= n.Ds + n.Ws
            routes(i).Ws = routes(colIndex).data;
        elseif colIndex <= n.Ds + n.Ws + n.I
            routes(i).I = routes(colIndex).data;
        elseif colIndex <= n.Ds + n.Ws + n.I + n.U
            routes(i).U = routes(colIndex).data;
        elseif colIndex <= n.Ds + n.Ws + n.I + n.U + n.O
            routes(i).O = routes(colIndex).data;
        elseif colIndex <= n.Ds + n.Ws + n.I + n.U + n.O + n.Wt
            routes(i).Wt = routes(colIndex).data;
        elseif colIndex <= n.Ds + n.Ws + n.I + n.U + n.O + n.Wt + n.Dt
            routes(i).Dt = routes(colIndex).data;
        end
    end  
    
    
end

routesTankScheduling(1:n.Ds+n.Ws+n.I+n.U) = routes(1:n.Ds+n.Ws+n.I+n.U);

end






