# name - name of the model.
model_stats <- function(formula, data, name){
  cat("------------------\n", name, ":\n------------------\n")
  # Linear Mixed model.
  if (length(lme4::findbars(formula)) > 0){
    model <- lmer(formula, data)
    model_stn <- lmer(formula, mutate_if(data, is.numeric, scale))
    # Raw data.
    print(summary(model))
    cat("Fixed: ", MuMIn::r.squaredGLMM(model)[1,1], "\n")
    cat("Fixed + Random: ", MuMIn::r.squaredGLMM(model)[1,2], "\n")
    # Stand data.
    cat("\n-----", name, "standardized:-----\n")
    print(summary(model_stn))
    cat("Fixed: ", MuMIn::r.squaredGLMM(model_stn)[1,1], "\n")
    cat("Fixed + Random: ", MuMIn::r.squaredGLMM(model_stn)[1,2], "\n")
    
  # Linear model.  
  } else {
    model <- lm(formula, data)
    model_stn <- lm(formula, mutate_if(data, is.numeric, scale))
    # Raw data.
    cat("R2: ", summary(model)$r.squared, "\n")
    print(summary(model)$coefficients)
    print(confint(model))
    # Stand data.
    cat("\n-----", name, "standardized:-----\n")
    cat("R2: ", summary(model_stn)$r.squared, "\n")
    print(summary(model_stn)$coefficients)
    print(confint(model_stn))
  }
  model_list <- list("raw"=model, "stn"=model_stn)
  return(model_list)
}
print_mixed <- function(model){
  rand_var = data.frame(VarCorr(model))[1,'vcov']
  err_var = data.frame(VarCorr(model))[2,'vcov']
  cat("Explained variance:\n")
  cat("Fixed: ", MuMIn::r.squaredGLMM(model)[1,1], "\n")
  cat("Fixed + Random: ", MuMIn::r.squaredGLMM(model)[1,2], "\n")
  cat("Random: ", rand_var, "\n")
  cat("Error: ", err_var, "\n")
  cat("Random/Error: ", rand_var / err_var, "%")
  print(VarCorr(model), comp="Variation")
  summary(model)
}