% Recieves Avg trajectory to left and right side.
% Calc area btween them.
% Input:
%   left/right - avg trajectory for reaches to one side.
%               3d array: (x,y,z)
% Output:
%   r_a - reach area.
function [r_a] = calcReachArea(left, right, p)
    % Convert to mili-meters.
    left(:,3) = left(:,3) * p.SCREEN_DIST * 10;
    right(:,3) = right(:,3) * p.SCREEN_DIST * 10;
    % Turn traj to 2D.
    left_2d = [left(:,3),  left(:,1)];
    right_2d = [right(:,3), right(:,1)];
    % Area between left and right trajs.
    r_a = calcArea(left_2d, right_2d);
end