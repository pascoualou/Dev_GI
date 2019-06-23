&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS C-Win 
/*------------------------------------------------------------------------

  File: 

  Description: 

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author: 

  Created: 

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.      */
/*----------------------------------------------------------------------*/

/* Create an unnamed pool to store all the widgets created 
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures 
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

{includes\i_environnement.i}
{includes\i_dialogue.i}
{menudev2\includes\menudev2.i}
{includes\i_html.i}

/* Parameters Definitions ---                                           */

DEFINE INPUT PARAMETER  winGeneral  AS HANDLE NO-UNDO.
DEFINE INPUT PARAMETER  cParametres AS CHARACTER NO-UNDO.
/* Local Variable Definitions ---                                       */

DEFINE BUFFER bprefs FOR prefs.

DEFINE TEMP-TABLE ttPasses
    FIELD cModule       AS CHARACTER
    FIELD clibelle      AS CHARACTER
    FIELD cpasse        AS CHARACTER
    
    INDEX ttPasses01 IS PRIMARY cModule clibelle
    .

DEFINE VARIABLE cRepertoireTempo AS CHARACTER NO-UNDO.


DEFINE VARIABLE lSensCode          AS LOGICAL      NO-UNDO INIT TRUE.
DEFINE VARIABLE lSensLibelle          AS LOGICAL      NO-UNDO INIT ?.
DEFINE VARIABLE cModuleEncours    AS CHARACTER    NO-UNDO INIT "".

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME frmModule
&Scoped-define BROWSE-NAME brwPasses

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ttPasses

/* Definitions for BROWSE brwPasses                                     */
&Scoped-define FIELDS-IN-QUERY-brwPasses ttPasses.cmodule ttPasses.clibelle ttPasses.cPasse   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brwPasses ttPasses.cmodule   
&Scoped-define ENABLED-TABLES-IN-QUERY-brwPasses ttPasses
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-brwPasses ttPasses
&Scoped-define SELF-NAME brwPasses
&Scoped-define QUERY-STRING-brwPasses FOR EACH ttPasses
&Scoped-define OPEN-QUERY-brwPasses OPEN QUERY {&SELF-NAME} FOR EACH ttPasses.
&Scoped-define TABLES-IN-QUERY-brwPasses ttPasses
&Scoped-define FIRST-TABLE-IN-QUERY-brwPasses ttPasses


/* Definitions for FRAME frmModule                                      */
&Scoped-define OPEN-BROWSERS-IN-QUERY-frmModule ~
    ~{&OPEN-QUERY-brwPasses}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS filRecherche btnCodePrecedent btnCodeSuivant ~
brwPasses 
&Scoped-Define DISPLAYED-OBJECTS filRecherche 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON btnCodePrecedent 
     LABEL "<" 
     SIZE-PIXELS 20 BY 20 TOOLTIP "Rechercher le précédent".

DEFINE BUTTON btnCodeSuivant  NO-CONVERT-3D-COLORS
     LABEL ">" 
     SIZE-PIXELS 20 BY 20 TOOLTIP "Rechercher le suivant".

