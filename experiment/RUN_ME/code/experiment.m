% prevents display of some warnings.
warning('off','MATLAB:table:PreallocateCharWarning');
warning('OFF', 'MATLAB:table:ModifiedAndSavedVarnames');
 
clc;
clear all;
close all;
addpath('.\NatNetSDK');

% Parameter definition.
p.SUB_NUM = 999;
p.DAY = 'day2';

p.FULLSCREEN = 1;
p.DEBUG = 0;
%% -------------------------- Align screen --------------------------------
% alignScreen(p);
%% -------------------------- Run Experiment ------------------------------
p = main(p);
save('p.mat', 'p');
%% -------------------------- Generate trial lists ------------------------
% p = load('./p.mat'); p = p.p;
% p.DAY = 'day2';
% num_trial_lists = 20;
% list_type = 'test';
% genTrialLists(num_trial_lists, list_type, p);
%% -------------------------- Generate Masks ------------------------------
% @@@@@@@@ Make new masks if sitting distance changes @@@@@@@@@@@@@@
% n_masks = 3;
% makeMasks(n_masks, p, 'left')
% makeMasks(n_masks, p, 'right')
% disp("--- Done generating masks! ---");
% close all;