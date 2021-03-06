-----------------------------------------------------------
-- SRC METADATA_INDICATOR
-----------------------------------------------------------

--NCD_SRC_METADATA_INDICATOR
truncate table NCD_SRC_METADATA_INDICATOR IMMEDIATE;

insert into NCD_SRC_METADATA_INDICATOR
select * from NCD_STG_METADATA_INDICATOR
where (Lower("name") like '% girls %' 
 or Lower("name") like '% female%'
 or Lower("name") like 'female%'
 or Lower("name") like '% women%' 
 or Lower("name") like 'women%'
 or Lower("name") like '%gender%'
 or Lower("name") like  'vaw laws %'
 or Lower("name") like  '%male %'
 or Lower("name") like  '% male%'
 or Lower("name") like  '% maternity%'
 or Lower("name") like  '% paternity%'
 or Lower("name") like  '%domestic violence%'
 or Lower("name") like '%sexual harassment%'
 or Lower("name") like  '%mother%'
 or "name" like '%GPI%');
------------------------------------------------------------

-- WB_SRC_METADATA_INDICATOR
truncate table WB_SRC_METADATA_INDICATOR IMMEDIATE;

insert into WB_SRC_METADATA_INDICATOR
select * from WB_STG_METADATA_INDICATOR;
------------------------------------------------------------

-- N4D METADATA_INDICATOR
truncate table N4D_SRC_METADATA_INDICATOR IMMEDIATE;

insert into N4D_SRC_METADATA_INDICATOR
select n4d."IndicatorCode", n4d."IndicatorName", n4d."IndicatorShortDef", n4d."SubTopicName", n4d."DataSetName"
from N4D_STG_METADATA_INDICATOR n4d;
------------------------------------------------------------

-----------------------------------------------------------
-- METADATA_INDICATOR
-----------------------------------------------------------
TRUNCATE table SRC_METADATA_INDICATOR IMMEDIATE;
ALTER TABLE SRC_METADATA_INDICATOR ALTER COLUMN INDICATOR_ID RESTART WITH 1;

-- NDC
INSERT INTO SRC_METADATA_INDICATOR (SOURCE_ID, SOURCE, SOURCE_GROUP, TOPIC, INDICATOR, PRIMARY, UOM, INDICATOR_DESC)
SELECT  INDICATOR_ID,  SOURCE, 'NCD', TOPIC, INDICATOR, 
Replace(Lower(Replace(Lower(INDICATOR),'female','')),'male',''), UOM, INDICATOR_DESC
FROM NCD_SRC_METADATA_INDICATOR;

-- WB
INSERT INTO SRC_METADATA_INDICATOR (SOURCE_ID, SOURCE,SOURCE_GROUP, INDICATOR, PRIMARY, INDICATOR_DESC)
SELECT  f.INDICATOR_ID,SOURCE_ORG,'WB/Findex', f.INDICATOR, 
Replace(Lower(Replace(Lower(F.INDICATOR),'female','')),'male','') as PRIMARY, f.INDICATOR_DESC
FROM WB_SRC_METADATA_INDICATOR f;

-- N4D
INSERT INTO SRC_METADATA_INDICATOR (SOURCE_ID, INDICATOR, INDICATOR_DESC, TOPIC, SOURCE,PRIMARY, SOURCE_GROUP)
select *, Replace(Lower(Replace(Lower(INDICATOR),'female','')),'male',''), 'Inter-American Development Bank (IDB)'
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
select "iso","indicator_id","year", "value" from NCD_STG_INDICATOR
where "indicator_id" in (select INDICATOR_ID from NCD_SRC_METADATA_INDICATOR);
---------------------------------------------------------

-- WB_SRC_INDICATOR------------------------------------
TRUNCATE TABLE WB_SRC_INDICATOR IMMEDIATE;

insert into WB_SRC_INDICATOR
select "iso2","indicatorID","year", "value" from WB_STG_INDICATOR;
---------------------------------------------------------

-- N4D_SRC_INDICATOR------------------------------------
TRUNCATE TABLE N4D_SRC_INDICATOR IMMEDIATE;

insert into N4D_SRC_INDICATOR
select * from N4D_STG_INDICATOR;
---------------------------------------------------------

-- STG_INDICATOR------------------------------------
TRUNCATE STG_INDICATOR IMMEDIATE;

--INSERT NCD-----------------------------------------
INSERT INTO STG_INDICATOR(ISO3, INDICATOR_ID, YEAR, VALUE )
select  ncd.ISO3 , md.INDICATOR_ID, ncd.year, ncd.value
from
NCD_SRC_INDICATOR ncd left join 
SRC_METADATA_INDICATOR md
on
ncd.INDICATOR_ID=md.SOURCE_ID
where source_group='NCD' and VALUE is not null
and ncd.iso3 in (select ISO_CD3 from IDB_COUNTRY);


--INSERT WB-----------------------------------------
INSERT INTO STG_INDICATOR(ISO3, INDICATOR_ID, YEAR, VALUE )
select  co.ISO_CD3 , md.INDICATOR_ID, wb.year, wb.value
from
WB_SRC_INDICATOR wb left join 
SRC_METADATA_INDICATOR md
on
wb.INDICATOR_ID=md.SOURCE_ID
left join IDB_COUNTRY co
on wb.iso2=co.iso_cd2
where source_group='WB/Findex' and VALUE is not null;


--INSERT N4D-----------------------------------------
INSERT INTO STG_INDICATOR(ISO3, INDICATOR_ID, YEAR, VALUE )
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

-- World
insert into STG_INDICATOR (ISO3, INDICATOR_ID, VALUE, YEAR)
With world as (select 'WLD' as iso3, INDICATOR_ID, AVG(VALUE) as value, year 
   from STG_INDICATOR 
   JOIN idb_country con on ISO3=con.ISO_CD3 
 where con.REGION = 'no' 
 group by INDICATOR_ID, year)
select * from world where
 (INDICATOR_ID, ISO3, YEAR) not in (select INDICATOR_ID, ISO3, YEAR from STG_INDICATOR where ISO3='WLD'); 

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
