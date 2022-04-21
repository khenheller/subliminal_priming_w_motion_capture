% Presents the fixation cross after finger return to the start point.
% p - all experiment's parameters.
% times - time when the fixation was displayed.
function [times] = showFixation(p)
    % waits until finger in start point.
    if ~p.DEBUG
        finInStartPoint(p);
    end
    Screen('DrawTexture',p.w, p.FIXATION_TXTR);
    [~,times] = Screen('Flip', p.w);
end