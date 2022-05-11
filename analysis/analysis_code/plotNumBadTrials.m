% Plots the number of bad trials for each sub.
% subplot_p - parameters for 'subplot' command for each of the 2 subplots.
% plt_p - struct of plotting params.
% p - struct of exp params.
function [] = plotNumBadTrials(traj_name, plt_p, p)
    % Define parameters.
    subs_string = regexprep(num2str(p.SUBS), '\s+', '_');
    n_bad_trials = load([p.PROC_DATA_FOLDER '/bad_trials_' p.DAY '_' traj_name '_subs_' subs_string '.mat']);
    reach_n_bad_trials = n_bad_trials.reach_n_bad_trials;
    keyboard_n_bad_trials = n_bad_trials.keyboard_n_bad_trials;
    good_subs = load([p.PROC_DATA_FOLDER '/good_subs_' p.DAY '_' traj_name '_subs_' subs_string '.mat']);  good_subs = good_subs.good_subs;
    num_reasons = size(reach_n_bad_trials,2);
    reasons = string(replace(reach_n_bad_trials.Properties.VariableNames, '_', ' '));

    % Set parameters for plot.
    for i_reason = 1:num_reasons
        beesdata{:, i_reason*2 - 1} = reach_n_bad_trials{good_subs, i_reason}';
        beesdata{:, i_reason*2}     = keyboard_n_bad_trials{good_subs, i_reason}';
    end
    yLabel = 'Number of bad trials';
    XTickLabel = [];
    colors = repmat({plt_p.reach_color, plt_p.keyboard_color},1,num_reasons);
    title_char = "Amount of bad trials comparison between reaching and keyboard";
    hold on;
    % Plot.
    printBeeswarm(beesdata, yLabel, XTickLabel, colors, plt_p.space, title_char, 'ci', plt_p.alpha_size);
    % Group graphs.
    ticks = get(gca,'XTick');
    labels = {["",""]; reasons;};
    dist = [0, 10];
    font_size = [1, 12];
    groupTick(ticks, labels, dist, font_size)

    ylim([-20 420]);
    % Legend.
    h = [];
    h(1) = bar(NaN,NaN,'FaceColor',plt_p.exp_2_color);
    h(2) = bar(NaN,NaN,'FaceColor',plt_p.exp_3_color);
    legend(h,'Reach','Keyboard', 'Location','northwest');
    % T-test.
    for i_reason = 1:num_reasons
        indx = i_reason*2;
        [~, bad_trials_p_val, ci, ~] = ttest(beesdata{:, indx-1}, beesdata{:, indx});
        text(mean(ticks(indx-1 : indx)), (max([beesdata{indx-1 : indx}])+10), ['p: ' num2str(bad_trials_p_val)], 'HorizontalAlignment','center', 'FontSize',14);
    end
end