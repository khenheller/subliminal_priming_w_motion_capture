% prevents display of some warnings.
warning('off','MATLAB:table:PreallocateCharWarning');
warning('OFF', 'MATLAB:table:ModifiedAndSavedVarnames');

clc; 
clear all;
addpath('.\NatNetSDK');

% Parameter definition.
subNumber = 9993 ;
global sittingDistance viewAngleX viewAngleY
sittingDistance = 60; % in cm.
viewAngleX = 2.5; % in deg.
viewAngleY = 1;
% -------------------------- Run Experiment -------------------------------
main(subNumber);

% -------------------------- Generate trial lists --------------------------
% num_trial_lists = 10;
% genTrialLists(num_trial_lists);
% -------------------------- Generate Masks -------------------------------
% @@@@@@@@ Make new masks if sitting distance changes @@@@@@@@@@@@@@
% makeMasks(60)

% close all
% clc
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
