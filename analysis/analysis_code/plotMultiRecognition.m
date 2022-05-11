% Plots the average (over good subs) recognition performance.
% pas_rate - only trials with this rating will be included in plot.
% plt_p - struct of plotting params.
% p - struct of exp params.
function [] = plotMultiRecognition(pas_rate, traj_name, plt_p, p)
    good_subs = load([p.PROC_DATA_FOLDER '/good_subs_' p.DAY '_' traj_name '_subs_' p.SUBS_STRING '.mat']);  good_subs = good_subs.good_subs;
    % Load data.
    reach_avg_each = load([p.PROC_DATA_FOLDER '/avg_each_' p.DAY '_' traj_name '_subs_' p.SUBS_STRING '.mat']);  reach_avg_each = reach_avg_each.reach_avg_each;
    beesdata = {reach_avg_each.fc_prime.con(good_subs), reach_avg_each.fc_prime.incon(good_subs)};
    % Plot.
    YLabel = "% Correct";
    XTickLabel = {'Con', 'Incon'};
    colors = {plt_p.con_col, plt_p.incon_col};
    title_char = ['Prime Forced response (PAS = ' num2str(pas_rate) ')'];
    printBeeswarm(beesdata, YLabel, XTickLabel, colors, plt_p.space, title_char, 'ci', plt_p.alpha_size);
    % Plot chance level.
    plot([-20 20], [0.5 0.5], '--', 'color',[0.3 0.3 0.3 plt_p.f_alpha], 'linewidth',2);

    ylim([0 1]);
    % T-test.
    [h, fc_p_val(1) , ci, stats] = ttest(reach_avg_each.fc_prime.con(good_subs), 0.5);
    [h, fc_p_val(2) , ci, stats] = ttest(reach_avg_each.fc_prime.incon(good_subs), 0.5);
    fc_p_val = round(fc_p_val, 2);
    text(get(gca, 'xTick'),[0.1 0.1], {['p = ' num2str(fc_p_val(1))], ['p = ' num2str(fc_p_val(2))]}, 'FontSize',14, 'HorizontalAlignment','center');
end