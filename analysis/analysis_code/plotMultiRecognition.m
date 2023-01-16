% Plots the average (over good subs) recognition performance.
% pas_rate - only trials with this rating will be included in plot.
% group - which participants to analyze: 'all_subs', 'good_subs'.
% measure - 'reach' / 'keyboard'.
% plt_p - struct of plotting params.
% p - struct of exp params.
function [] = plotMultiRecognition(pas_rate, measure, group, traj_name, plt_p, p)
    good_subs = load([p.PROC_DATA_FOLDER '/good_subs_' p.DAY '_' traj_name '_subs_' p.SUBS_STRING '.mat']);  good_subs = good_subs.good_subs;

    % What subs to analyze.
    if isequal(group, 'all_subs')
        subs = p.SUBS;
    elseif isequal(group, 'good_subs')
        subs = good_subs;
    else
        error('Wrong input, use all_subs or good_subs.');
    end
    % Load data.
    avg_each = load([p.PROC_DATA_FOLDER '/avg_each_' p.DAY '_' traj_name '_subs_' p.SUBS_STRING '.mat']);  avg_each = avg_each.([measure '_avg_each']);
    % Convert to %.
    avg_each.fc_prime.con = avg_each.fc_prime.con * 100;
    avg_each.fc_prime.incon = avg_each.fc_prime.incon * 100;
    beesdata = {avg_each.fc_prime.con(subs), avg_each.fc_prime.incon(subs)};
    % Plot.
    YLabel = "% Correct";
    XTickLabel = {'Con', 'Incon'};
    colors = {plt_p.con_col, plt_p.incon_col};
    title_char = ['Prime FC (PAS = ' num2str(pas_rate) ') , ' group ', ' measure];
    printBeeswarm(beesdata, YLabel, XTickLabel, colors, plt_p.space, title_char, plt_p.errbar_type, plt_p.alpha_size);
    % Plot chance level.
    plot([-20 20], [50 50], '--', 'color',[0.3 0.3 0.3 plt_p.f_alpha], 'linewidth',2);
    ylim([0 100]);

    % T-test.
    [~, fc_p_val(1) , ~, ~] = ttest(avg_each.fc_prime.con(subs), 50);
    [~, fc_p_val(2) , fc_ci, fc_stats] = ttest(avg_each.fc_prime.incon(subs), 50);
    fc_p_val = round(fc_p_val, 2);
    text(get(gca, 'xTick'),[10 10], {['p = ' num2str(fc_p_val(1))], ['p = ' num2str(fc_p_val(2))]}, 'FontSize',14, 'HorizontalAlignment','center');

    % Print stats to terminal.
    printStats(['@@@@-----Prime Forced Choice, ' group ', ' measure, '------------@@@@'], avg_each.fc_prime.con(subs), ...
        avg_each.fc_prime.incon(subs), ["Con","Incon"], fc_p_val(2), fc_ci, fc_stats);
end