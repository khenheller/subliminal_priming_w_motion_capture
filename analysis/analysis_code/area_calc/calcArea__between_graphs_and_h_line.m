% Receives two 2D graphs, calculates area between them:
% Graphs need to have equal X vals, so we fit func to 'a', and than get
% the Y vals that match 'b's X vals with interpolation.
% BUT since 'a','b' can retract (go back and forth in X), we cant fit func to 'a'.
% INSTEAD: calc area between 'a' and h_line (horizontal line), and 'b' and h_line,
%           and subtract areas to receive area between 'a' and 'b'.
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
    [~, ~, i_a, i_b] = intersections(a(:,1),a(:,2), b(:,1),b(:,2));
    [i_a, idx] = sort(i_a);
    i_b = i_b(idx);
    % Segment according to intersections, get start and end of each segment.
    points_a = [1; round(i_a); height(a)];
    points_b = [1; round(i_b); height(b)];

    seg_area = zeros(length(points_a)-1, 1);

    % Iterate over segments.
    for j = 1:length(points_a)-1
        % Loops are skipped.
        loop_in_graph = points_a(j) == points_a(j+1) || points_b(j) == points_b(j+1);
        % -------------------------------------------------------------------------------------------------------------------------
        real_loop = ~isequal(sort(points_a), points_a) || ~isequal(sort(points_b), points_b);
        if real_loop
            error("The points_a/b isn't sorted, so the areas will not be calculated in their order.")
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
% ------------------------------------------
function [] = plotab(new_fig, a,b, atitle, m,n,subplot_num)
    if new_fig
        figure();
    end
    subplot(m,n,subplot_num);
    plot(a(:,1), a(:,2), 'b', 'LineWidth',3); hold on;
    plot(b(:,1), b(:,2), 'r', 'LineWidth',3);
    xlabel('X (meter)');% xlim([-1 8]);
    ylabel('Z (meter)');% ylim([-4 2]);
    title(atitle);
    grid on;
    legend('a', 'b');
end
% ------------------------------------------