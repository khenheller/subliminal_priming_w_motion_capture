% Gets question type ('categor',recog') and a trial,
% and checks if response was correct.
function [trial] = checkAns(trial, ques_type)
    switch ques_type
        case 'categor'
            trial.target_ans_nat = trial.target_ans_left(:) == trial.natural_left; % sub answered 'natural'
            trial.target_correct = trial.target_ans_nat == trial.target_natural; % target was 'natural'
        case 'recog'
            trial.prime_correct = trial.prime_ans_left(:) == trial.prime_left;
    end
end