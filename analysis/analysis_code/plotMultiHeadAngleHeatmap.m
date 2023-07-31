% Plots the head angle of all the trials of all the good participants as a heatmap.
% subplot_p - parameters for 'subplot' command for each of the 2 subplots.
% plt_p - struct of plotting params.
% p - struct of exp params.
function [] = plotMultiHeadAngleHeatmap(traj_names, subplot_p, p)
    traj_len = load([p.PROC_DATA_FOLDER '/trim_len.mat']);  traj_len = traj_len.trim_len;

    good_subs = load([p.PROC_DATA_FOLDER '/good_subs_' p.DAY '_' traj_names{1}{1} '_subs_' p.SUBS_STRING '.mat']);  good_subs = good_subs.good_subs;
    for iTraj = 1:length(traj_names)
        data_con = [];
        data_incon = [];

        for iSub = good_subs
            % load data.
            single_trials = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_sorted_trials_' traj_names{iTraj}{1} '.mat']);  single_trials = single_trials.r_trial;
            % combine left and right.
            angles_con_mat = [single_trials.head_angle.con_left(:,:) single_trials.head_angle.con_right(:,:)];
            angles_incon_mat = [single_trials.head_angle.incon_left(:,:) single_trials.head_angle.incon_right(:,:)];

            % Combine all subs to one vector.
            num_trials_con = size(angles_con_mat,2);
            num_trials_incon = size(angles_incon_mat,2);
            data_con = [data_con; reshape(angles_con_mat, traj_len * num_trials_con, 1)];
            data_incon = [data_incon; reshape(angles_incon_mat, traj_len * num_trials_incon, 1)];
        end

        % Load avg over all subs.
        subs_avg = load([p.PROC_DATA_FOLDER '/subs_avg_' p.DAY '_' traj_names{iTraj}{1} '_subs_' p.SUBS_STRING '.mat']);  subs_avg = subs_avg.reach_subs_avg;

        % Plot congruent data.
        subplot(subplot_p(1,1), subplot_p(1,2), subplot_p(1,3));
        hold on;
        make_heat_map(data_con, 'con', subs_avg, traj_len);

        % Plot incongruent data.
        subplot(subplot_p(2,1), subplot_p(2,2), subplot_p(2,3));
        hold on;
        make_heat_map(data_incon, 'incon', subs_avg, traj_len);
    end
end

% Builds data for the x axis and then plots a colored histogram.
% cond - condition, 'con'/'incon'.
function [] = make_heat_map(data, cond, subs_avg, traj_len)
    n_bins = [traj_len, 100]; % in each axis (X, Y) of the histogram (heatmap).
    color_bar_lim = [-2 50]; % lower and upper limits of the colorbar.

    % Build z axis.
    z_axis = (subs_avg.traj.([cond '_left'])(:,3) + subs_avg.traj.([cond '_right'])(:,3)) / 2;
    z_axis = repmat(z_axis, size(data, 1) / size(z_axis,1), 1);
    % Plot data.
    hist3([z_axis, data], 'Nbins',n_bins, 'CdataMode','auto', 'EdgeColor','none');
    
    xlabel('% Path traveled');
    ylabel('Head angle');
    clim(color_bar_lim);
    title(['Head angle, ' cond 'gruent']);
    colorbar;
    colormap('turbo');
    view(2);
    set(gca, 'FontSize',14);
end