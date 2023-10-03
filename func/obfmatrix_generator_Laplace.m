function [z, overallcost, cost_distribution] = obfmatrix_generator_Laplace(G, coordinate, PATIENT, EPSILON, NR_LOC, ETA)
    OBF_RANGE = 100; 

    for i = 1:1:NR_LOC
        for j = 1:1:NR_LOC
            distance = sqrt((coordinate(i, 1) - coordinate(j, 1))^2 + (coordinate(i, 2) - coordinate(j, 2))^2 + (coordinate(i, 3) - coordinate(j, 3))^2); 
            if distance <= OBF_RANGE
                z(i, j) = exp(-distance*EPSILON);
            else 
                z(i, j) = 0;
            end
        end
        z_sum = sum(z(i, :));
        z(i, :) = z(i, :)/z_sum; 
    end


    %% Measure the expected errors
    [~, D] = shortestpathtree(G, PATIENT);
    overallcost = 0; 
    for i = 1:1:NR_LOC
        for j = 1:1:NR_LOC
            approx_distance = sqrt((coordinate(j, 1) - coordinate(PATIENT, 1))^2 + (coordinate(j, 2) - coordinate(PATIENT, 2))^2 + (coordinate(j, 3) - coordinate(PATIENT, 3))^2); 
            distance_error = abs(approx_distance - D(i)); 
            costMatrix(i, j) = distance_error; 
            overallcost = overallcost + distance_error * z(i, j);
        end
    end
    overallcost = overallcost/NR_LOC; 
    cost_distribution = cost_error_distribution(z, costMatrix, NR_LOC); 
end
