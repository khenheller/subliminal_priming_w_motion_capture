# Loads the dataframe of a variable that has a single value for each trial.
# converts strings to categoricals, and sub nums to factors.
# Standardizes numerical values.
# Returns the dataframe after these changes.
# var_name - name of variable to load, as it apears in the data_frame file name.
# measure - 'keyboard'/'reach'.
load_n_standardize_single_val <- function(var_name, measure, traj_names, p){
  # Get dataframe.
  df <- read.csv(paste0(p$PROC_DATA_FOLDER,'/format_to_r_',measure,'__',var_name,'_',p$DAY,'_',traj_names[1,1],'_',p$EXP,'.csv'))
  df <- type.convert(df) # Convert to categorical.
  df$sub <- as.factor(df$sub)
  # Standardize
  df <- df %>% mutate(across(where(is.numeric), scale, .names='{.col}_stn'))
  # Combine left and right
  var_name_stn <- paste(var_name, "_stn", sep = "")
  df <- df %>% group_by(sub, cond) %>% summarise("{var_name_stn}" := mean(get(var_name_stn)), "{var_name}" := mean(get(var_name))) %>% ungroup()
  sample_n(df, 10)
  return(df)
}