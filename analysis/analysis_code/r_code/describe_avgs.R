describe_avgs <- function(p){
  cat("---------------------------- Describe statistics ----------------------------\n")
  for(var_name in p$VAR_NAMES){
    # Load data.
    temp_df <- readRDS(paste0(p$PROC_DATA_FOLDER,"/", var_name, "_df.rds"))
    # Describe.
    describe_stats_single_val(temp_df, sub('[k,r]_','', var_name))
    readline("Press Enter to proceed")
  }
  cat("Stats description done.\n")
}