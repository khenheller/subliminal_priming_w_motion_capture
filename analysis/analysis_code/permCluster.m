% Receives time series data of each subject in each condition.
% performs permutation and clustering, to locate sections in which the
% conditions differ significantly.
% data1 - data condition 1, rows = samples, columns = subjects.
% data2 - data condition 2.
% n_perm - number of permutations.
% n_perm_clust_tests - total number of permutation and clustering analysis you have.
%               According to which the multiple comparisons correction will be made.
% clusters - tablewith info about significant clusters:
%   size - size of each significant cluster. Computed by sum of t-values in cluster
%   start/end - sample where each cluster starts and ends.
%   p_val - of each significant cluster.
%   dz - avg cohen's dz of each significant cluster.
%   t_star - (cluster size) / sd(permutation cluster sizes). NOT EQUIVALENT TO T-VALUE!!!
function [clusters] = permCluster(data1, data2, n_perm, n_perm_clust_tests)
    % Extreme quantile abovewhich clusters will be significant.
    alpha = 0.05;
    thresh = tinv(1 - alpha/2, size(data1, 2) - 1);

    clusters_dist = [];
    for iPerm = 1:n_perm
        % Shuffle conditions.
        rand_sign = repmat((rand(1, size(data1, 2)) < 0.5) * 2 - 1, size(data1, 1), 1);
        perm_data1 = data1 .* rand_sign;
        perm_data2 = data2 .* rand_sign;
        % T-test.
        t_values = getTValues(perm_data1, perm_data2);
        % Locate clusters.
        [rand_clusters, ~, ~] = getClusters(t_values, thresh);
        % Build dist from max clusters of noise.
        [~, idx] = max(abs(rand_clusters));
        max_cluster = rand_clusters(idx);
        clusters_dist = [clusters_dist; max_cluster];
    end

    % Transform hist for one sided t-test.
    clusters_dist = abs(clusters_dist);

    % T-test data.
    t_values = getTValues(data1,data2);
    % Cluster data.
    [sizes, starts, ends] = getClusters(t_values, thresh);
    % Find p-values.
    p_vals = [];
    if ~isempty(sizes)
        p_vals = 1 - invprctile(clusters_dist, abs(sizes))/100;
    end
    % Average Cohen's dz for each cluster.
    cohens_dz = getCohensDz(t_values, size(data1,2), starts, ends);
    % Compute t* of each significant cluster.
    t_star = sizes / std(clusters_dist);

    clusters = table(sizes, starts, ends, p_vals, cohens_dz, t_star,...
        'VariableNames',{'size','start','end','p_val','dz','t_star'});

    % Remove non-significant clusters.
    alpha = alpha / n_perm_clust_tests; % Correction for having 'n_perm_clust_tests' clustering analysis (multiple comparisons).
    clusters(clusters.p_val > alpha, :) = [];
end

% Receives 2 matrices, each row is a sample, each colum is a subject.
% Returns t-value for each sample.
function [t_values] = getTValues(data1, data2)
    t_values = NaN(size(data1,1), 1);
    for iSample = 1:size(data1, 1)
        [~, ~, ~, stats] = ttest(data1(iSample,:)', data2(iSample,:)');
        t_values(iSample) = stats.tstat;
    end
end

% Receives a vector that contains t-values, find clusters of ajdacent t-values
% that are above a threshold and share the same sign.
% Compute and return:
% data - t-values.
% thresh - to filter t-values accordingly.
% sizes - size of each significant cluster. Computed by sum of t-values in cluster
% starts/ends - sample where each cluster starts/ends.
function [sizes, starts, ends] = getClusters(data, thresh)
    % Find sign.
    above_thresh = data > thresh;
    below_thresh = data < (thresh * -1);
    % Sum t-values.
    [a_sizes, a_starts, a_ends] = sumTVals(above_thresh, data);
    [b_sizes, b_starts, b_ends] = sumTVals(below_thresh, data);
    sizes = [a_sizes; b_sizes];
    starts = [a_starts; b_starts];
    ends = [a_ends; b_ends];
end

% Receives t-values and which of them cross the threshold.
% Divides to clusters and sums t-values in each cluster.
function [sizes, starts, ends] = sumTVals(cross_thresh, data)
    % Locate transition between clusters.
    trans = diff([0; cross_thresh; 0]);
    % Find clusters start and end.
    starts = find(trans == 1);
    ends = find(trans == -1) - 1;
    % Compute each cluster's size.
    sizes = NaN(size(starts,1), 1);
    for iCluster = 1 : length(starts)
        sizes(iCluster) = sum(data(starts(iCluster) : ends(iCluster)));
    end
end

% Receives t-values and the start of each cluster.
% Computes average cohen's dz for each cluster.
% t_values - t value for each timepoint.
% num_subs - sample size (number of subjects).
% clusters_start - index of each cluster's first sample.
function [avg_cohens_dz] = getCohensDz(t_values, num_subs, starts, ends)
    avg_cohens_dz = NaN(size(starts));
    cohens_dz = t_values / sqrt(num_subs);
    for j = 1:length(starts)
        avg_cohens_dz(j) = mean(cohens_dz(starts(j) : ends(j)));
    end
end