% Calc maximum absolute deviation (from line between start and end points) for each trial
% and assignes to new column in data table.
% We find the point furthest away from the line connecting the start and end points,
% and calc its distance from that line.
function data_table = calcMAD(traj_table, prenorm_traj_table, data_table, traj_name, p)
    traj_len = load([p.PROC_DATA_FOLDER '/trim_len.mat']);  traj_len = traj_len.trim_len;
    mad_col   = [strrep(traj_name{1}, '_x','') '_mad'];
    mad_p_col = [strrep(traj_name{1}, '_x','') '_mad_p'];
    
    mad = NaN(p.NUM_TRIALS, 1); % Max abd dev.
    mad_p = NaN(p.NUM_TRIALS, 3); % Maximally deviating point.
    
    traj = traj_table{:, traj_name};
    prenorm_traj = prenorm_traj_table{:, traj_name};
    % Reshape to convenient format.
    traj_mat = reshape(traj, traj_len, p.NUM_TRIALS, 3); % 3 for (x,y,z).
    prenorm_traj_mat = reshape(prenorm_traj, p.REACH_MAX_RT_LIMIT, p.NUM_TRIALS, 3); % 3 for (x,y,z).
    
    for iTrial = 1:p.NUM_TRIALS
        last_sample = find(~isnan(prenorm_traj_mat(:,iTrial,1)), 1,'last');
        % Find start and end points.
        start_p = traj_mat(1, iTrial, :);
        end_p   = traj_mat(traj_len, iTrial, :);
        if ~p.NORM_TRAJ % Use actual last sample, before traj was trimmed.
            end_p = prenorm_traj_mat(last_sample, iTrial, :);
        end
        % Absolute deviation of each point along traj.
        start_p = repmat(start_p, traj_len,1);
        end_p = repmat(end_p, traj_len,1);
        a = start_p - end_p;
        b = traj_mat(:, iTrial, :) - end_p;
        abs_dev = sqrt(sum(cross(a,b,3).^2,3)) ./ sqrt(sum(a.^2,3));
        [mad(iTrial) index] = max(abs_dev);
        mad_p(iTrial,:) = squeeze(traj_mat(index, iTrial, :))';
    end
    data_table.(mad_col) = mad;
    data_table.(mad_p_col) = mad_p;
end