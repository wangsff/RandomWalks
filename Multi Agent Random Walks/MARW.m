function [visited] = MARW(Adj,p,agent_number,rope_length,start_point_index,max_step)
% Run MARW on a Graph given by Adj
% Written by M.Alamgir
%
% Adj : sparse graph adjacency matrix
% p   : coordinate of vertices  
% agent_number : number of agents
% rope_length
% start_point_index : where to start random walk
% max_step : maximum number of steps we expect to run MARW. easily can be
% changed by size of the discovered cluster
%
% visited : visited(i)=1 when the i'th vertex belongs to the local cluster
%
% Reference:
% Morteza Alamgir, Ulrike von Luxburg
% Multi-agent random walks for local clustering on graphs, ICDM 2010
if (~issparse(Adj))
    Adj = sparse(Adj);
end
halt_tr = 4000;
n = length(p);
visited = sparse(zeros(n,1));
%%%%%%%initialize agents on starting point
for i=1:agent_number
    agent(i) = start_point_index;
end
%%%%%% Run simulation
step = 1;
while (step <= max_step) % length(find(visited==1))
    visited(agent) = 1;
    for i=1:halt_tr
        for j=1:agent_number
           neighbors = find(Adj(agent(j),:)==1);
           rndint = floor(rand(1)*length(neighbors))+1;
           next(j) = neighbors(rndint);
        end
        if(check_length(p(next,:),rope_length))
            agent = next;
            break
        end
    end
    if (i==halt_tr)
        fprintf('Did not move for many iterations.\n Probably the rope length is short!!\n');
        break
    end 
    step = step + 1;
end
