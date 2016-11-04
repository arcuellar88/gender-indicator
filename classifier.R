
#con <- idaConnect("BLUDB","","")
#idaInit(con)

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
  
  #division<-read.csv("./data/terms.csv", header=TRUE)
  
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
  #df<-df %>% mutate (MULTIPLIER = ifelse(!is.na(MULTIPLIER),MULTIPLIER,ifelse(grepl ('outstanding|informal|death|mort|drop|HIV|viol|disor| vulnerable| fertility|unimpro|disea',INDICATOR), -1, 1 %>% as.integer())
  
  return(df)
}

classifyDashDB <- function(con)
{
 
  idaInit(con)
  #Load the lists with terms by division
  #division <- idaQuery("SELECT * FROM DASH6851.TERMS",as.is=F)
  
  #Gender
  
  try(idaQuery("update METADATA_INDICATOR 
  set GENDER='female'
  where (Lower(indicator) like '% female' or Lower(indicator) like '% women in%')",as.is=F))
  
  try(idaQuery("update METADATA_INDICATOR 
  set GENDER='male'
  where (GENDER is null or GENDER='other') and (Lower(indicator) like '% male' or Lower(indicator) like '% men in%')",as.is=F))
  
  try(idaQuery("update METADATA_INDICATOR 
  set GENDER='total'
  where (GENDER is null or GENDER='other') and Lower(indicator) like '% total'",as.is=F))
  
  
  #Area
  try(idaQuery("update SRC_METADATA_INDICATOR 
  set AREA='rural'
  where Lower(indicator) like '% rural'",as.is=F))
  
  try(idaQuery("update SRC_METADATA_INDICATOR 
  set AREA='urban'
  where AREA is null and Lower(indicator) like '% urban'",as.is=F))
  
  try(idaQuery("update SRC_METADATA_INDICATOR 
  set AREA='total'
  where AREA is null and Lower(indicator) like '% total'",as.is=F))
  
  #Multiplier
  try(idaQuery("update SRC_METADATA_INDICATOR
  set MULTIPLIER=-1
  WHERE REGEXP_LIKE(PRIMARY,'outstanding|informal|death|mort|drop|HIV|viol|disor| vulnerable| fertility|unimpro|disea','i')",as.is=F))
  
  try(idaQuery("update SRC_METADATA_INDICATOR
  set MULTIPLIER=1
  WHERE MULTIPLIER IS NULL",as.is=F))
  
  #DIVISION
  try(idaQuery("update SRC_METADATA_INDICATOR m
  set DIVISION=(SELECT cast(listagg(DIVISION, ', ') as varchar(100)) FROM TERMS_DIV WHERE REGEXP_LIKE( Lower(m.PRIMARY),terms,'i'))
  where DIVISION IS NULL;
  "))
  
  # Load the metadata table from dashdb
  #mData <- idaQuery("SELECT * FROM DASH6851.SRC_METADATA_INDICATOR",as.is=F)
  
  #classify metadata
  #mDataC <- classify(mData)
  
  #sqlUpdate(con, mDataC, "SRC_METADATA_INDICATOR", fast = TRUE)
      
}

