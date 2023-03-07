% Plots a sub's implied end point throughout each trial and the average iEP.
function [] = plotIEP(iSub, traj_names, subplot_p, plt_p, p)
% Load data.
trials = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_sorted_trials_' traj_names{1} '.mat']);  trials = trials.r_trial;
con = [trials.iep.con_left, trials.iep.con_right];
incon = [trials.iep.incon_left, trials.iep.incon_right];
ieps = [con, incon];
% Decide between time or Z.
if plt_p.x_as_func_of == "time"
    % Array with timing of each sample.
    y_axis = (1 : size(ieps,1)) * p.SAMPLE_RATE_SEC;
    y_label = 'time';
else
    y_axis = trials.trajs.con(:,1,3)*100;
    assert(p.NORM_TRAJ, "Must use identical Z to all trajs to plot them. Assumes trajs are normalized.")
    y_label = '% Path traveled';
end

% Plot single trials.
subplot(subplot_p(1,1),subplot_p(1,2),subplot_p(1,3));
xline(0, '--', 'color',[0.7 0.7 0.7]);
hold on;
plot(con, y_axis, 'color',[plt_p.con_col plt_p.f_alpha]);
plot(incon, y_axis, 'color',[plt_p.incon_col plt_p.f_alpha]);

set(gca, 'TickDir','out');
ylabel(y_label);
% ylim(y_lim);
% xticks([]);
xlabel('iEP');
title('iEP of each trial');
set(gca, 'FontSize',14);

% Plot avg with shade.
subplot(subplot_p(2,1),subplot_p(2,2),subplot_p(2,3));
xline(0, '--', 'color',[0.7 0.7 0.7]);
hold on;
stdshade(con', plt_p.f_alpha*0.9, plt_p.con_col, y_axis, 0, 0, 'se', plt_p.alpha_size, plt_p.linewidth);
stdshade(incon', plt_p.f_alpha*0.9, plt_p.incon_col, y_axis, 0, 0, 'se', plt_p.alpha_size, plt_p.linewidth);

set(gca, 'TickDir','out');
ylabel(y_label);
% ylim(ylimit);
% xticks([]);
xlabel('iEP');
title('Average iEP');
set(gca, 'FontSize',14);
% Legend.
h = [];
h(1) = plot(nan,nan,'Color',plt_p.con_col, 'linewidth',plt_p.linewidth);
h(2) = plot(nan,nan,'Color',plt_p.incon_col, 'linewidth',plt_p.linewidth);
graphs = {'Congruent', 'Incongruent'};
legend(h, graphs, 'Location','southeast');
legend('boxoff');
end
