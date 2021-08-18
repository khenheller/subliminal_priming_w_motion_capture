% Get 'deviating trials table', and trial num and check if stimuly display
% duration was fault during that trial.
function success = testStimDur(dev_table, trial_num)
    success = 0;
    % Looks if trial is in bad deviations table.
    trial_index = find(ismember(dev_table.TrialNum, trial_num));
    % If there is a deviation then success is 0.
    success = isempty(dev_table.Event(trial_index));
end