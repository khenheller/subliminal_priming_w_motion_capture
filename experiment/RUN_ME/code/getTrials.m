% Randomly selects a trial list from unused_lists.
% When unused_lists empties, refills it.
% This makes sure that one list doesn't repeat more than others.
% type: 'practice' / 'test'
function [trials] = getTrials(trial_type, p)
    unused_lists_path = [p.TRIALS_FOLDER '/' trial_type '_unused_lists_' p.DAY '.mat'];
    unused_lists = [];

    % If file exists, loads it.
    if isfile(unused_lists_path)
        unused_lists = load(unused_lists_path);
        unused_lists = unused_lists.unused_lists;
    end

    % If used all trials, refills.
    if isempty(unused_lists)
        lists = cellstr(ls(p.TRIALS_FOLDER));
        % Keep only trial lists files.
        lists = regexp(lists, [trial_type '_trials\d+' p.DAY '.xlsx'], 'match');
        lists(cellfun(@isempty, lists)) = [];
        unused_lists = vertcat(lists{:});
    end

    % Samples a list randomly.
    [list, list_index] = datasample(unused_lists,1);

    unused_lists(list_index) = [];
    save(unused_lists_path, 'unused_lists');
    
    trials = readtable([p.TRIALS_FOLDER '/' list{:}]);
    % List ID.
    trials.list_id = repmat(list, height(trials), 1);
    % Assign subject's number.
    trials.sub_num = ones(height(trials),1) * p.SUB_NUM;
    % In categorization task, "natural" is on the left for odd sub numbers.
    trials.natural_left = ones(height(trials),1) * rem(p.SUB_NUM, 2);
    % Set quit to 0.
    trials.quit = zeros(height(trials),1);
    % convert vars with multiple row in each trial to cells.
    for var = p.MULTI_ROW_VARS
        trials.(var{:}) = num2cell(NaN(height(trials),1));
    end
end