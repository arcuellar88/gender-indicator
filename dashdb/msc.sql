CREATE TABLE "DASH6851"."INDICATOR_BY_YEAR" (
		"INDICATOR_ID" INTEGER, 
		"YEAR" VARCHAR(4 OCTETS), 
		"MEAN" DECIMAL(21 , 9), 
		"STDDEV" DECIMAL(21 , 9), 
		"TOTAL" DECIMAL(21 , 9)
	)
	ORGANIZE BY COLUMN
	DATA CAPTURE NONE;
 
 select * from INDICATOR ind INNER JOIN INDICATOR_BY_YEAR indY
ON  ind.INDICATOR_ID= indY.INDICATOR_ID
AND ind.YEAR= indY.YEAR


select * from 
INDICATOR ind JOIN INDICATOR_BY_YEAR indY
ON  ind.INDICATOR_ID= indY.INDICATOR_ID
AND ind.YEAR= indY.YEAR



INSERT INTO INDICATOR (ISO3, INDICATOR_ID, YEAR, VALUE)
select  
ncd.ISO3,
mi.INDICATOR_ID,
ncd.YEAR,
ncd.VALUE

from NCD_SRC_INDICATOR ncd 
join METADATA_INDICATOR mi
ON ncd.INDICATOR_ID=mi.SOURCE_ID

select  
ncd.ISO3,
mi.TOPIC,
ncd.YEAR,
ncd.VALUE
from NCD_SRC_INDICATOR ncd 
join METADATA_INDICATOR mi
ON ncd.INDICATOR_ID=mi.SOURCE_ID;

SELECT INDICATOR, PRIMARY, UOM, SOURCE, VALUE, VALUE_NORMALIZED, TOPIC, GENDER, AREA, QUINTIL as QUINTILE, EDUCATION, DIVISION, MULTIPLIER, COUNTRY, REGION FROM SRC_INDICATOR JOIN METADATA_INDICATOR using (INDICATOR_ID)
left join idb_country on ISO3=ISO_CD3;

--With t as (
--select ISO3, INDICATOR_ID, AVG(VALUE) as value, 'ALL' as year 
--from STG_INDICATOR
--where year not like 'ALL' 
--group by ISO3, INDICATOR_ID)
--select count(*) from t

With TERMS_DIV as 
(select DIVISION,COUNT(*),LISTAGG(TERM, ' | ') WITHIN GROUP(ORDER BY TERM) as terms
from TERMS group by DIVISION)
select
 m.INDICATOR,
 	(SELECT DIVISION from TERMS_DIV where INDICATOR like TERMS) as div
 from METADATA_INDICATOR m
..select * from METADATA_INDICATOR
where
REGEXP_LIKE( INDICATOR,'road | transport','i');

select * from METADATA_INDICATOR
where
lower(INDICATOR) like '%transport%';



--xmlcast(xmlquery('fn:matches($INDICATOR,''(construc | infras | road )'')') as integer) = 1;


With TERMS_DIV as 
(select DIVISION,COUNT(*),LISTAGG(TERM, ' | ') WITHIN GROUP(ORDER BY TERM) as terms
from TERMS group by DIVISION)


With TERMS_DIV as 
(select DIVISION,COUNT(*),LISTAGG(TERM, ' | ') WITHIN GROUP(ORDER BY TERM) as terms
from TERMS group by DIVISION)

select INDICATOR,
(SELECT DIVISION FROM TERMS_DIV WHERE
 REGEXP_LIKE( m.INDICATOR,terms,'i') limit 1) as division
 from METADATA_INDICATOR m

 create table TERMS_DIV as (
select DIVISION,COUNT(*),LISTAGG(TERM, ' | ') WITHIN GROUP(ORDER BY TERM) as terms
from TERMS group by DIVISION) WITH NO DATA

drop table TERMS_DIV;
Create table TERMS_DIV (DIVISION VARCHAR(20), TERMS VARCHAR(500))

SELECT cast(listagg(DIVISION, ', ') as varchar(100)) FROM TERMS_DIV WHERE 
REGEXP_LIKE( Lower('malaria'),'malaria|water','i');


truncate TERMS_DIV immediate;
insert into TERMS_DIV 
select DIVISION,LISTAGG(TRIM(TERM), '|') WITHIN GROUP(ORDER BY TERM) as terms
from TERMS group by DIVISION;