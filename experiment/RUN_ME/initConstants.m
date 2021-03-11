% psychtoolbox_active - Some parameters can only be initiated after psychtoolbox was activated.    
function [p] = initConstants(psychtoolbox_active, p)
    
    % TEXT
    p.FONT_TYPE = 'Arial Bold'; %font name e.g. 'David';
    p.HAND_FONT_TYPE = 'HebHand';%'HebHand';
    p.FONT_COLOR = 0; % 0=black;
    
    p.WORD_WIDTH = 2 * (p.SITTING_DISTANCE*tand(p.VIEW_ANGLE_X/2)); % in cm. this is viewangle.
    p.WORD_HEIGHT = 2 * (p.SITTING_DISTANCE*tand(p.VIEW_ANGLE_Y/2)); % in cm.
    p.HAND_FONT_SIZE = ceil(p.WORD_WIDTH * 100 / 11);
    p.FONT_SIZE = ceil(p.WORD_WIDTH * 100 / 10); % typescript font size.
    p.RECOG_FONT_SIZE = ceil(p.WORD_WIDTH * 100 / 10); % font size oin recog question.
    
    % Paths
    [curr_path, ~, ~] = fileparts(mfilename('fullpath'));
    curr_path = replace(curr_path, '\', '/');
    p.STIM_FOLDER = [curr_path '/./stimuli'];
    p.DATA_FOLDER = [curr_path '/../../raw_data'];
    p.TRIALS_FOLDER = [p.STIM_FOLDER '/trial_lists'];
    p.DATA_FOLDER_WIN = replace(p.DATA_FOLDER, '/', '\');
    
    if psychtoolbox_active
        p.RECOG_CAP_LENGTH_SEC = 5; % Trajectory recording length in sec.
        p.CATEGOR_CAP_LENGTH_SEC = 1.5;
        p.RECOG_CAP_LENGTH = p.RECOG_CAP_LENGTH_SEC * p.REF_RATE_HZ; % Trajectory capture length (num of samples).
        p.CATEGOR_CAP_LENGTH = p.CATEGOR_CAP_LENGTH_SEC * p.REF_RATE_HZ;
        p.MAX_CAP_LENGTH = max(p.RECOG_CAP_LENGTH, p.CATEGOR_CAP_LENGTH);
        
        % Response keys.
        KbName('UnifyKeyNames');
        p.RIGHT_KEY      =  KbName('RightArrow');
        p.LEFT_KEY       =  KbName('LeftArrow');
        p.ABORT_KEY      =  KbName('ESCAPE'); % ESC aborts experiment
        p.ONE           =  KbName('1!');  % I did not see the phrase
        p.TWO           =  KbName('2@');  % I had a vague perception, but I don?t know what it was
        p.THREE         =  KbName('3#');  % I saw a clear part of the phrase
        p.FOUR          =  KbName('4$');  % I saw the entire phrase clearly
        p.SPACE_KEY      =  KbName('space');
        p.WRONG_KEY = 997;
        % number assigned to left/right response.
        p.RIGHT = 0;
        p.LEFT = 1;

        % Experiment slides.
        p.WELCOME_SCREEN = getTextureFromHD('welcome_screen.jpg', p);
        p.LOADING_SCREEN = getTextureFromHD('loading_screen.jpg', p);
        p.INSTRUCTIONS_SCREEN = getTextureFromHD('instructions_screen.jpg', p);
        p.PRACTICE_SCREEN = getTextureFromHD('practice_screen.jpg', p);
        p.TEST_SCREEN = getTextureFromHD('test_screen.jpg', p);
        p.END_SCREEN = getTextureFromHD('end_screen.jpg', p);
        p.BLOCK_END_SCREEN = getTextureFromHD('block_end_screen.jpg', p);
        p.CATEGOR_NATURAL_LEFT_SCREEN = getTextureFromHD('categor_natural_left_screen.jpg', p);
        p.CATEGOR_NATURAL_RIGHT_SCREEN = getTextureFromHD('categor_natural_right_screen.jpg', p);
        p.RECOG_SCREEN = getTextureFromHD('recog_screen.jpg', p);
        p.PAS_SCREEN = getTextureFromHD('pas_screen.jpg', p);
        p.FIXATION_SCREEN = getTextureFromHD('fixation_screen.jpg', p);
        p.RESPOND_FASTER_SCREEN = getTextureFromHD('respond_faster_screen.jpg', p);
        p.RETURN_TO_START_POINT_SCREEN = getTextureFromHD('return_start_point_screen.jpg', p);
        p.START_POINT_SCREEN = getTextureFromHD('start_point_screen.jpg', p);
        p.RIGHT_END_POINT_SCREEN = getTextureFromHD('right_end_point_screen.jpg', p);
        p.LEFT_END_POINT_SCREEN = getTextureFromHD('left_end_point_screen.jpg', p);
        p.BLACK_SCREEN = getTextureFromHD('black_screen.jpg', p);
        p.WHITE_SCREEN = getTextureFromHD('white_screen.jpg', p);

        p.NUM_MASKS = 60;
        for mask_i = 1:p.NUM_MASKS
            p.MASKS(mask_i) = getTextureFromHD(['mask' num2str(mask_i) '.jpg'], p);
        end

        p.MIDDLE_POINT_SCREEN = getTextureFromHD('middle_point_screen.jpg', p);
        
        global text
        Screen('TextFont',p.w, char(p.FONT_TYPE));
        Screen('TextStyle', p.w, 0);
        text.Color = p.FONT_COLOR; %black
    end
    
    p.NUMBER_OF_ERRORS_PROMPT = 3;
    p.TIME_SHOW_PROMPT = 1; % seconds
    
    p.NUM_BLOCKS = 12;
    p.BLOCK_SIZE = 40; % has to be a multiple of 4.
    p.NUM_TRIALS = p.NUM_BLOCKS*p.BLOCK_SIZE;
    
    % duration in sec
    p.FIX_DURATION = 1;
    p.MASK1_DURATION = 0.27;
    p.MASK2_DURATION = 0.03;
    p.PRIME_DURATION = 0.03;
    p.MASK3_DURATION = 0.03;
    p.TARGET_DURATION = 0.5;
    
    % data structure.
    p.CODE_OUTPUT_EXPLANATION = readtable('Code_Output_Explanation.xlsx');
    % word lists.
    p.NAT_TARGETS = readtable([p.STIM_FOLDER '/word_lists/nat_targets.xlsx']);
    p.ART_TARGETS = readtable([p.STIM_FOLDER '/word_lists/art_targets.xlsx']);
    p.ART_PRIMES = readtable([p.STIM_FOLDER '/word_lists/art_primes.xlsx']);
    p.NAT_PRIMES = readtable([p.STIM_FOLDER '/word_lists/nat_primes.xlsx']);
    p.WORD_LIST = readtable([p.STIM_FOLDER '/word_lists/word_freq_list.xlsx']);
    p.WORD_LIST = p.WORD_LIST(:,[1,3]); % Remove word frequencies.
    
    if height(p.WORD_LIST)*2 < p.BLOCK_SIZE % *2 because we have 2 comulns.
        error('Word list must be at least as big as block size to prevent words from repeting in the same block');
    end    
    
    % Output data structure.
    p.VARIABLE_NAMES = p.CODE_OUTPUT_EXPLANATION.Properties.VariableNames;
    % output that has many rows per trial.
    p.MULTI_ROW_VARS = {'target_x_to','target_y_to','target_z_to','target_timecourse_to',...
        'target_x_from','target_y_from','target_z_from','target_timecourse_from',...
        'prime_x_to','prime_y_to','prime_z_to','prime_timecourse_to',...
        'prime_x_from','prime_y_from','prime_z_from','prime_timecourse_from'};
    [~,p.MULTI_ROW_VARS_I] = ismember(p.MULTI_ROW_VARS, p.VARIABLE_NAMES);
    multi_row_logical_index = zeros(1,length(p.VARIABLE_NAMES));
    multi_row_logical_index(p.MULTI_ROW_VARS_I) = 1;
    % output data that has 1 row per trial. used in saveToFile.m.
    p.ONE_ROW_VARS = p.VARIABLE_NAMES(~multi_row_logical_index);
    [~,p.ONE_ROW_VARS_I] = ismember(p.ONE_ROW_VARS, p.VARIABLE_NAMES);
end