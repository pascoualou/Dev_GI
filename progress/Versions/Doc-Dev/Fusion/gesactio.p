/*==G E S A C T I O . P====================================================================================================*/

/*----------------------------------------------------------------------------*/
/*-- .Application   :   ADB                                                 --*/
/*-- .Programme     :   gesactio.p                                          --*/
/*-- .Objet         :   gestion des actions possibles sur un document       --*/
/*----------------------------------------------------------------------------*/
/*-- .Date          :   09/11/1999                                          --*/
/*-- .Auteur        :   AF                                                  --*/
/*----------------------------------------------------------------------------*/
/*-- Historique des modifications                                           --*/
/*----------------------------------------------------------------------------*/
/*  Nø  |    Date    |Auteur|                    Objet                      --*/
/*----------------------------------------------------------------------------*/
/* 0001 | 03/04/2000 |  AF  | .4350 : fenetre des imprimantes de word lors  --*/
/*      |            |      | de l'impression brouillon et definitive       --*/
/* 0002 | 17/11/2001 |  AF  | .Demande 1 seul foi l'imprimante sur          --*/
/*      |            |      | "impression definitive"                       --*/
/* 0003 | 04/09/2006 |  AF  | .0106/0412 : gestin des formulaire            --*/
/* 0004 | 11/12/2006 |  JR  | 1206/0094                                     --*/
/* 0005 | 13/02/2007 |  AF  | 0207/0199 : ouverture d'un word spécifique    --*/
/*      |            |      | pour la fusion                                  |
 | 0006 | 09/07/2009 |  SY  | 1106/0142 : Ajout Impression duplicata document |
 | 0007 | 09/07/2009 |  SY  | 1106/0142 : Ajout Impression Statut document    |
 |      |            |      | + Ajout texte no mandat location dans duplicata |
 | 0008 | 18/09/2009 |  SY  | 1106/0142 : modif IMPDUPLI                      |
 | 0009 | 01/07/2010 |  CC  | Format PDF                                      |
 | 0010 | 12/01/2010 |  PL  | 1110/0079 : controle de la disponibilité du doc |
 |      |            |      | avant de faire le PROTECTIONTYPE                |
 | 0011 | 05/07/2013 |  NP  | 0613/0231 pb besoin ouverture Word avant pour   |
 |      |            |      | Word 2010                                       |
 | 0012 | 21/01/2014 |  NP  | 1013/0076 si option PDF activée permettre de    |
 |      |            |      | modifier le document avant de sauver en pdf     |
 | 0013 | 09/07/2014 |  PL  | Pb sur ouverture Word 2010 & 2013.              |
 |      |            |      |                                                 |
 |      |            |      |                                                 |
 *----------------------------------------------------------------------------*/

/*=========================================================================================================================*/
/*==I N I T I A L I S A T I O N============================================================================================*/
/*=========================================================================================================================*/

/*==F O N C T I O N========================================================================================================*/

/*==D E F I N I T I O N====================================================================================================*/

/*--INCLUDES---------------------------------------------------------------------------------------------------------------*/
    {AllIncMn.i}    /* Include general  */
    {unicode.i}
    {waitapp.i}		/* NP 1013/0076 */

/*--PARAMETRES-------------------------------------------------------------------------------------------------------------*/
    DEF INPUT  PARAMETER LbCheDot   AS CHARACTER    NO-UNDO.
    DEF INPUT  PARAMETER LbCheDoc   AS CHARACTER    NO-UNDO.
    DEF INPUT  PARAMETER LsActUse   AS CHARACTER    NO-UNDO.
    DEF INPUT  PARAMETER FgAffUse   AS LOGICAL      NO-UNDO.
    DEF INPUT  PARAMETER FgLokUse   AS LOGICAL      NO-UNDO.
    DEF OUTPUT PARAMETER CdRetUse   AS CHARACTER    NO-UNDO.
    
