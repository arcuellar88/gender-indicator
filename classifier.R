#Load the lists with terms by division
division<-read.csv("./data/terms.csv", header=TRUE)

#Create list of divisions
div<-unique(division$division)

#Create the funcion to identify the divisions based on the terms and the name of the indicator
fDivision<-function(indicator){
  sapply(indicator, function(indicator){
    divValue<-""
    for(name in div){
      sel.division <- which(division$division %in% name)
      if (max(grepl(paste(division$term[sel.division], collapse="|"),indicator))==1) 
      { 
        divValue<-paste(name,divValue,sep=",")
      }
    }
    return(substr(divValue, 1, nchar(divValue)-1))
  })
  
}

############################################
#                                          #
#            Create multiplier             # 
#                                          #
#                                          #
############################################
classify <- function(df) {
  
  # get the number of columns in the data
  nCols <- length(names(df))
  
#Create multiplier variable (1 is neutral, -1 is interpreted negative)
df<-df %>% 
  mutate (multiplier = ifelse(grepl ('outstanding|informal|death|mort|drop|HIV|viol|disor| vulnerable| fertility|unimpro|disea',indicator), -1, 1) %>% as.character())

############################################
#                                          #
#            Create division               # 
#                                          #
#                                          #
############################################

#Create division using the fDivision function
df <- df %>% mutate(division=fDivision(indicator))

############################################
#                                          #
#             Create type                  #
#                                          #
#                                          #
############################################

df <- df %>% mutate (type = ifelse (grepl ("female", indicator), "female", ifelse (grepl ("male",indicator),"male", ifelse (grepl("total",indicator),"total", ifelse (grepl("urban",indicator), "urban", ifelse (grepl("rural",indicator), "rural", "other")) %>% as.character()))))

#Convert all variables to numeric , except the type
#x <- (nCols+1):(nCols+16) 
#df[x] <- lapply(df[x], as.numeric) 
  
  return(df)
}

