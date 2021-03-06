----------------------------------------------------------
-- Generate Reportin Table 
-----------------------------------------------------------
TRUNCATE TABLE GENDER_INDICATOR_TMP IMMEDIATE;
INSERT INTO GENDER_INDICATOR_TMP 
SELECT INDICATOR_ID,INDICATOR, PRIMARY, UOM, YEAR,ISO3, COUNTRY,REGION, IDB_REGION,SOURCE,SOURCE_GROUP, TOPIC, GENDER, AREA,AGE, QUINTIL as QUINTILE, EDUCATION, DIVISION, MULTIPLIER, 
 VALUE,VALUE_NORMALIZED,VALUE_NORMALIZED*MULTIPLIER,NR_COUNTRIES 
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
 NULL as DIVISION,
 MULTIPLIER,
 SUM(CASE WHEN Lower(indicator) not like '%female%' then value else NULL END ) as MALE,
 SUM(CASE WHEN Lower(indicator) like '%female%' then value else NULL END) as FEMALE,
 0.0 as gap
-- SUM(CASE WHEN Lower(indicator) like '%female%' then value else 0 END) / SUM(COALESCE(CASE WHEN Lower(indicator) not like '%female%' then value else NULL END,1)) as GAP
FROM
 GENDER_INDICATOR_TMP
 where
 GENDER in ('Male','Female')
 group by 
 country, year, topic,is_region,idb_region,source,source_group,area,MULTIPLIER,PRIMARY
  having count(*)=2);

--SELECT * FROM 
--GENDER_INDICATOR gi left JOIN GENDER_GAP gi.gp
--ON gi.YEAR=gp.YEAR and COUNTRY= gp.COUNTRY and PRIMARY=gp.INDICATOR;

-- Update GAP in GENDER_INDICATOR
update GENDER_GAP
	set VALUE_GAP=VALUE_FEMALE/VALUE_MALE
	where VALUE_MALE is not NULL and VALUE_MALE <>0;

TRUNCATE TABLE GENDER_INDICATOR IMMEDIATE;

INSERT INTO GENDER_INDICATOR("INDICATOR_ID","INDICATOR" ,"PRIMARY", "UOM","YEAR","ISO3","COUNTRY","IS_REGION","IDB_REGION",
		"SOURCE","SOURCE_GROUP","TOPIC","GENDER","AREA","AGE","QUINTILE","EDUCATION","DIVISION", 
		"MULTIPLIER","VALUE","VALUE_NORM","VALUE_NORM_CORRECTION","NR_COUNTRIES",
		"VALUE_MALE","VALUE_FEMALE","GAP")		
SELECT gi.*,
CASE WHEN gp.value_male is not NULL then gp.value_male WHEN GENDER='Male' THEN gi.VALUE ELSE NULL END,
CASE WHEN gp.value_female is not NULL then gp.value_female WHEN GENDER='Female' THEN gi.VALUE ELSE NULL END,
gp.VALUE_GAP 
from GENDER_INDICATOR_TMP AS gi
  LEFT JOIN GENDER_GAP AS gp
  ON gi.YEAR=gp.YEAR and gi.COUNTRY= gp.COUNTRY and gi.PRIMARY=gp.INDICATOR;