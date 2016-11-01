
truncate table INDICATOR_BY_YEAR immediate;
insert into INDICATOR_BY_YEAR
            select INDICATOR_ID, YEAR, AVG(VALUE), STDDEV(VALUE), count(*) as total
            from STG_INDICATOR JOIN IDB_COUNTRY on ISO3=ISO_CD3
            where REGION='no'
            group by YEAR, INDICATOR_ID;
            
UPDATE INDICATOR_BY_YEAR 
SET STDDEV=1 
WHERE STDDEV=0;

truncate table SRC_INDICATOR immediate;

insert into SRC_INDICATOR 
select 
ind.ISO3,
ind.INDICATOR_ID,
ind.YEAR,
ind.VALUE,
(ind.VALUE-indY.MEAN)/indY.STDDEV as VALUE_NORMALIZED
 from 
STG_INDICATOR ind LEFT outer JOIN INDICATOR_BY_YEAR indY
ON  ind.INDICATOR_ID= indY.INDICATOR_ID
AND ind.YEAR= indY.YEAR;