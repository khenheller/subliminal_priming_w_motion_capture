% Check if movement was 3STD slower than average MT across valid trials.
% trials_table - table with all the sub's trials, experiment's output.
% successes - rows=trials, column=screening reasons. Indicates which trials pass which screening reasons.
% indx - column of each screening reason. Each field is a boolean index for one reason.
% iTrial - num of trial to check.
function success = testVerySlowMvmnt (trials_table, successes, indx, iTrial)
    success = 1;
    
    % Find valid trial's index.
    important_reasons = indx.hole_in_data |...
                        indx.missing_data |...
                        indx.short_traj |...
                        indx.late_res | ...
                        indx.slow_mvmnt |...
                        indx.early_res |...
                        indx.incorrect |...
                        indx.quit;
    valid_trials = successes(:, important_reasons);
    % Only trials that passed all these tests.
    valid_trials = all(valid_trials, 2);
    valid_trials(iTrial) = 0;
    % Avg valid trials.
    mt_avg = mean(trials_table.offset(valid_trials) - trials_table.onset(valid_trials), 1);
    mt_std = std(trials_table.offset(valid_trials) - trials_table.onset(valid_trials), 1);
    % Current trial's MT.
    trial_mt = trials_table.offset(iTrial) - trials_table.onset(iTrial);

    % Check if MT is too long.
    if (trial_mt - mt_avg) > mt_std * 3
        success = 0;
    end
end