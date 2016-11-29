-----------------------------------------------------------
-- Classification
-----------------------------------------------------------

--Gender 
update SRC_METADATA_INDICATOR 
set GENDER='Female'
where (Lower(indicator) like '% girls %' 
 or Lower(indicator) like '% female%'
 or Lower(indicator) like 'female %'
 or Lower(indicator) like '% women%' 
 or Lower(indicator) like 'women%'
 or Lower(indicator) like '%gender%'
 or Lower(indicator) like  'vaw laws %'
 or Lower(indicator) like  '% maternity%'
 or indicator like '%GPI%'
 or Lower(indicator) like  '%domestic violence%'
 or Lower(indicator) like  '%mother%'
 or Lower(indicator) like '%sexual harassment%');
 
update SRC_METADATA_INDICATOR 
set GENDER='Male'
where (GENDER is null or GENDER='other') 
and (Lower(indicator) like '% male%' 
or Lower(indicator) like '% men in%'
or Lower(indicator) like '%paternity%');

 --AREA
update SRC_METADATA_INDICATOR 
set AREA='Rural'
where Lower(indicator) like '% rural%';

update SRC_METADATA_INDICATOR 
set AREA='Urban'
where AREA is null and Lower(indicator) like '% urban%';
  
update SRC_METADATA_INDICATOR 
set AREA='Total'
where AREA is null and Lower(indicator) like '% total%';

update SRC_METADATA_INDICATOR 
set AREA='Other'
where AREA is null;

 
 --Multiplier
update SRC_METADATA_INDICATOR
set MULTIPLIER=-1
WHERE REGEXP_LIKE(PRIMARY,'not good at math|helpless at math|Year women obtained election|Press Freedom Index|VAW laws SIGI|Unmet need|unemployed|unemployment|Out of school|homicide|outstanding|informal|death|mort|drop|HIV|viol|disor| vulnerable| fertility|unimpro|disea|wife beating|working very long|DALYs|Forced first sex','i');

update SRC_METADATA_INDICATOR
set MULTIPLIER=1
WHERE MULTIPLIER IS NULL;

--Division
truncate DIVISION_INDICATOR IMMEDIATE;

--Manual classification
insert into DIVISION_INDICATOR
select source_id,idiv.DIVISION from SRC_METADATA_INDICATOR smi join
INE_DIVISION idiv on
smi.INDICATOR=idiv.INDICATOR;

--Auto-classification
insert into DIVISION_INDICATOR
SELECT SOURCE_ID, terms.DIVISION 
FROM TERMS terms, SRC_METADATA_INDICATOR meta
WHERE Lower(meta.PRIMARY) like concat(concat('%',TERM),'%')
and terms.DIVISION not in ('WSA','TSP','ENE')
GROUP BY SOURCE_ID, terms.DIVISION ;

--Update DIVISION in SRC_METADATA_INDICATOR
MERGE INTO SRC_METADATA_INDICATOR AS meta
  USING (SELECT SOURCE_ID, listagg(DIVISION, ', ') as DIVISIONS from DIVISION_INDICATOR group by SOURCE_ID) AS div
  ON meta.SOURCE_ID=div.SOURCE_ID
  WHEN MATCHED THEN
     UPDATE SET
        DIVISION = DIVISIONS;

--Topic
update SRC_METADATA_INDICATOR
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

update SRC_METADATA_INDICATOR
set TOPIC='Other'
where TOPIC is null;

