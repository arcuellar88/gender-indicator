#------------------------------------------#
#            CLASSIFY                      # 
#   Area, Gender, Quintil,                 #
#    Age, Education, Division              #
#------------------------------------------#


#' Classify the Metadata of the indicator in dashdb
#' Classify: GENDER (female, male), AREA(urban, rural), Education (primary,etc.), MUltiplier (1,-1) and Topic (Education, labor, etc.)
#' @param con The connection to dashdb
#' @return 
#' @examples
#' classifyDashDB(con)
classifyDashDBFromFile <- function(con)
{
  sqlcommands<-readSQLCommands(paste0(DASHDB,"classify.sql"))
  runSQL(sqlcmdlist=sqlcommands,con=con)
}


