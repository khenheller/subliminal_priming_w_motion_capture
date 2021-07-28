clc;
clear all;
close all;
load('../p.mat');
warning('OFF', 'MATLAB:DELETE:FileNotFound');
TEST_RES_FOLDER = './test_results/';
DATA_FOLDER = '../../../../raw_data/';
STIM_FOLDER = '../stimuli/';
TRIALS_LISTS_FOLDER = [STIM_FOLDER 'trial_lists/'];
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
% READ ME: if you aren't Khen, set i_m_khen in timingTest.m to 0!
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
% To test sub data enter his number.
sub_num = [1 2 3 4 5 6 7 8 9 10];
% To test word list enter its name.
word_list = 'practice_wo_prime_trials.xlsx';
% Are you testing 'data' of a subject, or just a 'trials_list', or a 'practice_trials_list'.
test_type = 'data';
for iSub = sub_num
    % Tests data.
    if isequal(test_type, 'data')
        trials = readtable([DATA_FOLDER 'sub' num2str(iSub) 'data.csv']);
        trials_traj = readtable([DATA_FOLDER 'sub' num2str(iSub) 'traj.csv']);
        diary_name = [TEST_RES_FOLDER 'sub' num2str(iSub) '.txt'];
    % Tests trial_list.
    else
        trials = readtable([TRIALS_LISTS_FOLDER word_list]);
        trials_traj = [];
        diary_name = [TEST_RES_FOLDER strrep(word_list,'.xlsx','') '.txt'];
    end
    
    % Delete prev test data.
    delete([TEST_RES_FOLDER 'sub' num2str(iSub) '.mat']);
    delete(diary_name);
    
    % Log results to file.
    diary(diary_name);
    [pass_test, test_res] = tests(trials, trials_traj, test_type, p);
    diary off;

    save([TEST_RES_FOLDER 'sub' num2str(iSub) '.mat'], 'test_res');
end
