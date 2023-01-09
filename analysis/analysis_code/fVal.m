% Format a variable to R dataframe.
% var_name - name of variable to format, as it appears in avg_each table that is created in the analysis.m-->plotting params.
% measure - 'keyboard','reach'.
% data_type - 'time_series' (multiple values per trial), 'regular' (single value per trial).
% iSamp - sample index in trajectory, relevent only for time-series data.
% Output:
%   Columns: sub, side, condition, variable.
%   Rows: average under each condition.
function [var_df] = fVal(var_name, measure, data_type, iSamp, p)
% Build dataframe.
num_rows = p.N_SUBS * 2 * p.N_CONDS; % 2=left/right.
columns = ["sub", "side", "cond", var_name];
var_df = table('size',[num_rows length(columns)], 'VariableTypes',{'double','string','string','double'}, 'VariableNames',columns);

% Load subs data.
var = load([p.PROC_DATA_FOLDER '/avg_each_' p.DAY '_target_x_to_subs_' p.SUBS_STRING '.mat']);  var = var.([measure, '_avg_each']).(var_name);
good_subs = load([p.PROC_DATA_FOLDER '/good_subs_' p.DAY '_target_x_to_subs_' p.SUBS_STRING '.mat']);  good_subs = good_subs.good_subs;

% Prep table columns.
if isequal(data_type, 'time_series')
    var_col = [var.con_left(iSamp,good_subs,1)';...
                var.con_right(iSamp,good_subs,1)';...
                var.incon_left(iSamp,good_subs,1)';...
                var.incon_right(iSamp,good_subs,1)'];
    % Change var name.
    var_df.Properties.VariableNames{var_name} = [var_name, num2str(iSamp)];
else
    var_col = [var.con_left(good_subs)';...
                var.con_right(good_subs)';...
                var.incon_left(good_subs)';...
                var.incon_right(good_subs)'];
end
sub_col = repmat(good_subs', 4, 1); % 4=one for each condition and side combination.
side_col = repmat(repelem(["left"; "right"], length(good_subs)), 2, 1); % 2=one for each condition.
cond_col = repelem(p.CONDS', length(good_subs)*2); % 2=left/right.
% Fill table with goods.
var_df = table(sub_col, side_col, cond_col, var_col, 'VariableNames',var_df.Properties.VariableNames);