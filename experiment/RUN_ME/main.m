function [p] = main(p)
    % Subliminal priming experiment by Liad and Khen.
    % Coded by Khen (khenheller@mail.tau.ac.il)
    % Prof. Liad Mudrik's Lab, Tel-Aviv University
    
    if nargin < 1
        error('Missing subject number!');
    end

    try
        
        if ~p.DEBUG
            % Calibration and connection to natnetclient.
            [p.TOUCH_PLANE_INFO, p.NATNETCLIENT] = touch_plane_setup();
            p.SAMPLE_RATE = p.NATNETCLIENT.FrameRate;
        end
        
        % Initialize params.
        p = initPsychtoolbox(p);
        p = initConstants(1, p);
        
        % Generates trials.
        showTexture(p.LOADING_SCREEN, p);
        trials = getTrials('test', p);
        practice_trials = getTrials('practice', p);
        
        % Start,end points calibration.
        if ~p.DEBUG
            p = setPoints(p);
        end
        
        saveCode(trials.list_id{1}, p);
        save('p.mat', 'p');
        
        % Experiment
        showTexture(p.WELCOME_SCREEN, p);
        getInput('instruction', p);
        p = experiment(trials, practice_trials, p);
        
        if ~p.DEBUG
            p.NATNETCLIENT.disconnect;
        end
        
    catch e
        safeExit(p);
        rethrow(e);
    end
    safeExit(p);
end

function [] = cleanExit( )
    error('Exit by user!');
end

function [p] = experiment(trials, practice_trials, p)
    % 1st instructions.
    showTexture(p.FIRST_INSTRUCTIONS_SCREEN, p);
    getInput('instruction', p);
    
    % practice w/o prime.
    showTexture(p.SPEED_PRACTICE_SCREEN, p);
    getInput('instruction', p);
    p = runTrials(practice_trials, 0, p);
    
    % 2nd instructions.
    showTexture(p.SECOND_INSTRUCTIONS_SCREEN, p);
    getInput('instruction', p);
    
    % Example trial.
    showTexture(p.TRIAL_EXAMPLE_SCREEN, p);
    getInput('instruction', p);
    exampleTrial(trials, p);
    
    % practice with prime.
    showTexture(p.PRACTICE_SCREEN, p);
    getInput('instruction', p);
    p = runTrials(practice_trials, 1, p);
    
    % test.
    showTexture(p.TEST_SCREEN, p);
    getInput('instruction', p);
    p = runTrials(trials, 1, p);
    
    showTexture(p.SAVING_DATA_SCREEN, p);
    
    fixOutput(p);
    
    showTexture(p.END_SCREEN, p);
    getInput('instruction', p);
end

function [p] = runTrials(trials, include_prime, p)

    % Assigned to prime ans on block w/o prime.
    default_prime_ans = struct('answer',NaN, 'traj_to',NaN(p.MAX_CAP_LENGTH, 3), 'timecourse_to',NaN(p.MAX_CAP_LENGTH,1),...
        'traj_from',NaN(p.MAX_CAP_LENGTH, 3), 'timecourse_from',NaN(p.MAX_CAP_LENGTH,1), 'categor_time',NaN);
    
    % Set categories display side.
    if trials{1,'natural_left'}
        p.CATEGOR_SCREEN = p.CATEGOR_NATURAL_LEFT_SCREEN;
    else
        p.CATEGOR_SCREEN = p.CATEGOR_NATURAL_RIGHT_SCREEN;
    end
    
    try        
        % Iterates over trials.
        while ~isempty(trials)
            time = nan(9,1); % time of each event, taken from system's clock.
            
            % block change
            if trials.iTrial(1) ~= 1 
                if mod(trials.iTrial(1), p.BLOCK_SIZE) == 1
                    time = showTexture(p.BLOCK_END_SCREEN, p);
                    KbWait([], 3);
                end               
            end
            
            % Set prime font now to save run time.
            Screen('TextFont',p.w, p.HAND_FONT_TYPE);
            Screen('TextSize', p.w, p.HAND_FONT_SIZE);
            
            % Fixation
            time(1) = showFixation(p);
