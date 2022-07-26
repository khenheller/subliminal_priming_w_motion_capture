clear all;
close all;
clc;

%% Parameters
disp("Started setting up params.")
load('../../experiment/RUN_ME/code/p.mat');
addpath(genpath('./imported_code'));

% Adjustable params.
SORTED_SUBS.EXP_1_SUBS = [1 2 3 4 5 6 7 8 9 10]; % Participated in experiment version 1.
SORTED_SUBS.EXP_2_SUBS = [11 12 13 14 16 17 18 19 20 21 22 23 24 25]; % Sub 15 didn't finish the experiment (pressed Esc).
SORTED_SUBS.EXP_3_SUBS = [26 28 29 31 32 33 34 35 37 38 39 40 42]; % Sub 27, 30, 36, 41 didn't arrive to day 2.
SORTED_SUBS.EXP_4_SUBS = [43 44];
SORTED_SUBS.EXP_4_1_SUBS = [47 49 : 58];
SUBS = SORTED_SUBS.EXP_1_SUBS; % to analyze.
DAY = 'day2';
pas_rate = 1; % to analyze.
bs_iter = 1000;
picked_trajs = [1]; % traj to analyze (1=to_target, 2=from_target, 3=to_prime, 4=from_prime).
p.SIMULATE = 0; % Simulate less trials.
p = defineParams(p, SUBS, DAY, SUBS(1), SORTED_SUBS);

% Name of trajectory column in output data. each cell is a incon type of traj.
traj_names = {{'target_x_to' 'target_y_to' 'target_z_to'},...
    {'target_x_from' 'target_y_from' 'target_z_from'},...
    {'prime_x_to' 'prime_y_to' 'prime_z_to'},...
    {'prime_x_from' 'prime_y_from' 'prime_z_from'}};
traj_names_mat = reshape(string([traj_names{:}]),3,[])';
writematrix(traj_names_mat, [p.PROC_DATA_FOLDER '/traj_names.csv']);
traj_names = traj_names(picked_trajs);
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
disp("Done setting params.");
%% Simulates an exp with less trials for each sub.
% You have to run this before the rest of the analysis if you wish to use simulated number of trials.
gen_files = 0; % Generates a new file for each sub. Use 0 only if you already generated in prev run.
new_num_bloks = 6;
idx_shift = 200; % data will be saved in a sub num = iSub + idx_shift.

if p.SIMULATE
    % Set new number of blocks.
    p.NUM_BLOCKS = new_num_bloks;
    p.NUM_TRIALS = p.NUM_BLOCKS * p.BLOCK_SIZE;

    if all(p.SUBS <= 10)
        n_practice_blocks = 1;
    else
        n_practice_blocks = 2;
    end
    new_traj_table_size = n_practice_blocks * p.BLOCK_SIZE * p.MAX_CAP_LENGTH + p.NUM_TRIALS * p.MAX_CAP_LENGTH;
    new_data_table_size = n_practice_blocks * p.BLOCK_SIZE + p.NUM_TRIALS;

    if gen_files
        tic
        disp('Creating reduced data files for sub:');
        for iSub = p.SUBS
            % Delete file if already exists.
            delete([p.DATA_FOLDER '/sub' num2str(iSub+idx_shift) p.DAY '_' 'traj.csv']);
            delete([p.DATA_FOLDER '/sub' num2str(iSub+idx_shift) p.DAY '_' 'data.csv']);
            % Reduces num of trials for each sub and saves it as a new sub.
            reach_traj_table = readtable([p.DATA_FOLDER '/sub' num2str(iSub) p.DAY '_' 'traj.csv']);
            reach_data_table = readtable([p.DATA_FOLDER '/sub' num2str(iSub) p.DAY '_' 'data.csv']);
            reach_traj_table = reach_traj_table(1:min(new_traj_table_size, height(reach_traj_table)), :);
            reach_data_table = reach_data_table(1:min(new_data_table_size, height(reach_data_table)), :);
            writetable(reach_traj_table, [p.DATA_FOLDER '/sub' num2str(iSub+idx_shift) p.DAY '_' 'traj.csv']);
            writetable(reach_data_table, [p.DATA_FOLDER '/sub' num2str(iSub+idx_shift) p.DAY '_' 'data.csv']);
            % Copy p.mat and start_end_point to new sub.
            copyfile([p.DATA_FOLDER '/sub' num2str(iSub) p.DAY '_' 'start_end_points.mat'], [p.DATA_FOLDER '/sub' num2str(iSub+idx_shift) p.DAY '_' 'start_end_points.mat'], 'f');
            copyfile([p.DATA_FOLDER '/sub' num2str(iSub) p.DAY '_' 'p.mat'], [p.DATA_FOLDER '/sub' num2str(iSub+idx_shift) p.DAY '_' 'p.mat'], 'f');
            disp(num2str(iSub));
        end
        timing = num2str(toc);
        disp(['Done Creating reduced subs. ' timing 'Sec'])
    end
    p.SUBS = p.SUBS + idx_shift;
    p = defineParams(p, p.SUBS, DAY, p.SUBS(1), SORTED_SUBS);
    disp("Done Simulating less trials.");
