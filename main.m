addpath('./func'); 
addpath('./func/polytopes/'); 
addpath('./func/haversine/'); 


%% Parameters
TASK = 1;                       % Task ID
ETA = 1;                        % 2*ETA is the interval width of the peer locations
EPSILON = 3;                    % Privacy budget
LAMBDA = 1;                     % Distance threshold of Geo-Ind

% [coordinate, edge, edge_weight] = read_city_data(50); 


%% Select the target
region_idx = 10;                    % Region index

%% Select the scales of the parameters: ETA and EPSILON
ETA_SCALE = 0.03;                   
EPSILON_SCALE = 2; 

%% Load the task (user) index information 
load('.\dataset\city\task_ID.mat'); 

%% Obfuscation matrix generatoin
cost_distribution = []; 
real_cost = zeros(5, 30); 

%% Testing
% We test the performance of FineGeo with various parameters, including
% ETA, EPSILON, subregions, etc. 
for ETA = 1:1:1
    for EPSILON = 1:1:1 
        for REGION =   1:1:1
            VARIABLE_1 = ETA;       % We use to variables VARIABLE_1 and VARIABLE_2 to record the parameters we are changing
            VARIABLE_2 = REGION; 
            VARIABLE_1_str = 'eta:'; 
            VARIABLE_2_str = 'region';
            disp(append("Now, testing the case where eta is ", string(double(VARIABLE_1)), " and the region index is ", string(VARIABLE_2), "...")); 
            
            % Read the map information, including node ("coordinate") and
            % "edge" information, creating the corresponding mobility graph
            % "G". 
            % The map was retrived from OpenStreetMap: https://www.openstreetmap.org/#map=5/38.007/-95.844)
            [coordinate, edge, G, NR_LOC] = read_data(REGION);

            % We randomly deploy the tasks over the target region. The task
            % indecies were recorded in "task_ID.mat"
            for TASK = 1:1:1
                    % List of variables to record the results. We
                    % initialize those variables by -1 because in case the
                    % functions were not called, we will understand the 
                    % corresponding variables were not assigned any values. 
                    
                    overall_cost(VARIABLE_1, VARIABLE_2) = -1;               % overall cost of the obfuscation function 
                    running_time(VARIABLE_1, VARIABLE_2) = -1;              % running time of the FineGeo algorithm
                    nr_constraints_matrix(VARIABLE_1, VARIABLE_2) = -1;     % Number of constraints in the LP formulation
                    nr_constraints_neighbor(VARIABLE_1, VARIABLE_2) = -1;   % Number of peer neighbors
                    peerMatrix_mean(VARIABLE_1, VARIABLE_2) = -1;           % Average number of peers
                    peerNeighbor_mean(VARIABLE_1, VARIABLE_2) = -1;         % Avarage number of peer neighbors
                    clear cost_distribution; 
                    if NR_LOC > 0 
                                                                            %% Output list
                        [overall_cost(VARIABLE_1, VARIABLE_2), ...           % overall cost
                        peerMatrix, ...                                     % Matrix to record whether two locations are peer locations
                        peerNeighbor, ...                                   % Matrix to record whether two locations are peer neigbhors
                        running_time_init(VARIABLE_1, VARIABLE_2), ...      % Running time to initialize DW
                        running_time_master(VARIABLE_1, VARIABLE_2), ...    % Running time to run the master program
                        running_time_subproblem(VARIABLE_1, VARIABLE_2), ...% Running time to run the subproblems
                        obfuscation_matrix, ...                             % Obfuscation matrix
                        cost_distribution(VARIABLE_1, :), ...               % Cost distribution
                        iter_stop(VARIABLE_1, VARIABLE_2), ...              % Number of iterations to stop DW
                        convergence(VARIABLE_2, :)] ...                     % Convergence of DW
                        ...                                                 
                        = obfmatrix_generator_DW( ...                       %% Input list
                        G, ...                                              % Mobility graph G                    
                        coordinate, ...                                     % Coordinate of locations
                        TASK, ...                                           % Task ID
                        (EPSILON+2)*EPSILON_SCALE, ...                      % Privacy budget epsilon
                        (ETA+9)/10*ETA_SCALE, ...                           % peer location threshold eta
                        LAMBDA, ...                                         % GeoInd distance threshold
                        NR_LOC);                                            % The file to store the results
                        
                    end
            end 
        end
    end
end

save('.\results\city\overall_cost', 'overall_cost'); 
save('.\results\city\running_time', 'running_time'); 
save('.\results\city\nr_constraints_matrix', 'nr_constraints_matrix'); 
save('.\results\city\nr_constraints_neighbor', 'nr_constraints_neighbor'); 
save('.\results\city\peerMatrix_mean', 'peerMatrix_mean'); 
save('.\results\city\peerNeighbor_mean', 'peerNeighbor_mean'); 


disp("The simulation is completed.");