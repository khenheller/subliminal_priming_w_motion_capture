% Appends a trial to subject's trials file.
% If file doesn't exist, creates it.
% is_reach - 1=sub responds with reaching , 0=responds with keybaord.
function [] = saveToFile(trial, is_reach, p)
    if is_reach
        session_type = 'reach';
    else
        session_type = 'keyboard';
    end

    temp_data_file = [p.DATA_FOLDER_WIN '\sub' num2str(trial.sub_num) p.DAY '_' session_type '_data_temp.csv'];
    temp_traj_file = [p.DATA_FOLDER_WIN '\sub' num2str(trial.sub_num) p.DAY '_' session_type '_traj_temp.csv'];
    data_file = [p.DATA_FOLDER_WIN '\sub' num2str(trial.sub_num) p.DAY '_' session_type '_data.csv'];
    traj_file = [p.DATA_FOLDER_WIN '\sub' num2str(trial.sub_num) p.DAY '_' session_type '_traj.csv'];
    both_data_files = [p.DATA_FOLDER_WIN '\sub' num2str(trial.sub_num) p.DAY '_' session_type '_data*.csv'];
    both_traj_files = [p.DATA_FOLDER_WIN '\sub' num2str(trial.sub_num) p.DAY '_' session_type '_traj*.csv'];
    
    % seperates data (1 row) from trajectories (many rows).
    trial_data = trial(1,p.ONE_ROW_VARS_I);
    if is_reach
        trial_traj = trial(:,p.MULTI_ROW_VARS_I);
        trial_traj_matrix = cell2mat(trial_traj{:,:}(:,:)); % convert to matrix to unpack x,y and z cells.
        trial_num_vec = ones(length(trial_traj_matrix),1) * trial.iTrial;
        block_num_vec = ones(length(trial_traj_matrix),1) * trial.iBlock(1);
        sub_num_vec = ones(length(trial_traj_matrix),1) * trial.sub_num;
        practice_vec = ones(length(trial_traj_matrix),1) * trial.practice;
        trial_traj_matrix = [sub_num_vec, block_num_vec, trial_num_vec, practice_vec, trial_traj_matrix]; % add trial and block num column.
        trial_traj = array2table(trial_traj_matrix, 'VariableNames',['sub_num' 'iBlock' 'iTrial' 'practice' p.MULTI_ROW_VARS]);
    end
    
    % on first trial there isn't a file yet. So we add headers.
    file_doesnt_exist = trial.iTrial==1 & trial.practice==1;
    
    % saves to temporary file.
    writetable(trial_data, temp_data_file, 'WriteVariableNames', file_doesnt_exist);

    % merges existing file with new temp file.
    cmd=['copy ' both_data_files ' ' data_file];
    system(cmd); % submit to OS.

    % Does the same for the traj table, but only in the reaching condition.
    if is_reach
        writetable(trial_traj, temp_traj_file, 'WriteVariableNames', file_doesnt_exist);
        cmd=['copy ' both_traj_files ' ' traj_file];
        system(cmd);
    end
end