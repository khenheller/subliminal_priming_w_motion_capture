% Calc the heading angle for each point along a trajectory.
% Angle is estimated in the X,Z plane (2D).
% Angle between a line connecting the previous point and the current,
% and a line perpendicular to the screen.
% Angle is negative if it points to the side opposite to the final answer.
function traj_table = calcHeadAngle(traj_table, prenorm_traj_table, p)
    traj_len = load([p.PROC_DATA_FOLDER '/trim_len.mat']);  traj_len = traj_len.trim_len;
    angles_mat = nan(traj_len, p.NUM_TRIALS);

    % Reshape to convinient format.
    trajs = traj_table{:,{'target_x_to', 'target_y_to', 'target_z_to'}};
    prenorm_trajs = prenorm_traj_table{:,{'target_x_to', 'target_y_to', 'target_z_to'}};
    traj_mat = reshape(trajs, traj_len, p.NUM_TRIALS, 3);
    prenorm_traj_mat = reshape(prenorm_trajs, p.REACH_MAX_RT_LIMIT, p.NUM_TRIALS, 3);

    for iTrial = 1:max(traj_table{:, 'iTrial'})
        traj = squeeze(traj_mat(:, iTrial, :));
        prenorm_traj = squeeze(prenorm_traj_mat(:, iTrial, :));
        % Calc angle at each point on traj.
        head_angles = getAngle(traj, traj_len);
        % Find sign of angle.
        signs = getAngleSign(traj, prenorm_traj, traj_len, p);
        head_angles = abs(head_angles) .* signs;
        angles_mat(:, iTrial) = head_angles;
    end
    angles = reshape(angles_mat, traj_len * p.NUM_TRIALS, 1);
    traj_table{:, 'head_angle'} = angles;
end

% Computes the angle at each point along the traj with arc tan.
% Angle of first datapoitn is 0.
% traj - of a single trial.
function [angles] = getAngle(traj, traj_len)
    angles = zeros(traj_len, 1);
    % Find the opposite and adjacent edges to the angle.
    opposites = traj(2:end, 1) - traj(1:end-1, 1); % X component.
    adjacents = traj(2:end, 3) - traj(1:end-1, 3); % Z component.
    tangents = opposites ./ adjacents;
    angles(2:end) = atand(tangents); % Angle at first sample is unkown.
end

% Checks angles sign (pos / neg).
% Negative if the extension of the tangent meets the screen at
% the side opposite to the chosen answer.
% Sign of first data point is 1.
% Intersection with screen depends on dist from screen. Should depend only on movement to/away from answer.
% Would be better to implement a correction (setting very large screen dist, or check finger direction according delta X),
% but the current way matches the OSF pre-reg, so I kept it.
% traj - matrix of a single traj (traj_len, 3).
% signs - tells if each point along traj is pos or neg (1 / -1).
function [signs] = getAngleSign(traj, prenorm_traj, traj_len, p)
    signs = ones(traj_len, 1);
    screen_z_pos = p.NORM_TRAJ * 1 + ~p.NORM_TRAJ * (p.LEFT_END_POINT(3) - p.START_POINT(3)); 

    for iSample = 2:traj_len
        % Define two points the tangent line goes through.
        x = [traj(iSample, 1), traj(iSample-1, 1)];
        z = [traj(iSample, 3), traj(iSample-1, 3)];
        % Define two points the screen goes through.
        screen_x = [-0.01 0.01];
        screen_z = [screen_z_pos screen_z_pos];
        % find intersection.
        [inter_x, ~] = mathIntersect(x,z, screen_x,screen_z);
        % If intersection sign is diff than last sample sign, angle is neg.
        last_sample = find(~isnan(prenorm_traj(:,1)), 1,'last');
        if (inter_x < 0) ~= (prenorm_traj(last_sample, 1) < 0)
            signs(iSample) = -1;
        end
    end
end