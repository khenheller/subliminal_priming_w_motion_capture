% Finds trials that should be screened because:
% Reach:
%   Has big hole (NaNs) in data.
%   Have too much missing data.
%   Reach distance too short.
%   Finger missed target.
%   Stim duration was false.
%   Late response.
%   Slow movement time.
%   Early start (predictive mvmnt instead of response to target).
%   Quit (sub quit exp before this trial).
%   Incorrect (e.g. sub reached left but correct ans was right).
% Keyboard:
%   Slow RT.
%   No response given.
%   Incorrect answer.
% task_type - 'reach' / 'keyboard'.
% Output:
%   bad_trials - Cell for each sub, has table inside.
%               Table has row for each trial and column for each screening reason,
%               and a 'any' colum that indicates if any screen reason happend.
%   n_bad_trials - table, row for each sub, shows how many bad trials for each reason.
%   bad_trials_i - Cell for each sub, has table inside.
%               Table has list of disqualified trials for each screen reason.
%               bad_trials is logical indexing, this is numeric.
function [bad_trials, n_bad_trials, bad_trials_i] = trialScreen(traj_name, task_type, p)
    is_reach = isequal(task_type, 'reach');

    screen_reasons = {'hole_in_data','missing_data','short_traj','missed_target','bad_stim_dur',...
        'late_res', 'slow_mvmnt', 'very_slow_mvmnt', 'early_res', 'incorrect', 'quit', 'any'};
    % Index of each reason.
    indx.hole_in_data = ismember(screen_reasons, 'hole_in_data');
    indx.missing_data = ismember(screen_reasons, 'missing_data');
    indx.short_traj = ismember(screen_reasons, 'short_traj');
    indx.missed_target = ismember(screen_reasons, 'missed_target');
    indx.bad_stim_dur = ismember(screen_reasons, 'bad_stim_dur');
    indx.late_res = ismember(screen_reasons, 'late_res');
    indx.slow_mvmnt = ismember(screen_reasons, 'slow_mvmnt');
    indx.very_slow_mvmnt = ismember(screen_reasons, 'very_slow_mvmnt');
    indx.early_res = ismember(screen_reasons, 'early_res');
    indx.incorrect = ismember(screen_reasons, 'incorrect');
    indx.quit = ismember(screen_reasons, 'quit');
    indx.any = ismember(screen_reasons, 'any');
    % Bad trials' numbers. row = bad trial, column = reason.
    bad_trials_table = table('Size', [p.NUM_TRIALS length(screen_reasons)],...
        'VariableTypes', repmat({'double'}, length(screen_reasons), 1),...
        'VariableNames', screen_reasons);
    % Bad trials' indices. row = subject, column = reason, each slot contains nums of all bad trials.
    bad_trials_i = table('Size', [p.MAX_SUB length(screen_reasons)],...
        'VariableTypes', repmat({'cell'}, length(screen_reasons), 1),...
        'VariableNames', screen_reasons);
    n_bad_trials = bad_trials_table; % amount of bad trials, one row for each sub.
    n_bad_trials(p.N_SUBS+1 : end, :) = [];
    bad_trials = cell(p.N_SUBS, 1); % table for each sub, each row will be a trial marked as good/bad.
    
    too_short = load([p.PROC_DATA_FOLDER '/too_short_to_filter_' p.DAY '_subs_' p.SUBS_STRING '.mat'], 'too_short_to_filter');  too_short = too_short.too_short_to_filter;

    for iSub = p.SUBS
        p = defineParams(p, iSub);
        too_short_to_filter = too_short{iSub, strrep(traj_name{1}, '_x', '')};
        dev_table = load([p.TESTS_FOLDER '/sub' num2str(iSub) p.DAY '.mat']);  dev_table = dev_table.([task_type '_test_res']).dev_table;
        traj_table = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_reach_traj.mat']);  traj_table = traj_table.reach_traj_table;
        traj_table_pre_norm = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_reach_pre_norm_traj.mat']);  traj_table_pre_norm = traj_table_pre_norm.reach_pre_norm_traj_table;
        trials_table = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_' task_type '_data_proc.mat']);  trials_table = trials_table.([task_type '_data_table']);
        % remove practice.
        traj_table(traj_table{:,'practice'} >= 1, :) = [];
        traj_table_pre_norm(traj_table_pre_norm{:,'practice'} >= 1, :) = [];
        trials_table(trials_table{:,'practice'} >= 1, :) = [];
        traj = traj_table{:, traj_name};
        traj_pre_norm = traj_table_pre_norm{:, traj_name};

        bad_trials{iSub} = bad_trials_table;

        % Reshape to convenient format.
        traj_mat = reshape(traj, p.MAX_CAP_LENGTH, p.NUM_TRIALS, 3); % 3 for (x,y,z).
        traj_mat_pre_norm = reshape(traj_pre_norm, p.MAX_CAP_LENGTH, p.NUM_TRIALS, 3); % 3 for (x,y,z).

        % Screen result for each trial.
        successes = ones(p.NUM_TRIALS, length(screen_reasons));

        % Test every screen reason for each trial.
        for iTrial = 1:p.NUM_TRIALS
            success = ones(1, length(screen_reasons)); % 0 = bad trial.
            single_traj = squeeze(traj_mat(:,iTrial,:));
            single_traj_pre_norm = squeeze(traj_mat_pre_norm(:,iTrial,:));
    
            % Check if reaponse was too late.
            success(indx.late_res) = ~trials_table.late_res(iTrial);
            % Check if response was too early.
            success(indx.early_res) = ~trials_table.early_res(iTrial);
            % Check if stim display duration was bad.
            success(indx.bad_stim_dur) = testStimDur(dev_table, iTrial, iSub, p);
            % Check if answer is incorrect.
            success(indx.incorrect) = trials_table.target_correct(iTrial);
            % Check if sub quit before this trial.
            success(indx.quit) = ~trials_table.quit(iTrial);

            % Reaching screening.
            if is_reach
                % Check if mvmnt time is long.
                success(indx.slow_mvmnt) = ~trials_table.slow_mvmnt(iTrial);
                % Check if reach distance is too short.
                success(indx.short_traj) = testReachDist(single_traj_pre_norm, p);
                % Check if there is a big hole in the data.
                success(indx.hole_in_data) = testHoleData(single_traj, p);
                % Check if too much data is missing.
                success(indx.missing_data) = testAmountData(single_traj, p) &...
                    ~any(too_short_to_filter{:} == iTrial);
                % Check if finger missed target.
                if contains(traj_name{1}, '_to')
                    success(indx.missed_target) = testMissTarget(single_traj, p);
                end
            end
            % Store result.
            successes(iTrial, :) = success;
        end

        % Check "very slow mvmnt", considering previous screen results.
        for iTrial = 1:p.NUM_TRIALS
            success = successes(iTrial, :);
            
            if is_reach
                % Check if mvmnt time is TOO long.
                success(indx.very_slow_mvmnt) = testVerySlowMvmnt(trials_table, successes, indx, iTrial);
            end
            
            % Cancel unsuccess if it is caused by other unsuccess.
            success = cancelDuplicates(success, indx);
            
            fail = success * -1 + 1; % logical not, Can't use '~' because of nans.
            
            % Mark failed trials.
            bad_trials{iSub}{iTrial,:} = fail * iTrial;
        end

        % Mark if any test failed.
        bad_trials{iSub}.any = any(bad_trials{iSub}{:,1:end-1} > 0, 2); % OR between columns (reasons).
        bad_trials_i{iSub,'any'}{:,:} = find(bad_trials{iSub}{:,'any'});
        % save indices of bad trials.
        for iReason = 1:length(screen_reasons)-1
            bad_trials_i{iSub, iReason}{:,:} = find(bad_trials{iSub}{:,iReason});
        end
        % Count bad trials.
        n_bad_trials{iSub, :} = sum(bad_trials{iSub}{:,:} > 0, 1);
    end
end

% Some screening reasons cause other, Displaying both is redundant, so we remove one.
function success = cancelDuplicates(success, indx)
    success(indx.missing_data)  = success(indx.missing_data) |...
        ~(success(indx.short_traj) & success(indx.late_res) & success(indx.early_res));
    success(indx.missed_target) = success(indx.missed_target) |...
        ~(success(indx.short_traj) & success(indx.late_res) & success(indx.early_res) & success(indx.very_slow_mvmnt));
    success(indx.short_traj)    = success(indx.short_traj) |...
        ~(success(indx.late_res) & success(indx.very_slow_mvmnt) & success(indx.early_res));
    success(indx.slow_mvmnt)    = success(indx.slow_mvmnt) |...
        ~success(indx.very_slow_mvmnt);
    % traj isnt full , can't tell if ans is correct or not.
    if ~success(indx.short_traj) || ~success(indx.early_res) || ~success(indx.late_res)
        success(indx.incorrect) = nan;
    end
end