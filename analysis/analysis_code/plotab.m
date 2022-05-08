% Use to visualize 'a','b' graphs when there are problems.
% new_fig - open new one (1) or use existing (0).
% a,b - graphs to plot.
% atitle - a title to put on grpah.
% m,n,subplot_num - subplot func's inputs.
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