%             waitUntil(p.FIX_DURATION, p);
            WaitSecs(p.FIX_DURATION);
            
            % Mask 1
            time(2) = showMask(trials(1,:), 'mask1', p);
%             waitUntil(p.MASK1_DURATION, p);
            WaitSecs(p.MASK1_DURATION);
            
            % Mask 2
            time(3) = showMask(trials(1,:), 'mask2', p);
%             waitUntil(p.MASK2_DURATION, p);
            WaitSecs(p.MASK2_DURATION);
            
            % Prime
            if include_prime
                time(4) = showWord(trials(1,:), 'prime', p);
%                 waitUntil(p.PRIME_DURATION, p);
                WaitSecs(p.PRIME_DURATION);
            else
                time(4) = time(3);
            end
            
            % Mask 3
            time(5) = showMask(trials(1,:), 'mask3', p);
%             waitUntil(p.MASK3_DURATION, p);
            WaitSecs(p.MASK3_DURATION);
            
            % Target
            Screen('TextFont',p.w, p.FONT_TYPE); % Set target font.
            Screen('TextSize', p.w, p.FONT_SIZE);
            time(6) = showWord(trials(1,:), 'target', p);
            
            % Target categorization.
            target_ans = getAns('categor', p);
            
            % Prime recognition.
            if include_prime
                time(8) = showRecog(trials(1,:), p);
                prime_ans = getAns('recog', p);
            else
                time(8) = time(6);
                prime_ans = default_prime_ans;
            end
            
            % PAS
            time(9) = showPas(p);
            [pas, pas_time] = getInput('pas', p);
            
            % Assigns collected data to trials.
            trials = assign_to_trials(trials, time, target_ans, prime_ans, pas, pas_time);
            
            % Save trial to file and removes it from list.
            saveToFile(trials(1,:), p);
            trials(1,:) = [];
        end
    catch e % if error occured, saves data before exit.
        fixOutput(p);
        rethrow(e);
    end
end

function [p] = exampleTrial(trials, p)

    % Set categories display side.
    if trials{1,'natural_left'}
        p.CATEGOR_SCREEN = p.CATEGOR_NATURAL_LEFT_SCREEN;
    else
        p.CATEGOR_SCREEN = p.CATEGOR_NATURAL_RIGHT_SCREEN;
    end
    
    try
        % Set prime font now to save run time.
        Screen('TextFont',p.w, p.HAND_FONT_TYPE);
        Screen('TextSize', p.w, p.HAND_FONT_SIZE);

        % Fixation
        time(1) = showFixation(p);
        waitUntil(p.FIX_DURATION, p);

        % Mask 1
        Screen('DrawTexture',p.w, p.MASKS(1));
        [~,time] = Screen('Flip', p.w);
        waitUntil(p.MASK1_DURATION, p);

        % Mask 2
        Screen('DrawTexture',p.w, p.MASKS(2));
        [~,time] = Screen('Flip', p.w);
        waitUntil(p.MASK2_DURATION, p);

        % Prime
        DrawFormattedText(p.w, double('תיק'), 'center', (p.SCREEN_HEIGHT/2+3), [0 0 0]);
        [~,time] = Screen('Flip',p.w,0,1);
        waitUntil(p.PRIME_DURATION, p);

        % Mask 3
        Screen('DrawTexture',p.w, p.MASKS(3));
        [~,time] = Screen('Flip', p.w);
        waitUntil(p.MASK3_DURATION, p);

        % Target
        Screen('TextFont',p.w, p.FONT_TYPE); % Set target font.
        Screen('TextSize', p.w, p.FONT_SIZE);
        Screen('DrawTexture',p.w, p.CATEGOR_SCREEN); % Shows categor answers with target.
        DrawFormattedText(p.w, double('עלה'), 'center', (p.SCREEN_HEIGHT/2+3), [0 0 0]);
        [~,time] = Screen('Flip',p.w,0,1);
        
        % Waits for key press.
        getInput('instruction',p);

        % Target categorization.
        target_ans = getAns('categor', p);

        % Prime recognition.
        Screen('DrawTexture',p.w, p.RECOG_SCREEN);
        Screen('TextSize', p.w, p.RECOG_FONT_SIZE);
        DrawFormattedText(p.w, double('תיק'), p.SCREEN_WIDTH*2/7, p.SCREEN_HEIGHT*5/16, [0 0 0]);
        DrawFormattedText(p.w, double('ספל'), p.SCREEN_WIDTH*21/32, p.SCREEN_HEIGHT*5/16, [0 0 0]);
        [~,time] = Screen('Flip', p.w, 0, 1);
        
        % Waits for key press.
        getInput('instruction',p);
        
        prime_ans = getAns('recog', p);

        % PAS
        time(9) = showPas(p);
        [pas, pas_time] = getInput('pas', p);
    catch e % if error occured, saves data before exit.
        fixOutput(p);
        rethrow(e);
    end
