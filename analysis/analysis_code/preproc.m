% Receives a sibject's traj table and a single traj's name.
% Performs preprocessing and normalization on that traj and returns it.
% too_short - list of trials whos data was too short to use noise filtering.
function [traj_table, too_short] = preproc(traj_table, traj_name, p)
    time_name = replace(traj_name{1}, 'x', 'timecourse');
    too_short = zeros(p.NUM_TRIALS,1);
    
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
    traj_mat = trimOnsetOffset(traj_mat, p);
    
    %-------- Normalization --------
    % Fit using B-spline.
    [traj_mat, time_mat] = normalize(traj_mat, p);
    
    % Reassign to table.
    traj_table{:, traj_name} = reshape(traj_mat, p.MAX_CAP_LENGTH * p.NUM_TRIALS, 3);
    traj_table{:, time_name} = reshape(time_mat, p.MAX_CAP_LENGTH * p.NUM_TRIALS, 1);
    
    % Find trials that were too short to filter.
    too_short = find(~success);
end