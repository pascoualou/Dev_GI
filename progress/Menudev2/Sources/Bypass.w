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


/* Parameters Definitions ---                                           */

DEFINE INPUT PARAMETER  winGeneral  AS HANDLE NO-UNDO.
DEFINE INPUT PARAMETER  cParametres AS CHARACTER NO-UNDO.
/* Local Variable Definitions ---                                       */

DEFINE BUFFER bprefs FOR prefs.

DEFINE TEMP-TABLE ttBypass
    FIELD cModule       AS CHARACTER
    FIELD clibelle      AS CHARACTER
    FIELD cfichier      AS CHARACTER
    FIELD cRepertoire   AS CHARACTER
    FIELD lActif        AS LOGICAL
    
    INDEX ttbypass01 IS PRIMARY cModule clibelle
    .

DEFINE VARIABLE cRepertoireTempo AS CHARACTER NO-UNDO.
DEFINE VARIABLE cTempo AS CHARACTER NO-UNDO.


DEFINE MENU Menu001
        MENU-ITEM Menu001-Bascule     LABEL "Activer/Désactiver"
        RULE
        MENU-ITEM Menu001-Ouvrir  LABEL "Ouvrir le fichier"
        .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME frmModule
&Scoped-define BROWSE-NAME brwBypass

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ttByPass

/* Definitions for BROWSE brwBypass                                     */
&Scoped-define FIELDS-IN-QUERY-brwBypass ttbypass.cmodule ttbypass.clibelle ttbypass.lactif ttbypass.cFichier ttbypass.cRepertoire   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brwBypass   
&Scoped-define SELF-NAME brwBypass
&Scoped-define QUERY-STRING-brwBypass FOR EACH ttByPass
&Scoped-define OPEN-QUERY-brwBypass OPEN QUERY {&SELF-NAME} FOR EACH ttByPass.
&Scoped-define TABLES-IN-QUERY-brwBypass ttByPass
&Scoped-define FIRST-TABLE-IN-QUERY-brwBypass ttByPass


/* Definitions for FRAME frmModule                                      */
&Scoped-define OPEN-BROWSERS-IN-QUERY-frmModule ~
    ~{&OPEN-QUERY-brwBypass}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS filRecherche btnCodePrecedent btnCodeSuivant ~
brwBypass 
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
DEFINE QUERY brwBypass FOR 
      ttByPass SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brwBypass
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brwBypass C-Win _FREEFORM
  QUERY brwBypass DISPLAY
      ttbypass.cmodule FORMAT "x(25)" LABEL "Module"
      ttbypass.clibelle FORMAT "x(80)" LABEL "Description du bypass"
          ttbypass.lactif FORMAT "X/" LABEL "Actif"
          ttbypass.cFichier FORMAT "X(50)" LABEL "Fichier"
          ttbypass.cRepertoire FORMAT "X(50)" LABEL "Répertoire"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 164 BY 17.86
         FONT 1 ROW-HEIGHT-CHARS .81.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME frmModule
     filRecherche AT ROW 1.24 COL 88.2 WIDGET-ID 26
     btnCodePrecedent AT Y 5 X 785 WIDGET-ID 22
     btnCodeSuivant AT Y 5 X 805 WIDGET-ID 24
     brwBypass AT ROW 2.43 COL 2 WIDGET-ID 100
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 166.2 BY 20.62
         TITLE BGCOLOR 2 FGCOLOR 15 "ByPass".


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
  NOT-VISIBLE,                                                          */
/* SETTINGS FOR FRAME frmModule
   FRAME-NAME                                                           */
/* BROWSE-TAB brwBypass btnCodeSuivant frmModule */
ASSIGN 
       brwBypass:NUM-LOCKED-COLUMNS IN FRAME frmModule     = 3.

ASSIGN 
       btnCodeSuivant:AUTO-RESIZE IN FRAME frmModule      = TRUE.

/* SETTINGS FOR FILL-IN filRecherche IN FRAME frmModule
   ALIGN-L                                                              */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brwBypass
