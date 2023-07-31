% Receives data of subjects in a beeswarm and connects the dots of each subject.
% The connecting line looks different for positive and negative slopes.
% x_data - column for each subject.
% y_data - column for each subject.
%           Each row is under adifferent label in the beeswarm.
function [] = connect_dots(x_data, y_data)
    linewidth = 2;
    % tranperency of lines.
    f_alpha = 0.2;
    % Line types for each slope.
    neg_slope = '--';
    pos_slope = '-';
    for j = 1:size(x_data,2)
        % Color line according to slope.
        line_style = neg_slope;
        if y_data(2,j) > y_data(1,j)
            line_style = pos_slope;
        end
        plot(x_data(:,j), y_data(:,j), 'LineStyle',line_style, 'Color',[0.1 0.1 0.1 f_alpha*1.1], 'LineWidth',linewidth);
    end
end