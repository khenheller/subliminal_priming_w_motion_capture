main <- function(){
  debugSource('model_stats.R')
  debugSource('getOutliers.R')
  debugSource('load_n_standardize_multi_val.R')
  debugSource('load_n_standardize_single_val.R')
  debugSource('describe_stats_single_val.R')
  debugSource('describe_stats_ra.R')
  debugSource('preproc_avgs.R')
  debugSource('preproc_trials.R')
  debugSource('describe_avgs.R')
  debugSource('model_avgs.R')
  debugSource('model_trials.R')
  debugSource('test_assump_avgs.R')
  debugSource('permute_avgs.R')
  debugSource('effect_size_avgs.R')
  debugSource('coefs_test.R')
  debugSource('coefs_table.R')
  debugSource('coefs_plot.R')
  debugSource('test_assump_coefs.R')
  library(multilevel)
  library(tidyverse)
  library(lme4)
  library(R.matlab)
  library(caret)
  library(dplyr)
  library(ggplot2)
  library(qqplotr)
  library(performance)
  library(MKinfer)
  library(effectsize)
  library(rmatio)
  library(cowplot)
  # Paths.
  p <- list()
  p$EXP_FOLDER <- getwd()
  p$PROC_DATA_FOLDER <- paste0(p$EXP_FOLDER, "/../../processed_data/") # Processed data.
  
  # Experiments subs list.
  p$EXP_1_SUBS <- c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10) # Participated in experiment version 1.
  p$EXP_2_SUBS <- c(11, 12, 13, 14, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25)
  p$EXP_3_SUBS <- c(26, 28, 29, 31, 32, 33, 34, 35, 37, 38, 39, 40, 42)
  p$EXP_4_1_SUBS <- c(47, 49:85, 87:90)
  # trajectory length.
  traj_len = read.mat(paste0(p$PROC_DATA_FOLDER,'/trim_len.mat'))
  traj_len <- traj_len$trim_len
  
  # To be defined BY USER!
  p$DAY <- 'day2'
  p$SUBS <- p$EXP_4_1_SUBS # to analyze.
  p$PICKED_TRAJS <- c(1) # traj to analyze (1=to_target, 2=from_target, 3=to_prime, 4=from_prime).
  p$NORM_FRAMES <- 200 # Length of normalized trajs.
  p$STNDRD <- 0 # Standardize variables before modeling. Relevant when comparing coef between vars.
  p$RAND_EFF <- "intrcpt+slope" # "intrcpt+slope" / "intrcpt".
  # Choose which vars to analyze ("rt","react","mt","mad","tot_dist","auc","ra","com","max_vel",paste0("x",1:traj_len),paste0("iep",1:traj_len))
  # Add "r_ra" to p$VAR_NAMES (but not p$R_VAR_NAMES, since ra is relevant only for avgs analysis) to analyze reach area.
  p$R_VAR_NAMES <- c(paste0("iep",1:traj_len))
  p$K_VAR_NAMES <- c("rt")
  p$VAR_NAMES <- c(paste0("r_",p$R_VAR_NAMES), "r_ra", paste0("k_",p$K_VAR_NAMES)) # Used to save files. r/k=reach/keyboard. default: "r_react","r_mt",""r_mad",r_tot_dist","r_auc","r_com",,"k_rt"
  
  # Parameters setup
  p$SUBS_STRING <- paste(p$SUBS, collapse="_") # Concatenate sub's numbers with '_' between them.
  p$MAX_SUB <- max(p$SUBS)
  traj_names <- read.csv(paste0(p$PROC_DATA_FOLDER, '/traj_names.csv'), header=F)
  traj_names <- traj_names[p$PICKED_TRAJS,]
  
  # Check which experiment.
  if (setequal(p$SUBS, p$EXP_1_SUBS)){
    p$EXP = "exp1"
  } else if (setequal(p$SUBS, p$EXP_2_SUBS)){
    p$EXP = "exp2"
  } else if (setequal(p$SUBS, p$EXP_3_SUBS)){
    p$EXP = "exp3"
  } else if (setequal(p$SUBS, p$EXP_4_1_SUBS)){
    p$EXP = "exp4_1"
  } else {
    stop("Please analyze each exp seperatly.")
  }
  
  # Subs to analyze.
  p$GOOD_SUBS <- unlist(read.mat(paste0(p$PROC_DATA_FOLDER,'/format_to_r__good_subs.mat')))
  
  cat("Params Defined.\n")
  ##---- Preprocessing -----------------------------------
  # preproc_avgs(p)
  preproc_trials('r', p)
  preproc_trials('k', p)
  ##---- Descriptive statistics / Data Overview ----------
  # describe_avgs(p)
  ##---- Modeling ----------------------------------------
  # model_avgs(p)
  model_trials('r',p$R_VAR_NAMES, p)
  model_trials('k',p$K_VAR_NAMES, p)
  coefs_table('r', p$R_VAR_NAMES, p)
  coefs_table('k', p$K_VAR_NAMES, p)
  ##---- Assumptions testing -----------------------------
  # test_assump_avgs(p)
  test_assump_coefs('r', p$R_VAR_NAMES, p)
  test_assump_coefs('k', p$K_VAR_NAMES, p)
  ##---- Permutation T-testing ---------------------------
  # For variables that violated normality.
  # permute_avgs(p)
  ##---- Effect Size Calc --------------------------------
  # effect_size_avgs(p)
  ##---- Coefficients significance test ------------------
  coefs_test('k',p$K_VAR_NAMES,p)
  coefs_test('r',p$R_VAR_NAMES,p)
  coefs_plot(p)
  
  #########################################
  #########################################
  #########################################
  #########################################
  #########################################
  #########################################
  #########################################
  # Everything below is old ###############
  #########################################
  #########################################
  #########################################
  #########################################
  #########################################
  #########################################
  stop("Script Done!!!")
  # ---- Reach Area ----
  # Linearity - no trend should be in residuals plot.
  plot(auc_m, which=1)
  # Outliers - find with IQR, or in resPlot.
  output_list <- getOutliers(auc_df, 'auc')
  outliers <- output_list[[1]] 
  inliers <- output_list[[2]]
  inliers %>% ggplot(aes(x=auc, color=cond, fill=cond)) + geom_histogram(alpha=0.4, position="identity", bins=200) + theme_minimal() + theme(text=element_text(size=15))
  inliers %>% ggplot(aes(x=cond, y=auc, fill=cond)) + geom_violin(alpha=0.4) + geom_boxplot(width=0.15) + theme_minimal() + theme(text=element_text(size=15))
  # Heteroscedasticity - resPlot should distribute normaly / equally across y'.
  plot(auc_m, which=1)
  # Multicolinearity - irelevant, we have 1 predictor.
  # Normality - of residuals in hist, and also no devation from line in qqplot.
  hist(resid(auc_m))
  qqnorm(resid(auc_m))
  qqline(resid(auc_m))
  # --- X Position ----
  look_range <- c(round(runif(10)*p$NORM_FRAMES)) # Models whose assumptions will be tested.
  # Linearity - no trend should be in residuals plot.
  # Heteroscedasticity - resPlot should distribute normaly / equally across y'.
  models <- xpos_mixed$model[look_range]
  par(mfrow=c(2, length(look_range)/2))
  par(mar=c(4,4,2,0.5))
  for(j in 1:length(look_range)){
    plot(predict(models[[j]]), residuals(models[[j]]), main=look_range[j], xlab='pred', ylab='resid')
  }
  # Outliers - find with IQR, or in resPlot.
  for(j in 1:p$NORM_FRAMES){
    filt_data <- filter(xpos_data, zindex==j)
    output_list <- getOutliers(filt_data, 'xpos')
    outliers <- output_list[[1]] 
    inliers <- output_list[[2]]
    #inliers %>% ggplot(aes(x=xpos, color=cond, fill=cond)) + geom_histogram(alpha=0.4, position="identity", bins=200) + theme_minimal() + theme(text=element_text(size=15))
  }
  # Multicolinearity - irelevant, we have 1 predictor.
  # Normality - of residuals in hist, and also no devation from line in qqplot.
  par(mfrow=c(2, length(look_range)/2))
  par(mar=c(4,4,2,0.5))
  for(j in 1:length(look_range)){
    hist(resid(models[[j]]), main=look_range[j], xlab='resid', ylab='cnt')
  }
  for(j in 1:length(look_range)){
    qqnorm(resid(models[[j]]), main=look_range[j])#, xlab='resid', ylab='cnt')
    qqline(resid(models[[j]]))
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  ##--------------------------- Model Fitting ------------------------------
  # ---- Reach Area ----
  # Empty model
  r_a_empty <- lmer(reach_area_stn ~ 1 + (1|sub), ra_data)
  # Mixed model
  ra_data %>% ggplot(aes(x=sub, y=reach_area)) + geom_boxplot() # Look if sub seems to have rand effect.
  r_a_mixed <- lmer(reach_area_stn ~ 1 + cond + (1|sub), ra_data)
  summary(r_a_mixed)
  # ------- MAD --------
  # Empty model
  mad_empty <- lmer(mad_stn ~ 1 + (1|sub), mad_data)
  # Mixed model
  mad_data %>% ggplot(aes(x=sub, y=mad)) + geom_boxplot() # Sub seems to have rand effect.
  mad_data %>% ggplot(aes(x=side, y=mad)) + geom_boxplot() # Side doesn't seem to have rand effect.
  mad_mixed <- lmer(mad_stn ~ 1 + cond + (1|sub), mad_data)
  summary(mad_mixed)
  # --- X Position ----
  # 1 model for each zindex, for each side (left/right) = 200 zindex * 2 sides
  # Empty model
  empty_formula <- xpos_stn ~ 1 + (1|sub)
  xpos_empty <- xpos_data %>% group_by(side) %>% group_by(zindex, .add=T) %>%
    do(model=lmer(., formula=empty_formula))
  #xpos_empty2 <- by(xpos_data, xpos_data$zindex, lmer, formula=empty_formula)
  # Mixed model
  look_range <- c(100:110)
  xpos_data %>% filter(zindex %in% look_range) %>% ggplot(aes(x=sub, y=xpos_f)) + geom_boxplot() + facet_wrap("zindex") # Sub seems to have rand effect.
  xpos_data %>% filter(zindex %in% look_range) %>% ggplot(aes(x=side, y=xpos_f)) + geom_boxplot() + facet_wrap("zindex") # Side seems to have rand effect.
  mix_formula <- xpos_stn ~ 1 + cond + (1|sub)
  xpos_mixed <- xpos_data %>% group_by(side) %>% group_by(zindex, .add=T) %>%
    do(model=lmer(.,formula=mix_formula))
  
  ##------------------------- Model comparison -----------------------------
  # ---- Reach Area ----
  # ANOVA
  anova(r_a_empty, r_a_mixed)
  # LOOCV
  #loocv(reach_area ~ 1 + cond + (1|sub), ra_data, ra_data$reach_area) @@@@@@@@@@@@@@ Im not sure how to do this for mixed model @@@@@@@@@@@@@@@@@@@@@@@
  # ------- MAD --------
  anova(mad_empty, mad_mixed, test="chi")
  # --- X Position ----
  n_models <- nrow(xpos_mixed)
  empty_array <- numeric(length=n_models)
  pvals <- data.frame(side = factor(x = empty_array, levels=levels(xpos_mixed$side)),
                      zindex = factor(x = empty_array, levels=levels(xpos_mixed$zindex)),
                      val = empty_array)
  # Calc p-val for each model.
  for (j in 1:n_models){
    temp <- anova(xpos_empty$model[[j]], xpos_mixed$model[[j]])
    pvals$val[j] <- temp$`Pr(>Chisq)`[2]
    pvals$zindex[j] <- xpos_mixed$zindex[j]
    pvals$side[j] <- xpos_mixed$side[j]
  }
  
  # Plot p-val
  pvals %>% ggplot(aes(x=zindex, y=val, group=1)) + labs(title="significance of coef for: X-pos by cond", subtitle="Not FDR corrected", y="p-val") +
    geom_line(color="blue") + facet_wrap("side") + scale_x_discrete(breaks=seq(0,max(as.numeric(pvals$zindex)),50)) +
    scale_y_continuous(breaks=c(0.05, 0.25, 0.5, 0.75, 1)) + geom_hline(yintercept=0.05) + theme_bw()
}
