/*--------------------------------------------------------------------------*
| Programme        : Menudev2.i                                             |
| Objet            : variables, tables, fonctions et procédures utilisées   |
|                    par menudev2 et ses modules                            |
|---------------------------------------------------------------------------|
| Date de cr‚ation : 2008                                                   |
| Auteur(s)        : PL                                                     |
*---------------------------------------------------------------------------*

*---------------------------------------------------------------------------*
| Historique des modifications                                              |
|---------------------------------------------------------------------------|
|  Nø  |    Date    | Auteur |                  Objet                       |
|------+------------+--------+----------------------------------------------|
| .... | ../../.... |  ....  | .                                            |
| 0001 | 05/11/2014 |  PL    | Ajout de ja gestion des jours ferie          |
*--------------------------------------------------------------------------*/

{includes\i_temps.i}

&SCOPED-DEFINE Tabulation 4

/*-------------------------------------------------------------------------*
 | DEFINITIONS                                                             |
 *-------------------------------------------------------------------------*/
 
/* --------------  PARTAGE -------------- */

DEFINE {1} SHARED VARIABLE gcFichierPrefs            		AS CHARACTER	NO-UNDO.
DEFINE {1} SHARED VARIABLE gcFichierDefs             		AS CHARACTER   	NO-UNDO.
DEFINE {1} SHARED VARIABLE gcFichierAgenda           		AS CHARACTER   	NO-UNDO.
DEFINE {1} SHARED VARIABLE gcFichierAFaire           		AS CHARACTER   	NO-UNDO.
DEFINE {1} SHARED VARIABLE ghGeneral                 		AS HANDLE      	NO-UNDO.
DEFINE {1} SHARED VARIABLE giModuleEnCours           		AS INTEGER     	NO-UNDO.
DEFINE {1} SHARED VARIABLE gcModuleEnCours           		AS CHARACTER   	NO-UNDO.
DEFINE {1} SHARED VARIABLE gcAllerRetour             		AS CHARACTER   	NO-UNDO.
DEFINE {1} SHARED VARIABLE gcTypeMemo                		AS CHARACTER   	NO-UNDO.
DEFINE {1} SHARED VARIABLE gcUtilisateurInitial      		AS CHARACTER   	NO-UNDO.
DEFINE {1} SHARED VARIABLE gdPositionXModule         		AS DECIMAL     	NO-UNDO.
DEFINE {1} SHARED VARIABLE gdPositionYModule         		AS DECIMAL     	NO-UNDO.
DEFINE {1} SHARED VARIABLE gdHauteur                 		AS DECIMAL     	NO-UNDO.
DEFINE {1} SHARED VARIABLE gdLargeur                 		AS DECIMAL     	NO-UNDO.
DEFINE {1} SHARED VARIABLE iCouleurAdmin             		AS INTEGER		NO-UNDO.
DEFINE {1} SHARED VARIABLE giHeure                   		AS INTEGER  	NO-UNDO.
DEFINE {1} SHARED VARIABLE glModificationAlarmes     		AS LOGICAL  	NO-UNDO.
DEFINE {1} SHARED VARIABLE glDemarrage               		AS LOGICAL  	NO-UNDO INIT TRUE.
DEFINE {1} SHARED VARIABLE glUtilisateurAdmin        		AS LOGICAL  	NO-UNDO INIT FALSE.
DEFINE {1} SHARED VARIABLE glBasesConnectees         		AS LOGICAL  	NO-UNDO INIT FALSE.
DEFINE {1} SHARED VARIABLE giLatenceMax              		AS INTEGER  	NO-UNDO INIT 4.
DEFINE {1} SHARED VARIABLE giLatenceInternet         		AS INTEGER  	NO-UNDO INIT 10.
DEFINE {1} SHARED VARIABLE giNiveauUtilisateur       		AS INTEGER  	NO-UNDO.
DEFINE {1} SHARED VARIABLE gcGroupeUtilisateur       		AS CHARACTER  	NO-UNDO.
DEFINE {1} SHARED VARIABLE giVersionUtilisateur      		AS INTEGER  	NO-UNDO.
DEFINE {1} SHARED VARIABLE gcJoursFeries             		AS CHARACTER  	NO-UNDO INIT "".
DEFINE {1} SHARED VARIABLE gcFichierLocal            		AS CHARACTER  	NO-UNDO INIT "".
DEFINE {1} SHARED VARIABLE gcCaracteresInterdits     		AS CHARACTER  	NO-UNDO INIT "/:()\<>?,;& ".
DEFINE {1} SHARED VARIABLE gcVersionProgress         		AS CHARACTER  	NO-UNDO INIT ?.
DEFINE {1} SHARED VARIABLE gcDroitsUtilisateur       		AS CHARACTER  	NO-UNDO INIT ?.    
DEFINE {1} SHARED VARIABLE giPosXMenudev   					AS INTEGER  	NO-UNDO.
DEFINE {1} SHARED VARIABLE giPosYMenudev   					AS INTEGER  	NO-UNDO.
DEFINE {1} SHARED VARIABLE giPosXMessage   					AS INTEGER  	NO-UNDO.
DEFINE {1} SHARED VARIABLE giPosYMessage   					AS INTEGER  	NO-UNDO.
DEFINE {1} SHARED VARIABLE gcAideAjouter 					AS CHARACTER 	NO-UNDO.
DEFINE {1} SHARED VARIABLE gcAideModifier 					AS CHARACTER 	NO-UNDO.
DEFINE {1} SHARED VARIABLE gcAideSupprimer 					AS CHARACTER 	NO-UNDO.
DEFINE {1} SHARED VARIABLE gcAideImprimer 					AS CHARACTER 	NO-UNDO.
DEFINE {1} SHARED VARIABLE gcAideRaf 						AS CHARACTER 	NO-UNDO.
DEFINE {1} SHARED VARIABLE gcRepertoireRessourcesPrivees	AS CHARACTER    NO-UNDO.
DEFINE {1} SHARED VARIABLE gcRepertoireImages  				AS CHARACTER    NO-UNDO.
DEFINE {1} SHARED VARIABLE glDeveloppeur  					AS LOGICAL    	NO-UNDO.
DEFINE {1} SHARED VARIABLE glBy-pass      					AS LOGICAL    	NO-UNDO.
DEFINE {1} SHARED VARIABLE gcUtilTrace 						AS CHARACTER 	NO-UNDO INIT "".
DEFINE {1} SHARED VARIABLE glUtilTrace 						AS LOGICAL 		NO-UNDO INIT FALSE.

/* A retirer après la version */
DEFINE {1} SHARED VARIABLE giPosX   						AS INTEGER  	NO-UNDO.
DEFINE {1} SHARED VARIABLE giPosY   						AS INTEGER  	NO-UNDO.
DEFINE {1} SHARED VARIABLE gdPositionX   					AS INTEGER  	NO-UNDO.
DEFINE {1} SHARED VARIABLE gdPositionY   					AS INTEGER  	NO-UNDO.

DEFINE {1} SHARED TEMP-TABLE gttParam
    FIELD cIdent    AS CHARACTER
    FIELD cValeur   AS CHARACTER
    .

DEFINE {1} SHARED TEMP-TABLE gttPrefs
    FIELD cIdent    AS CHARACTER
    FIELD cValeur   AS CHARACTER
    .

DEFINE {1} SHARED TEMP-TABLE gttModules
    FIELD cIdent    AS CHARACTER
    FIELD cLibelle  AS CHARACTER
    FIELD lFavoris  AS LOGICAL
    FIELD hModule   AS HANDLE
    FIELD cParametres AS CHARACTER
    FIELD cProgramme AS CHARACTER
    FIELD lAdmin    AS LOGICAL
    FIELD lVisible    AS LOGICAL
    FIELD iNiveau    AS INTEGER
    .

DEFINE {1} SHARED STREAM gstrEntree.
DEFINE {1} SHARED STREAM gstrSortie.
DEFINE {1} SHARED STREAM gstrAgenda.

/* --------------  LOCAL -------------- */

DEFINE VARIABLE cFichierInfos 			AS CHARACTER 	NO-UNDO.
DEFINE VARIABLE iTabulation 			AS INTEGER 		NO-UNDO INIT 0.

/* Structure pour lire les contenus des répertoires */
DEFINE TEMP-TABLE ttDir
    FIELD cNom AS CHARACTER
    FIELD cNomComplet AS CHARACTER
    FIELD cType AS CHARACTER
    
    INDEX ixttDir IS PRIMARY UNIQUE cNom
    .

DEFINE TEMP-TABLE ttLignes
    FIELD cLigne AS CHARACTER
    .

DEFINE STREAM sInfos.

/* ----------------------------------------------------------------------------------------------------------*/
    
    
	/* Assignation des variables globales */
    gcNomApplication = "Menudev2".
    gdHauteur = 20.6.
    gdLargeur = 166.
    gcRepertoireRessourcesPrivees = gcRepertoireApplication + "ressources\".
    gcRepertoireImages = gcRepertoireRessourcesPrivees + "Images\".
    gcFichierAgenda = OS-GETENV("TMP") + "\menudev2-agenda.log".
    gcFichierAfaire = gcRepertoireApplication + "A_Faire.txt".
    
	/* Assignation des variables de travail */
    cListeJours = "dimanche,lundi,mardi,mercredi,jeudi,vendredi,samedi".
    cListeJoursCourts = "dim,lun,mar,mer,jeu,ven,sam".
    cListeMois = "janvier,février,mars,avril,mai,juin,juillet,août,septembre,octobre,novembre,décembre".
    cListeMoisCourts = "jan,fév,mar,avr,mai,jui,jul,aoû,sep,oct,nov,déc".
    iCouleurAdmin = 14.
    
    
/* ----------------------------------------------------------------------------------------------------------*/
    
FUNCTION DonneProgramme RETURNS CHARACTER (cIdent-in AS CHARACTER):
	
	DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO INIT "".
	DEFINE BUFFER bgttModules FOR gttModules.
	
    /* recherche du module */
    FIND FIRST	bgttModules NO-LOCK
    	WHERE	bgttModules.cIdent = cIdent-in
    	NO-ERROR.
    IF AVAILABLE(bgttModules) THEN DO:
    	cRetour = bgttModules.cProgramme.
    END.

	RETURN cRetour.

END FUNCTION.

FUNCTION DonneNomModule RETURNS CHARACTER (cIdent-in AS CHARACTER):
	
	DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO INIT "".
	DEFINE BUFFER bgttModules FOR gttModules.
	
    /* recherche du module */
    FIND FIRST	bgttModules NO-LOCK
    	WHERE	bgttModules.cIdent = cIdent-in
    	NO-ERROR.
    IF AVAILABLE(bgttModules) THEN DO:
    	cRetour = bgttModules.cLibelle.
    END.

	RETURN cRetour.

END FUNCTION.

