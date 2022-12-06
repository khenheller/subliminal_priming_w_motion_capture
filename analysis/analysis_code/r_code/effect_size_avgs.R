effect_size_avgs <- function(p){
  cat("---------------------------- Effect Size Calc ----------------------------\n")
  for(var_name in p$VAR_NAMES){
    # load.
    temp_df <- readRDS(paste0(p$PROC_DATA_FOLDER,'/',var_name,'_df.RDS'))
    cat(paste('\n\n------',var_name,'------\n'))
    # Cohen's d
    print(cohens_d(get(sub('[r,k]_','',var_name))~cond, data=temp_df, paired=TRUE, ci=NULL))
    # Rank-Biserial - Could use for vars that violate normality, but Mattan recommended to use Cohen's d.
    print(rank_biserial(get(sub('[r,k]_','',var_name))~cond, data=temp_df, paired=TRUE))
  }
  cat("Effect size calc done.\n")
}