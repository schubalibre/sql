/* 1. Von welchen Nutzern können wir durch die Suchanfragen auf seinen Standort schließen?*/
INSERT INTO LOCATION (CITY,ID, POPULATION) 
SELECT DISTINCT(AOLDATA.LOCATION.CITY) AS CITY, 
MIN(AOLDATA.LOCATION.ZIP) AS LOCATION_ID, 
SUM(AOLDATA.LOCATION.POPULATION)
FROM AOLDATA.LOCATION 
GROUP BY (AOLDATA.LOCATION.CITY)
ORDER BY CITY; /* POPULATION soll dann aus der FBI Datenbank genommen werden */


/* Erstellung der neuen LocationMatchQuery - Achtung die LocationMatchQuery wurde verändert */
DROP TABLE LocationMatchQuery;

CREATE TABLE LocationMatchQuery
  (
	Location_ID INTEGER NOT NULL ,
	Query_ID	INTEGER NOT NULL
  ) ;
  
ALTER TABLE LocationMatchQuery ADD CONSTRAINT LocationMatchQuery_PK PRIMARY KEY ( Location_ID, Query_ID ) ;

ALTER TABLE LocationMatchQuery ADD CONSTRAINT FK_ASS_3 FOREIGN KEY ( Location_ID ) REFERENCES Location ( ID ) ;

ALTER TABLE LocationMatchQuery ADD CONSTRAINT FK_ASS_4 FOREIGN KEY ( Query_ID ) REFERENCES AOLDATA.QUERYDATA_IDX ( ANONID ) ;


/* Unser INSERT */
INSERT INTO LOCATIONMATCHQUERY (QUERY_ID, LOCATION_ID)
SELECT AOLDATA.QUERYDATA_IDX.ANONID,
LOCATION.ID FROM AOLDATA.QUERYDATA_IDX,
LOCATION WHERE CONTAINS(AOLDATA.QUERYDATA_IDX.QUERY, LOWER(LOCATION.CITY), 1) > 0
AND ROWNUM <= 10000
GROUP BY AOLDATA.QUERYDATA_IDX.ANONID, LOCATION.ID
ORDER BY AOLDATA.QUERYDATA_IDX.ANONID;



/* 2. Welche Städte haben ein höheres Kriminalitätsaufkommen als der U.S. Amerikanische Durchschnitt? */
SELECT CITY, CRIME.VALUE
FROM LOCATION 
INNER JOIN CRIME ON LOCATION.ID = CRIME.LOCATION_ID
WHERE CRIME.VALUE > (SELECT AVG(CRIME.VALUE) FROM CRIME);

/* 3. Welche Städte haben ein höheres Gewaltaufkommen als der U.S. Amerikanische Durchschnitt? */
SELECT CITY, VIOLENCE.VALUE
FROM LOCATION 
INNER JOIN VIOLENCE ON LOCATION.ID = VIOLENCE.LOCATION_ID
WHERE VIOLENCE.VALUE > (SELECT AVG(VIOLENCE.VALUE) FROM VIOLENCE);

SELECT AOLDATA.QUERYDATA_IDX.Query FROM AOLDATA.QUERYDATA_IDX WHERE AOLDATA.QUERYDATA_IDX.ANONID = 36;

/* 4. Welche Städte wurden in den Suchen (am häufigsten) mit einem unserer Stichworten in Verbindung gebracht? */ 
SELECT AOLDATA.QUERYDATA_IDX.ANONID, AOLDATA.LOCATION.CITY, AOLDATA.QUERYDATA_IDX.Query /*Count(LOCATIONMATCHVIEW.LOCATION_ID) AS Number_of_matches*/
FROM AOLDATA.LOCATION, LOCATIONMATCHVIEW, AOLDATA.QUERYDATA_IDX LEFT JOIN
(SELECT ACTIVE_DEFENSE.KEYWORD
FROM ACTIVE_DEFENSE
UNION
SELECT PASSIVE_DEFENSE.KEYWORD
FROM PASSIVE_DEFENSE) KEYWORDS
ON CONTAINS  (AOLDATA.QUERYDATA_IDX.Query, KEYWORDS.KEYWORD,1)>0
WHERE AOLDATA.QUERYDATA_IDX.ANONID = LOCATIONMATCHVIEW.ANONID
AND LOCATIONMATCHVIEW.LOCATION_ID = AOLDATA.LOCATION.ZIP
/*AND AOLDATA.QUERYDATA_IDX.ANONID = 36*/
AND ROWNUM <= 1
/*GROUP BY LOCATIONMATCHVIEW.LOCATION_ID, AOLDATA.LOCATION.CITY*/;

/* 5. Wie oft suchen die Nutzer nach passiver Verteidigung? */
SELECT COUNT(AOLDATA.QUERYDATA_IDX.Query)
FROM 
AOLDATA.QUERYDATA_IDX	, PASSIVE_DEFENSE
WHERE  
CONTAINS (AOLDATA.QUERYDATA_IDX.Query , PASSIVE_DEFENSE.KEYWORD , 1)>0;

/* 6. Wie oft suchen die Nutzer nach aktiver Verteidigung? */
SELECT COUNT(AOLDATA.QUERYDATA_IDX.Query)
FROM 
AOLDATA.QUERYDATA_IDX , ACTIVE_DEFENSE
WHERE  
CONTAINS (AOLDATA.QUERYDATA_IDX.Query , ACTIVE_DEFENSE.KEYWORD , 1)>0;

/* 7. Wie oft wurde nach passiver im Vergleich zu aktiver Verteidigung gesucht? 
- Die Ergebnisse aus fünf und sechs geben uns die Antwort auf diese Frage. Wir bekommen jeweils eine Zahl zurück geliefert und können daraus ein Tortendiagramm erstellen. 
- Da unsere Anfragen momentan noch kein endgültiges Ergebnis liefern, gibt es auch noch keine Auswertung hierfür. 
*/

/* 8. Welche Internetseiten wurden über die Suche nach aktiver Verteidigung am häufigsten besucht? */

/* 9. Welche Internetseiten wurden über die Suche nach passiver Verteidigung am häufigsten besucht? */

/* 10. Wenn der Nutzer auf eine Internetseite einer unserer Kategorien klickt, können wir aus seinen anderen Anfragen auf den Standort schließen? */

/* 11. Wo wird am wenigsten/meisten nach passiver und aktiver Verteidigung im Verhältnis zu Bevölkerungszahl gesucht? */
