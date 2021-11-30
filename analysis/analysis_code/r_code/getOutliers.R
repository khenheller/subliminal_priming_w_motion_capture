getOutliers <- function(data_frame, data_col){
  q <- quantile(data_frame[,data_col], probs=c(.25, .75))
  iqr <- IQR(data_frame[,data_col])
  upper <- q[2] + iqr*1.5
  lower <- q[1] - iqr*1.5
  outliers <- subset(data_frame, data_frame[,data_col]<lower | data_frame[,data_col]>upper)
  inliers <- subset(data_frame, data_frame[,data_col]>=lower & data_frame[,data_col]<=upper)
  return(list(outliers, inliers))
}