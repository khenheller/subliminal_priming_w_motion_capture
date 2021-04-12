function p = initPsychtoolbox(p)
    % INITPSYCHTOOLBOX Initilizes Psychtoolbox and opens graphics window
    % output:
    % -------
    % * Opens a psychtoolbox window *
    % screenError - true or false answer if the function did not succeed in
    % opening a 100Hz window.
    
    p.BOX_RESOLUTION = [0 0 700 500]; % resolution when not in fullscreen.
    
    p.REF_RATE_OPTIMAL = 100;
    
    PsychDefaultSetup(2);
    
    % Set sync tests:
    Screen('Preference', 'SkipSyncTests', 0)
    Screen('Preference', 'VisualDebugLevel', 4);

    screens         =   Screen('Screens');
    p.screenNumber  =   max(screens);
    p.gray          =   128 * [1 1 1 1];

    % Finding the screen size and current resolution
    if p.FULLSCREEN
        [p.w, wRect]  =  Screen('OpenWindow',p.screenNumber, p.gray);
    else
        [p.w, wRect]  =  Screen('OpenWindow',p.screenNumber, p.gray, p.BOX_RESOLUTION);
    end
    
    p.SCREEN_WIDTH       =  wRect(3);
    p.SCREEN_HEIGHT      =  wRect(4);
    p.CENTER            =  [p.SCREEN_WIDTH/2; p.SCREEN_HEIGHT/2];
    p.REF_RATE_HZ         = Screen('NominalFrameRate', p.w);
    p.REF_RATE_SEC        = p.REF_RATE_HZ.^(-1);
    
%     %trying to set the refresh rate to optimal (100Hz)
%     if ~p.DEBUG
%         SetResolution(p.screenNumber,p.SCREEN_WIDTH,p.SCREEN_HEIGHT,(p.REF_RATE_OPTIMAL));
%     end
    
    disp(['p.SCREEN_WIDTH: ' num2str(p.SCREEN_WIDTH)]);
    disp(['p.SCREEN_HEIGHT: ' num2str(p.SCREEN_HEIGHT)]);
    disp(['p.REF_RATE_HZ: ' num2str(p.REF_RATE_HZ)]);
    disp(['p.REF_RATE_SEC: ' num2str(p.REF_RATE_SEC)]); % in seconds. 
    
    if p.FULLSCREEN
        HideCursor(p.w);
    end
  
    slCharacterEncoding('ISO_8859-8')
    Screen('TextFont', p.w, '-:lang=he');
    if ~IsLinux
%         Screen('Preference', 'TextEncodingLocale', 'Hebrew_israel.1255');
        Screen('Preference', 'TextEncodingLocale', 'UTF-8');
    else
        Screen('Preference', 'TextEncodingLocale', 'en_US.UTF-8');
    end
    Screen('Preference', 'TextRenderer', 0);
    
    % this enables us to use the alpha transparency
    Screen('BlendFunction', p.w, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA',p.gray);

    Priority(MaxPriority(p.w));

    %% PRELIMINTY PREPATATION
    % check for Opengl compatibility, abort otherwise
    AssertOpenGL;

    rng('default');
    % Reseed the random-number generator for each expt.
    rng('Shuffle');

    % Do dummy calls to GetSecs, WaitSecs, KbCheck
    KbCheck;
    WaitSecs(0.1);
    GetSecs;
    if p.FULLSCREEN
        ListenChar(2);
    end
end