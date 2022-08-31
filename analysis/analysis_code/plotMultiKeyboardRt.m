% Plots the average (over good subjects) Reaction time wen using a keyboard.
% plt_p - struct of plotting params.
% p - struct of exp params.
function [] = plotMultiKeyboardRt(traj_names, plt_p, p)
    good_subs = load([p.PROC_DATA_FOLDER '/good_subs_' p.DAY '_' traj_names{1}{1} '_subs_' p.SUBS_STRING '.mat']);  good_subs = good_subs.good_subs;

    for iTraj = 1:length(traj_names)
        keyboard_avg_each = load([p.PROC_DATA_FOLDER '/avg_each_' p.DAY '_' traj_names{iTraj}{1} '_subs_' p.SUBS_STRING '.mat']);  keyboard_avg_each = keyboard_avg_each.keyboard_avg_each;
        % Load data and prep params.
        beesdata = {keyboard_avg_each.rt(iTraj).con(good_subs), keyboard_avg_each.rt(iTraj).incon(good_subs)};
        yLabel = 'Time (ms)';
        XTickLabel = [];
        colors = {plt_p.con_col, plt_p.incon_col};
        title_char = 'Keyboard timing';
        % Plot.
        printBeeswarm(beesdata, yLabel, XTickLabel, colors, plt_p.space, title_char, 'ci', plt_p.alpha_size);
        ylim([0 1000]);
        % Group graphs.
        ticks = get(gca,'XTick');
        labels = {["Left","Right"]};
        dist = [70];
        font_size = [15];
        groupTick(ticks, labels, dist, font_size)

        % Connect each sub's dots with lines.
        rt_data = [keyboard_avg_each.rt(iTraj).con(good_subs); keyboard_avg_each.rt(iTraj).incon(good_subs)];
        y_data = rt_data;
        x_data = reshape(get(gca,'XTick'), 2,[]);
        x_data = repelem(x_data,1,length(good_subs));
        connect_dots(x_data, y_data);
        
        % Legend.
        h = [];
        h(1) = bar(NaN,NaN,'FaceColor',plt_p.con_col);
        h(2) = bar(NaN,NaN,'FaceColor',plt_p.incon_col);
        legend(h,'Con','Incon', 'Location','northwest');
    
        % T-test and Cohen's dz
        [~, p_val_rt, ci_rt, stats_rt] = ttest(keyboard_avg_each.rt(iTraj).con(good_subs), keyboard_avg_each.rt(iTraj).incon(good_subs));

        % Print stats to terminal.
        printStats('----Keyboard RT--------', keyboard_avg_each.rt(iTraj).con(good_subs), ...
            keyboard_avg_each.rt(iTraj).incon(good_subs), p_val_rt, ci_rt, stats_rt);
        disp('Between TRIALS rt std: ');
        disp(['Con: ', num2str(mean(keyboard_avg_each.rt_std.con(good_subs)))]);
        disp(['Incon: ', num2str(mean(keyboard_avg_each.rt_std.incon(good_subs)))]);
    end
end