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

        % Target duration passed, remove it and show only categorization screen.
        if (strcmp(ques_type, 'categor') && (frame_i+1 == p.TARGET_DURATION*p.REF_RATE_HZ) && to_screen)
            Screen('DrawTexture',p.w, p.CATEGOR_SCREEN);
            categor_time = timecourse(frame_i) + p.REF_RATE_SEC;
        end
    end
    
    % Responded too late, or didn't return to start point.
    message_screen = to_screen*p.RESPOND_FASTER_SCREEN + ~to_screen*p.RETURN_TO_START_POINT_SCREEN;    
    Screen('DrawTexture',p.w, message_screen);
    Screen('Flip',p.w);
    WaitSecs(1);
end