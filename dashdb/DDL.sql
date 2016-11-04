---------------------------------------
--<Reporting tables>	
---------------------------------------
--<GENDER_INDICATOR/>
DROP TABLE "DASH6851"."GENDER_INDICATOR";
CREATE TABLE "DASH6851"."GENDER_INDICATOR" (
		"INDICATOR" VARCHAR(300 OCTETS), 
		"PRIMARY" VARCHAR(300 OCTETS), 
		"UOM" VARCHAR(100 OCTETS),
		"YEAR" VARCHAR(4 OCTETS), 
		"ISO3" VARCHAR(3 OCTETS),
		"COUNTRY" VARCHAR(250 OCTETS), 
		"IS_REGION" VARCHAR(20 OCTETS), 
		"IDB_REGION" VARCHAR(50 OCTETS),
		"SOURCE" VARCHAR(100 OCTETS), 
		"TOPIC" VARCHAR(50 OCTETS), 
		"GENDER" VARCHAR(50 OCTETS),
		"AREA" VARCHAR(50 OCTETS), 
		"AGE" VARCHAR(50 OCTETS), 
		"QUINTILE" VARCHAR(50 OCTETS),
		"EDUCATION" VARCHAR(50 OCTETS),	
		"DIVISION" VARCHAR(50 OCTETS), 
		"MULTIPlIER" INTEGER, 
		"VALUE" DECIMAL(21 , 9), 
		"VALUE_NORM" DECIMAL(21 , 9), 
		"VALUE_NORM_CORRECTION" DECIMAL(21 , 9)
	)
	ORGANIZE BY COLUMN
	DATA CAPTURE NONE;
	
--<STG_INDICATOR/>	
DROP TABLE "DASH6851"."STG_INDICATOR";
CREATE TABLE "DASH6851"."STG_INDICATOR" (
		"ISO3" VARCHAR(3 OCTETS), 
		"INDICATOR_ID" INTEGER, 
		"YEAR" VARCHAR(4 OCTETS), 
		"VALUE" NUMERIC(21,9)
	)
	ORGANIZE BY COLUMN
	DATA CAPTURE NONE;	
	
--<SRC TABLE INDICATOR/>	
DROP TABLE "DASH6851"."SRC_INDICATOR";
CREATE TABLE "DASH6851"."SRC_INDICATOR" (
		"ISO3" VARCHAR(3 OCTETS), 
		"INDICATOR_ID" INTEGER, 
		"YEAR" VARCHAR(4 OCTETS), 
		"VALUE" NUMERIC(21,9),
		"VALUE_NORMALIZED" NUMERIC(21,9)
	)
	ORGANIZE BY COLUMN
	DATA CAPTURE NONE;	
	
--<TABLE METADATA_INDICATOR/>
DROP TABLE "DASH6851"."STG_METADATA_INDICATOR";
CREATE TABLE "DASH6851"."STG_METADATA_INDICATOR" (
		"INDICATOR_ID" INTEGER NOT NULL
					   GENERATED ALWAYS AS IDENTITY
                      (START WITH 1, INCREMENT BY 1), 
		"SOURCE_ID" VARCHAR(20 OCTETS) NOT NULL,
		"SOURCE" VARCHAR(255 OCTETS), 
		"SOURCE_GROUP" VARCHAR(100 OCTETS), 
		"TOPIC" VARCHAR(25 OCTETS), 
		"INDICATOR" VARCHAR(1000 OCTETS), 
		"PRIMARY" VARCHAR(255 OCTETS), 
		"UOM" VARCHAR(100 OCTETS), 
		"INDICATOR_DESC" VARCHAR(8000 OCTETS), 
		"GENDER" VARCHAR(50 OCTETS),
		"AREA" VARCHAR(50 OCTETS), 
		"AGE" VARCHAR(50 OCTETS), 
		"QUINTIL" VARCHAR(50 OCTETS),
		"EDUCATION" VARCHAR(50 OCTETS),	
		"DIVISION" VARCHAR(50 OCTETS),
		"MULTIPLIER" INTEGER, 		
		PRIMARY KEY (INDICATOR_ID),
		UNIQUE(SOURCE_ID)
	)
	ORGANIZE BY COLUMN
	DATA CAPTURE NONE;
	
	--<SRC METADATA_INDICATOR/>
