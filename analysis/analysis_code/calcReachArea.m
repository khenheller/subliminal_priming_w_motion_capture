% Recieves Avg traj to left and right side on same and diff conds,
% Calcs area between left and right for each cond.
% Input:
%   left - avg trajectory for reaches to the left side in one condition.
%               3d array: x,y,z.
function [r_a] = calcReachArea(left, right)
% Turn traj to 2D.
left_2d  = [left(:,3)  left(:,1)];
right_2d = [right(:,3) right(:,1)];
% Area between left and right trajs.
r_a = calcArea(left_2d, right_2d);
end