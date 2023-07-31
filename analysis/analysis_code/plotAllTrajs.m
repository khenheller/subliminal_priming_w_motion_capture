% Plots all the trajectories of a single sub and the average traj, overlaid on top of eachother.
% iSub - subject number
% subplot_p - parameters for 'subplot' command for each of the 2 subplots.
% plt_p - struct of plotting params.
% p - struct of exp params.
function [] = plotAllTrajs(iSub, traj_names, subplot_p, plt_p, p)
    p = defineParams(p, iSub);

    y_label = 'Path Traveled (%)';
    x_label = 'X (cm)';
    
    for iTraj = 1:length(traj_names)
        r_single = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_sorted_trials_' traj_names{iTraj}{1} '.mat']);  r_single = r_single.r_trial;
        r_avg = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_avg_' traj_names{iTraj}{1} '.mat']);  r_avg = r_avg.r_avg;

        % Convert to cm.
        r_single.trajs.con_left = r_single.trajs.con_left * 100;
        r_single.trajs.con_right = r_single.trajs.con_right * 100;
        r_single.trajs.incon_left = r_single.trajs.incon_left * 100;
        r_single.trajs.incon_right = r_single.trajs.incon_right * 100;
        r_avg.traj.con_left = r_avg.traj.con_left * 100;
        r_avg.traj.con_right = r_avg.traj.con_right * 100;
        r_avg.traj.incon_left = r_avg.traj.incon_left * 100;
        r_avg.traj.incon_right = r_avg.traj.incon_right * 100;

        % Plot single trial.
        subplot(subplot_p(1,1), subplot_p(1,2), [subplot_p(1,3) subplot_p(1,3)+1]);
        hold on;
        plot(r_single.trajs.con_left(:,:,1), r_single.trajs.con_left(:,:,3), 'Color',[plt_p.con_col plt_p.f_alpha]);
        plot(r_single.trajs.con_right(:,:,1), r_single.trajs.con_right(:,:,3), 'Color',[plt_p.con_col plt_p.f_alpha]);

        % Plot averages.
        plot(r_avg.traj.con_left(:,1), r_avg.traj.con_left(:,3), plt_p.con_avg_col, 'LineWidth',plt_p.avg_plot_width);
        plot(r_avg.traj.con_right(:,1), r_avg.traj.con_right(:,3), plt_p.con_avg_col, 'LineWidth',plt_p.avg_plot_width);

        set(gca, 'FontSize',plt_p.font_size);
        set(gca, 'FontName',plt_p.font_name);
        set(gca,'linewidth',plt_p.axes_line_thickness);
        xlabel(x_label);
        xlim([-12, 12]);
        ylabel(y_label);
        ylim([0, 100]);
        yticks(plt_p.percent_path_ticks);
        title(['Participant ', num2str(iSub)]);

        % Legend.
        h = [];
        h(1) = plot(nan,nan,'Color',plt_p.con_col, 'linewidth',plt_p.linewidth);
        h(2) = plot(nan,nan,'Color',plt_p.incon_col, 'linewidth',plt_p.linewidth);
        graphs = {'Congruent', 'Incongruent'};
        legend(h, graphs, 'Location','southeast');
        legend('boxoff');

        % Plot single trial.
        subplot(subplot_p(2,1), subplot_p(2,2), [subplot_p(2,3), subplot_p(2,3)+1]);
        hold on;
        plot(r_single.trajs.incon_left(:,:,1), r_single.trajs.incon_left(:,:,3), 'Color',[plt_p.incon_col plt_p.f_alpha]);
        plot(r_single.trajs.incon_right(:,:,1), r_single.trajs.incon_right(:,:,3), 'Color',[plt_p.incon_col plt_p.f_alpha]);

        % Plot averages.
        plot(r_avg.traj.incon_left(:,1), r_avg.traj.incon_left(:,3), plt_p.incon_avg_col, 'LineWidth',plt_p.avg_plot_width);
        plot(r_avg.traj.incon_right(:,1), r_avg.traj.incon_right(:,3), plt_p.incon_avg_col, 'LineWidth',plt_p.avg_plot_width);

        set(gca, 'FontSize',plt_p.font_size);
        set(gca, 'FontName',plt_p.font_name);
        set(gca,'linewidth',plt_p.axes_line_thickness);
        xlabel(x_label);
        xlim([-12, 12]);
        ylabel(y_label);
        ylim([0, 100]);
        yticks(plt_p.percent_path_ticks);
    end
end