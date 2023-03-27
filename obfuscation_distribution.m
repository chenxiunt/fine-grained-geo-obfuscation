addpath('./func'); 

%% Parameters
PATIENT = 50;                    
REAL_IDX = 70; 
ETA = 1;                        % 2*ETA is the interval width of the peer locations
EPSILON = 3;


%% Select the target
target = 'building'; 
% target = 'campus'; 

if strcmp(target, 'building') == 1
   ETA_SCALE = 10;
   EPSILON_SCALE = 1/15; 
end
if strcmp(target, 'campus') == 1
   ETA_SCALE = 1/2000;
   EPSILON_SCALE = 400; 
end

% Read data, including coordinates, edges, graph tree and 
[coordinate, edge, G, NR_LOC] = read_data(target);


% load('./results/z.mat')
% load('./results/z_20.mat')
load('./results/z_zeta10.mat')
obfuscated_idx = find(z(:, REAL_IDX) > 0); 


    
for i = 1:1:size(edge, 1)
    plot3(  [coordinate(edge(i, 1), 1), coordinate(edge(i, 2), 1)], ...
            [coordinate(edge(i, 1), 2), coordinate(edge(i, 2), 2)], ... 
            [coordinate(edge(i, 1), 3), coordinate(edge(i, 2), 3)], ... 
            'k'); 
    hold on; 
end


scatter3(coordinate(obfuscated_idx, 1), coordinate(obfuscated_idx, 2), coordinate(obfuscated_idx, 3), ones(size(obfuscated_idx))*60, log(z(obfuscated_idx, REAL_IDX)*1000), 'filled'); 
hold on; 

plot3(coordinate(REAL_IDX, 1), coordinate(REAL_IDX, 2), coordinate(REAL_IDX, 3), '*'); 
hold on; 

plot3(coordinate(PATIENT, 1), coordinate(PATIENT, 2), coordinate(PATIENT, 3), '*'); 
hold on; 
