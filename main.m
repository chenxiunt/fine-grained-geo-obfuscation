addpath('./func'); 
addpath('./func/polytopes/'); 
addpath('./func/haversine/'); 

%% Parameters
PATIENT = 1;                    
ETA = 1;                        % 2*ETA is the interval width of the peer locations
EPSILON = 3;
LAMBDA = 0.05; 
REGION = 10; 
% [coordinate, edge, edge_weight] = read_city_data(50); 


%% Select the target
% target = 'building'; 
target = 'campus'; 
% target = 'city'; 

if strcmp(target, 'building') == 1
    ETA_SCALE = 5;
    EPSILON_SCALE = 1/200; 
    LAMBDA = 50; 
    load('.\results\campus\user_ID_building.mat');
end
if strcmp(target, 'campus') == 1
%     LAMBDA = 0.005;
%     ETA_SCALE = 1/1000;
    ETA_SCALE = 0.1;
    EPSILON_SCALE = 10; 
    load('.\results\campus\user_ID_campus.mat'); 
end

if strcmp(target, 'city') == 1
    ETA_SCALE = 1/4000;
    % ETA_SCALE = 1/5000;
    EPSILON_SCALE = 100; 
    % EPSILON_SCALE = 500;
    load('.\results\campus\user_ID_campus.mat'); 
end

% Read data, including coordinates, edges, graph tree and 
% for region = 1:1:81
%     [coordinate, edge, G, NR_LOC] = read_data(target, region);
%     node_density(region) = NR_LOC;
%     edge_density(region) = size(edge, 1); 
% end

%% Select the algorithm 
% algorithm = 'simplex'; 
algorithm = 'DW'; 
% algorithm = 'gridLP'; 
% algorithm = 'Laplace'; 

%% Obfuscation matrix generatoin
% obfmatrix = obfmatrix_generator(G, coordinate, PATIENT, EPSILON/10, NR_LOC, ETA*20); 

% overallcost = zeros(7, 10); 
% peerMatrix_mean = zeros(7, 1); 
% peerNeighbor_mean = zeros(7, 1); 
% running_time = zeros(7, 1); 

cost_distribution = []; 
real_cost = zeros(5, 30); 


for ETA = 1:1:1
    for EPSILON = 1:1:5
        for REGION =   1:1:1

            
            [coordinate, edge, G, NR_LOC] = read_data(target, REGION);
            node_density(REGION) = NR_LOC;
            edge_density(REGION) = size(edge, 1); 
            prior = ones(1, NR_LOC)/NR_LOC; 
            for PATIENT = 1:1:1
                VARIABLE_1 = EPSILON; 
                VARIABLE_2 = PATIENT; 

                [VARIABLE_1, VARIABLE_2]
            
                if strcmp(algorithm, 'Laplace') == 1
                    [z, overallcost(VARIABLE_1, VARIABLE_2), cost_distribution(VARIABLE_1, :)] = obfmatrix_generator_Laplace(G, coordinate, PATIENT, (EPSILON+2)*EPSILON_SCALE, NR_LOC, (ETA+9)*ETA_SCALE); 
                end
                if strcmp(algorithm, 'gridLP') == 1
                    tic
                    [overallcost(VARIABLE_1, VARIABLE_2), cost_distribution(VARIABLE_1, :)] = obfmatrix_generator_gridLP(G, coordinate, PATIENT, (EPSILON+2)*EPSILON_SCALE, NR_LOC, (ETA+9)/10*ETA_SCALE); 
                    running_time(VARIABLE_1, VARIABLE_2) = toc; 
                end
                if strcmp(algorithm, 'simplex') == 1
                    tic
                    overallcost(EPSILON, PATIENT) = obfmatrix_generator(G, coordinate, PATIENT, (EPSILON+2)*EPSILON_SCALE, NR_LOC, (ETA+9)/10*ETA_SCALE); 
                    running_time(EPSILON, PATIENT) = toc; 
                end
                if strcmp(algorithm, 'DW') == 1
                    filename = append('.\real_test\3\result_', int2str(ETA), '_', int2str(EPSILON), '.csv'); 
                    overallcost(VARIABLE_1, VARIABLE_2) = -1; 
                    running_time(VARIABLE_1, VARIABLE_2) = -1;
                    nr_constraints_matrix(VARIABLE_1, VARIABLE_2) = -1;
                    nr_constraints_neighbor(VARIABLE_1, VARIABLE_2) = -1;
                    peerMatrix_mean(VARIABLE_1, VARIABLE_2) = -1;
                    peerNeighbor_mean(VARIABLE_1, VARIABLE_2) = -1;
                    % clear cost_distribution; 
                    if NR_LOC > 0
                        [overallcost(VARIABLE_1, VARIABLE_2), ... 
                        peerMatrix, ... 
                        peerNeighbor, ... 
                        running_time_peer(VARIABLE_1, VARIABLE_2), ...
                        running_time_init(VARIABLE_1, VARIABLE_2), ...
                        running_time_master(VARIABLE_1, VARIABLE_2), ...
                        running_time_dual(VARIABLE_1, VARIABLE_2), ...
                        running_time_subproblem(VARIABLE_1, VARIABLE_2), ...
                        z, ...
                        cost_distribution(VARIABLE_1, :), ...
                        eie_distribution(VARIABLE_1, :), ...
                        real_cost(VARIABLE_1, :), ...
                        iter_stop(VARIABLE_1, VARIABLE_2)]                           = obfmatrix_generator_DW( G, ...
                                                                                coordinate, ...
                                                                                prior, ...
                                                                                PATIENT, ... % user_ID(ETA, PATIENT), ... 
                                                                                (EPSILON+2)*EPSILON_SCALE, ...
                                                                                (ETA+9)/10*ETA_SCALE, ...
                                                                                LAMBDA, ...
                                                                                NR_LOC, ...
                                                                                filename); 
                        xlswrite(append('z', int2str(EPSILON), '.xlsx'), z); 
                        nr_peer = sum(peerMatrix); 
                        nr_constraints_matrix(VARIABLE_1, VARIABLE_2) = sum(nr_peer.^2);
                        nr_constraints_neighbor(VARIABLE_1, VARIABLE_2) = sum(sum(peerNeighbor).*nr_peer); 
                        peerMatrix_mean(VARIABLE_1, VARIABLE_2) = mean(sum(peerMatrix)); 
                        peerNeighbor_mean(VARIABLE_1, VARIABLE_2) = mean(sum(peerNeighbor));
                    end
                end
%             csvwrite(append('.\obfuscation_matrix\obfuscationmatrix_', int2str(ETA), '_', int2str(EPSILON), '.csv'), z); 
            end 
        % overallcost_(ETA, EPSILON) = overallcost(ETA, PATIENT); 
        end

%         overallcost(ceil((ETA-0.9)*10), EPSILON) = obfmatrix_generator_DW(G, coordinate, PATIENT, EPSILON/15, NR_LOC, ETA*20); 
    end
end



% if strcmp(target, 'building') == 1
%     save ('.\running_time_building.mat', 'running_time'); 
% end
% if strcmp(target, 'campus') == 1
%     save ('.\running_time_campus.mat', 'running_time'); 
% end
% save ('.\running_time_master.mat', 'running_time_master'); 
% save ('.\running_time_subproblem.mat', 'running_time_subproblem'); 
% a = 0; 