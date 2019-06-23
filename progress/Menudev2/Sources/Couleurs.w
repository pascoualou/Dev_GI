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

/* Local Variable Definitions ---                                       */

DEFINE VARIABLE hrectangle AS HANDLE EXTENT 15.

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
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 6 BY .95
     BGCOLOR 0 FGCOLOR 0 .

DEFINE RECTANGLE RECT-10
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 6 BY .95
     BGCOLOR 9 FGCOLOR 9 .

DEFINE RECTANGLE RECT-11
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 6 BY .95
     BGCOLOR 10 FGCOLOR 10 .

DEFINE RECTANGLE RECT-12
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 6 BY .95
     BGCOLOR 11 FGCOLOR 11 .

DEFINE RECTANGLE RECT-13
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 6 BY .95
     BGCOLOR 12 FGCOLOR 12 .

DEFINE RECTANGLE RECT-14
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 6 BY .95
     BGCOLOR 13 FGCOLOR 13 .

DEFINE RECTANGLE RECT-15
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 6 BY .95
     BGCOLOR 14 FGCOLOR 14 .

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 6 BY .95
     BGCOLOR 1 FGCOLOR 1 .

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 6 BY .95
     BGCOLOR 2 FGCOLOR 2 .

DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 6 BY .95
     BGCOLOR 3 FGCOLOR 3 .

DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 6 BY .95
     BGCOLOR 4 FGCOLOR 4 .

DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 6 BY .95
     BGCOLOR 5 FGCOLOR 5 .

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 6 BY .95
     BGCOLOR 6 FGCOLOR 6 .

DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 6 BY .95
     BGCOLOR 7 FGCOLOR 7 .

DEFINE RECTANGLE RECT-9
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 6 BY .95
     BGCOLOR 8 FGCOLOR 8 .

DEFINE BUTTON btnAbandon 
     LABEL "Abandon" 
     SIZE 33 BY .95.

DEFINE BUTTON BtnOK 
     LABEL "Ok" 
     SIZE 18 BY .95.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME frmSaisie
     BtnOK AT ROW 6.95 COL 3 WIDGET-ID 4
     btnAbandon AT ROW 6.95 COL 21.4 WIDGET-ID 2
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 55 BY 7.52 WIDGET-ID 100.

DEFINE FRAME frmModule
     RECT-1 AT ROW 1.24 COL 2 WIDGET-ID 2
     RECT-2 AT ROW 1.24 COL 12 WIDGET-ID 4
     RECT-3 AT ROW 1.24 COL 22 WIDGET-ID 6
     RECT-4 AT ROW 1.24 COL 33 WIDGET-ID 8
     RECT-5 AT ROW 1.24 COL 43 WIDGET-ID 10
     RECT-6 AT ROW 2.43 COL 2 WIDGET-ID 12
     RECT-7 AT ROW 2.43 COL 12 WIDGET-ID 14
     RECT-8 AT ROW 2.43 COL 22 WIDGET-ID 16
     RECT-9 AT ROW 2.43 COL 33 WIDGET-ID 18
     RECT-10 AT ROW 2.43 COL 43 WIDGET-ID 20
     RECT-11 AT ROW 3.86 COL 2 WIDGET-ID 22
     RECT-12 AT ROW 3.86 COL 12 WIDGET-ID 24
     RECT-13 AT ROW 3.86 COL 22 WIDGET-ID 26
     RECT-14 AT ROW 3.86 COL 33 WIDGET-ID 28
     RECT-15 AT ROW 3.86 COL 43 WIDGET-ID 30
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3 ROW 1.24
         SIZE 52 BY 5.48
         TITLE "Couleurs disponibles" WIDGET-ID 200.


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
         TITLE              = "Saisie couleur"
         HEIGHT             = 7.52
         WIDTH              = 55
         MAX-HEIGHT         = 32.57
         MAX-WIDTH          = 273.2
         VIRTUAL-HEIGHT     = 32.57
         VIRTUAL-WIDTH      = 273.2
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

ASSIGN 
       RECT-1:SELECTABLE IN FRAME frmModule       = TRUE
       RECT-1:PRIVATE-DATA IN FRAME frmModule     = 
                "0".

ASSIGN 
       RECT-10:SELECTABLE IN FRAME frmModule       = TRUE
       RECT-10:PRIVATE-DATA IN FRAME frmModule     = 
                "9".

ASSIGN 
       RECT-11:SELECTABLE IN FRAME frmModule       = TRUE
       RECT-11:PRIVATE-DATA IN FRAME frmModule     = 
                "10".

