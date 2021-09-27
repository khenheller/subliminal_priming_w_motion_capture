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
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
% READ ME: if you aren't Khen, set i_m_khen in timingTest.m to 0!
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

% To test sub data enter his number.
sub_num = [26];
% To test word list enter its name.
word_list = 'trials1day1.xlsx';
% Are you testing 'data' of a subject, or just a 'trials_list', or a 'practice_trials_list'.
test_type = 'data';
% Day: 'day1' or 'day2'.
test_day = 'day2';

for iSub = sub_num
    file_name = ['sub' num2str(iSub) test_day];
    % Get data.
    if isequal(test_type, 'data')
        trials = readtable([DATA_FOLDER file_name '_data.csv']);
        trials_traj = readtable([DATA_FOLDER file_name '_traj.csv']);
        diary_name = [TEST_RES_FOLDER file_name '.txt'];
        p = load([DATA_FOLDER file_name '_p.mat']); p = p.p;
    % Get trial_list.
    else
        trials = readtable([TRIALS_LISTS_FOLDER word_list]);
        trials_traj = [];
        diary_name = [TEST_RES_FOLDER strrep(word_list,'.xlsx','') '.txt'];
        p = load('p.mat'); p = p.p;
        p.DAY = 'day1'; disp('@@@Dont need this line after having a p.mat from sub 26 and higher@@@');
        p = initConstants(0,p);
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
    [pass_test, test_res] = tests(trials, trials_traj, test_type, events, desired_durations, test_day, p);
    %@@@@@@@@@@@@@@@@@@@@
    disp('@@@@@@@@@@@@@@@@@ Look Here! @@@@@@@@@@@@@@@@@');
    disp('Make a change in timingsTest.m (marked @with remove@ this) so that the time of target will also be checked.\nYou canceled its check because the getTraj.m didnt display the categor screen after 500ms of target,\n so target timing is always bad');
    disp('@@@@@@@@@@@@@@@@@ Look Here! @@@@@@@@@@@@@@@@@');
    %@@@@@@@@@@@@@@@@@@@@
    diary off;

    save([TEST_RES_FOLDER file_name '.mat'], 'test_res');
end