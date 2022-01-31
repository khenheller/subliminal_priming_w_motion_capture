% Get 'deviating trials table', and trial num and check if stimuly display
% duration was fault during that trial.
function success = testStimDur(dev_table, trial_num, sub_num, p)
    success = 0;
    % Version 2 of exp didn't limit target duration properly, so following subs had bad stimuli timing in almost all their trials:
    if ismember(sub_num, p.EXP_2_SUBS)
        dev_table(string(dev_table.Event) == "target_time",:) = [];
    end
    % Looks if trial is in bad deviations table.
    trial_index = find(ismember(dev_table.TrialNum, trial_num));
    % If there is a deviation then success is 0.
    success = isempty(dev_table.Event(trial_index));
end