% Format reach area to R dataframe.
% Output:
% Columns: sub, condition, reach area, num_trials.
% Rows: one for each combination of sub and condition.
function [r_a_df] = fReachArea(traj_name, p)
    % Reach are column.
    reach_area = load([p.PROC_DATA_FOLDER strrep(traj_name{1}, '_x','') '_reach_area.mat']); reach_area = reach_area.reach_area;
    reach_area.same(isnan(reach_area.same)) = [];
    reach_area.diff(isnan(reach_area.diff)) = [];
    reach_area = [reach_area.same reach_area.diff]';
    % Sub num column.
    sub_num = repmat(p.SUBS', p.N_COND,1);
    % Cond column.
    cond = repelem(p.CONDS', p.N_SUBS);
    % Num trials column.
    num_trials = load([p.PROC_DATA_FOLDER '/num_trials_' p.DAY '_' traj_name{1} '.mat'], 'num_trials');  num_trials = num_trials.num_trials;
    n_trials.same = num_trials.same_left + num_trials.same_right;
    n_trials.diff = num_trials.diff_left + num_trials.diff_right;
    n_trials.same(isnan(n_trials.same)) = [];
    n_trials.diff(isnan(n_trials.diff)) = [];
    n_trials = [n_trials.same; n_trials.diff];
    % Reach area dataframe.
    r_a_df = table(sub_num,cond,reach_area,n_trials);
end