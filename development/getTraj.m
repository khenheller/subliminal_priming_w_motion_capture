% records reaching trajectory (in mm), time course (sec) and touch point (in pixels).
function [touch_point, traj, timecourse] = getTraj()
    global TOUCH_PLANE_INFO NATNETCLIENT; % generated with touch_plane_setup.m
    global refRate w;
    
    finger_size = 20; % marker distance (mm) from screen when touching it.
    mm_per_pixel = TOUCH_PLANE_INFO.mmPerPixel / 1000;
    start_time = GetSecs;
    
    touch_point = NaN(1,3);
    max_record_length = 10; % in sec
    max_sample_length = max_record_length * refRate;
    traj = NaN(max_sample_length, 3); % 3 cordinates (x,y,z).
    timecourse = NaN(max_sample_length,1);
    
    markers = NATNETCLIENT.getFrame.LabeledMarker;
    
    % records trajectory upto screen.
    for i = 1:length(traj)
        
        cur_location = double([markers(1).x, markers(1).y, markers(1).z]);
        cur_location = transform4(TOUCH_PLANE_INFO.T_opto_plane, cur_location); % transform to screen related space.
        
        traj(i,:) = cur_location; check that traj is in mm, if not: update here and getAns.
        timecourse(i) = GetSecs - start_time;
        
        % identify screen touch
        if round(cur_location(3))-finger_size < 0
            touch_point = cur_location / mm_per_pixel; You may need Y to be: ScreenHeight - cur_location/mm_per_pixel
            break;
        end
        
        Screen('Flip',w,0,1); % syncs trajectory sampling to screen refRate.
    end
end