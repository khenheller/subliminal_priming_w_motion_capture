% Gets question type ('recog','categor','pas').
% varargin relevant only for type='categor', indicates on which side natural
% is dispayed.
% returns sub's answer: 1=left, 0=right. For pas ans are: 1/2/3/4.
function [answer, traj_x,traj_y,traj_z, timecourse, categor_time] = getAns(type, varargin)
    
    [touch_point, traj, timecourse, categor_time] = getTraj(varargin);
    traj_x = traj(:,1);
    traj_y = traj(:,2);
    traj_z = traj(:,3);
    
    global ScreenWidth w;
    
    answer = NaN;
    
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
    Screen('Flip',w);
end