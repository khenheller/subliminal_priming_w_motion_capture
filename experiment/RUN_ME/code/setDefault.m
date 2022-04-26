% Assign 0 to non-cell column (otherwise get matlab error).
% trials - An empty table with headers according to p.CODE_OUTPUT_EXPLANATION.
function trials = setDefault(trials)
    trials.prime_natural = zeros(height(trials),1);
    trials.target_natural = zeros(height(trials),1);
    trials.prime_left = zeros(height(trials),1);
    trials.same = zeros(height(trials),1);
    trials.target_ans_nat = zeros(height(trials),1);
    trials.target_correct = zeros(height(trials),1);
    trials.prime_correct = zeros(height(trials),1);
    trials.late_res = zeros(height(trials),1);
    trials.slow_mvmnt = zeros(height(trials),1);
    trials.early_res = zeros(height(trials),1);
end