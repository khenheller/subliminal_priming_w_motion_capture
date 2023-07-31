% Plots the maximal absolute deviating point for each trial in each condition, overlaid on top of eachother.
% iSub - subject number
% subplot_p - parameters for 'subplot' command for each of the 2 subplots.
% plt_p - struct of plotting params.
% p - struct of exp params.
function [] = plotMadPoint(iSub, traj_names, subplot_p, plt_p, p)
    p = defineParams(p, iSub);
    for iTraj = 1:length(traj_names)
        reach_single = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_' 'sorted_trials_' traj_names{iTraj}{1} '.mat']);  reach_single = reach_single.reach_single;
        % Unite sides to single var.
        traj_con = {reach_single.trajs.con_left, reach_single.trajs.con_right};
        traj_incon = {reach_single.trajs.incon_left, reach_single.trajs.incon_right};
        mad_p_con = {reach_single.mad_p.con_left, reach_single.mad_p.con_right};
        mad_p_incon = {reach_single.mad_p.incon_left, reach_single.mad_p.incon_right};
        % 2 plots: left, right.
        for side = 1:2
            subplot(subplot_p(side, 1), subplot_p(side, 2), subplot_p(side, 3));
            hold on;
            % Plot all trajs.
            plot(traj_con{side}(:,:,1), traj_con{side}(:,:,3), 'Color',[plt_p.con_col plt_p.f_alpha]);
            plot(traj_incon{side}(:,:,1), traj_incon{side}(:,:,3), 'Color',[plt_p.incon_col plt_p.f_alpha]);
            % Plot MAD points.
            plot(mad_p_con{side}(:,1), mad_p_con{side}(:,3), 'o','color',plt_p.con_col);
            plot(mad_p_incon{side}(:,1), mad_p_incon{side}(:,3), 'o','color',plt_p.incon_col);
            % Plot targets.
            target_pos = p.DIST_BETWEEN_TARGETS/2;
            plot([-target_pos target_pos], [p.SCREEN_DIST p.SCREEN_DIST], 'bo', 'linewidth',6);
            
            xlim([-0.11 0.11]);
            xlabel('X');
            xlim([-0.12, 0.12]);
            ylabel('Z Axis (to screen)');
            ylim([0, 1]);
            title('Maximally deviating point');
            set(gca, 'FontSize',14);
            % Legend.
            h = [];
            h(1) = bar(NaN,NaN,'FaceColor',plt_p.con_col);
            h(2) = bar(NaN,NaN,'FaceColor',plt_p.incon_col);
            h(3) = plot(NaN,NaN,'ko');
            h(4) = plot(NaN,NaN,'bo','linewidth',6);
            legend(h, 'Con', 'Incon', 'MAD','Target', 'Location','southeast');
        end
    end
end