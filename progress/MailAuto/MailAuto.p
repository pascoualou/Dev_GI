/*---------------------------------------------------------------------------
 Application      : MAGI
 Programme        : MailAuto.p
 Objet            : Envoi de mail automatique
                    
*---------------------------------------------------------------------------
 Date de création : 22/01/2016
 Auteur(s)        : PL
 Dossier analyse  : 9999/9999
*---------------------------------------------------------------------------
 Entrée :
 Sortie :
 Appel  :
*---------------------------------------------------------------------------
 Modifications :
 ....   ../../....  ... ...............................................

*--------------------------------------------------------------------------*/

{dfvarenv.i "NEW SHARED"}
{asvarenv.i}

DEFINE VARIABLE cNomApplication         AS CHARACTER NO-UNDO INIT "MailAuto".
DEFINE VARIABLE cRepertoireCourant      AS CHARACTER NO-UNDO.
DEFINE VARIABLE cFichierLog     AS CHARACTER NO-UNDO.
define variable dDateApplication as date no-undo.
define variable iHeureApplication as integer no-undo.

DEFINE VARIABLE cFichierParametres      AS CHARACTER NO-UNDO.
DEFINE VARIABLE cFichierCorpsMail       AS CHARACTER NO-UNDO.
DEFINE VARIABLE cTraitement             AS CHARACTER NO-UNDO.
DEFINE VARIABLE cRepertoireDemon        AS CHARACTER NO-UNDO.
DEFINE VARIABLE cEmail                  AS CHARACTER NO-UNDO.
DEFINE VARIABLE cEmailBis               AS CHARACTER NO-UNDO.
DEFINE VARIABLE cRepertoireTraites      AS CHARACTER NO-UNDO.
DEFINE VARIABLE cLigne AS CHARACTER NO-UNDO.
DEFINE VARIABLE cFichierLogBlat AS CHARACTER NO-UNDO.
DEFINE VARIABLE cCommande AS CHARACTER NO-UNDO.
DEFINE VARIABLE lLog AS LOGICAL NO-UNDO INIT TRUE.


DEFINE TEMP-TABLE ttFichiers
    FIELD cNomFichier AS CHARACTER
    FIELD cNomCompletFichier AS CHARACTER.
    .

DEFINE STREAM sEntree.
DEFINE STREAM sSortie.

FUNCTION MLog RETURNS LOGICAL (cLibelleMessage-in AS CHARACTER):
/* -------------------------------------------------------------------------
   Affichage d'un message dans le fichier Log de l'application
   ----------------------------------------------------------------------- */
    
    DEFINE VARIABLE cPrefixe            AS CHARACTER    NO-UNDO init "> ".
    DEFINE VARIABLE iBoucle             AS INTEGER      NO-UNDO.

    IF lLog OR cLibelleMessage-in BEGINS "!" THEN DO:
	
	    IF cLibelleMessage-in BEGINS "!" THEN cLibelleMessage-in = SUBSTRING(cLibelleMessage-in,2).
	    
        /* Constitution du prefixe de la ligne */
        cPrefixe = string(today,"99/99/9999")
                  + " - "
                  + string(time,"HH:MM:SS")
                   + " - "
                 .
        
        /* Stockage du message si pas à blanc */ 
        IF TRIM(cLibelleMessage-in) <> "" THEN DO:
            cLibelleMessage-in = cPrefixe + cLibelleMessage-in.
            cLibelleMessage-in = REPLACE(cLibelleMessage-in,"%s ",CHR(10)).
            cLibelleMessage-in = REPLACE(cLibelleMessage-in,"%s",CHR(10)).
            cLibelleMessage-in = REPLACE(cLibelleMessage-in,"%t "," / ").
            cLibelleMessage-in = REPLACE(cLibelleMessage-in,"%t"," / ").
            cLibelleMessage-in = REPLACE(cLibelleMessage-in,"%e "," ").
            cLibelleMessage-in = REPLACE(cLibelleMessage-in,"%e"," ").
            DO iBoucle = 1 TO NUM-ENTRIES(cLibelleMessage-in,CHR(10)):
                OUTPUT STREAM sSortie TO VALUE(cFichierLog) append.
                PUT STREAM sSortie UNFORMATTED (IF iBoucle > 1 THEN fill(" ",length(cPrefixe)) ELSE "") + ENTRY(iboucle,cLibelleMessage-in,CHR(10)) SKIP.
                OUTPUT STREAM sSortie CLOSE.
            END.
        END.
    END.
        
    RETURN TRUE.
    
