% for practice: loads practice_trials list.
% for test: Randomly selects a trial list from unused_lists.
%           When unused_lists empties, refills it.
%           This makes sure that one list doesn't repeat more than others.
% type: 'practice' / 'test'
function [trials] = getTrials(type, p)
    if isequal(type, 'test')
        unused_lists_path = [p.TRIALS_FOLDER '/unused_lists.mat'];
        unused_lists = [];

        % If file exists, loads it.
        if isfile(unused_lists_path)
            unused_lists = load(unused_lists_path);
            unused_lists = unused_lists.unused_lists;
        end

        % If used all trials, refills.
        if isempty(unused_lists)
            lists = string(ls(p.TRIALS_FOLDER));
            % Keep only trial lists files.
            lists = regexp(lists, 'trials\d+.xlsx', 'match');
            lists(cellfun(@isempty, lists)) = [];
            unused_lists = lists;
        end

        % Samples a list randomly.
        [list, list_index] = datasample(unused_lists,1);
        
        unused_lists(list_index) = [];
        save(unused_lists_path, 'unused_lists');
    else
        list = {'practice_trials.xlsx'};
    end
    
    list = char(list{:});
    trials = readtable([p.TRIALS_FOLDER '/' list]);
    % List ID.
    trials.list_id = repmat(list, height(trials), 1);
    % Assign subject's number.
    trials.sub_num = ones(height(trials),1) * p.SUB_NUM;
    % In categorization task, "natural" is on the left for odd sub numbers.
    trials.natural_left = ones(height(trials),1) * rem(p.SUB_NUM, 2);
    % convert vars with multiple row in each trial to cells.
    for var = p.MULTI_ROW_VARS
        trials.(var{:}) = num2cell(NaN(height(trials),1));
    end
end