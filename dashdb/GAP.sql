-- Example SQL queries that you can run against the sample data in dashDB.
TRUNCATE TABLE GENDER_GAP IMMEDIATE;
 INSERT INTO GENDER_GAP
(SELECT
 Replace(Lower(Replace(Lower(indicator),'female','')),'male','') as indicator,
 year,
 country, 
 is_region,
 idb_region,
 SOURCE,
 SOURCE_GROUP,
 TOPIC,
 AREA,
 DIVISION,
 gi."MULTIPlIER",
 SUM(CASE WHEN Lower(indicator) not like '%female%' then value else 0 END ) as MALE,
 SUM(CASE WHEN Lower(indicator) like '%female%' then value else 0 END) as FEMALE,
 SUM(CASE WHEN Lower(indicator) like '%female%' then value else 0 END - CASE WHEN Lower(indicator) not like '%female%' then value else 0 END ) as GAP

FROM
 GENDER_INDICATOR gi
 where
 GENDER in ('male','female')
 group by country, year, topic,is_region,idb_region,source,source_group,area,gi."MULTIPlIER",DIVISION,
 Replace(Lower(Replace(Lower(indicator),'female','')),'male','')
 having count(*)=2);