% Waits for keyboard response to the question displayed to participant.
% type: 'instruction','categor', 'recog', 'pas'.
function [ key, Resp_Time ] = getInput(type)

    global compKbDevice abortKey rightKey leftKey WRONG_KEY One Two Three Four
    global RIGHT LEFT

    key = [];
    Resp_Time = [];
    
    [Resp_Time, Resp] = KbWait(compKbDevice, 2); % Waits for keypress.
    switch type
        case ('instruction')
            if Resp(abortKey)
                key = abortKey;
                cleanExit();
            end
        case ('categor')
            if Resp(abortKey)
                key = abortKey;
                cleanExit();
            elseif Resp(rightKey)
                key = RIGHT;
            elseif Resp(leftKey)
                key = LEFT; 
            else
                key = WRONG_KEY;
            end
        case ('recog')
            if Resp(abortKey)
                key = abortKey;
                cleanExit();
            elseif Resp(rightKey)
                key = RIGHT;
            elseif Resp(leftKey)
                key = LEFT; 
            else
                key = WRONG_KEY;
            end
        case ('pas')
            if Resp(abortKey)
                key = abortKey;
                cleanExit();
            elseif Resp(One)
                key = 1;
            elseif Resp(Two)
                key = 2;
            elseif Resp(Three)
                key = 3;
            elseif Resp(Four)
                key = 4;
            else
                key = WRONG_KEY;
            end
    end
end