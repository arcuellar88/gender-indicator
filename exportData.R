#################################
# Export datasets               #
#################################
#
#' Function to compute the normalization of the value of the indicators by year in DashDB.
#' @param con connection to dashdb (con <- idaConnect("BLUDB", "", ""))
#' @return the results are computed directly in DashDB
#' @examples
#' computeScores(con)
generateGenderIndicatorDashDB <-function(con) {
  
  #Initialize connection
  idaInit(con)
  
  #----------------------#
  #---GENDER_INDICATOR---#
  #----------------------#
  idaQuery("TRUNCATE TABLE GENDER_INDICATOR IMMEDIATE;",as.is=F) 
  idaQuery("INSERT INTO GENDER_INDICATOR
          SELECT INDICATOR, PRIMARY, UOM, YEAR,ISO3, COUNTRY,REGION, IDB_REGION,SOURCE,SOURCE_GROUP, TOPIC, GENDER, AREA,AGE, QUINTIL as QUINTILE, EDUCATION, DIVISION, MULTIPLIER, 
          VALUE, VALUE_NORMALIZED,VALUE_NORMALIZED*MULTIPLIER 
          FROM SRC_INDICATOR JOIN SRC_METADATA_INDICATOR using (INDICATOR_ID)
          left join idb_country on ISO3=ISO_CD3",as.is=F) 
  
}

uploadSocrata <-function(df)
{
  # Store user email and password
  socrataEmail <- Sys.getenv("SOCRATA_EMAIL", SOCRATA_EMAIL)
  socrataPassword <- Sys.getenv("SOCRATA_PASSWORD", SOCRATA_PASSWORD)
  
  datasetToAddToUrl <- "https://mydata.iadb.org/OData.svc/miqb-7p2m" # dataset
  
  
  # Upload to Socrata
  write.socrata(head(df,50000),datasetToAddToUrl,"REPLACE",socrataEmail,socrataPassword)
}

export<-function(con, socrata=FALSE)
{
  generateGenderIndicatorDashDB(con)
  
  #Initialize connection
  idaInit(con)
  df<-idaQuery("SELECT *  FROM GENDER_INDICATOR LIMIT 50000",as.is=F) 
  
  if(socrata)
  {
    uploadSocrata(df)
  }
  
  #################################
  # Output results to file        #
  #################################
  setwd(OUTPUT_FOLDER)
  write.table(df, file=MAIN_OUTPUT_FILENAME, sep=",", quote=TRUE, row.names=FALSE)
  
  
  
  
}