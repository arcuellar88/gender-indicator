--Set up IDB_COUNTRY

truncate table IDB_COUNTRY immediate;
--East Asia & Pacific (developing only)	4E
Insert into idb_country (IDB_CD, ISO_CD3,ISO_CD2, COUNTRY,REGION) values ('4E','R4E','4E','East Asia & Pacific (developing only)','yes') ;
--Europe & Central Asia (developing only)	7E
Insert into idb_country (IDB_CD, ISO_CD3,ISO_CD2, ENGL_NM, COUNTRY,REGION) values ('7E','R7E','7E','Europe & Central Asia (developing only)','Europe & Central Asia (developing only)','yes') ;
--Latin America & Caribbean (developing only)	XJ
Insert into idb_country (IDB_CD, ISO_CD3,ISO_CD2,ENGL_NM, COUNTRY,REGION) values ('XJ','RXJ','XJ','Latin America & Caribbean (developing only)','Latin America & Caribbean (developing only)','yes') ;
--Middle East (Developing only)	M1
Insert into idb_country (IDB_CD, ISO_CD3,ISO_CD2,ENGL_NM, COUNTRY,REGION) values ('M1','RM1','M1','Middle East (Developing only)','Middle East (Developing only)','yes') ;
--Sub-Saharan Africa (developing only)	ZF
Insert into idb_country (IDB_CD, ISO_CD3,ISO_CD2,ENGL_NM, COUNTRY,REGION) values ('ZF','RZF','ZF','Sub-Saharan Africa (developing only)','Sub-Saharan Africa (developing only)','yes') ;
--World	1W
Insert into idb_country (IDB_CD, ISO_CD3,ISO_CD2, ENGL_NM, COUNTRY,REGION) values ('1W','R1W','1W','World','World','yes');

Insert into idb_country (IDB_CD, ISO_CD3,ISO_CD2, ENGL_NM, COUNTRY,REGION) values ('XR','RXR','XR','High income: nonOECD','High income: nonOECD','yes');
Insert into idb_country (IDB_CD, ISO_CD3,ISO_CD2, ENGL_NM, COUNTRY,REGION) values ('KV','RKV','KV','Kosovo','Kosovo','yes');
Insert into idb_country (IDB_CD, ISO_CD3,ISO_CD2, ENGL_NM, COUNTRY,REGION) values ('XC','RXC','XC','Euro area','Euro area','yes');
Insert into idb_country (IDB_CD, ISO_CD3,ISO_CD2, ENGL_NM, COUNTRY,REGION) values ('XT','RXT','XT','Upper middle income','Upper middle income','yes');
Insert into idb_country (IDB_CD, ISO_CD3,ISO_CD2, ENGL_NM, COUNTRY,REGION) values ('XN','RXN','XN','Lower middle income','Lower middle income','yes');
Insert into idb_country (IDB_CD, ISO_CD3,ISO_CD2, ENGL_NM, COUNTRY,REGION) values ('XS','RXS','XS','High income: OECD','High income: OECD','yes');
Insert into idb_country (IDB_CD, ISO_CD3,ISO_CD2, ENGL_NM, COUNTRY,REGION) values ('8S','R8S','8S','South Asia','South Asia','yes');
Insert into idb_country (IDB_CD, ISO_CD3,ISO_CD2, ENGL_NM, COUNTRY,REGION) values ('XO','RXO','XO','Low & middle income','Low & middle income','yes');
Insert into idb_country (IDB_CD, ISO_CD3,ISO_CD2, ENGL_NM, COUNTRY,REGION) values ('XD','RXD','XD','High income','High income','yes');
Insert into idb_country (IDB_CD, ISO_CD3,ISO_CD2, ENGL_NM, COUNTRY,REGION) values ('XP','RXP','XP','Middle income','Middle income','yes');
Insert into idb_country (IDB_CD, ISO_CD3,ISO_CD2, ENGL_NM, COUNTRY,REGION) values ('XM','RXM','XM','Low income','Low income','yes');


Insert into idb_country (IDB_CD, ISO_CD3,ISO_CD2, ENGL_NM, COUNTRY,REGION) values ('11','IB1','11','Southern Cone (CSC)','Southern Cone (CSC)','yes');
Insert into idb_country (IDB_CD, ISO_CD3,ISO_CD2, ENGL_NM, COUNTRY,REGION) values ('12','IB2','12','Andean Group (CAN)','Andean Group (CAN)','yes');
Insert into idb_country (IDB_CD, ISO_CD3,ISO_CD2, ENGL_NM, COUNTRY,REGION) values ('13','IB3','13','Central America (CID)','Central America (CID)','yes');
Insert into idb_country (IDB_CD, ISO_CD3,ISO_CD2, ENGL_NM, COUNTRY,REGION) values asd('14','IB4','14','Caribbean (CCB)','Caribbean (CCB)','yes');
Insert into idb_country (IDB_CD, ISO_CD3,ISO_CD2, ENGL_NM, COUNTRY,REGION) values ('15','IB5','15','Haiti (CDH)','Haiti (CDH)','yes');
Insert into idb_country (IDB_CD, ISO_CD3,ISO_CD2, ENGL_NM, COUNTRY,REGION) values ('16','IB6','16','Not IDB','Not IDB','yes');



update idb_country set REGION='no' where REGION <>'yes';

update IDB_COUNTRY 
set IDB_REGION='Southern Cone (CSC)'
where country in ('Argentina', 'Brazil','Chile','Paraguay', 'Uruguay');

update IDB_COUNTRY 
set IDB_REGION='Andean Group (CAN)'
where country in ('Colombia', 'Venezuela','Peru','Ecuador', 'Bolivia');

update IDB_COUNTRY 
set IDB_REGION='Caribbean (CCB)'
where country in ('Bahamas', 'Barbados','Guyana','Jamaica', 'Suriname', 'Trinidad and Tobago');

update IDB_COUNTRY 
set IDB_REGION='Central America (CID)'
where country in ('Mexico', 'Belize','Costa Rica','Dominican Republic', 'El Salvador', 'Guatemala','Honduras','Nicaragua','Panama');

update IDB_COUNTRY 
set IDB_REGION='Haiti (CDH)'
where country in ('Haiti');

update IDB_COUNTRY 
set IDB_REGION='Southern Cone (CSC)'
where COUNTRY= 'Southern Cone (CSC)';

update IDB_COUNTRY 
set IDB_REGION='Andean Group (CAN)'
where COUNTRY= 'Andean Group (CAN)';

update IDB_COUNTRY 
set IDB_REGION='Central America (CID)'
where COUNTRY= 'Central America (CID)';

update IDB_COUNTRY 
set IDB_REGION='Caribbean (CCB)'
where COUNTRY= 'Caribbean (CCB)';

update IDB_COUNTRY 
set IDB_REGION='Haiti (CDH)'
where COUNTRY= 'Haiti (CDH)';

update IDB_COUNTRY 
set IDB_REGION='Not IDB'
where COUNTRY= 'Not IDB';

update IDB_COUNTRY 
set IDB_REGION='Not IDB'
where IDB_REGION is null;





