&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME frmSaisie
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS frmSaisie 
/*------------------------------------------------------------------------

  File: 

  Description: 

  Input Parameters:
      

  Output Parameters:
      <none>

  Author: 

  Created: 
------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE INPUT PARAMETER   cModule-in    AS CHARACTER    NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER   cParametres-io    AS CHARACTER    NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME frmSaisie

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_Cancel Btn_OK 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_Cancel AUTO-END-KEY 
     LABEL "Abandon" 
     SIZE 15 BY 1.14
     BGCOLOR 8 .

DEFINE BUTTON Btn_OK AUTO-GO 
     LABEL "Validation" 
     SIZE 35 BY 1.14
     BGCOLOR 8 .

DEFINE VARIABLE filCode AS CHARACTER FORMAT "X(256)":U 
     LABEL "Code du module" 
     VIEW-AS FILL-IN 
     SIZE 31 BY .95 NO-UNDO.

DEFINE VARIABLE filNom AS CHARACTER FORMAT "X(256)":U 
     LABEL "Libellé du module" 
     VIEW-AS FILL-IN 
     SIZE 30.6 BY .95 NO-UNDO.

DEFINE VARIABLE filParametres AS CHARACTER FORMAT "X(256)":U 
     LABEL "Paramètres du module" 
     VIEW-AS FILL-IN 
     SIZE 26.6 BY .95 NO-UNDO.

DEFINE VARIABLE filParametres-2 AS CHARACTER FORMAT "X(256)":U 
     LABEL "Niveau du module" 
     VIEW-AS FILL-IN 
     SIZE 30 BY .95 NO-UNDO.

DEFINE VARIABLE filParametres-3 AS CHARACTER FORMAT "X(256)":U 
     LABEL "Groupe du module" 
     VIEW-AS FILL-IN 
     SIZE 29.6 BY .95 NO-UNDO.

DEFINE VARIABLE filProgramme AS CHARACTER FORMAT "X(256)":U 
     LABEL "Programme du module" 
     VIEW-AS FILL-IN 
     SIZE 26.6 BY .95 NO-UNDO.

DEFINE VARIABLE tglAdmin AS LOGICAL INITIAL no 
     LABEL "Module résérvé au mode administrateur" 
     VIEW-AS TOGGLE-BOX
     SIZE 49 BY .71 NO-UNDO.

DEFINE VARIABLE tglbases AS LOGICAL INITIAL no 
     LABEL "Bases (module nécessitant une connexion)" 
     VIEW-AS TOGGLE-BOX
     SIZE 49 BY .71 NO-UNDO.

DEFINE VARIABLE tglLancement AS LOGICAL INITIAL no 
     LABEL "Lancer le module au démarrage de l'application" 
     VIEW-AS TOGGLE-BOX
     SIZE 49 BY .71 NO-UNDO.

DEFINE VARIABLE tglVisible AS LOGICAL INITIAL no 
     LABEL "Module Visible" 
     VIEW-AS TOGGLE-BOX
     SIZE 49 BY .71 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME frmSaisie
     Btn_Cancel AT ROW 14.57 COL 3
     Btn_OK AT ROW 14.57 COL 20
     SPACE(1.99) SKIP(0.19)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Saisie..."
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel.

DEFINE FRAME frmModule
     filCode AT ROW 1.24 COL 18 COLON-ALIGNED
     filNom AT ROW 2.67 COL 19 COLON-ALIGNED
     tglLancement AT ROW 4.1 COL 3
     filProgramme AT ROW 5.05 COL 23 COLON-ALIGNED
     filParametres AT ROW 6.24 COL 2.8
     tglAdmin AT ROW 7.57 COL 3
     tglVisible AT ROW 8.38 COL 3 WIDGET-ID 2
     tglbases AT ROW 9.33 COL 3 WIDGET-ID 4
     filParametres-2 AT ROW 10.52 COL 20 COLON-ALIGNED WIDGET-ID 6
     filParametres-3 AT ROW 11.71 COL 20 COLON-ALIGNED WIDGET-ID 8
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3 ROW 1.24
         SIZE 52 BY 13.1
         TITLE "Informations sur le module".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* REPARENT FRAME */
ASSIGN FRAME frmModule:FRAME = FRAME frmSaisie:HANDLE.

/* SETTINGS FOR FRAME frmModule
                                                                        */
ASSIGN 
       FRAME frmModule:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN filParametres IN FRAME frmModule
   ALIGN-L                                                              */
/* SETTINGS FOR DIALOG-BOX frmSaisie
   FRAME-NAME                                                           */

DEFINE VARIABLE XXTABVALXX AS LOGICAL NO-UNDO.

ASSIGN XXTABVALXX = FRAME frmModule:MOVE-BEFORE-TAB-ITEM (Btn_Cancel:HANDLE IN FRAME frmSaisie)
/* END-ASSIGN-TABS */.

ASSIGN 
       FRAME frmSaisie:SCROLLABLE       = FALSE
       FRAME frmSaisie:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME frmSaisie
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL frmSaisie frmSaisie
ON WINDOW-CLOSE OF FRAME frmSaisie /* Saisie... */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_Cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_Cancel frmSaisie
ON CHOOSE OF Btn_Cancel IN FRAME frmSaisie /* Abandon */
DO:
  cParametres-io = "".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_OK frmSaisie
