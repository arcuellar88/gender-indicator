############################################
#                                          #
#   Inter-American Development Bank (IDB)  #
#       Gender Indicators                  #
#                                          #
# Authors:                                 #
#        Andreina Vardy                    #
#        Paula Castillo                    #
#        Carlos Grandet                    #                 
#        Cesar Lins                        #
#        Alejandro Rodriguez               #
#                                          #
#                                          #
#                                          #
############################################

#idf <- as.ida.data.frame(iris2,"IRIS",clear.existing=T)
library(RSocrata)

uploadSocrata <-function(df)
{
  # Store user email and password
  socrataEmail <- Sys.getenv("SOCRATA_EMAIL", "alejandroro@iadb.org")
  socrataPassword <- Sys.getenv("SOCRATA_PASSWORD", "coL1988San")
  
  datasetToAddToUrl <- "https://mydata.iadb.org/resource/miqb-7p2m.json" # dataset
  
  
  # Upload to Socrata
  write.socrata(head(df,50000),datasetToAddToUrl,"REPLACE",socrataEmail,socrataPassword)
}

library(ibmdbR)

#' updload data into DashDB
#' 
#' @param df data.frame 
#' (indicator, country, year, source, sourceYear, isRegion, type, division, multiplier,
#'  value,value_normalized, value_with_correction, value_normalized_with_correction )
#' @return All the divisions that the indicator belong to separated by comma
#' @examples
#' uploadData(df)
#' uploadData(df,'INDICATOR_DATA')
uploadData <- function(df, table_name='INDICATOR_DATA') {
  
  con <-idaConnect("dashdb", conType = "odbc")
  idaInit(con)
  
  lYears <- split( df , df$year )
  for (name in names(lYears)) {
    print(name)
    as.ida.data.frame(lYears[[name]],table_name,clear.existing=T)
  }
  
  
}

