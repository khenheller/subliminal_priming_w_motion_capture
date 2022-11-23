% Plots the average trajectories (over multiple subs) with a shade of CI around them.
% plt_p - struct of plotting params.
% p - struct of exp params.
function [] = plotMultiAvgTrajWithShade(traj_names, plt_p, p)

    good_subs = load([p.PROC_DATA_FOLDER '/good_subs_' p.DAY '_' traj_names{1}{1} '_subs_' p.SUBS_STRING '.mat']);  good_subs = good_subs.good_subs;
    for iTraj = 1:length(traj_names)
        hold on;
        % Load avg over all subs.
        subs_avg = load([p.PROC_DATA_FOLDER '/subs_avg_' p.DAY '_' traj_names{iTraj}{1} '_subs_' p.SUBS_STRING '.mat']);  subs_avg = subs_avg.reach_subs_avg;
        % Load avg of each sub.
        avg_each = load([p.PROC_DATA_FOLDER '/avg_each_' p.DAY '_' traj_names{iTraj}{1} '_subs_' p.SUBS_STRING '.mat']);  avg_each = avg_each.reach_avg_each;

        % Plot time instead of Z axis.
        if plt_p.x_as_func_of == "time"
            % Array with timing of each sample.
            timeseries = (1 : size(subs_avg.traj.con_left,1)) * p.SAMPLE_RATE_SEC;
            left_axis = timeseries;
            y_label = 'time';
            xlimit = [-0.003 0.003]; % For plot.
        else
            left_axis = subs_avg.traj.con_left(:,3)*100;
            assert(p.NORM_TRAJ, "Uses identical Z to all trajs, assumes trajs are normalized.")
            y_label = '% Path traveled';
            xlimit = [-1.105, 1.105];
        end

        % Plot avg with shade.
        stdshade(avg_each.traj(iTraj).con_left(:,good_subs,1)', plt_p.f_alpha*0.9, plt_p.con_col, left_axis, 0, 0, 'se', plt_p.alpha_size, plt_p.linewidth);
        stdshade(avg_each.traj(iTraj).con_right(:,good_subs,1)', plt_p.f_alpha*0.9, plt_p.con_col, left_axis, 0, 0, 'se', plt_p.alpha_size, plt_p.linewidth);
        stdshade(avg_each.traj(iTraj).incon_left(:,good_subs,1)', plt_p.f_alpha*0.9, plt_p.incon_col, left_axis, 0, 0, 'se', plt_p.alpha_size, plt_p.linewidth);
        stdshade(avg_each.traj(iTraj).incon_right(:,good_subs,1)', plt_p.f_alpha*0.9, plt_p.incon_col, left_axis, 0, 0, 'se', plt_p.alpha_size, plt_p.linewidth);
        
        % Permutation testing.
        clusters = permCluster(avg_each.traj.con(:,good_subs,1), avg_each.traj.incon(:,good_subs,1), plt_p.n_perm);

        % Plot clusters.
        points = [left_axis(clusters.start,3)'; left_axis(clusters.end,3)'];
        drawRectangle(points, 'y', xlimit, plt_p);

        set(gca, 'TickDir','out');
        xlabel('X');
        xlim(xlimit);
        xticks([]);
        ylabel(y_label);
        title('Average trajectory');
        set(gca, 'FontSize',14);
        % Legend.
        h = [];
        h(1) = plot(nan,nan,'Color',plt_p.con_col, 'linewidth',plt_p.linewidth);
        h(2) = plot(nan,nan,'Color',plt_p.incon_col, 'linewidth',plt_p.linewidth);
        graphs = {'Congruent', 'Incongruent'};
%         if ~isempty(clusters)
%             h(3) = plot(nan,nan,'Color',[1, 1, 1, plt_p.f_alpha/2], 'linewidth',plt_p.linewidth);
%             graphs{3} = 'Significant';
%         end
        legend(h, graphs, 'Location','southeast');
        legend('boxoff');

        % Print stats to terminal.
        printTsStats('----Deviation From center--------', clusters);
    end
end