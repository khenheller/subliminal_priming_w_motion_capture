% Prints data as violin plot, with 'space' between each category.
% colors - color of each plot (e.g. 'r', or [0.1 0.55 0.3]).
% beesdata - cell array, each slot is a graph.
function [] = printBeeswarm(beesdata, yLabel, names, colors, space, title_name)
    x_val = 1 : space : length(beesdata)*space;
    marker_shape = repmat({'o'}, 1, length(beesdata));
    % plot beeswarm.
    h = plotSpread(beesdata,'yLabel',yLabel, 'xNames',names,...
        'distributionMarkers', marker_shape, 'spreadWidth',4, 'xMode','manual', 'xValues',x_val);
    means = cellfun(@mean, beesdata);
    stds = cellfun(@std, beesdata);
    for i = 1:length(beesdata)
        set(h{1,1}(i,1),'MarkerFaceColor',colors{i},'MarkerEdgeColor','k', 'markersize', 8);
        % plot mean.
        plot([x_val(i)-space/3; x_val(i)+space/3],[means(i); means(i)], 'color',colors{i}, 'LineWidth',5);
    end
    % plot std.
    errorbar([x_val; x_val],[means; means],[stds; stds], 'k.', 'CapSize',20, 'LineWidth',2);
    title(title_name);
    set(gca,'FontSize',14);
end