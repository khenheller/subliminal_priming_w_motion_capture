% Receives two 2D graphs, calculates area between them.
% a,b - curves, 1st column = X values, 2nd column = Y values.
function area = calcArea(a, b)
    b = trimB(a,b);
    % Fit cubic spline to curve.
    a_f = fit(a(:,1), a(:,2), 'cubicspline');
    % 'a' and 'b' must have same x vals to calc area between.
    a = b;
    % Calc matching Y values.
    a(:,2) = a_f(a(:,1));
    % Finds intersect points. i,j are indices of points closest to intersect in 'a' and 'b' curves.
    [x0, y0, i_a, j_b] = intersections(a(:,1),a(:,2), b(:,1),b(:,2));
    % Add intersection points.
    for i = 1:length(i_a)
        rnd_i = floor(i_a(i)); % round.
        rnd_j = floor(j_b(i));
        a = [a(1:rnd_i, :); [x0 y0]; a(rnd_i+1:end, :)];
        b = [b(1:rnd_j, :); [x0 y0]; b(rnd_j+1:end, :)];
        i_a = i_a+1;
        j_b = j_b+1;
    end
    % Calc area.
    area = abs(trapz(a(:,1), abs(a(:,2)-b(:,2))));
end

function b = trimB(a,b)
    % We use interpolation to get Y values of 'a' for every X value of 'b'.
    % So we trim X values of 'b' that are outside the X range of 'a'.
    b_x = b(:,1);
    a_x = a(:,1);
    % Check direction of b.
    b_rising = b_x(1) < b_x(end);
    % Check if b extends over a.
    if min(b_x) < min(a_x)
        if b_rising
            min_thresh = find(b_x < min(a_x), 1, 'last') + 1;
            b = b(min_thresh : end, :);
        else
            min_thresh = find(b_x < min(a_x), 1) - 1;
            b = b(1 : min_thresh, :);
        end
    end
    if max(b_x) > max(a_x)
        if b_rising
            max_thresh = find(b_x > max(a_x), 1) - 1;
            b = b(1 : max_thresh, :);
        else
            max_thresh = find(b_x > max(a_x), 1, 'last') + 1;
            b = b(max_thresh : end, :);
        end
    end
end