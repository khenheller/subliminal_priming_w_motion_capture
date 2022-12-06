# Models each sub's variables as a func of condition with random effect.
# measure - r/k for reach/keyboard.
model_trials <- function(measure, var_names, p){
  for(iSub in p$GOOD_SUBS){
    # Load data.
    df <- readRDS(paste0(p$PROC_DATA_FOLDER,'/sub',iSub,measure,'data.rds'))
    # Mixed model for each dependent var.
    models <- lapply(select(df, var_names), function(x) lmer(x ~ cond + (cond|side), data=df))
    # Summarize.
    print(lapply(models, summary))
    # Save.
    saveRDS(models, file=paste0(p$PROC_DATA_FOLDER,'/sub',iSub,measure,'models.rds'))
  }
  cat(measure, " trials model creation done.\n")
}