function [group, peerMatrix] = peer_group(peerMatrix, NR_LOC)
    
    group = [1];
    covered = peerMatrix(:, 1); 
    for i = 2:1:NR_LOC
        if sum(covered.*peerMatrix(:, i)) <= 0
            group = [group i]; 
            covered = covered + peerMatrix(:, i);
        end
    end
    temp = ones(NR_LOC, 1) - covered; 
    temp = temp';

    temp_sum = temp*peerMatrix; 
    [~, idx_flag] = max(temp_sum); 
    peerMatrix(:, idx_flag) = ones(NR_LOC, 1) - covered;
    group = [group idx_flag]; 
end