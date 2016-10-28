
#con <- idaConnect("BLUDB","","")
#idaInit(con)
#Load the lists with terms by division
#division<-read.csv("./data/terms.csv", header=TRUE)


#Create the funcion to identify the divisions based on the terms and the name of the indicator
fDivision<-function(indicator){
  sapply(indicator, function(indicator){
    divValue<-""
    for(name in div){
      sel.division <- which(division$DIVISION %in% name)
      if (max(grepl(paste(division$TERM[sel.division], collapse="|"),indicator))==1) 
      { 
        divValue<-paste(name,divValue,sep=",")
      }
    }
    return(substr(divValue, 1, nchar(divValue)-1))
  })
}
#------------------------------------------#
#            CLASSIFY                      # 
#   Area, Gender, Quintil,                 #
#    Age, Education, Division              #
#------------------------------------------#
classify <- function(df) {
  
  division <- idaQuery("SELECT * FROM DASH6851.TERMS",as.is=F)
  
  #Create list of divisions
  div<-unique(division$DIVISION)
  
  #------------------------------------------#
  #             GENDER                       #
  #------------------------------------------#
  df <- df %>% mutate (GENDER = ifelse(!is.na(GENDER),GENDER,ifelse (grepl ("female", INDICATOR), "female", ifelse (grepl("male",INDICATOR),"male", "other"))) %>% as.character())
  
  #------------------------------------------#
  #             AREA                         #
  #------------------------------------------#
  df <- df %>% mutate (AREA = ifelse(!is.na(AREA),AREA,ifelse (grepl ("urban", INDICATOR), "urban", ifelse (grepl("rural",INDICATOR),"rural", "other"))) %>% as.character())
  
  #------------------------------------------#
  #             AGE                      #
  #------------------------------------------#
  df <- df %>% mutate (AGE = ifelse(!is.na(AGE),AGE,"N/A")) 
  
  #------------------------------------------#
  #             QUINTIL                      #
  #------------------------------------------#
  df <- df %>% mutate (QUINTIL = ifelse(!is.na(QUINTIL),QUINTIL,"N/A"))
  
  #------------------------------------------#
  #             EDUCATION                    #
  #------------------------------------------#
  df <- df %>% mutate (EDUCATION = ifelse(!is.na(EDUCATION),EDUCATION,"N/A"))
  
  #------------------------------------------#
  #            Create DIVISION               # 
  #------------------------------------------#
  df <- df %>% mutate(DIVISION=fDivision(INDICATOR)  %>% as.character())
  
  #------------------------------------------#
  #             MULTIPLIER                   #        
  # 1 is neutral, -1 is interpreted negative #
  #------------------------------------------#
  df<-df %>% mutate (MULTIPLIER = ifelse(grepl ('outstanding|informal|death|mort|drop|HIV|viol|disor| vulnerable| fertility|unimpro|disea',INDICATOR), -1, 1) %>% as.integer())
  
  return(df)
}

