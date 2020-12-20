function screenError = initPsychtoolbox()
    % INITPSYCHTOOLBOX Initilizes Psychtoolbox and opens graphics window
    % output:
    % -------
    % * Opens a psychtoolbox window *
    % screenError - true or false answer if the function did not succeed in
    % opening a 100Hz window.

    global screenScaler oldone screenNumber DEBUG ScreenHeight ScreenWidth refRateHz refRateSec gray w REF_RATE_OPTIMAL center 
    global WINDOW_RESOLUTION debugFactor NO_FULLSCREEN  

    REF_RATE_OPTIMAL = 100;
    
    PsychDefaultSetup(2);

    %trying to set the refresh rate to optimal (100Hz)
    try
        SetResolution(screenNumber,ScreenWidth,ScreenHeight,(REF_RATE_OPTIMAL));
        screenError = false;
    catch
        screenError = true;
    end
    
    % Set sync tests:
 
    %Screen('Preference', 'SkipSyncTests', 0)
    try
        if DEBUG; Screen('Preference', 'SkipSyncTests', 1); else; Screen('Preference', 'SkipSyncTests', 0); end
    catch
        if DEBUG; Screen('Preference', 'SkipSyncTests', 1); else; Screen('Preference', 'SkipSyncTests', 0); end
    end
   

    Screen('Preference', 'VisualDebugLevel', 4);

    screens         =   Screen('Screens');
    screenNumber    =   max(screens);
    gray           =   128 * [1 1 1 1];

    % Finding the screen size and current resolution
    try
        if NO_FULLSCREEN; [w, wRect]  =  Screen('OpenWindow',screenNumber, gray, WINDOW_RESOLUTION); else; [w, wRect]  =  Screen('OpenWindow',screenNumber, gray); end
    catch
        if NO_FULLSCREEN; [w, wRect]  =  Screen('OpenWindow',screenNumber, gray, WINDOW_RESOLUTION); else; [w, wRect]  =  Screen('OpenWindow',screenNumber, gray); end
    end
    
    ScreenWidth     =  wRect(3); disp(['ScreenWidth: ' num2str(ScreenWidth)]);
    ScreenHeight    =  wRect(4); disp(['ScreenHeight: ' num2str(ScreenHeight)]);
    center          =  [ScreenWidth/2; ScreenHeight/2];
    refRateHz = Screen('NominalFrameRate', w); disp(['refRateHz: ' num2str(refRateHz)]);
    refRateSec = refRateHz.^(-1); disp(['refRateSec: ' num2str(refRateSec)]); % in seconds. 
    if DEBUG == 2; refRateSec = refRateSec / debugFactor; end
    sca;

    screenScaler = ScreenWidth/1920; % allows scaling so that with smaller screens, objects will be of smaller sizes (1 = Full HD)

    try
        if NO_FULLSCREEN; [w, wRect]  =  Screen('OpenWindow',screenNumber, gray, WINDOW_RESOLUTION); else; [w, wRect]  =  Screen('OpenWindow',screenNumber, gray); end
    catch
        if NO_FULLSCREEN; [w, wRect]  =  Screen('OpenWindow',screenNumber, gray, WINDOW_RESOLUTION); else; [w, wRect]  =  Screen('OpenWindow',screenNumber, gray); end
    end

    if ~NO_FULLSCREEN
%         HideCursor(1);
    end
  
    slCharacterEncoding('ISO_8859-8')
    Screen('TextFont', w, '-:lang=he');
    if ~IsLinux
%         oldone = Screen('Preference', 'TextEncodingLocale', 'Hebrew_israel.1255');
        oldone = Screen('Preference', 'TextEncodingLocale', 'UTF-8');
    else
        oldone = Screen('Preference', 'TextEncodingLocale', 'en_US.UTF-8');
    end
    Screen('Preference', 'TextRenderer', 0);

    global ptb_drawformattedtext_disableClipping;
    ptb_drawformattedtext_disableClipping = 1;
    
    % this enables us to use the alpha transparency
    Screen('BlendFunction', w, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA',gray);

    Priority(MaxPriority(w));

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
    if ~NO_FULLSCREEN
        ListenChar(2);
    end
end