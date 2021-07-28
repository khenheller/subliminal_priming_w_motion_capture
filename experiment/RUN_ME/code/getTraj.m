% Records reaching trajectory (in m), time course (sec) to OR from screen.
% For categorization question:
%   waits until target display time passes and then shows categor screen.
% traj_type - 'to_screen', 'from_screen'
% ques_type - question type ('recog','categor').
function [traj, timecourse, categor_time] = getTraj(traj_type, ques_type, p)
    
    % Sample length is different for recog/categor questions.
    sample_length = strcmp(ques_type, 'recog') * p.RECOG_CAP_LENGTH + ...
        strcmp(ques_type, 'categor') * p.CATEGOR_CAP_LENGTH;
    
    traj = NaN(p.MAX_CAP_LENGTH, 3); % 3 cordinates (x,y,z).
    timecourse = NaN(p.MAX_CAP_LENGTH,1);
    categor_time = NaN;
    curDistance = NaN;
    
    to_screen = strcmp(traj_type, 'to_screen') * 1;
    late_move_onset = 0;
    
    % records trajectory upto screen.
    for frame_i = 1:sample_length

        % syncs trajectory sampling to screen refRate.
        [~,timecourse(frame_i)] = Screen('Flip',p.w,0,to_screen); % when retracting, clear screen.
        
        % samples location.
        markers = p.NATNETCLIENT.getFrame.LabeledMarker;
        
        % checks if there is a marker.
        if ~isempty(markers(1))
            cur_location = double([markers(1).x, markers(1).y, markers(1).z]);
            traj(frame_i,:) = transform4(p.TOUCH_PLANE_INFO.T_opto_plane, cur_location); % transform to screen related space.
            
            % REACHING TO SCREEN: identify screen touch.
            if to_screen
                if traj(frame_i,3)-p.FINGER_SIZE < 0
                    Screen('Flip',p.w,0,0); % Erase stimuli and sync to screen flips.
                    remove the line above, it causes 20ms delay between to screen recording and from screen recording @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                    remove the line above @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                    remove the line above @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                    remove the line above @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                    remove the line above @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
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
        
        if (strcmp(ques_type, 'categor') && to_screen)
            % Exits if Movement onset passed and Sub didn't move.
            if  (frame_i > p.REACT_TIME*p.REF_RATE_HZ)% onset passed.
                if sqrt(sum((traj(frame_i,:)-p.START_POINT).^2)) < p.START_POINT_RANGE % sub didn't move.
                    frame_i = sample_length;
                    late_move_onset = 1;
                end
            end
            % Target duration passed, remove it and show only categorization screen.
            if (frame_i+1 == p.TARGET_DURATION*p.REF_RATE_HZ)
                Screen('DrawTexture',p.w, p.CATEGOR_SCREEN);
                categor_time = timecourse(frame_i) + p.REF_RATE_SEC;
            end
        end
    end
    
    % Responded too late, or didn't return to start point.
    message_screen = to_screen * ~late_move_onset * p.MISS_RESPONSE_WINDOW_SCREEN +...
        ~to_screen * p.RTRN_START_POINT_SCREEN + ...
        to_screen * late_move_onset * p.LATE_MOVE_ONSET_SCREEN;
    fix slides here, they dont represesnt the slide number no more@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    fix slides here@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    fix slides here@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    fix slides here@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    Screen('DrawTexture',p.w, message_screen);
    Screen('Flip',p.w);
    WaitSecs(1.5);
end