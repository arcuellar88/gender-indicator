
############################################
#                                          #
#            Clean appended data           #
#                                          #
############################################

#remove indicators that have NAs in value variable
df <- df[!is.na(df$value),]


IDB <- df

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
  # mutate(value_with_correction = value * multiplier) %>%
  mutate(value_normalized_with_correction = value_normalized * multiplier)




