source('model_stats.R')
source('getOutliers.R')
library(multilevel)
library(tidyverse)
library(lme4)
library(R.matlab)
library(caret)
library(dplyr)
# Paths.
p <- list(EXP_FOLDER = getwd())
p$EXP_FOLDER <- getwd()
p$PROC_DATA_FOLDER <- paste0(p$EXP_FOLDER, "/../../processed_data/") # Processed data.

# Define.
p$DAY <- 'day2'
p$SUBS <- c(26,28,29,31,32,33,34,35,37,38) # to analyze.
p$PICKED_TRAJS <- c(1) # traj to analyze (1=to_target, 2=from_target, 3=to_prime, 4=from_prime).
p$NORM_FRAMES <- 200 # Length of normalized trajs.

traj_names <- read.csv(paste0(p$PROC_DATA_FOLDER, '/traj_names.csv'), header=F)
traj_names <- traj_names[p$PICKED_TRAJS,]

# Analyze each traj speratly.
#for (iTraj in 1:nrow(traj_names)){
iTraj = 1
print("@@@@ Make iteration for each traj. @@@@")

##-------------------------- Preprocessing -------------------------------
# ---- Reach Area ----
# Get data.
# Conains many avg trajs, created with bootstrap.
r_a_data <- read.csv(paste0(p$PROC_DATA_FOLDER,'/reach_area_',p$DAY,'_',traj_names[iTraj,1],'.csv'))
r_a_data <- type.convert(r_a_data) # Convert to categor.
r_a_data$sub <- as.factor(r_a_data$sub)
# Standardize
r_a_data <- r_a_data %>% mutate(across(where(is.numeric), scale, .names='{.col}_stn'))
sample_n(r_a_data, 20)
# ------- MAD --------
# Get data.
# Single trials, not avg
mad_data <- read.csv(paste0(p$PROC_DATA_FOLDER,'/mad_',p$DAY,'_',traj_names[iTraj,1],'.csv'))
mad_data <- type.convert(mad_data) # Convert to categor.
mad_data$sub <- as.factor(mad_data$sub)
# Standardize
mad_data <- mad_data %>% mutate(across(where(is.numeric), scale, .names='{.col}_stn'))
sample_n(mad_data, 10)
# --- X Position ----
# Get data.
# Single trials, not avg
xpos_data <- read.csv(paste0(p$PROC_DATA_FOLDER,'/xpos_',p$DAY,'_',traj_names[iTraj,1],'.csv'))
xpos_data <- type.convert(xpos_data) # Convert to categor.
xpos_data$sub <- as.factor(xpos_data$sub)
xpos_data$zindex <- as.factor(xpos_data$zindex)
# Flip left side xpos.
xpos_data$xpos_f <- ifelse(xpos_data$side=="left", xpos_data$xpos*-1, xpos_data$xpos)
# Standardize
xpos_data <- xpos_data %>% mutate(across(where(is.numeric), scale, .names='{.col}_stn'))
sample_n(xpos_data, 10)

##---------------- Descriptive statistics / Data Overview ----------------
# ---- Reach Area ----
# Calc statistics.
r_a_stats <- r_a_data %>%
  group_by(cond) %>% summarize(mean = mean(reach_area), sd = sd(reach_area)) %>% ungroup()
r_a_stats
# Visualize.
r_a_data %>% ggplot(aes(x=reach_area, color=cond, fill=cond)) + geom_histogram(alpha=0.4, position="identity", bins=200) + theme_minimal() + theme(text=element_text(size=15))
r_a_data %>% ggplot(aes(x=cond, y=reach_area, fill=cond)) + geom_violin(alpha=0.4) + geom_boxplot(width=0.15) + theme_minimal() + theme(text=element_text(size=15))
# ------- MAD --------
# Calc statistics.
mad_stats <- mad_data %>%
  group_by(side, cond) %>% summarize(mean = mean(mad), sd = sd(mad)) %>% ungroup()
mad_stats
# Visualize.
mad_data %>% ggplot(aes(x=mad, color=cond, fill=cond)) + geom_histogram(alpha=0.4, position="identity", bins=200) + theme_minimal() + theme(text=element_text(size=15)) + facet_wrap(~side)
mad_data %>% ggplot(aes(x=cond, y=mad, fill=cond)) + geom_violin(alpha=0.4) + geom_boxplot(width=0.15) + theme_minimal() + theme(text=element_text(size=15)) + facet_wrap(~side)
# --- X Position ----
# Calc statistics.
xpos_stats <- xpos_data %>%
  group_by(zindex, side, cond) %>% summarize(mean = mean(xpos), sd = sd(xpos)) %>% ungroup()
