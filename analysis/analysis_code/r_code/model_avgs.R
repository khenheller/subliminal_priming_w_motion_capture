# Models each DP var as a function of condition (con/incon)
# Uses avg of each sub instead of single trials.
model_avgs <- function(p){
  cat("---------------------------- Create models ----------------------------\n")
  for(var_name in p$VAR_NAMES){
    cat(paste('------',var_name,'------\n'))
    # Load data.
    temp_df <- data.frame(readRDS(paste0(p$PROC_DATA_FOLDER,"/", var_name, "_df.rds")))
    # Remove prefix.
    clean_var_name <- sub('[r,k]_','',var_name)
    # Select var: standardized or not.
    if(p$STNDRD){
      clean_var_name <- paste0(clean_var_name,'_stn')
    }
    # Compute diff between conds.
    diff_df <- temp_df %>% group_by(sub) %>% summarize(differ = .data[[clean_var_name]][cond=='con'] - .data[[clean_var_name]][cond=='incon']) %>% ungroup()
    # Model
    temp_m <- lm(differ ~ 1, diff_df)
    # Summarize
    print(summary(temp_m))
    # Save.
    saveRDS(temp_m, file=paste0(p$PROC_DATA_FOLDER,"/",var_name,"_m.rds"))
  }
  cat("Avgs model creation done.\n")
}