# Performs Leave one out cross validation on our model.
loocv <- function(formula, data, trueY) {
  y_pred <- array(dim=nrow(data))
  # Iterate obs.
  for (i in 1:nrow(data)){
    # Make a model on all data expect 1st line.
    model <- makeModel(formula, data)
    # Predict 1st line's Y.
    y_pred[i] <- predict(model, newdata=data[1,])
    # Roll the data.
    data <- rbind(data[-1,], data[1,])
  }
  # Corr between pred and real Y.
  R2_pred <- cor(y_pred, trueY)^2
  return(R2_pred)
}

makeModel <- function(formula, data){
  # Check if mixed model.
  if (length(lme4::findbars(formula)) > 0){
    model <- lmer(formula, data[-1,])
  } else {
    model <- lm(formula, data[-1,])
  }
  return(model)
}