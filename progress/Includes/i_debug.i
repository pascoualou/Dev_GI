/*--------------------------------------------------------------------------*
| Programme        : i_debug.i                                              |
| Objet            : Ajout de procedures et fonctions de debugging en "live"|
|---------------------------------------------------------------------------|
| Date de cr‚ation : 09/09/2003                                             |
| Auteur(s)        : PL                                                     |
*---------------------------------------------------------------------------*
*---------------------------------------------------------------------------*
| Historique des modifications                                              |
|---------------------------------------------------------------------------|
|  Nø  |    Date    | Auteur |                  Objet                       |
|------+------------+--------+----------------------------------------------|
|      |            |        |                                              |
*--------------------------------------------------------------------------*/

/* UTILISATION DU MODE DEBUG :

  Pour tout programme contenant l'include debug.i, il est possible d'afficher 
  des messages ou de faire un traitement spécifique en fonction d'un mode 
  debug actif ou non. Les fonctions et procédures suivantes ne travaillent que 
  si le mode debug est actif...
  Ce mode peut être activé ou désactivé dans le programme en question par les 
  touches : "CTRL-SHIFT-ALT-D"

  Avantage : Vous pouvez laisser les commandes de debug dans le programme 
  livré aux clients. Toute action faite en mode debug = FALSE ne sera pas 
  executée.
  Chez le client, par télémaintenance, vous pouvez en activant le mode debug, 
  voir vos messages de debug et même éventuellement ne pas faire le traitement, 
  le simuler et sortir un fichier
  trace de ce qui aurait été fait. (Cf : adb/src/intf/annchest.p)

  Fonctions, procédures et variables utilisables :

	Debug_Flag_Actif	: Variable contenant l'etat du mode debug.
	Debug_Stream		: Stream du fichier debug (ouvert avec la Debug_Ouvre_Log()).

	Debug_Actif()		: Retourne l'etat actuel du mode debug (booléen)

  L'utilisateur dispose dans les programmes d'une variable de chaque type qu'il 
  peut utiliser dans le cadre du debugging :

  	Debug_Var_Int	: Variable de type 'Integer'.
  	Debug_Var_Dec	: Variable de type 'Decimal'.
  	Debug_Var_Dat	: Variable de type 'Date'.
  	Debug_Var_Cha	: Variable de type 'CHARACTER'.
  	Debug_Var_Log	: Variable de type 'LOGICAL'.
  	Debug_Libelle	: Variable de type 'CHARACTER'.


	Debug_Message(libelle)		: Permet d'afficher un message à l'écran.

	Debug_Message_log(libelle)	: Permet d'afficher un message dans le stream 'Debug_Stream'.
					  Ouvre le stream debug_stream sur le fichier 'Debug_Fichier'
					  avec comme mode d'ouverture  "APPEND" si le libelle du message est blanc.
					  Le répertoire de stockage est obligatoirement le répertoire 'tmp' du disque
					  de l'application (Variable d'environnement "DISQUE").

	Debug_Active_Debug(etat)	: Si  etat = ?, provoque une bascule du mode debug dans l'etat
					  contraire.
					  Sinon, passe le mode debug dans l'etat 'etat'.


	ATTENTION : Pour eviter tout conflit de variable, si vous ajoutez des variable ou fonction 
	ou procédures, merci de systematiquement faire commencer le nom par "debug_".
	Merci aussi de renseigner cette bannière afin que chacun sache ce qu'il peut utiliser et faire.
*/

/* *-----------------*
   | DEBUGGING       | -----------------------------------------------------
   *-----------------* */
/* Variables à usage interne */
DEFINE VARIABLE 	Debug_Flag_Actif	AS LOGICAL INIT FALSE	NO-UNDO.
DEFINE VARIABLE     Debug_FichierLog    AS CHARACTER            NO-UNDO.
DEFINE STREAM 		Debug_Stream.

/* Variables utilisables par l'utilisateur */
DEFINE VARIABLE		Debug_Var_Int		AS INTEGER	INIT 0		NO-UNDO.
DEFINE VARIABLE		Debug_Var_Cha		AS CHARACTER	INIT ""	NO-UNDO.
DEFINE VARIABLE		Debug_Var_Log		AS LOGICAL	INIT FALSE	NO-UNDO.
DEFINE VARIABLE		Debug_Var_Dat		AS DATE		INIT ?		NO-UNDO.
DEFINE VARIABLE		Debug_Var_Dec		AS DECIMAL	INIT 0		NO-UNDO.
DEFINE VARIABLE		Debug_Libelle		AS CHARACTER	INIT ""	NO-UNDO.

