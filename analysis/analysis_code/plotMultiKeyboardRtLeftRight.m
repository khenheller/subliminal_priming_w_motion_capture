% Plots the average (over good subjects) Reaction time wen using a keyboard.
% Sepereates left and right answers.
% plt_p - struct of plotting params.
% p - struct of exp params.
function [] = plotMultiKeyboardRtLeftRight(traj_names, plt_p, p)
    good_subs = load([p.PROC_DATA_FOLDER '/good_subs_' p.DAY '_' traj_names{1}{1} '_subs_' p.SUBS_STRING '.mat']);  good_subs = good_subs.good_subs;

    for iTraj = 1:length(traj_names)
        keyboard_avg_each = load([p.PROC_DATA_FOLDER '/avg_each_' p.DAY '_' traj_names{iTraj}{1} '_subs_' p.SUBS_STRING '.mat']);  keyboard_avg_each = keyboard_avg_each.keyboard_avg_each;
        % Load data and prep params.
        beesdata = {keyboard_avg_each.rt(iTraj).con_left(good_subs),     keyboard_avg_each.rt(iTraj).incon_left(good_subs),...
                    keyboard_avg_each.rt(iTraj).con_right(good_subs),    keyboard_avg_each.rt(iTraj).incon_right(good_subs)};
        yLabel = 'Time (ms)';
        XTickLabel = [];
        colors = repmat({plt_p.con_col, plt_p.incon_col},1,2);
        title_char = 'Keyboard timing';
        % Plot.
        printBeeswarm(beesdata, yLabel, XTickLabel, colors, plt_p.space, title_char, 'ci', plt_p.alpha_size);
        ylim([0 1000]);
        % Group graphs.
        ticks = get(gca,'XTick');
        labels = {["",""]; ["Left","Right"]};
        dist = [0, 70];
        font_size = [1, 15];
        groupTick(ticks, labels, dist, font_size)

        % Connect each sub's dots with lines.
        rt_data = [keyboard_avg_each.rt(iTraj).con_left(good_subs), keyboard_avg_each.rt(iTraj).con_right(good_subs);...
                      keyboard_avg_each.rt(iTraj).incon_left(good_subs), keyboard_avg_each.rt(iTraj).incon_right(good_subs)];
        y_data = rt_data;
        x_data = reshape(get(gca,'XTick'), 2,[]);
        x_data = repelem(x_data,1,length(good_subs));
        plot(x_data, y_data, 'color',[0.1 0.1 0.1, plt_p.f_alpha]);
        
        % Legend.
        h = [];
        h(1) = bar(NaN,NaN,'FaceColor',plt_p.con_col);
        h(2) = bar(NaN,NaN,'FaceColor',plt_p.incon_col);
        legend(h,'Con','Incon', 'Location','northwest');
    end
end