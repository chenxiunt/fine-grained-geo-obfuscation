[a, b] = find(overallcost>0); 

c(1) = struct('id', []); 
c(2) = struct('id', []);  
c(3) = struct('id', []); 
c(4) = struct('id', []); 
c(5) = struct('id', []); 
c(6) = struct('id', []); 
c(7) = struct('id', []); 
c(8) = struct('id', []); 
for i = 1:1:size(a, 1)
    c(a(i)).id = [c(a(i)).id, b(i)]; 
end