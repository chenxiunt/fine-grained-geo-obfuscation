function [coordinate, edge, edge_weight] = read_campus_data()
% x coordinate [-97.1627, -97.1191]
% y coordinate [33.2059, 33.2264]
    X_START = -97.1627; 
    X_END = -97.1191; 
    Y_START = 33.2059; 
    Y_END = 33.2264; 
    SCALE = 2.6; 
    x_start = X_START+ (X_END-X_START)/SCALE;
    y_start = Y_START+ (Y_END-Y_START)/SCALE; 
    x_end = X_END - (X_END-X_START)/SCALE; 
    y_end = Y_END - (Y_END-Y_START)/SCALE; 

    nodelist1_raw = xlsread('.\dataset\campus\nodelist1.xlsx');
    nodelist2_raw = xlsread('.\dataset\campus\nodelist2.xlsx');
    edgelist_raw = xlsread('.\dataset\campus\edges.xlsx');
    
    index = 1; 
    for i = 1:1:size(nodelist1_raw, 1)
        if nodelist1_raw(i, 2) >= x_start && nodelist1_raw(i, 2) <= x_end && nodelist1_raw(i, 3) >= y_start && nodelist1_raw(i, 3) <= y_end
            node_ID1(index, 1) = nodelist1_raw(i, 1);
            x_coordinate1(index, 1) = nodelist1_raw(i, 2); 
            y_coordinate1(index, 1) = nodelist1_raw(i, 3); 
            z_coordinate1(index, 1) = nodelist1_raw(i, 4); 
            index = index + 1;
        end
    end

    index = 1; 
    for i = 1:1:size(nodelist2_raw, 1)
        if nodelist2_raw(i, 2) >= x_start && nodelist2_raw(i, 2) <= x_end && nodelist2_raw(i, 3) >= y_start && nodelist2_raw(i, 3) <= y_end
            node_ID2(index, 1) = nodelist2_raw(i, 1);
            x_coordinate2(index, 1) = nodelist2_raw(i, 2); 
            y_coordinate2(index, 1) = nodelist2_raw(i, 3); 
            z_coordinate2(index, 1) = nodelist2_raw(i, 4); 
            index = index + 1;
        end
    end

    node_ID = [node_ID1; node_ID2]; 

    index = 1;
    for i = 1:1:size(edgelist_raw, 1)
        if any(edgelist_raw(i, 1) == node_ID) && any(edgelist_raw(i, 2) == node_ID)
            edgelist(index, :) = [find(node_ID == edgelist_raw(i, 1))-1, find(node_ID == edgelist_raw(i, 2))-1]; 
            index = index + 1;
        end
    end

    edge_start = edgelist(:, 1)+1; 
    edge_end = edgelist(:, 2)+1; 
    edge = [edge_start, edge_end]; 
    
    x_coordinate = [x_coordinate1; x_coordinate2]; 
    y_coordinate = [y_coordinate1; y_coordinate2]; 
    z_coordinate = [z_coordinate1; z_coordinate2]; 
    coordinate = [x_coordinate, y_coordinate, z_coordinate]; 
    edge_weight = sqrt((x_coordinate(edge_start) - x_coordinate(edge_end)).^2 + (y_coordinate(edge_start) - y_coordinate(edge_end)).^2 + (z_coordinate(edge_start) - z_coordinate(edge_end)).^2);

%     for i = 1:1:size(edge_start, 1)
%         [edge_start(i)+1, edge_end(i)+1]
%         plot(  [x_coordinate(edge_start(i)), x_coordinate(edge_end(i))], ...
%                 [y_coordinate(edge_start(i)), y_coordinate(edge_end(i))], ... 
%                 'k'); 
%         hold on; 
%     end
%     plot(x_coordinate, y_coordinate, 'o'); 
%     hold on; 

end