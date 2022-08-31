% Averages only good trials.
% pas_rate - double, only trials with this pas rating will be averaged.
% avg - structure, each field is avg of one condition. Average of all the good trias that had "pas_rate".
% single - struct, each field contains one condition's trials, that were good and had "pas_rate".
function [reach_avg, reach_single, keyboard_avg, keyboard_single] = avgWithin(iSub, traj_name, reach_bad_trials, keyboard_bad_trials, pas_rate, p)
    % Timecourse column.
    time_name = replace(traj_name{1}, 'x', 'timecourse');

    % Get sub data.
    reach_traj_table = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_reach_traj_proc.mat']);  reach_traj_table = reach_traj_table.reach_traj_table;
    reach_data_table = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_reach_data_proc.mat']);  reach_data_table = reach_data_table.reach_data_table;
    keyboard_data_table = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_keyboard_data_proc.mat']);  keyboard_data_table = keyboard_data_table.keyboard_data_table;

    % remove practice.
    reach_traj_table(reach_traj_table{:,'practice'} >= 1, :) = [];
    reach_data_table(reach_data_table{:,'practice'} >= 1, :) = [];
    keyboard_data_table(keyboard_data_table{:,'practice'} >= 1, :) = [];

    % Get traj and heading angle.
    traj = reach_traj_table{:, traj_name};
    time = reach_traj_table{:, time_name};
    head_angle = reach_traj_table{:, 'head_angle'};
    % Reshape to convenient format.
    traj_mat = reshape(traj, p.NORM_FRAMES, p.NUM_TRIALS, 3); % 3 for (x,y,z).
    time_mat = reshape(time, p.NORM_FRAMES, p.NUM_TRIALS);
    head_angle_mat = reshape(head_angle, p.NORM_FRAMES, p.NUM_TRIALS);

    % Column names in tables.
    ans_left_col   = regexprep(traj_name{1}, '_x_.+', '_ans_left'); % name of traj's ans_left column.
    rt_col          = regexprep(traj_name{1}, '_x_.+', '_rt'); % name of traj's rt column.
    onset_col   = ['onset'];
    offset_col  = ['offset'];
    mad_col     = [strrep(traj_name{1}, '_x',''), '_mad'];
    mad_p_col   = [strrep(traj_name{1}, '_x',''), '_mad_p'];
    head_angle_col = ['head_angle'];
    com_col = ['com'];
    tot_dist_col = ['tot_dist'];

    % -------------------- Sort and avg REACH --------------------
    % Bad trials reasons, Remove reason: "slow_mvmnt".
    reasons = string(reach_bad_trials{iSub}.Properties.VariableNames);
    reasons(reasons == "any" | reasons == "slow_mvmnt") = [];
    % Sorts trials.
    bad = any(reach_bad_trials{iSub}{:, reasons}, 2);
    bad_timing_or_quit = reach_bad_trials{iSub}.bad_stim_dur | reach_bad_trials{iSub}.quit; % Bad stim duration, or sub quit before trial.
    pas = ismember(reach_data_table.('pas'), pas_rate);
    con = reach_data_table.('con');
    left = reach_data_table.(ans_left_col); % Sub chose left ans.
    sorter = struct("bad",bad, "bad_timing_or_quit",bad_timing_or_quit, "pas",pas, "con",con, "left",left);
    % Sort trials and calc avg.
    single.trajs  = sortTrials(traj_mat, sorter, 1);
    single.time = sortTrials(time_mat, sorter, 1);
    single.head_angle = sortTrials(head_angle_mat, sorter, 1);
    single.rt = sortTrials(reach_data_table.(offset_col), sorter, 0); % Response time.
    single.react = sortTrials(reach_data_table.(onset_col), sorter, 0); % Reaction time.
    single.mt = sortTrials(reach_data_table.(offset_col) - reach_data_table.(onset_col), sorter, 0); % Movement time.
    single.mad = sortTrials(reach_data_table.(mad_col), sorter, 0); % Maximum absolute deviation.
    single.mad_p = sortTrials(reach_data_table.(mad_p_col), sorter, 0); % Maximally deviating point.
    single.com = sortTrials(reach_data_table.(com_col), sorter, 0); % Number of changes of mind.
    single.tot_dist = sortTrials(reach_data_table.(tot_dist_col), sorter, 0); % Total distance traveled.
    single.fc_prime.con   = reach_data_table.prime_correct(~bad_timing_or_quit & pas & con); % forced choice.
    single.fc_prime.incon = reach_data_table.prime_correct(~bad_timing_or_quit & pas & ~con);
    single.pas.con   = reach_data_table.pas(~bad_timing_or_quit & con);
    single.pas.incon = reach_data_table.pas(~bad_timing_or_quit & ~con);
    % Average.
    avg.traj = sortedAvg(single.trajs, 1);
    avg.time = sortedAvg(single.time, 1);
    avg.head_angle = sortedAvg(single.head_angle, 1);
    avg.rt = sortedAvg(single.rt, 0);
    avg.react = sortedAvg(single.react, 0);
    avg.mt = sortedAvg(single.mt, 0);
    avg.mad = sortedAvg(single.mad, 0);
    avg.mad_p = sortedAvg(single.mad_p, 0);
    avg.com = sortedAvg(single.com, 0);
    avg.tot_dist = sortedAvg(single.tot_dist, 0);
    avg.fc_prime.con   = nanmean(single.fc_prime.con);
    avg.fc_prime.incon = nanmean(single.fc_prime.incon);
    avg.x_std.con_left    = std(single.trajs.con_left (:,:,1), 0, 2); % std between trials.
    avg.x_std.con_right   = std(single.trajs.con_right(:,:,1), 0, 2);
    avg.x_std.incon_left  = std(single.trajs.incon_left (:,:,1), 0, 2);
    avg.x_std.incon_right = std(single.trajs.incon_right(:,:,1), 0, 2);
    avg.x_avg_std = sortedAvg(avg.x_std, 0); % avg across time. one value for whole traj.
    avg.cond_diff.left  = avg.traj.con_left  - avg.traj.incon_left;
    avg.cond_diff.right = avg.traj.con_right - avg.traj.incon_right;
    % Count pas ratings.
    for i = 1:4
        avg.pas.con(i)   = sum(single.pas.con == i); 
        avg.pas.incon(i) = sum(single.pas.incon == i);
    end
    reach_single = single;
    reach_avg = avg;
    single = []; % Clear before computing keyboard.
    avg = [];

    % -------------------- Sort and avg KEYBOARD --------------------
    % Sorts trials.
    bad = keyboard_bad_trials{iSub}.any;
    bad_timing_or_quit = keyboard_bad_trials{iSub}.bad_stim_dur | keyboard_bad_trials{iSub}.quit; % Bad stim duration, or sub quit before trial.
    pas = ismember(keyboard_data_table.('pas'), pas_rate);
    con = keyboard_data_table.('con');
    left = keyboard_data_table.(ans_left_col); % Sub chose left ans.
    sorter = struct("bad",bad, "bad_timing_or_quit",bad_timing_or_quit, "pas",pas, "con",con, "left",left);
    % Sort trials and calc avg.
    single.rt = sortTrials(keyboard_data_table.(rt_col), sorter, 0); % Response time.
    single.fc_prime.con   = keyboard_data_table.prime_correct(~bad_timing_or_quit & pas & con); % forced choice.
    single.fc_prime.incon = keyboard_data_table.prime_correct(~bad_timing_or_quit & pas & ~con);
    single.pas.con   = keyboard_data_table.pas(~bad_timing_or_quit & con);
    single.pas.incon = keyboard_data_table.pas(~bad_timing_or_quit & ~con);
    % Average.
    avg.rt = sortedAvg(single.rt, 0);
    avg.rt_std.con_left = std(single.rt.con_left);
    avg.rt_std.con_right = std(single.rt.con_right);
    avg.rt_std.incon_left = std(single.rt.incon_left);
    avg.rt_std.incon_right = std(single.rt.incon_right);
    avg.fc_prime.con   = nanmean(single.fc_prime.con);
    avg.fc_prime.incon = nanmean(single.fc_prime.incon);
    % Count pas ratings.
    for i = 1:4
        avg.pas.con(i)   = sum(single.pas.con == i); 
        avg.pas.incon(i) = sum(single.pas.incon == i);
    end
    keyboard_single = single;
    keyboard_avg = avg;
