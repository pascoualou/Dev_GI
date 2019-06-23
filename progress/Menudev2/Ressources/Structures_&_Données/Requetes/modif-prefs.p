/* Requête générée par menudev2 */
CURRENT-WINDOW:WIDTH = 300.

/* Balayage de la table */
FOR EACH    PREFS
    WHERE   PREFS.cUtilisateur = "PPL"
	AND 	PREFS.cCode = "PREFS-BASES-FICHIERS-NOUVELLE-GESTION"
	AND 	PREFS.cValeur = PREFS.cValeur
	AND 	true
    :
    DISPLAY 
    PREFS.cUtilisateur FORMAT "X(20)"
	PREFS.cCode FORMAT "X(32)"
	PREFS.cValeur FORMAT "X(50)"
	 
    WITH WIDTH 300.
    UPDATE PREFS.cValeur.
END.

/* Balayage de la table */
FOR EACH    PREFS
    WHERE   PREFS.cUtilisateur = "PPL"
	AND 	PREFS.cCode = "PREFS-BASES-FICHIERS-NOUVELLE-GESTION-EFFACER-ANCIENS"
	AND 	PREFS.cValeur = PREFS.cValeur
	AND 	true
    :
    DISPLAY 
    PREFS.cUtilisateur FORMAT "X(20)"
	PREFS.cCode FORMAT "X(32)"
	PREFS.cValeur FORMAT "X(50)"
	 
    WITH WIDTH 300.
    UPDATE PREFS.cValeur.
END.



