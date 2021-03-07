% Records reaching trajectory (in m), time course (sec) to OR from screen.
% when reaching to screen also records touch point (in pixels).
% For categorization question:
%   waits until target display time passes and then shows categor screen.
% traj_type - 'to_screen', 'from_screen'
% varargin - natural displayed left(1)/right(0) side on categor screen.
function [touch_point, traj, timecourse, categor_time] = getTraj(traj_type, varargin)
    global TOUCH_PLANE_INFO NATNETCLIENT; % generated with touch_plane_setup.m
    global refRateHz refRateSec w;
    global TARGET_DURATION;
    global RESPOND_FASTER_SCREEN RETURN_START_POINT_SCREEN;
    global START_POINT;
    global CATEGOR_CAP_LENGTH RECOG_CAP_LENGTH MAX_CAP_LENGTH;
    
    finger_size = 0.03; % marker distance (m) from screen when touching it.
    
    % Sample length is different for recog/categor questions.
    sample_length = isempty(varargin{1}) * RECOG_CAP_LENGTH + ...
        ~isempty(varargin{1}) * CATEGOR_CAP_LENGTH;
    
    touch_point = NaN(1,3);
    traj = NaN(MAX_CAP_LENGTH, 3); % 3 cordinates (x,y,z).
    timecourse = NaN(MAX_CAP_LENGTH,1);
    categor_time = NaN;
    curRange = NaN;
    
    to_screen = strcmp(traj_type, 'to_screen') * 1;
    
    start_point_range = 0.02; %3D distance from start point which finger needs to be in (in meter).
    
    % records trajectory upto screen.
    for frame_i = 1:sample_length

        % syncs trajectory sampling to screen refRate.
        [~,timecourse(frame_i)] = Screen('Flip',w,0,to_screen); % when retracting, clear screen.
        
        % samples location.
        markers = NATNETCLIENT.getFrame.LabeledMarker;
        
        % checks if there is a marker.
        if ~isempty(markers(1))
            cur_location = double([markers(1).x, markers(1).y, markers(1).z]);
            traj(frame_i,:) = transform4(TOUCH_PLANE_INFO.T_opto_plane, cur_location); % transform to screen related space.
            
            % REACHING TO SCREEN: identify screen touch.
            if to_screen
                if traj(frame_i,3)-finger_size < 0
                    touch_point = traj(frame_i,:) / TOUCH_PLANE_INFO.mPerPixel;
                    return;
                end
            % RETURNING FROM SCREEN: identify start point touch.
            else
                curRange = sqrt(sum((traj(frame_i,:)-START_POINT).^2));
                if curRange < start_point_range
                    return;
                end
            end
        end

        % Target duration passed, remove it and show only categorization screen.
        if (~isempty(varargin{:}) && (frame_i+1 == TARGET_DURATION*refRateHz))
            showCategor(varargin{:}{:});
            categor_time = timecourse(frame_i) + refRateSec;
        end
    end
    
    % Responded too late, or didn't return to start point.
    message_screen = to_screen*RESPOND_FASTER_SCREEN + ~to_screen*RETURN_START_POINT_SCREEN;    
    Screen('DrawTexture',w, message_screen);
    Screen('Flip',w);
    WaitSecs(1);
end

% Draws 'natural' and 'artificial' categories for categorization task.
function [] = showCategor(natural_left)
    global w CATEGOR_NATURAL_LEFT_SCREEN CATEGOR_NATURAL_RIGHT_SCREEN BLACK_SCREEN
    if natural_left
        Screen('DrawTexture',w, CATEGOR_NATURAL_LEFT_SCREEN);
    else
        Screen('DrawTexture',w, CATEGOR_NATURAL_RIGHT_SCREEN);
    end
end