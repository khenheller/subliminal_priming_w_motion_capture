% Displays guides on screen and the marker's position.
% This allows to align the screen's position and angle to the starting point.
function [] = alignScreen(p)
    a = [0 0 0];
    b = [0 0 0];
    key = zeros(1,256);
    
    p.NATNETCLIENT = initializeNatnet();
    initPsychtoolbox(p);
    
    % Get start point.
    start_point = setPoint(p.START_POINT_SCREEN, p);
    
    % Runs until space press.
    while ~key(p.SPACE_KEY)
        % sample location.
        markers = p.NATNETCLIENT.getFrame.LabeledMarker;
        if ~isempty(markers(1))
            point = [markers(1).x markers(1).y markers(1).z];
        end
        % Check if A/B was pressed.
        [~, ~, key, ~] = KbCheck();
        if key(p.A_KEY)
            a = point;
            KbWait([], 1); % Waits until release.
        elseif key(p.B_KEY)
            b = point;
            KbWait([], 1); % Waits until release.
        end
        
        % Calc angle
        ba = b - a;
        sa = start_point - a;
        angle = rad2deg(atan2(norm(cross(ba,sa)), dot(ba,sa)));
        
        message = ['Angle between AB and AS: ' num2str(angle) ' degrees'];
        Screen('DrawTexture',p.w, p.ALIGNMENT_SCREEN);
        DrawFormattedText(p.w, double(message), 'left', 'center', [0 0 0]);
        [~,time] = Screen('Flip', p.w);
    end
    KbWait([], 1); % Waits until space is released.
    p.NATNETCLIENT.disconnect;
end