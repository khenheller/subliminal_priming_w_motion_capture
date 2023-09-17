% Some parameters might change between running the exp and analyzing its results.
% This function loads the parameters values that were set when the exp was run and adjusts some of them for the analysis to work.
function p = defineParams(p, iSub)
    p.DATA_FOLDER = '../../raw_data/';

    % Save prev values.
    SIM_NUM_BLOCKS = p.NUM_BLOCKS;
    SIMULATE = p.SIMULATE;
    NORMALIZE_WITHIN_SUB = p.NORMALIZE_WITHIN_SUB;
    NORM_TRAJ = p.NORM_TRAJ;
    MIN_SAMP_LEN = p.MIN_SAMP_LEN;
    MIN_TRIM_FRAMES = p.MIN_TRIM_FRAMES;
    EXP_1_SUBS = p.EXP_1_SUBS;
    EXP_2_SUBS = p.EXP_2_SUBS;
    EXP_3_SUBS = p.EXP_3_SUBS;
    EXP_4_SUBS = p.EXP_4_SUBS;
    EXP_4_1_SUBS = p.EXP_4_1_SUBS;
    SIM_SUBS = p.SIM_SUBS;
    SUBS = p.SUBS;
    ORIG_SUBS = p.ORIG_SUBS;
    DAY = p.DAY;

    p = load([p.DATA_FOLDER '/sub' num2str(iSub) DAY '_' 'p.mat']); p = p.p;
    p.SIMULATE = SIMULATE;
    p.NORMALIZE_WITHIN_SUB = NORMALIZE_WITHIN_SUB;
    p.NORM_TRAJ = NORM_TRAJ;
    p.MIN_SAMP_LEN = MIN_SAMP_LEN;
    p.MIN_TRIM_FRAMES = MIN_TRIM_FRAMES;
    % Paths.
    [curr_path, ~, ~] = fileparts(mfilename('fullpath'));
    curr_path = replace(curr_path, '\', '/');
    p.EXP_FOLDER = [curr_path '/../../experiment/RUN_ME/code'];
    p.STIM_FOLDER = [p.EXP_FOLDER '/../stimuli/'];
    p.DATA_FOLDER = [p.EXP_FOLDER '/../../../raw_data/'];
    p.PROC_DATA_FOLDER = [p.EXP_FOLDER '/../../../analysis/processed_data/']; % preprocessed data folder.
    p.TRIALS_FOLDER = [p.STIM_FOLDER '/trial_lists/'];
    p.DATA_FOLDER_WIN = replace(p.DATA_FOLDER, '/', '\');
    p.TESTS_FOLDER = [p.EXP_FOLDER '/./tests/test_results/'];
    % Subjects
    p.EXP_1_SUBS = EXP_1_SUBS;
    p.EXP_2_SUBS = EXP_2_SUBS;
    p.EXP_3_SUBS = EXP_3_SUBS;
    p.EXP_4_SUBS = EXP_4_SUBS;
    p.EXP_4_1_SUBS = EXP_4_1_SUBS;
    p.SIM_SUBS = SIM_SUBS;
    p.SUBS = SUBS;
    p.ORIG_SUBS = ORIG_SUBS;
    p.SUBS_STRING = regexprep(num2str(p.SUBS), '\s+', '_'); % Concatenate sub's numbers with '_' between them.
    p.DAY = DAY;
    p.N_SUBS = length(p.SUBS);
    p.MAX_SUB = max(p.SUBS);
    % Normalization params.
    p.TRAJ_FILT_ORDER = 2;
    p.TRAJ_FILT_CUTOFF = 8;% in Hz.
    p.VEL_FILTER_ORDER = 2;
    p.VEL_FILTER_CUTOFF = 10;% in Hz.
    p.NORM_FRAMES = 200; % length of normalized trajs.
    p.NORM_TYPE = 4; % 1=to time, 2=to x, 3=to y, 4=to z.

    % Reach dist: Subs 1-10 = 40cm, Subs 10-25 = 35cm.
    % Recog cap length: Subs 1-10 = 5sec, Subs 10-25 = 7sec.
    % Categor cap length: Subs 1-10 = 1.5sec, Subs 10-25 = 0.75sec.
    % Subs 10-25 have 1 day, Subs 26 onword have 2 days of experiment.
    if all(p.ORIG_SUBS <= 10)
        p.SCREEN_DIST = 0.4;
        p.RECOG_CAP_LENGTH_SEC = 5;
        p.CATEGOR_CAP_LENGTH_SEC = 1.5;
    elseif all(p.ORIG_SUBS > 10) & all(p.ORIG_SUBS <= 25)
        p.SCREEN_DIST = 0.35;
        p.RECOG_CAP_LENGTH_SEC = 7;
        p.CATEGOR_CAP_LENGTH_SEC = 0.75;
    elseif all(p.ORIG_SUBS > 25)
        p.SCREEN_DIST = 0.35;
        p.RECOG_CAP_LENGTH_SEC = 7;
        p.CATEGOR_CAP_LENGTH_SEC = 0.74;
    else
        error('Please analyze subs of each experiment seperatly.');
    end
    p.MIN_REACH_DIST = p.SCREEN_DIST - p.MAX_DIST_FROM_SCREEN; % exp2=0.3 exp3=0.32
    % Distances.
    p.DIST_BETWEEN_TARGETS = 0.20; % In meter.
    p.TARGET_MISS_RANGE = 0.12; % In meter.

    % Recording length.
    p.RECOG_CAP_LENGTH = p.RECOG_CAP_LENGTH_SEC * p.REF_RATE_HZ; % Trajectory capture length (num of samples).
    p.CATEGOR_CAP_LENGTH = p.CATEGOR_CAP_LENGTH_SEC * p.REF_RATE_HZ;
    p.MAX_CAP_LENGTH = max(p.RECOG_CAP_LENGTH, p.CATEGOR_CAP_LENGTH);
    
    % RT lmitations.
    % React_time, Move_time doesn't exist in subs 1-10.
    if all(p.ORIG_SUBS <= 10)
        p.REACT_TIME = 1.5;
        p.MOVE_TIME = 1.5;
        p.MIN_REACT_TIME = 0;
    % Minimal react time doesn't exist in subs 11-25. Neither does max reaction time.
    elseif all(p.ORIG_SUBS > 10 & p.ORIG_SUBS <= 25)
        p.MIN_REACT_TIME = 0;
        p.REACH_MAX_RT_LIMIT = max(p.REACH_RECOG_RT_LIMIT, p.REACH_CATEGOR_RT_LIMIT);
    end
    p.MIN_REACT_TIME_SAMPLES = p.MIN_REACT_TIME * p.REF_RATE_HZ;
    p.REACT_TIME_SAMPLES = p.REACT_TIME * p.REF_RATE_HZ;
    p.MOVE_TIME_SAMPLES = p.MOVE_TIME * p.REF_RATE_HZ;

    % Number of trials.
    if p.SIMULATE == 1 % Use simulated num of blocks.
        p.NUM_BLOCKS = SIM_NUM_BLOCKS;
    end
    p.NUM_TRIALS = p.NUM_BLOCKS * p.BLOCK_SIZE;
    p.MIN_AMNT_TRIALS_IN_COND = 25; % sub with less good trials in each condition (same/diff) is disqualified.
    p.MIN_GOOD_TRIALS = p.MIN_AMNT_TRIALS_IN_COND * 2; % Total, regardless of condition.
    p.MAX_BAD_TRIALS = p.NUM_TRIALS - p.MIN_GOOD_TRIALS; % sub with more bad trials is disqualified.

    % Conditions.
    p.CONDS = ["con" "incon"];
    p.N_CONDS = length(p.CONDS); % Conditions: Same/Diff.

    % Hypothesis testing.
    p.SIG_PVAL = 0.05;

    % Which exp is run.
    if isequal(p.ORIG_SUBS, p.EXP_1_SUBS)
        p.EXP = 'exp1';
    elseif isequal(p.ORIG_SUBS, p.EXP_2_SUBS)
        p.EXP = 'exp2';
    elseif isequal(p.ORIG_SUBS, p.EXP_3_SUBS)
        p.EXP = 'exp3';
    elseif isequal(p.ORIG_SUBS, p.EXP_4_SUBS)
        p.EXP = 'exp4';
    elseif isequal(p.ORIG_SUBS, p.EXP_4_1_SUBS)
        p.EXP = 'exp4_1';
    elseif isequal(p.ORIG_SUBS, p.SIM_SUBS)
        p.EXP = 'exp_sim';
    else
        error('Please analyze subs of each experiment seperatly.');
    end
end