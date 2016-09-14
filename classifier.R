############################################
#                                          #
#            Create multiplier and         # 
#               division variables         #
#                                          #
############################################
classify <- function(df) {
  
  # get the number of columns in the data
  nCols <- length(names(df))
  
#Create multiplier variable (1 is neutral, -1 is interpreted negative)
df<-df %>% 
  mutate (multiplier = ifelse(grepl ('outstanding|informal|death|mort|drop|HIV|viol|disor| vulnerable| fertility|unimpro|disea',indicator), -1, 1) %>% as.character())

#Create the lists with terms by division
# TODO: load this from file(s)
SPH <- c("pregnancy", "death", "mortality", "fertility", "condom", "contracep", "birth", "antire", "immu", "survi", "lifetime", "child")
ICS_PM <- c("internet", "broadband", "services", "administration", "representation", "judiciary", "participant", "mobile", "right", "contract")
ICS_CS <- c("violence", "rob", "police", "inheritance", "beating", "peace", "rape", "ownership", "homecide", "headed", "military", "fertility", "judiciary")
LMK <- c("empl","pension","unempl", "training","vocational", "work", "unpaid", "smoking", "self")
CMF <- c("bank", "account", "check","financial", "contract", "business", "own-account")
EDU <- c("school", "literacy", "dropout", "education", "study")
FMM <- c("urban", "rural")
CCS <- c("journalist", "internet")
EXR <- c("internet", "commu", "journal")
CTI <- c("tech", "internet", "science", "broadband", "intellectual")
ENE <- c("energy", "fuel", "methane", "electric")
WSA <- c("water", "sanita", "well", "electricity", "fresh")
RND <- c("agri", "land", "rural", "protected")
TSP <- c("trans", "road", "construc", "infras")
HUD <- c("hous","urban")


#Create division categories using keywords above
df <- df %>% 
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

df <- df %>% mutate (type = ifelse (grepl ("female", indicator), "female", ifelse (grepl ("male",indicator),"male", ifelse (grepl("total",indicator),"total", ifelse (grepl("urban",indicator), "urban", ifelse (grepl("rural",indicator), "rural", "other")) %>% as.character()))))



#Convert all division variables to numeric 
x <- (nCols+1):(nCols+16) 
df[x] <- lapply(df[x], as.numeric) 
  
  return(df)
}

