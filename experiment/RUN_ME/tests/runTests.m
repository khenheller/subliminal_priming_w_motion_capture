clc;
clear all;
close all;
load('../p.mat');
% To test sub data enter his number.
sub_num = [1 2 3 4 5 6 7 8 9 10];
% To test word list enter its name.
word_list = 'practice_wo_prime_trials.xlsx';
% Are you testing 'data' of a subject, or just a 'trials_list', or a 'practice_trials_list'.
type = 'data';
for iSub = sub_num
    % Tests data.
    if isequal(type, 'data')
        trials = readtable(['../../../raw_data/sub' num2str(iSub) 'data.csv']);
        trials_traj = readtable(['../../../raw_data/sub' num2str(iSub) 'traj.csv']);
        diary_name = ['./test_results/sub' num2str(iSub) '.txt'];
    % Tests trial_list.
    else
        trials = readtable(['../stimuli/trial_lists/' word_list]);
        trials_traj = [];
        diary_name = ['./test_results/' strrep(word_list,'.xlsx','') '.txt'];
    end
    % Log results to file.
    diary(diary_name);
    [pass_test, test_res] = tests(trials, trials_traj, type, p);
    diary off;

    save(['./test_results/sub' num2str(iSub) '.mat'], 'test_res');
end
