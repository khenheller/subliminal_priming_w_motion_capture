% Waits for finger to return to starting point.
function [] = finInStartPoint()
    global NATNETCLIENT TOUCH_PLANE_INFO START_POINT;
    global abortKey;
    
    inRange = 0.02; %3D distance range finger needs to be in. in meter.
    inRangeFlag = 0;
    
    % Waits until finger returns to start pos.
    while ~inRangeFlag

        % User can exit in this time.
        [~, ~, key, ~] = KbCheck();
        if key(abortKey)
            cleanExit();
        end
        
        % samples location and time.
        markers = NATNETCLIENT.getFrame.LabeledMarker;
        
        % checks if there is a marker.
        if ~isempty(markers(1))
            cur_location = double([markers(1).x, markers(1).y, markers(1).z]);
            cur_location = transform4(TOUCH_PLANE_INFO.T_opto_plane, cur_location); % transform to screen related space.

            curRange = sqrt(sum((cur_location-START_POINT).^2));

            if curRange < inRange
                inRangeFlag = 1;
            end
        end
    end
end