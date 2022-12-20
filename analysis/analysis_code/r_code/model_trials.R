# Models each sub's variables as a func of condition with random effect.
# measure - r/k for reach/keyboard.
model_trials <- function(measure, var_names, p){
  for(iSub in p$GOOD_SUBS){
    # Load data.
    df <- readRDS(paste0(p$PROC_DATA_FOLDER,'/sub',iSub,measure,'data.rds'))
    # Mixed model for each dependent var (with intrcpt or with intrcpt and slope).
    models <- switch(
      p$RAND_EFF,
      "intrcpt" = lapply(select(df, var_names), function(x) lmer(x ~ cond + (1|side), data=df)),
      "intrcpt+slope" = lapply(select(df, var_names), function(x) lmer(x ~ cond + (cond|side), data=df)),
      stop("RAND_EFF var didnt get a valid value"))

    # Can't 'summary' when fixed effect are 0. Remove those cases.
    no_summary = unlist(lapply(models, function(m)  all(fixef(m)==0)))
    # Summarize.
    print(lapply(models[-no_summary], summary))
    # Save.
    saveRDS(models, file=paste0(p$PROC_DATA_FOLDER,'/sub',iSub,measure,'models.rds'))
  }
  cat(measure, " trials model creation done.\n")
}