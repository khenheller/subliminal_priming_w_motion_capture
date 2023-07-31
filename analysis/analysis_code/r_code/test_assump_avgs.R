# Tests linearity assumptions for the models. Marks non-normal variables.
test_assump_avgs <- function(p){
  cat("---------------------------- Assumptions testing ----------------------------\n")
  for(var_name in p$VAR_NAMES){
    df_file <- paste0(p$PROC_DATA_FOLDER,"/",var_name,'_df.rds')
    m_file <- paste0(p$PROC_DATA_FOLDER,"/",var_name,'_m.rds')
    # Load df and model.
    temp_df <- data.frame(readRDS(df_file))
    temp_m <- readRDS(m_file)
    
    # Compute residuals.
    temp_df$res <- resid(temp_m)
    # Plot density plot
    check_model(temp_m, check = c("normality","outliers"))
    # Test normality with Shapiro-Wilk
    print(paste0(var_name,': '), quote=FALSE)
    print(check_normality(temp_m))
    # Test normality with qq-plot of model.
    # par(mfrow=c(1,2))
    # qqnorm(resid(temp_m))
    # qqline(resid(temp_m))
    # Test normality with qqplot of diff.
    plot(ggplot(data = temp_df, mapping = aes(sample = res)) + stat_qq_band() +
      stat_qq_line() + stat_qq_point() + labs(x = "Theoretical Quantiles", y = "Sample Quantiles") + ggtitle(var_name) + theme_classic() + theme(plot.title = element_text(hjust = 0.5)))
    # Verdict of visual inspection.
    is_normal <- ifelse(menu(c("Normal","Not Normal"), title="Res dist normally? ans with 1/2") == 1, 1, 0)
    # Test for outliers.
    print(check_outliers(temp_m, method = "iqr", threshold = list('iqr'=1.5)))
    
    # Save.
    saveRDS(temp_df, file=df_file)
    saveRDS(is_normal, file=paste0(p$PROC_DATA_FOLDER,"/",var_name,"_is_normal.rds"))
  }
  cat("Assumption testing done.\n")
}