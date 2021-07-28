%to run this example, you will have to download the FDA scripts from Dr.
%Jim Ramsay's fda site:
%
%ftp://ego.psych.mcgill.ca/pub/ramsay/FDAfuns/Matlab/
%
%make sure you follow the INSTALL.MATLAB.WIN.txt instructions
%
%This script ALSO requires the scripts smoothFDA and evalFDA, which I
%received (and slightly modified) from Dr. Caroline Palmer's lab at McGill:
%
%http://www.mcgill.ca/spl/
%
%with the kind help of her graduate student Janeer Loehr and Erik Koopmans
%- these files are included in the zip folder that contained this example
%function

%the sample trial comes from a recent experiment we conducted (Chapman,
%Gallivan et al, Cognition 116 (2): 168-176) where particpants perform a
%rapid reach toward a single target OR toward two targets. With two
%targets, the final target position is selected only AFTER movement onset.
%NOTE: This trial has already undergone preprocessing and has had any
%missing data filled in (primarily using inpaint_nans, a function available
%on Mathworks forum) has been filtered (lowpass, 10hz) and has had the
%onset and the offset of the reach determined (by velocity criteria) and
%the rest of the data trimmed.
load sampleTrial

%from the normalizeFDA function:
%
%data = cell array where each cell holds the x,y,z (as columns) position
%data for each IR (or tracked marker)

%toNormalize = a list of IRs that you want to normalize - this refers to
%the indexes of the data cell array

%normalizeFrames = number of frames you want for your normalized
%trajectories

%normalizeType
%1 = to time
%2 = to x distance
%3 = to y distance
%4 = to z distance

%frameRate = the frame rate of data collection


%initialize the above arguments for use with the data from sampleTrial
toNormalize = 1; 
normalizeFrames = 200;
normalizeType = 4;
frameRate = 100;

data_length = find(~isnan(current_traj(:,1)), 1, 'last'); data = {current_traj};
data{1} = data{1}(1:data_length,:);
% data{1} = [data{1}(1:data_length,:); NaN(40,3)];

[normalizedReach, normalizedTime] = normalizeFDA(data,toNormalize,normalizeFrames,normalizeType,frameRate);

samprate_sec = (1/p.SAMPLE_RATE);
timestamps = 0 : samprate_sec : (size(data{1}, 1)-1) * samprate_sec;
close all;
figure();
subplot(3,1,1);
plot(timestamps, data{1}(:,1), 'ob');
hold on;
subplot(3,1,2);
plot(timestamps, data{1}(:,2), 'ob');
subplot(3,1,3);
plot(timestamps, data{1}(:,3), 'ob');

%1
subplot(3,1,1);
hold on;
plot(normalizedTime, normalizedReach{1}(:,1), 'LineWidth', 3);
% plot(linspace(1,data_length,normalizeFrames), normalizedReach{1}(:,1));
title("X");
set(gca,'fontsize',14)
legend("original", "fit");
ylabel("position");
%2
subplot(3,1,2);
hold on;
plot(normalizedTime, normalizedReach{1}(:,2), 'LineWidth', 3);
% plot(linspace(1,data_length,normalizeFrames), normalizedReach{1}(:,2));
title("Y");
set(gca,'fontsize',14)
legend("original", "fit");
ylabel("position");
%3
subplot(3,1,3);
hold on;
plot(normalizedTime, normalizedReach{1}(:,3), 'LineWidth', 3);
% plot(linspace(1,data_length,normalizeFrames), normalizedReach{1}(:,3));
title("Z");
set(gca,'fontsize',14)
legend("original", "fit");
xlabel("time");
ylabel("position");