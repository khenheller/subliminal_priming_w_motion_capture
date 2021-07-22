% Records sub traj to and from screen, his answer, and timestamps of stimuli.
% traj_type - 'categor', 'categor_wo_prime', 'recog'.
function [output, times] = getAns(traj_type, q, p)
    
    [traj_to, timecourse_to, times] = run_q(traj_type, q, p);
    [traj_from, timecourse_from]    = finInStartPoint(p);   
    
    % Get screen touch point.
    last_sample = find(~isnan(traj_to(:,1)), 1, 'last');
    touch_point = traj_to(last_sample,1) / p.TOUCH_PLANE_INFO.mPerPixel; % Sample current position, convert to pixels.
    
    % Reorder event times.
    times = circshift(times, -sum(isnan(times)));
    % Fill timestamps of events that occured after sub response.
    times(isnan(times)) = max(timecourse_to,[],'omitnan') + p.REF_RATE_SEC;
    
    if touch_point(1) < p.SCREEN_WIDTH/2 % left half of screen.
        answer = 1;
    else % right half.
        answer = 0;
    end
    
    % Remove 'Late res' time.
    times(q.name(~ismissing(q.name)) == "late_res") = [];
    
    output = struct('answer',answer, 'traj_to',traj_to, 'timecourse_to',timecourse_to,...
        'traj_from',traj_from, 'timecourse_from',timecourse_from);
end