DROP VIEW LOCATIONVIEW;

CREATE VIEW LOCATIONVIEW AS
SELECT DISTINCT(AOLDATA.LOCATION.CITY) 
FROM AOLDATA.LOCATION ORDER BY CITY;

DROP VIEW MATCHVIEW;

CREATE VIEW MATCHVIEW AS
SELECT 
AOLDATA.QUERYDATA_IDX.ANONID, 
AOLDATA.QUERYDATA_IDX.QUERY AS USERQUERY, 
AOLDATA.QUERYDATA_IDX.QUERYTIME AS USERTIME, 
LOCATIONVIEW.CITY
FROM AOLDATA.QUERYDATA_IDX,
LOCATIONVIEW
WHERE 
CONTAINS(AOLDATA.QUERYDATA_IDX.QUERY, LOWER(LOCATIONVIEW.CITY), 1) > 0 
AND ROWNUM <= 100 ;
  
 
