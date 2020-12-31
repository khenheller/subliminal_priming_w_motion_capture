function [ ] = main(subNumber)     
    % Subliminal priming experiment by Liad and Khen.
    % Coded by Khen (khenheller@mail.tau.ac.il)
    % Prof. Liad Mudrik's Lab, Tel-Aviv University

    global NO_FULLSCREEN WINDOW_RESOLUTION TIME_SLOW
    global compKbDevice
    global WELCOME_SCREEN LOADING_SCREEN
    global TOUCH_PLANE_INFO NATNETCLIENT START_POINT

    TIME_SLOW = 1; % default = 1; time slower for debugging
    NO_FULLSCREEN = false; % default = false
    WINDOW_RESOLUTION = [100 100 900 700];
    
    global SUB_NUM
    SUB_NUM = subNumber;    
    
    if nargin < 1; error('Missing subject number!'); end

    try
        
        % Calibration and connection to natnetclient.
        [TOUCH_PLANE_INFO, NATNETCLIENT] = touch_plane_setup();
        START_POINT = setStartPoint();
        
        initPsychtoolbox();
        initConstants();

        saveCode();        
        
        % Experiment
        showTexture(LOADING_SCREEN);
        trials = newTrials();
        showTexture(WELCOME_SCREEN);
        KbWait(compKbDevice,3);
        experiment(trials);
        
        NATNETCLIENT.disconnect;
        
    catch e
        safeExit();
        rethrow(e);        
    end
    safeExit();
end

function [] = cleanExit( )
    error('Exit by user!');
end

function [] = experiment(trials)

    global INSTRUCTIONS_SCREEN PRACTICE_SCREEN TEST_SCREEN END_SCREEN
    
    % instructions.
    showTexture(INSTRUCTIONS_SCREEN);
    getInput('instruction');
    
    % practice.
    showTexture(PRACTICE_SCREEN);
    getInput('instruction');
    runPractice(trials);
    
    % test.
    showTexture(TEST_SCREEN);
    getInput('instruction');
    runTrials(trials);
    
    showTexture(END_SCREEN);
    getInput('instruction');
end

function [] = runPractice(trials)
    global refRateSec;
    global FIX_DURATION MASK1_DURATION MASK2_DURATION PRIME_DURATION MASK3_DURATION TARGET_DURATION; % in sec.
    global NUM_PRACTICE_TRIALS SUB_NUM;
    global PRACTICE_MASKS;
    
    % natural category on left side for odd sub numbers.
    natural_left = rem(SUB_NUM, 2);
    % table containing practice masks.
    practice_masks = table({PRACTICE_MASKS(1)}, {PRACTICE_MASKS(2)}, {PRACTICE_MASKS(3)},...
        'VariableNames',{'mask1','mask2','mask3'});
    % table containing practice words.
    pratice_trials = table({'גזר';'טלויזיה';'מחשב';'עלה'},...
        {'גזר';'טלויזיה';'תפוז';'ספל'},...
        [natural_left; natural_left; natural_left; natural_left],...
        [1; 0; 1; 0],...
        {'עגבניה';'שלט';'גלשן';'ענף'},...
        'VariableNames',{'prime','target','natural_left','prime_left','distractor'});
    
    % Iterates over trials.
    for tr = 1 : NUM_PRACTICE_TRIALS

        % Fixation
        showFixation();
        WaitSecs(FIX_DURATION - refRateSec / 2); % "- refRateSec / 2" so that it will flip exactly at the end of TIME_FIXATION.

        % Mask 1
        showMask(practice_masks, 'mask1');
        WaitSecs(MASK1_DURATION - refRateSec / 2);

        % Mask 2
        showMask(practice_masks, 'mask2');
        WaitSecs(MASK2_DURATION - refRateSec / 2);

        % Prime
        showWord(pratice_trials(tr,:), 'prime');
        WaitSecs(PRIME_DURATION - refRateSec / 2);

        % Mask 3
        showMask(practice_masks, 'mask3');
        WaitSecs(MASK3_DURATION - refRateSec / 2);

        % Target
        showWord(pratice_trials(tr,:), 'target');

        % Target categorization.
        getAns('categor', trials.natural_left(1));

        % Prime recognition.
        showRecog(pratice_trials(tr,:));
        getAns('recog');

        % PAS
        showPas();
        getInput('pas');
    end
