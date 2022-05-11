% Plots the average (over good subjects) STD in the X axis on each point along the taj.
% Seperates to conditions and sides.
% subplot_p - parameters for 'subplot' command for each of the 2 subplots.
% plt_p - struct of plotting params.
% p - struct of exp params.
function [] = plotMultiXStd(traj_names, subplot_p, plt_p, p)
    for iTraj = 1:length(traj_names)
        left_right = ["left", "right"];
        good_subs = load([p.PROC_DATA_FOLDER '/good_subs_' p.DAY '_' traj_names{iTraj}{1} '_subs_' p.SUBS_STRING '.mat']);  good_subs = good_subs.good_subs;
        % Avg over all subs.
        reach_avg_each = load([p.PROC_DATA_FOLDER '/avg_each_' p.DAY '_' traj_names{iTraj}{1} '_subs_' p.SUBS_STRING '.mat']);  reach_avg_each = reach_avg_each.reach_avg_each;
        % Avg of each sub.
        reach_subs_avg = load([p.PROC_DATA_FOLDER '/subs_avg_' p.DAY '_' traj_names{iTraj}{1} '_subs_' p.SUBS_STRING '.mat']);  reach_subs_avg = reach_subs_avg.reach_subs_avg;

        % Unite sides to single var.
        traj_con = {reach_subs_avg.traj.con_left, reach_subs_avg.traj.con_right};
        traj_incon = {reach_subs_avg.traj.incon_left, reach_subs_avg.traj.incon_right};
        x_std_con = {reach_subs_avg.x_std.con_left, reach_subs_avg.x_std.con_right};
        x_std_incon = {reach_subs_avg.x_std.incon_left, reach_subs_avg.x_std.incon_right};
        % 2 plots: left, right.
        for side = 1:2
            subplot(subplot_p(side, 1), subplot_p(side, 2), subplot_p(side, 3));
            hold on;
            plot(traj_con{side}(:,3), x_std_con{side}, 'color',plt_p.con_col);
            plot(traj_incon{side}(:,3), x_std_incon{side}, 'color',plt_p.incon_col);

            ylabel('X STD');
            set(gca,'FontSize',14);
            title(['STD in X Axis' left_right(side)]);
            % Legend.
            h = [];
            h(1) = bar(NaN,NaN,'FaceColor',plt_p.con_col);
            h(2) = bar(NaN,NaN,'FaceColor',plt_p.incon_col);
            legend(h,'Con','Incon', 'Location','northwest');
        end
        
        % Combined (left and right).
        subplot(subplot_p(3, 1), subplot_p(3, 2), subplot_p(3, 3));
        hold on;
        % Plot.
        stdshade(reach_avg_each.x_std.diff(:,good_subs)', plt_p.f_alpha, 'k', reach_subs_avg.traj.con_right(:,3), 0, 1, 'ci', plt_p.alpha_size, plt_p.linewidth);
        plot([0 100], [0 0], '--', 'linewidth',3, 'color',[0.15 0.15 0.15 plt_p.f_alpha]); % Zero line.

        xlabel('Proportion of Z');
        ylabel('X STD difference');
        ylim([-0.005 0.02]);
        title('Diff between con and incon in "X STD", combined left and right');
        set(gca,'FontSize',14);
        legend(['CI, \alpha=' num2str(plt_p.alpha_size)], 'con - incon');
    end
end