% Filters traj to cancel noise.
function trials_traj = filterTraj(trials_traj)
    global MAX_CAP_LENGTH;
    
    %------------------------ remove --------------
    clear all;
    clc;
    MAX_CAP_LENGTH = 200;
    new_trials_traj = readtable('../../development/data/sub9993traj.csv');
    new_trials_traj(new_trials_traj.practice==1, :) = [];
    trials_traj = new_trials_traj;
    %------------------------ remove --------------
    
    order = 2;
    cutoff = [8, 12]; % in Hz
    
    % For bandpass/bandstop, matlab uses filter of order 2n, so we divide n.
    if length(cutoff) > 1
        order = order/2;
    end
    
    [b, a] = butter(order, 2*pi*cutoff, 'stop', 's');
    
    % Get only trajectories.
    trajs = trials_traj;
    not_traj = {'sub_num', 'iBlock', 'iTrial' ,'practice',...
        'target_timecourse_to', 'target_timecourse_from'...
        'prime_timecourse_to', 'prime_timecourse_from'};
    trajs(:, not_traj) = [];
    % concatenate trials next to each other (on snd dimension).
    trajs_matrix = table2array(trajs);
    trajs_matrix = cell2mat(reshape(num2cell(trajs_matrix,2), MAX_CAP_LENGTH,[]));
    
    % Filter.
    filtered_trajs = filter(b,a, trajs_matrix);
end