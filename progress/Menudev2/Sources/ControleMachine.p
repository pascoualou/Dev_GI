/*---------------------------------------------------------------------------
 Application      : MENUDEV2
 Programme        : ControleMachine.p
 Objet            : Controles divers d'une machine gérée par menudev2
*---------------------------------------------------------------------------
 Date de création : 24/06/2016
 Auteur(s)        : PL
 Dossier analyse  : 
*---------------------------------------------------------------------------
 Entrée :
 Sortie :
 Appel  :
*---------------------------------------------------------------------------
 Modifications :
 ....   ../../....    ....  

*--------------------------------------------------------------------------*/

{dfvarenv.i "NEW SHARED"}         
{asvarenv.i}

/*-------------------------------------------------------------------------*
 | DEFINITIONS                                                             |
 *-------------------------------------------------------------------------*/

SESSION:APPL-ALERT-BOXES = TRUE.

DEFINE VARIABLE cParametres AS CHARACTER NO-UNDO.

DEFINE VARIABLE cRepertoireBases AS CHARACTER NO-UNDO INIT "".
DEFINE VARIABLE cRepertoireBasesDos AS CHARACTER NO-UNDO INIT "".
DEFINE VARIABLE cUtilisateur AS CHARACTER NO-UNDO INIT "".
DEFINE VARIABLE cAdresseMail AS CHARACTER NO-UNDO INIT "".
DEFINE VARIABLE lErreurParametrage AS LOGICAL NO-UNDO INIT FALSE.
DEFINE VARIABLE lPresenceErreurs AS LOGICAL NO-UNDO.
DEFINE VARIABLE lPresenceErreursQuota AS LOGICAL NO-UNDO INIT FALSE.
DEFINE VARIABLE lPresenceAuMoins1Erreur AS LOGICAL NO-UNDO.
DEFINE VARIABLE lFichierSauvegardeExiste AS LOGICAL NO-UNDO.
DEFINE VARIABLE lFichierSauvegardeCorrect AS LOGICAL NO-UNDO.
DEFINE VARIABLE lFichierBaseExiste AS LOGICAL NO-UNDO.
DEFINE VARIABLE lASupprimer AS LOGICAL NO-UNDO.
DEFINE VARIABLE lControleSauvegardePresente AS LOGICAL NO-UNDO.
DEFINE VARIABLE lControleBases AS LOGICAL NO-UNDO.
DEFINE VARIABLE lControleBasePresente AS LOGICAL NO-UNDO.
DEFINE VARIABLE lControleFichier7Z AS LOGICAL NO-UNDO.
DEFINE VARIABLE lVisualisationLog AS LOGICAL NO-UNDO.
DEFINE VARIABLE cMessage AS CHARACTER NO-UNDO.
DEFINE VARIABLE cCommande AS CHARACTER NO-UNDO.
DEFINE VARIABLE lQueSiErreur AS LOGICAL NO-UNDO.
DEFINE VARIABLE lBaseDos AS LOGICAL NO-UNDO.
DEFINE VARIABLE lDisponible AS LOGICAL NO-UNDO.
DEFINE VARIABLE lMail AS LOGICAL NO-UNDO.
DEFINE VARIABLE cFichierControle7z AS CHARACTER NO-UNDO.
DEFINE VARIABLE cNomFichierSvg  AS CHARACTER NO-UNDO.
DEFINE VARIABLE cLigne  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lExclus AS LOGICAL NO-UNDO.
DEFINE VARIABLE cFichierControle AS CHARACTER NO-UNDO.
DEFINE VARIABLE cInfoDisque AS CHARACTER NO-UNDO.
DEFINE VARIABLE iInfoRestant AS INT64 NO-UNDO.
DEFINE VARIABLE iInfoTotal AS INT64 NO-UNDO.
DEFINE VARIABLE iTempoR AS INTEGER NO-UNDO.
DEFINE VARIABLE iTempoT AS INTEGER NO-UNDO.
DEFINE VARIABLE iTempoRatio AS INTEGER NO-UNDO.
DEFINE VARIABLE iRatio AS INTEGER NO-UNDO.
DEFINE VARIABLE lQuota AS LOGICAL NO-UNDO.
DEFINE VARIABLE iQuota AS INTEGER NO-UNDO.
DEFINE VARIABLE cErreurQuota AS CHARACTER NO-UNDO.
DEFINE VARIABLE cPrefixe AS CHARACTER NO-UNDO INIT ">>>>> ".
DEFINE VARIABLE cFichierExclusion AS CHARACTER NO-UNDO.

