% Recieves Avg trajectory to left and right side.
% Calc area btween them.
% Input:
%   left/right - avg trajectory for reaches to one side.
%               3d array: (x,y,z)
% Output:
%   r_a - reach area.
%   fail - fit was bad either because both graphs fliped, or because fit was bad.
function [r_a, fail] = calcReachArea(left, right, p)
    r_a = NaN;
    fail.both_flip = 0;
    fail.bad_fit = 0;
    % Turn traj to 2D.
    a = [left(:,3)  left(:,1)];
    b = [right(:,3) right(:,1)];
    
    % Find the graph that flips it's direction.
    dist_from_end = [abs(a(end,1) - a(:,1)), abs(b(end,1) - b(:,1))];
    flip_idx = dist_from_end(1:end-1, :) - dist_from_end(2:end, :) < 0;
    flip_exists = any(flip_idx, 1);
    % Both trajs flip, can't calc area.
    if isequal(flip_exists, [1 1])
        fail.both_flip = 1; disp('Both trajs flip, cant fit func.');
        return;
    % 'a' flips, so swap with 'b' since you can't interpolate a graph that flips.
    elseif isequal(flip_exists, [1 0])
        temp = a;
        a = b;
        b = temp;
    end
    
    % Area between left and right trajs.
    [r_a, a_fit, b_trim] = calcArea(a, b);
    
    % fitted extreme values? ("extreme" Criterion is specific for Khen's exp).
    if abs(max(a_fit(:,2)) - min(a_fit(:,2))) > p.DIST_BETWEEN_TARGETS * 1.5
        fail.bad_fit = 1; disp('Bad fit.')
        return;
    end
end