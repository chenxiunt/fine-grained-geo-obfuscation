function [GeoIMatrix, extremepoint] = DW_init(peerMatrix, peerNeighbor, distMatrix, costMatrix, k, NR_LOC, EPSILON, LAMBDA)
    extremepoint = []; 
    [idx_row, idx_col] = find(peerMatrix); 
    real_loc_idx = idx_row(find(idx_col == k));

%% Create tee GeoIMatrix for a z_k
    GeoIMatrix = sparse(0, NR_LOC); 
    constraint_idx = 1; 
    for i = 1:1:size(real_loc_idx, 1)-1
        for j = i+1:1:size(real_loc_idx, 1)
            % [real_loc_idx(i) real_loc_idx(j)]
            if peerNeighbor(real_loc_idx(i), real_loc_idx(j)) > 0 && distMatrix(real_loc_idx(i), real_loc_idx(j)) <= LAMBDA
                GeoIMatrix(constraint_idx, real_loc_idx(i)) = 1;
                GeoIMatrix(constraint_idx, real_loc_idx(j)) = -exp(EPSILON*distMatrix(real_loc_idx(i), real_loc_idx(j)));
                constraint_idx = constraint_idx + 1;
                GeoIMatrix(constraint_idx, real_loc_idx(j)) = 1;
                GeoIMatrix(constraint_idx, real_loc_idx(i)) = -exp(EPSILON*distMatrix(real_loc_idx(i), real_loc_idx(j)));
                constraint_idx = constraint_idx + 1;
            end
        end
    end
    nr_constraints = constraint_idx - 1;

%% Fina an optimal solution
%     options = optimoptions('linprog', 'Algorithm', 'dual-simplex', 'Display', 'none');
%     options.Preprocess = 'none';
%     A = GeoIMatrix;
%     b = zeros(size(GeoIMatrix, 1), 1);
%     Aeq = []; 
%     beq = []; 
%     lb = zeros(NR_LOC, 1);
%     ub = ones(NR_LOC, 1);
%     f = costMatrix(:, k);
%     x = linprog(f, A, b, [], [], lb, ub, options);
%     feasible_solution = peerMatrix(:, k) * x(k, 1); 

%% Find a feasible solution
%     options = optimoptions('linprog', 'Algorithm', 'dual-simplex', 'Display', 'none');
%     options.Preprocess = 'none';
%     A = [];
%     b = [];
%     Aeq = full(peerMatrix); 
%     beq = ones(NR_LOC, 1); 
%     lb = zeros(NR_LOC, 1);
%     ub = ones(NR_LOC, 1);
%     f = costMatrix(:, k);
%     x = linprog(f, A, b, [], [], lb, ub, options);
%     feasible_solution = peerMatrix(:, k) * x(k, 1); 

%     exitflag = 0; 
%     iter = 1; 
%     while exitflag ~= 1
%         [k iter]
%         extremepoint_temp = add_extremepoint_rand(GeoIMatrix, peerMatrix, nr_constraints, iter, k, NR_LOC); 
%         % extremepoint_temp = pinv(full(peerMatrix))*ones(133, 1); 
%         extremepoint = [extremepoint, extremepoint_temp]; 
%         clear Aeq beq; 
%         Aeq = [extremepoint; ones(1, iter)]; 
%         beq = [feasible_solution; 1]; 
%         lb = zeros(iter, 1);
%         ub = ones(iter, 1); 
%         [x, ~, exitflag, ~] = linprog(ones(1, iter), [], [], Aeq, beq, lb, ub, options);
%         iter = iter + 1;
%     end

%     for iter = 1:1:NR_LOC
%         [k iter]
%         extremepoint_temp = add_extremepoint_rand(GeoIMatrix, peerMatrix, nr_constraints, costMatrix(:, k), iter, k, NR_LOC); 
%         % extremepoint_temp = pinv(full(peerMatrix))*ones(133, 1); 
%         extremepoint = [extremepoint, extremepoint_temp]; 
% %         clear Aeq beq; 
% %         Aeq = [extremepoint; ones(1, iter)]; 
% %         beq = [feasible_solution; 1]; 
% %         lb = zeros(iter, 1);
% %         ub = ones(iter, 1); 
% %         [lambda, ~, exitflag, ~] = linprog(ones(1, iter), [], [], Aeq, beq, lb, ub, options);
% %         if exitflag == 1
% %             break; 
% %         end
%     end




    % c = pinv(full(peerMatrix))*ones(133, 1);
end