end

% Seperate data to struct fields according to conditions.
% sorter - struct, with flag marking each trial's type:
%   bad - is each trial bad (1) or good (0).
%   pas - has each trial got required pas rating.
%   con - is each trial congruent.
%   left - was answer in each trial "left".
% is_traj - sorting trajs (which have multiple values for each trial) or regular data (single value per trial)?
function [sorted_data] = sortTrials(data, sorter, is_traj)
    bad = sorter.bad;
    pas = sorter.pas;
    con = sorter.con;
    left = sorter.left;
    if is_traj
        sorted_data.con_left = data(:, ~bad & pas & con  & (left==1), :); % using "==" because of NaNs.
        sorted_data.con_right = data(:, ~bad & pas & con  & (left==0), :);
        sorted_data.incon_left = data(:, ~bad & pas & ~con & (left==1), :);
        sorted_data.incon_right = data(:, ~bad & pas & ~con & (left==0), :);
    else
        sorted_data.con_left = data(~bad & pas & con  & (left==1),:);
        sorted_data.con_right = data(~bad & pas & con  & (left==0),:);
        sorted_data.incon_left = data(~bad & pas & ~con & (left==1),:);
        sorted_data.incon_right = data(~bad & pas & ~con & (left==0),:);
    end
end

% Compute avg for each type of trials.
% is_traj - sorting trajs (avg 2nd dim) or regular data (avg 1st dim)?
function [sorted_avg] = sortedAvg(data, is_traj)
    if is_traj
        sorted_avg.con_left = squeeze(mean(data.con_left, 2));
        sorted_avg.con_right = squeeze(mean(data.con_right, 2));
        sorted_avg.incon_left = squeeze(mean(data.incon_left, 2));
        sorted_avg.incon_right = squeeze(mean(data.incon_right, 2));
    else
        sorted_avg.con_left = mean(data.con_left, 1);
        sorted_avg.con_right = mean(data.con_right, 1);
        sorted_avg.incon_left = mean(data.incon_left, 1);
        sorted_avg.incon_right = mean(data.incon_right, 1);
    end
end