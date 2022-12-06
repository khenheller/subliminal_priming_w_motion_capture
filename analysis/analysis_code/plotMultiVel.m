function [] = plotMultiVel(traj_names, subplot_p, plt_p, p)
good_subs = load([p.PROC_DATA_FOLDER '/good_subs_' p.DAY '_' traj_names{1} '_subs_' p.SUBS_STRING '.mat']);  good_subs = good_subs.good_subs;

assert(~p.NORM_TRAJ, "If traj was normalized in space, velocity has no meaning and should not be used");
% Load data.
avg_each = load([p.PROC_DATA_FOLDER '/avg_each_' p.DAY '_' traj_names{1} '_subs_' p.SUBS_STRING '.mat']);  avg_each = avg_each.reach_avg_each;
vel_con = avg_each.vel.con(:, good_subs);
vel_incon = avg_each.vel.incon(:, good_subs);
vels = [vel_con, vel_incon];
% Decide between time or Z.
if plt_p.x_as_func_of == "time"
    % Array with timing of each sample.
    x_axis = (1 : size(vels,1)) * p.SAMPLE_RATE_SEC;
    x_label = 'time';
else
    x_axis = avg_each.trajs.con(:,good_subs(1),3)*100;
    assert(p.NORM_TRAJ, "Must use identical Z to all trajs to plot them. Assumes trajs are normalized.")
    x_label = '% Path traveled';
end

% Plots each sub's avg.
subplot(subplot_p(1,1),subplot_p(1,2),subplot_p(1,3));
yline(0, '--', 'color',[0.7 0.7 0.7]);
hold on;
plot(x_axis, vel_con, 'color',[plt_p.con_col plt_p.f_alpha]);
plot(x_axis, vel_incon, 'color',[plt_p.incon_col plt_p.f_alpha]);

set(gca, 'TickDir','out');
xlabel(x_label);
ylim([-1 1.5]);
% xticks([]);
ylabel('Velocity(m/s)');
title('Velocity');
set(gca, 'FontSize',14);

% Plot avg with shade.
subplot(subplot_p(2,1),subplot_p(2,2),subplot_p(2,3));
yline(0, '--', 'color',[0.7 0.7 0.7]);
hold on;
stdshade(vel_con', plt_p.f_alpha*0.9, plt_p.con_col, x_axis, 0, 1, 'se', plt_p.alpha_size, plt_p.linewidth);
stdshade(vel_incon', plt_p.f_alpha*0.9, plt_p.incon_col, x_axis, 0, 1, 'se', plt_p.alpha_size, plt_p.linewidth);

set(gca, 'TickDir','out');
xlabel(x_label);
% ylim(ylimit);
% xticks([]);
ylabel('Velocity(m/s)');
title('Velocity');
set(gca, 'FontSize',14);
% Legend.
h = [];
h(1) = plot(nan,nan,'Color',plt_p.con_col, 'linewidth',plt_p.linewidth);
h(2) = plot(nan,nan,'Color',plt_p.incon_col, 'linewidth',plt_p.linewidth);
graphs = {'Congruent', 'Incongruent'};
legend(h, graphs, 'Location','southeast');
legend('boxoff');
end