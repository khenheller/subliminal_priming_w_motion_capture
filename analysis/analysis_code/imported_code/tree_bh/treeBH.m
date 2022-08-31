function [G,GP] = treeBH(G,plot_flag,interactive_plot,recalculate_p,alpha_level)
% treeBH applies the method described in Bogomolov et al. to correct
% p-values in a tree-structure of experimental design

% reference: Bogomolov, M., Peterson, C. B., Benjamini, Y., & Sabatti, C. (2021).
% Hypotheses on a tree: new error rates and testing strategies. Biometrika, 108(3), 575-590.

% input/output: G is a directed graph object (created with Matlab's
% digraph). Each leaf of the tree (childless nodes) should have a p-value

% debug_interactive_plot: Plot an interactive plot of the treeBH process.
% Useful for debugging. The code advances with each mouse click.

% recalculate_p: Override existing p-values when calculating missing p-values bottom-up.
% Default is 0.

% alpha_level: Unadjusted alpha level. Default is 0.05
% ** current version does not support different alpha values for different
% levels of the tree

% Input graph Nodes:
%   Name (optional): Node name
%   p: uncorrected p-value. Can be NaN for non-leaf nodes (experiment level,
%   manuscript level, etc.)

% Output graph Nodes:
%   Name (optional): Node name
%   p: uncorrected p-value
%   corr_p: corrected p-value
%   alpha: corrected alpha level
%   reject: reject H0 (yes=1)

% GP - Graph Plot handle

%% Input check
if ~isa(G,'digraph')
    error('Incorrect input: Input should be a digraph object')
end

if ~ismember('p',G.Nodes.Properties.VariableNames)
    error('Incorrect input: Input should have p-values as node properties')
end

if nargin<5
    alpha_level = 0.05;
end
if nargin<4
    recalculate_p = 0;
end
if nargin<3
    interactive_plot = 0;
end
if nargin<2
    plot_flag = 0;
end

%% Graph setup
% rearrange node order by tree level
root_ind = find(arrayfun(@(x) isempty(G.predecessors(x)),1:G.numnodes,'UniformOutput',1));
perm = G.bfsearch(root_ind);
[~,inv_perm] = sort(perm);
G = reordernodes(G,perm);

% define parent and child relations
G.Nodes.parent(2:G.numnodes) = arrayfun(@(x) G.predecessors(x),2:G.numnodes,'UniformOutput',1);
[G.Nodes.child] = arrayfun(@(x) G.successors(x),1:G.numnodes,'UniformOutput',0)';

% define functions
Simes_p = @(p) min(length(p)*sort(p(:))'./(1:length(p)));
sister = @(node) G.Nodes.child{G.Nodes.parent(node)};
parent = @(node) G.Nodes.parent(node);
child = @(node) G.Nodes.child{node};

%% combine p-value of upper nodes using Simes's method (bottom-up)
V = sort(unique(G.Nodes.parent),'descend');
V(end)=[];
G.Nodes.corr_p = G.Nodes.p;
for par=V'
    if isnan(G.Nodes.corr_p(par))
        G.Nodes.corr_p(par) = Simes_p(G.Nodes.corr_p(child(par)));
    elseif recalculate_p
        G.Nodes.corr_p(par) = Simes_p(G.Nodes.corr_p(child(par)));
    end
end

%% apply the treeBH process (top-down)
G.Nodes.alpha = ones(G.numnodes,1)*alpha_level;
G.Nodes.reject(1) = true;

if interactive_plot
    figure('WindowStyle','docked')
    hold on
end
for node=1:G.numnodes
    % skip leaf nodes and non-significant nodes
    if isempty(child(node)) || (node>1 && ~G.Nodes.reject(parent(node)))
        continue
    end
    
    % perform BH for all the children nodes
    child_corr_p = mafdr(G.Nodes.corr_p(child(node)),'BHFDR',1);
    G.Nodes.corr_p(child(node)) = child_corr_p;
    
    % calculate q recursively (bottom-up)
    L=node;
    q=1;
    while L>1
        q = q * mean(G.Nodes.reject(sister(L)));
        L = parent(L);
    end
    
    % reject children
    G.Nodes.alpha(child(node)) = alpha_level*q;
    G.Nodes.reject(child(node)) = child_corr_p < alpha_level*q;
    
    % debug_interactive_plot (advances with mouse click)
    if interactive_plot
        colors = [G.Nodes.reject,zeros(G.numnodes,2)];
        cla
        GP_debug=G.plot('EdgeColor','k','NodeColor',colors,'NodeLabel',cellstr(num2str(G.Nodes.corr_p)));
        plot(GP_debug.XData(node),GP_debug.YData(node),'bo','MarkerSize',30)
        text(GP_debug.XData(child(node)),GP_debug.YData(child(node))+.1,arrayfun(@num2str,child_corr_p,'un',0)','color','b')
        text(GP_debug.XData(node),GP_debug.YData(node)+.1,sprintf('q=%.3f, \\alpha=%.4f',q,alpha_level*q),'Interpreter','tex','color','b')
        drawnow
        waitforbuttonpress
    end
end
if interactive_plot
    colors = [G.Nodes.reject,zeros(G.numnodes,2)];
    cla
    GP_debug=G.plot('EdgeColor','k','NodeColor',colors,'NodeLabel',cellstr(num2str(G.Nodes.corr_p)));
end

%% undo changes to graph
var_to_keep = setdiff(G.Nodes.Properties.VariableNames,{'parent','child'},'stable');
G.Nodes = G.Nodes(:,var_to_keep);
G = reordernodes(G,inv_perm);

%% plot tree
if plot_flag
    figure
    colors = [G.Nodes.reject,zeros(G.numnodes,2)];
    if ismember('name',G.Nodes.Properties.VariableNames)
        node_labels = cellfun(@(x,y) sprintf('%s_{%.3f}',x,y),G.Nodes.name,num2cell(G.Nodes.corr_p),'un',0);
        GP=G.plot('EdgeColor','k','NodeColor',colors,'NodeLabel',node_labels);
    else
        GP=G.plot('EdgeColor','k','NodeColor',colors);
    end
    set(GP,'MarkerSize',8)
    set(GP,'NodeFontSize',12)
    
    pos = get(gca,'Position');
    sz = [.1 .1];
    lgd_pos = [pos(1) pos(2)+pos(3)-sz(2) sz];
    axes('Position',lgd_pos)
    hold on
    plot(1,1,'k.','MarkerSize',20)
    plot(1,-1,'r.','MarkerSize',20)
    text(2,1,'n.s','FontSize',12)
    text(2,-1,'signif','FontSize',12)
    ylim([-5 5])
    xlim([-5 20])
    axis off
    
elseif nargout>1
        GP=[];
end
