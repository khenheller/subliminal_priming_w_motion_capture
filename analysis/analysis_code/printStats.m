% Prints the descriptive statistcs.
% print_title - to print before the results.
% data_title - title of each data var (e.g., {'con', 'incon'}).
% p_val - of test.
% ci - confidence intervals.
% stats - output of ttest(): tstat, df, sd. 
function printStats(print_title, data1, data2, data_title, p_val, ci, stats)
    cohens_dz = stats.tstat / sqrt(length(data1));
    differ = data1 - data2;
    disp(['----' print_title]);
    disp([data_title{1} ': M=' num2str(mean(data1)) '    STD=' num2str(std(data1))]);
    disp([data_title{2} ': M=' num2str(mean(data2)) '    STD=' num2str(std(data2))]);
    disp(['Avg diff = ' num2str(mean(differ)) '    Relative STD = ' num2str(std(differ) / mean(differ))])
    disp(['t-test = ' num2str(stats.tstat) '    df = ' num2str(stats.df) '     p-value = ' num2str(p_val)]);
    disp(['CI = [' num2str(ci(1)) ', ' num2str(ci(2)) ']     sd = ' num2str(stats.sd)]);
    disp(['cohens d_z = ' num2str(cohens_dz)]);
end