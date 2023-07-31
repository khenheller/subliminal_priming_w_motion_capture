% Creates a list of trials and their associated stimuli while keeping the following constraints:
% 1. All targets apear the same number of times.
% 2. A target doesn't appear twice in the same block (otherwise experiment conditions would be transperent to the participant).
% 3. The target is equally frequenct in the congruent and incongruent condition.
% 4. Target doesn't share letters in common locations with its prime.
% 5. Prime doesn't share letters in common locations with its distractor.
% 6. Half of the targets are natural and half artificial.
% N_words_to_use – How many words should we use from our word_freq_list?
% 			There are 2 conditions (congruent/incongruent) and two categories (artificial/natural), 
%           Therefor we divide the number of trials by 4. This gives us “X”, the number of words in a 	single category+condition combination.
%           The words can’t repeat in a single block, and in every block we have both categories of words, therefor we need a quotient of X that is larger the half a block size.

% Input:
% practice: 0 for test, 1 for practice trials.
%           practice lists' length is one block.
% draw_stats: 1=yes, 0=nope.
function trials = newTrials(draw_stats, practice, p)
    
    trials = p.CODE_OUTPUT_EXPLANATION;
    
    % Creates empty table (we add values later).
    empty_table = cell2table(cell(p.NUM_TRIALS, width(trials)));
    empty_table.Properties.VariableNames = trials.Properties.VariableNames;
    trials = empty_table;
    % Assign 0 to non-cell column (otherwise get matlab error).
    trials = setDefault(trials);
    % Assign trial number.
    trials.iTrial = [1:height(trials)]';
    % Assigns block number.
    block_nums = repmat(1:p.NUM_BLOCKS, p.BLOCK_SIZE, 1);
    block_nums = reshape(block_nums, p.NUM_BLOCKS*p.BLOCK_SIZE, 1);
    trials.iBlock = block_nums;
    % Assign trails type (practice/ test).
    trials.practice = ones(height(trials),1) * practice;
    % Assign time.
    trials.fix_duration = ones(height(trials),1) * p.FIX_DURATION;
    trials.mask1_duration = ones(height(trials),1) * p.MASK1_DURATION;
    trials.mask2_duration = ones(height(trials),1) * p.MASK2_DURATION;
    trials.prime_duration = ones(height(trials),1) * p.PRIME_DURATION;
    trials.mask3_duration = ones(height(trials),1) * p.MASK3_DURATION;
    trials.target_duration = ones(height(trials),1) * p.TARGET_DURATION;
    % Assign 'quit'.
    trials.quit = zeros(height(trials),1);
    
    % sample words to use as targets (See main.docx for explanation on this calc).
    divisors = 1:height(p.WORD_LIST);
    if practice > 0
        n_words_to_use = p.BLOCK_SIZE/2;
        word_repetitions = 1;
    else
        n_words_to_use = max(divisors(mod(p.NUM_TRIALS/4,divisors) == 0));
        word_repetitions = (p.NUM_TRIALS / 2 / 2 / n_words_to_use); % trials/conditions/categories/n_words_to_use.
    end
    [nat_words_to_use, nat_i] = datasample(p.WORD_LIST{:,'natural'}, n_words_to_use, 'Replace',false);
    [art_words_to_use, art_i] = datasample(p.WORD_LIST{:,'artificial'}, n_words_to_use, 'Replace',false);
    chosen_words  = [nat_words_to_use; art_words_to_use];
    words = table(chosen_words, NaN(length(chosen_words),1), ones(length(chosen_words),1),...
        'VariableNames',{'word', 'last_block', 'available'}); % Word, the number of the last block it apeared at, and whether it is avialable (wasn't already selected).
    
    % for each prime, lists all targets it can precede (doesn't share lettes with).
    possible_targets = [table2cell(p.ART_TARGETS(:,nat_i)) table2cell(p.NAT_TARGETS(:,art_i))];
    % for each distractor, lists all primes it can follow (doesn't share lettes with).
    possible_primes = [table2cell(p.NAT_PRIMES(:,nat_i)) table2cell(p.ART_PRIMES(:,art_i))];
    
    % Add target.
    for iTrial = 1:height(trials)
        % Used all words (=all words apeared same amount), renew list.
        if sum(words.available) == 0
            words.available = ones(height(words),1);
        end
        
        current_block = trials.iBlock(iTrial);
        % samples from available words who didn't apear in current block.
        target = datasample(words.word(words.available & (words.last_block~=current_block)), 1);
        [~,iWord] = ismember(target, words.word);
        words.last_block(iWord) = current_block;
        words.available(iWord) = 0;
        trials.target(iTrial) = target;
        trials.target_natural(iTrial) = iWord <= height(words)/2; % first half in "words" list are natural.
        
        % Adds Masks.
        masks = datasample(1:p.NUM_MASKS, 3, 'Replace',false);
        trials.mask1{iTrial} = masks(1);
        trials.mask2{iTrial} = masks(2);
        trials.mask3{iTrial} = masks(3);
    end
    
    % Add same / diff condition.
    if practice > 0
        trials.same(trials.target_natural == 1) = randerr(1, height(trials)/2, height(trials)/4)'; % half of nat targets are in congruent condition.
        trials.same(trials.target_natural == 0) = randerr(1, height(trials)/2, height(trials)/4)'; % half of art targets are in congruent condition.
    else
        % Each target apears equally in the congruent / incngruent conditions.
        for word = words.word'
            word_is_target = ismember(trials.target, word); % All locations of the target word.
            num_instances = sum(word_is_target);
            trials.same(word_is_target) = randerr(1,num_instances, num_instances/2); % half 1 half 0.
        end
    end
    
    % determines randomly for each trial if prime is displayed on left side.
    ones_and_zeros = [ones(1,height(trials)/2) zeros(1,height(trials)/2)];
    trials.prime_left = ones_and_zeros(randperm(length(ones_and_zeros)))';
    % prime is natural when: same = natural.
    trials.prime_natural = ~xor(trials.same,trials.target_natural);
    
    % Add primes.
    % Tries until succeed filling all primes.
    while sum(cellfun(@isempty, trials.prime)) > 0
        trials.prime = cell(height(trials), 1); % Delete all assigned primes.
        trials.prime(trials.same==1) = trials.target(trials.same==1);
        % Iterate over primes randomly.
        for i = randperm(size(possible_targets, 2))
            indices = ismember(trials.target, possible_targets(:,i)); % Take all indices of possible targets.
            indices = indices & cellfun(@isempty, trials.prime); % That have no prime yet.
            indices = find(indices);
            if length(indices) < word_repetitions % doesn't have enough places to put prime.
                break;
            end
            indices = datasample(indices, word_repetitions, 'Replace',false);
            trials.prime(indices) = words.word(i);
        end
    end
    
    % Add distractors.
    word_repetitions = word_repetitions * 2; % Primes are identical to targets in half of the trials, but distractors must be found for every trial, thus '*2'.
    % Tries until succeed filling all dist.
    while sum(cellfun(@isempty, trials.distractor)) > 0
        trials.distractor = cell(height(trials), 1);
        % Iterate over distractors randomly.
        for i = randperm(size(possible_targets, 2))
            indices = ismember(trials.prime, possible_primes(:,i)); % Take all indices of possible primes.
            indices = indices & cellfun(@isempty, trials.distractor); % that have no dist yet.
            indices = find(indices);
            if length(indices) < word_repetitions % doesn't have enough places to put dist.
                break;
            end
            indices = datasample(indices, word_repetitions, 'Replace',false);
            trials.distractor(indices) = words.word(i);
        end
    end
    
    % Draw statistics.
    if draw_stats
        % word prime/target/distractor frequency.
        freq.prime = zeros(height(words),1);
        freq.target = zeros(height(words),1);
        freq.dist = zeros(height(words),1);
        for iWord = 1:height(words)
            freq.prime(iWord)    = count(strjoin(trials.prime), words.word(iWord));
            freq.target(iWord)   = count(strjoin(trials.target), words.word(iWord));
            freq.dist(iWord)     = count(strjoin(trials.distractor), words.word(iWord));
        end
        
        % plot results.
        words.word = categorical(words.word, words.word);
        figure('Name','Primes');
        bar(words.word, freq.prime); title('Primes', 'FontSize',14); ylim([0 (max(freq.prime) + 1)]); ylabel('Number of appearances');
        figure('Name','Targets');
        bar(words.word, freq.target); title('Targets', 'FontSize',14); ylim([0 (max(freq.target) + 1)]); ylabel('Number of appearances');
        figure('Name','Distractors');
        bar(words.word, freq.dist); title('Distractors', 'FontSize',14); ylim([0 (max(freq.dist) + 1)]); ylabel('Number of appearances');
    end
end