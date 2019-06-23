/* Moulinette de génération/modification des activités pour tests et dev */

DEFINE VARIABLE dDateDepart AS DATE NO-UNDO.

/* Requête générée par menudev2 */
CURRENT-WINDOW:WIDTH = 300.

dDateDepart = DATE(03,13,2018).

/* Balayage de la table */
FOR EACH    ACTIVITE
    WHERE   ACTIVITE.cUtilisateur = ACTIVITE.cUtilisateur
	AND 	(ACTIVITE.dDate = dDateDepart OR ACTIVITE.dDate = dDateDepart + 1)
	AND 	ACTIVITE.cTypeActivite = ACTIVITE.cTypeActivite
	AND 	true
    :
    IF ACTIVITE.dDate = dDateDepart THEN ACTIVITE.dDate = TODAY - 1.
    IF ACTIVITE.dDate = dDateDepart + 1 THEN ACTIVITE.dDate = TODAY.
    
    DISPLAY 
    ACTIVITE.cUtilisateur FORMAT "X(20)"
	ACTIVITE.dDate FORMAT "99/99/9999"
	ACTIVITE.cTypeActivite FORMAT "x(32)"
	 
    WITH WIDTH 300.
END.
