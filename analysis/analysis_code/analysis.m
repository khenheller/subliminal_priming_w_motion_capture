clear all;
close all;
clc;
%% Parameters
load('../../experiment/RUN_ME/p.mat');
addpath(genpath('./imported_code'));
% @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@remove
p.PROC_DATA_FOLDER = '../processed_data';
p.DATA_FOLDER = '../../raw_data';
p.MAX_BAD_TRIALS = p.NUM_TRIALS / 2; % sub with more bad trials is disqualified.
p.MIN_AMNT_TRIALS_IN_COND = 100; % sub with less good trials in each condition is disqualified.
p.MIN_CORRECT_ANS = ceil(p.NUM_TRIALS * 0.7); % sub with less amnt of good answeres is disqualified.
% @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@remove
% Normalization params.
p.TRAJ_FILT_ORDER = 2;
p.TRAJ_FILT_CUTOFF = 8;% in Hz.
p.VEL_FILTER_ORDER = 2;
p.VEL_FILTER_CUTOFF = 10;% in Hz.
p.NORM_FRAMES = 200; % length of normalized trajs.
p.NORM_TYPE = 4; % 1=to time, 2=to x, 3=to y, 4=to z.

% Name of trajectory column in output data. each cell is a diff type of traj.
traj_names = {{'target_x_to' 'target_y_to' 'target_z_to'},...
    {'target_x_from' 'target_y_from' 'target_z_from'},...
    {'prime_x_to' 'prime_y_to' 'prime_z_to'},...
    {'prime_x_from' 'prime_y_from' 'prime_z_from'}};
% name of normalized traj column in output data.
traj_names_norm = [traj_names{:,:}];
traj_names_norm = reshape(traj_names_norm, [], length(traj_names));
traj_names_norm = strcat(traj_names_norm, '_norm');
traj_names_norm = traj_names_norm';
% Traj names without 'x'/'y'/'z'.
traj_types = [traj_names{:,:}];
traj_types = reshape(traj_types, [], length(traj_names));
traj_types = traj_types(1,:);
traj_types = replace(traj_types, '_x', '');

% Adjustable params.
p.SUBS = [1 2 3 4 5 6 7 8 9]; % to analyze.
p.N_SUBS = length(p.SUBS);
pas_rate = 1; % to analyze.
%% Preprocessing & Normalization
% Trials too short to filter.
% too_short_to_filter = table('Size', [p.N_SUBS length(traj_types)],...
%     'VariableTypes', repmat({'cell'}, length(traj_types), 1),...
%     'VariableNames', traj_types);
% @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ return to normnal @@@@@@@@@@@
too_short_to_filter = table('Size', [max(p.SUBS) length(traj_types)],...
    'VariableTypes', repmat({'cell'}, length(traj_types), 1),...
    'VariableNames', traj_types);
% @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ return to normnal @@@@@@@@@@@
for iSub = p.SUBS
    traj_table = readtable([p.DATA_FOLDER '/sub' num2str(iSub) 'traj.csv']);
    data_table = readtable([p.DATA_FOLDER '/sub' num2str(iSub) 'data.csv']);
    save([p.PROC_DATA_FOLDER '/sub' num2str(iSub) 'traj.mat'], 'traj_table'); % '.mat' is faster to read than '.csv'.
    save([p.PROC_DATA_FOLDER '/sub' num2str(iSub) 'data.mat'], 'data_table');
    
    % remove practice.
    traj_table(traj_table{:,'practice'} == 1, :) = [];
    
    % Preprocessing and normalization.
    for iTraj = 1:length(traj_names)
        [traj_table, too_short_to_filter{iSub, iTraj}{:}] = preproc(traj_table, traj_names{iTraj}, p);
    end
    % Trim to normalized length (=p.norm_frames).
    matrix = reshape(traj_table{:,:}, p.MAX_CAP_LENGTH, p.NUM_TRIALS, width(traj_table));
    matrix = matrix(1:p.NORM_FRAMES, :, :);
    traj_table = traj_table(1 : p.NORM_FRAMES * p.NUM_TRIALS, :);
    traj_table{:,:} = reshape(matrix, p.NORM_FRAMES * p.NUM_TRIALS, width(traj_table));
    % Save
    writetable(traj_table, [p.PROC_DATA_FOLDER '/sub' num2str(iSub) 'traj_proc.csv']);
    save([p.PROC_DATA_FOLDER '/sub' num2str(iSub) 'traj_proc.mat'], 'traj_table');
