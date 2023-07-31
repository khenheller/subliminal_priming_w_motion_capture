% plt_p - struct of plotting params.
% p - struct of exp params.
% p_val - p-value of the statistical test.
function [p_val] = plotMultiTotDist(traj_names, plt_p, p)
    units = '(cm)';
    % When normalized, no units.
    if p.NORMALIZE_WITHIN_SUB
        units = '';
    end
    for iTraj = 1:length(traj_names)
        good_subs = load([p.PROC_DATA_FOLDER '/good_subs_' p.DAY '_' traj_names{iTraj}{1} '_subs_' p.SUBS_STRING '.mat']);  good_subs = good_subs.good_subs;
        reach_avg_each = load([p.PROC_DATA_FOLDER '/avg_each_' p.DAY '_' traj_names{iTraj}{1} '_subs_' p.SUBS_STRING '.mat']);  reach_avg_each = reach_avg_each.reach_avg_each;
        hold on;

        % Convert to cm.
        reach_avg_each(iTraj).tot_dist.con = reach_avg_each(iTraj).tot_dist.con * 100;
        reach_avg_each(iTraj).tot_dist.incon = reach_avg_each(iTraj).tot_dist.incon * 100;
        reach_avg_each(iTraj).tot_dist.con_left = reach_avg_each(iTraj).tot_dist.con_left * 100;
        reach_avg_each(iTraj).tot_dist.con_right = reach_avg_each(iTraj).tot_dist.con_right * 100;
        reach_avg_each(iTraj).tot_dist.incon_left = reach_avg_each(iTraj).tot_dist.incon_left * 100;
        reach_avg_each(iTraj).tot_dist.incon_right = reach_avg_each(iTraj).tot_dist.incon_right * 100;

        % Load data and set parameters.
        beesdata = {reach_avg_each(iTraj).tot_dist.con(good_subs), reach_avg_each(iTraj).tot_dist.incon(good_subs)};
        yLabel = ['Distance ', units];
        XTickLabels = [];
        colors = {plt_p.con_col, plt_p.incon_col};
        title_char = 'Distance Traveled';
        % plot.
        if length(good_subs) > 200 % beeswarm doesn't look good with many subs.
            makeItRain(beesdata, colors, title_char, yLabel, plt_p);
        else
            printBeeswarm(beesdata, yLabel, XTickLabels, colors, plt_p.space, title_char, plt_p.errbar_type, plt_p.alpha_size);
            % Connect each sub's dots with lines.
            y_data = [beesdata{1}; beesdata{2}];
            x_data = reshape(get(gca,'XTick'), 2,[]);
            x_data = repelem(x_data,1,length(good_subs));
            connect_dots(x_data, y_data);
            ylim([34 46]);
            yticks(35 : 2 : 45);
        end

        set(gca, 'TickDir','out');
        xticks([]);
        set(gca, 'FontSize',plt_p.font_size);
        set(gca, 'FontName',plt_p.font_name);
        set(gca, 'linewidth',plt_p.axes_line_thickness);
        % Legend.
%         h = [];
%         h(1) = bar(NaN,NaN,'FaceColor',plt_p.con_col, 'ShowBaseLine','off');
%         h(2) = bar(NaN,NaN,'FaceColor',plt_p.incon_col, 'ShowBaseLine','off');
%         h(3) = plot(NaN,NaN,'k','linewidth',14);
%         legend(h,'Con','Incon',err_bar_type, 'Location','northwest');
        
        % T-test On plot
        [~, p_val, ~, ~] = ttest(beesdata{1}, beesdata{2});
%         text(mean(ticks(1:2)), (max([beesdata{1:2}])+0.005), ['p: ' num2str(p_val)], 'HorizontalAlignment','center', 'FontSize',14);
%         [~, p_val, ~, ~] = ttest(beesdata{3}, beesdata{4});
%         text(mean(ticks(3:4)), (max([beesdata{3:4}])+0.005), ['p: ' num2str(p_val)], 'HorizontalAlignment','center', 'FontSize',14);
        % T-test and Cohen's dz
        [~, p_val, ci, stats] = ttest(reach_avg_each.tot_dist.con(good_subs), reach_avg_each.tot_dist.incon(good_subs));
        printStats('-----Total Distance Traveled------------', reach_avg_each.tot_dist.con(good_subs), ...
            reach_avg_each.tot_dist.incon(good_subs), ["Con","Incon"], p_val, ci, stats);
    end
end