% Receives a single subjects single type of trajectory and return b-spline func fit to it,
% and a list of points equally spaced in time on the trajectories.
% Receives: traj - a subject's trajectory, of 1 type (categot_to / categor_from / recog_to / recog_from).
%               double matrix, each column represent axis (x,y,z), each row represents a sample,
%               multiple trials in a signle column, each trial has MAX_RECORD_LENGTH samples.
% returns: b-spline - matrix of structs, 3 functions (sctructs) for each trial (because: x, y, z),
%                   each row is a trial.
%           traj - same as input, but has equal amount of readings for each trial (rest is NaN) 
%                   which are equally spaced in time within the trial.
function [b_spline, traj] = fitBspline(traj, p)
    k = 6; % order of b-spline.
    num_points = 200; % num of samples from traj.
    
    fields = {'form','knots','coefs','number','order','dim'};
    empty_cell = cell(6, 480);
    b_spline = cell2struct(empty_cell, fields);
    b_spline = [b_spline b_spline b_spline];
    
    traj_mat = reshape(traj, p.MAX_RECORD_LENGTH, p.NUM_TRIALS, 3); % 3: x,y,z dim.
    % Iterate over dimensions.
    for iDim = 1:3
        for iTrial = 1 : p.NUM_TRIALS
            % Current traj.
            trial_traj = squeeze(traj_mat(:, iTrial, iDim));
            trial_length = find(~isnan(trial_traj), 1, 'last');
            trial_traj = trial_traj(1 : trial_length);
            % B spline.
            knots = 1 : trial_length;
            b_spline(iTrial, iDim) = spap2(knots, k, knots, trial_traj);
            % Points equally spaced in time.
            points = fnval(b_spline(iTrial, iDim), linspace(1, trial_length, num_points)');
            traj_mat(:, iTrial, iDim) = [points; NaN(p.MAX_RECORD_LENGTH - num_points, 1)];
            %@@@@@@@@@@@@@@@@ Remove, linear interp @@@@@@@@@@@@@@@@@@@@@@@@
%             points = interp1(1:trial_length, trial_traj, linspace(1, trial_length, num_points)');
%             traj_mat(:, iTrial, iDim) = [points; NaN(p.MAX_RECORD_LENGTH - num_points, 1)];
            %@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
        end
    end
    traj = reshape(traj_mat, p.MAX_RECORD_LENGTH * p.NUM_TRIALS, 3);
end