end

function [trials] = runTrials(trials)
    global compKbDevice refRateSec;
    global FIX_DURATION MASK1_DURATION MASK2_DURATION PRIME_DURATION MASK3_DURATION; % in sec.
    global BLOCK_END_SCREEN BLOCK_SIZE;
    
    mistakesCounter = 0;
    
    try        
        % Iterates over trials.
        while ~isempty(trials)
            time = nan(9,1); % time of each event, taken from system's clock.
            
            % block change
            if trials.iTrial(1) ~= 1 
                if mod(trials.iTrial(1), BLOCK_SIZE) == 1
                    time = showTexture(BLOCK_END_SCREEN);
                    KbWait(compKbDevice,3);
                end               
            end
            
            % Fixation
            time(1) = showFixation();
            WaitSecs(FIX_DURATION - refRateSec / 2); % "- refRateSec / 2" so that it will flip exactly at the end of TIME_FIXATION.

            % Mask 1
            time(2) = showMask(trials(1,:), 'mask1');
            WaitSecs(MASK1_DURATION - refRateSec / 2);
            
            % Mask 2
            time(3) = showMask(trials(1,:), 'mask2');
            WaitSecs(MASK2_DURATION - refRateSec / 2);

            % Prime
            time(4) = showWord(trials(1,:), 'prime');
            WaitSecs(PRIME_DURATION - refRateSec / 2);

            % Mask 3
            time(5) = showMask(trials(1,:), 'mask3');
            WaitSecs(MASK3_DURATION - refRateSec / 2);

            % Target
            time(6) = showWord(trials(1,:), 'target');
            
            % Target categorization.
            target_ans = getAns('categor', trials.natural_left(1));
            
            % Prime recognition.
            time(8) = showRecog(trials(1,:));
            prime_ans = getAns('recog');
            
            % PAS
            time(9) = showPas();
            [pas, pas_rt] = getInput('pas');
            
            % Assigns collected data to trials.
            trials = assign_to_trials(trials, time, target_ans, prime_ans, pas, pas_rt);
            
            % Save trial to file and removes it from list.
            saveToFile(trials(1,:));
            trials(1,:) = [];

%             % wrong key catch
%             if trials.answer{1} == WRONG_KEY
%                 mistakesCounter = mistakesCounter + 1;
%                 if mistakesCounter == NUMBER_OF_ERRORS_PROMPT
%                     mistakesCounter = 0;
%                     showTexture(ERROR_CLICK_SLIDE);
%                     WaitSecs(TIME_SHOW_PROMPT); 
%                     KbReleaseWait(compKbDevice);
%                     KbWait(compKbDevice,3);                                
%                 end
%             end
        end
    catch e % if error occured, saves data before exit.
        saveTable(trials,'trialsExperiment');
        rethrow(e);
    end
    
    saveTable(trials,'trialsExperiment');
end

function [] = safeExit()
    global oldone
    global NATNETCLIENT
    NATNETCLIENT.disconnect;
    Priority(0);
    sca;
    ShowCursor;
    ListenChar(0);
%     Screen('Preference', 'TextEncodingLocale', oldone);
end

function [] = saveTable(tbl,type)

    global DATA_FOLDER SUB_NUM %subject number
    dir = fullfile(pwd,DATA_FOLDER,num2str(SUB_NUM));
    mkdir(dir);

    prf1 = sprintf('%s_%d',type,SUB_NUM);
    fileName = fullfile(dir,prf1);

    try
        writetable(tbl,[fileName,'.xlsx']);
        save([fileName,'.mat'],'tbl');        
    catch
        save([fileName,'.mat'],'tbl');
    end
end

function [time] = showFixation()
    % waits until finger in start point.
    finInStartPoint();
    
    global w % window experiment runs on. initialized in initPsychtoolbox();
    global FIXATION_SCREEN
    Screen('DrawTexture',w, FIXATION_SCREEN);
    [~,time] = Screen('Flip', w);
end

function [time] = showMask(trial, mask) % 'mask' - which mask to show (1st / 2nd / 3rd).
    global w
    Screen('DrawTexture',w, trial.(mask){:});
    [~,time] = Screen('Flip', w);
end

function [ time ] = showMessage( message )
    global w text
    DrawFormattedText(w, textProcess(message), 'center', 'center', text.Color);
    [~, time] = Screen('Flip', w);
