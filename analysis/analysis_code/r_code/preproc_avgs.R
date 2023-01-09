# Combines all the subs' avgs to a single dataframe and standardizes it.
preproc_avgs <- function(p){
  cat("---------------------------- Pre Proc ----------------------------\n")
  for(var_name in p$VAR_NAMES){
    # Get dataframe.
    df <- read.csv(paste0(p$PROC_DATA_FOLDER,'/format_to_r__',var_name,'_',p$DAY,'_',p$EXP,'.csv'))
    df <- type.convert(df) # Convert to categorical.
    df$sub <- as.factor(df$sub)
    # Combine left and right
    clean_var_name <- sub('[r,k]_','',var_name) # Remove prefix.
    df <- df %>% group_by(sub, cond) %>% summarise("{clean_var_name}" := mean(get(clean_var_name))) %>% ungroup()
    # Standardize
    if(p$STNDRD){
      df <- df %>% mutate(across(where(is.numeric), scale, .names='stn'))
    }
    
    # Save.
    saveRDS(df, file=paste0(p$PROC_DATA_FOLDER,"/",var_name,"_df.rds"))
  }
  cat("Avgs pre proc done.\n")
}
