% Records reaching trajectory (in m), time course (sec) and touch point (in pixels).
% For categorization question:
%   waits until target display time passes and then shows categor screen.
%   natural_left: natural displayed left(1)/right(0) side on categor screen.
function [touch_point, traj, timecourse, categor_time] = getTraj(natural_left)
    global TOUCH_PLANE_INFO NATNETCLIENT; % generated with touch_plane_setup.m
    global refRateHz w;
    global TARGET_DURATION;
    
    finger_size = 0.02; % marker distance (m) from screen when touching it.
    
    touch_point = NaN(1,3);
    max_record_length = 10; % in sec
    sample_length = max_record_length * refRateHz;
    traj = NaN(sample_length, 3); % 3 cordinates (x,y,z).
    timecourse = NaN(sample_length,1);
    categor_time = NaN;
    
    % records trajectory upto screen.
    for frame_i = 1:sample_length

        % samples location and time.
        markers = NATNETCLIENT.getFrame.LabeledMarker;
        cur_location = double([markers(1).x, markers(1).y, markers(1).z]);
        cur_location = transform4(TOUCH_PLANE_INFO.T_opto_plane, cur_location); % transform to screen related space.
        traj(frame_i,:) = cur_location;
        timecourse(frame_i) = GetSecs;

        % identify screen touch
        if cur_location(3)-finger_size < 0
            touch_point = cur_location / TOUCH_PLANE_INFO.mPerPixel;% You may need Y to be: ScreenHeight - cur_location/mm_per_pixel
            break;
        end

        % disp categor screen if this is categor question.
        if (nargin>0) && (frame_i == TARGET_DURATION*refRateHz)
            categor_time = showCategor(natural_left);
        end

        Screen('Flip',w,0,1); % syncs trajectory sampling to screen refRate.
    end
end

% Draws 'natural' and 'artificial' categories for categorization task.
function [time] = showCategor(natural_left)
    global w CATEGOR_NATURAL_LEFT_SCREEN CATEGOR_NATURAL_RIGHT_SCREEN
    if natural_left
        Screen('DrawTexture',w, CATEGOR_NATURAL_LEFT_SCREEN);
    else
        Screen('DrawTexture',w, CATEGOR_NATURAL_RIGHT_SCREEN);
    end
    time = getSecs;
end