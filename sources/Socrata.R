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
#             SOCRATA Data                 #
#                                          #
############################################


socrata <- function(){
 

install.packages ("RSocrata")
library(RSocrata)
library(dplyr)


############################################
#                                          #
#           Download the data through API  #
#                                          #  
#                                          #
############################################


# Download private dataset
socrataEmail <- Sys.getenv("SOCRATA_EMAIL", SOCRATA_EMAIL)
socrataPassword <- Sys.getenv("SOCRATA_PASSWORD", SOCRATA_PASSWORD)
privateResourceToReadCsvUrl <- "https://mydata.iadb.org/Gender/Numbers-for-Development-Gender-Indicators/u5nc-wtuz" # dataset

df <- read.socrata(url = privateResourceToReadCsvUrl, email = socrataEmail, password = socrataPassword)


############################################
#                                          #
#               Transform data             #
#                                          #  
#                                          #
############################################
install.packages("R.utils")
library(R.utils)

#convert to lower case the varible names
names(df)<- tolower(names(df))


#convert to lower case country variable
df$country <- tolower(df$country)
df$country <- capitalize(df$country)


############################################
#                                          #
#            Clean appended data           #
#                                          #
############################################

#remove indicators that have NAs in value variable
df <- df[!is.na(df$value),]


############################################
#                                          #
#            Create multiplier and         # 
#               division variables         #
#                                          #
############################################

#Create multiplier variable (1 is neutral, -1 is interpreted negative)
IDB<-df %>% 
  mutate (multiplier = ifelse(grepl ('outstanding|informal|death|mort|drop|HIV|viol|disor| vulnerable| fertility|unimpro|disea',indicator), -1, 1) %>% as.character())

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


#Create division categories using patters from lists created above
IDB <-IDB %>% 
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



############################################
#                                          #
#             Create type                  #
#               variables                  #
#                                          #
############################################

findex <- findex %>% mutate (type = ifelse (grepl ("female", indicator), "female", ifelse (grepl ("male",indicator),"male", ifelse (grepl("total",indicator),"total", ifelse (grepl("urban",indicator), "urban", ifelse (grepl("rural",indicator), "rural", "other")) %>% as.character()))))



############################################
#                                          #
#           Normalization and adjustment   #
#                with multiplier           #  
#                                          #
############################################

#convert to numeric
IDB$value <- as.numeric(IDB$value)

#normalize indexing
indicator_names <- names(table(IDB$indicator))
IDB$value_normalized <- NA

for(i in indicator_names){
  
  selection <- which(IDB$indicator %in% i)
  IDB$value_normalized[selection] <- scale(IDB$value[selection])
  
}

#adjust with multiplier
IDB$multiplier<- as.numeric(IDB$multiplier)

IDB <-
  IDB %>%
  mutate(value_with_correction = value * multiplier) %>%
  mutate(value_normalized_with_correction = value_normalized * multiplier)

#Convert to numeric all division variables
x <- 6:21
IDB[x] <- lapply(IDB[x], as.numeric) 

#Add source variable

IDB <- IDB %>%
  mutate (sourceOrg = "IDB")


rm(df)

write.csv(IDB, '/data/socrata.csv', row.names = FALSE) 
}
