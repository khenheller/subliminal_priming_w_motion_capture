clear all;
close all;
clc;

%% Parameters
disp("Started setting up params.")
load('../../experiment/RUN_ME/code/p.mat');
addpath(genpath('./imported_code'));

% Adjustable params.
p.EXP_1_SUBS = [1 2 3 4 5 6 7 8 9 10]; % Participated in experiment version 1.
p.EXP_2_SUBS = [11 12 13 14 16 17 18 19 20 21 22 23 24 25]; % Sub 15 didn't finish the experiment (pressed Esc).
p.EXP_3_SUBS = [26 28 29 31 32 33 34 35 37 38 39 40 42]; % Sub 27, 30, 36, 41 didn't arrive to day 2.
p.EXP_4_SUBS = [43 44];
p.EXP_4_1_SUBS = [47, 49:85, 87:90];
p.SIM_SUBS = [94]; % Simulated data, for verifying analysis functions properly.
p.SUBS = p.SIM_SUBS; % to analyze.
p.ORIG_SUBS = p.SUBS; % When simulating less trials, I add 200 to sub nums, so I use this variable to store nums without the addition.
p.DAY = 'day2';
pas_rate = 1; % to analyze.
picked_trajs = [1]; % traj to analyze (1=to_target, 2=from_target, 3=to_prime, 4=from_prime).
p.SIMULATE = 0; % Simulate less trials.
p.NORMALIZE_WITHIN_SUB = 0; % Normalize each variable within each sub.
p.NORM_TRAJ = 1; % Normalize traj in space. ATTENTION: When NORM_TRAJ=0, change MIN_SAMP_LEN from 0.1 to min length you want trajs to be trimmed to.
p.MIN_SAMP_LEN = 0.1; % In sec. Shorter trajs are excluded. (for NORM_TRAJ=0 use 0.34, otherwise 0.1).
                        % When NORM_TRAJ=0, this is the len all trajs will be trimmed to.
                        % Used "Movement Time Percentiles" section to determine the desired value.
p.MIN_TRIM_FRAMES = p.MIN_SAMP_LEN * p.REF_RATE_HZ; % Minimal length (in samples, also called frames) to trim traj to (instead of normalization).
p = defineParams(p, p.SUBS(1));

% Name of trajectory column in output data. each cell is a incon type of traj.
traj_names = {{'target_x_to' 'target_y_to' 'target_z_to'},...
    {'target_x_from' 'target_y_from' 'target_z_from'},...
    {'prime_x_to' 'prime_y_to' 'prime_z_to'},...
    {'prime_x_from' 'prime_y_from' 'prime_z_from'}};
traj_names_mat = reshape(string([traj_names{:}]),3,[])';
if ~exist('../processed_data/')
    mkdir('../processed_data/');
end
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
            p = defineParams(p, iSub);
            % Delete file if already exists.
            delete([p.DATA_FOLDER '/sub' num2str(iSub+idx_shift) p.DAY '_reach_traj.csv']);
            delete([p.DATA_FOLDER '/sub' num2str(iSub+idx_shift) p.DAY '_reach_data.csv']);
            % Reduces num of trials for each sub and saves it as a new sub.
            reach_traj_table = readtable([p.DATA_FOLDER '/sub' num2str(iSub) p.DAY '_reach_traj.csv']);
            reach_data_table = readtable([p.DATA_FOLDER '/sub' num2str(iSub) p.DAY '_reach_data.csv']);
            reach_traj_table = reach_traj_table(1:min(new_traj_table_size, height(reach_traj_table)), :);
            reach_data_table = reach_data_table(1:min(new_data_table_size, height(reach_data_table)), :);
            writetable(reach_traj_table, [p.DATA_FOLDER '/sub' num2str(iSub+idx_shift) p.DAY '_reach_traj.csv']);
            writetable(reach_data_table, [p.DATA_FOLDER '/sub' num2str(iSub+idx_shift) p.DAY '_reach_data.csv']);
            % Copy p.mat, start_end_point, and test results to new sub.
            copyfile([p.DATA_FOLDER '/sub' num2str(iSub) p.DAY '_' 'start_end_points.mat'], [p.DATA_FOLDER '/sub' num2str(iSub+idx_shift) p.DAY '_' 'start_end_points.mat'], 'f');
            copyfile([p.DATA_FOLDER '/sub' num2str(iSub) p.DAY '_' 'p.mat'], [p.DATA_FOLDER '/sub' num2str(iSub+idx_shift) p.DAY '_' 'p.mat'], 'f');
            copyfile([p.TESTS_FOLDER '/sub' num2str(iSub) p.DAY '.mat'], [p.TESTS_FOLDER '/sub' num2str(iSub+idx_shift) p.DAY '.mat'], 'f');
            disp(num2str(iSub));
        end
        timing = num2str(toc);
        disp(['Done Creating reduced subs. ' timing 'Sec'])
    end
    p.SUBS = p.SUBS + idx_shift;
    p = defineParams(p, p.SUBS(1));
    disp("Done Simulating less trials.");
end
%% Create proc data file
% Copy the original data to a new file, to keep the data safe.
tic
disp('Creating processing data files for sub:');
for iSub = p.SUBS
    p = defineParams(p, iSub);
    reach_traj_table = readtable([p.DATA_FOLDER '/sub' num2str(iSub) p.DAY '_reach_traj.csv']);
    reach_data_table = readtable([p.DATA_FOLDER '/sub' num2str(iSub) p.DAY '_reach_data.csv']);
    % Fake keybaord data for Exp1,2,3.
    if any(p.ORIG_SUBS < 43)
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
    p = defineParams(p, iSub);
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
    p = defineParams(p, iSub);
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
tic
% Trials too short to filter.
too_short_to_filter = table('Size', [max(p.SUBS) length(traj_types)],...
    'VariableTypes', repmat({'cell'}, length(traj_types), 1),...
    'VariableNames', traj_types);