/*--VARIABLES--------------------------------------------------------------------------------------------------------------*/
    DEF VAR NoErrUse                AS INTEGER      NO-UNDO.
    DEF VAR NoBacPre                AS INTEGER      NO-UNDO.
    DEF VAR NoBacAut                AS INTEGER      NO-UNDO.
    
    DEF VAR LbDotUse                AS CHARACTER    NO-UNDO.
    
    DEF VAR HwComWrd                AS COM-HANDLE   NO-UNDO.
    DEF VAR HwComDot                AS COM-HANDLE   NO-UNDO.
    DEF VAR HwComDoc                AS COM-HANDLE   NO-UNDO.
    DEF VAR HwComDia                AS COM-HANDLE   NO-UNDO.
    DEF VAR HwComBar                AS COM-HANDLE   NO-UNDO.
    DEF VAR HwComImg                AS COM-HANDLE   NO-UNDO. 

    DEF VAR i                       AS INTEGER      NO-UNDO.

	DEF VAR LbCheDoc-ini			AS CHARACTER	NO-UNDO.
	DEF VAR TpActUse				AS CHARACTER	NO-UNDO.
	DEF VAR LsParDiv				AS CHARACTER	NO-UNDO.
	DEF VAR param1					AS CHARACTER	NO-UNDO.
  	DEF VAR hInstance               AS INTEGER      NO-UNDO.	 

    DEFINE VARIABLE lPDF AS LOGICAL NO-UNDO.  /* PL 09/07/2014 */
  DEFINE VARIABLE  iProtect    AS INTEGER  NO-UNDO INIT ?.   
  DEFINE VARIABLE  iCompteurSecours AS INTEGER  NO-UNDO INIT 0.    
	        
/*==M A I N   B L O C K====================================================================================================*/
	TpActUse = ENTRY(1 , LsActUse , "|").
	IF NUM-ENTRIES( LsActUse , "|") >= 2 THEN DO:
		LsParDiv = ENTRY(2 , LsActUse , "|").
		Param1   = ENTRY(1 , LsParDiv , separ[1] ).
	END.
			
    FgExeMth = SESSION:SET-WAIT-STATE("GENERAL").

    /*--> Lancement de WORD */
    RUN Word(TRUE).	/* NP 0613/0231 forcer l'ouverture de Word pour pb Word 2010 */

    FUSION:
    DO TRANS:

/*--FUSION-----------------------------------------------------------------------------------------------------------------*/
        IF TpActUse = "FUSION" THEN
        DO:
            /*--> Recherche du modele */
            IF SEARCH(LbCheDot) = ? THEN
            DO:
                NoErrUse = 104702.
                LEAVE FUSION.
            END.

             /* PL 09/07/2014 */
            lPDF = FALSE.
            FIND FIRST iparm WHERE iparm.tppar = "TFORM" NO-LOCK NO-ERROR.
            IF AVAILABLE iparm THEN lPDF = TRUE.
            
            /*--> Lancement de WORD */
            /*RUN Word(FALSE).*/	/* NP 1013/0076 */
