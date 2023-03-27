%% Graph generation
nodelist1 = xlsread('.\dataset\nodelist1.xlsx');
nodelist2 = xlsread('.\dataset\nodelist2.xlsx');
edgelist = xlsread('.\dataset\edges.xlsx');

x_coordinate1 = nodelist1(:, 2); 
y_coordinate1 = nodelist1(:, 3); 
z_coordinate1 = nodelist1(:, 4); 

x_coordinate2 = nodelist2(:, 2); 
y_coordinate2 = nodelist2(:, 3); 
z_coordinate2 = nodelist2(:, 4); 

edge_start = edgelist(:, 1)+1; 
edge_end = edgelist(:, 2)+1; 

x_coordinate = [x_coordinate1; x_coordinate2]; 
y_coordinate = [y_coordinate1; y_coordinate2]; 
z_coordinate = [z_coordinate1; z_coordinate2]; 


% plot3(x_coordinate1, y_coordinate1, z_coordinate1, 'o'); 
% hold on; 
% plot3(x_coordinate2, y_coordinate2, z_coordinate2, 'o'); 
% hold on; 

% for i = 1:1:size(edge_start, 1)
%     [edge_start(i)+1, edge_end(i)+1]
%     plot3(  [x_coordinate(edge_start(i)), x_coordinate(edge_end(i))], ...
%             [y_coordinate(edge_start(i)), y_coordinate(edge_end(i))], ... 
%             [z_coordinate(edge_start(i)), z_coordinate(edge_end(i))], ... 
%             'k'); 
%     hold on; 
% end

G = graph(edge_start, edge_end);

[TR, D] = shortestpathtree(G, 1);

% plot(TR)
