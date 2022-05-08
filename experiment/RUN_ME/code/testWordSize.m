% Prints word on screen to measure thier actual size (by hand).
% p - all experiment's parameters.
function [] = testWordSize(p)
    Screen('TextFont',p.w, p.HAND_FONT_TYPE);
    Screen('TextSize', p.w, p.HAND_FONT_SIZE);
    DrawFormattedText(p.w, double('אבגדה וזחטי אבגדהוזחטיכךלמנןסעפףצץקרשת'), 'p.CENTER', p.SCREEN_HEIGHT/4, [0 0 0]);
    
    Screen('TextFont',p.w, p.FONT_TYPE);
    Screen('TextSize', p.w, p.FONT_SIZE);
    DrawFormattedText(p.w, double('אבגדה וזחטי אבגדהוזחטיכךלמנןסעפףצץקרשת'), 'p.CENTER', p.SCREEN_HEIGHT*3/4, [0 0 0]);
    [~,times] = Screen('Flip',p.w);
end