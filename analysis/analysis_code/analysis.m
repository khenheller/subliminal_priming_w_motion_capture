clear all;
clc;
p.MAX_RECORD_LENGTH = 500;
p.NUM_TRIALS = 480;
p.DATA_FOLDER = '../../raw_data';
p.PROC_DATA_FOLDER = '../processed_data';
p.SAMPLE_RATE = 100;
%% Parameters
sub_nums = [1];
p.norm_frames = 200; % length of normalized trajs.
p.norm_type = 4; % 1=to time, 2=to x, 3=to y, 4=to z.
p.sample_rate = p.SAMPLE_RATE; % Camera samprate in Hz.

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
        traj_mat = reshape(traj, p.MAX_RECORD_LENGTH, p.NUM_TRIALS, 3); % 3 for (x,y,z).
        time_mat = reshape(time, p.MAX_RECORD_LENGTH, p.NUM_TRIALS);
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
        traj_mat_norm = normalize(traj_mat, p);
        
        % Reassign to table.
        traj = reshape(traj_mat, p.MAX_RECORD_LENGTH * p.NUM_TRIALS, 3); % 3 for (x,y,z).
        traj_norm = reshape(traj_mat_norm, p.MAX_RECORD_LENGTH * p.NUM_TRIALS, 3); % 3 for (x,y,z).
        time = reshape(time_mat, p.MAX_RECORD_LENGTH * p.NUM_TRIALS, 1);
        traj_table{:, traj_names{iTraj}} = traj;
        traj_table{:, traj_names_norm(iTraj,:)} = traj_norm;
        traj_table{:, time_names{iTraj}} = time;
        
        too_short_to_filter{find(iSub==sub_nums),iTraj}{:} = find(~success);
        too_short_to_filter{find(iSub==sub_nums),'sub_num'} = iSub;
    end
    
    disp(["Following trials where too short to filter for sub ", num2str(iSub), ":"]);
    for i = 1:length(traj_types)
        disp([traj_types{i}, ': ', num2str(too_short_to_filter{find(iSub==sub_nums), i}{:}')]);
    end
    
    writetable(traj_table, [p.PROC_DATA_FOLDER '/sub' num2str(iSub) 'traj_proc.csv']);
end
%% Screening
%{
create bad_trials cell: cell array, one cell for each traj type.
                        each cell contains a table where each variable is a err type
iterate over subs
    import single sub original table(not preprocessed)
    iterate over traj types
        create traj_mat
        iterate over trials
            perform all checks for each trial.
            mark in bad_trails failed tests: bad_trails{traj type}{iSub, 'test1'} = [bad_trails{traj type}{iSub, 'test1'} ~success]
            remove bad trials from traj_mat
        iterate over tests in bad_trials
            bad_trials{traj_type}{iSub, 'testi'} = find(bad_trials{traj_type}{iSub, 'testi'})
%}