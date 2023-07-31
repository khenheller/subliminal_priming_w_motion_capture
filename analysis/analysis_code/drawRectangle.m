% Receives points and draws a filled rectangle between these points and one of the axes.
% points - 2 rows = start/end of rectangle. Column for each rectangle.
% points_axis - the axis the points are on ('x'/'y').
% limits - [min, max] of the axis the points are NOT on. If points are on 'x', limit is for 'y'.
function [] = drawRectangle(points, points_axis, limits, plt_p)
    min_max = repmat(limits', 1, size(points,2));
    if points_axis == 'x'
        x = [points; flipud(points)];
        y = repelem(min_max, 2, 1);
    else
        y = [points; flipud(points)];
        x = repelem(min_max, 2, 1);
    end
    fill(x, y, 'k', 'FaceAlpha',plt_p.f_alpha / 2, 'EdgeColor','none');
end