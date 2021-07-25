%%
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
        practice_wo_prime_trials = getTrials('practice_wo_prime', p);
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
        p = experiment(trials, practice_trials, practice_wo_prime_trials, p);
        
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
%%
function [p] = experiment(trials, practice_trials, practice_wo_prime_trials, p)
    % 1st instructions.
    showTexture(p.FIRST_INSTRUCTIONS_SCREEN, p);
    getInput('instruction', p);
    
    % practice w/o prime.
    showTexture(p.SPEED_PRACTICE_SCREEN, p);
    getInput('instruction', p);
    p = runTrials(practice_wo_prime_trials, 0, p);
    
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
%%
function [p] = runTrials(trials, include_prime, p)

    % Assigned to prime ans on block w/o prime.
    default_prime_ans = struct('answer',NaN, 'traj_to',NaN(p.MAX_CAP_LENGTH, 3), 'timecourse_to',NaN(p.MAX_CAP_LENGTH,1),...
        'traj_from',NaN(p.MAX_CAP_LENGTH, 3), 'timecourse_from',NaN(p.MAX_CAP_LENGTH,1), 'categor_time',NaN);
    
    try        
        % Iterates over trials.
        while ~isempty(trials)
            times = nan(9,1); % times of each event, taken from system's clock.
            
            % block change
            if trials.iTrial(1) ~= 1 
                if mod(trials.iTrial(1), p.BLOCK_SIZE) == 1
                    showTexture(p.BLOCK_END_SCREEN, p);
                    KbWait([], 3);
                end               
            end
            
            % Make masks slides.
            p.MASK1_TXTR = getTextureFromHD(p.MASKS(trials.mask1(1)), p);
            p.MASK2_TXTR = getTextureFromHD(p.MASKS(trials.mask2(1)), p);
            p.MASK3_TXTR = getTextureFromHD(p.MASKS(trials.mask3(1)), p);
            
            % Set prime font now to save run times.
            Screen('TextFont',p.w, p.HAND_FONT_TYPE);
            Screen('TextSize', p.w, p.HAND_FONT_SIZE);
            
            if include_prime
                % Create queue for current trial.
                categor_q = build_q(trials, 'categor', p);
                recog_q = build_q(trials, 'recog', p);
                
                % Shows: masks, prime, target, categorization question.
                [target_ans, events(1:7)] = getAns('categor', categor_q, p);
                times(1) = events.times(event.names == 'fix');
                times(2) = events.times(event.names == 'mask1');
                times(3) = events.times(event.names == 'mask2');
                times(4) = events.times(event.names == 'prime');
                times(5) = events.times(event.names == 'mask3');
                times(6) = events.times(event.names == 'target');
                times(7) = events.times(event.names == 'categor');
                
                % Shows: recognition question.
                [prime_ans, events] = getAns('recog', recog_q, p);
                times(8) = events.times(event.names == 'recog');
                
                % PAS
                times(9) = showPas(p);
                [pas, pas_time] = getInput('pas', p);
            else
                % Create queue for current trial.
                categor_q = build_q(trials, 'categor_wo_prime', p);
                
                % Shows: masks, target, categorization question.
                [target_ans, times_temp] = getAns('categor_wo_prime', categor_q, p);
                times(1:7) = [times_temp(1:3); times_temp(4); times_temp(4:6)];
                
                % Fill missing values.
                prime_ans = default_prime_ans; % Recog ans.
                times(8) = times(7); % Recog disp time.
                times(9) = times(8); % PAS disp time.
                pas = 1; % PAS ans.
                pas_time = times(9);
            end
            
            % Assigns collected data to trials.
            trials = assign_to_trials(trials, times, target_ans, prime_ans, pas, pas_time);
            
            % Save trial to file and removes it from list.
            saveToFile(trials(1,:), p);
            trials(1,:) = [];
            
            % Close mask textures.
            Screen('close',[p.MASK1_TXTR p.MASK2_TXTR p.MASK3_TXTR]);
        end
    catch e % if error occured, saves data before exit.
        fixOutput(p);
        rethrow(e);
    end
end
%%
function [p] = exampleTrial(trials, p)
    
    try
        % Set prime font now to save run times.
        Screen('TextFont',p.w, p.HAND_FONT_TYPE);
        Screen('TextSize', p.w, p.HAND_FONT_SIZE);
        
        % Make masks slides.
        mask1 = getTextureFromHD(p.MASKS(trials.mask1(1)), p);
        mask2 = getTextureFromHD(p.MASKS(trials.mask2(1)), p);
        mask3 = getTextureFromHD(p.MASKS(trials.mask3(1)), p);

        % Fixation
        times(1) = showFixation(p);
        waitUntil(p.FIX_DURATION_SEC, p);

        % Mask 1
        Screen('DrawTexture',p.w, mask1);
        [~,times] = Screen('Flip', p.w);
        waitUntil(p.MASK1_DURATION_SEC, p);

        % Mask 2
        Screen('DrawTexture',p.w, mask2);
        [~,times] = Screen('Flip', p.w);
        waitUntil(p.MASK2_DURATION_SEC, p);

        % Prime
        Screen('DrawTexture',p.w, p.CATEGOR_TXTR); % Shows categor answers with word.
        DrawFormattedText(p.w, double('תיק'), 'center', (p.SCREEN_HEIGHT/2+3), [0 0 0]);
        [~,times] = Screen('Flip',p.w,0,1);
        waitUntil(p.PRIME_DURATION_SEC, p);

        % Mask 3
        Screen('DrawTexture',p.w, mask3);
        [~,times] = Screen('Flip', p.w);
        waitUntil(p.MASK3_DURATION_SEC, p);

        % Target
        Screen('TextFont',p.w, p.FONT_TYPE); % Set target font.
        Screen('TextSize', p.w, p.FONT_SIZE);
        Screen('DrawTexture',p.w, p.CATEGOR_TXTR); % Shows categor answers with target.
        DrawFormattedText(p.w, double('עלה'), 'center', (p.SCREEN_HEIGHT/2+3), [0 0 0]);
        [~,times] = Screen('Flip',p.w,0,1);
        
        % Waits for key press.
        getInput('instruction',p);

        % Target categorization.
