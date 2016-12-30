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

#################################
# SET UP Algorithm Parameters   #
#################################
source("R/config.R")


#Install required libraries

  list.of.packages <- c("dplyr", "wbstats","devtools","downloader","WDI","tidyr","stringr","R.utils","tools","RSocrata")
  new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
  if(length(new.packages)) install.packages(new.packages)

library(devtools)


#Set proxy:
library(httr)
set_config(
  use_proxy(url=PROXY_HOST, port=PROXY_PORT, username=PROXY_USER,password=PROXY_PWD)
)

  #Object Storage IBM
  list.of.packages <- c("objectStoreR")
  new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
  if(length(new.packages)) install_github('IBMDataScience/objectStoreR') #installs the package
  
  #N4D API
  list.of.packages <- c("idbstats")
  new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
  if(length(new.packages)) install_github('arcuellar88/iadbstats')

#Load required libraries
library(dplyr)
library(wbstats)
library(downloader)
library(WDI)
library(tidyr)
library(stringr)
library('objectStoreR')
library(idbstats)




############################################
#                                          #
# Dataset format after harmonization:      #
#    * indicator - indicator name          #
#    * country - country name (or region)  #
#    * year - reference year (or "all")    #
#    * value - indicator value             #
#    * source - indicator source           #
#    * sourceYear - year when the info was #
#                   obtained or published  #
#                   by the source          #
#    * isRegion - whether it is a country  #
#                 or a region indicator    #
#                                          #
#                                          #
############################################

#setwd("SOURCE_FOLDER")


#################################
# Load harmonization functions  #
#################################

#source("test/IDB.R")

source("R/sources/WB.R")
source("R/sources/NCD.R")

source("R/harmonize.R")
source("R/normalizer.R")
source("R/classifier.R")
source("R/exportData.R")


connectDB <- function()
{
  library(ibmdbR)
  con <- idaConnect("DASHDB","","")
  con
}

readSQLCommands <- function(file)
{
  #"/dashdb/classify.sql"
  sqlcmds <- readLines(file)
  sqlcmds <- sqlcmds[!grepl(pattern = "^\\s*--", x = sqlcmds)] # remove full-line comments
  sqlcmds <- sub(pattern = "--.*", replacement="", x = sqlcmds) # remove midline comments
  sqlcmds <- paste(sqlcmds, collapse=" ")
  
  sqlcmdlist<<-as.list(strsplit(sqlcmds, ";")[[1]])
  
  sqlcmdlist
}

runSQL<-function(sqlcmdlist,con)
{
  #idaInit(con)
  #print(length(sqlcmdlist))
  
  for(i in 1:length(sqlcmdlist))
  {
    q<-trim(sqlcmdlist[[i]])
    
    if(q!="")
    {
      #print(paste0("index: ",i))
      #print(q)
      try(idaQuery(q))
    }
  }
  
}
#' Orchestrator of the ETL process for the Gender Dashboard
#' Load data into Dashdb, classify, normalize and generate the final GENDER_INDICATOR table in dashdb.
#' @return 
#' @examples
#' processinDB(df)
processinDB <- function()
{
  
  start.time <- Sys.time()
  #################################
  # Connect to DashDB             #
  #################################
  con<-connectDB()
  idaInit(con)
  
  #################################
  # Load Datasets                 #
  #################################
  #TODO DEcember 2016
  
  #################################
  # Harmonize Datasets            #
  #################################
  print("Start harmonize.R")
  harmonizeDashDBFromFile(con)
  print("End harmonize.R")
  
  end.time <- Sys.time()
  print(end.time - start.time)
  
  #################################
  # Classify Indicators           #
  #################################
  print("Start classify.R")
  classifyDashDBFromFile(con)
  print("End classify.R")
  
  end.time <- Sys.time()
  print(end.time - start.time)
  
  
  #################################
  # Normalize Values (Std. Score) #
  #################################
  # The normalization method used #
  # is the standard scores. The   #
  # resulting scores represent    #
  # how many standard deviations  #
  # the data point is distant     #
  # from the average.             #
  #################################
  print("Start normalize.R")
  computeScoresDashDBFromFile(con)
  print("End normalize.R")
  
  end.time <- Sys.time()
  print(end.time - start.time)
  
  
  #################################
  # Export dataset incl. GAP      #
  #################################
  print("Start exportData.R")
  exportData(con)
  print("End exportData.R")
  
  end.time <- Sys.time()
  print(end.time - start.time)
  
}

