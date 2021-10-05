function [bad_subs] = subScreening(traj_name, p)
    bad_trials = load([p.PROC_DATA_FOLDER '/bad_trials_' traj_name{1} '.mat']);
    n_bad_trials = bad_trials.n_bad_trials;
    bad_trials = bad_trials.bad_trials;
    screen_reasons = {'not_enough_trials','not_enough_trials_in_cond','ans_chance_lvl','any'};
    bad_subs = table('size',[p.MAX_SUB, length(screen_reasons)],...
        'VariableTypes', repmat({'double'}, length(screen_reasons), 1),...
        'VariableNames', screen_reasons);
    good_same_trials = NaN(p.N_SUBS, 1);
    good_diff_trials = NaN(p.N_SUBS, 1);
    
    for iSub = p.SUBS
        data_table = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_' 'data_proc.mat']);  data_table = data_table.data_table;
        % Remove practice.
        data_table(data_table.practice>=1, :) = [];
        % Too much missing trials.
        bad_subs{iSub, 'not_enough_trials'} =  n_bad_trials{iSub, 'any'} > p.MAX_BAD_TRIALS;
        % Not enough trials in each condition.
        good_same_trials(iSub) = sum(~bad_trials{iSub}.any & data_table.same);
        good_diff_trials(iSub) = sum(~bad_trials{iSub}.any & ~data_table.same);
        bad_subs{iSub, 'not_enough_trials_in_cond'} = good_same_trials(iSub) < p.MIN_AMNT_TRIALS_IN_COND |...
            good_diff_trials(iSub) < p.MIN_AMNT_TRIALS_IN_COND;
        % Number of correct ans is at chance lvl (for categorization).
        amnt_corr = sum(data_table.target_correct);
        bad_subs{iSub, 'ans_chance_lvl'} = myBinomTest(amnt_corr, p.NUM_TRIALS, 0.5, 'Two') >= p.SIG_PVAL;
        % Any.
        bad_subs{iSub, 'any'} = any(bad_subs{iSub,1:end-1});
    end
end