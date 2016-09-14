


load.IDBData <- function(outputFile) {
  df <- data.frame(indicator=rep("indicator IDB",3),
                   country=c("Chile","Equador", "Equador"),
                   year=c("2016","2015","2016"),
                   value=c(1, 0.6, 0.4),
                   sourceOrg=rep("IDB",3),
                   sourceYear=rep(2016,3),
                   isRegion=rep(0,3))
  
  return(df)
}



