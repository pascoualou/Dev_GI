&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME winMessage
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS winMessage 
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
    {includes\i_api.i}
{menudev2\includes\menudev2.i}
/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE INPUT PARAMETER iPositionX-in AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER iPositionY-in AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER cTitre-in AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER cMessage-in AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER lOuiNon-in AS LOGICAL  NO-UNDO.
DEFINE INPUT PARAMETER iTemporisation-in AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER cBoutonDefaut-in AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER cIdentBouton-in AS CHARACTER NO-UNDO.
DEFINE OUTPUT PARAMETER cBoutonRetour-ou AS CHARACTER NO-UNDO.


/*
iPositionX = 0.
iPositionY = 0.
cTitre-in = "Test de message temporisé".
cMessage-in = "Ceci est le corps du message temporisé.".
lOuiNon-in = TRUE.
iTemporisation-in = 5.
cBoutonDefaut-in = "NON".
*/

DEFINE VARIABLE hBoutonDefaut AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE hBoutonEsc AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE iReste AS INTEGER NO-UNDO.
DEFINE VARIABLE lClique AS LOGICAL INIT FALSE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME frmMessage

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS edtMessage tglAffichage btnOui btnOK btnNon 
&Scoped-Define DISPLAYED-OBJECTS edtMessage tglAffichage 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR winMessage AS WIDGET-HANDLE NO-UNDO.

/* Definitions of handles for OCX Containers                            */
DEFINE VARIABLE Timer AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chTimer AS COMPONENT-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON btnNon 
     LABEL "Non" 
     SIZE 24 BY 1.1.

DEFINE BUTTON btnOK 
     LABEL "OK" 
     SIZE 24 BY 1.1.

DEFINE BUTTON btnOui 
     LABEL "Oui" 
     SIZE 24 BY 1.1.

DEFINE VARIABLE edtMessage AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL NO-BOX
     SIZE 72 BY 1.38
     BGCOLOR 20 FONT 8 NO-UNDO.

DEFINE VARIABLE tglAffichage AS LOGICAL INITIAL no 
     LABEL "Ne plus afficher ce message" 
     VIEW-AS TOGGLE-BOX
     SIZE 34 BY .71 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME frmMessage
     edtMessage AT ROW 1.29 COL 2 NO-LABEL WIDGET-ID 2
     tglAffichage AT ROW 3.14 COL 21 WIDGET-ID 12
     btnOui AT ROW 4.1 COL 12 WIDGET-ID 4
     btnOK AT ROW 4.1 COL 26 WIDGET-ID 8
     btnNon AT ROW 4.1 COL 38 WIDGET-ID 6
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 73.8 BY 5.57 WIDGET-ID 100.


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
  CREATE WINDOW winMessage ASSIGN
         HIDDEN             = YES
         TITLE              = "<insert window title>"
         COLUMN             = 51.4
         ROW                = 12
         HEIGHT             = 5.57
         WIDTH              = 73.8
         MAX-HEIGHT         = 46
         MAX-WIDTH          = 336
         VIRTUAL-HEIGHT     = 46
         VIRTUAL-WIDTH      = 336
         CONTROL-BOX        = no
         MIN-BUTTON         = no
         MAX-BUTTON         = no
         ALWAYS-ON-TOP      = yes
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
/* SETTINGS FOR WINDOW winMessage
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME frmMessage
   FRAME-NAME                                                           */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(winMessage)
THEN winMessage:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

CREATE CONTROL-FRAME Timer ASSIGN
       FRAME           = FRAME frmMessage:HANDLE
       ROW             = 1
       COLUMN          = 1
       HEIGHT          = 1.33
       WIDTH           = 6
       WIDGET-ID       = 10
       HIDDEN          = yes
       SENSITIVE       = yes.
