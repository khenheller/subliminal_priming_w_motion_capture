% Fills NaNs in trajectory using inpaint_nsn.
% Receives: trajs_mat - a subject's trajectory, of 1 type (categot_to / categor_from / recog_to / recog_from).
%               3 Dim double matrix, row = sample, column = trial, 3rd dim = axis (x,y,z).
%               Each trial has MAX_CAP_LENGTH samples.
function trajs_mat = fillMissingData(trajs_mat, p)
    
    for iTrial = 1:p.NUM_TRIALS
        traj = squeeze(trajs_mat(:, iTrial, :)); % single trial.
        trial_length = find(~isnan(traj(:,1)), 1 ,'last'); % finds last sample.
        % Fills when trial length is longer than 1.
        if trial_length > 1
            traj(1:trial_length, :) = [inpaint_nans(traj(1:trial_length, 1))...
                inpaint_nans(traj(1:trial_length, 2))...
                inpaint_nans(traj(1:trial_length, 3))];
        end
        trajs_mat(:, iTrial, :) = traj;
    end
end