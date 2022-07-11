% Prints that desctiptive statistcs.
% print_title - to print before the results.
% con - congreunt condition data.
% incon - incongreunt condition data.
% p_val - of test.
% ci - confidence intervals.
% stats - output of ttest(): tstat, df, sd. 
function print_stats(print_title, con, incon, p_val, ci, stats)
    cohens_dz = stats.tstat / sqrt(length(con));
    disp(['----' print_title]);
    disp(['Con: M=' num2str(mean(con)) '    STD=' num2str(std(con))]);
    disp(['Incon: M=' num2str(mean(incon)) '    STD=' num2str(std(incon))]);
    disp(['t-test = ' num2str(stats.tstat) '    df = ' num2str(stats.df) '     p-value = ' num2str(p_val)]);
    disp(['CI = [' num2str(ci(1)) ', ' num2str(ci(2)) ']     sd = ' num2str(stats.sd)]);
    disp(['cohens d_z = ' num2str(cohens_dz)]);
end