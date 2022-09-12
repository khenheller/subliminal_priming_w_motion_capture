% Make a rain clouds plot.
function [] = makeItRain(beesdata, colors, title_char, yLabel, plt_p)
    box_color = [0.2 0.2 0.2];
    dodge_amount_1 = 0.20;
    dodge_amount_2 = 0.40;
    [~, ~, y_lims(1,:), x_lims(1,:)] = raincloud_plot(beesdata{1}, 'box_on',1, 'color',colors{1}, 'bxcl',box_color, 'alpha',plt_p.f_alpha, 'line_width',1,...
    'box_dodge',1, 'box_dodge_amount',dodge_amount_1, 'dot_dodge_amount',dodge_amount_1, 'box_col_match',0);
    [~, ~, y_lims(2,:), x_lims(2,:)] = raincloud_plot(beesdata{2}, 'box_on',1, 'color',colors{2}, 'bxcl',box_color, 'alpha',plt_p.f_alpha, 'line_width',1,...
    'box_dodge',1, 'box_dodge_amount',dodge_amount_2, 'dot_dodge_amount',dodge_amount_2, 'box_col_match',0);
    title(title_char);
    ylabel(yLabel);
    set(gca, 'FontSize',14);
    y_lims = [min(y_lims(:,1)), max(y_lims(:,2))];
    x_lims = [min(x_lims(:,1)), max(x_lims(:,2))];
    ylim([y_lims(1)-diff(y_lims)*0.1, y_lims(2)+diff(y_lims)*0.1]);
    xlim([x_lims(1)-diff(x_lims)*0.1, x_lims(2)+diff(x_lims)*0.1]);
end
