% Receives single sub's data and runs various tests on it.
% test_type - 'data', 'trials_list', each runs different set of tests.
% events - names of the columns containing the event's timestamps.
% desired_durations - of each event, in sec.
% test_day - 'day1', 'day2'.
% is_reach - testing a reaching session (1) or a keyboard response sesssion (0).
function [pass_test, test_res] = tests (trials, trials_traj, test_type, events, desired_durations, test_day, is_reach, p)
    warning('off','MATLAB:table:ModifiedAndSavedVarnames');
    traj_end = [];
    test_res = [];
    
    % Initialize parameters.
    pass_test.deviations = NaN;
    pass_test.deviation_of_mean = NaN;
    pass_test.std = NaN;
    pass_test.prime_alter = NaN;
    
    if strcmp(test_type, 'data')
        % Remove practice from data.
        trials(trials.practice > 0, :) = [];
        
        if is_reach
            % Remove practice drom traj.
            trials_traj(trials_traj.practice > 0, :) = [];
            
            % Get last timestamp in every reach to target.
            for j = 1:max(trials.iTrial)
                timecourse = trials_traj.target_timecourse_to(trials_traj.iTrial == j);
                last_sample_indx = find(~isnan(timecourse), 1, 'last');
                traj_end(j) = timecourse(last_sample_indx);
            end
        end
    else
        disp('Didnt run test');
    end
    
    % Test event durations.
    if strcmp(test_type, 'data')
        disp('------------------------------- Event Durations -------------------------------');
        timestamps = trials(:,events);
        [pass_timings , test_res.dev_table] = timingsTest(events, timestamps, traj_end, desired_durations, trials.target_rt, is_reach);
        pass_test.deviations = pass_timings.deviations;
        pass_test.deviation_of_mean = pass_timings.deviation_of_mean;
        pass_test.std = pass_timings.std;
    else
        disp('Didnt run test');
    end
    
    % Test output has values for all fields.
    if strcmp(test_type, 'data')
        disp('------------------------------- Has Values -------------------------------');
        [pass_test.data_values ~] = hasValuesTest(trials, 'iTrial');
        % Tests traj only in reach session.
        if is_reach
            [pass_test.traj_values test_res.miss_data] = hasValuesTest(trials_traj, 'iTrial');
        else
            pass_test.traj_values = 1;
        end
    else
        disp('Didnt run test');
    end
    
    % Test prime-target-distractor relations (don't share letters, are from same/diff categor).
    disp('------------------------------- Relations -------------------------------');
    if test_day == 'day2'
        pass_relations.prime_target = relationsTest(cell2mat(trials.prime), cell2mat(trials.target), 'prime_target', p);
        pass_relations.prime_dist = relationsTest(cell2mat(trials.prime), cell2mat(trials.distractor), 'prime_dist', p);
        pass_test.prime_target_common_letters = pass_relations.prime_target.common_letters;
        pass_test.prime_target_categor = pass_relations.prime_target.categor;
        pass_test.prime_dist_common_letters = pass_relations.prime_dist.common_letters;
        pass_test.prime_dist_categor = pass_relations.prime_dist.categor;
    else
        disp('Didnt run test');
    end
    
    % Test conditions count.
    disp('------------------------------- Conditions -------------------------------');
    var_names = {'target_natural','same'};
    vars = trials(:,var_names);
    lvls = table([1;1;0;0],[1;0;1;0], 'VariableNames',var_names); % All possible cominations of conditions.
    num_cond = p.N_CONDS * p.N_CATEGOR; % Num conditions.
    reps = (p.NUM_TRIALS / num_cond) * ones(1,num_cond);
    pass_test.conditions = conditionTests(vars, lvls, reps); 
    
    % Test target doesn't repeat in block.
    disp('------------------------------- Target Repeatitions -------------------------------');
    pass_test.word_dont_repeat = wordInBlockTest(trials);
    
    % Test prime alternates between left and right in recog equally.
    disp('------------------------------- Prime right/left alternations -------------------------------');
    if test_day == 'day2'
        if sum(trials.prime_left) ~= p.NUM_TRIALS / 2
            disp(['Prime is on left side in categor question: ' num2str(sum(trials.prime_left))...
                ' times, instead of: ' num2str(p.NUM_TRIALS/2)]);
            pass_test.prime_alter = 0;
        else
            pass_test.prime_alter = 1;
        end
    else
        disp('Didnt run test');
    end
    
    % Test there are enough trials and blocks.
    disp('------------------------------- Count trials and blocks -------------------------------');
    pass_count = testTrialBlockCount(trials.iTrial, trials.iBlock, p);
    pass_test.block_count = pass_count.block_count;
    pass_test.trial_count = pass_count.trial_count;
    
    disp('------------------------------- Test results (0=didnt pass test) -------------------------------');
    disp('------------------------------------------------------------------------------------------------');
    disp(pass_test);
end

% Makes sure num trials and blocks is right.
% trial_num_col: column with trial nums, from output data table.
function pass_test = testTrialBlockCount(trial_num_col, block_num_col, p)
    pass_test.trial_count = 1;
    pass_test.block_count = 1;
    num_trials = length(unique(trial_num_col));
    num_blocks = length(unique(block_num_col));
    if num_trials ~= p.NUM_TRIALS
        disp(['Desired num of trials: ' num2str(p.NUM_TRIALS) '   Actual num: ' num2str(num_trials)]);
        pass_test.trial_count = 0;
    end
    if num_blocks ~= p.NUM_BLOCKS
        disp(['Desired num of blocks: ' num2str(p.NUM_BLOCKS) '   Actual num: ' num2str(num_blocks)]);
        pass_test.block_count = 0;
    end
end

% Check each target repeats once per block.
% trials: table with all vars value for all trials.
function pass_test = wordInBlockTest(trials)
    pass_test = 1;
    % Iterates until checked all words.
    while ~isempty(trials)
        word = trials.target(1);
        % Finds all trials that have the word, and then all blocks.
        word_instances = find(ismember(trials.target, word));
        word_trials = trials.iTrial(word_instances);
        word_blocks = trials.iBlock(word_instances);
        % Checks target don't repeat in same block.
        if ~isequal(unique(word_blocks), word_blocks)
            instances = table(word_blocks, word_trials, 'VariableNames',{'Blocks','Trials'});
            disp([' The following word repeats in a block: ' trials.target{1} '    Here are its apearances:']);
            disp(instances);
            pass_test = 0;
        end
        % Remove trials that have word.
        trials(word_instances,:) = [];
    end
end