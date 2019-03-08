function [similarityLevel] = getSimilarity(p,q)

%% Similarity own trucks
lastRegularTruck = size(q,2)-size(q,1); 
similar_owntrucks = sum(sum(p(:,1:lastRegularTruck) & q(:,1:lastRegularTruck)));

%% Similarity charters
p_trans_q = p(:,lastRegularTruck+1:end)'*q(:,lastRegularTruck+1:end);

dummy3 = find(p_trans_q);

similar_charters = 0;
if ~isempty(dummy3)
    
    p_trans_q_vec = p_trans_q(dummy3);
    
    [p_trans_q_vec,idx] = sort(p_trans_q_vec,'descend');
    
    dummy3 = dummy3(idx,:);
    
    [dummy2,dummy1]=ind2sub(size(q),dummy3);
    
    [~,uniqueCol2,~] = unique(dummy1);
    [~,uniqueCol3,~] = unique(dummy2);
    
    choose = uniqueCol2(logical(sum(uniqueCol2 == uniqueCol3',2)));
    
    similar_charters = sum(p_trans_q_vec(choose));
end
%%
similarityLevel = full(similar_owntrucks + similar_charters);


end