ASSIGN 
       RECT-12:SELECTABLE IN FRAME frmModule       = TRUE
       RECT-12:PRIVATE-DATA IN FRAME frmModule     = 
                "11".

ASSIGN 
       RECT-13:SELECTABLE IN FRAME frmModule       = TRUE
       RECT-13:PRIVATE-DATA IN FRAME frmModule     = 
                "12".

ASSIGN 
       RECT-14:SELECTABLE IN FRAME frmModule       = TRUE
       RECT-14:PRIVATE-DATA IN FRAME frmModule     = 
                "13".

ASSIGN 
       RECT-15:SELECTABLE IN FRAME frmModule       = TRUE
       RECT-15:PRIVATE-DATA IN FRAME frmModule     = 
                "14".

ASSIGN 
       RECT-2:SELECTABLE IN FRAME frmModule       = TRUE
       RECT-2:PRIVATE-DATA IN FRAME frmModule     = 
                "1".

ASSIGN 
       RECT-3:SELECTABLE IN FRAME frmModule       = TRUE
       RECT-3:PRIVATE-DATA IN FRAME frmModule     = 
                "2".

ASSIGN 
       RECT-4:SELECTABLE IN FRAME frmModule       = TRUE
       RECT-4:PRIVATE-DATA IN FRAME frmModule     = 
                "3".

ASSIGN 
       RECT-5:SELECTABLE IN FRAME frmModule       = TRUE
       RECT-5:PRIVATE-DATA IN FRAME frmModule     = 
                "4".

ASSIGN 
       RECT-6:SELECTABLE IN FRAME frmModule       = TRUE
       RECT-6:PRIVATE-DATA IN FRAME frmModule     = 
                "5".

ASSIGN 
       RECT-7:SELECTABLE IN FRAME frmModule       = TRUE
       RECT-7:PRIVATE-DATA IN FRAME frmModule     = 
                "6".

ASSIGN 
       RECT-8:SELECTABLE IN FRAME frmModule       = TRUE
       RECT-8:PRIVATE-DATA IN FRAME frmModule     = 
                "7".

ASSIGN 
       RECT-9:SELECTABLE IN FRAME frmModule       = TRUE
       RECT-9:PRIVATE-DATA IN FRAME frmModule     = 
                "8".

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
ON END-ERROR OF C-Win /* Saisie couleur */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON WINDOW-CLOSE OF C-Win /* Saisie couleur */
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

    DO iBoucle = 1 TO 15:
        IF hrectangle[iboucle]:SELECTED THEN 
            cValeur = hrectangle[iboucle]:PRIVATE-DATA.
    END.

    ENTRY(4,cParametres-io,"|") = cValeur.
    APPLY "WINDOW-CLOSE" TO c-win.

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
  ENABLE RECT-1 RECT-2 RECT-3 RECT-4 RECT-5 RECT-6 RECT-7 RECT-8 RECT-9 RECT-10 
         RECT-11 RECT-12 RECT-13 RECT-14 RECT-15 
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

    iPosX = INTEGER(ENTRY(1,cParametres-io,"|")).
    iPosY = INTEGER(ENTRY(2,cParametres-io,"|")).

        IF iPosX <> ? AND iPosY <> ? THEN DO:
        /*CURRENT-WINDOW:X = iPosX.*/
        c-win:X = iPosX + 340.
        /*CURRENT-WINDOW:Y = iPosY.*/
        c-win:Y = iPosY + 250.
    END.
    
    DO WITH FRAME frmModule:
        hrectangle[1] = rect-1:HANDLE.
        hrectangle[2] = rect-2:HANDLE.
        hrectangle[3] = rect-3:HANDLE.
        hrectangle[4] = rect-4:HANDLE.
        hrectangle[5] = rect-5:HANDLE.
        hrectangle[6] = rect-6:HANDLE.
        hrectangle[7] = rect-7:HANDLE.
        hrectangle[8] = rect-8:HANDLE.
        hrectangle[9] = rect-9:HANDLE.
        hrectangle[10] = rect-10:HANDLE.
        hrectangle[11] = rect-11:HANDLE.
        hrectangle[12] = rect-12:HANDLE.
        hrectangle[13] = rect-13:HANDLE.
        hrectangle[14] = rect-14:HANDLE.
        hrectangle[15] = rect-15:HANDLE.
    END.

    IF ENTRY(4,cParametres-io,"|") <> "" THEN hrectangle[INTEGER(ENTRY(4,cParametres-io,"|")) + 1]:SELECTED = TRUE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

