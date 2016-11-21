

-----------------------------------------------------------
-- SRC METADATA_INDICATOR
-----------------------------------------------------------

--NCD_SRC_METADATA_INDICATOR
truncate table NCD_SRC_METADATA_INDICATOR IMMEDIATE;

insert into NCD_SRC_METADATA_INDICATOR
select * from NCD_STG_METADATA_INDICATOR
where source not like '%World%Bank%' and source not like '%Global%Findex%';

------------------------------------------------------------

-- WB_SRC_METADATA_INDICATOR
truncate table WB_SRC_METADATA_INDICATOR IMMEDIATE;

insert into WB_SRC_METADATA_INDICATOR
select * from WB_STG_METADATA_INDICATOR;
------------------------------------------------------------

-- N4D METADATA_INDICATOR
--update N4D_STG_METADATA_INDICATOR
--set GENDER = Lower(GENDER), QUINTILE=Lower(QUINTILE), AREA=LOWER(AREA), AGE=LOWER(AGE), EDUCATION=LOWER(EDUCATION);

truncate table N4D_SRC_METADATA_INDICATOR IMMEDIATE;

insert into N4D_SRC_METADATA_INDICATOR
select * from N4D_STG_METADATA_INDICATOR;
------------------------------------------------------------

-----------------------------------------------------------
-- METADATA_INDICATOR
-----------------------------------------------------------
TRUNCATE table SRC_METADATA_INDICATOR IMMEDIATE;
ALTER TABLE SRC_METADATA_INDICATOR ALTER COLUMN INDICATOR_ID RESTART WITH 1;

-- NDC
INSERT INTO SRC_METADATA_INDICATOR (SOURCE_ID, SOURCE, SOURCE_GROUP, TOPIC, INDICATOR, PRIMARY, UOM, INDICATOR_DESC)
SELECT  INDICATOR_ID,  SOURCE, 'NCD', TOPIC, INDICATOR, TRIM(CONCAT(PRIMARY,CONCAT(' ', COALESCE(SECONDARY,'')))), UOM, INDICATOR_DESC
FROM NCD_SRC_METADATA_INDICATOR;

-- WB
INSERT INTO SRC_METADATA_INDICATOR (SOURCE_ID, SOURCE,SOURCE_GROUP, INDICATOR, PRIMARY, INDICATOR_DESC)
SELECT  f.INDICATOR_ID,SOURCE_ORG,'WB/Findex', f."INDICATOR",substr(f."INDICATOR",1,locate(',',f."INDICATOR")-1) as PRIMARY, f.INDICATOR_DESC
FROM WB_SRC_METADATA_INDICATOR f;

-- N4D
INSERT INTO SRC_METADATA_INDICATOR (SOURCE_ID, INDICATOR, INDICATOR_DESC, GENDER,QUINTIL, AREA, AGE, EDUCATION, TOPIC, SOURCE,PRIMARY, SOURCE_GROUP)
select *, substr(INDICATOR,1,locate(',',INDICATOR)-1), 'Inter-American Development Bank (IDB)'
 from N4D_SRC_METADATA_INDICATOR;
 
 
-----------------------------------------------------------
-- Classification
-----------------------------------------------------------
 --see classify.sql

-----------------------------------------------------------
-- SRC INDICATOR DATA
-----------------------------------------------------------

-- NCD_SRC_INDICATOR DATA--------------------------------
TRUNCATE TABLE NCD_SRC_INDICATOR IMMEDIATE;

insert into NCD_SRC_INDICATOR
select iso3,INDICATOR_ID,YEAR, value from NCD_STG_INDICATOR
where INDICATOR_ID in (select INDICATOR_ID from NCD_SRC_METADATA_INDICATOR);
---------------------------------------------------------

-- WB_SRC_INDICATOR------------------------------------
TRUNCATE TABLE WB_SRC_INDICATOR IMMEDIATE;

insert into WB_SRC_INDICATOR
select iso2,INDICATOR_ID,YEAR, value from WB_STG_INDICATOR;
---------------------------------------------------------

