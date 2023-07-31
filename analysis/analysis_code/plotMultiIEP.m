% Plots the average Implied endpoint.
% plot_each_sub - Add another plot with each sub's avg.
% plt_p - struct of plotting params.
% p - struct of exp params.
function [] = plotMultiIEP(traj_names, subplot_p, plot_each_sub, plt_p, p)

good_subs = load([p.PROC_DATA_FOLDER '/good_subs_' p.DAY '_' traj_names{1}{1} '_subs_' p.SUBS_STRING '.mat']);  good_subs = good_subs.good_subs;

% Load avg over all subs.
subs_avg = load([p.PROC_DATA_FOLDER '/subs_avg_' p.DAY '_' traj_names{1}{1} '_subs_' p.SUBS_STRING '.mat']);  subs_avg = subs_avg.reach_subs_avg;
% Load avg of each sub.
avg_each = load([p.PROC_DATA_FOLDER '/avg_each_' p.DAY '_' traj_names{1}{1} '_subs_' p.SUBS_STRING '.mat']);  avg_each = avg_each.reach_avg_each;

% Convert to cm.
avg_each.iep.con_left(:,good_subs) = avg_each.iep.con_left(:,good_subs) * 100;
avg_each.iep.con_right(:,good_subs) = avg_each.iep.con_right(:,good_subs) * 100;
avg_each.iep.incon_left(:,good_subs) = avg_each.iep.incon_left(:,good_subs) * 100;
avg_each.iep.incon_right(:,good_subs) = avg_each.iep.incon_right(:,good_subs) * 100;

% Plot time instead of Z axis.
if plt_p.x_as_func_of == "time"
    assert(~p.NORM_TRAJ, "When traj is normalized in space, time isn't releveant and shouldnt be used");
    % Array with timing of each sample.
    time_series = (1 : size(subs_avg.iep.con_left,1)) * p.SAMPLE_RATE_SEC * 1000;
    left_axis = time_series;
    y_label = 'Time (ms)';
    xlimit = [-15 15]; % For plot.
    ylimit = [0 p.MIN_SAMP_LEN] * 1000;
else
    left_axis = subs_avg.traj.con_left(:,3)*100;
    assert(p.NORM_TRAJ, "Uses identical Z to all trajs, assumes trajs are normalized.")
    y_label = 'Path Traveled (%)';
    xlimit = [-25, 10];
    ylimit = [0 1];
end

% Plot each subs avg.
if plot_each_sub
    subplot(subplot_p(1,1), subplot_p(1,2), subplot_p(1,3));
    hold on;
    plot(avg_each.iep.con(:,good_subs), left_axis, 'color',[plt_p.con_col, plt_p.f_alpha]);
    plot(avg_each.iep.incon(:,good_subs), left_axis, 'color',[plt_p.incon_col, plt_p.f_alpha]);
    xline(0, '--', 'color',[0.7,0.7,0.7], 'LineWidth',2);
    
    set(gca, 'TickDir','out');
    xlabel('X (cm)');
    xlim(xlimit);
    ylabel(y_label);
    title('iEP, each sub avg');
    set(gca, 'FontSize',14);
end

% Plot avg with shade.
subplot(subplot_p(2,1), subplot_p(2,2), subplot_p(2,3));
hold on;
stdshade(avg_each.iep.con_left(:,good_subs)', plt_p.f_alpha*0.9, plt_p.con_col, left_axis, 0, 0, plt_p.errbar_type, plt_p.alpha_size, plt_p.linewidth);
stdshade(avg_each.iep.con_right(:,good_subs)', plt_p.f_alpha*0.9, plt_p.con_col, left_axis, 0, 0, plt_p.errbar_type, plt_p.alpha_size, plt_p.linewidth);
stdshade(avg_each.iep.incon_left(:,good_subs)', plt_p.f_alpha*0.9, plt_p.incon_col, left_axis, 0, 0, plt_p.errbar_type, plt_p.alpha_size, plt_p.linewidth);
stdshade(avg_each.iep.incon_right(:,good_subs)', plt_p.f_alpha*0.9, plt_p.incon_col, left_axis, 0, 0, plt_p.errbar_type, plt_p.alpha_size, plt_p.linewidth);
% xline(0, '--', 'color',[0.7,0.7,0.7], 'LineWidth',2);

% Permutation testing.
clusters = permCluster(avg_each.iep.con(:,good_subs,1), avg_each.iep.incon(:,good_subs,1), plt_p.n_perm, plt_p.n_perm_clust_tests);

% Plot clusters.
points = [left_axis(clusters.start)'; left_axis(clusters.end)'];
if ~isempty(points)
    drawRectangle(points, 'y', xlimit, plt_p);
end

set(gca, 'TickDir','out');
xticks(plt_p.left_right_ticks);
xlabel('Implied Endpoint');
xlim(xlimit);
yticks(plt_p.time_ticks);
ylabel(y_label);
ylim(ylimit);
title('Implied End Point');
set(gca, 'FontSize',plt_p.font_size);
set(gca, 'FontName',plt_p.font_name);
set(gca,'linewidth',plt_p.axes_line_thickness);
% Legend.
h = [];
h(1) = plot(nan,nan,'Color',plt_p.con_col, 'linewidth',plt_p.linewidth);
h(2) = plot(nan,nan,'Color',plt_p.incon_col, 'linewidth',plt_p.linewidth);
graphs = {'Congruent', 'Incongruent'};
%         if ~isempty(clusters)
%             h(3) = plot(nan,nan,'Color',[1, 1, 1, plt_p.f_alpha/2], 'linewidth',plt_p.linewidth);
%             graphs{3} = 'Significant';
%         end
% legend(h, graphs, 'Location','southeast');
% legend('boxoff');

% Print stats to terminal.
printTsStats('---- iEP --------', clusters);
end