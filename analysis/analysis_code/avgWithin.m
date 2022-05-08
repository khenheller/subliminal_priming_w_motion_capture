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
    con = data_table.('con');
    left = data_table.(reach_dir_col);
    % Sort trials and calc avg.
    single.trajs.con_left  = traj_mat(:, ~bad & pas & con  & left, :);
    single.trajs.con_right = traj_mat(:, ~bad & pas & con  & ~left, :);
    single.trajs.incon_left  = traj_mat(:, ~bad & pas & ~con & left, :);
    single.trajs.incon_right = traj_mat(:, ~bad & pas & ~con & ~left, :);
    single.rt.con_left  = data_table.(offset_col)(~bad & pas & con  & left);
    single.rt.con_right = data_table.(offset_col)(~bad & pas & con  & ~left);
    single.rt.incon_left  = data_table.(offset_col)(~bad & pas & ~con & left);
    single.rt.incon_right = data_table.(offset_col)(~bad & pas & ~con & ~left);
    single.react.con_left  = data_table.(onset_col)(~bad & pas & con  & left); % Reaction time.
    single.react.con_right = data_table.(onset_col)(~bad & pas & con  & ~left);
    single.react.incon_left  = data_table.(onset_col)(~bad & pas & ~con & left);
    single.react.incon_right = data_table.(onset_col)(~bad & pas & ~con & ~left);
    single.mt.con_left  = single.rt.con_left  - single.react.con_left; % Movement time.
    single.mt.con_right = single.rt.con_right - single.react.con_right;
    single.mt.incon_left  = single.rt.incon_left  - single.react.incon_left;
    single.mt.incon_right = single.rt.incon_right - single.react.incon_right;
    single.fc_prime.con = data_table.prime_correct(~bad_timing_or_quit & pas & con); % forced choice.
    single.fc_prime.incon = data_table.prime_correct(~bad_timing_or_quit & pas & ~con);
    single.pas.con = data_table.pas(~bad & con);
    single.pas.incon = data_table.pas(~bad & ~con);
    single.mad.con_left  = data_table.(mad_col)(~bad & pas & con  & left); % Maximum absolute deviation.
    single.mad.con_right = data_table.(mad_col)(~bad & pas & con  & ~left);
    single.mad.incon_left  = data_table.(mad_col)(~bad & pas & ~con & left);
    single.mad.incon_right = data_table.(mad_col)(~bad & pas & ~con & ~left);
    single.mad_p.con_left  = data_table.(mad_p_col)(~bad & pas & con  & left, :); % Maximally deviating point.
    single.mad_p.con_right = data_table.(mad_p_col)(~bad & pas & con  & ~left, :);
    single.mad_p.incon_left  = data_table.(mad_p_col)(~bad & pas & ~con & left, :);
    single.mad_p.incon_right = data_table.(mad_p_col)(~bad & pas & ~con & ~left, :);
    % Average.
    avg.traj.con_left   = squeeze(mean(single.trajs.con_left , 2));
    avg.traj.con_right  = squeeze(mean(single.trajs.con_right, 2));
    avg.traj.incon_left   = squeeze(mean(single.trajs.incon_left , 2));
    avg.traj.incon_right  = squeeze(mean(single.trajs.incon_right, 2));
    avg.rt.con_left     = mean(single.rt.con_left);
    avg.rt.con_right    = mean(single.rt.con_right);
    avg.rt.incon_left     = mean(single.rt.incon_left);
    avg.rt.incon_right    = mean(single.rt.incon_right);
    avg.react.con_left  = mean(single.react.con_left);
    avg.react.con_right = mean(single.react.con_right);
    avg.react.incon_left  = mean(single.react.incon_left);
    avg.react.incon_right = mean(single.react.incon_right);
    avg.mt.con_left     = mean(single.mt.con_left);
    avg.mt.con_right    = mean(single.mt.con_right);
    avg.mt.incon_left     = mean(single.mt.incon_left);
    avg.mt.incon_right    = mean(single.mt.incon_right);
    avg.fc_prime.con    = mean(single.fc_prime.con);
    avg.fc_prime.incon    = mean(single.fc_prime.incon);
    avg.mad.con_left    = mean(single.mad.con_left);
    avg.mad.con_right   = mean(single.mad.con_right);
    avg.mad.incon_left    = mean(single.mad.incon_left);
    avg.mad.incon_right   = mean(single.mad.incon_right);
    avg.mad_p.con_left  = mean(single.mad_p.con_left, 1);
    avg.mad_p.con_right = mean(single.mad_p.con_right, 1);
    avg.mad_p.incon_left  = mean(single.mad_p.incon_left, 1);
    avg.mad_p.incon_right = mean(single.mad_p.incon_right, 1);
    avg.x_std.con_left  = std(single.trajs.con_left (:,:,1), 0, 2); % std between trials.
    avg.x_std.con_right = std(single.trajs.con_right(:,:,1), 0, 2);
    avg.x_std.incon_left  = std(single.trajs.incon_left (:,:,1), 0, 2);
    avg.x_std.incon_right = std(single.trajs.incon_right(:,:,1), 0, 2);
    avg.x_avg_std.con_left  = mean(avg.x_std.con_left); % avg across time. one value for whole traj.
    avg.x_avg_std.con_right = mean(avg.x_std.con_right);
    avg.x_avg_std.incon_left  = mean(avg.x_std.incon_left);
    avg.x_avg_std.incon_right = mean(avg.x_std.incon_right);
    avg.cond_diff.left  = avg.traj.con_left  - avg.traj.incon_left;
    avg.cond_diff.right = avg.traj.con_right - avg.traj.incon_right;
    % Count pas ratings.
    for i = 1:4
        avg.pas.con(i) = sum(single.pas.con == i); 
        avg.pas.incon(i) = sum(single.pas.incon == i);
    end
end