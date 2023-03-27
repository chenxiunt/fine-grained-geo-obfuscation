function [coordinate, edge, G, NR_LOC] = read_data(region)
    [coordinate, edge, edge_weight] = read_city_data(region);
    NR_LOC = size(coordinate, 1);
    if NR_LOC == 0
        G = graph;
    else 
        G = digraph([edge(:, 1); edge(:, 2)], [edge(:, 2); edge(:, 1)], [edge_weight; edge_weight]);
    end
end