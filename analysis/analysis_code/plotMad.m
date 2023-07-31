% Plots the maximal absolute deviation for each trial, seperated to conditions.
% iSub - subject number
% plt_p - struct of plotting params.
% p - struct of exp params.
function [] = plotMad(iSub, traj_names, plt_p, p)
    p = defineParams(p, iSub);
    for iTraj = 1:length(traj_names)
        hold on;
        reach_single = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_' 'sorted_trials_' traj_names{iTraj}{1} '.mat']);  reach_single = reach_single.reach_single;
        % Load data and prep params.
        beesdata = {reach_single.mad.con_left, reach_single.mad.incon_left, reach_single.mad.con_right, reach_single.mad.incon_right};
        yLabel = 'MAD (meter)';
        XTickLabels = [];
        colors = {plt_p.con_col, plt_p.incon_col, plt_p.con_col, plt_p.incon_col};
        title_char = cell2mat(['Maximum Absolute Deviation ' regexp(traj_names{iTraj}{1},'_._(.+)','tokens','once') ' ' regexp(traj_names{iTraj}{1},'(.+)_.+_','tokens','once')]);
        % Plot.
        printBeeswarm(beesdata, yLabel, XTickLabels, colors, plt_p.space, title_char, 'ci', plt_p.alpha_size);
        % Group graphs.
        ticks = get(gca,'XTick');
        labels = {["",""]; ["Left","Right"]};
        dist = [0, 0.01];
        font_size = [1, 15];
        groupTick(ticks, labels, dist, font_size)

        % Legend.
        h = [];
        h(1) = bar(NaN,NaN,'FaceColor',plt_p.con_col);
        h(2) = bar(NaN,NaN,'FaceColor',plt_p.incon_col);
        legend(h,'Con','Incon', 'Location','northwest');
    end
end