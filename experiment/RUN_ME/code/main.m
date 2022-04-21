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
        p = runExperiment(trials, practice_trials, practice_wo_prime_trials, p);
        
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