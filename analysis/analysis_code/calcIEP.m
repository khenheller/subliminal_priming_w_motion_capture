% Calc implied end point (iEP) (intersection of tangent to current point with the screen)
% For every point in each trial.
% Currently saves only the X value of intersections.
function [traj_table] = calcIEP(traj_table, traj_name, p)
trim_len = load([p.PROC_DATA_FOLDER '/trim_len.mat']);  trim_len = trim_len.trim_len;
screen_z_pos = p.NORM_TRAJ * 1 + ~p.NORM_TRAJ * (p.LEFT_END_POINT(3) - p.START_POINT(3));
% Define two points on screen.
screen_x = [-0.1, 0.1];
screen_z = [screen_z_pos, screen_z_pos];

% Reshape.
traj_mat = reshape(traj_table{:, traj_name}, trim_len, p.NUM_TRIALS, 3);

ieps = NaN(trim_len, p.NUM_TRIALS);
ieps(1,:,:) = 0; % There is no direction in first sample.

for iTrial = 1:p.NUM_TRIALS
    traj = squeeze(traj_mat(:, iTrial,:));
    for iSamp = 2:trim_len
        % Define tangent to current point.
        tan_x = [traj(iSamp,1), traj(iSamp-1,1)];
        tan_z = [traj(iSamp,3), traj(iSamp-1,3)];
        % Find intersection with screen.
        [ieps(iSamp, iTrial), ~] = mathIntersect(tan_x,tan_z, screen_x,screen_z);
    end
end

% Furthest point from screen center that touch is accepted.
furthest_touch = p.DIST_BETWEEN_TARGETS/2 + p.TARGET_MISS_RANGE; % divide by two, because its dist form center.
% Crop iEPs that pass screen boundaries +-5%.
% See Dotan et al. (2016) "On the origins... " where iEP is corpped to +- of target boundary.
boundary = furthest_touch + furthest_touch * 0.05;
ieps(ieps > boundary) = boundary;
ieps(ieps < -boundary) = -boundary;

traj_table(:,'iep') = table(reshape(ieps(:,:), trim_len*p.NUM_TRIALS, 1));
end