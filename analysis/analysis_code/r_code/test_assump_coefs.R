# Tests linearity assumptions for the models. Marks non-normal variables.
test_assump_coefs <- function(measure, var_names, p){
  cat("---------------------------- Coefs assumptions testing ----------------------------\n")
  coefs_table <- readRDS(paste0(p$PROC_DATA_FOLDER,'coefs_table_',measure,'.rds'))
  for(var_name in var_names){
    # Test normality with qqplot of diff.
    plot(ggplot(data = coefs_table, mapping = aes(sample=.data[[var_name]])) + stat_qq_band() + 
           stat_qq_line() + stat_qq_point() + labs(x = "Theoretical Quantiles", y = "Sample Quantiles") + ggtitle(var_name) + theme_classic() + theme(plot.title = element_text(hjust = 0.5)))
    # Verdict of visual inspection.
    is_normal <- ifelse(menu(c("Normal","Not Normal"), title="Res dist normally? ans with 1/2") == 1, 1, 0)
    # Save.
    saveRDS(is_normal, file=paste0(p$PROC_DATA_FOLDER,"/",var_name,"_coefs_are_normal.rds"))
  }
  cat("Coefs assumption testing done.\n")
}