end

function [time] = showWord(trial, prime_or_target)
    global w fontType handFontType
    
    % prime=handwriting, target=typescript
    if strcmp(prime_or_target, 'prime')
        Screen('TextFont',w, handFontType);
    else
        Screen('TextFont',w, fontType);
    end

    DrawFormattedText(w, double(trial.(prime_or_target){:}), 'center', 'center', [0 0 0]);
    [~,time] = Screen('Flip',w,0,1);
end

% draws prime and distractor for recognition task.
function [time] = showRecog(trial)
    global w ScreenWidth ScreenHeight
    global RECOG_SCREEN;
    
    if trial.prime_left
        left_word = trial.prime{:};
        right_word = trial.distractor{:};
    else
        left_word = trial.distractor{:};
        right_word = trial.prime{:};
    end
    
    Screen('DrawTexture',w, RECOG_SCREEN);
    DrawFormattedText(w, double(left_word), ScreenWidth*2/10, ScreenHeight*3/8, [0 0 0]);
    DrawFormattedText(w, double(right_word), 'right', ScreenHeight*3/8, [0 0 0], [], [], [], [] ,[],...
        [ScreenWidth/4 ScreenHeight ScreenWidth*8/10 0]);
    [~,time] = Screen('Flip', w, 0, 1);
end

% draws PAS task.
function [time] = showPas()
    global w PAS_SCREEN
    
    Screen('DrawTexture',w, PAS_SCREEN);
    [~,time] = Screen('Flip', w, 0, 1);
end

function [time] = showTexture(txtr)
    global w
    Screen('DrawTexture',w, txtr);
    [~,time] = Screen('Flip', w);    
end

function [ txt ] = textProcess( txt )
    txt = double(txt);
%     txt = flip(txt);
end

% Assigns data captured in this trial to 'trials'.
function [trials] = assign_to_trials(trials, time, target_ans, prime_ans, pas, pas_rt)
    trials.trial_start_time{1} = time(1);

    % Assigns event times.
    trials.fix_time{1} = time(1);
    trials.mask1_time{1} = time(2);
    trials.mask2_time{1} = time(3);
    trials.prime_time{1} = time(4);
    trials.mask3_time{1} = time(5);
    trials.target_time{1} = time(6);
    trials.categor_time{1} = target_ans.categor_time;
    trials.recog_time{1} = time(8);
    trials.pas_time{1} = time(9);

    % Save responses.
    trials.target_ans_left{1} = target_ans.answer;
    trials.target_x_to{1} = target_ans.traj_to(:,1);
    trials.target_y_to{1} = target_ans.traj_to(:,2);
    trials.target_z_to{1} = target_ans.traj_to(:,3);
    trials.target_x_from{1} = target_ans.traj_from(:,1);
    trials.target_y_from{1} = target_ans.traj_from(:,2);
    trials.target_z_from{1} = target_ans.traj_from(:,3);
    trials.target_timecourse_to{1} = target_ans.timecourse_to;
    trials.target_timecourse_from{1} = target_ans.timecourse_from;
    trials.target_rt{1} = max(target_ans.timecourse_to) - min(target_ans.timecourse_to);
    trials(1,:) = checkAns(trials(1,:), 'categor');

    trials.prime_ans_left{1} = prime_ans.answer;
    trials.prime_x_to{1} = prime_ans.traj_to(:,1);
    trials.prime_y_to{1} = prime_ans.traj_to(:,2);
    trials.prime_z_to{1} = prime_ans.traj_to(:,3);
    trials.prime_x_from{1} = prime_ans.traj_from(:,1);
    trials.prime_y_from{1} = prime_ans.traj_from(:,2);
    trials.prime_z_from{1} = prime_ans.traj_from(:,3);
    trials.prime_timecourse_to{1} = prime_ans.timecourse_to;
    trials.prime_timecourse_from{1} = prime_ans.timecourse_from;
    trials.prime_rt{1} = max(prime_ans.timecourse_to) - min(prime_ans.timecourse_to);
    trials(1,:) = checkAns(trials(1,:), 'recog');

    trials.pas{1} = pas;
    trials.pas_rt{1} = pas_rt;
    
    trials.trial_end_time{1} = trials.pas_time{1} + pas_rt;
end