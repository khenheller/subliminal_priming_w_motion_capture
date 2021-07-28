% Receives trials table (row=trial, col=variable), and name of trial num column.
% Checks if there are missing values in any trial,
% If so, prints them and return pass_test = 0;
% ATTENTION! NaN is considered empty value.
%           Must have trial num variable (in column trial_num_col).
% Can handle multiple lines for each trial if neccesary.
% trial_num_col_name: name of column with trials numbers.
function pass_test = hasValuesTest (trials, trial_num_col_name)
    pass_test = 1;
    
    trial_num_col = find(strcmp(trials.Properties.VariableNames, trial_num_col_name));
    % Finds all trials that have value.
    has_values = ~ismissing(trials(:,:),NaN);
    
    % Checks if missing trial nums.
    no_trial_num = find(~has_values(:,trial_num_col));
    if no_trial_num
        disp(['Trial num has no value in row' num2str(no_trial_num)]);
    end
    
    % Lists all trials that have a value.
    trial_num_mat = repmat(trials.(trial_num_col), 1, width(trials));
    trial_num_mat(~has_values) = 0;
    % for each var, checks all trial nums apear in trial_num_mat.
    for i = 1 : size(trial_num_mat,2)
        empty_trials{i} = setdiff(1 : max(trials.(trial_num_col)), trial_num_mat(:,i));
        % if has empty trials, prints them.
        if ~isempty(empty_trials{i})
            pass_test = 0;
            var = trials.Properties.VariableNames{i};
            disp([var ' has no values in trials: ' num2str(empty_trials{i})]);
        end
    end
end