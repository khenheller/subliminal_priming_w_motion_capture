% Prints data as violin plot, with 'space' between each category.
% colors - color of each plot (e.g. 'r', or [0.1 0.55 0.3]).
% beesdata - cell array, each slot is a graph.
function [] = printBeeswarm(beesdata, names, colors, space, title_name)
    x_val = 1 : space : length(beesdata)*space;
    marker_shape = repmat({'o'}, 1, length(beesdata));
    h = plotSpread(beesdata,'yLabel','RT', 'xNames',names,...
        'distributionMarkers', marker_shape, 'spreadWidth',4, 'xMode','manual', 'xValues',x_val);
    for i = 1:length(beesdata)
        set(h{1,1}(i,1),'MarkerFaceColor',colors{i},'MarkerEdgeColor','k', 'markersize', 8);
    end
    means = cellfun(@mean, beesdata);
    plot([x_val-space/3; x_val+space/3],[means; means],'k','LineWidth',5); % plot mean.
    title(title_name);
    set(gca,'FontSize',14);
end