DEFINE STREAM sSortie.
DEFINE VARIABLE cFichierLog AS CHARACTER NO-UNDO.

          
DEFINE TEMP-TABLE ttBases
	FIELD cNom AS CHARACTER 	
	FIELD cNomComplet AS CHARACTER
	FIELD cTypeEntree AS CHARACTER 
	.          
          
DEFINE TEMP-TABLE ttRepertoires
        LIKE ttbases.
          
DEFINE TEMP-TABLE ttFichiers
        LIKE ttbases.
          
DEFINE TEMP-TABLE ttFichiersSvg
        LIKE ttbases.
          
DEFINE TEMP-TABLE ttControles
	FIELD cNom AS CHARACTER
	FIELD cErreur AS CHARACTER
	.
	
/*-------------------------------------------------------------------------*
 | FONCTIONS (PROTOS)                                                      |
 *-------------------------------------------------------------------------*/
FUNCTION DonneParametre RETURNS CHARACTER(cIdentParametre-in AS CHARACTER) FORWARD.
FUNCTION FormatteTaille RETURNS CHARACTER(iTaille-in AS INT64) FORWARD.

/*-------------------------------------------------------------------------*
 | MAIN BLOCK                                                              |
 *-------------------------------------------------------------------------*/

	cParametres = SESSION:PARAMETER.
	
	/*MESSAGE "cParametres = " cParametres VIEW-AS ALERT-BOX.*/
	
	cFichierLog = DonneParametre("FICHIER-LOG").	
	cUtilisateur = DonneParametre("UTILISATEUR").	

	cAdresseMail = DonneParametre("ADRESSE-EMAIL").

	lControleBases = (DonneParametre("BASES") = "OUI").
	cRepertoireBases = DonneParametre("REPERTOIRE-BASES").	

	lControleBasePresente = lControleBases AND (DonneParametre("BASE+SVG-PRESENTE") = "OUI").
	lControleSauvegardePresente = lControleBases AND (DonneParametre("SVG-PRESENTE") = "OUI" OR lControleBasePresente).
	lControleFichier7Z = lControleBases AND (DonneParametre("FICHIER-7Z") = "OUI").
    
    lQueSiErreur = (DonneParametre("QUE-SI-ERREUR") = "OUI").
    lVisualisationLog = (DonneParametre("VISU-LOG") = "OUI").
    lMail = (DonneParametre("MAIL") = "OUI").

    lBaseDos = (DonneParametre("BASEDOS") = "OUI").
	cRepertoireBasesDos = DonneParametre("repertoire-basesdos").	

    lDisponible = (DonneParametre("DISPONIBLE") = "OUI").
    lExclus = (DonneParametre("EXCLUS") = "OUI").
    lQuota = (DonneParametre("QUOTA") = "OUI").
    iQuota = INTEGER(DonneParametre("QUOTA-VALEUR")).
    

	/* Parametres vitaux */
	lErreurParametrage = FALSE
		OR (cFichierLog = "")
		OR (cRepertoireBases = "")
		OR (cUtilisateur = "")
		.
	IF lErreurParametrage THEN DO:
		MESSAGE "Erreur dans le parametrage de l'appel du programme : "
			+ CHR(10) + "FICHIER-LOG = " + (IF cFichierLog <> ? THEN cFichierLog ELSE "?")
			+ CHR(10) + "REPERTOIRE-BASES = " + (IF cRepertoireBases <> ? THEN cRepertoireBases ELSE "?")
			+ CHR(10) + "UTILISATEUR = " + (IF cUtilisateur <> ? THEN cUtilisateur ELSE "?")
			VIEW-AS ALERT-BOX ERROR
			TITLE "Contrôle des paramètres".
	END.
	
	/* Si pas de fichier log...on arrete ici */
	IF cFichierLog = "" THEN QUIT.
	
	/* Ouverture et vidage du fichier log */
	cFichierLog = loc_log + "\" + cFichierLog.
    RUN EcritLog("#VIDE#").
    
    cMessage =           cPrefixe + "Contrôle de la machine : " + cUtilisateur
    		 + (IF lVisualisationLog THEN CHR(10) ELSE "")
    		 + CHR(10) + CHR(9) + "Le " + STRING(TODAY,"99/99/9999") + " à " + STRING(TIME,"hh:mm:ss")
             + CHR(10)
             + CHR(10) + cPrefixe + "Paramétrage :"
    		 + (IF lVisualisationLog THEN CHR(10) ELSE "")
			 + CHR(10) + CHR(9) + "Utilisateur : " + (IF cUtilisateur <> ? THEN cUtilisateur ELSE "?")
    		 /*+ CHR(10) + CHR(9) + "Fichier log : " + (IF cFichierLog <> ? THEN cFichierLog ELSE "?")*/
			 + CHR(10) + CHR(9) + "Email : " + (IF cAdresseMail <> ? THEN cAdresseMail ELSE "?")
			 + CHR(10) + CHR(9) + "Affichage du fichier log résultat : " + (IF lVisualisationLog <> ? THEN STRING(lVisualisationLog,"OUI/NON") ELSE "?")
			 + CHR(10) + CHR(9) + "Envoi par mail du fichier log résultat : " + (IF lMail <> ? THEN STRING(lMail,"OUI/NON") ELSE "?")
			 + CHR(10) + CHR(9) + CHR(9) + "Affichage du log ou envoi par mail uniquement si présence d'erreur : " + (IF lQueSiErreur <> ? THEN STRING(lQueSiErreur,"OUI/NON") ELSE "?")
			 + CHR(10) + CHR(9) + "Contrôle du répertoire des bases : " + (IF lControleBases <> ? THEN STRING(lControleBases,"OUI/NON") ELSE "?")
			 + CHR(10) + CHR(9) + CHR(9) + "Répertoire des bases : " + (IF cRepertoireBases <> ? THEN cRepertoireBases ELSE "?")
			 + CHR(10) + CHR(9) + CHR(9) + "Contrôle si la sauvegarde de la base client est présente : " + (IF lControleSauvegardePresente <> ? THEN STRING(lControleSauvegardePresente,"OUI/NON") ELSE "?")
			 + CHR(10) + CHR(9) + CHR(9) + "Contrôle si la base est présente en plus de la sauvegarde (xcompil) : " + (IF lControleBasePresente <> ? THEN STRING(lControleBasePresente,"OUI/NON") ELSE "?")
			 + CHR(10) + CHR(9) + CHR(9) + "Contrôle la validité du fichier 7z :  " + (IF lControleFichier7Z <> ? THEN STRING(lControleFichier7Z,"OUI/NON") ELSE "?")
			 + CHR(10) + CHR(9) + CHR(9) + "Traiter aussi les répertoires exclus : " + (IF lExclus <> ? THEN STRING(lExclus,"OUI/NON") ELSE "?")
			 + CHR(10) + CHR(9) + "Contrôle des fichiers oubliés lors des dump-load (Bases-Dos) : " + (IF lBaseDos <> ? THEN STRING(lBaseDos,"OUI/NON") ELSE "?")
			 + CHR(10) + CHR(9) + CHR(9) + "Répertoire Bases-Dos : " + (IF cRepertoireBasesDos <> ? THEN cRepertoireBasesDos ELSE "?")
			 + CHR(10) + CHR(9) + "Résumé de la place disponible sur la machine : " + (IF lDisponible <> ? THEN STRING(lDisponible,"OUI/NON") ELSE "?")
			 + CHR(10) + CHR(9) + CHR(9) + "Prévenir en cas d'espace disponible faible : " + (IF lQuota <> ? THEN STRING(lQuota,"OUI/NON") ELSE "?")
			 + CHR(10) + CHR(9) + CHR(9) + "Limite d'espace libre : " + (IF iQuota <> ? THEN STRING(iQuota) + " %" ELSE "?")
             .
    RUN EcritLog(cMessage).