end

function [] = safeExit(p)
    if ~p.DEBUG
        p.NATNETCLIENT.disconnect;
    end
%     Priority(0);
    sca;
    ShowCursor;
    ListenChar(0);
end

function [time] = showFixation(p)
    % waits until finger in start point.
    finInStartPoint(p);
    
    Screen('DrawTexture',p.w, p.FIXATION_SCREEN);
    [~,time] = Screen('Flip', p.w);
end

function [time] = showMask(trial, mask, p) % 'mask' - which mask to show (1st / 2nd / 3rd).
    Screen('DrawTexture',p.w, trial.(mask));
    [~,time] = Screen('Flip', p.w);
end

function [time] = showWord(trial, prime_or_target, p)
    Screen('DrawTexture',p.w, p.CATEGOR_SCREEN); % Shows categor answers with word.
    DrawFormattedText(p.w, double(trial.(prime_or_target){:}), 'center', (p.SCREEN_HEIGHT/2+3), [0 0 0]);
    [~,time] = Screen('Flip',p.w,0,1);
end

% draws prime and distractor for recognition task.
function [time] = showRecog(trial, p)
    if trial.prime_left
        left_word = trial.prime{:};
        right_word = trial.distractor{:};
    else
        left_word = trial.distractor{:};
        right_word = trial.prime{:};
    end
    
    Screen('DrawTexture',p.w, p.RECOG_SCREEN);
    Screen('TextSize', p.w, p.RECOG_FONT_SIZE);
    DrawFormattedText(p.w, double(left_word), p.SCREEN_WIDTH*2/7, p.SCREEN_HEIGHT*5/16, [0 0 0]);
    DrawFormattedText(p.w, double(right_word), p.SCREEN_WIDTH*21/32, p.SCREEN_HEIGHT*5/16, [0 0 0]);
    [~,time] = Screen('Flip', p.w, 0, 1);
end

% draws PAS task.
function [time] = showPas(p)
    Screen('DrawTexture',p.w, p.PAS_SCREEN);
    [~,time] = Screen('Flip', p.w, 0, 1);
end

