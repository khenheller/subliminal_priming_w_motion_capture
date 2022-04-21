% Presents a word.
% when - absolute time (i.e., the actual time of the day, not relatively to the previous stimuli).
% prime_or_target - which one to show. values: "prime" / "target".
% trial - one row from "trials" generated in main.m, contains the word to be shown.
% p - all experiment's parameters.
% times - time when the word was displayed.
function [times] = showWord(trial, prime_or_target, when, p)
    Screen('DrawTexture',p.w, p.CATEGOR_TXTR); % Shows categor answers with word.
    DrawFormattedText(p.w, double(trial.(prime_or_target){:}), 'center', (p.SCREEN_HEIGHT/2+3), [0 0 0]);
    [~,times] = Screen('Flip', p.w, when, 1);
end