END FUNCTION.

function RemplaceVariables returns character(cChaine-in as character):

    define variable cRetour as character no-undo.
    define variable cyyyymmdd as character no-undo.
    define variable chhmmss as character no-undo.
    
    cyyyymmdd = string(year(dDateApplication),"9999")
          + string(month(dDateApplication),"99")
          + string(day(dDateApplication),"99")
          .
    
    chhmmss = replace(string(iHeureApplication,"hh:mm:ss"),":","").
    
    MLog ("RemplaceVariables - Entrée :"
        + "%e cChaine-in = " + (IF cChaine-in <> ? THEN STRING(cChaine-in) ELSE "?")
        ).

    cRetour = cChaine-in.
    cRetour = replace(cRetour,"[disque]",disque).
    cRetour = replace(cRetour,"[reseau]",reseau).
    cRetour = replace(cRetour,"[dlc]",dlc).
    cRetour = replace(cRetour,"[yyyymmdd]",cyyyymmdd).
    cRetour = replace(cRetour,"[hhmmss]",chhmmss).
    cRetour = replace(cRetour,"[util]",Util).
    
    MLog ("RemplaceVariables - Sortie :"
        + "%e cRetour = " + (IF cRetour <> ? THEN STRING(cRetour) ELSE "?")
        ).

    return cRetour.

end function.

