% Plots the average MAD of each subject.
% plt_p - struct of plotting params.
% p - struct of exp params.
function [p_val] = plotMultiMad(traj_names, plt_p, p)
    for iTraj = 1:length(traj_names)
        good_subs = load([p.PROC_DATA_FOLDER '/good_subs_' p.DAY '_' traj_names{iTraj}{1} '_subs_' p.SUBS_STRING '.mat']);  good_subs = good_subs.good_subs;
        reach_avg_each = load([p.PROC_DATA_FOLDER '/avg_each_' p.DAY '_' traj_names{iTraj}{1} '_subs_' p.SUBS_STRING '.mat']);  reach_avg_each = reach_avg_each.reach_avg_each;
        hold on;

        % Load data and set parameters.
        beesdata = {reach_avg_each(iTraj).mad.con_left(good_subs), reach_avg_each(iTraj).mad.incon_left(good_subs), reach_avg_each(iTraj).mad.con_right(good_subs), reach_avg_each(iTraj).mad.incon_right(good_subs)};
        yLabel = 'MAD (meter)';
        XTickLabels = [];
        colors = {plt_p.con_col, plt_p.incon_col, plt_p.con_col, plt_p.incon_col};
        title_char = cell2mat(['Maximum Absolute Deviation ' regexp(traj_names{iTraj}{1},'_._(.+)','tokens','once') ' ' regexp(traj_names{iTraj}{1},'(.+)_.+_','tokens','once')]);
        % plot.
        printBeeswarm(beesdata, yLabel, XTickLabels, colors, plt_p.space, title_char, plt_p.errbar_type, plt_p.alpha_size);
        % Group graphs.
        ticks = get(gca,'XTick');
        labels = {["",""]; ["Left","Right"]};
        dist = [0, 0.005];
        font_size = [1, 15];
        groupTick(ticks, labels, dist, font_size)

        % Connect each sub's dots with lines.
        y_data = [beesdata{1} beesdata{3}; beesdata{2} beesdata{4}];
        x_data = reshape(get(gca,'XTick'), 2,[]);
        x_data = repelem(x_data,1,length(good_subs));
        connect_dots(x_data, y_data);

        % Legend.
        h = [];
        h(1) = bar(NaN,NaN,'FaceColor',plt_p.con_col);
        h(2) = bar(NaN,NaN,'FaceColor',plt_p.incon_col);
        h(3) = plot(NaN,NaN,'k','linewidth',14);
        legend(h,'Con','Incon',plt_p.errbar_type, 'Location','northwest');
        
        % T-test On plot
        [~, p_val_mad, ci, ~] = ttest(beesdata{1}, beesdata{2});
        text(mean(ticks(1:2)), (max([beesdata{1:2}])+0.005), ['p: ' num2str(p_val_mad)], 'HorizontalAlignment','center', 'FontSize',14);
        [~, p_val_mad, ci, ~] = ttest(beesdata{3}, beesdata{4});
        text(mean(ticks(3:4)), (max([beesdata{3:4}])+0.005), ['p: ' num2str(p_val_mad)], 'HorizontalAlignment','center', 'FontSize',14);
        % T-test and Cohen's dz
        [~, p_val, ci, stats] = ttest(reach_avg_each.mad(iTraj).con(good_subs), reach_avg_each.mad(iTraj).incon(good_subs));
        printStats('-----MAD------------', reach_avg_each.mad(iTraj).con(good_subs), ...
            reach_avg_each.mad(iTraj).incon(good_subs), ["Con","Incon"], p_val, ci, stats);
    end
end