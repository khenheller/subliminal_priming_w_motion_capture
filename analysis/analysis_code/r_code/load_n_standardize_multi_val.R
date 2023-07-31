# Loads the dataframe of a variable that has multiple values for each trial.
# converts strings to categoricals, and sub nums to factors.
# Standardizes numerical values.
# Returns the dataframe after these changes.
# var_name - name of variable to load, as it apears in the data_frame file name.
# measure - 'keyboard'/'reach'.
load_n_standardize_multi_val <- function(var_name, traj_names, p){
  # Get dataframe.
  df <- read.csv(paste0(p$PROC_DATA_FOLDER,'/format_to_r_reach__',var_name,'_',p$DAY,'_',traj_names[1,1],'_',p$EXP,'.csv'))
  df <- type.convert(df) # Convert to categorical.
  df$sub <- as.factor(df$sub)
  df$z_pos <- as.factor(df$z_pos)
  # Standardize
  df <- df %>% group_by(z_pos) %>% mutate(across(where(is.numeric), scale, .names='{.col}_stn')) %>% ungroup()
  # Combine left and right
  var_name_stn = paste(var_name, "_stn", sep="")
  df <- df %>% group_by(sub,cond) %>% summarise("{var_name_stn}" = mean(get(var_name_stn))) %>% ungroup()
  sample_n(df, 10)
  return(df)
}