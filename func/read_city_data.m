function [coordinate, edge, edge_weight] = read_city_data(region)
    coordinate = [];
    edge = [];
    edge_weight = []; 
    node_file= append('./dataset/city/Nodes/nodes_', int2str(region), '.csv');
    edge_file = append('./dataset/city/Edges/edges_', int2str(region), '.csv');
    nodelist = xlsread(node_file); 
    edgelist = xlsread(edge_file);
%     node_file_ = append('./dataset/city_xls/Nodes/nodes_', int2str(region), '.xlsx');
%     edge_file_ = append('./dataset/city_xls/Edges/edges_', int2str(region), '.xlsx');
%     xlswrite(node_file_, nodelist);
%     xlswrite(edge_file_, edgelist);
    if nodelist(1, 1) == -1
        return; 
    else 
        coordinate = nodelist(:, 2:3); 
        coordinate = [coordinate, zeros(size(nodelist, 1), 1)]; 
    %     plot(coordinate(:, 1), coordinate(:, 2), 'o'); 
    %     hold on; 
    
        for i = 1:1:size(edgelist, 1)
            edge_start(i, 1) = find(nodelist(:, 1) == edgelist(i, 1));
            edge_end(i, 1) = find(nodelist(:, 1) == edgelist(i, 2));
            edge_weight(i, 1) = haversine(coordinate(edge_start(i, 1), 1:2), coordinate(edge_end(i, 1), 1:2));
            % edge_weight(i, 1) = sqrt((coordinate(edge_start(i, 1), 1) - coordinate(edge_end(i, 1), 1))^2 + (coordinate(edge_start(i, 1), 2) - coordinate(edge_end(i, 1), 2))^2); 
    %         plot([coordinate(edge_start(i, 1), 1) coordinate(edge_end(i, 1), 1)], [coordinate(edge_start(i, 1), 2) coordinate(edge_end(i, 1), 2)], 'k'); 
    %         hold on; 
        end
        edge = [edge_start, edge_end]; 
    end
end