xpos_stats
# Visualize.
#xpos_data %>% ggplot(aes(x=zindex, y=xpos, color=cond, fill=cond)) + geom_point() + theme_minimal() + theme(text=element_text(size=15)) + facet_wrap(~side)

##--------------------------- Model Fitting ------------------------------
# ---- Reach Area ----
# Empty model
r_a_empty <- lmer(reach_area_stn ~ 1 + (1|sub), r_a_data)
# Mixed model
r_a_data %>% ggplot(aes(x=sub, y=reach_area)) + geom_boxplot() # Look if sub seems to have rand effect.
r_a_mixed <- lmer(reach_area_stn ~ 1 + cond + (1|sub), r_a_data)
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
#loocv(reach_area ~ 1 + cond + (1|sub), r_a_data, r_a_data$reach_area) @@@@@@@@@@@@@@ Im not sure how to do this for mixed model @@@@@@@@@@@@@@@@@@@@@@@
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

##----------------------- Assumptions testing ----------------------------
# ---- Reach Area ----
# Linearity - no trend should be in residuals plot.
plot(r_a_mixed, which=1)
# Outliers - find with IQR, or in resPlot.
output_list <- getOutliers(r_a_data, 'reach_area')
outliers <- output_list[[1]] 
inliers <- output_list[[2]]
inliers %>% ggplot(aes(x=reach_area, color=cond, fill=cond)) + geom_histogram(alpha=0.4, position="identity", bins=200) + theme_minimal() + theme(text=element_text(size=15))
inliers %>% ggplot(aes(x=cond, y=reach_area, fill=cond)) + geom_violin(alpha=0.4) + geom_boxplot(width=0.15) + theme_minimal() + theme(text=element_text(size=15))
# Heteroscedasticity - resPlot should distribute normaly / equally across y'.
plot(r_a_mixed, which=1)
# Multicolinearity - irelevant, we have 1 predictor.
# Normality - of residuals i nhist, and also no devation from line in qqplot.
hist(resid(r_a_mixed))
qqnorm(resid(r_a_mixed))
qqline(resid(r_a_mixed))
# ------- MAD --------
# Linearity - no trend should be in residuals plot.
plot(mad_mixed, which=1)
# Outliers - find with IQR, or in resPlot.
output_list <- getOutliers(mad_data, 'mad')
outliers <- output_list[[1]] 
inliers <- output_list[[2]]
inliers %>% ggplot(aes(x=mad, color=cond, fill=cond)) + geom_histogram(alpha=0.4, position="identity", bins=200) + theme_minimal() + theme(text=element_text(size=15))
inliers %>% ggplot(aes(x=cond, y=mad, fill=cond)) + geom_violin(alpha=0.4) + geom_boxplot(width=0.15) + theme_minimal() + theme(text=element_text(size=15)) + facet_wrap(~side)
# Heteroscedasticity - resPlot should distribute normaly / equally across y'.
plot(mad_mixed, which=1)
# Multicolinearity - irelevant, we have 1 predictor.
# Normality - of residuals hist, and also no deviation from line in qqplot.
hist(resid(mad_mixed))
qqnorm(resid(mad_mixed))
qqline(resid(mad_mixed))
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




#This explains about mixed effect analysis:
#https://it.unt.edu/sites/default/files/linearmixedmodels_jds_dec2010.pdf

# Residuals plot
#autoplot(sat_by_time, c(1,2), colour=colours, size=2) + ggtitle('Satisfaction by Time worked')



# REmove everything after this @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
install.packages('lmerTest')
library(lmerTest)
# Empty model
r_a_empty <- lmer(reach_area_stn ~ 1 + (1|sub), inliers)
# Mixed model
inliers %>% ggplot(aes(x=sub, y=reach_area)) + geom_boxplot() # Look if sub seems to have rand effect.
r_a_mixed <- lmer(reach_area_stn ~ 1 + cond + (1|sub), inliers)
summary(r_a_mixed)
# ANOVA
anova(r_a_empty, r_a_mixed, test="chi")
