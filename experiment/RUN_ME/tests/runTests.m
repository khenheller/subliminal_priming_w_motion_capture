clc;
clear all;
close all;
load('../p.mat');
sub_num = '9';
trials = readtable(['../../../raw_data/sub' sub_num 'data.csv']);
trials_traj = readtable(['../../../raw_data/sub' sub_num 'traj.csv']);
type = 'data';
% Log results to file.
diary(['./test_results/sub' sub_num '.txt']);
pass_test = tests(trials, trials_traj, type, p);
diary off;