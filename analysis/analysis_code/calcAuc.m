% Calc Area Under the Curve (AUC) for each trial of a single sub.
% Includes only area centrally to the optimal path.
function [data_table] = calcAuc(traj_table, data_table, prenorm_traj_table, p)
    traj_len = load([p.PROC_DATA_FOLDER '/trim_len.mat']);  traj_len = traj_len.trim_len;
    data_table.auc = cell(p.NUM_TRIALS,1);
    auc = NaN(p.NUM_TRIALS,1);

    % Reshape to convinient format.
    trajs = traj_table{:,{'target_x_to', 'target_y_to', 'target_z_to'}};
    prenorm_trajs = prenorm_traj_table{:,{'target_x_to', 'target_y_to', 'target_z_to'}};
    traj_mat = reshape(trajs, traj_len, p.NUM_TRIALS, 3);
    prenorm_traj_mat = reshape(prenorm_trajs, p.REACH_MAX_RT_LIMIT, p.NUM_TRIALS, 3);

    for iTrial = 1:height(data_table)
        traj = squeeze(traj_mat(:, iTrial, :));
        prenorm_traj = squeeze(prenorm_traj_mat(:, iTrial, :));
        % Exclude trials with nans.
        if ~any(isnan(traj))
            if size(traj,1) ~= traj_len
                error('Traj is expected to be normalized, So good trajs shouldnt have nans. All trajs with nans were excluded here.')
            end
            % When not normalized, take last point from traj *before trimming*.
            last_sample = find(~isnan(prenorm_traj(:,1)), 1,'last');
            if ~p.NORM_TRAJ
                last_point = prenorm_traj(last_sample, :);
            else
                last_point = traj(end, :);
            end
            % Create 'optimal path' line, beginning to screen touch.
            z_vals = [traj(1, 3), last_point(3)];
            x_vals = [traj(1, 1), last_point(1)];
            interp_x = interp1(z_vals, x_vals, traj(:, 3), 'linear', 'extrap'); % Add points parllel to those in traj.
            opt_path_x_vals = interp_x;
            opt_path_z_vals = [traj(:,3)];
            opt_path = [opt_path_x_vals, NaN(traj_len,1), opt_path_z_vals];
            % Relation between start and end points.
            start_pnt_smaller = opt_path(1,1) < opt_path(end,1);
            % Keep only traj x vals that have the same relation to the optimal path,
            % as the relation between the start and end points.
            % So keep only those central to the optimal path.
            if start_pnt_smaller
                pnts_to_keep = traj(:,1) < opt_path(:,1);
            else
                pnts_to_keep = traj(:,1) > opt_path(:,1);
            end
            % Pnts lateral to optimal path get its x values.
            traj(~pnts_to_keep, 1) = opt_path(~pnts_to_keep, 1);
            % Calc area between optimal path and traj.
            auc(iTrial) = calcReachArea(traj, opt_path, p);
        end
    end
    data_table.auc = auc;
end