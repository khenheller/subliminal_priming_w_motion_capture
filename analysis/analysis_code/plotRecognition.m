% Plots the recognition performance of a single sub.
% iSub - subject number
% pas_rate - only trials with this rating will be included in plot.
% plt_p - struct of plotting params.
% p - struct of exp params.
function [] = plotRecognition(iSub, pas_rate, traj_name, plt_p, p)
    p = defineParams(p, iSub);
    reach_avg = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_avg_' traj_name '.mat']);  reach_avg = reach_avg.reach_avg;
    reach_single = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_sorted_trials_' traj_name '.mat']);  reach_single = reach_single.reach_single;
    % Convert to %.
    fc_con = reach_avg.fc_prime.con * 100;
    fc_incon = reach_avg.fc_prime.incon * 100;
    % Plot
    hold on;
    bar(1, fc_con, 'FaceColor',plt_p.con_col);
    bar(2, fc_incon, 'FaceColor',plt_p.incon_col);
    plot([0 4], [50 50], '--k'); % Plot chance level line.

    xticks(1:2);
    xticklabels({[num2str(round(fc_con,1)) '%'] [num2str(round(fc_incon,1)) '%']});
    yticks(0:10:100);
    xlabel('Con / Incon');
    ylabel('%Correct', 'FontWeight','bold');
    ylim([0 100]);
    title(['Prime Forced Choice (PAS=' pas_rate ')']);
    ax = gca;
    ax.YGrid = 'on';
    legend('Con','Incon');
    set(gca,'FontSize',14);

    % Binomial test.
    n_con_trials = size(reach_single.fc_prime.con,1);
    n_incon_trials = size(reach_single.fc_prime.incon,1);
    binom_con = round(myBinomTest(sum(reach_single.fc_prime.con), n_con_trials, 0.5, 'Two'), 3);
    binom_incon = round(myBinomTest(sum(reach_single.fc_prime.incon), n_incon_trials, 0.5, 'Two'), 3);
    text(1, fc_con+5, ['p_{bin}=' num2str(binom_con)], 'HorizontalAlignment','center');
    text(2, fc_incon+5, ['p_{bin}=' num2str(binom_incon)], 'HorizontalAlignment','center');
end