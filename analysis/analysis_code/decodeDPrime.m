% Convert's direct and indirect task results to d' (sensitivity).
% Uses logistic regression classifier for indirect task's results.
% measure - 'reach'/'keyboard'.
% selected - String array, names of features to include in regression.
% save_to_python - save features and labels to be analyzed in python.
% d_prime - d' of in/direct task.
% coef - table with regression classifier coefficients, column=variable.
function [d_prime, coef] = decodeDPrime(iSub, measure, selected, save_to_python, traj_name, p)

    % Num samples used when feature is traj.
    n_samples = 30;
    downsample_i = round(linspace(1,p.NORM_FRAMES, n_samples));

    % Load data and arrange features.
    single = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_sorted_trials_' traj_name '.mat']);
    if isequal(measure, 'reach')
        single = single.reach_single;
        feats = table([single.rt.con; single.rt.incon],...
            [single.react.con; single.react.incon],...
            [single.mt.con; single.mt.incon],...
            [single.mad.con; single.mad.incon],...
            [single.com.con; single.com.incon],...
            [single.tot_dist.con; single.tot_dist.incon],...
            [single.auc.con; single.auc.incon],...
            'VariableNames',{'rt','react','mt','mad','com','tot_dist','auc'});
        traj = [single.trajs.con(downsample_i,:,1)'; single.trajs.incon(downsample_i,:,1)'];
        feats = [feats , array2table(traj)];
    else
        single = single.keyboard_single;
        feats = table([single.rt.con; single.rt.incon], 'VariableNames',{'rt'});
    end

    % Copy traj's variable name to selected variables.
    if ismember("traj", selected(:))
        selected(ismember(selected(:), "traj")) = [];
        selected = [selected, string(feats.Properties.VariableNames(contains([feats.Properties.VariableNames], 'traj')))];
    end

    % Make features and labels for classification.
    feats = feats(:, selected);
    labels = table([repmat("con", size(single.rt.con, 1), 1); repmat("incon", size(single.rt.incon, 1), 1)],...
        'VariableNames',{'labels'});

    % Save to analyze in python.
    if save_to_python
        writetable([feats, labels], [p.PROC_DATA_FOLDER '/' measure(1) '_feats_table_sub' num2str(iSub) '.csv']);
    end

    % Compute d prime.
    [d_prime, coef] = calcDPrime(feats, labels);

    coef = array2table(coef, 'VariableNames',selected);
end

% Classifies trials as in/congruent with classfier.
% feats - table, variables are classifier features (predictors). Rows are trials.
% labels - table with label of each trial.
function [d_prime, coef] = calcDPrime(feats, labels)
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