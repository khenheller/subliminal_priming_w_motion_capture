# Creates a table with all subs' coefficients.
# measure - r/k for reach/keyboard.
# var_names - names of all variables of one measure.
coefs_table <- function(measure, var_names, p){
  # Coefs, col=var, row=sub.
  all_coefs <- data.frame(matrix(NA, p$MAX_SUB, length(var_names)))
  colnames(all_coefs) <- var_names
  # Extract coef for each sub.
  for(iSub in p$GOOD_SUBS){
    models <- readRDS(paste0(p$PROC_DATA_FOLDER,'/sub',iSub,measure,'models.rds'))
    all_coefs[iSub, ] <- sapply(models, function(x) fixef(x)[2])
  }
  # Remove empty values.
  all_coefs <- na.omit(all_coefs)
  # Save.
  saveRDS(all_coefs, file=paste0(p$PROC_DATA_FOLDER,'coefs_table_',measure,'.rds'))
}
