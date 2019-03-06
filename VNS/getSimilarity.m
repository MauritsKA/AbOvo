function [similarityLevel] = getSimilarity(p,q)

%% Similarity own trucks
similar_owntrucks = sum(sum(p(:,1:257) == q(:,1:257) & p(:,1:257) > 0));

%% Similarity charters
P_char = p(:,258:end);
Q_char = q(:,258:end);

p_trans_q = P_char'*Q_char;

dummy1 = repmat([1:1:size(P_char,2)]',size(P_char,2),1);
dum_temp = 1:1:size(P_char,2);
dummy2 = (dum_temp'*ones(1,size(P_char,2)))';
dummy2 = dummy2(:);

temp = [p_trans_q(:), dummy1, dummy2];
temp(temp(:,1) == 0,:) = [];
 
[~,idx] = sort(temp(:,1),'descend');
temp = temp(idx,:);
 
[~,uniqueCol2,~] = unique(temp(:,2));
[~,uniqueCol3,~] = unique(temp(:,3));

choose = uniqueCol2(logical(sum(uniqueCol2 == uniqueCol3',2)));

similar_charters = sum(temp(choose,1));

%%
similarityLevel = similar_owntrucks + similar_charters;


end