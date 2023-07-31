% Plots a single sub's max velocotu in each trial.
function [] = plotMaxVel(iSub, traj_name, plt_p, p)
hold on;

% Load data and prep params.
sorted_trials = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_' 'sorted_trials_' traj_name{1} '.mat']);  sorted_trials = sorted_trials.r_trial;
max_vel = sorted_trials.max_vel;
beesdata = {max_vel.con_left, max_vel.incon_left, max_vel.con_right, max_vel.incon_right};
yLabel = 'Max Horizontal Velocity (m/s^2)';
XTickLabels = [];
colors = {plt_p.con_col, plt_p.incon_col, plt_p.con_col, plt_p.incon_col};
title_char = ['Max Velocity Sub ' num2str(iSub)];
% Plot.
printBeeswarm(beesdata, yLabel, XTickLabels, colors, plt_p.space, title_char, 'se', plt_p.alpha_size);
% Group graphs.
ticks = get(gca,'XTick');
labels = {["",""]; ["Left","Right"]};
dist = [0, 0.01];
font_size = [1, 15];
groupTick(ticks, labels, dist, font_size)

% Legend.
h = [];
h(1) = bar(NaN,NaN,'FaceColor',plt_p.con_col);
h(2) = bar(NaN,NaN,'FaceColor',plt_p.incon_col);
legend(h,'Con','Incon', 'Location','northwest');
end