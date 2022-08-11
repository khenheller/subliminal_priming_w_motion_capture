% Plots the average distribution of PAS answers of a single sub.
% iSub - subject number
% plt_p - struct of plotting params.
% p - struct of exp params.
function [] = plotPas(iSub, traj_name, plt_p, p)
    p = defineParams(p, iSub);
    reach_avg = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_avg_' traj_name '.mat']);  reach_avg = reach_avg.reach_avg;
    % Plot
    hold on;
    bar(1:4, reach_avg.pas.con * 100 / sum(reach_avg.pas.con), 'FaceColor',plt_p.con_col);
    bar(5:8, reach_avg.pas.incon * 100 / sum(reach_avg.pas.incon), 'FaceColor',plt_p.incon_col);

    xticks(1:8);
    yticks(0:10:100);
    xticklabels({1:4 1:4});
    xlabel('Rating');
    ylabel('%', 'FontWeight','bold');
    ylim([0 100]);
    title(['PAS']);
    ax = gca;
    ax.YGrid = 'on';
    legend('Con','Incon');
    set(gca,'FontSize',14);
end