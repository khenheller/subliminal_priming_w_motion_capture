# Loads the dataframe of a variable that has a single value for each trial.
# converts strings to categoricals, and sub nums to factors.
# Standardizes numerical values.
# Returns the dataframe after these changes.
# var_name - name of variable to load, as it apears in the data_frame file name.
# measure - 'keyboard'/'reach'.
load_n_standardize_single_val <- function(var_name, measure, p){
  # Get dataframe.
  print(paste0(p$PROC_DATA_FOLDER,'/format_to_r__',var_name,'_',p$DAY,'_',p$EXP,'.csv'))
  df <- read.csv(paste0(p$PROC_DATA_FOLDER,'/format_to_r__',var_name,'_',p$DAY,'_',p$EXP,'.csv'))
  df <- type.convert(df) # Convert to categorical.
  df$sub <- as.factor(df$sub)
  # Combine left and right
  clean_var_name <- sub('[r,k]_','',var_name) # Remove prefix.
  df <- df %>% group_by(sub, cond) %>% summarise("{clean_var_name}" := mean(get(clean_var_name))) %>% ungroup()
  # Standardize
  if(p$STANDARDIZE){
    df <- df %>% mutate(across(where(is.numeric), scale, .names='stn'))
  }
  return(df)
}