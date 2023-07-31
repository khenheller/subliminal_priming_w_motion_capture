% Plots velocity or avg acceleration of all subs.
% plot_each_sub - Add another plot with each sub's avg.
% target - 'vel'/'acc'.
function [] = plotMultiVelAcc(target, traj_names, subplot_p, plot_each_sub, plt_p, p)
good_subs = load([p.PROC_DATA_FOLDER '/good_subs_' p.DAY '_' traj_names{1} '_subs_' p.SUBS_STRING '.mat']);  good_subs = good_subs.good_subs;

% Load data.
avg_each = load([p.PROC_DATA_FOLDER '/avg_each_' p.DAY '_' traj_names{1} '_subs_' p.SUBS_STRING '.mat']);  avg_each = avg_each.reach_avg_each;
con = avg_each.(target).con(:, good_subs);
incon = avg_each.(target).incon(:, good_subs);
values = [con, incon];
% Decide between time or Z.
if plt_p.x_as_func_of == "time"
    % Array with timing of each sample.
    x_axis = (1 : size(values,1))' * p.SAMPLE_RATE_SEC * 1000;
    x_label = 'Time (ms)';
    xlimit = [0 p.MIN_SAMP_LEN] * 1000;
else
    x_axis = avg_each.traj.con(:,good_subs(1),3)*100;
    assert(p.NORM_TRAJ, "Must use identical Z to all trajs to plot them. Assumes trajs are normalized.")
    x_label = '% Path Traveled';
    xlimit = [0 1];
end

if isequal(target,'vel')
    y_label = 'Velocity (m/s)';
    ylimit = [-0.06 0.6];
    graph_title = 'Velocity';
else
    y_label = 'Acceleration (m/s^2)';
    ylimit = [-0.06 6];
    graph_title = 'Acceleration';
end

% Plots each sub's avg.
if plot_each_sub
    subplot(subplot_p(1,1),subplot_p(1,2),subplot_p(1,3));
    yline(0, '--', 'color',[0.7 0.7 0.7]);
    hold on;
    plot(x_axis, con, 'color',[plt_p.con_col plt_p.f_alpha]);
    plot(x_axis, incon, 'color',[plt_p.incon_col plt_p.f_alpha]);
    
    set(gca, 'TickDir','out');
    xlabel(x_label);
    ylim(ylimit);
    title([graph_title ', avg of each sub']);
    % xticks([]);
    ylabel(y_label);
    set(gca, 'FontSize',14);
end

% Plot avg with shade.
subplot(subplot_p(2,1),subplot_p(2,2),subplot_p(2,3));
yline(0, '--', 'color',[0.7 0.7 0.7], 'LineWidth',2);
hold on;
stdshade(con', plt_p.f_alpha*0.9, plt_p.con_col, x_axis, 0, 1, plt_p.errbar_type, plt_p.alpha_size, plt_p.linewidth);
stdshade(incon', plt_p.f_alpha*0.9, plt_p.incon_col, x_axis, 0, 1, plt_p.errbar_type, plt_p.alpha_size, plt_p.linewidth);

% Permutation testing.
clusters = permCluster(avg_each.(target).con(:,good_subs), avg_each.(target).incon(:,good_subs), plt_p.n_perm, plt_p.n_perm_clust_tests);

% Plot clusters.
if ~isempty(clusters)
    points = [x_axis(clusters.start)'; x_axis(clusters.end)'];
    drawRectangle(points, 'x', ylimit, plt_p);
end

set(gca, 'TickDir','out');
xlabel(x_label);
ylim(ylimit);
xticks(plt_p.time_ticks);
xlim(xlimit);
ylabel(y_label);
title(graph_title);
set(gca, 'FontSize',plt_p.font_size);
set(gca, 'FontName',plt_p.font_name);
set(gca,'linewidth',plt_p.axes_line_thickness);
% Legend.
h = [];
h(1) = plot(nan,nan,'Color',plt_p.con_col, 'linewidth',plt_p.linewidth);
h(2) = plot(nan,nan,'Color',plt_p.incon_col, 'linewidth',plt_p.linewidth);
graphs = {'Congruent', 'Incongruent'};
% legend(h, graphs, 'Location','southeast');
% legend('boxoff');

% Print stats to terminal.
printTsStats(['---- ' target ' --------'], clusters);
end