DEFINE VARIABLE filRecherche AS CHARACTER FORMAT "X(256)":U 
     LABEL "Recherche" 
     VIEW-AS FILL-IN 
     SIZE 58 BY .95 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brwPasses FOR 
      ttPasses SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brwPasses
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brwPasses C-Win _FREEFORM
  QUERY brwPasses DISPLAY
      ttPasses.cmodule FORMAT "x(30)" LABEL "Module"
      ttPasses.clibelle FORMAT "x(80)" LABEL "Description du Mot de passe"
          ttPasses.cPasse FORMAT "X(200)" LABEL "Mot(s) de passe"
          ENABLE ttPasses.cmodule
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 164 BY 17.86
         FONT 1 ROW-HEIGHT-CHARS .76 TOOLTIP "Double-clique pour modifier le fichier des mots de passe".


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME frmModule
     filRecherche AT ROW 1.24 COL 86.2 WIDGET-ID 26
     btnCodePrecedent AT Y 5 X 780 WIDGET-ID 2
     btnCodeSuivant AT Y 5 X 801 WIDGET-ID 4
     brwPasses AT ROW 2.43 COL 2 WIDGET-ID 100
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 166.2 BY 20.62
         TITLE BGCOLOR 2 FGCOLOR 15 "Mots de passe".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
   Allow: Basic,Browse,DB-Fields,Window,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW C-Win ASSIGN
         HIDDEN             = YES
         TITLE              = "<insert window title>"
         HEIGHT             = 20.62
         WIDTH              = 166
         MAX-HEIGHT         = 33.95
         MAX-WIDTH          = 166.2
         VIRTUAL-HEIGHT     = 33.95
         VIRTUAL-WIDTH      = 166.2
         SHOW-IN-TASKBAR    = no
         CONTROL-BOX        = no
         MIN-BUTTON         = no
         MAX-BUTTON         = no
         RESIZE             = no
         SCROLL-BARS        = no
         STATUS-AREA        = no
         BGCOLOR            = ?
         FGCOLOR            = ?
         KEEP-FRAME-Z-ORDER = yes
         THREE-D            = yes
         MESSAGE-AREA       = no
         SENSITIVE          = yes.
ELSE {&WINDOW-NAME} = CURRENT-WINDOW.
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW C-Win
  NOT-VISIBLE,,RUN-PERSISTENT                                           */
/* SETTINGS FOR FRAME frmModule
   FRAME-NAME                                                           */
/* BROWSE-TAB brwPasses btnCodeSuivant frmModule */
ASSIGN 
       brwPasses:NUM-LOCKED-COLUMNS IN FRAME frmModule     = 1
       brwPasses:COLUMN-RESIZABLE IN FRAME frmModule       = TRUE.

ASSIGN 
       btnCodeSuivant:AUTO-RESIZE IN FRAME frmModule      = TRUE.

/* SETTINGS FOR FILL-IN filRecherche IN FRAME frmModule
   ALIGN-L                                                              */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brwPasses
/* Query rebuild information for BROWSE brwPasses
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH ttPasses.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE brwPasses */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON END-ERROR OF C-Win /* <insert window title> */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON WINDOW-CLOSE OF C-Win /* <insert window title> */
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brwPasses
&Scoped-define SELF-NAME brwPasses
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwPasses C-Win
ON START-SEARCH OF brwPasses IN FRAME frmModule
DO:
    IF BrwPasses:CURRENT-COLUMN:NAME = "cModule" THEN do:
        lSensCode = NOT(lSensCode).
        IF lSensCode = ? THEN lSensCode = TRUE.
        lSensLibelle = ?.
    END.
    IF BrwPasses:CURRENT-COLUMN:NAME = "cLibelle" THEN do:
        lSensLibelle = NOT(lSensLibelle).
        IF lSensLibelle = ? THEN lSensLibelle = TRUE.
        lSensCode = ?.
    END.
    RUN OuvreQueryPasses.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwPasses C-Win
ON VALUE-CHANGED OF brwPasses IN FRAME frmModule
DO:
      cModuleEncours = (IF available(ttPasses) THEN ttPasses.cModule ELSE "").

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnCodePrecedent
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnCodePrecedent C-Win
ON CHOOSE OF btnCodePrecedent IN FRAME frmModule /* < */
DO:
  
    RUN Saisie ("PREV").

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnCodeSuivant
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnCodeSuivant C-Win
ON CHOOSE OF btnCodeSuivant IN FRAME frmModule /* > */
DO:
    
    RUN Saisie ("NEXT").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filRecherche
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filRecherche C-Win
ON RETURN OF filRecherche IN FRAME frmModule /* Recherche */
DO:
    APPLY  LAST-KEY TO SELF.
    RUN Saisie ("").
    RETURN NO-APPLY.
        
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK C-Win 


/* ***************************  Main Block  *************************** */

/* Set CURRENT-WINDOW: this will parent dialog-boxes and frames.        */
ASSIGN CURRENT-WINDOW                = {&WINDOW-NAME} 
       THIS-PROCEDURE:CURRENT-WINDOW = {&WINDOW-NAME}.

