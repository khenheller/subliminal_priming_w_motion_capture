function trials = newTrials() % Generates trials list.
    global CODE_OUTPUT_EXPLANATION; %path to data structure file.
    global BLOCK_SIZE NUM_BLOCKS;
    global FIX_DURATION MASK1_DURATION MASK2_DURATION PRIME_DURATION MASK3_DURATION TARGET_DURATION;
    global SUB_NUM;
    
    trials = CODE_OUTPUT_EXPLANATION;
    
    % Creates empty table (we add values later).
    empty_table = cell2table(cell(BLOCK_SIZE*NUM_BLOCKS, width(trials)));
    empty_table.Properties.VariableNames = trials.Properties.VariableNames;
    trials = empty_table;
    
    % Sets default value(0) to non-cell column (otherwise get matlab error).
    trials = setDefault(trials);
    
    % Creates blocks.
    for i = 1:NUM_BLOCKS
        block_range = BLOCK_SIZE*(i-1) +1 : BLOCK_SIZE*i; % block's trials numbers.
        
        success = 0;
        while ~success % Tries to create block until succeeds.
            [trials(block_range, :), success] = newBlock();
        end
        
        % Assigns block number.
        trials.block_num(block_range) = table2cell(table(repmat(i,BLOCK_SIZE,1)));
    end
    
    % Assign subject's number.
    trials.sub_num = ones(height(trials),1) * SUB_NUM;
    % Assign trial numbers.
    trials.trial = [1:height(trials)]';
    % In categorization task, "natural" is on the left for odd sub numbers.
    trials.natural_left = ones(height(trials),1) * rem(SUB_NUM, 2);
    % assign time.
    trials.fix_duration = ones(height(trials),1) * FIX_DURATION;
    trials.mask1_duration = ones(height(trials),1) * MASK1_DURATION;
    trials.mask2_duration = ones(height(trials),1) * MASK2_DURATION;
    trials.prime_duration = ones(height(trials),1) * PRIME_DURATION;
    trials.mask3_duration = ones(height(trials),1) * MASK3_DURATION;
    trials.target_duration = ones(height(trials),1) * TARGET_DURATION;
end

function trials = setDefault(trials)
    trials.prime_natural = zeros(height(trials),1);
    trials.target_natural = zeros(height(trials),1);
    trials.prime_left = zeros(height(trials),1);
    trials.same_w = zeros(height(trials),1);
    trials.target_ans_nat = zeros(height(trials),1);
    trials.target_correct = zeros(height(trials),1);
    trials.prime_correct = zeros(height(trials),1);
end