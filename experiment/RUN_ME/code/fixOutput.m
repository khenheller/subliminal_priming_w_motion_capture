% Removes bad char('') from output files.
function [] = fixOutput(p)
    reach_traj_file = [p.DATA_FOLDER '/sub' num2str(p.SUB_NUM) p.DAY '_reach_traj.csv'];
    reach_data_file = [p.DATA_FOLDER '/sub' num2str(p.SUB_NUM) p.DAY '_reach_data.csv'];
    keyboard_data_file = [p.DATA_FOLDER '/sub' num2str(p.SUB_NUM) p.DAY '_keyboard_data.csv'];

    % Check if reach file exists.
    if isfile(reach_data_file)
        % Fix Reaching traj file.
        file_length = getFileLen(reach_traj_file) - 1; % Removes last line (has bad char).
        read_range = [2 file_length];
        opts = detectImportOptions(reach_traj_file);
        opts.DataLines = read_range;
        opts.VariableTypes{1} = 'char'; % If left as double, the bad char is read as Nan and cant be removed.
        results = readtable(reach_traj_file, opts);
        results{:,1} = replace(results{:,1}, '',''); % Removes bad char.
        writetable(results, reach_traj_file);
        
        % Fix Reaching data file.
        file_length = getFileLen(reach_data_file) - 1; % Removes last line (has bad char).
        read_range = [2 file_length];
        opts = detectImportOptions(reach_data_file);
        opts.DataLines = read_range;
        opts.VariableTypes{1} = 'char'; % If left as double, the bad char is read as Nan and cant be removed.
        results = readtable(reach_data_file, opts);
        results{:,1} = replace(results{:,1}, '','');
        writetable(results, reach_data_file);
    end
        

    % Check if keyboard file exists
    if isfile(keyboard_data_file)
        % Fix Keyboard data file.
        file_length = getFileLen(keyboard_data_file) - 1; % Removes last line (has bad char).
        read_range = [2 file_length];
        opts = detectImportOptions(keyboard_data_file);
        opts.DataLines = read_range;
        opts.VariableTypes{1} = 'char';
        results = readtable(keyboard_data_file, opts);
        results{:,1} = replace(results{:,1}, '','');
        writetable(results, keyboard_data_file);
    end
end

% Returns num of lines in file.
function num_lines = getFileLen(file_path)
    file_id = fopen(file_path, 'r');
    file = fread(file_id);
    num_lines = sum(file == newline()) + 1; % Counts lines.
    fclose(file_id);
end