/* The CLOSE event can be used from inside or outside the procedure to  */
/* terminate it.                                                        */
ON CLOSE OF THIS-PROCEDURE 
   RUN disable_UI.

/* Best default for GUI applications is...                              */
PAUSE 0 BEFORE-HIDE.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN MYenable_UI.
  IF NOT THIS-PROCEDURE:PERSISTENT THEN
    WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI C-Win  _DEFAULT-DISABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide 
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Delete the WINDOW we created */
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
  THEN DELETE WIDGET C-Win.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE DonneOrdre C-Win 
PROCEDURE DonneOrdre :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER  cOrdre-in   AS CHARACTER    NO-UNDO.


    /* Handle valide ? */
    IF VALID-HANDLE(ghGeneral) THEN DO:
        /* appel du module */
        RUN ExecuteOrdre IN ghGeneral (cOrdre-in).
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI C-Win  _DEFAULT-ENABLE
PROCEDURE enable_UI :
/*------------------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other 
               Settings" section of the widget Property Sheets.
------------------------------------------------------------------------------*/
  DISPLAY filRecherche 
      WITH FRAME frmModule IN WINDOW C-Win.
  ENABLE filRecherche btnCodePrecedent btnCodeSuivant brwPasses 
      WITH FRAME frmModule IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-frmModule}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ExecuteOrdre C-Win 
PROCEDURE ExecuteOrdre :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER  cOrdre-in   AS CHARACTER    NO-UNDO.
DEFINE OUTPUT PARAMETER lRetour-ou AS LOGICAL NO-UNDO.

    DEFINE VARIABLE iBoucle AS INTEGER      NO-UNDO.
    DEFINE VARIABLE cOrdre  AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE cAction AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE cValeur AS CHARACTER    NO-UNDO.

    /* Décomposition de la chaine d'ordre */
    DO iBoucle = 1 TO NUM-ENTRIES(cOrdre-in):
        cOrdre = ENTRY(iBoucle,cOrdre-in).
        cAction = ENTRY(1,cOrdre,"=").
        cValeur = (IF NUM-ENTRIES(cOrdre,"=") = 2 THEN ENTRY(2,cOrdre,"=") ELSE "").
    
        /* Lancement de l'action */
        CASE cAction:
            WHEN "AFFICHE" THEN DO:
                IF gTopRechargeModule("passes.txt") THEN RUN Recharger.
                /* Affichage de la frame principale */
                VIEW FRAME frmModule.
                FRAME frmModule:MOVE-TO-TOP().
            END.
            WHEN "CACHE" THEN DO:
                HIDE FRAME frmModule.
            END.
            WHEN "TOPGENERAL" THEN DO:
                RUN TopChronoGeneral.
            END.
            WHEN "TOPPARTIEL" THEN DO:
                RUN TopChronoPartiel.
            END.
            WHEN "INIT" THEN DO:
                RUN Initialisation.
            END.
            WHEN "RECHARGE" THEN DO:
                RUN Recharger.
            END.
            WHEN "MODIFIER" THEN DO:
                RUN Modification(OUTPUT lRetour-ou).
            END.
            WHEN "RECHERCHE" THEN DO:
                APPLY "entry" TO filRecherche IN FRAME frmModule.
            END.
            WHEN "IMPRIME" THEN DO:
                RUN Impression.
            END.
        END CASE. /* fin du case */
    END. /* fin du do iboucle */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE GereBoutons C-Win 
PROCEDURE GereBoutons :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    gcAideAjouter = "#INTERDIT#".
    gcAideModifier = "#" + (IF gModificationAutorisee("passes.txt") THEN "DIRECT" ELSE "INTERDIT") + "#Modifier la liste des mots de passe".
    gcAideSupprimer = "#INTERDIT#".
    gcAideImprimer = "Imprimer la liste dez mots de passe".
    gcAideRaf = "Recharger la liste des mots de passe".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Impression C-Win 
