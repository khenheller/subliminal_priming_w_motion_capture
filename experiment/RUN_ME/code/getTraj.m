% Records reaching trajectory (in m), time course (sec) to OR from screen.
% For categorization question:
%   waits until target display time passes and then shows categor screen.
% traj_type - 'to_screen', 'from_screen'
% task_type - question type ('recog','categor').
% p - all experiment's parameters.
% Output:
% categor_time - time at which the presented word was removed.
function [traj, timecourse, categor_time, late_res, early_res, slow_mvmnt] = getTraj(traj_type, task_type, p)
    
    traj = NaN(p.REACH_MAX_RT_LIMIT, 3); % 3 cordinates (x,y,z).
    timecourse = NaN(p.REACH_MAX_RT_LIMIT,1);
    categor_time = NaN;
    curDistance = NaN;
    late_res = 0;
    early_res = 0;
    slow_mvmnt = 0;
    
    to_screen = strcmp(traj_type, 'to_screen') * 1;
    mvmnt_dur = 0; % Counts time from mvmnt onset.
    
    % records trajectory upto screen.
    for frame_i = 1:p.REACH_MAX_RT_LIMIT

        % syncs trajectory sampling to screen refRate.
        [~,timecourse(frame_i)] = Screen('Flip',p.w,0,to_screen); % when retracting, clear screen.
        
        % samples location.
        markers = p.NATNETCLIENT.getFrame.LabeledMarkers;
        
        % checks if there is a marker.
        if ~isempty(markers(1))
            cur_location = double([markers(1).x, markers(1).y, markers(1).z]);
            traj(frame_i,:) = transform4(p.TOUCH_PLANE_INFO.T_opto_plane, cur_location); % transform to screen related space.
            
            % REACHING TO SCREEN: identify screen touch.
            if to_screen
                if traj(frame_i,3)-p.FINGER_SIZE < 0
                    return;
                end
            % RETURNING FROM SCREEN: identify start point touch.
            else
                curDistance = sqrt(sum((traj(frame_i,:)-p.START_POINT).^2));
                if curDistance < p.START_POINT_RANGE
                    return;
                end
            end
        end
        
        % Check response timing.
        if ((task_type == "categor") && to_screen)
            % sub didn't move.
            if sqrt(sum((traj(frame_i,:)-p.START_POINT).^2)) < p.START_POINT_RANGE
                % Movement onset passed.
                if  (frame_i >= p.REACT_TIME_SAMPLES) % '>=': when frame==max_react_time, it means react time passed and sub didn't move.
                    late_res = 1;
                    showTexture(p.LATE_RES_SCREEN, p);
                    WaitSecs(p.MSG_DURATION);
                    return;
                end
            % Sub did move.
            else
                mvmnt_dur = mvmnt_dur + 1;
                % Sub moved too early.
                if frame_i <= p.MIN_REACT_TIME_SAMPLES
                    early_res = 1;
                    showTexture(p.EARLY_RES_SCREEN, p);
                    WaitSecs(p.MSG_DURATION);
                    return;
                end
            end
            % Slow movement.
            if mvmnt_dur >= p.MOVE_TIME_SAMPLES % '>=': when dur==max_mvmnt_time, it means move time passed and sub didn't reach screen.
                slow_mvmnt = 1;
            end
            
            % Target duration passed, remove it and show only categorization screen.
            if (frame_i+1 >= p.TARGET_DURATION_SAMPLES && isnan(categor_time))
                Screen('DrawTexture',p.w, p.CATEGOR_TXTR);
                categor_time = timecourse(frame_i) + p.REF_RATE_SEC;
            end
        end
    end
    
    % Didn't return to start point.
    if ~to_screen
        showTexture(p.RTRN_START_POINT_SCREEN, p);
        WaitSecs(p.MSG_DURATION);
    end
end