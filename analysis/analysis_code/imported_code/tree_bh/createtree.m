function G = createtree(node_parents,node_names,node_p_values)
%initialize a tree graph:
%inputs:
%   node_parents:  a vector of the parent of each node other than the root
%   node_names:    a label for each node
%   node_p_values: p-values for each nodes. can be NaN
%output:
%   G:             a tree object, to use in treeBH

G = digraph(node_parents,2:length(node_parents)+1);
G.Nodes.name = node_names';
G.Nodes.p = node_p_values';