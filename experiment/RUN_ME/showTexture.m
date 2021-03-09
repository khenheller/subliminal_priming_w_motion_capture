function [time] = showTexture(txtr, p)
    Screen('DrawTexture',p.w, txtr);
    [~,time] = Screen('Flip', p.w);    
end