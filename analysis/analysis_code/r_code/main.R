source('model_stats.R')
source('getOutliers.R')
source('load_n_standardize_multi_val.R')
source('load_n_standardize_single_val.R')
source('describe_stats_single_val.R')
source('describe_stats_ra.R')
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
# Paths.
p <- list()
p$EXP_FOLDER <- getwd()
p$PROC_DATA_FOLDER <- paste0(p$EXP_FOLDER, "/../../processed_data/") # Processed data.

# Define.
p$EXP_1_SUBS <- c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10) # Participated in experiment version 1.
p$EXP_2_SUBS <- c(11, 12, 13, 14, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25)
p$EXP_3_SUBS <- c(26, 28, 29, 31, 32, 33, 34, 35, 37, 38, 39, 40, 42)
p$EXP_4_1_SUBS <- c(47, 49:85, 87:90)
p$DAY <- 'day2'
p$SUBS <- p$EXP_4_1_SUBS # to analyze.
p$SUBS_STRING <- paste(p$SUBS, collapse="_") # Concatenate sub's numbers with '_' between them.
p$PICKED_TRAJS <- c(1) # traj to analyze (1=to_target, 2=from_target, 3=to_prime, 4=from_prime).
p$NORM_FRAMES <- 200 # Length of normalized trajs.

traj_names <- read.csv(paste0(p$PROC_DATA_FOLDER, '/traj_names.csv'), header=F)
traj_names <- traj_names[p$PICKED_TRAJS,]

