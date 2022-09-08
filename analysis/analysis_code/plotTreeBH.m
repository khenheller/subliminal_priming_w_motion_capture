function [] = plotTreeBH(plt_p, p)

    switch p.EXP
        case 'exp1'
            % Specify tree structure.
            parents_vec = [1 1 1 1 1];
            node_names = [{'reach'},...
                {'react','mt','com','tot dist','ra'}];
            % Add p-values to tree.
            react_p_val = load([p.PROC_DATA_FOLDER '/react_p_val_' p.DAY '_' p.EXP '.mat']);  react_p_val = react_p_val.p_val;
            mt_p_val = load([p.PROC_DATA_FOLDER '/mt_p_val_' p.DAY '_' p.EXP '.mat']);  mt_p_val = mt_p_val.p_val;
            com_p_val = load([p.PROC_DATA_FOLDER '/com_p_val_' p.DAY '_' p.EXP '.mat']);  com_p_val = com_p_val.p_val;
            tot_dist_p_val = load([p.PROC_DATA_FOLDER '/tot_dist_p_val_' p.DAY '_' p.EXP '.mat']);  tot_dist_p_val = tot_dist_p_val.p_val;
            ra_p_val = load([p.PROC_DATA_FOLDER '/ra_p_val_' p.DAY '_' p.EXP '.mat']);  ra_p_val = ra_p_val.p_val;
            node_p_values = [nan,...
                react_p_val, mt_p_val, com_p_val, tot_dist_p_val, ra_p_val];
        case {'exp2', 'exp3'}
            % Specify tree structure.
            parents_vec = [1 1 2 2 2 2 3];
            node_names = [{'reach'},...
                {'exploratory','confirmatory'},...
                {'react','mt','com','tot dist','ra'}];
            % Add p-values to tree.
            react_p_val = load([p.PROC_DATA_FOLDER '/react_p_val_' p.DAY '_' p.EXP '.mat']);  react_p_val = react_p_val.p_val;
            mt_p_val = load([p.PROC_DATA_FOLDER '/mt_p_val_' p.DAY '_' p.EXP '.mat']);  mt_p_val = mt_p_val.p_val;
            com_p_val = load([p.PROC_DATA_FOLDER '/com_p_val_' p.DAY '_' p.EXP '.mat']);  com_p_val = com_p_val.p_val;
            tot_dist_p_val = load([p.PROC_DATA_FOLDER '/tot_dist_p_val_' p.DAY '_' p.EXP '.mat']);  tot_dist_p_val = tot_dist_p_val.p_val;
            ra_p_val = load([p.PROC_DATA_FOLDER '/ra_p_val_' p.DAY '_' p.EXP '.mat']);  ra_p_val = ra_p_val.p_val;
            node_p_values = [nan,...
                nan, nan,...
                react_p_val, mt_p_val, com_p_val, tot_dist_p_val, ra_p_val];
        case {'exp4', 'exp4_1'}
            % Specify tree structure.
            parents_vec = [1 1 2 2 3 4 4 4 4 5];
            node_names = [{'effect size comparison'},...
                {'reach','keyboard'},...
                {'exploratory','confirmatory','rt'},...
                {'react','mt','com','tot dist','ra'}];
            % Add p-values to tree.
            keyboard_rt_p_val = load([p.PROC_DATA_FOLDER '/keyboard_rt_p_val_' p.DAY '_' p.EXP '.mat']);  keyboard_rt_p_val = keyboard_rt_p_val.p_val;
            react_p_val = load([p.PROC_DATA_FOLDER '/react_p_val_' p.DAY '_' p.EXP '.mat']);  react_p_val = react_p_val.p_val;
            mt_p_val = load([p.PROC_DATA_FOLDER '/mt_p_val_' p.DAY '_' p.EXP '.mat']);  mt_p_val = mt_p_val.p_val;
            com_p_val = load([p.PROC_DATA_FOLDER '/com_p_val_' p.DAY '_' p.EXP '.mat']);  com_p_val = com_p_val.p_val;
            tot_dist_p_val = load([p.PROC_DATA_FOLDER '/tot_dist_p_val_' p.DAY '_' p.EXP '.mat']);  tot_dist_p_val = tot_dist_p_val.p_val;
            ra_p_val = load([p.PROC_DATA_FOLDER '/ra_p_val_' p.DAY '_' p.EXP '.mat']);  ra_p_val = ra_p_val.p_val;
            node_p_values = [nan,...
                nan, nan,...
                nan, nan, keyboard_rt_p_val,...
                react_p_val, mt_p_val, com_p_val, tot_dist_p_val, ra_p_val];
        otherwise
            error(['No experiment with name ' p.EXP ' exists.']);
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