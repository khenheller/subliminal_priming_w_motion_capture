% Convert's direct and indirect task results to d' (sensitivity).
% Uses logistic regression classifier for indirect task's results.
% measure - 'reach'/'keyboard'.
% selected - String array, names of features to include in regression.
% save_to_python - save features and labels to be analyzed in python.
% d_prime - d' of in/direct task.
% coef - table with regression classifier coefficients, column=variable.
function [d_prime, coef] = decodeDPrime(iSub, measure, selected, save_to_python, traj_name, p)
    traj_len = load([p.PROC_DATA_FOLDER '/trim_len.mat']);  traj_len = traj_len.trim_len;
    % Num samples used when feature is traj.
    n_samples = 30;
    downsample_i = round(linspace(1,traj_len, n_samples));
    assert(n_samples <= traj_len, "Trajectory is too short to downsample, adjust length or downsample rate.")

    % Load data and arrange features.
    trial = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_sorted_trials_' traj_name '.mat']);
    if isequal(measure, 'reach')
        trial = trial.r_trial;
        feats = table([trial.rt.con; trial.rt.incon],...
            [trial.react.con; trial.react.incon],...
            [trial.mt.con; trial.mt.incon],...
            [trial.mad.con; trial.mad.incon],...
            [trial.com.con; trial.com.incon],...
            [trial.tot_dist.con; trial.tot_dist.incon],...
            [trial.auc.con; trial.auc.incon],...
            'VariableNames',{'rt','react','mt','mad','com','tot_dist','auc'});
        traj = [trial.trajs.con(downsample_i,:,1)'; trial.trajs.incon(downsample_i,:,1)'];
        feats = [feats , array2table(traj)];
    else
        trial = trial.k_trial;
        feats = table([trial.rt.con; trial.rt.incon], 'VariableNames',{'rt'});
    end

    % Copy traj's variable name to selected variables.
    if ismember("traj", selected(:))
        selected(ismember(selected(:), "traj")) = [];
        selected = [selected, string(feats.Properties.VariableNames(contains([feats.Properties.VariableNames], 'traj')))];
    end

    % Make features and labels for classification.
    feats = feats(:, selected);
    labels = table([repmat("con", size(trial.rt.con, 1), 1); repmat("incon", size(trial.rt.incon, 1), 1)],...
        'VariableNames',{'labels'});

    % Save to analyze in python.
    if save_to_python
        writetable([feats, labels], [p.PROC_DATA_FOLDER '/' measure(1) '_feats_labels_table_sub' num2str(iSub) '.csv']);
    end

    % Compute d prime.
    [d_prime, coef] = calcDPrime(feats, labels);

    coef = array2table(coef, 'VariableNames',selected);
end

% Classifies trials as in/congruent with classfier.
% feats - table, variables are classifier features (predictors). Rows are trials.
% labels - table with label of each trial.
function [d_prime, coef] = calcDPrime(feats, labels)
    % What classifiation to use: Naive bayesian ('fitcnb'), logistic ('fitclinear').
    alg_type = 'fitcnb';

    % Train-test split.
    test_fraction = 0.2;
%     rng('default');  # Uncomment to have consistent results.
    spliter = cvpartition(labels{:,:}, 'Holdout', test_fraction);
    train_labels = labels(spliter.training, :);
    train_feats = feats(spliter.training, :);
    test_labels = labels(spliter.test, :);
    test_feats = feats(spliter.test, :);

    % Standardize.
    train_avg = mean(train_feats{:,:}, 1);
    train_std = std(train_feats{:,:}, 1);
    train_feats{:,:} = (train_feats{:,:} - train_avg) ./ train_std;
    test_feats{:,:} = (test_feats{:,:} - train_avg) ./ train_std;

    % Train
    if isequal(alg_type, 'fitclinear')
        [model, ~] = fitclinear(train_feats, train_labels,...
            'PredictorNames',train_feats.Properties.VariableNames,...
            'ResponseName','labels',...
            'Learner','logistic',...
            'Regularization','ridge',...
            'Lambda', 0.7,...
            'Prior','uniform',...
            'OptimizeHyperparameters','none',...
            'HyperparameterOptimizationOptions',struct('ShowPlots',false,...
                'Verbose',0,...
                'KFold',10,...
                'AcquisitionFunctionName','expected-improvement-plus'));
        coef = model.Beta';
    elseif isequal(alg_type, 'fitcnb')
        [model] = fitcnb(train_feats, train_labels,...
            'PredictorNames',train_feats.Properties.VariableNames,...
            'ResponseName','labels',...
            'DistributionNames','kernel');
        coef = zeros(1, width(train_feats)); % Unused in this algorithm.
    else
        error(['Unknown algorithm name: ', alg_type]);
    end

    % Predict test set.
    test_preds = predict(model, test_feats);

    hits = test_preds=="con" & test_labels.labels=="con";
    fas = test_preds=="con" & test_labels.labels=="incon";

    n_hits = sum(hits);
    n_fas = sum(fas);
    
    % Num of signal/noise trials.
    n_signal = sum(test_labels.labels=="con");
    n_noise = sum(test_labels.labels=="incon");
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