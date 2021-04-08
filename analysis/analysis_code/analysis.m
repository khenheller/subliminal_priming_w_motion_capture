clear all;
clc;
%% Parameters
load('../../experiment/RUN_ME/p.mat');
% @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@remove
p.PROC_DATA_FOLDER = '../processed_data';
p.DATA_FOLDER = '../../raw_data';
p.SAMPLE_RATE_HZ = p.REF_RATE_HZ; % Camera sample rate in Hz.
p.SAMPLE_RATE_SEC = 1 / p.SAMPLE_RATE_HZ; % Sec
p.TRAJ_FILT_ORDER = 2;
p.TRAJ_FILT_CUTOFF = 8;% in Hz.
p.VEL_FILTER_ORDER = 2;
p.VEL_FILTER_CUTOFF = 10;% in Hz.
% @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@remove
sub_nums = [1 1009];
p.norm_frames = 200; % length of normalized trajs.
p.norm_type = 4; % 1=to time, 2=to x, 3=to y, 4=to z.

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

addpath(genpath('./craig_code/'));
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
    matrix = matrix(1:p.norm_frames, :, :);
    traj_table = traj_table(1 : p.norm_frames * p.NUM_TRIALS, :);
    traj_table{:,:} = reshape(matrix, p.norm_frames * p.NUM_TRIALS, width(traj_table));
    
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
        traj_proc_mat = reshape(traj_proc, p.norm_frames, p.NUM_TRIALS, 3); % 3 for (x,y,z).
        
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
        traj_mat = reshape(traj, p.norm_frames, p.NUM_TRIALS, 3); % 3 for (x,y,z).
        % Seperate conditions, and left/right, and filter bad trials, and include only pas=1.
        left_reach = regexprep(traj_names{iTraj}{1}, '_x_.+', '_ans_left');
        bad = bad_trials{iTraj, iSub}.any;
        pas1 = data_table.('pas')==1;
        same = data_table.('same');
        left = data_table.(left_reach);
        trials(iTraj).same.left  = traj_mat(:, ~bad & pas1 & same  & left, :);
        trials(iTraj).same.right = traj_mat(:, ~bad & pas1 & same  & ~left, :);
        trials(iTraj).diff.left  = traj_mat(:, ~bad & pas1 & ~same & left, :);
        trials(iTraj).diff.right = traj_mat(:, ~bad & pas1 & ~same & ~left, :);
        % Average.
        avg_traj_table(iTraj).same.left  = squeeze(mean(trials(iTraj).same.left , 2));
        avg_traj_table(iTraj).same.right = squeeze(mean(trials(iTraj).same.right, 2));
        avg_traj_table(iTraj).diff.left  = squeeze(mean(trials(iTraj).diff.left , 2));
        avg_traj_table(iTraj).diff.right = squeeze(mean(trials(iTraj).diff.right, 2));
    end
    
    save(['../processed_data/sub' num2str(iSub) 'sorted_trials.mat'], 'trials');
    save(['../processed_data/sub' num2str(iSub) 'avg_traj.mat'], 'avg_traj_table');
end
%% Plot
%@@@@@@@@@@@@@@@@@@ think about what plots you desire and rewrite this, because you wrote it just to get a preview.
load('../processed_data/bad_trials.mat', 'bad_trials');
close all;

% Color of plots.
same_col = [0 0.4470 0.7410 0.3];
same_avg_col = 'b';
diff_col = [0.6350 0.0780 0.1840 0.3];
diff_avg_col = 'r';
avg_plot_width = 4;

