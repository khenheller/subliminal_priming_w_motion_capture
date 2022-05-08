% Gets the answer with keyboard.
% task_type - 'recog','categor'.
% stim_disp_time - time when stimuli was presented.
% p - all experiment's parameters.
% output - sub's ans (left/right),
%           categor_time - the time at which the presented word was removed.
%           late_res/early_res - was response time good?
%           timecourse_to - time of stimulus display and time when answer was given.
%           slow_mvmnt, traj_to/from, timecourse_from - isn't used, receives nan. Is used in getReachAns and I wanted to keep an identical format.
function [output] = getKeyboardAns(task_type, stim_disp_time, p)

    [key, keypress_time, categor_time, late_res, early_res] = getKeypress(task_type, stim_disp_time, p);
    
    % Check selected side.
    answer_left = NaN;
    if find(key) == p.LEFT_KEY
        answer_left = 1;
    elseif find(key) == p.RIGHT_KEY
        answer_left = 0;
    end
       
    output = struct('answer_left',answer_left, 'categor_time',categor_time,...
        'late_res',late_res, 'early_res', early_res, 'slow_mvmnt',0,...
        'traj_to',nan(1,3), 'timecourse_to',[stim_disp_time; keypress_time],...
        'traj_from',nan(1,3), 'timecourse_from',nan(1,3));
end