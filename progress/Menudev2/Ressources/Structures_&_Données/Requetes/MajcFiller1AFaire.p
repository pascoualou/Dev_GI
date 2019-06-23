                       /* Requête générée par menudev2 */
CURRENT-WINDOW:WIDTH = 300.

/* Balayage de la table */
FOR EACH    AFAIRE_LISTE
    WHERE   AFAIRE_LISTE.cFiller1 = AFAIRE_LISTE.cFiller1
	AND 	true
    :
    AFAIRE_LISTE.cFiller1 = "0".
    DISPLAY 
    AFAIRE_LISTE.cFiller1 FORMAT "x(50)"
	 
    WITH WIDTH 300.
END.
