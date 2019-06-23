/*---------------------------------------------------------------------------
 Application      : MAGI
 Programme        : procgene.p
 Objet            : Procedures persistentes pour toute l'application
                    Implémentation à faire en compta !!
*---------------------------------------------------------------------------
 Date de création : 18/03/2009
 Auteur(s)        : PL
 Dossier analyse  : 
*---------------------------------------------------------------------------
 Entrée :
 Sortie :
 Appel  :
*---------------------------------------------------------------------------
 Modifications :
 0001   19/03/2009  PL  Ajout trigger pour l'édition du fichier log.
 0002   19/10/2009  PL  Prise en compte des sauts de ligne.          
 0003   08/09/2010  PL  Correction ligne blanche                    
 0004   25/11/2010  PL  Ajout effacement, marqueurs, infos nom fichier
 0005   11/02/2011  PL  Ajout %t pour séparation infos avec " / "     
*--------------------------------------------------------------------------*/


/*-------------------------------------------------------------------------*
 | DEFINITIONS                                                             |
 *-------------------------------------------------------------------------*/
DEFINE VARIABLE cFichierLog     AS CHARACTER    NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE iNiveauLog AS INTEGER    NO-UNDO.
DEFINE VARIABLE cMarqueur AS CHARACTER  NO-UNDO.
DEFINE new GLOBAL SHARED VARIABLE gcNomApplication        AS CHARACTER NO-UNDO.

/*-------------------------------------------------------------------------*
 | MAIN BLOCK                                                              |
 *-------------------------------------------------------------------------*/
    /* Nom du fichier log */
    cFichierLog = SESSION:TEMP-DIRECTORY + gcNomApplication + ".log".
    
    RUN PurgeLog.
    
    /* Trigger pour edition manuelle du fichier log */
    ON "SHIFT-CTRL-ALT-L" ANYWHERE DO:
        RUN MLog ("#EDITE#").
    END.

    ON "SHIFT-CTRL-ALT-J" ANYWHERE DO:
        RUN MLog ("#NOUVEAU#").
        MESSAGE "Fichier Log de l'application vidé."
            VIEW-AS ALERT-BOX INFORMATION
            TITLE "Gestion du log de " + gcNomApplication + "..."
            .
    END.

    ON "SHIFT-CTRL-ALT-K" ANYWHERE DO:
        cMarqueur = "M" + STRING(TIME).
        RUN MLog ("%s%s%s#TITRE#" + "*** Marqueur : " + cMarqueur + " ***%s%s%s").
        MESSAGE "Marqueur n° " + cMarqueur + " ajouté dans le log de l'application."
            VIEW-AS ALERT-BOX INFORMATION
            TITLE "Gestion du log de " + gcNomApplication + "..."
            .
    END.

/*-------------------------------------------------------------------------*
 | PROCEDURES                                                              |
 *-------------------------------------------------------------------------*/
PROCEDURE PurgeLog:
/* -------------------------------------------------------------------------
   Vérification de la date du fichier par rapport à la date du jour
    Purge si on change de date
   ----------------------------------------------------------------------- */
    FILE-INFO:FILENAME = cFichierLog.
    IF FILE-INFO:FILE-MOD-DATE <> TODAY THEN 
        OS-DELETE VALUE(cFichierLog) NO-ERROR.
    
END PROCEDURE.

PROCEDURE MLog:
/* -------------------------------------------------------------------------
   Affichage d'un message dans le fichier Log de l'application
    Traitements particuliers si le message contient les chaines suivantes :
    #PURGE#     : Lance le controle de date pour éventuellement purger le fichier
    #NOUVEAU#   : Efface le fichier log avant d'écrire dedans
    #TITRE#     : Le message est précédé et suivi d'une ligne de "-"
    #EDITE#     : Lance la visu du fichier via Notepad.exe
   ----------------------------------------------------------------------- */
    DEFINE INPUT PARAMETER cLibelleMessage AS CHARACTER.
    
    DEFINE VARIABLE cLibelleTempo       AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE cPrefixe            AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE iLongueurPrefixe    AS INTEGER      NO-UNDO.

	/* ajout SY le 16/07/2010 */
	IF cLibelleMessage = ? THEN cLibelleMessage = "??".
	
    /* Purge du fichier log */
    IF cLibelleMessage MATCHES "*#PURGE#*" THEN DO:
        RUN PurgeLog.
        RETURN.
    END.
    
    /* ouverture du fichier */
    IF cLibelleMessage MATCHES "*#NOUVEAU#*" THEN DO:
        OUTPUT TO VALUE(cFichierLog).
        PUT UNFORMATTED "Fichier log de Versions : " + cFichierLog SKIP.
        PUT UNFORMATTED FILL("-",80) SKIP(1).
    END.
    ELSE
        OUTPUT TO VALUE(cFichierLog) APPEND.
         
    /* Entete de titre */
    IF cLibelleMessage MATCHES "*#TITRE#*" THEN 
        PUT UNFORMATTED FILL("-",80) SKIP.
    
    /* Epuration du libellé à afficher */
    cLibelleTempo = REPLACE(cLibelleMessage,"#NOUVEAU#","").
    cLibelleTempo = REPLACE(cLibelleTempo,"#TITRE#","").
    cLibelleTempo = REPLACE(cLibelleTempo,"#EDITE#","").
    IF cLibelleTempo BEGINS "%s" THEN cLibelleTempo = CHR(10) + SUBSTRING(cLibelleTempo,3).
    
    /* Stockage du message si pas à blanc */ 
    IF TRIM(cLibelleTempo) <> "" THEN DO:
        
        /* Constitution du prefixe de la ligne */
        cPrefixe = STRING(TODAY,"99/99/9999") + " - " + STRING(TIME,"hh:mm:ss")+ " - " + ENTRY(NUM-ENTRIES(PROGRAM-NAME(2),"\"),PROGRAM-NAME(2),"\").
        iLongueurPrefixe = LENGTH(cPrefixe) + 3.
        
        /* Ajout du programme */
        /* Seul le premier saut de ligne est pris en compte, les autres sont remplacés par "" */
        cLibelleTempo = cPrefixe
         + " - " + REPLACE(cLibelleTempo,"%s ",CHR(10) + FILL(" ",iLongueurPrefixe)).
        cLibelleTempo = REPLACE(cLibelleTempo,"%s",CHR(10) + FILL(" ",iLongueurPrefixe)).
        cLibelleTempo = REPLACE(cLibelleTempo,"%t "," / ").
        cLibelleTempo = REPLACE(cLibelleTempo,"%t"," / ").
        PUT UNFORMATTED cLibelleTempo SKIP.
    END.

    /* Pied de titre */
    IF cLibelleMessage MATCHES "*#TITRE#*" THEN 
        PUT UNFORMATTED FILL("-",80) SKIP.
        
    /* Pour mettre une ligne blanche */
    IF cLibelleMessage = "%s" THEN 
        PUT UNFORMATTED " " SKIP.
    
    /* Fermeture du fichier */
    OUTPUT CLOSE.
    
    /* Edition (si nécessaire) du fichier */
    IF cLibelleMessage MATCHES "*#EDITE#*" THEN DO:
        OS-COMMAND NO-WAIT VALUE("notepad.exe " + cFichierLog).
    END.
    
END PROCEDURE.