%         target_ans = getAns('categor', q, p); dont need this

        % Prime recognition.
        Screen('DrawTexture',p.w, p.RECOG_TXTR);
        Screen('TextSize', p.w, p.RECOG_FONT_SIZE);
        DrawFormattedText(p.w, double('תיק'), p.SCREEN_WIDTH*2/7, p.SCREEN_HEIGHT*5/16, [0 0 0]);
        DrawFormattedText(p.w, double('ספל'), p.SCREEN_WIDTH*21/32, p.SCREEN_HEIGHT*5/16, [0 0 0]);
        [~,times] = Screen('Flip', p.w, 0, 1);
        
        % Waits for key press.
        getInput('instruction',p);
        
%         prime_ans = getAns('recog', p); dont need this

        % PAS
        times(9) = showPas(p);
        [pas, pas_time] = getInput('pas', p);
        
        % Close mask textures.
        Screen('close',[mask1 mask2 mask3]);
    catch e % if error occured, saves data before exit.
        fixOutput(p);
        rethrow(e);
    end
end
%%
function [] = safeExit(p)
    if ~p.DEBUG
        p.NATNETCLIENT.disconnect;
    end
%     Priority(0);
    sca;
    ShowCursor;
    ListenChar(0);
end

function [times] = showFixation(p)
    % waits until finger in start point.
    if ~p.DEBUG
        finInStartPoint(p);
    end
    
    Screen('DrawTexture',p.w, p.FIXATION_TXTR);
    [~,times] = Screen('Flip', p.w);
end

function [times] = showMask(mask, p) % 'mask' - which mask to show (1st / 2nd / 3rd).
    Screen('DrawTexture',p.w, mask);
    [~,times] = Screen('Flip', p.w);
end

function [times] = showWord(trial, prime_or_target, p)
    Screen('DrawTexture',p.w, p.CATEGOR_TXTR); % Shows categor answers with word.
    DrawFormattedText(p.w, double(trial.(prime_or_target){:}), 'center', (p.SCREEN_HEIGHT/2+3), [0 0 0]);
    [~,times] = Screen('Flip',p.w,0,1);
end

% draws prime and distractor for recognition task.
function [times] = showRecog(trial, p)
    if trial.prime_left
        left_word = trial.prime{:};
        right_word = trial.distractor{:};
    else
        left_word = trial.distractor{:};
        right_word = trial.prime{:};
    end
    
    Screen('DrawTexture',p.w, p.RECOG_TXTR);
    Screen('TextSize', p.w, p.RECOG_FONT_SIZE);
    DrawFormattedText(p.w, double(left_word), p.SCREEN_WIDTH*2/7, p.SCREEN_HEIGHT*5/16, [0 0 0]);
    DrawFormattedText(p.w, double(right_word), p.SCREEN_WIDTH*21/32, p.SCREEN_HEIGHT*5/16, [0 0 0]);
    [~,times] = Screen('Flip', p.w, 0, 1);
end

% draws PAS task.
function [times] = showPas(p)
    times = showTexture(p.PAS_SCREEN, p);
end

% Assigns data captured in this trial to 'trials'.
function [trials] = assign_to_trials(trials, times, target_ans, prime_ans, pas, pas_time)
    trials.trial_start_time(1) = times(1);

    % Assigns event times.
    trials.fix_time(1) = times(1);
    trials.mask1_time(1) = times(2);
    trials.mask2_time(1) = times(3);
    trials.prime_time(1) = times(4);
    trials.mask3_time(1) = times(5);
    trials.target_time(1) = times(6);
    trials.categor_time(1) = times(7);
    trials.recog_time(1) = times(8);
    trials.pas_time(1) = times(9);

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
    trials.pas_rt(1) = pas_time - times(9);
    
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
    [~,times] = Screen('Flip',p.w);
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
% didn't use switch case to save process times.
function [] = waitUntil(event_dur, p)
%     WaitSecs(event_dur - p.REF_RATE_SEC / 2); % "- p.REF_RATE_SEC / 2" so that it will flip exactly at the end of p.FIX_DURATION.
    WaitSecs(event_dur - p.REF_RATE_SEC * 3 / 4);
%     WaitSecs('UntilTime', times(1) + (event_dur - p.REF_RATE_SEC / 2));
end