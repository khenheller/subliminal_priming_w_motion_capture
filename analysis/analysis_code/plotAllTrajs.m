% Plots all the trajectories of a single sub and the average traj, overlaid on top of eachother.
% iSub - subject number
% plt_p - struct of plotting params.
% p - struct of exp params.
function [] = plotAllTrajs(iSub, traj_names, plt_p, p)
    for iTraj = 1:length(traj_names)
        reach_single = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_sorted_trials_' traj_names{iTraj}{1} '.mat']);  reach_single = reach_single.reach_single;
        reach_avg = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_avg_' traj_names{iTraj}{1} '.mat']);  reach_avg = reach_avg.reach_avg;
        % Flips traj to screen since its Z values are negative.
        hold on;

        % Plot single trial.
        plot(reach_single.trajs.con_left(:,:,1), reach_single.trajs.con_left(:,:,3), 'Color',[plt_p.con_col plt_p.f_alpha]);
        plot(reach_single.trajs.con_right(:,:,1), reach_single.trajs.con_right(:,:,3), 'Color',[plt_p.con_col plt_p.f_alpha]);
        plot(reach_single.trajs.incon_left(:,:,1), reach_single.trajs.incon_left(:,:,3), 'Color',[plt_p.incon_col plt_p.f_alpha]);
        plot(reach_single.trajs.incon_right(:,:,1), reach_single.trajs.incon_right(:,:,3), 'Color',[plt_p.incon_col plt_p.f_alpha]);

        % Plot averages.
        plot(reach_avg.traj.con_left(:,1), reach_avg.traj.con_left(:,3), plt_p.con_avg_col, 'LineWidth',plt_p.avg_plot_width);
        plot(reach_avg.traj.con_right(:,1), reach_avg.traj.con_right(:,3), plt_p.con_avg_col, 'LineWidth',plt_p.avg_plot_width);
        plot(reach_avg.traj.incon_left(:,1), reach_avg.traj.incon_left(:,3), plt_p.incon_avg_col, 'LineWidth',plt_p.avg_plot_width);
        plot(reach_avg.traj.incon_right(:,1), reach_avg.traj.incon_right(:,3), plt_p.incon_avg_col, 'LineWidth',plt_p.avg_plot_width);

        xlabel('X'); xlim([-0.12, 0.12]);
        ylabel('Z Axis (to screen)');
        ylim([0, 100]);
        ylabel('Y');
        title(cell2mat(['Reach ' regexp(traj_names{iTraj}{1},'_._(.+)','tokens','once') ' ' regexp(traj_names{iTraj}{1},'(.+)_.+_','tokens','once')]));
        % Legend.
        h = [];
        h(1) = plot(nan,nan,'Color',plt_p.con_col);
        h(2) = plot(nan,nan,'Color',plt_p.incon_col);
        h(3) = plot(nan,nan,plt_p.con_avg_col);
        h(4) = plot(nan,nan,plt_p.incon_avg_col);
        legend(h, 'Con', 'Incon', 'Con avg', 'Incon avg', 'Location','southeast');
        set(gca, 'FontSize',14);
    end
end