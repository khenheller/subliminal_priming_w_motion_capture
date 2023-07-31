% Plots the maximal absolute deviating point for each trial in each condition, overlaid on top of eachother.
% iSub - subject number
% subplot_p - parameters for 'subplot' command for each of the 2 subplots.
% plt_p - struct of plotting params.
% p - struct of exp params.
function [] = plotXStd(iSub, traj_names, subplot_p, plt_p, p)
    p = defineParams(p, iSub);
    for iTraj = 1:length(traj_names)
        left_right = ["left", "right"];
        reach_avg = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_avg_' traj_names{iTraj}{1} '.mat']);  reach_avg = reach_avg.reach_avg;
        % Unite sides to single var.
        traj_con = {reach_avg.traj.con_left, reach_avg.traj.con_right};
        traj_incon = {reach_avg.traj.incon_left, reach_avg.traj.incon_right};
        x_std_con = {reach_avg.x_std.con_left, reach_avg.x_std.con_right};
        x_std_incon = {reach_avg.x_std.incon_left, reach_avg.x_std.incon_right};
        % 2 plots: left, right.
        for side = 1:2
            subplot(subplot_p(side, 1), subplot_p(side, 2), subplot_p(side, 3));
            hold on;
            % Plot STD.
            plot(traj_con{side}(:,3), x_std_con{side}, 'color',plt_p.con_col);
            plot(traj_incon{side}(:,3), x_std_incon{side}, 'color',plt_p.incon_col);
            
            ylabel('X std');
            xlim([0 100]);
            title(['STD in X Axis' left_right(side)]);
            set(gca,'FontSize',14);
            % Legend.
            h = [];
            h(1) = bar(NaN,NaN,'FaceColor',plt_p.con_col);
            h(2) = bar(NaN,NaN,'FaceColor',plt_p.incon_col);
            legend(h,'Con','Incon', 'Location','northwest');
        end 
    end
end