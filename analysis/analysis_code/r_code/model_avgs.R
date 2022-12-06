# Models each DP var as a function of condition (con/incon)
# Uses avg of each sub instead of single trials.
model_avgs <- function(p){
  cat("---------------------------- Create models ----------------------------\n")
  for(var_name in p$VAR_NAMES){
    # Load data.
    temp_df <- readRDS(paste0(p$PROC_DATA_FOLDER,"/", var_name, "_df.rds"))
    # Model
    temp_m <- lm(stn ~ 1 + cond, temp_df)
    # Summarize
    cat(paste('------',var_name,'------\n'))
    print(summary(temp_m))
    # Save.
    saveRDS(temp_m, file=paste0(p$PROC_DATA_FOLDER,"/",var_name,"_m.rds"))
  }
  cat("Avgs model creation done.\n")
}