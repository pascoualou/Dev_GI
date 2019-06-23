/*--------------------------------------------------------------------------*
| Programme        : versions.i                                             |
| Objet            : Gestion des version de MAGI                            |
|---------------------------------------------------------------------------|
| Date de cr‚ation : 20/01/2015                                             |
| Auteur(s)        : PL                                                     |
*---------------------------------------------------------------------------*

*---------------------------------------------------------------------------*
| Historique des modifications                                              |
|---------------------------------------------------------------------------|
|  Nø  |    Date    | Auteur |                  Objet                       |
|------+------------+--------+----------------------------------------------|
| .... | ../../.... |  ....  | .                                            |
*--------------------------------------------------------------------------*/

{includes\i_temps.i}

/*-------------------------------------------------------------------------*
 | DEFINITIONS                                                             |
 *-------------------------------------------------------------------------*/
    DEFINE {1} SHARED VARIABLE ghGeneral                 AS HANDLE       NO-UNDO.
    DEFINE {1} SHARED VARIABLE gcAllerRetour             AS CHARACTER    NO-UNDO.
    DEFINE {1} SHARED VARIABLE gcUtilisateurInitial     AS CHARACTER    NO-UNDO.
    
    DEFINE VARIABLE gcRetourProcedure        AS CHARACTER  NO-UNDO INIT "".
       
    DEFINE {1} SHARED STREAM gstrEntree.
    DEFINE {1} SHARED STREAM gstrSortie.
    
    /* Pour les répertoires privés */
    DEFINE {1} SHARED VARIABLE gcRepertoireRessourcesPrivees  AS CHARACTER    NO-UNDO.
    DEFINE {1} SHARED VARIABLE gcRepertoireMontage  AS CHARACTER    NO-UNDO.
    DEFINE {1} SHARED VARIABLE giNiveauUtilisateur      AS INTEGER  NO-UNDO.
    DEFINE {1} SHARED VARIABLE gcGroupeUtilisateur      AS CHARACTER  NO-UNDO.
    DEFINE {1} SHARED VARIABLE giVersionUtilisateur     AS INTEGER  NO-UNDO.
    DEFINE {1} SHARED VARIABLE glUtilisateurAdmin       AS LOGICAL  NO-UNDO INIT FALSE.
    
    DEFINE {1} SHARED TEMP-TABLE gttParam
        FIELD cIdent    AS CHARACTER
        FIELD cValeur   AS CHARACTER
        .



/*-------------------------------------------------------------------------*
 | MAIN BLOCK                                                              |
 *-------------------------------------------------------------------------*/
    /* Variables de travail */
    
    /* Nom de l'application */
    gcNomApplication = "Versions".
    gcRepertoireRessourcesPrivees = gcRepertoireApplication + "ressources\".
    gcRepertoireMontage = reseau + "gi\maj\versions".
	glLogActif = false.    

/* -------------------------------------------------------------------------
   Ecrit dans le log
   ----------------------------------------------------------------------- */
FUNCTION gMlog RETURNS LOGICAL (cLibelleMessage AS CHARACTER):
    IF NOT(glLogActif) THEN RETURN FALSE.
    IF VALID-HANDLE(hProcGene) THEN RUN MLog IN hProcGene (cLibelleMessage) NO-ERROR.
    RETURN TRUE.
END FUNCTION.

/* -------------------------------------------------------------------------
   Formatte une date pour ecriture dans un fichier (éviter les ?)
   ----------------------------------------------------------------------- */
FUNCTION gFormatteValeur RETURNS CHARACTER (cValeur-in AS CHARACTER):
    DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO INIT "?".

    IF cValeur-in <> ? THEN cRetour = cValeur-in.

    RETURN cRetour.
    
END FUNCTION.

/* -------------------------------------------------------------------------
   Donne la valeur d'un ident des préférences
   ----------------------------------------------------------------------- */
FUNCTION gDonnePreference RETURNS CHARACTER ( INPUT cIdent-in AS CHARACTER ) :
    DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO INIT "".

    FIND FIRST  Prefs   NO-LOCK
        WHERE   Prefs.cUtilisateur = gcUtilisateur
        AND     Prefs.cCode = cIdent-in 
        NO-ERROR.
    IF AVAILABLE(Prefs) THEN cRetour = Prefs.cValeur.

    RETURN cRetour.   

END FUNCTION.

/* -------------------------------------------------------------------------
   Sauve la valeur d'un ident des préférences
   ----------------------------------------------------------------------- */
FUNCTION gSauvePreference RETURNS LOGICAL ( INPUT cIdent-in AS CHARACTER,INPUT cValeur-in AS CHARACTER ) :

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

/* -------------------------------------------------------------------------
   Ajout d'un parametre global à la session
   ----------------------------------------------------------------------- */
FUNCTION gAddParam RETURNS LOGICAL (cIdent-in AS CHARACTER,cValeur-in AS CHARACTER):
	DEFINE VARIABLE lRetour AS LOGICAL NO-UNDO INIT FALSE.
	
	/* Vérification d'existence */
	find first gttParam
		where gttParam.cIdent = cIdent-in
		no-error.
	if not(available(gttParam)) then do:
		create gttParam.
		gttParam.cIdent = cIdent-in.
	end.
	
	gttParam.cValeur = cValeur-in.
	return(lRetour).