FUNCTION DonneVersionMenudev2 RETURNS INTEGER():
    
    DEFINE VARIABLE cLigne AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lASupprimer AS LOGICAL NO-UNDO.
    DEFINE VARIABLE iRetour AS INTEGER NO-UNDO INIT 0.
    define variable iTempo as integer no-undo.

    EMPTY TEMP-TABLE ttDir.
    INPUT FROM OS-DIR(gcRepertoireRessourcesPrivees + "Majs\").
    REPEAT:
        CREATE ttDir.
        IMPORT ttDir.   
    END.

    /* Epuration de la table */
    FOR EACH ttDir
        BY ttDir.cNom
        :
        lASupprimer = FALSE.
        IF ttDir.cType = "F" THEN lASupprimer = TRUE.
        IF ttDir.cNom = "999" THEN lASupprimer = TRUE.
        IF ttDir.cNom = "." THEN lASupprimer = TRUE.
        IF ttDir.cNom = ".." THEN lASupprimer = TRUE.
        if not(lASupprimer) then do:
        	iTempo =  INTEGER(ttDir.cNom) no-error.
        	if error-status:error then lASupprimer = TRUE.	
        end.
        
        IF lASupprimer THEN DELETE ttDir.
    END.

    FIND LAST ttDir NO-ERROR.
    IF AVAILABLE(ttDir) THEN iRetour = INTEGER(ttDir.cNom).
    RETURN iRetour.

END FUNCTION.

FUNCTION FormateValeur RETURNS CHARACTER (cValeur-in AS CHARACTER):
    DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO INIT "?".

    /* Pour, entre autres, les dates, pour ecriture dans un fichier (éviter les ?) */
    IF cValeur-in <> ? THEN cRetour = cValeur-in.

    RETURN cRetour.
    
END FUNCTION.

FUNCTION DonnePreferenceGenerale RETURNS CHARACTER ( INPUT cIdent-in AS CHARACTER ) :
    DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO INIT "".

    FIND FIRST  Prefs   NO-LOCK
        WHERE   Prefs.cUtilisateur = "menudev2"
        AND     Prefs.cCode = cIdent-in 
        NO-ERROR.
    IF AVAILABLE(Prefs) THEN cRetour = Prefs.cValeur.

    RETURN cRetour.   

END FUNCTION.

FUNCTION DonnePreference RETURNS CHARACTER ( INPUT cIdent-in AS CHARACTER ) :
    DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO INIT "".

    FIND FIRST  Prefs   NO-LOCK
        WHERE   Prefs.cUtilisateur = gcUtilisateur
        AND     Prefs.cCode = cIdent-in 
        NO-ERROR.
    IF AVAILABLE(Prefs) THEN cRetour = Prefs.cValeur.

    RETURN cRetour.   

END FUNCTION.

FUNCTION SupprimePreference RETURNS LOGICAL ( INPUT cIdent-in AS CHARACTER ) :

    FOR EACH    Prefs   EXCLUSIVE-LOCK
        WHERE   Prefs.cUtilisateur = gcUtilisateur
        AND     Prefs.cCode MATCHES cIdent-in 
        :
    	DELETE Prefs.
    END.

    RETURN TRUE.   

END FUNCTION.

FUNCTION DonnePreferenceUtilisateur RETURNS CHARACTER ( INPUT cUtilisateur-in AS CHARACTER, INPUT cIdent-in AS CHARACTER ) :
    DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO INIT "".

    FIND FIRST  Prefs   NO-LOCK
        WHERE   Prefs.cUtilisateur = cUtilisateur-in
        AND     Prefs.cCode = cIdent-in 
        NO-ERROR.
    IF AVAILABLE(Prefs) THEN cRetour = Prefs.cValeur.

    RETURN cRetour.   

END FUNCTION.

FUNCTION SauvePreference RETURNS LOGICAL ( INPUT cIdent-in AS CHARACTER,INPUT cValeur-in AS CHARACTER ) :

    DO TRANSACTION:
        FIND FIRST  Prefs   EXCLUSIVE-LOCK
            WHERE   Prefs.cUtilisateur = gcUtilisateur
            AND     Prefs.cCode = cIdent-in 
            NO-ERROR.
        IF cValeur-in <> "" THEN DO:
            IF not(AVAILABLE(Prefs)) THEN DO:
                CREATE Prefs.
            END.
            Prefs.cUtilisateur = gcUtilisateur.
            Prefs.cCode = cIdent-in.
            Prefs.cValeur = cValeur-in.
        END.
        ELSE DO:
            IF AVAILABLE(prefs) THEN DELETE prefs.
        END.
    END.    
    RELEASE prefs.
        
    RETURN TRUE.   

END FUNCTION.

FUNCTION SauvePreferenceUtilisateur RETURNS LOGICAL ( INPUT cUtilisateur-in AS CHARACTER, INPUT cIdent-in AS CHARACTER,INPUT cValeur-in AS CHARACTER ) :

    DO TRANSACTION:
        FIND FIRST  Prefs   EXCLUSIVE-LOCK
            WHERE   Prefs.cUtilisateur = cUtilisateur-in
            AND     Prefs.cCode = cIdent-in 
            NO-ERROR.
        IF cValeur-in <> "" THEN DO:
            IF not(AVAILABLE(Prefs)) THEN DO:
                CREATE Prefs.
            END.
            Prefs.cUtilisateur = cUtilisateur-in.
            Prefs.cCode = cIdent-in.
            Prefs.cValeur = cValeur-in.
        END.
        ELSE DO:
            IF AVAILABLE(prefs) THEN DELETE prefs.
        END.
    END.    
    RELEASE prefs.
        
    RETURN TRUE.   

END FUNCTION.

FUNCTION SauvePreferenceGenerale RETURNS LOGICAL ( INPUT cIdent-in AS CHARACTER,INPUT cValeur-in AS CHARACTER ) :

    DO TRANSACTION:
        FIND FIRST  Prefs   EXCLUSIVE-LOCK
            WHERE   Prefs.cUtilisateur = "menudev2"
            AND     Prefs.cCode = cIdent-in 
            NO-ERROR.
        IF cValeur-in <> "" THEN DO:
            IF not(AVAILABLE(Prefs)) THEN DO:
                CREATE Prefs.
            END.
            Prefs.cUtilisateur = "menudev2".
            Prefs.cCode = cIdent-in.
            Prefs.cValeur = cValeur-in.
        END.
        ELSE DO:
            IF AVAILABLE(prefs) THEN DELETE prefs.
        END.
    END.    
    RELEASE prefs.
        
    RETURN TRUE.   

END FUNCTION.

FUNCTION DonneOptionsControle RETURNS CHARACTER(cSeparateur-in AS CHARACTER):
	DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO.
	
	/* Récupération des infos standards */
	cRetour = "" 
		+ "fichier-log=Controle-Machine-" + gcUtilisateur + ".log"
		+ cSeparateur-in + "repertoire-bases=" + DonnePreference("REPERTOIRE-BASES")
		+ cSeparateur-in + "utilisateur=" + gcUtilisateur
		.
	/* Ajout des infos de controle */
	cRetour = cRetour 
		+ cSeparateur-in + "mail=" + DonnePreference("PREF-CONTROLE-MAIL")
		+ cSeparateur-in + "que-si-erreur=" + DonnePreference("PREF-CONTROLE-QUE-SI-ERREUR")
		+ cSeparateur-in + "repertoire-basesdos=" + os-getenv("DISQUE") + "Bases-Dos"
		+ cSeparateur-in + "bases=" + DonnePreference("PREF-CONTROLE-BASES")
		+ cSeparateur-in + "basedos=" + DonnePreference("PREF-CONTROLE-BASEDOS")
		+ cSeparateur-in + "disponible=" + DonnePreference("PREF-CONTROLE-DISPONIBLE")
		+ cSeparateur-in + "adresse-email=" + DonnePreference("EMAIL-UTILISATEUR")
		+ cSeparateur-in + "visu-log=" + DonnePreference("PREF-CONTROLE-VISU-LOG")
		+ cSeparateur-in + "svg-presente=" + DonnePreference("PREF-CONTROLE-SVG-PRESENTE")
		+ cSeparateur-in + "base+svg-presente=" + DonnePreference("PREF-CONTROLE-BASE+SVG-PRESENTE")
		+ cSeparateur-in + "fichier-7z=" + DonnePreference("PREF-CONTROLE-7Z")
		+ cSeparateur-in + "exclus=" + DonnePreference("PREF-CONTROLE-EXCLUS")
		+ cSeparateur-in + "quota=" + DonnePreference("PREF-CONTROLE-QUOTA")
		+ cSeparateur-in + "quota-valeur=" + DonnePreference("PREF-CONTROLE-QUOTA-VALEUR")
		.
	
	RETURN(cRetour).

END FUNCTION.    

FUNCTION JourFerie RETURN LOGICAL (dDateTestee AS DATE):
	
	DEFINE VARIABLE lRetour AS LOGICAL NO-UNDO INIT FALSE.
	DEFINE VARIABLE cRecherche AS CHARACTER NO-UNDO.
	
	/* constitution de la liste des jours feries */
	gcJoursFeries = DonnePreferenceGenerale("JOURSFERIESFIXES") + "," + DonnePreferenceGenerale("JOURSFERIESMOBILES").

	/* recherche jour fixe */
	cRecherche = STRING(day(dDateTestee),"99") + "/" + STRING(month(dDateTestee),"99").
	lRetour = (LOOKUP(cRecherche,gcJoursFeries) > 0).
	
	/* recherche jour mobile */
	cRecherche = STRING(dDateTestee,"99/99/9999").
	lRetour = (lRetour OR (LOOKUP(cRecherche,gcJoursFeries) > 0)).
	
	/* trace */
	MLog("JourFerie : "
	+ "%sdDateTestee = " + string(dDateTestee)
	+ "%sgcJoursFeries = " + gcJoursFeries
	+ "%slRetour = " + string(lRetour)
	).

	RETURN lRetour.
	
END FUNCTION.

FUNCTION VacancesScolaires RETURN LOGICAL (dDateTestee AS DATE):
	
	DEFINE VARIABLE lRetour 		AS LOGICAL 		NO-UNDO INIT FALSE.
	DEFINE VARIABLE cListePeriodes 	AS CHARACTER 	NO-UNDO.
	DEFINE VARIABLE dDateDebut 		AS DATE 		NO-UNDO.
	DEFINE VARIABLE dDateFin 		AS DATE 		NO-UNDO.
	DEFINE VARIABLE cTempo 			AS CHARACTER 	NO-UNDO.
	DEFINE VARIABLE iBoucle 		AS INTEGER 		NO-UNDO.
	
	cListePeriodes = DonnePreferenceGenerale("VACANCES-SCOLAIRES").

	DO iBoucle = 1 TO NUM-ENTRIES(cListePeriodes):
	    cTempo = ENTRY(iBoucle,cListePeriodes).
	    dDateDebut = DATE(ENTRY(1,cTempo,"-")).
	    dDateFin = DATE(ENTRY(2,cTempo,"-")).
    	IF (dDateTestee >= dDateDebut AND dDateTestee <= dDateFin) THEN DO:
            lRetour = TRUE.
    	END.
	END.

	/* trace */
	MLog("VacancesScolaires : "
	+ "%sdDateTestee = " + string(dDateTestee)
	+ "%cListePeriodes = " + cListePeriodes
	+ "%slRetour = " + string(lRetour)
	).

	RETURN lRetour.
	
END FUNCTION.

FUNCTION ModuleARecharger RETURNS LOGICAL(cFichier-in AS CHARACTER):
/* -------------------------------------------------------------------------
   Vérification si l'on doit recharger un module ou non. Si le fichier
   utilisé par ce module a été modifié depuis le dernier affichage du
   module
   ----------------------------------------------------------------------- */
    DEFINE VARIABLE lRetour AS LOGICAL NO-UNDO INIT FALSE.
    DEFINE VARIABLE cIdent AS CHARACTER NO-UNDO.

    cIdent = gcUtilisateur + "|" + cFichier-in.

    FIND FIRST  fichiers    NO-LOCK
        WHERE   fichiers.cUtilisateur = ""
        AND     fichiers.cIdentFichier = cFichier-in
        NO-ERROR.
    IF NOT(AVAILABLE(fichiers)) THEN DO:
        lRetour = FALSE.
    END.
    ELSE DO:    
        FIND FIRST  details  EXCLUSIVE-LOCK
            WHERE   details.iddet1 = cIdent
            NO-ERROR.
        IF NOT(AVAILABLE(details)) THEN DO:
            lRetour = TRUE.
            CREATE details.
            details.iddet1 = cIdent.
            details.vldet1 = fichiers.idModification.
        END.
        ELSE DO:
            IF fichiers.idModification <> details.vldet1 THEN do:
                lRetour = TRUE.
                details.vldet1 = fichiers.idModification.
            END.
        END.
    END.

    RELEASE fichiers.
    RELEASE details.

    RETURN(lRetour).

END FUNCTION.

FUNCTION ModificationAutorisee RETURNS LOGICAL(cFichier-in AS CHARACTER):
    DEFINE VARIABLE lRetour AS LOGICAL NO-UNDO INIT FALSE.

    /* on cherche un fichier administrateur = util = "" et ladmin = true */
    FIND FIRST  fichiers    NO-LOCK
        WHERE   fichiers.cUtilisateur = ""
        AND     fichiers.cIdentFichier = cFichier-in
        NO-ERROR.
    IF NOT(AVAILABLE(fichiers)) THEN DO:
        /* Le fichier n'esiste pas 'tout utilisateur' on peut donc le modifier */
        lRetour = TRUE.
    END.
    ELSE DO:
        /* Il faut être administrateur pour modifier le fichier */
        IF fichiers.ladmin AND glUtilisateurAdmin THEN lRetour = TRUE.
    END.

    RELEASE fichiers.

    RETURN(lRetour).

END FUNCTION.

FUNCTION DonneVraiNomUtilisateur RETURNS CHARACTER (cUtilisateur-in AS CHARACTER):
	DEFINE VARIABLE cRetour  AS CHARACTER NO-UNDO INIT "?.?.?".

	/* On commence par prendre le nom éventuellement saisi pas l'utilisateur */
    cRetour = DonnePreferenceUtilisateur(cUtilisateur-in,"PREF-VRAI-NOM").
    
    /* Sinon on prend de nom fourni dans la base pour cet utilisateur */
    IF cRetour = "" THEN DO:
	    /* Recherche de l'utilisateur en cours */
	    FIND FIRST  Utilisateurs    NO-LOCK
	        WHERE  Utilisateurs.cUtilisateur = cUtilisateur-in
	        NO-ERROR.
	    IF AVAILABLE(Utilisateurs) THEN DO:
	    	cRetour = Utilisateurs.cVraiNom.
		END.
	END.	
	
	/* Et sinon, le vrai nom sera le code utilisateur */
	IF cRetour = "" THEN cRetour = cUtilisateur-in.
	
	RETURN cRetour.
	
END FUNCTION.

FUNCTION DonneTypeAbsence RETURNS CHARACTER (cTypeAbsence-in AS CHARACTER):
	DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO INIT "".
	
	IF cTypeAbsence-in = "C" THEN cRetour = "Congés".
	IF cTypeAbsence-in = "M" THEN cRetour = "Maladie".
	IF cTypeAbsence-in = "A" THEN cRetour = "Autre".
	IF cTypeAbsence-in = "FC" THEN cRetour = "Formation (Client)".
	IF cTypeAbsence-in = "FG" THEN cRetour = "Formation (GI)".
	
	RETURN cRetour.

END FUNCTION.

FUNCTION DecoupeLigne RETURNS INTEGER ( cLigne-in AS CHARACTER ) :
      DEFINE VARIABLE iRetour AS INTEGER NO-UNDO INIT 0.
      DEFINE VARIABLE iMax AS INTEGER NO-UNDO.
      DEFINE VARIABLE cTempo AS CHARACTER NO-UNDO.

	  if cLigne-in = ? then cLigne-in = "*** erreur ***".

      iMax = 113 - (iTabulation * {&Tabulation}).

      EMPTY TEMP-TABLE ttLignes.
      cTempo = cLigne-in.
      REPEAT:
          IF LENGTH(cTempo) <= iMax THEN LEAVE.
          CREATE ttLignes.
          ttLignes.cLigne = SUBSTRING(cTempo,1,iMax).
          cTempo = SUBSTRING(cTempo,iMax + 1).
          iRetour = iRetour + 1.
      END.
      CREATE ttLignes.
      ttLignes.cLigne = cTempo.
      iRetour = iRetour + 1.

      RETURN iRetour.

END FUNCTION.

FUNCTION EcritLigne RETURNS LOGICAL (cInformation-in AS CHARACTER, iSautLigne-in AS INTEGER):
    DEFINE VARIABLE cTabulation AS CHARACTER NO-UNDO.
    DEFINE VARIABLE iNombreLignes AS INTEGER NO-UNDO.

    IF iTabulation > 0 THEN cTabulation = FILL(" ",iTabulation * {&Tabulation}).

    IF cInformation-in = "#VIDE#" THEN DO:
        OUTPUT STREAM sInfos TO value(cFichierInfos).
    END.
    ELSE DO:
        iNombreLignes = DecoupeLigne(cInformation-in).
        if iNombreLignes = 0 then RETURN TRUE.
        OUTPUT STREAM sInfos TO value(cFichierInfos) APPEND.
        FOR EACH ttLignes:
            PUT STREAM sInfos UNFORMATTED cTabulation + ttLignes.cLigne SKIP.
        END.
        IF iSautLigne-in > 1 THEN DO:
            PUT STREAM sInfos UNFORMATTED " " SKIP(iSautLigne-in - 1).    
        END.
    END.
    OUTPUT STREAM sInfos CLOSE.

    RETURN TRUE.

END FUNCTION.

FUNCTION AjouteRetireTabulation RETURNS LOGICAL ( iNombre-in AS INTEGER ) :
	iTabulation = iTabulation + iNombre-in.
	IF iTabulation < 0 THEN iTabulation = 0.

	RETURN TRUE.

END FUNCTION.

FUNCTION EcritTitre RETURNS LOGICAL (cInformation-in AS CHARACTER, iSautLigne-in AS INTEGER) :

    EcritLigne(cInformation-in,1).
    EcritLigne(FILL("-",LENGTH(cInformation-in)),iSautLigne-in).

    RETURN TRUE.

END FUNCTION.
    
FUNCTION DonneRepertoireApplication RETURNS CHARACTER (cType-in AS CHARACTER):
	
	DEFINE VARIABLE cTempo    AS CHARACTER NO-UNDO INIT "".
	DEFINE VARIABLE cPrefixe  AS CHARACTER NO-UNDO init "PREFS-REP&1".
	DEFINE VARIABLE cRetour   AS CHARACTER NO-UNDO INIT "".
	
	IF cType-in = "DEV"  then cTempo = substitute(cPrefixe,"GIDEV").
	IF cType-in = "CLI"  then cTempo = substitute(cPrefixe,"GI").
	IF cType-in = "PREC" then cTempo = substitute(cPrefixe,"GIPREC").
	IF cType-in = "SUIV" then cTempo = substitute(cPrefixe,"GISUIV").
	IF cType-in = "SPE"  then cTempo = substitute(cPrefixe,"GISPE").
	
	cRetour = DonnePreference(cTempo).
	
	/* Si rien de saisi dans les préférences */
	if cRetour = "" then do:
		IF cType-in = "DEV"  then cRetour = "gidev".
		IF cType-in = "CLI"  then cRetour = "gi".
		IF cType-in = "PREC" then cRetour = "gi_prec".
		IF cType-in = "SUIV" then cRetour = "gi_suiv".
		IF cType-in = "SPE"  then cRetour = "gi_spe".
		cRetour = cRetour + cSuffixe.
	end.

	/* Si version autre que CLI ou DEV, on ajoute le répertoire "gi" */
	IF cType-in = "PREC" or cType-in = "SUIV" or cType-in = "SPE"  then cRetour = cRetour + "\gi".
		
	RETURN cRetour.

END FUNCTION.

FUNCTION DonneDisqueApplication RETURNS CHARACTER (cType-in AS CHARACTER):
	
	DEFINE VARIABLE cTempo    AS CHARACTER NO-UNDO INIT "".
	DEFINE VARIABLE cPrefixe  AS CHARACTER NO-UNDO init "PREFS-REP&1".
	DEFINE VARIABLE cRetour   AS CHARACTER NO-UNDO INIT "".
	
	IF cType-in = "DEV"  then cTempo = "".
	IF cType-in = "CLI"  then cTempo = "".
	IF cType-in = "PREC" then cTempo = substitute(cPrefixe,"GIPREC").
	IF cType-in = "SUIV" then cTempo = substitute(cPrefixe,"GISUIV").
	IF cType-in = "SPE"  then cTempo = substitute(cPrefixe,"GISPE").
	
	cRetour = DonnePreference(cTempo).
	
	/* Si rien de saisi dans les préférences */
	if cRetour = "" then do:
		IF cType-in = "DEV"  then cRetour = "".
		IF cType-in = "CLI"  then cRetour = "".
		IF cType-in = "PREC" then cRetour = "gi_prec" + cSuffixe.
		IF cType-in = "SUIV" then cRetour = "gi_suiv" + cSuffixe.
		IF cType-in = "SPE"  then cRetour = "gi_spe" + cSuffixe.
	end.

	/* Dans tous les cas on ajoute le disque */
	cRetour = disque + cRetour.
	if cType-in <> "DEV" and cType-in <> "CLI" then cRetour = cRetour + "\". 
	
/*	mdebug("cType-in / disque = " + cType-in + " / " + cRetour).*/
	RETURN cRetour.

END FUNCTION.

FUNCTION DonneRepGIApplication RETURNS CHARACTER (cType-in AS CHARACTER):
	
	DEFINE VARIABLE cTempo    AS CHARACTER NO-UNDO INIT "".
	DEFINE VARIABLE cPrefixe  AS CHARACTER NO-UNDO init "PREFS-REP&1".
	DEFINE VARIABLE cRetour   AS CHARACTER NO-UNDO INIT "".
	
	IF cType-in = "DEV"  then cTempo = substitute(cPrefixe,"GIDEV").
	IF cType-in = "CLI"  then cTempo = substitute(cPrefixe,"GI").
	IF cType-in = "PREC" then cTempo = "gi".
	IF cType-in = "SUIV" then cTempo = "gi".
	IF cType-in = "SPE"  then cTempo = "gi".
	
	cRetour = DonnePreference(cTempo).
	
	/* Si rien de saisi dans les préférences */
	if cRetour = "" then do:
		IF cType-in = "DEV"  then cRetour = "gidev" + cSuffixe.
		IF cType-in = "CLI"  then cRetour = "gi" + cSuffixe.
		IF cType-in = "PREC" then cRetour = "gi".
		IF cType-in = "SUIV" then cRetour = "gi".
		IF cType-in = "SPE"  then cRetour = "gi".
	end.

/*	mdebug("cType-in / RepGI = " + cType-in + " / " + cRetour).*/
	RETURN cRetour.

END FUNCTION.

PROCEDURE ChargeDefinitions :
    DEFINE VARIABLE cLigne  AS CHARACTER    NO-UNDO.
   
    /* Y a t il d'autres bases que menudev2 de connectées */
    glBasesConnectees = FALSE.
    IF CONNECTED("ladb") THEN glBasesConnectees = TRUE.

    /* Vidage de la table temporaire */
    EMPTY TEMP-TABLE gttModules.
    FOR EACH    defs   no-lock
        WHERE   defs.cCle = "MODULE"
        :
        /* Si module avec connexion a des bases */
        IF defs.lbases AND NOT(glBasesConnectees) THEN NEXT.
        
        /* Création du module */
        CREATE gttModules.
        gttModules.cIdent = defs.cCode.
        gttModules.cLibelle = defs.cValeur.
        gttModules.cParametres = defs.cParametres.
        gttModules.cProgramme = defs.cProgramme.
        gttmodules.lADmin = defs.ladmin.
        gttmodules.lVisible = defs.lVisible.
        gttmodules.iNiveau = (IF defs.filler = "" THEN 5 ELSE INTEGER(ENTRY(1,defs.filler,"|"))).

        /* Recherche si module favoris */
        FIND FIRST  prefs   NO-LOCK
            WHERE   prefs.cUtilisateur = gcUtilisateur
            AND     prefs.cCode = "MODULE-FAVORIS"
            AND     prefs.cValeur = defs.cCode
            NO-ERROR.
        gttModules.lFavoris = AVAILABLE(prefs) AND gttmodules.lVisible.
    END.

END PROCEDURE.

PROCEDURE ChargeAlarmes :
    DEFINE VARIABLE iHeureCourante AS INTEGER NO-UNDO.
    
    /* Mémorisation de l'heure */
    iHeureCourante = INTEGER(ENTRY(1,STRING(TIME,"hh:mm"),":") + ENTRY(2,STRING(TIME,"hh:mm"),":")).

    /* Controle d'alarmes passées non déclenchées */
    IF glDemarrage THEN DO:
        RUN TraiteAlarmesPassees(iHeureCourante).
        glDemarrage = FALSE.
    END.
    
    /* Vidage de la table temporaire */
    FOR EACH Alarmes EXCLUSIVE-LOCK 
        WHERE   Alarmes.cUtilisateur = gcUtilisateur
        AND     Alarmes.lRappel = FALSE 
        AND     Alarmes.lEncours = FALSE
        :
        DELETE Alarmes.
    END.
    RELEASE Alarmes.
    
     /* Si Agenda désactivé, on ne fait rien */ 
    IF DonnePreference("PREF-PASAGENDA") = "OUI" THEN RETURN.
	
   /* Chargement des alarmes de l'utilisateur en cours */
    RUN ChargeAlarmesUtilisateur(gcUtilisateur,iHeureCourante).
    
    /* Ajout des alarmes administrateur */
    IF NOT(DonnePreference("PREF-PASALERTESADMIN") = "OUI") THEN 
        RUN ChargeAlarmesUtilisateur("ADMIN",iHeureCourante).
    
END PROCEDURE.    

PROCEDURE ChargeAlarmesUtilisateur :
    DEFINE INPUT PARAMETER cUtilisateurCourant 	AS CHARACTER 	NO-UNDO.
    DEFINE INPUT PARAMETER iHeureCourante 		AS INTEGER 		NO-UNDO.
      
    DEFINE VARIABLE dDateProchain 	AS DATE 	NO-UNDO.
    DEFINE VARIABLE dDateInitiale 	AS DATE 	NO-UNDO.
    DEFINE VARIABLE iHeureProchain 	AS INTEGER 	NO-UNDO.
    DEFINE VARIABLE iHeureInitiale 	AS INTEGER 	NO-UNDO.
    DEFINE VARIABLE lJourNonTraite 	AS LOGICAL 	NO-UNDO.
    DEFINE VARIABLE iCompteur   	AS INTEGER  NO-UNDO.

    /* Génération des lignes d'alarme */
    FOR EACH    agenda NO-LOCK
        WHERE   agenda.cUtilisateur = cUtilisateurCourant
        AND     (
                 /* Alarmes du futur non périodiques */
                (NOT(agenda.lperiodique) AND agenda.ddate > TODAY)
                OR
                /* Alarmes du jour non périodiques */
                (NOT(agenda.lperiodique) AND agenda.ddate = TODAY AND agenda.iheureDebut > iHeureCourante) 
                OR 
                 /* Alarmes périodiques */
                (agenda.lperiodique)
                )
        :
       
        dDateProchain = agenda.ddate.
        iHeureProchain = agenda.iheureDebut.
        
        /* Calcul de la prochaine date, avec delai */
        /* Gestion du delai avant avertissement */
        IF agenda.ldelai THEN DO:
            IF agenda.cunitedelai = "H" THEN DO:
                iHeureProchain = EnHeuresMinutes(EnMinute(iHeureProchain) - (agenda.inbdelai * 60)).
                IF iHeureProchain < 0 THEN DO:
                    iHeureProchain = iHeureProchain + 2400.
                    dDateProchain = dDateProchain - 1.
                END.
            END.
            IF agenda.cunitedelai = "J" THEN 
                dDateProchain = dDateProchain - agenda.inbdelai.
            IF agenda.cunitedelai = "S" THEN 
                dDateProchain = dDateProchain - (agenda.inbdelai * 7).
            IF agenda.cunitedelai = "M" THEN
                dDateProchain = AjouteMois(agenda.inbdelai * -1,dDateProchain).
            IF agenda.cunitedelai = "A" THEN
                dDateProchain = AjouteAnnees(agenda.inbdelai * -1,dDateProchain).
        END.

        /* Périodique : calcul prochaine date/heure */
        IF agenda.lperiodique THEN DO:
            REPEAT:
                IF dDateProchain > TODAY THEN LEAVE.
                IF dDateProchain = TODAY AND iHeureProchain > iHeureCourante THEN LEAVE.
                IF agenda.cuniteperiode = "H" THEN DO:
                    iHeureProchain = EnHeuresMinutes(EnMinute(iHeureProchain) + (agenda.inbperiode * 60)).
                    IF iHeureProchain > 2400 THEN DO:
                        iHeureProchain = iHeureProchain - 2400.
                        dDateProchain = dDateProchain + 1.
                    END.
                    IF iHeureProchain < 0 THEN DO:
                        iHeureProchain = iHeureProchain + 2400.
                        dDateProchain = dDateProchain - 1.
                    END.
                END.
                IF agenda.cuniteperiode = "J" THEN 
                    dDateProchain = dDateProchain + agenda.inbperiode.
                IF agenda.cuniteperiode = "S" THEN 
                    dDateProchain = dDateProchain + (agenda.inbperiode * 7).
                IF agenda.cuniteperiode = "M" THEN
                    dDateProchain = AjouteMois(agenda.inbperiode,dDateProchain).
                IF agenda.cuniteperiode = "A" THEN
                    dDateProchain = AjouteAnnees(agenda.inbperiode,dDateProchain).
            END.
        END.
        
        /* Gestion du jour */
        lJourNonTraite = FALSE.
        /* Ne pas traiter l'alarmes le WE si demandé */
        IF agenda.lWeekEnd THEN DO:
            lJourNonTraite = (WEEKDAY(dDateProchain) = 1 OR  WEEKDAY(dDateProchain) = 7).   
        END.
        
        /* Ne pas traiter l'alarmes si pas le bon jour (et si pas en test alarme) */
        IF agenda.lJours AND lJourNonTraite = FALSE THEN DO:
            lJourNonTraite = lJourNonTraite OR (WEEKDAY(dDateProchain) = 1 AND NOT(agenda.lDimanche)).   
            lJourNonTraite = lJourNonTraite OR (WEEKDAY(dDateProchain) = 2 AND NOT(agenda.lLundi)).   
            lJourNonTraite = lJourNonTraite OR (WEEKDAY(dDateProchain) = 3 AND NOT(agenda.lMardi)).   
            lJourNonTraite = lJourNonTraite OR (WEEKDAY(dDateProchain) = 4 AND NOT(agenda.lMercredi)).   
            lJourNonTraite = lJourNonTraite OR (WEEKDAY(dDateProchain) = 5 AND NOT(agenda.lJeudi)).   
            lJourNonTraite = lJourNonTraite OR (WEEKDAY(dDateProchain) = 6 AND NOT(agenda.lVendredi)).   
            lJourNonTraite = lJourNonTraite OR (WEEKDAY(dDateProchain) = 7 AND NOT(agenda.lSamedi)).   
        END.
    
        IF NOT(lJourNonTraite) THEN DO:
                   
            /* Création de l'alarme */
            CREATE Alarmes.
            Alarmes.cUtilisateur = gcUtilisateur.
            Alarmes.ddate = dDateProchain.
            Alarmes.iheure = iHeureProchain.
            Alarmes.cIdent = agenda.cident.
            Alarmes.lRappel = FALSE.
            Alarmes.lTraitee = FALSE.
            Alarmes.cIdentAlarme = gcUtilisateur 
                    + "-" + STRING(YEAR(TODAY),"9999") 
                    + STRING(MONTH(TODAY),"99") 
                    + STRING(DAY(TODAY),"99") 
                    + "-" + STRING(TIME)
                    + "-" + STRING(NEXT-VALUE(sq_AlarmeSuivante),"999999")
                    .
        END.
                                
        dDateInitiale = dDateProchain.
        iHeureInitiale = iHeureProchain.
       
        /* Calcul de la prochaine date, sans delai donc, on ajoute le délai */
        /* Périodique : calcul prochaine date/heure */
        IF agenda.ldelai THEN DO:
            IF agenda.cunitedelai = "H" THEN DO:
                iHeureProchain = EnHeuresMinutes(EnMinute(iHeureProchain) + (agenda.inbdelai * 60)).
                IF iHeureProchain > 2400 THEN DO:
                    iHeureProchain = iHeureProchain - 2400.
                    dDateProchain = dDateProchain + 1.
                END.
            END.
            IF agenda.cunitedelai = "J" THEN 
                dDateProchain = dDateProchain + agenda.inbdelai.
            IF agenda.cunitedelai = "S" THEN 
                dDateProchain = dDateProchain + (agenda.inbdelai * 7).
            IF agenda.cunitedelai = "M" THEN
                dDateProchain = AjouteMois(agenda.inbdelai,dDateProchain).
            IF agenda.cunitedelai = "A" THEN
                dDateProchain = AjouteAnnees(agenda.inbdelai,dDateProchain).
        END.
        

        /* Gestion du jour */
        lJourNonTraite = FALSE.
        /* Ne pas traiter l'alarmes le WE si demandé */
        IF agenda.lWeekEnd THEN DO:
            lJourNonTraite = (WEEKDAY(dDateProchain) = 1 OR  WEEKDAY(dDateProchain) = 7).   
        END.
        
        /* Ne pas traiter l'alarmes si pas le bon jour (et si pas en test alarme) */
        IF agenda.lJours AND lJourNonTraite = FALSE THEN DO:
            lJourNonTraite = lJourNonTraite OR (WEEKDAY(dDateProchain) = 1 AND NOT(agenda.lDimanche)).   
            lJourNonTraite = lJourNonTraite OR (WEEKDAY(dDateProchain) = 2 AND NOT(agenda.lLundi)).   
            lJourNonTraite = lJourNonTraite OR (WEEKDAY(dDateProchain) = 3 AND NOT(agenda.lMardi)).   
            lJourNonTraite = lJourNonTraite OR (WEEKDAY(dDateProchain) = 4 AND NOT(agenda.lMercredi)).   
            lJourNonTraite = lJourNonTraite OR (WEEKDAY(dDateProchain) = 5 AND NOT(agenda.lJeudi)).   
            lJourNonTraite = lJourNonTraite OR (WEEKDAY(dDateProchain) = 6 AND NOT(agenda.lVendredi)).   
            lJourNonTraite = lJourNonTraite OR (WEEKDAY(dDateProchain) = 7 AND NOT(agenda.lSamedi)).   
        END.
    
        IF NOT(lJourNonTraite) THEN DO:
                                    
            /* Création de l'alarme exacte (=sans delai) */
            IF dDateProchain <> dDateInitiale OR iHeureProchain <> iHeureInitiale THEN DO:
                CREATE Alarmes.
                Alarmes.cUtilisateur = gcUtilisateur.
                Alarmes.ddate = dDateProchain.
                Alarmes.iheure = iHeureProchain.
                Alarmes.cIdent = agenda.cident.
                Alarmes.lRappel = FALSE.
                Alarmes.lTraitee = FALSE.
                Alarmes.cIdentAlarme = gcUtilisateur 
                        + "-" + STRING(YEAR(TODAY),"9999") 
                        + STRING(MONTH(TODAY),"99") 
                        + STRING(DAY(TODAY),"99") 
                        + "-" + STRING(TIME)
                    + "-" + STRING(NEXT-VALUE(sq_AlarmeSuivante),"999999")
                        .
            END.
        END.
    END.

END PROCEDURE.

PROCEDURE TraiteAlarmesPassees:
    DEFINE INPUT PARAMETER iHeureCourante AS INTEGER NO-UNDO.

    DEFINE VARIABLE cRetour 	AS CHARACTER 	NO-UNDO.
    DEFINE VARIABLE cLibelle 	AS CHARACTER 	NO-UNDO.
    DEFINE VARIABLE iX 			AS INTEGER 		NO-UNDO.
    DEFINE VARIABLE iY 			AS INTEGER 		NO-UNDO.
    DEFINE VARIABLE lpremier 	AS LOGICAL 		NO-UNDO INIT TRUE.
    
    FOR EACH Alarmes NO-LOCK
        WHERE   Alarmes.cUtilisateur = gcUtilisateur
        AND     Alarmes.lEncours = FALSE
        AND     (Alarmes.ddate < TODAY OR (Alarmes.ddate = TODAY AND Alarmes.iheure < iHeureCourante))
        :
        IF lpremier = TRUE THEN DO:
            RUN AfficheMessageAvecTemporisation("Traitement des alertes","Des alertes passées n'ont pas été déclenchées. Voulez vous les déclencher maintenant ?",TRUE,10,"NON","",false,OUTPUT cRetour).
            lPremier = FALSE.
        END.
        IF cRetour = "OUI" THEN RUN DeclencheAgenda(Alarmes.cIdent,Alarmes.cIDentAlarme).
    END.
    
    /* Suppression des alarmes passées (pas possible de le faire en une fois car 
       c'est alarme.w qui efface l'alarme, et il ne peut le faire si je suis
       en exclusive-lock sur la boucle précédente de déclenchement */
    FOR EACH Alarmes EXCLUSIVE-LOCK
        WHERE   Alarmes.cUtilisateur = gcUtilisateur
        AND     Alarmes.lEncours = FALSE
        /*AND     (Alarmes.ddate > TODAY OR (Alarmes.ddate = TODAY AND Alarmes.iheure < iHeureCourante))*/
        AND     (Alarmes.ddate < TODAY OR (Alarmes.ddate = TODAY AND Alarmes.iheure < iHeureCourante))
        :
        DELETE Alarmes.
    END.
    RELEASE Alarmes.
END PROCEDURE.

PROCEDURE DeclencheAgenda:
    DEFINE INPUT PARAMETER cIdentAgenda AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER cIDentAlarme AS CHARACTER NO-UNDO.
    
    DEFINE VARIABLE lManuel 		AS LOGICAL 		NO-UNDO.
    DEFINE VARIABLE hModuleAlarme   AS HANDLE   	NO-UNDO.
    DEFINE VARIABLE cNomModule     	AS CHARACTER   	NO-UNDO.
    
    DEFINE BUFFER gda_agenda 	FOR agenda.
    DEFINE BUFFER gda_Alarmes 	FOR Alarmes.
    
    lManuel = (DonneEtSupprimeParametre("AGENDA-DECLENCHEMENT_MANUEL") = "OUI").

    /* Positionnement sur l'agenda en cours */
    FIND FIRST  gda_agenda  NO-LOCK
        WHERE   gda_agenda.cident = cIdentAgenda
        NO-ERROR.
    IF NOT(AVAILABLE(gda_agenda)) THEN RETURN.
    
    /* Si pas déclenchement manuel... */
    IF NOT(lManuel) THEN DO:
        
        /* Si alarme non activée */
        IF NOT(gda_agenda.lactivation) THEN RETURN.
        
		/* ne pas traiter l'alarme si jour ferie */
		if JourFerie(today) then return.
	
        /* Ne pas traiter l'alarmes le WE si demandé */
        IF gda_agenda.lWeekEnd THEN DO:
            IF WEEKDAY(TODAY) = 1 OR  WEEKDAY(TODAY) = 7 THEN RETURN.   
        END.
        
        /* Ne pas traiter l'alarmes si pas le bon jour (et si pas en test alarme) */
        IF gda_agenda.lJours THEN DO:
            IF WEEKDAY(TODAY) = 1 AND NOT(gda_agenda.lDimanche) THEN RETURN.   
            IF WEEKDAY(TODAY) = 2 AND NOT(gda_agenda.lLundi) THEN RETURN.   
            IF WEEKDAY(TODAY) = 3 AND NOT(gda_agenda.lMardi) THEN RETURN.   
            IF WEEKDAY(TODAY) = 4 AND NOT(gda_agenda.lMercredi) THEN RETURN.   
            IF WEEKDAY(TODAY) = 5 AND NOT(gda_agenda.lJeudi) THEN RETURN.   
            IF WEEKDAY(TODAY) = 6 AND NOT(gda_agenda.lVendredi) THEN RETURN.   
            IF WEEKDAY(TODAY) = 7 AND NOT(gda_agenda.lSamedi) THEN RETURN.   
        END.
    END.
            
    /* Positionnement sur l'alarme en cours */
    IF cIDentAlarme <> "" THEN DO:
        FIND FIRST gda_Alarmes EXCLUSIVE-LOCK
            WHERE   gda_Alarmes.cIdentAlarme = cIDentAlarme
            NO-ERROR.
        IF NOT(AVAILABLE(gda_Alarmes)) THEN RETURN.
        
        /* Marquer l'alarme comme traitée */
        gda_Alarmes.ltraitee = TRUE.
        gda_Alarmes.lEncours = TRUE.
        RELEASE gda_Alarmes.
    END. 
       
    cNomModule = gcRepertoireExecution + "Alarme.w".
    RUN EcritLogAgenda("Déclenchement de l'alarme : " + gda_agenda.clibelle).
    RUN VALUE(cNomModule) PERSISTENT SET hModuleAlarme (INPUT cIdentAgenda, INPUT cIDentAlarme).
    
END PROCEDURE.

PROCEDURE DeclencheRappelHoraire:
    DEFINE INPUT PARAMETER cLibelle AS CHARACTER NO-UNDO.
       
    DEFINE VARIABLE hModuleAlarme   AS HANDLE   	NO-UNDO.
    DEFINE VARIABLE cNomModule     	AS CHARACTER   	NO-UNDO.
    DEFINE VARIABLE cLibelleLog 	AS CHARACTER 	NO-UNDO.
    
	/* ne pas traiter si jour ferie */
	if JourFerie(today) then return.
	
    /* Ne pas traiter l'alarme horaire le WE */
    IF WEEKDAY(TODAY) = 1 OR  WEEKDAY(TODAY) = 7 THEN RETURN.  
    
    /* Ne pas traiter si agenda désactivé */ 
    IF DonnePreference("PREF-PASAGENDA") = "OUI" THEN RETURN.
    
    cNomModule = gcRepertoireExecution + "AlarmeHoraire.w".
    cLibelleLog = clibelle.
    cLibelleLog = REPLACE(cLibelleLog,CHR(10),"§").
    cLibelleLog = REPLACE(cLibelleLog,CHR(13),"§").
    cLibelleLog = REPLACE(cLibelleLog,"§§"," / ").
    RUN EcritLogAgenda("Déclenchement de l'alarme horaire : " + cLibelleLog).
    RUN VALUE(cNomModule) PERSISTENT SET hModuleAlarme (INPUT cLibelle).
    
END PROCEDURE.

PROCEDURE DeclencheRappelHoraire2:
/* -------------------------------------------------------------------------
   Procédure de déclenchement des alertes "horaire" (Spécifique)
   ----------------------------------------------------------------------- */
    DEFINE INPUT PARAMETER cLibelle AS CHARACTER NO-UNDO.
       
    DEFINE VARIABLE hModuleAlarme   AS HANDLE   	NO-UNDO.
    DEFINE VARIABLE cNomModule     	AS CHARACTER   	NO-UNDO.
    DEFINE VARIABLE cLibelleLog 	AS CHARACTER 	NO-UNDO.
    
	/* ne pas traiter si jour ferie */
	if NOT(glBy-pass) AND JourFerie(today) then return.
	
    /* Ne pas traiter l'alarme horaire le WE */
    IF NOT(glBy-pass) AND (WEEKDAY(TODAY) = 1 OR  WEEKDAY(TODAY) = 7) THEN RETURN.   
    
    /* Ne pas traiter si agenda désactivé */ 
    IF NOT(glBy-pass) AND DonnePreference("PREF-PASAGENDA") = "OUI" THEN RETURN.
    
    cNomModule = gcRepertoireExecution + "AlarmeHoraire2.w".
    cLibelleLog = clibelle.
    cLibelleLog = REPLACE(cLibelleLog,CHR(10),"§").
    cLibelleLog = REPLACE(cLibelleLog,CHR(13),"§").
    cLibelleLog = REPLACE(cLibelleLog,"§§"," / ").
    RUN EcritLogAgenda("Déclenchement de l'alarme horaire avec module RTF : " + cLibelleLog).
    RUN VALUE(cNomModule) PERSISTENT SET hModuleAlarme (INPUT cLibelle).
    
END PROCEDURE.

PROCEDURE EcritLogAgenda:
    DEFINE INPUT PARAMETER cLibelle AS CHARACTER.
    
    OUTPUT STREAM gstrAgenda TO VALUE(gcFichierAgenda) APPEND.
    
    PUT STREAM gstrAgenda UNFORMATTED STRING(TODAY,"99/99/9999") 
        + " - " + STRING(TIME,"hh:mm:ss") 
        + " - " + cLibelle
        SKIP.
    
    OUTPUT STREAM gstrAgenda CLOSE.
END PROCEDURE.

PROCEDURE GereUtilisateur:
	DEFINE INPUT PARAMETER cAction  AS CHARACTER NO-UNDO.
    
    DEFINE VARIABLE cTempo  AS CHARACTER NO-UNDO.
    DEFINE BUFFER butilisateurs FOR utilisateurs.

    /* Création automatique de l'utilisateur si inexistant mais utilisateur de base existe exemple ppl_11 à partir de ppl */ 
    FIND FIRST  utilisateurs NO-LOCK
        WHERE   utilisateurs.cUtilisateur = gcUtilisateur
        NO-ERROR.
    IF NOT AVAILABLE utilisateurs AND gcUtilisateur MATCHES "*_*" THEN DO:
        cTempo = ENTRY(1,gcUtilisateur ,"_").
        FIND FIRST  butilisateurs NO-LOCK
            WHERE   butilisateurs.cUtilisateur = cTempo
            NO-ERROR.
        IF AVAILABLE butilisateurs THEN DO:
            CREATE utilisateurs.
            BUFFER-COPY butilisateurs EXCEPT cUtilisateur TO utilisateurs
                        ASSIGN utilisateurs.cUtilisateur = gcUtilisateur.
        END.
    END.
 
    /* Recherche de l'utilisateur en cours */
    FIND FIRST  Utilisateurs    EXCLUSIVE-LOCK
        WHERE  Utilisateurs.cUtilisateur = gcUtilisateur
        NO-ERROR.
    IF NOT(AVAILABLE(Utilisateurs)) THEN DO:
        /* Création de l'utilisateur car inexistant */
        CREATE Utilisateurs.
        Utilisateurs.cUtilisateur = gcUtilisateur.
    END.

    /* Inscription dans le log */
    IF cAction = "ENTREE" THEN DO:
        utilisateurs.lConnecte = TRUE.
        MLog("Démarrage de Menudev2.").
        MLog("Connexion de l'utilisateur : " + gcUtilisateur).
        MLog("Mode Administrateur : " + STRING(utilisateurs.lAdmin)).
        RUN EcritLogAgenda("Démarrage de menudev2").
    END.

    IF cAction = "SORTIE" THEN DO:
        utilisateurs.lConnecte = FALSE.
        MLog("Déconnexion de l'utilisateur : " + gcUtilisateur).
        MLog("Arret de Menudev2.").
        RUN EcritLogAgenda("Arret de menudev2").
    END.

    IF cAction = "ADMIN" THEN DO:
        utilisateurs.lAdmin = TRUE.
        MLog("Passage en ADMIN de l'utilisateur : " + gcUtilisateur).
        MLog("Mode Administrateur : " + STRING(utilisateurs.lAdmin)).
    END.

    IF cAction = "UTIL" THEN DO:
        utilisateurs.lAdmin = FALSE.
        MLog("Passage en 'UTIL' de l'utilisateur : " + gcUtilisateur).
        MLog("Mode Administrateur : " + STRING(utilisateurs.lAdmin)).
    END.

    /* Au passage, mémorisation du flag administrateur et des infos de l'utilisateur */
    glUtilisateurAdmin = utilisateurs.lAdmin.
    giNiveauUtilisateur = utilisateurs.iNiveau.
    gcGroupeUtilisateur = utilisateurs.cGroupe.
    
    /* gestion des versions */
    IF utilisateurs.iVersion = 0 THEN utilisateurs.iVersion = 1.
    giVersionUtilisateur = utilisateurs.iversion.
    if glNo-Version then giVersionUtilisateur = 99.
    if glAdmin then glUtilisateurAdmin = true.
    
    /* Droits utilisateur */
    gcDroitsUtilisateur = utilisateurs.cFiller.
    
    /* Libération de l'enregistrement */
    RELEASE utilisateurs.

END PROCEDURE.

PROCEDURE EnvoiOrdre:
	DEFINE INPUT PARAMETER cAction 			AS CHARACTER 	NO-UNDO.
	DEFINE INPUT PARAMETER cMessage 		AS CHARACTER 	NO-UNDO.
	DEFINE INPUT PARAMETER cAQui 			AS CHARACTER 	NO-UNDO.
	DEFINE INPUT PARAMETER cDeQui 			AS CHARACTER 	NO-UNDO.
	DEFINE INPUT PARAMETER lPrioritaire-in 	AS logical		NO-UNDO.
	DEFINE INPUT PARAMETER lCollegue-in 	AS logical 		NO-UNDO.

	DEFINE VARIABLE dDateMessage 	AS DATE 	NO-UNDO.
	DEFINE VARIABLE iheureMessage 	AS INTEGER 	NO-UNDO.

	DEFINE BUFFER creOrdres FOR Ordres.

	dDateMessage = TODAY.
	iheuremessage = TIME.

	FOR EACH utilisateurs NO-LOCK
		WHERE (cAQui = "" OR utilisateurs.cutilisateur = cAQui)
		:
		CREATE creOrdres.
		ASSIGN
		creOrdres.cutilisateur = utilisateurs.cUtilisateur /* Destinataire */
		creOrdres.cAction = cAction
		creOrdres.cmessage = cMessage.
		creOrdres.ddate = ddatemessage.
		creOrdres.iordre = iheuremessage.
		creOrdres.filler = cDeQui. /* Emeteur */
		creOrdres.lCollegue = lCollegue-in.
		creOrdres.lPrioritaire = lPrioritaire-in.
		creOrdres.cSens = "R".

		/* Pour garder une trace de l'envoi sauf si c'est menudev qui envoi le message et qu'il est pour moi */
		IF NOT(cDeQui = "Menudev2" AND cAQui = gcUtilisateur) THEN DO:
			CREATE creOrdres.
			ASSIGN
			creOrdres.cutilisateur = gcUtilisateur /* Emeteur */
			creOrdres.cAction = cAction
			creOrdres.cmessage = cMessage.
			creOrdres.ddate = ddatemessage.
			creOrdres.iordre = iheuremessage.
			creOrdres.filler = utilisateurs.cUtilisateur. /* destinataire */ 
			creOrdres.lCollegue = lCollegue-in.
			creOrdres.lPrioritaire = lPrioritaire-in.
			creOrdres.cSens = "E".
		END.
		RELEASE creOrdres.
	END.
  
END PROCEDURE.

PROCEDURE Impression:
	
    IF DonnePreference("PREF-EDITIONSWORD") = "OUI" THEN
        RUN HTML_AfficheFichierAvecWord.
    ELSE
        RUN HTML_AfficheFichier.

END PROCEDURE.

PROCEDURE ImpressionFichier:
	DEFINE INPUT PARAMETER cFichier AS CHARACTER NO-UNDO.
	DEFINE INPUT PARAMETER cTitre 	AS CHARACTER NO-UNDO.

    IF DonnePreference("PREF-EDITIONSWORD") = "OUI" THEN
        RUN HTML_EditeFichierAvecWord(cFichier,cTitre).
    ELSE
        RUN HTML_EditeFichier(cFichier,cTitre).

END PROCEDURE.

PROCEDURE GereDetail :
    DEFINE INPUT PARAMETER cAction-in   AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER cIdent1-in   AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER cIdent2-in   AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER cIdent3-in   AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER cIdent4-in   AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER cValeur1-in  AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER cValeur2-in  AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER cValeur3-in  AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER cValeur4-in  AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER cIdx-in      AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER cRetour-ou  AS CHARACTER NO-UNDO INIT "".
    
    DEFINE BUFFER bdetails FOR details.
    
    IF cAction-in = "CREER" THEN DO:
        CREATE bdetails.
        ASSIGN
            bdetails.iddet1 = cIdent1-in
            bdetails.iddet2 = cIdent2-in
            bdetails.iddet3 = cIdent3-in
            bdetails.iddet4 = cIdent4-in
            bdetails.vldet1 = cValeur1-in
            bdetails.vldet2 = cValeur2-in
            bdetails.vldet3 = cValeur3-in
            bdetails.vldet4 = cValeur4-in
            bdetails.idxdet = cIdx-in
            .    
    END.
    
    IF cAction-in = "MODIFIER" OR cAction-in = "SUPPRIMER" THEN DO:
        FIND FIRST  bdetails    EXCLUSIVE-LOCK
            WHERE   bdetails.idxdet = cIdx-in
            NO-ERROR.
        IF NOT(AVAILABLE(bdetails)) THEN DO:
            MESSAGE "Enregistrement de 'details' introuvable pour Modification/Suppression"
                VIEW-AS ALERT-BOX ERROR.
            RETURN.
        END.
        
        IF cAction-in = "MODIFIER" THEN DO:
            ASSIGN
                bdetails.vldet1 = cValeur1-in
                bdetails.vldet2 = cValeur2-in
                bdetails.vldet3 = cValeur3-in
                bdetails.vldet4 = cValeur4-in
                .    
        END.
       
        IF cAction-in = "MODIFIER" THEN DO:
            DELETE bdetails.
        END.
    END.
    
    RELEASE bdetails.
    
    /* Mise a jour du code retour */
    cRetour-ou = "OK".
    
END PROCEDURE. 

PROCEDURE DonneDetail :
    DEFINE INPUT PARAMETER cIdent1-in   AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER cIdent2-in   AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER cIdent3-in   AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER cIdent4-in   AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER cRetour-ou  AS CHARACTER NO-UNDO INIT "".
    
    DEFINE VARIABLE cTempo  AS CHARACTER NO-UNDO.
    
    DEFINE BUFFER bdetails FOR details.
    
    /* Se positionner sur l'enregistrement */
    FOR EACH    bdetails NO-LOCK
        WHERE   (cIdent1-in = "" OR bdetails.iddet1 = cIdent1-in)
        AND     (cIdent2-in = "" OR bdetails.iddet2 = cIdent2-in)
        AND     (cIdent3-in = "" OR bdetails.iddet3 = cIdent3-in)
        AND     (cIdent4-in = "" OR bdetails.iddet4 = cIdent4-in)
        :
        
        /* Mise a jour du code retour */
        cTempo = ""
            + (IF TRIM(bdetails.vldet1) <> "" THEN TRIM(bdetails.vldet1) ELSE "")
            + (IF TRIM(bdetails.vldet2) <> "" THEN " - " + TRIM(bdetails.vldet2) ELSE "")
            + (IF TRIM(bdetails.vldet3) <> "" THEN " - " + TRIM(bdetails.vldet3) ELSE "")
            + (IF TRIM(bdetails.vldet4) <> "" THEN " - " + TRIM(bdetails.vldet4) ELSE "")
            .
        IF cTempo <> "" THEN 
            cRetour-ou = cRetour-ou + (IF cRetour-ou <> "" THEN CHR(10) ELSE "") + cTempo.
    END.
       
END PROCEDURE.        

PROCEDURE DechargeVariables:
    DEFINE INPUT PARAMETER cMode-in AS CHARACTER NO-UNDO.

    IF cMode-in = "FICHIER" THEN DO:
        cFichierInfos = loc_tmp + "Menudev2-Variables.txt".
    END.

    EcritLigne(FILL("-",80),1).
    EcritLigne("VARIABLES GLOBALES...",2).
    AjouteRetireTabulation(1).
        EcritLigne("gcFichierPrefs = " + FormateValeur(gcFichierPrefs),1).
        EcritLigne("gcFichierDefs = " + FormateValeur(gcFichierDefs),1).
        EcritLigne("gcFichierAgenda = " + FormateValeur(gcFichierAgenda),1).
        EcritLigne("gcFichierAFaire = " + FormateValeur(gcFichierAFaire),1).
        EcritLigne("ghGeneral = " + FormateValeur(string(ghGeneral)),1).
        EcritLigne("giModuleEnCours = " + FormateValeur(string(giModuleEnCours)),1).
        EcritLigne("gcModuleEnCours = " + FormateValeur(gcModuleEnCours),1).
        EcritLigne("gcAllerRetour = " + FormateValeur(gcAllerRetour),1).
        EcritLigne("gcTypeMemo = " + FormateValeur(gcTypeMemo),1)  .
        EcritLigne("gcUtilisateurInitial = " + FormateValeur(gcUtilisateurInitial),1).
        EcritLigne("gdPositionXModule = " + FormateValeur(string(gdPositionXModule)),1).
        EcritLigne("gdPositionYModule = " + FormateValeur(string(gdPositionYModule)),1).
        EcritLigne("giPosXMessage = " + FormateValeur(string(giPosXMessage)),1).
        EcritLigne("giPosYMessage = " + FormateValeur(string(giPosYMessage)),1).
        EcritLigne("gdHauteur = " + FormateValeur(string(gdHauteur)),1).
        EcritLigne("gdLargeur = " + FormateValeur(string(gdLargeur)),1).
        EcritLigne("iCouleurAdmin = " + FormateValeur(string(iCouleurAdmin)),1).
        EcritLigne("giHeure = " + FormateValeur(string(giHeure)),1).
        EcritLigne("glModificationAlarmes = " + FormateValeur(STRING(glModificationAlarmes)),1).
        EcritLigne("glDemarrage = " + FormateValeur(string(glDemarrage)),1).
        EcritLigne("glUtilisateurAdmin = " + FormateValeur(STRING(glUtilisateurAdmin)),1).
        EcritLigne("glLogActif = " + FormateValeur(STRING(glLogActif)),1).
        EcritLigne("glBasesConnectees = " + FormateValeur(STRING(glBasesConnectees)),1).
        EcritLigne("giLatenceMax = " + FormateValeur(string(giLatenceMax)),1).
        EcritLigne("giNiveauUtilisateur = " + FormateValeur(string(giNiveauUtilisateur)),1).
        EcritLigne("gcGroupeUtilisateur = " + FormateValeur(gcGroupeUtilisateur),1).
        EcritLigne("giVersionUtilisateur = " + FormateValeur(string(giVersionUtilisateur)),1).
        EcritLigne("gcJoursFeries = " + FormateValeur(gcJoursFeries),1).
        EcritLigne("gcAideAjouter = " + FormateValeur(gcAideAjouter),1).
        EcritLigne("gcAideModifier = " + FormateValeur(gcAideModifier),1).
        EcritLigne("gcAideSupprimer = " + FormateValeur(gcAideSupprimer),1).
        EcritLigne("gcAideImprimer = " + FormateValeur(gcAideImprimer),1).
        EcritLigne("gcAideRaf = " + FormateValeur(gcAideRaf),1).
        EcritLigne("gcRepertoireRessourcesPrivees = " + FormateValeur(gcRepertoireRessourcesPrivees),1).
        EcritLigne("gcRepertoireRessources = " + FormateValeur(gcRepertoireRessources),1).
        EcritLigne("glDeveloppeur = " + FormateValeur(string(glDeveloppeur)),1).
        EcritLigne("glBy-pass = " + FormateValeur(string(glBy-pass)),1).
        EcritLigne("gcFichierLocal = " + FormateValeur(string(gcFichierLocal)),1).
        EcritLigne(FILL("-",80),1).
    AjouteRetireTabulation(-1).
    EcritLigne("VARIABLES GLOBALES OUTILGI...",2).
    AjouteRetireTabulation(1).
        EcritLigne("ser_outils = " + FormateValeur(ser_outils),1).
        EcritLigne("ser_outadb = " + FormateValeur(ser_outadb),1).
        EcritLigne("ser_outgest = " + FormateValeur(ser_outgest),1).
        EcritLigne("ser_outcadb = " + FormateValeur(ser_outcadb),1).
        EcritLigne("ser_outtrans = " + FormateValeur(ser_outtrans),1).
        EcritLigne("ser_appli = " + FormateValeur(ser_appli),1).
        EcritLigne("ser_appdev = " + FormateValeur(ser_appdev),1).
        EcritLigne("ser_tmp = " + FormateValeur(ser_tmp),1).
        EcritLigne("ser_log = " + FormateValeur(ser_log),1).
        EcritLigne("ser_intf = " + FormateValeur(ser_intf),1).
        EcritLigne("ser_dat = " + FormateValeur(ser_dat),1).
        EcritLigne("loc_outils = " + FormateValeur(loc_outils),1).
        EcritLigne("loc_outadb = " + FormateValeur(loc_outadb),1).
        EcritLigne("loc_outgest = " + FormateValeur(loc_outgest),1).
        EcritLigne("loc_outcadb = " + FormateValeur(loc_outcadb),1).
        EcritLigne("loc_outtrans = " + FormateValeur(loc_outtrans),1).
        EcritLigne("loc_appli = " + FormateValeur(loc_appli),1).
        EcritLigne("loc_appdev = " + FormateValeur(loc_appdev),1).
        EcritLigne("loc_tmp = " + FormateValeur(loc_tmp),1). 
        EcritLigne("loc_log = " + FormateValeur(loc_log),1).
        EcritLigne("loc_intf = " + FormateValeur(loc_intf),1).
        EcritLigne("RpOriGi = " + FormateValeur(RpOriGi),1).
        EcritLigne("RpDesGi = " + FormateValeur(RpDesGi),1).
        EcritLigne("RpOriadb = " + FormateValeur(RpOriadb),1).
        EcritLigne("RpDesadb = " + FormateValeur(RpDesadb),1).
        EcritLigne("RpOriges = " + FormateValeur(RpOriges),1). 
        EcritLigne("RpDesges = " + FormateValeur(RpDesges),1).
        EcritLigne("RpOricad = " + FormateValeur(RpOricad),1).
        EcritLigne("RpDescad = " + FormateValeur(RpDescad),1).
        EcritLigne("RpOritrf = " + FormateValeur(RpOritrf),1).
        EcritLigne("RpDestrf = " + FormateValeur(RpDestrf),1).
        EcritLigne(FILL("-",80),1).
        
    AjouteRetireTabulation(-1).
    EcritLigne("TABLES PARTAGEES...",2).
    AjouteRetireTabulation(1).
        EcritLigne("gttParam = ",1).
        AjouteRetireTabulation(1).
        FOR EACH gttparam:
         EcritLigne("cIdent = " + FormateValeur(gttparam.cident),1).
         EcritLigne("cValeur = " + FormateValeur(gttparam.cValeur),1).
         EcritLigne("--------------------",1).
        END.
        AjouteRetireTabulation(-1).
        
        EcritLigne(FILL("-",80),1).
        EcritLigne("gttPrefs = ",1).
        AjouteRetireTabulation(1).
        FOR EACH gttPrefs:
         EcritLigne("cIdent = " + FormateValeur(gttPrefs.cident),1).
         EcritLigne("cValeur = " + FormateValeur(gttPrefs.cValeur),1).
         EcritLigne("--------------------",1).
        END.
        AjouteRetireTabulation(-1).
        
        EcritLigne(FILL("-",80),1).
        EcritLigne("gttModules = ",1).
        AjouteRetireTabulation(1).
        FOR EACH gttModules:
            EcritLigne("cIdent = " + FormateValeur(gttModules.cident),1).
            EcritLigne("cLibelle = " + FormateValeur(gttModules.cLibelle),1).
            EcritLigne("lFavoris = " + FormateValeur(string(gttModules.lFavoris)),1).
            EcritLigne("hModule = " + FormateValeur(string(gttModules.hModule)),1).
            EcritLigne("cParametres = " + FormateValeur(gttModules.cParametres),1).
            EcritLigne("cProgramme = " + FormateValeur(gttModules.cProgramme),1).
            EcritLigne("lAdmin = " + FormateValeur(string(gttModules.lAdmin)),1).
            EcritLigne("lVisible = " + FormateValeur(string(gttModules.lVisible)),1).
            EcritLigne("iNiveau = " + FormateValeur(string(gttModules.iNiveau)),1).
            EcritLigne("--------------------",1).
        END.  
        AjouteRetireTabulation(-1).
    AjouteRetireTabulation(-1).
    
    /*-----
    /* appel de la procedure dans les différents modules en cours */
    EcritLigne(FILL("-",80),1).
    EcritLigne("VARIABLES DES MODULES...",2).
    AjouteRetireTabulation(1).
    FOR EACH gttmodules
         WHERE gttmodules.hmodule <> ?
         :
         EcritLigne(gttModules.cLibelle,1).
         IF valid-handle(gttmodules.hmodule) THEN RUN DechargeVariables IN gttmodules.hmodule NO-ERROR.
		 EcritLigne(FILL("-",80),1).
    END.
    AjouteRetireTabulation(-1).
    ---*/
    
    IF cMode-in = "FICHIER" THEN DO:
        OS-COMMAND NO-WAIT VALUE(cFichierInfos).
    END.
    
END PROCEDURE.

PROCEDURE ExtraitFichierDeLaBase:
/* -------------------------------------------------------------------------
   Procédure de déchargement d'un fichier de la base sur le disque local
   ----------------------------------------------------------------------- */
    DEFINE INPUT PARAMETER cUtil-in 	AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER cFichier-in 	AS CHARACTER NO-UNDO.

    gcFichierLocal = loc_tmp + "\" + cFichier-in.

    OUTPUT STREAM gstrSortie TO VALUE(gcFichierLocal).

    FIND FIRST  fichiers    NO-LOCK
        WHERE   fichiers.cUtilisateur = cutil-in
        AND     fichiers.cIdentFichier = cFichier-in
        NO-ERROR.
    IF AVAILABLE(fichiers) THEN DO:
        PUT STREAM gstrSortie UNFORMATTED fichiers.texte skip.
		
    END.
    ELSE DO:
        MESSAGE "L'enregistrement de '" cFichier-in "' est introuvable dans la base menudev2 !"
            VIEW-AS ALERT-BOX ERROR
            TITLE "ExtraitFichierDeLaBase"
            .
    END.

    OUTPUT STREAM gstrSortie CLOSE.

END PROCEDURE.

PROCEDURE ExecuteCommandeDos:
    DEFINE INPUT PARAMETER cCommande-in AS CHARACTER NO-UNDO.
        
	MLog("Execution de la commande DOS : " + "%scCommande-in = " + cCommande-in ).

    IF (DonnePreference("COMMANDESDOSVISIBLES") = "OUI") THEN DO:
        OS-COMMAND value(cCommande-in).
    END.
    ELSE DO:
        OS-COMMAND SILENT value(cCommande-in).
    END.

END PROCEDURE.

PROCEDURE FormateNomFichier:
    DEFINE INPUT 	PARAMETER cPrefixe-in 		AS CHARACTER NO-UNDO.
    DEFINE INPUT 	PARAMETER cSufixe-in 		AS CHARACTER NO-UNDO.
    DEFINE INPUT 	PARAMETER cExtension-in 	AS CHARACTER NO-UNDO.
    DEFINE OUTPUT 	PARAMETER cNomFichier-ou 	AS CHARACTER NO-UNDO.

    cNomFichier-ou = cPrefixe-in.

    cNomFichier-ou = cNomFichier-ou 
        + "-" + STRING(YEAR(TODAY),"9999")
        + "-" + STRING(MONTH(TODAY),"99")
        + "-" + STRING(DAY(TODAY),"99")
        + "-" + REPLACE(STRING(TIME,"hh:mm:ss"),":","")
        .

    cNomFichier-ou = cNomFichier-ou + (IF csufixe-in <> "" THEN "-" + csufixe-in ELSE "").
    cNomFichier-ou = cNomFichier-ou + cExtension-in.

END PROCEDURE.

PROCEDURE AfficheMessageAvecTemporisation:
    DEFINE INPUT 	PARAMETER cTitre-in 			AS CHARACTER 	NO-UNDO.
    DEFINE INPUT 	PARAMETER cMessage-in 			AS CHARACTER 	NO-UNDO.
    DEFINE INPUT 	PARAMETER lOuiNon-in 			AS LOGICAL  	NO-UNDO.
    DEFINE INPUT 	PARAMETER iTemporisation-in 	AS INTEGER 		NO-UNDO.
    DEFINE INPUT 	PARAMETER cBoutonDefaut-in 		AS CHARACTER 	NO-UNDO.
    DEFINE INPUT 	PARAMETER cIdentBouton-in 		AS CHARACTER 	NO-UNDO.
    DEFINE INPUT 	PARAMETER lImportant-in 		AS LOGICAL 		NO-UNDO.
    DEFINE OUTPUT 	PARAMETER cBoutonRetour-ou 		AS CHARACTER 	NO-UNDO.

    RUN DonnePositionMessage IN ghGeneral.

    IF DonnePreference(cIdentBouton-in) = "OUI" THEN DO:
        cBoutonRetour-ou = cBoutonDefaut-in.
        RETURN.
    END.
    
    IF lImportant-in THEN 
        RUN VALUE(gcRepertoireExecution + "mestemp.w") persistent (giPosXMessage,giPosYMessage,"Menudev2 : " + cTitre-in,cMessage-in,lOuiNon-in,iTemporisation-in,cBoutonDefaut-in,cIdentBouton-in,OUTPUT cBoutonRetour-ou) .
    ELSE
        RUN VALUE(gcRepertoireExecution + "mestemp.w") (giPosXMessage,giPosYMessage,"Menudev2 : " + cTitre-in,cMessage-in,lOuiNon-in,iTemporisation-in,cBoutonDefaut-in,cIdentBouton-in,OUTPUT cBoutonRetour-ou) .
    
END PROCEDURE.

PROCEDURE DonneAbsences:
	DEFINE INPUT 	PARAMETER lForcage-in 		AS LOGICAL 		NO-UNDO.
	DEFINE OUTPUT 	PARAMETER cAbsJour-ou 		AS CHARACTER 	NO-UNDO.
	DEFINE OUTPUT 	PARAMETER cAbsFutures-ou 	AS CHARACTER 	NO-UNDO.
	
	DEFINE VARIABLE cTempo AS CHARACTER NO-UNDO.

	cTempo = DonnePreference("PREFS-ABSENCES-PRESENTATION").
	IF cTempo = "" THEN cTempo = "2".
	RUN VALUE("FormateAbsences-" + cTempo) (lForcage-in,OUTPUT cAbsJour-ou, OUTPUT cAbsFutures-ou).
    
END PROCEDURE.

PROCEDURE FormateAbsences-1:
	DEFINE INPUT 	PARAMETER lForcage-in 		AS LOGICAL 		NO-UNDO.
	DEFINE OUTPUT 	PARAMETER cAbsJour-ou 		AS CHARACTER 	NO-UNDO.
	DEFINE OUTPUT 	PARAMETER cAbsFutures-ou 	AS CHARACTER 	NO-UNDO.

    DEFINE VARIABLE cAbsJour 			AS CHARACTER 	NO-UNDO.
    DEFINE VARIABLE cAbsJour-Journee 	AS CHARACTER 	NO-UNDO.
    DEFINE VARIABLE cAbsJour-Matin 		AS CHARACTER 	NO-UNDO.
    DEFINE VARIABLE cAbsJour-ApresMidi 	AS CHARACTER 	NO-UNDO.
    DEFINE VARIABLE iNombreJours 		AS INTEGER 		NO-UNDO.
    DEFINE VARIABLE cTempo 				AS CHARACTER 	NO-UNDO.
    
    /* Absences du jour */
    cAbsJour = "".
    cAbsJour-Matin = "".
    cAbsJour-ApresMidi = "".
    cAbsJour-Journee = "".
    FOR EACH    absences NO-LOCK
        WHERE   absences.ddate = TODAY
        :
        cTempo = "ABSENCES-SIGNALEES"
        	+ "-" + absences.cUtilisateur 
        	+ "-" + STRING(absences.ddate,"99/99/9999")
        	+ "-" + STRING(absences.lmatin,"O/N")
        	+ "-" + STRING(absences.lApresMidi,"O/N")
        	+ "-" + absences.cTypeAbsence
        	.
        	
        /* Si l'absence a déjà été signalée, on ne fait rien */
        IF NOT(lForcage-in) AND DonnePreference(cTempo) = "OUI" THEN NEXT.
        
        IF (absences.lmatin AND absences.lApresMidi) THEN
            cAbsJour-Journee = cAbsJour-Journee 
            	+ (IF cAbsJour-Journee <> "" THEN ", " ELSE "") 
            	+ DonneVraiNomUtilisateur(absences.cUtilisateur)
            	+ " (" + DonneTypeAbsence(absences.cTypeAbsence) + ")".
        ELSE IF (absences.lmatin) THEN
            cAbsJour-Matin = cAbsJour-Matin 
            	+ (IF cAbsJour-Matin <> "" THEN ", " ELSE "") 
            	+ DonneVraiNomUtilisateur(absences.cUtilisateur)
            	+ " (" + DonneTypeAbsence(absences.cTypeAbsence) + ")".
        ELSE IF (absences.lApresMidi) THEN
            cAbsJour-ApresMidi = cAbsJour-ApresMidi 
	            + (IF cAbsJour-ApresMidi <> "" THEN ", " ELSE "") 
	            + DonneVraiNomUtilisateur(absences.cUtilisateur)
	        	+ " (" + DonneTypeAbsence(absences.cTypeAbsence) + ")".
	        	
	     IF NOT(lForcage-in) THEN SauvePreference(cTempo,"OUI").
    END.
    IF cAbsJour-Journee <> "" OR cAbsJour-Matin <> "" OR cAbsJour-ApresMidi <> "" THEN DO:
        IF cAbsJour-Matin <> "" THEN
	        cAbsJour = "Absent ce matin : " + cAbsJour-Matin.
	    IF cAbsJour-ApresMidi <> "" THEN 
	    	cAbsJour = cAbsJour + (IF cAbsJour <> "" THEN CHR(10) ELSE "") + "Absent cet après-midi : " + cAbsJour-ApresMidi.
	    IF cAbsJour-Journee <> "" THEN 
	    	cAbsJour = cAbsJour + (IF cAbsJour <> "" THEN CHR(10) ELSE "") + "Absent aujourd'hui : " + cAbsJour-Journee.
    END.
    cAbsJour-ou = cAbsJour.
    
    /* Absences futures */
    cAbsJour = "".
    cAbsJour-Matin = "".
    cAbsJour-ApresMidi = "".
    cAbsJour-Journee = "".
    iNombreJours = INTEGER(DonnePreference("PREFS-ABSENCES-JOURS")).
    FOR EACH    absences NO-LOCK
        WHERE   absences.ddate > TODAY
        AND		absences.ddate < (TODAY + iNombreJours) 	
        :
        cTempo = "ABSENCES-SIGNALEES"
        	+ "-" + absences.cUtilisateur 
        	+ "-" + STRING(absences.ddate,"99/99/9999")
        	+ "-" + STRING(absences.lmatin,"O/N")
        	+ "-" + STRING(absences.lApresMidi,"O/N")
        	+ "-" + absences.cTypeAbsence
        	.
        	
        /* Si l'absence a déjà été signalée, on ne fait rien */
        IF NOT(lForcage-in) AND DonnePreference(cTempo) = "OUI" THEN NEXT.
        
        IF (absences.lmatin AND absences.lApresMidi) THEN
            cAbsJour-Journee = cAbsJour-Journee 
            	+ (IF cAbsJour-Journee <> "" THEN ", " ELSE "") 
            	+ DonneVraiNomUtilisateur(absences.cUtilisateur)
            	+ " (" + STRING(absences.ddate,"99/99/9999") + " - " + DonneTypeAbsence(absences.cTypeAbsence) + ")".
        ELSE IF (absences.lmatin) THEN
            cAbsJour-Matin = cAbsJour-Matin 
            	+ (IF cAbsJour-Matin <> "" THEN ", " ELSE "") 
            	+ DonneVraiNomUtilisateur(absences.cUtilisateur)
            	+ " (" + STRING(absences.ddate,"99/99/9999") + " - " + DonneTypeAbsence(absences.cTypeAbsence) + ")".
        ELSE IF (absences.lApresMidi) THEN
            cAbsJour-ApresMidi = cAbsJour-ApresMidi 
	            + (IF cAbsJour-ApresMidi <> "" THEN ", " ELSE "") 
	            + DonneVraiNomUtilisateur(absences.cUtilisateur)
	        	+ " (" + STRING(absences.ddate,"99/99/9999") + " - " + DonneTypeAbsence(absences.cTypeAbsence) + ")".

	     IF NOT(lForcage-in) THEN SauvePreference(cTempo,"OUI").
    END.
    IF cAbsJour-Journee <> "" OR cAbsJour-Matin <> "" OR cAbsJour-ApresMidi <> "" THEN DO:
        IF cAbsJour-Matin <> "" THEN
	        cAbsJour = "Absent le matin : " + cAbsJour-Matin.
	    IF cAbsJour-ApresMidi <> "" THEN 
	    	cAbsJour = cAbsJour + (IF cAbsJour <> "" THEN CHR(10) ELSE "") + "Absent l'après-midi : " + cAbsJour-ApresMidi.
	    IF cAbsJour-Journee <> "" THEN 
	    	cAbsJour = cAbsJour + (IF cAbsJour <> "" THEN CHR(10) ELSE "") + "Absent toute la journée : " + cAbsJour-Journee.
    END.
    cAbsFutures-ou = cAbsJour.
    
END PROCEDURE.

PROCEDURE FormateAbsences-2:
	DEFINE INPUT 	PARAMETER lForcage-in 		AS LOGICAL 		NO-UNDO.
	DEFINE OUTPUT 	PARAMETER cAbsJour-ou 		AS CHARACTER 	NO-UNDO.
	DEFINE OUTPUT 	PARAMETER cAbsFutures-ou 	AS CHARACTER 	NO-UNDO.

    DEFINE VARIABLE cAbsJour 		AS CHARACTER 	NO-UNDO.
    DEFINE VARIABLE iNombreJours 	AS INTEGER 		NO-UNDO.
    DEFINE VARIABLE cTempo 			AS CHARACTER 	NO-UNDO.
    DEFINE VARIABLE cMode 			AS CHARACTER 	NO-UNDO.
    DEFINE VARIABLE lSautLigne 		AS LOGICAL 		NO-UNDO.
    DEFINE VARIABLE cEntete 		AS CHARACTER 	NO-UNDO.
    DEFINE VARIABLE iIndentation 	AS INTEGER 		NO-UNDO.
    
    lSautLigne = (DonnePreference("PREFS-ABSENCES-UNE-PAR-LIGNE") = "OUI").
    iIndentation = (IF lForcage-in THEN 22 ELSE 25).
    
    /* Absences du jour */
    cAbsJour = "".
    FOR EACH    absences NO-LOCK
        WHERE   absences.ddate = TODAY
        :
        cTempo = "ABSENCES-SIGNALEES"
        	+ "-" + absences.cUtilisateur 
        	+ "-" + STRING(absences.ddate,"99/99/9999")
        	+ "-" + STRING(absences.lmatin,"O/N")
        	+ "-" + STRING(absences.lApresMidi,"O/N")
        	+ "-" + absences.cTypeAbsence
        	.
        	
        /* Si l'absence a déjà été signalée, on ne fait rien */
        IF NOT(lForcage-in) AND DonnePreference(cTempo) = "OUI" THEN NEXT.
        
        IF (absences.lmatin AND absences.lApresMidi) THEN cMode = "".
        ELSE IF absences.lmatin THEN cMode = "Matin".
        ELSE IF absences.lApresMidi THEN cMode = "Après-midi".
        
    	IF lSautLigne THEN DO:
    		cEntete = CHR(10).
    	END.

        cAbsJour = cAbsJour 
        		 + (IF cAbsJour <> "" THEN ", " ELSE "")
        		 + (IF cAbsJour <> "" THEN cEntete ELSE "")
        		 + DonneVraiNomUtilisateur(absences.cUtilisateur) 
        		 + " ("
        		 + (IF cMode <> "" THEN cMode + " - " ELSE "")
        		 + DonneTypeAbsence(absences.cTypeAbsence)
        		 + ")"
        		 .
        
	    IF NOT(lForcage-in) THEN SauvePreference(cTempo,"OUI").
    END.
    cAbsJour-ou = cAbsJour.
    
    /* Absences futures */
    cAbsJour = "".
    iNombreJours = INTEGER(DonnePreference("PREFS-ABSENCES-JOURS")).
    FOR EACH    absences NO-LOCK
        WHERE   absences.ddate > TODAY
        AND		absences.ddate < (TODAY + iNombreJours) 
        BREAK BY absences.ddate	
        :
        cTempo = "ABSENCES-SIGNALEES"
        	+ "-" + absences.cUtilisateur 
        	+ "-" + STRING(absences.ddate,"99/99/9999")
        	+ "-" + STRING(absences.lmatin,"O/N")
        	+ "-" + STRING(absences.lApresMidi,"O/N")
        	+ "-" + absences.cTypeAbsence
        	.
        	
        /* Si l'absence a déjà été signalée, on ne fait rien */
        IF NOT(lForcage-in) AND DonnePreference(cTempo) = "OUI" THEN NEXT.
        
        IF FIRST-OF(absences.ddate) THEN DO:
        	cEntete = (IF cAbsJour <> "" THEN CHR(10) ELSE "") + STRING(absences.ddate,"99/99/9999") + " - ".
        END.
        ELSE DO:
        	IF lSautLigne THEN DO:
        		cEntete = CHR(10) + FILL(" ",iIndentation).
        	END.
        	ELSE DO:
        		cEntete = "".
        	END.
        END.
                
        IF (absences.lmatin AND absences.lApresMidi) THEN cMode = "".
        ELSE IF absences.lmatin THEN cMode = "Matin".
        ELSE IF absences.lApresMidi THEN cMode = "Après-midi".
        
        cAbsJour = cAbsJour 
        		 + (IF cAbsJour <> "" THEN ", " ELSE "")
        		 + cEntete
        		 + DonneVraiNomUtilisateur(absences.cUtilisateur) 
        		 + " ("
        		 + (IF cMode <> "" THEN cMode + " - " ELSE "")
        		 + DonneTypeAbsence(absences.cTypeAbsence)
        		 + ")"
        		 .
        
	     IF NOT(lForcage-in) THEN SauvePreference(cTempo,"OUI").
    END.
    cAbsFutures-ou = cAbsJour.
    
END PROCEDURE.

