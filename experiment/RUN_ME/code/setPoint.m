% Displays a point on the screen. When user presses space his coordinates are returned.
function [point] = setPoint(point_screen, p)

    point = [];
    showTexture(point_screen, p);
    
    KbWait([], 1); % Waits until all keys are released.
    
    % Waits until space is pressed and point receives a value.
    key = zeros(1,256);
    while ~key(p.SPACE_KEY) || isempty(point) || isempty(markers(1))
        
        % sample location.
        markers = p.NATNETCLIENT.getFrame.LabeledMarkers;
        if ~isempty(markers(1))
            point = [markers(1).x markers(1).y markers(1).z];
            point = transform4(p.TOUCH_PLANE_INFO.T_opto_plane, point); % transform to screen related space.
        end
        % Check if space was pressed.
        [~, ~, key, ~] = KbCheck();
    end
    KbWait([], 1); % Waits until space is released.
end