% Iterates over all subs trajs and finds the shortest one that is longer than a certain threshold.
% It will be used as a common length to which all trajs will be trimmed.
function min_len = getMinLength(traj_name, p)
    min_len = NaN(p.MAX_SUB, 1);
    for iSub = p.SUBS
        % Load data.
        pre_norm_traj_table = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_reach_pre_norm_traj.mat'], 'reach_pre_norm_traj_table');  pre_norm_traj_table = pre_norm_traj_table.reach_pre_norm_traj_table;
        % Trajs of interest.
        trajs = pre_norm_traj_table{:, traj_name};
        % Reshape to convinient format.
        traj_mat = reshape(trajs, p.MAX_CAP_LENGTH, p.NUM_TRIALS, 3); % 3 for (x,y,z).

        % Traj lengths.
        lengths = NaN(size(traj_mat, 2), 1);
        for iTraj = 1:size(traj_mat, 2)
            lengths(iTraj) = find(~isnan(traj_mat(:,iTraj,1)), 1, 'last');
        end
        % Exclude trajs shorter than threshold.
        lengths(lengths < p.MIN_TRIM_FRAMES) = [];
        min_len(iSub) = min(lengths);
    end
    min_len = min(min_len);
end