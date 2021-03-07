% Receives single sub's data and runs various tests on it.
function [pass_test] = tests (trials, trials_traj, practice)
    
    % Initialize parameters.
    initPsychtoolbox();
    initConstants();
    % Closes psychtoolbox.
    Priority(0); sca; ShowCursor; ListenChar(0);
    global NUM_TRIALS;
    pass_test.prime_alter = 1;
    pass_test.deviations = 1;
    pass_test.deviation_of_mean = 1;
    pass_test.std = 1;
    pass_test.prime_alter = 1;
    
    % Remove practice trials, unless testing practice trials.
    if ~practice
        trials(trials.practice==1, :) = [];
    end
    
    
    % Test event durations.
    disp('------------------------------- Event Durations -------------------------------');
    events = {'fix_time','mask1_time','mask2_time','prime_time','mask3_time','target_time','categor_time'};
    timestamps = trials(:,events);
    desired_durations = [1 0.270 0.030 0.030 0.030 0.500];
    pass_timings = timingsTest(events, timestamps, desired_durations);
    pass_test.deviations = pass_timings.deviations;
    pass_test.deviation_of_mean = pass_timings.deviation_of_mean;
    pass_test.std = pass_timings.std;
    
    % Test output has values for all fields.
    disp('------------------------------- Has Values -------------------------------');
    pass_test.data_values = hasValuesTest(trials, 'iTrial');
    pass_test.traj_values = hasValuesTest(trials_traj, 'iTrial');
    
    % Test prime-target-distractor relations (don't share letters, are from same/diff categor).
    disp('------------------------------- Relations -------------------------------');
    pass_relations.prime_target = relationsTest(cell2mat(trials.prime), cell2mat(trials.target), 'prime_target');
    pass_relations.prime_dist = relationsTest(cell2mat(trials.prime), cell2mat(trials.distractor), 'prime_dist');
    pass_test.prime_target_common_letters = pass_relations.prime_target.common_letters;
    pass_test.prime_target_categor = pass_relations.prime_target.categor;
    pass_test.prime_dist_common_letters = pass_relations.prime_dist.common_letters;
    pass_test.prime_dist_categor = pass_relations.prime_dist.categor;
    
    % Test conditions count.
    disp('------------------------------- Conditions -------------------------------');
    var_names = {'target_natural','same'};
    vars = trials(:,var_names);
    lvls = table([1;1;0;0],[1;0;1;0], 'VariableNames',var_names);
    reps = [120 120 120 120];
    pass_test.conditions = conditionTests(vars, lvls, reps); 
    
    % Test target doesn't repeat in block.
    disp('------------------------------- Target Repeatitions -------------------------------');
    pass_test.word_dont_repeat = wordInBlockTest(trials);
    
    % Test prime alternates between left and right in recog equally.
    disp('------------------------------- Prime right/left alternations -------------------------------');
    if sum(trials.prime_left) ~= NUM_TRIALS / 2
        disp(['Prime is on left side in categor question: ' num2str(sum(trials.prime_left))...
            ' times, instead of: ' num2str(NUM_TRIALS/2)]);
        pass_test.prime_alter = 0;
    end
    
    % Test there are enough trials and blocks.
    disp('------------------------------- Count trials and blocks -------------------------------');
    pass_count = testTrialBlockCount(trials.iTrial, trials.iBlock);
    pass_test.block_count = pass_count.block_count;
    pass_test.trial_count = pass_count.trial_count;
    
    % Test all trial lists apear equally (between subs).
    disp('------------------------------- Trial Lists -------------------------------');
    disp('------------------------------------------------------------------------------------------------');
    disp('------------------------------- Test results (0=didnt pass test) -------------------------------');
    disp('------------------------------------------------------------------------------------------------');
    disp(pass_test);
end

% Makes sure num trials and blocks is right.
% trial_num_col: column with trial nums, from output data table.
function pass_test = testTrialBlockCount(trial_num_col, block_num_col)
    pass_test.trial_count = 1;
    pass_test.block_count = 1;
    global NUM_BLOCKS NUM_TRIALS;
    num_trials = length(unique(trial_num_col));
    num_blocks = length(unique(block_num_col));
    if num_trials ~= NUM_TRIALS
        disp(['Desired num of trials: ' num2str(NUM_TRIALS) '   Actual num: ' num2str(num_trials)]);
        pass_test.trial_count = 0;
    end
    if num_blocks ~= NUM_BLOCKS
        disp(['Desired num of blocks: ' num2str(NUM_BLOCKS) '   Actual num: ' num2str(num_blocks)]);
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