ON CHOOSE OF Btn_OK IN FRAME frmSaisie /* Validation */
DO:
    DO WITH FRAME frmmodule :
    cParametres-io = ""
        + filcode:SCREEN-VALUE
        + "|" + filnom:SCREEN-VALUE
        + "|" + (IF tgllancement:CHECKED THEN "X" ELSE "")
        + "|" + filParametres:SCREEN-VALUE
        + "|" + filProgramme:SCREEN-VALUE
        + "|" + (IF tgladmin:CHECKED THEN "X" ELSE "")
        + "|" + (IF tglVisible:CHECKED THEN "X" ELSE "")
        + "|" + (IF tglbases:CHECKED THEN "X" ELSE "")
        + "|" + (IF filParametres-2:SCREEN-VALUE <> "" THEN filParametres-2:SCREEN-VALUE ELSE "0")
        + "|" + filParametres-3
        .
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frmModule
&Scoped-define SELF-NAME filCode
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filCode frmSaisie
ON LEAVE OF filCode IN FRAME frmModule /* Code du module */
DO:
    RUN StockeValeur(1,SELF:SCREEN-VALUE).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filNom
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filNom frmSaisie
ON LEAVE OF filNom IN FRAME frmModule /* Libellé du module */
DO:
  
    RUN StockeValeur(2,SELF:SCREEN-VALUE).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filParametres
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filParametres frmSaisie
ON LEAVE OF filParametres IN FRAME frmModule /* Paramètres du module */
DO:
  
    RUN StockeValeur(4,SELF:SCREEN-VALUE).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filParametres-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filParametres-2 frmSaisie
ON LEAVE OF filParametres-2 IN FRAME frmModule /* Niveau du module */
DO:
  
    RUN StockeValeur(4,SELF:SCREEN-VALUE).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filParametres-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filParametres-3 frmSaisie
ON LEAVE OF filParametres-3 IN FRAME frmModule /* Groupe du module */
DO:
  
    RUN StockeValeur(4,SELF:SCREEN-VALUE).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filProgramme
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filProgramme frmSaisie
ON LEAVE OF filProgramme IN FRAME frmModule /* Programme du module */
DO:
  
    RUN StockeValeur(5,SELF:SCREEN-VALUE).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglAdmin
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglAdmin frmSaisie
ON VALUE-CHANGED OF tglAdmin IN FRAME frmModule /* Module résérvé au mode administrateur */
DO:
      RUN StockeValeur(6,(IF SELF:CHECKED THEN "X" ELSE "")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglbases
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglbases frmSaisie
ON VALUE-CHANGED OF tglbases IN FRAME frmModule /* Bases (module nécessitant une connexion) */
DO:
      RUN StockeValeur(7,(IF SELF:CHECKED THEN "X" ELSE "")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglLancement
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglLancement frmSaisie
ON VALUE-CHANGED OF tglLancement IN FRAME frmModule /* Lancer le module au démarrage de l'application */
DO:
      RUN StockeValeur(3,(IF SELF:CHECKED THEN "X" ELSE "")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglVisible
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglVisible frmSaisie
ON VALUE-CHANGED OF tglVisible IN FRAME frmModule /* Module Visible */
DO:
      RUN StockeValeur(7,(IF SELF:CHECKED THEN "X" ELSE "")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frmSaisie
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK frmSaisie 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  RUN Initialisation.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI frmSaisie  _DEFAULT-DISABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide 
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Hide all frames. */
  HIDE FRAME frmModule.
  HIDE FRAME frmSaisie.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI frmSaisie  _DEFAULT-ENABLE
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
  ENABLE Btn_Cancel Btn_OK 
      WITH FRAME frmSaisie.
  VIEW FRAME frmSaisie.
  {&OPEN-BROWSERS-IN-QUERY-frmSaisie}
  DISPLAY filCode filNom tglLancement filProgramme filParametres tglAdmin 
          tglVisible tglbases filParametres-2 filParametres-3 
      WITH FRAME frmModule.
  ENABLE filCode filNom tglLancement filProgramme filParametres tglAdmin 
         tglVisible tglbases filParametres-2 filParametres-3 
      WITH FRAME frmModule.
  VIEW FRAME frmModule.
  {&OPEN-BROWSERS-IN-QUERY-frmModule}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Initialisation frmSaisie 
PROCEDURE Initialisation :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    RUN VALUE("Saisie" + cModule-in).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE SaisieModule frmSaisie 
PROCEDURE SaisieModule :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    VIEW FRAME frmModule.

    /* Affichage des valeurs courantes */
    IF cParametres-io <> "" THEN DO WITH FRAME frmModule:
        filCode:SCREEN-VALUE = ENTRY(1,cParametres-io,"|").    
        filNom:SCREEN-VALUE = ENTRY(2,cParametres-io,"|").    
        tglLancement:CHECKED = (IF ENTRY(3,cParametres-io,"|") = "X" THEN TRUE ELSE FALSE).    
        filParametres:SCREEN-VALUE = ENTRY(4,cParametres-io,"|").    
        filProgramme:SCREEN-VALUE = ENTRY(5,cParametres-io,"|").    
        tglAdmin:CHECKED = (IF ENTRY(6,cParametres-io,"|") = "X" THEN TRUE ELSE FALSE).    
        tglVisible:CHECKED = (IF ENTRY(7,cParametres-io,"|") = "X" THEN TRUE ELSE FALSE).    
        tglbases:CHECKED = (IF ENTRY(8,cParametres-io,"|") = "X" THEN TRUE ELSE FALSE).    
        filParametres-2:SCREEN-VALUE = ENTRY(9,cParametres-io,"|").
        filParametres-3:SCREEN-VALUE = ENTRY(10,cParametres-io,"|").
    END.
    

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE StockeValeur frmSaisie 
PROCEDURE StockeValeur :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER  iPosition-in   AS INTEGER  NO-UNDO.
    DEFINE INPUT PARAMETER  cValeur-in     AS CHARACTER    NO-UNDO.

    entry(iPosition-in,cParametres-io,"|") = cValeur-in.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

