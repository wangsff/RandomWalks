% A sample test for running MARW on a graph with nodes sampled from a
% mixture of gaussian
% Written by M.Alamgir
%
% Reference:
% Morteza Alamgir, Ulrike von Luxburg
% Multi-agent random walks for local clustering on graphs, ICDM 2010
clear all
clc

load Adjacency.mat
load points.mat

Adj = sparse(Adj);
agent_number = 3;
max_step = 400;
start_point_index = 22;
rope_length = 0.8;
p = [p1;p2];

visited = MARW(Adj,p,agent_number,rope_length,start_point_index,max_step);

cl = find(visited==1);
gplot(Adj,p);
hold on;
plot(p(cl,1),p(cl,2),'or','Linewidth',3)
plot(p(start_point_index,1),p(start_point_index,2),'ok','Linewidth',3)
