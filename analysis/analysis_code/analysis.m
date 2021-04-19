clear all;
close all;
clc;
%% Parameters
load('../../experiment/RUN_ME/p.mat');
addpath(genpath('./imported_code'));
% @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@remove
p.PROC_DATA_FOLDER = '../processed_data';
p.DATA_FOLDER = '../../raw_data';
% @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@remove

% Normalization params.
p.TRAJ_FILT_ORDER = 2;
p.TRAJ_FILT_CUTOFF = 8;% in Hz.
p.VEL_FILTER_ORDER = 2;
p.VEL_FILTER_CUTOFF = 10;% in Hz.

sub_nums = [1 2 3];
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
% Name of timecourse column in output data. each cell is a diff type of traj.
time_names = {'target_timecourse_to',...
    'target_timecourse_from',...
    'prime_timecourse_to',...
    'prime_timecourse_from'};
% Trials too short to filter.
traj_types = [traj_names{:,:}];
traj_types = reshape(traj_types, [], length(traj_names));
traj_types = traj_types(1,:);
traj_types = replace(traj_types, '_x', '');
too_short_to_filter = cell2table(cell(length(sub_nums), length(traj_types)), 'VariableNames',traj_types);
%% Preprocessing & Normalization
for iSub = sub_nums
    traj_table = readtable([p.DATA_FOLDER '/sub' num2str(iSub) 'traj.csv']);
    % remove practice.
    traj_table(traj_table{:,'practice'} == 1, :) = [];
    % Choose one traj type each time.
    for iTraj = 1:length(traj_names)
        traj = traj_table{:, traj_names{iTraj}};
        time = traj_table{:, time_names{iTraj}};
        %-------- Preprocessing --------
        % Reshape to convinient format.
        traj_mat = reshape(traj, p.MAX_CAP_LENGTH, p.NUM_TRIALS, 3); % 3 for (x,y,z).
        time_mat = reshape(time, p.MAX_CAP_LENGTH, p.NUM_TRIALS);
        % Fill missing samples.
        traj_mat = fillMissingData(traj_mat, p);
        % Low pass filter.
        [traj_mat, success] = filterTraj(traj_mat, p);
        % Set origin at first sample.
        [traj_mat, time_mat] = setOrigin(traj_mat, time_mat);
        % Trim to onset and offset.
        traj_mat = trimOnsetOffset(traj_mat, p);
        %-------- Normalization --------
        % Fit using B-spline.
        [traj_mat, time_mat] = normalize(traj_mat, p);
        
        % Reassign to table.
        traj = reshape(traj_mat, p.MAX_CAP_LENGTH * p.NUM_TRIALS, 3); % 3 for (x,y,z).
        time = reshape(time_mat, p.MAX_CAP_LENGTH * p.NUM_TRIALS, 1);
        traj_table{:, traj_names{iTraj}} = traj;
        traj_table{:, time_names{iTraj}} = time;
        
        % Check if traj was too short to filter.
        too_short_to_filter{iSub==sub_nums,iTraj}{:} = find(~success);
        too_short_to_filter{iSub==sub_nums,'sub_num'} = iSub; % Adds sub num column.
    end
    
    disp(['Following trials where too short to filter for sub ', num2str(iSub), ':']);
    for i = 1:length(traj_types)
        disp([traj_types{i}, ': ', num2str(too_short_to_filter{iSub==sub_nums, i}{:}')]);
    end
    
    % Trim to normalized length (=p.norm_frames).
    matrix = reshape(traj_table{:,:}, p.MAX_CAP_LENGTH, p.NUM_TRIALS, width(traj_table));
    matrix = matrix(1:p.NORM_FRAMES, :, :);
    traj_table = traj_table(1 : p.NORM_FRAMES * p.NUM_TRIALS, :);
    traj_table{:,:} = reshape(matrix, p.NORM_FRAMES * p.NUM_TRIALS, width(traj_table));
    
    writetable(traj_table, [p.PROC_DATA_FOLDER '/sub' num2str(iSub) 'traj_proc.csv']);
end
%% Screening
screen_reasons = {'missing_data','short_traj','missed_target'};
% Bad trials' numbers. row = bad trial, column = reason.
bad_trials_table = table('Size', [p.NUM_TRIALS length(screen_reasons)],...
    'VariableTypes', repmat({'double'}, length(screen_reasons), 1),...
    'VariableNames', screen_reasons);
bad_trials = cell(length(traj_names), length(sub_nums));
bad_trials_index = cell(length(traj_names), length(sub_nums));

for iSub = sub_nums
    traj_table = readtable([p.DATA_FOLDER '/sub' num2str(iSub) 'traj.csv']);
    traj_table_proc = readtable([p.PROC_DATA_FOLDER '/sub' num2str(iSub) 'traj_proc.csv']);
    % remove practice.
    traj_table(traj_table{:,'practice'} == 1, :) = [];
    traj_table_proc(traj_table_proc{:,'practice'} == 1, :) = [];
    
    % Choose one traj type each time.
    for iTraj = 1:length(traj_names)
        bad_trials{iTraj, iSub} = bad_trials_table;
        bad_trials_index{iTraj, iSub} = table();
        
        traj = traj_table{:, traj_names{iTraj}};
        traj_proc = traj_table_proc{:, traj_names{iTraj}};
        % Reshape to convenient format.
        traj_mat = reshape(traj, p.MAX_CAP_LENGTH, p.NUM_TRIALS, 3); % 3 for (x,y,z).
        traj_proc_mat = reshape(traj_proc, p.NORM_FRAMES, p.NUM_TRIALS, 3); % 3 for (x,y,z).
        
        for iTrial = 1:p.NUM_TRIALS
            success = ones(1, length(screen_reasons)); % 0 = screen out trial.
            single_traj = squeeze(traj_mat(:,iTrial,:));
            single_traj_proc = squeeze(traj_proc_mat(:,iTrial,:));
            % Check if too much data is missing.
            success(ismember(screen_reasons, 'missing_data')) = testAmountData(single_traj, p);
            % Check if reach distance is too short.
            success(ismember(screen_reasons, 'short_traj')) = testReachDist(single_traj_proc, p);
            % Check if finger missed target.
            if contains(traj_names{iTraj}{1}, '_to')
                success(ismember(screen_reasons, 'missed_target')) = testMissTarget(single_traj, p);
            end
            bad_trials{iTraj, iSub}{iTrial,:} = ~success * iTrial;
        end
        
        % Mark if any test failed.
        bad_trials{iTraj, iSub}.any = any(bad_trials{iTraj, iSub}{:,:} > 0, 2); % OR between columns (reasons).
        
        % Convert logical index to numberic index.
        for reason = screen_reasons
            with_zeros = ['  ' num2str(bad_trials{iTraj, iSub}{:, reason}') ' '];
            no_zeros = strrep(with_zeros, ' 0 ', '');
            no_zeros = regexprep(no_zeros, '\s\s+', ' ');
            bad_trials_index{iTraj, iSub}.(reason{:}) = no_zeros;
        end
    end
end
save('../processed_data/bad_trials.mat', 'bad_trials', 'bad_trials_index');
%% Sorting and averaging (within subject)
load('../processed_data/bad_trials.mat', 'bad_trials');
for iSub = sub_nums
    % Get sub data.
    traj_table = readtable([p.PROC_DATA_FOLDER '/sub' num2str(iSub) 'traj_proc.csv']);
    data_table = readtable([p.DATA_FOLDER '/sub' num2str(iSub) 'data.csv']);
    
    % remove practice.
    traj_table(traj_table{:,'practice'} == 1, :) = [];
    data_table(data_table{:,'practice'} == 1, :) = [];
    
    for iTraj = 1:length(traj_names)
        traj = traj_table{:, traj_names{iTraj}};
        % Reshape to convenient format.
        traj_mat = reshape(traj, p.NORM_FRAMES, p.NUM_TRIALS, 3); % 3 for (x,y,z).
        % Trial types.
        reach_dir_col = regexprep(traj_names{iTraj}{1}, '_x_.+', '_ans_left'); % name of traj's ans_left column.
        rt_col = regexprep(traj_names{iTraj}{1}, '_x_.+', '_rt'); % name of traj's rt column.
        bad = bad_trials{iTraj, iSub}.any;
        pas1 = data_table.('pas')==1;
        same = data_table.('same');
        left = data_table.(reach_dir_col);
        % Sort trials.
        single.trajs(iTraj).same_left  = traj_mat(:, ~bad & pas1 & same  & left, :);
        single.trajs(iTraj).same_right = traj_mat(:, ~bad & pas1 & same  & ~left, :);
        single.trajs(iTraj).diff_left  = traj_mat(:, ~bad & pas1 & ~same & left, :);
        single.trajs(iTraj).diff_right = traj_mat(:, ~bad & pas1 & ~same & ~left, :);
        single.rt(iTraj).same_left  = data_table.(rt_col)(~bad & pas1 & same  & left);
        single.rt(iTraj).same_right = data_table.(rt_col)(~bad & pas1 & same  & ~left);
        single.rt(iTraj).diff_left  = data_table.(rt_col)(~bad & pas1 & ~same & left);
        single.rt(iTraj).diff_right = data_table.(rt_col)(~bad & pas1 & ~same & ~left);
        % Average.
        avg.traj_table(iTraj).same_left  = squeeze(mean(single.trajs(iTraj).same_left , 2));
        avg.traj_table(iTraj).same_right = squeeze(mean(single.trajs(iTraj).same_right, 2));
        avg.traj_table(iTraj).diff_left  = squeeze(mean(single.trajs(iTraj).diff_left , 2));
        avg.traj_table(iTraj).diff_right = squeeze(mean(single.trajs(iTraj).diff_right, 2));
        avg.rt(iTraj).same_left  = squeeze(mean(single.rt(iTraj).same_left));
        avg.rt(iTraj).same_right = squeeze(mean(single.rt(iTraj).same_right));
        avg.rt(iTraj).diff_left  = squeeze(mean(single.rt(iTraj).diff_left));
        avg.rt(iTraj).diff_right = squeeze(mean(single.rt(iTraj).diff_right));
    end
    
    save(['../processed_data/sub' num2str(iSub) 'sorted_trials.mat'], 'single');
    save(['../processed_data/sub' num2str(iSub) 'avg.mat'], 'avg');
end
%% Plot
%@@@@@@@@@@@@@@@@@@ think about what plots you desire and rewrite this, because you wrote it just to get a preview.
load('../processed_data/bad_trials.mat', 'bad_trials');
close all;

% Color of plots.
space = 4; % between beeswarm graphs.
alpha = 0.3;
same_col = [0 0.4470 0.7410];%[0 0.4470 0.7410 alpha];
same_avg_col = 'b';
diff_col = [0.6350 0.0780 0.1840];%[0.6350 0.0780 0.1840 alpha];
diff_avg_col = 'r';
avg_plot_width = 4;

for iSub = sub_nums
    traj_table = readtable([p.PROC_DATA_FOLDER '/sub' num2str(iSub) 'traj_proc.csv']);
    data_table = readtable([p.DATA_FOLDER '/sub' num2str(iSub) 'data.csv']);
    load(['../processed_data/sub' num2str(iSub) 'sorted_trials.mat']);
    load(['../processed_data/sub' num2str(iSub) 'avg.mat']);
    
    % remove practice.
    traj_table(traj_table{:,'practice'} == 1, :) = [];
    data_table(data_table{:,'practice'} == 1, :) = [];
    
    traj_f = figure('Name',['sub' num2str(iSub) ' traj'],'WindowState','maximized', 'MenuBar','figure');
    rt_f = figure('Name',['sub' num2str(iSub) ' RT'],'WindowState','maximized', 'MenuBar','figure');
    vel_f = figure('Name',['sub' num2str(iSub) ' vel'],'WindowState','maximized', 'MenuBar','figure');
    
    for iTraj = 1:length(traj_names)
        % Flips traj to screen since its Z values are negative.
        if contains(traj_names{iTraj}{1}, '_to')
            flip_traj = -1;
        else
            flip_traj = 1;
        end
        
        % ------- X vs. Z -------
        figure(traj_f);
        subplot(2,2,iTraj);
        hold on;
        % single trial.
%         plot(single.trajs(iTraj).same_left(:,:,1),  single.trajs(iTraj).same_left(:,:,3)*flip_traj,  'Color',same_col);
%         plot(single.trajs(iTraj).same_right(:,:,1), single.trajs(iTraj).same_right(:,:,3)*flip_traj, 'Color',same_col);
%         plot(single.trajs(iTraj).diff_left(:,:,1),  single.trajs(iTraj).diff_left(:,:,3)*flip_traj,  'Color',diff_col);
%         plot(single.trajs(iTraj).diff_right(:,:,1), single.trajs(iTraj).diff_right(:,:,3)*flip_traj, 'Color',diff_col);
        % Averages.
%         plot(avg.traj_table(iTraj).same_left(:,1),  avg.traj_table(iTraj).same_left(:,3) * flip_traj,  same_avg_col, 'LineWidth',avg_plot_width);
%         plot(avg.traj_table(iTraj).same_right(:,1), avg.traj_table(iTraj).same_right(:,3) * flip_traj, same_avg_col, 'LineWidth',avg_plot_width);
%         plot(avg.traj_table(iTraj).diff_left(:,1),  avg.traj_table(iTraj).diff_left(:,3) * flip_traj,  diff_avg_col, 'LineWidth',avg_plot_width);
%         plot(avg.traj_table(iTraj).diff_right(:,1), avg.traj_table(iTraj).diff_right(:,3) * flip_traj, diff_avg_col, 'LineWidth',avg_plot_width);
        % plot's description.
        handle(1) = plot(nan,nan,'Color',same_col);
        handle(2) = plot(nan,nan,'Color',diff_col);
%         handle(3) = plot(nan,nan,same_avg_col);
%         handle(4) = plot(nan,nan,diff_avg_col);
        stdshade(single.trajs(iTraj).same_left(:,:,1)',  alpha, same_col, avg.traj_table(iTraj).same_left(:,3)*flip_traj, 0, 0);
        stdshade(single.trajs(iTraj).same_right(:,:,1)', alpha, same_col, avg.traj_table(iTraj).same_right(:,3)*flip_traj, 0, 0);
        stdshade(single.trajs(iTraj).diff_left(:,:,1)',  alpha, diff_col, avg.traj_table(iTraj).diff_left(:,3)*flip_traj, 0, 0);
        stdshade(single.trajs(iTraj).diff_right(:,:,1)', alpha, diff_col, avg.traj_table(iTraj).diff_right(:,3)*flip_traj, 0, 0);
        legend(handle, 'same', 'diff', 'Location','southeast');
        xlabel('X'); xlim([-0.12, 0.12]);
        ylabel('Z Axis (to screen)'); ylim([0, 0.4]);
        title(cell2mat(['Reach ' regexp(traj_names{iTraj}{1},'_._(.+)','tokens','once') ' ' regexp(traj_names{iTraj}{1},'(.+)_.+_','tokens','once')]));
        set(gca, 'FontSize',14);
        
        % ------- RT -------
        beesdata = {single.rt(iTraj).same_left, single.rt(iTraj).diff_left, single.rt(iTraj).same_right, single.rt(iTraj).diff_right};
        names = {'same left', 'diff left', 'same right', 'diff right'};%cellstr(strrep(fieldnames(single.rt), '_',' '))'; % remove '_' from names.
        colors = {same_col, diff_col, same_col, diff_col};
        title_char = cell2mat(['RT ' regexp(traj_names{iTraj}{1},'_._(.+)','tokens','once') ' ' regexp(traj_names{iTraj}{1},'(.+)_.+_','tokens','once')]);
        figure(rt_f);
        subplot(2,2,iTraj);
        hold on;
        printBeeswarm(beesdata, names, colors, space, title_char);
        
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
    end
    
    % Add sub num title.
    for fig = [traj_f, rt_f]
       figure(fig);
       annotation('textbox',[0.45 0.9 0.1 0.1], 'String',['Sub ' num2str(iSub)], 'FontSize',40, 'LineStyle','none', 'FitBoxToText','on');
    end
%     figure(vel_f);
%     suptitle(['Sub' num2str(iSub) ' Velocities']);
end