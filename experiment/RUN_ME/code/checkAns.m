% Gets question type ('categor',recog') and a trial,
% and checks if response was correct.
% trial - includes timing and stimuli of a single trial in a table form.
% ques_type - 'categor' / 'recog'
function [trial] = checkAns(trial, ques_type)
    switch ques_type
        case 'categor'
            trial.target_ans_nat = trial.target_ans_left == trial.natural_left; % sub answered 'natural'
            trial.target_correct = trial.target_ans_nat == trial.target_natural; % target was 'natural'
            
            % No response given, mark as NaN.
            if isnan(trial.target_ans_left)
                trial.target_ans_nat = NaN;
                trial.target_correct = NaN;
            end
            
        case 'recog'
            trial.prime_correct = trial.prime_ans_left == trial.prime_left;
            
            % No response given, mark as NaN.
            if isnan(trial.prime_ans_left)
                trial.prime_correct = NaN;
            end
    end
end