/* 1. Von welchen Nutzern können wir durch die Suchanfragen auf seinen Standort schließen?*/
CREATE OR REPLACE VIEW LOCATIONVIEW AS
SELECT DISTINCT(AOLDATA.LOCATION.CITY) AS CITY, MIN(AOLDATA.LOCATION.ZIP) AS LOCATION_ID
FROM AOLDATA.LOCATION group by (AOLDATA.LOCATION.CITY)
ORDER BY CITY;

CREATE OR REPLACE VIEW LOCATIONMATCHVIEW AS
SELECT AOLDATA.QUERYDATA_IDX.ANONID,
LOCATIONVIEW.LOCATION_ID FROM AOLDATA.QUERYDATA_IDX,
LOCATIONVIEW WHERE CONTAINS(AOLDATA.QUERYDATA_IDX.QUERY, LOWER(LOCATIONVIEW.CITY), 1) > 0
  /*AND ROWNUM <= 10000 */
GROUP BY AOLDATA.QUERYDATA_IDX.ANONID, LOCATIONVIEW.LOCATION_ID
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

/* 4. Welche Städte wurden in den Suchen (am häufigsten) mit einem unserer Stichworten in Verbindung gebracht? */ 
SELECT LOCATIONMATCHVIEW.LOCATION_ID, Count(LOCATIONMATCHVIEW.LOCATION_ID)
FROM LOCATIONMATCHVIEW, AOLDATA.QUERYDATA_IDX LEFT JOIN
(SELECT ACTIVE_DEFENSE.KEYWORD
FROM ACTIVE_DEFENSE
UNION
SELECT PASSIVE_DEFENSE.KEYWORD
FROM PASSIVE_DEFENSE) KEYWORDS
ON CONTAINS  (AOLDATA.QUERYDATA_IDX.Query, KEYWORDS.KEYWORD,1)>0
WHERE AOLDATA.QUERYDATA_IDX.ANONID = LOCATIONMATCHVIEW.ANONID
AND ROWNUM <= 10
GROUP BY LOCATIONMATCHVIEW.LOCATION_ID;

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
