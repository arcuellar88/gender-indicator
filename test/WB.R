


load.WBIData <- function(outputFile) {
  df <- data.frame(indicator=rep("indicator WBI",2), #duplicated
                   country=rep("Americas",2),
                   year=rep("2016",2),
                   value=rep(0.5,2),
                   sourceOrg=rep("WBI",2),
                   sourceYear=rep(2015,2),
                   isRegion=c(1,1))
  
  return(df)
}


