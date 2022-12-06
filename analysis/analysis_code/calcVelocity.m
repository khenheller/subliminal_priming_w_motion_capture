% Calc the velocity for all participant's trial.
function [traj_table] = calcVelocity(traj_table, p)
traj_len = load([p.PROC_DATA_FOLDER '/trim_len.mat']);  traj_len = traj_len.trim_len;
% Reshape to convineint format.
x_mat = reshape(traj_table.target_x_to, traj_len, p.NUM_TRIALS);
vel_mat = NaN(traj_len, p.NUM_TRIALS);
vel_mat(1,:) = 0;
for iTrial = 1:p.NUM_TRIALS
    trial_x = x_mat(:, iTrial);
    % Calc velocity.
    vel_mat(2:end, iTrial) = (trial_x(2:end) - trial_x(1:end-1)) / p.REF_RATE_SEC;
    % Change sign, moving to endpoint is positive.
    last_sample = find(~isnan(trial_x), 1, 'last');
    if trial_x(last_sample) < 0
        vel_mat(:, iTrial) = vel_mat(:, iTrial) * -1;
    end
end
% Reshape.
traj_table.vel = reshape(vel_mat, traj_len * p.NUM_TRIALS, 1);
end