

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

library(RSocrata)
library(wbstats)
library(WDI)
library(R.utils)
library(tools)
library(dplyr)
library(tidyr)
library(stringr)
library(countrycode)

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

#setwd("")
#################################
# SET UP Algorithm Parameters   #
#################################
source("config.R")


#################################
# Load harmonization functions  #
#################################
#source("test/IDB.R")
source("sources/Socrata.R")
source("sources/WB.R")
#source("test/NCD.R")


#################################
# Load and Harmonize Datasets   #
#################################

idb <- load.IDBData(IDB_OUTPUT_FILENAME, useBackup=TRUE)
wbi <- load.WBIData(WBI_OUTPUT_FILENAME, useBackup=TRUE)
#ncd <- load.NCData(NCD_OUTPUT_FILENAME)

#################################
# Concatenate the datasets      #
#################################
#rbind(idb, wbi, ncd)
#data <- bind_rows(idb, wbi, ncd)
data <- bind_rows(idb, wbi)

#remove the temporary tables
rm(idb)
rm(wbi)
#rm(ncd)

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


paste("Algorithm finished processing...", "---", "indicators and", length(data$indicator), "rows of data")
paste("Results were written to CSV file:", MAIN_OUTPUT_FILENAME, "on folder", OUTPUT_FOLDER)

