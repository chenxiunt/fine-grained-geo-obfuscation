function extremepoint = add_extremepoint_rand(GeoIMatrix, peerMatrix, nr_constraints, costMatrix, iter, k, NR_LOC)
    b = zeros(nr_constraints, 1); 
    lb = zeros(NR_LOC, 1)*0;
    ub = full(peerMatrix(:, k)); 
    

    options = optimoptions('linprog','Algorithm','dual-simplex', 'Display','none');
    options.Preprocess = 'none';

    %%  Find an extreme point
    if k >= 1 
        for i = 1:1:1
%             f = rand(1, NR_LOC)-0.5; 
            f = -costMatrix; 
            f(iter, 1) = 0;
            [extremepoint, ~] = linprog(f, GeoIMatrix, b, [], [], lb, ub, options); 

%             A = [full(GeoIMatrix); eye(NR_LOC); -eye(NR_LOC)];
%             b = [b; ones(NR_LOC, 1); zeros(NR_LOC, 1)]; 
%             V=lcon2vert(A, b, [], []); 

%            extremepoint = [extremepoint, extremepoint_temp]; 
        end
    end
end