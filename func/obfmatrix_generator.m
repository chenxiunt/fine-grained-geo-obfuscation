function obfmatrix = obfmatrix_generator(G, coordinate, PATIENT, EPSILON, NR_LOC, ETA)
    % x_{k, l} -> x((l - 1)*(NR_LOC + 1) + j)

    peerMatrix = peer_location(G, coordinate, PATIENT, NR_LOC, ETA); 
    peerNeighbor = peer_neighbor(G, peerMatrix, NR_LOC); 
    distMatrix = distance_calculation(G, peerMatrix, NR_LOC); 
    costVector = cost_calculation(G, PATIENT, NR_LOC);
    
    % Create the GeoI constraint matrix
    [row_idx, col_idx] = find(peerMatrix); 
    idx = 1;
    GeoI_matrix = sparse(2*size(row_idx,1), NR_LOC*NR_LOC); 
    for k = 1:1:size(row_idx,1)
        if row_idx(k) ~= col_idx(k) 
            row_idx_nonzero = find(peerMatrix(row_idx(k), :));
            col_idx_nonzero = find(peerMatrix(col_idx(k), :));
            common_peer = intersect(row_idx_nonzero, col_idx_nonzero); 

            for l = 1:1:size(common_peer, 2)
                GeoI_matrix(idx, (row_idx(k)-1)*NR_LOC + common_peer(l)) = 1;
                GeoI_matrix(idx, (col_idx(k)-1)*NR_LOC + common_peer(l)) = -exp(EPSILON*distMatrix(row_idx(k), col_idx(k)));
                idx = idx + 1;
                GeoI_matrix(idx, (col_idx(k)-1)*NR_LOC + common_peer(l)) = -exp(EPSILON*distMatrix(row_idx(k), col_idx(k)));
                GeoI_matrix(idx, (row_idx(k)-1)*NR_LOC + common_peer(l)) = 1;
                idx = idx + 1; 
            end
        end
    end	 
    b = zeros(size(GeoI_matrix, 1), 1); 


    Aeq = sparse(NR_LOC, NR_LOC*NR_LOC); 
    beq = ones(NR_LOC, 1); 
    
    for k = 1:1:NR_LOC
        for l = 1:1:NR_LOC
            Aeq(k, (k-1)*NR_LOC + l) = 1;
        end
    end   
    
    %% Each z is in the range of [0, 1]
	lb = zeros(NR_LOC*NR_LOC,1)*0;
    ub = reshape(peerMatrix, NR_LOC, NR_LOC);


    % Linear programming
%     options = optimoptions('linprog','Algorithm','dual-simplex');
%     options.Preprocess = 'none';



    [z, z_fval] = linprog(costVector, GeoI_matrix, b, Aeq, beq, lb, ub);                       % Represent obfuscation matrix Z by a vector z, where each z_{i,j} -> z((i-1)*NR_LOC + j)
    obfmatrix = reshape(z, NR_LOC, NR_LOC);                                         % reshape the obfuscation vector to matrix
    obfmatrix = obfmatrix'; 

    % test code: draw heatmap
%     idx_test = find(obfmatrix(1, :)); 
%     scatter3(coordinate(idx_test, 1), coordinate(idx_test, 2), coordinate(idx_test, 3), 60); 
    % scatter3(coordinate(idx_test, 1), coordinate(idx_test, 2), coordinate(idx_test, 3), 60, z(1, idx_test)/max(z(1, idx_test)), 'filled'); 
    % z(1, idx_test)/max(z(1, idx_test))

%     f_ = reshape(f, NR_LOC, NR_LOC); 
%     f_ = f_';
end