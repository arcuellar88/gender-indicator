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
harmonizeDashDB <-function(con) {
  
  #Initialize connection
  idaInit(con)
  
  #----------------------#
  #NCD METADATA_INDICATOR#
  #----------------------#
  idaQuery("truncate table NCD_SRC_METADATA_INDICATOR IMMEDIATE",as.is=F) 
  idaQuery("insert into NCD_SRC_METADATA_INDICATOR 
           select * from NCD_STG_METADATA_INDICATOR
           where source not like '%World%Bank%' and source not like '%Global%Findex%' 
           and (Lower(NAME) like '% girls %' 
           or Lower(NAME) like '% female%'
           or Lower(NAME) like 'female%'
           or Lower(NAME) like '% women%' 
           or Lower(NAME) like 'women %')",as.is=F) 
  
  
  #----------------------#
  #WB METADATA_INDICATOR #
  #----------------------#
  idaQuery("truncate table WB_SRC_METADATA_INDICATOR IMMEDIATE",as.is=F) 
  idaQuery("insert into WB_SRC_METADATA_INDICATOR select * from WB_STG_METADATA_INDICATOR",as.is=F) 
  
  
  #----------------------#
  #N4D METADATA_INDICATOR#
  #----------------------#
  idaQuery("truncate table N4D_SRC_METADATA_INDICATOR IMMEDIATE",as.is=F) 
  idaQuery("insert into N4D_SRC_METADATA_INDICATOR select * from N4D_STG_METADATA_INDICATOR",as.is=F) 
  
 
  #----------------------#
  #NCD SRC_INDICATOR-----#
  #----------------------#
  idaQuery("TRUNCATE TABLE NCD_SRC_INDICATOR IMMEDIATE",as.is=F) 
  idaQuery("insert into NCD_SRC_INDICATOR
          select iso3,INDICATOR_ID,YEAR, value from NCD_STG_INDICATOR
          where INDICATOR_ID in (select INDICATOR_ID from NCD_SRC_METADATA_INDICATOR)",as.is=F) 
  
  #----------------------#
  #-WB SRC_INDICATOR-----#
  #----------------------#
  idaQuery("TRUNCATE TABLE WB_SRC_INDICATOR IMMEDIATE",as.is=F) 
  idaQuery("insert into WB_SRC_INDICATOR select iso2,INDICATOR_ID,YEAR, value from WB_STG_INDICATOR",as.is=F) 
  
  
  #----------------------#
  #N4D SRC_INDICATOR-----#
  #----------------------#
  idaQuery("TRUNCATE TABLE N4D_SRC_INDICATOR IMMEDIATE",as.is=F) 
  idaQuery("insert into N4D_SRC_INDICATOR select * from N4D_STG_INDICATOR",as.is=F) 
  

  #----------------------#
  #SRC_METADATA_INDICATOR#
  #----------------------#  
  idaQuery("TRUNCATE table SRC_METADATA_INDICATOR IMMEDIATE",as.is=F) 
  idaQuery("ALTER TABLE SRC_METADATA_INDICATOR ALTER COLUMN INDICATOR_ID RESTART WITH 1")
  
  #NCD
  idaQuery("INSERT INTO SRC_METADATA_INDICATOR (SOURCE_ID, SOURCE, SOURCE_GROUP, TOPIC, INDICATOR, PRIMARY, UOM, INDICATOR_DESC)
            SELECT  INDICATOR_ID,  SOURCE, 'NCD', TOPIC, INDICATOR, 
            Replace(Lower(Replace(Lower(INDICATOR),'female','')),'male',''), UOM, INDICATOR_DESC
            FROM NCD_SRC_METADATA_INDICATOR",as.is=F) 
  
  #WB
  idaQuery("INSERT INTO SRC_METADATA_INDICATOR (SOURCE_ID, SOURCE,SOURCE_GROUP, INDICATOR, PRIMARY, INDICATOR_DESC)
            SELECT  f.INDICATOR_ID,SOURCE_ORG,'WB/Findex', f.INDICATOR, 
            Replace(Lower(Replace(Lower(F.INDICATOR),'female','')),'male','') as PRIMARY, f.INDICATOR_DESC
            FROM WB_SRC_METADATA_INDICATOR f",as.is=F) 
  
  #IDB
  idaQuery("INSERT INTO SRC_METADATA_INDICATOR (SOURCE_ID, INDICATOR, INDICATOR_DESC, GENDER,QUINTIL, AREA, AGE, EDUCATION, TOPIC, SOURCE,PRIMARY, SOURCE_GROUP)
            SELECT *, Replace(Lower(Replace(Lower(INDICATOR),'female','')),'male',''), 'Inter-American Development Bank (IDB)'
            from N4D_SRC_METADATA_INDICATOR") 
  
  #----------------------#
  #-----STG_INDICATOR----#
  #----------------------#  
 
  idaQuery("TRUNCATE STG_INDICATOR IMMEDIATE") 

  #NCD
  idaQuery("INSERT INTO STG_INDICATOR
            select  ncd.ISO3 , md.INDICATOR_ID, ncd.year, ncd.value
            from
            NCD_SRC_INDICATOR ncd left join 
            SRC_METADATA_INDICATOR md
            on
            ncd.INDICATOR_ID=md.SOURCE_ID
            where source_group='NCD' and VALUE is not null
            and ncd.iso3 in (select ISO_CD3 from IDB_COUNTRY)") 
  
  #WB
  idaQuery("INSERT INTO STG_INDICATOR
            select  co.ISO_CD3 , md.INDICATOR_ID, wb.year, wb.value
            from
            WB_SRC_INDICATOR wb left join 
            SRC_METADATA_INDICATOR md
            on
            wb.INDICATOR_ID=md.SOURCE_ID
            left join IDB_COUNTRY co
            on wb.iso2=co.iso_cd2
            where source_group='WB/Findex' and VALUE is not null") 
  
  #N4D
  idaQuery("INSERT INTO STG_INDICATOR
            select  n4d.ISO3 , md.INDICATOR_ID, n4d.year, n4d.value
            from
            N4D_SRC_INDICATOR n4d left join 
            SRC_METADATA_INDICATOR md
            on
            n4d.INDICATOR_ID=md.SOURCE_ID
            where source_group not in ('NCD', 'WB/Findex') and VALUE is not null;") 
  
  #Insert IDB REGIONS
  idaQuery("insert into STG_INDICATOR (ISO3, INDICATOR_ID, VALUE, YEAR)
            select reg.ISO_CD3, INDICATOR_ID, AVG(VALUE) as value, year 
              from STG_INDICATOR 
              JOIN idb_country con on ISO3=con.ISO_CD3 
              JOIN idb_country reg on con.IDB_REGION=reg.COUNTRY
             where con.IDB_REGION not like '%Not IDB%' 
             group by reg.ISO_CD3, INDICATOR_ID, year") 
  
  #Insert IDB
  
  idaQuery("insert into STG_INDICATOR (ISO3, INDICATOR_ID, VALUE, YEAR)
               select 'IBA', INDICATOR_ID, AVG(VALUE) as value, year 
                 from STG_INDICATOR 
                 JOIN idb_country con on ISO3=con.ISO_CD3 
                where con.IDB_REGION not like '%Not IDB%' 
                group by INDICATOR_ID, year")
  #ALL YEARS
  idaQuery("insert into STG_INDICATOR (ISO3, INDICATOR_ID, VALUE, YEAR)
            select ISO3, INDICATOR_ID, AVG(VALUE) as value, 'ALL' as year 
               from STG_INDICATOR JOIN idb_country on ISO3=ISO_CD3 
             group by ISO3, INDICATOR_ID") 
  
}
