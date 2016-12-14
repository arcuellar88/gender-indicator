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
getObjectStorageFile <- function(credentials) {
  if(!require(httr)) install.packages('httr')
  if(!require(RCurl)) install.packages('RCurl')
  library(httr, RCurl)
  auth_url <- paste(credentials[['auth_url']],'/v3/auth/tokens', sep= '')
  auth_args <- paste('{"auth": {"identity": {"password": {"user": {"domain": {"id": ', credentials[['domain_id']],'},"password": ',
                     credentials[['password']],',"name": ', credentials[['username']],'}},"methods": ["password"]}}}', sep='"')
  auth_response <- httr::POST(url = auth_url, body = auth_args)
  x_subject_token <- headers(auth_response)[['x-subject-token']]
  auth_body <- content(auth_response)
  access_url <- unlist(lapply(auth_body[['token']][['catalog']], function(catalog){
    if((catalog[['type']] == 'object-store')){
      lapply(catalog[['endpoints']], function(endpoints){
        if(endpoints[['interface']] == 'public' && endpoints[['region_id']] == credentials[['region']]) {
          paste(endpoints[['url']], credentials[['container']], credentials[['filename']], sep='/')}
      })
    }
  })) 
  data <- content(httr::GET(url = access_url, add_headers ("Content-Type" = "application/json", "X-Auth-Token" = x_subject_token)), as="text")
  textConnection(data)
}

load.IDBData <- function(outputDir, useBackup=FALSE){

  source(paste0(IDB_FOLDER,"iadbstats.R"))
  source(paste0(IDB_FOLDER,"utilities.R"))
  source(paste0(IDB_FOLDER,"iadbsearch.R"))
  
  meta_ind<-iadbmsearch('ALL')
  meta_ind <- meta_ind %>% filter(grepl (pattern= "male|women", tolower(IndicatorName)))
  #write.table(meta_ind,paste0(outputDir,"n4d_meta.csv"), quote=T, sep=',', fileEncoding='UTF8',  append = FALSE, row.names=F)
  
  
  
  
  
  #Download data from indicators
  ind<-iadbstats.list(IndicatorCodes=meta_ind$IndicatorCode)
  #Select columns
  ind_data <-select(ind, -CountryTableName, -IndicatorName, -SubTopicName , -Quarter, -Month, -AggregationLevel, -UOM, -TopicName)
  
  #Write data into csv file
  #write.table(ind_data,paste0(outputDir,"n4d_data.csv"), quote=T, sep=',', fileEncoding='UTF8',  append = FALSE, row.names=F)
  
  
  
}
