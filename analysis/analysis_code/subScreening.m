% Marks bad subjects who:
% - Don't have enough trials.
% - Don't have enough trials in each condition.
% - Categorization performance is at chance lvl.
% - Are aware of prime.
% Input:
%   pas_rate - double, only trials with this pas rating will be averaged.
%   task_type - 'reach' / 'keyboard'
function [bad_subs, valid_trials] = subScreening(traj_name, pas_rate, task_type, p)
    bad_trials = load([p.PROC_DATA_FOLDER '/bad_trials_' p.DAY '_' traj_name{1} '_subs_' p.SUBS_STRING '.mat']); bad_trials = bad_trials.([task_type '_bad_trials']);
    screen_reasons = {'not_enough_trials','not_enough_trials_in_cond','bad_performance','seen_prime','any'};
    bad_subs = table('size',[p.MAX_SUB, length(screen_reasons)],...
        'VariableTypes', repmat({'double'}, length(screen_reasons), 1),...
        'VariableNames', screen_reasons);
    
    % Counts and prints good trials.
    con = NaN(p.MAX_SUB, 1);
    incon = NaN(p.MAX_SUB, 1);
    disp([task_type ' trials with correct timing, pas=' num2str(pas_rate) ' and correct categorization'])
    

    for iSub = p.SUBS
        p = defineParams(p, iSub);
        data_table = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_' task_type '_data_proc.mat']);  data_table = data_table.([task_type '_data_table']);
        % Remove practice.
        data_table(data_table.practice>=1, :) = [];
        % Bad trials reasons, Remove reason: "incorrect", "slow_mvmnt", "loop".
        reasons = string(bad_trials{iSub}.Properties.VariableNames);
        reasons(reasons == "any" | reasons == "incorrect" | reasons == "slow_mvmnt" | reasons == "loop") = [];
        % Find good trials
        ok = ~any(bad_trials{iSub}{:, reasons}, 2); % has no timing / data issues (includes "slow mvmnt", excludes "very_slow_mvmnt".
        ok_pas = ok & ismember(data_table.pas, pas_rate); % And PAS rating is ok.
        ok_pas_categcorr = ok_pas & (bad_trials{iSub}.incorrect == 0); % And target categorization is correct.
        % Too much missing trials.
        bad_subs{iSub, 'not_enough_trials'} =  sum(ok_pas_categcorr) < p.MIN_GOOD_TRIALS;
        % Not enough trials in each condition.
        ok_pas_categcorr_con = ok_pas_categcorr & data_table.con;
        ok_pas_categcorr_incon = ok_pas_categcorr & ~data_table.con;
        bad_subs{iSub, 'not_enough_trials_in_cond'} = sum(ok_pas_categcorr_con) < p.MIN_AMNT_TRIALS_IN_COND |...
                                                      sum(ok_pas_categcorr_incon) < p.MIN_AMNT_TRIALS_IN_COND;
        % Counts good trials.
        disp(['-- Sub ', num2str(iSub) ' --']);
        disp(['Con: ' num2str(sum(ok_pas_categcorr_con))])
        disp(['Incon: ' num2str(sum(ok_pas_categcorr_incon))])
        con(iSub) = sum(ok_pas_categcorr_con);
        incon(iSub) = sum(ok_pas_categcorr_incon);

        % Categorization performance isn't good enough.
        perf_reasons = reasons;
        perf_reasons(perf_reasons == "very_slow_mvmnt" | perf_reasons == "bad_stim_dur") = [];
        perf_trials = ~any(bad_trials{iSub}{:, perf_reasons}, 2); % No timing/data issues.
        perf_trials_categorcorr = perf_trials & (bad_trials{iSub}.incorrect == 0); % And target categorization is correct.
        perf_is_low = sum(perf_trials_categorcorr) / sum(perf_trials) < 0.7;
        perf_diff_from_threshold = myBinomTest(sum(perf_trials_categorcorr), sum(perf_trials), 0.7, 'One') < p.SIG_PVAL;
        bad_subs{iSub, 'bad_performance'} =  perf_is_low & perf_diff_from_threshold;
        % Sub seen prime (prime recog isn't at chance). Looks also in "bad" trials.
        oktiming = ~bad_trials{iSub}{:, 'bad_stim_dur'}; % All trials with good stimulus duration.
        oktiming_pas = oktiming & ismember(data_table.pas, pas_rate);
        oktiming_pas_incon = oktiming_pas & ~data_table.con;
        oktiming_pas_incon_primecorr = oktiming_pas_incon & (data_table.prime_correct == 1);
        bad_subs{iSub, 'seen_prime'} = myBinomTest(sum(oktiming_pas_incon_primecorr), sum(oktiming_pas_incon), 0.5, 'Two') < p.SIG_PVAL;
        % Any.
        bad_subs{iSub, 'any'} = any(bad_subs{iSub,1:end-1});
    end
    
    con_good_subs = con(~bad_subs{:,'any'});
    incon_good_subs = incon(~bad_subs{:,'any'});
    
    valid_trials.con = con;
    valid_trials.incon = incon;

    con(isnan(con)) = [];
    incon(isnan(incon)) = [];
    con_good_subs(isnan(con_good_subs)) = [];
    incon_good_subs(isnan(incon_good_subs)) = [];

    % Prints good trials.
    disp(['Avg Congurnet: ' num2str(mean(con)) '  STD: ' num2str(std(con))]);
    disp(['Avg Incongruent: ' num2str(mean(incon)) '  STD: ' num2str(std(incon))]);
    disp(['Avg Congurnet, good subs: ' num2str(mean(con_good_subs)) '  STD: ' num2str(std(con_good_subs))]);
    disp(['Avg Incongruent, good subs: ' num2str(mean(incon_good_subs)) '  STD: ' num2str(std(incon_good_subs))]);
end