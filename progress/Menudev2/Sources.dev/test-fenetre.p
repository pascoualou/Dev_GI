DEFINE VARIABLE hFenetreEnCours AS INTEGER NO-UNDO.
DEFINE VARIABLE cTitre AS CHARACTER NO-UNDO INIT "Sans titre - Bloc-notes".

UPDATE cTitre.

RUN FindWindowA("Notepad",cTitre,OUTPUT hFenetreEnCours).

MESSAGE "fenetre trouvée : " hFenetreEnCours SKIP hFenetreEnCours <> 0.

PROCEDURE FindWindowA EXTERNAL "user32" :
/* -------------------------------------------------------------------------
   Procedure externe retournant la position de la souris dans la windows en cours
       à partir de la position sur l'écran physique
   ----------------------------------------------------------------------- */
   DEFINE INPUT  PARAMETER lpClassName         AS CHARACTER.
   DEFINE INPUT  PARAMETER lpWindowName     AS CHARACTER. 
   DEFINE RETURN PARAMETER ReturnValue AS LONG.
END PROCEDURE.

