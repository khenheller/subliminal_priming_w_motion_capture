% Gets queue of stimuli.
% Displays them while recording the subject's trajectory.
% To display text on image put image in q.txtr and text in q.txt.
% q - struct: txtr, txt1, txt2, name, len (q's length).
%           'txt1' drawn on center or left side, 'txt2' drawn on right side.
% traj_type - 'categor', 'recog'.
function [traj, timecourse, events] = run_q(traj_type, q, p)
    traj = NaN(p.MAX_CAP_LENGTH,3);
    timecourse = NaN(p.MAX_CAP_LENGTH,1);
    event_indx = find(~isnan(q.txtr));
    num_events = length(event_indx) + 1; % '+ 1' because we add 'slow_mvmnt' event.
    events.times = NaN(num_events, 1);
    events.names = [q.name(event_indx); 'slow_mvmnt'];
    categor_traj = any(strcmp(traj_type, ["categor","categor_wo_prime"]));
    seen_target = 0;
    
    for iQ = 1:q.len
        % Sync to screen refresh.
        timecourse(iQ) = Screen('Flip', p.w, 0, 1);
        
        % sample location.
        markers = p.NATNETCLIENT.getFrame.LabeledMarker;
        % Marker exist?
        if ~isempty(markers(1))
            cur_location = double([markers(1).x, markers(1).y, markers(1).z]);
            cur_location = transform4(p.TOUCH_PLANE_INFO.T_opto_plane, cur_location); % transform to screen related space.
            traj(iQ,:) = cur_location;
            dist_from_start = sqrt(sum((cur_location - p.START_POINT).^ 2));
            at_start = dist_from_start < p.START_POINT_RANGE;
            at_screen = (cur_location(3) - p.FINGER_SIZE) < 0;
        end
        
        % Identify screen touch
        if at_screen && seen_target
            Screen('DrawTexture',p.w, p.EMPTY_TXTR);
            return;
        end
        
        % Left start, initiate Mvmnt Time cnt. Limit MT only when responding to target.
        if ~at_start && categor_traj
            q.name(iQ + p.MOVE_TIME_SAMPLES) = 'slow_mvmnt';
        end
        
        % Samples time when there is event.
        if ~isnan(q.txtr(iQ))
            events.times(events.names == q.name(iQ)) = timecourse(iQ) + p.REF_RATE_SEC;
        end
        
        switch q.name(iQ)
            case {'fix','mask1','mask2','mask3','categor'}
                Screen('DrawTexture',p.w, q.txtr(iQ));
            case 'prime'
                Screen('DrawTexture',p.w, q.txtr(iQ));
                DrawFormattedText(p.w, q.txt1(iQ,:), 'center', (p.SCREEN_HEIGHT/2+3), [0 0 0]);
            case 'target'
                seen_target = 1;
                Screen('TextFont',p.w, p.FONT_TYPE);
                Screen('TextSize', p.w, p.FONT_SIZE);
                Screen('DrawTexture',p.w, q.txtr(iQ));
                DrawFormattedText(p.w, q.txt1(iQ,:), 'center', (p.SCREEN_HEIGHT/2+3), [0 0 0]);
            case 'recog'
                seen_target = 1;
                Screen('TextFont',p.w, p.FONT_TYPE);
                Screen('TextSize', p.w, p.RECOG_FONT_SIZE);
                Screen('DrawTexture',p.w, q.txtr(iQ));
                DrawFormattedText(p.w, double(q.txt1(iQ,:)), p.SCREEN_WIDTH*2/7, p.SCREEN_HEIGHT*5/16, [0 0 0]);
                DrawFormattedText(p.w, double(q.txt2(iQ,:)), p.SCREEN_WIDTH*21/32, p.SCREEN_HEIGHT*5/16, [0 0 0]);
            case 'late_res' % Mvmnt onset too late.
                if at_start
                    Screen('DrawTexture',p.w, q.txtr(iQ));
                    return;
                end
            case 'slow_mvmnt' % Mvmnt too slow.
                Screen('DrawTexture',p.w, p.SLOW_MVMNT_TXTR);
                return;
        end
    end
end