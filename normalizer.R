

computeScores <- function(d) {
  indicator_names <- unique(d$indicator)
  
  d$score <- NA
  
  for(name in indicator_names){
    
    sel.indicator <- which(d$indicator %in% name)
    
    #which years this indicator have
    years <- unique(d$year[sel.indicator])
    
    for (y in years)
    {
      #select all countries for this single indicator and year
      selection <- which(d$indicator %in% name & d$year %in% y)
      
      #computes standard score within the selected subset
      d$score[selection] <- scale(d$value[selection])
    }
  }
  
  return(d)
}





