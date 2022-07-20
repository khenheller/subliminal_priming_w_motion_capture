% Calc the total distance traveled (in the x and z axis) in each trial.
function [data_table] = calcTotDistTravel(traj_table, data_table, p)

    data_table.tot_dist_trav = cell(p.NUM_TRIALS,1);

    % Reshape to convinient format.
    trajs = traj_table{:,{'target_x_to', 'target_y_to', 'target_z_to'}};
    traj_mat = reshape(trajs, p.NORM_FRAMES, p.NUM_TRIALS, 3);

    for iTrial = 1:height(data_table)
        traj = squeeze(traj_mat(:, iTrial, :));
        % The change (delta) in X and in Z between adjacent points.
        delta = (traj(2:end, [1,3]) - traj(1:end-1, [1,3]));
        dist_between_points = sqrt(sum(delta.^2, 2));
        % Sum distances.
        data_table.tot_dist_trav{iTrial} = sum(dist_between_points);
    end
end