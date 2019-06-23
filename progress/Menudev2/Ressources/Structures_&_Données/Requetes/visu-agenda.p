FOR EACH agenda NO-LOCK 
    WHERE agenda.cUtilisateur = "PPL" 
    AND agenda.ddate >= TODAY 
    AND agenda.iheuredebut >= INTEGER(replace(STRING(TIME,"hh:mm"),":","")):
    DISPLAY agenda WITH 1 COL WIDTH 200.
