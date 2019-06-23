/* Lecture de fpclie.i pour extraire les mots de passe */

{dfvarenv.i "NEW SHARED"}         
{asvarenv.i}

DEFINE VARIABLE cFichierEntree AS CHARACTER NO-UNDO.
DEFINE VARIABLE cFichierSortie AS CHARACTER NO-UNDO.
DEFINE VARIABLE cLigne AS CHARACTER NO-UNDO.
DEFINE VARIABLE cLibelle AS CHARACTER NO-UNDO.
DEFINE VARIABLE lWhenTrouve AS LOGICAL NO-UNDO.
DEFINE VARIABLE cMdp AS CHARACTER NO-UNDO.


DEFINE STREAM sEntree.
DEFINE STREAM sSortie.

cFichierEntree = reseau + "gidev\src\fpclie.i".
cFichierSortie = ser_log + "\fpclie.mdp".

INPUT STREAM sEntree FROM VALUE(cFichierEntree).
OUTPUT STREAM sSortie TO VALUE(cFichierSortie).

REPEAT:
    IMPORT STREAM sEntree UNFORMATTED cLigne.
    cLigne = TRIM(cLigne).
    IF cLigne = "" THEN NEXT.
    IF cLigne BEGINS "WHEN" THEN DO:
        /* Extraction du libellé */
        cLibelle = ENTRY(2,cLigne,"~"").
        lWhenTrouve = TRUE.
    END.
    IF cLigne MATCHES "*motpasse.w*" THEN DO:
        /* Si pas la suite logique du libellé on ne fait rien */
        IF NOT(lWhenTrouve) THEN NEXT.
        /* Extraction du mot de passe */
        cMdp = ENTRY(6,cLigne,"~"").
        cMdp = REPLACE(cMdp,"'","").
        IF cMdp = "" THEN cMdp = "Mot de passe INS".
        PUT STREAM sSortie UNFORMATTED "Paramètres client§" + cLibelle + "§" + cMdp SKIP.
        lWhenTrouve = FALSE.
    END.
    
END.

OUTPUT STREAM sSortie CLOSE.
INPUT STREAM sEntree CLOSE.