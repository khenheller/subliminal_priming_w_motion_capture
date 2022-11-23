% Trim all trajs to a certain length (min_len). Trimmed values are replaced with NaNs.
function [traj_table] = trimToLength(iSub, min_len, traj_name, p)
time_name = replace(traj_name{1}, 'x', 'timecourse');

% Load data.
pre_norm_traj_table = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_reach_pre_norm_traj.mat'], 'reach_pre_norm_traj_table');  pre_norm_traj_table = pre_norm_traj_table.reach_pre_norm_traj_table;
% Traj of interest.
trajs = pre_norm_traj_table{:, traj_name};
time_vec = pre_norm_traj_table{:, time_name};
% Reshape to convinient format.
traj_mat = reshape(trajs, p.MAX_CAP_LENGTH, p.NUM_TRIALS, 3); % 3 for (x,y,z).
time_mat = reshape(time_vec, p.MAX_CAP_LENGTH, p.NUM_TRIALS);

% Trim all to minimal length.
traj_mat(min_len+1 : end, :, :) = NaN;
time_mat(min_len+1 : end, :) = NaN;

traj_table = pre_norm_traj_table;
traj_table{:, traj_name} = reshape(traj_mat, p.MAX_CAP_LENGTH * p.NUM_TRIALS, 3);
traj_table{:, time_name} = reshape(time_mat, p.MAX_CAP_LENGTH * p.NUM_TRIALS, 1);
end