function [time] = showTexture(txtr)
    global w
    Screen('DrawTexture',w, txtr);
    [~,time] = Screen('Flip', w);    
end