% Plots the average (over good subjects) Reaction, movment and Response times.
% subplot_p - parameters for 'subplot' command for each of the 2 subplots.
% plt_p - struct of plotting params.
% p - struct of exp params.
% p_vals - p-value of the statistical tests.
function [p_vals] = plotMultiReactMtRt(traj_names, subplot_p, plt_p, p)
    units = '(ms)';
    % When normalized, no units.
    if p.NORMALIZE_WITHIN_SUB
        units = '';
    end
    good_subs = load([p.PROC_DATA_FOLDER '/good_subs_' p.DAY '_' traj_names{1}{1} '_subs_' p.SUBS_STRING '.mat']);  good_subs = good_subs.good_subs;

    disp('------------Reaching RTs------------');

    for iTraj = 1:length(traj_names)
        reach_avg_each = load([p.PROC_DATA_FOLDER '/avg_each_' p.DAY '_' traj_names{iTraj}{1} '_subs_' p.SUBS_STRING '.mat']);  reach_avg_each = reach_avg_each.reach_avg_each;
        vars = ["react", "mt"];
        titles = ["Reaching Onset", "Reaching Duration"];
        
        for j = 1:length(vars)
            data = reach_avg_each.(vars(j));
            subplot(subplot_p(j,1), subplot_p(j,2), subplot_p(j,3));
            hold on;
            % Load data and prep params.
            beesdata = {data.con(good_subs),  data.incon(good_subs)};
            yLabel = ['Time ', units];
            XTickLabel = ["Congruent", "Incongruent"];
            colors = {plt_p.con_col, plt_p.incon_col};
            title_char = titles(j);
            % Plot.
            if length(good_subs) > 200 % beeswarm doesn't look good with many subs.
                makeItRain(beesdata, colors, title_char, yLabel, plt_p);
            else
                printBeeswarm(beesdata, yLabel, XTickLabel, colors, plt_p.space, title_char, plt_p.errbar_type, plt_p.alpha_size);
                % Connect each sub's dots with lines.
                y_data = [data.con(good_subs); data.incon(good_subs)];
                x_data = reshape(get(gca,'XTick'), 2,[]);
                x_data = repelem(x_data,1,length(good_subs));
                connect_dots(x_data, y_data);
                ylim([100 750]);
                yticks(100 : 200 : 700);
            end
            
            set(gca, 'TickDir','out');
            xticks([]);
            set(gca, 'FontSize',plt_p.font_size);
            set(gca, 'FontName',plt_p.font_name);
            set(gca, 'linewidth',plt_p.axes_line_thickness);
            % Legend.
%             h = [];
%             h(1) = bar(NaN,NaN,'FaceColor',plt_p.con_col, 'ShowBaseLine','off');
%             h(2) = bar(NaN,NaN,'FaceColor',plt_p.incon_col, 'ShowBaseLine','off');
%             legend(h,'Con','Incon', 'Location','northwest');
        
            % T-test and Cohen's dz
            [~, p_val_temp, ci, stats] = ttest(data.con(good_subs), data.incon(good_subs));
            p_vals.(vars(j)) = p_val_temp;
    
            % Print stats to terminal.
            printStats(char(vars(j)), data.con(good_subs), ...
                data.incon(good_subs), ["Con","Incon"], p_val_temp, ci, stats);
        end
    end
end