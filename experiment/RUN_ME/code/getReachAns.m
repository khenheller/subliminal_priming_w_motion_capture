% Gets the answer with reaching.
% task_type - 'recog','categor'.
% p - all experiment's parameters.
% output - sub's ans (left/right),
%           categor_time - the time at which the presented word was removed.
%           late_res/early_res/slow_mvmnt - was response time good?
%           traj/timecourse - trajectory and timecourse of response.
function [output] = getReachAns(task_type, p)
    
    [traj_to, timecourse_to, categor_time, late_res, early_res, slow_mvmnt] = getTraj('to_screen', task_type, p);
    [traj_from, timecourse_from, ~, ~, ~, ~] = getTraj('from_screen', task_type, p);   
    
    answer_left = NaN;
    
    last_sample = find(~isnan(traj_to(:,1)), 1, 'last');
    touch_point = traj_to(last_sample,1) / p.TOUCH_PLANE_INFO.mPerPixel; % Sample current position, convert to pixels.
    
    % If sub responded before target ended, categor_time didn't get value.
    if isnan(categor_time) 
        categor_time = max(timecourse_to,[],'omitnan') + p.REF_RATE_SEC; % target cleared 1 ref rate after last sample.
    end
    
    if touch_point < p.SCREEN_WIDTH/2 % left half of screen.
        answer_left = 1;
    else % right half.
        answer_left = 0;
    end

    % Notify subject if he moved too slowly.
    if slow_mvmnt
        showTexture(p.SLOW_MVMNT_SCREEN, p);
        WaitSecs(p.MSG_DURATION);
    end
    
    output = struct('answer_left',answer_left, 'categor_time',categor_time,...
        'late_res',late_res, 'early_res', early_res, 'slow_mvmnt',slow_mvmnt,...
        'traj_to',traj_to, 'timecourse_to',timecourse_to,...
        'traj_from',traj_from, 'timecourse_from',timecourse_from);
end