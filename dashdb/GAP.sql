-- GENDE_GAP
TRUNCATE TABLE GENDER_GAP IMMEDIATE;
 INSERT INTO GENDER_GAP
(SELECT
 PRIMARY as indicator,
 year,
 country, 
 is_region,
 idb_region,
 SOURCE,
 SOURCE_GROUP,
 TOPIC,
 AREA,
 DIVISION,
 MULTIPLIER,
 SUM(CASE WHEN Lower(indicator) not like '%female%' then value else NULL END ) as MALE,
 SUM(CASE WHEN Lower(indicator) like '%female%' then value else NULL END) as FEMALE,
 SUM(CASE WHEN Lower(indicator) like '%female%' then value else 0 END) / SUM(COALESCE(CASE WHEN Lower(indicator) not like '%female%' then value else NULL END ,1)) as GAP

FROM
 GENDER_INDICATOR
 where
 GENDER in ('Male','Female')
 group by country, year, topic,is_region,idb_region,source,source_group,area,MULTIPLIER,DIVISION,
 PRIMARY
 having count(*)=2);


--SELECT * FROM 
--GENDER_INDICATOR gi left JOIN GENDER_GAP gi.gp
--ON gi.YEAR=gp.YEAR and COUNTRY= gp.COUNTRY and PRIMARY=gp.INDICATOR;

-- Update GAP in GENDER_INDICATOR
MERGE INTO GENDER_INDICATOR gi
  USING (SELECT year,country, indicator, value_male, value_female, VALUE_GAP FROM GENDER_GAP) gp
  ON gi.YEAR=gp.YEAR and gi.COUNTRY= gp.COUNTRY and gi.PRIMARY=gp.INDICATOR
  WHEN MATCHED THEN
     UPDATE SET
        value_male = gp.value_male,
        value_female=gp.value_female,
        gap=gp.VALUE_GAP
  ELSE IGNORE;

