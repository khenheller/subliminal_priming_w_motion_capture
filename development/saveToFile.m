% Appends a trial to subject's trials file.
% If file doesn't exist, creates it.
function [] = saveToFile(trial)
    global DATA_FOLDER_WIN;
    global ONE_ROW_VARS_I MULTI_ROW_VARS_I MULTI_ROW_VARS;
    
    temp_data_file = [DATA_FOLDER_WIN '\sub' num2str(trial.sub_num) 'data_temp.csv'];
    temp_traj_file = [DATA_FOLDER_WIN '\sub' num2str(trial.sub_num) 'traj_temp.csv'];
    data_file = [DATA_FOLDER_WIN '\sub' num2str(trial.sub_num) 'data.csv'];
    traj_file = [DATA_FOLDER_WIN '\sub' num2str(trial.sub_num) 'traj.csv'];
    both_data_files = [DATA_FOLDER_WIN '\sub' num2str(trial.sub_num) 'data*.csv'];
    both_traj_files = [DATA_FOLDER_WIN '\sub' num2str(trial.sub_num) 'traj*.csv'];
    
    % seperates data (1 row) from trajectories (many rows).
    trial_data = trial(1,ONE_ROW_VARS_I);
    trial_traj = trial(:,MULTI_ROW_VARS_I);
    trial_traj_matrix = cell2mat(trial_traj{:,:}(:,:)); % convert to matrix to unpack x,y and z cells.
    trial_num_vec = ones(length(trial_traj_matrix),1) * trial.iTrial;
    block_num_vec = ones(length(trial_traj_matrix),1) * trial.iBlock(1);
    sub_num_vec = ones(length(trial_traj_matrix),1) * trial.sub_num;
    practice_vec = ones(length(trial_traj_matrix),1) * trial.practice;
    trial_traj_matrix = [sub_num_vec, block_num_vec, trial_num_vec, practice_vec, trial_traj_matrix]; % add trial and block num column.
    trial_traj = array2table(trial_traj_matrix, 'VariableNames',['sub_num' 'iBlock' 'iTrial' 'practice' MULTI_ROW_VARS]);
    
    % on first trial there isn't a file yet. So we add headers.
    file_doesnt_exist = trial.iTrial==1 & trial.practice==1;
    
    % saves to temporary file.
    writetable(trial_data, temp_data_file, 'WriteVariableNames', file_doesnt_exist);
    writetable(trial_traj, temp_traj_file, 'WriteVariableNames', file_doesnt_exist);
    
    % merges existing file with new temp file.
    cmd=['copy ' both_data_files ' ' data_file];
    system(cmd); % submit to OS.
    cmd=['copy ' both_traj_files ' ' traj_file];
    system(cmd);
end