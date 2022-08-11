% Plots a beeswarm of subs Keyboard response times.
% Seperatges according to conditions and sides.
% iSub - subject number
% plt_p - struct of plotting params.
% p - struct of exp params.
function [] = plotKeyboardRt(iSub, traj_name, plt_p, p)
    p = defineParams(p, iSub);
    hold on;
    keyboard_single = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_sorted_trials_' traj_name '.mat']);  keyboard_single = keyboard_single.keyboard_single;
    % Load data and prep params.
    beesdata = {keyboard_single.rt.con_left,  keyboard_single.rt.incon_left,...
                keyboard_single.rt.con_right, keyboard_single.rt.incon_right};
    yLabel = 'Time (Sec)';
    XTickLabel = [];
    colors = repmat({plt_p.con_col, plt_p.incon_col},1,2);
    title_char = 'Keyboard RT';
    % Plot.
    printBeeswarm(beesdata, yLabel, XTickLabel, colors, plt_p.space, title_char, 'ci', plt_p.alpha_size);
    % Group graphs.
    ticks = get(gca,'XTick');
    labels = {["",""]; ["Left","Right"]};
    dist = [0, 0.08];
    font_size = [1, 15];
    ylim([0.4 1]);
    groupTick(ticks, labels, dist, font_size)

    set(gca, 'YGrid','on');
    % Legend.
    h = [];
    h(1) = bar(NaN,NaN,'FaceColor',plt_p.con_col);
    h(2) = bar(NaN,NaN,'FaceColor',plt_p.incon_col);
    legend(h,'Con','Incon', 'Location','northwest');
end