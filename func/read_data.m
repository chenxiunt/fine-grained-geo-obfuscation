function [coordinate, edge, G, NR_LOC] = read_data(target,  region)


%% Building
if strcmp(target, 'building')
   [coordinate, edge, edge_weight] = read_building_data();
end

%% Campus 
if strcmp(target, 'campus')
    [coordinate, edge, edge_weight] = read_campus_data();
end 

%% City 
if strcmp(target, 'city')
    [coordinate, edge, edge_weight] = read_city_data(region);
end 
    NR_LOC = size(coordinate, 1);
    if NR_LOC == 0
        G = graph;
    else 
        G = digraph([edge(:, 1); edge(:, 2)], [edge(:, 2); edge(:, 1)], [edge_weight; edge_weight]);
    end
end