% Format a variable with a multiple values for each trial to R dataframe.
% var_name - name of variable to format, as it appears in avg_each table that is created in the analysis.m-->plotting params.
% Output:
%   Columns: sub, side, condition, Proportion of path traveled, variable.
%   Rows: average under each condition.
function [var_df] = fMultiVal(var_name, traj_name, p)
traj_len = load([p.PROC_DATA_FOLDER '/trim_len.mat']);  traj_len = traj_len.trim_len;
% Load subs data.
var = load([p.PROC_DATA_FOLDER '/avg_each_' p.DAY '_' traj_name '_subs_' p.SUBS_STRING '.mat']);  var = var.reach_avg_each.(var_name);
good_subs = load([p.PROC_DATA_FOLDER '/good_subs_' p.DAY '_' traj_name '_subs_' p.SUBS_STRING '.mat']);  good_subs = good_subs.good_subs;

% IF var is traj, keep only X values.
if isequal(var_name, 'traj')
    var.con_left = var.con_left(:,:,1);
    var.con_right = var.con_right(:,:,1);
    var.incon_left = var.incon_left(:,:,1);
    var.incon_right = var.incon_right(:,:,1);
    var_name = 'x';
end

% Build dataframe.
num_rows = p.N_SUBS * 2 * p.N_CONDS; % 2=left/right.
columns = ["sub", "side", "cond", "z_pos", var_name];
var_df = table('size',[num_rows length(columns)], 'VariableTypes',{'double','string','string','double', 'double'}, 'VariableNames',columns);

% Prep table columns.
num_values = size(var.con_left, 1);
con_left_data = reshape(var.con_left(:, good_subs), num_values * length(good_subs), 1);
con_right_data = reshape(var.con_right(:, good_subs), num_values * length(good_subs), 1);
incon_left_data = reshape(var.incon_left(:, good_subs), num_values * length(good_subs), 1);
incon_right_data = reshape(var.incon_right(:, good_subs), num_values * length(good_subs), 1);
var_col = [con_left_data; con_right_data; incon_left_data; incon_right_data];
sub_col = repmat(repelem(good_subs', num_values), 4, 1); % 4=one for each condition and side combination.
side_col = repmat(repelem(["left"; "right"], num_values * length(good_subs)), 2, 1); % 2=one for each condition.
cond_col = repelem(p.CONDS', num_values * length(good_subs) * 2); % 2=left/right
z_pos_col = repmat([0.5 : 100/traj_len : 100]', length(good_subs)*4, 1); % 4=one for each condition and side combination.

% Fill table with goods.
var_df = table(sub_col, side_col, cond_col, z_pos_col, var_col, 'VariableNames',var_df.Properties.VariableNames);