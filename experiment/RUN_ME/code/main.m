% Generates a list of trials for a subject and then runs the experiment.
% p - all experiment's parameters.
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
        reach_trials = getTrials('test', p);
        reach_practice_wo_prime_trials = getTrials('practice_wo_prime', p);
        reach_practice_trials = getTrials('practice', p);
        keyboard_trials = getTrials('test', p);
        keyboard_practice_wo_prime_trials = getTrials('practice_wo_prime', p);
        keyboard_practice_trials = getTrials('practice', p);
        
        % Start,end points calibration.
        if ~p.DEBUG
            p = setPoints(p);
        end
        
        % Save code snapshot.
        saveCode(trials.list_id{1}, p);
        % Save 'p' snapshot.
        save([p.DATA_FOLDER 'sub' num2str(p.SUB_NUM) p.DAY '_p.mat'], 'p');
        
        % Choose first session.
        reach_first = randi(2) - 1;

        % Experiment
        showTexture(p.WELCOME_SCREEN, p);
        getInput('instruction', p);
        % 1st instructions.
        showTexture(p.FIRST_INSTRUCTIONS_SCREEN, p);
        getInput('instruction', p);
        switch reach_first
            % Reaching and then keyboard.
            case 1
                p = runExperiment(reach_trials, reach_practice_trials, reach_practice_wo_prime_trials, 1, p);
                showTexture(p.BETWEEN_SESSIONS_SCREEN, p);
                getInput('instruction', p);
                p = runExperiment(keyboard_trials, keyboard_practice_trials, keyboard_practice_wo_prime_trials, 0, p);
            % Keyboard and then reaching.
            case 0
                p = runExperiment(keyboard_trials, keyboard_practice_trials, keyboard_practice_wo_prime_trials, 0, p);
                showTexture(p.BETWEEN_SESSIONS_SCREEN, p);
                getInput('instruction', p);
                p = runExperiment(reach_trials, reach_practice_trials, reach_practice_wo_prime_trials, 1, p);
        end

        showTexture(p.END_SCREEN, p);
        getInput('instruction', p);
        
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