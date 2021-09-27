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
        
        % Save code snapshot.
        saveCode(trials.list_id{1}, p);
        % Save 'p' snapshot.
        save([p.DATA_FOLDER 'sub' num2str(p.SUB_NUM) p.DAY '_p.mat'], 'p');
        
        % Experiment
        showTexture(p.WELCOME_SCREEN, p);
        getInput('instruction', p);
        p = experiment(trials, practice_trials, practice_wo_prime_trials, p);
        
        % Save 'p' snapshot.
        save([p.DATA_FOLDER 'sub' num2str(p.SUB_NUM) p.DAY '_p.mat'], 'p');
        
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
    
    switch p.DAY
        case 'day1'
            % Example trial.
            showTexture(p.TRIAL_EXAMPLE_SCREEN, p);
            getInput('instruction', p);
            exampleTrial(trials, 0, p);
            
            % test.
            showTexture(p.TEST_SCREEN, p);
            getInput('instruction', p);
            p = runTrials(trials, 0, p);
        case 'day2'
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
            exampleTrial(trials, 1, p);

            % practice with prime.
            showTexture(p.PRACTICE_SCREEN, p);
            getInput('instruction', p);
            p = runTrials(practice_trials, 1, p);

            % test.
            showTexture(p.TEST_SCREEN, p);
            getInput('instruction', p);
            p = runTrials(trials, 1, p);
    end
    
    showTexture(p.SAVING_DATA_SCREEN, p);
    
    fixOutput(p);
    
    showTexture(p.END_SCREEN, p);
    getInput('instruction', p);
end
%%
function [p] = runTrials(trials, include_prime, p)

    % Assigned to prime ans on block w/o prime.
    default_prime_ans = struct('answer_left',NaN, 'traj_to',NaN(p.MAX_CAP_LENGTH, 3), 'timecourse_to',NaN(p.MAX_CAP_LENGTH,1),...
        'traj_from',NaN(p.MAX_CAP_LENGTH, 3), 'timecourse_from',NaN(p.MAX_CAP_LENGTH,1), 'categor_time',NaN);
    
    % Shorter durations to avoide missing the screen flip.
    fix_duration = p.FIX_DURATION - p.REF_RATE_SEC * 3 / 4;
    mask1_duration = p.MASK1_DURATION - p.REF_RATE_SEC * 3 / 4;
    mask2_duration = p.MASK2_DURATION - p.REF_RATE_SEC * 3 / 4;
    prime_duration = p.PRIME_DURATION - p.REF_RATE_SEC * 3 / 4;
    mask3_duration = p.MASK3_DURATION - p.REF_RATE_SEC * 3 / 4;
    
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
            mask1 = getTextureFromHD(p.MASKS(trials.mask1(1)), p);
            mask2 = getTextureFromHD(p.MASKS(trials.mask2(1)), p);
            mask3 = getTextureFromHD(p.MASKS(trials.mask3(1)), p);
            
            % Set prime font now to save run times.
            Screen('TextFont',p.w, p.HAND_FONT_TYPE);
            Screen('TextSize', p.w, p.HAND_FONT_SIZE);
            
            % Fixation
            times(1) = showFixation(p);
            WaitSecs(fix_duration);
            
            % Mask 1
            times(2) = showMask(mask1, p);
            WaitSecs(mask1_duration);
            
            % Mask 2
            times(3) = showMask(mask2, p);
            WaitSecs(mask2_duration);
            
            % Prime
            if include_prime
                times(4) = showWord(trials(1,:), 'prime', p);
                WaitSecs(prime_duration);
            end
            
            % Mask 3
            times(5) = showMask(mask3, p);
            WaitSecs(mask3_duration);
            
            % Target
            Screen('TextFont',p.w, p.FONT_TYPE); % Set target font.
            Screen('TextSize', p.w, p.FONT_SIZE);
            times(6) = showWord(trials(1,:), 'target', p);
            
            % Target categorization.
            target_ans = getAns('categor', p);
            
            % Check answer.
            trials.target_ans_left(1) = target_ans.answer_left;
            trials(1,:) = checkAns(trials(1,:), 'categor');
            sub_answered = ~(target_ans.late_res | target_ans.slow_mvmnt | target_ans.early_res);
            if ~trials.target_correct(1) && sub_answered
                showTexture(p.WRONG_ANS_SCREEN, p);
                WaitSecs(p.MSG_DURATION);
            end
            
            % Prime recognition.
            if include_prime
                times(8) = showRecog(trials(1,:), p);
                prime_ans = getAns('recog', p);
            else
                times(4) = times(5);
                prime_ans = default_prime_ans;
            end
            
            % PAS
            if include_prime
                times(9) = showTexture(p.PAS_SCREEN, p);
                [pas, pas_ans_time] = getInput('pas', p);
            else
                
                times(9) = target_ans.categor_time;
                times(8) = times(9);
                pas = 1;
                pas_ans_time = times(9);
                pause(0.7);
            end
            
            % Assigns collected data to trials.
            trials = assign_to_trials(trials, times, target_ans, prime_ans, pas, pas_ans_time);
            
            % Save trial to file and removes it from list.
            saveToFile(trials(1,:), p);
            trials(1,:) = [];
            
            % Close mask textures.
            Screen('close',[mask1 mask2 mask3]);
        end
    catch e % if error occured, saves data before exit.
        fixOutput(p);
        rethrow(e);
    end