/* Timer OCXINFO:CREATE-CONTROL from: {F0B88A90-F5DA-11CF-B545-0020AF6ED35A} type: PSTimer */
      Timer:MOVE-BEFORE(edtMessage:HANDLE IN FRAME frmMessage).

&ENDIF

&ANALYZE-RESUME /* End of _CREATE-DYNAMIC */


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME winMessage
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL winMessage winMessage
ON END-ERROR OF winMessage /* <insert window title> */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  /*IF THIS-PROCEDURE:PERSISTENT THEN*/ /*RETURN NO-APPLY. */
    IF VALID-HANDLE(hBoutonEsc) THEN 
        APPLY "choose" TO hBoutonEsc.
    ELSE
        RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL winMessage winMessage
ON WINDOW-CLOSE OF winMessage /* <insert window title> */
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnNon
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnNon winMessage
ON CHOOSE OF btnNon IN FRAME frmMessage /* Non */
DO:
    lClique = TRUE.
    cBoutonRetour-ou = "NON".
    /*MESSAGE "Action sur le bouton NON" VIEW-AS ALERT-BOX.*/
    APPLY "CLOSE" TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnOK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnOK winMessage
ON CHOOSE OF btnOK IN FRAME frmMessage /* OK */
DO:
    lClique = TRUE.
    cBoutonRetour-ou = "OK".
    /*MESSAGE "Action sur le bouton OK" VIEW-AS ALERT-BOX.*/
    APPLY "CLOSE" TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnOui
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnOui winMessage
ON CHOOSE OF btnOui IN FRAME frmMessage /* Oui */
DO:
    lClique = TRUE.
    cBoutonRetour-ou = "OUI".
    /*MESSAGE "Action sur le bouton OUI" VIEW-AS ALERT-BOX.*/
    APPLY "CLOSE" TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglAffichage
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglAffichage winMessage
ON VALUE-CHANGED OF tglAffichage IN FRAME frmMessage /* Ne plus afficher ce message */
DO:
  
    gSauvePreference(cIdentBouton-in,(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Timer
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Timer winMessage OCX.Tick
PROCEDURE Timer.PSTimer.Tick .
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  None required for OCX.
  Notes:       
------------------------------------------------------------------------------*/
    RUN ProcedureTic.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK winMessage 


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

ON ENDKEY ANYWHERE 
DO:
    MESSAGE "coucou" VIEW-AS ALERT-BOX.
    RETURN.
END.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO /*ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK*/ :
  RUN enable_UI.
  RUN Initialisation.
  IF NOT THIS-PROCEDURE:PERSISTENT THEN
    WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE AfficheLabelBouton winMessage 
PROCEDURE AfficheLabelBouton :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control_load winMessage  _CONTROL-LOAD
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

OCXFile = SEARCH( "MesTemp.wrx":U ).
IF OCXFile = ? THEN
  OCXFile = SEARCH(SUBSTRING(THIS-PROCEDURE:FILE-NAME, 1,
                     R-INDEX(THIS-PROCEDURE:FILE-NAME, ".":U), "CHARACTER":U) + "wrx":U).

IF OCXFile <> ? THEN
DO:
  ASSIGN
    chTimer = Timer:COM-HANDLE
    UIB_S = chTimer:LoadControls( OCXFile, "Timer":U)
    Timer:NAME = "Timer":U
  .
  RUN initialize-controls IN THIS-PROCEDURE NO-ERROR.
END.
ELSE MESSAGE "MesTemp.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI winMessage  _DEFAULT-DISABLE
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
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(winMessage)
  THEN DELETE WIDGET winMessage.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI winMessage  _DEFAULT-ENABLE
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
  DISPLAY edtMessage tglAffichage 
      WITH FRAME frmMessage IN WINDOW winMessage.
  ENABLE edtMessage tglAffichage btnOui btnOK btnNon 
      WITH FRAME frmMessage IN WINDOW winMessage.
  {&OPEN-BROWSERS-IN-QUERY-frmMessage}
  VIEW winMessage.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Initialisation winMessage 
PROCEDURE Initialisation :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    winMessage:TITLE = cTitre-in.
    IF iPositionX-in <> 0 THEN winMessage:X = iPositionX-in - (winMessage:WIDTH-PIXELS / 2).
    IF iPositionY-in <> 0 THEN winMessage:Y = iPositionY-in - (winMessage:HEIGHT-PIXELS / 2).

    IF iPositionX-in = 0 AND iPositionY-in = 0 THEN DO:

    END.

    DO WITH FRAME frmMessage:
        edtMessage:SCREEN-VALUE = replace(cMessage-in,"%s",CHR(10)).
        btnOui:VISIBLE = lOuiNon-in.
        btnNon:VISIBLE = lOuiNon-in.
        btnOK:VISIBLE = not(lOuiNon-in).
        tglAffichage:VISIBLE = NOT(lOuiNon-in OR cIdentBouton-in = "").

        /* redimensionnement en fonction de la taille du message */
        ASSIGN
            edtMessage:HEIGHT-PIXELS = (18 * (edtMessage:NUM-LINES))
            NO-ERROR.
        IF edtMessage:HEIGHT-PIXELS >= 252 THEN DO:
            ASSIGN
                edtMessage:HEIGHT-PIXELS = 252
                NO-ERROR.
            /*edtMessage:SCROLLBAR-VERTICAL = TRUE.*/
        END.
        
        ASSIGN
            tglAffichage:Y = edtMessage:Y + edtMessage:HEIGHT-PIXELS + 5
            btnOK:Y = tglAffichage:Y + tglAffichage:HEIGHT-PIXELS + 5
            btnOui:Y = btnOK:Y
            btnNon:Y = btnOK:Y
            FRAME frmMessage:HEIGHT-PIXELS = btnOK:Y + btnOK:HEIGHT-PIXELS + 10
            FRAME frmMessage:virtual-HEIGHT-PIXELS = FRAME frmMessage:HEIGHT-PIXELS 
            winMessage:HEIGHT-PIXELS = FRAME frmMessage:HEIGHT-PIXELS
            NO-ERROR. /* pour éviter les message d'erreur sur le positionnement du bouton en dehors de la window */

        IF iTemporisation-in <> 0 THEN DO:
            chtimer:INTERVAL = 1000.
            iReste = iTemporisation-in.
            IF cBoutonDefaut-in <> "" THEN DO :
                CASE cBoutonDefaut-in:
                    WHEN "OK" THEN hBoutonDefaut = btnOK:HANDLE.
                    WHEN "OUI" THEN hBoutonDefaut = btnOui:HANDLE.
                    WHEN "NON" THEN hBoutonDefaut = btnNon:HANDLE.
                END CASE.
                hBoutonDefaut:PRIVATE-DATA = hBoutonDefaut:LABEL.
                RUN procedureTic.
            END.
        END.
        IF VALID-HANDLE(hBoutonDefaut) THEN APPLY "ENTRY" TO hBoutonDefaut.
        IF lOuiNon-in AND hBoutonDefaut = btnOui:HANDLE THEN hBoutonEsc = btnNon:HANDLE.
        IF lOuiNon-in AND hBoutonDefaut = btnNon:HANDLE THEN hBoutonEsc = btnOui:HANDLE.
        IF not(lOuiNon-in) THEN hBoutonEsc = hBoutonDefaut.
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ProcedureTic winMessage 
PROCEDURE ProcedureTic :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    IF iTemporisation-in = 0 THEN RETURN.
    IF iReste < 0 OR lClique THEN RETURN.
    hBoutonDefaut:LABEL = hBoutonDefaut:PRIVATE-DATA + " (" + STRING(iReste) + "s)".
    iReste = iReste - 1.
    IF iReste < 0 THEN do:
        
        cBoutonRetour-ou = cBoutonDefaut-in.
        APPLY "CHOOSE" TO hBoutonDefaut.
    
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

