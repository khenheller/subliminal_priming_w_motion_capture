effect_size_avgs <- function(p){
  cat("---------------------------- Effect Size Calc ----------------------------\n")
  for(var_name in p$VAR_NAMES){
    # load.
    temp_df <- data.frame(readRDS(paste0(p$PROC_DATA_FOLDER,'/',var_name,'_df.RDS')))
    # Remove prefix.
    new_var_name <- sub('[r,k]_','',var_name)
    # Select var: standardized or not.
    if(p$STNDRD){
      new_var_name <- paste0(new_var_name,'_stn')
    }
    cat(paste('\n\n------',new_var_name,'------\n'))
    # Cohen's d
    print(cohens_d(get(new_var_name)~cond, data=temp_df, paired=TRUE, ci=NULL))
    # Rank-Biserial - Could use for vars that violate normality, but Mattan recommended to use Cohen's d.
    print(rank_biserial(get(new_var_name)~cond, data=temp_df, paired=TRUE))
  }
  cat("Effect size calc done.\n")
}