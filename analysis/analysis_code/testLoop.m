% Check if trial has loop in traj (traj goes forward and then backwards).
% traj - double matrix, row = sample, column for each axis(x,y,z).
function success = testLoop (traj)
    success = 1;
    last_samp = find(~isnan(traj(:,1)), 1, 'last');
    % Increasing values on Z axis.
    if traj(last_samp,3) > traj(1,3)
        % Some values are decreasing, so there is a loop.
        if ~isequal(sort(traj(:,3)), traj(:,3))
            success = 0;
        end
    % Decreasing values on Z axis.
    else
        % Some values are increasing, so there is a loop.
        if ~isequal(sort(traj(:,3), 'descend'), traj(:,3))
            success = 0;
        end
    end
end