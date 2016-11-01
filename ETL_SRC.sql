
-----------------------------------------------------------
-- NCD METADATA_INDICATOR
-----------------------------------------------------------
truncate table NCD_SRC_METADATA_INDICATOR IMMEDIATE;

insert into NCD_SRC_METADATA_INDICATOR
select * from NCD_STG_METADATA_INDICATOR
where source not like '%World%Bank%' and source not like '%Global%Findex%';

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
-- NCD INDICATOR DATA
-----------------------------------------------------------
TRUNCATE TABLE NCD_SRC_INDICATOR IMMEDIATE;

insert into NCD_SRC_INDICATOR
select iso3,INDICATOR_ID,YEAR, value from NCD_STG_INDICATOR
where INDICATOR_ID in (select INDICATOR_ID from NCD_SRC_METADATA_INDICATOR);


-----------------------------------------------------------
-- WB INDICATOR DATA
-----------------------------------------------------------
TRUNCATE TABLE WB_SRC_INDICATOR IMMEDIATE;

insert into WB_SRC_INDICATOR
select iso2,INDICATOR_ID,YEAR, value from WB_STG_INDICATOR;

-----------------------------------------------------------
-- N4D INDICATOR DATA
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
 
update METADATA_INDICATOR 
set GENDER='female'
where indicator like '% Female';

update METADATA_INDICATOR 
set GENDER='male'
where indicator like '% Male';

update METADATA_INDICATOR 
set GENDER='total'
where indicator like '% Total';

update METADATA_INDICATOR
set TOPIC='Economic Opportunities'
where TOPIC is null and 
(INDICATOR like '%Saved for%' 
or INDICATOR like '%Saved any%' 
or INDICATOR like '%Saved at%'
or Lower(INDICATOR) like '%loan%'
or INDICATOR like '%send money%'
or INDICATOR like '%Debit card%'
or INDICATOR like '%Credit card%' 
or INDICATOR like '%emergency funds%'
or INDICATOR like '%Borrowed from%' 
or INDICATOR like '%financial institution%'
or INDICATOR like '%make payments%'
or INDICATOR like '%Account%'
or INDICATOR like '%Saved using%'
or INDICATOR like '%pay%bills%'
or INDICATOR like '%Paid%bills%'
or INDICATOR like '%Paid%fees%'
or INDICATOR like '%paid%for%'
or INDICATOR like '%pay%fees%'
or INDICATOR like '%receive money%'
or INDICATOR like '%Saved to start%'
or INDICATOR like '%Borrowed%'
or INDICATOR like '%Received%payments%'
or INDICATOR like '%Received%remittances%'
or INDICATOR like '%Received%wages%'
or INDICATOR like '%Received%transfers%'
or INDICATOR like '%Sent%remittances%'
or INDICATOR like '%Used an account%'
or INDICATOR like '%mortgage%'
);

-----------------------------------------------------------
--INDICATOR DATA
-----------------------------------------------------------
TRUNCATE STG_INDICATOR IMMEDIATE;
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
where source='WB/Findex' and VALUE is not null;

--NCD
INSERT INTO STG_INDICATOR
select  ncd.ISO3 , md.INDICATOR_ID, ncd.year, ncd.value
from
NCD_SRC_INDICATOR ncd left join 
METADATA_INDICATOR md
on
ncd.INDICATOR_ID=md.SOURCE_ID
where source='NCD' and VALUE is not null;

--N4D
INSERT INTO STG_INDICATOR
select  n4d.ISO3 , md.INDICATOR_ID, n4d.year, n4d.value
from
N4D_SRC_INDICATOR n4d left join 
METADATA_INDICATOR md
on
n4d.INDICATOR_ID=md.SOURCE_ID
where source not in ('NCD', 'WB/Findex') and VALUE is not null;

-- ALL REGIONS
insert into STG_INDICATOR (ISO3, INDICATOR_ID, VALUE, YEAR)
select reg.ISO_CD3, INDICATOR_ID, AVG(VALUE) as value, year 
   from STG_INDICATOR JOIN idb_country con on ISO3=con.ISO_CD3 
   join idb_country reg on con.IDB_REGION=reg.COUNTRY
 where con.IDB_REGION not like '%Not IDB%' 
 group by reg.ISO_CD3, INDICATOR_ID, year;


--ALL YEARS
insert into STG_INDICATOR (ISO3, INDICATOR_ID, VALUE, YEAR)
select ISO3, INDICATOR_ID, AVG(VALUE) as value, 'ALL' as year 
   from STG_INDICATOR JOIN idb_country on ISO3=ISO_CD3 
 where REGION='no'
 group by ISO3, INDICATOR_ID;
 


--With t as (
--select ISO3, INDICATOR_ID, AVG(VALUE) as value, 'ALL' as year 
--from STG_INDICATOR
--where year not like 'ALL' 
--group by ISO3, INDICATOR_ID)
--select count(*) from t


TRUNCATE TABLE GENDER_INDICATOR IMMEDIATE;
INSERT INTO GENDER_INDICATOR
SELECT INDICATOR, PRIMARY, UOM, YEAR,ISO3, COUNTRY,REGION, IDB_REGION,SOURCE, TOPIC, GENDER, AREA,AGE, QUINTIL as QUINTILE, EDUCATION, DIVISION, MULTIPLIER, 
 VALUE, VALUE_NORMALIZED,VALUE_NORMALIZED*MULTIPLIER 
FROM SRC_INDICATOR JOIN METADATA_INDICATOR using (INDICATOR_ID)
left join idb_country on ISO3=ISO_CD3;


