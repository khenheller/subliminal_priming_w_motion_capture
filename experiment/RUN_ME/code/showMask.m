% Presents a mask.
% when - absolute time (i.e., the actual time of the day, not relatively to the previous stimuli).
% mask - which mask to show (1st / 2nd / 3rd).
% p - all experiment's parameters.
% times - time when the mask was displayed.
function [times] = showMask(mask, when, p) 
    Screen('DrawTexture',p.w, mask);
    [~,times] = Screen('Flip', p.w, when);
end