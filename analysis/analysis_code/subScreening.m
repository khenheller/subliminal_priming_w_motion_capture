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
    
    % Counts and prints good trials.
    avg_con = 0;
    avg_incon = 0;
    disp(['Trials with correct timing, pas=' num2str(pas_rate) ' and correct categorization'])
    

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
        ok_pas_categcorr_con = ok_pas_categcorr & data_table.con;
        ok_pas_categcorr_incon = ok_pas_categcorr & ~data_table.con;
        bad_subs{iSub, 'not_enough_trials_in_cond'} = sum(ok_pas_categcorr_con) < p.MIN_AMNT_TRIALS_IN_COND |...
                                                      sum(ok_pas_categcorr_incon) < p.MIN_AMNT_TRIALS_IN_COND;
        % Counts good trials.
        disp(['Sub ', num2str(iSub)]);
        disp(['Con: ' num2str(sum(ok_pas_categcorr_con))])
        disp(['Incon: ' num2str(sum(ok_pas_categcorr_incon))])
        avg_con = avg_con + sum(ok_pas_categcorr_con);
        avg_incon = avg_incon + sum(ok_pas_categcorr_incon);

        % Categorization performance isn't good enough.
        bad_subs{iSub, 'categor_chance_lvl'} = myBinomTest(sum(ok_pas_categcorr), sum(ok_pas), 0.5, 'Two') >= p.SIG_PVAL;
        % Sub seen prime (prime recog isn't at chance). Looks also in "bad" trials.
        oktiming = ~bad_trials{iSub}{:, 'bad_stim_dur'}; % All trials with good stimulus duration.
        oktiming_pas = oktiming & data_table.pas == pas_rate;
        oktiming_pas_incon = oktiming_pas & ~data_table.con;
        oktiming_pas_incon_primecorr = oktiming_pas_incon & data_table.prime_correct;
        bad_subs{iSub, 'seen_prime'} = myBinomTest(sum(oktiming_pas_incon_primecorr), sum(oktiming_pas_incon), 0.5, 'Two') < p.SIG_PVAL;
        % Any.
        bad_subs{iSub, 'any'} = any(bad_subs{iSub,1:end-1});
    end
    
    % Prints good trials.
    disp(['Avg Congurnet: ' num2str(avg_con/length(p.SUBS))]);
    disp(['Avg Incongruent: ' num2str(avg_incon/length(p.SUBS))]);
end