PROCEDURE Impression :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE VARIABLE cLigne AS CHARACTER NO-UNDO.

    /* Début de l'édition */
    RUN HTML_OuvreFichier("").
    cLigne = "Liste des mots de passe MaGI".
    RUN HTML_TitreEdition(cLigne).
    
    RUN HTML_ChargeFormatCellule("E",0,"CF=gris,A=><,T=3").
    RUN HTML_ChargeFormatCellule("L",0,"A=<").
    
    /* Ecriture de l'entete pour le tableau des champs */
    cLigne = "" 
        + "Module"
        + devSeparateurEdition + "Libellé"
        + devSeparateurEdition + "MDP"
        .
    RUN HTML_DebutTableau(cLigne).
    
    /* Balayage de la table des champs */
    FOR EACH ttPasses
        :
        cLigne = "" 
            + TRIM(ttPasses.cModule)
            + devSeparateurEdition + TRIM(ttPasses.cLibelle)
            + devSeparateurEdition + TRIM(ttpasses.cpasse)
            .
        RUN HTML_LigneTableau(cLigne).
    END.
    
    /* Fin de l'édition des champs */
    RUN HTML_FinTableau.
    
    RUN HTML_FinEdition.
    RUN HTML_FermeFichier.
    RUN gImpression.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Initialisation C-Win 
PROCEDURE Initialisation :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE cProgrammeExterne AS CHARACTER NO-UNDO.  
    
    FRAME frmModule:COLUMN = gdPositionXModule.
    FRAME frmModule:ROW = gdPositionYModule.

    /* Chargement des images */
    
    /* Chargemenet des mot de passe */
    DEFINE VARIABLE cFichierBP AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cLigne AS CHARACTER NO-UNDO.

        /* Chargement du fichier des mots de passe */
        /* Ouverture du fichier */
        RUN gDechargeFichierEnLocal("","passes.txt").
        INPUT FROM VALUE(gcFichierLocal).

        /* Chargement de la table des bypass */
        EMPTY TEMP-TABLE ttPasses.
        REPEAT:
            IMPORT UNFORMATTED cLigne.
            IF cLigne = ""  THEN NEXT.
            IF cLigne BEGINS "_Nom du Module" THEN NEXT.
            CREATE ttPasses.
            ttPasses.cModule = ENTRY(1,cLigne,"|").
            ttPasses.cLibelle = ENTRY(2,cLigne,"|").
            ttPasses.cPasse = ENTRY(3,cLigne,"|").
        END.

        /* Fermeture du fichier */
        INPUT CLOSE.

        /* Chargement des mots de passe des modules optionnels */
        FOR EACH pclid NO-LOCK
            WHERE   (ENTRY(1,pclid.lslib,"|") <> ""
                OR  (NUM-ENTRIES(pclid.lslib,"|") >= 2 AND ENTRY(2,pclid.lslib,"|") <> "")
                )
           ,FIRST sys_lb NO-LOCK
            WHERE sys_lb.cdlng = 0
            AND   sys_lb.nomes = pclid.nomes     
            :
            CREATE ttPasses.
            ttPasses.cModule = "Module Optionnel : " + pclid.tppar.
            ttPasses.cLibelle = sys_lb.lbmes.
            ttPasses.cPasse = "Déblocage = " + ENTRY(1,pclid.lslib,"|") + " / Blocage = " + ENTRY(2,pclid.lslib,"|").
        END.

        cProgrammeExterne = gcRepertoireExecution + "ExtMdpFpclie.p".
        IF SEARCH(cProgrammeExterne) = ? THEN RETURN.
        RUN VALUE(cProgrammeExterne).
        gcFichierLocal = ser_log + "\fpclie.mdp".
        INPUT FROM VALUE(gcFichierLocal).

        /* Chargement des mdp issus de fpclie.i */
        REPEAT:
            IMPORT UNFORMATTED cLigne.
            IF cLigne = ""  THEN NEXT.
            CREATE ttPasses.
            ttPasses.cModule = ENTRY(1,cLigne,"§").
            ttPasses.cLibelle = ENTRY(2,cLigne,"§").
            ttPasses.cPasse = ENTRY(3,cLigne,"§").           
        END.

        /* Fermeture du fichier */
        INPUT CLOSE.


    RUN TopChronoGeneral.
    RUN TopChronoPartiel.
    
    /* Ouverture du qurey */  
    RUN OuvreQueryPasses.

    
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Modification C-Win 
PROCEDURE Modification :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE OUTPUT PARAMETER lRetour-ou AS LOGICAL NO-UNDO.

    RUN DonneOrdre("REINIT-BOUTONS-2").
    gAddParam("FICHIERS-INFOSFICHIER","passes.txt" + ",PARAM").
    RUN DonneOrdre("DONNEORDREAMODULE=FICHIERS|AFFICHE").  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MYenable_UI C-Win 
