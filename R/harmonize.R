#################################
# Harmonize Datasets            #
#################################

#
#' Function to harmonize the data from the different sources. Create SRC tables for all the sources and the consolidated tables
#' METADATA_INDICATOR: Table with the metadata of all the indicators
#' STG_INDICATOR: Table with the data of all the indicators (ISO3, YEAR, YEAR VALUE, VALUE_NORMALIZED)
#' @param con connection to dashdb (con <- idaConnect("BLUDB", "", ""))
#' @return the results are computed directly in DashDB
#' @examples
#' harmonizeDashDB(con)
harmonizeDashDBFromFile <- function(con)
{
  sqlcommands<-readSQLCommands(paste0(DASHDB,"harmonize.sql"))
  runSQL(sqlcmdlist=sqlcommands,con=con)
}
