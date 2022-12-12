% Receives 2 lines (defined by 2 points each).
% Finds their intersection by building and comparing their equations.
% x1 - 2 x values ofthe first line.
% y1 - 2 y values ofthe first line.
function [inter_x, inter_y] = mathIntersect(x1, y1, x2, y2)
% fit a linear func to both lines.
line1_coef = polyfit(x1, y1, 1);
line2_coef = polyfit(x2, y2, 1);
% Find intersection with screen.
inter_x = (line1_coef(2) - line2_coef(2)) / (line2_coef(1) - line1_coef(1));
inter_y = line1_coef(1) * inter_x + line1_coef(2);
end