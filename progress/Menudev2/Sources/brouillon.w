&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
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

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER hPere-in AS HANDLE NO-UNDO.
    
/* Local Variable Definitions ---                                       */


{includes\i_environnement.i}
{includes\i_dialogue.i}
{menudev2\includes\menudev2.i}

    &SCOPED-DEFINE  MAX_ONGLETS 5

DEFINE VARIABLE cFichierBrouillon AS CHARACTER NO-UNDO.
DEFINE VARIABLE lChargementEnCours AS LOGICAL NO-UNDO INIT FALSE.
DEFINE VARIABLE iMaxBrouillons AS INTEGER NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME DEFAULT-FRAME

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS filRecherche btnCodePrecedent btnCodeSuivant ~
TOGGLE-1 edtBrouillon 
&Scoped-Define DISPLAYED-OBJECTS filRecherche TOGGLE-1 edtBrouillon 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD DonneNomFichier C-Win 
FUNCTION DonneNomFichier RETURNS CHARACTER
  ( /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.

/* Definitions of handles for OCX Containers                            */
DEFINE VARIABLE CtrlFrame AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chCtrlFrame AS COMPONENT-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON btnCodePrecedent 
     LABEL "<" 
     SIZE-PIXELS 20 BY 20 TOOLTIP "Rechercher le précédent".

DEFINE BUTTON btnCodeSuivant  NO-CONVERT-3D-COLORS
     LABEL ">" 
     SIZE-PIXELS 20 BY 20 TOOLTIP "Rechercher le suivant".

DEFINE VARIABLE edtBrouillon AS CHARACTER 
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
     SIZE 78 BY 13.57
     FONT 11 NO-UNDO.

DEFINE VARIABLE filRecherche AS CHARACTER FORMAT "X(256)":U 
     LABEL "Recherche" 
     VIEW-AS FILL-IN 
     SIZE 58 BY .95 NO-UNDO.

DEFINE VARIABLE TOGGLE-1 AS LOGICAL INITIAL no 
     LABEL "Toujours visible" 
     VIEW-AS TOGGLE-BOX
     SIZE 20 BY .95 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME DEFAULT-FRAME
     filRecherche AT ROW 1.1 COL 2.2 WIDGET-ID 4
     btnCodePrecedent AT Y 2 X 355 WIDGET-ID 22
     btnCodeSuivant AT Y 2 X 375 WIDGET-ID 24
     TOGGLE-1 AT ROW 2.43 COL 60 WIDGET-ID 8
     edtBrouillon AT ROW 3.38 COL 2 NO-LABEL WIDGET-ID 2
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 250 BY 30 WIDGET-ID 100.


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
         TITLE              = "Brouillons"
         HEIGHT             = 16.24
         WIDTH              = 80
         MAX-HEIGHT         = 46
         MAX-WIDTH          = 336
         VIRTUAL-HEIGHT     = 46
         VIRTUAL-WIDTH      = 336
         ALWAYS-ON-TOP      = yes
         RESIZE             = yes
         SCROLL-BARS        = no
         STATUS-AREA        = no
         BGCOLOR            = ?
         FGCOLOR            = ?
         KEEP-FRAME-Z-ORDER = yes
         THREE-D            = yes
         MESSAGE-AREA       = no
         SENSITIVE          = yes.
ELSE {&WINDOW-NAME} = CURRENT-WINDOW.

&IF '{&WINDOW-SYSTEM}' NE 'TTY' &THEN
IF NOT C-Win:LOAD-ICON("Menudev2/Ressources/images/smile.ico":U) THEN
    MESSAGE "Unable to load icon: Menudev2/Ressources/images/smile.ico"
            VIEW-AS ALERT-BOX WARNING BUTTONS OK.
&ENDIF
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW C-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME DEFAULT-FRAME
   FRAME-NAME                                                           */
ASSIGN 
       btnCodeSuivant:AUTO-RESIZE IN FRAME DEFAULT-FRAME      = TRUE.

/* SETTINGS FOR FILL-IN filRecherche IN FRAME DEFAULT-FRAME
   ALIGN-L                                                              */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

CREATE CONTROL-FRAME CtrlFrame ASSIGN
       FRAME           = FRAME DEFAULT-FRAME:HANDLE
       ROW             = 2.19
       COLUMN          = 2
       HEIGHT          = .95
       WIDTH           = 40
       WIDGET-ID       = 34
       HIDDEN          = no
       SENSITIVE       = yes.
/* CtrlFrame OCXINFO:CREATE-CONTROL from: {EAE50EB0-4A62-11CE-BED6-00AA00611080} type: TabStrip */
      CtrlFrame:MOVE-AFTER(btnCodeSuivant:HANDLE IN FRAME DEFAULT-FRAME).

&ENDIF

&ANALYZE-RESUME /* End of _CREATE-DYNAMIC */


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON END-ERROR OF C-Win /* Brouillons */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON LEAVE OF C-Win /* Brouillons */
DO:
  APPLY "LEAVE" TO edtbrouillon IN FRAME DEFAULT-FRAME.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON WINDOW-CLOSE OF C-Win /* Brouillons */
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "LEAVE" TO edtbrouillon IN FRAME DEFAULT-FRAME.
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON WINDOW-RESIZED OF C-Win /* Brouillons */
DO:
    RUN AdapteTaille.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnCodePrecedent
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnCodePrecedent C-Win
ON CHOOSE OF btnCodePrecedent IN FRAME DEFAULT-FRAME /* < */
DO:
    /* Recherche en arrière avec selection et retour en fin de fichier si  debut de fichier */
    edtbrouillon:SEARCH(filRecherche:SCREEN-VALUE,50). 
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnCodeSuivant
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnCodeSuivant C-Win
ON CHOOSE OF btnCodeSuivant IN FRAME DEFAULT-FRAME /* > */
DO:
    /* Recherche en avant avec selection et retour au debut en fin de fichier */
    edtbrouillon:SEARCH(filRecherche:SCREEN-VALUE,49). 
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME CtrlFrame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL CtrlFrame C-Win OCX.Change
PROCEDURE CtrlFrame.TabStrip.Change .
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  None required for OCX.
  Notes:       
------------------------------------------------------------------------------*/

    RUN ChangementOnglet.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME edtBrouillon
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL edtBrouillon C-Win
ON CTRL-A OF edtBrouillon IN FRAME DEFAULT-FRAME
DO:
  
  DO WITH FRAME DEFAULT-FRAME:
      edtbrouillon:SET-SELECTION(1,LENGTH(edtbrouillon:SCREEN-VALUE) + 100) NO-ERROR.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL edtBrouillon C-Win
ON LEAVE OF edtBrouillon IN FRAME DEFAULT-FRAME
DO:
  edtbrouillon:SAVE-FILE(cFichierBrouillon).
  RUN terminaison.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filRecherche
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filRecherche C-Win
ON RETURN OF filRecherche IN FRAME DEFAULT-FRAME /* Recherche */
DO:
  APPLY "CHOOSE" TO BtnCodeSuivant.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME TOGGLE-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL TOGGLE-1 C-Win
ON VALUE-CHANGED OF TOGGLE-1 IN FRAME DEFAULT-FRAME /* Toujours visible */
DO:
    c-win:ALWAYS-ON-TOP = SELF:CHECKED.
    gSauvePreference("PREF-BROUILLON-TOPMOST",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
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
  RUN enable_UI.
  RUN Initialisation.
  IF NOT THIS-PROCEDURE:PERSISTENT THEN
    WAIT-FOR CLOSE OF THIS-PROCEDURE.
  RUN Terminaison.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE AdapteTaille C-Win 
PROCEDURE AdapteTaille :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    IF c-win:WIDTH-P >= FRAME DEFAULT-FRAME:WIDTH-P THEN c-win:WIDTH-P = FRAME DEFAULT-FRAME:WIDTH-P.
    IF c-win:HEIGHT-P >= FRAME DEFAULT-FRAME:HEIGHT-P THEN c-win:HEIGHT-P = FRAME DEFAULT-FRAME:HEIGHT-P.
    
    IF c-win:HEIGHT-P < 160 THEN c-win:HEIGHT-P = 160.
    IF c-win:WIDTH-P < 195 THEN c-win:WIDTH-P = 195.
    
    DO WITH FRAME DEFAULT-FRAME:
        edtbrouillon:WIDTH-P = c-win:WIDTH-P - (edtbrouillon:X * 2).
        edtbrouillon:HEIGHT-P = c-win:HEIGHT-P - (edtbrouillon:Y + 5).
        btncodeSuivant:X = edtbrouillon:X + edtbrouillon:WIDTH-P - btncodeSuivant:WIDTH-P.
        btncodeprecedent:X = btncodeSuivant:X - (btncodeprecedent:WIDTH-P + 2).
        toggle-1:X =  c-win:WIDTH-P - (toggle-1:WIDTH-P + 2).
        filRecherche:Y = 2.
        filRecherche:X = edtbrouillon:X.
        filRecherche:WIDTH-P = btncodeprecedent:X - filRecherche:X - 2.
        chCtrlFrame:Y = filRecherche:Y + (filRecherche:HEIGHT-P + 2).
        chCtrlFrame:WIDTH = edtbrouillon:WIDTH-P - (toggle-1:WIDTH-P + 5).
        chCtrlFrame:tabstrip:tabfixedwidth = (chCtrlFrame:WIDTH / (iMaxBrouillons + 1)) - ( c-win:WIDTH-P / 55) .
    END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ChangementOnglet C-Win 
PROCEDURE ChangementOnglet :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    DEFINE VARIABLE cTempo AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cInfosTempo AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cInfosCreateur AS CHARACTER NO-UNDO.

    /*IF lChargementEnCours THEN RETURN NO-APPLY.*/
    
    DO WITH FRAME DEFAULT-FRAME:
        /* Sauvegarde de la note en cours */
        IF not(lChargementEnCours) THEN edtBrouillon:SAVE-FILE(cFichierBrouillon).
    
        /* Chargement de la note */
        cFichierBrouillon = DonneNomFichier().
        
        edtBrouillon:READ-FILE(cFichierBrouillon).
    
        APPLY "ENTRY" TO edtBrouillon.
    END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control_load C-Win  _CONTROL-LOAD
PROCEDURE control_load :
/*------------------------------------------------------------------------------
  Purpose:     Load the OCXs    
  Parameters:  <none>
  Notes:       Here we load, initialize and make visible the 
               OCXs in the interface.                        
------------------------------------------------------------------------------*/

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN
DEFINE VARIABLE UIB_S    AS LOGICAL    NO-UNDO.
DEFINE VARIABLE OCXFile  AS CHARACTER  NO-UNDO.

OCXFile = SEARCH( "brouillon.wrx":U ).
IF OCXFile = ? THEN
  OCXFile = SEARCH(SUBSTRING(THIS-PROCEDURE:FILE-NAME, 1,
                     R-INDEX(THIS-PROCEDURE:FILE-NAME, ".":U), "CHARACTER":U) + "wrx":U).

IF OCXFile <> ? THEN
DO:
  ASSIGN
    chCtrlFrame = CtrlFrame:COM-HANDLE
    UIB_S = chCtrlFrame:LoadControls( OCXFile, "CtrlFrame":U)
    CtrlFrame:NAME = "CtrlFrame":U
  .
  RUN initialize-controls IN THIS-PROCEDURE NO-ERROR.
END.
ELSE MESSAGE "brouillon.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

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
  RUN control_load.
  DISPLAY filRecherche TOGGLE-1 edtBrouillon 
      WITH FRAME DEFAULT-FRAME IN WINDOW C-Win.
  ENABLE filRecherche btnCodePrecedent btnCodeSuivant TOGGLE-1 edtBrouillon 
      WITH FRAME DEFAULT-FRAME IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-DEFAULT-FRAME}
  VIEW C-Win.
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
    DEFINE VARIABLE cwin-X AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cwin-Y AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cwin-H AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cwin-L AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cwin-TOPMOST AS CHARACTER NO-UNDO.
    DEFINE VARIABLE iBrouillon AS INTEGER NO-UNDO INIT 0.

    /* Positionnement de la fenetre */
    cWin-X = gDonnePreference("PREF-BROUILLON-X").
    cWin-Y = gDonnePreference("PREF-BROUILLON-Y").
    cWin-H = gDonnePreference("PREF-BROUILLON-H").
    cWin-L = gDonnePreference("PREF-BROUILLON-L").
    cWin-TOPMOST = gDonnePreference("PREF-BROUILLON-TOPMOST").
    IF cWin-X <> "" THEN c-Win:X = integer(cwin-X).
    IF cWin-Y <> "" THEN c-Win:Y = integer(cWin-Y).
    IF cWin-H <> "" THEN c-Win:HEIGHT-P = integer(cWin-H).
    IF cWin-L <> "" THEN c-Win:WIDTH-P = integer(cWin-L).
    IF cWin-TOPMOST <> "" THEN c-win:ALWAYS-ON-TOP = (cWin-TOPMOST = "oui").
    toggle-1:CHECKED  IN FRAME DEFAULT-FRAME = (c-win:ALWAYS-ON-TOP).

    /* récupération du nombre de brouillons */
    iMaxBrouillons = INTEGER(gDonnePreference("PREF-MAX-BROUILLONS")).
    IF iMaxBrouillons = 0 THEN iMaxBrouillons = {&MAX_ONGLETS}.
    gSauvePreference("PREF-MAX-BROUILLONS",STRING(iMaxBrouillons)).

    /* Création des brouillons si inexistant + création des onglets */
    lChargementEnCours = TRUE.
    chCtrlFrame:tabstrip:tabs:CLEAR.
    DO iBoucle = 1 TO iMaxBrouillons:
        cFichierBrouillon = loc_outils + "\Brouillon" + STRING(iBoucle) + ".txt".
        IF SEARCH(cFichierBrouillon) = ? THEN DO:
            OUTPUT TO VALUE(cFichierBrouillon).
            OUTPUT CLOSE.
        END.
        chCtrlFrame:tabstrip:tabs:ADD(STRING(iBoucle)).
    END.

/* Récupération du dernier brouillon utilisé */
    cFichierBrouillon = loc_outils + "\Brouillon1.txt". /* Par defaut */
    iBrouillon = INTEGER(gDonnePreference("PREF-DERNIER-BROUILLON")).
    IF iBrouillon = 0 THEN iBrouillon = 1.
    IF iBrouillon > iMaxBrouillons THEN iBrouillon = 1.
    IF iBrouillon <> 0 THEN chCtrlFrame:tabstrip:VALUE = iBrouillon - 1.
    RUN ChangementOnglet.

    /* Chargement du brouillon */
    RUN AdapteTaille.

    lChargementEnCours = FALSE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE RendVisible C-Win 
PROCEDURE RendVisible :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
                c-win:WINDOW-STATE = 3.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Terminaison C-Win 
PROCEDURE Terminaison :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    IF c-win:WINDOW-STATE = 2 THEN RETURN.
    gSauvePreference("PREF-BROUILLON-X",STRING(c-win:X)).
    gSauvePreference("PREF-BROUILLON-Y",STRING(c-win:Y)).
    gSauvePreference("PREF-BROUILLON-H",STRING(c-win:HEIGHT-P)).
    gSauvePreference("PREF-BROUILLON-L",STRING(c-win:WIDTH-P)).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION DonneNomFichier C-Win 
FUNCTION DonneNomFichier RETURNS CHARACTER
  ( /* parameter-definitions */ ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
    DEFINE VARIABLE iOnglet AS INTEGER NO-UNDO.
    DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO.  

    iOnglet = INTEGER(trim(chCtrlFrame:tabstrip:SelectedItem:NAME)).
    cRetour = loc_outils 
        + "\Brouillon"
        + STRING(iOnglet) 
        + ".txt".

    IF NOT(lChargementEnCours) THEN DO:
        gSauvePreference("PREF-DERNIER-BROUILLON",STRING(iOnglet)).
    END.

  RETURN cRetour.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

