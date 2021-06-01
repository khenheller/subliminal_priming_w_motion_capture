% Finds trials that answered screening reasons:
%   Have too much missing data.
%   Reach distance too short.
%   Finger missed target.
% Output:
%   bad_trials - Cell for each sub, has table inside.
%               Table has row for each trial and column for each screening reason,
%               and a 'any' colum that indicates if any screen reason happend.
%   n_bad_trials - table, row for each sub, shows how many bad trials for each reason.
%   bad_trials_i - Cell for each sub, has table inside.
%               Table has list of disqualified trials for each screen reason.
%               bad_trials is logical indexing, this is numeric.
function [bad_trials, n_bad_trials, bad_trials_i] = trialScreen(traj_name, p)
    screen_reasons = {'missing_data','short_traj','missed_target','any'};
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
    
    too_short = load([p.PROC_DATA_FOLDER '/too_short_to_filter.mat'], 'too_short_to_filter');  too_short = too_short.too_short_to_filter;

    for iSub = p.SUBS
        too_short_to_filter = too_short{iSub, strrep(traj_name{1}, '_x', '')};
        
        traj_table = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) 'traj.mat']);  traj_table = traj_table.traj_table;
        % remove practice.
        traj_table(traj_table{:,'practice'} >= 1, :) = [];
        traj = traj_table{:, traj_name};

        bad_trials{iSub} = bad_trials_table;

        % Reshape to convenient format.
        traj_mat = reshape(traj, p.MAX_CAP_LENGTH, p.NUM_TRIALS, 3); % 3 for (x,y,z).

        for iTrial = 1:p.NUM_TRIALS
            success = ones(1, length(screen_reasons)); % 0 = bad trial.
            single_traj = squeeze(traj_mat(:,iTrial,:));
            % Check if too much data is missing.
            success(ismember(screen_reasons, 'missing_data')) = testAmountData(single_traj, p) &...
                ~any(too_short_to_filter{:} == iTrial);
            % Check if reach distance is too short.
            success(ismember(screen_reasons, 'short_traj')) = testReachDist(single_traj, p);
            % Check if finger missed target.
            if contains(traj_name{1}, '_to')
                success(ismember(screen_reasons, 'missed_target')) = testMissTarget(single_traj, p);
            end
            bad_trials{iSub}{iTrial,:} = ~success * iTrial;
        end

        % save indices of bad trials.
        for iReason = 1:length(screen_reasons)-1
            bad_trials_i{iSub, iReason}{:,:} = find(bad_trials{iSub}{:,iReason});
        end
        % Mark if any test failed.
        bad_trials{iSub}.any = any(bad_trials{iSub}{:,1:end-1} > 0, 2); % OR between columns (reasons).
        % Count bad trials.
        n_bad_trials{iSub, :} = sum(bad_trials{iSub}{:,:} > 0, 1);
    end
end