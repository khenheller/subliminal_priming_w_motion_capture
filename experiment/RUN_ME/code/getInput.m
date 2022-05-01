% Waits for keyboard response to the question displayed to participant.
% ques_type: question 'instruction','categor', 'recog', 'pas'.
function [ key, Resp_Time ] = getInput(ques_type, p)
    key = [];
    Resp_Time = [];
    
    
    while isempty(key)
        [Resp_Time, Resp] = KbWait([], 2); % Waits for keypress.
        switch ques_type
            case ('instruction')
                if Resp(p.ABORT_KEY1) && Resp(p.ABORT_KEY2)
                    key = p.ABORT_KEY1;
                    error('Exit by user!');
                else
                    key = 1;
                end
            case ('categor')
                if Resp(p.ABORT_KEY1) && Resp(p.ABORT_KEY2)
                    key = p.ABORT_KEY1;
                    error('Exit by user!');
                elseif Resp(p.RIGHT_KEY)
                    key = p.RIGHT;
                elseif Resp(p.LEFT_KEY)
                    key = p.LEFT;
                end
            case ('recog')
                if Resp(p.ABORT_KEY1) && Resp(p.ABORT_KEY2)
                    key = p.ABORT_KEY1;
                    error('Exit by user!');
                elseif Resp(p.RIGHT_KEY)
                    key = p.RIGHT;
                elseif Resp(p.LEFT_KEY)
                    key = p.LEFT;
                end
            case ('pas')
                if Resp(p.ABORT_KEY1) && Resp(p.ABORT_KEY2)
                    key = p.ABORT_KEY1;
                    error('Exit by user!');
                elseif Resp(p.ONE)
                    key = 1;
                elseif Resp(p.TWO)
                    key = 2;
                elseif Resp(p.THREE)
                    key = 3;
                elseif Resp(p.FOUR)
                    key = 4;
                end
        end
    end
end