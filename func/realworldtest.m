load('.\intermediate\costMatrix.mat'); 

for i = 1:1:5
    filename = append('.\intermediate\real_campus_epsilon\result_', int2str(i), '.csv'); 
%     filename = append('.\intermediate\real_campus_eta\result_', int2str(i), '.csv'); 
    report = xlsread(filename); 
    error(i) = 0; 
    for j = 1:1:size(report, 1)
        error(i, j) = costMatrix(report(j, 1), report(j, 2)); 
    end
end

a = 0; 