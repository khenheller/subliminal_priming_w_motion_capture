% Waits for finger to return to starting point.
function [] = finInStartPoint(p)
    inRangeFlag = 0;
    
    % Waits until finger returns to start pos.
    while ~inRangeFlag

        % User can exit in this time.
        [~, ~, key, ~] = KbCheck();
        if key(p.ABORT_KEY1) && key(p.ABORT_KEY2)
            error('Exit by user!');
        end
        
        % samples location and time.
        markers = p.NATNETCLIENT.getFrame.LabeledMarkers;
        
        % checks if there is a marker.
        if ~isempty(markers(1))
            cur_location = double([markers(1).x, markers(1).y, markers(1).z]);
            cur_location = transform4(p.TOUCH_PLANE_INFO.T_opto_plane, cur_location); % transform to screen related space.

            curRange = sqrt(sum((cur_location-p.START_POINT).^2));

            if curRange < p.START_POINT_RANGE
                inRangeFlag = 1;
            end
        end
    end
end