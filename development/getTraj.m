% Records reaching trajectory (in m), time course (sec) and touch point (in pixels).
% For categorization question:
%   waits until target display time passes and then shows categor screen.
%   varargin: natural displayed left(1)/right(0) side on categor screen.
function [touch_point, traj, timecourse, categor_time] = getTraj(varargin)
    global TOUCH_PLANE_INFO NATNETCLIENT; % generated with touch_plane_setup.m
    global refRateHz refRateSec w;
    global TARGET_DURATION;
    global RESPOND_FASTER_SCREEN;
    
    finger_size = 0.02; % marker distance (m) from screen when touching it.
    
    touch_point = NaN(1,3);
    max_record_length = 10; % in sec
    sample_length = max_record_length * refRateHz;
    traj = NaN(sample_length, 3); % 3 cordinates (x,y,z).
    timecourse = NaN(sample_length,1);
    categor_time = NaN;
    
    % records trajectory upto screen.
    for frame_i = 1:sample_length

        % syncs trajectory sampling to screen refRate.
        [~,timecourse(frame_i)] = Screen('Flip',w,0,1);
        
        % samples location.
        markers = NATNETCLIENT.getFrame.LabeledMarker;
        
        % checks if there is a marker.
        if ~isempty(markers(1))
            cur_location = double([markers(1).x, markers(1).y, markers(1).z]);
            traj(frame_i,:) = transform4(TOUCH_PLANE_INFO.T_opto_plane, cur_location); % transform to screen related space.
            
            % identify screen touch
            if traj(frame_i,3)-finger_size < 0
                touch_point = traj(frame_i,:) / TOUCH_PLANE_INFO.mPerPixel;
                return;
            end
        end

        % disp categor screen after target.
        if (~isempty(varargin{:}) && (frame_i+1 == TARGET_DURATION*refRateHz))
            showCategor(varargin{:}{:});
            categor_time = timecourse(frame_i) + refRateSec;
        end
    end
    
    % User didn't respond in time.
    Screen('DrawTexture',w, RESPOND_FASTER_SCREEN);
    Screen('Flip',w);
    WaitSecs(1);
end

% Draws 'natural' and 'artificial' categories for categorization task.
function [] = showCategor(natural_left)
    global w CATEGOR_NATURAL_LEFT_SCREEN CATEGOR_NATURAL_RIGHT_SCREEN 
    if natural_left
        Screen('DrawTexture',w, CATEGOR_NATURAL_LEFT_SCREEN);
    else
        Screen('DrawTexture',w, CATEGOR_NATURAL_RIGHT_SCREEN);
    end
end