processinFile <- function(useBackup=TRUE)
{
  
  #################################
  # Load and Harmonize Datasets   #
  #################################
  idb <- load.IDBData(IDB_OUTPUT_FILENAME, useBackup=TRUE)
  wbi <- load.WBIData(WBI_OUTPUT_FILENAME, useBackup=TRUE)
  ncd <- load.NCData(NCD_OUTPUT_FILENAME)
  
  #################################
  # Concatenate the datasets      #
  #################################
  
  data <- bind_rows(idb, wbi, ncd)
  
  #remove the temporary tables
  rm(idb)
  rm(wbi)
  rm(ncd)
  
  #################################
  # Look for duplicate indicators #
  #################################
  ## 
  #cnt <- count(data, indicator,country,year,source) #count possible repetitions
  #dups <- cnt[cnt$n > 1,] #select those that are repeated
  # save the list of duplicated to a file for future inspection
  # write.table(dups, file="log_dups.csv", sep="\t", quote=TRUE, row.names=FALSE)
  ##
  #... data <- count(data, indicator,country,year,value,source,sourceYear,isRegion)
  # data <- data[,-n]
  
  
  #################################
  # Summarize Values   (mean)     #
  #  (For regions)                #
  #  (For all years)              #
  #################################
  
  #aggregate all years of each distinct country
  attach(data)
  data.agg.years <- aggregate(data, by=list(ind=indicator,cty=country,s=source), FUN=mean, na.rm=TRUE) %>%
    select(-indicator, -country, -source) 
  detach(data)
  #adjust column names
  names(data.agg.years) <- c("indicator", "country", "source", "year", "value", "sourceYear", "isRegion")
  #set year value to "all"
  data.agg.years$year <- "all"
  
  #append to the data
  data <- bind_rows(data, data.agg.years)
  #delete temporary data
  rm(data.agg.years)
    
  #################################
  # Normalize Values (Std. Score) #
  #################################
  # The normalization method used #
  # is the standard scores. The   #
  # resulting scores represent    #
  # how many standard deviations  #
  # the data point is distant     #
  # from the average.             #
  #################################
  
  source("normalizer.R")
  data <- computeScores(data)
  
  #################################
  # Classify Indicators           #
  #################################
  source("classifier.R")
  data <- classify(data)
  
  #################################
  #  Adjust multiplier
  # ---> should this be run by normalizer or classifier?
  
  data <-
    data %>%
    mutate(score_corrected = score * multiplier)
  #################################
  
  
  #################################
  # Output results to file        #
  #################################
  setwd(OUTPUT_FOLDER)
  write.table(data, file=MAIN_OUTPUT_FILENAME, sep=";", quote=TRUE, row.names=FALSE)
  
  total_indicators <- length(unique(data$indicator))
  paste("Algorithm finished processing...", total_indicators, "indicators and", length(data$indicator), "rows of data")
  paste("Results were written to CSV file:", MAIN_OUTPUT_FILENAME, "on folder", OUTPUT_FOLDER)
}

#' Update the terms by DIVISION. Read csv files with term-division combinations, upload to dashdb and update the TERMS_DIV table
#' @return End result is in dashdb
#' @examples
#' updateTerms()
updateTerms<-function()
{
  idaInit(con)
  division<-read.csv("./data/terms.csv", header=TRUE)
  as.ida.data.frame(division, 'TERMS', clear.existing=TRUE)
  
  idaQuery("truncate TERMS_DIV immediate")
  
  idaQuery("insert into TERMS_DIV 
            select DIVISION,LISTAGG(TRIM(TERM), '|') WITHIN GROUP(ORDER BY TERM) as terms
            from TERMS group by DIVISION")
  
}




