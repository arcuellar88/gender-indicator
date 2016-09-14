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
############################################

############################################
# Load and Harmonize a dataset from:       #
############################################
#                                          #
#             IDB Gender Data              #
#             Open Data Portal             #
#            (Socrata Platform)            #
#                                          #
############################################

# required packages: RSocrata, dplyr, R.utils, tools 3.3.0

#if the outputFile is blank ("") or null,
# just return the results without writing to a file
load.IDBData <- function(outputFile, useBackup=FALSE){
   
  
  ############################################
  #                                          #
  #   Download the data through Socrata API  #
  #                                          #  
  #                                          #
  ############################################
  
  
  if (useBackup)
  {
    df <- read.csv(file.choose())
  }
  else
  {
    socrataEmail <- Sys.getenv("SOCRATA_EMAIL", SOCRATA_EMAIL)
    socrataPassword <- Sys.getenv("SOCRATA_PASSWORD", SOCRATA_PASSWORD)
    privateResourceToReadCsvUrl <- "https://mydata.iadb.org/Gender/Numbers-for-Development-Gender-Indicators/u5nc-wtuz" # dataset
    
    df <- read.socrata(url = privateResourceToReadCsvUrl, email = socrataEmail, password = socrataPassword)
  }
  
  ############################################
  #                                          #
  #             Harmonization                #
  #                                          #  
  #                                          #
  ############################################
  
  #convert to lower case the varible names
  names(df)<- tolower(names(df))
  
  
  #convert to lower case country variable
  df$country <- tolower(df$country)
  #then, capitalize first letters, except stop words
  df$country <- toTitleCase(df$country)
  
  #convert year to character, as we are going to have the "all" member
  df$year <- as.character(df$year)
  
  
  
  #Add source variable
  
  df <- df %>%
    mutate (source = "IDB") %>%
    mutate (sourceYear = 2016) %>%
    mutate (isRegion = 0)
  
  
  # If a filename was given, write result to the file
  if (!is.null(outputFile) && !(outputFile==""))
    write.csv(df, file=outputFile, sep=";", row.names = FALSE) # '/data/socrata.csv'
  
  #return the final data frame
  return(df)
}
