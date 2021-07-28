% Prints data as violin plot, with 'space' between each category.
% colors - color of each plot (e.g. 'r', or [0.1 0.55 0.3]).
% beesdata - cell array, each slot is plotted as a different group.
% type - want to draw 'std' / 'se' (standard error) / 'ci' (Coinfidence interval).
% a_val - alpha value when drawing CI.
function [] = printBeeswarm(beesdata, yLabel, xTickLabel, colors, space, title_name, type, a_val)
    prev_tick = max(get(gca, 'xTick'));
    xTick = prev_tick + space : space : prev_tick + length(beesdata)*space;
    marker_shape = repmat({'o'}, 1, length(beesdata));
    % plot beeswarm.
    h = plotSpread(beesdata,'yLabel',yLabel, 'xNames',xTickLabel,...
        'distributionMarkers', marker_shape, 'spreadWidth',space, 'xMode','manual', 'xValues',xTick);
    % Calc mean and std/se/ci.
    means = cellfun(@mean, beesdata);
    switch type
        case 'std'
            bar_size = cellfun(@(data) std(data), beesdata);
        case 'se'
            bar_size = cellfun(@(data) std(data)/sqrt(length(data)), beesdata);
        case 'ci'
            bar_size = cellfun(@(data) tinv(a_val, length(data)) * std(data) / sqrt(length(data)), beesdata);
        otherwise
            error('Wrong input, has to be: std/se/ci');
    end
    for i = 1:length(beesdata)
        set(h{1,1}(i,1),'MarkerFaceColor',colors{i},'MarkerEdgeColor','k', 'markersize', 8);
        % plot mean.
        plot([xTick(i)-space/3,  xTick(i)+space/3], [means(i) means(i)], 'color','k', 'LineWidth',7);
        plot([xTick(i)-space/3,  xTick(i)+space/3], [means(i) means(i)], 'color',colors{i}, 'LineWidth',5);
    end
    % plot std.
    errorbar([xTick; xTick],[means; means],[bar_size; bar_size], 'k.', 'CapSize',20, 'LineWidth',2);
    title(title_name);
    set(gca,'FontSize',14);
end