/*=========================================================================*

                    Contrôle physique de la machine
   
 *=========================================================================*/
   	
   	IF lDisponible THEN DO:
		cFichierControle = loc_tmp + "\disques.tmp".

		RUN InitControles.
        cMessage = CHR(10) + cPrefixe + "Contrôle physique de la machine :"
                 + (IF lVisualisationLog THEN CHR(10) ELSE "")
                 .
        RUN EcritLog(cMessage).
/*        OS-COMMAND SILENT VALUE(ser_outils + "\progress\menudev2\ressources\scripts\general\Disques.vbs " + cFichierControle).*/
        OS-COMMAND SILENT VALUE(loc_outils + "\Disques.vbs " + cFichierControle).
		/* Lecture du fichier sortie */
        INPUT FROM VALUE(cFichierControle).
        REPEAT:
            IMPORT UNFORMATTED cLigne.
            cInfoDisque = ENTRY(1,cLigne).
            iInfoTotal = INT64(ENTRY(2,cLigne)).
            iInfoRestant = INT64(ENTRY(3,cLigne)).
            cErreurQuota = "".
			iRatio = (iInfoRestant / iInfoTotal) * 100.
			IF iRatio < iQuota AND lQuota THEN DO:
				cErreurQuota = " (Espace disponible faible : " + STRING(iRatio) + "%)".
				lPresenceErreursQuota = TRUE.
            END.
            RUN AjouteControle("Disque " + cInfoDisque ,lPresenceErreursQuota /*FALSE*/,FormatteTaille(iInfoRestant) + " / " + FormatteTaille(iInfoTotal) + cErreurQuota).
        END.
        INPUT CLOSE.
        /*
        lPresenceErreurs = lPresenceErreursQuota.
		lPresenceAuMoins1Erreur = lPresenceErreursQuota.
        */
		RUN EcritControles(lPresenceErreursQuota).
    END.
        	
