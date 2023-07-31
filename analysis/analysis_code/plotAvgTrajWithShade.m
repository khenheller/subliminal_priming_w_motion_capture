% Plots the average trajectories of a single sub with a shade of CI around them.
% iSub - subject number
% plt_p - struct of plotting params.
% p - struct of exp params.
function [] = plotAvgTrajWithShade(iSub, traj_names, plt_p, p)
    p = defineParams(p, iSub);
    for iTraj = 1:length(traj_names)
        reach_single = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_sorted_trials_' traj_names{iTraj}{1} '.mat']);  reach_single = reach_single.reach_single;
        reach_avg = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_avg_' traj_names{iTraj}{1} '.mat']);  reach_avg = reach_avg.reach_avg;
        hold on;

        % Plot.
        stdshade(reach_single.trajs.con_left(:,:,1)', plt_p.f_alpha, plt_p.con_col, reach_avg.traj.con_left(:,3), 0, 0, 'ci', plt_p.alpha_size, plt_p.linewidth);
        stdshade(reach_single.trajs.con_right(:,:,1)', plt_p.f_alpha, plt_p.con_col, reach_avg.traj.con_right(:,3), 0, 0, 'ci', plt_p.alpha_size, plt_p.linewidth);
        stdshade(reach_single.trajs.incon_left(:,:,1)', plt_p.f_alpha, plt_p.incon_col, reach_avg.traj.incon_left(:,3), 0, 0, 'ci', plt_p.alpha_size, plt_p.linewidth);
        stdshade(reach_single.trajs.incon_right(:,:,1)', plt_p.f_alpha, plt_p.incon_col, reach_avg.traj.incon_right(:,3), 0, 0, 'ci', plt_p.alpha_size, plt_p.linewidth);

        xlabel('X');
        xlim([-0.12, 0.12]);
        ylabel('Z Axis (to screen)');
        title(cell2mat(['Reach ' regexp(traj_names{iTraj}{1},'_._(.+)','tokens','once') ' ' regexp(traj_names{iTraj}{1},'(.+)_.+_','tokens','once')]));
        % Legend.
        h = [];
        h(1) = plot(nan,nan,'Color',plt_p.con_col);
        h(2) = plot(nan,nan,'Color',plt_p.incon_col);
        legend(h, 'Con', 'Incon', 'Location','southeast');
        set(gca, 'FontSize',14);
    end
end