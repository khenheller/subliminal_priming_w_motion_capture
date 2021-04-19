% Normalizes all trials in a single type of traj.
% Receives: trajs_mat - a subject's trajectory, of 1 type (categot_to / categor_from / recog_to / recog_from).
%               3 Dim double matrix, row = sample, column = trial, 3rd dim = axis (x,y,z).
%               Each trial has MAX_CAP_LENGTH samples.
% Returns: traj_mat - normalized traj.
%           time_mat - New timestamps that match each sample in the normalized traj.
%                       double matrix, row=smaple, column=trial.
function [traj_mat, time_mat] = normalize(traj_mat, p)
    time_mat = NaN(p.MAX_CAP_LENGTH, p.NUM_TRIALS);
    for iTrial = 1:size(traj_mat,2)
        current_traj = squeeze(traj_mat(:,iTrial,:));
        current_traj(isnan(current_traj(:,1)), :) = [];% remove nans.
        % Normalize when trial longer than 2 samples (otherwise normalizeFDA doesn't work).
        if size(current_traj,1) > 2
            [norm_traj, norm_time] = normalizeFDA({current_traj}, 1, p.NORM_FRAMES, p.NORM_TYPE, p.SAMPLE_RATE_HZ);
            traj_mat(:, iTrial, :) = NaN;
            traj_mat(1:p.NORM_FRAMES, iTrial, :) = norm_traj{1}(:, 1:3); %1:3 are position, 4:6 are velocity
            time_mat(1:p.NORM_FRAMES, iTrial) = norm_time;
        end
    end
end