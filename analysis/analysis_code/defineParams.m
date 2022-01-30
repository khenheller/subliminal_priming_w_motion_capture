% SORTED_SUBS - subjects sorted according to the version of the experiment they participated in.
function p = defineParams(p, SUBS, DAY, iSub, SORTED_SUBS)
    p.DATA_FOLDER = '../../raw_data/';

    p = load([p.DATA_FOLDER '/sub' num2str(iSub) DAY '_' 'p.mat']); p = p.p;
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
    p.EXP_1_SUBS = SORTED_SUBS.EXP_1_SUBS;
    p.EXP_2_SUBS = SORTED_SUBS.EXP_2_SUBS;
    p.EXP_3_SUBS = SORTED_SUBS.EXP_3_SUBS;
    p.SUBS = SUBS;
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
    if all(p.SUBS <= 10)
        p.SCREEN_DIST = 0.4;
        p.RECOG_CAP_LENGTH_SEC = 5;
        p.CATEGOR_CAP_LENGTH_SEC = 1.5;
    elseif all(p.SUBS > 10) & all(p.SUBS <= 25)
        p.SCREEN_DIST = 0.35;
        p.RECOG_CAP_LENGTH_SEC = 7;
        p.CATEGOR_CAP_LENGTH_SEC = 0.75;
    elseif all(p.SUBS > 25)
        p.SCREEN_DIST = 0.35;
        p.RECOG_CAP_LENGTH_SEC = 7;
        p.CATEGOR_CAP_LENGTH_SEC = 0.74;
    else
        error('Please analyze subs 1-10, 11-25 and 26-... seperatly.');
    end
    p.MIN_REACH_DIST = p.SCREEN_DIST - p.MAX_DIST_FROM_SCREEN;
    p.DIST_BETWEEN_TARGETS = 0.20; % In meter.
    p.TARGET_MISS_RANGE = 0.12; % In meter.
    p.RECOG_CAP_LENGTH = p.RECOG_CAP_LENGTH_SEC * p.REF_RATE_HZ; % Trajectory capture length (num of samples).
    p.CATEGOR_CAP_LENGTH = p.CATEGOR_CAP_LENGTH_SEC * p.REF_RATE_HZ;
    p.MAX_CAP_LENGTH = max(p.RECOG_CAP_LENGTH, p.CATEGOR_CAP_LENGTH);
    % @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@remove
    p.PROC_DATA_FOLDER = '../processed_data/';
    p.TESTS_FOLDER = '../../experiment/RUN_ME/code/tests/test_results/';
    p.MIN_REACT_TIME_SAMPLES = 10;
    p.MIN_GOOD_TRIALS = 60;
    p.MAX_BAD_TRIALS = p.NUM_TRIALS - p.MIN_GOOD_TRIALS; % sub with more bad trials is disqualified.
    p.MIN_AMNT_TRIALS_IN_COND = 30; % sub with less good trials in each condition (same/diff) is disqualified.
    p.REACT_TIME_SAMPLES = p.REACT_TIME * p.REF_RATE_HZ;
    p.MOVE_TIME_SAMPLES = p.MOVE_TIME * p.REF_RATE_HZ;
    p.SIG_PVAL = 0.05;
    p.CONDS = ["same" "diff"];
    p.N_CONDS = length(p.CONDS); % Conditions: Same/Diff.
    % @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@remove
end