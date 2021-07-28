% Check if finger missed target on screen.
% traj - double matrix, row = sample, column for each axis(x,y,z).
function success = testMissTarget(traj, p)
    success = 1;
    % distance from starting point on Z axis.    
    dist_to_start = abs(traj(:,3) - traj(1,3));
    [~, traj_end] = max(dist_to_start);
    % Distance from right/left targets.
    right_dist = sqrt((traj(traj_end,1) - p.RIGHT_END_POINT(1))^2 + ...
        (traj(traj_end,2) - p.RIGHT_END_POINT(2))^2);
    left_dist = sqrt((traj(traj_end,1) - p.LEFT_END_POINT(1))^2 + ...
        (traj(traj_end,2) - p.LEFT_END_POINT(2))^2);
    % Check if distance from left/right target is too big.
    if right_dist > p.TARGET_MISS_RANGE && left_dist > p.TARGET_MISS_RANGE
        success = 0;
    end
end