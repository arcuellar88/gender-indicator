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
#             World Bank Data              #
#                                          #
#   Accessible through wbstats and WDI     #
#     packages in R                        #
#                                          #
############################################

load.WBIData <- function(outputFile, useBackup=FALSE){
  
  #General indicators and Global Findex Data are included in this dataframe
  
  ############################################
  #                                          #
  #             FINDEX DATA                  #
  #                                          #
  ############################################
  
  
  ############################################
  #                                          #
  #       Importing untransformed data       #
  #                                          #
  ############################################
  
  if (useBackup)
  {
    df <- read.csv(file="findex_data.csv", sep=",")
    findex_ind <- read.csv(file="findex_ind.csv", sep=",")
  }
  else
  {
    #Download indicator list from WB (filter those indicators that have FINDEX as the source)
    findex_ind <-  wbsearch(pattern = 'Global Findex', 'source', extra = TRUE) 
    
    
    #filter those indicators that are disagregated by gender using "male" as the pattern
    findex_ind <- findex_ind %>%
      filter(grepl (pattern= "male", indicator))
    
    #Download only gender indicators, all countries available from 2000 to 2015
    df <- WDI(indicator = findex_ind$indicatorID, country = 'all', start=2000, end=2015)
    
    #detach packages
    #detach(package: WDI, unload = TRUE)
    #detach(package: wbstats, unload = TRUE)
    
    #save to backup files
    write.csv(findex_ind, file="findex_ind.csv", quote=TRUE, row.names=FALSE)
    write.csv(df, file="findex_data.csv", quote=TRUE, row.names=FALSE)
  }
  
  ############################################
  #                                          #
  #             Harmonization                #
  #                                          #
  ############################################
  
  #get year of reference of the indicators
  findex_ind <- transform(findex_ind, sourceYear=as.numeric(strsplit(as.character(sourceOrg), ", ")[[1]][2]))
    
  #remove country code
  df <- df %>% rename (iso=iso2c)
  
  #reshape wide to long and paste 
  df <- df %>% gather('indicatorID', 'value', 4:length(df)) 
  
  df <- df[!is.na(df$value),] #remove rows where value=NA
  
  df <- df[!is.na(df$indicator),] #remove rows where indicator name=NA
  
  #set year as character (as we will be appending the "all" value later)
  df$year <- as.character(df$year)
  
  #insert indicator names into main data frame
  df <- inner_join (df, select(findex_ind, -indicatorDesc, -source, -sourceID, -sourceOrg), by = 'indicatorID') 
  
  
  
  
  
  #remove indicators list
  rm(findex_ind)
  
    
  
  #change iso 2 character to iso3 character coding (do not have region codes)
  df$iso <- countrycode (df$iso, "iso2c", "iso3c", warn = FALSE)
  
  #insert the region column  
  df <- df %>% 
    mutate (isRegion=ifelse(is.na(iso), 1, 0)) #regions do not have ISO3 value
  
  #Shorter source name
  df$source <- "WB/Findex"
  
  #remove unwanted columns
  df <- df %>%
    select(-indicatorID, -iso)
  
  #ensure compatible structure
  df$country <- as.vector(df$country)
  
  # If a filename was given, write result to the file
  if (!is.null(outputFile) && !(outputFile==""))
    write.csv(df, file=outputFile, row.names = FALSE)
  
  #return the final data frame
  return(df)

}