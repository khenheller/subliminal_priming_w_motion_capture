% Normalizes all trials in a single type of traj.
% Assigns new timestamps that match each sample in the normalized traj.
function [traj_table] = normalize_trajs(iSub, traj_name, p)
    time_name = replace(traj_name{1}, 'x', 'timecourse');

    % Load data.
    pre_norm_traj_table = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_reach_pre_norm_traj.mat'], 'reach_pre_norm_traj_table');  pre_norm_traj_table = pre_norm_traj_table.reach_pre_norm_traj_table;
    % Traj of interest.
    traj = pre_norm_traj_table{:, traj_name};
    % Reshape to convinient format.
    traj_mat = reshape(traj, p.MAX_CAP_LENGTH, p.NUM_TRIALS, 3); % 3 for (x,y,z).

    time_mat = NaN(p.MAX_CAP_LENGTH, p.NUM_TRIALS);
    for iTrial = 1:size(traj_mat,2)
        current_traj = squeeze(traj_mat(:,iTrial,:));
        current_traj(isnan(current_traj(:,1)), :) = [];% remove nans tail (nans at beginning or middle were filled).
        % Normalize when trial longer than 2 samples (otherwise normalizeFDA doesn't work).
        if size(current_traj,1) > 2
            [norm_traj, norm_time] = normalizeFDA({current_traj}, 1, p.NORM_FRAMES, p.NORM_TYPE, p.SAMPLE_RATE_HZ);
            traj_mat(:, iTrial, :) = NaN;
            traj_mat(1:p.NORM_FRAMES, iTrial, :) = norm_traj{1}(:, 1:3); %1:3 are position, 4:6 are velocity
            traj_mat(1:p.NORM_FRAMES, iTrial, 3) = (1:p.NORM_FRAMES) / p.NORM_FRAMES; % We normalize to Z so Z values should be % of trajectory traveled, instead of actual Z coordinate.
            time_mat(1:p.NORM_FRAMES, iTrial) = norm_time;
        end
    end

    traj_table = pre_norm_traj_table;
    traj_table{:, time_name} = reshape(time_mat, p.MAX_CAP_LENGTH * p.NUM_TRIALS, 1);
    traj_table{:, traj_name} = reshape(traj_mat, p.MAX_CAP_LENGTH * p.NUM_TRIALS, 3);
end