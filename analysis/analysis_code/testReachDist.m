% Check if trial's reach distance is smaller than distance between starting point and screen.
% traj - double matrix, row = sample, column for each axis(x,y,z).
function success = testReachDist (traj, p)
    success = 1;
    z_col = 3;
    last_sample = find(~isnan(traj), 'last');
    if abs(traj(last_sample, z_col) - traj(1, z_col)) < p.MIN_REACH_DIST
        success = 0;
    end
    Search in all files for "dist", decide what should be moved to initConstants.
    
end