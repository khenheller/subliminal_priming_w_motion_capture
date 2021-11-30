% Receives two 2D graphs, calculates area between them:
% Trim 'b' X vals to the range in 'a' to prevent extrapulation.
% We need equal X vals in 'a' and 'b', so we fit func to 'a', and than get
% the Y vals that match 'b's X vals with interpolation.
% Input: 
%   a,b - curves, 1st column = X values, 2nd column = Y values.
% Output:
%   area - area, da...
%   a - X = b's X vals. Y = interpolated values.
%   b - Trimmed X to the range of 'a' X vals (before fit).
function [area, b, a]  = calcArea(a, b)
    % Trim 'b' X vals to the range in 'a' X vals.
    b = trimGrpah(a, b);
    % Finds intersect points. i,j are indices of points closest to intersect in 'a' and 'b' curves.
    [x0, y0, i_a, j_b] = intersections(a(:,1),a(:,2), b(:,1),b(:,2));
    % Add intersection points.
    for i = 1:length(i_a)
        rnd_i = floor(i_a(i)); % round.
        rnd_j = floor(j_b(i));
        a = [a(1:rnd_i, :); [x0(i) y0(i)]; a(rnd_i+1:end, :)];
        b = [b(1:rnd_j, :); [x0(i) y0(i)]; b(rnd_j+1:end, :)];
        i_a = i_a+1;
        j_b = j_b+1;
    end
    % Fit cubic spline to curve.
    a_f = fit(a(:,1), a(:,2), 'cubicspline');
    % 'a' and 'b' must have same x vals to calc area between.
    a = b;
    % Calc matching Y values.
    a(:,2) = a_f(a(:,1));
    % Calc area.
    area = abs(trapz(a(:,1), abs(a(:,2)-b(:,2))));
end

% Trim X values of graph 'd' that are outside the X range of grpah 'c'.
function d = trimGrpah(c,d)
    d_x = d(:,1);
    c_x = c(:,1);
    % Check direction of b.
    d_rising = d_x(1) < d_x(end);
    % Check if b extends over a.
    if min(d_x) < min(c_x)
        if d_rising
            min_thresh = find(d_x < min(c_x), 1, 'last') + 1;
            d = d(min_thresh : end, :);
        else
            min_thresh = find(d_x < min(c_x), 1) - 1;
            d = d(1 : min_thresh, :);
        end
    end
    if max(d_x) > max(c_x)
        if d_rising
            max_thresh = find(d_x > max(c_x), 1) - 1;
            d = d(1 : max_thresh, :);
        else
            max_thresh = find(d_x > max(c_x), 1, 'last') + 1;
            d = d(max_thresh : end, :);
        end
    end
end