% Filters traj to cancel noise.
% Receives: trajs_mat - a subject's trajectory, of 1 type (categot_to / categor_from / recog_to / recog_from).
%               3 Dim double matrix, row = sample, column = trial, 3rd dim = axis (x,y,z).
%               Each trial has MAX_RECORD_LENGTH samples.
function [trajs_mat, success] = filterTraj(trajs_mat, p)
    
    order = 2;
    cutoff = [8, 12]; % in Hz.
    samprate = 100; % in Hz.
    
    success = zeros(p.NUM_TRIALS,1);
    
    for iTrial = 1 : p.NUM_TRIALS
        % Find last value in traj.
        trial_length = find(~isnan(trajs_mat(:, iTrial, 1)), 1, 'last');
        real_traj = squeeze(trajs_mat(1:trial_length, iTrial, :));
        % Filters only trials longer than 1.
        if trial_length > 1
            % Low pass on each axis.
            [real_traj(:, 1), success(iTrial)] = lowpass(real_traj(:, 1), samprate, cutoff, order);
            [real_traj(:, 2), ~] = lowpass(real_traj(:, 2), samprate, cutoff, order);
            [real_traj(:, 3), ~] = lowpass(real_traj(:, 3), samprate, cutoff, order);
        end
        % Assign back to matrix.
        trajs_mat(1:trial_length, iTrial, :) = real_traj;
    end
end