#' Function to compute the normalization of the value of the indicators by year in R.
#' @param d dataset to normalize (it should include the INDICATOR column)
#' @return d with an additional column called SCORE 
#' @examples
#' computeScores(df)
computeScores <- function(d) {
  
  #Get the names of the indicators
  indicator_names <- unique(d$indicator)
  
  #create empty column scores
  d$score <- NA
  
  #iterate over the indicator name and normalize (scale) by year
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

#
#' Function to compute the normalization of the value of the indicators by year in DashDB.
#' @param con connection to dashdb (con <- idaConnect("BLUDB", "", "")
#' @return the results are computed directly in DashDB
#' @examples
#' computeScores(con)
computeScoresDashDB() <-function(con) {
  
  #Initialize connection
  idaInit(con)
  
  #Truncate indicator_by_year table
  idaQuery("truncate table INDICATOR_BY_YEAR immediate",as.is=F) 
  
  # Insert mean and standard deviation by year and indicator into the INDICATOR_BY_YEAR table
  idaQuery("insert into INDICATOR_BY_YEAR
           select INDICATOR_ID, YEAR, AVG(VALUE), STDDEV(VALUE), count(*) as total
           from INDICATOR group by YEAR, INDICATOR_ID",as.is=F) 
  
  # update INDICATOR_BY_YEAR table set standard deviation equal to 1 where it is equal to zero (for indicators with only one country)
  idaQuery(" UPDATE INDICATOR_BY_YEAR SET STDDEV=1 WHERE STDDEV=0",as.is=F) 
  
  # Insert into SRC_INDICATOR value normalized from STG_INDICATOR
  idaQuery("insert into SRC_INDICATOR 
           select 
           ind.ISO3,
           ind.INDICATOR_ID,
           ind.YEAR,
           ind.VALUE,
           (ind.VALUE-indY.MEAN)/indY.STDDEV as VALUE_NORMALIZED
           from 
           INDICATOR ind JOIN INDICATOR_BY_YEAR indY
           ON  ind.INDICATOR_ID= indY.INDICATOR_ID
           AND ind.YEAR= indY.YEAR",as.is=F) 
}
