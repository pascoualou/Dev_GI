/*--------------------------------------------------------------------------*
| Programme        : i_dialogue.i                                           |
| Objet            : Gestion des messages et autres dialoque avec utilisat. |
|                    Attention : nécessite i_environnement.i                |
|---------------------------------------------------------------------------|
| Date de création : 09/04/2008                                             |
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
FUNCTION MsgInformation RETURNS LOGICAL(cMessage-in AS CHARACTER):
	MESSAGE REPLACE(cMessage-in,"%s",gcSautLigne) VIEW-AS ALERT-BOX INFORMATION
		TITLE gcNomApplication.
	RETURN TRUE.
END FUNCTION.

/* -------------------------------------------------------------------------
   Procedure d'affichage d'un message de type question
   ----------------------------------------------------------------------- */
FUNCTION msgQuestion RETURNS LOGICAL(cMessage-in AS CHARACTER):
	MESSAGE REPLACE(cMessage-in,"%s",gcSautLigne) VIEW-AS ALERT-BOX QUESTION
        BUTTONS YES-NO
		TITLE gcNomApplication
		UPDATE lReponse AS LOGICAL.
	RETURN lReponse.
END FUNCTION.

/* -------------------------------------------------------------------------
   Procedure d'affichage d'un message d'erreur
   ----------------------------------------------------------------------- */
FUNCTION MsgErreur RETURNS LOGICAL(cMessage-in AS CHARACTER):
	MESSAGE REPLACE(cMessage-in,"%s",gcSautLigne) VIEW-AS ALERT-BOX ERROR
		TITLE gcNomApplication.
	RETURN TRUE.
END FUNCTION.

