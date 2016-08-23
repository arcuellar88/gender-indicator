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
#                                          #
#             World Bank Data              #
#                                          #
############################################

WBD <- function(){

#The World Bank data is available through R packages "wbstats' and 'WDI'
#General indicators and Global Findex Data are included in this dataframe


#install packages
#install.packages("wbstats")
#install.packages("WDI")
#install.packages("dplyr")
#install.packages("tidyr")

library(wbstats)
library(WDI)
library(dplyr)
library(tidyr)

#set working directory (and chaged as required)
setwd ("C:/Users/andreinav/OneDrive - Inter-American Development Bank Group/Dashboard/Dashboard Coding/WBD")

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

#filter by indicator code those that are FINDEX indicators using source
findex_ind <-  wbsearch(pattern = 'Global Findex', 'source', extra = TRUE) 

#filter those that are disagregated by women or male using "male" as the patterns
findex_ind <- findex_ind %>%
  filter(grepl (pattern= "male", indicator))

#call API of WB and request only gender indicators
findex <- WDI(indicator = findex_ind$indicatorID, country = 'all', start=2000, end=2015)

#detach packages and upload basic ones
detach(package: WDI, unload = TRUE)
detach(package: wbstats, unload = TRUE)
install.packages("dplyr")
install.packages("tidyr")
library(stats)
library(dplyr, warn.conflicts = FALSE)
library(tidyr)


############################################
#                                          #
#             Clean the data               #
#                                          #
############################################


#load data (optional)
#findex <- read.csv('findex.csv', stringsAsFactors = FALSE)

#remove country code
findex <- findex %>% rename (iso=iso2c)

#reshape wide to long and paste 
findex <- findex %>% gather('indicatorID', 'value', 4:length(findex)) 

findex <- findex[!is.na(findex$value),] #remove NAs

findex <- findex[!is.na(findex$indicator),] #remove NAs

findex <- inner_join (findex, findex_ind, by = 'indicatorID') #reshape



############################################
#                                          #
#       Create multiplier and division     #
#                   variables              #
#                                          #
############################################

#create new variable for the multiplier
findex<-findex %>% 
  mutate (multiplier = ifelse(grepl ('outstanding|informal',indicator), -1, 1) %>% as.character())

#create the lists with terms by division
SPH <- c("pregnancy", "death", "mortality", "fertility", "condom", "contracep", "birth", "antire", "immu", "survi", "lifetime", "child")
ICS_PM <- c("internet", "broadband", "services", "administration", "representation", "judiciary", "participant", "mobile", "right", "contract")
ICS_CS <- c("violence", "rob", "police", "inheritance", "beating", "peace", "rape", "ownership", "homecide", "headed", "military", "fertility", "judiciary")
LMK <- c("empl","pension","unempl", "training","vocational", "work", "unpaid", "smoking", "self")
CMF <- c("bank", "account", "check","financial", "contract", "business", "own-account")
EDU <- c("school", "literacy", "dropout")
FMM <- c("urban", "rural")
CCS <- c("journalist", "internet")
EXR <- c("internet", "commu", "journal")
CTI <- c("tech", "internet", "science", "broadband", "intellectual", "")
ENE <- c("energy", "fuel", "methane", "electric")
WSA <- c("water", "sanita", "well", "electricity", "fresh")
RND <- c("agri", "land", "rural", "protected")
TSP <- c("trans", "road", "construc", "infras")
HUD <- c("hous","urban")


#create new variable for the multiplier
findex <-findex %>% 
  mutate (SPH = ifelse(grepl (paste(SPH,collapse="|"), indicator), 1, 0) %>% as.character()) %>% 
  mutate (ICS_PM = ifelse(grepl (paste(ICS_PM,collapse="|"), indicator), 1, 0) %>% as.character()) %>% 
  mutate (ICS_CS = ifelse(grepl (paste(ICS_CS,collapse="|"), indicator), 1, 0) %>% as.character()) %>%
  mutate (LMK = ifelse(grepl (paste(LMK, collapse="|"), indicator), 1, 0) %>% as.character()) %>%
  mutate (CMF = ifelse(grepl (paste(CMF, collapse="|"), indicator), 1, 0) %>% as.character()) %>%
  mutate (EDU = ifelse(grepl (paste(EDU,collapse="|"), indicator), 1, 0) %>% as.character()) %>%
  mutate (FMM = ifelse(grepl (paste(FMM, collapse="|"), indicator), 1, 0) %>% as.character()) %>%
  mutate (CCS = ifelse(grepl (paste(CCS, collapse="|"), indicator), 1, 0) %>% as.character()) %>%
  mutate (EXR = ifelse(grepl (paste(EXR,collapse="|"), indicator), 1, 0) %>% as.character()) %>%
  mutate (CTI = ifelse(grepl (paste(CTI, collapse="|"), indicator), 1, 0) %>% as.character()) %>%
  mutate (ENE = ifelse(grepl (paste(ENE, collapse="|"), indicator), 1, 0) %>% as.character()) %>%
  mutate (WSA = ifelse(grepl (paste(WSA,collapse="|"), indicator), 1, 0) %>% as.character()) %>%
  mutate (RND = ifelse(grepl (paste(RND, collapse="|"), indicator), 1, 0) %>% as.character()) %>%
  mutate (TSP = ifelse(grepl (paste(TSP, collapse="|"), indicator), 1, 0) %>% as.character()) %>%
  mutate (HUD = ifelse(grepl (paste(HUD, collapse="|"), indicator), 1, 0) %>% as.character())


#remove dataframes
rm(findex_ind)

############################################
#                                          #
#             Create type                  #
#               variables                  #
#                                          #
############################################

findex <- findex %>% mutate (type = ifelse (grepl ("female", indicator), "female", ifelse (grepl ("male",indicator),"male", ifelse (grepl("total",indicator),"total", ifelse (grepl("urban",indicator), "urban", ifelse (grepl("rural",indicator), "rural", "other")) %>% as.character()))))


############################################
#                                          #
#       Normalize the data                 #
#         variables                        #
#                                          #
############################################

#convert to numeric
findex$value <- as.numeric(findex$value)

#normalize indexing
indicator_names <- names(table(findex$indicator))
findex$value_normalized <- NA

for(i in indicator_names){
  
  selection <- which(findex$indicator %in% i)
  findex$value_normalized[selection] <- scale(findex$value[selection])
  
}

#adjust with multiplier
findex$multiplier<- as.numeric(findex$multiplier)

findex <-
  findex %>%
  mutate(value_with_correction = value * multiplier) %>%
  mutate(value_normalized_with_correction = value_normalized * multiplier)

#Convert to numeric all division variables
x <- 11:26
findex[x] <- lapply(findex[x], as.numeric) 

#optional save data
#write.csv(findex, "findex_final.csv", row.names = FALSE)

############################################
#                                          #
#             WB Gender DATA               #
#                                          #
############################################


############################################
#                                          #
#       Importing untransformed data       #
#                                          #
############################################

#load packages
install.packages("wbstats")
install.packages("WDI")
library(wbstats)
library(WDI)

#set working directory (and chaged as required)
setwd ("C:/Users/andreinav/OneDrive - Inter-American Development Bank Group/Dashboard/Dashboard Coding/WBD")

#create a filter by indicator name that contains MA and FE for male and female disagregated
gender_ind<-  wbsearch (pattern= 'male', fields = "indicator", extra = TRUE)

#call API of WB and request only gender indicators
gender<-  WDI(indicator = gender_ind$indicatorID, country = 'all', start=2000, end=2015, extra = TRUE) 

#save data for loading later (optional)
#write.csv (gender,file= "gender.csv", row.names= FALSE)

#load data (optional)
#gender <- read.csv('gender.csv', stringsAsFactors = FALSE)


#remove packages
detach(package:WDI, unload = TRUE)
detach(package: wbstats, unload = TRUE)

#load packages
install.packages("dplyr")
install.packages("tidyr")
library(dplyr)
library(tidyr)


############################################
#                                          #
#             Clean the data               #
#                                          #
############################################


#remove country codes
gender <- gender %>% rename (iso=iso2c)

#reshape
gender <- gender %>%
  gather ('indicatorID', 'value', 4:length(gender))

#remove NAs
gender<- gender[!is.na(gender$value),] #remove NAs

#join with indicator names
gender <- inner_join (gender, gender_ind, by = 'indicatorID') #reshape



############################################
#                                          #
#       Create multiplier and division     #
#                   variables              #
#                                          #
############################################



#create new variable for the multiplier
gender<-gender %>% 
  mutate (multiplier = ifelse(grepl ('outstanding|informal|death|mort|drop|HIV|viol|disor|vulnerable| fertility|unimpro|disea',indicator), -1, 1) %>% as.character())



#Create the lists with terms by division
SPH <- c("pregnancy", "death", "mortality", "fertility", "condom", "contracep", "birth", "antire", "immu", "survi", "lifetime", "child")
ICS_PM <- c("internet", "broadband", "services", "administration", "representation", "judiciary", "participant", "mobile", "right", "contract")
ICS_CS <- c("violence", "rob", "police", "inheritance", "beating", "peace", "rape", "ownership", "homecide", "headed", "military", "fertility", "judiciary")
LMK <- c("empl","pension","unempl", "training","vocational", "work", "unpaid", "smoking", "self")
CMF <- c("bank", "account", "check","financial", "contract", "business", "own-account")
EDU <- c("school", "literacy", "dropout")
FMM <- c("urban", "rural")
CCS <- c("journalist", "internet")
EXR <- c("internet", "commu", "journal")
CTI <- c("tech", "internet", "science", "broadband", "intellectual")
ENE <- c("energy", "fuel", "methane", "electric")
WSA <- c("water", "sanita", "well", "electricity", "fresh")
RND <- c("agri", "land", "rural", "protected")
TSP <- c("trans", "road", "construc", "infras")
HUD <- c("hous","urban")


#create new variable for the multiplier
gender <-gender %>% 
  mutate (SPH = ifelse(grepl (paste(SPH,collapse="|"), indicator), 1, 0) %>% as.character()) %>% 
  mutate (ICS_PM = ifelse(grepl (paste(ICS_PM,collapse="|"), indicator), 1, 0) %>% as.character()) %>% 
  mutate (ICS_CS = ifelse(grepl (paste(ICS_CS,collapse="|"), indicator), 1, 0) %>% as.character()) %>%
  mutate (LMK = ifelse(grepl (paste(LMK, collapse="|"), indicator), 1, 0) %>% as.character()) %>%
  mutate (CMF = ifelse(grepl (paste(CMF, collapse="|"), indicator), 1, 0) %>% as.character()) %>%
  mutate (EDU = ifelse(grepl (paste(EDU,collapse="|"), indicator), 1, 0) %>% as.character()) %>%
  mutate (FMM = ifelse(grepl (paste(FMM, collapse="|"), indicator), 1, 0) %>% as.character()) %>%
  mutate (CCS = ifelse(grepl (paste(CCS, collapse="|"), indicator), 1, 0) %>% as.character()) %>%
  mutate (EXR = ifelse(grepl (paste(EXR,collapse="|"), indicator), 1, 0) %>% as.character()) %>%
  mutate (CTI = ifelse(grepl (paste(CTI, collapse="|"), indicator), 1, 0) %>% as.character()) %>%
  mutate (ENE = ifelse(grepl (paste(ENE, collapse="|"), indicator), 1, 0) %>% as.character()) %>%
  mutate (WSA = ifelse(grepl (paste(WSA,collapse="|"), indicator), 1, 0) %>% as.character()) %>%
  mutate (RND = ifelse(grepl (paste(RND, collapse="|"), indicator), 1, 0) %>% as.character()) %>%
  mutate (TSP = ifelse(grepl (paste(TSP, collapse="|"), indicator), 1, 0) %>% as.character()) %>%
mutate (HUD = ifelse(grepl (paste(HUD, collapse="|"), indicator), 1, 0) %>% as.character())


#remove dataframes
rm(gender_ind)

############################################
#                                          #
#             Create type                  #
#               variables                  #
#                                          #
############################################

gender <- gender %>% mutate (type = ifelse (grepl ("female", indicator), "female", ifelse (grepl ("male",indicator),"male", ifelse (grepl("total",indicator),"total", ifelse (grepl("urban",indicator), "urban", ifelse (grepl("rural",indicator), "rural", "other")) %>% as.character()))))

############################################
#                                          #
#       Normalize the data                 #
#         variables                        #
#                                          #
############################################

#convert to numeric
gender$value <- as.numeric(gender$value)

#normalize indexing
indicator_names <- names(table(gender$indicator))
gender$value_normalized <- NA

for(i in indicator_names){
  
  selection <- which(gender$indicator %in% i)
  gender$value_normalized[selection] <- scale(gender$value[selection])
  
}

#adjust with multiplier
gender$multiplier<- as.numeric(gender$multiplier)

gender <-
  gender %>%
  mutate(value_with_correction = value * multiplier) %>%
  mutate(value_normalized_with_correction = value_normalized * multiplier)

#Convert to numeric all division variables
x <- 11:26
gender[x] <- lapply(gender[x], as.numeric) 


#change as required
#setwd ("C:/Users/andreinav/OneDrive - Inter-American Development Bank Group/Dashboard/Dashboard Coding/WBD")

#optional save data
#write.csv(gender, "gender_final.csv", row.names = FALSE)



############################################
#                                          #
#                JOIN DATA                 #
#                                          #
############################################

data <- gender %>%
        bind_rows (findex) 

install.packages("countrycode")
library(countrycode)

#change iso 2 character to iso3 character coding for merging
data$iso <- countrycode (data$iso, "iso2c", "iso3c", warn = FALSE)


data <- data %>%
  select(-sourceID, -source, -indicatorDesc, -indicatorID)

write.csv(data, "/data/data_final.csv", row.names = FALSE)

}