/*            RUN Word(TRUE).*/ /* PL 09/07/2014 */
            RUN Word(lPDF).
            IF NoErrUse <> 0 THEN LEAVE FUSION.
            
            /*--> Codé le fichier : données.doc en UNICODE */
            IF V_win-version = "XP" THEN
            DO:
                LbTmpPdt = OS-GETENV("Tmp") + "\".
                RUN Unicode(INPUT RpWrdEve, INPUT "", INPUT LbTmpPdt, INPUT "donnees.doc").
                /** OS-COMMAND SILENT VALUE(RpWrdEve + "macro\unicode.vbs " + LbTmpPdt + "donnees.doc"). 1206/0094 **/
            END.
            
            /*--> Rendre visible word */
            HwComWrd:VISIBLE = TRUE NO-ERROR.
            HwComWrd:WINDOWSTATE = 1 NO-ERROR.
            HwComWrd:ACTIVATE() NO-ERROR.
            
            /*--> Ouverture du modele */
            HwComDot = HwComWrd:DOCUMENTS:OPEN(LbCheDot) NO-ERROR.
            IF HwComDot = ? THEN
            DO:
                HwComDot = HwComWrd:ACTIVEDOCUMENT.
                CpUseInc = 0.
                DO WHILE HwComDot = ? AND CpUseInc < 60:
                    HwComDot = HwComWrd:ACTIVEDOCUMENT.
                    CpUseInc = CpUseInc + 1.
                    PAUSE 0.5.
                END.            
            END.
            IF HwComDot = ? THEN
            DO:
                NoErrUse = 104704.
                LEAVE FUSION.
            END.                
            
            /*--> On supprime le projet outilGI s'il existe */
            DO i = 1 TO HwComDot:VBPROJECT:VBCOMPONENTS:COUNT:
                IF HwComDot:VBPROJECT:VBCOMPONENTS:ITEM(i):NAME BEGINS("OutilsGI") OR HwComDot:VBPROJECT:VBCOMPONENTS:ITEM(i):NAME BEGINS("FrmTest") THEN
                DO:
                    HwComDot:VBPROJECT:VBCOMPONENTS:REMOVE(HwComDot:VBPROJECT:VBCOMPONENTS:ITEM(i)).
                    i = 1.
                END.
            END.
    
            /*--> Insertion des macros gi */
            HwComDot:VBPROJECT:VBCOMPONENTS:IMPORT(RpWrdEve + "macro\outils.bas").
        
            /*--> Execution du rattachement */
            HwComWrd:RUN("attacherfusion").

            /*--> Fusion */
            HwComDot:CHECK() NO-ERROR.
            HwComDot:MAILMERGE:DESTINATION = 0 NO-ERROR.
            HwComDot:MAILMERGE:EXECUTE() NO-ERROR.
        
            /*--> Raffraichir document */
            HwComDoc = HwComWrd:ACTIVEDOCUMENT NO-ERROR.
            HwComWrd:SELECTION:WHOLESTORY() NO-ERROR.
            HwComWrd:SELECTION:FIELDS:UPDATE() NO-ERROR.
            
            /*--> Sauvegarde document */
            IF NOT(lPDF) THEN
                HwComDoc:SAVEAS(LbCheDoc) NO-ERROR.
            ELSE DO:
                HwComDoc:SAVEAS(LbCheDoc) NO-ERROR. 
/* NP 1013/0076 add */
            	/*--> Fermeture modele */
            	HwComDot:CLOSE(0) NO-ERROR.

    			/* Pour obtenir le PID du process */
    			RUN GetCurrentProcessId(OUTPUT PID).

				/*--> Mise en attente de word tant que la fenêtre est active **/
				Ma_List = "0".
				REPEAT :
				    IF Ma_List = "" THEN LEAVE.
				    RUN ListProcesses("WINWORD", "11473-001.doc").	/* NP pb titre : il reste à le récupérer  !!!! */
				END.

                /*--> Réouverture pour sauvegarde en PDF */
                RUN Word(TRUE).
                HwComDoc = HwComWrd:DOCUMENTS:OPEN(LbCheDoc) NO-ERROR.
/* NP 1013/0076 add fin */
                HwComDoc:SAVEAS(REPLACE(LbCheDoc,".doc",".pdf"),17) NO-ERROR.
                IF ERROR-STATUS:ERROR THEN DO:
                    NoErrUse = 110881.
                    LEAVE FUSION.
                END.

            END.            

            /*--> Fermeture modele & document */
            HwComDot:CLOSE(0) NO-ERROR.
            HwComDoc:CLOSE(0) NO-ERROR.
            
            /*--> Quitter word */
            HwComWrd:QUIT(0) NO-ERROR.
            
            /*--> Gestion d'erreur */
            IF ERROR-STATUS:ERROR THEN
            DO:
                NoErrUse = 104704.
                LEAVE FUSION.
            END.
        END.

