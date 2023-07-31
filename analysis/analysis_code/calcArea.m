% Receives two 2D graphs, calculates area between them:
% Calc area between 'a' and h_line (horizontal line), and 'b' and h_line,
% and subtract areas to receive area between 'a' and 'b'.
% a,b - curves, 1st column = X values, 2nd column = Y values.
function area = calcArea(a, b)
    % Find graph with smallest Y.
    b_is_small = min(b(:,2)) < min(a(:,2));
    % Put it in 'a'.
    if b_is_small
        temp = a;
        a = b;
        b = temp;
    end
    min_y = min(a(:,2));

    % Trim 'b' X vals to the range in 'a' X vals:
    % We don't want 'b' to extend much over 'a' (in X), because then the area between
    % 'b' and 'h_line' would have an extra section that isn't included in 'a'.
    b = trimGrpah(a, b);

    % Create horizontal line on smallest Y val.
    h_line = min_y;

    % Area changes sign after intersection, but we want it positive all the way.
    % So we split graphs in intersections, calc area for each segment seperatly.
    % Find intersections:
    [xi,yi, ii] = polyxpoly(a(:,1),a(:,2),b(:,1),b(:,2));
    i_a = ii(:,1);
    i_b = ii(:,2);
    [i_a, idx] = sort(i_a);
    i_b = i_b(idx);
    % Segment according to intersections, get start and end of each segment.
    points_a = [1; round(i_a); height(a)];
    points_b = [1; round(i_b); height(b)];

    seg_area = zeros(length(points_a)-1, 1);

    % Iterate over segments.
    for j = 1:length(points_a)-1
        % Loops create segments of length=1, this rises an error in trapz. So we skip loops.
        loop_in_graph = points_a(j) == points_a(j+1) || points_b(j) == points_b(j+1);
        % ----------------------------------- Perhaps can be removed --------------------------------------------------------------------------------------
        not_in_order = ~isequal(sort(points_a), points_a) || ~isequal(sort(points_b), points_b);
        if not_in_order
            error("The points_a/b isn't sorted, so the segments (between intersections) will not be calculated in their order. Not sure if thats bad or not.")
        end
        % -------------------------------------------------------------------------------------------------------------------------
        if ~loop_in_graph
            seg_a = a(points_a(j): points_a(j+1), :);
            seg_b = b(points_b(j): points_b(j+1), :);
            % Calc area.
            area_a = abs(trapz(seg_a(:,1), abs(seg_a(:,2)-h_line)));
            area_b = abs(trapz(seg_b(:,1), abs(seg_b(:,2)-h_line)));
            seg_area(j) = abs(area_b - area_a);
        end
    end
    area = sum(seg_area);
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