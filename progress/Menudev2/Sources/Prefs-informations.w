&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME frmPrefs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS frmPrefs 
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
    DEFINE INPUT PARAMETER cIdentModule-in AS CHARACTER NO-UNDO.

/* Local Variable Definitions ---                                       */

    {includes\i_environnement.i}
    {includes\i_dialogue.i}
    {menudev2\includes\menudev2.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME frmPrefs

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_PrefsGenerales Btn_Cancel 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */
&Scoped-define List-6 frmPrefs 

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_Cancel AUTO-GO 
     LABEL "Retour" 
     SIZE 49 BY 1.14
     BGCOLOR 8 .

DEFINE BUTTON Btn_PrefsGenerales 
     LABEL "Préférences générales" 
     SIZE 31 BY 1.14
     BGCOLOR 8 .

DEFINE VARIABLE filJoursMessages AS CHARACTER FORMAT "99":U 
     LABEL "Afficher les messages reçus et/ou envoyés depuis" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 5 BY .95 NO-UNDO.

DEFINE VARIABLE tglDernierIncorporation AS LOGICAL INITIAL no 
     LABEL "Ne conserver que le dernier message d'incorporation des sources (DEV)" 
     VIEW-AS TOGGLE-BOX
     SIZE 76.6 BY .95 NO-UNDO.

DEFINE VARIABLE tglDernierMessage AS LOGICAL INITIAL no 
     LABEL "Toujours se positionner sur le dernier messge à l'entrée dans le module" 
     VIEW-AS TOGGLE-BOX
     SIZE 76.6 BY .95 NO-UNDO.

DEFINE VARIABLE tglTriDecroissant AS LOGICAL INITIAL no 
     LABEL "Trier la liste des messages du message le plus recent au plus vieux par défaut" 
     VIEW-AS TOGGLE-BOX
     SIZE 76.6 BY .95 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME frmPrefs
     Btn_PrefsGenerales AT ROW 8.38 COL 3 WIDGET-ID 2
     Btn_Cancel AT ROW 8.38 COL 35
     SPACE(1.79) SKIP(0.38)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Préférences xxx".

DEFINE FRAME frmModule
     filJoursMessages AT ROW 1.24 COL 50 COLON-ALIGNED WIDGET-ID 330
     tglTriDecroissant AT ROW 2.43 COL 3 WIDGET-ID 336
     tglDernierIncorporation AT ROW 3.86 COL 3 WIDGET-ID 338
     tglDernierMessage AT ROW 5.29 COL 3 WIDGET-ID 334
     "jours" VIEW-AS TEXT
          SIZE 7 BY .95 AT ROW 1.24 COL 58 WIDGET-ID 332
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3 ROW 1.24
         SIZE 81 BY 6.91
         TITLE "Préférences du module : xxx".


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
ASSIGN FRAME frmModule:FRAME = FRAME frmPrefs:HANDLE.

/* SETTINGS FOR FRAME frmModule
                                                                        */
ASSIGN 
       FRAME frmModule:HIDDEN           = TRUE.

/* SETTINGS FOR DIALOG-BOX frmPrefs
   NOT-VISIBLE FRAME-NAME 6                                             */

DEFINE VARIABLE XXTABVALXX AS LOGICAL NO-UNDO.

ASSIGN XXTABVALXX = FRAME frmModule:MOVE-BEFORE-TAB-ITEM (Btn_PrefsGenerales:HANDLE IN FRAME frmPrefs)
/* END-ASSIGN-TABS */.

ASSIGN 
       FRAME frmPrefs:SCROLLABLE       = FALSE
       FRAME frmPrefs:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME frmPrefs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL frmPrefs frmPrefs
ON WINDOW-CLOSE OF FRAME frmPrefs /* Préférences xxx */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_PrefsGenerales
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_PrefsGenerales frmPrefs
ON CHOOSE OF Btn_PrefsGenerales IN FRAME frmPrefs /* Préférences générales */
DO:
  RUN DonneOrdre("PREFS-GENERALES").
  APPLY "CHOOSE" TO Btn_Cancel.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frmModule
&Scoped-define SELF-NAME filJoursMessages
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filJoursMessages frmPrefs
ON LEAVE OF filJoursMessages IN FRAME frmModule /* Afficher les messages reçus et/ou envoyés depuis */
DO:
      gSauvePreference("INFOS-JOURS-MAX",SELF:SCREEN-VALUE).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglDernierIncorporation
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglDernierIncorporation frmPrefs
ON VALUE-CHANGED OF tglDernierIncorporation IN FRAME frmModule /* Ne conserver que le dernier message d'incorporation des sources (DEV) */
DO:
    gSauvePreference("PREF-MESSAGES-DERNIER-INCORPORATION",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglDernierMessage
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglDernierMessage frmPrefs
ON VALUE-CHANGED OF tglDernierMessage IN FRAME frmModule /* Toujours se positionner sur le dernier messge à l'entrée dans le module */
DO:
    gSauvePreference("PREF-MESSAGES-DERNIER",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglTriDecroissant
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglTriDecroissant frmPrefs
ON VALUE-CHANGED OF tglTriDecroissant IN FRAME frmModule /* Trier la liste des messages du message le plus recent au plus vieux par défaut */
DO:
    gSauvePreference("PREF-MESSAGES-DECROISSANT",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frmPrefs
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK frmPrefs 


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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI frmPrefs  _DEFAULT-DISABLE
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
  HIDE FRAME frmPrefs.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE DonneOrdre frmPrefs 
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI frmPrefs  _DEFAULT-ENABLE
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
  ENABLE Btn_PrefsGenerales Btn_Cancel 
      WITH FRAME frmPrefs.
  {&OPEN-BROWSERS-IN-QUERY-frmPrefs}
  DISPLAY filJoursMessages tglTriDecroissant tglDernierIncorporation 
          tglDernierMessage 
      WITH FRAME frmModule.
  ENABLE filJoursMessages tglTriDecroissant tglDernierIncorporation 
         tglDernierMessage 
      WITH FRAME frmModule.
  VIEW FRAME frmModule.
  {&OPEN-BROWSERS-IN-QUERY-frmModule}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Initialisation frmPrefs 
PROCEDURE Initialisation :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    FRAME frmPrefs:TITLE = "Préférences " + gDonneNomModule(cIdentModule-in).
    FRAME frmModule:TITLE = "Préférences du module : " + gDonneNomModule(cIdentModule-in).

    DO WITH FRAME frmModule:
        filJoursMessages:SCREEN-VALUE = gDonnePreference("INFOS-JOURS-MAX").
        tglTriDecroissant:CHECKED = (IF gDonnePreference("PREF-MESSAGES-DECROISSANT") = "OUI" THEN TRUE ELSE FALSE).
        tglDernierIncorporation:CHECKED = (IF gDonnePreference("PREF-MESSAGES-DERNIER-INCORPORATION") = "OUI" THEN TRUE ELSE FALSE).
        tglDernierMessage:CHECKED = (IF gDonnePreference("PREF-MESSAGES-DERNIER") = "OUI" THEN TRUE ELSE FALSE).
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

