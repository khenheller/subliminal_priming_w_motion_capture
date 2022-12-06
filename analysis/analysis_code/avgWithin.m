% Averages only good trials.
% pas_rate - double, only trials with this pas rating will be averaged.
% to_normalize - nromalize data within each subject (1/0).
% r/k_avg - struct, contains struct for each var, in which each field is average of good trials in a condition.
% r/k_trial - struct, contains struct for each var, in which each field has all good trials for that condition.
function [r_avg, r_trial, k_avg, k_trial] = avgWithin(iSub, traj_name, reach_bad_trials, keyboard_bad_trials, pas_rate, to_normalize, p)
    time_name = replace(traj_name{1}, 'x', 'timecourse');

    traj_len = load([p.PROC_DATA_FOLDER '/trim_len.mat']);  traj_len = traj_len.trim_len;
    % Get sub data.
    reach_traj_table = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_reach_traj_proc.mat']);  reach_traj_table = reach_traj_table.reach_traj_table;
    reach_data_table = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_reach_data_proc.mat']);  reach_data_table = reach_data_table.reach_data_table;
    keyboard_data_table = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_keyboard_data_proc.mat']);  keyboard_data_table = keyboard_data_table.keyboard_data_table;

    % remove practice.
    reach_traj_table(reach_traj_table{:,'practice'} >= 1, :) = [];
    reach_data_table(reach_data_table{:,'practice'} >= 1, :) = [];
    keyboard_data_table(keyboard_data_table{:,'practice'} >= 1, :) = [];

    % Get timeseries variables.
    traj = reach_traj_table{:, traj_name};
    time_vec = reach_traj_table{:, time_name};
    head_angle = reach_traj_table{:, 'head_angle'};
    % Reshape to convenient format.
    traj_mat = reshape(traj, traj_len, p.NUM_TRIALS, 3); % 3 for (x,y,z).
    time_mat = reshape(time_vec, traj_len, p.NUM_TRIALS);
    head_angle_mat = reshape(head_angle, traj_len, p.NUM_TRIALS);

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
    auc_col = ['auc'];

    % -------------------- Sort and avg REACH --------------------
    % Bad trials reasons, Remove reason: "slow_mvmnt", "loop".
    reasons = string(reach_bad_trials{iSub}.Properties.VariableNames);
    reasons(reasons == "any" | reasons == "slow_mvmnt" | reasons == "loop") = [];
    % Create sorter.
    bad = any(reach_bad_trials{iSub}{:, reasons}, 2);
    bad_timing_or_quit = reach_bad_trials{iSub}.bad_stim_dur | reach_bad_trials{iSub}.quit; % Bad stim duration, or sub quit before trial.
    pas = ismember(reach_data_table.('pas'), pas_rate);
    con = reach_data_table.('con');
    left = reach_data_table.(ans_left_col); % Sub chose left ans.
    sorter = struct("bad",bad, "bad_timing_or_quit",bad_timing_or_quit, "pas",pas, "con",con, "left",left);
    % Sort trials.
    trial.trajs  = sortTrials(traj_mat, sorter, 'timeseries', to_normalize);
    trial.time  = sortTrials(time_mat, sorter, 'timeseries', 0);
    trial.head_angle = sortTrials(head_angle_mat, sorter, 'timeseries', to_normalize);
    trial.rt = sortTrials(reach_data_table.(offset_col), sorter, 0, to_normalize); % Response time.
    trial.react = sortTrials(reach_data_table.(onset_col), sorter, 0, to_normalize); % Reaction time.
    trial.mt = sortTrials(reach_data_table.(offset_col) - reach_data_table.(onset_col), sorter, 0, to_normalize); % Movement time.
    trial.mad = sortTrials(reach_data_table.(mad_col), sorter, 0, to_normalize); % Maximum absolute deviation.
    trial.mad_p = sortTrials(reach_data_table.(mad_p_col), sorter, 0, to_normalize); % Maximally deviating point.
    trial.com = sortTrials(reach_data_table.(com_col), sorter, 0, to_normalize); % Number of changes of mind.
    trial.tot_dist = sortTrials(reach_data_table.(tot_dist_col), sorter, 0, to_normalize); % Total distance traveled.
    trial.auc = sortTrials(reach_data_table.(auc_col), sorter, 0, to_normalize); % Area Under the Curve.
    trial.fc_prime.con   = reach_data_table.prime_correct(~bad_timing_or_quit & pas & con); % forced choice.
    trial.fc_prime.incon = reach_data_table.prime_correct(~bad_timing_or_quit & pas & ~con);
    trial.pas.con   = reach_data_table.pas(~bad_timing_or_quit & con);
    trial.pas.incon = reach_data_table.pas(~bad_timing_or_quit & ~con);
    % Average.
    avg.traj = sortedAvg(trial.trajs, 'timeseries', 1);
    avg.time = sortedAvg(trial.time, 'timeseries', 0);
    avg.head_angle = sortedAvg(trial.head_angle, 'timeseries', 0);
    avg.rt = sortedAvg(trial.rt, '', 0);
    avg.react = sortedAvg(trial.react, '', 0);
    avg.mt = sortedAvg(trial.mt, '', 0);
    avg.mad = sortedAvg(trial.mad, '', 0);
    avg.mad_p = sortedAvg(trial.mad_p, '', 1);
    avg.com = sortedAvg(trial.com, '', 0);
    avg.tot_dist = sortedAvg(trial.tot_dist, '', 0);
    avg.auc = sortedAvg(trial.auc, '', 0);
    avg.fc_prime.con   = nanmean(trial.fc_prime.con);
    avg.fc_prime.incon = nanmean(trial.fc_prime.incon);
    avg.x_std.con_left    = std(trial.trajs.con_left (:,:,1), 0, 2); % std between trials.
    avg.x_std.con_right   = std(trial.trajs.con_right(:,:,1), 0, 2);
    avg.x_std.incon_left  = std(trial.trajs.incon_left (:,:,1), 0, 2);
    avg.x_std.incon_right = std(trial.trajs.incon_right(:,:,1), 0, 2);
    avg.cond_diff.left  = avg.traj.con_left  - avg.traj.incon_left;
    avg.cond_diff.right = avg.traj.con_right - avg.traj.incon_right;
    % Count pas ratings.
    for i = 1:4
        avg.pas.con(i)   = sum(trial.pas.con == i); 
        avg.pas.incon(i) = sum(trial.pas.incon == i);
    end
    r_trial = trial;
    r_avg = avg;
    trial = []; % Clear before computing keyboard.
    avg = [];

    % -------------------- Sort and avg KEYBOARD --------------------
    % Create sorter.
    bad = keyboard_bad_trials{iSub}.any;
    bad_timing_or_quit = keyboard_bad_trials{iSub}.bad_stim_dur | keyboard_bad_trials{iSub}.quit; % Bad stim duration, or sub quit before trial.
    pas = ismember(keyboard_data_table.('pas'), pas_rate);
    con = keyboard_data_table.('con');
    left = keyboard_data_table.(ans_left_col); % Sub chose left ans.
    sorter = struct("bad",bad, "bad_timing_or_quit",bad_timing_or_quit, "pas",pas, "con",con, "left",left);
    % Sort trials.
    trial.rt = sortTrials(keyboard_data_table.(rt_col), sorter, '', to_normalize); % Response time.
    trial.fc_prime.con   = keyboard_data_table.prime_correct(~bad_timing_or_quit & pas & con); % forced choice.
    trial.fc_prime.incon = keyboard_data_table.prime_correct(~bad_timing_or_quit & pas & ~con);
    trial.pas.con   = keyboard_data_table.pas(~bad_timing_or_quit & con);
    trial.pas.incon = keyboard_data_table.pas(~bad_timing_or_quit & ~con);
    % Average.
    avg.rt = sortedAvg(trial.rt, '', 0);
    avg.rt_std.con_left = std(trial.rt.con_left);
    avg.rt_std.con_right = std(trial.rt.con_right);
    avg.rt_std.incon_left = std(trial.rt.incon_left);
    avg.rt_std.incon_right = std(trial.rt.incon_right);
    avg.rt_std.con = std(trial.rt.con);
    avg.rt_std.incon = std(trial.rt.incon);
    avg.fc_prime.con   = nanmean(trial.fc_prime.con);
    avg.fc_prime.incon = nanmean(trial.fc_prime.incon);
    % Count pas ratings.
    for i = 1:4
        avg.pas.con(i)   = sum(trial.pas.con == i); 
        avg.pas.incon(i) = sum(trial.pas.incon == i);
    end
    k_trial = trial;
    k_avg = avg;
