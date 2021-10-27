library(tidyverse)
library(lme4)
library(R.matlab)
# Paths.
p <- list(EXP_FOLDER = getwd())
p$EXP_FOLDER <- getwd()
p$PROC_DATA_FOLDER <- paste0(p$EXP_FOLDER, "/../../processed_data/") # Processed data.

# Define.
p$DAY <- 'day2'
p$SUBS <- c(26,28,29,31,32,33,34,35,37,38) # to analyze.
p$PICKED_TRAJS <- c(1) # traj to analyze (1=to_target, 2=from_target, 3=to_prime, 4=from_prime).

traj_names <- read.csv(paste0(p$PROC_DATA_FOLDER, '/traj_names.csv'), header=F)
traj_names <- traj_names[p$PICKED_TRAJS,]
##---------------- LMM ----------------
for (iTraj in 1:nrow(traj_names)){
  # ---- Reach Area ----
  reach_area <- read.csv(paste0(p$PROC_DATA_FOLDER,'/reach_area_',p$DAY,'_',traj_names[iTraj,1],'.csv'))
  
  # ---- MAD ----
  mad <- read.csv(paste0(p$PROC_DATA_FOLDER,'/mad_',p$DAY,'_',traj_names[iTraj,1],'.csv'))
  # Plot data
  mad %>% ggplot(aes(x=side,y=mad, color=cond)) + geom_point()
  mad_lmm <- lmer(mad ~ 1 + cond + side + (1|sub), data=mad)
  summary(mad_lmm)
  
  # ---- Traj ----
}
  
  