% Plots avg max velocity of all subs.
function [] = plotMultiMaxVel(traj_name, plt_p, p)
good_subs = load([p.PROC_DATA_FOLDER '/good_subs_' p.DAY '_' traj_name{1} '_subs_' p.SUBS_STRING '.mat']);  good_subs = good_subs.good_subs;
avg_each = load([p.PROC_DATA_FOLDER '/avg_each_' p.DAY '_' traj_name{1} '_subs_' p.SUBS_STRING '.mat']);  avg_each = avg_each.reach_avg_each;
hold on;

% Load data and set parameters.
beesdata = {avg_each.max_vel.con(good_subs), avg_each.max_vel.incon(good_subs)};
yLabel = 'Velocity (m/s^2)';
XTickLabels = [];
colors = {plt_p.con_col, plt_p.incon_col};
title_char = 'Max Velocity';
% plot.
printBeeswarm(beesdata, yLabel, XTickLabels, colors, plt_p.space, title_char, plt_p.errbar_type, plt_p.alpha_size);

% Connect each sub's dots with lines.
y_data = [beesdata{1}; beesdata{2}];
x_data = reshape(get(gca,'XTick'), 2,[]);
x_data = repelem(x_data,1,length(good_subs));
connect_dots(x_data, y_data);

xticks([]);
set(gca, 'TickDir','out');
% Legend.
h = [];
h(1) = plot(nan,nan,'Color',plt_p.con_col, 'linewidth',plt_p.linewidth);
h(2) = plot(nan,nan,'Color',plt_p.incon_col, 'linewidth',plt_p.linewidth);
h(3) = plot(nan,nan,'Color','k', 'linewidth',plt_p.linewidth);
graphs = {'Congruent', 'Incongruent', plt_p.errbar_type};
legend(h, graphs, 'Location','southeast');
legend('boxoff');

% T-test and Cohen's dz
[~, p_val, ci, stats] = ttest(avg_each.max_vel.con(good_subs), avg_each.max_vel.incon(good_subs));
printStats('-----Max Velocity------------', avg_each.max_vel.con(good_subs), ...
avg_each.max_vel.incon(good_subs), ["Con","Incon"], p_val, ci, stats);
end