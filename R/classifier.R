#------------------------------------------#
#            CLASSIFY                      # 
#   Area, Gender, Quintil,                 #
#    Age, Education, Division              #
#------------------------------------------#


#' Auxiliary function to classify the DIVISION of the indicator
#' Identify the divisions based on the terms and the name of the indicator
#' DIVISION (WSA, ENE, TSP, etc. )
#' @param indicator is a dataframe of indicators
#' @return data frame with an additional column for the DIVISION (WSA, ENE, TSP, etc. 
#' @examples
#' fDivision(indicator)
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

#' Classify the metadata of the indicator from a data frame
#' Classify: GENDER (female, male), AREA(urban, rural), Education (primary,etc.), MUltiplier (1,-1) and Topic (Education, labor, etc.)
#' @param con The connection to dashdb
#' @return 
#' @examples
#' classify(df)
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

#' Classify the Metadata of the indicator in dashdb
#' Classify: GENDER (female, male), AREA(urban, rural), Education (primary,etc.), MUltiplier (1,-1) and Topic (Education, labor, etc.)
#' @param con The connection to dashdb
#' @return 
#' @examples
#' classifyDashDB(con)
classifyDashDB <- function(con)
{
 
  idaInit(con)
  #Load the lists with terms by division
  #division <- idaQuery("SELECT * FROM DASH6851.TERMS",as.is=F)
  
  #GENDER
  try(idaQuery("update SRC_METADATA_INDICATOR 
    set GENDER='Female'
    where (Lower(indicator) like '% girls %' 
    or Lower(indicator) like '% female%'
    or Lower(indicator) like 'female%'
    or Lower(indicator) like '% women%' 
    or Lower(indicator) like 'women %');",as.is=F))
  
  try(idaQuery("update SRC_METADATA_INDICATOR 
    set GENDER='Male'
    where (GENDER is null or GENDER='other') 
    and (Lower(indicator) like '% male%' or Lower(indicator) like '% men%)",as.is=F))
  
  
  #AREA
  try(idaQuery("update SRC_METADATA_INDICATOR 
  set AREA='Rural'
  where Lower(indicator) like '% rural%'",as.is=F))
  
  try(idaQuery("update SRC_METADATA_INDICATOR 
  set AREA='Urban'
  where AREA is null and Lower(indicator) like '% urban%'",as.is=F))
  
  try(idaQuery("update SRC_METADATA_INDICATOR 
                set AREA='Total'
                where AREA is null and Lower(indicator) like '% total%'",as.is=F))
  
  try(idaQuery("update SRC_METADATA_INDICATOR 
                set AREA='Other'
                where AREA is null")
                
  #MULTIPLIER
  try(idaQuery("update SRC_METADATA_INDICATOR
      set MULTIPLIER=-1
      WHERE 
      REGEXP_LIKE(PRIMARY,'Year women obtained election|Press Freedom Index|VAW laws SIGI|Unmet need|unemployed|unemployment|Out of school|homicide|outstanding|informal|death|mort|drop|HIV|viol|disor| vulnerable| fertility|unimpro|disea|wife beating|working very long|DALYs|Forced first sex','i')",as.is=F))
  
  try(idaQuery("update SRC_METADATA_INDICATOR
  set MULTIPLIER=1
  WHERE MULTIPLIER IS NULL",as.is=F))
  
  #DIVISION
  try(idaQuery("update SRC_METADATA_INDICATOR m
  set DIVISION=(SELECT cast(listagg(DIVISION, ', ') as varchar(100)) FROM TERMS_DIV WHERE REGEXP_LIKE( Lower(m.PRIMARY),terms,'i'))
  where DIVISION IS NULL;
  "))
  
  #TOPIC
  try(idaQuery("update SRC_METADATA_INDICATOR
      set TOPIC='Economic Opportunities'
      where TOPIC is null and 
      (INDICATOR like '%Saved for%' 
      or INDICATOR like '%Saved any%' 
      or INDICATOR like '%Saved at%'
      or Lower(INDICATOR) like '%loan%'
      or INDICATOR like '%send money%'
      or INDICATOR like '%Debit card%'
      or INDICATOR like '%Credit card%' 
      or INDICATOR like '%emergency funds%'
      or INDICATOR like '%Borrowed from%' 
      or INDICATOR like '%financial institution%'
      or INDICATOR like '%make payments%'
      or INDICATOR like '%Account%'
      or INDICATOR like '%Saved using%'
      or INDICATOR like '%pay%bills%'
      or INDICATOR like '%Paid%bills%'
      or INDICATOR like '%Paid%fees%'
      or INDICATOR like '%paid%for%'
      or INDICATOR like '%pay%fees%'
      or INDICATOR like '%receive money%'
      or INDICATOR like '%Saved to start%'
      or INDICATOR like '%Borrowed%'
      or INDICATOR like '%Received%payments%'
      or INDICATOR like '%Received%remittances%'
      or INDICATOR like '%Received%wages%'
      or INDICATOR like '%Received%transfers%'
      or INDICATOR like '%Sent%remittances%'
      or INDICATOR like '%Used an account%'
      or INDICATOR like '%mortgage%'
      )"))   
  
    try(idaQuery("update SRC_METADATA_INDICATOR set TOPIC='Other' where TOPIC is null"))
}

