addpath('./func'); 
addpath('./func/polytopes/'); 
addpath('./func/haversine/'); 


%% Parameters
PATIENT = 1;                    
ETA = 1;                        % 2*ETA is the interval width of the peer locations
EPSILON = 3;
LAMBDA = 1; 
region = 10; 
% [coordinate, edge, edge_weight] = read_city_data(50); 


%% Select the target

    
ETA_SCALE = 0.03;
% ETA_SCALE = 1/5000;
EPSILON_SCALE = 2; 
% EPSILON_SCALE = 500;
load('.\results\campus\user_ID_campus.mat'); 

%% Obfuscation matrix generatoin
cost_distribution = []; 
real_cost = zeros(5, 30); 

for ETA = 1:1:1
    for EPSILON = 1:1:1 
        for REGION =   1:1:81
            VARIABLE_1 = ETA; 
            VARIABLE_2 = REGION; 
            [VARIABLE_1, VARIABLE_2]
            [coordinate, edge, G, NR_LOC] = read_data(REGION);
            node_density(REGION) = NR_LOC;
            edge_density(REGION) = size(edge, 1); 
            for PATIENT = 1:1:1
                    filename = append('.\real_test\3\result_', int2str(ETA), '_', int2str(EPSILON), '.csv'); 
                    overallcost(VARIABLE_1, VARIABLE_2) = -1; 
                    running_time(VARIABLE_1, VARIABLE_2) = -1;
                    nr_constraints_matrix(VARIABLE_1, VARIABLE_2) = -1;
                    nr_constraints_neighbor(VARIABLE_1, VARIABLE_2) = -1;
                    peerMatrix_mean(VARIABLE_1, VARIABLE_2) = -1;
                    peerNeighbor_mean(VARIABLE_1, VARIABLE_2) = -1;
                    clear cost_distribution; 
                    if NR_LOC > 0
                        [overallcost(VARIABLE_1, VARIABLE_2), ... 
                        peerMatrix, ... 
                        peerNeighbor, ... 
                        running_time_init(VARIABLE_1, VARIABLE_2), ...
                        running_time_master(VARIABLE_1, VARIABLE_2), ...
                        running_time_subproblem(VARIABLE_1, VARIABLE_2), ... 
                        z, ...
                        cost_distribution(VARIABLE_1, :), ...
                        real_cost(VARIABLE_1, :), ...
                        iter_stop(VARIABLE_1, VARIABLE_2), ...
                        convergence(VARIABLE_2, :)]                           = obfmatrix_generator_DW( G, ...
                                                                                coordinate, ...
                                                                                PATIENT, ... % user_ID(ETA, PATIENT), ... 
                                                                                (EPSILON+2)*EPSILON_SCALE, ...
                                                                                (ETA+9)/10*ETA_SCALE, ...
                                                                                LAMBDA, ...
                                                                                NR_LOC, ...
                                                                                filename); 
                        nr_peer = sum(peerMatrix); 
                        nr_constraints_matrix(VARIABLE_1, VARIABLE_2) = sum(nr_peer.^2);
                        nr_constraints_neighbor(VARIABLE_1, VARIABLE_2) = sum(sum(peerNeighbor).*nr_peer); 
                        peerMatrix_mean(VARIABLE_1, VARIABLE_2) = mean(sum(peerMatrix)); 
                        peerNeighbor_mean(VARIABLE_1, VARIABLE_2) = mean(sum(peerNeighbor));
                    end
%             csvwrite(append('.\obfuscation_matrix\obfuscationmatrix_', int2str(ETA), '_', int2str(EPSILON), '.csv'), z); 
            end 
        % overallcost_(ETA, EPSILON) = overallcost(ETA, PATIENT); 
        end

%         overallcost(ceil((ETA-0.9)*10), EPSILON) = obfmatrix_generator_DW(G, coordinate, PATIENT, EPSILON/15, NR_LOC, ETA*20); 
    end
end