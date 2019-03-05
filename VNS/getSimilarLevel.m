function [similarLevel] = getSimilarLevel(p,q)
%% Similarity own trucks
similar_owntrucks = sum(sum(p(:,1:257) == q(:,1:257) & p(:,1:257) > 0))

%% Similarity charters
p_jobsWithCharters = sum(p(:,258:end),2);
q_jobsWithCharters = sum(q(:,258:end),2);

similar_charters = p_jobsWithCharters' *  q_jobsWithCharters;

%% Total similar lever
similarLevel = similar_owntrucks + similar_charters;

end