end

% Seperate data to struct fields according to conditions.
% sorter - struct, with flag marking each trial's type:
%   bad - is each trial bad (1) or good (0).
%   pas - has each trial got required pas rating.
%   con - is each trial congruent.
%   left - was answer in each trial "left".
% data_type - sorting trajs (which have multiple values for each trial) or regular data (single value per trial)?
% to_normalize - within each sub.
function [sorted_data] = sortTrials(data, sorter, data_type, to_normalize)
    bad = sorter.bad;
    pas = sorter.pas;
    con = sorter.con;
    left = sorter.left;
    if isequal(data_type, 'timeseries')
        sorted_data.con_left = data(:, ~bad & pas & con  & (left==1), :); % using "==" because of NaNs.
        sorted_data.con_right = data(:, ~bad & pas & con  & (left==0), :);
        sorted_data.incon_left = data(:, ~bad & pas & ~con & (left==1), :);
        sorted_data.incon_right = data(:, ~bad & pas & ~con & (left==0), :);
        sorted_data.con = data(:, ~bad & pas & con, :);
        sorted_data.incon = data(:, ~bad & pas & ~con, :);
        % Calc mean and std.
        data_avg = mean([sorted_data.con, sorted_data.incon], 2);
        data_std = std([sorted_data.con, sorted_data.incon], 0, 2);
        % If traj was normalized in space (z identical for all trials), don't normalize Z.
        all_trials = [sorted_data.con, sorted_data.incon];
        if all(all_trials(:,1,end) == all_trials(:,:,end), 'all')
            data_avg(:,1,end) = 0;
            data_std(:,1,end) = 1;
        end
    else
        sorted_data.con_left = data(~bad & pas & con  & (left==1),:);
        sorted_data.con_right = data(~bad & pas & con  & (left==0),:);
        sorted_data.incon_left = data(~bad & pas & ~con & (left==1),:);
        sorted_data.incon_right = data(~bad & pas & ~con & (left==0),:);
        sorted_data.con = data(~bad & pas & con,:);
        sorted_data.incon = data(~bad & pas & ~con,:);
        % Calc mean and std.
        data_avg = mean([sorted_data.con; sorted_data.incon], 1);
        data_std = std([sorted_data.con; sorted_data.incon], 0, 1);
        all_trials = [sorted_data.con; sorted_data.incon];
    end

    % Normalize.
    if to_normalize
        sorted_data.con_left = round((sorted_data.con_left - data_avg), 10) ./ data_std;
        sorted_data.con_right = round((sorted_data.con_right - data_avg), 10) ./ data_std;
        sorted_data.incon_left = round((sorted_data.incon_left - data_avg), 10) ./ data_std;
        sorted_data.incon_right = round((sorted_data.incon_right - data_avg), 10) ./ data_std;
        sorted_data.con = round((sorted_data.con - data_avg), 10) ./ data_std;
        sorted_data.incon = round((sorted_data.incon - data_avg), 10) ./ data_std;
    end
end

% Compute avg for each type of trials.
% is_traj - sorting trajs (avg 2nd dim) or regular data (avg 1st dim)?
% flip_left - if left and right have opposite values.
function [sorted_avg] = sortedAvg(data, data_type, flip_left)
    if isequal(data_type, 'timeseries')
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

    flip = ones(size(sorted_avg.con_left));
    if flip_left
        flip(:,1) = -1;
    end
    sorted_avg.con = (sorted_avg.con_left .* flip + sorted_avg.con_right) / 2;
    sorted_avg.incon = (sorted_avg.incon_left .* flip + sorted_avg.incon_right) / 2;
end