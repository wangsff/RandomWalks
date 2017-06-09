function res = check_length(points,rope_length)
% Inefficient implementation using for loops
% This part should be changed to adapt for different metrics on the graph
% e.g shortest path distace
n = length(points);
res = 1;
for i=1:n
    for j=1:n
        if(norm(points(i,:)-points(j,:))>rope_length)
            res = 0;
            return;
        end
    end
end
