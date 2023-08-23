#
# find the squared root of the squared difference between two metrics
# returns a vector of continuity with values ranging from 0 to 1
# Thomas Keggin
#

continuity <- function(metric1,metric2){
  
  metric1_clean <- metric1[which(!is.na(metric1),metric1)]
  metric2_clean <- metric2[which(!is.na(metric2),metric2)]
  
  metric1_normalised <- (metric1-min(metric1_clean))/(max(metric1_clean)-min(metric1_clean))
  metric2_normalised <- (metric2-min(metric2_clean))/(max(metric2_clean)-min(metric2_clean))
  
  continuity <- sqrt((metric1_normalised-metric2_normalised)^2)

  return(continuity)
}

continuity2 <- function(metric1,metric2){
  
  metric1_clean <- metric1[which(!is.na(metric1),metric1)]
  metric2_clean <- metric2[which(!is.na(metric2),metric2)]
  
  metric1_normalised <- (metric1-min(metric1_clean))/(max(metric1_clean)-min(metric1_clean))
  metric2_normalised <- (metric2-min(metric2_clean))/(max(metric2_clean)-min(metric2_clean))
  
  continuity <- metric1_normalised-metric2_normalised
  
  return(continuity)
}
