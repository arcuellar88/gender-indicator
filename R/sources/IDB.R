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
############################################

load.IDBData <- function(outputDir, useBackup=FALSE){

  ############################################
  #                                          #
  #       Download metadata                  #
  #                                          #
  ############################################
  meta_ind<-iadbmsearch('ALL')
  meta_ind <- meta_ind %>% filter(grepl (pattern= "male|women", tolower(IndicatorName)))
  
  
  write.table(meta_ind,paste0(outputDir,"N4D_STG_METADATA_INDICATOR.csv"), quote=T, sep=',', fileEncoding='UTF8',  append = FALSE, row.names=F)
  
  
  
  
  ############################################
  #                                          #
  #       Download indicator data            #
  #                                          #
  ############################################
  
  #Download data from indicators
  ind<-iadbstats.list(IndicatorCodes=meta_ind$IndicatorCode)
  #Select columns
  ind_data <-select(ind, -CountryTableName, -IndicatorName, -SubTopicName , -Quarter, -Month, -AggregationLevel, -UOM, -TopicName)
  
  #Write data into csv file
  write.table(ind_data,paste0(outputDir,"N4D_STG_INDICATOR.csv"), quote=T, sep=',', fileEncoding='UTF8',  append = FALSE, row.names=F)
  
  
  
}
