% Gets question traj_type ('recog','categor','pas').
% returns sub's answer: 1=left, 0=right. For pas ans are: 1/2/3/4.
function [output] = getAns(traj_type, p)
    
    [traj_to, timecourse_to, categor_time, late_res, slow_mvmnt]  = getTraj('to_screen', traj_type, p);
    [traj_from, timecourse_from, ~]         = getTraj('from_screen', traj_type, p);   
    
    answer = NaN;
    
    last_sample = find(~isnan(traj_to(:,1)), 1, 'last');
    touch_point = traj_to(last_sample,1) / p.TOUCH_PLANE_INFO.mPerPixel; % Sample current position, convert to pixels.
    
    % If sub responded before target ended, categor_time didn't get value.
    if isnan(categor_time) 
        categor_time = max(timecourse_to,[],'omitnan') + p.REF_RATE_SEC; % target cleared 1 ref rate after last sample.
    end
    
    switch traj_type
        case {'recog','categor'}
            if touch_point(1) < p.SCREEN_WIDTH/2 % left half of screen.
                answer = 1;
            else % right half.
                answer = 0;
            end
    end
    
    output = struct('answer',answer, 'categor_time',categor_time, 'late_res',late_res, 'slow_mvmnt',slow_mvmnt,...
        'traj_to',traj_to, 'timecourse_to',timecourse_to,...
        'traj_from',traj_from, 'timecourse_from',timecourse_from);
end