END FUNCTION.     

/* -------------------------------------------------------------------------
   récupération d'un parametre global à la session
   ----------------------------------------------------------------------- */
function gGetParam returns character (cIdent-in as character):
	define variable cRetour as character no-undo init "".
	
	/* Vérification d'existence */
	find first gttParam
		where gttParam.cIdent = cIdent-in
		no-error.
	if (available(gttParam)) then do:
		cRetour = gttParam.cValeur.
	end.
	return(cRetour).
end function. 

/* -------------------------------------------------------------------------
   suppression d'un parametre global à la session
   ----------------------------------------------------------------------- */
function gSupParam returns logical (cIdent-in as character):
	define variable lRetour as logical no-undo init false.
	
	/* Vérification d'existence */
	find first gttParam
		where gttParam.cIdent = cIdent-in
		no-error.
	if (available(gttParam)) then do:
		delete gttParam.
		lRetour = true.
	end.
	return(lRetour).
end function. 


/* -------------------------------------------------------------------------
   Procédure de gestion des impressions
   ----------------------------------------------------------------------- */
PROCEDURE gImpression:
    IF gDonnePreference("PREF-EDITIONSWORD") = "OUI" THEN
        RUN HTML_AfficheFichierAvecWord.
    ELSE
        RUN HTML_AfficheFichier.

END PROCEDURE.

/* -------------------------------------------------------------------------
   Procédure de gestion des impressions
   ----------------------------------------------------------------------- */
PROCEDURE gImpressionFichier:
DEFINE INPUT PARAMETER cFichier AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER cTitre AS CHARACTER NO-UNDO.

    IF gDonnePreference("PREF-EDITIONSWORD") = "OUI" THEN
        RUN HTML_EditeFichierAvecWord(cFichier,cTitre).
    ELSE
        RUN HTML_EditeFichier(cFichier,cTitre).

END PROCEDURE.


/* -------------------------------------------------------------------------
   Procédure de déchargement des variables de l'application dans un fichier
   ----------------------------------------------------------------------- */
