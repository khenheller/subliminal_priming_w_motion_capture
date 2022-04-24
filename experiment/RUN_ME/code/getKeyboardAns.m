% Gets the answer with keyboard.
% ques_type - 'recog','categor'.
% stim_disp_time - time when stimuli was presented.
% p - all experiment's parameters.
% output - sub's ans (left/right),
%           categor_time - the time at which the presented word was removed.
%           late_res/early_res - was response time good?
%           timecourse_to - time of stimulus display and time when answer was given.
%           slow_mvmnt, traj_to/from, timecourse_from - isn't used, receives nan. Is used in getReachAns and I wanted to keep an identical format.
function [output] = getKeyboardAns(ques_type, stim_disp_time, p)

    [key_press, key_press_time, categor_time, late_res, early_res] = getKeypress(ques_type, stim_disp_time, p);
    
    % Check selected side.
    answer_left = NaN;
    switch key_press
        case p.LEFT_KEY
            answer_left = 1;
        case p.RIGHT_KEY
            answer_left = 0;
    end
    
    output = struct('answer_left',answer_left, 'categor_time',categor_time,...
        'late_res',late_res, 'early_res', early_res, 'slow_mvmnt',slow_mvmnt,...
        'traj_to',traj_to, 'timecourse_to',[stim_disp_time; key_press_time],...
        'traj_from',traj_from, 'timecourse_from',timecourse_from);
end