% Plots the average (over good subs) recognition performance.
% plt_p - struct of plotting params.
% p - struct of exp params.
function [] = plotMultiPas(traj_name, plt_p, p)
    reach_subs_avg = load([p.PROC_DATA_FOLDER '/subs_avg_' p.DAY '_' traj_name '_subs_' p.SUBS_STRING '.mat']);  reach_subs_avg = reach_subs_avg.reach_subs_avg;
    hold on;
    % Plot.
    bar(1:4, reach_subs_avg.pas.con * 100 / sum(reach_subs_avg.pas.con), 'FaceColor',plt_p.con_col);
    bar(5:8, reach_subs_avg.pas.incon * 100 / sum(reach_subs_avg.pas.incon), 'FaceColor',plt_p.incon_col);

    xticks(1:8);
    xticklabels({1:4 1:4});
    xlabel('PAS');
    ylabel('% Trials', 'FontWeight','bold');
    ylim([0 100]);
    title('PAS');
    set(gca,'FontSize',14);
    % Legend.
    legend('Con','Incon');
end