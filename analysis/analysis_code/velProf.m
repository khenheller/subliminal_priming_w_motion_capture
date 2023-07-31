% Velocity profile - the distribution of velocities in each time window over all subs.
function [vel_dist] = velProf(p)
% Load data and define params.
good_subs = load([p.PROC_DATA_FOLDER '/good_subs_' p.DAY '_target_x_to_subs_' p.SUBS_STRING '.mat']);  good_subs = good_subs.good_subs;
trim_len = load([p.PROC_DATA_FOLDER '/trim_len.mat']);  trim_len = trim_len.trim_len; % In samples.
timecourse = (0 : trim_len-1) * p.REF_RATE_SEC * 1000; % Time of each sample (ms).
% -------- User defined --------
vel_threshs = 0: 0.05 : 1.5; % Thresholds, will calc num trials with velocity lower than each threshold(m/s).
win_len = 50; % Time window (ms).
win_bounds = win_len : win_len : trim_len * p.REF_RATE_SEC * 1000;

% Concatenate all trials.
all_vel = NaN(trim_len, p.NUM_TRIALS * length(good_subs));
last_data = 0;
for iSub = good_subs
    vel_mat = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_sorted_trials_target_x_to.mat']);  vel_mat = vel_mat.r_trial.vel;
    vel_mat = [vel_mat.con, vel_mat.incon];
    all_vel(:, last_data+1 : last_data+size(vel_mat,2)) = vel_mat;
    last_data = last_data+size(vel_mat,2);
end
all_vel(:, last_data+1 : end) = [];

% Build distributions
vel_dist = array2table(NaN(length(vel_threshs), length(win_bounds)),...
    'RowNames',strcat("vel",string(vel_threshs)),...
    'VariableNames',strcat("win",string(win_bounds)));
for iThresh = 1:length(vel_threshs)
    win_start = 1;
    iWin = 1;
    for window_end = win_bounds
        % Samples that fall within window.
        in_win = timecourse > win_start & timecourse <= window_end;
        % Vel in this time window that is lower than thresh.
        below_thresh = all_vel(in_win, :) > vel_threshs(iThresh);
        % Percentage of trials.
        vel_dist(iThresh, iWin) = array2table(mean(any(below_thresh, 1)));
        iWin = iWin + 1;
        win_start = window_end;
    end
end