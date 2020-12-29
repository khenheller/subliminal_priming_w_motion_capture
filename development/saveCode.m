function [ ] = saveCode()
    % SAVECODE saves the code into the code folder
    % output:
    % -------
    % This code file is saved into the code folder ("/data/code/").

    global SUB_NUM CODE_FOLDER DATA_FOLDER %subject number
    try
        fileStruct = dir('*.m');

        mkdir(fullfile(pwd,DATA_FOLDER,num2str(SUB_NUM),CODE_FOLDER));

        prf1 = sprintf('%d',SUB_NUM);
        for i = 1 : length(fileStruct)
            k = 0;
            k = strfind(fileStruct(i).name,'.m');
            if (k ~= 0)
                fileName = fileStruct(i).name;
                source = fullfile(pwd,fileName);
                destination = fullfile(pwd,DATA_FOLDER,num2str(SUB_NUM),CODE_FOLDER,strcat(fileName,'_',prf1,'.m'));
                copyfile(source,destination);
            end
        end
    catch
        fileStruct = dir('*.m');

        mkdir(fullfile(pwd,DATA_FOLDER,num2str(SUB_NUM),CODE_FOLDER));

        prf1 = sprintf('%d',SUB_NUM);
        for i = 1 : length(fileStruct)
            k = 0;
            k = strfind(fileStruct(i).name,'.m');
            if (k ~= 0)
                fileName = fileStruct(i).name;
                source = fullfile(pwd,fileName);
                destination = fullfile(pwd,DATA_FOLDER,num2str(SUB_NUM),CODE_FOLDER,strcat(fileName,'_',prf1,'.m'));
                copyfile(source,destination);
            end
        end
    end
end