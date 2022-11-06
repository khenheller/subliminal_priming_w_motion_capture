% Plots the average heading angle (over subs) at each point along the trajectory.
% plt_p - struct of plotting params.
% p - struct of exp params.
function [] = plotMultiHeadAngle(traj_names, plt_p, p)

    good_subs = load([p.PROC_DATA_FOLDER '/good_subs_' p.DAY '_' traj_names{1}{1} '_subs_' p.SUBS_STRING '.mat']);  good_subs = good_subs.good_subs;
    for iTraj = 1:length(traj_names)
        hold on;
        % Load avg of each sub.
        avg_each = load([p.PROC_DATA_FOLDER '/avg_each_' p.DAY '_' traj_names{iTraj}{1} '_subs_' p.SUBS_STRING '.mat']);  avg_each = avg_each.reach_avg_each;
        avg_con_traj = mean(squeeze(avg_each.traj(iTraj).con(:,good_subs, 3)), 2);
        avg_incon_traj = mean(squeeze(avg_each.traj(iTraj).incon(:,good_subs, 3)), 2);

        % Plot avg with shade.
        stdshade(avg_each.head_angle(iTraj).con(:,good_subs)', plt_p.f_alpha*0.3, plt_p.con_col, avg_con_traj, 0, 1, 'se', plt_p.alpha_size, plt_p.linewidth);
        stdshade(avg_each.head_angle(iTraj).incon(:,good_subs)', plt_p.f_alpha*0.3, plt_p.incon_col, avg_incon_traj, 0, 1, 'se', plt_p.alpha_size, plt_p.linewidth);
        % Plot 0 line.
        plot([0 1], [0 0], '--', 'linewidth',3, 'color',[0.15 0.15 0.15 plt_p.f_alpha]);
        
        % Permutation testing.
        clusters = permCluster(avg_each.head_angle.con(:,good_subs), avg_each.head_angle.incon(:,good_subs), plt_p.n_perm);

        % Plot clusters.
        points = [avg_con_traj(clusters.start)'; avg_con_traj(clusters.end)'];
        drawRectangle(points, 'x', [-3 5], plt_p); % 10000 is just a big enough number.

        set(gca, 'TickDir','out');
        xlabel('% Path traveled');
        xlim([min(avg_con_traj) max(avg_con_traj)]);
        ylabel('Angle (degrees)');
        title('Heading angle');
        set(gca, 'FontSize',14);
        % Legend.
        h = [];
        h(1) = plot(nan,nan,'Color',plt_p.con_col, 'linewidth',plt_p.linewidth);
        h(2) = plot(nan,nan,'Color',plt_p.incon_col, 'linewidth',plt_p.linewidth);
        h(3) = plot(nan,nan,'Color',[1, 1, 1, plt_p.f_alpha/2], 'linewidth',plt_p.linewidth);
        legend(h, 'Congruent', 'Incongruent', 'Significant', 'Location','southeast');

        % Prints stats to terminal.
        printTsStats('----Heading angle--------', clusters); % Why t* is NaN???????
    end
end