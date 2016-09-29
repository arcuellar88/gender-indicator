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
#            No Ceilings Data              #
#                                          #
#   Downloaded from www.noceilings.org     #
#   Set the folder where the data can      #
#    be found in the NCD_FOLDER variable   #
#    (config.R file)                       #
#                                          #
############################################

load.NCData <- function(outputFile){


#No ceiling data is an innitiative developed by the Clinton Foundation.
#This was a one time effort that gathered data from multiple sources.
#Information regarding renovating this effort is not yet defined.


############################################
#                                          #
#       Importing untransformed data      #
#                                          #
############################################
df <- NA

#setwd(NCD_FOLDER)

# Get file names
files <- list.files(paste0(NCD_FOLDER,'/csv')) 

#files <- list.files (paste (getwd(), '/csv', sep = ''), full.names = TRUE)

wd <- getwd()
setwd(paste0(NCD_FOLDER,'/csv'))

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
  
  #put in the appropriate structure (from wide to long form)
  temp <- gather(temp, year, value, 2:(length(names(temp))-1))
  
  #remove rows that have NAs in value variable
  temp <- temp[!is.na(temp$value),]
  
  #convert text "yes/no" rows into numeric 1/0 values  
  temp <- temp %>%
    mutate(value = ifelse(value=="yes","1",ifelse(value=="no","0",value)))
  
  #ensure that all data have numeric value
  temp$value <- as.numeric(temp$value)
  
  indicator_list[[i]] = temp   # adds indicator df to list
}

setwd(wd)

############################################
#                                          #
#       Append untsransformed data         #
#                                          #
############################################


# Collapses list with data frames into single dataframe (must have same variables - missing replaced with NAs)
full_data <- bind_rows(indicator_list) 

#free memory
rm(indicator_list)

# Remove csv extension from series names
full_data$series <- sub (".csv", "", full_data$series)


# Load country and indicator information to be joind into df

countries <- read.csv(paste0(NCD_FOLDER,'/countries.csv'), stringsAsFactors = FALSE)
indicators <- read.csv(paste0(NCD_FOLDER,'/indicators.csv'), stringsAsFactors = FALSE)
indicators <- select(indicators, theme, series, name, unit, source, tertiary) 



#Combine data with country names, indicator names and relevant variables
df <-
  full_data %>%
  rename(iso = ISO) %>%                           # rename ISO variables to iso - used for country join
  full_join(countries, by = 'iso') %>%            # join country data by "iso"
  rename(country = name) %>%                     # change country variable name - conflict with indicator variable "name"
  #filter(country %in% country_names) %>%       # select only IDB countries
  full_join (indicators, by = 'series') %>%     # join indicator data by "series"
  rename(indicator = name) # change "name" variable to "indicator"
  

rm(full_data)



############################################
#                                          #
#            Clean appended data           #
#                                          #
############################################

#remove x at begining of each year variable
df$year <- sub ("X", "", df$year)


#Note: tertiary is a complementary variable,
#      it being empty doesn't mean that the
#      indicator is not disaggregated
#df <- df %>% filter (!tertiary =="")

#remove indicators that have NAs in value variable
df <- df[!is.na(df$value),]



############################################
#                                          #
#  Adding unit and type information        #
#                                          #
############################################

df <- df %>%
  mutate(new_indicator = paste0(indicator, ' (', unit, ')') ) %>%
  select(-indicator) %>%
  rename(indicator=new_indicator)



######################################
# Filter WB data, as this will       #
# already be included by another     #
# function                           #
######################################
df <- df %>%
  mutate (duplicate = ifelse (grepl ('Global Findex|World Bank', source), 1, 0) %>% as.character())

df <- df %>%
  filter(duplicate==0) %>%
  select(-duplicate) 

#select only variables of interest for row bind
df <- df %>%
  select(-theme, -unit, -short_name, -series, -iso, -tertiary)

df <- df %>%
  mutate (sourceYear = NA) %>% #--- TODO -------------------
  mutate (isRegion = 0)


rm(countries, indicators, regions, temp)


#Ensure structure is correct

df$value <- as.numeric(df$value)         
df$indicator <- as.factor(df$indicator)
df$sourceYear <- as.numeric(df$sourceYear)



# If a filename was given, write result to the file
if (!is.null(outputFile) && !(outputFile==""))
  write.csv(df, file=outputFile, row.names = FALSE)

#return the final data frame
return(df)

}
