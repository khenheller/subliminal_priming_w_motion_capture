% Displays a point on the screen. When user presses space his coordinates are returned.
function [point] = setPoint(point_screen)
    global NATNETCLIENT TOUCH_PLANE_INFO spaceKey

    showTexture(point_screen);
    
    % Waits for "space" press.
    key = 0;
    while ~key(spaceKey)
        
        % sample location.
        markers = NATNETCLIENT.getFrame.LabeledMarker;
        point = [markers(1).x markers(1).y markers(1).z];
        point = transform4(TOUCH_PLANE_INFO.T_opto_plane, point); % transform to screen related space.
        % Check if space was pressed.
        [~, ~, key, ~] = KbCheck();
    end
end