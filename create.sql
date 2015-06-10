DROP TABLE MATCH_QUERY_LOCATION;
DROP TABLE MATCH_QUERY_KEYWORDS;
DROP TABLE MATCH_KEYWORD_WEBSITE_CATEGORY;
DROP TABLE FBI;
DROP TABLE KEYWORDS;
DROP TABLE LOCATION;




CREATE TABLE LOCATION(
	ID      	INTEGER NOT NULL ,
	CITY    	VARCHAR2(50) ,
	POPULATION  INTEGER,
	PRIMARY KEY(ID)
);

INSERT INTO LOCATION(CITY,ID,POPULATION)
SELECT DISTINCT(AOLDATA.LOCATION.CITY), MIN(AOLDATA.LOCATION.ZIP), MAX(FBI_TMP.POPULATION)
FROM AOLDATA.LOCATION, FBI_TMP
WHERE AOLDATA.LOCATION.CITY = FBI_TMP.CITY
GROUP BY AOLDATA.LOCATION.CITY,(AOLDATA.LOCATION.CITY)
ORDER BY CITY;


CREATE TABLE KEYWORDS(
	ID      	INTEGER NOT NULL ,
	VALUE   	VARCHAR2(50) ,
	CATEGORY  INTEGER,
	PRIMARY KEY(ID)
);
INSERT INTO KEYWORDS VALUES (1, 'weapon',1 );
INSERT INTO KEYWORDS VALUES (2, 'axe' ,1 );
INSERT INTO KEYWORDS VALUES (3, 'judo' ,1 );
INSERT INTO KEYWORDS VALUES(4, 'martial arts',2);
INSERT INTO KEYWORDS VALUES(5, 'alarm' ,2);
INSERT INTO KEYWORDS VALUES(6, 'pepper spray',2);

CREATE TABLE FBI(
	LOCATION_ID     	INTEGER NOT NULL ,
	PROPERTY_CRIME  INTEGER ,
	VIOLANCE_CRIME  INTEGER,
	PRIMARY KEY(LOCATION_ID),
	FOREIGN KEY(LOCATION_ID) REFERENCES LOCATION(ID)
);
INSERT INTO FBI (LOCATION_ID, PROPERTY_CRIME, VIOLANCE_CRIME)
SELECT LOCATION.ID, FBI_TMP.PROPERTY_CRIME, FBI_TMP.VIOLENT_CRIME
FROM FBI_TMP, LOCATION
WHERE LOCATION.CITY = FBI_TMP.CITY 
AND LOCATION.POPULATION = FBI_TMP.POPULATION;


CREATE TABLE MATCH_QUERY_LOCATION(
	USER_ID     	INTEGER NOT NULL ,
	LOCATION_ID  INTEGER,
	PRIMARY KEY(USER_ID),
	FOREIGN KEY(LOCATION_ID) REFERENCES  LOCATION(ID)
);

CREATE OR REPLACE VIEW USER_LOCATION_COUNT AS
SELECT AOLDATA.QUERYDATA_IDX.ANONID, LOCATION.ID,Count(LOCATION.CITY) LOCCOUNT, 
ROW_NUMBER() OVER (PARTITION BY AOLDATA.QUERYDATA_IDX.ANONID ORDER BY Count(LOCATION.CITY) DESC) AS RN
FROM AOLDATA.QUERYDATA_IDX, LOCATION
WHERE CONTAINS(AOLDATA.QUERYDATA_IDX.QUERY, LOWER(LOCATION.CITY), 1) > 0
GROUP BY AOLDATA.QUERYDATA_IDX.ANONID, LOCATION.ID, LOCATION.CITY;

/* nun nutzen wir die VIEW um unsere Abfrage zu vereinfachen */
INSERT INTO MATCH_QUERY_LOCATION (USER_ID, LOCATION_ID)
SELECT USER_LOCATION_COUNT.ANONID, USER_LOCATION_COUNT.ID
FROM USER_LOCATION_COUNT
WHERE USER_LOCATION_COUNT.RN = 1;

CREATE TABLE MATCH_QUERY_KEYWORDS(
	USER_ID     	INTEGER ,
	KEYWORD_ID  INTEGER ,
  QUERY_ID INTEGER ,
	FOREIGN KEY(KEYWORD_ID) REFERENCES  KEYWORDS(ID)
);

INSERT INTO MATCH_QUERY_KEYWORDS(USER_ID,KEYWORD_ID,QUERY_ID)
SELECT DISTINCT AOLDATA.QUERYDATA_IDX.ANONID, KEYWORDS.ID,AOLDATA.QUERYDATA_IDX.ID
FROM AOLDATA.QUERYDATA_IDX, KEYWORDS
WHERE CONTAINS(AOLDATA.QUERYDATA_IDX.QUERY,  KEYWORDS.VALUE, 1) > 0
ORDER BY AOLDATA.QUERYDATA_IDX.ANONID;



/*Liefert alle USER von den wir wissen, das sie*/
CREATE TABLE MATCH_KEYWORD_WEBSITE_CATEGORY(
	KEYWORD_ID INTEGER NOT NULL ,
	CAT_ID     INTEGER,
	PRIMARY KEY(KEYWORD_ID,CAT_ID)
);
INSERT INTO MATCH_KEYWORD_WEBSITE_CATEGORY(KEYWORD_ID,CAT_ID)
SELECT KEYWORDS.ID, AOLDATA.DMOZ_CATEGORIES.CATID
FROM AOLDATA.DMOZ_CATEGORIES, KEYWORDS
WHERE AOLDATA.DMOZ_CATEGORIES.DESCRIPTION LIKE  '%' || KEYWORDS.VALUE || '%'
AND ROWNUM <= 50
ORDER BY AOLDATA.DMOZ_CATEGORIES.CATID;



