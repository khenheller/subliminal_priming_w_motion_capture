% Displays a point on the screen. When user presses space his coordinates are returned.
function [point] = setPoint(point_screen, p)

    showTexture(point_screen, p);
    
    % Waits for "space" press.
    key = zeros(1,256);
    while ~key(p.SPACE_KEY)
        
        % sample location.
        markers = p.NATNETCLIENT.getFrame.LabeledMarker;
        if ~isempty(markers(1))
            point = [markers(1).x markers(1).y markers(1).z];
            point = transform4(p.TOUCH_PLANE_INFO.T_opto_plane, point); % transform to screen related space.
        end
        % Check if space was pressed.
        [~, ~, key, ~] = KbCheck();
    end
    KbWait([], 1); % Waits until space is released.
end