/* Query rebuild information for BROWSE brwBypass
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH ttByPass.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE brwBypass */
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


&Scoped-define BROWSE-NAME brwBypass
&Scoped-define SELF-NAME brwBypass
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwBypass C-Win
ON DEFAULT-ACTION OF brwBypass IN FRAME frmModule
DO:
    IF ttBypass.lactif THEN DO:
        OS-DELETE VALUE(ttbypass.cRepertoire + "\" + ttBypass.cFichier).
    END. 
    ELSE DO:
        OS-COMMAND SILENT VALUE("echo .. > " + ttbypass.cRepertoire + "\" + ttBypass.cFichier).
    END. 
    RUN TopChronoGeneral.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnCodePrecedent
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnCodePrecedent C-Win
ON CHOOSE OF btnCodePrecedent IN FRAME frmModule /* < */
DO:
    DEFINE VARIABLE cRecherche AS CHARACTER NO-UNDO.

    cRecherche = "*" + filRecherche:SCREEN-VALUE + "*".

    /* Recherche en arriere */
    IF AVAILABLE(ttbypass) THEN DO:
        FIND PREV   ttbypass
            WHERE   ttbypass.cModule MATCHES cRecherche
            OR      ttbypass.cLibelle MATCHES cRecherche
            NO-ERROR.
    END.
    IF NOT(AVAILABLE(ttbypass)) THEN DO:
        FIND LAST   ttbypass
            WHERE   ttbypass.cModule MATCHES cRecherche
            OR      ttbypass.cLibelle MATCHES cRecherche
            NO-ERROR.
    END.
    IF AVAILABLE(ttbypass) THEN DO:
        REPOSITION brwbypass TO RECID RECID(ttbypass).
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnCodeSuivant
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnCodeSuivant C-Win
ON CHOOSE OF btnCodeSuivant IN FRAME frmModule /* > */
DO:
    DEFINE VARIABLE cRecherche AS CHARACTER NO-UNDO.

    cRecherche = "*" + filRecherche:SCREEN-VALUE + "*".

    /* Recherche en avant */
    IF AVAILABLE(ttbypass) THEN DO:
        FIND NEXT   ttbypass
            WHERE   ttbypass.cModule MATCHES cRecherche
            OR      ttbypass.cLibelle MATCHES cRecherche
            NO-ERROR.
    END.
    IF NOT(AVAILABLE(ttbypass)) THEN DO:
        FIND FIRST   ttbypass
            WHERE   ttbypass.cModule MATCHES cRecherche
            OR      ttbypass.cLibelle MATCHES cRecherche
            NO-ERROR.
    END.
    IF AVAILABLE(ttbypass) THEN DO:
        REPOSITION brwbypass TO RECID RECID(ttbypass).
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filRecherche
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filRecherche C-Win
ON RETURN OF filRecherche IN FRAME frmModule /* Recherche */
DO:
  APPLY "CHOOSE" TO BtnCodeSuivant.
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
ON CHOOSE OF MENU-ITEM Menu001-Bascule IN MENU Menu001 DO:
    APPLY "DEFAULT-ACTION" TO brwBypass IN FRAME frmModule.
END.                
ON CHOOSE OF MENU-ITEM Menu001-Ouvrir IN MENU Menu001 DO:
    IF not(ttbypass.lactif) THEN DO:
        MESSAGE "Il faut activer le bypass pour pouvoir ouvrir le fichier."
            VIEW-AS ALERT-BOX INFORMATION
            TITLE "Controle bypass..."
            .
        RETURN NO-APPLY.
    END.
    /*cTempo = gcRepertoireRessourcesPrivees + "\scripts\general\execute3.bat " + gcRepertoireRessourcesPrivees + "\scripts\general\modifbypass.bat " + ttbypass.cRepertoire + "\" + ttBypass.cFichier.*/
    cTempo = gcRepertoireRessourcesPrivees + "\scripts\general\execute2.bat notepad.exe " + ttbypass.cRepertoire + "\" + ttBypass.cFichier.
    RUN ExecuteCommandeDos(cTempo).
    /*OS-COMMAND SILENT VALUE(gcRepertoireRessourcesPrivees + "\scripts\general\execute2.bat notepad.exe """ + ttbypass.cRepertoire + "\" + ttBypass.cFichier + """").*/
    /*OS-COMMAND SILENT VALUE("notepad " + ttbypass.cRepertoire + "\" + ttBypass.cFichier).*/
END.                

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
  ENABLE filRecherche btnCodePrecedent btnCodeSuivant brwBypass 
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
                IF gTopRechargeModule("bypass.txt") THEN RUN Recharger.
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
                MESSAGE "Recharge" VIEW-AS ALERT-BOX.
                RUN Recharger.
            END.
            WHEN "MODIFIER" THEN DO:
                RUN Modification(OUTPUT lRetour-ou).
            END.
            WHEN "RECHERCHE" THEN DO:
                APPLY "entry" TO filRecherche IN FRAME frmModule.
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
    gcAideModifier = "#" + (IF gModificationAutorisee("bypass.txt") THEN "DIRECT" ELSE "INTERDIT") + "#Modifier la liste des ByPass".
    gcAideSupprimer = "#INTERDIT#".
    gcAideImprimer = "#INTERDIT#".
    gcAideRaf = "Recharger la liste des bypass".

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
    DEFINE VARIABLE cLigne AS CHARACTER NO-UNDO.
    
    FRAME frmModule:COLUMN = gdPositionXModule.
    FRAME frmModule:ROW = gdPositionYModule.

    

    /* Chargement des images */
    
    /* Ouverture du fichier */
    RUN gDechargeFichierEnLocal("","bypass.txt").
    INPUT FROM VALUE(gcFichierLocal).

    /* Chargement de la table des bypass */
    EMPTY TEMP-TABLE ttbypass.
    REPEAT:
        IMPORT UNFORMATTED cLigne.
        IF cLigne = ""  THEN NEXT.
        CREATE ttbypass.
        ttbypass.cModule = ENTRY(1,cLigne,"|").
        ttbypass.cLibelle = ENTRY(2,cLigne,"|").
        ttbypass.cFichier = ENTRY(3,cLigne,"|").
        ttbypass.cRepertoire = (IF num-entries(cLigne,"|") >= 4 THEN RemplaceVariables(ENTRY(4,cLigne,"|")) ELSE OS-GETENV("disque") + "gidev\bypass").
        /* création des répertoire si besoin */
        RUN TraiteRepertoire(ttbypass.cRepertoire).
    END.

    /* Fermeture du fichier */
    INPUT CLOSE.

    /* ouverture du query */
    {&OPEN-QUERY-brwBypass}

    RUN TopChronoGeneral.
    RUN TopChronoPartiel.
    
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
    gAddParam("FICHIERS-INFOSFICHIER","bypass.txt" + ",PARAM").
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
  brwBypass:popup-MENU  = MENU menu001:HANDLE.
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE TopChronoGeneral C-Win 
PROCEDURE TopChronoGeneral :
/* Gestion du chrono général */
DEFINE VARIABLE cFichierBP AS CHARACTER NO-UNDO.

    /* recherche des fichiers bypass */
    FOR EACH ttByPass:
        cFichierBP = ttBypass.cRepertoire + "\" + ttBypass.cFichier.
        ttbypass.lActif = SEARCH(cFichierBP) <> ?.
    END.

    /* raffraichissement du browse */
    brwByPass:REFRESH() IN FRAME frmModule.
   

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE TopChronoPartiel C-Win 
PROCEDURE TopChronoPartiel :
/* Gestion du chrono Partiel */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE TraiteRepertoire C-Win 
PROCEDURE TraiteRepertoire :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER cRepertoire-in AS CHARACTER NO-UNDO.

    IF SEARCH(cRepertoire-in + "\_Ne_pas_supprimer") = ? THEN DO:
        OS-COMMAND SILENT value(gcRepertoireRessourcesPrivees + "\scripts\general\crerep.bat " + cRepertoire-in).
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

