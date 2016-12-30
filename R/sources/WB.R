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
    findex_data <- read.csv(file="findex_data.csv", sep=",")
    findex_ind <- read.csv(file="findex_ind.csv", sep=",")
  }
  else
  {
    ############################################
    #                                          #
    #       Download metadata                  #
    #                                          #
    ############################################
    
    #Download indicator list from WB (filter those indicators that have FINDEX as the source)
    findex_ind <-  wbsearch(pattern = 'Global Findex', 'source', extra = TRUE) 
    
    #filter those indicators that are disagregated by gender using "male" as the pattern
    findex_ind <- findex_ind %>%
    filter(grepl (pattern= "male|women", indicator))
    
    #Write metadata to csv
    write.csv(findex_ind, file="WB_STG_METADATA_INDICATOR.csv", quote=TRUE, row.names=FALSE)
    
    ############################################
    #                                          #
    #       Download indicator data            #
    #                                          #
    ############################################    
    
    #Download only gender indicators, all countries available from 2000 to 2015
    findex_data <- WDI(indicator = findex_ind$indicatorID, country = 'all', start=2000, end=2015)
    
    #Rename country code
    findex_data <- findex_data %>% rename (iso2=iso2c)
    
    #Reshape wide to long and paste 
    findex_data <- findex_data %>% gather('indicatorID', 'value', 4:length(findex_data)) 
    
    #Remove rows where value=NA
    findex_data <- findex_data[!is.na(findex_data$value),] 
    
    #remove rows where indicator name=NA
    findex_data <- findex_data[!is.na(findex_data$indicator),] 
    
    #set year as character (as we will be appending the "all" value later)
    findex_data$year <- as.character(findex_data$year)
    
    #save to backup files
    write.csv(findex_data, file="WB_STG_INDICATOR.csv", quote=TRUE, row.names=FALSE)
  }
  
   return(findex_data)

}