/*--OUVRIR-----------------------------------------------------------------------------------------------------------------*/
        IF TpActUse = "OUVRIR" THEN
        DO:
        	
            FIND FIRST iparm WHERE tppar = "TFORM" NO-LOCK NO-ERROR.
            IF NOT AVAILABLE iparm OR (AVAILABLE iparm AND SEARCH(REPLACE(LbCheDoc,".doc",".pdf")) = ?) THEN DO:        	
        	
	            IF SEARCH(LbCheDoc) = ? THEN
	            DO:
	                NoErrUse = 104701.
	                LEAVE FUSION.
	            END.
	            
	            /*--> Lancement de WORD */
	            RUN Word(TRUE).
	            IF NoErrUse <> 0 THEN LEAVE FUSION.
	            
	            /*--> Rendre visible word */
	            HwComWrd:VISIBLE = TRUE NO-ERROR.
	            HwComWrd:WINDOWSTATE = 1 NO-ERROR.
	            HwComWrd:ACTIVATE() NO-ERROR.
	            
	            HwComDoc = HwComWrd:DOCUMENTS:OPEN(LbCheDoc) NO-ERROR.
	            IF HwComWrd:ACTIVEWINDOW:VIEW:SHOWFIELDCODES THEN
	                HwComWrd:ACTIVEWINDOW:VIEW:SHOWFIELDCODES = FALSE.
	        	            
                /* Mise en attente de l'ouverture complète du fichier car sinon
                   erreur sur protectiontype */
	            DO WHILE iProtect = ? AND iCompteurSecours < 1000 :
    	            ASSIGN iProtect = HwComDoc:PROTECTIONTYPE NO-ERROR.
    	            iCompteurSecours = iCompteurSecours + 1. /* Pour eviter la boucle folle */
                END.
                
	            IF FgLokUse AND HwComDoc:PROTECTIONTYPE <> 1 THEN
	            DO:
	                HwComDoc:PROTECT(1).
	                HwComDoc:SAVE().
	            END.
	        	            
	            /*--> Ajout de la barre outils GI */
	            RUN OutilGI.
	        	                        
	            IF ERROR-STATUS:ERROR THEN
	            DO:
	                NoErrUse = 104704.
	                LEAVE FUSION.
	            END.
	            
	            /* ajout Sy le 09/07/2009 : ajout statut en travers du document */
	            IF Param1 BEGINS "STATUT:" THEN DO:
	            	/*--> Execution insertion texte WordArt */
	            	HwComWrd:RUN("Statut" , ENTRY( 2 , Param1 , ":") ).
	            	HwComDoc:SAVE().
	            END.
            END.
	        ELSE DO:

		            IF SEARCH(REPLACE(LbCheDoc,".doc",".pdf")) = ? THEN
		            DO:
		                NoErrUse = 104701.
		                LEAVE FUSION.
		            END.
		            
		            /*--> Lancement de ADOBE READER */
                    RUN ShellExecuteA(0, "open", REPLACE(LbCheDoc,".doc",".pdf"), "", "", 0, OUTPUT hInstance).
                    
                    IF hInstance = 31 THEN DO:
                        LbTmpPdt = "L'extension pdf n'est associée à aucune application. Visualisation impossible".
                        RUN GestMess IN HdLibPrc(0,"",0,LbTmpPdt,"","INFORMATION",OUTPUT FgExeMth).
                    END.  
                    ELSE IF hInstance >= 0 AND hInstance <= 32 THEN DO:
                        LbTmpPdt = " Erreur no " + STRING(hInstance) + " à l'ouverture du fichier " + REPLACE(LbCheDoc,".doc",".pdf") .
                        RUN GestMess IN HdLibPrc(0,"Erreur ouverture fichier",0,LbTmpPdt,"","ERROR",OUTPUT FgExeMth).
                    END.	          	
	          	
	        END. 	
	          
        END.