iTraj = 1

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
##-------------------------- Preprocessing -------------------------------
# ---- Single value per trial ----
tot_dist_df <- load_n_standardize_single_val('tot_dist', 'reach', traj_names, p)
auc_df <- load_n_standardize_single_val('auc', 'reach', traj_names, p)
com_df <- load_n_standardize_single_val('com', 'reach', traj_names, p)
react_df <- load_n_standardize_single_val('react', 'reach', traj_names, p)
mt_df <- load_n_standardize_single_val('mt', 'reach', traj_names, p)
ra_df <- load_n_standardize_single_val('ra', 'reach', traj_names, p)
# ---- Multiple values per trial ----
head_angle_df = load_n_standardize_multi_val('head_angle', traj_names, p)
x_df = load_n_standardize_multi_val('x', traj_names, p)
x_std_df = load_n_standardize_multi_val('x_std', traj_names, p)
# ---- Keyboard ----
rt_df <- load_n_standardize_single_val('rt', 'keyboard', traj_names, p)
# Convert taveled dist to cm.
tot_dist_df$tot_dist <- tot_dist_df$tot_dist * 100
##---------------- Descriptive statistics / Data Overview ----------------
# ---- Single value per trial ----
describe_stats_single_val(tot_dist_df, 'tot_dist')
describe_stats_single_val(auc_df, 'auc')
describe_stats_single_val(com_df, 'com')
describe_stats_single_val(react_df, 'react')
describe_stats_single_val(mt_df, 'mt')
describe_stats_ra(ra_df)
# ---- Keyboard ----
describe_stats_single_val(rt_df, 'rt')
##----------------------- Modeling ----------------------------
# ---- Single value per trial ----
tot_dist_m <- lm(tot_dist_stn ~ 1 + cond, tot_dist_df)
auc_m <- lm(auc_stn ~ 1 + cond, auc_df)
com_m <- lm(com_stn ~ 1 + cond, com_df)
react_m <- lm(react_stn ~ 1 + cond, react_df)
mt_m <- lm(mt_stn ~ 1 + cond, mt_df)
ra_m <- lm(ra_stn ~ 1 + cond, ra_df)
summary(tot_dist_m)
summary(auc_m)
summary(com_m)
summary(react_m)
summary(mt_m)
summary(ra_m)
# ---- Keyboard ----
rt_m <- lm(rt_stn ~ 1 + cond, rt_df)
summary(rt_m)
##----------------------- Assumptions testing ----------------------------
# ---- Single value per trial ----
check_model(tot_dist_m, check = c("normality","outliers"))
check_model(auc_m, check = c("normality","outliers"))
check_model(com_m, check = c("normality","outliers"))
check_model(react_m, check = c("normality","outliers"))
check_model(mt_m, check = c("normality","outliers"))
check_model(ra_m, check = c("normality","outliers"))
check_outliers(tot_dist_m, method = "iqr", threshold = list('iqr'=1.5))
check_outliers(auc_m, method = "iqr", threshold = list('iqr'=1.5))
check_outliers(com_m, method = "iqr", threshold = list('iqr'=1.5))
check_outliers(react_m, method = "iqr", threshold = list('iqr'=1.5))
check_outliers(mt_m, method = "iqr", threshold = list('iqr'=1.5))
check_outliers(ra_m, method = "iqr", threshold = list('iqr'=1.5))
# ---- Keyboard ----
check_model(rt_m, check = c("normality","outliers"))
check_outliers(rt_m, method = "iqr", threshold = list('iqr'=1.5))
##----------------------- Permutation T-testing ----------------------------
# For variables that violated normality.
alpha = 0.05
tot_dist_perm_result = perm.t.test(formula=tot_dist~cond, data=tot_dist_df, paired=TRUE, conf.level=1-alpha)
auc_perm_result = perm.t.test(formula=auc~cond, data=auc_df, paired=TRUE, conf.level=1-alpha)
com_perm_result = perm.t.test(formula=com~cond, data=com_df, paired=TRUE, conf.level=1-alpha)
react_perm_result = perm.t.test(formula=react~cond, data=react_df, paired=TRUE, conf.level=1-alpha)
mt_perm_result = perm.t.test(formula=mt~cond, data=mt_df, paired=TRUE, conf.level=1-alpha)
ra_perm_result = perm.t.test(formula=ra~cond, data=ra_df, paired=TRUE, conf.level=1-alpha)
rt_perm_result = perm.t.test(formula=rt~cond, data=rt_df, paired=TRUE, conf.level=1-alpha)
# Print results.
tot_dist_perm_result
auc_perm_result
com_perm_result
react_perm_result
mt_perm_result
ra_perm_result
rt_perm_result
# Save results.
# !!!!!!!!!!!!!!!!!!!!!RUN ONLY FOR VARS THAT VIOLATE NORMALITY !!!!!!!!!!!!!!!!!!!!!!!!!
writeMat(con=paste0(p$PROC_DATA_FOLDER, '/tot_dist_p_val_', p$DAY, '_', p$EXP, '.mat'), p_val=tot_dist_perm_result$perm.p.value, ci=tot_dist_perm_result$perm.conf.int)
writeMat(con=paste0(p$PROC_DATA_FOLDER, '/auc_p_val_', p$DAY, '_', p$EXP, '.mat'), p_val=auc_perm_result$perm.p.value, ci=auc_perm_result$perm.conf.int)
writeMat(con=paste0(p$PROC_DATA_FOLDER, '/com_p_val_', p$DAY, '_', p$EXP, '.mat'), p_val=com_perm_result$perm.p.value, ci=com_perm_result$perm.conf.int)
writeMat(con=paste0(p$PROC_DATA_FOLDER, '/react_p_val_', p$DAY, '_', p$EXP, '.mat'), p_val=react_perm_result$perm.p.value, ci=react_perm_result$perm.conf.int)
writeMat(con=paste0(p$PROC_DATA_FOLDER, '/mt_p_val_', p$DAY, '_', p$EXP, '.mat'), p_val=mt_perm_result$perm.p.value, ci=mt_perm_result$perm.conf.int)
writeMat(con=paste0(p$PROC_DATA_FOLDER, '/ra_p_val_', p$DAY, '_', p$EXP, '.mat'), p_val=ra_perm_result$perm.p.value, ci=ra_perm_result$perm.conf.int)
writeMat(con=paste0(p$PROC_DATA_FOLDER, '/rt_p_val_', p$DAY, '_', p$EXP, '.mat'), p_val=rt_perm_result$perm.p.value, ci=rt_perm_result$perm.conf.int)
##----------------------- Effect Size Calc ----------------------------
# Used for vars that violate normality.
rank_biserial(tot_dist~cond, data=tot_dist_df, paired=TRUE)
rank_biserial(auc~cond, data=auc_df, paired=TRUE)
rank_biserial(com~cond, data=com_df, paired=TRUE)
rank_biserial(react~cond, data=react_df, paired=TRUE)
rank_biserial(mt~cond, data=mt_df, paired=TRUE)
rank_biserial(ra~cond, data=ra_df, paired=TRUE)
# ---- Keyboard ----
rank_biserial(rt~cond, data=rt_df, paired=TRUE)
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