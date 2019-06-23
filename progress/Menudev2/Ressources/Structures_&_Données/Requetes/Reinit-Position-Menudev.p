FOR EACH prefs WHERE cutilisateur = "PPL"
AND cCode = "POSITION":
    DISPLAY prefs WITH 1 COL WIDTH 200.
    DELETE prefs.
END.
