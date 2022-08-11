% Format reach areato R dataframe.
% Output:
%   Columns: sub, condition, reach area.
%   Rows: average under each condition.
function [ra_df] = fReachArea(traj_name, p)
% Build dataframe.
num_rows = p.N_SUBS * 2 * p.N_CONDS; % 2=left/right.
columns = ["sub", "cond", "ra"];
ra_df = table('size',[num_rows length(columns)], 'VariableTypes',{'double','string','double'}, 'VariableNames',columns);

% Load subs data.
ra = load([p.PROC_DATA_FOLDER '/avg_each_' p.DAY '_' traj_name '_subs_' p.SUBS_STRING '.mat']);  ra = ra.reach_avg_each.ra;
good_subs = load([p.PROC_DATA_FOLDER '/good_subs_' p.DAY '_' traj_name '_subs_' p.SUBS_STRING '.mat']);  good_subs = good_subs.good_subs;

% Prep table columns.
var_col = [ra.con(good_subs)';...
    ra.incon(good_subs)'];
sub_col = repmat(good_subs', 2, 1); % 2=one for each condition.
cond_col = repelem(p.CONDS', length(good_subs));
% Fill table with goods.
ra_df = table(sub_col, cond_col, var_col, 'VariableNames',ra_df.Properties.VariableNames);