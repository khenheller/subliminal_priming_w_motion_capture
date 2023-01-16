% Plots the average (over good subjects) STD in the X axis on each point along the taj.
% Seperates to conditions and sides.
% subplot_p - parameters for 'subplot' command for each of the 2 subplots.
% plt_p - struct of plotting params.
% p - struct of exp params.
function [] = plotMultiXStd(traj_names, subplot_p, plt_p, p)

    for iTraj = 1:length(traj_names)
        left_right = ["left", "right"];
        good_subs = load([p.PROC_DATA_FOLDER '/good_subs_' p.DAY '_' traj_names{iTraj}{1} '_subs_' p.SUBS_STRING '.mat']);  good_subs = good_subs.good_subs;
        % Avg of each sub.
        avg_each = load([p.PROC_DATA_FOLDER '/avg_each_' p.DAY '_' traj_names{iTraj}{1} '_subs_' p.SUBS_STRING '.mat']);  avg_each = avg_each.reach_avg_each;
        % Avg over all subs.
        subs_avg = load([p.PROC_DATA_FOLDER '/subs_avg_' p.DAY '_' traj_names{iTraj}{1} '_subs_' p.SUBS_STRING '.mat']);  subs_avg = subs_avg.reach_subs_avg;

        % Plot time instead of Z axis.
        if plt_p.x_as_func_of == "time"
            assert(~p.NORM_TRAJ, "When traj is normalized in space, time isn't releveant and shouldnt be used");
            % Array with timing of each sample.
            time_series = (1 : size(subs_avg.traj.con_left,1)) * p.SAMPLE_RATE_SEC;
            x_axis = time_series;
            x_label = 'time';
            xlimit = [0 p.MIN_SAMP_LEN]; % For plot.
        else
            x_axis = subs_avg.traj.con_left(:,3)*100;
            assert(p.NORM_TRAJ, "Uses identical Z to all trajs, assumes trajs are normalized.")
            x_label = '% Path traveled';
            xlimit = [0, 100];
        end

        % Unite sides to single var.
        x_std_con = {subs_avg.x_std.con_left, subs_avg.x_std.con_right};
        x_std_incon = {subs_avg.x_std.incon_left, subs_avg.x_std.incon_right};
        % 2 plots: left, right.
        for side = 1:2
            subplot(subplot_p(side, 1), subplot_p(side, 2), subplot_p(side, 3));
            hold on;
            plot(x_axis, x_std_con{side}, 'color',plt_p.con_col);
            plot(x_axis, x_std_incon{side}, 'color',plt_p.incon_col);

            ylabel('X STD');
            xlabel(x_label);
            xlim(xlimit);
            set(gca,'FontSize',14);
            title(['STD in X Axis' left_right(side)]);
            % Legend.
            h = [];
            h(1) = bar(NaN,NaN,'FaceColor',plt_p.con_col);
            h(2) = bar(NaN,NaN,'FaceColor',plt_p.incon_col);
            legend(h,'Con','Incon', 'Location','northwest');
        end
        
        % Combined (left and right).
        subplot(subplot_p(3, 1), subplot_p(3, 2), subplot_p(3, 3));
        hold on;
        % Plot.
        stdshade(avg_each.x_std.con(:,good_subs)', plt_p.f_alpha, plt_p.con_col, x_axis, 0, 1, plt_p.errbar_type, plt_p.alpha_size, plt_p.linewidth);
        stdshade(avg_each.x_std.incon(:,good_subs)', plt_p.f_alpha, plt_p.incon_col, x_axis, 0, 1, plt_p.errbar_type, plt_p.alpha_size, plt_p.linewidth);

        plot(xlimit, [0 0], '--', 'linewidth',3, 'color',[0.15 0.15 0.15 plt_p.f_alpha]); % Zero line.

        % Permutation testing.
        clusters = permCluster(avg_each.x_std.con(:,good_subs), avg_each.x_std.incon(:,good_subs), plt_p.n_perm, plt_p.n_perm_clust_tests);

        % Plot clusters.
        if ~isempty(clusters)
            y_lim = get(gca, 'ylim');
            points = [x_axis(clusters.start)'; x_axis(clusters.end)'];
            drawRectangle(points, 'x', y_lim, plt_p);
        end

        set(gca, 'TickDir','out');
        xlabel(x_label);
        ylabel('X SD');
        title('Trajectory SD');
        set(gca,'FontSize',14);
        % Legend.
%         h = [];
%         h(1) = bar(NaN,NaN,'FaceColor',plt_p.con_col);
%         h(2) = bar(NaN,NaN,'FaceColor',plt_p.incon_col);
%         h(3) = bar(NaN,NaN,'FaceColor',[0.15 0.15 0.15]);
%         legend(h, 'con','incon',err_bar_type, 'Location','northwest');

        % Print stats to terminal.
        printTsStats('----Movement variation--------', clusters);
    end
end