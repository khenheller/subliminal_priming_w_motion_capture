warning('off','MATLAB:table:PreallocateCharWarning'); % prevents display of one of the warnings.
warning('OFF', 'MATLAB:table:ModifiedAndSavedVarnames');
clc;
clear all;

% Parameter definition.
subNumber = 123123;
global sittingDistance viewAngleX viewAngleY
sittingDistance = 50; % in cm.
viewAngleX = 2.5; % in deg.
viewAngleY = 1;

main(subNumber) 
% @@@@@@@@@ Make new masks if sitting distance changes @@@@@@@@@@@@@@
% makeMasks(3)