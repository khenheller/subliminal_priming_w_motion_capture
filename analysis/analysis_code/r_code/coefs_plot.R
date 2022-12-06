coefs_plot <- function(p){
  k_all_coefs <- readRDS(paste0(p$PROC_DATA_FOLDER,'coefs_table_k.rds'))
  r_all_coefs <- readRDS(paste0(p$PROC_DATA_FOLDER,'coefs_table_r.rds'))
  all_coefs <- data.frame(r_all_coefs[,], k_all_coefs[,])
  colnames(all_coefs) <- c(paste0("r_",colnames(r_all_coefs)), paste0("k_",colnames(k_all_coefs)))
  # Compute t-test for each variable.
  t_val <- sapply(all_coefs, function(x) t.test(x)$statistic)
  means <- sapply(all_coefs, function(x) t.test(x)$estimate)
  conf_int_l <- sapply(all_coefs, function(x) t.test(x)$conf.int[1])
  conf_int_h <- sapply(all_coefs, function(x) t.test(x)$conf.int[2])
  t_stats = data.frame(t_val,means,conf_int_l,conf_int_h, names=names(conf_int_l))
  # Change to long format.
  all_coefs_long <- pivot_longer(all_coefs, cols=everything(),names_to="var_name", values_to="beta_val")
  # Plot.
  print(ggplot(data=all_coefs_long, aes(x=var_name, y=beta_val)) +
          geom_violin() + geom_jitter() +
          geom_errorbar(data=t_stats, aes(x=names, ymin=conf_int_l, ymax=conf_int_h, y=means), colour="red") +
          geom_point(data=t_stats, aes(x=names, y=means), colour="red") +
          geom_hline(yintercept = 0))
  # Test if coef are larger then 0.
}