DROP TABLE "DASH6851"."SRC_METADATA_INDICATOR";
CREATE TABLE "DASH6851"."SRC_METADATA_INDICATOR" (
		"INDICATOR_ID" INTEGER NOT NULL
					   GENERATED ALWAYS AS IDENTITY
                      (START WITH 1, INCREMENT BY 1), 
		"SOURCE_ID" VARCHAR(20 OCTETS) NOT NULL,
		"SOURCE" VARCHAR(255 OCTETS), 
		"SOURCE_GROUP" VARCHAR(100 OCTETS), 
		"TOPIC" VARCHAR(25 OCTETS), 
		"INDICATOR" VARCHAR(1000 OCTETS), 
		"PRIMARY" VARCHAR(255 OCTETS), 
		"UOM" VARCHAR(100 OCTETS), 
		"INDICATOR_DESC" VARCHAR(8000 OCTETS), 
		"GENDER" VARCHAR(50 OCTETS),
		"AREA" VARCHAR(50 OCTETS), 
		"AGE" VARCHAR(50 OCTETS), 
		"QUINTIL" VARCHAR(50 OCTETS),
		"EDUCATION" VARCHAR(50 OCTETS),	
		"DIVISION" VARCHAR(50 OCTETS),
		"MULTIPLIER" INTEGER, 		
		PRIMARY KEY (INDICATOR_ID),
		UNIQUE(SOURCE_ID)
	)
	ORGANIZE BY COLUMN
	DATA CAPTURE NONE;
---------------------------------------	
---------<Auxiliary Tables>	
---------------------------------------	
--<TABLE COUNTRY/>

DROP TABLE "DASH6851"."IDB_COUNTRY";
CREATE TABLE "DASH6851"."IDB_COUNTRY" 
   (
    "IDB_CD" VARCHAR(2 BYTE) NOT NULL , 
	"ISO_CD3" VARCHAR(3 BYTE) NOT NULL , 
	"ENGL_NM" VARCHAR(70 BYTE) NOT NULL ,
	"COUNTRY" VARCHAR(70 BYTE) NOT NULL ,
	"SPANISH_NM" VARCHAR(70 BYTE), 
	"PORTUGUESE_NM" VARCHAR(70 BYTE), 
	"FRENCH_NAME" VARCHAR(70 BYTE), 
	"ISO_CD2" VARCHAR(2 BYTE) NOT NULL ,
	"TYP" VARCHAR(20 BYTE),
	"REGION" VARCHAR(20 BYTE),
	PRIMARY KEY (ISO_CD3),
	UNIQUE (ISO_CD2) 
   )
    ORGANIZE BY COLUMN
	DATA CAPTURE NONE;   

---------------------------------------	
---------<NCD>	
---------------------------------------	
   
 --<STG TABLE NCD_INDICATOR/>
DROP TABLE "DASH6851"."NCD_STG_INDICATOR";

CREATE TABLE "DASH6851"."NCD_STG_INDICATOR" (
		"ISO3" VARCHAR(3 OCTETS), 
		"INDICATOR_ID" VARCHAR(8 OCTETS), 
		"YEAR" SMALLINT, 
		"VALUE" NUMERIC(21,10)
	)
	ORGANIZE BY COLUMN
	DATA CAPTURE NONE;
	
 --<SRC TABLE NCD_INDICATOR/>
DROP TABLE "DASH6851"."NCD_SRC_INDICATOR";

CREATE TABLE "DASH6851"."NCD_SRC_INDICATOR" (
		"ISO3" VARCHAR(3 OCTETS), 
		"INDICATOR_ID" VARCHAR(8 OCTETS), 
		"YEAR" SMALLINT, 
		"VALUE" NUMERIC(21,10)
	)
	ORGANIZE BY COLUMN
	DATA CAPTURE NONE;
	

