clc;
clear all;
close all;
warning('OFF', 'MATLAB:DELETE:FileNotFound');
TESTS_FOLDER = './tests/';
TEST_RES_FOLDER = [TESTS_FOLDER '/test_results/'];
DATA_FOLDER = '../../../raw_data/';
STIM_FOLDER = '../stimuli/';
TRIALS_LISTS_FOLDER = [STIM_FOLDER 'trial_lists/'];
addpath('.\tests');
% Names of the columns containing the event's timestamps.
events = {'fix_time','mask1_time','mask2_time','prime_time','mask3_time','target_time','categor_time'};
% desired_durations - of each event, in sec.
desired_durations = [1 0.270 0.030 0.030 0.030 0.500];

% To test sub data enter his number.
sub_num = [1028];
% To test word list enter its name.
word_list = 'test_trials20day2.xlsx';
list_type = 'test';
% Are you testing 'data' of a subject, or just a 'trials_list'.
test_type = 'data';
% Day: 'day1' or 'day2'.
test_day = 'day2';

if isequal(test_type, 'trials_list')
    sub_num = 1;
end

for iSub = sub_num
    % Get data.
    if isequal(test_type, 'data')
        file_name = ['sub' num2str(iSub) test_day];
        reach_trials = readtable([DATA_FOLDER file_name '_reach_data.csv']);
        reach_trials_traj = readtable([DATA_FOLDER file_name '_reach_traj.csv']);
        keyboard_trials = readtable([DATA_FOLDER file_name '_keyboard_data.csv']);
        diary_name = [TEST_RES_FOLDER file_name '.txt'];
        p = load([DATA_FOLDER file_name '_p.mat']); p = p.p;
    % Get trial_list.
    else
        file_name = word_list;
        reach_trials = readtable([TRIALS_LISTS_FOLDER word_list]);
        trials_traj = [];
        diary_name = [TEST_RES_FOLDER strrep(word_list,'.xlsx','') '.txt'];
        p = load('p.mat'); p = p.p;
        p.DAY = 'day2'; disp('@@@Dont need this line after having a p.mat from sub 26 and higher@@@');
        p = initConstants(0, list_type, p);
    end
    
    % Day1 has no prime, so remove it's columns.
    if test_day == 'day1'
        prime_columns = regexp(trials.Properties.VariableNames', '.*prime.*');
        prime_columns = ~cellfun(@isempty,prime_columns);
        trials(:, prime_columns) = [];
        prime_columns = regexp(trials_traj.Properties.VariableNames', '.*prime.*');
        prime_columns = ~cellfun(@isempty,prime_columns);
        trials_traj(:, prime_columns) = [];
        prime_columns = regexp(events, '.*prime.*');
        prime_columns = ~cellfun(@isempty,prime_columns);
        events(prime_columns) = [];
        desired_durations(prime_columns) = [];
    end
    
    % Delete prev test data.
    delete([TEST_RES_FOLDER file_name '.mat']);
    delete(diary_name);
    
    % Log results to file.
    diary(diary_name);
    
    % Old subs don't have correct parameters.
    if any(sub_num < 26)
        p.N_CATEGOR = 2; % Num of word categories (2 = natural / artificial).
        p.CONDS = ["same" "diff"];
        p.N_CONDS = length(p.CONDS); % Conditions: Same/Diff.
    end
    
    % Tests reaching session.
    disp('@@@@@@@@@@@@@@@@@@@@@@@@@ Testing Reaching session @@@@@@@@@@@@@@@@@@@@@@@@@');
    [reach_pass_test, reach_test_res] = tests(reach_trials, reach_trials_traj, test_type, events, desired_durations, test_day, 1, p);
    % Tests keyboard session.
    disp('@@@@@@@@@@@@@@@@@@@@@@@@@ Testing Keyboard session @@@@@@@@@@@@@@@@@@@@@@@@@');
    [keyboard_pass_test, keyboard_test_res] = tests(keyboard_trials, [], test_type, events, desired_durations, test_day, 0, p);
    diary off;

    save([TEST_RES_FOLDER file_name '.mat'], 'reach_test_res','keyboard_test_res');
end