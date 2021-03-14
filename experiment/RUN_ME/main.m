function [ ] = main(p)
    % Subliminal priming experiment by Liad and Khen.
    % Coded by Khen (khenheller@mail.tau.ac.il)
    % Prof. Liad Mudrik's Lab, Tel-Aviv University
    
    if nargin < 1
        error('Missing subject number!');
    end

    try
        
        % Calibration and connection to natnetclient.
        [p.TOUCH_PLANE_INFO, p.NATNETCLIENT] = touch_plane_setup();
        
        % Initialize params.
        p = initPsychtoolbox(p);
        p = initConstants(1, p);
        
        % Generates trials.
        showTexture(p.LOADING_SCREEN, p);
        trials = getTrials('test', p);
        practice_trials = getTrials('practice', p);

        saveCode(trials.list_id{1}, p);
        
        % Start,end points calibration.
        p = setPoints(p);
        
        % Experiment
        showTexture(p.WELCOME_SCREEN, p);
        getInput('instruction', p);
        experiment(trials, practice_trials, p);
        
        p.NATNETCLIENT.disconnect;
        
    catch e
        safeExit(p);
        rethrow(e);
    end
    safeExit(p);
end

function [] = cleanExit( )
    error('Exit by user!');
end

function [] = experiment(trials, practice_trials, p)
    % instructions.
    showTexture(p.INSTRUCTIONS_SCREEN, p);
    getInput('instruction', p);
    
    % practice.
    showTexture(p.PRACTICE_SCREEN, p);
    getInput('instruction', p);
    p = runTrials(practice_trials, p);
    
    % test.
    showTexture(p.TEST_SCREEN, p);
    getInput('instruction', p);
    p = runTrials(trials, p);
    
    fixOutput(p);
    
    showTexture(p.END_SCREEN, p);
    getInput('instruction', p);
end

function [p] = runTrials(trials, p)

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
%             WaitSecs(p.FIX_DURATION - p.REF_RATE_SEC / 2); % "- p.REF_RATE_SEC / 2" so that it will flip exactly at the end of p.FIX_DURATION.
            WaitSecs(p.FIX_DURATION - p.REF_RATE_SEC * 3 / 4);
            
            % Mask 1
            time(2) = showMask(trials(1,:), 'mask1', p);
%             WaitSecs(p.MASK1_DURATION - p.REF_RATE_SEC / 2);
            WaitSecs(p.MASK1_DURATION - p.REF_RATE_SEC * 3 / 4);
            
            % Mask 2
            time(3) = showMask(trials(1,:), 'mask2', p);
%             WaitSecs(p.MASK2_DURATION - p.REF_RATE_SEC / 2);
            WaitSecs(p.MASK2_DURATION - p.REF_RATE_SEC * 3 / 4);

            % Prime
            time(4) = showWord(trials(1,:), 'prime', p);
%             WaitSecs(p.PRIME_DURATION - p.REF_RATE_SEC / 2);
            WaitSecs(p.PRIME_DURATION - p.REF_RATE_SEC * 3 / 4);

            % Mask 3
            time(5) = showMask(trials(1,:), 'mask3', p);
%             WaitSecs(p.MASK3_DURATION - p.REF_RATE_SEC / 2);
            WaitSecs(p.MASK3_DURATION - p.REF_RATE_SEC * 3 / 4);

            % Target
            Screen('TextFont',p.w, p.FONT_TYPE); % Set target font.
            Screen('TextSize', p.w, p.FONT_SIZE);
            Screen('DrawTexture',p.w, p.CATEGOR_SCREEN); % Shows categor answers with target.
            time(6) = showWord(trials(1,:), 'target', p);
            
            % Target categorization.
            target_ans = getAns('categor', p);
            
            % Prime recognition.
            time(8) = showRecog(trials(1,:), p);
            prime_ans = getAns('recog', p);
            
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

function [] = safeExit(p)
    p.NATNETCLIENT.disconnect;
    Priority(0);
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
    DrawFormattedText(p.w, double(left_word), p.SCREEN_WIDTH*2/7, p.SCREEN_HEIGHT*3/8, [0 0 0]);
    DrawFormattedText(p.w, double(right_word), p.SCREEN_WIDTH*21/32, p.SCREEN_HEIGHT*3/8, [0 0 0]);
    [~,time] = Screen('Flip', p.w, 0, 1);
end

% draws PAS task.
function [time] = showPas(p)
    Screen('DrawTexture',p.w, p.PAS_SCREEN);
    [~,time] = Screen('Flip', p.w, 0, 1);
end

% for practice: loads practice_trials list.
% for test: Randomly selects a trial list from unused_lists.
%           When unused_lists empties, refills it.
%           This makes sure that one list doesn't repeat more than others.
% type: 'practice' / 'test'
function [trials] = getTrials(type, p)
    if isequal(type, 'test')
        unused_lists_path = [p.TRIALS_FOLDER '/unused_lists.mat'];
        unused_lists = [];

        % If file exists, loads it.
        if isfile(unused_lists_path)
            unused_lists = load(unused_lists_path);
            unused_lists = unused_lists.unused_lists;
        end

        % If used all trials, refills.
        if isempty(unused_lists)
            unused_lists = cellstr(ls(p.TRIALS_FOLDER));
            % Remove '.', '..', 'practice.trials.xlsx', 'unused_lists.mat'
            unused_lists(strcmp(unused_lists, '.')) = [];
            unused_lists(strcmp(unused_lists, '..')) = [];
            unused_lists(strcmp(unused_lists, 'practice_trials.xlsx')) = [];
            unused_lists(strcmp(unused_lists, 'unused_lists.mat')) = [];
        end

        % Samples a list randomly.
        [list, list_index] = datasample(unused_lists,1);
        
        unused_lists(list_index) = [];
        save(unused_lists_path, 'unused_lists');
    else
        list = {'practice_trials.xlsx'};
    end
    
    trials = readtable([p.TRIALS_FOLDER '/' list{:}]);
    % List ID.
    trials.list_id = repmat(list, height(trials), 1);
    % Assign subject's number.
    trials.sub_num = ones(height(trials),1) * p.SUB_NUM;
    % In categorization task, "natural" is on the left for odd sub numbers.
    trials.natural_left = ones(height(trials),1) * rem(p.SUB_NUM, 2);
    % convert vars with multiple row in each trial to cells.
    for var = p.MULTI_ROW_VARS
        trials.(var{:}) = num2cell(NaN(height(trials),1));
    end
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