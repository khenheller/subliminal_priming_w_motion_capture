% Waits for keyboard response to the question displayed to participant.
% type: 'instruction','categor', 'recog', 'pas'.
function [ key, Resp_Time ] = getInput(type, p)
    key = [];
    Resp_Time = [];
    
    [Resp_Time, Resp] = KbWait([], 2); % Waits for keypress.
    switch type
        case ('instruction')
            if Resp(p.ABORT_KEY)
                key = p.ABORT_KEY;
                error('Exit by user!');
            end
        case ('categor')
            if Resp(p.ABORT_KEY)
                key = p.ABORT_KEY;
                error('Exit by user!');
            elseif Resp(p.RIGHT_KEY)
                key = p.RIGHT;
            elseif Resp(p.LEFT_KEY)
                key = p.LEFT; 
            else
                key = p.WRONG_KEY;
            end
        case ('recog')
            if Resp(p.ABORT_KEY)
                key = p.ABORT_KEY;
                error('Exit by user!');
            elseif Resp(p.RIGHT_KEY)
                key = p.RIGHT;
            elseif Resp(p.LEFT_KEY)
                key = p.LEFT; 
            else
                key = p.WRONG_KEY;
            end
        case ('pas')
            if Resp(p.ABORT_KEY)
                key = p.ABORT_KEY;
                error('Exit by user!');
            elseif Resp(p.ONE)
                key = 1;
            elseif Resp(p.TWO)
                key = 2;
            elseif Resp(p.THREE)
                key = 3;
            elseif Resp(p.FOUR)
                key = 4;
            else
                key = p.WRONG_KEY;
            end
    end
end