/*--IMPRESSION BROUILLON---------------------------------------------------------------------------------------------------*/
        IF TpActUse = "IMPBO" THEN
        DO:
            /*--> Recherche du modele */
            IF SEARCH(LbCheDot) = ? THEN
            DO:
                NoErrUse = 104702.
                LEAVE FUSION.
            END.

            /*--> Lancement de WORD */
            RUN Word(TRUE).
            IF NoErrUse <> 0 THEN LEAVE FUSION.
            
            /*--> Rendre visible word */
            HwComWrd:VISIBLE = TRUE NO-ERROR.
            HwComWrd:WINDOWSTATE = 1 NO-ERROR.
            HwComWrd:ACTIVATE() NO-ERROR.

            /*--> Ouverture du modèle */
            HwComDot = HwComWrd:DOCUMENTS:OPEN(LbCheDot) NO-ERROR.
            IF HwComDot = ? THEN
            DO:
                HwComDot = HwComWrd:ACTIVEDOCUMENT.
                CpUseInc = 0.
                DO WHILE HwComDot = ? AND CpUseInc < 60:
                    HwComDot = HwComWrd:ACTIVEDOCUMENT.
                    CpUseInc = CpUseInc + 1.
                    PAUSE 0.5.
                END.
            END.
            IF HwComDot = ? THEN
            DO:
                NoErrUse = 104704.
                LEAVE FUSION.
            END.                
            
            HwComDia = HwComWrd:DIALOGS:ITEM(88).
            HwComDia:SHOW.
            
            HwComDot:CLOSE(0) NO-ERROR.
            
            IF ERROR-STATUS:ERROR THEN
            DO:
                NoErrUse = 104704.
                LEAVE FUSION.
            END.
        END.

/*--IMPRESSION DEFINITIVE AVEC SELECTION IMPRIMANTE------------------------------------------------------------------------*/
        IF TpActUse = "IMPD1" THEN
        DO:
            IF SEARCH(LbCheDoc) = ? THEN
            DO:
                NoErrUse = 104701.
                LEAVE FUSION.
            END.

            /*--> Lancement de WORD */
            RUN Word(TRUE).
            IF NoErrUse <> 0 THEN LEAVE FUSION.
            
            /*--> Rendre visible word */
            HwComWrd:VISIBLE = TRUE NO-ERROR.
            HwComWrd:WINDOWSTATE = 1 NO-ERROR.
            HwComWrd:ACTIVATE() NO-ERROR.

            HwComDoc = HwComWrd:DOCUMENTS:OPEN(LbCheDoc) NO-ERROR.
            
            HwComDia = HwComWrd:DIALOGS:ITEM(88).
            HwComDia:SHOW.
            
            HwComDoc:CLOSE(0) NO-ERROR.
            
            IF ERROR-STATUS:ERROR THEN
            DO:
                NoErrUse = 104704.
                LEAVE FUSION.
            END.
        END.
    
