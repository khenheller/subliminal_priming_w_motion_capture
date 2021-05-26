% prevents display of some warnings.
warning('off','MATLAB:table:PreallocateCharWarning');
warning('OFF', 'MATLAB:table:ModifiedAndSavedVarnames');

clc; 
clear all;
close all;
addpath('.\NatNetSDK');

% Parameter definit1ion.
p.SUB_NUM = 1014;
  
p.FULLSCREEN = 1;
p.DEBUG = 0;
%% -------------------------- Align screen --------------------------------
% alignScreen(p);
%% -------------------------- Run Experiment ------------------------------
p = main(p);
save('p.mat', 'p');
%% -------------------------- Generate trial lists ------------------------
% global p.FULLSCREEN
% p.FULLSCREEN = true; % default = true
% num_trial_lists = 10;
% genTrialLists(num_trial_lists);
%% -------------------------- Generate Masks ------------------------------
% @@@@@@@@ Make new masks if sitting distance changes @@@@@@@@@@@@@@
% n_masks = 3;
% makeMasks(n_masks, p, 'left')
% makeMasks(n_masks, p, 'right')
% disp("--- Done generating masks! ---");
% close all;