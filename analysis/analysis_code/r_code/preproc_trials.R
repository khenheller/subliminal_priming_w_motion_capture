# Turn each sub's data to data frame and standardizes it.
# measure - r/k for reach/keyboard.
preproc_trials <- function(measure, p){
  for(iSub in p$GOOD_SUBS){
    df <- read.csv(paste0(p$PROC_DATA_FOLDER,'/format_to_r__sub',iSub,measure,'data.csv'))
    df <- type.convert(df) # Convert strings to categoricals.
    # Standardize
    if(p$STNDRD){
      df <- df %>% mutate(across(where(is.numeric), scale))
    }
    # Save.
    saveRDS(df, file=paste0(p$PROC_DATA_FOLDER,'/sub',iSub,measure,'data.rds'))
  }
  cat(measure, " trials pre proc done.\n")
}