/*=========================================================================*

                    Contrôle des répertoires des bases
   
 *=========================================================================*/
	IF lControleBases THEN DO:
		RUN InitControles.
	
	    cMessage = CHR(10) + cPrefixe + "Contrôle des répertoires des bases :"
	             + (IF lVisualisationLog THEN CHR(10) ELSE "")
	             .
	    RUN EcritLog(cMessage).
	    	
		/* Récupération de la liste des bases */
		EMPTY TEMP-TABLE ttbases.
		INPUT FROM OS-DIR (cRepertoireBases).
		REPEAT:
			CREATE ttbases.
			IMPORT ttbases.cNom ttbases.cNomComplet ttbases.cTypeEntree.
		END.
		INPUT CLOSE.
		
		/* épuration de la table temporaire */
		FOR EACH ttbases:
			lASupprimer = FALSE.
			IF ttbases.cNom = "." THEN lASupprimer = TRUE.
			IF ttbases.cNom = ".." THEN lASupprimer = TRUE.
			IF ttbases.cTypeEntree <> "D" THEN lASupprimer = TRUE.
			IF ttbases.cNom MATCHES "*.exc" AND NOT(lExclus) THEN lASupprimer = TRUE. /* Répertoires à exclure du controle */
			IF lASupprimer THEN DELETE ttbases.
		END.
		
		/* controles */
		FOR EACH ttbases:
		    cFichierExclusion = cRepertoireBases + "\" + ttBases.cNom + "\_Exclusion.txt".
		    IF SEARCH(cFichierExclusion) <> ? THEN NEXT.
		    IF lControleBasePresente THEN DO:
	    	    /* Lecture des fichiers du repertoire */
	            EMPTY TEMP-TABLE ttfichiers.
	        	INPUT FROM OS-DIR (ttbases.cNomComplet).
	        	REPEAT:
	        		CREATE ttfichiers.
	        		IMPORT ttfichiers.cNom ttfichiers.cNomComplet ttfichiers.cTypeEntree.
	        	END.
	        	INPUT CLOSE.
	        	/* épuration de la table temporaire */
	        	FOR EACH ttfichiers:
	        	    lASupprimer = FALSE.
	        		IF ttfichiers.cNom = "." THEN lASupprimer = TRUE.
	        		IF ttfichiers.cNom = ".." THEN lASupprimer = TRUE.
	        		IF ttfichiers.cTypeEntree <> "F" THEN lASupprimer = TRUE.
	    	        IF lASupprimer THEN DELETE ttfichiers.
	        	END.
	            /* Recherche de la base */
	            lFichierBaseExiste = FALSE.
	            FOR EACH ttfichiers :
	                IF ttfichiers.cNom BEGINS ("sadb")
	                OR ttfichiers.cNom BEGINS ("cadb")
	                OR ttfichiers.cNom BEGINS ("compta")
	                OR ttfichiers.cNom BEGINS ("inter")
	                OR ttfichiers.cNom BEGINS ("trans")
	                THEN lFichierBaseExiste = TRUE.
	            END.
	        END.
	        	    
	    	/* Lecture des répertoires du repertoire */
		    EMPTY TEMP-TABLE ttRepertoires.
	    	INPUT FROM OS-DIR (ttbases.cNomComplet).
	    	REPEAT:
	    		CREATE ttRepertoires.
	    		IMPORT ttRepertoires.cNom ttRepertoires.cNomComplet ttRepertoires.cTypeEntree.
	    	END.
	    	INPUT CLOSE.
	    	/* épuration de la table temporaire */
	    	FOR EACH ttRepertoires:
	    		lASupprimer = FALSE.
	    		IF ttRepertoires.cNom = "." THEN lASupprimer = TRUE.
	    		IF ttRepertoires.cNom = ".." THEN lASupprimer = TRUE.
	    		IF ttRepertoires.cTypeEntree <> "D" THEN lASupprimer = TRUE.
			    IF lASupprimer THEN DELETE ttRepertoires.
	    	END.
		
			/* présence du répertoire svg en cours */
			FIND FIRST  ttRepertoires
			    WHERE   ttRepertoires.cNom = "svg"
			    AND     ttRepertoires.cTypeEntree = "D"
			    NO-ERROR.
			IF NOT(AVAILABLE(ttRepertoires)) THEN DO:
				RUN AjouteControle(ttbases.cNom,TRUE,"Répertoire de sauvegarde 'svg' inexistant").
			END.
			ELSE IF lControleSauvegardePresente THEN DO:
	        	/* Lecture des fichiers du repertoire svg */
		        EMPTY TEMP-TABLE ttfichierssvg.
	        	INPUT FROM OS-DIR (ttRepertoires.cNomComplet).
	        	REPEAT:
	        		CREATE ttfichierssvg.
	        		IMPORT ttfichierssvg.cNom ttfichierssvg.cNomComplet ttfichierssvg.cTypeEntree.
	        	END.
	        	INPUT CLOSE.
	        	/* épuration de la table temporaire */
	        	FOR EACH ttfichierssvg:
	        	    lASupprimer = FALSE.
	        		IF ttfichierssvg.cNom = "." THEN lASupprimer = TRUE.
	        		IF ttfichierssvg.cNom = ".." THEN lASupprimer = TRUE.
	        		IF ttfichierssvg.cTypeEntree <> "F" THEN lASupprimer = TRUE.
			        IF lASupprimer THEN DELETE ttfichierssvg.
	        	END.
		
	    		/* Controle du fichier de sauvegarde */
	    		lFichierSauvegardeexiste = FALSE.
	    		lFichierSauvegardeCorrect = FALSE.
	    		FOR EACH    ttfichierssvg
	    		    WHERE   ttfichierssvg.cNom MATCHES "*.7z"
	    		    AND     ttfichierssvg.cTypeEntree = "F"
	    		    :
	    		    lFichierSauvegardeexiste = TRUE.
	    		    IF ttfichierssvg.cNom = ttbases.cNom + ".7z" THEN lFichierSauvegardeCorrect = TRUE.
	    		    cNomFichierSvg = ttfichierssvg.cNomComplet.
	    		END.
	    		IF NOT(lFichierSauvegardeexiste) THEN DO:
	    			RUN AjouteControle(ttbases.cNom,TRUE,"Fichier de sauvegarde inexistant").
	    		END.
	    		ELSE DO:
	    		    IF NOT(lFichierSauvegardeCorrect) THEN DO:
	        			RUN AjouteControle(ttbases.cNom,TRUE,"Fichier de sauvegarde mal nommé").
	    		    END.
	    		    ELSE DO:
	                    IF lFichierBaseExiste THEN DO:
	        			    RUN AjouteControle(ttbases.cNom,TRUE,"Base présente + Fichier de sauvegarde présent").
	                    END.
	                    /* Controle de la validité du fichier 7z */
	                    IF lControleFichier7Z THEN DO:
                            cFichierControle7z = loc_tmp + "\" + ttbases.cNom + ".ver".
	                        OS-COMMAND SILENT VALUE(loc_appli + "\exe\7-zip\7z.exe t " + cNomFichierSvg + " * > " + cFichierControle7z).
	                        /* Lecture du fichier à la recherche du résultat */
	                        INPUT FROM VALUE(cFichierControle7z).
                            REPEAT:
                                IMPORT UNFORMATTED cLigne.
                                IF cLigne MATCHES ("*Error*") THEN DO:
	        			            RUN AjouteControle(ttbases.cnom,TRUE,"Validité 7z : " + cLigne).
                                END.
                            END.
	                        INPUT CLOSE.
	                    END.
	    		    END.
	    		END.
	        END.		
		
		END.
		
		RUN EcritControles(TRUE).
	END.	