end
%%
function [p] = exampleTrial(trials, include_prime, p)

    % Shorter durations to avoide missing the screen flip.
    fix_duration = p.FIX_DURATION - p.REF_RATE_SEC * 3 / 4;
    mask1_duration = p.MASK1_DURATION - p.REF_RATE_SEC * 3 / 4;
    mask2_duration = p.MASK2_DURATION - p.REF_RATE_SEC * 3 / 4;
    prime_duration = p.PRIME_DURATION - p.REF_RATE_SEC * 3 / 4;
    mask3_duration = p.MASK3_DURATION - p.REF_RATE_SEC * 3 / 4;

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
        WaitSecs(fix_duration);

        % Mask 1
        Screen('DrawTexture',p.w, mask1);
        [~,times] = Screen('Flip', p.w);
        WaitSecs(mask1_duration);

        % Mask 2
        Screen('DrawTexture',p.w, mask2);
        [~,times] = Screen('Flip', p.w);
        WaitSecs(mask2_duration);

        if include_prime
            % Prime
            Screen('DrawTexture',p.w, p.CATEGOR_TXTR); % Shows categor answers with word.
            DrawFormattedText(p.w, double('תיק'), 'center', (p.SCREEN_HEIGHT/2+3), [0 0 0]);
            [~,times] = Screen('Flip',p.w,0,1);
            WaitSecs(prime_duration);
        end

        % Mask 3
        Screen('DrawTexture',p.w, mask3);
        [~,times] = Screen('Flip', p.w);
        WaitSecs(mask3_duration);

        % Target
        Screen('TextFont',p.w, p.FONT_TYPE); % Set target font.
        Screen('TextSize', p.w, p.FONT_SIZE);
        Screen('DrawTexture',p.w, p.CATEGOR_TXTR); % Shows categor answers with target.
        DrawFormattedText(p.w, double('עלה'), 'center', (p.SCREEN_HEIGHT/2+3), [0 0 0]);
        [~,times] = Screen('Flip',p.w,0,1);
        
        % Waits for key press.
        getInput('instruction',p);

        % Target categorization.
%         target_ans = getAns('categor', p); not necessary in example.

        if include_prime
            % Prime recognition.
            txtr_num = getTextureFromHD(p.RECOG_SCREEN, p);
            Screen('DrawTexture',p.w, txtr_num);
            Screen('TextSize', p.w, p.RECOG_FONT_SIZE);
            DrawFormattedText(p.w, double('תיק'), p.SCREEN_WIDTH*2/7, p.SCREEN_HEIGHT*5/16, [0 0 0]);
            DrawFormattedText(p.w, double('ספל'), p.SCREEN_WIDTH*21/32, p.SCREEN_HEIGHT*5/16, [0 0 0]);
            [~,times] = Screen('Flip', p.w, 0, 1);
            Screen('close', txtr_num);
            
            % Waits for key press.
            getInput('instruction',p);
%           prime_ans = getAns('recog', p); not necessary in example.

            % PAS
            times(9) = showTexture(p.PAS_SCREEN, p);
            [pas, pas_time] = getInput('pas', p);
        end
        
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
    
    % Prime recognition.    
    txtr_num = getTextureFromHD(p.RECOG_SCREEN, p);
    Screen('DrawTexture',p.w, txtr_num);
    Screen('TextSize', p.w, p.RECOG_FONT_SIZE);
    DrawFormattedText(p.w, double(left_word), p.SCREEN_WIDTH*2/7, p.SCREEN_HEIGHT*5/16, [0 0 0]);
    DrawFormattedText(p.w, double(right_word), p.SCREEN_WIDTH*21/32, p.SCREEN_HEIGHT*5/16, [0 0 0]);
    [~,times] = Screen('Flip', p.w, 0, 1);
    Screen('close', txtr_num);
end

% Assigns data captured in this trial to 'trials'.
function [trials] = assign_to_trials(trials, times, target_ans, prime_ans, pas, pas_ans_time)
    trials.trial_start_time(1) = times(1);

    % Assigns event times.
    trials.fix_time(1) = times(1);
    trials.mask1_time(1) = times(2);
    trials.mask2_time(1) = times(3);
    trials.prime_time(1) = times(4);
    trials.mask3_time(1) = times(5);
    trials.target_time(1) = times(6);
    trials.categor_time(1) = target_ans.categor_time;
    trials.recog_time(1) = times(8);
    trials.pas_time(1) = times(9);
    
    trials.late_res(1) = target_ans.late_res;
    trials.early_res(1) = target_ans.early_res;
    trials.slow_mvmnt(1) = target_ans.slow_mvmnt;

    % Save responses.
    trials.target_x_to{1} = target_ans.traj_to(:,1);
    trials.target_y_to{1} = target_ans.traj_to(:,2);
    trials.target_z_to{1} = target_ans.traj_to(:,3);
    trials.target_x_from{1} = target_ans.traj_from(:,1);
    trials.target_y_from{1} = target_ans.traj_from(:,2);
    trials.target_z_from{1} = target_ans.traj_from(:,3);
    trials.target_timecourse_to{1} = target_ans.timecourse_to;
    trials.target_timecourse_from{1} = target_ans.timecourse_from;
    trials.target_rt(1) = max(target_ans.timecourse_to) - min(target_ans.timecourse_to);

    trials.prime_ans_left(1) = prime_ans.answer_left;
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
    trials.pas_rt(1) = pas_ans_time - trials.pas_time(1);
    
    trials.trial_end_time(1) = pas_ans_time;
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
    file_name = [p.DATA_FOLDER '\sub' num2str(p.SUB_NUM) p.DAY '_start_end_points.mat'];
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