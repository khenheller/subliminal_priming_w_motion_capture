% Check if trial has more 100ms of NaN data (NaN after the last
% smaple of the traj doesn't count included).
% traj - double matrix, row = sample, column for each axis(x,y,z).
function success = testHoleData (traj, p)
    success = 1;
    traj = traj(:,1); % if data is missing in 1 axis, its missing in all of them.
    last_sample = find(~isnan(traj), 1, 'last');
    missing_data = find(isnan(traj(1:last_sample)));
    if (length(missing_data) * p.REF_RATE_SEC > p.MAX_MISSING_DATA)
        success = 0;
    end
end