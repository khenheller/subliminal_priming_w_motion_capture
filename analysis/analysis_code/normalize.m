% Normalizes all trials in a single type of traj.
% Receives: trajs_mat - a subject's trajectory, of 1 type (categot_to / categor_from / recog_to / recog_from).
%               3 Dim double matrix, row = sample, column = trial, 3rd dim = axis (x,y,z).
%               Each trial has MAX_RECORD_LENGTH samples.
function traj_mat = normalize(traj_mat, p)
    for iTrial = 1:size(traj_mat,2)
        current_traj = squeeze(traj_mat(:,iTrial,:));
        current_traj(isnan(current_traj(:,1)), :) = [];% remove nans.
        % Normalize when trial longer than 2 samples (otherwise normalizeFDA doesn't work).
        if size(current_traj,1) > 2
            norm_traj = normalizeFDA({current_traj}, 1, p.norm_frames, p.norm_type, p.sample_rate);
            traj_mat(:, iTrial, :) = NaN;
            traj_mat(1:p.norm_frames, iTrial, :) = norm_traj{1}(:, 1:3); %1:3 are psotion, 4:6 are velocity
        end
    end
end