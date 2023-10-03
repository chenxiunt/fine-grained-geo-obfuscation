function [overallcost, peerMatrix, peerNeighbor, ...
    running_time_init, running_time_master, running_time_subproblem, ...
    z, cost_distribution, iter_stop, convergence] ... 
    = obfmatrix_generator_DW(G, coordinate, PATIENT, EPSILON, ETA, LAMBDA, NR_LOC)
    iter_stop = 20; 
    optimal_find = 0; 
    z = zeros(NR_LOC, NR_LOC);
    overallcost = 0; 
    running_time = 0; 
    running_time_init = 0; 
    running_time_master = 0; 
    running_time_subproblem = 0; 

    NR_ITER = 100; 
    convergence = ones(1, NR_ITER); 

    % peerMatrix 
    peerMatrix = peer_location(G, coordinate, PATIENT, NR_LOC, ETA); 
%     peerMatrix = ones(NR_LOC, NR_LOC); 

    [group, peerMatrix] = peer_group(peerMatrix, NR_LOC); 
%     peerMatrix(:, 50) = ones(NR_LOC, 1); 
    % peerNeighbor
    peerNeighbor = peer_neighbor(G, peerMatrix, NR_LOC); 
    % distMatrix: describe the distance between any pair of locations 
    distMatrix = distance_calculation(G, peerMatrix, NR_LOC); 
    % costMatrix: the cost estimation error of two locations given the
    % patient location "PATIENT". 
    costVector = cost_calculation(G, PATIENT, NR_LOC);
    costMatrix = reshape(costVector, NR_LOC, NR_LOC); 
%    cost_distribution = full(peerMatrix.*costMatrix); 

    cost_distribution = 0;
    
    %% Initialization   
    tic
    constraint_matrix1 = sparse(NR_LOC, 0);     % This matrix is used to check whether the matrix of master problem is full rank
    for k = 1:NR_LOC
    % parfor k = 1:NR_LOC   
    % k
        [GeoIMatrix, extremepoint] = DW_init(peerMatrix, peerNeighbor, distMatrix, costMatrix, k, NR_LOC, EPSILON, LAMBDA); 
%         if find(group == k)>0 
%             extremepoint = [zeros(NR_LOC, 1), full(peerMatrix(:, k))];
%         else
%             extremepoint = [zeros(NR_LOC, 1), full(peerMatrix(:, k))];
%         end
        extremepoint = [zeros(NR_LOC, 1), full(peerMatrix(:, k))];
%         extremepoint = [full(peerMatrix(:, k))];
        idx = find(peerMatrix(:, k)); 

%        extremepoint_eye = zeros(NR_LOC, 1);
%         for i =1:1:size(idx, 1)
%             extremepoint_eye(idx(i, 1), i) = 1;
%         end
%        extremepoint = [extremepoint_eye, extremepoint]; 

        subproblem(k) = struct( 'GeoIMatrix', GeoIMatrix, ...
                                'ExtremeP', extremepoint, ...
                                'costMatrix', costMatrix(:, k), ...
                                'cost', costMatrix(:, k)'*extremepoint);
    end  

    for k = 1:NR_LOC
        constraint_matrix1 = [constraint_matrix1, subproblem(k).ExtremeP]; 
    end
    
    nr_ExtremeP = size(constraint_matrix1, 2); 
    constraint_matrix2 = constraint_matrix2_generator(subproblem, nr_ExtremeP, NR_LOC); 
    constraint_matrix = [constraint_matrix1; constraint_matrix2]; 

    b = ones(size(constraint_matrix, 1), 1); 
    lb = zeros(size(constraint_matrix, 2), 1); 
    f = ones(size(constraint_matrix1, 2), 1); 
    options = optimoptions('linprog','Algorithm','dual-simplex', 'Display','none');
    [~, ~, exitflag, ~] = linprog(f, [], [], constraint_matrix, b, lb, [], options); 
    if exitflag ~= 1
        return; 
    end
    running_time_init = toc; 




    %% Two level programming    
    

    checkvalue = zeros(NR_ITER, NR_LOC);
%    crecord = zeros(NR_ITER, NR_LOC);
    dfval = zeros(NR_ITER, 1);
    fval_dual = zeros(NR_ITER, 1);
    iter = 1;

    
    
    %% --------------- Yuede: Please focus on this part -------------------
    while iter <= NR_ITER       
%         iter
        %% Master Dual problem
        tic
        [lambda, pi, mu, cost_vector, dfval(iter, 1), fval_dual(iter, 1), exitflag] = dual_master_DW_1(subproblem, costMatrix); 
        running_time_master = running_time_master + toc; 
        %% Subproblem (Optimality check)
        running_time_subproblem_ = 0; 
        for l = 1:1:NR_LOC
        tic
%         parfor (l = 1:NR_LOC, 16)
            
            [extremeP_temp, cost] = subproblem_dual(subproblem(l), full(peerMatrix(:,l)), pi, mu(l,1), cost_vector(1, l));
            isoptimal(l) = 1;
            checkvalue(iter, l) = cost; 
            if checkvalue(iter, l) > 0.00001
                isoptimal(l) = 0;
                subproblem(l).ExtremeP = [subproblem(l).ExtremeP extremeP_temp];
                subproblem(l).cost = subproblem(l).costMatrix'*subproblem(l).ExtremeP;
            end

            if running_time_subproblem_ < toc
                running_time_subproblem_ = toc; 
            end
        end
        if sum(isoptimal) == NR_LOC
            optimal_find = 1; 
            iter_stop = iter; 
            break; 
        end
        
        lower_bound(iter, 1) = sum(pi) + sum(mu) - sum(checkvalue(iter, :)); 
%         convergence(1, iter) = (-fval_dual(iter, 1))/lower_bound(iter, 1);
        iter = iter + 1;

        running_time_subproblem = running_time_subproblem + toc; 
    end
    % running_time = toc; 

%     plot(dfval)
%     hold on;
%     plot(lower_bound)
    %% -----------------------------------------------------------------
    [lambda, pi, mu, cost_vector, dfval(iter, 1), fval_dual(iter, 1), exitflag] = dual_master_DW_2(subproblem, costMatrix); 


    %% ------- find the iteration to stop
    for iter = 1:1:iter_stop
        convergence(1, iter) = (-fval_dual(iter, 1))/dfval(iter_stop, 1); 
    end
    if optimal_find == 0
        iter_stop = NR_ITER; 
        for iter = 1:1:NR_ITER
            convergence(1, iter) = (-fval_dual(iter, 1))/dfval(NR_ITER, 1); 
            if convergence(1, iter) <= 1.005
                iter_stop = iter;
                break; 
            end
        end
    end
    %% Create the obfuscation matrix
    z_matrix = zeros(NR_LOC, NR_LOC); 
    index = 1;
    for i = 1:1:NR_LOC
        z(:, i) = subproblem(i).ExtremeP*lambda(index: index + size(subproblem(i).ExtremeP, 2)-1); 
        index = index + size(subproblem(i).ExtremeP, 2); 
    end
     
    overallcost = -fval_dual(iter_stop, 1);   

    cost_distribution = cost_error_distribution(z, full(peerMatrix.*costMatrix), NR_LOC); 
end

