function [similarityLevel] = getSimilarity(p,q)

%% Similarity own trucks
similar_owntrucks = sum(sum(p(:,1:257) & q(:,1:257)));

%% Similarity charters
p_trans_q = p(:,258:end)'*q(:,258:end);

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