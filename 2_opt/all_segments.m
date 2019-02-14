function [out] = all_segments(N)
% This function creates all segments
out = [];
for i = 0:N-1
    for j = i+2:N-1
        for k = j+2:N+(i>0)
            out = [out;i,j,k];
        end
    end
end
end

