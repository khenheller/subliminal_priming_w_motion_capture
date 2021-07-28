clc;
clear all;
addpath('.\NatNetSDK'); 
p.NATNETCLIENT = initializeNatnet();
rec_time = 2;% recording time in hr.
rec_time_sec = rec_time * 60 * 60;
samp_rate_hz = 100;
samp_rate_sec = 1/samp_rate_hz;
rec_len = rec_time_sec * samp_rate_hz; % in samples.
empty_col = NaN(rec_len, 1);
record_path = './tests/camera_test_results/';
%% Natural recording (only cam).
traj = [empty_col, empty_col, empty_col, empty_col, empty_col];
start_time = clock;
time = 0;
j = 1;
while j < rec_len
    tic
    % Samples a trial.
    markers = p.NATNETCLIENT.getFrame.LabeledMarker;
    traj(j, 4) = ~isempty(markers(1));
    traj(j, 5) = ~isempty(markers(2));
    if traj(j, 4)
        traj(j, 1:3) = double([markers(1).x, markers(1).y, markers(1).z]);
    end
    j = j + 1;
    while time < samp_rate_sec
        time = toc;
    end
    time = 0;
end
end_time = clock;
my_table = table(traj(:,1), traj(:,2), traj(:,3), traj(:,4), traj(:,5), 'VariableNames',{'x','y','z','marker1exist','marker2exist'});
save([record_path 'nat_record5.mat'],'my_table');
disp('Natural record took: ');
disp(end_time - start_time);
p.NATNETCLIENT.disconnect;
