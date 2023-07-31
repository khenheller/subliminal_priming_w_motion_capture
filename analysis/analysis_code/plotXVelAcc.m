% Plots acceleration or velocity.
% target - 'vel'/'acc', velocity or acceleration.
function [] = plotXVelAcc(iSub, target, traj_names, subplot_p, plt_p, p)
assert(~p.NORM_TRAJ, "If traj was normalized in space, velocity and acceleration have no meaning and should not be used");
% Load data.
trials = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_sorted_trials_' traj_names{1} '.mat']);  trials = trials.r_trial;
con = trials.(target).con;
incon = trials.(target).incon;
vels = [con, incon];
% Decide between time or Z.
if plt_p.x_as_func_of == "time"
    % Array with timing of each sample.
    x_axis = (1 : size(vels,1)) * p.SAMPLE_RATE_SEC;
    x_label = 'time';
else
    x_axis = trials.trajs.con(:,1,3)*100;
    assert(p.NORM_TRAJ, "Must use identical Z to all trajs to plot them. Assumes trajs are normalized.")
    x_label = '% Path traveled';
end

if isequal(target,'vel')
    y_label = 'Velocity(m/s)';
    y_lim = [-1 1.5];
else
    y_label = 'Acceleration(m/s^2)';
    y_lim = [-15 25];
end

% Plot single trials.
subplot(subplot_p(1,1),subplot_p(1,2),subplot_p(1,3));
yline(0, '--', 'color',[0.7 0.7 0.7]);
hold on;
plot(x_axis, con, 'color',[plt_p.con_col plt_p.f_alpha]);
plot(x_axis, incon, 'color',[plt_p.incon_col plt_p.f_alpha]);

set(gca, 'TickDir','out');
xlabel(x_label);
ylim(y_lim);
title([target ' of each trial']);
% xticks([]);
ylabel(y_label);
set(gca, 'FontSize',14);

% Plot avg with shade.
subplot(subplot_p(2,1),subplot_p(2,2),subplot_p(2,3));
yline(0, '--', 'color',[0.7 0.7 0.7]);
hold on;
stdshade(con', plt_p.f_alpha*0.9, plt_p.con_col, x_axis, 0, 1, 'se', plt_p.alpha_size, plt_p.linewidth);
stdshade(incon', plt_p.f_alpha*0.9, plt_p.incon_col, x_axis, 0, 1, 'se', plt_p.alpha_size, plt_p.linewidth);

set(gca, 'TickDir','out');
xlabel(x_label);
title(['Average ' target]);
% ylim(ylimit);
% xticks([]);
ylabel(y_label);
set(gca, 'FontSize',14);
% Legend.
h = [];
h(1) = plot(nan,nan,'Color',plt_p.con_col, 'linewidth',plt_p.linewidth);
h(2) = plot(nan,nan,'Color',plt_p.incon_col, 'linewidth',plt_p.linewidth);
graphs = {'Congruent', 'Incongruent'};
legend(h, graphs, 'Location','southeast');
legend('boxoff');
end