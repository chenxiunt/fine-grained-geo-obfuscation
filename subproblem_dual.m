function [extremeP, cost] = subproblem_dual(subproblem, peerMatrix, pi, mu, cost_vector)

    %% Solve the dual problem
    NR_LOC = size(subproblem.ExtremeP, 1); 
    % nr_ExtremeP = size(subproblem.ExtremeP, 2); 
    constraint_matrix = subproblem.GeoIMatrix;  % ; 
    
    b = zeros(size(constraint_matrix, 1), 1);
    lb = zeros(NR_LOC, 1);
    
    ub = peerMatrix; 

    options = optimoptions('linprog','Algorithm','dual-simplex', 'Display','none');
    options.Preprocess = 'none';

    [extremeP, ~, exitflag] = linprog(-(pi-subproblem.costMatrix), constraint_matrix, b, [], [], lb, ub, options);
    if exitflag == 1
        cost = (pi-subproblem.costMatrix)'*extremeP + mu;
    else
        cost = 0;
    end
end