end
disp('Following trials where too short to filter:');
disp(too_short_to_filter);
save([p.PROC_DATA_FOLDER '/too_short_to_filter.mat'], 'too_short_to_filter');
%% Trial Screening
for iTraj = 1:length(traj_names)
    [bad_trials, n_bad_trials, bad_trials_i] = trialScreen(traj_names{iTraj}, p);
    save([p.PROC_DATA_FOLDER '/bad_trials_' traj_names{iTraj}{1} '.mat'], 'bad_trials', 'n_bad_trials', 'bad_trials_i');
end
%% Subject screening
for iTraj = 1:length(traj_names')
    bad_subs = subScreening(traj_names{iTraj}, p);
    save([p.PROC_DATA_FOLDER '/bad_subs_' traj_names{iTraj}{1} '.mat'], 'bad_subs');
end
%% Sorting and averaging (within subject)
for iTraj = 1:length(traj_names)
    bad_trials = load([p.PROC_DATA_FOLDER '/bad_trials_' traj_names{iTraj}{1} '.mat'], 'bad_trials');  bad_trials = bad_trials.bad_trials;
    for iSub = p.SUBS
        [avg, single] = avgWithin(iSub, traj_names{iTraj}, bad_trials, pas_rate, p);
        save([p.PROC_DATA_FOLDER '/sub' num2str(iSub) 'sorted_trials_' traj_names{iTraj}{1} '.mat'], 'single');
        save([p.PROC_DATA_FOLDER '/sub' num2str(iSub) 'avg_' traj_names{iTraj}{1} '.mat'], 'avg');
    end
end
%% Sorting and averaging (between subjects)
for iTraj = 1:length(traj_names)
    subs_avg = avgBetween(traj_names{iTraj}, p);
    save([p.PROC_DATA_FOLDER '/subs_avg_' traj_names{iTraj}{1} '.mat'], 'subs_avg');
end
%% FDA
for iTraj = 1:length(traj_names)
    [p_val, corr_p, ~, stats] = runFDA(traj_names{iTraj}, p);
    save([p.PROC_DATA_FOLDER '/fda_' traj_names{iTraj}{1} '.mat'], 'p_val','corr_p','stats');
end
%% Plotting params
close all;

% Color of plots.
space = 4; % between beeswarm graphs.
alpha = 0.3;
same_col = [0 0.4470 0.7410];%[0 0.4470 0.7410 alpha];
same_avg_col = 'b';
diff_col = [0.6350 0.0780 0.1840];%[0.6350 0.0780 0.1840 alpha];
diff_avg_col = 'r';
avg_plot_width = 4;

% Unite all subs to one variable.
for iSub = p.SUBS
    for iTraj = 1:length(traj_names)
        avg = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) 'avg_' traj_names{iTraj}{1} '.mat']);  avg = avg.avg;
        avg_each.traj(iTraj).same_left(:,iSub,:) = avg.traj.same_left;
        avg_each.traj(iTraj).same_right(:,iSub,:) = avg.traj.same_right;
        avg_each.traj(iTraj).diff_left(:,iSub,:) = avg.traj.diff_left;
        avg_each.traj(iTraj).diff_right(:,iSub,:) = avg.traj.diff_right;
        avg_each.rt(iTraj).same_left(iSub)  = avg.rt.same_left;
        avg_each.rt(iTraj).same_right(iSub) = avg.rt.same_right;
        avg_each.rt(iTraj).diff_left(iSub)  = avg.rt.diff_left;
        avg_each.rt(iTraj).diff_right(iSub) = avg.rt.diff_right;
    end
    avg_each.fc.same(iSub) = avg.fc.same;
    avg_each.fc.diff(iSub) = avg.fc.diff;
