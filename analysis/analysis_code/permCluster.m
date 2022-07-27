% Receives time series data of each subject in each condition.
% performs permutation and clustering, to locate sections in which the
% conditions differ significantly.
% data1 - data condition 1, rows = samples, columns = subjects.
% data2 - data condition 2.
% n_perm - number of permutations.
% sig_clusters - size of each significant cluster. Computed by sum of t-values in cluster.
% p_values - of each significant cluster.
% sig_cohens_dz - avg cohen's dz of each significant cluster.
% t_star - (cluster size) / sd(permutation cluster sizes). NOT EQUIVALENT TO T-VALUE!!!
function [sig_clusters, p_vals, sig_cohens_dz, t_star] = permCluster(data1, data2, n_perm)
    % Extreme quantile that clusters above it will be significant.
    alpha = 0.05;

    clusters_dist = [];
    for iPerm = 1:n_perm
        % Randomize sign.
        rand_sign = (rand(size(data1)) < 0.5) * 2 - 1;
        perm_data1 = data1 .* rand_sign;
        perm_data2 = data2 .* rand_sign;
        % T-test every sample.
        t_values = getTValues(perm_data1, perm_data2);
        [rand_clusters, ~] = getClusters(t_values);
        clusters_dist = [clusters_dist; rand_clusters];
    end

    % T-test data.
    t_values = getTValues(data1,data2);
    % Cluster data.
    [clusters, clusters_start] = getClusters(t_values);
    % Average Cohen's dz for each cluster.
    cohens_dz = getCohensDz(t_values, size(data1,2), clusters_start);

    % Find 95% quantiles.
    quantiles = quantile(clusters_dist, [alpha, 1-alpha]);

    % Find significant clusters.
    sig_clusters_idx = clusters < quantiles(1) | clusters > quantiles(2);
    sig_clusters = clusters(sig_clusters_idx);
    sig_cohens_dz = cohens_dz(sig_clusters_idx);

    % Compute t* of each significant cluster.
    t_star = sig_clusters / std(clusters_dist);

    % Find p-values.
    p_vals = 1 - invprctile(clusters_dist, sig_clusters)/100;
end

% Receives 2 matrices, each row is a sample, each colum nis a subject.
% Returns t-value for each sample.
function [t_values] = getTValues(data1, data2)
    t_values = NaN(size(data1,1), 1);
    for iSample = 1:size(data1, 1)
        [~, ~, ~, stats] = ttest(data1(iSample,:)', data2(iSample,:)');
        t_values(iSample) = stats.tstat;
    end
end

% Receives a vector that contains clusters, returns clusters size and index.
% A cluster is a set of values that are adjacent and share the same sign.
% Compute and return:
% Cluster size - sum of values in each cluster.
% Cluster idx - index of start of each cluster.
function [clusters, clusters_start] = getClusters(data)
    % Find sign.
    negative = data < 0;
    % Locate transition between clusters.
    change_sign = [0; diff(negative)];
    % Clusters start
    clusters_start = [1; find(change_sign)];
    clusters_end = [find(change_sign)-1; length(data)];
    clusters = NaN(length(clusters_start), 1);
    % Compute each cluster's size (sum contained values).
    for j = 1 : length(clusters)
        clusters(j) = sum(data(clusters_start(j) : clusters_end(j)));
    end
end

% Receives t-values and the start of each cluster.
% Computes average cohen's dz for each cluster.
% t_values - t value foe each timepoint.
% num_subs - sample size (number of subjects).
% clusters_start - index of each cluster's first sample.
function [avg_cohens_dz] = getCohensDz(t_values, num_subs, clusters_start)
    avg_cohens_dz = NaN(size(clusters_start));

    clusters_end = [clusters_start(2 : end)-1; length(t_values)];
    cohens_dz = t_values / sqrt(num_subs);
    for j = 1:length(clusters_start)
        avg_cohens_dz(j) = mean(cohens_dz(clusters_start(j) : clusters_end(j)));
    end
end