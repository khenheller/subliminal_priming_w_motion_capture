function [reach_d_prime, keyboard_d_prime] = convertToDPrime(traj_name, p)

    % Intialize empty vars.
    reach_d_prime.direct = NaN(p.MAX_SUB, 1);
    reach_d_prime.indirect = NaN(p.MAX_SUB, 1);
    keyboard_d_prime.direct = NaN(p.MAX_SUB, 1);
    keyboard_d_prime.indirect = NaN(p.MAX_SUB, 1);

    % Bad subs have too few trials, so we don't use them.
    good_subs = load([p.PROC_DATA_FOLDER '/good_subs_' p.DAY '_' traj_name '_subs_' p.SUBS_STRING '.mat']);  good_subs = good_subs.good_subs;

    for iSub = good_subs
        single = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_sorted_trials_' traj_name '.mat']);
        avg = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_sorted_trials_' traj_name '.mat']);
        r_single = single.reach_single;
        k_single = single.keyboard_single;
        r_avg = avg.reach_avg;
        k_avg = avg.keyboard_avg;
        % ---- Reaching d prime ----
        % Arrange features.
        rt       = [r_single.rt.con; r_single.rt.incon];
        react    = [r_single.react.con; r_single.react.incon];
        mt       = [r_single.mt.con; r_single.mt.incon];
        mad      = [r_single.mad.con; r_single.mad.incon];
        com      = [r_single.com.con; r_single.com.incon];
        tot_dist = [r_single.tot_dist.con; r_single.tot_dist.incon];
        auc      = [r_single.auc.con; r_single.auc.incon];
        % Labels for classification.
        labels = [repmat("con", size(r_single.rt.con,1), 1);
            repmat("incon", size(r_single.rt.incon,1), 1)];
        % Featuers table.
        feats_lables_table = table(rt, react, mt, mad, com, tot_dist, auc, labels);
        % Compute d prime.
        reach_d_prime.indirect(iSub) = calcDPrime(feats_lables_table);
        reach_d_prime.direct(iSub) = 2 * norminv((r_avg.fc_prime.con + r_avg.fc_prime.incon) / 2); % Meyen et al. (2022) advancing research...

        % ---- Keyboard d prime ----
        % Arrange features.
        rt       = [k_single.rt.con; k_single.rt.incon];
        % Labels for classification.
        labels = [repmat("con", size(k_single.rt.con,1), 1);
            repmat("incon", size(k_single.rt.incon,1), 1)];
        % Featuers table.
        feats_lables_table = table(rt, labels);
        % Compute d prime.
        keyboard_d_prime.indirect(iSub) = calcDPrime(feats_lables_table);
        keyboard_d_prime.direct(iSub) = 2 * norminv((k_avg.fc_prime.con + k_avg.fc_prime.incon) / 2); % Meyen et al. (2022) advancing research...
    end
end

% Classifies trials as in/congruent with logistic regression classfier.
% feats_lables_table - table variables are classifier features (predictors). Last var is true labels.
function d_prime = calcDPrime(feats_lables_table)
    % Train-test split.
    test_fraction = 0.2;
    spliter = cvpartition(feats_lables_table.labels, 'Holdout', test_fraction);
    train_table = feats_lables_table(spliter.training, :);
    test_table = feats_lables_table(spliter.test, :);

    % Standardize.
    train_table(:, 1:end-1) = normalize(train_table(:, 1:end-1));
    test_table(:, 1:end-1) = normalize(test_table(:, 1:end-1));

    % Train 
    [model, ~, ~] = fitclinear(train_table{:, 1:end-1}, train_table{:, end},...
        'PredictorNames',train_table.Properties.VariableNames(1:end-1),...
        'ResponseName','labels',...
        'Learner','logistic',...
        'Prior','empirical',...
        'OptimizeHyperparameters',{'Lambda', 'Regularization'}, ...
        'HyperparameterOptimizationOptions',struct('ShowPlots',false, 'Verbose',0, 'KFold',2));

    % Predict test set.
    test_preds = predict(model, test_table);

    hits = test_preds=="con" & test_table.labels=="con";
    fas = test_preds=="con" & test_table.labels=="incon";

    n_hits = sum(hits);
    n_fas = sum(fas);
    
    % Num of signal/noise trials.
    n_signal = sum(test_table.labels=="con");
    n_noise = sum(test_table.labels=="incon");
    % Proportion of signal/noise trials.
    portion_signal = n_signal / (n_signal + n_noise);
    portion_noise = 1 - portion_signal;

    % log-linear Correction for hit/fa rate of 1 or 0 (Hautus, 1995):
    % https://stats.stackexchange.com/questions/134779/d-prime-with-100-hit-rate-probability-and-0-false-alarm-probability
    hit_rate = (n_hits + portion_signal) / (n_signal + 2*portion_signal);
    fa_rate = (n_fas + portion_noise) / (n_noise + 2*portion_noise);

    % Calc d prime.
    d_prime = norminv(hit_rate) - norminv(fa_rate);
end