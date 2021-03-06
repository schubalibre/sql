
DROP VIEW match;
CREATE VIEW match AS 
SELECT AOLDATA.QUERYDATA.QUERY AS QUERY,(SELECT AOLDATA.LOCATION.CITY FROM AOLDATA.LOCATION GROUP BY AOLDATA.LOCATION.CITY) AS CITY, AOLDATA.QUERYDATA.ANONID AS USER_ID 
FROM AOLDATA.QUERYDATA 
INNER JOIN AOLDATA.LOCATION ON AOLDATA.QUERYDATA.QUERY LIKE ('%' || LOWER(CITY) || '%')
WHERE AOLDATA.QUERYDATA.QUERYTIME >= TO_TIMESTAMP('2006-05-01','yyyy-mm-dd') 
AND AOLDATA.QUERYDATA.QUERYTIME < TO_TIMESTAMP('2006-05-02','yyyy-mm-dd');

CREATE OR REPLACE VIEW LOCATIONVIEW AS
SELECT DISTINCT(AOLDATA.LOCATION.CITY)
FROM AOLDATA.LOCATION
ORDER BY CITY;

CREATE OR REPLACE VIEW LOCATIONMATCHVIEW AS
SELECT AOLDATA.QUERYDATA_IDX.ANONID,
AOLDATA.QUERYDATA_IDX.QUERY
AS USERQUERY, AOLDATA.QUERYDATA_IDX.QUERYTIME
AS USERTIME, LOCATIONVIEW.CITY
FROM AOLDATA.QUERYDATA_IDX,LOCATIONVIEW
WHERE CONTAINS(AOLDATA.QUERYDATA_IDX.QUERY, LOWER(LOCATIONVIEW.CITY), 1) > 0;

SELECT LOCATIONMATCHVIEW.CITY, Count(LOCATIONMATCHVIEW.CITY)
FROM LOCATIONMATCHVIEW, AOLDATA.QUERYDATA_IDX LEFT JOIN
(SELECT ACTIVE_DEFENSE.KEYWORD
FROM ACTIVE_DEFENSE
UNION
SELECT PASSIVE_DEFENSE.KEYWORDS
FROM PASSIVE_DEFENSE) Keywords
ON CONTAINS  (AOLDATA.QUERYDATA_IDX.Query, KEYWORDS.KEYWORD,1)>0
WHERE AOLDATA.QUERYDATA_IDX.ANONID = LOCATIONMATCHVIEW.ANONID
AND ROWNUM <= 10
GROUP BY LOCATIONMATCHVIEW.CITY;

