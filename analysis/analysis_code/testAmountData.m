% Check if trial has less than 100ms of data.
% traj - double matrix, row = sample, column for each axis(x,y,z).
function success = testAmountData (traj, p)
    success = 1;
    traj = traj(:,1); % if data is missing in 1 axis, its missing in all of them.
    last_sample = find(~isnan(traj), 1, 'last');
    if (last_sample * p.REF_RATE_SEC < p.MIN_SAMP_LEN)
        success = 0;
    end
end