--<SRC TABLE NCD_META_INDICATOR/>
DROP TABLE "DASH6851"."NCD_SRC_METADATA_INDICATOR";

CREATE TABLE "DASH6851"."NCD_SRC_METADATA_INDICATOR" (
		"TOPIC" VARCHAR(13 OCTETS), 
		"INDICATOR_ID" VARCHAR(8 OCTETS) NOT NULL, 
		"INDICATOR" VARCHAR(136 OCTETS), 
		"UOM" VARCHAR(59 OCTETS), 
		"SOURCE" VARCHAR(185 OCTETS), 
		"INDICATOR_DESC" VARCHAR(1393 OCTETS), 
		"PRIMARY" VARCHAR(73 OCTETS), 
		"SECONDARY" VARCHAR(102 OCTETS), 
		"TERTIARY" VARCHAR(8 OCTETS),
		PRIMARY KEY (INDICATOR_ID)
	)
	ORGANIZE BY COLUMN
	DATA CAPTURE NONE;

--<STG TABLE NCD_META_INDICATOR/>
DROP TABLE "DASH6851"."NCD_STG_METADATA_INDICATOR";
CREATE TABLE "DASH6851"."NCD_STG_METADATA_INDICATOR" (
		"THEME" VARCHAR(13 OCTETS), 
		"SERIES" VARCHAR(8 OCTETS) NOT NULL, 
		"NAME" VARCHAR(136 OCTETS), 
		"UNIT" VARCHAR(59 OCTETS), 
		"SOURCE" VARCHAR(185 OCTETS), 
		"DEFINITION" VARCHAR(1393 OCTETS), 
		"PRIMARY" VARCHAR(73 OCTETS), 
		"SECONDARY" VARCHAR(102 OCTETS), 
		"TERTIARY" VARCHAR(8 OCTETS),
		PRIMARY KEY (SERIES)
	)
	ORGANIZE BY COLUMN
	DATA CAPTURE NONE;

--------------------------------------	
---------<IDB>	
---------------------------------------	

--<N4D_STG_INDICATOR/>
CREATE TABLE "DASH6851"."N4D_STG_INDICATOR" (
		"ISO3" VARCHAR(3 OCTETS), 
		"INDICATOR_ID" VARCHAR(20 OCTETS), 
		"YEAR" SMALLINT, 
		"VALUE" NUMERIC(21,10)
);

--<N4D_SRC_INDICATOR/>
CREATE TABLE "DASH6851"."N4D_SRC_INDICATOR" (
		"ISO3" VARCHAR(3 OCTETS), 
		"INDICATOR_ID" VARCHAR(20 OCTETS), 
		"YEAR" SMALLINT, 
		"VALUE" NUMERIC(21,10)
);

--<N4D_STG_METADATA_INDICATOR/>
CREATE TABLE "DASH6851"."N4D_STG_METADATA_INDICATOR" (
		"﻿INDICATOR_ID" SMALLINT NOT NULL, 
		"INDICATOR" VARCHAR(110 OCTETS), 
		"INDICATOR_DESC" VARCHAR(254 OCTETS), 
		"GENDER" VARCHAR(6 OCTETS), 
		"QUINTILE" VARCHAR(23 OCTETS), 
		"AREA" VARCHAR(5 OCTETS), 
		"AGE" VARCHAR(5 OCTETS), 
		"EDUCATION" VARCHAR(14 OCTETS), 
		"TOPIC" VARCHAR(12 OCTETS), 
		"SOURCE" VARCHAR(10 OCTETS),
		PRIMARY KEY(﻿INDICATOR_ID)
	)
	ORGANIZE BY COLUMN
	DATA CAPTURE NONE;
	
--<N4D_SRC_METADATA_INDICATOR/>

