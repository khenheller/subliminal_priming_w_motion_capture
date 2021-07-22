% Receives independent variables value for each trial, lvls combinations,
% and num of repetitions for each condition (cond+lvl combination).
% Checks each condition repeats appropriate amount of times.
% reps: num of repetitions for each combination of the vars levels.
%       exmample: Word/non-word , congruent/incongruent
%                       lvl(1)          lvl(2)              reps
%                       'word'          'con'               120
%                       'word'          'incon'             120
%                       'nonword'       'con'               120
%                       'nonword'       'incon'             120
% vars: table, row = var value for each trial, header = var name.
% lvls: table. row = vars combination, header = var name.
function pass_test = conditionTests(vars, lvls, reps)
    pass_test = 1;
    
    % Checks each lvl combo.
    for iCond = 1:size(lvls,1)
        instances = ismember(vars, lvls(iCond,:));
        actual_reps = sum(instances);
        if actual_reps ~= reps(iCond)
            disp(['Repetitions: desired->' num2str(reps(iCond))...
                '  Actual->' num2str(actual_reps) '   for condition:']);
            disp(lvls(iCond,:));
            pass_test = 0;
        end
    end
end