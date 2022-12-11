function [] = plotMultiVelProf(p)
vel_dist = load([p.PROC_DATA_FOLDER '/vel_dist_' p.DAY '_subs_' p.SUBS_STRING '.mat']);  vel_dist = vel_dist.vel_dist;
plot(vel_dist{:,:}, 'LineWidth',2);

set(gca, 'TickDir','out');
xlabel('Velocity Thresh(m/s)');
ylabel('% Trials above thresh');
% ylim(ylimit);
title('Velocity profile, all trials of all subs');
set(gca, 'FontSize',14);
% Legend.

win_bounds = replace(vel_dist.Properties.VariableNames, 'win','');
win_bounds = ["0", win_bounds];
win_range = strcat(win_bounds(1:end-1),'-',win_bounds(2:end));
graphs = strcat(win_range, ' ms');
legend(graphs, 'Location','northeast');
legend('boxoff');
end