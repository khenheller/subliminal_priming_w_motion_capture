% Plots the average trajectories (over multiple subs) with a shade of CI around them.
% plt_p - struct of plotting params.
% p - struct of exp params.
function [] = plotMultiAvgTrajWithShade(traj_names, plt_p, p)
    good_subs = load([p.PROC_DATA_FOLDER '/good_subs_' p.DAY '_' traj_names{1}{1} '_subs_' p.SUBS_STRING '.mat']);  good_subs = good_subs.good_subs;
    for iTraj = 1:length(traj_names)
        hold on;
        % Load avg over all subs.
        reach_subs_avg = load([p.PROC_DATA_FOLDER '/subs_avg_' p.DAY '_' traj_names{iTraj}{1} '_subs_' p.SUBS_STRING '.mat']);  reach_subs_avg = reach_subs_avg.reach_subs_avg;
        % Load avg of each sub.
        reach_avg_each = load([p.PROC_DATA_FOLDER '/avg_each_' p.DAY '_' traj_names{iTraj}{1} '_subs_' p.SUBS_STRING '.mat']);  reach_avg_each = reach_avg_each.reach_avg_each;

        % Plot avg with shade.
        stdshade(reach_avg_each.traj(iTraj).con_left(:,good_subs,1)', plt_p.f_alpha*0.3, plt_p.con_col, reach_subs_avg.traj.con_left(:,3), 0, 0, 'ci', plt_p.alpha_size, plt_p.linewidth);
        stdshade(reach_avg_each.traj(iTraj).con_right(:,good_subs,1)', plt_p.f_alpha*0.3, plt_p.con_col, reach_subs_avg.traj.con_right(:,3), 0, 0, 'ci', plt_p.alpha_size, plt_p.linewidth);
        stdshade(reach_avg_each.traj(iTraj).incon_left(:,good_subs,1)', plt_p.f_alpha*0.3, plt_p.incon_col, reach_subs_avg.traj.incon_left(:,3), 0, 0, 'ci', plt_p.alpha_size, plt_p.linewidth);
        stdshade(reach_avg_each.traj(iTraj).incon_right(:,good_subs,1)', plt_p.f_alpha*0.3, plt_p.incon_col, reach_subs_avg.traj.incon_right(:,3), 0, 0, 'ci', plt_p.alpha_size, plt_p.linewidth);
        
        xlabel('X');
        xlim([-0.105, 0.105]);
        ylabel('% path traveled');
        title(cell2mat(['Reach ' regexp(traj_names{iTraj}{1},'_._(.+)','tokens','once') ' ' regexp(traj_names{iTraj}{1},'(.+)_.+_','tokens','once')]));
        set(gca, 'FontSize',14);
        % Legend.
        h = [];
        h(1) = plot(nan,nan,'Color',plt_p.con_col, 'linewidth',plt_p.linewidth);
        h(2) = plot(nan,nan,'Color',plt_p.incon_col, 'linewidth',plt_p.linewidth);
        legend(h, 'Congruent', 'Incongruent', 'Location','southeast');
    end
end