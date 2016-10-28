
-----------------------------------------------------------
-- NCD METADATA_INDICATOR
-----------------------------------------------------------
truncate table NCD_SRC_METADATA_INDICATOR IMMEDIATE;

insert into NCD_SRC_METADATA_INDICATOR
select * from NCD_STG_METADATA_INDICATOR;

-----------------------------------------------------------
-- WB METADATA_INDICATOR
-----------------------------------------------------------
truncate table WB_SRC_METADATA_INDICATOR IMMEDIATE;

insert into WB_SRC_METADATA_INDICATOR
select * from WB_STG_METADATA_INDICATOR;

-----------------------------------------------------------
-- N4D METADATA_INDICATOR
-----------------------------------------------------------
truncate table N4D_SRC_METADATA_INDICATOR IMMEDIATE;

insert into N4D_SRC_METADATA_INDICATOR
select * from N4D_STG_METADATA_INDICATOR;


-----------------------------------------------------------
-- WB INDICATOR DATA
-----------------------------------------------------------
TRUNCATE TABLE WB_SRC_INDICATOR;

insert into WB_SRC_INDICATOR
select iso2,INDICATOR_ID,YEAR, value from WB_STG_INDICATOR;

-----------------------------------------------------------
-- WB INDICATOR DATA
-----------------------------------------------------------
TRUNCATE TABLE N4D_SRC_INDICATOR IMMEDIATE;

insert into N4D_SRC_INDICATOR
select * from N4D_STG_INDICATOR;

-----------------------------------------------------------
-- METADATA_INDICATOR
-----------------------------------------------------------
TRUNCATE table METADATA_INDICATOR IMMEDIATE;

-- NDC
INSERT INTO METADATA_INDICATOR (SOURCE_ID, SOURCE, TOPIC, INDICATOR, PRIMARY, UOM, INDICATOR_DESC)
SELECT  INDICATOR_ID, 'NCD', TOPIC, INDICATOR, CONCAT(PRIMARY,  SECONDARY), UOM, INDICATOR_DESC
FROM NCD_SRC_METADATA_INDICATOR;

-- WB
INSERT INTO METADATA_INDICATOR (SOURCE_ID, SOURCE, INDICATOR, PRIMARY, INDICATOR_DESC)
SELECT  f.INDICATOR_ID, 'WB/Findex', f."INDICATOR",substr(f."INDICATOR",1,locate(',',f."INDICATOR")-1) as PRIMARY, f.INDICATOR_DESC
FROM WB_SRC_METADATA_INDICATOR f;

-- N4D
INSERT INTO METADATA_INDICATOR (SOURCE_ID, INDICATOR, INDICATOR_DESC, GENDER,QUINTIL, AREA, AGE, EDUCATION, TOPIC, SOURCE)
select *
 from N4D_SRC_METADATA_INDICATOR;
 
-----------------------------------------------------------
--INDICATOR DATA
-----------------------------------------------------------
--WB
INSERT INTO STG_INDICATOR
select  co.ISO_CD3 , md.INDICATOR_ID, wb.year, wb.value
from
WB_SRC_INDICATOR wb left join 
METADATA_INDICATOR md
on
wb.INDICATOR_ID=md.SOURCE_ID
left join IDB_COUNTRY co
on wb.iso2=co.iso_cd2
where source='WB/Findex';

--NCD
INSERT INTO STG_INDICATOR
select  ncd.ISO3 , md.INDICATOR_ID, ncd.year, ncd.value
from
NCD_SRC_INDICATOR ncd left join 
METADATA_INDICATOR md
on
ncd.INDICATOR_ID=md.SOURCE_ID
where source='NCD';

--N4D
INSERT INTO STG_INDICATOR
select  n4d.ISO3 , md.INDICATOR_ID, n4d.year, n4d.value
from
N4D_SRC_INDICATOR n4d left join 
METADATA_INDICATOR md
on
n4d.INDICATOR_ID=md.SOURCE_ID
where source not in ('NCD', 'WB/Findex');

TRUNCATE TABLE GENDER_INDICATOR;
INSERT INTO GENDER_INDICATOR
SELECT INDICATOR, PRIMARY, UOM, YEAR,COUNTRY,REGION,SOURCE, TOPIC, GENDER, AREA,AGE, QUINTIL as QUINTILE, EDUCATION, DIVISION, MULTIPLIER, 
 VALUE, VALUE_NORMALIZED,VALUE_NORMALIZED*MULTIPLIER 
FROM SRC_INDICATOR JOIN METADATA_INDICATOR using (INDICATOR_ID)
left join idb_country on ISO3=ISO_CD3;

