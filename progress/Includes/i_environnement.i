/*--------------------------------------------------------------------------*
| Programme        : i_environnement.i                                      |
| Objet            : Gestion de l'environnement d'execution                 |
|---------------------------------------------------------------------------|
| Date de création : 07/04/2008                                             |
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

{dfvarenv.i}
{asvarenv.i}

    FUNCTION AfficheDebug RETURNS LOGICAL () FORWARD.
    FUNCTION ActiveDebug RETURNS LOGICAL () FORWARD.
    FUNCTION DesactiveDebug RETURNS LOGICAL () FORWARD.
    FUNCTION StockDebug RETURNS LOGICAL (cLibelle-in AS CHARACTER) FORWARD.

/*-------------------------------------------------------------------------*
 | DEFINITIONS                                                             |
 *-------------------------------------------------------------------------*/
 
    DEFINE {1} SHARED VARIABLE glDebug                 AS LOGICAL NO-UNDO INIT FALSE.
    DEFINE {1} SHARED VARIABLE gcDebug                 AS CHARACTER EXTENT 50 NO-UNDO.    

    DEFINE {1} SHARED VARIABLE gcRepertoireApplication AS CHARACTER NO-UNDO.
    DEFINE {1} SHARED VARIABLE gcRepertoireExecution   AS CHARACTER NO-UNDO INIT ?.
    DEFINE {1} SHARED VARIABLE gcRepertoireRessources  AS CHARACTER NO-UNDO.
    DEFINE {1} SHARED VARIABLE gcRepertoireTempo       AS CHARACTER NO-UNDO.
    DEFINE {1} SHARED VARIABLE gcRepertoireBase        AS CHARACTER NO-UNDO.
    DEFINE {1} SHARED VARIABLE gcNomApplication        AS CHARACTER NO-UNDO.
    DEFINE {1} SHARED VARIABLE gcUtilisateur           AS CHARACTER NO-UNDO.
    DEFINE {1} SHARED VARIABLE gcSautLigne             AS CHARACTER NO-UNDO.
    DEFINE {1} SHARED VARIABLE gcRepertoireRessourcesImages         AS CHARACTER NO-UNDO.
    DEFINE {1} SHARED VARIABLE gcRepertoireRessourcesSons           AS CHARACTER NO-UNDO.
    DEFINE {1} SHARED VARIABLE gcRepertoireRessourcesDocumentations as CHARACTER NO-UNDO.
    DEFINE {1} SHARED VARIABLE gcRepertoireRessourcesParametres     AS CHARACTER NO-UNDO.
    DEFINE {1} SHARED VARIABLE gcRepertoireRessourcesUtilisateurs   AS CHARACTER NO-UNDO.
    
    DEFINE {1} SHARED VARIABLE cTempo1                 AS CHARACTER NO-UNDO.
    DEFINE {1} SHARED VARIABLE cTempo2                 AS CHARACTER NO-UNDO.
    DEFINE {1} SHARED VARIABLE iTempo1                 AS INTEGER   NO-UNDO.
    DEFINE {1} SHARED VARIABLE iTempo2                 AS INTEGER   NO-UNDO.
    DEFINE {1} SHARED VARIABLE dTempo1                 AS DATE      NO-UNDO.
    DEFINE {1} SHARED VARIABLE dTempo2                 AS DATE      NO-UNDO.
    DEFINE {1} SHARED VARIABLE decTempo1               AS DECIMAL   NO-UNDO.
    DEFINE {1} SHARED VARIABLE decTempo2               AS DECIMAL   NO-UNDO.
    DEFINE {1} SHARED VARIABLE lTempo1                 AS LOGICAL   NO-UNDO.
    DEFINE {1} SHARED VARIABLE lTempo2                 AS LOGICAL   NO-UNDO.

    DEFINE {1} SHARED VARIABLE iBoucle                 AS INTEGER   NO-UNDO.
    define {1} shared variable glNo-Version			   as logical	no-undo.
    define {1} shared variable glAdmin   			   as logical	no-undo.
    define {1} shared variable gcStart   			   as CHARACTER	no-undo.
	DEFINE {1} SHARED VARIABLE glLogActif                		AS LOGICAL  	NO-UNDO INIT FALSE.

    /* Table temporaire des paramètres */
    DEFINE {1} SHARED TEMP-TABLE    glTbParametres
        FIELD   cCode        AS CHARACTER
        FIELD   cValeur      AS CHARACTER
        .
    
    DEFINE {1} SHARED VARIABLE hProcGene    AS HANDLE.
    
	DEFINE VARIABLE cListeJours 			AS CHARACTER 	NO-UNDO.
	DEFINE VARIABLE cListeJoursCourts 		AS CHARACTER 	NO-UNDO.
	DEFINE VARIABLE cListeMois 				AS CHARACTER 	NO-UNDO.
	DEFINE VARIABLE cListeMoisCourts	 	AS CHARACTER 	NO-UNDO.
    DEFINE VARIABLE cSuffixe                AS CHARACTER    NO-UNDO.
	
    /* Paramètrage de la session */
    SESSION:IMMEDIATE-DISPLAY = TRUE.
    SESSION:APPL-ALERT-BOXES = TRUE. 
       
    cSuffixe = OS-GETENV("SUFFIXE").
    IF cSuffixe = ? THEN cSuffixe = "".

    /* Affectation des variables globales si nécessaire */
    IF gcRepertoireExecution = /*<>*/ ? THEN DO:
    
    	/* Répertoire d'execution */
    	/*MESSAGE PROGRAM-NAME(1) VIEW-AS ALERT-BOX.*/
    	gcRepertoireExecution = PROGRAM-NAME(1).
    	ENTRY(NUM-ENTRIES(gcRepertoireExecution,"\"),gcRepertoireExecution,"\") = "".
    
    	/* Répertoire de l'application */
    	gcRepertoireApplication = SUBSTRING(gcRepertoireExecution,1,LENGTH(gcRepertoireExecution) - 1).
    	ENTRY(NUM-ENTRIES(gcRepertoireApplication,"\"),gcRepertoireApplication,"\") = "".
    
    	/* Répertoire de base */
    	gcRepertoireBase = gcRepertoireApplication + "data\".
    
    	/* Répertoire Ressources */
    	gcRepertoireRessources = os-getenv("DEV") + "\Ressources\".
    
    	/* Répertoire Temporaire */
    	gcRepertoireTempo = os-getenv("TEMP") + "\".
    
    
        /* Affection du saut de ligne */
        gcSautLigne = CHR(10) + CHR(13).
    
        /* Récupération du code utilisateur */
        gcUtilisateur = OS-GETENV("DEVUSR").
        IF gcUtilisateur = "" OR gcUtilisateur = ? THEN DO:
            MESSAGE "Utilisateur introuvable !" 
                + gcSautLigne
                + "Veuillez saisir le nom de l'utilisateur."
                VIEW-AS ALERT-BOX ERROR
                TITLE "Contrôle de l'utilisateur..."
                .
            UPDATE gcUtilisateur LABEL "Code utilisateur : ".
        END.
        
        /* Initialisation du log */
		RUN VALUE(gcRepertoireExecution + "procgene.p") PERSISTENT SET hProcGene.

        /* Lancement de la procedure de forcage dans le programme maitre */
        RUN Forcage NO-ERROR.
        
        if session:parameter <> "" AND NUM-ENTRIES(SESSION:parameter) > 1 then do:
            gcStart = ENTRY(2,session:parameter).
        	gcUtilisateur = entry(1,gcStart,";"). 
        	IF NUM-ENTRIES(gcStart,";") > 1 THEN DO:
            	glNo-Version = entry(2,gcStart,";") matches "*NO-VERSION*".
            	glAdmin = entry(2,gcStart,";") matches "*ADMIN*".
            END.
        end.

    END.
    
    ON "ALT-F12" ANYWHERE DO:
        glDebug = NOT(glDebug).
    END.

    ON "CTRL-F12" ANYWHERE DO:
        AfficheDebug().
    END.

/* -------------------------------------------------------------------------
   Affichage d'un message de debug standardisé
   ----------------------------------------------------------------------- */
FUNCTION MDebug  RETURN LOGICAL (cLibelleMessage AS CHARACTER):
    /* Ajout du programme */
    cLibelleMessage = ""
        + "*** " + PROGRAM-NAME(1) + " ***"
        /*+ CHR(10) + CHR(10) + cLibelleMessage.*/
        + "%s%s" + cLibelleMessage.
    
    /* Affichage du message */    
    MESSAGE REPLACE(cLibelleMessage,"%s",CHR(10)) VIEW-AS ALERT-BOX INFORMATION TITLE "Debugging...".
END FUNCTION.

/*-------------------------------------------------------------------------*
  Fonction de génération d'un chaine d'information sur un format donné.
  Les informations à fournir sont dans la chaine  cGeneration-IN.
  Les mots clé entourés de % sont à remplacer par leur valeur sur l'instant
  exemple %date% remplacé par la date en cours, %reseau%, par la valeur du
  disque reseau, %heure%:%minutes% par l'heure : et les minutes etc...
 *-------------------------------------------------------------------------*/
FUNCTION RemplaceVariables RETURNS CHARACTER(cCommande-in AS CHARACTER,cModeRemplacement-in AS CHARACTER,dDate-in AS DATE,iHeure-in AS INTEGER): 
    
    DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO.
    DEFINE VARIABLE dDateEncours AS DATE NO-UNDO.
    DEFINE VARIABLE cDateEncours AS CHARACTER NO-UNDO.
    DEFINE VARIABLE iHeureEncours AS INTEGER NO-UNDO.
    DEFINE VARIABLE cHeureEncours AS CHARACTER NO-UNDO.
    
    DEFINE VARIABLE iJour  AS INTEGER  NO-UNDO.
    DEFINE VARIABLE cJour  AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE cJourCourt  AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE iMois  AS INTEGER  NO-UNDO.
    DEFINE VARIABLE cMois  AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE cMoisCourt  AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE iAnnee  AS INTEGER  NO-UNDO.
    DEFINE VARIABLE iHeures  AS INTEGER  NO-UNDO.
    DEFINE VARIABLE iMinutes AS INTEGER NO-UNDO.
    DEFINE VARIABLE iSecondes AS INTEGER NO-UNDO.
    DEFINE VARIABLE iJourSemaine AS INTEGER NO-UNDO.
    
    cRetour = cCommande-in.
    
    /* Repères */
    dDateEncours = TODAY.
    IF dDate-in <> ? THEN dDateEncours = dDate-in.
    iHeureEncours = TIME.
    IF iHeure-in <> ? THEN iHeureEncours = iHeure-in.
    
    /* Génération des valeurs */
    cDateEncours = STRING(dDateEncours,"99/99/9999").
    cHeureEncours = STRING(iHeureEncours,"HH:MM:SS").
    iJour = DAY(dDateEncours).
    iMois = MONTH(dDateEncours).
    iAnnee = YEAR(dDateEncours).
    iHeures = INTEGER(ENTRY(1,cHeureEncours,":")).
    iMinutes = INTEGER(ENTRY(2,cHeureEncours,":")).
    iSecondes = INTEGER(ENTRY(3,cHeureEncours,":")).
    iJourSemaine = WEEKDAY(dDateEncours).
    cJour = ENTRY(iJourSemaine,cListeJours).
    cJourCourt = ENTRY(iJourSemaine,cListeJoursCourts).
    cMois = ENTRY(iMois,cListeMois).
    cMoisCourt = ENTRY(iMois,cListeMoisCourts).

    IF cModeRemplacement-in = "*" OR cModeRemplacement-in = "ENV" THEN DO:
	     /* Remplacement des variable d'environnement */
	    cRetour = REPLACE(cRetour,"%dlc%",OS-GETENV("DLC")).
	    cRetour = REPLACE(cRetour,"%windir%",OS-GETENV("WINDIR")).
	    cRetour = REPLACE(cRetour,"%reseau%",reseau).
	    cRetour = REPLACE(cRetour,"%disque%",OS-GETENV("DISQUE")).
	    cRetour = REPLACE(cRetour,"%devusr%",OS-GETENV("DEVUSR")).
	    cRetour = REPLACE(cRetour,"%dev%",OS-GETENV("DEV")).
	    cRetour = REPLACE(cRetour,"%repgi%",OS-GETENV("REPGI")).
	    cRetour = REPLACE(cRetour,"%prowin%",prowin).
		cRetour = REPLACE(cRetour,"%Ser_appli%",Ser_appli).
		cRetour = REPLACE(cRetour,"%Ser_appdev%",Ser_appdev).
		cRetour = REPLACE(cRetour,"%Ser_Outils%",Ser_Outils).
		cRetour = REPLACE(cRetour,"%Ser_tmp%",Ser_tmp).
		cRetour = REPLACE(cRetour,"%Ser_Log%",Ser_Log).
		cRetour = REPLACE(cRetour,"%Ser_intf%",Ser_intf).
		cRetour = REPLACE(cRetour,"%ser_dat%",ser_dat).
		cRetour = REPLACE(cRetour,"%Loc_Outils%",Loc_Outils).
		cRetour = REPLACE(cRetour,"%Loc_appli%",Loc_appli).
		cRetour = REPLACE(cRetour,"%Loc_appdev%",Loc_appdev).
		cRetour = REPLACE(cRetour,"%Loc_tmp%",Loc_tmp).
		cRetour = REPLACE(cRetour,"%Loc_Log%",Loc_Log).
		cRetour = REPLACE(cRetour,"%Loc_intf%",Loc_intf).
	    cRetour = REPLACE(cRetour,"%Suffixe%",cSuffixe).
	END.
    
    IF cModeRemplacement-in = "*" OR cModeRemplacement-in = "PSEUDO" THEN DO:  
	    /* Remplacement des pseudo variables */
        cRetour = REPLACE(cRetour,"%date%",cDateEncours).
        cRetour = REPLACE(cRetour,"%date-%",REPLACE(cDateEncours,"/","-")).
        cRetour = REPLACE(cRetour,"%jj%",STRING(iJour,"99")).
        cRetour = REPLACE(cRetour,"%mm%",STRING(iMois,"99")).
        cRetour = REPLACE(cRetour,"%aa%",SUBSTRING(STRING(iAnnee,"9999"),3,2)).
        cRetour = REPLACE(cRetour,"%aaaa%",STRING(iAnnee,"9999")).
        cRetour = REPLACE(cRetour,"%jour%",cJour).
        cRetour = REPLACE(cRetour,"%j%",cJourCourt).
        cRetour = REPLACE(cRetour,"%mois%",cMois).
        cRetour = REPLACE(cRetour,"%m%",cMoisCourt).
        
        cRetour = REPLACE(cRetour,"%heure%",STRING(iHeureEncours,"HH:MM:SS")).
        cRetour = REPLACE(cRetour,"%heures%",STRING(iHeures,"99")).
        cRetour = REPLACE(cRetour,"%minutes%",STRING(iMinutes,"99")).
        cRetour = REPLACE(cRetour,"%secondes%",STRING(iSecondes,"99")).
	END.
	
    RETURN cRetour.
    
END FUNCTION.
    
/* -------------------------------------------------------------------------
   Affichage d'un message standardisé dans le fichier log
   ----------------------------------------------------------------------- */
FUNCTION MLog  RETURN LOGICAL (cLibelleMessage AS CHARACTER):
    IF NOT(glLogActif) THEN RETURN FALSE.
    IF VALID-HANDLE(hProcGene) THEN RUN MLog IN hProcGene (cLibelleMessage) NO-ERROR.
    RETURN TRUE.
END FUNCTION.

/* -------------------------------------------------------------------------
   Récupération d'une entrée dans une chaine avec gestion des incohérences
   ----------------------------------------------------------------------- */
FUNCTION DonneEntree  RETURN CHARACTER (iNumeroEntree AS INTEGER, cChaineSource AS CHARACTER, cSeparateur AS CHARACTER):
    DEFINE VARIABLE cRetour AS CHARACTER    NO-UNDO INIT "".
    DEFINE VARIABLE lErreur AS LOGICAL      NO-UNDO INIT FALSE.
        
    /* Gestion du séparateur par défaut */    
    IF cSeparateur = "" THEN cSeparateur = ",".

    /* Controles de cohérence des paramètres */
    IF iNumeroEntree = 0 THEN DO:
        IF NOT(lErreur) THEN MDEBUG(PROGRAM-NAME(2) + " -> " + "Entrée demandée : 0 -> Traitement impossible !").
        lErreur = TRUE.
    END.
    IF NUM-ENTRIES(cChaineSource,cSeparateur) < iNumeroEntree THEN DO:
        IF NOT(lErreur) THEN MDEBUG(PROGRAM-NAME(2) + " -> " + "Entrée demandée (" + STRING(iNumeroEntree) + ") > nombre d'entrées de la chaine source (" + STRING(NUM-ENTRIES(cChaineSource,cSeparateur)) + ") -> Traitement impossible !").
        lErreur = TRUE.
    END.

    /* si tout ok = Récupération de la valeur */
    IF NOT(lErreur) THEN DO:
        cRetour = ENTRY(iNumeroEntree,cChaineSource,cSeparateur).
    END.    
    
    /* Gestion du retour */
    RETURN cRetour.
    
END FUNCTION.

/* -------------------------------------------------------------------------
   Vidage dans un fichier de la table des paramètres
   ----------------------------------------------------------------------- */
FUNCTION VidageParametre  RETURN LOGICAL ():
    DEFINE VARIABLE lRetour AS LOGICAL NO-UNDO INIT TRUE.
    DEFINE VARIABLE cFichier AS CHARACTER NO-UNDO.
    
    /* Ouverture du fichier de sortie */
    cFichier = OS-GETENV("TEMP") + "\TableDesParametres.log".
    OUTPUT TO VALUE(cFichier).
    
    /* Recherche du parametre */
    FOR EACH  glTbParametres  NO-LOCK :
        EXPORT glTbParametres.
    END.    
    
    /* Fermeture du fichier */
    OUTPUT CLOSE.
    
    /* Gestion du retour */
    RETURN lRetour.

END FUNCTION.

/* -------------------------------------------------------------------------
   Récupération d'une valeur de la table des paramètres
   ----------------------------------------------------------------------- */
FUNCTION DonneParametre  RETURN CHARACTER (cCodeParametre AS CHARACTER):
    DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO INIT "".
    
    /* Recherche du parametre */
    FIND FIRST  glTbParametres  NO-LOCK
        WHERE   glTbParametres.cCode = cCodeParametre
        NO-ERROR.
    IF AVAILABLE(glTbParametres) THEN cRetour = glTbParametres.cValeur.
    
    /* Gestion du retour */
    RETURN cRetour.

END FUNCTION.

/* -------------------------------------------------------------------------
   Récupération d'une valeur de la table des paramètres et suppression
   ----------------------------------------------------------------------- */
FUNCTION DonneEtSupprimeParametre  RETURN CHARACTER (cCodeParametre AS CHARACTER):
    DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO INIT "".
    
    /* Recherche du parametre */
    FIND FIRST  glTbParametres  NO-LOCK
        WHERE   glTbParametres.cCode = cCodeParametre
        NO-ERROR.
    IF AVAILABLE(glTbParametres) THEN DO:
        cRetour = glTbParametres.cValeur.
        /* suppression de la valeur */
        DELETE glTbParametres.
    END.
    
    /* Gestion du retour */
    RETURN cRetour.

END FUNCTION.

/* -------------------------------------------------------------------------
   Assignation d'une valeur de la table des paramètres
   ----------------------------------------------------------------------- */
FUNCTION AssigneParametre  RETURN LOGICAL (cCodeParametre AS CHARACTER, cValeurParametre AS CHARACTER):
    DEFINE VARIABLE lRetour AS LOGICAL NO-UNDO INIT TRUE.
    
    /* Recherche du parametre */
    FIND FIRST  glTbParametres  EXCLUSIVE-LOCK
        WHERE   glTbParametres.cCode = cCodeParametre
        NO-ERROR.
    IF NOT(AVAILABLE(glTbParametres)) THEN DO:
        /* Création de la valeur */
        CREATE glTbParametres.
        glTbParametres.cCode = cCodeParametre.
    END.
    
    /* Mise à jour de la valeur */
    glTbParametres.cValeur = cValeurParametre.
    
    /* Gestion du retour */
    RETURN TRUE.

END FUNCTION.

/* -------------------------------------------------------------------------
   suppression d'une valeur de la table des paramètres
   ----------------------------------------------------------------------- */
FUNCTION SupprimeParametre  RETURN LOGICAL (cCodeParametre AS CHARACTER):
    DEFINE VARIABLE lRetour AS LOGICAL NO-UNDO INIT FALSE.
    
    /* Recherche du parametre */
    FIND FIRST  glTbParametres  EXCLUSIVE-LOCK
        WHERE   glTbParametres.cCode = cCodeParametre
        NO-ERROR.
    IF AVAILABLE(glTbParametres) THEN DO:
        /* suppression de la valeur */
        DELETE glTbParametres.
		lRetour = true.
    END.
    
    /* Gestion du retour */
    RETURN lRetour.

END FUNCTION.

/* -------------------------------------------------------------------------
   Affichage des infos de debugging
   ----------------------------------------------------------------------- */ 
FUNCTION AfficheDebug RETURNS LOGICAL ():
    DEFINE VARIABLE cLibelle AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE iBoucle  AS INTEGER      NO-UNDO.
    DEFINE VARIABLE lRetour  AS LOGICAL      NO-UNDO INIT FALSE.

    /* Si flag debugging pas actif : on sort */
    IF not(glDebug) THEN RETURN lRetour.

    DO iBoucle = 1 TO 20:
        IF gcDebug[iBoucle] <> "" THEN cLibelle = clibelle + gcSautLigne + gcDebug[iBoucle].
    END.

    /* Affichage des infos de debugging */
    MESSAGE 
        
        "gcRepertoireExecution = "      gcRepertoireExecution       SKIP
        "gcRepertoireApplication = "    gcRepertoireApplication     SKIP
        "gcRepertoireBase = "           gcRepertoireBase            SKIP
        "gcRepertoireRessources = "     gcRepertoireRessources      SKIP
        cLibelle
        
        VIEW-AS ALERT-BOX INFORMATION
        TITLE gcNomApplication + ":AfficheDebug...".

    lRetour = TRUE.
    RETURN lRetour.

END FUNCTION.


/* -------------------------------------------------------------------------
   Affectation des infos de debugging
   ----------------------------------------------------------------------- */ 
FUNCTION StockDebug RETURNS LOGICAL (cLibelle-in AS CHARACTER):
    DEFINE VARIABLE lRetour AS LOGICAL NO-UNDO INIT FALSE.
    DEFINE VARIABLE iBoucle AS INTEGER  NO-UNDO.
    DEFINE VARIABLE iPosition   AS INTEGER  NO-UNDO.

    /* Recherche d'une place libre */
    iPosition = 0.
    DO iBoucle = 1 TO 50:
        IF gcDebug[iBoucle] = "" THEN do:
            iPosition = iBoucle.    
            LEAVE.
        END.
    END.

    /* Stockage de la valeur */
    IF iPosition = 0 THEN do:
        MESSAGE "Plus de place pour les informations de debug ! "
            VIEW-AS ALERT-BOX ERROR
            TITLE "Debugging...".
    END.
    ELSE DO:
        gcDebug[iPosition] = cLibelle-in.
    END.

    /* gestion du retour */
    RETURN lRetour.

END FUNCTION.

/* -------------------------------------------------------------------------
   Activation du debugging
   ----------------------------------------------------------------------- */ 
FUNCTION ActiveDebug RETURNS LOGICAL ():
    DEFINE VARIABLE lRetour AS LOGICAL NO-UNDO INIT FALSE.

    glDebug = TRUE.

    /* gestion du retour */
    RETURN lRetour.

END FUNCTION.

/* -------------------------------------------------------------------------
   DesActivation du debugging
   ----------------------------------------------------------------------- */ 
FUNCTION DesactiveDebug RETURNS LOGICAL ():
    DEFINE VARIABLE lRetour AS LOGICAL NO-UNDO INIT FALSE.

    glDebug = FALSE.

    /* gestion du retour */
    RETURN lRetour.

END FUNCTION.


