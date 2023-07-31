% psychtoolbox_active - Some parameters can only be initiated after psychtoolbox was activated.    
% list_type - 'practice'/'test'. Used when generating new trials lists. Default is 'test'.
function [p] = initConstants(psychtoolbox_active, list_type, p)

    % Setup
    p.SITTING_DISTANCE = 60; % in cm.
    p.SCREEN_DIST = 0.35; %from start point, in meter.
    p.VIEW_ANGLE_X = 2.5; % in deg.
    p.VIEW_ANGLE_Y = 1;
    p.FINGER_SIZE = 0.007; %in meter.
    p.START_POINT_RANGE = 0.01; %3D distance (in meter) from start point which counts as finger in start point.
    
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
    p.EXP_FOLDER = [curr_path];
    p.STIM_FOLDER = [p.EXP_FOLDER '/../stimuli/'];
    p.DATA_FOLDER = [p.EXP_FOLDER '/../../../raw_data/'];
    p.PROC_DATA_FOLDER = [p.EXP_FOLDER '/../../../analysis/processed_data/']; % preprocessed data folder.
    p.TRIALS_FOLDER = [p.STIM_FOLDER '/trial_lists/'];
    p.DATA_FOLDER_WIN = replace(p.DATA_FOLDER, '/', '\');
    p.TESTS_FOLDER = [p.EXP_FOLDER '/./tests/test_results/'];
    
    if psychtoolbox_active
        % Response time constraints of reaching.
        p.REACT_TIME = 0.320; % Maximal allowed time to movement onset (in sec).
        p.MIN_REACT_TIME = 0.100; % Faster mvmnts are considered predictive (planned before target display).
        p.MOVE_TIME = 0.420; % Maximal allowed movement time (in sec).
        p.REACH_RECOG_RT_LIMIT_SEC = 7; % Trajectory recording length in sec.
        p.REACH_CATEGOR_RT_LIMIT_SEC = p.REACT_TIME + p.MOVE_TIME; % in sec.
        p.REACH_RECOG_RT_LIMIT = p.REACH_RECOG_RT_LIMIT_SEC * p.REF_RATE_HZ; % Trajectory capture length (num of samples).
        p.REACH_CATEGOR_RT_LIMIT = p.REACH_CATEGOR_RT_LIMIT_SEC * p.REF_RATE_HZ;
        p.REACH_MAX_RT_LIMIT = max(p.REACH_RECOG_RT_LIMIT, p.REACH_CATEGOR_RT_LIMIT); % In samples.
        p.REACT_TIME_SAMPLES = p.REACT_TIME * p.REF_RATE_HZ;
        p.MIN_REACT_TIME_SAMPLES = p.MIN_REACT_TIME * p.REF_RATE_HZ;
        p.MOVE_TIME_SAMPLES = p.MOVE_TIME * p.REF_RATE_HZ;
        % Reponse time constraints of keyboard.
        p.KEYBOARD_MIN_RT_LIMIT_SEC = 0.100; % In seconds.
        p.KEYBOARD_RECOG_RT_LIMIT_SEC = 7; % RT limit for recognition task.
        p.KEYBOARD_CATEGOR_RT_LIMIT_SEC = 0.740; % RT limit for categorization task.
        
        % Response keys.
        KbName('UnifyKeyNames');
        p.RIGHT_KEY      =  KbName('Y');
        p.LEFT_KEY       =  KbName('E');
        p.ABORT_KEY1     =  KbName('ESCAPE'); % ESC + q aborts experiment
        p.ABORT_KEY2     =  KbName('Q'); % ESC + q aborts experiment
        p.ONE           =  KbName('1!');  % I did not see the phrase
        p.TWO           =  KbName('2@');  % I had a vague perception, but I don?t know what it was
        p.THREE         =  KbName('3#');  % I saw a clear part of the phrase
        p.FOUR          =  KbName('4$');  % I saw the entire phrase clearly
        p.SPACE_KEY      =  KbName('space');
        p.S_KEY      =  KbName('S');
        p.A_KEY      =  KbName('A');
        p.B_KEY      =  KbName('B');
        p.T_KEY      =  KbName('T');
        p.WRONG_KEY = 997;
        % number assigned to left/right response.
        p.RIGHT = 0;
        p.LEFT = 1;

        % Experiment slides.
        % "natural" category is on the left for odd sub numbers.
        if rem(p.SUB_NUM, 2); side = 'left'; else; side = 'right'; end
        % Initialized before experiment starts.
        p.CATEGOR_TXTR                = getTextureFromHD(['categor_natural_' side '_screen.jpg'], p);
        p.FIXATION_TXTR               = getTextureFromHD(['fixation_natural_' side '_screen.jpg'], p);
        % Initialized during experiment.
        p.WELCOME_SCREEN = 'welcome_screen.jpg';
        p.LOADING_SCREEN = 'loading_screen.jpg';
        p.FIRST_INSTRUCTIONS_SCREEN = 'first_instructions_screen.jpg';
        p.PRACTICE_SCREEN = 'practice_screen.jpg';
        p.TEST_SCREEN = 'test_screen.jpg';
        p.END_SCREEN = 'end_screen.jpg';
        p.BLOCK_END_SCREEN = 'block_end_screen.jpg';
        p.START_POINT_SCREEN = 'start_point_screen.jpg';
        p.RIGHT_END_POINT_SCREEN = 'right_end_point_screen.jpg';
        p.LEFT_END_POINT_SCREEN = 'left_end_point_screen.jpg';
        p.BLACK_SCREEN = 'black_screen.jpg';
        p.WHITE_SCREEN = 'white_screen.jpg';
        p.NUM_MASKS = 60;
        for mask_i = 1:p.NUM_MASKS
            p.MASKS(mask_i) = string(['/masks/mask' num2str(mask_i) '_natural_' side '.jpg']);
        end
        p.MIDDLE_POINT_SCREEN = 'middle_point_screen.jpg';
        p.SAVING_DATA_SCREEN = 'saving_data_screen.jpg';
        p.ALIGNMENT_SCREEN = 'alignment_screen.jpg';
        p.TRIAL_EXAMPLE_SCREEN = 'trial_example_screen.jpg';
        p.SECOND_INSTRUCTIONS_SCREEN = 'second_instructions_screen.jpg';
        p.SPEED_PRACTICE_SCREEN = 'speed_practice_screen.jpg';
        p.PAS_SCREEN = 'pas_screen.jpg';
        p.RECOG_SCREEN = 'recog_screen.jpg';
        p.RTRN_START_POINT_SCREEN = 'return_start_point_screen.jpg';
        p.LATE_RES_SCREEN = 'late_res_screen.jpg';
        p.SLOW_MVMNT_SCREEN = 'slow_mvmnt_screen.jpg';
        p.EARLY_RES_SCREEN = 'early_res_screen.jpg';
        p.WRONG_ANS_SCREEN = 'wrong_ans_screen.jpg';
        p.BETWEEN_SESSIONS_SCREEN = 'between_sessions_screen.jpg';
        p.PRESS_SPACE_TO_CONTINUE = 'press_space_to_continue_screen.jpg';
        p.REACH_RESPONSE_EXPLANATION = 'reach_response_explanation_screen.jpg';
        p.KEYBOARD_RESPONSE_EXPLANATION = 'keyboard_response_explanation_screen.jpg';
        p.TIMING_SCREEN = 'timing_screen.jpg';
        
        % Text
        Screen('TextFont',p.w, char(p.FONT_TYPE));
        Screen('TextStyle', p.w, 0);
        p.text.Color = p.FONT_COLOR; %black
    end
    
    p.NUMBER_OF_ERRORS_PROMPT = 3;
    p.TIME_SHOW_PROMPT = 1; % seconds
    
    p.NUM_BLOCKS = 6;
    if isequal(list_type, 'practice') % The is relevant when generating a practice block.
        p.NUM_BLOCKS = 1;
    end
    p.BLOCK_SIZE = 40; % has to be a multiple of 4.
    p.NUM_TRIALS = p.NUM_BLOCKS*p.BLOCK_SIZE;
    p.N_CATEGOR = 2; % Num of word categories (2 = natural / artificial).
    p.CONDS = ["con" "incon"];
    p.N_CONDS = length(p.CONDS); % Conditions: Same/Diff.
    
    % duration in sec
    p.FIX_DURATION = 1;
    p.MASK1_DURATION = 0.27;
    p.MASK2_DURATION = 0.03;
    p.PRIME_DURATION = 0.03;
    p.MASK3_DURATION = 0.03;
    p.TARGET_DURATION = 0.5;
    p.TARGET_DURATION_SAMPLES = p.TARGET_DURATION * p.REF_RATE_HZ;
    p.MSG_DURATION = 0.7;
    p.PAUSE_DURATION = 0.5;
    
    % data structure.
    p.CODE_OUTPUT_EXPLANATION = readtable('Code_Output_Explanation.xlsx');
    % word lists.
    p.NAT_TARGETS = readtable([p.STIM_FOLDER '/word_lists/' list_type '_nat_targets_' p.DAY '.xlsx']);
    p.ART_TARGETS = readtable([p.STIM_FOLDER '/word_lists/' list_type '_art_targets_' p.DAY '.xlsx']);
    p.ART_PRIMES = readtable([p.STIM_FOLDER '/word_lists/' list_type '_art_primes_' p.DAY '.xlsx']);
    p.NAT_PRIMES = readtable([p.STIM_FOLDER '/word_lists/' list_type '_nat_primes_' p.DAY '.xlsx']);
    p.WORD_LIST = readtable([p.STIM_FOLDER '/word_lists/' list_type '_word_freq_list_' p.DAY '.xlsx']);
    p.WORD_LIST = p.WORD_LIST(:,[1,3]); % Remove word frequencies.
    
    if height(p.WORD_LIST)*2 < p.BLOCK_SIZE % *2 because we have 2 comulns in word_list file.
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
    
    %% Analysis params.
    % Missing data restrictions.
    p.MIN_SAMP_LEN = 0.1; % in sec.
    p.MAX_MISSING_DATA = 0.1; % in sec.
    p.MIN_GOOD_TRIALS = 60; % Total, across conditions.
    p.MAX_BAD_TRIALS = p.NUM_TRIALS - p.MIN_GOOD_TRIALS; % sub with more bad trials is disqualified.
    p.MIN_AMNT_TRIALS_IN_COND = 25; % sub with less good trials in each condition is disqualified.
    p.SIG_PVAL = 0.05; % Significance threshold for P-values (smaller p-vals are significant).
    
    % Cameras
    p.SAMPLE_RATE_HZ = p.REF_RATE_HZ; % Camera sample rate in Hz.
    p.SAMPLE_RATE_SEC = 1 / p.SAMPLE_RATE_HZ; % Sec
    
    % Lowpass filter
    p.TRAJ_FILT_ORDER = 2;
    p.TRAJ_FILT_CUTOFF = 8;% in Hz.
                            % originaly in paper dual pass: [8, 12]. To use dual, add 'stop' input to butter in lowpass.m
    p.VEL_FILTER_ORDER = 2;
    p.VEL_FILTER_CUTOFF = 10;% in Hz.
    
    % Reach distance.
    p.MAX_DIST_FROM_SCREEN = 0.03; %that is still considered as "touch" in analysis. in meter. This compensates for inaccuracies in the setup (if the startpoint isn't exactly 35cm fomr the screen).
    p.MIN_REACH_DIST = p.SCREEN_DIST - p.MAX_DIST_FROM_SCREEN; % trials with shorter reaches will be discarded.
    p.DIST_BETWEEN_TARGETS = 0.20; % In meter.
    p.TARGET_MISS_RANGE = 0.12; %Touches outside this radius of the target (circle flat on screen, centered on target),
                                % are disqualified from analysis.
end