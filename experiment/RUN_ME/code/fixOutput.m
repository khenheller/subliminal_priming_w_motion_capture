% Removes bad char('') from output files.
function [] = fixOutput(p)
    sub_traj_file = [p.DATA_FOLDER '/sub' num2str(p.SUB_NUM) p.DAY '_traj.csv'];
    sub_data_file = [p.DATA_FOLDER '/sub' num2str(p.SUB_NUM) p.DAY '_data.csv'];

    % Fix traj file.
    file_length = num2str(getFileLen(sub_traj_file) - 1); % Removes last line (has bad char).
    read_range = ['1:' file_length];
    results = readtable(sub_traj_file, 'FileType','spreadsheet', 'Range',read_range);
    results{:,1} = replace(results{:,1}, '',''); % Removes bad char.
    writetable(results, sub_traj_file);
    
    % Fix data file.
    file_length = num2str(getFileLen(sub_data_file) - 1);
    read_range = ['1:' file_length];
    results = readtable(sub_data_file, 'FileType','spreadsheet', 'Range',read_range);
    results{:,1} = replace(results{:,1}, '','');
    writetable(results, sub_data_file);
end

% Returns num of lines in file.
function num_lines = getFileLen(file_path)
    file_id = fopen(file_path, 'r');
    file = fread(file_id);
    num_lines = sum(file == newline()) + 1; % Counts lines.
    fclose(file_id);
end