function G = mergetrees(G1,G2,root_name)
%merge two tree graphs:
%inputs:
%   G1,G2:      tree objects (created with createtree)
%   root_name:  a label for the root node
%output:
%   G:             a tree object, to use in treeBH
%
% mergetrees treat the root nodes of both input trees as sister nodes in
% the output tree

if ~all(ismember(G1.Nodes.Properties.VariableNames,G2.Nodes.Properties.VariableNames))
    error('Tree graphs should have the same node properties')
end
n1 = G1.numnodes;
n2 = G2.numnodes;
e2 = G2.Edges.EndNodes + n1;
G = addnode(G1,G2.Nodes);
G = addedge(G,e2(:,1),e2(:,2));
G = addedge(G,repmat(n1+n2+1,2,1),[1;n1+1]);
G = reordernodes(G,circshift(1:G.numnodes,1));
if ismember('p',G.Nodes.Properties.VariableNames)
    G.Nodes.p(1) = nan;
end
if nargin>2 && ~isempty(root_name) && ismember('name',G.Nodes.Properties.VariableNames)
    G.Nodes.name{1} = root_name;
end