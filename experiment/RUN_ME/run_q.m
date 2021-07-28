% Gets queue of stimuli.
% Displays them while recording the subject's trajectory.
% To display text on image put image in q.txtr and text in q.txt.
% q - struct: txtr, txt, name, len (q's length).
% traj_type - 'categor', 'recog'.
function [traj, timecourse, times] = run_q(traj_type, q, p)
    traj = NaN(q.len,3);
    timecourse = NaN(q.len,1);
    times = NaN(length(find(~isnan(q.name))));
    last_txtr = 1;
    categor_traj = traj_type == 'categor';
    
    for iQ = 1:q.len
        % Sync to screen refresh.
        timecourse(iQ) = Screen('Flip', p.w, 0, 1);

        % Samples time when there is event.
        if ~isnan(q.name(iQ))
            times(1) = timecourse(iQ) + p.REF_RATE_SEC;
            times = circshift(times,-1);
        end

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
        if at_screen
            return;
        end
        
        % Left start, initiate Mvmnt Time cnt. Limit MT only when responding to target.
        if ~at_start && categor_traj
            q.txtr(iQ + p.MOVE_TIME_SAMPLES) = p.SLOW_MVMNT_TXTR;
            q.name(iQ + p.MOVE_TIME_SAMPLES) = 'slow_mvmnt';
            q.txt (iQ + p.MOVE_TIME_SAMPLES) = NaN;
        end
        
        Screen('DrawTexture',p.w, q.txtr(iQ));
        
        switch q.name(iQ)
            case 'target'
                Screen('TextFont',p.w, p.FONT_TYPE);
                Screen('TextSize', p.w, p.FONT_SIZE);
            case 'late_res' % Mvmnt onset too late.
                if at_start
                    return;
                else
                    Screen('DrawTexture',p.w, last_txtr);
                end
            case 'slow_mvmnt' % Mvmnt too slow.
                return;
        end
        DrawFormattedText(p.w, q.txt(iQ), 'center', (p.SCREEN_HEIGHT/2+3), [0 0 0]);
        last_txtr = q.txtr(iQ);
    end
end