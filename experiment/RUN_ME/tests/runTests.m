clc;
clear all;
close all;
load('../p.mat');
% To test sub data enter his number.
sub_num = '10';
% To test word list enter its name.
word_list = 'practice_wo_prime_trials.xlsx';
% Are you testing 'data' of a subject, or just a 'trials_list', or a 'practice_trials_list'.
type = 'practice_trials_list';
if isequal(type, 'data')
    trials = readtable(['../../../raw_data/sub' sub_num 'data.csv']);
    trials_traj = readtable(['../../../raw_data/sub' sub_num 'traj.csv']);
    diary_name = ['./test_results/sub' sub_num '.txt'];
else
    trials = readtable(['../stimuli/trial_lists/' word_list]);
    trials_traj = [];
    diary_name = ['./test_results/' strrep(word_list,'.xlsx','') '.txt'];
end
% Log results to file.
diary(diary_name);
pass_test = tests(trials, trials_traj, type, p);
diary off;