/* -------------------------------------------------------------------------
   Fonction pour savoir si debug actif ou non
   ----------------------------------------------------------------------- */
FUNCTION Debug_Actif RETURNS LOGICAL ():

	/* Pour l'instant aucun controle */
	RETURN (Debug_Flag_Actif).

END FUNCTION.

/* -------------------------------------------------------------------------
   Fonction de définition du fichier de debug
   ----------------------------------------------------------------------- */
FUNCTION Debug_Fichier RETURNS LOGICAL (Debug_FichierLogPrg AS CHARACTER):

    Debug_FichierLog = OS-GETENV("DEVTMP") + "\" + Debug_FichierLogPrg.
    
	/* Retour */
	RETURN (TRUE).

END FUNCTION.

/* -------------------------------------------------------------------------
   Fonction d'ecriture à l'ecran des infos de debug
   ----------------------------------------------------------------------- */
FUNCTION Debug_Message RETURNS LOGICAL (Debug_Libelle AS CHARACTER):

	/* Si pas option debug : on quitte */
	IF NOT Debug_actif() THEN RETURN (FALSE).

	/* Remplacement des %s par des sauts de ligne */
	Debug_Libelle = REPLACE(Debug_Libelle,"%s",CHR(10)).

	/* ecriture à l'ecran du message */
	MESSAGE Debug_Libelle VIEW-AS ALERT-BOX INFORMATION TITLE "Debugging ...".

	/* Retour */
	RETURN (TRUE).

END FUNCTION.

/* -------------------------------------------------------------------------
   Fonction d'ecriture des infos de debug dans le stream debug
   ----------------------------------------------------------------------- */
FUNCTION Debug_Message_Log RETURNS LOGICAL (Debug_libelle AS CHARACTER):

	/* Si pas option debug : on quitte */
	IF NOT Debug_Actif() THEN RETURN (FALSE).

	/* Remplacement des %s par des sauts de ligne */
	Debug_Libelle = REPLACE(Debug_Libelle,"%s",CHR(10)).

	/* Ouverture du fichier */
	IF Debug_Libelle <> "" THEN DO:
		OUTPUT STREAM Debug_Stream TO VALUE(Debug_FichierLog) APPEND.
	END.
	ELSE DO:
		OUTPUT STREAM Debug_Stream TO VALUE(Debug_FichierLog).
	END.

	IF Debug_Libelle <> "" THEN DO:
    	/* ecriture dans le stream debug */
    	PUT STREAM Debug_Stream UNFORMATTED STRING(TIME,"hh:mm:ss") + " - " + Debug_Libelle SKIP.
    END.
    
	/* Fermeture du stream */
	OUTPUT STREAM Debug_Stream CLOSE.

	/* Retour */
	RETURN (TRUE).

END FUNCTION.

/* -------------------------------------------------------------------------
   Fonction de fermeture du stream de debug
   ----------------------------------------------------------------------- */
FUNCTION Debug_Active_Debug RETURNS LOGICAL (Debug_Etat	AS LOGICAL,Debug_Mode   AS CHARACTER):

	/* Bascule du flag debug */
	IF Debug_Etat <> ? THEN DO:
		/* Assignation de l'etat */
		Debug_Flag_Actif = Debug_Etat.
	END.
	ELSE DO:
		/* Bascule du flag debug */
		MESSAGE "Avant : " Debug_Flag_Actif.
		Debug_Flag_Actif = NOT(Debug_Flag_Actif).
		MESSAGE "Apres : " Debug_Flag_Actif.
	END.

	/* Affichage du message si necessaire */
	IF (Debug_Mode <> "MUET") THEN MESSAGE "Option debugging : " + STRING(Debug_Flag_Actif).

	/* Retour */
	RETURN (TRUE).

END FUNCTION.

/* -------------------------------------------------------------------------
   Trigger pour Activer/Desactiver le mode debug 
   ----------------------------------------------------------------------- */
ON "SHIFT-CTRL-ALT-D" ANYWHERE DO:

	/* Appel de la fonction avec ? = etat inconnu */
	Debug_Active_Debug(?,"").

END.

ON "SHIFT-CTRL-ALT-I" ANYWHERE DO:

	/* Appel de la fonction d'information dans le père */
	Debug_Active_Debug(TRUE,"MUET").
	RUN Debug_Informations.
	Debug_Active_Debug(FALSE,"MUET").
	
END.

