 % prevents display of some warnings.
warning('off','MATLAB:table:PreallocateCharWarning');
warning('OFF', 'MATLAB:table:ModifiedAndSavedVarnames');

clc;
clear all;
addpath('.\NatNetSDK');

% Parameter definit1ion.1
subNumber = 999;
global sittingDistance viewAngleX viewAngleY
sittingDistance = 60; % in cm.
viewAngleX = 2.5; % in deg.
viewAngleY = 1;
% -------------------------- Run Experiment -------------------------------
main(subNumber);
% -------------------------- Generate trial lists --------------------------
% global NO_FULLSCREEN
% NO_FULLSCREEN = false; % default = false
% num_trial_lists = 10;
% genTrialLists(num_trial_lists);
% -------------------------- Generate Masks -------------------------------
% @@@@@@@@ Make new masks if sitting distance changes @@@@@@@@@@@@@@
% makeMasks(60)
% -------------------------- Draw result -------------------------------
% close all
% clc
% 
% global NUM_TRIALS
% global RECOG_RECORD_LENGTH CATEGOR_RECORD_LENGTH
% global refRateHz
% 
% record_len = 200;%max(RECOG_RECORD_LENGTH, CATEGOR_RECORD_LENGTH) * refRateHz;
% 
% num_practice_trials = 40;
% 
% % Get trails and remove practice.
% trials_traj = readtable('./data/sub9993traj.csv');
% trials_data = readtable('./data/sub9993data.csv');
% trials_traj(trials_traj.practice == 1,:) = [];
% trials_data(trials_data.practice == 1,:) = [];
% 
% % Seperate same and diff.
% same_trials_data = trials_data(trials_data.same == 1, :);
% same_trials_traj = trials_traj(ismember(trials_traj.iTrial, same_trials_data.iTrial), :);
% diff_trials_data = trials_data(~trials_data.same == 1, :);
% diff_trials_traj = trials_traj(~ismember(trials_traj.iTrial, same_trials_data.iTrial), :);
% 
% for trial = 1:NUM_TRIALS/2
%     plot3(same_trials_traj.target_x_to(1:record_len), same_trials_traj.target_z_to(1:record_len), same_trials_traj.target_y_to(1:record_len), 'LineWidth',3, 'color','b')
%     hold on;
%     plot3(diff_trials_traj.target_x_to(1:record_len), diff_trials_traj.target_z_to(1:record_len), diff_trials_traj.target_y_to(1:record_len), 'LineWidth',3, 'color','r')
%     
%     same_trials_traj(1:record_len, :) = [];
%     diff_trials_traj(1:record_len, :) = [];
% end
%     
%     
% plot3(traject.target_x_to(1:1000), traject.target_z_to(1:1000), traject.target_y_to(1:1000), 'LineWidth',5, 'color','b')
% hold on
% plot3(traject.target_x_to(1001:2000), traject.target_z_to(1001:2000), traject.target_y_to(1001:2000), 'LineWidth',5, 'color','b')
% plot3(traject.target_x_to(2001:3000), traject.target_z_to(2001:3000), traject.target_y_to(2001:3000), 'LineWidth',5, 'color','b')
% plot3(traject.target_x_to(3001:4000), traject.target_z_to(3001:4000), traject.target_y_to(3001:4000), 'LineWidth',5, 'color','b')
% 
% plot3(traject.target_x_from(1:1000), traject.target_z_from(1:1000), traject.target_y_from(1:1000), 'LineWidth',5, 'color','r')
% plot3(traject.target_x_from(1001:2000), traject.target_z_from(1001:2000), traject.target_y_from(1001:2000), 'LineWidth',5, 'color','r')
% plot3(traject.target_x_from(2001:3000), traject.target_z_from(2001:3000), traject.target_y_from(2001:3000), 'LineWidth',5, 'color','r')
% plot3(traject.target_x_from(3001:4000), traject.target_z_from(3001:4000), traject.target_y_from(3001:4000), 'LineWidth',5, 'color','r')
% 
% xlabel('X'); ylabel('Z'); zlabel('Y');
% plot3([0 0.53 0.53 0 0],  [0 0 0 0 0], [0 0 0.30 0.30 0], 'LineWidth',3)
