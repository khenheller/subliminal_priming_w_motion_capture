% Marks bad subjects who:
% - Don't have enough trials.
% - Don't have enough trials in each condition.
%  - Categorization performance is at chance lvl.
% Input:
%   pas_rate - double, only trials with this pas rating will be averaged.
function [bad_subs] = subScreening(traj_name, pas_rate, p)
    bad_trials = load([p.PROC_DATA_FOLDER '/bad_trials_' p.DAY '_' traj_name{1} '.mat']);
    n_bad_trials = bad_trials.n_bad_trials;
    bad_trials = bad_trials.bad_trials;
    screen_reasons = {'not_enough_trials','not_enough_trials_in_cond','ans_chance_lvl','any'};
    bad_subs = table('size',[p.MAX_SUB, length(screen_reasons)],...
        'VariableTypes', repmat({'double'}, length(screen_reasons), 1),...
        'VariableNames', screen_reasons);
    
    for iSub = p.SUBS
        data_table = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_' 'data_proc.mat']);  data_table = data_table.data_table;
        % Remove practice.
        data_table(data_table.practice>=1, :) = [];
        % Too much missing trials.
        bad_subs{iSub, 'not_enough_trials'} =  n_bad_trials{iSub, 'any'} > p.MAX_BAD_TRIALS;
        % Not enough trials in each condition.
        good_same_trials = sum(~bad_trials{iSub}.any & data_table.same & data_table.pas == pas_rate);
        good_diff_trials = sum(~bad_trials{iSub}.any & ~data_table.same & data_table.pas == pas_rate);
        good_trials = good_same_trials + good_diff_trials;
        bad_subs{iSub, 'not_enough_trials_in_cond'} = good_same_trials < p.MIN_AMNT_TRIALS_IN_COND |...
                                                      good_diff_trials < p.MIN_AMNT_TRIALS_IN_COND;
        % Number of correct ans is at chance lvl (for categorization).
        [good_trials, corr_trials] = cntGoodTrials(bad_trials, iSub);
        bad_subs{iSub, 'ans_chance_lvl'} = myBinomTest(corr_trials, good_trials, 0.5, 'Two') >= p.SIG_PVAL;
        % Any.
        bad_subs{iSub, 'any'} = any(bad_subs{iSub,1:end-1});
    end
end
function [good_trials, corr_trials] = cntGoodTrials(bad_trials, iSub)
    % Bad trials reasons.
    reasons = string(bad_trials{iSub}.Properties.VariableNames);
    % Trials that are bad but not because they're incorrect.
    reasons(reasons == "any" | reasons == "incorrect") = [];
    % Good trials (including incorrect).
    good_trials = sum(~any(bad_trials{iSub}{:, reasons}>0, 2));
    % Good trials, correct only.
    corr_trials = sum(~bad_trials{iSub}.any,1);
end