CREATE TABLE "DASH6851"."N4D_SRC_METADATA_INDICATOR" (
		"﻿INDICATOR_ID" SMALLINT NOT NULL, 
		"INDICATOR" VARCHAR(110 OCTETS), 
		"INDICATOR_DESC" VARCHAR(254 OCTETS), 
		"GENDER" VARCHAR(6 OCTETS), 
		"QUINTILE" VARCHAR(23 OCTETS), 
		"AREA" VARCHAR(5 OCTETS), 
		"AGE" VARCHAR(5 OCTETS), 
		"EDUCATION" VARCHAR(14 OCTETS), 
		"TOPIC" VARCHAR(12 OCTETS), 
		"SOURCE" VARCHAR(10 OCTETS),
		PRIMARY KEY(﻿INDICATOR_ID)
	)
	ORGANIZE BY COLUMN
	DATA CAPTURE NONE;

---------------------------------------	
---------<World Bank>	
---------------------------------------	
CREATE TABLE "DASH6851"."WB_STG_INDICATOR" (
		"ISO2" VARCHAR(3 OCTETS), 
		"country_region" VARCHAR(100 OCTETS),
		"YEAR" SMALLINT, 
		"INDICATOR_ID" VARCHAR(25 OCTETS), 
		"VALUE" NUMERIC(21,10)
);

CREATE TABLE "DASH6851"."WB_SRC_INDICATOR" (
		"ISO2" VARCHAR(3 OCTETS), 
		"INDICATOR_ID" VARCHAR(25 OCTETS), 
		"YEAR" SMALLINT, 
		"VALUE" NUMERIC(21,10)
);

--<DDL TABLE WB_METADATA_INDICATOR/>
DROP TABLE "DASH6851"."WB_STG_METADATA_INDICATOR";

CREATE TABLE "DASH6851"."WB_STG_METADATA_INDICATOR" (
		"indicatorID" VARCHAR(25 OCTETS)  NOT NULL, 
		"indicator" VARCHAR(255 OCTETS) NOT NULL, 
		"indicatorDesc" VARCHAR(2000 OCTETS), 
		"sourceOrg" VARCHAR(255 OCTETS), 
		"sourceID" VARCHAR(255 OCTETS), 
		"source" VARCHAR(255 OCTETS),
		PRIMARY KEY ("indicatorID")
);

--<DDL TABLE WB_METADATA_INDICATOR/>
DROP TABLE "DASH6851"."WB_SRC_METADATA_INDICATOR";
CREATE TABLE "DASH6851"."WB_SRC_METADATA_INDICATOR" (
		"INDICATOR_ID" VARCHAR(25 OCTETS)  NOT NULL, 
		"INDICATOR" VARCHAR(255 OCTETS) NOT NULL, 
		"INDICATOR_DESC" VARCHAR(2000 OCTETS), 
		"SOURCE_ORG" VARCHAR(255 OCTETS), 
		"SOURCE_ID" VARCHAR(255 OCTETS), 
		"SOURCE" VARCHAR(255 OCTETS),
		PRIMARY KEY (INDICATOR_ID)

);

---------------------------------------	
--<Tables for classification>-----
---------------------------------------	
	
DROP TABLE "DASH6851"."TERMS";

--<DDL TABLE TERM/>
CREATE TABLE "DASH6851"."TERM" (
		"DIVISION" VARCHAR(255 OCTETS), 
		"TERM" VARCHAR(255 OCTETS)
	)
	ORGANIZE BY COLUMN
	DATA CAPTURE NONE;

---------------------------------------	
--<Tables for classification>-----
---------------------------------------	
CREATE TABLE "DASH6851"."INDICATOR_BY_YEAR" (
	"INDICATOR_ID" INTEGER NOT NULL, 
	"YEAR" VARCHAR(4 OCTETS) NOT NULL, 
	"MEAN" DECIMAL(21 , 9), 
	"STDDEV" DECIMAL(21 , 9), 
	"TOTAL" DECIMAL(21 , 9),
	PRIMARY KEY("INDICATOR_ID","YEAR")
	)
	ORGANIZE BY COLUMN
	DATA CAPTURE NONE;