-- N4D_SRC_INDICATOR------------------------------------
TRUNCATE TABLE N4D_SRC_INDICATOR IMMEDIATE;

insert into N4D_SRC_INDICATOR
select * from N4D_STG_INDICATOR;
---------------------------------------------------------

-- STG_INDICATOR------------------------------------
TRUNCATE STG_INDICATOR IMMEDIATE;

--INSERT WB-----------------------------------------
INSERT INTO STG_INDICATOR
select  co.ISO_CD3 , md.INDICATOR_ID, wb.year, wb.value
from
WB_SRC_INDICATOR wb left join 
SRC_METADATA_INDICATOR md
on
wb.INDICATOR_ID=md.SOURCE_ID
left join IDB_COUNTRY co
on wb.iso2=co.iso_cd2
where source_group='WB/Findex' and VALUE is not null;

--INSERT NCD-----------------------------------------
INSERT INTO STG_INDICATOR
select  ncd.ISO3 , md.INDICATOR_ID, ncd.year, ncd.value
from
NCD_SRC_INDICATOR ncd left join 
SRC_METADATA_INDICATOR md
on
ncd.INDICATOR_ID=md.SOURCE_ID
where source_group='NCD' and VALUE is not null
and ncd.iso3 in (select ISO_CD3 from IDB_COUNTRY);

--INSERT N4D-----------------------------------------
INSERT INTO STG_INDICATOR
select  n4d.ISO3 , md.INDICATOR_ID, n4d.year, n4d.value
from
N4D_SRC_INDICATOR n4d left join 
SRC_METADATA_INDICATOR md
on
n4d.INDICATOR_ID=md.SOURCE_ID
where source_group not in ('NCD', 'WB/Findex') and VALUE is not null;

--Insert ALL REGIONS
insert into STG_INDICATOR (ISO3, INDICATOR_ID, VALUE, YEAR)
select reg.ISO_CD3, INDICATOR_ID, AVG(VALUE) as value, year 
   from STG_INDICATOR 
   JOIN idb_country con on ISO3=con.ISO_CD3 
   JOIN idb_country reg on con.IDB_REGION=reg.COUNTRY
 where con.IDB_REGION not like '%Not IDB%' 
 group by reg.ISO_CD3, INDICATOR_ID, year;

 -- IDB
insert into STG_INDICATOR (ISO3, INDICATOR_ID, VALUE, YEAR)
select 'IBA', INDICATOR_ID, AVG(VALUE) as value, year 
   from STG_INDICATOR 
   JOIN idb_country con on ISO3=con.ISO_CD3 
 where con.IDB_REGION not like '%Not IDB%' 
 group by INDICATOR_ID, year;


--Insert ALL YEARS
insert into STG_INDICATOR (ISO3, INDICATOR_ID, VALUE, YEAR)
select ISO3, INDICATOR_ID, AVG(VALUE) as value, 'ALL' as year 
   from STG_INDICATOR JOIN idb_country on ISO3=ISO_CD3 
-- where REGION='no'
 group by ISO3, INDICATOR_ID;
 
-----------------------------------------------------------
-- Normalization
-----------------------------------------------------------
-- see normalization.sql

-----------------------------------------------------------
-- Generate Reportin Table 
-----------------------------------------------------------
TRUNCATE TABLE GENDER_INDICATOR IMMEDIATE;
INSERT INTO GENDER_INDICATOR
SELECT INDICATOR, PRIMARY, UOM, YEAR,ISO3, COUNTRY,REGION, IDB_REGION,SOURCE,SOURCE_GROUP, TOPIC, GENDER, AREA,AGE, QUINTIL as QUINTILE, EDUCATION, DIVISION, MULTIPLIER, 
 VALUE, VALUE_NORMALIZED,VALUE_NORMALIZED*MULTIPLIER 
FROM SRC_INDICATOR JOIN SRC_METADATA_INDICATOR using (INDICATOR_ID)
left join idb_country on ISO3=ISO_CD3;


