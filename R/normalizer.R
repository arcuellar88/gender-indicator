#' Function to compute the normalization of the value of the indicators by year in DashDB.
#' @param con connection to dashdb (con <- idaConnect("BLUDB", "", ""))
#' @return the results are computed directly in DashDB
#' @examples
#' computeScores(con)
computeScoresDashDBFromFile <- function(con)
{
  sqlcommands<-readSQLCommands(paste0(DASHDB,"normalization.sql"))
  runSQL(sqlcmdlist=sqlcommands,con=con)
}