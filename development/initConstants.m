function [] = initConstants()

    global fontType handFontType fontSize fontColor  % text params.
    global STIM_FOLDER DATA_FOLDER DATA_FOLDER_WIN % paths
    global VARIABLE_NAMES
    global WELCOME_SCREEN LOADING_SCREEN INSTRUCTIONS_SCREEN PRACTICE_SCREEN PAS_SCREEN...
        TEST_SCREEN END_SCREEN BLOCK_END_SCREEN CATEGOR_NATURAL_LEFT_SCREEN CATEGOR_NATURAL_RIGHT_SCREEN...
        RECOG_SCREEN FIXATION_SCREEN RESPOND_FASTER_SCREEN MASKS PRACTICE_MASKS% experiment slides (images).
    global One Two Three Four leftKey abortKey rightKey WRONG_KEY % Keys.
    global ERROR_CLICK_SLIDE TIME_SHOW_PROMPT NUMBER_OF_ERRORS_PROMPT
    global RIGHT LEFT; % number assigned to left/right response.
    global NUM_BLOCKS BLOCK_SIZE NUM_PRACTICE_TRIALS; % Block params.
    global FIX_DURATION MASK1_DURATION MASK2_DURATION PRIME_DURATION MASK3_DURATION TARGET_DURATION; % timing (seconds).
    global CODE_OUTPUT_EXPLANATION WORD_LIST ART_NOT_COMMON NAT_NOT_COMMON...
        ART_DISTRACTORS NAT_DISTRACTORS % word lists.
    global ONE_ROW_DATA MULTI_ROW_DATA ONE_ROW_VARS MULTI_ROW_VARS;
    
    NUMBER_OF_ERRORS_PROMPT = 3;
    TIME_SHOW_PROMPT = 1; % seconds
    
    NUM_BLOCKS = 4;
    BLOCK_SIZE = 40;%120; % has to be a multiple of 4.
    NUM_PRACTICE_TRIALS = 4;
    
    % duration in sec
    FIX_DURATION = 1;
    MASK1_DURATION = 0.27;
    MASK2_DURATION = 0.03;
    PRIME_DURATION = 0.03;
    MASK3_DURATION = 0.03;
    TARGET_DURATION = 0.5;
     
    % stimuli folders addresses
    STIM_FOLDER = './stimuli';
    DATA_FOLDER = './data';
    DATA_FOLDER_WIN = replace(DATA_FOLDER, '/', '\');
%     CODE_FOLDER = 'code';
    
    WRONG_KEY = 997;
    RIGHT = 0;
    LEFT = 1;
    
    % Response params
    KbName('UnifyKeyNames');
    rightKey      =  KbName('RightArrow');
    leftKey       =  KbName('LeftArrow');
    abortKey      =  KbName('ESCAPE'); % ESC aborts experiment
    One           =  KbName('1!');  % I did not see the phrase
    Two           =  KbName('2@');  % I had a vague perception, but I don?t know what it was
    Three         =  KbName('3#');  % I saw a clear part of the phrase
    Four          =  KbName('4$');  % I saw the entire phrase clearly

    % Get slides (screen images).
    WELCOME_SCREEN = getTextureFromHD('welcome_screen.jpg');
    LOADING_SCREEN = getTextureFromHD('loading_screen.jpg');
    INSTRUCTIONS_SCREEN = getTextureFromHD('instructions_screen.jpg');
    PRACTICE_SCREEN = getTextureFromHD('practice_screen.jpg');
    TEST_SCREEN = getTextureFromHD('test_screen.jpg');
    END_SCREEN = getTextureFromHD('end_screen.jpg');
    BLOCK_END_SCREEN = getTextureFromHD('block_end_screen.jpg');
    CATEGOR_NATURAL_LEFT_SCREEN = getTextureFromHD('categor_natural_left_screen.jpg');
    CATEGOR_NATURAL_RIGHT_SCREEN = getTextureFromHD('categor_natural_right_screen.jpg');
    RECOG_SCREEN = getTextureFromHD('recog_screen.jpg');
    PAS_SCREEN = getTextureFromHD('pas_screen.jpg');
    FIXATION_SCREEN = getTextureFromHD('fixation_screen.jpg');
    RESPOND_FASTER_SCREEN = getTextureFromHD('respond_faster_screen.jpg');
    ERROR_CLICK_SLIDE = getTextureFromHD('errorClickMessage.jpg');
    
    NUM_MASKS = 60;
    NUM_PRACTICE_MASKS = 3;
    for mask_i = 1:NUM_MASKS
        MASKS(mask_i) = getTextureFromHD(['mask' num2str(mask_i) '.jpg']);
    end
    for mask_i = 1:NUM_PRACTICE_MASKS
        PRACTICE_MASKS(mask_i) = getTextureFromHD(['practice_mask' num2str(mask_i) '.jpg']);
    end
    
    
    % trial structure and word lists.
    CODE_OUTPUT_EXPLANATION = readtable('Code_Output_Explanation.xlsx');
    ART_NOT_COMMON = readtable([STIM_FOLDER '/word_lists/art_not_common.xlsx']);
    NAT_NOT_COMMON = readtable([STIM_FOLDER '/word_lists/nat_not_common.xlsx']);
    ART_DISTRACTORS = readtable([STIM_FOLDER '/word_lists/art_distractors.xlsx']);
    NAT_DISTRACTORS = readtable([STIM_FOLDER '/word_lists/nat_distractors.xlsx']);
    WORD_LIST = readtable([STIM_FOLDER '/word_lists/word_freq_list.xlsx']);
    WORD_LIST = WORD_LIST(:,[1,3]); % Remove word frequencies.
    
    % output data that has 1 row per trial. used in saveToFile.m.
    ONE_ROW_VARS = {'prime','prime_natural','target','target_natural','distractor',...
        'prime_left','same_w','natural_left','mask1','mask2','mask3','fix_duration',...
        'mask1_duration','mask2_duration','prime_duration','mask3_duration','target_duration',...
        'fix_time','mask1_time','mask2_time','prime_time','mask3_time','target_time','categor_time',...
        'recog_time','pas_time','target_ans_left','target_ans_nat','target_correct','target_rt',...
        'prime_ans_left','prime_correct','prime_rt','pas','pas_rt','trial_start_time','trial_end_time',...
        'trial','block_num','cat_block','sub_num'};
    [~,ONE_ROW_DATA] = ismember(ONE_ROW_VARS, CODE_OUTPUT_EXPLANATION.Properties.VariableNames);
    % output that has many rows per trial.
    MULTI_ROW_VARS = {'target_x','target_y','target_z','target_timecourse',...
        'prime_x','prime_y','prime_z','prime_timecourse',...
        'pas_x','pas_y','pas_z','pas_timecourse'};
    [~,MULTI_ROW_DATA] = ismember(MULTI_ROW_VARS, CODE_OUTPUT_EXPLANATION.Properties.VariableNames);
    
    % WARNING! ANY CHANGE WILL BREAK THE CODE! Use cntrl+h only! 
    VARIABLE_NAMES = {'prime', 'prime_natural', 'target', 'target_natural', 'distractor',...
        'prime_left', 'same_w', 'natural', 'left', 'mask1', 'mask2', 'mask3',...
        'fix_time', 'mask1_time', 'mask2_time', 'prime_time', 'mask3_time', 'target_time',...
        'target_traj', 'target_ans_left', 'target_ans_nat', 'target_correct', 'target_rt',...
        'prime_traj', 'prime_ans_left', 'prime_correct', 'prime_rt',...
        'pas_traj', 'pas', 'pas_rt',...
        'trial_start_time', 'trial_end_time', 'trial', 'block_num', 'cat_block'};
    %%NatNet, motion capture.
    
    %% Text params
    
    % TEXT
    fontType = 'Arial'; %font name e.g. 'David';
    handFontType = 'HebHand';%'HebHand';
    fontColor = 0; % 0=black;
    
    global sittingDistance viewAngleX viewAngleY wordWidth wordHeight
    wordWidth = 2 * (sittingDistance*tand(viewAngleX)); % in cm. this is viewangle.
    wordHeight = 2 * (sittingDistance*tand(viewAngleY)); % in cm.
    fontSize = wordWidth * 100 / 8.5; % when font=100, word_width=8.5, measured by hand.
    
    global w screenScaler text
    Screen('TextFont',w, char(fontType));
    Screen('TextStyle', w, 0);
    Screen('TextSize', w, ceil(fontSize*screenScaler));
    text.Color = fontColor; %black
end