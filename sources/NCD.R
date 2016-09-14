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
#       NO CEILING DATA                    #
#                                          #
############################################

#No ceiling data is an innitiative developed by the Clinton Foundation.
#This was a one time effort that gathered data from multiple sources. #Information regarding renovating this effort is not yet defined.
#data was downloaded from a space in Github: r55555555555555555555555ilj5
[]

NCD <- function(){

#load libraries and packages
#install.packages("stringr")
#install.packages("dplyr")
#install.packages("dplyr")
#install.packages("stringr")
#library(dplyr)
#library(tidyr)





############################################
#                                          #
#       Importing untransformed data      #
#                                          #
############################################
NCD <- NA
#set working directory to csv files in host computer (change if required)
#setwd("")
setwd(NCD_FOLDER)
# Get file names and vector with ro be used for object names
files <- list.files(getwd()) 

#files <- list.files (paste (getwd(), '/csv', sep = ''), full.names = TRUE)



# LOOP to create dataframes from all csv files
indicator_list <- list()
for(i in 1:length(files)){
  
  f = readLines(files[i])                           # used for counts
  temp = read.csv(files[i], nrows = length(f) - 7)  # removes the last 7 lines of csv
  temp$series = rep(files[i], nrow(temp)) # creates a variable with the indicator name
  #df_name = paste('IND-', 1, sep = '')
  #assign(df_name, temp)
  #expression <- parse(text = names[i]) # results in: expression(AllstarFull)
  #print(eval(expression))
  indicator_list[[i]] = temp   # adds indicator df to list
}



############################################
#                                          #
#       Append untsransformed data         #
#                                          #
############################################


# Collapses list with data frames into single dataframe (must have same variables - missing replaced with NAs)
full_data <- bind_rows(indicator_list) 

# Remove csv from series to allow
full_data$series <- sub (".csv", "", full_data$series)


# Load country and indicator information to be joind into df
setwd("D:\\Consultorias\\BID 2016-2017\\Text Analytics\\SPD\\noceilings-data")

countries <- read.csv('countries.csv', stringsAsFactors = FALSE)
indicators <- read.csv('indicators.csv', stringsAsFactors = FALSE)
indicators <- select(indicators, theme, series, name, unit, source, tertiary) 

#create region filter
regions<- c ('CSC',
                   'CCB',
                   'CCB',
                   'CID',
                   'CAN',
                   'CSC',
                   'CSC',
                   'CAN',
                   'CID',
                   'CID',
                   'CAN',
                   'CID',
                   'CID',
                   'CCB',
                   'CDH',
                   'CID',
                   'CCB',
                   'CID',
                   'CID',
                   'CID',
                   'CSC',
                   'CAN',
                   'CCB',
                   'CCB',
                   'CSC',
                   'CAN')

#Create BDI countries
country<- c('Argentina',
                   'Bahamas',
                   'Barbados',
                   'Belize',
                   'Bolivia',
                   'Brazil',
                   'Chile',
                   'Colombia',
                   'Costa Rica',
                   'Dominican Republic',
                   'Ecuador',
                   'El Salvador',
                   'Guatemala',
                   'Guyana',
                   'Haiti',
                   'Honduras',
                   'Jamaica',
                   'Mexico',
                   'Nicaragua',
                   'Panama',
                   'Paraguay',
                   'Peru',
                   'Suriname',
                   'Trinidad & Tobago',
                   'Uruguay',
                   'Venezuela')

#Create BID country and region filter
regions <- data.frame(regions, country)


#LOOP: Combine data with master country, indicator name and relevant variables
NCD <-
  full_data %>%
  rename(iso = ISO) %>%                           # rename ISO variables to iso - used for country join
  full_join(countries, by = 'iso') %>%            # join country data by "iso"
  rename(country = name) %>%                     # change country variable name - conflict with indicator variable "name"
  #filter(country %in% country_names) %>%       # select only IDB countries
  full_join (indicators, by = 'series') %>%     # join indicator data by "series"
  rename(indicator = name) %>% # select necessary variables
  gather(year, value, X1995:X2014)           #change years depending on                                                     what was downloaded each                                                               year(X1995:X2015)





############################################
#                                          #
#            Clean appended data           #
#                                          #
############################################

#remove x at begining of each year variable
NCD$year <- sub ("X", "", NCD$year)


#remove non-disagregated variables and keep male/female/total/rural/urban/ratio
NCD <- NCD %>% filter (!tertiary =="")

#remove indicators that have NAs in value variable
NCD <- NCD[!is.na(NCD$value),]




############################################
#                                          #
#            Create multiplier and         # 
#               division variables         #
#                                          #
############################################


#Create multiplier variable (1 is neutral, -1 is interpreted negative)
NCD<-NCD %>% 
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
NCD <-NCD %>% 
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
#           Adding unit information        #
#                                          #
############################################

NCD <- NCD %>%
  mutate(new_indicator = paste(indicator, ' (', unit, ')', sep = '') ) %>%
  select(-indicator) %>%
  rename(indicator=new_indicator)


############################################
#                                          #
#           Normalization and adjustment   #
#                with multiplier           #  
#                                          #
############################################

#convert to numeric
NCD$value <- as.numeric(NCD$value)

#normalize indexing
indicator_names <- names(table(NCD$indicator))
NCD$value_normalized <- NA

for(i in indicator_names){
  
  selection <- which(NCD$indicator %in% i)
  NCD$value_normalized[selection] <- scale(NCD$value[selection])
  
}

#adjust with multiplier
NCD$multiplier<- as.numeric(NCD$multiplier)

NCD <-
  NCD %>%
  mutate(value_with_correction = value * multiplier) %>%
  mutate(value_normalized_with_correction = value_normalized * multiplier)

#Convert to numeric all division variables
x <- 10:24
NCD[x] <- lapply(NCD[x], as.numeric) 

#filter out WB data

NCD <- NCD %>%
  mutate (duplicate = ifelse (grepl ('Global Findex|World Bank', source), 1, 0) %>% as.character())

NCD <- NCD %>%
  filter(duplicate==0) %>%
  select(-duplicate) 

#select only variables of interest for row bind
NCD <- NCD %>%
  select(-theme, -unit) %>%
  rename(type=tertiary) %>%
  rename(sourceOrg=source)

NCD$year<- as.numeric(NCD$year)



rm(full_data, countries, indicators, regions, temp)

#Save data into CSV file
write.csv(NCD, '/data/NCD2.csv', row.names = FALSE)

}
