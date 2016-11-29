#################################
# Export datasets               #
#################################

uploadSocrata <-function(df)
{
  # Store user email and password
  socrataEmail <- Sys.getenv("SOCRATA_EMAIL", SOCRATA_EMAIL)
  socrataPassword <- Sys.getenv("SOCRATA_PASSWORD", SOCRATA_PASSWORD)
  
  datasetToAddToUrl <- "https://mydata.iadb.org/OData.svc/miqb-7p2m" # dataset
  
  # Upload to Socrata
  write.socrata(head(df,50000),datasetToAddToUrl,"REPLACE",socrataEmail,socrataPassword)
}

#
#' Function to compute the GAP, generate the GENDER_INDICATOR, upload to socrata and save to file.
#' @param con connection to dashdb (con <- idaConnect("BLUDB", "", ""))
#' @return the results are computed directly in DashDB
#' @examples
#' computeScores(con)
exportData<-function(con, socrata=FALSE)
{
  #Initialize connection
  sqlcommands<-readSQLCommands(paste0(DASHDB,"GAP.sql"))
  runSQL(sqlcmdlist=sqlcommands,con=con)
  
  if(socrata)
  {
    uploadSocrata(df)
  }
  
  #################################
  # Output results to file        #
  #################################
  #setwd(OUTPUT_FOLDER)
  write.table(df, file=MAIN_OUTPUT_FILENAME, sep=",", quote=TRUE, row.names=FALSE)
  
}