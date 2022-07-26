% Prints the descriptive statistcs of a time series variable.
% print_title - to print before the results.
% cluster_size - Sum t-values of each cluster.
% p_val - of each cluster.
% cohens_dz - avg cohens dz of each cluster.
% t_star - (cluster size) / sd(permutation cluster sizes).  ISN'T T-VALUE! CANNOT BE USED AS ONE!!!
function printTsStats(print_title, cluster_size, p_val, cohens_dz, t_star)
    stats_table = table(cluster_size, p_val, cohens_dz, t_star, 'VariableNames',{'cluster_size','p_val','cohens_dz','t*',});
    disp(['----' print_title]);
    disp(stats_table);
end