/*=========================================================================*

                    Contrôle des basedos oubliées
   
 *=========================================================================*/
   	
   	IF lBaseDos THEN DO:
   		RUN InitControles.
        cMessage = CHR(10) + cPrefixe + "Contrôle du répertoire 'bases-dos' :"
                 + (IF lVisualisationLog THEN CHR(10) ELSE "")
                 .
        RUN EcritLog(cMessage).
        
        FILE-INFO:FILE-NAME = cRepertoireBasesDos.
        IF FILE-INFO:FULL-PATHNAME <> ? THEN DO:
	        
		    EMPTY TEMP-TABLE ttRepertoires.
	    	INPUT FROM OS-DIR (cRepertoireBasesDos).
	    	REPEAT:
	    		CREATE ttRepertoires.
	    		IMPORT ttRepertoires.cNom ttRepertoires.cNomComplet ttRepertoires.cTypeEntree.
	    	END.
	    	INPUT CLOSE.
	    	/* épuration de la table temporaire */
	    	FOR EACH ttRepertoires:
	    		lASupprimer = FALSE.
	    		IF ttRepertoires.cNom = "." THEN lASupprimer = TRUE.
	    		IF ttRepertoires.cNom = ".." THEN lASupprimer = TRUE.
	    		IF ttRepertoires.cTypeEntree <> "D" THEN lASupprimer = TRUE.
			    IF lASupprimer THEN DELETE ttRepertoires.
	    	END.
	    	FOR EACH ttRepertoires:
	            EMPTY TEMP-TABLE ttfichiers.
	        	INPUT FROM OS-DIR (ttRepertoires.cNomComplet).
	        	REPEAT:
	        		CREATE ttfichiers.
	        		IMPORT ttfichiers.cNom ttfichiers.cNomComplet ttfichiers.cTypeEntree.
	        	END.
	        	INPUT CLOSE.
	        	/* épuration de la table temporaire */
	        	FOR EACH ttfichiers:
	        	    lASupprimer = FALSE.
	        		IF ttfichiers.cNom = "." THEN lASupprimer = TRUE.
	        		IF ttfichiers.cNom = ".." THEN lASupprimer = TRUE.
	        		IF ttfichiers.cTypeEntree <> "F" THEN lASupprimer = TRUE.
	    	        IF lASupprimer THEN DELETE ttfichiers.
	        	END.
	        	FIND FIRST ttFichiers NO-ERROR.
	        	IF AVAILABLE(ttFichiers) THEN DO:
				    RUN AjouteControle(cRepertoireBasesDos + "\" + ttRepertoires.cNom,TRUE,"Des fichiers sont présents dans ce répertoire").
	        	END.
	        END.
	    END.
	    ELSE DO:
		    RUN AjouteControle(cRepertoireBasesDos,TRUE,"Répertoire inexistant").
		END.
		RUN EcritControles(TRUE).
	END.

        	
/*=========================================================================*

                    Affichage du fichier log
   
 *=========================================================================*/
   	
    /* Visualisation du log */
    IF (lVisualisationLog AND NOT(lQueSiErreur)) THEN DO:
        OS-COMMAND NO-WAIT VALUE(cFichierLog).
    END.
    
/*=========================================================================*

                    Mail d'avertissement
   
 *=========================================================================*/
    IF ((lPresenceAuMoins1Erreur AND lQueSiErreur) OR NOT(lQueSiErreur)) AND cAdresseMail <> "" AND lMail THEN DO:
        RUN EcritLog(CHR(10) + CHR(10)).
        RUN EcritLog(cPrefixe + "Envoi du log par mail à : " + cAdresseMail).
        
        cCommande = "%reseau%\dev\outils\blat\blat.exe " + cFichierLog 
            + " -subject ""Controle de la machine de l'utilisateur : """ + cUtilisateur
            + " -to """ + cAdresseMail + """"
            + " -from """ + cUtilisateur + "@la-gi.fr" + """"
            + "  -p %PROFILE_BLAT%"
            + " "
            .
        IF cCommande <> ? THEN OS-COMMAND SILENT VALUE(cCommande).
    END.
	
/*=========================================================================*

                             FIN
   
 *=========================================================================*/
   	
 	QUIT.
 	
/*-------------------------------------------------------------------------*
 | PROCEDURES                                                             |
 *-------------------------------------------------------------------------*/

PROCEDURE InitControles:

	EMPTY TEMP-TABLE ttControles.
	lPresenceErreurs = FALSE.

END PROCEDURE.

PROCEDURE EcritControles:
    DEFINE INPUT PARAMETER lGestionAnomalie-in AS LOGICAL.
    
	IF lGestionAnomalie-in THEN DO: 
    	/* Récupération de la liste des erreurs */
        IF lPresenceErreurs THEN DO:
            cMessage = CHR(9) + ">>>> Anomalies : "
            		+ CHR(10) + "".
        	FOR EACH ttControles: 
        	    cMessage = cMessage 
        	        + CHR(10) + CHR(9) + ttControles.cNom + " --> " + ttControles.cErreur.
        	END.
        END.
        ELSE DO:
            cMessage = CHR(9) + ">>>> Aucune Anomalie".
        END.
    END.
    ELSE DO:
        cMessage = CHR(9) + ">>>> Résultat : "
        		+ CHR(10) + "".
    	FOR EACH ttControles: 
    	    cMessage = cMessage 
    	        + CHR(10) + CHR(9) + ttControles.cNom + " --> " + ttControles.cErreur.
    	END.
    END.
    RUN EcritLog(cMessage).


END PROCEDURE.

PROCEDURE AjouteControle:

	DEFINE INPUT PARAMETER cNom-in AS CHARACTER NO-UNDO.
	DEFINE INPUT PARAMETER lErreur-in AS LOGICAL NO-UNDO.
	DEFINE INPUT PARAMETER cLibelle-in AS CHARACTER NO-UNDO.
	
	CREATE ttControles.
	ASSIGN
		ttControles.cNom = cNom-in
		ttControles.cErreur = cLibelle-in
		.
		IF lErreur-in THEN lPresenceErreurs = TRUE.
		IF lErreur-in THEN lPresenceAuMoins1Erreur = TRUE.
		

END PROCEDURE.

PROCEDURE EcritLog:

	DEFINE INPUT PARAMETER cMessage-in AS CHARACTER NO-UNDO.
	
	IF cMessage-in = "#VIDE#" THEN 
        OUTPUT STREAM sSortie TO VALUE(cFichierLog).
    ELSE DO:
        OUTPUT STREAM sSortie TO VALUE(cFichierLog) APPEND.
        PUT STREAM sSortie UNFORMATTED cMessage-in SKIP.
    END.
        
    OUTPUT STREAM sSortie CLOSE.
    
END PROCEDURE.

/*-------------------------------------------------------------------------*
 | FONCTIONS                                                               |
 *-------------------------------------------------------------------------*/
FUNCTION DonneParametre RETURNS CHARACTER(cIdentParametre-in AS CHARACTER):

	DEFINE VARIABLE iBoucle AS INTEGER NO-UNDO INIT 0.
	DEFINE VARIABLE cCode AS CHARACTER NO-UNDO INIT "".
	DEFINE VARIABLE cValeur AS CHARACTER NO-UNDO INIT "".
	
	DO iBoucle = 1 TO NUM-ENTRIES(cParametres,"|"):
		cCode = ENTRY(iBoucle,cParametres,"|").
		IF ENTRY(1,cCode,"=") = cIdentParametre-in THEN DO:
			cValeur = ENTRY(2,cCode,"=").
		END.
	END.
	
	RETURN cValeur.
	
END FUNCTION.

FUNCTION FormatteTaille RETURNS CHARACTER(iTaille-in AS INT64):

	DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO.
	DEFINE VARIABLE cUnite AS CHARACTER NO-UNDO INIT "Ko".
	DEFINE VARIABLE iValeur AS DECIMAL NO-UNDO.
	DEFINE VARIABLE iValeurTempo AS DECIMAL NO-UNDO.
	
	iValeur = iTaille-in.
	iValeurTempo = TRUNCATE(iValeur / 1000,3).
	IF ivaleurTempo > 1 THEN DO:
		iValeur = iValeurTEmpo.
		cUnite = "Mo".
	END.
    
	iValeurTempo = TRUNCATE(iValeur / 1000,3).
	IF ivaleurTempo > 1 THEN DO:
	    iValeur = iValeurTEmpo.
		cUnite = "Go".
	END.
	iValeurTempo = TRUNCATE(iValeur / 1000,3).
	IF ivaleurTempo > 1 THEN DO:
		iValeur = iValeurTEmpo.
		cUnite = "To".
	END.
	
	cRetour = STRING(iValeur,">>>9.999") + " " + cUnite.
    RETURN cRetour.
        
END FUNCTION.

