% Format reach area to R dataframe.
% Reach area is calc on avg traj, but we need single trials to perform Linear mixed model,
% so we bootstrap: resmaple N trials and calc avg traj, we do this M times.
% N = min_amnt, M = iter.
% Output:
%   Columns: sub, condition, reach area, num_trials.
%   Rows: one for each combination of sub and condition.
% Input:
%   iter = number of bootstrap iterations.
function [r_a_df] = fReachArea(traj_name, iter, p)
% Get bad subs.
bad_subs = load([p.PROC_DATA_FOLDER '/bad_subs_' p.DAY '_' traj_name{1} '_subs_' p.SUBS_STRING '.mat'], 'bad_subs');  bad_subs = bad_subs.bad_subs;
bad_subs = find(bad_subs.any);
subs = p.SUBS(~ismember(p.SUBS, bad_subs));
% Find sub with least trials.
num_trials = load([p.PROC_DATA_FOLDER '/num_trials_' p.DAY '_' traj_name{1} '_subs_' p.SUBS_STRING '.mat'], 'num_trials');  num_trials = num_trials.num_trials;
num_trials = cell2mat(struct2cell(num_trials)');
num_trials(bad_subs, :) = [];
min_amnt = min(num_trials,[], 'all');
% Build dataframe.
num_rows = length(subs) * p.N_CONDS * iter;
columns = ["sub", "cond", "reach_area"];
r_a_df = table('Size',[num_rows length(columns)], 'VariableTypes',{'double','string','double'} , 'VariableNames',columns);

% Fill table with goods.
disp('Formatted reach area for sub: ');
j = 1;
for iSub = subs
    % Load sub data.
    sub_trajs = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_' 'sorted_trials_' traj_name{1} '.mat']); sub_trajs = sub_trajs.single.trajs;
    for cond = p.CONDS
        % Get trajs of this cond.
        left_trajs = sub_trajs.(strcat(cond,'_','left'));
        right_trajs = sub_trajs.(strcat(cond,'_','right'));
        % Resample trajs and calc 'iter' avg trajectories.
        for iter = 1:iter
            % Sample traj and avg.
            left_avg = mean(datasample(left_trajs, min_amnt, 2), 2);
            right_avg = mean(datasample(right_trajs, min_amnt, 2), 2);
            % Calc area.
            reach_area = calcReachArea(left_avg, right_avg);
            if reach_area > 15
                error('Reach area is too big, check for error in analysis.');
            end
            r_a_df(j,:) = table(iSub, cond, reach_area); % has to match columns!
            j = j+1;
        end
    end
    disp(iSub);
end

disp("You converted Z coordinates to % of path traveled. This increased Reach area, so you had to cancel the check you put in fReachArea: if reach_area > 1.");
disp("Establish a new limit and update that maximum thrshold.");
%{
% This uses a single sample (avg traj) for each sub, instead of generating many avgs with bootstrap. %
% Reach are column.
reach_area = load([p.PROC_DATA_FOLDER strrep(traj_name{1}, '_x','') '_'  p.DAY '_reach_area.mat']); reach_area = reach_area.reach_area;
reach_area.same(isnan(reach_area.same)) = [];
reach_area.diff(isnan(reach_area.diff)) = [];
reach_area = [reach_area.same reach_area.diff]';
% Sub num column.
sub = repmat(p.SUBS', p.N_CONDS,1);
% Cond column.
cond = repelem(p.CONDS', p.N_SUBS);
% Num trials column.
num_trials = load([p.PROC_DATA_FOLDER '/num_trials_' p.DAY '_' traj_name{1} '_subs_' p.SUBS_STRING '.mat'], 'num_trials');  num_trials = num_trials.num_trials;
n_trials.same = num_trials.same_left + num_trials.same_right;
n_trials.diff = num_trials.diff_left + num_trials.diff_right;
n_trials.same(isnan(n_trials.same)) = [];
n_trials.diff(isnan(n_trials.diff)) = [];
n_trials = [n_trials.same; n_trials.diff];
% Reach area dataframe.
r_a_df = table(sub,cond,reach_area,n_trials);
%}
end