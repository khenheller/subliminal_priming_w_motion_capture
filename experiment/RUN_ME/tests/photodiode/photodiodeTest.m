% Checks if event durations recorded by the photodiode match those recorded in matlab,
% and are equal to desired durations.
% last event in events ---ISN'T TESTED---.
% File organization:
%   Put your experiment output file in a folder with the osciliscope output folders and nothing else.
%   Experiment output file - Should be called 'sub*data.csv', '*' be the subjet's number.
%                           Columns are events (can contain other columns as well), and rows are trials.
%                           Values are the timestamp (not duraion) of the event.
%   osciloscope folders & files - should be named in rising order (e.g. F0002CH2, F0003CH2, F0004CH2...).
%                               First file (F0002CH2) is matched to first trial.
%               
% Input: test_path - folder with experiment output files and osciloscope output folders. 
%       events - cell array, names of timestamps' headers in output data.
%       desired_durations - double array. Same order as events.
function [output] = photodiodeTest(test_path, events, desired_durations)
    warning('OFF', 'MATLAB:table:RowsAddedExistingVars');
    
    % Get files.
    files = dir([test_path, '/**']); % including subfolders.
    files([files.isdir]) = []; % Remove folders.
    files = files(contains({files.name}, '.CSV', 'IgnoreCase',true)); % keep releavant files.
    exp_files = files(contains({files.name}, 'sub'));
    diode_files = files(~contains({files.name}, 'sub'));
    exp_files = fullfile({exp_files.folder}, {exp_files.name}); % full paths.
    diode_files = fullfile({diode_files.folder}, {diode_files.name}); % full paths.
    diode_files = cell2mat(diode_files');
    
    % Param decleration.
    num_trials = size(diode_files,1);
    diode_timings = NaN(num_trials, length(events)-1);
    allowed_diff = 0.004; % between different measurements (this is osciliscope interval).
    desired_durations = repmat(desired_durations(1:end-1), num_trials,1); % turn to matrix.
    
    % Diode timing calc.
    % Iterates over files (each file is a single trial).
    for iTrial = 1:num_trials
        diode_measure = readtable(diode_files(iTrial,:), 'ReadVariableNames',false);
        time = diode_measure{:,4};
        volt = diode_measure{:,5} > 30;
        % Keep data from first event.
        event_start = find(volt, 1);
        time = time(event_start : end);
        volt = volt(event_start : end);
        
        % Calc each event's duration.
        for iEvent = 1 : length(events)-1
            event_end = find(~volt, 1); % finds first 0.
            diode_timings(iTrial, iEvent) = abs(time(event_end) - time(1));
            % Remove event.
            volt = volt(event_end : end);
            time = time(event_end : end);
            % Makes next event's volt 1.
            volt = ~ volt;
        end
    end
    
    % Matlab timing calc.
    trials = readtable(exp_files{contains(exp_files, 'data')});
    trials = trials(:, events);
    matlab_timings = (trials{:, 2 : end} - trials{:, 1 : end-1});
    
    % Diff between Matlab and Diode.
    mat_diode_diff = getDiff(matlab_timings, diode_timings, allowed_diff, events);
    % Diff between Matlab and desire.
    mat_desired_diff = getDiff(matlab_timings, desired_durations, allowed_diff, events);
    % Diff between Diode and desire.
    diode_desired_diff = getDiff(diode_timings, desired_durations, allowed_diff, events);
    
    
    % Dislay results.
    timings = [desired_durations;...
        diode_timings(:,:);...
        matlab_timings(:,:)];
    events = events(:, 1:end-1);
    headers = [strcat(events, '_desired');...
        strcat(events, '_diode');...
        strcat(events, '_matlab')];
    headers = reshape(headers, 1, length(events)*3);
    timings = reshape(timings, num_trials, length(events) * 3);
    timings = array2table(timings, 'VariableNames',headers);
    disp(timings);
    disp('Big deviations between Matlab and Diode: ');
    disp(mat_diode_diff);
    disp('Big deviations between Matlab and desired durations: ');
    disp(mat_desired_diff);
    disp('Big deviations between Diode and desired durations: ');
    disp(diode_desired_diff);
    
    output.timings = timings;
    output.mat_diode_diff = mat_diode_diff;
    output.mat_desired_diff = mat_desired_diff;
    output.diode_desired_diff = diode_desired_diff;
end

% Finds diff between two timings lists that exceed allowed_diff.
function [big_timing_diff] = getDiff(timings1, timings2, allowed_diff, events)
    timing_diff = abs(timings1 - timings2);
    timing_diff = round(timing_diff, 3); % remove diff smaller than osciliscope interval.
    timing_diff(isnan(timing_diff)) = 0; % erase nans.
    timing_diff(timing_diff <= allowed_diff) = 0; % Keep only big deviations.
    [trial, event, diff] = find(timing_diff);
    big_timing_diff = table(events(event)', trial, diff, 'VariableNames',{'event', 'trial', 'diff'}); 
end