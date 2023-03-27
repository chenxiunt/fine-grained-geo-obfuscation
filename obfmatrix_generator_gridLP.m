function [overallcost, cost_distribution] = obfmatrix_generator_gridLP(G, coordinate, PATIENT, EPSILON, NR_LOC, ETA)

% 4*4 - 4*5
    X_NUM = 5; 
    Y_NUM = 10; 
    Z_NUM = 1; 

    NR_LOC_GRID = X_NUM*Y_NUM*Z_NUM; 
    OBF_RANGE = 100; 

    X_MIN = min(coordinate(:, 1)); 
    X_MAX = max(coordinate(:, 1)); 
    Y_MIN = min(coordinate(:, 2)); 
    Y_MAX = max(coordinate(:, 2));
    Z_MIN = min(coordinate(:, 3)); 
    Z_MAX = max(coordinate(:, 3));

    x_grid_size = (X_MAX-X_MIN)/X_NUM; 
    y_grid_size = (Y_MAX-Y_MIN)/Y_NUM;
    z_grid_size = (Z_MAX-Z_MIN)/Z_NUM;

    grid_coordinate = zeros(X_NUM*Y_NUM*Z_NUM, 3); 

    for i = 1:1:X_NUM 
        for j = 1:1:Y_NUM 
            for k = 1:1:Z_NUM
                x = X_MIN + x_grid_size*(i-1) + x_grid_size/2;
                y = Y_MIN + y_grid_size*(j-1) + y_grid_size/2;
                z = int8(Z_MIN + z_grid_size*(k-1) + z_grid_size/2);
                index = (i-1)*Y_NUM*Z_NUM + (j-1)*Z_NUM + k; 
                grid_coordinate(index, :) = [x, y, double(z)]; 
            end
        end
    end

    [~, patient_grid_idx] = min(sum((grid_coordinate - coordinate(PATIENT, :)).^2, 2)); 
    

    %% Create the GeoI constraint matrix
    idx = 1;
    GeoI_matrix = sparse(0, NR_LOC_GRID*NR_LOC_GRID); 
    for k = 1:1:NR_LOC_GRID
        for i = 1:1:NR_LOC_GRID
            for j = i+1:1:NR_LOC_GRID
                distance = sqrt((grid_coordinate(i, 1) - grid_coordinate(j, 1))^2 + (grid_coordinate(i, 2) - grid_coordinate(j, 2))^2 + (grid_coordinate(i, 3) - grid_coordinate(j, 3))^2); 
                if distance <= OBF_RANGE
                    GeoI_matrix(idx, (i-1)*NR_LOC_GRID + k) = sqrt(exp(EPSILON*distance));
                    GeoI_matrix(idx, (j-1)*NR_LOC_GRID + k) = -sqrt(exp(EPSILON*distance));
                    idx = idx + 1;
                    GeoI_matrix(idx, (j-1)*NR_LOC_GRID + k) = -sqrt(exp(EPSILON*distance));
                    GeoI_matrix(idx, (i-1)*NR_LOC_GRID + k) = sqrt(exp(EPSILON*distance));
                    idx = idx + 1; 
                end
            end
        end
    end	 
    b = zeros(size(GeoI_matrix, 1), 1); 

    %% Create the probability unit measure
    Aeq = sparse(NR_LOC_GRID, NR_LOC_GRID*NR_LOC_GRID); 
    beq = ones(NR_LOC_GRID, 1); 
    
    for k = 1:1:NR_LOC_GRID
        for l = 1:1:NR_LOC_GRID
            Aeq(k, (k-1)*NR_LOC_GRID + l) = 1;
        end
    end   

    % Greate the cost vector
    for i = 1:1:NR_LOC_GRID
        for j = 1:1:NR_LOC_GRID
            i_patient_distance = sqrt((grid_coordinate(i, 1) - grid_coordinate(patient_grid_idx, 1))^2 + (grid_coordinate(i, 2) - grid_coordinate(patient_grid_idx, 2))^2 + (grid_coordinate(i, 3) - grid_coordinate(patient_grid_idx, 3))^2);  
            j_patient_distance = sqrt((grid_coordinate(j, 1) - grid_coordinate(patient_grid_idx, 1))^2 + (grid_coordinate(j, 2) - grid_coordinate(patient_grid_idx, 2))^2 + (grid_coordinate(j, 3) - grid_coordinate(patient_grid_idx, 3))^2); 
            costVector(1, (i-1)*NR_LOC_GRID+j) = abs(i_patient_distance - j_patient_distance);
            costMatrix(i, j) = abs(i_patient_distance - j_patient_distance);
        end
    end
    

    lb = zeros(NR_LOC_GRID*NR_LOC_GRID,1)*0;
    ub = ones(NR_LOC_GRID*NR_LOC_GRID,1);

    [z, overallcost] = linprog(costVector, GeoI_matrix, b, Aeq, beq, lb, ub);            % Represent obfuscation matrix Z by a vector z, where each z_{i,j} -> z((i-1)*NR_LOC_GRID + j)
    z = reshape(z, NR_LOC_GRID, NR_LOC_GRID); 
    z = z'; 
    %% Measure the expected errors
    [~, D] = shortestpathtree(G, PATIENT);
    overallcost = 0;
    NR_SAMPLE = 100; 


    for i = 1:1:NR_LOC
        for j = 1:1:NR_LOC
            [~, i_grid_idx] = min(sum((grid_coordinate - coordinate(i, :)).^2, 2)); 
            [~, j_grid_idx] = min(sum((grid_coordinate - coordinate(j, :)).^2, 2)); 
            approx_distance = sqrt((grid_coordinate(j_grid_idx, 1) - grid_coordinate(patient_grid_idx, 1))^2 + (grid_coordinate(j_grid_idx, 2) - grid_coordinate(patient_grid_idx, 2))^2 + (grid_coordinate(j_grid_idx, 3) - grid_coordinate(patient_grid_idx, 3))^2); 
            distance_error = abs(approx_distance - D(i)); 
            overallcost = overallcost + distance_error * z(i_grid_idx, j_grid_idx)*NR_LOC_GRID/NR_LOC;    
%             overallcost = overallcost + costMatrix(i_grid_idx, j_grid_idx) * z(i_grid_idx, j_grid_idx)*NR_LOC_GRID/NR_LOC;
        end
    end
    overallcost = overallcost/NR_LOC; 

    cost_distribution = cost_error_distribution(z, costMatrix, NR_LOC_GRID); 
end