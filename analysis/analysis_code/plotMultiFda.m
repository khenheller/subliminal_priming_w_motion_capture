% Plots the FDA of all subjects. This shows which parts of the trajectory are significant.
% plt_p - struct of plotting params.
% p - struct of exp params.
function [] = plotMultiFda(traj_names, plt_p, p)
traj_len = load([p.PROC_DATA_FOLDER '/trim_len.mat']);  traj_len = traj_len.trim_len;
x_lim = [0 1] * p.NORM_TRAJ + [0 p.SCREEN_DIST] * ~p.NORM_TRAJ;
% Determine X axis for plot.
if p.NORM_TRAJ
    x_axis = 1/traj_len : 1/traj_len : 1;
    x_label = '% path traveled';
else
    x_axis = (1 : traj_len) * p.SAMPLE_RATE_SEC; % Array with timing of each sample.
    x_label = 'Time';
end
    for iTraj = 1:length(traj_names)
        p_val = load([p.PROC_DATA_FOLDER '/fda_' p.DAY '_' traj_names{iTraj}{1} '_subs_' p.SUBS_STRING '.mat'], 'p_val');  p_val = p_val.p_val;
        hold on;
        % Plot.
        plot(x_axis, p_val.x(1,:), 'k', 'linewidth',2); % 1=con/incon index in p_val.
        plot(x_lim, [plt_p.alpha_size plt_p.alpha_size], 'r');
        xlabel(x_label);
        ylabel('P value');
        set(gca,'FontSize',14);
        ylim([0 1]);
        xlim(x_lim);
        title('FDA - Significance of inconerence between\newlineconditions (trajCon_x,trajIncon_x)');
    end
end