% Averages only good trials.
% pas_rate - double, only trials with this pas rating will be averaged.
% avg - structure, each field is avg of one condition. Average of all the good trias that had "pas_rate".
% single - struct, each field contains one condition's trials, that were good and had "pas_rate".
function [avg, single] = avgWithin(iSub, traj_name, bad_trials, pas_rate, p)
    % Get sub data.
    traj_table = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) 'traj_proc.mat']);  traj_table = traj_table.traj_table;
    data_table = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) 'data.mat']);  data_table = data_table.data_table;

    % remove practice.
    traj_table(traj_table{:,'practice'} == 1, :) = [];
    data_table(data_table{:,'practice'} == 1, :) = [];

    traj = traj_table{:, traj_name};
    % Reshape to convenient format.
    traj_mat = reshape(traj, p.NORM_FRAMES, p.NUM_TRIALS, 3); % 3 for (x,y,z).
    % Trial types.
    reach_dir_col = regexprep(traj_name{1}, '_x_.+', '_ans_left'); % name of traj's ans_left column.
    rt_col = regexprep(traj_name{1}, '_x_.+', '_rt'); % name of traj's rt column.
    bad = bad_trials{iSub}.any;
    pas = data_table.('pas')==pas_rate;
    same = data_table.('same');
    left = data_table.(reach_dir_col);
    % Sort trials.
    single.trajs.same_left  = traj_mat(:, ~bad & pas & same  & left, :);
    single.trajs.same_right = traj_mat(:, ~bad & pas & same  & ~left, :);
    single.trajs.diff_left  = traj_mat(:, ~bad & pas & ~same & left, :);
    single.trajs.diff_right = traj_mat(:, ~bad & pas & ~same & ~left, :);
    single.rt.same_left  = data_table.(rt_col)(~bad & pas & same  & left);
    single.rt.same_right = data_table.(rt_col)(~bad & pas & same  & ~left);
    single.rt.diff_left  = data_table.(rt_col)(~bad & pas & ~same & left);
    single.rt.diff_right = data_table.(rt_col)(~bad & pas & ~same & ~left);
    single.fc.same = data_table.prime_correct(~bad & pas & same); % forced choice.
    single.fc.diff = data_table.prime_correct(~bad & pas & ~same);
    % Average.
    avg.traj.same_left  = squeeze(mean(single.trajs.same_left , 2));
    avg.traj.same_right = squeeze(mean(single.trajs.same_right, 2));
    avg.traj.diff_left  = squeeze(mean(single.trajs.diff_left , 2));
    avg.traj.diff_right = squeeze(mean(single.trajs.diff_right, 2));
    avg.rt.same_left  = mean(single.rt.same_left);
    avg.rt.same_right = mean(single.rt.same_right);
    avg.rt.diff_left  = mean(single.rt.diff_left);
    avg.rt.diff_right = mean(single.rt.diff_right);
    avg.fc.same = mean(single.fc.same);
    avg.fc.diff = mean(single.fc.diff);
end