/*--------------------------------------------------------------------------*
| Programme        : i_son.i                                                |
| Objet            : procedures et fonctions sur les sons                   |
|---------------------------------------------------------------------------|
| Date de cr�ation : 29/03/2011                                             |
| Auteur(s)        : PL                                                     |
*---------------------------------------------------------------------------*
*---------------------------------------------------------------------------*
| Historique des modifications                                              |
|---------------------------------------------------------------------------|
|  N�  |    Date    | Auteur |                  Objet                       |
|------+------------+--------+----------------------------------------------|
| .... | ../../.... |  ....  | .                                            |
|      |            |        |                                              |
*--------------------------------------------------------------------------*/

PROCEDURE mciExecute EXTERNAL "winmm.dll" :
  DEFINE INPUT  PARAMETER lpstrCommand  AS CHAR.  /* Nom du fichier */
  DEFINE RETURN PARAMETER hInstance    AS LONG.   /* retour (true/false) */
END.


DEFINE VARIABLE lMciTempo AS INTEGER NO-UNDO.

PROCEDURE JoueSon:
    DEFINE INPUT PARAMETER cFichierSon AS CHARACTER NO-UNDO.    
    
    RUN mciExecute ("play " + cFichierSon,OUTPUT lMciTempo).

END PROCEDURE.