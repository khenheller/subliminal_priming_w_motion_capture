% Gets question type ('recog','categor','pas').
% natural_left relevant only for type='categor'
% returns sub's answer: 1=left, 0=right. For pas ans are: 1/2/3/4.
function [answer, traj, timecourse, categor_time] = getAns(type, natural_left)
    
    global ScreenWidth w;
    
    answer = NaN;

    % Add code that waits for finger toreurn to start point.
    pause(0.5);
    
    [touch_point, traj, timecourse, categor_time] = getTraj(natural_left);
    
    switch type
        case {'recog','categor'}
            if touch_point(1) < ScreenWidth/2 % left half of screen.
                answer = 1;
            else % right half.
                answer = 0;
            end
            
        case 'pas'
            if touch_point(1) < ScreenWidth/4 % leftmost quarter of screen.
                answer = 1;
            elseif touch_point(1) < (ScreenWidth/4 * 2)
                answer = 2;
            elseif touch_point(1) < (ScreenWidth/4 * 3)
                answer = 3;
            else
                answer = 4;
            end
    end
    
    % Clears screen.
    Screen('Flip',w);
end