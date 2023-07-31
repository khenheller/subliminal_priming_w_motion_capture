% Plots a beeswarm of subs reaction, movement and response times.
% Seperatges according to conditions and sides.
% iSub - subject number
% plt_p - struct of plotting params.
% p - struct of exp params.
function [] = plotReactMtRt(iSub, traj_names, plt_p, p)
    p = defineParams(p, iSub);
    for iTraj = 1:length(traj_names)
        hold on;
        reach_single = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_sorted_trials_' traj_names{iTraj}{1} '.mat']);  reach_single = reach_single.reach_single;
        % Load data and prep params.
        beesdata = {reach_single.react.con_left,  reach_single.react.incon_left,...
                    reach_single.react.con_right, reach_single.react.incon_right,...
                    reach_single.mt.con_left,     reach_single.mt.incon_left,...
                    reach_single.mt.con_right,    reach_single.mt.incon_right,...
                    reach_single.rt.con_left,     reach_single.rt.incon_left,...
                    reach_single.rt.con_right,    reach_single.rt.incon_right};
        yLabel = 'Time (Sec)';
        XTickLabel = [];
        colors = repmat({plt_p.con_col, plt_p.incon_col},1,6);
        title_char = 'Reaching timing';
        % Plot.
        printBeeswarm(beesdata, yLabel, XTickLabel, colors, plt_p.space, title_char, 'ci', plt_p.alpha_size);
        % Group graphs.
        ticks = get(gca,'XTick');
        labels = {["",""]; ["Left","Right"]; ["React","MT","RT"]};
        dist = [0, 0.07 0.2];
        font_size = [1, 15, 20];
        groupTick(ticks, labels, dist, font_size)

        set(gca, 'YGrid','on');
        % Legend.
        h = [];
        h(1) = bar(NaN,NaN,'FaceColor',plt_p.con_col);
        h(2) = bar(NaN,NaN,'FaceColor',plt_p.incon_col);
        legend(h,'Con','Incon', 'Location','northwest');
    end
end