/*--IMPRESSION DEFINITIVE SANS SELECTION IMPRIMANTE------------------------------------------------------------------------*/
        IF TpActUse = "IMPD2" THEN
        DO:
            IF SEARCH(LbCheDoc) = ? THEN
            DO:
                NoErrUse = 104701.
                LEAVE FUSION.
            END.

            /*--> Lancement de WORD */
            RUN Word(TRUE).
            IF NoErrUse <> 0 THEN LEAVE FUSION.
            
            /*--> Rendre visible word */
            HwComWrd:VISIBLE = TRUE NO-ERROR.
            HwComWrd:WINDOWSTATE = 1 NO-ERROR.
            HwComWrd:ACTIVATE() NO-ERROR.

            HwComDoc = HwComWrd:DOCUMENTS:OPEN(LbCheDoc) NO-ERROR.
            HwComDoc:PRINTOUT().
            HwComDoc:CLOSE(0) NO-ERROR.
            
            IF ERROR-STATUS:ERROR THEN
            DO:
                NoErrUse = 104704.
                LEAVE FUSION.
            END.
        END.
        
		/* Ajout Sy le 09/07/2009 */
        IF TpActUse = "IMPDUPLI" THEN
        DO:
            IF SEARCH(LbCheDoc) = ? THEN
            DO:
                NoErrUse = 104701.
                LEAVE FUSION.
            END.

			/* Copier le document pour ne pas y toucher */
			LbCheDoc-ini = LbCheDoc.
			LbCheDoc = REPLACE( LbCheDoc , ".doc" , "-dup.doc" ).
			
            OS-COPY VALUE(LbCheDoc-ini) VALUE(LbCheDoc).
	        IF OS-ERROR <> 0 THEN 
            DO:
				RUN GestMess IN HdLibPrc(1,"",103736,"",LbCheDoc,"ERROR",OUTPUT FgExeMth).
	            RETURN.
			END.
            /* NP pas de gestion du no-error
            IF ERROR-STATUS:ERROR THEN DO:
                RUN GestMess IN HdLibPrc(1,"",103736,"",LbCheDoc,"ERROR",OUTPUT FgExeMth).                
                RETURN.
            END.*/
            						
            /*--> Lancement de WORD */
            RUN Word(TRUE).
            IF NoErrUse <> 0 THEN LEAVE FUSION.
            
            /*--> Rendre visible word */
            HwComWrd:VISIBLE = TRUE NO-ERROR.
            HwComWrd:WINDOWSTATE = 1 NO-ERROR.
            HwComWrd:ACTIVATE() NO-ERROR.

            HwComDoc = HwComWrd:DOCUMENTS:OPEN(LbCheDoc) NO-ERROR.

            HwComDoc = HwComWrd:DOCUMENTS:OPEN(LbCheDoc) NO-ERROR.
            IF HwComWrd:ACTIVEWINDOW:VIEW:SHOWFIELDCODES THEN
                HwComWrd:ACTIVEWINDOW:VIEW:SHOWFIELDCODES = FALSE.
    
		    /*--> On supprime le projet statut s'il existe */
		    DO CpUseInc = 1 TO HwComDoc:VBPROJECT:VBCOMPONENTS:COUNT:
		        IF HwComDoc:VBPROJECT:VBCOMPONENTS:ITEM(CpUseInc):NAME = "Statut" THEN
		        DO:
		            HwComDoc:VBPROJECT:VBCOMPONENTS:REMOVE(HwComDoc:VBPROJECT:VBCOMPONENTS:ITEM(CpUseInc)).
		        END.
		    END.
		                        
		    /*--> Insertion des macros statut */
		    HwComDoc:VBPROJECT:VBCOMPONENTS:IMPORT(RpWrdEve + "macro\Statut.bas").

            /*--> Execution insertion texte WordArt */
            HwComWrd:RUN("Duplicata").

			IF Param1 BEGINS "TEXTE:" THEN DO:
			    /*--> Deproteger le document */
			    IF HwComDoc:PROTECTIONTYPE = 2 THEN
			        HwComDoc:UNPROTECT.
            	/*--> Execution insertion texte  */
            	HwComWrd:RUN("AjouteTextBox" , ENTRY( 2 , Param1 , ":") ).            	
			END.	
			
			HwComDoc:PROTECT(1).	
			HwComDoc:SAVE().	            	     

			/* choix de l'imprimante */                                        
            HwComDia = HwComWrd:DIALOGS:ITEM(88).
            HwComDia:SHOW.
            
            HwComDoc:CLOSE(0) NO-ERROR.
            
            IF ERROR-STATUS:ERROR THEN
            DO:
                NoErrUse = 104704.
                LEAVE FUSION.
            END.
            
            /*--> Quitter word */
            /**HwComWrd:QUIT(0) NO-ERROR.**/	/** modif sy le 18/09/2009 : surtout pas sinon rien ne s'imprime !!! */
        END.		        
    END.

    CdRetUse = "0".
    IF NoErrUse <> 0 THEN
    DO:
        RUN GestMess IN HdLibPrc(0,"Document " + LbCheDoc ,NoErrUse,"","","ERROR",OUTPUT FgExeMth).
        CdRetUse = "1".
    END.

    RELEASE OBJECT HwComImg NO-ERROR.
    RELEASE OBJECT HwComBar NO-ERROR.    
    RELEASE OBJECT HwComDot NO-ERROR.
    RELEASE OBJECT HwComDoc NO-ERROR.
    RELEASE OBJECT HwComWrd NO-ERROR.
    RELEASE OBJECT HwComDia NO-ERROR.

    FgExeMth = SESSION:SET-WAIT-STATE("").

/*=========================================================================================================================*/
/*==P R O C E D U R E======================================================================================================*/
/*=========================================================================================================================*/

/*==W O R D================================================================================================================*/
    /*--> Lancement de Word */
    