end
%% Single Sub plots.
% ------- Traj of each trial -------
for iSub = p.SUBS
    figure('Name',['sub' num2str(iSub) ' traj'],'WindowState','maximized', 'MenuBar','figure');
    for iTraj = 1:length(traj_names)
        single = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) 'sorted_trials_' traj_names{iTraj}{1} '.mat']);  single = single.single;
        avg = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) 'avg_' traj_names{iTraj}{1} '.mat']);  avg = avg.avg;
        % Flips traj to screen since its Z values are negative.
        flip_traj = 1 + contains(traj_names{iTraj}{1}, '_to') * -2; % if contains: -1, else: 1.
        subplot(2,2,iTraj);
        hold on;
        % single trial.
        plot(single.trajs.same_left(:,:,1),  single.trajs.same_left(:,:,3)*flip_traj,  'Color',same_col);
        plot(single.trajs.same_right(:,:,1), single.trajs.same_right(:,:,3)*flip_traj, 'Color',same_col);
        plot(single.trajs.diff_left(:,:,1),  single.trajs.diff_left(:,:,3)*flip_traj,  'Color',diff_col);
        plot(single.trajs.diff_right(:,:,1), single.trajs.diff_right(:,:,3)*flip_traj, 'Color',diff_col);
        % Averages.
        plot(avg.traj.same_left(:,1),  avg.traj.same_left(:,3) * flip_traj,  same_avg_col, 'LineWidth',avg_plot_width);
        plot(avg.traj.same_right(:,1), avg.traj.same_right(:,3) * flip_traj, same_avg_col, 'LineWidth',avg_plot_width);
        plot(avg.traj.diff_left(:,1),  avg.traj.diff_left(:,3) * flip_traj,  diff_avg_col, 'LineWidth',avg_plot_width);
        plot(avg.traj.diff_right(:,1), avg.traj.diff_right(:,3) * flip_traj, diff_avg_col, 'LineWidth',avg_plot_width);
        % plot's description.
        handle(1) = plot(nan,nan,'Color',same_col);
        handle(2) = plot(nan,nan,'Color',diff_col);
        handle(3) = plot(nan,nan,same_avg_col);
        handle(4) = plot(nan,nan,diff_avg_col);
        legend(handle, 'same', 'diff', 'same avg', 'diff avg', 'Location','southeast');
        xlabel('X'); xlim([-0.12, 0.12]);
        ylabel('Z Axis (to screen)'); ylim([0, 0.4]);
        title(cell2mat(['Reach ' regexp(traj_names{iTraj}{1},'_._(.+)','tokens','once') ' ' regexp(traj_names{iTraj}{1},'(.+)_.+_','tokens','once')]));
        set(gca, 'FontSize',14);
    end
    % Add sub num title.
    annotation('textbox',[0.45 0.9 0.1 0.1], 'String',['Sub ' num2str(iSub)], 'FontSize',40, 'LineStyle','none', 'FitBoxToText','on');
end

