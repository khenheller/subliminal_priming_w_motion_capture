% Generates trials list.
% practice: 0 for test, 1 for practice trials, 2 for practice trials w/o prime.
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
    trials.fix_duration = ones(height(trials),1) * p.FIX_DURATION_SEC;
    trials.mask1_duration = ones(height(trials),1) * p.MASK1_DURATION_SEC;
    trials.mask2_duration = ones(height(trials),1) * p.MASK2_DURATION_SEC;
    trials.prime_duration = ones(height(trials),1) * p.PRIME_DURATION_SEC;
    trials.mask3_duration = ones(height(trials),1) * p.MASK3_DURATION_SEC;
    trials.target_duration = ones(height(trials),1) * p.TARGET_DURATION_SEC;
    
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
        'VariableNames',{'word', 'last_block', 'available'});
    
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
        trials.target_natural(iTrial) = iWord <= height(words)/2; % first half are natural.
        
        % Adds Masks.
        masks = datasample(1:p.NUM_MASKS, 3, 'Replace',false);
        trials.mask1{iTrial} = masks(1);
        trials.mask2{iTrial} = masks(2);
        trials.mask3{iTrial} = masks(3);
    end
    
    % Add same / diff condition.
    if practice > 0
        trials.same(:) = randerr(1, height(trials), height(trials)/2)'; % half 1 half 0.
    else
        for word = words.word'
            word_is_target = ismember(trials.target, word);
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
        trials.prime = cell(height(trials), 1);
        trials.prime(trials.same==1) = trials.target(trials.same==1);
        % Iterate over primes randomly.
        for i = randperm(size(possible_targets, 2))
            indices = ismember(trials.target, possible_targets(:,i)); % all indices of possible targets.
            indices = indices & cellfun(@isempty, trials.prime); % only empty primes.
            indices = find(indices);
            if length(indices) < word_repetitions % doesn't have enough places to put prime.
                break;
            end
            indices = datasample(indices, word_repetitions, 'Replace',false);
            trials.prime(indices) = words.word(i);
        end
    end
    
    % Add distractors.
    % Tries until succeed filling all dist.
    while sum(cellfun(@isempty, trials.distractor)) > 0
        trials.distractor = cell(height(trials), 1);
        % Iterate over primes randomly.
        for i = randperm(size(possible_targets, 2))
            indices = ismember(trials.prime, possible_primes(:,i)); % all indices of possible primes.
            indices = indices & cellfun(@isempty, trials.distractor); % only empty dist.
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
        bar(words.word, freq.prime); title('Primes', 'FontSize',14); ylim([0 (max(freq.prime) + 1)]);
        figure('Name','Targets');
        bar(words.word, freq.target); title('Targets', 'FontSize',14); ylim([0 (max(freq.target) + 1)]);
        figure('Name','Distractors');
        bar(words.word, freq.dist); title('Distractors', 'FontSize',14); ylim([0 (max(freq.dist) + 1)]);
    end
end

% recieves list of words.
% samples randomly a word from the list.
% erases that word from the list.
function [word_list, word] = getWord(word_list, word_index)
    success = 0;
    if ~isEmptyCell(word_list(:,word_index))
        while ~success
            [word, erase_i] = datasample(word_list(:,word_index), 1);
            success = ~isEmptyCell(word);
        end
        word_list(erase_i, :) = table('Size',[1 1], 'VariableTypes',{'char'});
    end
end

function trials = setDefault(trials)
    trials.prime_natural = zeros(height(trials),1);
    trials.target_natural = zeros(height(trials),1);
    trials.prime_left = zeros(height(trials),1);
    trials.same = zeros(height(trials),1);
    trials.target_ans_nat = zeros(height(trials),1);
    trials.target_correct = zeros(height(trials),1);
    trials.prime_correct = zeros(height(trials),1);
end

function empty = isEmptyCell(cell_array)
    empty = isequal(cell_array, cell(size(cell_array)));
end