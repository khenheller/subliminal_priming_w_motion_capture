% Check if trial's reach distance is smaller than distance between starting point and screen.
% traj - double matrix, row = sample, column for each axis(x,y,z).
function success = testReachDist (traj, p)
    success = 1;
    % We are only interested in Z coordinates.
    traj = traj(:,3);
    last_sample = find(~isnan(traj), 1, 'last');
    if abs(traj(last_sample) - traj(1)) < p.MIN_REACH_DIST
        success = 0;
    end    
end