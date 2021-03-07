% Gets single sub, 
% For each trial:
%   Set origin as the first sample's coordinates.
%   Rotate axes to be orthogonal to screen.
%   Set each trial's first timestamp as time=0.
% Input: trials_traj - single sub's traj table.
function trials_traj = setOrigin(trials_traj)
    global MULTI_ROW_VARS
    global RECOG_CAP_LENGTH
    traj_n_time = trials_traj(:,MULTI_ROW_VARS);
    
    % Find first sample in each trial.
    first_sample_index = [true; (diff(trials_traj.('iTrial')) ~= 0)]; % finds changes in trial num.
    origins = traj_n_time{first_sample_index', :};
    % replicate origin, one for each of the trial's samples.
    origins_mat = repelem(origins, RECOG_CAP_LENGTH, 1);
    
    % Move axis origin to start point.
    % Set each trial's first timestamp as time=0.
    traj_n_time = traj_n_time{:,:} - origins_mat;
    
    trials_traj{:,MULTI_ROW_VARS} = traj_n_time;
end