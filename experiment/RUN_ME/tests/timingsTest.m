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
%       desired_durations - vector of doubles.

function pass_test = timingsTest(events, timestamps, desired_durations)

    max_dev = 2; % max deviation in ms.
    desired_std = 2;
    
    % Calc deviations.
    durations = timestamps{:, 2:end} - timestamps{:, 1:end-1};
    durations = durations * 1000; % convert to ms.
    desired_durations = desired_durations * 1000;
    durations_mean = mean(durations,1, 'omitnan');
    durations_std = std(durations,1, 'omitnan');
    deviations = durations - desired_durations;
    deviations_abs = abs(deviations);
    bad_deviations_index = find(deviations_abs > max_dev);
    [bad_deviations_trial,~] = ind2sub(size(deviations_abs), bad_deviations_index);
    bad_deviations = deviations(bad_deviations_index);
    
    % Checks if passed tests.
    pass_test.deviations = isempty(bad_deviations);
    pass_test.deviation_of_mean = ~any(abs(durations_mean - desired_durations) > max_dev);
    pass_test.std = ~any(durations_std > desired_std);
        
    
    % replicates names for later printing.
    events = repmat(events,height(timestamps),1);
    
    % Print deviations from desired duration.
    disp('Number of trials devaiting from desired duration:');
    disp(num2str(length(bad_deviations)));
    disp('Deviating trials and their deviation (in ms):');
    deviations_table = table(bad_deviations_trial, bad_deviations, events(bad_deviations_index),...
        'VariableNames',{'TrialNum','Deviation','Event'});
    disp(deviations_table);
    
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
        xlim([min(durations(:,iEvent)) max(durations(:,iEvent))]);
        ylim([0 max(durations_hist.Values)]);
        xlabel('duration'); ylabel('trials');
        title(events(1,iEvent), 'FontSize',14);
        hold on;
    end
end