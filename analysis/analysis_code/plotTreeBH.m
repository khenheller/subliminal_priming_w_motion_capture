function [] = plotTreeBH(plt_p, p)
    % Specify tree structure.
    parents_vec = [1 1 2 2 3 4 4 4 4 4 5];
    node_names = [{'effect size comparison'},...
        {'reach','keyboard'},...
        {'exploratory','confirmatory','rt'},...
        {'react','mt','com','tot dist','auc','ra'}];
    
    % Add p-values to tree.
    if isequal(p.EXP, 'exp_4') || isequal(p.EXP, 'exp4_1')
        keyboard_rt_p_val = load([p.PROC_DATA_FOLDER '/keyboard_rt_p_val_' p.DAY '_' p.EXP '.mat']);  keyboard_rt_p_val = keyboard_rt_p_val.p_val;
    else
        keyboard_rt_p_val = NaN;
    end
    tot_dist_p_val = load([p.PROC_DATA_FOLDER '/tot_dist_p_val_' p.DAY '_' p.EXP '.mat']);  tot_dist_p_val = tot_dist_p_val.p_val;
    auc_p_val = load([p.PROC_DATA_FOLDER '/auc_p_val_' p.DAY '_' p.EXP '.mat']);  auc_p_val = auc_p_val.p_val;
    com_p_val = load([p.PROC_DATA_FOLDER '/com_p_val_' p.DAY '_' p.EXP '.mat']);  com_p_val = com_p_val.p_val;
    ra_p_val = load([p.PROC_DATA_FOLDER '/ra_p_val_' p.DAY '_' p.EXP '.mat']);  ra_p_val = ra_p_val.p_val;
    react_p_val = load([p.PROC_DATA_FOLDER '/react_p_val_' p.DAY '_' p.EXP '.mat']);  react_p_val = react_p_val.p_val;
    mt_p_val = load([p.PROC_DATA_FOLDER '/mt_p_val_' p.DAY '_' p.EXP '.mat']);  mt_p_val = mt_p_val.p_val;
    node_p_values = [nan,...
        nan, nan,...
        nan, nan, keyboard_rt_p_val,...
        react_p_val, mt_p_val, com_p_val, tot_dist_p_val, auc_p_val, ra_p_val];
    
    % Remove keyboard in exp 1,2,3.
    if ~isequal(p.EXP, 'exp4_1')
        parents_vec([2, 5]) = [];
        node_p_values([3, 6]) = [];
        node_names([3, 6])= [];
    end

    % Create a a tree.
    g = createtree(parents_vec, node_names, node_p_values);
    
    % Run Tree-BH.
    plot_tree = 1; % plot it or not it.
    interactive_plot = 0;
    recalculate_p = 0;
    [g_output, g_plot_handle] = treeBH(g, plot_tree, interactive_plot, recalculate_p, plt_p.alpha_size);

    % Print results to terminal.
    disp('@@@@--------Tree-BH Correction--------@@@@')
    g_output.Nodes.name = string(g_output.Nodes.name);
    disp(g_output.Nodes(:, {'name','p','corr_p'}));

end