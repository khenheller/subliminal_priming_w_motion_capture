% Plots the number of bad trials for each sub in exp 2 and 3 and compares it with t-test.
% subplot_p - parameters for 'subplot' command for each of the 2 subplots.
% group - 'all_subs','good_subs', to include in analysis.
% plt_p - struct of plotting params.
% p - struct of exp params.
function [] = plotNumBadTrialsExp2Exp3(traj_name, group, plt_p, p)
    % Load valid trials and bad trials count.
    exp2_subs_string = regexprep(num2str(p.EXP_2_SUBS), '\s+', '_');
    exp3_subs_string = regexprep(num2str(p.EXP_3_SUBS), '\s+', '_');
    exp_2_good_subs = load([p.PROC_DATA_FOLDER '/good_subs_' p.DAY '_' traj_name '_subs_' exp2_subs_string '.mat']);  exp_2_good_subs = exp_2_good_subs.good_subs;
    exp_3_good_subs = load([p.PROC_DATA_FOLDER '/good_subs_' p.DAY '_' traj_name '_subs_' exp3_subs_string '.mat']);  exp_3_good_subs = exp_3_good_subs.good_subs;
    exp2_valid_trials = load([p.PROC_DATA_FOLDER '/valid_trials_' p.DAY '_' traj_name '_subs_' exp2_subs_string '.mat']);  exp2_valid_trials = exp2_valid_trials.reach_valid_trials;
    exp3_valid_trials = load([p.PROC_DATA_FOLDER '/valid_trials_' p.DAY '_' traj_name '_subs_' exp3_subs_string '.mat']);  exp3_valid_trials = exp3_valid_trials.reach_valid_trials;
    exp2_n_bad_trials = load([p.PROC_DATA_FOLDER '/bad_trials_' p.DAY '_' traj_name '_subs_' exp2_subs_string '.mat']);
    exp3_n_bad_trials = load([p.PROC_DATA_FOLDER '/bad_trials_' p.DAY '_' traj_name '_subs_' exp3_subs_string '.mat']);
    exp2_n_bad_trials = exp2_n_bad_trials.reach_n_bad_trials;
    exp3_n_bad_trials = exp3_n_bad_trials.reach_n_bad_trials;
    % Define parameters.
    num_reasons = size(exp2_n_bad_trials,2);
    reasons = string(replace(exp2_n_bad_trials.Properties.VariableNames, '_', ' '));

    % Which subs to analyze.
    if isequal(group, 'all_subs')
        exp2_subs = p.EXP_2_SUBS;
        exp3_subs = p.EXP_3_SUBS;
    elseif isequal(group, 'good_subs')
        exp2_subs = exp_2_good_subs;
        exp3_subs = exp_3_good_subs;
    else
        error('Wrong input, use all_subs or good_subs.');
    end

    test_table = table('Size',[num_reasons, 10], 'VariableTypes',['string', repmat("double", [1,9])], ...
        'VariableNames',{'reason','exp2_m','exp3_m','exp2_std','exp3_std','t_val','df','p_val','ci_low','ci_high'});

    % Count bad trials for each reason in each exp.
    for i_reason = 1:num_reasons
        beesdata{:, i_reason*2 - 1} = exp2_n_bad_trials{exp2_subs, i_reason}';
        beesdata{:, i_reason*2}     = exp3_n_bad_trials{exp3_subs, i_reason}';
    end
    yLabel = 'Excluded trials';
    XTickLabel = [];
    colors = repmat({plt_p.reach_color, plt_p.keyboard_color},1,num_reasons);
    title_char = ['Excluded trials Exp 2 Vs 3, ', group];
    hold on;
    % Plot.
    printBeeswarm(beesdata, yLabel, XTickLabel, colors, plt_p.space, title_char, plt_p.errbar_type, plt_p.alpha_size);
    % Group graphs.
    ticks = get(gca,'XTick');
    labels = {["",""]; reasons;};
    dist = [0, 10];
    font_size = [1, 12];
    groupTick(ticks, labels, dist, font_size)

    h = gca;
    h.XAxis.TickLength = [0 0];
    h.TickDir = 'out';
    % Legend.
    h = [];
    h(1) = bar(NaN,NaN,'FaceColor',plt_p.reach_color);
    h(2) = bar(NaN,NaN,'FaceColor',plt_p.keyboard_color);
    legend(h,'Exp2','Exp3', 'Location','northwest');
    % T-test.
    for i_reason = 1:num_reasons
        indx = i_reason*2;
        [~, each_p_val, each_ci, each_stats] = ttest2(beesdata{:, indx}, beesdata{:, indx-1});
        text(mean(ticks(indx-1 : indx)), (max([beesdata{indx-1 : indx}])+10), ['p: ' num2str(round(each_p_val,3))], 'HorizontalAlignment','center', 'FontSize',14);
        test_table(i_reason, :) = table(reasons(i_reason), mean(beesdata{:, indx-1}), mean(beesdata{:, indx}), ...
            std(beesdata{:, indx-1}), std(beesdata{:, indx}), each_stats.tstat, each_stats.df, ...
            each_p_val, each_ci(1), each_ci(2));
    end
    % Print t-test.
    exp2_valid_trials = exp2_valid_trials.con + exp2_valid_trials.incon;
    exp3_valid_trials = exp3_valid_trials.con + exp3_valid_trials.incon;
    exp2_valid_trials = exp2_valid_trials(exp2_subs);
    exp3_valid_trials = exp3_valid_trials(exp3_subs);
    [~, p_val, ci, stats] = ttest2(exp3_valid_trials, exp2_valid_trials);
    disp(['--------Avg num of Valid trials, Exp 2vs3, ', group, '--------']);
    disp(['Exp 2: M=' num2str(mean(exp2_valid_trials)) '    STD=' num2str(std(exp2_valid_trials))]);
    disp(['Exp 3: M=' num2str(mean(exp3_valid_trials)) '    STD=' num2str(std(exp3_valid_trials))]);
    disp(['t-test = ' num2str(stats.tstat) '    df = ' num2str(stats.df) '     p-value = ' num2str(p_val)]);
    disp(['CI = [' num2str(ci(1)) ', ' num2str(ci(2)) ']     sd = ' num2str(stats.sd)]);
    disp(test_table);
end