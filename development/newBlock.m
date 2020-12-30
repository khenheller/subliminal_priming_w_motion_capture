% Returns block table of one block.
% Trials are shuffled: no consequetive target/prime word.
function [block, success] = newBlock()
    global BLOCK_SIZE;
    global CODE_OUTPUT_EXPLANATION WORD_LIST ART_NOT_COMMON NAT_NOT_COMMON ART_DISTRACTORS NAT_DISTRACTORS;
    global MASKS;
    
    block = CODE_OUTPUT_EXPLANATION;
    
    % Creates empty table (later we add values).
    empty_table = cell2table(cell(BLOCK_SIZE, width(block)));
    empty_table.Properties.VariableNames = block.Properties.VariableNames;
    block = empty_table;
    
    % stimuli words.
    words = WORD_LIST;
    % the words that don't share common letters with each stimuli word.
    art_not_common = ART_NOT_COMMON;
    nat_not_common = NAT_NOT_COMMON;
    nat_distractors = NAT_DISTRACTORS;
    art_distractors = ART_DISTRACTORS;
    nat_distractors = [nat_distractors; nat_distractors]; % on 2 condition out of 4, the prime is nat, so we duplicate the list.
    art_distractors = [art_distractors; art_distractors];
    
    % words structure:
    % ARTIFICAIL    NATURAL
    %   phone       fruit
    %
    % block structure before shuffle: (has more columns then mentioned below)
    % TARGET_NATURAL   SAME_W  TARGET    PRIME
    %       1           1       fruit    fruit
    %       1           0       fruit    phone
    %       0           1       phone    phone
    %       0           0       phone    fruit
    
    natural = [ones(BLOCK_SIZE/2,1); zeros(BLOCK_SIZE/2,1)]; % trails when target is natural.
    same = repmat([ones(BLOCK_SIZE/4,1); zeros(BLOCK_SIZE/4,1)], 2,1); % condition (same/diff) for each trial.
    
    % determines randomly for each trial if prime is displayed on left side.
    block.prime_left = round(rand(height(block),1));
    
    % marks each trial as natural/artificial and same/different.
    block.target_natural = natural;
    block.prime_natural = ~xor(same,natural); % prime is natural when: same = natural.
    block.same_w = same;
    
    % Sets default values, otherwise matlab error.
    block.target_ans_nat = zeros(height(block),1);
    block.target_correct = zeros(height(block),1);
    block.prime_correct = zeros(height(block),1);
    
    % assigns target word to each trial.
    nat_target_words_in_block = datasample(words.natural, BLOCK_SIZE/4); % 4 conditions in each block.
    art_target_words_in_block = datasample(words.artificial, BLOCK_SIZE/4);
    block.target(block.target_natural==1) = repmat(nat_target_words_in_block, 2,1); % 2 out of 4 conditions have natural targets.
    block.target(block.target_natural==0) = repmat(art_target_words_in_block, 2,1);
    
    % Adds prime, distractor and masks to each trial.
    for i = 1:height(block)
        
        % Adds prime
        if block.same_w(i)  % prime = target.
            block.prime(i) = block.target(i);
            success_p = 1;  
        else                % prime!=target.
            if block.target_natural(i)  % Target is natural, prime isn't.
                [nat_not_common, block.prime(i), success_p] = getWord(nat_not_common, block.target{i});
                
            else                        % Target is artficial, prime isn't.
                [art_not_common, block.prime(i), success_p] = getWord(art_not_common, block.target{i});
            end
        end
        
        % Adds a distractor.
        if block.prime_natural(i)   % Target is natural, distractor is too.
            [nat_distractors, block.distractor(i), success_d] = getWord(nat_distractors, block.prime{i});
        else                        % Target is artficial, thus distractor is too.
            [art_distractors, block.distractor(i), success_d] = getWord(art_distractors, block.prime{i});
        end
        
        % Adds Masks.
        masks = datasample(MASKS, 3, 'Replace',false);
        block.mask1{i} = masks(1);
        block.mask2{i} = masks(2);
        block.mask3{i} = masks(3);
        
        success = success_p & success_d;
        if ~success; return; end % failed to get a word, exits newBlock func.
    end
    
    block = shuffle(block);
end

% recieves lists of words (not_common.xlsx / distractors.xlsx).
% samples randomly a word from list number word_index.
% erases that word from the list.
function [word_list, rand_word, success] = getWord(word_list, word)

    global WORD_LIST;
    
    [word_index, word_type] = find(ismember(WORD_LIST{:,:},word));
    
    % If list empty, fail.
    empty_column = cell(height(word_list),1);
    if isequal(word_list.(word_index), empty_column)
        disp(['no words left in list for: ' WORD_LIST(word_index,word_type)]);
        rand_word = {'@@failed@@'}; % assign word to prevent code crash.
        success = 0;
        return;
    end
    success = 1;
    
    % Samples randomly, exits loop when sample isn't empty.
    while true
        [rand_word, erase_i] = datasample(word_list.(word_index), 1);
        if ~isequal(rand_word, cell(1,1)); break; end
    end
    % erases prime from list so it won't repeat.
    word_list(erase_i, :) = table('Size',[1 1],'VariableTypes',{'char'});
end