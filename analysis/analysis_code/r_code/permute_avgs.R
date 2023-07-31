# Permutation testing for vars that violated normality of residuals assumption.
permute_avgs <- function(p){
  cat("---------------------------- Permutation testing ----------------------------\n")
  alpha = 0.05
  for(var_name in p$VAR_NAMES){
    # Verify non-normality.
    is_normal <- readRDS(paste0(p$PROC_DATA_FOLDER,"/",var_name,"_is_normal.rds"))
    if (!is_normal){
      temp_df <- data.frame(readRDS(paste0(p$PROC_DATA_FOLDER,"/",var_name,"_df.rds")))
      # Remove prefix.
      clean_var_name <- sub('[r,k]_','',var_name)
      new_var_name <- clean_var_name
      # Select var: standardized or not.
      if(p$STNDRD){
        new_var_name <- paste0(clean_var_name,'_stn')
      }
      # Permutate
      perm_result = perm.t.test(formula=get(new_var_name)~cond, data=temp_df, paired=TRUE, conf.level=1-alpha)
      # Print results.
      cat(paste('------',new_var_name,'------\n'))
      print(perm_result)
      # Save results.
      writeMat(con=paste0(p$PROC_DATA_FOLDER,'/',clean_var_name,'_p_val_',p$DAY,'_',p$EXP,'.mat'), p_val=perm_result$perm.p.value, ci=perm_result$perm.conf.int)
    }
  }
  cat("Permutation testing done.\n")
}