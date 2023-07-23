% Recieves Avg trajectory to left and right side.
% Calc area btween them.
% Input:
%   left/right - avg trajectory for reaches to one side.
%               3d array: (x,y,z)
% Output:
%   r_a - reach area.
function [r_a] = calcReachArea(left, right, p)
    % Convert to micro-meters.
    left(:,3) = left(:,3) * p.SCREEN_DIST * 100;
    right(:,3) = right(:,3) * p.SCREEN_DIST * 100;
    % If traj not normalized to Z, loops can occur in traj.
    % To avoid that, replaced Z with time (time can't reverse direction [unless a timemachine is at hand]).
    if ~p.NORM_TRAJ
        time_series = (1 : p.MAX_CAP_LENGTH) * p.SAMPLE_RATE_SEC; % Array with timing of each sample.
        last_sample_left = find(~isnan(left(:,3)), 1, 'last');
        last_sample_right = find(~isnan(right(:,3)), 1, 'last');
        % Verify traj length.
        assert(last_sample_left==last_sample_right, ['Cant compute area between trajectories of different length.',...
            '  Left traj len: ',num2str(last_sample_left), ...
            '  Right traj len: ',num2str(last_sample_right)]);
        left(1:last_sample_left, 3) = time_series(1:last_sample_left);
        right(1:last_sample_right, 3) = time_series(1:last_sample_right);
    end
    % Turn traj to 2D.
    left_2d = [left(:,3),  left(:,1)];
    right_2d = [right(:,3), right(:,1)];
    % Area between left and right trajs.
    r_a = calcArea(left_2d, right_2d);
end