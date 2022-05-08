% Records response given with a keyboard..
% For categorization question:
%   waits until target display time passes and then shows categor screen.
% task_type - question type ('recog','categor').
% stim_disp_time - time when stimuli was presented.
% p - all experiment's parameters.
% Output:
% key - what key was pressed.
% keypress_time - when was the key pressed.
% categor_time - time at which the presented word was removed.
function [key, keypress_time, categor_time, late_res, early_res] = getKeypress(task_type, stim_disp_time, p)
    % RT limits are different for recog/categor questions.
    max_rt_limit = strcmp(task_type, 'recog') * p.KEYBOARD_RECOG_RT_LIMIT_SEC + ...
        strcmp(task_type, 'categor') * p.KEYBOARD_CATEGOR_RT_LIMIT_SEC;

    % Compute timing before loop for faster processing.
    max_rt_limit = stim_disp_time + max_rt_limit;
    min_rt_limit = stim_disp_time + p.KEYBOARD_MIN_RT_LIMIT_SEC;
    target_disp_time = stim_disp_time + p.TARGET_DURATION - p.REF_RATE_SEC;
    
    categor_time = NaN;
    late_res = 0;
    early_res = 0;

    % Get current time.
    curr_time = GetSecs();

    % Loops until max rt passes.
    while curr_time < max_rt_limit

        [keypressed, curr_time, key, ~] = KbCheck();
        
        % Check if "left"/"right" key was pressed.
        if keypressed && (key(p.LEFT_KEY) || key(p.RIGHT_KEY))
            % Record time.
            keypress_time = curr_time;

            % Update categor time if it didn't receive a value yet.
            if isnan(categor_time)
                categor_time = curr_time;
            end
            % Check if response was too early.
            if curr_time < min_rt_limit
                early_res = 1;
                showTexture(p.EARLY_RES_SCREEN, p);
                WaitSecs(p.MSG_DURATION);
            end
            return;
        end

        if task_type == "categor"
            % Target duration passed, replace it with categorization screen.
            if (curr_time >= target_disp_time) && isnan(categor_time)
                Screen('DrawTexture',p.w, p.CATEGOR_TXTR);
                Screen('Flip',p.w,0,0,1);
                categor_time = curr_time + p.REF_RATE_SEC; % Might cause iaccuracy in estimated target display time, but since we dont want to wait for a flip, we have no other way to estimate when was the categorization screen diplayed.
            end
        end
    end

    % Response was too late.
    key = NaN;
    keypress_time = curr_time;
    late_res = 1;
    showTexture(p.LATE_RES_SCREEN, p);
    WaitSecs(p.MSG_DURATION);
    return;
end