% Counts the number of Changes Of Minf (COM) in each trial.
% COM happens when the subject changes his end goal, this is
% reflected by a change in the heading angle's sign.
function data_table = countCom(traj_table, data_table, p)
    assert(any(contains(traj_table.Properties.VariableNames, 'head_angle')), "Run heading angle section before COM section");

    % NAme of COM column in data_table.
    com_col = 'com';

    com = NaN(p.NUM_TRIALS,1);

    % Reshape to convinient format.
    angles = traj_table{:,'head_angle'};
    angles_mat = reshape(angles, p.NORM_FRAMES, p.NUM_TRIALS);

    for iTrial = 1:height(data_table)
        % Find all negative angles.
        neg_angle = angles_mat(:, iTrial) < 0;
        neg_angle(1) = neg_angle(2); % There is no angle at first sample, so there is no change from first to second sample.
        % Find changes in sign.
        num_com = length(find(diff(neg_angle)));
        com(iTrial) = num_com;
    end

    data_table.com = com;
end