PROCEDURE MYenable_UI :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  VIEW FRAME frmModule IN WINDOW winGeneral.
    {&OPEN-BROWSERS-IN-QUERY-frmModule}
    HIDE c-win.
  ENABLE ALL WITH FRAME frmModule.
  ttPasses.cModule:READ-ONLY IN BROWSE brwPasses = TRUE.
  brwpasses:SET-REPOSITIONED-ROW(15).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OuvreQueryPasses C-Win 
PROCEDURE OuvreQueryPasses :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    IF lSensLibelle <> ? THEN DO:
        IF lSensLibelle THEN        
            OPEN QUERY BrwPasses FOR EACH ttPasses BY ttPasses.cLibelle .
        ELSE
            OPEN QUERY BrwPasses FOR EACH ttPasses BY ttPasses.cLibelle DESC.
    END.
    IF lSensCode <> ? THEN DO:
        IF lSensCode THEN        
            OPEN QUERY BrwPasses FOR EACH ttPasses BY ttPasses.cModule.
        ELSE
            OPEN QUERY BrwPasses FOR EACH ttPasses BY ttPasses.cModule DESC.
    END.

    /* Repositionnement */
    /*
    IF cModuleEncours <> "" THEN DO:
        FIND FIRST ttPasses WHERE ttPasses.cModule = cModuleEncours NO-ERROR.
        IF available(ttPasses) THEN REPOSITION BrwPasses TO ROWID ROWID(ttPasses).
    END.
    */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Recharger C-Win 
PROCEDURE Recharger :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    RUN Initialisation.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Saisie C-Win 
PROCEDURE Saisie :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER cModeRecherche AS CHARACTER NO-UNDO.

    DO WITH FRAME frmModule:
        
        IF cModeRecherche = "" THEN DO:
            FIND FIRST ttpasses
                WHERE ttpasses.cModule MATCHES "*" + filRecherche:SCREEN-VALUE + "*"
                OR    ttpasses.cLibelle MATCHES "*" + filRecherche:SCREEN-VALUE + "*"
                NO-ERROR.
        END.
        ELSE IF cModeRecherche = "NEXT" THEN DO:
            FIND NEXT ttpasses
                WHERE ttpasses.cModule MATCHES "*" + filRecherche:SCREEN-VALUE + "*"
                OR    ttpasses.cLibelle MATCHES "*" + filRecherche:SCREEN-VALUE + "*"
                NO-ERROR.
        END.
        ELSE DO:
            FIND PREV ttpasses
                WHERE ttpasses.cModule MATCHES "*" + filRecherche:SCREEN-VALUE + "*"
                OR    ttpasses.cLibelle MATCHES "*" + filRecherche:SCREEN-VALUE + "*"
                NO-ERROR.
        END.
        IF AVAILABLE(ttpasses) THEN do:
            REPOSITION brwPasses TO ROWID ROWID(ttpasses).
        END.
        ELSE DO:
            BELL.
        END.
    END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE TopChronoGeneral C-Win 
PROCEDURE TopChronoGeneral :
/* Gestion du chrono général */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE TopChronoPartiel C-Win 
PROCEDURE TopChronoPartiel :
/* Gestion du chrono Partiel */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

