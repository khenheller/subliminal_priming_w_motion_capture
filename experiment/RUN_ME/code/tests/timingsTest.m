% Recieves table with timestamps (sec) for each event,
% a matching array with desired duration (sec) of each event,
% and events name (cell array of chars).
% Check if (EXCEPT for last stimuli):
%   Duration in each trial deviates from desired by more than max_dev.
%   Mean duration deviates from desired by more than max_dev.
%   STD is bigger than desired_std.
% If so pass_test = 0.
% prints results as text and histograms.
% Input: events - cell array of chars.
%       timestamps - table, each column is an event, each row is a timestamp.
%       traj_end - double vec, last timestamp in each reach to target.
%       desired_durations - vector of doubles
%       is_reach - testing a reaching session (1) or a keyboard response sesssion (0).
%       target_rt - RT to target on each trial.
% Output: dev_table - Contains all the trials with deviating stimuli duration.
%                   3 col:Trial number, deviation and event type.
function [pass_test, dev_table] = timingsTest(events, timestamps, traj_end, desired_durations, target_rt, is_reach)
    max_dev = 2; % max deviation in ms.
    desired_std = 2;
    
    target_col = find(ismember(events, 'target_time'));
    % Calc RT.
    if is_reach
        % RT = delay between target disp and end of traj.
        resp_time = traj_end' - timestamps{:,target_col};
        resp_time = resp_time * 1000; % convert to ms.
        resp_time = resp_time + 10;
    else
        resp_time = target_rt * 1000;
    end
    
    % Calc deviations.
    durations = timestamps{:, 2:end} - timestamps{:, 1:end-1};
    durations = durations * 1000; % convert to ms.
    durations_mean = mean(durations,1, 'omitnan');
    durations_std = std(durations,1, 'omitnan');
    desired_durations = desired_durations * 1000;
    deviations = durations - desired_durations;
    deviations_abs = abs(deviations);
    deviating_trials = deviations_abs > max_dev;
    
    % Ignore cases when sub responded before target duration passed.
    rt_equal_duration = abs(ceil(durations(:, target_col)) - ceil(resp_time)) <= 1; % Equal up to 1ms difference.
    sub_res_quickly = rt_equal_duration & (resp_time <= desired_durations(target_col));
    deviating_trials(:, target_col) = deviating_trials(:, target_col) & ~sub_res_quickly;
    bad_deviations_index = find(deviating_trials);
    
    [bad_deviations_trial,~] = ind2sub(size(deviations_abs), bad_deviations_index);
    bad_deviations = deviations(bad_deviations_index);
    
    % Compute duration mean (ignoring cases when response came before the target disp time passed).
    durations_wo_fast_res = durations;
    durations_wo_fast_res(sub_res_quickly, target_col) = NaN;
    durations_mean_wo_fast_res = mean(durations_wo_fast_res,1, 'omitnan');
    durations_std_wo_fast_res = std(durations_wo_fast_res,1, 'omitnan');
    
    % Checks if passed tests.
    pass_test.deviations = isempty(bad_deviations);
    pass_test.deviation_of_mean = ~any(abs(durations_mean_wo_fast_res - desired_durations) > max_dev);
    pass_test.std = ~any(durations_std_wo_fast_res > desired_std);
        
    
    % replicates names for later printing.
    events = repmat(events,height(timestamps),1);
    
    % Print deviations from desired duration.
    disp('Number of trials devaiting from desired duration:');
    disp(num2str(length(bad_deviations)));
    disp('Deviating trials and their deviation (in ms, exmaple: -10 = stimuli was 10 ms shorter than desired):');
    dev_table = table(bad_deviations_trial, bad_deviations, events(bad_deviations_index),...
        'VariableNames',{'TrialNum','Deviation','Event'});
    disp(dev_table);
    
    % Print deviations of mean from desired duration.
    deviation_of_mean_from_desired = durations_mean - desired_durations;
    timings_table = table(desired_durations', durations_mean', durations_std',...
        deviation_of_mean_from_desired',...
        'VariableNames',{'Desired_duration','Mean_duration','STD','Deviation_of_mean_from_desired'});    
    disp('Deviations in ms:');
    disp(timings_table);
    
    % Draw timestamp histogram for each event.
    figure('Name','Timings');
    num_subplots = ceil(size(events,2) / 2);
    for iEvent = 1 : size(events,2)-1
        subplot(2, num_subplots, iEvent);
        durations_hist = histogram(durations(:,iEvent));
        hold on;
        line([durations_mean(iEvent) durations_mean(iEvent)], [0 height(timestamps)], 'color','red', 'LineWidth',3);
        xlim([min(durations(:,iEvent)) (max(durations(:,iEvent)) + 0.0001)]);
        ylim([0 max(durations_hist.Values)]);
        xlabel('duration'); ylabel('trials');
        title(events(1,iEvent), 'FontSize',14);
        hold on;
    end
end