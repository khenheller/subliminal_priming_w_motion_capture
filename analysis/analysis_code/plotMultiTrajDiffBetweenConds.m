% Plots the average (over good subjects) diff between conditions in each point along the traj.
% subplot_p - parameters for 'subplot' command for each of the 2 subplots.
% plt_p - struct of plotting params.
% p - struct of exp params.
function [] = plotMultiTrajDiffBetweenConds(traj_names, subplot_p, plt_p, p)
    for iTraj = 1:length(traj_names)
        left_right = ["left", "right"];
        good_subs = load([p.PROC_DATA_FOLDER '/good_subs_' p.DAY '_' traj_names{1}{1} '_subs_' p.SUBS_STRING '.mat']);  good_subs = good_subs.good_subs;
        % Avg of each sub.
        reach_avg_each = load([p.PROC_DATA_FOLDER '/avg_each_' p.DAY '_' traj_names{iTraj}{1} '_subs_' p.SUBS_STRING '.mat']);  reach_avg_each = reach_avg_each.reach_avg_each;
        % Avg over all subs.
        reach_subs_avg = load([p.PROC_DATA_FOLDER '/subs_avg_' p.DAY '_' traj_names{iTraj}{1} '_subs_' p.SUBS_STRING '.mat']);  reach_subs_avg = reach_subs_avg.reach_subs_avg;

        % Unite sides to single var.
        traj_con = {reach_subs_avg.traj.con_left, reach_subs_avg.traj.con_right}; % Used only for Z values in plot.
        cond_diff = {reach_avg_each.cond_diff.left, reach_avg_each.cond_diff.right};
        % 2 plots: left, right.
        for side = 1:2
            subplot(subplot_p(side, 1), subplot_p(side, 2), subplot_p(side, 3));
            hold on;

            % Plot.
            stdshade(cond_diff{side}(:,good_subs,1)'*-1, plt_p.f_alpha, 'k', traj_con{side}(:,3), 0, 1,'ci', plt_p.alpha_size, plt_p.linewidth);
            % Plot 0 line.
            plot([0 1], [0 0], '--', 'linewidth',3, 'color',[0.15 0.15 0.15 plt_p.f_alpha]);

            xlabel('Z (m)');
            ylabel('X incon (m)');
            ylim([-0.015 0.015]);
            title(['TrajCon_x - TrajIncon_x, ' left_right(side)]);
            set(gca,'FontSize',14);
            legend(['CI, \alpha=' num2str(plt_p.alpha_size)], 'con - incon');
        end

        % Combined (left and right).
        subplot(subplot_p(3, 1), subplot_p(3, 2), subplot_p(3, 3));
        hold on;
        % Plot.
        stdshade(reach_avg_each.x_dev.diff(:,good_subs)', plt_p.f_alpha, 'k', reach_subs_avg.traj.con_right(:,3), 0, 1, 'ci', plt_p.alpha_size, plt_p.linewidth);
        % Plot 0 line.

        plot([0 1], [0 0], '--', 'linewidth',3, 'color',[0.15 0.15 0.15 plt_p.f_alpha]);
        xlabel('Z (m)');
        ylabel('X dev difference (m)');
        ylim([-0.015 0.015]);
        title('Diff between con and incon in "X Deviation from center", combined left and right');
        set(gca,'FontSize',14);
        legend(['CI, \alpha=' num2str(plt_p.alpha_size)], 'con - incon');
    end
        
end