FUNCTION CreChemin RETURNS CHARACTER (cChemin-IN AS CHARACTER,lMuet-IN AS LOGICAL,lFichier-in AS LOGICAL):

	DEFINE VARIABLE cCheminPartiel  AS CHARACTER    NO-UNDO.  	
    DEFINE VARIABLE cRetour         AS CHARACTER    NO-UNDO INIT "".
    DEFINE VARIABLE ierreur         AS INTEGER      NO-UNDO INIT 0.
	DEFINE VARIABLE iBoucle         AS INTEGER      NO-UNDO.
	DEFINE VARIABLE iMax AS INTEGER NO-UNDO.
	
	iMax = NUM-ENTRIES(cChemin-IN,"\").
	/* il s'agit d'un fichier en entrée ? */
	IF lFichier-in THEN iMax = iMax - 1.
	
	/* Parcours du chemin passé en parametre pour création */
	DO iBoucle = 1 TO iMax:
        
        /* Composition du chemin partiel */
        cCheminPartiel = cCheminPartiel 
            + (IF cCheminPartiel <> "" THEN "\" ELSE "")
            + ENTRY(iBoucle,cChemin-IN,"\").
        
        /* Si 1 ere entrée, on considère qu'il s'agit du disque */
        IF iBoucle = 1 THEN NEXT.
        
        /* Sinon on crée l'arborescence */
        OS-CREATE-DIR VALUE(cCheminPartiel).
        ierreur = OS-ERROR.
        IF ierreur NE 0 THEN DO:
            cRetour = cRetour + CHR(10) + "Erreur système n°: " + STRING(ierreur) + " lors de la création du répertoire : " + cCheminPartiel.                
        END.
	END.

    /* Message si demandé */
    IF cRetour <> "" AND NOT(lMuet-IN) THEN DO:
        MESSAGE "Création de répertoires : " + cRetour
            VIEW-AS ALERT-BOX ERROR
            TITLE "CreChemin : Erreur...".
    END.
	  
	RETURN cRetour.
        
END FUNCTION.
    
    /* --------------------------------- MAIN ------------------------------------- */
   
    /* Environnement...................................... */
    dDateApplication = today.
    iHeureApplication = time.
    cRepertoireCourant = REPLACE(PROGRAM-NAME(1),"\" + cNomApplication + ".p","").
    cFichierLog = Loc_Log + "\" + cNomApplication + ".log".
    
    /* Parametres...................................... */
    RUN RecupereParametres.
    
    MLog ("!MailAuto - ***********************  Début de l'application ***********************").
    
    MLog ("Main - Main :"
        + "%s cFichierLog = " + (IF cFichierLog <> ? THEN STRING(cFichierLog) ELSE "?")
        + "%s dDateApplication = " + (IF dDateApplication <> ? THEN STRING(dDateApplication) ELSE "?")
        + "%s iHeureApplication = " + (IF iHeureApplication <> ? THEN STRING(iHeureApplication) ELSE "?")
        + "%s disque = " + (IF disque <> ? THEN STRING(disque) ELSE "?")
        + "%s reseau = " + (IF reseau <> ? THEN STRING(reseau) ELSE "?")
        + "%s dlc = " + (IF dlc <> ? THEN STRING(dlc) ELSE "?")
        + "%s Util = " + (IF Util <> ? THEN STRING(Util) ELSE "?")
        ).
    
    
    MLog ("Main - Paramètres :"
        + "%s cRepertoireCourant = " + (IF cRepertoireCourant <> ? THEN STRING(cRepertoireCourant) ELSE "?")
        + "%s cNomApplication = " + (IF cNomApplication <> ? THEN STRING(cNomApplication) ELSE "?")
        + "%s cRepertoireDemon = " + (IF cRepertoireDemon <> ? THEN STRING(cRepertoireDemon) ELSE "?")
        + "%s cRepertoireTraites = " + (IF cRepertoireTraites <> ? THEN STRING(cRepertoireTraites) ELSE "?")
        + "%s cFichierLogBlat = " + (IF cFichierLogBlat <> ? THEN STRING(cFichierLogBlat) ELSE "?")
        + "%s cFichierCorpsMail = " + (IF cFichierCorpsMail <> ? THEN STRING(cFichierCorpsMail) ELSE "?")
        + "%s cEmail = " + (IF cEmail <> ? THEN STRING(cEmail) ELSE "?")
        + "%s cEmailBis = " + (IF cEmailBis <> ? THEN STRING(cEmailBis) ELSE "?")
        ).
    
    /* Création des répertoires si inexistants */
    CreChemin (cRepertoireDemon,FALSE,FALSE).
    CreChemin (cRepertoireTraites,FALSE,FALSE).
    CreChemin (cFichierCorpsMail,FALSE,TRUE).
    CreChemin (cFichierLogBlat,FALSE,TRUE).
    
    /* Vérification d'existence du fichier du corps du mail */
    IF SEARCH(cFichierCorpsMail) = ? THEN DO:
        OUTPUT STREAM sSortie TO VALUE(cFichierCorpsMail).
        PUT STREAM sSortie UNFORMATTED "Transfert automatique de fichiers par Email." SKIP.
        PUT STREAM sSortie UNFORMATTED "Les fichiers sont en PJ." SKIP(1).
        PUT STREAM sSortie UNFORMATTED Util SKIP(2).
        PUT STREAM sSortie UNFORMATTED "Note : Ce mail est envoyé par un automate. Ne pas y répondre SVP." SKIP.
        OUTPUT STREAM sSortie CLOSE.    
    END.
        
    /* Balayage du répertoire de traitement */        
    INPUT STREAM sEntree FROM OS-DIR(cRepertoireDemon) NO-ATTR-LIST.
    
    REPEAT:
        CREATE ttFichiers.
        IMPORT STREAM sEntree ttFichiers.
    END.
    /* Suppression de l'enregistrement blanc créé en plus pour le dernier fichier */
    DELETE ttFichiers.
    INPUT STREAM sEntree CLOSE.
        
    FOR EACH ttFichiers:
        IF TRIM(ttFichiers.cNomFichier) = "." OR TRIM(ttFichiers.cNomFichier) = ".." THEN NEXT.
        FILE-INFO:FILENAME = ttFichiers.cNomCompletFichier.
        IF FILE-INFO:FILE-TYPE BEGINS("D") THEN NEXT.
        MLog ("!MailAuto - Traitement de : "
            + "%s ttFichiers.cNomFichier = " + (IF ttFichiers.cNomFichier <> ? THEN STRING(ttFichiers.cNomFichier) ELSE "?")
            + "%s FILE-INFO:FileName = " + (IF FILE-INFO:FILENAME <> ? THEN STRING(FILE-INFO:FILENAME) ELSE "?")
            + "%s FILE-INFO:file-type = " + (IF FILE-INFO:FILE-TYPE <> ? THEN STRING(FILE-INFO:FILE-TYPE) ELSE "?")
            + "%s FILE-INFO:full-pathname = " + (IF FILE-INFO:full-pathname <> ? THEN STRING(FILE-INFO:full-pathname) ELSE "?")
            ).
            
        /* Appel de blat */        
        cCommande = "%reseau%\dev\outils\blat\blat.exe " + cFichierCorpsMail 
            + " -subject ""Transfert de fichiers..."""
            + " -to """ + cEmail + """"
            + (IF cEmailBis <> "" THEN " -cc """ + cEmailBis + """" ELSE "")
            + " -log """ + cFichierLogBlat + """"
            + " -from """ + util + "@la-gi.fr" + """"
            + "  -p %PROFILE_BLAT%"
            + " -attach """ + ttFichiers.cNomCompletFichier + """ "
            .
        OS-COMMAND SILENT VALUE(cCommande).
        
        /* Déplacement du fichier traité */
        cCommande = "move """ + ttFichiers.cNomCompletFichier + """ " + cRepertoireTraites.
        OS-COMMAND SILENT VALUE(cCommande).
        
    END.        
    
    MLog ("!MailAuto - ********************  Fin normale de l'application ********************").

    QUIT.

/* -------------------------------------------------------------------------- */

PROCEDURE RecupereParametres:
    
    DEFINE VARIABLE cLigne AS CHARACTER NO-UNDO INIT "".
    DEFINE VARIABLE cParametre AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cValeur AS CHARACTER NO-UNDO.
    
    /* Fichier de parametrage */
    cFichierParametres = cRepertoireCourant + "\" + cNomApplication + ".prm".
    
        /* Valeurs par défaut */
    cRepertoireDemon    = "".
    cRepertoireTraites  = "".
    cFichierLogBlat     = "".
    cEmail              = "".
    cEmailBis           = "".
    
    /* Valeurs paramètrées */
    INPUT STREAM sEntree FROM VALUE(cFichierParametres).
    REPEAT:
        /* Lecture du fichier */
        IMPORT STREAM sEntree UNFORMATTED cLigne. 
        IF TRIM(cLigne) = "" THEN NEXT.  /* lignes blanches */
        IF TRIM(cLigne) BEGINS "#" THEN NEXT.  /* commentaires */
        IF NUM-ENTRIES(cLigne,"=") <> 2 THEN NEXT.  /* Il faut le format xxx=yyy */
        
        /* Décodage de la ligne */
        cParametre = ENTRY(1,cLigne,"=").
        cValeur = ENTRY(2,cLigne,"=").
        CASE cParametre:
            WHEN cNomApplication + "_Traitement" THEN cTraitement = cValeur.
            WHEN cNomApplication + "_Repertoire_Demon" THEN cRepertoireDemon = cValeur.
            WHEN cNomApplication + "_Repertoire_Traites" THEN cRepertoireTraites = cValeur.
            WHEN cNomApplication + "_Email" THEN cEmail = cValeur.
            WHEN cNomApplication + "_EmailBis" THEN cEmailBis = cValeur.
            WHEN cNomApplication + "_CorpsEmail" THEN cFichierCorpsMail = cValeur.
            WHEN cNomApplication + "_LogBlat" THEN cFichierLogBlat = cValeur.
            WHEN cNomApplication + "_NoLog" THEN lLog = NOT(cValeur = "OUI").
            
            /* Surcharge des adresses mail en fonction de l'utilisateur */
            WHEN cNomApplication + "_Email_" + Util THEN cEmail = cValeur.
            WHEN cNomApplication + "_EmailBis_" + Util THEN cEmailBis = cValeur.
            WHEN cNomApplication + "_NoLog_" + Util THEN lLog = NOT(cValeur = "OUI").
        END CASE.
    END.
    INPUT STREAM sEntree CLOSE.
    
    /* Traitement des remplacements de variables */
    cRepertoireDemon    = RemplaceVariables(cRepertoireDemon).
    cRepertoireTraites  = RemplaceVariables(cRepertoireTraites).
    cEmail              = RemplaceVariables(cEmail).
    cEmailBis           = RemplaceVariables(cEmailBis).
    cFichierCorpsMail   = RemplaceVariables(cFichierCorpsMail).
    cFichierLogBlat     = RemplaceVariables(cFichierLogBlat).
    
    /* Log blat dans le log de l'application ou non */
    IF cFichierLogBlat = "" THEN cFichierLogBlat = cFichierLog.

END PROCEDURE.

