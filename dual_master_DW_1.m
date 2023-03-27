function [lambda, pi, mu, cost_vector, fval, fval_dual, exitflag] = dual_master_DW_1(subproblem, cost_matrix)
    NR_LOC = size(subproblem, 2); 
    lambda = []; 
    fval = 0; 
    exitflag = 1;
    
    nr_ExtremeP = 0;
%     matrix_ExtremeP = []; 
    for l = 1:1:NR_LOC
        nr_ExtremeP = nr_ExtremeP + size(subproblem(l).ExtremeP, 2); 
%         matrix_ExtremeP = [matrix_ExtremeP, subproblem(l).ExtremeP]; 
    end 

    %% Restributed Master problem
    % Cost vector
    cost_vector = []; 
    for l = 1:1:NR_LOC
        cost_vector = [cost_vector subproblem(l).cost];
    end
    
    % Constraint matrix
    idx = 1; 
    % constraint_matrix1 = sparse(NR_LOC, nr_ExtremeP); 
    constraint_matrix1 = zeros(NR_LOC, nr_ExtremeP); 
    % constraint_matrix2 = sparse(NR_LOC, nr_ExtremeP); 
    constraint_matrix2 = zeros(NR_LOC, nr_ExtremeP);
    for l = 1:1:NR_LOC
        constraint_matrix1(:, idx:idx+size(subproblem(l).ExtremeP, 2)-1) = subproblem(l).ExtremeP;
        idx = idx + size(subproblem(l).ExtremeP, 2); 
    end
    idx = 1; 
    for l = 1:1:NR_LOC
        constraint_matrix2(l, idx:idx+size(subproblem(l).ExtremeP, 2)-1) = ones(1, size(subproblem(l).ExtremeP, 2));
        idx = idx + size(subproblem(l).ExtremeP, 2); 
    end
    constraint_matrix = [constraint_matrix1; constraint_matrix2];
    constraint_b = ones(2*NR_LOC, 1);
 	lb = zeros(nr_ExtremeP, 1);
    ub = ones(nr_ExtremeP, 1);
    % Solve the restricted dual problem 
    % cost_vector
    % options = optimoptions('linprog','Algorithm','interior-point', 'Display','none','MaxIter',10000);
%     options = optimoptions('linprog','Algorithm','interior-point', 'Display','none');
%     options.Preprocess = 'none';
%     [lambda, fval, exitflag] = linprog(cost_vector, [], [], constraint_matrix, constraint_b, lb, ub, options);
% 
%     if exitflag ~= 1 
%         % options = optimoptions('linprog','Algorithm','dual-simplex', 'Display','none','MaxIter',10000);
%         options = optimoptions('linprog','Algorithm','dual-simplex', 'Display','none');
%         options.Preprocess = 'none';
%         [lambda, fval, exitflag] = linprog(cost_vector, [], [], constraint_matrix, constraint_b, lb, ub, options);
%     end


    % rank(full(constraint_matrix))
    %% Dual problem
    % options = optimoptions('linprog','Algorithm','dual-simplex', 'Display','none','MaxIter',10000);
    options = optimoptions('linprog','Algorithm','dual-simplex', 'Display','none');
    options.Preprocess = 'none';
    [x, fval_dual, exitflag2] = linprog(-constraint_b, constraint_matrix', cost_vector', [], [], [], ones(2*NR_LOC, 1)*999, options);

    if exitflag2 ~= 1 
        % options = optimoptions('linprog','Algorithm','interior-point', 'Display','none','MaxIter',10000);
        options = optimoptions('linprog','Algorithm','interior-point', 'Display','none');
        options.Preprocess = 'none';
        [x, fval_dual, exitflag2] = linprog(-constraint_b, constraint_matrix', cost_vector', [], [], [], ones(2*NR_LOC, 1)*999, options);
    end
%    [exitflag exitflag2]
    if exitflag2 ~= 1
        a = 0; 
    end
    pi = x(1:NR_LOC, :); 
    mu = x(NR_LOC+1:2*NR_LOC, :);
%     if exitflag == 1
%         pi = x(1:NR_LOC, :); 
%         mu = x(NR_LOC+1:2*NR_LOC, :);
%     else
%         pi = x(1:NR_LOC, :); 
%         mu = x(NR_LOC+1:2*NR_LOC, :);
% %         pi = [];
% %         mu = []; 
%     end
end

