% Plots the FDA of all subjects. This shows which parts of the trajectory are significant.
% plt_p - struct of plotting params.
% p - struct of exp params.
function [] = plotMultiFda(traj_names, plt_p, p)
    for iTraj = 1:length(traj_names)
        p_val = load([p.PROC_DATA_FOLDER '/fda_' p.DAY '_' traj_names{iTraj}{1} '_subs_' p.SUBS_STRING '.mat'], 'p_val');  p_val = p_val.p_val;
        hold on;
        % Plot.
        plot(1/p.NORM_FRAMES : 1/p.NORM_FRAMES : 1, p_val.x(1,:), 'k', 'linewidth',2); % 1=con/incon index in p_val.
        plot([0 1], [plt_p.alpha_size plt_p.alpha_size], 'r');
        xlabel('Percent of Z movement');
        ylabel('P value');
        set(gca,'FontSize',14);
        ylim([0 1]);
        xlim([0 1]);
        title('FDA - Significance of inconerence between\newlineconditions (trajCon_x,trajIncon_x)');
    end
end