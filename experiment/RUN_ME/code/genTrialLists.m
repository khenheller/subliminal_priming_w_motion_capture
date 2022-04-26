% Generates trials lists.
% Checks lists aren't idnetical (at least 50% of trials are different).
% If they are throws an error.
% num_lists: number of lists to generate.
% list_type: 'test' / 'practice'.
function [] = genTrialLists(num_lists, list_type, p)
    p = initConstants(0, list_type, p);

    stim_col = {'prime','target','distractor'}; % column of stimuli words.

    disp('Done generating following lists:');
    % Generate lists.
    for iList = 1:num_lists
        curr_list = newTrials(1, isequal(list_type,'practice'), p);
        
        % Check if identical to previous lists.
        iPrev_list = iList - 1;
        while iPrev_list > 0
            prev_list = readtable([p.TRIALS_FOLDER '/' list_type '_trials' num2str(iPrev_list) p.DAY '.xlsx']);
            equal_trials = strcmp(prev_list{:,stim_col}, curr_list{:,stim_col});
            per_equal_trials = mean(equal_trials,1); % percent identical trials.
            if any(per_equal_trials > 0.5)
                disp(['List ' num2str(iPrev_list) ' and list ' num2str(iList) ' have high percent of idnetical trials:']);
                disp(array2table(per_equal_trials, 'VariableNames',stim_col));
                error('Identical trial lists.');
            end
            iPrev_list = iPrev_list - 1;
        end
        
        % Isn't identical to prev lists, so save it.
        writetable(curr_list, [p.TRIALS_FOLDER '/' list_type '_trials' num2str(iList) p.DAY '.xlsx']);
        disp(iList);
    end
    disp('Done genereating lists');
end