% Receives trials table (row=trial, col=variable), and name of trial num column.
% Checks if there are missing values in any trial,
% If so, prints them and return pass_test = 0;
% ATTENTION! NaN is considered empty value.
%           Must have trial num variable (in column trial_num_col).
% Can handle multiple lines for each trial if neccesary. In which case NaNs will
%   pass the test if they are at the end of the trial
%   (e.g. [1 1 1 NaN] will pass, [1 NaN 1 1 NaN] will not).
% trial_num_col_name: name of column with trials numbers.
% miss_data: one hot, rows=trials, col=vars, 1 means trial has missing values.
function [pass_test miss_data] = hasValuesTest (trials, trial_num_col_name)
    pass_test = 1;
    
    num_vars = size(trials, 2);
    trial_num_col = find(strcmp(trials.Properties.VariableNames, trial_num_col_name));
    num_trials = max(trials.(trial_num_col));
    miss_data = zeros(num_trials, num_vars); % trials with missing values.
    
    % Checks if missing trial nums.
    no_trial_num = find(isnan(trials.(trial_num_col)));
    if no_trial_num
        disp('Trial num has no value in row (hasValuesTest will not run properly):');
        disp(num2str(no_trial_num));
        error('Read msg above');
    end
    
    for iVar = 1:num_vars
        for iTrial = 1:num_trials
            % Get single trial.
            trial = trials(trials.(trial_num_col) == iTrial, iVar);
            % Find end of trial.
            trial_end = find(~ismissing(trial,NaN), 1, 'last');
            % NaNs at end of trial are fine, so fill them.
            trial(trial_end+1 : end,1) = trial(trial_end,1);
            % If there are NaNs at beginning or middle of trial, test failed.
            if ~isempty(find(ismissing(trial), 1))
                pass_test = 0;
                miss_data(iTrial,iVar) = 1;
            end
        end
        % if variable has trials with missing values, prints them.
        if ~isempty(find(miss_data(:,iVar),1))
            var = trials.Properties.VariableNames{iVar};
            disp([var ' is missing values in trials: ']);
            disp(find(miss_data(:,iVar)));
        end
    end
end