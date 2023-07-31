% Adds following fields to sub data:
%   late_res - sub started moving late.
%   slow_mvmnt - sub's mvmnt was slow.
%   early_res - sub started movign too early = predidctive mvmnt.
% Input:
%   trials_table - trails table. Each row is a trial, each column is var.
%   trajs_table - trajectories table. multiple rows per trial, column are vars.
function [trials_table] = addFields(trials_table, trajs_table, p)
    % Add columns.
    trials_table.late_res = nan(height(trials_table), 1);
    trials_table.slow_mvmnt = nan(height(trials_table), 1);
    trials_table.early_res = nan(height(trials_table), 1);
    
    % Get target trajs.
    trajs_names = regexp(p.MULTI_ROW_VARS, 'target_\w_to', 'match');
    trajs_names = [trajs_names{:}];
    trajs = trajs_table{:, trajs_names};
    timecourses = trajs_table{:, 'target_timecourse_to'};
    % Reshape to convinient format.
    traj_length = find(trajs_table.iTrial == 2, 1) - 1;
    trajs_mat = reshape(trajs, traj_length, height(trials_table), 3);
    timecourse_mat = reshape(timecourses, traj_length, height(trials_table));
    
    for j = 1:height(trials_table)
        % Get current trial's data.
        traj = squeeze(trajs_mat(:, j, :));
        timecourse = timecourse_mat(:, j);
        % Distance from start in every point in traj.
        distance = sqrt(sum((traj - p.START_POINT).^2, 2));
        
        % Find time of leaving start point.
        mvmnt_strt = find(distance > p.START_POINT_RANGE, 1);
        mvmnt_end = find(~isnan(traj(:,1)), 1, 'last');
        react_time = mvmnt_strt;
        mvmnt_time = mvmnt_end - mvmnt_strt;
        % Check if sub didn't move.
        if isempty(mvmnt_strt)
            react_time = mvmnt_end;
            mvmnt_time = 0;
        end
        % Update late res, slow mvmnt and early response.
        trials_table{j, 'late_res'} = react_time > p.REACT_TIME_SAMPLES;
        trials_table{j, 'slow_mvmnt'} = mvmnt_time >= p.MOVE_TIME_SAMPLES;
        trials_table{j, 'early_res'} = react_time <= p.MIN_REACT_TIME_SAMPLES;
        % If sub responded too late, he didn't start moving, so his mvmnt couldn't be slow.
        trials_table{j, 'slow_mvmnt'} = trials_table{j, 'slow_mvmnt'} & ~trials_table{j, 'late_res'};
    end
end