PROCEDURE gDechargeVariables:

    DEFINE VARIABLE cFichier AS CHARACTER NO-UNDO.

    cFichier = loc_tmp + "Versions-Variables.txt".

    OUTPUT STREAM gstrSortie TO VALUE(cFichier).

    PUT STREAM gstrSortie UNFORMATTED FILL("-",80) SKIP.
    PUT STREAM gstrSortie UNFORMATTED "VARIABLES GLOBALES..." SKIP(1).

     PUT STREAM gstrSortie UNFORMATTED "ghGeneral = " + gformatteValeur(string(ghGeneral)) SKIP.
     PUT STREAM gstrSortie UNFORMATTED "gcAllerRetour = " + gformatteValeur(gcAllerRetour) SKIP.
     PUT STREAM gstrSortie UNFORMATTED "gcUtilisateurInitial = " + gformatteValeur(gcUtilisateurInitial) SKIP.
     PUT STREAM gstrSortie UNFORMATTED "gcRetourProcedure = " + gformatteValeur(gcRetourProcedure) SKIP.
     PUT STREAM gstrSortie UNFORMATTED "gcRepertoireRessourcesPrivees = " + gformatteValeur(gcRepertoireRessourcesPrivees) SKIP.
     PUT STREAM gstrSortie UNFORMATTED "gcRepertoireRessources = " + gformatteValeur(gcRepertoireRessources) SKIP.
     
     PUT STREAM gstrSortie UNFORMATTED FILL("-",80) SKIP.
     PUT STREAM gstrSortie UNFORMATTED "VARIABLES GLOBALES OUTILGI..." SKIP(1).
    
     PUT STREAM gstrSortie UNFORMATTED "ser_outils = " + gformatteValeur(ser_outils) SKIP.
     PUT STREAM gstrSortie UNFORMATTED "ser_outadb = " + gformatteValeur(ser_outadb) SKIP.
     PUT STREAM gstrSortie UNFORMATTED "ser_outgest = " + gformatteValeur(ser_outgest) SKIP.
     PUT STREAM gstrSortie UNFORMATTED "ser_outcadb = " + gformatteValeur(ser_outcadb) SKIP.
     PUT STREAM gstrSortie UNFORMATTED "ser_outtrans = " + gformatteValeur(ser_outtrans) SKIP.
     PUT STREAM gstrSortie UNFORMATTED "ser_appli = " + gformatteValeur(ser_appli) SKIP.
     PUT STREAM gstrSortie UNFORMATTED "ser_appdev = " + gformatteValeur(ser_appdev) SKIP.
     PUT STREAM gstrSortie UNFORMATTED "ser_tmp = " + gformatteValeur(ser_tmp) SKIP.
     PUT STREAM gstrSortie UNFORMATTED "ser_log = " + gformatteValeur(ser_log) SKIP.
     PUT STREAM gstrSortie UNFORMATTED "ser_intf = " + gformatteValeur(ser_intf) SKIP.
     PUT STREAM gstrSortie UNFORMATTED "ser_dat = " + gformatteValeur(ser_dat) SKIP.
     PUT STREAM gstrSortie UNFORMATTED "loc_outils = " + gformatteValeur(loc_outils) SKIP.
     PUT STREAM gstrSortie UNFORMATTED "loc_outadb = " + gformatteValeur(loc_outadb) SKIP.
     PUT STREAM gstrSortie UNFORMATTED "loc_outgest = " + gformatteValeur(loc_outgest) SKIP.
     PUT STREAM gstrSortie UNFORMATTED "loc_outcadb = " + gformatteValeur(loc_outcadb) SKIP.
     PUT STREAM gstrSortie UNFORMATTED "loc_outtrans = " + gformatteValeur(loc_outtrans) SKIP.
     PUT STREAM gstrSortie UNFORMATTED "loc_appli = " + gformatteValeur(loc_appli) SKIP.
     PUT STREAM gstrSortie UNFORMATTED "loc_appdev = " + gformatteValeur(loc_appdev) SKIP.
     PUT STREAM gstrSortie UNFORMATTED "loc_tmp = " + gformatteValeur(loc_tmp) SKIP. 
     PUT STREAM gstrSortie UNFORMATTED "loc_log = " + gformatteValeur(loc_log) SKIP.
     PUT STREAM gstrSortie UNFORMATTED "loc_intf = " + gformatteValeur(loc_intf) SKIP.
     PUT STREAM gstrSortie UNFORMATTED "RpOriGi = " + gformatteValeur(RpOriGi) SKIP.
     PUT STREAM gstrSortie UNFORMATTED "RpDesGi = " + gformatteValeur(RpDesGi) SKIP.
     PUT STREAM gstrSortie UNFORMATTED "RpOriadb = " + gformatteValeur(RpOriadb) SKIP.
     PUT STREAM gstrSortie UNFORMATTED "RpDesadb = " + gformatteValeur(RpDesadb) SKIP.
     PUT STREAM gstrSortie UNFORMATTED "RpOriges = " + gformatteValeur(RpOriges) SKIP. 
     PUT STREAM gstrSortie UNFORMATTED "RpDesges = " + gformatteValeur(RpDesges) SKIP.
     PUT STREAM gstrSortie UNFORMATTED "RpOricad = " + gformatteValeur(RpOricad) SKIP.
     PUT STREAM gstrSortie UNFORMATTED "RpDescad = " + gformatteValeur(RpDescad) SKIP.
     PUT STREAM gstrSortie UNFORMATTED "RpOritrf = " + gformatteValeur(RpOritrf) SKIP.
     PUT STREAM gstrSortie UNFORMATTED "RpDestrf = " + gformatteValeur(RpDestrf) SKIP.
    
     PUT STREAM gstrSortie UNFORMATTED FILL("-",80) SKIP.
     PUT STREAM gstrSortie UNFORMATTED "TABLES PARTAGEES..." SKIP(1).
/*----
     PUT STREAM gstrSortie UNFORMATTED "gttParam = " SKIP.
     FOR EACH gttparam:
         PUT STREAM gstrSortie UNFORMATTED "    cIdent = " + gformatteValeur(gttparam.cident) SKIP.
         PUT STREAM gstrSortie UNFORMATTED "    cValeur = " + gformatteValeur(gttparam.cValeur) SKIP.
         PUT STREAM gstrSortie UNFORMATTED "--------------------" SKIP.
     END.
----*/      
    OUTPUT STREAM gstrSortie CLOSE.
    OS-COMMAND NO-WAIT VALUE(cFichier).
    
END PROCEDURE.

/* -------------------------------------------------------------------------
   Procédure de gestion des utilisateurs
   ----------------------------------------------------------------------- */
PROCEDURE gGereUtilisateurs:

    /* Recherche de l'utilisateur en cours */
    FIND FIRST  Utilisateurs    EXCLUSIVE-LOCK
        WHERE  Utilisateurs.cUtilisateur = gcUtilisateur
        NO-ERROR.
    IF NOT(AVAILABLE(Utilisateurs)) THEN DO:
        /* Création de l'utilisateur car inexistant */
        CREATE Utilisateurs.
        Utilisateurs.cUtilisateur = gcUtilisateur.
    END.


    /* Au passage, mémorisation du flag administrateur et des infos de l'utilisateur */
    glUtilisateurAdmin = utilisateurs.lAdmin.
    giNiveauUtilisateur = utilisateurs.iNiveau.
    gcGroupeUtilisateur = utilisateurs.cGroupe.
    
    /* gestion des versions */
    IF utilisateurs.iVersion = 0 THEN utilisateurs.iVersion = 1.
    giVersionUtilisateur = utilisateurs.iversion.
    
    /* Libération de l'enregistrement */
    RELEASE utilisateurs.

END PROCEDURE.


