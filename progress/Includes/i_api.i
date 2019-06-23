/*--------------------------------------------------------------------------*
| Programme        : i_api.i                                                |
| Objet            : gestion des procedure de l'api windows                 |
|                                                                           |
|---------------------------------------------------------------------------|
| Date de création : 23/07/2010                                             |
| Auteur(s)        : PL                                                     |
*---------------------------------------------------------------------------*
*---------------------------------------------------------------------------*
| Historique des modifications                                              |
|---------------------------------------------------------------------------|
|  Nø  |    Date    | Auteur |                  Objet                       |
|------+------------+--------+----------------------------------------------|
| .... | ../../.... |  ....  | .                                            |
|      |            |        |                                              |
*--------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 | DEFINITIONS                                                             |
 *-------------------------------------------------------------------------*/
/*-------------------------------------------------------------------------*
 | PROCEDURES & fonctions                                                  |
 *-------------------------------------------------------------------------*/
/* -------------------------------------------------------------------------
   Procedure d'affichage d'un message d'information
   ----------------------------------------------------------------------- */
DEFINE VARIABLE hFenetreEnCours AS INTEGER NO-UNDO.

FUNCTION DonneHandleFenetre RETURNS INTEGER (cClassFenetre AS CHARACTER, cTitreFenetre AS CHARACTER):

    DEFINE VARIABLE hRetour AS INTEGER NO-UNDO INIT 0.

    RUN FindWindowA(cClassFenetre,cTitreFenetre,OUTPUT hFenetreEnCours).
    hREtour = hFenetreEnCours.
    
    RETURN hRetour.
    
END FUNCTION.

PROCEDURE FindWindowA EXTERNAL "user32" :
/* -------------------------------------------------------------------------
   Procedure externe retournant la position de la souris dans la windows en cours
       à partir de la position sur l'écran physique
   ----------------------------------------------------------------------- */
   DEFINE INPUT  PARAMETER lpClassName         AS CHARACTER.
   DEFINE INPUT  PARAMETER lpWindowName     AS CHARACTER. 
   DEFINE RETURN PARAMETER ReturnValue AS LONG.
END PROCEDURE.

PROCEDURE Sleep EXTERNAL "KERNEL32.DLL":
    DEFINE INPUT PARAMETER intMilliseconds AS LONG.
END PROCEDURE.


