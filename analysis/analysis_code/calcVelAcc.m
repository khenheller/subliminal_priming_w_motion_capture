% Calc the velocity/accelaration for a participant's trials.
% target - 'vel' / 'acc'. What are calculating.
function [traj_table] = calcVelAcc(prenorm_traj_table, traj_table, target, p)
traj_len = load([p.PROC_DATA_FOLDER '/trim_len.mat']);  traj_len = traj_len.trim_len;
if isequal(target, 'vel')
    src_col = 'target_x_to';
    trgt_col = 'vel';
else
    src_col = 'vel';
    trgt_col = 'acc';
end
% Reshape to convineint format.
value_mat = reshape(traj_table.(src_col), traj_len, p.NUM_TRIALS);
prenorm_x_mat = reshape(prenorm_traj_table{:,'target_x_to'}, p.REACH_MAX_RT_LIMIT, p.NUM_TRIALS);
deriv_mat = NaN(traj_len, p.NUM_TRIALS); % Derivative (vel / acc).
deriv_mat(1,:) = 0; % First sample has no vel/acc.
for iTrial = 1:p.NUM_TRIALS
    value = value_mat(:, iTrial);
    prenorm_traj = prenorm_x_mat(:, iTrial);
    % Calc vel or acc.
    deriv_mat(2:end, iTrial) = (value(2:end) - value(1:end-1)) / p.REF_RATE_SEC;
    % Make velocity positive when moving to endpoint.
    last_sample = find(~isnan(prenorm_traj(:)), 1, 'last');
    if isequal(target, 'vel') && prenorm_traj(last_sample) < 0
        deriv_mat(:, iTrial) = deriv_mat(:, iTrial) * -1;
    end
end
% Reshape.
traj_table.(trgt_col) = reshape(deriv_mat, traj_len * p.NUM_TRIALS, 1);

% Velocity is meaningless when traj is normalized in space.
if p.NORM_TRAJ
   traj_table.(trgt_col) = zeros(traj_len * p.NUM_TRIALS, 1);
end
end