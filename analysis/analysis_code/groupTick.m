% Adds ticks in heirarchy.
% ax - axes to draw on.
% ticks - x ticks in axes.
% labels - cell matrix with labels. Each row is a level of heirarchy.
%           exmp: {["a","b","c"]; ["one","two"]} would be:
%                   a  b  c  a  b  c 
%                     one      two
% dist - double vec. dist of each lvl from x axis.
% font_size - double vec. Of each level.
% draw_edges - draw lines on both sides of each group.
function ax = groupTick(ticks, labels, dist, font_size, draw_edges)
    % Default value for draw_edges.
    if nargin < 5
        draw_edges = 1;
    end

    set(gca,'XTickLabel',[], 'Clipping','off');
    y_lim = get(gca,'YLim');
    % Iterate over lvls.
    for i = 1:size(labels,1)
        % replicate label.
        n_rep = length(ticks) / length(labels{i});
        tick_labels = repmat(labels{i}, 1, n_rep);
        % draw labels.
        y_pos = (ones(1,length(ticks)) * min(y_lim)) - dist(i);
        text(ticks, y_pos, tick_labels, 'FontSize',font_size(i), 'HorizontalAlignment','center', 'VerticalAlignment','bottom');
        % draw lines.
        spaces = ticks(2:end) - ticks(1:end-1); % between ticks.
        x_pos = ticks(1:end-1) + spaces/2;
        line([x_pos; x_pos], [min(y_lim)*ones(1,length(spaces)); y_pos(1:end-1)], 'color','k', 'LineWidth',2);
        % draw edge lines.
        if i==size(labels,1) && draw_edges
            x_pos = [ticks(1) - spaces(1)/2, ticks(end) + spaces(end)/2];
            line([x_pos; x_pos], [min(y_lim) min(y_lim); y_pos(1:2)], 'color','k', 'LineWidth',2);
        end
        % Calc new ticks.
        ticks = reshape(ticks, length(labels{i}), n_rep)';
        ticks = mean(ticks, 2)';
    end
    ylim(y_lim);
end