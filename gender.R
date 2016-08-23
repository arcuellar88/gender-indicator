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
#             MERGE ALL DATA               #
#                                          #
############################################

#run code/function for each source

#source("sources/socrata.r")
#source("sources/"NCD.r") 
#source("sources/"WB.r") 

############################################
#                                          #
#                MUTATE DATA               #
#                                          #
############################################

#merge data (WB and FINDEX combined) with NCD data
combined <- data %>%
  bind_rows(NCD) %>% 
  select(-iso)

#merge data with Socrata data

combined<- combined %>%
  bind_rows(NCD)


############################################
#                                          #
#          filtering duplicates            #
#                                          #
############################################

combined <- combined %>%
  mutate(country = as.character(country))

combined $country[combined $country=="Dominica"] <- "Dominican Republic"

combined $country[combined $country=="Congo, Rep."] <- "Congo, Dem. Rep."

combined $country[combined $country=="United States"] <- "United States of America"

combined $country[combined $country=="Yemen, Rep."] <- "Yemen"

combined $country[combined $country=="Trinidad and Tobago "] <- "Trinidad & Tobago"

combined $country[combined $country=="Syrian Arab Republic"] <- "Syria"

combined $country[combined $country=="St. Kitts and Nevis"] <- "St. Kitts & Nevis"

combined $country[combined $country=="Macedonia, FYR"] <- "Macedonia"

combined $country[combined $country== "Lao PDR"] <- "Laos"

combined $country[combined $country== "Korea, Dem. Rep."] <- "Korea, Rep."

combined $country[combined $country=="Iran, Islamic Rep."] <- "Iran"

combined $country[combined $country=="Gambia, The"] <- "Gambia"

combined $country[combined $country=="Bosnia and Herzegovina"] <- "Bosnia & Herzegovina"

combined $country[combined $country=="Bahamas, The"] <- "Bahamas"

combined $country[combined $country=="Antigua and Barbuda"] <- "Antigua & Barbuda"

############################################
#                                          #
#          ADD REGIONAL INFORMATION        #
#                                          #
############################################

#create and append region infomation

#create region filter
region<- c ('CSC',
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
region <- data.frame(region, country)

#append region information
combined <- combined %>%
  full_join (region, by="country")

setwd("D:/OneDrive - Inter-American Development Bank Group/Dashboard/Dashboard Coding/final")

write.csv(combined, "combined_final.csv", row.names = FALSE)