disp('Preprocessing done for subject:');
% Preprocessing.
for iSub = p.SUBS
    p = defineParams(p, iSub);
    reach_traj_table = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_reach_traj.mat']);  reach_traj_table = reach_traj_table.reach_traj_table;
    reach_data_table = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_reach_data.mat']);  reach_data_table = reach_data_table.reach_data_table;
    keyboard_data_table = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_keyboard_data.mat']);  keyboard_data_table = keyboard_data_table.keyboard_data_table;
    
    % remove practice.
    reach_traj_table(reach_traj_table{:,'practice'} > 0, :) = [];
    reach_data_table(reach_data_table{:,'practice'} > 0, :) = [];
    keyboard_data_table(keyboard_data_table{:,'practice'} > 0, :) = [];
    
    % Preprocessing.
    for iTraj = 1:length(traj_names)
        [reach_pre_norm_traj_table, reach_data_table, too_short_to_filter{iSub, iTraj}{:}] = preproc(reach_traj_table, reach_data_table, traj_names{iTraj}, p);
    end

    % Save
    save([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_reach_pre_norm_traj.mat'], 'reach_pre_norm_traj_table');
    save([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_reach_data_proc.mat'], 'reach_data_table');
    save([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_keyboard_data_proc.mat'], 'keyboard_data_table'); % Keyboard data isn't pre-processed because there is no need for that.
end

% Get minimal traj length.
min_len = getMinLength(traj_names{1}, p);
trim_len = p.NORM_TRAJ * p.NORM_FRAMES + ~p.NORM_TRAJ * min_len;
save([p.PROC_DATA_FOLDER '/trim_len.mat'], 'trim_len');

% Normalize or Trim
for iSub = p.SUBS
    % Normalize by fitting a B-spline.
    if p.NORM_TRAJ
        [reach_traj_table] = normalize_trajs(iSub, traj_names{1}, p);
    % Trim to minimal traj's length (across subs).
    else
        [reach_traj_table] = trimToLength(iSub, min_len, traj_names{1}, p);
    end

    % Trim num samples to new length.
    matrix = reshape(reach_traj_table{:,:}, p.MAX_CAP_LENGTH, p.NUM_TRIALS, width(reach_traj_table));
    matrix = matrix(1:trim_len, :, :);
    reach_traj_table = reach_traj_table(1 : trim_len * p.NUM_TRIALS, :);
    reach_traj_table{:,:} = reshape(matrix, trim_len * p.NUM_TRIALS, width(reach_traj_table));
    % Save
    save([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_reach_traj_proc.mat'], 'reach_traj_table');
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
    if any(p.ORIG_SUBS < 43)
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
    [reach_bad_subs, reach_valid_trials] = subScreening(traj_names{iTraj}, pas_rate, 'reach', p);
    [keyboard_bad_subs, keyboard_valid_trials] = subScreening(traj_names{iTraj}, pas_rate, 'keyboard', p);
    % Exp 1,2,3 had no keyboard task.
    if any(p.ORIG_SUBS < 43)
        keyboard_bad_subs(:,:) = array2table(zeros(size(keyboard_bad_subs)));
    end
    bad_subs = array2table(reach_bad_subs{:,:} | keyboard_bad_subs{:,:}, 'VariableNames',reach_bad_subs.Properties.VariableNames);
    good_subs = p.SUBS(~ismember(p.SUBS, find(bad_subs.any)));
    save([p.PROC_DATA_FOLDER '/bad_subs_' p.DAY '_' traj_names{iTraj}{1} '_subs_' p.SUBS_STRING '.mat'], 'bad_subs', 'reach_bad_subs', 'keyboard_bad_subs');
    save([p.PROC_DATA_FOLDER '/good_subs_' p.DAY '_' traj_names{iTraj}{1} '_subs_' p.SUBS_STRING '.mat'], 'good_subs');
    save([p.PROC_DATA_FOLDER '/valid_trials_' p.DAY '_' traj_names{iTraj}{1} '_subs_' p.SUBS_STRING '.mat'], 'reach_valid_trials', 'keyboard_valid_trials');
end
timing = num2str(toc);
disp(['Sub screening done. ' timing 'Sec']);
%% Maximum absolute deviation
tic
for iTraj = 1:length(traj_names)
    for iSub = p.SUBS
        % Load.
        p = defineParams(p, iSub);
        reach_traj_table = load([p.PROC_DATA_FOLDER 'sub' num2str(iSub) p.DAY '_reach_traj_proc.mat']);  reach_traj_table = reach_traj_table.reach_traj_table;
        reach_prenorm_traj_table = load([p.PROC_DATA_FOLDER 'sub' num2str(iSub) p.DAY '_reach_pre_norm_traj.mat']);  reach_prenorm_traj_table = reach_prenorm_traj_table.reach_pre_norm_traj_table;
        reach_data_table = load([p.PROC_DATA_FOLDER 'sub' num2str(iSub) p.DAY '_reach_data_proc.mat']);  reach_data_table = reach_data_table.reach_data_table;
        % Compute.
        reach_data_table = calcMAD(reach_traj_table, reach_prenorm_traj_table, reach_data_table, traj_names{iTraj}, p);
        % Save.
        save([p.PROC_DATA_FOLDER 'sub' num2str(iSub) p.DAY '_reach_data_proc.mat'], 'reach_data_table');
    end
end
timing = num2str(toc);
disp(['MAD calc done. ' timing 'Sec']);
%% Heading angle
tic
for iSub = p.SUBS
    % Load.
    p = defineParams(p, iSub);
    reach_traj_table = load([p.PROC_DATA_FOLDER 'sub' num2str(iSub) p.DAY '_reach_traj_proc.mat']);  reach_traj_table = reach_traj_table.reach_traj_table;
    reach_prenorm_traj_table = load([p.PROC_DATA_FOLDER 'sub' num2str(iSub) p.DAY '_reach_pre_norm_traj.mat']);  reach_prenorm_traj_table = reach_prenorm_traj_table.reach_pre_norm_traj_table;
    reach_traj_table = calcHeadAngle(reach_traj_table, reach_prenorm_traj_table, p);
    save([p.PROC_DATA_FOLDER 'sub' num2str(iSub) p.DAY '_reach_traj_proc.mat'], 'reach_traj_table');
end
timing = num2str(toc);
disp(['Heading angle calc done. ' timing 'Sec']);
%% Implied endpoint.
tic
for iSub = p.SUBS
    % Load.
    p = defineParams(p, iSub);
    reach_traj_table = load([p.PROC_DATA_FOLDER 'sub' num2str(iSub) p.DAY '_reach_traj_proc.mat']);  reach_traj_table = reach_traj_table.reach_traj_table;
    reach_traj_table = calcIEP(reach_traj_table, traj_names{1}, p);
    save([p.PROC_DATA_FOLDER 'sub' num2str(iSub) p.DAY '_reach_traj_proc.mat'], 'reach_traj_table');
end
timing = num2str(toc);
disp(['Implied endpoint calc done. ' timing 'Sec']);
%% Changes of mind
tic
for iSub = p.SUBS
    p = defineParams(p, iSub);
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
    p = defineParams(p, iSub);
    reach_traj_table = load([p.PROC_DATA_FOLDER 'sub' num2str(iSub) p.DAY '_reach_pre_norm_traj.mat']);  reach_traj_table = reach_traj_table.reach_pre_norm_traj_table;
    reach_data_table = load([p.PROC_DATA_FOLDER 'sub' num2str(iSub) p.DAY '_reach_data_proc.mat']);  reach_data_table = reach_data_table.reach_data_table;
    reach_data_table = calcTotDistTravel(reach_traj_table, reach_data_table, p);
    save([p.PROC_DATA_FOLDER 'sub' num2str(iSub) p.DAY '_reach_data_proc.mat'], 'reach_data_table');
end
timing = num2str(toc);
disp(['Total distance traveled calc done. ' timing 'Sec']);
%% AUC
tic
for iSub = p.SUBS
    p = defineParams(p, iSub);
    reach_traj_table = load([p.PROC_DATA_FOLDER 'sub' num2str(iSub) p.DAY '_reach_traj_proc.mat']);  reach_traj_table = reach_traj_table.reach_traj_table;
    reach_pre_norm_traj_table = load([p.PROC_DATA_FOLDER 'sub' num2str(iSub) p.DAY '_reach_pre_norm_traj.mat']);  reach_pre_norm_traj_table = reach_pre_norm_traj_table.reach_pre_norm_traj_table;
    reach_data_table = load([p.PROC_DATA_FOLDER 'sub' num2str(iSub) p.DAY '_reach_data_proc.mat']);  reach_data_table = reach_data_table.reach_data_table;
    reach_data_table = calcAuc(reach_traj_table, reach_data_table, reach_pre_norm_traj_table, p);
    save([p.PROC_DATA_FOLDER 'sub' num2str(iSub) p.DAY '_reach_data_proc.mat'], 'reach_data_table');
end
timing = num2str(toc);
disp(['AUC calc done. ' timing 'Sec']);
%% Velocity
tic
for iSub = p.SUBS
    p = defineParams(p, iSub);
    reach_traj_table = load([p.PROC_DATA_FOLDER 'sub' num2str(iSub) p.DAY '_reach_traj_proc.mat']);  reach_traj_table = reach_traj_table.reach_traj_table;
    prenorm_traj_table = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_reach_pre_norm_traj.mat']);  prenorm_traj_table = prenorm_traj_table.reach_pre_norm_traj_table;
    reach_traj_table = calcVelAcc(prenorm_traj_table, reach_traj_table, 'vel', p);
    save([p.PROC_DATA_FOLDER 'sub' num2str(iSub) p.DAY '_reach_traj_proc.mat'], 'reach_traj_table');
end
timing = num2str(toc);
disp(['Velocity calc done. ' timing 'Sec']);
%% Max Velocity
tic
for iSub = p.SUBS
    p = defineParams(p, iSub);
    reach_traj_table = load([p.PROC_DATA_FOLDER 'sub' num2str(iSub) p.DAY '_reach_traj_proc.mat']);  reach_traj_table = reach_traj_table.reach_traj_table;
    reach_data_table = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_reach_data_proc.mat']);  reach_data_table = reach_data_table.reach_data_table;
    reach_data_table = calcMaxVel(reach_traj_table, reach_data_table, p);
    save([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_reach_data_proc.mat'], 'reach_data_table');
end
timing = num2str(toc);
disp(['Max Velocity calc done. ' timing 'Sec']);
%% Acceleration
tic
for iSub = p.SUBS
    p = defineParams(p, iSub);
    reach_traj_table = load([p.PROC_DATA_FOLDER 'sub' num2str(iSub) p.DAY '_reach_traj_proc.mat']);  reach_traj_table = reach_traj_table.reach_traj_table;
    prenorm_traj_table = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_reach_pre_norm_traj.mat']);  prenorm_traj_table = prenorm_traj_table.reach_pre_norm_traj_table;
    reach_traj_table = calcVelAcc(prenorm_traj_table, reach_traj_table, 'acc', p);
    save([p.PROC_DATA_FOLDER 'sub' num2str(iSub) p.DAY '_reach_traj_proc.mat'], 'reach_traj_table');
end
timing = num2str(toc);
disp(['Acceleration calc done. ' timing 'Sec']);
%% Sorting and averaging (within subject)
tic
for iTraj = 1:length(traj_names)
    bad_trials = load([p.PROC_DATA_FOLDER '/bad_trials_' p.DAY '_' traj_names{iTraj}{1} '_subs_' p.SUBS_STRING '.mat']);
    reach_bad_trials = bad_trials.reach_bad_trials;
    keyboard_bad_trials = bad_trials.keyboard_bad_trials;
    for iSub = p.SUBS
        p = defineParams(p, iSub);
        [r_avg, r_trial, k_avg, k_trial] = avgWithin(iSub, traj_names{iTraj}, reach_bad_trials, keyboard_bad_trials, pas_rate, p.NORMALIZE_WITHIN_SUB, p);
        save([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_sorted_trials_' traj_names{iTraj}{1} '.mat'], 'r_trial', 'k_trial');
        save([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_avg_' traj_names{iTraj}{1} '.mat'], 'r_avg', 'k_avg');
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
        p = defineParams(p, iSub);
        r_avg = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_avg_' traj_names{iTraj}{1} '.mat']);  r_avg = r_avg.r_avg;
        reach_area.con(iSub) = calcReachArea(r_avg.traj.con_left, r_avg.traj.con_right, p);
        reach_area.incon(iSub) = calcReachArea(r_avg.traj.incon_left, r_avg.traj.incon_right, p);
    end
    save([p.PROC_DATA_FOLDER 'reach_area_' traj_names{iTraj}{1} '_' p.DAY '_subs_' p.SUBS_STRING '.mat'], 'reach_area');
end
timing = num2str(toc);
disp(['Reach area calc done. ' timing 'Sec']);
%% d' computation
% Computes each var's d' (sensitivity) many times.
% Num iters.
iters = 2;
% Features when decoding d' for indirect measure (Reach: rt, react, mt, mad, com, tot_dist, auc, traj)
r_preds = ["rt","react","mt","mad","tot_dist","auc"];
k_preds = ["rt"];
% Save a features and labels table to be used in python.
save_to_python = 1;
if save_to_python
    iters = 1;
end

r_coef = {}; % Regression classifier coefficients.
k_coef = {}; % Regression classifier coefficients.
r_d_prime = struct('direct',NaN(iters, p.MAX_SUB), 'indirect',NaN(iters, p.MAX_SUB));
k_d_prime = struct('direct',NaN(iters, p.MAX_SUB), 'indirect',NaN(iters, p.MAX_SUB));
% Bad subs have too few trials, so we don't use them.
good_subs = load([p.PROC_DATA_FOLDER '/good_subs_' p.DAY '_' traj_names{1}{1} '_subs_' p.SUBS_STRING '.mat']);  good_subs = good_subs.good_subs;

for iIter = 1:iters
    tic
    for iSub = good_subs
        avg = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_avg_' traj_names{1}{1} '.mat']);
        r_avg = avg.r_avg;
        k_avg = avg.k_avg;

        % Direct measure sensitivity. [Meyen et al. (2022) advancing research...]
        r_d_prime.direct(iIter, iSub) = 2 * norminv(r_avg.fc_prime.incon);
        k_d_prime.direct(iIter, iSub) = 2 * norminv(k_avg.fc_prime.incon);
        % Decode indirect measure sensitivity.
        [r_d_prime.indirect(iIter, iSub), r_coef{iIter}(iSub,:)] = decodeDPrime(iSub, 'reach', r_preds, save_to_python, traj_names{1}{1}, p);
        [k_d_prime.indirect(iIter, iSub), k_coef{iIter}(iSub,:)] = decodeDPrime(iSub, 'keyboard', k_preds, save_to_python, traj_names{1}{1}, p);
    end

    timing = num2str(toc);
    disp([num2str(iIter) ' iterations of d prime calc done. ' timing 'Sec']);
end
save([p.PROC_DATA_FOLDER '/d_prime_' p.DAY '_' traj_names{1}{1} '_subs_' p.SUBS_STRING '.mat'], 'r_d_prime', 'k_d_prime');
%% Velocity profile
tic
vel_dist = velProf(p);
save([p.PROC_DATA_FOLDER,'/vel_dist_' p.DAY '_subs_' p.SUBS_STRING '.mat'], 'vel_dist');
timing = num2str(toc);
disp(['Velocity profiling done. ' timing 'Sec']);
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
%% Count trials for each condition
tic
for iTraj = 1:length(traj_names)
    for iSub = p.SUBS
        p = defineParams(p, iSub);
        % Get trials stats for this sub.
        single_trial = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_sorted_trials_' traj_names{iTraj}{1} '.mat']);
        reach_single = single_trial.r_trial;
        keyboard_single = single_trial.k_trial;
        reach_num_trials(iSub).con_left  = size(reach_single.rt.con_left, 1);
        reach_num_trials(iSub).con_right = size(reach_single.rt.con_right, 1);
        reach_num_trials(iSub).incon_left  = size(reach_single.rt.incon_left, 1);
        reach_num_trials(iSub).incon_right = size(reach_single.rt.incon_right, 1);
        reach_num_trials(iSub).con = reach_num_trials(iSub).con_left + reach_num_trials(iSub).con_right;
        reach_num_trials(iSub).incon = reach_num_trials(iSub).incon_left + reach_num_trials(iSub).incon_right;
        keyboard_num_trials(iSub).con_left  = size(keyboard_single.rt.con_left, 1);
        keyboard_num_trials(iSub).con_right = size(keyboard_single.rt.con_right, 1);
        keyboard_num_trials(iSub).incon_left  = size(keyboard_single.rt.incon_left, 1);
        keyboard_num_trials(iSub).incon_right = size(keyboard_single.rt.incon_right, 1);
        keyboard_num_trials(iSub).con = keyboard_num_trials(iSub).con_left + keyboard_num_trials(iSub).con_right;
        keyboard_num_trials(iSub).incon = keyboard_num_trials(iSub).incon_left + keyboard_num_trials(iSub).incon_right;
    end
    save([p.PROC_DATA_FOLDER '/num_trials_' p.DAY '_' traj_names{iTraj}{1} '_subs_' p.SUBS_STRING '.mat'], 'reach_num_trials', 'keyboard_num_trials');
end
timing = num2str(toc);
disp(['Counting trials in each condition done. ' timing 'Sec']);
%% Plotting params
disp("Started setting plotting params.");
close all;

% Params to be defined by user.
plt_p.alpha_size = 0.05; % For confidence interval.
plt_p.n_perm = 1000; % Number of permutations for permutation and clustering procedure.
plt_p.x_as_func_of = "zaxis"; % To plot X as a function of "time" or "zaxis".
plt_p.errbar_type = 'ci'; % Shade and error bar type: 'se', 'ci'. ci is only relevant when var distributes normally.
% Statistical params.
plt_p.n_perm_clust_tests = input("How many permutation+clustering tests do you have?");
% Plots appearance.
plt_p.avg_plot_width = 4;
plt_p.space = 3; % between beeswarm graphs.
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
plt_p.green_1 = [0.46667 0.85882 0.40392];
plt_p.green_2 = [0.56471 0.6902 0.37255];
plt_p.test_color = [240 240 30] / 255;
plt_p.axes_line_thickness = 3;
plt_p.time_ticks = [0.05 : 0.05 : p.MIN_SAMP_LEN] * 1000; % Ticks for the time axis in plots.
plt_p.percent_path_ticks = 10 : 20 : 100; % Ticks for the %path_traveled axis in plots.
plt_p.left_right_ticks = -10 : 5 : 10; % Ticks for the left/right axis in plots.
plt_p.font_name = 'Calibri';
plt_p.font_size = 17;
plt_p.labels_font_size = 14;

% Load reach area.
reach_area = load([p.PROC_DATA_FOLDER 'reach_area_' traj_names{1}{1} '_' p.DAY '_subs_' p.SUBS_STRING '.mat']);  reach_area = reach_area.reach_area;

% Unite all subs to one variable.
for iSub = p.SUBS
    for iTraj = 1:length(traj_names)
        avg = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_' 'avg_' traj_names{iTraj}{1} '.mat']);
        r_avg = avg.r_avg;
        k_avg = avg.k_avg;
        % Seperate avg for left and right.
        reach_avg_each.traj(iTraj).con_left(:,iSub,:) = r_avg.traj.con_left;
        reach_avg_each.traj(iTraj).con_right(:,iSub,:) = r_avg.traj.con_right;
        reach_avg_each.traj(iTraj).incon_left(:,iSub,:) = r_avg.traj.incon_left;
        reach_avg_each.traj(iTraj).incon_right(:,iSub,:) = r_avg.traj.incon_right;
        reach_avg_each.head_angle(iTraj).con_left(:,iSub) = r_avg.head_angle.con_left;
        reach_avg_each.head_angle(iTraj).con_right(:,iSub) = r_avg.head_angle.con_right;
        reach_avg_each.head_angle(iTraj).incon_left(:,iSub) = r_avg.head_angle.incon_left;
        reach_avg_each.head_angle(iTraj).incon_right(:,iSub) = r_avg.head_angle.incon_right;
        reach_avg_each.vel(iTraj).con_left(:,iSub) = r_avg.vel.con_left;
        reach_avg_each.vel(iTraj).con_right(:,iSub) = r_avg.vel.con_right;
        reach_avg_each.vel(iTraj).incon_left(:,iSub) = r_avg.vel.incon_left;
        reach_avg_each.vel(iTraj).incon_right(:,iSub) = r_avg.vel.incon_right;
        reach_avg_each.acc(iTraj).con_left(:,iSub) = r_avg.acc.con_left;
        reach_avg_each.acc(iTraj).con_right(:,iSub) = r_avg.acc.con_right;
        reach_avg_each.acc(iTraj).incon_left(:,iSub) = r_avg.acc.incon_left;
        reach_avg_each.acc(iTraj).incon_right(:,iSub) = r_avg.acc.incon_right;
        reach_avg_each.iep(iTraj).con_left(:,iSub) = r_avg.iep.con_left;
        reach_avg_each.iep(iTraj).con_right(:,iSub) = r_avg.iep.con_right;
        reach_avg_each.iep(iTraj).incon_left(:,iSub) = r_avg.iep.incon_left;
        reach_avg_each.iep(iTraj).incon_right(:,iSub) = r_avg.iep.incon_right;
        reach_avg_each.rt(iTraj).con_left(iSub)  = r_avg.rt.con_left * 1000;
        reach_avg_each.rt(iTraj).con_right(iSub) = r_avg.rt.con_right * 1000;
        reach_avg_each.rt(iTraj).incon_left(iSub)  = r_avg.rt.incon_left * 1000;
        reach_avg_each.rt(iTraj).incon_right(iSub) = r_avg.rt.incon_right * 1000;
        reach_avg_each.react(iTraj).con_left(iSub)  = r_avg.react.con_left * 1000;
        reach_avg_each.react(iTraj).con_right(iSub) = r_avg.react.con_right * 1000;
        reach_avg_each.react(iTraj).incon_left(iSub)  = r_avg.react.incon_left * 1000;
        reach_avg_each.react(iTraj).incon_right(iSub) = r_avg.react.incon_right * 1000;
        reach_avg_each.mt(iTraj).con_left(iSub)  = r_avg.mt.con_left * 1000;
        reach_avg_each.mt(iTraj).con_right(iSub) = r_avg.mt.con_right * 1000;
        reach_avg_each.mt(iTraj).incon_left(iSub)  = r_avg.mt.incon_left * 1000;
        reach_avg_each.mt(iTraj).incon_right(iSub) = r_avg.mt.incon_right * 1000;
        reach_avg_each.mad(iTraj).con_left(iSub)  = r_avg.mad.con_left;
        reach_avg_each.mad(iTraj).con_right(iSub) = r_avg.mad.con_right;
        reach_avg_each.mad(iTraj).incon_left(iSub)  = r_avg.mad.incon_left;
        reach_avg_each.mad(iTraj).incon_right(iSub) = r_avg.mad.incon_right;
        reach_avg_each.com(iTraj).con_left(iSub)  = r_avg.com.con_left;
        reach_avg_each.com(iTraj).con_right(iSub) = r_avg.com.con_right;
        reach_avg_each.com(iTraj).incon_left(iSub)  = r_avg.com.incon_left;
        reach_avg_each.com(iTraj).incon_right(iSub) = r_avg.com.incon_right;
        reach_avg_each.tot_dist(iTraj).con_left(iSub)  = r_avg.tot_dist.con_left;
        reach_avg_each.tot_dist(iTraj).con_right(iSub) = r_avg.tot_dist.con_right;
        reach_avg_each.tot_dist(iTraj).incon_left(iSub)  = r_avg.tot_dist.incon_left;
        reach_avg_each.tot_dist(iTraj).incon_right(iSub) = r_avg.tot_dist.incon_right;
        reach_avg_each.auc(iTraj).con_left(iSub)  = r_avg.auc.con_left;
        reach_avg_each.auc(iTraj).con_right(iSub) = r_avg.auc.con_right;
        reach_avg_each.auc(iTraj).incon_left(iSub)  = r_avg.auc.incon_left;
        reach_avg_each.auc(iTraj).incon_right(iSub) = r_avg.auc.incon_right;
        reach_avg_each.max_vel(iTraj).con_left(iSub)  = r_avg.max_vel.con_left;
        reach_avg_each.max_vel(iTraj).con_right(iSub) = r_avg.max_vel.con_right;
        reach_avg_each.max_vel(iTraj).incon_left(iSub)  = r_avg.max_vel.incon_left;
        reach_avg_each.max_vel(iTraj).incon_right(iSub) = r_avg.max_vel.incon_right;
        reach_avg_each.x_std(iTraj).con_left(:,iSub)  = r_avg.x_std.con_left;
        reach_avg_each.x_std(iTraj).con_right(:,iSub) = r_avg.x_std.con_right;
        reach_avg_each.x_std(iTraj).incon_left(:,iSub)  = r_avg.x_std.incon_left;
        reach_avg_each.x_std(iTraj).incon_right(:,iSub) = r_avg.x_std.incon_right;
        reach_avg_each.cond_diff(iTraj).left(:,iSub,:)  = r_avg.cond_diff.left;
        reach_avg_each.cond_diff(iTraj).right(:,iSub,:) = r_avg.cond_diff.right;
        keyboard_avg_each.rt(iTraj).con_left(iSub)  = k_avg.rt.con_left * 1000;
        keyboard_avg_each.rt(iTraj).con_right(iSub) = k_avg.rt.con_right * 1000;
        keyboard_avg_each.rt(iTraj).incon_left(iSub)  = k_avg.rt.incon_left * 1000;
        keyboard_avg_each.rt(iTraj).incon_right(iSub) = k_avg.rt.incon_right * 1000;
        keyboard_avg_each.rt_std(iTraj).con_left(iSub)  = k_avg.rt_std.con_left;
        keyboard_avg_each.rt_std(iTraj).con_right(iSub) = k_avg.rt_std.con_right;
        keyboard_avg_each.rt_std(iTraj).incon_left(iSub)  = k_avg.rt_std.incon_left;
        keyboard_avg_each.rt_std(iTraj).incon_right(iSub) = k_avg.rt_std.incon_right;
        % Combined avg of left and right.
        reach_avg_each.traj(iTraj).con(:, iSub, :) = r_avg.traj.con;
        reach_avg_each.traj(iTraj).incon(:, iSub, :) = r_avg.traj.incon;
        reach_avg_each.head_angle(iTraj).con(:, iSub) = r_avg.head_angle.con;
        reach_avg_each.head_angle(iTraj).incon(:, iSub) = r_avg.head_angle.incon;
        reach_avg_each.vel(iTraj).con(:, iSub) = r_avg.vel.con;
        reach_avg_each.vel(iTraj).incon(:, iSub) = r_avg.vel.incon;
        reach_avg_each.acc(iTraj).con(:, iSub) = r_avg.acc.con;
        reach_avg_each.acc(iTraj).incon(:, iSub) = r_avg.acc.incon;
        reach_avg_each.iep(iTraj).con(:, iSub) = r_avg.iep.con;
        reach_avg_each.iep(iTraj).incon(:, iSub) = r_avg.iep.incon;
        reach_avg_each.rt(iTraj).con(iSub) = r_avg.rt.con * 1000;
        reach_avg_each.rt(iTraj).incon(iSub) = r_avg.rt.incon * 1000;
        reach_avg_each.react(iTraj).con(iSub) = r_avg.react.con * 1000;
        reach_avg_each.react(iTraj).incon(iSub) = r_avg.react.incon * 1000;
        reach_avg_each.mt(iTraj).con(iSub) = r_avg.mt.con * 1000;
        reach_avg_each.mt(iTraj).incon(iSub) = r_avg.mt.incon * 1000;
        reach_avg_each.mad(iTraj).con(iSub) = r_avg.mad.con;
        reach_avg_each.mad(iTraj).incon(iSub) = r_avg.mad.incon;
        reach_avg_each.com(iTraj).con(iSub) = r_avg.com.con;
        reach_avg_each.com(iTraj).incon(iSub) = r_avg.com.incon;
        reach_avg_each.tot_dist(iTraj).con(iSub) = r_avg.tot_dist.con;
        reach_avg_each.tot_dist(iTraj).incon(iSub) = r_avg.tot_dist.incon;
        reach_avg_each.auc(iTraj).con(iSub) = r_avg.auc.con;
        reach_avg_each.auc(iTraj).incon(iSub) = r_avg.auc.incon;
        reach_avg_each.max_vel(iTraj).con(iSub) = r_avg.max_vel.con;
        reach_avg_each.max_vel(iTraj).incon(iSub) = r_avg.max_vel.incon;
        reach_avg_each.x_std(iTraj).con(:, iSub) = r_avg.x_std.con;
        reach_avg_each.x_std(iTraj).incon(:, iSub) = r_avg.x_std.incon;
        reach_avg_each.ra(iTraj).con(iSub) = reach_area.con(iSub);
        reach_avg_each.ra(iTraj).incon(iSub) = reach_area.incon(iSub);
        reach_avg_each.pas(iTraj).con(iSub,:) = r_avg.pas.con;
        reach_avg_each.pas(iTraj).incon(iSub,:) = r_avg.pas.incon;
        keyboard_avg_each.rt(iTraj).con(iSub) = k_avg.rt.con * 1000;
        keyboard_avg_each.rt(iTraj).incon(iSub) = k_avg.rt.incon * 1000;
        keyboard_avg_each.rt_std(iTraj).con(iSub) = k_avg.rt_std.con;
        keyboard_avg_each.rt_std(iTraj).incon(iSub) = k_avg.rt_std.incon;
        keyboard_avg_each.pas(iTraj).con(iSub,:) = k_avg.pas.con;
        keyboard_avg_each.pas(iTraj).incon(iSub,:) = k_avg.pas.incon;
        % Compute diff between conditions (con/incon).
        reach_avg_each.rt(iTraj).diff(iSub)  = mean([r_avg.rt.con_left - r_avg.rt.incon_left,...
                                                r_avg.rt.con_right - r_avg.rt.incon_right]) * 1000;
        reach_avg_each.react(iTraj).diff(iSub)  = mean([r_avg.react.con_left - r_avg.react.incon_left,...
                                                r_avg.react.con_right - r_avg.react.incon_right]) * 1000;
        reach_avg_each.mt(iTraj).diff(iSub)  = mean([r_avg.mt.con_left - r_avg.mt.incon_left,...
                                                r_avg.mt.con_right - r_avg.mt.incon_right]) * 1000;
        reach_avg_each.mad(iTraj).diff(iSub)  = mean([r_avg.mad.con_left - r_avg.mad.incon_left,...
                                                r_avg.mad.con_right - r_avg.mad.incon_right]);
        reach_avg_each.x_dev(iTraj).diff(:,iSub) = mean([-1 * (r_avg.traj.con_left(:,1) - r_avg.traj.incon_left(:,1)),...
                                                    (r_avg.traj.con_right(:,1) - r_avg.traj.incon_right(:,1))],...
                                                    2);
        reach_avg_each.x_std(iTraj).diff(:,iSub) = mean([r_avg.x_std.con_left - r_avg.x_std.incon_left,...
                                                    r_avg.x_std.con_right - r_avg.x_std.incon_right],...
                                                    2);
        reach_avg_each.ra(iTraj).diff(iSub) = reach_area.con(iSub) - reach_area.incon(iSub);
        keyboard_avg_each.rt(iTraj).diff(iSub)  = mean([k_avg.rt.con_left - k_avg.rt.incon_left,...
                                                k_avg.rt.con_right - k_avg.rt.incon_right]) * 1000;
    end
    reach_avg_each.fc_prime.con(iSub) = r_avg.fc_prime.con;
    reach_avg_each.fc_prime.incon(iSub) = r_avg.fc_prime.incon;
    keyboard_avg_each.fc_prime.con(iSub) = k_avg.fc_prime.con;
    keyboard_avg_each.fc_prime.incon(iSub) = k_avg.fc_prime.incon;
end
save([p.PROC_DATA_FOLDER '/avg_each_' p.DAY '_' traj_names{iTraj}{1} '_subs_' p.SUBS_STRING '.mat'], 'reach_avg_each', 'keyboard_avg_each');
disp("Done setting plotting params.");
%% Single Sub plots.
good_subs = load([p.PROC_DATA_FOLDER '/good_subs_' p.DAY '_' traj_names{iTraj}{1} '_subs_' p.SUBS_STRING '.mat']);  good_subs = good_subs.good_subs;
subs_to_present = good_subs([5,10]);
% Create figure for each sub.
for iSub = subs_to_present
    sub_f(iSub,1) = figure('Name',['Sub ' num2str(iSub)], 'WindowState','maximized', 'MenuBar','figure');
%     sub_f(iSub,2) = figure('Name',['Sub ' num2str(iSub)], 'WindowState','maximized', 'MenuBar','figure');
%     sub_f(iSub,3) = figure('Name',['Sub ' num2str(iSub)], 'WindowState','maximized', 'MenuBar','figure');
    % Add title.
    figure(sub_f(iSub,1)); annotation('textbox',[0.45 0.915 0.1 0.1], 'String',['Sub ' num2str(iSub)], 'FontSize',30, 'LineStyle','none', 'FitBoxToText','on');
%     figure(sub_f(iSub,2)); annotation('textbox',[0.45 0.915 0.1 0.1], 'String',['Sub ' num2str(iSub)], 'FontSize',30, 'LineStyle','none', 'FitBoxToText','on');
%     figure(sub_f(iSub,3)); annotation('textbox',[0.45 0.915 0.1 0.1], 'String',['Sub ' num2str(iSub)], 'FontSize',30, 'LineStyle','none', 'FitBoxToText','on');
end
% 
% ------- Traj of each trial -------
for iSub = subs_to_present
    figure(sub_f(iSub,1));
    subplot_p = [2,3,1; 2,3,4];
    plotAllTrajs(iSub, traj_names, subplot_p, plt_p, p);
end
% 
% % ------- Heading angle of each trial -------
% for iSub = subs_to_present
%     figure(sub_f(subs_to_present(1),1));
%     subplot(2,3,4);
%     plotHeadAngles(iSub, traj_names{1}{1}, plt_p, p);
% end
% 
% % ------- Avg traj with shade -------
% for iSub = subs_to_present
%     figure(sub_f(iSub,1));
%     subplot(2,3,2);
%     plotAvgTrajWithShade(iSub, traj_names, plt_p, p);
% end
% 
% % ------- React + Movement + Response Times -------
% for iSub = p.SUBS
%     figure(sub_f(iSub,1));
%     subplot(2,1,2);
%     plotReactMtRt(iSub, traj_names, plt_p, p);
% end
% 
% % ------- PAS -------
% for iSub = p.SUBS
%     figure(sub_f(iSub,1));
%     subplot(2,6,5);
%     plotPas(iSub, traj_names{1}{1}, plt_p, p);
% end
% 
% % ------- Prime Forced Choice -------
% for iSub = p.SUBS
%     figure(sub_f(iSub,1));
%     subplot(2,6,6);
%     plotRecognition(iSub, pas_rate, traj_names{1}{1}, plt_p, p);
% end
% 
% % ------- MAD -------
% % Maximum absolute deviation.
% for iSub = p.SUBS
%     figure(sub_f(iSub,2));
%     subplot(1,2,1);
%     plotMad(iSub, traj_names, plt_p, p);
% end
% 
% % ------- MAD Point -------
% % Maximally absolute deviating point.
% for iSub = p.SUBS
%     figure(sub_f(iSub,2));
%     subplot_p = [2,2,2; 2,2,4]; % Params for 1st and 2nd subplots.
%     plotMadPoint(iSub, traj_names, subplot_p, plt_p, p);
% end
% 
% % ------- X Standard Deviation -------
% for iSub = p.SUBS
%     figure(sub_f(iSub,3));
%     subplot_p = [2,2,1; 2,2,2]; % Params for 1st and 2nd subplots.
%     plotXStd(iSub, traj_names, subplot_p, plt_p, p);
% end

% ------- X Velocity -------
% for iSub = subs_to_present
%     figure(sub_f(iSub,1));
%     subplot_p = [2,3,2; 2,3,5]; % Params for 1st and 2nd subplots.
%     plotXVelAcc(iSub, 'vel', traj_names{1}, subplot_p, plt_p, p);
% end

% ------- X Max Velocity -------
% for iSub = subs_to_present
%     figure(sub_f(iSub,1));
%     subplot(2,3,3);
%     plotMaxVel(iSub, traj_names{1}, plt_p, p);
% end

% ------- X Acceleration -------
% for iSub = subs_to_present
%     figure(sub_f(iSub,1));
%     subplot_p = [2,3,2; 2,3,5]; % Params for 1st and 2nd subplots.
%     plotXVelAcc(iSub, 'acc', traj_names{1}, subplot_p, plt_p, p);
% end

% % ------- Implied endpoint -------
% for iSub = subs_to_present
%     figure(sub_f(iSub,1));
%     subplot_p = [2,3,3; 2,3,6]; % Params for 1st and 2nd subplots.
%     plotIEP(iSub, traj_names{1}, subplot_p, plt_p, p);
% end
% 
% % ------- Keyboard Response Times -------
% if any(p.ORIG_SUBS >=43) % Only for Exp 4.
%     for iSub = p.SUBS
%         figure(sub_f(iSub,3));
%         subplot(2,1,2);
%         plotKeyboardRt(iSub, traj_names{1}{1}, plt_p, p);
%     end
% end
%% Multiple subs average plots.
% Create figures.
all_sub_f(1) = figure('Name',['All Subs'], 'WindowState','maximized', 'MenuBar','figure');
all_sub_f(2) = figure('Name',['All Subs'], 'WindowState','maximized', 'MenuBar','figure');
all_sub_f(3) = figure('Name',['All Subs'], 'WindowState','maximized', 'MenuBar','figure');
all_sub_f(4) = figure('Name',['All Subs'], 'WindowState','maximized', 'MenuBar','figure');
all_sub_f(5) = figure('Name',['All Subs'], 'WindowState','maximized', 'MenuBar','figure');
all_sub_f(6) = figure('Name',['All Subs'], 'WindowState','maximized', 'MenuBar','figure');
all_sub_f(7) = figure('Name',['All Subs'], 'WindowState','maximized', 'MenuBar','figure');
% Add title.
figure(all_sub_f(1)); annotation('textbox',[0.45 0.915 0.1 0.1], 'String','All Subs', 'FontSize',30, 'LineStyle','none', 'FitBoxToText','on');
figure(all_sub_f(2)); annotation('textbox',[0.45 0.915 0.1 0.1], 'String','All Subs', 'FontSize',30, 'LineStyle','none', 'FitBoxToText','on');
figure(all_sub_f(3)); annotation('textbox',[0.45 0.915 0.1 0.1], 'String','All Subs', 'FontSize',30, 'LineStyle','none', 'FitBoxToText','on');
figure(all_sub_f(4)); annotation('textbox',[0.45 0.915 0.1 0.1], 'String','All Subs', 'FontSize',30, 'LineStyle','none', 'FitBoxToText','on');
figure(all_sub_f(5)); annotation('textbox',[0.45 0.915 0.1 0.1], 'String','All Subs', 'FontSize',30, 'LineStyle','none', 'FitBoxToText','on');
figure(all_sub_f(6)); annotation('textbox',[0.45 0.915 0.1 0.1], 'String','All Subs', 'FontSize',30, 'LineStyle','none', 'FitBoxToText','on');
figure(all_sub_f(7)); annotation('textbox',[0.45 0.915 0.1 0.1], 'String','All Subs', 'FontSize',30, 'LineStyle','none', 'FitBoxToText','on');

% ------- Avg traj with shade -------
figure(all_sub_f(1));
subplot(2,5,[1 2]);
plotMultiAvgTrajWithShade(traj_names, plt_p, p);

if ~p.NORM_TRAJ % Vel, acc, angle, iEP are meaningless for normalized traj whose z vals mean nothign in space.
    % ------- Implied Endpoint -------
    figure(all_sub_f(1));
    subplot_p = [2,3,3; 2,3,6];
    plotMultiIEP(traj_names, subplot_p, 1, plt_p, p);

    % ------- Heading angle -------
    figure(all_sub_f(4));
    subplot(2,2,1);
    plotMultiHeadAngle(traj_names, plt_p, p);
    subplot_p = [2,2,3; 2,2,4];
%     plotMultiHeadAngleHeatmap(traj_names, subplot_p, p);

    % ------- Velocity -------
    figure(all_sub_f(2));
    subplot_p = [2,3,1; 2,3,4];
    plotMultiVelAcc('vel', traj_names{1}, subplot_p, 0, plt_p, p);
    
    % ------- Max Velocity -------
    figure(all_sub_f(1));
    subplot(2,3,4);
    plotMultiMaxVel(traj_names{1}, plt_p, p);
    
    % ------- Acceleration -------
    figure(all_sub_f(2));
    subplot_p = [2,3,2; 2,3,5];
    plotMultiVelAcc('acc', traj_names{1}, subplot_p, 0, plt_p, p);
    
    % ------- Velocity Profile -------
    % figure(all_sub_f(1));
    % plotMultiVelProf(p);
end

% ------- React + Movement + Response Times Reaching -------
figure(all_sub_f(1));
subplot_p = [2,5,6; 2,5,7];
react_mt_rt_p_val = plotMultiReactMtRt(traj_names, subplot_p, plt_p, p);
p_val = react_mt_rt_p_val.react;
save([p.PROC_DATA_FOLDER '/react_p_val_' p.DAY '_' p.EXP '.mat'], 'p_val');
p_val = react_mt_rt_p_val.mt;
save([p.PROC_DATA_FOLDER '/mt_p_val_' p.DAY '_' p.EXP '.mat'], 'p_val');

% % ------- MAD -------
% % Maximum absolute deviation.
figure(all_sub_f(3));
subplot(1,3,1);
p_val = plotMultiMad(traj_names, plt_p, p);
save([p.PROC_DATA_FOLDER '/mad_p_val_' p.DAY '_subs_' p.SUBS_STRING '.mat'], 'p_val');

% ------- Reach Area -------
% Area between avg left traj and avg right traj (in each condition).
figure(all_sub_f(1));
subplot(2,5,8);
p_val = plotMultiReachArea(traj_names, plt_p, p);
save([p.PROC_DATA_FOLDER '/ra_p_val_' p.DAY '_' p.EXP '.mat'], 'p_val');

% ------- X STD -------
figure(all_sub_f(3));
subplot_p = [2,3,2; 2,3,3; 2,3,5];
plotMultiXStd(traj_names, subplot_p, plt_p, p);

% ------- COM -------
% Number of changes of mind.
figure(all_sub_f(3));
subplot(2,3,6);
p_val = plotMultiCom(traj_names, plt_p, p);
save([p.PROC_DATA_FOLDER '/com_p_val_' p.DAY '_' p.EXP '.mat'], 'p_val');

% ------- Total distance traveled -------
% Total distance traveled.
figure(all_sub_f(1));
subplot(2,5,3);
p_val = plotMultiTotDist(traj_names, plt_p, p);
save([p.PROC_DATA_FOLDER '/tot_dist_p_val_' p.DAY '_' p.EXP '.mat'], 'p_val');

% ------- AUC -------
% Area under the curve.
figure(all_sub_f(2));
subplot(2,3,3);
p_val = plotMultiAuc(traj_names, plt_p, p);
save([p.PROC_DATA_FOLDER '/auc_p_val_' p.DAY '_' p.EXP '.mat'], 'p_val');

% ------- Response Times Keyboard -------
if any(p.ORIG_SUBS >=43) % Only for Exp 4.
    figure(all_sub_f(2));
    subplot(2,3,6);
    p_val = plotMultiKeyboardRt(traj_names, plt_p, p);
    save([p.PROC_DATA_FOLDER '/keyboard_rt_p_val_' p.DAY '_' p.EXP '.mat'], 'p_val');
end

% % ------- FDA -------
figure(all_sub_f(5));
subplot(1,3,3);
plotMultiFda(traj_names, plt_p, p);

% @@@@@@@@------- Prime Forced choice -------@@@@@@@@
figure(all_sub_f(6));
subplot(2,4,1);
plotMultiRecognition(pas_rate, 'reach', 'good_subs', traj_names{1}{1}, plt_p, p);
hold on;
subplot(2,4,2);
plotMultiRecognition(pas_rate, 'reach', 'all_subs', traj_names{1}{1}, plt_p, p);
subplot(2,4,3);
plotMultiRecognition(pas_rate, 'keyboard', 'good_subs', traj_names{1}{1}, plt_p, p);
subplot(2,4,4);
plotMultiRecognition(pas_rate, 'keyboard', 'all_subs', traj_names{1}{1}, plt_p, p);

% @@@@@@@@------- PAS -------@@@@@@@@
figure(all_sub_f(6));
subplot(2,4,5);
plotMultiPas(traj_names{1}{1}, 'reach', 'good_subs', plt_p, p);
subplot(2,4,6);
plotMultiPas(traj_names{1}{1}, 'reach', 'all_subs', plt_p, p);
subplot(2,4,7);
plotMultiPas(traj_names{1}{1}, 'keyboard', 'good_subs', plt_p, p);
subplot(2,4,8);
plotMultiPas(traj_names{1}{1}, 'keyboard', 'all_subs', plt_p, p);

% @@@@@@@@------- Condition Diff -------@@@@@@@@
% Difference between avg traj in each condition.
% figure(all_sub_f(7));
% subplot_p = [2,4,6; 2,4,7; 2,4,8];
% plotMultiTrajDiffBetweenConds(traj_names, subplot_p, plt_p, p);

% @@@@@@@@------- Number of bad trials -------@@@@@@@@
% Comparison of bad trials count between Keybaord and reaching.
figure(all_sub_f(7));
subplot(2,1,1);
plotNumBadTrials(traj_names{1}{1}, 'all_subs', plt_p, p);
subplot(2,1,2);
plotNumBadTrials(traj_names{1}{1}, 'good_subs', plt_p, p);

% @@@@@@@@------- d' direct vs indirect -------@@@@@@@@
% Comparison of sensitivity between direct and indirect measures of prime processing.
% figure(all_sub_f(6));
% subplot_p = [2,3,1; 2,3,2];
% plotMultiDPrime(traj_names{1}{1}, subplot_p, plt_p, p);
%% Plots for paper
good_subs = load([p.PROC_DATA_FOLDER '/good_subs_' p.DAY '_' traj_names{iTraj}{1} '_subs_' p.SUBS_STRING '.mat']);  good_subs = good_subs.good_subs;
% Present single trial data of which subs?
subs_to_present = good_subs([5,10]);

if ~p.NORM_TRAJ
    paper_f(1) = figure('Name',['All Subs'], 'WindowState','maximized', 'MenuBar','figure');
    % ------- Avg traj with shade -------
    figure(paper_f(1));
    subplot(2,3,1);
    plotMultiAvgTrajWithShade(traj_names, plt_p, p);

    % ------- Implied Endpoint -------
    figure(paper_f(1));
    subplot_p = [0,0,0; 2,3,2];
    plotMultiIEP(traj_names, subplot_p, 0, plt_p, p);
else
    
    paper_f(1) = figure('Name',['All Subs'], 'WindowState','maximized', 'MenuBar','figure');
    % ------- Avg traj with shade -------
    figure(paper_f(1));
    subplot(2,5,[1 2]);
    plotMultiAvgTrajWithShade(traj_names, plt_p, p);
    
    % ------- Reach Area -------
    % Area between avg left traj and avg right traj (in each condition).
    figure(paper_f(1));
    subplot(2,5,3);
    p_val = plotMultiReachArea(traj_names, plt_p, p);
    save([p.PROC_DATA_FOLDER '/ra_p_val_' p.DAY '_' p.EXP '.mat'], 'p_val');
    
    % ------- COM -------
    % Number of changes of mind.
    figure(paper_f(1));
    subplot(2,5,4);
    p_val = plotMultiCom(traj_names, plt_p, p);
    save([p.PROC_DATA_FOLDER '/com_p_val_' p.DAY '_' p.EXP '.mat'], 'p_val');
    
    % ------- React + Movement + Response Times Reaching -------
    figure(paper_f(1));
    subplot_p = [2,5,6; 2,5,7];
    react_mt_rt_p_val = plotMultiReactMtRt(traj_names, subplot_p, plt_p, p);
    p_val = react_mt_rt_p_val.react;
    save([p.PROC_DATA_FOLDER '/react_p_val_' p.DAY '_' p.EXP '.mat'], 'p_val');
    p_val = react_mt_rt_p_val.mt;
    save([p.PROC_DATA_FOLDER '/mt_p_val_' p.DAY '_' p.EXP '.mat'], 'p_val');
    
    % ------- Response Times Keyboard -------
    figure(paper_f(1));
    subplot(2,5,8);
    p_val = plotMultiKeyboardRt(traj_names, plt_p, p);
    save([p.PROC_DATA_FOLDER '/keyboard_rt_p_val_' p.DAY '_' p.EXP '.mat'], 'p_val');
    
    % ------- Total distance traveled -------
    figure(paper_f(1));
    subplot(2,5,9);
    p_val = plotMultiTotDist(traj_names, plt_p, p);
    save([p.PROC_DATA_FOLDER '/tot_dist_p_val_' p.DAY '_' p.EXP '.mat'], 'p_val');

    paper_f(2) = figure('Name',['All Subs'], 'WindowState','maximized', 'MenuBar','figure');
    % ------- Traj of each trial -------
    j = 1;
    for iSub = subs_to_present
        figure(paper_f(2));
        subplot_p = [2,5,2*j-1; 2,5,4+2*j];
        plotAllTrajs(iSub, traj_names, subplot_p, plt_p, p);
        j = j + 1;
    end
end

paper_f(3) = figure('Name',['All Subs'], 'WindowState','maximized', 'MenuBar','figure');
% ------- Prime Forced choice -------
figure(paper_f(3));
subplot(2,3,1);
plotMultiRecognition(pas_rate, 'reach', 'good_subs', traj_names{1}{1}, plt_p, p);
subplot(2,3,2);
plotMultiRecognition(pas_rate, 'keyboard', 'good_subs', traj_names{1}{1}, plt_p, p);
%% Add labels to subplots.
subplots = [];
% Define order of subplots for each configuration.
if p.NORM_TRAJ
    figure(paper_f(1));
    all_plots = paper_f(1).Children;
    subplots{1} = [all_plots(8); all_plots(6); all_plots(5); all_plots(4); all_plots(3); all_plots(2); all_plots(1)];
    figure(paper_f(2));
    all_plots = paper_f(2).Children;
    subplots{2} = [all_plots(6); all_plots(3)];
else
    figure(paper_f(1));
    all_plots = paper_f(1).Children;
    subplots{1} = [all_plots(3); all_plots(1)];
end

figure(paper_f(3));
all_plots = paper_f(3).Children;
subplots{end+1} = [all_plots(4); all_plots(2)];

% Iterate over figures.
for iFigure = 1:length(subplots)
    labels = 'a':'z';
    % Label each subplot.
    for iSubplot = 1:length(subplots{iFigure})
        y_lim = subplots{iFigure}(iSubplot).YLim;
        x_lim = subplots{iFigure}(iSubplot).XLim;
        y_location = y_lim(2) + (y_lim(2) - y_lim(1))*0.075;
        x_location = x_lim(1) - (x_lim(2) - x_lim(1))*0.19;
        text(subplots{iFigure}(iSubplot), x_location, y_location, ['(', labels(iSubplot), ')'], 'FontSize',plt_p.labels_font_size, 'FontWeight','bold');
        pause(0.1);
    end
end
%% Number of bad trials, Exp 2 vs 3
% To run this section you must first run the analysis on the subs of exp 2 and 3 (seperatly).
num_bad_trials_comp_f = figure('Name',['All Subs'], 'WindowState','maximized', 'MenuBar','figure');
% Add title.
figure(num_bad_trials_comp_f); annotation('textbox',[0.45 0.915 0.1 0.1], 'String','All Subs', 'FontSize',30, 'LineStyle','none', 'FitBoxToText','on');
% subplot(2,1,1);
% plotNumBadTrialsExp2Exp3(traj_names{1}{1}, 'all_subs', plt_p, p);
% subplot(2,1,2);
plotNumBadTrialsExp2Exp3(traj_names{1}{1}, 'good_subs', plt_p, p);
%% Effect size comparison to previous papers.
% To run this section you must first run the analysis on the subs of exp 2 and 3 (seperatly).
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
sim_exp = isequal(p.SUBS-200, p.EXP_1_SUBS) * 1 + isequal(p.SUBS-200, p.EXP_2_SUBS) * 2 + isequal(p.SUBS-200, p.EXP_3_SUBS) * 3;
effects_table.exp_name = ["exp2"; "exp3"; string(['exp' num2str(sim_exp) ' sim ' num2str(p.NUM_TRIALS) ' trials'])];
writetable(effects_table, [p.PROC_DATA_FOLDER 'effects_table.csv'], 'WriteMode','append');
%% Compare RT between 1st and 2nd day of experiment 3.
% To run this section you must first run the analysis on the subs of exp 3.
rt_comp_day1_day2 = figure('Name',['RT comp day1 day2'], 'WindowState','maximized', 'MenuBar','figure');
% Add title.
figure(all_sub_f(1));
subplot(2,5,3);
compareRTFirstSecondDay(traj_names, plt_p, p);
%% RT comparison between 1st and 2nd practice blocks.
% Relevant only for Exp 3's data.
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
printBeeswarm(beesdata, yLabel, XTickLabel, colors, plt_p.space, title_char, plt_p.errbar_type, plt_p.alpha_size);
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
%% Movement time percentiles.
% Find value of requested percentiles, in an array of all of the good subs' MTs.
% Used to determine what length to trim all trajs to when the trajectory isn't space normalized.
prctiles = [1, 5, 10, 20, 25]; % To look for (0-100).
good_subs = load([p.PROC_DATA_FOLDER '/good_subs_' p.DAY '_' traj_names{iTraj}{1} '_subs_' p.SUBS_STRING '.mat']);  good_subs = good_subs.good_subs;
all_subs_mt = [];
for iSub = good_subs
    single_trials = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_sorted_trials_' traj_names{iTraj}{1} '.mat']);  single_trials = single_trials.r_trial;
    sub_mt = [single_trials.mt.con; single_trials.mt.incon];
    all_subs_mt = [all_subs_mt; sub_mt];
end
mt_prctiles = prctile(all_subs_mt, prctiles);
disp('-------- MT percentiles --------');
disp(array2table(round(mt_prctiles * 1000, 2), 'VariableNames',[string(prctiles)]));
%% Format to R
% Convert matlab data to a format suitable for R dataframes.

assert(exist('reach_avg_each'), "Run Plotting params section before running this one");

good_subs = load([p.PROC_DATA_FOLDER '/good_subs_' p.DAY '_target_x_to_subs_' p.SUBS_STRING '.mat']);  good_subs = good_subs.good_subs;
trim_len = load([p.PROC_DATA_FOLDER '/trim_len.mat']);  trim_len = trim_len.trim_len;
save([p.PROC_DATA_FOLDER '/format_to_r__good_subs.mat'], 'good_subs');

tic
% ----------- Avg of each Sub -----------
% Total traveled distance
tot_dist_df = fVal('tot_dist', 'reach', '', [], p);
writetable(tot_dist_df, [p.PROC_DATA_FOLDER '/format_to_r__r_tot_dist_' p.DAY '_' p.EXP '.csv']);
% AUC
auc_df = fVal('auc', 'reach', '', [], p);
writetable(auc_df, [p.PROC_DATA_FOLDER '/format_to_r__r_auc_' p.DAY '_' p.EXP '.csv']);
% Frequency of COM
com_df = fVal('com', 'reach', '', [], p);
writetable(com_df, [p.PROC_DATA_FOLDER '/format_to_r__r_com_' p.DAY '_' p.EXP '.csv']);
% Reaction time
react_df = fVal('react', 'reach', '', [], p);
writetable(react_df, [p.PROC_DATA_FOLDER '/format_to_r__r_react_' p.DAY '_' p.EXP '.csv']);
% Movment time
mt_df = fVal('mt', 'reach', '', [], p);
writetable(mt_df, [p.PROC_DATA_FOLDER '/format_to_r__r_mt_' p.DAY '_' p.EXP '.csv']);
% Reach Area.
ra_df = fReachArea(traj_names{iTraj}{1}, p);
writetable(ra_df, [p.PROC_DATA_FOLDER '/format_to_r__r_ra_' p.DAY '_' p.EXP '.csv']);
% Keyboard RT
rt_df = fVal('rt', 'keyboard', '', [], p);
writetable(rt_df, [p.PROC_DATA_FOLDER '/format_to_r__k_rt_' p.DAY '_' p.EXP '.csv']);
for iSamp = 1:trim_len
    % Deviation from center
    traj_df = fVal('traj', 'reach', 'time_series', iSamp, p);
    writetable(traj_df, [p.PROC_DATA_FOLDER '/format_to_r__r_traj' num2str(iSamp) '_' p.DAY '_' p.EXP '.csv']);
    % Movement variation
    x_std_df = fVal('x_std', 'reach', 'time_series', iSamp, p);
    writetable(x_std_df, [p.PROC_DATA_FOLDER '/format_to_r__r_x_std' num2str(iSamp) '_' p.DAY '_' p.EXP '.csv']);
    % Heading angle
    head_angle_df = fVal('head_angle', 'reach', 'time_series', iSamp, p);
    writetable(head_angle_df, [p.PROC_DATA_FOLDER '/format_to_r__r_head_angle' num2str(iSamp) '_' p.DAY '_' p.EXP '.csv']);
    % Horizontal Velocity
    vel_df = fVal('vel', 'reach', 'time_series', iSamp, p);
    writetable(vel_df, [p.PROC_DATA_FOLDER '/format_to_r__r_vel' num2str(iSamp) '_' p.DAY '_' p.EXP '.csv']);
end
% ----------- All good trials of each Sub -----------
% for iSub = good_subs
%     [r_df, k_df] = fAllGoodTrials(iSub, p);
%     writetable(r_df, [p.PROC_DATA_FOLDER '/format_to_r__sub' num2str(iSub) 'rdata.csv'])
%     writetable(k_df, [p.PROC_DATA_FOLDER '/format_to_r__sub' num2str(iSub) 'kdata.csv'])
% end

timing = num2str(toc);
disp(['Formating to R done. ' timing 'Sec']);
%% Tree-BH Correction. RUN ONLY AFTER R SCRIPTS.
plotTreeBH(plt_p, p);