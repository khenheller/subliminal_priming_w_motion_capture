% Waits for finger to return to starting point.
% Records trajectory.
function [traj, timestamp] = finInStartPoint(p)
    traj = NaN(p.RECOG_CAP_LENGTH_SEC, 3);
    timestamp = NaN(p.RECOG_CAP_LENGTH_SEC, 1);
    inRangeFlag = 0;
    
    % Waits until finger returns to start pos.
    j = 1;
    while ~inRangeFlag
        
        % Sync to screen refresh.
        timestamp(j) = Screen('Flip', p.w, 0, 1);
        
        % User can exit in this time.
        [~, ~, key, ~] = KbCheck();
        if key(p.ABORT_KEY)
            cleanExit();
        end
        
        % samples location and time.
        markers = p.NATNETCLIENT.getFrame.LabeledMarker;
        
        % checks if there is a marker.
        if ~isempty(markers(1))
            cur_location = double([markers(1).x, markers(1).y, markers(1).z]);
            cur_location = transform4(p.TOUCH_PLANE_INFO.T_opto_plane, cur_location); % transform to screen related space.
            traj(j,:) = cur_location;
            curRange = sqrt(sum((cur_location-p.START_POINT).^2));

            if curRange < p.START_POINT_RANGE
                inRangeFlag = 1;
            end
        end
        
        % Disp "rtrn to start" after a while.
        if j == p.LATE_RES_DURATION
            Screen('DrawTexture',p.w, p.RTRN_START_TXTR);
        end
        
        % Prevents overflow if subject doesn't return to start point.
        if j ~= size(traj,1) - 1
            j = j + 1;
        end
    end
end