% Check if the processed trial is not at the defined length.
% traj - double matrix, row = sample, column for each axis(x,y,z).
function success = testDefinedLength (traj, p)
    trim_len = load([p.PROC_DATA_FOLDER '/trim_len.mat']);  trim_len = trim_len.trim_len;
    success = 1;
    traj = traj(:,1); % if data is missing in 1 axis, its missing in all of them.
    last_sample = find(~isnan(traj), 1, 'last');
    if (last_sample ~= trim_len)
        success = 0;
    end
end