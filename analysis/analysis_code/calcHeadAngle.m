% Calc the heading angle for each point along a trajectory.
% Angle is estimated in the X,Z plane (2D).
% Angle between a line connecting the previous point and the current,
% and a line perpendicular to the screen.
% Angle is negative if it points to the side opposite to the final answer.
function traj_table = calcHeadAngle(traj_table, p)
    traj_len = load([p.PROC_DATA_FOLDER '/trim_len.mat']);  traj_len = traj_len.trim_len;
    angles_mat = nan(traj_len, p.NUM_TRIALS);

    % Reshape to convinient format.
    trajs = traj_table{:,{'target_x_to', 'target_y_to', 'target_z_to'}};
    traj_mat = reshape(trajs, traj_len, p.NUM_TRIALS, 3);

    for iTrial = 1:max(traj_table{:, 'iTrial'})
        traj = squeeze(traj_mat(:, iTrial, :));
        % Calc angle at each point on traj.
        head_angles = getAngle(traj, traj_len, p);
        % Find sign of angle.
        signs = getAngleSign(traj, traj_len, p);
        head_angles = head_angles .* signs;

        angles_mat(:, iTrial) = head_angles;
    end
    angles = reshape(angles_mat, traj_len * p.NUM_TRIALS, 1);
    traj_table{:, 'head_angle'} = angles;
end

% Computes the angle at each point along the traj with arc tan.
% Angle of first datapoitn is 0.
% traj - of a single trial.
function [angles] = getAngle(traj, traj_len, p)
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
% traj - matrix of a single traj (traj_len, 3).
% signs - tells if each point along traj is pos or neg (1 / -1).
function [signs] = getAngleSign(traj, traj_len, p)
    signs = ones(traj_len, 1);
    assert((traj(end, 3) > traj(1,3)) || isnan(traj(end, 3)), "Expcects Z axis to go from start point (0) to screen (1)."); % Look at screen points below.
    screen_dist = p.NORM_TRAJ * 100 + ~p.NORM_TRAJ * p.SCREEN_DIST; % Non/normalized diatance from start point.

    for iSample = 2:traj_len
        % Define two points the tangent line goes through.
        x = [traj(iSample, 1), traj(iSample-1, 1)];
        z = [traj(iSample, 3), traj(iSample-1, 3)];
        % Define two points the screen goes through.
        screen_x = [-0.01 0.01];
        screen_z = [screen_dist*-100000000 screen_dist*-100000000];
        [inter_x, ~] = mathIntersect(x,z, screen_x,screen_z);
        % Find sign.
        signs(iSample) = ((inter_x < 0 && traj(end, 1) < 0) || ...
                          (inter_x >= 0 && traj(end, 1) >= 0)) ...
                            * 2 - 1;
    end
end