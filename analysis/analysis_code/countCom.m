% Counts the number of Changes Of Minf (COM) in each trial.
% COM happens when the subject changes his implied endpoint from
% one side of the screen to the other.
function data_table = countCom(traj_table, data_table, p)
    traj_len = load([p.PROC_DATA_FOLDER '/trim_len.mat']);  traj_len = traj_len.trim_len;
    assert(any(contains(traj_table.Properties.VariableNames, 'head_angle')), "Run heading angle section before COM section");

    % Name of COM column in data_table.
    com_col = 'com';

    com = NaN(p.NUM_TRIALS,1);

    % Reshape to convinient format.
    iep = traj_table{:,'iep'};
    iep_mat = reshape(iep, traj_len, p.NUM_TRIALS); % X values of iEP.

    for iTrial = 1:height(data_table)
        % Find all negative angles.
        neg_angle = iep_mat(:, iTrial) < 0;
        neg_angle(1) = neg_angle(2); % There is no angle at first sample, so there is no change from first to second sample.
        % Find changes in sign.
        num_com = length(find(diff(neg_angle)));
        com(iTrial) = num_com;
    end

    data_table.com = com;
end