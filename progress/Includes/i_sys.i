FUNCTION Attends RETURNS LOGICAL (iTEmporisation-in AS INTEGER):

    DEFINE VARIABLE iBoucle AS INTEGER NO-UNDO.
    DEFINE VARIABLE iCompteur AS INTEGER NO-UNDO.

    IF iTemporisation-in <> 0 THEN DO:
        iTemporisation-in = iTemporisation-in * 10000.
        DO iBoucle = 1 TO iTemporisation-in:
            iCompteur = iCompteur + 1.
        END.
    END.
    
END FUNCTION.
