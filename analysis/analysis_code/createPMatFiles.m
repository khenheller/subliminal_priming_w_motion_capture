%@@@@@@@@@@@@@@@@@@@@@
% I started creating this because I needed a subXday2_p.mat file for subs 1-10,
% but then I relaized their subXday2_start_end_points.mat is that file, So I stoped writing this.
% Sub 1 didn't have a subXday2_start_end_points.mat file so I used sub 2's file.
%@@@@@@@@@@@@@@@@@@@@@

% Creates a "subXday2_p.mat" file for each subject in dest_subs by copying the
% "subXday2_p.mat" file of src_sub and adapting some of the fields.
% dest_subs - array of sub nums.
% src_sub - sub num to take copy subXday2_p.mat file from.
clear all;
clc;

% Define the following:
src_sub = 11;
dest_subs = [1 2 3 4 5 6 7 8 9 10];
DATA_FOLDER = 'D:/university/mudrick_lab/subliminal_priming_w_motion_capture/raw_data/';
FINGER_SIZE = 0.03;
REF_RATE_HZ = 100;
MOVE_TIME = 1.5;
MOVE_TIME_SAMPLES = MOVE_TIME * REF_RATE_HZ;
RECOG_CAP_LENGTH_SEC = 5;
RECOG_CAP_LENGTH = RECOG_CAP_LENGTH_SEC * REF_RATE_HZ;
CATEGOR_CAP_LENGTH_SEC = 1.5;
CATEGOR_CAP_LENGTH = CATEGOR_CAP_LENGTH_SEC * REF_RATE_HZ;
MAX_CAP_LENGTH = max([CATEGOR_CAP_LENGTH, RECOG_CAP_LENGTH]);
SCREEN_DIST = 0.4;
MAX_DIST_FROM_SCREEN = 0.03; %that is still considered as "touch" in analysis. in meter. This compensates for inaccuracies in the setup (if the startpoint isn't exactly 35cm fomr the screen).
MIN_REACH_DIST = SCREEN_DIST - MAX_DIST_FROM_SCREEN;
TARGET_MISS_RANGE = 0.12;

SRC_FILE = [DATA_FOLDER 'sub' num2str(src_sub) 'day2_p.mat'];

% Load p variable (contains all the parameters).
src_p = load(SRC_FILE);  src_p = src_p.p;

for iSub = dest_subs

    dest_file = [DATA_FOLDER 'sub' num2str(iSub) 'day2_p.mat'];
    % Delete file if it already exists.
    if isfile(dest_file)
        delete(dest_file);
    end

    % Copy p variable.
    new_p = src_p;

    % Load sub's starting points.
    points = load([DATA_FOLDER 'sub' num2str(iSub) 'day2_start_end_points.mat']);

    % Adapt fields.
    new_p.SUB_NUM = iSub;
    new_p.FINGER_SIZE = FINGER_SIZE;
    new_p.MOVE_TIME = MOVE_TIME;
    new_p.MOVE_TIME_SAMPLES = MOVE_TIME_SAMPLES;
    new_p.RECOG_CAP_LENGTH_SEC = RECOG_CAP_LENGTH_SEC;
    new_p.RECOG_CAP_LENGTH = RECOG_CAP_LENGTH;
    new_p.CATEGOR_CAP_LENGTH_SEC = CATEGOR_CAP_LENGTH_SEC;
    new_p.CATEGOR_CAP_LENGTH = CATEGOR_CAP_LENGTH;
    new_p.MAX_CAP_LENGTH = MAX_CAP_LENGTH;
    new_p.SCREEN_DIST = SCREEN_DIST;
    new_p.MAX_DIST_FROM_SCREEN = MAX_DIST_FROM_SCREEN;
    new_p.MIN_REACH_DIST = MIN_REACH_DIST;
    new_p.TARGET_MISS_RANGE = TARGET_MISS_RANGE;
    new_p.START_POINT = points.START_POINT;
    new_p.RIGHT_END_POINT = points.RIGHT_END_POINT;
    new_p.LEFT_END_POINT = points.LEFT_END_POINT;
    new_p.MIDDLE_POINT = points.MIDDLE_POINT;

    % Save new p.mat file.
    p = new_p;
    save(dest_file, 'p');
end