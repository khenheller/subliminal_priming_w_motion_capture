% Presents the fixation cross after finger return to the start point.
% is_reach - 1=sub responds with reaching , 0=responds with keybaord.
% p - all experiment's parameters.
% times - time when the fixation was displayed.
function [times] = showFixation(is_reach, p)
    % waits until finger in start point.
    if ~p.DEBUG && is_reach
        finInStartPoint(p);
    end
    Screen('DrawTexture',p.w, p.FIXATION_TXTR);
    [~,times] = Screen('Flip', p.w);
end