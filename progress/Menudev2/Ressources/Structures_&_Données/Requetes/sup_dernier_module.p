/* Requête générée par menudev2 */
CURRENT-WINDOW:WIDTH = 300.

/* Balayage de la table */
FOR EACH    PREFS
    WHERE   PREFS.cUtilisateur = "pof"
	AND 	PREFS.cCode = "dernier-module"
	AND 	PREFS.cValeur = PREFS.cValeur
	AND 	true
    :
    DISPLAY 
    PREFS.cUtilisateur FORMAT "X(20)"
	PREFS.cCode FORMAT "X(32)"
	PREFS.cValeur FORMAT "X(50)"
	 
    WITH WIDTH 300.
    DELETE prefs.
END.
