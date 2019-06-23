&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME WinAlarme
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS WinAlarme 
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
DEFINE INPUT PARAMETER cIdentAgenda AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER cIdentAlarme AS CHARACTER NO-UNDO.

{includes\i_environnement.i}
    {includes\i_chaine.i}
    {includes\i_son.i}
{menudev2\includes\menudev2.i}


    /* Local Variable Definitions ---                                       */
    DEFINE BUFFER refAlarmes FOR Alarmes.
    DEFINE BUFFER bAlarmes FOR Alarmes.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME frmAlarme

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS edtTexte BtnStop tglRappel filTitre 
&Scoped-Define DISPLAYED-OBJECTS edtTexte tglRappel filTitre 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR WinAlarme AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON BtnStop 
     LABEL "Stop" 
     SIZE 9 BY 1.91.

DEFINE VARIABLE edtTexte AS CHARACTER 
     VIEW-AS EDITOR NO-BOX
     SIZE 82 BY 4.52
     FONT 8 NO-UNDO.

DEFINE VARIABLE filTitre AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 82 BY .86
     FONT 10 NO-UNDO.

DEFINE VARIABLE tglRappel AS LOGICAL INITIAL no 
     LABEL "me représenter cette alerte dans 10 minutes" 
     VIEW-AS TOGGLE-BOX
     SIZE 46 BY 1.19 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME frmAlarme
     edtTexte AT ROW 2.91 COL 2 NO-LABEL
     BtnStop AT ROW 8.14 COL 74
     tglRappel AT ROW 8.38 COL 3
     filTitre AT ROW 1.24 COL 2 NO-LABEL
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 84 BY 9.38.


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
  CREATE WINDOW WinAlarme ASSIGN
         HIDDEN             = YES
         TITLE              = "Menudev2 : Alarme..."
         HEIGHT             = 9.38
         WIDTH              = 84
         MAX-HEIGHT         = 44.76
         MAX-WIDTH          = 256
         VIRTUAL-HEIGHT     = 44.76
         VIRTUAL-WIDTH      = 256
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
/* SETTINGS FOR WINDOW WinAlarme
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME frmAlarme
   FRAME-NAME                                                           */
ASSIGN 
       edtTexte:READ-ONLY IN FRAME frmAlarme        = TRUE.

/* SETTINGS FOR FILL-IN filTitre IN FRAME frmAlarme
   ALIGN-L                                                              */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(WinAlarme)
THEN WinAlarme:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME WinAlarme
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL WinAlarme WinAlarme
ON END-ERROR OF WinAlarme /* Menudev2 : Alarme... */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL WinAlarme WinAlarme
ON WINDOW-CLOSE OF WinAlarme /* Menudev2 : Alarme... */
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BtnStop
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BtnStop WinAlarme
ON CHOOSE OF BtnStop IN FRAME frmAlarme /* Stop */
DO:
    /* Gestion du rappel */
    IF cIdentAlarme <> "" THEN DO:
        FIND FIRST refAlarmes EXCLUSIVE-LOCK
            WHERE refAlarmes.cIdentAlarme = cIdentAlarme NO-ERROR.
            
    END.
    IF tglRappel:CHECKED AND available(refAlarmes) THEN DO:
        /* Création de l'alarme */
        CREATE bAlarmes.
        BUFFER-COPY refAlarmes TO bAlarmes.
        bAlarmes.ddate = TODAY.
        bAlarmes.iheure = EnHeuresMinutes(EnMinute(integer(REPLACE(STRING(TIME,"hh:mm"),":","")) + 10)).
        bAlarmes.lRappel = TRUE.
        bAlarmes.ltraitee = FALSE.
        bAlarmes.lEncours = FALSE.
    END.

    /* suppression de l'alarmes en cours */
    IF available(refAlarmes) AND cIdentAlarme <> "" THEN do:
        DELETE refAlarmes.
    END.
    IF cIdentAlarme <> "" THEN glModificationAlarmes = TRUE.
    APPLY "close" TO THIS-PROCEDURE.
    
    RELEASE refAlarmes.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK WinAlarme 


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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI WinAlarme  _DEFAULT-DISABLE
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
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(WinAlarme)
  THEN DELETE WIDGET WinAlarme.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI WinAlarme  _DEFAULT-ENABLE
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
  DISPLAY edtTexte tglRappel filTitre 
      WITH FRAME frmAlarme IN WINDOW WinAlarme.
  ENABLE edtTexte BtnStop tglRappel filTitre 
      WITH FRAME frmAlarme IN WINDOW WinAlarme.
  {&OPEN-BROWSERS-IN-QUERY-frmAlarme}
  VIEW WinAlarme.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Initialisation WinAlarme 
PROCEDURE Initialisation :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE chSon AS COM-HANDLE NO-UNDO.
    DEFINE VARIABLE cCommande AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cActionModifiee AS CHARACTER NO-UNDO.

    WinAlarme:LOAD-ICON(gcRepertoireImages + "alarme.ico").
    
    btnstop:LOAD-IMAGE(gcRepertoireImages + "stop.ico") IN FRAME frmAlarme.

    /* se positionner sur la bonne ligne de l'agenda */

    IF cIdentAlarme <> "" THEN DO:
        FIND FIRST refAlarmes NO-LOCK
            WHERE refAlarmes.cIdentAlarme = cIdentAlarme NO-ERROR.
    END.
    FIND FIRST agenda NO-LOCK
        WHERE agenda.cident = cIdentAgenda
        NO-ERROR.
    IF NOT(AVAILABLE(agenda)) THEN RETURN.

    DO WITH FRAME frmAlarme:
        filTitre:SCREEN-VALUE = agenda.cLibelle.
        edtTexte:SCREEN-VALUE = agenda.cTexte.
        tglRappel:SENSITIVE = (cIdentAlarme <> ""). /* on vient du test alarme = pas de rappel */
    END.

    /* Gestion de l'action */
    IF agenda.laction THEN DO:
        /* remplacement de certaines variables dans la ligne de commande avant execution */
        cActionModifiee = RemplaceVariables(agenda.cAction,"*",?,0).
        IF cActionModifiee MATCHES "*.bat*" THEN
            OS-COMMAND NO-WAIT VALUE(gcRepertoireRessourcesPrivees + "\scripts\general\execute2.bat " + cActionModifiee
                                     ).
        ELSE
            OS-COMMAND NO-WAIT VALUE(cActionModifiee).
    END.

    /* Gestion du son */
    IF agenda.cSon <> "" AND agenda.cSon <> "-" THEN DO:
        IF not(DonnePreference("PREF-MODESILENCIEUX")) = "OUI" THEN RUN JoueSon(gcRepertoireRessources + agenda.cSon + ".wav").
    END.

    /* Fermeture si pas de message */
    IF agenda.ctexte = "" THEN APPLY "CHOOSE" TO btnStop.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

