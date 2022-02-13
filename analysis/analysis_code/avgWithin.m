% Averages only good trials.
% pas_rate - double, only trials with this pas rating will be averaged.
% avg - structure, each field is avg of one condition. Average of all the good trias that had "pas_rate".
% single - struct, each field contains one condition's trials, that were good and had "pas_rate".
function [avg, single] = avgWithin(iSub, traj_name, bad_trials, pas_rate, p)
    % Get sub data.
    traj_table = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_' 'traj_proc.mat']);  traj_table = traj_table.traj_table;
    data_table = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_' 'data_proc.mat']);  data_table = data_table.data_table;

    % remove practice.
    traj_table(traj_table{:,'practice'} >= 1, :) = [];
    data_table(data_table{:,'practice'} >= 1, :) = [];

    traj = traj_table{:, traj_name};
    % Reshape to convenient format.
    traj_mat = reshape(traj, p.NORM_FRAMES, p.NUM_TRIALS, 3); % 3 for (x,y,z).
    % Column names in tables.
    reach_dir_col   = regexprep(traj_name{1}, '_x_.+', '_ans_left'); % name of traj's ans_left column.
    rt_col          = regexprep(traj_name{1}, '_x_.+', '_rt'); % name of traj's rt column.
    onset_col   = [strrep(traj_name{1}, '_x',''), '_onset'];
    offset_col  = [strrep(traj_name{1}, '_x',''), '_offset'];
    mad_col     = [strrep(traj_name{1}, '_x',''), '_mad'];
    mad_p_col   = [strrep(traj_name{1}, '_x',''), '_mad_p'];
    % Trial types.
    bad = bad_trials{iSub}.any;
    bad_timing_or_quit = bad_trials{iSub}.bad_stim_dur | bad_trials{iSub}.quit;
    pas = data_table.('pas')==pas_rate;
    same = data_table.('same');
    left = data_table.(reach_dir_col);
    % Sort trials and calc avg.
    single.trajs.same_left  = traj_mat(:, ~bad & pas & same  & left, :);
    single.trajs.same_right = traj_mat(:, ~bad & pas & same  & ~left, :);
    single.trajs.diff_left  = traj_mat(:, ~bad & pas & ~same & left, :);
    single.trajs.diff_right = traj_mat(:, ~bad & pas & ~same & ~left, :);
    single.rt.same_left  = data_table.(offset_col)(~bad & pas & same  & left);
    single.rt.same_right = data_table.(offset_col)(~bad & pas & same  & ~left);
    single.rt.diff_left  = data_table.(offset_col)(~bad & pas & ~same & left);
    single.rt.diff_right = data_table.(offset_col)(~bad & pas & ~same & ~left);
    single.react.same_left  = data_table.(onset_col)(~bad & pas & same  & left); % Reaction time.
    single.react.same_right = data_table.(onset_col)(~bad & pas & same  & ~left);
    single.react.diff_left  = data_table.(onset_col)(~bad & pas & ~same & left);
    single.react.diff_right = data_table.(onset_col)(~bad & pas & ~same & ~left);
    single.mt.same_left  = single.rt.same_left  - single.react.same_left; % Movement time.
    single.mt.same_right = single.rt.same_right - single.react.same_right;
    single.mt.diff_left  = single.rt.diff_left  - single.react.diff_left;
    single.mt.diff_right = single.rt.diff_right - single.react.diff_right;
    single.fc_prime.same = data_table.prime_correct(~bad_timing_or_quit & pas & same); % forced choice.
    single.fc_prime.diff = data_table.prime_correct(~bad_timing_or_quit & pas & ~same);
    single.pas.same = data_table.pas(~bad & same);
    single.pas.diff = data_table.pas(~bad & ~same);
    single.mad.same_left  = data_table.(mad_col)(~bad & pas & same  & left); % Maximum absolute deviation.
    single.mad.same_right = data_table.(mad_col)(~bad & pas & same  & ~left);
    single.mad.diff_left  = data_table.(mad_col)(~bad & pas & ~same & left);
    single.mad.diff_right = data_table.(mad_col)(~bad & pas & ~same & ~left);
    single.mad_p.same_left  = data_table.(mad_p_col)(~bad & pas & same  & left, :); % Maximally deviating point.
    single.mad_p.same_right = data_table.(mad_p_col)(~bad & pas & same  & ~left, :);
    single.mad_p.diff_left  = data_table.(mad_p_col)(~bad & pas & ~same & left, :);
    single.mad_p.diff_right = data_table.(mad_p_col)(~bad & pas & ~same & ~left, :);
    % Average.
    avg.traj.same_left   = squeeze(mean(single.trajs.same_left , 2));
    avg.traj.same_right  = squeeze(mean(single.trajs.same_right, 2));
    avg.traj.diff_left   = squeeze(mean(single.trajs.diff_left , 2));
    avg.traj.diff_right  = squeeze(mean(single.trajs.diff_right, 2));
    avg.rt.same_left     = mean(single.rt.same_left);
    avg.rt.same_right    = mean(single.rt.same_right);
    avg.rt.diff_left     = mean(single.rt.diff_left);
    avg.rt.diff_right    = mean(single.rt.diff_right);
    avg.react.same_left  = mean(single.react.same_left);
    avg.react.same_right = mean(single.react.same_right);
    avg.react.diff_left  = mean(single.react.diff_left);
    avg.react.diff_right = mean(single.react.diff_right);
    avg.mt.same_left     = mean(single.mt.same_left);
    avg.mt.same_right    = mean(single.mt.same_right);
    avg.mt.diff_left     = mean(single.mt.diff_left);
    avg.mt.diff_right    = mean(single.mt.diff_right);
    avg.fc_prime.same    = mean(single.fc_prime.same);
    avg.fc_prime.diff    = mean(single.fc_prime.diff);
    avg.mad.same_left    = mean(single.mad.same_left);
    avg.mad.same_right   = mean(single.mad.same_right);
    avg.mad.diff_left    = mean(single.mad.diff_left);
    avg.mad.diff_right   = mean(single.mad.diff_right);
    avg.mad_p.same_left  = mean(single.mad_p.same_left, 1);
    avg.mad_p.same_right = mean(single.mad_p.same_right, 1);
    avg.mad_p.diff_left  = mean(single.mad_p.diff_left, 1);
    avg.mad_p.diff_right = mean(single.mad_p.diff_right, 1);
    avg.x_std.same_left  = std(single.trajs.same_left (:,:,1), 0, 2); % std between trials.
    avg.x_std.same_right = std(single.trajs.same_right(:,:,1), 0, 2);
    avg.x_std.diff_left  = std(single.trajs.diff_left (:,:,1), 0, 2);
    avg.x_std.diff_right = std(single.trajs.diff_right(:,:,1), 0, 2);
    avg.x_avg_std.same_left  = mean(avg.x_std.same_left); % avg across time. one value for whole traj.
    avg.x_avg_std.same_right = mean(avg.x_std.same_right);
    avg.x_avg_std.diff_left  = mean(avg.x_std.diff_left);
    avg.x_avg_std.diff_right = mean(avg.x_std.diff_right);
    avg.cond_diff.left  = avg.traj.same_left  - avg.traj.diff_left;
    avg.cond_diff.right = avg.traj.same_right - avg.traj.diff_right;
    % Count pas ratings.
    for i = 1:4
        avg.pas.same(i) = sum(single.pas.same == i); 
        avg.pas.diff(i) = sum(single.pas.diff == i);
    end
end