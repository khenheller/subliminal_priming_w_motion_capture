% Plots the number of bad trials for each sub.
% group - 'all_subs','good_subs', to include in analysis.
% plt_p - struct of plotting params.
% p - struct of exp params.
function [] = plotNumBadTrials(traj_name, group, plt_p, p)
    % Define parameters.
    subs_string = regexprep(num2str(p.SUBS), '\s+', '_');
    n_bad_trials = load([p.PROC_DATA_FOLDER '/bad_trials_' p.DAY '_' traj_name '_subs_' subs_string '.mat']);
    good_subs = load([p.PROC_DATA_FOLDER '/good_subs_' p.DAY '_' traj_name '_subs_' p.SUBS_STRING '.mat']);  good_subs = good_subs.good_subs;
    reach_n_bad_trials = n_bad_trials.reach_n_bad_trials;
    keyboard_n_bad_trials = n_bad_trials.keyboard_n_bad_trials;
    num_reasons = size(reach_n_bad_trials,2);
    reasons = string(replace(reach_n_bad_trials.Properties.VariableNames, '_', ' '));

    % Which subs to analyze.
    if isequal(group, 'all_subs')
        subs = p.SUBS;
    elseif isequal(group, 'good_subs')
        subs = good_subs;
    else
        error('Wrong input, use all_subs or good_subs.');
    end

    % Set parameters for plot.
    for i_reason = 1:num_reasons
        beesdata{:, i_reason*2 - 1} = reach_n_bad_trials{subs, i_reason}';
        beesdata{:, i_reason*2}     = keyboard_n_bad_trials{subs, i_reason}';
    end
    yLabel = 'Number of bad trials';
    XTickLabel = [];
    colors = repmat({plt_p.reach_color, plt_p.keyboard_color},1,num_reasons);
    title_char = ['Bad trials, Reaching Vs Keyboard, ', group];
    hold on;
    % Plot.
    printBeeswarm(beesdata, yLabel, XTickLabel, colors, plt_p.space, title_char, plt_p.errbar_type, plt_p.alpha_size);
    % Group graphs.
    ticks = get(gca,'XTick');
    labels = {["",""]; reasons;};
    dist = [0, 10];
    font_size = [1, 12];
    groupTick(ticks, labels, dist, font_size)

    % Legend.
    h = [];
    h(1) = bar(NaN,NaN,'FaceColor',plt_p.reach_color);
    h(2) = bar(NaN,NaN,'FaceColor',plt_p.keyboard_color);
    legend(h,'Reach','Keyboard', 'Location','northwest');
    % T-test.
    disp(['@@@@--------Bad Trials Reach vs Keyboard, ', group, '--------@@@@']);
    for i_reason = 1:num_reasons
        indx = i_reason*2;
        [~, p_val, ci, stats] = ttest(beesdata{:, indx-1}, beesdata{:, indx});
        text(mean(ticks(indx-1 : indx)), (max([beesdata{indx-1 : indx}])+10), ['p: ' num2str(p_val)], 'HorizontalAlignment','center', 'FontSize',14);
        
        % Print stats to terminal.
        printStats(reasons{i_reason}, beesdata{:, indx-1}, ...
            beesdata{:, indx}, ["reach","keyboard"], p_val, ci, stats);
    end
end