end
%% Create proc data file
% Copy the real data to a new file, to keep the original data safe.
tic
disp('Creating processing data files for sub:');
for iSub = p.SUBS
    reach_traj_table = readtable([p.DATA_FOLDER '/sub' num2str(iSub) p.DAY '_reach_traj.csv']);
    reach_data_table = readtable([p.DATA_FOLDER '/sub' num2str(iSub) p.DAY '_reach_data.csv']);
    % Fake keybaord data for Exp1,2,3.
    if any(p.SUBS < 43)
        keyboard_data_table = readtable([p.DATA_FOLDER '/sub49' p.DAY '_keyboard_data.csv']);
        keyboard_data_table.sub_num = p.SUB_NUM * ones(size(keyboard_data_table.sub_num));
    else
        keyboard_data_table = readtable([p.DATA_FOLDER '/sub' num2str(iSub) p.DAY '_keyboard_data.csv']);
    end
    % Change 'same' column to 'con'.
    if any(contains(reach_data_table.Properties.VariableNames, 'same'))
        reach_data_table.Properties.VariableNames{'same'} = 'con';
        keyboard_data_table.Properties.VariableNames{'same'} = 'con';
    end
    save([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_reach_traj.mat'], 'reach_traj_table'); % '.mat' is faster to read than '.csv'.
    save([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_reach_data.mat'], 'reach_data_table');
    save([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_keyboard_data.mat'], 'keyboard_data_table');
    disp(num2str(iSub));
end
timing = num2str(toc);
disp(['Done Creating processing data files. ' timing 'Sec'])
%% Add fields
% Adds missing fields:
% late_res and slow_mvmnt fields to sub 1-14.
% quit to sub 1-38.
tic
disp('Adding missing fields to sub:');
for iSub = p.SUBS
    % Checks if the fields were already added.
    reach_data_table = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_reach_data.mat']);  reach_data_table = reach_data_table.reach_data_table;
    fields = reach_data_table.Properties.VariableNames;
    has_t_fields = any(contains(fields, 'late_res')) &...
        any(contains(fields, 'slow_mvmnt')) &...
        any(contains(fields, 'early_res'));
    has_q_field = any(contains(fields, 'quit'));
    % If fields don't exist, add them.
    if ~has_t_fields || ~has_q_field
        reach_traj_table = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_reach_traj.mat']);  reach_traj_table = reach_traj_table.reach_traj_table;
        if ~has_t_fields
            start_end_points = load([p.DATA_FOLDER '/sub' num2str(iSub) p.DAY '_' 'start_end_points.mat']);
            p.START_POINT = start_end_points.p.START_POINT;
            reach_data_table = addFields(reach_data_table, reach_traj_table, p);
            disp([num2str(iSub) ' timing fields']);
        end
        if ~has_q_field
            reach_data_table.quit(:) = 0;
            disp([num2str(iSub) ' quit field']);
        end
        save([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_reach_data.mat'], 'reach_data_table');
    end
end
timing = num2str(toc);
disp(['Done Adding missing fields. ' timing 'Sec'])
%% Add trials.
% Adds trials to subjects who quit before the experiment ended.
tic
for iSub = p.SUBS
    reach_traj_table = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_reach_traj.mat']);  reach_traj_table = reach_traj_table.reach_traj_table;
    reach_data_table = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_reach_data.mat']);  reach_data_table = reach_data_table.reach_data_table;
    keyboard_data_table = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_keyboard_data.mat']);  keyboard_data_table = keyboard_data_table.keyboard_data_table;
    % Remove practice
    reach_traj_table(reach_traj_table.practice > 0, :) = [];
    reach_data_table(reach_data_table.practice > 0, :) = [];
    keyboard_data_table(keyboard_data_table.practice > 0, :) = [];
    % Fill missing trials.
    reach_last_trial = height(reach_data_table);
    keyboard_last_trial = height(keyboard_data_table);
    if reach_last_trial < p.NUM_TRIALS || keyboard_last_trial < p.NUM_TRIALS
        reach_traj_table{reach_last_trial*p.MAX_CAP_LENGTH+1 : p.NUM_TRIALS*p.MAX_CAP_LENGTH, 'iTrial'} = nan;
        reach_data_table{reach_last_trial+1 : p.NUM_TRIALS, 'iTrial'} = nan;
        keyboard_data_table{keyboard_last_trial+1 : p.NUM_TRIALS, 'iTrial'} = nan;
        % Mark missing trials.
        reach_data_table{reach_last_trial+1 : end, 'quit'} = 1;
        keyboard_data_table{keyboard_last_trial+1 : end, 'quit'} = 1;
        save([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_reach_data.mat'], 'reach_data_table');
        save([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_reach_traj.mat'], 'reach_traj_table');
        save([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_keyboard_data.mat'], 'keyboard_data_table');
        disp(['Added missing trials to sub' num2str(iSub)]);
    end
end
timing = num2str(toc);
disp(['Done adding missing trials. ' timing 'Sec'])
%% Preprocessing & Normalization
% Trials too short to filter.
tic
too_short_to_filter = table('Size', [max(p.SUBS) length(traj_types)],...
    'VariableTypes', repmat({'cell'}, length(traj_types), 1),...
    'VariableNames', traj_types);
disp('Preprocessing done for subject:');
for iSub = p.SUBS
    p = defineParams(p, p.SUBS, DAY, iSub, SORTED_SUBS);
    reach_traj_table = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_reach_traj.mat']);  reach_traj_table = reach_traj_table.reach_traj_table;
    reach_data_table = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_reach_data.mat']);  reach_data_table = reach_data_table.reach_data_table;
    keyboard_data_table = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_keyboard_data.mat']);  keyboard_data_table = keyboard_data_table.keyboard_data_table;
    
    % remove practice.
    reach_traj_table(reach_traj_table{:,'practice'} > 0, :) = [];
    reach_data_table(reach_data_table{:,'practice'} > 0, :) = [];
    keyboard_data_table(keyboard_data_table{:,'practice'} > 0, :) = [];
    
    % Preprocessing and normalization.
    for iTraj = 1:length(traj_names)
        [reach_traj_table, reach_data_table, too_short_to_filter{iSub, iTraj}{:}, reach_pre_norm_traj_table] = preproc(reach_traj_table, reach_data_table, traj_names{iTraj}, p);
    end
    % Trim to normalized length (=p.norm_frames).
    matrix = reshape(reach_traj_table{:,:}, p.MAX_CAP_LENGTH, p.NUM_TRIALS, width(reach_traj_table));
    matrix = matrix(1:p.NORM_FRAMES, :, :);
    reach_traj_table = reach_traj_table(1 : p.NORM_FRAMES * p.NUM_TRIALS, :);
    reach_traj_table{:,:} = reshape(matrix, p.NORM_FRAMES * p.NUM_TRIALS, width(reach_traj_table));
    % Save
    save([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_reach_pre_norm_traj.mat'], 'reach_pre_norm_traj_table');
    save([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_reach_traj_proc.mat'], 'reach_traj_table');
    save([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_reach_data_proc.mat'], 'reach_data_table');
    save([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_keyboard_data_proc.mat'], 'keyboard_data_table'); % Keyboard data isn't pre-processed because there is no need for that.
    disp(num2str(iSub));
end
disp('Following trials where too short to filter:');
disp(too_short_to_filter);
save([p.PROC_DATA_FOLDER '/too_short_to_filter_'  p.DAY '_subs_' p.SUBS_STRING '.mat'], 'too_short_to_filter');
timing = num2str(toc);
disp(['Preprocessing done. ' timing 'Sec']);
%% Trial Screening
tic
for iTraj = 1:length(traj_names)
    [reach_bad_trials, reach_n_bad_trials, reach_bad_trials_i] = trialScreen(traj_names{iTraj}, 'reach', p);
    % Exp 1,2,3 has no keybaord session.
    if any(p.SUBS < 43)
        keyboard_n_bad_trials = array2table(zeros(size(reach_n_bad_trials)), 'VariableNames',reach_n_bad_trials.Properties.VariableNames);
        keyboard_bad_trials_i = table('size',size(reach_bad_trials_i), 'variableNames',reach_bad_trials_i.Properties.VariableNames, 'VariableTypes',repmat("cell", [1, width(reach_bad_trials_i)]));
        keyboard_bad_trials = {};
        for iSub = p.SUBS
            keyboard_bad_trials{iSub,1} = array2table(zeros(size(reach_bad_trials{iSub})), 'VariableNames',reach_bad_trials{iSub}.Properties.VariableNames);
        end
    else
        [keyboard_bad_trials, keyboard_n_bad_trials, keyboard_bad_trials_i] = trialScreen(traj_names{iTraj}, 'keyboard', p);
    end
    save([p.PROC_DATA_FOLDER '/bad_trials_' p.DAY '_' traj_names{iTraj}{1} '_subs_' p.SUBS_STRING '.mat'], 'reach_bad_trials', 'reach_n_bad_trials', 'reach_bad_trials_i', 'keyboard_bad_trials', 'keyboard_n_bad_trials', 'keyboard_bad_trials_i');
end
timing = num2str(toc);
disp(['Trial screening done. ' timing 'Sec']);
%% Subject screening
tic
for iTraj = 1:length(traj_names')
    reach_bad_subs = subScreening(traj_names{iTraj}, pas_rate, 'reach', p);
    keyboard_bad_subs = subScreening(traj_names{iTraj}, pas_rate, 'keyboard', p);
    % Exp 1,2,3 had no keyboard task.
    if any(p.SUBS < 43)
        keyboard_bad_subs(:,:) = array2table(zeros(size(keyboard_bad_subs)));
    end
    bad_subs = array2table(reach_bad_subs{:,:} | keyboard_bad_subs{:,:}, 'VariableNames',reach_bad_subs.Properties.VariableNames);
    good_subs = p.SUBS(~ismember(p.SUBS, find(bad_subs.any)));
    save([p.PROC_DATA_FOLDER '/bad_subs_' p.DAY '_' traj_names{iTraj}{1} '_subs_' p.SUBS_STRING '.mat'], 'bad_subs', 'reach_bad_subs', 'keyboard_bad_subs');
    save([p.PROC_DATA_FOLDER '/good_subs_' p.DAY '_' traj_names{iTraj}{1} '_subs_' p.SUBS_STRING '.mat'], 'good_subs');
end
timing = num2str(toc);
disp(['Sub screening done. ' timing 'Sec']);
%% Maximum absolute deviation
tic
for iTraj = 1:length(traj_names)
    for iSub = p.SUBS
        reach_traj_table = load([p.PROC_DATA_FOLDER 'sub' num2str(iSub) p.DAY '_reach_traj_proc.mat']);  reach_traj_table = reach_traj_table.reach_traj_table;
        reach_data_table = load([p.PROC_DATA_FOLDER 'sub' num2str(iSub) p.DAY '_reach_data_proc.mat']);  reach_data_table = reach_data_table.reach_data_table;
        reach_data_table = calcMAD(reach_traj_table, reach_data_table, traj_names{iTraj}, p);
        save([p.PROC_DATA_FOLDER 'sub' num2str(iSub) p.DAY '_reach_data_proc.mat'], 'reach_data_table');
    end
end
timing = num2str(toc);
disp(['MAD calc done. ' timing 'Sec']);
%% Heading angle
tic
for iSub = p.SUBS
    reach_traj_table = load([p.PROC_DATA_FOLDER 'sub' num2str(iSub) p.DAY '_reach_traj_proc.mat']);  reach_traj_table = reach_traj_table.reach_traj_table;
    reach_traj_table = calcHeadAngle(reach_traj_table, p);
    save([p.PROC_DATA_FOLDER 'sub' num2str(iSub) p.DAY '_reach_traj_proc.mat'], 'reach_traj_table');
end
timing = num2str(toc);
disp(['Heading angle calc done. ' timing 'Sec']);
%% Changes of mind
tic
for iSub = p.SUBS
    reach_traj_table = load([p.PROC_DATA_FOLDER 'sub' num2str(iSub) p.DAY '_reach_traj_proc.mat']);  reach_traj_table = reach_traj_table.reach_traj_table;
    reach_data_table = load([p.PROC_DATA_FOLDER 'sub' num2str(iSub) p.DAY '_reach_data_proc.mat']);  reach_data_table = reach_data_table.reach_data_table;
    reach_data_table = countCom(reach_traj_table, reach_data_table, p);
    save([p.PROC_DATA_FOLDER 'sub' num2str(iSub) p.DAY '_reach_data_proc.mat'], 'reach_data_table');
end
timing = num2str(toc);
disp(['COM calc done. ' timing 'Sec']);
%% Total distance traveled
tic
for iSub = p.SUBS
    reach_traj_table = load([p.PROC_DATA_FOLDER 'sub' num2str(iSub) p.DAY '_reach_traj_proc.mat']);  reach_traj_table = reach_traj_table.reach_traj_table;
    reach_data_table = load([p.PROC_DATA_FOLDER 'sub' num2str(iSub) p.DAY '_reach_data_proc.mat']);  reach_data_table = reach_data_table.reach_data_table;
    reach_data_table = calcTotDistTravel(reach_traj_table, reach_data_table, p);
    save([p.PROC_DATA_FOLDER 'sub' num2str(iSub) p.DAY '_reach_data_proc.mat'], 'reach_data_table');
end
timing = num2str(toc);
disp(['Total distance traveled calc done. ' timing 'Sec']);
%% Sorting and averaging (within subject)
tic
for iTraj = 1:length(traj_names)
    bad_trials = load([p.PROC_DATA_FOLDER '/bad_trials_' p.DAY '_' traj_names{iTraj}{1} '_subs_' p.SUBS_STRING '.mat']);
    reach_bad_trials = bad_trials.reach_bad_trials;
    keyboard_bad_trials = bad_trials.keyboard_bad_trials;
    for iSub = p.SUBS
        [reach_avg, reach_single, keyboard_avg, keyboard_single] = avgWithin(iSub, traj_names{iTraj}, reach_bad_trials, keyboard_bad_trials, pas_rate, p);
        save([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_sorted_trials_' traj_names{iTraj}{1} '.mat'], 'reach_single', 'keyboard_single');
        save([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_avg_' traj_names{iTraj}{1} '.mat'], 'reach_avg', 'keyboard_avg');
    end
end
timing = num2str(toc);
disp(['Sorting and avging within sub done. ' timing 'Sec']);
%% Reach Area
% Area between left and right traj for con/incon condition.
tic
for iTraj = 1:length(traj_names)
    reach_area.con = NaN(1,p.MAX_SUB);
    reach_area.incon = NaN(1,p.MAX_SUB);
    
    good_subs = load([p.PROC_DATA_FOLDER '/good_subs_' p.DAY '_' traj_names{iTraj}{1} '_subs_' p.SUBS_STRING '.mat']);  good_subs = good_subs.good_subs;
    
    for iSub = good_subs
        reach_avg = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_avg_' traj_names{iTraj}{1} '.mat']);  reach_avg = reach_avg.reach_avg;
        reach_area.con(iSub) = calcReachArea(reach_avg.traj.con_left, reach_avg.traj.con_right, p);
        reach_area.incon(iSub) = calcReachArea(reach_avg.traj.incon_left, reach_avg.traj.incon_right, p);
    end
    save([p.PROC_DATA_FOLDER 'reach_area_' traj_names{iTraj}{1} '_' p.DAY '_subs_' p.SUBS_STRING '.mat'], 'reach_area');
end
timing = num2str(toc);
disp(['Reach area calc done. ' timing 'Sec']);
%% Sorting and averaging (between subjects)
tic
for iTraj = 1:length(traj_names)
    [reach_subs_avg, keyboard_subs_avg] = avgBetween(traj_names{iTraj}, p);
    save([p.PROC_DATA_FOLDER '/subs_avg_' p.DAY '_' traj_names{iTraj}{1} '_subs_' p.SUBS_STRING '.mat'], 'reach_subs_avg', 'keyboard_subs_avg');
end
timing = num2str(toc);
disp(['Sorting and avging between sub done. ' timing 'Sec']);
%% FDA
tic
for iTraj = 1:length(traj_names)
    [p_val, corr_p, ~, stats] = runFDA(traj_names{iTraj}, p);
    save([p.PROC_DATA_FOLDER '/fda_' p.DAY '_' traj_names{iTraj}{1} '_subs_' p.SUBS_STRING '.mat'], 'p_val','corr_p','stats');
end
timing = num2str(toc);
disp(['FDA calc done. ' timing 'Sec']);
%% Count trials
tic
for iTraj = 1:length(traj_names)
    num_trials = struct('con_left',NaN(p.MAX_SUB,1), 'con_right',NaN(p.MAX_SUB,1),...
        'incon_left',NaN(p.MAX_SUB,1), 'incon_right',NaN(p.MAX_SUB,1));
    for iSub = p.SUBS
        % Get trials stats for this sub.
        single = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_sorted_trials_' traj_names{iTraj}{1} '.mat']);
        reach_single = single.reach_single;
        keyboard_single = single.keyboard_single;
        reach_num_trials.con_left(iSub)  = size(reach_single.rt.con_left, 1);
        reach_num_trials.con_right(iSub) = size(reach_single.rt.con_right, 1);
        reach_num_trials.incon_left(iSub)  = size(reach_single.rt.incon_left, 1);
        reach_num_trials.incon_right(iSub) = size(reach_single.rt.incon_right, 1);
        keyboard_num_trials.con_left(iSub)  = size(keyboard_single.rt.con_left, 1);
        keyboard_num_trials.con_right(iSub) = size(keyboard_single.rt.con_right, 1);
        keyboard_num_trials.incon_left(iSub)  = size(keyboard_single.rt.incon_left, 1);
        keyboard_num_trials.incon_right(iSub) = size(keyboard_single.rt.incon_right, 1);
    end
    save([p.PROC_DATA_FOLDER '/num_trials_' p.DAY '_' traj_names{iTraj}{1} '_subs_' p.SUBS_STRING '.mat'], 'reach_num_trials', 'keyboard_num_trials');
end
timing = num2str(toc);
disp(['Counting trials in each condition done. ' timing 'Sec']);
%% Format to R
% % Convert matlab data to a format suitable for R dataframes.
% You are not doing things correctly. You should bootstrap subjects not trials. bootstrapping trials creates a false distribution for each subject that doens't represent his real data.
% tic
% for iTraj = 1:length(traj_names)
%     % Get bad subs.
%     bad_subs = load([p.PROC_DATA_FOLDER '/bad_subs_' p.DAY '_' traj_names{iTraj}{1} '_subs_' p.SUBS_STRING '.mat'], 'bad_subs');  bad_subs = bad_subs.bad_subs;
%     bad_subs_numbers = find(bad_subs.any);
%     
%     % Reach Area.
%     reach_area = fReachArea(traj_names{iTraj}, bs_iter, p);
%     writetable(reach_area, [p.PROC_DATA_FOLDER '/reach_area_' p.DAY '_' traj_names{iTraj}{1} '_subs_' p.SUBS_STRING '.csv']);
% 
%     % MAD
%     mad = fMAD(traj_names{iTraj}, p);
%     mad(ismember(mad.sub, bad_subs_numbers), :) = [];
%     writetable(mad, [p.PROC_DATA_FOLDER '/mad_' p.DAY '_' traj_names{iTraj}{1} '_subs_' p.SUBS_STRING '.csv']);
% 
%     % Traj
%     traj = fTraj(traj_names{iTraj}, p);
%     traj(ismember(traj.sub, bad_subs_numbers), :) = [];
%     writetable(traj, [p.PROC_DATA_FOLDER '/xpos_' p.DAY '_' traj_names{iTraj}{1} '_subs_' p.SUBS_STRING '.csv']);
% end
% timing = num2str(toc);
% disp(['Formating to R done. ' timing 'Sec']);
% % You are not doing things correctly. You should bootstrap subjects not trials. bootstrapping trials creates a false distribution for each subject that doens't represent his real data.
%% Plotting params
disp("Started setting plotting params.");
close all;

plt_p.avg_plot_width = 4;
plt_p.alpha_size = 0.05; % For confidence interval.
plt_p.space = 4; % between beeswarm graphs.
% Color of plots.
plt_p.f_alpha = 0.2; % transperacy of shading.
plt_p.linewidth = 4; % Used for some graphs.
plt_p.con_col = [0 0.35294 0.7098];%[0 0.4470 0.7410 f_f_alpha];
plt_p.con_avg_col = 'b';
plt_p.incon_col = [0.86275 0.19608 0.12549];%[0.6350 0.0780 0.1840 f_f_alpha];
plt_p.incon_avg_col = 'r';
plt_p.reach_color = [225 225 225] / 255; % used when comparing exp 2 and 3.
plt_p.keyboard_color = [0 146 146] / 255;
plt_p.first_practice_color = [125 255 0] / 255;
plt_p.second_practice_color = [0 125 0] / 255;
plt_p.test_color = [240 240 30] / 255;

% Load reach area.
reach_area = load([p.PROC_DATA_FOLDER 'reach_area_' traj_names{1}{1} '_' p.DAY '_subs_' p.SUBS_STRING '.mat']);  reach_area = reach_area.reach_area;

% Unite all subs to one variable.
for iSub = p.SUBS
    for iTraj = 1:length(traj_names)
        avg = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_' 'avg_' traj_names{iTraj}{1} '.mat']);
        reach_avg = avg.reach_avg;
        keyboard_avg = avg.keyboard_avg;
        % Seperate avg for left and right.
        reach_avg_each.traj(iTraj).con_left(:,iSub,:) = reach_avg.traj.con_left;
        reach_avg_each.traj(iTraj).con_right(:,iSub,:) = reach_avg.traj.con_right;
        reach_avg_each.traj(iTraj).incon_left(:,iSub,:) = reach_avg.traj.incon_left;
        reach_avg_each.traj(iTraj).incon_right(:,iSub,:) = reach_avg.traj.incon_right;
        reach_avg_each.rt(iTraj).con_left(iSub)  = reach_avg.rt.con_left;
        reach_avg_each.rt(iTraj).con_right(iSub) = reach_avg.rt.con_right;
        reach_avg_each.rt(iTraj).incon_left(iSub)  = reach_avg.rt.incon_left;
        reach_avg_each.rt(iTraj).incon_right(iSub) = reach_avg.rt.incon_right;
        reach_avg_each.react(iTraj).con_left(iSub)  = reach_avg.react.con_left;
        reach_avg_each.react(iTraj).con_right(iSub) = reach_avg.react.con_right;
        reach_avg_each.react(iTraj).incon_left(iSub)  = reach_avg.react.incon_left;
        reach_avg_each.react(iTraj).incon_right(iSub) = reach_avg.react.incon_right;
        reach_avg_each.mt(iTraj).con_left(iSub)  = reach_avg.mt.con_left;
        reach_avg_each.mt(iTraj).con_right(iSub) = reach_avg.mt.con_right;
        reach_avg_each.mt(iTraj).incon_left(iSub)  = reach_avg.mt.incon_left;
        reach_avg_each.mt(iTraj).incon_right(iSub) = reach_avg.mt.incon_right;
        reach_avg_each.mad(iTraj).con_left(iSub)  = reach_avg.mad.con_left;
        reach_avg_each.mad(iTraj).con_right(iSub) = reach_avg.mad.con_right;
        reach_avg_each.mad(iTraj).incon_left(iSub)  = reach_avg.mad.incon_left;
        reach_avg_each.mad(iTraj).incon_right(iSub) = reach_avg.mad.incon_right;
        reach_avg_each.com(iTraj).con_left(iSub)  = reach_avg.com.con_left;
        reach_avg_each.com(iTraj).con_right(iSub) = reach_avg.com.con_right;
        reach_avg_each.com(iTraj).incon_left(iSub)  = reach_avg.com.incon_left;
        reach_avg_each.com(iTraj).incon_right(iSub) = reach_avg.com.incon_right;
        reach_avg_each.tot_dist(iTraj).con_left(iSub)  = reach_avg.tot_dist.con_left;
        reach_avg_each.tot_dist(iTraj).con_right(iSub) = reach_avg.tot_dist.con_right;
        reach_avg_each.tot_dist(iTraj).incon_left(iSub)  = reach_avg.tot_dist.incon_left;
        reach_avg_each.tot_dist(iTraj).incon_right(iSub) = reach_avg.tot_dist.incon_right;
        reach_avg_each.x_std(iTraj).con_left(:,iSub)  = reach_avg.x_std.con_left;
        reach_avg_each.x_std(iTraj).con_right(:,iSub) = reach_avg.x_std.con_right;
        reach_avg_each.x_std(iTraj).incon_left(:,iSub)  = reach_avg.x_std.incon_left;
        reach_avg_each.x_std(iTraj).incon_right(:,iSub) = reach_avg.x_std.incon_right;
        reach_avg_each.cond_diff(iTraj).left(:,iSub,:)  = reach_avg.cond_diff.left;
        reach_avg_each.cond_diff(iTraj).right(:,iSub,:) = reach_avg.cond_diff.right;
        keyboard_avg_each.rt(iTraj).con_left(iSub)  = keyboard_avg.rt.con_left;
        keyboard_avg_each.rt(iTraj).con_right(iSub) = keyboard_avg.rt.con_right;
        keyboard_avg_each.rt(iTraj).incon_left(iSub)  = keyboard_avg.rt.incon_left;
        keyboard_avg_each.rt(iTraj).incon_right(iSub) = keyboard_avg.rt.incon_right;
        % Combined avg of left and right.
        reach_avg_each.traj(iTraj).con(:, iSub, :) = (reach_avg.traj.con_right + reach_avg.traj.con_left .* [-1,1,1]) / 2;
        reach_avg_each.traj(iTraj).incon(:, iSub, :) = (reach_avg.traj.incon_right + reach_avg.traj.incon_left .* [-1,1,1]) / 2;
        reach_avg_each.rt(iTraj).con(iSub) = mean([reach_avg.rt.con_right, reach_avg.rt.con_left]);
        reach_avg_each.rt(iTraj).incon(iSub) = mean([reach_avg.rt.incon_right, reach_avg.rt.incon_left]);
        reach_avg_each.react(iTraj).con(iSub) = mean([reach_avg.react.con_right, reach_avg.react.con_left]);
        reach_avg_each.react(iTraj).incon(iSub) = mean([reach_avg.react.incon_right, reach_avg.react.incon_left]);
        reach_avg_each.mt(iTraj).con(iSub) = mean([reach_avg.mt.con_right, reach_avg.mt.con_left]);
        reach_avg_each.mt(iTraj).incon(iSub) = mean([reach_avg.mt.incon_right, reach_avg.mt.incon_left]);
        reach_avg_each.mad(iTraj).con(iSub) = mean([reach_avg.mad.con_right, reach_avg.mad.con_left]);
        reach_avg_each.mad(iTraj).incon(iSub) = mean([reach_avg.mad.incon_right, reach_avg.mad.incon_left]);
        reach_avg_each.com(iTraj).con(iSub) = mean([reach_avg.com.con_right, reach_avg.com.con_left]);
        reach_avg_each.com(iTraj).incon(iSub) = mean([reach_avg.com.incon_right, reach_avg.com.incon_left]);
        reach_avg_each.tot_dist(iTraj).con(iSub) = mean([reach_avg.tot_dist.con_right, reach_avg.tot_dist.con_left]);
        reach_avg_each.tot_dist(iTraj).incon(iSub) = mean([reach_avg.tot_dist.incon_right, reach_avg.tot_dist.incon_left]);
        reach_avg_each.x_std(iTraj).con(:, iSub) = mean([reach_avg.x_std.con_right, reach_avg.x_std.con_left], 2);
        reach_avg_each.x_std(iTraj).incon(:, iSub) = mean([reach_avg.x_std.incon_right, reach_avg.x_std.incon_left], 2);
        reach_avg_each.ra(iTraj).con(iSub) = reach_area.con(iSub);
        reach_avg_each.ra(iTraj).incon(iSub) = reach_area.incon(iSub);
        keyboard_avg_each.rt(iTraj).con(iSub) = mean([keyboard_avg.rt.con_right, keyboard_avg.rt.con_left]);
        keyboard_avg_each.rt(iTraj).incon(iSub) = mean([keyboard_avg.rt.incon_right, keyboard_avg.rt.incon_left]);
        % Compute diff between conditions (con/incon).
        reach_avg_each.rt(iTraj).diff(iSub)  = mean([reach_avg.rt.con_left - reach_avg.rt.incon_left,...
                                                reach_avg.rt.con_right - reach_avg.rt.incon_right]);
        reach_avg_each.react(iTraj).diff(iSub)  = mean([reach_avg.react.con_left - reach_avg.react.incon_left,...
                                                reach_avg.react.con_right - reach_avg.react.incon_right]);
        reach_avg_each.mt(iTraj).diff(iSub)  = mean([reach_avg.mt.con_left - reach_avg.mt.incon_left,...
                                                reach_avg.mt.con_right - reach_avg.mt.incon_right]);
        reach_avg_each.mad(iTraj).diff(iSub)  = mean([reach_avg.mad.con_left - reach_avg.mad.incon_left,...
                                                reach_avg.mad.con_right - reach_avg.mad.incon_right]);
        reach_avg_each.x_dev(iTraj).diff(:,iSub) = mean([-1 * (reach_avg.traj.con_left(:,1) - reach_avg.traj.incon_left(:,1)),...
                                                    (reach_avg.traj.con_right(:,1) - reach_avg.traj.incon_right(:,1))],...
                                                    2);
        reach_avg_each.x_std(iTraj).diff(:,iSub) = mean([reach_avg.x_std.con_left - reach_avg.x_std.incon_left,...
                                                    reach_avg.x_std.con_right - reach_avg.x_std.incon_right],...
                                                    2);
        reach_avg_each.ra(iTraj).diff(iSub) = reach_area.con(iSub) - reach_area.incon(iSub);
        keyboard_avg_each.rt(iTraj).diff(iSub)  = mean([keyboard_avg.rt.con_left - keyboard_avg.rt.incon_left,...
                                                keyboard_avg.rt.con_right - keyboard_avg.rt.incon_right]);
    end
    reach_avg_each.fc_prime.con(iSub) = reach_avg.fc_prime.con;
    reach_avg_each.fc_prime.incon(iSub) = reach_avg.fc_prime.incon;
    keyboard_avg_each.fc_prime.con(iSub) = keyboard_avg.fc_prime.con;
    keyboard_avg_each.fc_prime.incon(iSub) = keyboard_avg.fc_prime.incon;
end
save([p.PROC_DATA_FOLDER '/avg_each_' p.DAY '_' traj_names{iTraj}{1} '_subs_' p.SUBS_STRING '.mat'], 'reach_avg_each', 'keyboard_avg_each');
disp("Done setting plotting params.");
%% Single Sub plots.
% Create figure for each sub.
for iSub = p.SUBS
    sub_f(iSub,1) = figure('Name',['Sub ' num2str(iSub)], 'WindowState','maximized', 'MenuBar','figure');
    sub_f(iSub,2) = figure('Name',['Sub ' num2str(iSub)], 'WindowState','maximized', 'MenuBar','figure');
    sub_f(iSub,3) = figure('Name',['Sub ' num2str(iSub)], 'WindowState','maximized', 'MenuBar','figure');
    % Add title.
    figure(sub_f(iSub,1)); annotation('textbox',[0.45 0.915 0.1 0.1], 'String',['Sub ' num2str(iSub)], 'FontSize',30, 'LineStyle','none', 'FitBoxToText','on');
    figure(sub_f(iSub,2)); annotation('textbox',[0.45 0.915 0.1 0.1], 'String',['Sub ' num2str(iSub)], 'FontSize',30, 'LineStyle','none', 'FitBoxToText','on');
%     figure(sub_f(iSub,3)); annotation('textbox',[0.45 0.915 0.1 0.1], 'String',['Sub ' num2str(iSub)], 'FontSize',30, 'LineStyle','none', 'FitBoxToText','on');
end

% ------- Traj of each trial -------
for iSub = p.SUBS
    figure(sub_f(iSub,1));
    subplot(2,3,1);
    plotAllTrajs(iSub, traj_names, plt_p, p);
end

% ------- Avg traj with shade -------
for iSub = p.SUBS
    figure(sub_f(iSub,1));
    subplot(2,3,2);
    plotAvgTrajWithShade(iSub, traj_names, plt_p, p);
end

% ------- React + Movement + Response Times -------
for iSub = p.SUBS
    figure(sub_f(iSub,1));
    subplot(2,1,2);
    plotReactMtRt(iSub, traj_names, plt_p, p);
end

% ------- PAS -------
for iSub = p.SUBS
    figure(sub_f(iSub,1));
    subplot(2,6,5);
    plotPas(iSub, traj_names{1}{1}, plt_p, p);
end

% ------- Prime Forced Choice -------
for iSub = p.SUBS
    figure(sub_f(iSub,1));
    subplot(2,6,6);
    plotRecognition(iSub, pas_rate, traj_names{1}{1}, plt_p, p);
end

% ------- MAD -------
% Maximum absolute deviation.
for iSub = p.SUBS
    figure(sub_f(iSub,2));
    subplot(1,2,1);
    plotMad(iSub, traj_names, plt_p, p);
end

% ------- MAD Point -------
% Maximally absolute deviating point.
for iSub = p.SUBS
    figure(sub_f(iSub,2));
    subplot_p = [2,2,2; 2,2,4]; % Params for 1st and 2nd subplots.
    plotMadPoint(iSub, traj_names, subplot_p, plt_p, p);
end

% ------- X Standard Deviation -------
for iSub = p.SUBS
    figure(sub_f(iSub,3));
    subplot_p = [2,2,1; 2,2,2]; % Params for 1st and 2nd subplots.
    plotXStd(iSub, traj_names, subplot_p, plt_p, p);
end

% ------- Keyboard Response Times -------
if any(p.SUBS >=43) % Only for Exp 4.
    for iSub = p.SUBS
        figure(sub_f(iSub,3));
        subplot(2,1,2);
        plotKeyboardRt(iSub, traj_names{1}{1}, plt_p, p);
    end
end
%% Multiple subs average plots.
% Create figures.
all_sub_f(1) = figure('Name',['All Subs'], 'WindowState','maximized', 'MenuBar','figure');
all_sub_f(2) = figure('Name',['All Subs'], 'WindowState','maximized', 'MenuBar','figure');
all_sub_f(3) = figure('Name',['All Subs'], 'WindowState','maximized', 'MenuBar','figure');
all_sub_f(4) = figure('Name',['All Subs'], 'WindowState','maximized', 'MenuBar','figure');
all_sub_f(5) = figure('Name',['All Subs'], 'WindowState','maximized', 'MenuBar','figure');
% Add title.
figure(all_sub_f(1)); annotation('textbox',[0.45 0.915 0.1 0.1], 'String','All Subs', 'FontSize',30, 'LineStyle','none', 'FitBoxToText','on');
figure(all_sub_f(2)); annotation('textbox',[0.45 0.915 0.1 0.1], 'String','All Subs', 'FontSize',30, 'LineStyle','none', 'FitBoxToText','on');
figure(all_sub_f(3)); annotation('textbox',[0.45 0.915 0.1 0.1], 'String','All Subs', 'FontSize',30, 'LineStyle','none', 'FitBoxToText','on');
figure(all_sub_f(4)); annotation('textbox',[0.45 0.915 0.1 0.1], 'String','All Subs', 'FontSize',30, 'LineStyle','none', 'FitBoxToText','on');
figure(all_sub_f(5)); annotation('textbox',[0.45 0.915 0.1 0.1], 'String','All Subs', 'FontSize',30, 'LineStyle','none', 'FitBoxToText','on');

% ------- Avg traj with shade -------
figure(all_sub_f(2));
subplot(2,2,1);
plotMultiAvgTrajWithShade(traj_names, plt_p, p);

% ------- FDA -------
figure(all_sub_f(1));
subplot(2,3,6);
plotMultiFda(traj_names, plt_p, p);

% ------- React + Movement + Response Times Reaching -------
figure(all_sub_f(3));
subplot(2,1,1);
plotMultiReactMtRt(traj_names, plt_p, p);

% ------- Prime Forced choice -------
figure(all_sub_f(5));
subplot(2,4,3);
plotMultiRecognition(pas_rate, traj_names{1}{1}, plt_p, p);

% ------- PAS -------
figure(all_sub_f(5));
hold on;
subplot(2,4,4);
plotMultiPas(traj_names{1}{1}, plt_p, p);

% ------- MAD -------
% Maximum absolute deviation.
figure(all_sub_f(1));
subplot(1,3,1);
plotMultiMad(traj_names, plt_p, p);

% ------- Reach Area -------
% Area between avg left traj and avg right traj (in each condition).
figure(all_sub_f(2));
subplot(2,4,5);
plotMultiReachArea(traj_names, plt_p, p);

% ------- X STD -------
figure(all_sub_f(1));
subplot_p = [2,3,2; 2,3,3; 2,3,5];
plotMultiXStd(traj_names, subplot_p, plt_p, p);

% ------- Condition Diff -------
% Difference between avg traj in each condition.
figure(all_sub_f(2));
subplot_p = [2,4,6; 2,4,7; 2,4,8];
plotMultiTrajDiffBetweenConds(traj_names, subplot_p, plt_p, p);

% ------- COM -------
% Number of changes of mind.
figure(all_sub_f(2));
subplot(2,4,3);
plotMultiCom(traj_names, plt_p, p);

% ------- Total distance traveled -------
% Total distance traveled.
figure(all_sub_f(2));
subplot(2,4,4);
plotMultiTotDist(traj_names, plt_p, p);

% ------- Number of bad trials -------
% Comparison of bad trials count between subs of exp2 and subs of exp 3.
figure(all_sub_f(4));
plotNumBadTrials(traj_names{1}{1}, plt_p, p)

% ------- Response Times Keyboard -------
if any(p.SUBS >=43) % Only for Exp 4.
    figure(all_sub_f(3));
    subplot(2,1,2);
    plotMultiKeyboardRt(traj_names, plt_p, p);
end

%% Effect size comparison to previous papers.
% Prev exp data.
xiao_auc = struct('N',28,...% Xiao, K., Yamauchi, T., & Bowman, C. (2015)
    'mean1',3628.43,...
    'mean2',4746.17,...
    'sd1',3875.79,...
    'sd2',4135.95,...
    't',5.13,...
    'd',1.97);
xiao_rt = struct('N',36,... % Results of keyboard measure.
    'mean1',733.32,...
    'mean2',759.50,...
    'sd1',156.28,...
    'sd2',168.60,...
    't',1.92,...
    'd',0.65);
almeida_auc = struct('N',37,... % Almeida, Mahon, Zapater-Raberov, Dziuba, et al., (2014) - This is an average of results between 3 conditions
    'mean_incon',2.56,...
    'sem',1.3,...
    't',2.32,...
    'd',NaN);
finkbeiner_maxcurv1 = struct('N',7,... % Finkbeiner, M., Song, J. H., Nakayama, K., & Caramazza, A. (2008)
    'mean_incon',NaN,...
    'sem',NaN,...
    't',4.23,...
    'd',NaN);
finkbeiner_maxcurv2 = struct('N',7,... %This is the 2nd experiment. Average of results of SOA=30 and SOA=40
    'mean_incon',NaN,...
    'sem',NaN,...
    't',(4.57 + 3.55)/2,...
    'd',NaN);
% My data.
good_subs_exp_2 = load([p.PROC_DATA_FOLDER '/good_subs_' p.DAY '_' traj_names{1}{1} '_subs_' regexprep(num2str(p.EXP_2_SUBS), '\s+', '_') '.mat']);  good_subs_exp_2 = good_subs_exp_2.good_subs;
good_subs_exp_3 = load([p.PROC_DATA_FOLDER '/good_subs_' p.DAY '_' traj_names{1}{1} '_subs_' regexprep(num2str(p.EXP_3_SUBS), '\s+', '_') '.mat']);  good_subs_exp_3 = good_subs_exp_3.good_subs;
good_subs_sim = load([p.PROC_DATA_FOLDER '/good_subs_' p.DAY '_' traj_names{1}{1} '_subs_' regexprep(num2str(p.SUBS), '\s+', '_') '.mat']);  good_subs_sim = good_subs_sim.good_subs;
avg_each_exp_2 = load([p.PROC_DATA_FOLDER 'avg_each_' p.DAY '_' traj_names{1}{1} '_subs_' regexprep(num2str(p.EXP_2_SUBS), '\s+', '_') '.mat']);  avg_each_exp_2 = avg_each_exp_2.avg_each;
avg_each_exp_3 = load([p.PROC_DATA_FOLDER 'avg_each_' p.DAY '_' traj_names{1}{1} '_subs_' regexprep(num2str(p.EXP_3_SUBS), '\s+', '_') '.mat']);  avg_each_exp_3 = avg_each_exp_3.avg_each;
avg_each_sim = load([p.PROC_DATA_FOLDER 'avg_each_' p.DAY '_' traj_names{1}{1} '_subs_' regexprep(num2str(p.SUBS), '\s+', '_') '.mat']);  avg_each_sim = avg_each_sim.avg_each;

% Stack all experiments.
exps_table = table('VariableNames',["name","data","n_subs","t_test","cohens_dz"],...
                    'VariableTypes',["string","cell","double","double","double"],...
                    'Size',[1,5]);
exps_table(1,:) = table("xiao_auc", {nan}, xiao_auc.N, xiao_auc.t, nan);
exps_table(end+1,:) = table("xiao_rt", {nan}, xiao_rt.N, xiao_rt.t, nan);
exps_table(end+1,:) = table("almeida_auc", {nan}, almeida_auc.N, almeida_auc.t, nan);
exps_table(end+1,:) = table("finkbeiner_maxcurv1", {nan}, finkbeiner_maxcurv1.N, finkbeiner_maxcurv1.t, nan);
exps_table(end+1,:) = table("finkbeiner_maxcurv2", {nan}, finkbeiner_maxcurv2.N, finkbeiner_maxcurv2.t, nan);
exps_table(end+1,:) = table("ra_exp2", {avg_each_exp_2.ra.diff(good_subs_exp_2)}, length(good_subs_exp_2), nan, nan);
exps_table(end+1,:) = table("ra_exp3", {avg_each_exp_3.ra.diff(good_subs_exp_3)}, length(good_subs_exp_3), nan, nan);
exps_table(end+1,:) = table("ra_sim", {avg_each_sim.ra.diff(good_subs_sim)}, length(good_subs_sim), nan, nan);
exps_table(end+1,:) = table("mad_exp2", {avg_each_exp_2.mad.diff(good_subs_exp_2)}, length(good_subs_exp_2), nan, nan);
exps_table(end+1,:) = table("mad_exp3", {avg_each_exp_3.mad.diff(good_subs_exp_3)}, length(good_subs_exp_3), nan, nan);
exps_table(end+1,:) = table("mad_sim", {avg_each_sim.mad.diff(good_subs_sim)}, length(good_subs_sim), nan, nan);
exps_table(end+1,:) = table("react_exp2", {avg_each_exp_2.react.diff(good_subs_exp_2)}, length(good_subs_exp_2), nan, nan);
exps_table(end+1,:) = table("react_exp3", {avg_each_exp_3.react.diff(good_subs_exp_3)}, length(good_subs_exp_3), nan, nan);
exps_table(end+1,:) = table("react_sim", {avg_each_sim.react.diff(good_subs_sim)}, length(good_subs_sim), nan, nan);
exps_table(end+1,:) = table("mt_exp2", {avg_each_exp_2.mt.diff(good_subs_exp_2)}, length(good_subs_exp_2), nan, nan);
exps_table(end+1,:) = table("mt_exp3", {avg_each_exp_3.mt.diff(good_subs_exp_3)}, length(good_subs_exp_3), nan, nan);
exps_table(end+1,:) = table("mt_sim", {avg_each_sim.mt.diff(good_subs_sim)}, length(good_subs_sim), nan, nan);
exps_table(end+1,:) = table("rt_exp2", {avg_each_exp_2.rt.diff(good_subs_exp_2)}, length(good_subs_exp_2), nan, nan);
exps_table(end+1,:) = table("rt_exp3", {avg_each_exp_3.rt.diff(good_subs_exp_3)}, length(good_subs_exp_3), nan, nan);
exps_table(end+1,:) = table("rt_sim", {avg_each_sim.rt.diff(good_subs_sim)}, length(good_subs_sim), nan, nan);

% T-test my data.
for iRow = 6:height(exps_table)
    [~, ~, ~, stats] = ttest(exps_table.data{iRow});
    exps_table.t_test(iRow) = stats.tstat;
end

% Cohen's dz.
for iRow = 1:height(exps_table)
    exps_table.cohens_dz(iRow) = exps_table.t_test(iRow) / sqrt(exps_table.n_subs(iRow));
end

% Plot
prev_papers_comp_f(1) = figure('Name','Papers comparison', 'WindowState','maximized', 'MenuBar','figure');
bar(exps_table.cohens_dz, 'FaceColor',[0.9290 0.6940 0.1250], 'FaceAlpha',0.2, 'EdgeColor',[0.9290 0.6940 0.1250], 'linewidth',3);
ylabel('Cohen`s  d_z');
set(gca, 'FontSize',14);
set(gca, 'TickLabelInterpreter','none')';
xticks([1:height(exps_table)]);
xticklabels([exps_table.name]);
ax = gca;
ax.Box = 'off';
grid on;
title("Reach area / area under the curve");

% Store my effect sizes in a table.
effects_table = array2table([exps_table.cohens_dz(contains(exps_table.name, 'exp2'))';...
                            exps_table.cohens_dz(contains(exps_table.name, 'exp3'))';...
                            exps_table.cohens_dz(contains(exps_table.name, 'sim'))']);
% Add names as column of table.
effects_names = regexp(exps_table.name', '(.+)_exp2', 'tokens','once');
effects_names = [effects_names{:}];
effects_table.Properties.VariableNames = effects_names;
% Identify the simulated exp according to sub nums.
sim_exp = isequal(p.SUBS-200, SORTED_SUBS.EXP_1_SUBS) * 1 + isequal(p.SUBS-200, SORTED_SUBS.EXP_2_SUBS) * 2 + isequal(p.SUBS-200, SORTED_SUBS.EXP_3_SUBS) * 3;
effects_table.exp_name = ["exp2"; "exp3"; string(['exp' num2str(sim_exp) ' sim ' num2str(p.NUM_TRIALS) ' trials'])];
writetable(effects_table, [p.PROC_DATA_FOLDER 'effects_table.csv'], 'WriteMode','append');
%% RT comparison between 1st and 2nd practice blocks.
% Compares n trials from the end of each practice block.
n_comp_trials = 10;
% Reation, movement, response times.
rt = nan(p.MAX_SUB, 3); % 3 =  for 2 practice blocks and 1 for avg of all test blocks.

% Get data of each sub.
for iSub = p.SUBS
    reach_data_table = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_data.mat']);  reach_data_table = reach_data_table.reach_data_table;
    first_block = reach_data_table.target_rt(reach_data_table.practice == 1);
    second_block = reach_data_table.target_rt(reach_data_table.practice == 2);
    test_blocks = reach_data_table.target_rt(reach_data_table.practice == 0);
    % If subject performed both practices.
    if ~prod(isnan(first_block)) && ~prod(isnan(second_block))
        rt(iSub, 1:2) = mean([first_block(end-n_comp_trials+1 : end), second_block(end-n_comp_trials+1 : end)], 1, 'omitnan');
        rt(iSub, 3) = mean(test_blocks, 'omitnan');
    end
end

% Remove empty slots.
rt(any(isnan(rt),2), :) = [];
% Convert to ms.
rt = rt * 1000;

% Check significance.
[~, p_value] = ttest(rt(:,1), rt(:,2));

% Plot inconerence.
fig = figure('Name',"RT comparison between practice blocks and also test blocks");
beesdata = {rt(:,1), rt(:,2), rt(:,3)};
yLabel = 'Time (milisec)';
XTickLabel = ["1_s_t", "2_n_d", "Test"];
colors = {plt_p.first_practice_color, plt_p.second_practice_color, plt_p.test_color};
title_char = "RT comparison between practice blocks and also test blocks";
printBeeswarm(beesdata, yLabel, XTickLabel, colors, plt_p.space, title_char, 'ci', plt_p.alpha_size);
h = [];
h(1) = bar(NaN,NaN,'FaceColor',plt_p.first_practice_color);
h(2) = bar(NaN,NaN,'FaceColor',plt_p.second_practice_color);
h(3) = bar(NaN,NaN,'FaceColor',plt_p.test_color);
legend(h,'First practice','Second practice', 'Avg of test blocks', 'Location','southwest');
ax = gca;
ylim([350 750]);
text(mean(ax.XTick(1:2)), max(rt(1:2))+10, ['p = ' num2str(p_value)], 'FontSize',14, 'HorizontalAlignment','center');
%% GUI, compares proc to real traj.
close all;
warning('off','MATLAB:legend:IgnoringExtraEntries');
miss_data(p, traj_names); clc;
%% Velocity
%{
        % calc velocity.-----------------------------------------------
        dx = traj_mat(2:end, :, :) - traj_mat(1:end-1, :, :); % distance between 2 samples.
        vel_per_axis = dx / p.SAMPLE_RATE_SEC;
        veloc = sqrt(sum(vel_per_axis.^2, 3));
        veloc = [veloc; veloc(end,:)];
        vel.con_left = veloc(:, con_trials.left);
        vel.con_right = veloc(:, con_trials.right);
        vel.incon_left = veloc(:, incon_trials.left);
        vel.incon_right = veloc(:, incon_trials.right);
        avg_vel.con_left = mean(vel.con_left, 2);
        avg_vel.con_right = mean(vel.con_right, 2);
        avg_vel.incon_left = mean(vel.incon_left, 2);
        avg_vel.incon_right = mean(vel.incon_right, 2);
        
        figure(vel_f);
        subplot(2,2,iTraj);
        hold on;
        % Con trials left.
        plot(traj_mat(:, con_trials.left, 3)*flip_traj, vel.con_left, 'Color',[0 0.4470 0.7410 0.3]);
        % Con trials right.
        plot(traj_mat(:, con_trials.right, 3)*flip_traj, vel.con_right, 'Color',[0 0.4470 0.7410 0.3]);
        % incon trials left.
        plot(traj_mat(:, incon_trials.left, 3)*flip_traj, vel.incon_left, 'Color',[0.6350 0.0780 0.1840 0.3]);
        % incon trials right.
        plot(traj_mat(:, incon_trials.right, 3)*flip_traj, vel.incon_right, 'Color',[0.6350 0.0780 0.1840 0.3]);
        % Averages.
        plot(avg_traj_table.con_left{:, traj_names{iTraj}{3}}*flip_traj, avg_vel.con_left, 'b', 'LineWidth',4); % X as func of Z.
        plot(avg_traj_table.con_right{:, traj_names{iTraj}{3}}*flip_traj, avg_vel.con_right, 'b', 'LineWidth',4); % X as func of Z.
        plot(avg_traj_table.incon_left{:, traj_names{iTraj}{3}}*flip_traj, avg_vel.incon_left, 'r', 'LineWidth',4); % X as func of Z.
        plot(avg_traj_table.incon_right{:, traj_names{iTraj}{3}}*flip_traj, avg_vel.incon_right, 'r', 'LineWidth',4); % X as func of Z.
        h(1) = plot(nan,nan,'Color',[0 0.4470 0.7410 0.3]);
        h(2) = plot(nan,nan,'Color',[0.6350 0.0780 0.1840 0.3]);
        h(3) = plot(nan,nan,'b');
        h(4) = plot(nan,nan,'r');
        legend(h, 'con', 'incon', 'con avg', 'incon avg', 'Location','southeast');
        xlabel('Z'); xlim([0, 0.4]);
        ylabel('Velocity'); ylim([0, 1]);
        title(traj_names{iTraj}{1}, 'Interpreter','none');
        set(gca, 'FontSize',14);
        %}