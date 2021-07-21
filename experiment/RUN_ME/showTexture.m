% Reads texture, draws it, and closes it.
% txtr = image file's name w/ extension.
function [times] = showTexture(txtr, p)
    txtr_num = getTextureFromHD(txtr, p);
    Screen('DrawTexture',p.w, txtr_num);
    [~,times] = Screen('Flip', p.w);
    Screen('close', txtr_num);
end