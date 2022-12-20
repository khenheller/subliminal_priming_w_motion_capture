% Finds the maximal ABSOLUTE velocity in each trial.
function [data_table] = calcMaxVel(traj_table, data_table, p)
assert(~p.NORM_TRAJ, "Velocity isnt relevant when trajectory is normalized in space.");
traj_len = load([p.PROC_DATA_FOLDER '/trim_len.mat']);  traj_len = traj_len.trim_len;
target_col = 'max_vel'; % To which values will be assigned.

% Reshape.
vel_vec = traj_table{:, 'vel'};
vel_mat = reshape(vel_vec, traj_len, p.NUM_TRIALS);
max_vel = NaN(p.NUM_TRIALS,1);
% Fidn max velocity.
for iTrial = 1:p.NUM_TRIALS
    max_vel(iTrial) = max(abs(vel_mat(:,iTrial)));
end
data_table.(target_col) = max_vel;
end