% ------- Avg traj with shade -------
for iSub = p.SUBS
    figure('Name',['sub' num2str(iSub) ' traj'],'WindowState','maximized', 'MenuBar','figure');
    for iTraj = 1:length(traj_names)
        single = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) 'sorted_trials_' traj_names{iTraj}{1} '.mat']);  single = single.single;
        avg = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) 'avg_' traj_names{iTraj}{1} '.mat']);  avg = avg.avg;
        % Flips traj to screen since its Z values are negative.
        flip_traj = 1 + contains(traj_names{iTraj}{1}, '_to') * -2; % if contains: -1, else: 1.
        subplot(2,2,iTraj);
        hold on;
        % Avg with var shade.
        stdshade(single.trajs.same_left(:,:,1)',  alpha, same_col, avg.traj.same_left(:,3)*flip_traj, 0, 0);
        stdshade(single.trajs.same_right(:,:,1)', alpha, same_col, avg.traj.same_right(:,3)*flip_traj, 0, 0);
        stdshade(single.trajs.diff_left(:,:,1)',  alpha, diff_col, avg.traj.diff_left(:,3)*flip_traj, 0, 0);
        stdshade(single.trajs.diff_right(:,:,1)', alpha, diff_col, avg.traj.diff_right(:,3)*flip_traj, 0, 0);
        handle = [];
        handle(1) = plot(nan,nan,'Color',same_col);
        handle(2) = plot(nan,nan,'Color',diff_col);
        legend(handle, 'same', 'diff', 'Location','southeast');
        xlabel('X'); xlim([-0.12, 0.12]);
        ylabel('Z Axis (to screen)'); ylim([0, 0.4]);
        title(cell2mat(['Reach ' regexp(traj_names{iTraj}{1},'_._(.+)','tokens','once') ' ' regexp(traj_names{iTraj}{1},'(.+)_.+_','tokens','once')]));
        set(gca, 'FontSize',14);
    end
    % Add sub num title.
    annotation('textbox',[0.45 0.9 0.1 0.1], 'String',['Sub ' num2str(iSub)], 'FontSize',40, 'LineStyle','none', 'FitBoxToText','on');
end

% ------- RT -------
for iSub = p.SUBS
    figure('Name',['sub' num2str(iSub) ' RT ' traj_names{iTraj}{1}],'WindowState','maximized', 'MenuBar','figure');
    for iTraj = 1:length(traj_names)
        subplot(2,2,iTraj);
        hold on;
        single = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) 'sorted_trials_' traj_names{iTraj}{1} '.mat']);  single = single.single;
        beesdata = {single.rt.same_left, single.rt.diff_left, single.rt.same_right, single.rt.diff_right};
        names = {'same left', 'diff left', 'same right', 'diff right'};%cellstr(strrep(fieldnames(single.rt), '_',' '))'; % remove '_' from names.
        colors = {same_col, diff_col, same_col, diff_col};
        title_char = cell2mat(['RT ' regexp(traj_names{iTraj}{1},'_._(.+)','tokens','once') ' ' regexp(traj_names{iTraj}{1},'(.+)_.+_','tokens','once')]);
        printBeeswarm(beesdata, names, colors, space, title_char);
    end
    % Add sub num title.
    annotation('textbox',[0.45 0.9 0.1 0.1], 'String',['Sub ' num2str(iSub)], 'FontSize',40, 'LineStyle','none', 'FitBoxToText','on');
end
%% Multiple subs average plots.
% ------- Avg traj with shade -------
figure('Name','avg_traj','WindowState','maximized', 'MenuBar','figure');
for iTraj = 1:length(traj_names)
    subplot(2,2,iTraj);
    hold on;
    subs_avg = load([p.PROC_DATA_FOLDER 'subs_avg_' traj_names{iTraj}{1} '.mat']);  subs_avg = subs_avg.subs_avg;
    % Flips traj to screen since its Z values are negative.
    flip_traj = 1 + contains(traj_names{iTraj}{1}, '_to') * -2; % if contains: -1, else: 1.
    % Avg with var shade.
    stdshade(avg_each.traj(iTraj).same_left(:,:,1)',  alpha, same_col, subs_avg.traj.same_left(:,3)*flip_traj, 0, 0);
    stdshade(avg_each.traj(iTraj).same_right(:,:,1)', alpha, same_col, subs_avg.traj.same_right(:,3)*flip_traj, 0, 0);
    stdshade(avg_each.traj(iTraj).diff_left(:,:,1)',  alpha, diff_col, subs_avg.traj.diff_left(:,3)*flip_traj, 0, 0);
    stdshade(avg_each.traj(iTraj).diff_right(:,:,1)', alpha, diff_col, subs_avg.traj.diff_right(:,3)*flip_traj, 0, 0);
    handle = [];
    handle(1) = plot(nan,nan,'Color',same_col);
    handle(2) = plot(nan,nan,'Color',diff_col);
    legend(handle, 'same', 'diff', 'Location','southeast');
    xlabel('X'); xlim([-0.12, 0.12]);
    ylabel('Z Axis (to screen)'); ylim([0, 0.4]);
    title(cell2mat(['Reach ' regexp(traj_names{iTraj}{1},'_._(.+)','tokens','once') ' ' regexp(traj_names{iTraj}{1},'(.+)_.+_','tokens','once')]));
    set(gca, 'FontSize',14);
end
annotation('textbox',[0.4 0.9 0.1 0.1], 'String','Avg across Subs', 'FontSize',40, 'LineStyle','none', 'FitBoxToText','on');

% ------- RT -------
figure('Name','avg_rt','WindowState','maximized', 'MenuBar','figure');
for iTraj = 1:length(traj_names)
    beesdata = {avg_each.rt(iTraj).same_left, avg_each.rt(iTraj).diff_left, avg_each.rt(iTraj).same_right, avg_each.rt(iTraj).diff_right};
    names = {'same left', 'diff left', 'same right', 'diff right'};%cellstr(strrep(fieldnames(single.rt), '_',' '))'; % remove '_' from names.
    colors = {same_col, diff_col, same_col, diff_col};
    title_char = cell2mat(['RT ' regexp(traj_names{iTraj}{1},'_._(.+)','tokens','once') ' ' regexp(traj_names{iTraj}{1},'(.+)_.+_','tokens','once')]);
    subplot(2,2,iTraj);
    hold on;
    printBeeswarm(beesdata, names, colors, space, title_char);
end

% ------- Forced choice -------
figure('Name','Forced choice','WindowState','maximized', 'MenuBar','figure');
beesdata = {avg_each.fc.same, avg_each.fc.diff};
names = {'same', 'diff'};
colors = {same_col, diff_col};
title_char = 'Forced response';
printBeeswarm(beesdata, names, colors, space, title_char);
ylabel('percent correct');
ylim([0 1]);

% ------- FDA -------
fda_f = figure('Name','FDA','WindowState','maximized', 'MenuBar','figure');
alpha = 0.05;
for iTraj = 1:length(traj_names)
    p_val = load([p.PROC_DATA_FOLDER '/fda_' traj_names{iTraj}{1} '.mat'], 'p_val');  p_val = p_val.p_val;
    subplot(2,2,iTraj);
    hold on;
    plot(1/p.NORM_FRAMES : 1/p.NORM_FRAMES : 1, p_val.x(1,:), 'LineWidth',3); % 1=same/diff index in p_val.
    plot([0 1], [alpha alpha], 'r');
    xlabel('Percent of Z movement');
    ylabel('p value between same and diff cond');
    ylim([0 1]);
    xlim([0 1]);
end
%% Velocity
%{
        % calc velocity.-----------------------------------------------
        dx = traj_mat(2:end, :, :) - traj_mat(1:end-1, :, :); % distance between 2 samples.
        vel_per_axis = dx / p.SAMPLE_RATE_SEC;
        veloc = sqrt(sum(vel_per_axis.^2, 3));
        veloc = [veloc; veloc(end,:)];
        vel.same_left = veloc(:, same_trials.left);
        vel.same_right = veloc(:, same_trials.right);
        vel.diff_left = veloc(:, diff_trials.left);
        vel.diff_right = veloc(:, diff_trials.right);
        avg_vel.same_left = mean(vel.same_left, 2);
        avg_vel.same_right = mean(vel.same_right, 2);
        avg_vel.diff_left = mean(vel.diff_left, 2);
        avg_vel.diff_right = mean(vel.diff_right, 2);
        
        figure(vel_f);
        subplot(2,2,iTraj);
        hold on;
        % Same trials left.
        plot(traj_mat(:, same_trials.left, 3)*flip_traj, vel.same_left, 'Color',[0 0.4470 0.7410 0.3]);
        % Same trials right.
        plot(traj_mat(:, same_trials.right, 3)*flip_traj, vel.same_right, 'Color',[0 0.4470 0.7410 0.3]);
        % diff trials left.
        plot(traj_mat(:, diff_trials.left, 3)*flip_traj, vel.diff_left, 'Color',[0.6350 0.0780 0.1840 0.3]);
        % diff trials right.
        plot(traj_mat(:, diff_trials.right, 3)*flip_traj, vel.diff_right, 'Color',[0.6350 0.0780 0.1840 0.3]);
        % Averages.
        plot(avg_traj_table.same_left{:, traj_names{iTraj}{3}}*flip_traj, avg_vel.same_left, 'b', 'LineWidth',4); % X as func of Z.
        plot(avg_traj_table.same_right{:, traj_names{iTraj}{3}}*flip_traj, avg_vel.same_right, 'b', 'LineWidth',4); % X as func of Z.
        plot(avg_traj_table.diff_left{:, traj_names{iTraj}{3}}*flip_traj, avg_vel.diff_left, 'r', 'LineWidth',4); % X as func of Z.
        plot(avg_traj_table.diff_right{:, traj_names{iTraj}{3}}*flip_traj, avg_vel.diff_right, 'r', 'LineWidth',4); % X as func of Z.
        handle(1) = plot(nan,nan,'Color',[0 0.4470 0.7410 0.3]);
        handle(2) = plot(nan,nan,'Color',[0.6350 0.0780 0.1840 0.3]);
        handle(3) = plot(nan,nan,'b');
        handle(4) = plot(nan,nan,'r');
        legend(handle, 'same', 'diff', 'same avg', 'diff avg', 'Location','southeast');
        xlabel('Z'); xlim([0, 0.4]);
        ylabel('Velocity'); ylim([0, 1]);
        title(traj_names{iTraj}{1}, 'Interpreter','none');
        set(gca, 'FontSize',14);
        %}