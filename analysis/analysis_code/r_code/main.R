main <- function(){
  debugSource('describe_stats_single_val.R')
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
  # Choose which vars to analyze ["rt","react","mt","mad","tot_dist","auc","ra","com","max_vel",paste0("traj",1:traj_len),paste0("iep",1:traj_len),paste0("vel",1:traj_len)]
  # Add "r_ra" to p$VAR_NAMES (but not p$R_VAR_NAMES, since ra is relevant only for avgs analysis) to analyze reach area.
  p$R_VAR_NAMES <- c("react","mt","tot_dist", "com", "auc")
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
  
  #############################README############################################
  # Two types of functions below: '_avgs', '_trials'.                           #
  # Use '_avgs' to calculate effects with each sub's avg.                       #
  # Use '_trials' to create a LMM for each sub with 'side'(left/right) of answer#
  # as a random effect.                                                         #
  ###############################################################################
  
  
  cat("Params Defined.\n")
  ##---- Preprocessing -----------------------------------
  preproc_avgs(p)
  #preproc_trials('r', p)
  #preproc_trials('k', p)
  ##---- Descriptive statistics / Data Overview ----------
  describe_avgs(p)
  ##---- Modeling ----------------------------------------
  model_avgs(p)
  # model_trials('r',p$R_VAR_NAMES, p)
  # model_trials('k',p$K_VAR_NAMES, p)
  # coefs_table('r', p$R_VAR_NAMES, p)
  # coefs_table('k', p$K_VAR_NAMES, p)
  ##---- Assumptions testing -----------------------------
  test_assump_avgs(p)
  # test_assump_coefs('r', p$R_VAR_NAMES, p)
  # test_assump_coefs('k', p$K_VAR_NAMES, p)
  ##---- Permutation T-testing ---------------------------
  # For variables that violated normality.
  permute_avgs(p)
  ##---- Effect Size Calc --------------------------------
  effect_size_avgs(p)
  ##---- Coefficients significance test ------------------
  # coefs_test('k',p$K_VAR_NAMES,p)
  # coefs_test('r',p$R_VAR_NAMES,p)
  # coefs_plot(p)
}
