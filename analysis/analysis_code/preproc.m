% Receives a subject's traj and data tables and a single traj's name.
% Performs preprocessing and normalization on that traj and returns it.
% Adds movement onset and offset time to each trial in data_table.
% too_short - list of trials whos data was too short to use noise filtering.
% pre_norm_traj_table - table with the trajectory after preprocessing but before normalization.
function [traj_table, data_table, too_short, pre_norm_traj_table] = preproc(traj_table, data_table, traj_name, p)
    time_name = replace(traj_name{1}, 'x', 'timecourse');
    too_short = zeros(p.NUM_TRIALS,1);
    
    onset_col  = ['onset']; % name of time onset column.
    offset_col = ['offset'];
    onset_idx_col  = ['onset_idx'];
    offset_idx_col = ['offset_idx'];

    pre_norm_traj_table = traj_table;
    
    % Traj of interest.
    traj = traj_table{:, traj_name};
    time = traj_table{:, time_name};
    % Reshape to convinient format.
    traj_mat = reshape(traj, p.MAX_CAP_LENGTH, p.NUM_TRIALS, 3); % 3 for (x,y,z).
    time_mat = reshape(time, p.MAX_CAP_LENGTH, p.NUM_TRIALS);
    
    %-------- Preprocessing --------
    % Fill missing samples.
    traj_mat = fillMissingData(traj_mat, p);
    % Low pass filter.
    [traj_mat, success] = filterTraj(traj_mat, p);
    % Set origin at first sample.
    [traj_mat, time_mat] = setOrigin(traj_mat, time_mat);
    % Trim to onset and offset.
    [traj_mat, onsets, offsets, onsets_idx, offsets_idx] = trimOnsetOffset(traj_mat, time_mat, p);
    pre_norm_traj_mat = traj_mat;

    %-------- Normalization --------
    % Fit using B-spline.
    [traj_mat, time_mat] = normalize(traj_mat, p);
    
    % Reassign to table.
    pre_norm_traj_table{:, traj_name} = reshape(pre_norm_traj_mat, p.MAX_CAP_LENGTH * p.NUM_TRIALS, 3);
    traj_table{:, traj_name} = reshape(traj_mat, p.MAX_CAP_LENGTH * p.NUM_TRIALS, 3);
    traj_table{:, time_name} = reshape(time_mat, p.MAX_CAP_LENGTH * p.NUM_TRIALS, 1);
    data_table{:, onset_col}  = onsets;
    data_table{:, offset_col} = offsets;
    data_table{:, onset_idx_col}  = onsets_idx;
    data_table{:, offset_idx_col} = offsets_idx;
    
    % Find trials that were too short to filter.
    too_short = find(~success);
end