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
{includes\i_environnement.i}
{includes\i_dialogue.i}
{menudev2\includes\menudev2.i}

/* Parameters Definitions ---                                           */
DEFINE INPUT-OUTPUT PARAMETER   cParametres-io    AS CHARACTER    NO-UNDO.

/* Local Variable Definitions ---    */

DEFINE TEMP-TABLE ttUtils
    FIELD cNom  AS CHARACTER
    FIELD cVraiNom AS CHARACTER
    
   .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME frmSaisie

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS BtnOK btnAbandon 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE VARIABLE cmbUtilisateurs AS CHARACTER 
     VIEW-AS SELECTION-LIST SINGLE SCROLLBAR-VERTICAL 
     SIZE 50 BY 13.57 NO-UNDO.

DEFINE BUTTON btnAbandon 
     LABEL "Abandon" 
     SIZE 33 BY .95.

DEFINE BUTTON BtnOK 
     LABEL "Ok" 
     SIZE 18 BY .95.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME frmSaisie
     BtnOK AT ROW 16.71 COL 3 WIDGET-ID 4
     btnAbandon AT ROW 16.71 COL 21.4 WIDGET-ID 2
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 55 BY 16.95 WIDGET-ID 100.

DEFINE FRAME frmModule
     cmbUtilisateurs AT ROW 1.24 COL 2 NO-LABEL WIDGET-ID 4
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3 ROW 1.24
         SIZE 52 BY 15
         TITLE "..." WIDGET-ID 200.


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
         TITLE              = "Saisie paramètres...."
         HEIGHT             = 16.95
         WIDTH              = 55
         MAX-HEIGHT         = 16.95
         MAX-WIDTH          = 80
         VIRTUAL-HEIGHT     = 16.95
         VIRTUAL-WIDTH      = 80
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
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW C-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* REPARENT FRAME */
ASSIGN FRAME frmModule:FRAME = FRAME frmSaisie:HANDLE.

/* SETTINGS FOR FRAME frmModule
                                                                        */
ASSIGN 
       FRAME frmModule:HIDDEN           = TRUE.

/* SETTINGS FOR FRAME frmSaisie
   FRAME-NAME                                                           */

DEFINE VARIABLE XXTABVALXX AS LOGICAL NO-UNDO.

ASSIGN XXTABVALXX = FRAME frmModule:MOVE-BEFORE-TAB-ITEM (BtnOK:HANDLE IN FRAME frmSaisie)
/* END-ASSIGN-TABS */.

IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON END-ERROR OF C-Win /* Saisie paramètres.... */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON WINDOW-CLOSE OF C-Win /* Saisie paramètres.... */
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnAbandon
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnAbandon C-Win
ON CHOOSE OF btnAbandon IN FRAME frmSaisie /* Abandon */
DO:
    cParametres-io = "".
    APPLY "WINDOW-CLOSE" TO c-win.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnAbandon C-Win
ON RIGHT-MOUSE-CLICK OF btnAbandon IN FRAME frmSaisie /* Abandon */
DO:
    /*
    MESSAGE "X = / Y = " c-win:X " / " c-win:Y VIEW-AS ALERT-BOX.
    MESSAGE "gdPositionXModule = / gdPositionYModule = " gdPositionXModule " / " gdPositionYModule VIEW-AS ALERT-BOX.
    */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BtnOK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BtnOK C-Win
ON CHOOSE OF BtnOK IN FRAME frmSaisie /* Ok */
DO:
    DEFINE VARIABLE cValeur AS CHARACTER NO-UNDO.

    DO WITH FRAME frmModule:
        cValeur = ENTRY(2,cmbUtilisateurs:SCREEN-VALUE,"|").
        ENTRY(4,cParametres-io,"|") = (IF NOT(cValeur BEGINS "Choisissez") THEN cValeur ELSE "") .
    END.
    APPLY "WINDOW-CLOSE" TO c-win.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frmModule
&Scoped-define SELF-NAME cmbUtilisateurs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cmbUtilisateurs C-Win
ON DEFAULT-ACTION OF cmbUtilisateurs IN FRAME frmModule
DO:
  APPLY "CHOOSE" TO btnOK IN FRAME frmSaisie.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frmSaisie
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
  ENABLE BtnOK btnAbandon 
      WITH FRAME frmSaisie IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-frmSaisie}
  DISPLAY cmbUtilisateurs 
      WITH FRAME frmModule IN WINDOW C-Win.
  ENABLE cmbUtilisateurs 
      WITH FRAME frmModule IN WINDOW C-Win.
  VIEW FRAME frmModule IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-frmModule}
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
    DEFINE VARIABLE iPosX AS INTEGER NO-UNDO.
    DEFINE VARIABLE iPosY AS INTEGER NO-UNDO.

    DEFINE VARIABLE cTempo AS CHARACTER NO-UNDO.
    DEFINE VARIABLE iVersionMenudev2 AS INTEGER NO-UNDO.


    iPosX = INTEGER(ENTRY(1,cParametres-io,"|")).
    iPosY = INTEGER(ENTRY(2,cParametres-io,"|")).

    IF iPosX <> ? AND iPosY <> ? THEN DO:
        c-win:X = iPosX - (c-win:width-pixels / 2).
        c-win:Y = iPosY - (c-win:height-pixels / 2).
    END.
    
    FRAME frmModule:TITLE = ENTRY(3,cParametres-io,"|").
    
    /* Chargement de la liste des utilisateurs */
    FOR EACH    utilisateurs   NO-LOCK
        :
        /* exclusions */
        /*IF UTILISATEURS.cUtilisateur = gcUtilisateur THEN NEXT.*/
        IF UTILISATEURS.lDesactive THEN NEXT.
        IF UTILISATEURS.lNonPhysique THEN NEXT.
        /*IF UTILISATEURS.iVersion < (iVersionMenudev2 - 2) THEN NEXT.*/
        CREATE ttUtils.
        ASSIGN
            ttUtils.cnom = UTILISATEURS.cUtilisateur
            ttUtils.cVraiNom = DonneVraiNomUtilisateur(UTILISATEURS.cUtilisateur)
            .
    END.
    
    cmbUtilisateurs:LIST-ITEMS = ?.
    FOR EACH ttUtils
        BY ttUtils.cVraiNom
        :
        cmbUtilisateurs:add-last(ttUtils.cVraiNom + FILL(" ",100) + "|" + ttUtils.cNom).
    END.
    cmbUtilisateurs:SCREEN-VALUE = cmbUtilisateurs:ENTRY(1).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

