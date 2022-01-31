% Marks bad subjects who:
% - Don't have enough trials.
% - Don't have enough trials in each condition.
%  - Categorization performance is at chance lvl.
% Input:
%   pas_rate - double, only trials with this pas rating will be averaged.
function [bad_subs] = subScreening(traj_name, pas_rate, p)
    bad_trials = load([p.PROC_DATA_FOLDER '/bad_trials_' p.DAY '_' traj_name{1} '_subs_' p.SUBS_STRING '.mat']);
    bad_trials = bad_trials.bad_trials;
    screen_reasons = {'not_enough_trials','not_enough_trials_in_cond','categor_chance_lvl','seen_prime','any'};
    bad_subs = table('size',[p.MAX_SUB, length(screen_reasons)],...
        'VariableTypes', repmat({'double'}, length(screen_reasons), 1),...
        'VariableNames', screen_reasons);
    
    for iSub = p.SUBS
        data_table = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_' 'data_proc.mat']);  data_table = data_table.data_table;
        % Remove practice.
        data_table(data_table.practice>=1, :) = [];
        % Bad trials reasons, Remove reason: "incorrect" categor.
        reasons = string(bad_trials{iSub}.Properties.VariableNames);
        reasons(reasons == "any" | reasons == "incorrect") = [];
        % Find good trials
        ok = ~any(bad_trials{iSub}{:, reasons}, 2); % has no timing / data issues.
        ok_pas = ok & data_table.pas == pas_rate; % And PAS rating is ok.
        ok_pas_categcorr = ok_pas & ~bad_trials{iSub}.incorrect; % And target categorization is correct.
        % Too much missing trials.
        bad_subs{iSub, 'not_enough_trials'} =  sum(ok_pas_categcorr) < p.MIN_GOOD_TRIALS;
        % Not enough trials in each condition.
        ok_pas_categcorr_same = ok_pas_categcorr & data_table.same;
        ok_pas_categcorr_diff = ok_pas_categcorr & ~data_table.same;
        bad_subs{iSub, 'not_enough_trials_in_cond'} = sum(ok_pas_categcorr_same) < p.MIN_AMNT_TRIALS_IN_COND |...
                                                      sum(ok_pas_categcorr_diff) < p.MIN_AMNT_TRIALS_IN_COND;
        % Categorization is at chance level (sub is geussing).
        bad_subs{iSub, 'categor_chance_lvl'} = myBinomTest(sum(ok_pas_categcorr), sum(ok_pas), 0.5, 'Two') >= p.SIG_PVAL;
        % Sub seen prime (prime recog isn't at chance). Looks also in "bad" trials.
        oktiming = ~bad_trials{iSub}{:, 'bad_stim_dur'}; % All trials with good stimulus duration.
        oktiming_pas = oktiming & data_table.pas == pas_rate;
        oktiming_pas_diff = oktiming_pas & ~data_table.same;
        oktiming_pas_diff_primecorr = oktiming_pas_diff & data_table.prime_correct;
        bad_subs{iSub, 'seen_prime'} = myBinomTest(sum(oktiming_pas_diff_primecorr), sum(oktiming_pas_diff), 0.5, 'Two') < p.SIG_PVAL;
        % Any.
        bad_subs{iSub, 'any'} = any(bad_subs{iSub,1:end-1});
    end
end