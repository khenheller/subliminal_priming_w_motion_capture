% Plots the heading angle at every point along the trajecotry for every trial of the subject.
function [] = plotHeadAngles(iSub, traj_name, plt_p, p)
    single_trials = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_sorted_trials_' traj_name '.mat']);  single_trials = single_trials.reach_single;
    subs_avg = load([p.PROC_DATA_FOLDER '/subs_avg_' p.DAY '_' traj_name '_subs_' p.SUBS_STRING '.mat']); subs_avg = subs_avg.reach_subs_avg;
    
    % combine left and right.
    head_angles_con = [single_trials.head_angle.con_left(:,:) single_trials.head_angle.con_right(:,:)];
    head_angles_incon = [single_trials.head_angle.incon_left(:,:) single_trials.head_angle.incon_right(:,:)];
    z_axis = (subs_avg.traj.con_left(:,3) + subs_avg.traj.con_right(:,3)) / 2;

    % plot.
    plot(repmat(z_axis, 1, size(head_angles_con, 2)), head_angles_con, 'Color',[plt_p.con_col plt_p.f_alpha]);
    hold on;
    plot(repmat(z_axis, 1, size(head_angles_incon, 2)), head_angles_incon, 'Color',[plt_p.incon_col plt_p.f_alpha]);

    ylabel('Head Angle (degrees)');
    xlim([0 1]);
    set(gca,'FontSize',14);
    title('Head angle');
    % Legend.
    h = [];
    h(1) = bar(NaN,NaN,'FaceColor',plt_p.con_col);
    h(2) = bar(NaN,NaN,'FaceColor',plt_p.incon_col);
    legend(h,'Con','Incon', 'Location','northwest');
end