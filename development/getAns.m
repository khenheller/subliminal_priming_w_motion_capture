% Gets question type ('recog','categor','pas').
% varargin relevant only for type='categor', indicates on which side natural
% is dispayed.
% returns sub's answer: 1=left, 0=right. For pas ans are: 1/2/3/4.
function [output] = getAns(type, varargin)
    
    [touch_point, traj_to, timecourse_to, categor_time] = getTraj('to_screen',varargin);
    [~, traj_from, timecourse_from, ~]                  = getTraj('from_screen');
    
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
    
    output = struct('answer',answer, 'traj_to',traj_to, 'timecourse_to',timecourse_to,...
        'traj_from',traj_from, 'timecourse_from',timecourse_from, 'categor_time',categor_time);
end