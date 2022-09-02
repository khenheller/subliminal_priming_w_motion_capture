function [] = plotTreeBH(plt_p, p)
    % Specify tree structure.
    parents_vec = [1 1 2 2 3 4 4 4 4 4 5];
    node_names = [{'effect size comparison'},...
        {'reach','keyboard'},...
        {'exploratory','confirmatory','rt'},...
        {'react','mt','com','tot dist','auc','ra'}];
    
    % Add p-values to tree.
    keyboard_rt_p_val = load([p.PROC_DATA_FOLDER '/keyboard_rt_p_val_' p.DAY '_subs_' p.SUBS_STRING '.mat']);  keyboard_rt_p_val = keyboard_rt_p_val.p_val;
    tot_dist_p_val = load([p.PROC_DATA_FOLDER '/tot_dist_p_val_' p.DAY '_subs_' p.SUBS_STRING '.mat']);  tot_dist_p_val = tot_dist_p_val.p_val;
    auc_p_val = load([p.PROC_DATA_FOLDER '/auc_p_val_' p.DAY '_subs_' p.SUBS_STRING '.mat']);  auc_p_val = auc_p_val.p_val;
    com_p_val = load([p.PROC_DATA_FOLDER '/com_p_val_' p.DAY '_subs_' p.SUBS_STRING '.mat']);  com_p_val = com_p_val.p_val;
    ra_p_val = load([p.PROC_DATA_FOLDER '/ra_p_val_' p.DAY '_subs_' p.SUBS_STRING '.mat']);  ra_p_val = ra_p_val.p_val;
    react_mt_rt_p_val = load([p.PROC_DATA_FOLDER '/react_mt_rt_p_val_' p.DAY '_subs_' p.SUBS_STRING '.mat']);  react_mt_rt_p_val = react_mt_rt_p_val.p_val;
    react_p_val = react_mt_rt_p_val.react;
    mt_p_val = react_mt_rt_p_val.mt;
    node_p_values = [nan,...
        nan, nan,...
        nan, nan, keyboard_rt_p_val,...
        react_p_val, mt_p_val, com_p_val, tot_dist_p_val, auc_p_val, ra_p_val];
    
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