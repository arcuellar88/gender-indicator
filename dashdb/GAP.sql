----------------------------------------------------------
-- Generate Reportin Table 
-----------------------------------------------------------
TRUNCATE TABLE GENDER_INDICATOR IMMEDIATE;
INSERT INTO GENDER_INDICATOR 
SELECT INDICATOR_ID,INDICATOR, PRIMARY, UOM, YEAR,ISO3, COUNTRY,REGION, IDB_REGION,SOURCE,SOURCE_GROUP, TOPIC, GENDER, AREA,AGE, QUINTIL as QUINTILE, EDUCATION, DIVISION, MULTIPLIER, 
 VALUE, NULL,NULL,NULL,VALUE_NORMALIZED,VALUE_NORMALIZED*MULTIPLIER 
FROM SRC_INDICATOR JOIN SRC_METADATA_INDICATOR using (INDICATOR_ID)
left join idb_country on ISO3=ISO_CD3;

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
 0.0 as gap
-- SUM(CASE WHEN Lower(indicator) like '%female%' then value else 0 END) / SUM(COALESCE(CASE WHEN Lower(indicator) not like '%female%' then value else NULL END,1)) as GAP
FROM
 GENDER_INDICATOR
 where
 GENDER in ('Male','Female')
 group by country, year, topic,is_region,idb_region,source,source_group,area,MULTIPLIER,DIVISION,
 PRIMARY
 having count(*)=2 );

--SELECT * FROM 
--GENDER_INDICATOR gi left JOIN GENDER_GAP gi.gp
--ON gi.YEAR=gp.YEAR and COUNTRY= gp.COUNTRY and PRIMARY=gp.INDICATOR;

-- Update GAP in GENDER_INDICATOR
update GENDER_GAP
	set VALUE_GAP=VALUE_FEMALE/VALUE_MALE
	where VALUE_MALE is not NULL and VALUE_MALE <>0;

MERGE INTO GENDER_INDICATOR AS gi
  USING GENDER_GAP AS gp
  ON gi.YEAR=gp.YEAR and gi.COUNTRY= gp.COUNTRY and gi.PRIMARY=gp.INDICATOR
  WHEN MATCHED THEN
     UPDATE SET
        value_male = gp.value_male,
        value_female=gp.value_female,
        gap=gp.VALUE_GAP;

update
 GENDER_INDICATOR 
  set VALUE_FEMALE=VALUE
where VALUE_FEMALE is null and VALUE_MALE is null and GENDER = 'Female';

update
 GENDER_INDICATOR 
  set VALUE_MALE=VALUE
where VALUE_FEMALE is null and VALUE_MALE is null and GENDER = 'Male';





