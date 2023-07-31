% Recieves a subject's trajectories.
% Trims each trial to start at the movement onset and end at movemnt offset, fills the end of recording with NaNs.
% Onset criterion: the first out of 4 consequetive frames where each velocity towards screen was greater
%                   than threshold, and total acceleration was over a threshold.
% Offset criterion: first frame where [velocity dropped below threshold - not implemented] or
%                   position reached max.
% Receives: trajs_mat - a subject's trajectory, of 1 type (categot_to / categor_from / recog_to / recog_from).
%               3 Dim matrix of doubles, row = sample, column = trial, 3rd dim = axis (x,y,z).
%               Each trial has REACH_MAX_RT_LIMIT samples.
%           time_mat - a sub's timestamps mat. matching trajs_mat.
%                   row = sample, column = trial.
% Output: onsets_idx/offsets_idx - index of sample of movement initiation and finish.
%           onsets/offsets - time of of movement initiation and finish relatively to trial onset.
function [trajs_mat, onsets, offsets, onsets_idx, offsets_idx] = trimOnsetOffset(trajs_mat, time_mat, p)
    thresh.v = 0.02; % onset and offset velocity threshold (m/s).
    thresh.a = 0.02; % onset acceleration threshold (m/s^2).
    
    onsets  = NaN(p.NUM_TRIALS,1);
    offsets = NaN(p.NUM_TRIALS,1);
    onsets_idx  = NaN(p.NUM_TRIALS,1);
    offsets_idx = NaN(p.NUM_TRIALS,1);
    
    % calc velocity.
    dx = trajs_mat(2:end, :, :) - trajs_mat(1:end-1, :, :); % distance between 2 samples.
    vel_per_axis = dx / p.SAMPLE_RATE_SEC;
    vel = sqrt(sum(vel_per_axis.^2, 3));
    vel = [vel; NaN(1,p.NUM_TRIALS)]; % Round size.
    
    % trim each trial.
    for iTrial = 1:p.NUM_TRIALS
        trial_vel = vel(:, iTrial);
        trial_traj = squeeze(trajs_mat(:, iTrial, :));
        
        % Determine direction.
        last_sample = find(~isnan(trial_traj(:,3)), 1,'last');
        % Can't calc direction if traj len is 1.
        if last_sample > 1
            dist_from_end = abs(trial_traj(last_sample, 3) - trial_traj(1:last_sample, 3));
            direction = dist_from_end(1:end-1) < dist_from_end(2:end); % Dist from end at t=i is smaller than t=i+1, than moving backwords.
            direction = direction * -1; % Backwords = negative velocity.
            direction(direction == 0) = 1; % Forward, positive vel.
            direction(end+1:height(trial_vel), :) = 1; % Positive vel in last samples.
            % Apply direction to vel.
            trial_vel = trial_vel(1:length(direction)) .* direction;
        end

        % Lowpass filter velocity.
        trial_vel = filterVel(trial_vel, p);
        % Get Onset: velocity above threshoold.
        onset = getOnset(trial_vel, thresh);
        % Get Offset: velocity below threshoold or reached maximum position.
        offset = getOffset(trial_vel(onset:end), thresh, trial_traj(onset:end, 3));
        % remove values before onset.
        trial_traj = circshift(trial_traj, -onset+1, 1);
        trial_vel = circshift(trial_vel, -onset+1, 1);
        % remove values after offset.
        trial_traj(offset+1 : p.MAX_CAP_LENGTH, :) = NaN;
        trajs_mat(:, iTrial, :) = trial_traj;
        
        onsets(iTrial)  = time_mat(onset             , iTrial);
        offsets(iTrial) = time_mat(onset + offset - 1, iTrial); % Offset is relative to onset.
        onsets_idx(iTrial)  = onset;
        offsets_idx(iTrial) = onset + offset - 1; % Offset is relative to onset.
    end
end

% Lowpass filters velocity vector.
function trial_vel = filterVel(trial_vel, p)
    samprate = p.SAMPLE_RATE_HZ;
    cutoff = p.VEL_FILTER_CUTOFF;
    order = p.VEL_FILTER_ORDER;
    
    last_value = find(~isnan(trial_vel), 1, 'last');
    filtered_vel = trial_vel(1:last_value);
    
    % Filters only trials longer than 1.
    if last_value > 1
        [filtered_vel, ~] = lowpassFilt(trial_vel(1:last_value), samprate, cutoff, order);
    end
    trial_vel(1:last_value) = filtered_vel;
end

% Return onset index (according to onset criterion).
function onset = getOnset(velocities, thresh)
    % all indices that match criterion.
    onsets = velocities(1 : end-3) > thresh.v & ...
            velocities(2 : end-2) > thresh.v & ...
            velocities(3 : end-1) > thresh.v & ...
            velocities(4 : end) > thresh.v & ...
            (velocities(4 : end) - velocities(1 : end-3)) >= thresh.a;
    % Check if sub didn't move
    if isempty(find(onsets,1))
        onset = 1;
    else
        % send only the first.
        onset = find(onsets, 1);
    end
end
% Return offset index (according to offset criterion).
function offset = getOffset(velocities, thresh, z_traj)
    % Distance from start point.
    dist_start_point = abs(z_traj - z_traj(1));
    % all indices that match criterion.
%     offsets = (velocities < thresh.v) |...
%             (dist_start_point == max(dist_start_point));
    offsets = dist_start_point == max(dist_start_point);
    % Send only the first.
    offset = find(offsets, 1);
end