# Check if across subs coefficients are significant.
# measure - r/k for reach/keyboard.
# var_names - names of all variables of one measure.
coefs_test <- function(measure, var_names, p){
  cat("---------------------------- ",measure," Coefs t-tests ----------------------------")
  all_coefs <- readRDS(file=paste0(p$PROC_DATA_FOLDER,'coefs_table_',measure,'.rds'))
  for(var_name in var_names){
    # Test normality.
    is_normal <- readRDS(file=paste0(p$PROC_DATA_FOLDER,"/",var_name,"_coefs_are_normal.rds"))
    if (!is_normal){
      
      # Use permutation if assump violated.
      test_res <- perm.t.test(x=all_coefs[[var_name]], alternative="two.sided")
      effect <- paste("Rank b-Serial: ", round(rank_biserial(all_coefs[[var_name]], ci=NULL), 2))
      
    } else {
      # T-test.
      test_res <- t.test(x=all_coefs[[var_name]], alternative="two.sided")
      effect <- paste("Cohen's d: ", round(cohens_d(all_coefs[[var_name]], ci=NULL), 2))
    }
    
    cat("\n----",var_name,"----\n",
        "Rand eff: ",p$RAND_EFF,
        "\nmean: ",round(test_res$estimate,2),"  SD Err: ",round(test_res$stderr,2),
        "\nt-value: ",round(test_res$statistic,2),"  p-val: ",round(test_res$p.value,3),
        "\nCI: ",round(test_res$conf.int,2), effect)
  }
  cat("\nCoefs t tests done.\n")
}
