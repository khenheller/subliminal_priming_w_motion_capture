% Gets single sub, 
% For each trial:
%   Set origin as the first reading's coordinates.
%   Rotate axes to be orthogonal to screen.
% Input: trials_traj - single sub's traj table.
function trials_traj = setOrigin(trials_traj)
    traj_n_time = trials_traj.(MULTI_ROW_VARS);
    
    % Find first reading in each trial.
    origins = traj_n_time(diff(trials_traj.(sub_num)) ~= 0);
end