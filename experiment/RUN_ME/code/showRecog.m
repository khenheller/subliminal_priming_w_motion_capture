% Prints prime and distractor words for the recognition task.
% p - all experiment's parameters.
% trial - one row from "trials" generated in main.m, contains the words to be shown.
% times - time when the words were displayed.
function [times] = showRecog(trial, p)
    if trial.prime_left
        left_word = trial.prime{:};
        right_word = trial.distractor{:};
    else
        left_word = trial.distractor{:};
        right_word = trial.prime{:};
    end
    
    % Prime recognition.    
    txtr_num = getTextureFromHD(p.RECOG_SCREEN, p);
    Screen('DrawTexture',p.w, txtr_num);
    Screen('TextSize', p.w, p.RECOG_FONT_SIZE);
    DrawFormattedText(p.w, double(left_word), p.SCREEN_WIDTH*2/7, p.SCREEN_HEIGHT*5/16, [0 0 0]);
    DrawFormattedText(p.w, double(right_word), p.SCREEN_WIDTH*21/32, p.SCREEN_HEIGHT*5/16, [0 0 0]);
    [~,times] = Screen('Flip', p.w, 0, 1);
    Screen('close', txtr_num);
end