% Assigns data captured in this trial to 'trials'.
function [trials] = assign_to_trials(trials, time, target_ans, prime_ans, pas, pas_time)
    trials.trial_start_time(1) = time(1);

    % Assigns event times.
    trials.fix_time(1) = time(1);
    trials.mask1_time(1) = time(2);
    trials.mask2_time(1) = time(3);
    trials.prime_time(1) = time(4);
    trials.mask3_time(1) = time(5);
    trials.target_time(1) = time(6);
    trials.categor_time(1) = target_ans.categor_time;
    trials.recog_time(1) = time(8);
    trials.pas_time(1) = time(9);

    % Save responses.
    trials.target_ans_left(1) = target_ans.answer;
    trials.target_x_to{1} = target_ans.traj_to(:,1);
    trials.target_y_to{1} = target_ans.traj_to(:,2);
    trials.target_z_to{1} = target_ans.traj_to(:,3);
    trials.target_x_from{1} = target_ans.traj_from(:,1);
    trials.target_y_from{1} = target_ans.traj_from(:,2);
    trials.target_z_from{1} = target_ans.traj_from(:,3);
    trials.target_timecourse_to{1} = target_ans.timecourse_to;
    trials.target_timecourse_from{1} = target_ans.timecourse_from;
    trials.target_rt(1) = max(target_ans.timecourse_to) - min(target_ans.timecourse_to);
    trials(1,:) = checkAns(trials(1,:), 'categor');

    trials.prime_ans_left(1) = prime_ans.answer;
    trials.prime_x_to{1} = prime_ans.traj_to(:,1);
    trials.prime_y_to{1} = prime_ans.traj_to(:,2);
    trials.prime_z_to{1} = prime_ans.traj_to(:,3);
    trials.prime_x_from{1} = prime_ans.traj_from(:,1);
    trials.prime_y_from{1} = prime_ans.traj_from(:,2);
    trials.prime_z_from{1} = prime_ans.traj_from(:,3);
    trials.prime_timecourse_to{1} = prime_ans.timecourse_to;
    trials.prime_timecourse_from{1} = prime_ans.timecourse_from;
    trials.prime_rt(1) = max(prime_ans.timecourse_to) - min(prime_ans.timecourse_to);
    trials(1,:) = checkAns(trials(1,:), 'recog');

    trials.pas(1) = pas;
    trials.pas_rt(1) = pas_time - time(9);
    
    trials.trial_end_time(1) = trials.pas_time(1) + pas_time;
end

% Prints word on screen to measure thier actual size (by hand).
function [] = testWordSize(p)
    Screen('TextFont',p.w, p.HAND_FONT_TYPE);
    Screen('TextSize', p.w, p.HAND_FONT_SIZE);
    DrawFormattedText(p.w, double('אבגדה וזחטי אבגדהוזחטיכךלמנןסעפףצץקרשת'), 'p.CENTER', p.SCREEN_HEIGHT/4, [0 0 0]);
    
    Screen('TextFont',p.w, p.FONT_TYPE);
    Screen('TextSize', p.w, p.FONT_SIZE);
    DrawFormattedText(p.w, double('אבגדה וזחטי אבגדהוזחטיכךלמנןסעפףצץקרשת'), 'p.CENTER', p.SCREEN_HEIGHT*3/4, [0 0 0]);
    [~,time] = Screen('Flip',p.w);
end

% Sets start and end points in space.
function [p] = setPoints(p)
    p.START_POINT = setPoint(p.START_POINT_SCREEN, p);
    p.RIGHT_END_POINT = setPoint(p.RIGHT_END_POINT_SCREEN, p);
    p.LEFT_END_POINT = setPoint(p.LEFT_END_POINT_SCREEN, p);
    p.MIDDLE_POINT = setPoint(p.MIDDLE_POINT_SCREEN, p);
    file_name = [p.DATA_FOLDER '\sub' num2str(p.SUB_NUM) 'start_end_points.m'];
    save(file_name, 'p');
end

% Waits until event ends. 3 types of wait:
%   until event_dur - 1/2 refrate.
%   until event_dur - 3/4 refrate.
%   until last_event_time + event_dur - 1/2 refrate.
% didn't use switch case to save process time.
function [] = waitUntil(event_dur, p)
%     WaitSecs(event_dur - p.REF_RATE_SEC / 2); % "- p.REF_RATE_SEC / 2" so that it will flip exactly at the end of p.FIX_DURATION.
    WaitSecs(event_dur - p.REF_RATE_SEC * 3 / 4);
%     WaitSecs('UntilTime', time(1) + (event_dur - p.REF_RATE_SEC / 2));
end