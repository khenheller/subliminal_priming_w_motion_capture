% Prints the descriptive statistcs of a time series variable.
% print_title - to print before the results.
% clusters - struct:
%   cluster_size - Sum t-values of each cluster.
%   p_val - of each cluster.
%   cohens_dz - avg cohens dz of each cluster.
%   t_star - (cluster size) / sd(permutation cluster sizes).  ISN'T T-VALUE! CANNOT BE USED AS ONE!!!
% subs_avg - struct with average over all subs, of different variables.
function printTsStats(print_title, clusters)
    stats_table = table(clusters.('start'), clusters.('end'), clusters.size, clusters.p_val, clusters.dz, clusters.t_star,...
        'VariableNames',{'start_time','end_time','cluster_size','p_val','cohens_dz','t*',});
    disp(['----' print_title]);
    disp(stats_table);
end