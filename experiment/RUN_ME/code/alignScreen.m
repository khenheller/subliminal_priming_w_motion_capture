% Displays guides on screen and the marker's position.
% This allows to align the screen's position and angle to the starting point.
function [] = alignScreen(p)
    s = [0 0 0];
    a = [0 0 0];
    b = [0 0 0];
    t = [0 0 0];
    key = zeros(1,256);
    
    [p.TOUCH_PLANE_INFO, p.NATNETCLIENT] = touch_plane_setup();
    p = initPsychtoolbox(p);
    p = initConstants(1, 'test', p);
    
    txtr_num = getTextureFromHD(p.ALIGNMENT_SCREEN, p);
    
    % Runs until space press.
    while ~key(p.SPACE_KEY)
        % sample location.
        markers = p.NATNETCLIENT.getFrame.LabeledMarkers;
        if ~isempty(markers(1))
            point = [markers(1).x markers(1).y markers(1).z];
            point = transform4(p.TOUCH_PLANE_INFO.T_opto_plane, point); % transform to screen related space.
        end
        % Check if A/B/C was pressed.
        [~, ~, key, ~] = KbCheck();
        if key(p.S_KEY)
            s = point;
            KbWait([], 1); % Waits until release.
        elseif key(p.A_KEY)
            a = point;
            KbWait([], 1);
        elseif key(p.B_KEY)
            b = point;
            KbWait([], 1);
        elseif key(p.T_KEY)
            t = point;
            KbWait([], 1);
        end
        
        % Calc angle
        ba = b - a;
        sa = s - a;
        angle = rad2deg(atan2(norm(cross(ba,sa)), dot(ba,sa)));
        % Distance between screen and start point.
        dist_to_s = norm(s-t);
        % Screen height.
        screen_height = norm(a-t); % 3d vec length.
        
        Screen('DrawTexture',p.w, txtr_num);
        messages = {['Angle between AB and AS: ' num2str(angle) ' degrees'],...
            ['Distance between screen and starting point: ' num2str(dist_to_s)],...
            ['Height of A: ' num2str(screen_height)]};
        showMessages(messages, p);
        [~,time] = Screen('Flip', p.w);
    end
    KbWait([], 1); % Waits until space is released.
    % Close psychtoolbox.
    Screen('close', txtr_num);
    p.NATNETCLIENT.disconnect;
    sca;
    ShowCursor;
    ListenChar(0);
end

function [] = showMessages(messages, p)
    for i = 1:length(messages)
        message = messages{i};
        DrawFormattedText(p.w, double(message), 'left',  p.SCREEN_HEIGHT*1/2 + i*40, [0 0 0]);
    end
end