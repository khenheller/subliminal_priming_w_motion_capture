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
  
  # If plotting a timeseries.
  if(any(grepl("iep[1-9]", colnames(all_coefs)) | grepl("x[1-9]", colnames(all_coefs)))){
    # Plot reach timeseries coef.
    r_t_stats <- t_stats[grepl("^r", t_stats$names), ]
    p1 <- ggplot(data=r_t_stats, aes(x=as.double(sub('\\D+_\\D+','', names)), y=means, group=1)) +
      geom_line(size=2, colour="green") + geom_ribbon(aes(ymin=conf_int_l, ymax=conf_int_h), alpha=0.2) +
      geom_hline(yintercept = 0, linetype="dashed") +
      ggtitle(sub('\\d+','', r_t_stats$names[1])) +
      xlab("Sample num") + ylab("Coef (beta)") +
      theme_minimal() + theme(axis.title=element_text(size=14),
                              axis.text=element_text(size=12),
                              plot.title=element_text(size=18))
    # Plot keyboard coefs.
    k_all_coefs_long <- all_coefs_long[grepl("^k", all_coefs_long$var_name), ]
    k_t_stats <- t_stats[grepl("^k", t_stats$names), ]
    p2 <- ggplot(data=k_all_coefs_long, aes(x=var_name, y=beta_val)) +
      geom_violin() + geom_jitter() +
      geom_errorbar(data=k_t_stats, aes(x=names, ymin=conf_int_l, ymax=conf_int_h, y=means), colour="red") +
      geom_point(data=k_t_stats, aes(x=names, y=means), colour="red") +
      geom_hline(yintercept = 0, linetype="dashed") +
      ggtitle(sub('\\d+','', k_all_coefs_long$var_name[1])) +
      xlab("") + ylab("Coef (beta)") +
      theme_minimal() + theme(axis.title=element_text(size=14),
                              axis.text=element_text(size=12),
                              plot.title=element_text(size=18))
    print(plot_grid(p1, p2, labels=c('A','B')))
  
  } else{
    print(ggplot(data=all_coefs_long, aes(x=var_name, y=beta_val)) +
            geom_violin() + geom_jitter() +
            geom_errorbar(data=t_stats, aes(x=names, ymin=conf_int_l, ymax=conf_int_h, y=means), colour="red") +
            geom_point(data=t_stats, aes(x=names, y=means), colour="red") +
            geom_hline(yintercept = 0)) + theme_minimal()
  }
}