PROCEDURE Word:
    DEF INPUT PARAMETER FgExeWrd    AS LOGICAL  NO-UNDO.
    
    IF FgExeWrd THEN
        CREATE "word.Application" HwComWrd CONNECT NO-ERROR.
        
    IF ERROR-STATUS:ERROR OR NOT FgExeWrd THEN
    DO:
        CREATE "word.Application" HwComWrd NO-ERROR.
        IF ERROR-STATUS:ERROR THEN
            NoErrUse = 104703.
    END.
END.

/*==O U T I L G I==========================================================================================================*/

PROCEDURE OutilGI:
    /*--> Deproteger le document */
    IF HwComDoc:PROTECTIONTYPE = 2 THEN
        HwComDoc:UNPROTECT.
    
    /*--> On supprime le projet outilGI s'il existe */
    DO i = 1 TO HwComDoc:VBPROJECT:VBCOMPONENTS:COUNT:
        IF HwComDoc:VBPROJECT:VBCOMPONENTS:ITEM(i):NAME BEGINS("OutilsGI") OR HwComDoc:VBPROJECT:VBCOMPONENTS:ITEM(i):NAME BEGINS("FrmTest") THEN
        DO:
            HwComDoc:VBPROJECT:VBCOMPONENTS:REMOVE(HwComDoc:VBPROJECT:VBCOMPONENTS:ITEM(i)).
            i = 1.
        END.
    END.
    
    /*--> Insertion des macros gi */
    HwComDoc:VBPROJECT:VBCOMPONENTS:IMPORT(RpWrdEve + "macro\outils.bas").
    
    /*--> Suppression de la barre d'outils gi */
    HwComBar = HwComDoc:COMMANDBARS("Outils GI") NO-ERROR.
    DO WHILE VALID-HANDLE(HwComBar):
        HwComBar:DELETE NO-ERROR.
        HwComBar = HwComDoc:COMMANDBARS("Outils GI") NO-ERROR.
    END.
    
    /*--> Si presence de champs de type formulaire insertion de la barre "Outils GI" */
    IF HwComDoc:FORMFIELDS:COUNT > 0 THEN
    DO:
        /*--> Insertion de la barre d'outils gi */
        HwComBar = HwComDoc:COMMANDBARS:ADD("Outils GI",4,0,1).
        
        /*--> Insertion du logo */
        ASSIGN
        HwComImg            = HwComBar:CONTROLS:ADD(1,1)
        HwComImg:STYLE      = 3
        HwComImg:ONACTION   = "OutilsGI.Protect"
        HwComImg:CAPTION    = "Oter la Protection"
        HwComImg:FACEID     = 277.
        
        /*--> Affichage de la barre */
        ASSIGN
        HwComBar:HEIGHT     = 200
        HwComBar:LEFT       = 30
        HwComBar:TOP        = 150
        HwComBar:VISIBLE    = TRUE.    

        /*--> Protéger le document */
        HwComDoc:PROTECT(2,TRUE).
    END.
END.

/*==SHELLEXECUTEA======================================================================================================*/
    /*--> Procedure Windows */
    
PROCEDURE ShellExecuteA EXTERNAL "shell32.dll" :
  DEFINE INPUT  PARAMETER hwnd         AS LONG.  /* Handle to parent window */
  DEFINE INPUT  PARAMETER lpOperation  AS CHAR.  /* Operation to perform: open, print */
  DEFINE INPUT  PARAMETER lpFile       AS CHAR.  /* Document or executable name */
  DEFINE INPUT  PARAMETER lpParameters AS CHAR.  /* Command line parameters to executable in lpFile */
  DEFINE INPUT  PARAMETER lpDirectory  AS CHAR.  /* Default directory */
  DEFINE INPUT  PARAMETER nShowCmd     AS LONG.  /* Whether shown when opened:
                                                    0 hidden, 1 normal, minimized 2, maximized 3, 
                                                    0 if lpFile is a document */
  DEFINE RETURN PARAMETER hInstance    AS LONG.  /* Less than or equal to 32 */
  
END.
 