for iSub = sub_nums
    traj_table = readtable([p.PROC_DATA_FOLDER '/sub' num2str(iSub) 'traj_proc.csv']);
    data_table = readtable([p.DATA_FOLDER '/sub' num2str(iSub) 'data.csv']);
    load(['../processed_data/sub' num2str(iSub) 'avg_traj.mat']);
    load(['../processed_data/sub' num2str(iSub) 'sorted_trials.mat']);
    
    % remove practice.
    traj_table(traj_table{:,'practice'} == 1, :) = [];
    data_table(data_table{:,'practice'} == 1, :) = [];
    
    traj_fig = figure('Name',['sub' num2str(iSub) ' traj'],'WindowState','maximized', 'MenuBar','figure');
    vel_fig = figure('Name',['sub' num2str(iSub) ' vel'],'WindowState','maximized', 'MenuBar','figure');
    
    for iTraj = 1:length(traj_names)
        % Flips traj to screen since its Z values are negative.
        if contains(traj_names{iTraj}{1}, '_to')
            flip_traj = -1;
        else
            flip_traj = 1;
        end
        
        figure(traj_fig);
        subplot(2,2,iTraj);
        hold on;
        % X as func of Z.
        plot(trials(iTraj).same.left(:,:,1),  trials(iTraj).same.left(:,:,3)*flip_traj,  'Color',same_col);
        plot(trials(iTraj).same.right(:,:,1), trials(iTraj).same.right(:,:,3)*flip_traj, 'Color',same_col);
        plot(trials(iTraj).diff.left(:,:,1),  trials(iTraj).diff.left(:,:,3)*flip_traj,  'Color',diff_col);
        plot(trials(iTraj).diff.right(:,:,1), trials(iTraj).diff.right(:,:,3)*flip_traj, 'Color',diff_col);
        % Averages.
        plot(avg_traj_table(iTraj).same.left(:,1),  avg_traj_table(iTraj).same.left(:,3) * flip_traj,  same_avg_col, 'LineWidth',avg_plot_width);
        plot(avg_traj_table(iTraj).same.right(:,1), avg_traj_table(iTraj).same.right(:,3) * flip_traj, same_avg_col, 'LineWidth',avg_plot_width);
        plot(avg_traj_table(iTraj).diff.left(:,1),  avg_traj_table(iTraj).diff.left(:,3) * flip_traj,  diff_avg_col, 'LineWidth',avg_plot_width);
        plot(avg_traj_table(iTraj).diff.right(:,1), avg_traj_table(iTraj).diff.right(:,3) * flip_traj, diff_avg_col, 'LineWidth',avg_plot_width);
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
        
        %{
        % calc velocity.-----------------------------------------------
        dx = traj_mat(2:end, :, :) - traj_mat(1:end-1, :, :); % distance between 2 samples.
        vel_per_axis = dx / p.SAMPLE_RATE_SEC;
        veloc = sqrt(sum(vel_per_axis.^2, 3));
        veloc = [veloc; veloc(end,:)];
        vel.same.left = veloc(:, same_trials.left);
        vel.same.right = veloc(:, same_trials.right);
        vel.diff.left = veloc(:, diff_trials.left);
        vel.diff.right = veloc(:, diff_trials.right);
        avg_vel.same.left = mean(vel.same.left, 2);
        avg_vel.same.right = mean(vel.same.right, 2);
        avg_vel.diff.left = mean(vel.diff.left, 2);
        avg_vel.diff.right = mean(vel.diff.right, 2);
        
        figure(vel_fig);
        subplot(2,2,iTraj);
        hold on;
        % Same trials left.
        plot(traj_mat(:, same_trials.left, 3)*flip_traj, vel.same.left, 'Color',[0 0.4470 0.7410 0.3]);
        % Same trials right.
        plot(traj_mat(:, same_trials.right, 3)*flip_traj, vel.same.right, 'Color',[0 0.4470 0.7410 0.3]);
        % diff trials left.
        plot(traj_mat(:, diff_trials.left, 3)*flip_traj, vel.diff.left, 'Color',[0.6350 0.0780 0.1840 0.3]);
        % diff trials right.
        plot(traj_mat(:, diff_trials.right, 3)*flip_traj, vel.diff.right, 'Color',[0.6350 0.0780 0.1840 0.3]);
        % Averages.
        plot(avg_traj_table.same.left{:, traj_names{iTraj}{3}}*flip_traj, avg_vel.same.left, 'b', 'LineWidth',4); % X as func of Z.
        plot(avg_traj_table.same.right{:, traj_names{iTraj}{3}}*flip_traj, avg_vel.same.right, 'b', 'LineWidth',4); % X as func of Z.
        plot(avg_traj_table.diff.left{:, traj_names{iTraj}{3}}*flip_traj, avg_vel.diff.left, 'r', 'LineWidth',4); % X as func of Z.
        plot(avg_traj_table.diff.right{:, traj_names{iTraj}{3}}*flip_traj, avg_vel.diff.right, 'r', 'LineWidth',4); % X as func of Z.
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
%     figure(traj_fig);
%     suptitle(['Sub' num2str(iSub)]);
%     figure(vel_fig);
%     suptitle(['Sub' num2str(iSub) ' Velocities']);
end