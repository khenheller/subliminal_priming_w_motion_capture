function [ ] = saveCode(trial_list_name, p)
    % SAVECODE saves the code into the code folder, including trial list.
    % output:
    % -------
    % This code file is saved into the code folder ("/data/code/").

    practice_trials = 'practice_trials.xlsx';

    try
        fileStruct = dir('*.m');

        mkdir(fullfile(p.DATA_FOLDER,num2str(p.SUB_NUM)));

        prf1 = sprintf('%d',p.SUB_NUM);
        for i = 1 : length(fileStruct)
            k = 0;
            k = strfind(fileStruct(i).name,'.m');
            if (k ~= 0)
                fileName = fileStruct(i).name;
                source = fullfile(pwd,fileName);
                destination = fullfile(p.DATA_FOLDER,num2str(p.SUB_NUM),strcat(fileName,'_',prf1,'.m'));
                copyfile(source,destination);
            end
        end
        % Copy trial list.
        source = fullfile(p.TRIALS_FOLDER,trial_list_name);
        destination = fullfile(p.DATA_FOLDER,num2str(p.SUB_NUM),trial_list_name);
        copyfile(source,destination);
        % Copy practice trial list.
        source = fullfile(p.TRIALS_FOLDER,practice_trials);
        destination = fullfile(p.DATA_FOLDER,num2str(p.SUB_NUM),practice_trials);
        copyfile(source,destination);
    catch
        fileStruct = dir('*.m');

        mkdir(fullfile(p.DATA_FOLDER,num2str(p.SUB_NUM)));

        prf1 = sprintf('%d',p.SUB_NUM);
        for i = 1 : length(fileStruct)
            k = 0;
            k = strfind(fileStruct(i).name,'.m');
            if (k ~= 0)
                fileName = fileStruct(i).name;
                source = fullfile(pwd,fileName);
                destination = fullfile(p.DATA_FOLDER,num2str(p.SUB_NUM),strcat(fileName,'_',prf1,'.m'));
                copyfile(source,destination);
            end
        end
        % Copy trial list.
        source = fullfile(p.TRIALS_FOLDER,trial_list_name);
        destination = fullfile(p.DATA_FOLDER,num2str(p.SUB_NUM),trial_list_name);
        copyfile(source,destination);
        % Copy practice trial list.
        source = fullfile(p.TRIALS_FOLDER,practice_trials);
        destination = fullfile(p.DATA_FOLDER,num2str(p.SUB_NUM),practice_trials);
        copyfile(source,destination);
    end
end