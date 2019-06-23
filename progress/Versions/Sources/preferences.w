&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME winPreferences
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS winPreferences 
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
/* Local Variable Definitions ---                                       */


CREATE WIDGET-POOL.
IF NOT(PROPATH MATCHES("*" + OS-GETENV("DLC") + "\src*")) THEN DO:
    PROPATH = PROPATH + "," + OS-GETENV("DLC") + "\src".
END.

/* ***************************  Definitions  ************************** */
{includes\i_environnement.i NEW GLOBAL}
{includes\i_api.i NEW}
{includes\i_son.i}
{versions\includes\versions.i NEW}


/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

    DEFINE VARIABLE lModificationsAutorisees AS LOGICAL NO-UNDO INIT TRUE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME frmFond

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS tglSortie tglWord tglControle tglHebdo ~
tgldev tgltest tglclient tglGestion tglPME tglHref tglHvid tgluref tgluvid 
&Scoped-Define DISPLAYED-OBJECTS tglSortie tglWord tglControle tglHebdo ~
tgldev tgltest tglclient tglGestion tglPME tglHref tglHvid tgluref tgluvid 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR winPreferences AS WIDGET-HANDLE NO-UNDO.

/* Menu Definitions                                                     */
DEFINE MENU MENU-BAR-winMontageVersion MENUBAR
       MENU-ITEM m_item         LABEL "?"             .


/* Definitions of the field level widgets                               */
DEFINE BUTTON btnQuitter 
     LABEL "X" 
     SIZE 8 BY 1.91 TOOLTIP "Quitter".

DEFINE VARIABLE tglclient AS LOGICAL INITIAL no 
     LABEL "Client" 
     VIEW-AS TOGGLE-BOX
     SIZE 10 BY .95 NO-UNDO.

DEFINE VARIABLE tglControle AS LOGICAL INITIAL no 
     LABEL "Contrôler la présences des moulinettes à la création du fichier de montage" 
     VIEW-AS TOGGLE-BOX
     SIZE 75 BY .95 NO-UNDO.

DEFINE VARIABLE tgldev AS LOGICAL INITIAL no 
     LABEL "DEV" 
     VIEW-AS TOGGLE-BOX
     SIZE 13 BY .95 NO-UNDO.

DEFINE VARIABLE tglGestion AS LOGICAL INITIAL no 
     LABEL "Gestion" 
     VIEW-AS TOGGLE-BOX
     SIZE 13 BY .95 NO-UNDO.

DEFINE VARIABLE tglHebdo AS LOGICAL INITIAL no 
     LABEL "Génération automatique de la version hebdomadaire" 
     VIEW-AS TOGGLE-BOX
     SIZE 71 BY .95 NO-UNDO.

DEFINE VARIABLE tglHref AS LOGICAL INITIAL no 
     LABEL "HRef" 
     VIEW-AS TOGGLE-BOX
     SIZE 10 BY .95 NO-UNDO.

DEFINE VARIABLE tglHvid AS LOGICAL INITIAL no 
     LABEL "HVid" 
     VIEW-AS TOGGLE-BOX
     SIZE 9 BY .95 NO-UNDO.

DEFINE VARIABLE tglPME AS LOGICAL INITIAL no 
     LABEL "Pme" 
     VIEW-AS TOGGLE-BOX
     SIZE 9 BY .95 NO-UNDO.

DEFINE VARIABLE tglSortie AS LOGICAL INITIAL no 
     LABEL "Demander confirmation lors de la sortie de la gestion des versions MaGI" 
     VIEW-AS TOGGLE-BOX
     SIZE 75 BY .95 NO-UNDO.

DEFINE VARIABLE tgltest AS LOGICAL INITIAL no 
     LABEL "Test" 
     VIEW-AS TOGGLE-BOX
     SIZE 9 BY .95 NO-UNDO.

DEFINE VARIABLE tgluref AS LOGICAL INITIAL no 
     LABEL "URef" 
     VIEW-AS TOGGLE-BOX
     SIZE 11 BY .95 NO-UNDO.

DEFINE VARIABLE tgluvid AS LOGICAL INITIAL no 
     LABEL "UVid" 
     VIEW-AS TOGGLE-BOX
     SIZE 9 BY .95 NO-UNDO.

DEFINE VARIABLE tglWord AS LOGICAL INITIAL no 
     LABEL "Passer par Word pour les éditions" 
     VIEW-AS TOGGLE-BOX
     SIZE 67.6 BY .95 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME frmFond
     tglSortie AT ROW 3.38 COL 2 WIDGET-ID 28
     tglWord AT ROW 4.33 COL 2 WIDGET-ID 30
     tglControle AT ROW 5.29 COL 2 WIDGET-ID 38
     tglHebdo AT ROW 6.24 COL 2 WIDGET-ID 36
     tgldev AT ROW 8.38 COL 2 WIDGET-ID 62
     tgltest AT ROW 8.38 COL 15 WIDGET-ID 68
     tglclient AT ROW 8.38 COL 26 WIDGET-ID 64
     tglGestion AT ROW 10.29 COL 2 WIDGET-ID 40
     tglPME AT ROW 10.29 COL 15 WIDGET-ID 58
     tglHref AT ROW 10.29 COL 26 WIDGET-ID 56
     tglHvid AT ROW 10.29 COL 36 WIDGET-ID 54
     tgluref AT ROW 10.29 COL 45 WIDGET-ID 52
     tgluvid AT ROW 10.29 COL 56 WIDGET-ID 50
     "Valeurs par défaut des toggles lors de la saisie des versions" VIEW-AS TEXT
          SIZE 61 BY .95 AT ROW 7.43 COL 2 WIDGET-ID 60
     "Valeurs par défaut des toggles lors de la saisie des moulinettes" VIEW-AS TEXT
          SIZE 61 BY .95 AT ROW 9.33 COL 2 WIDGET-ID 42
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 77.8 BY 11.71 WIDGET-ID 100.

DEFINE FRAME frmBoutons
     btnQuitter AT ROW 1.05 COL 1.2 WIDGET-ID 2
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1.1
         SIZE 77 BY 2.1 WIDGET-ID 600.


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
  CREATE WINDOW winPreferences ASSIGN
         HIDDEN             = YES
         TITLE              = "Gestion des version MaGI : Préférences"
         HEIGHT             = 11.81
         WIDTH              = 77.8
         MAX-HEIGHT         = 45.05
         MAX-WIDTH          = 336
         VIRTUAL-HEIGHT     = 45.05
         VIRTUAL-WIDTH      = 336
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

ASSIGN {&WINDOW-NAME}:MENUBAR    = MENU MENU-BAR-winMontageVersion:HANDLE.
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW winPreferences
  VISIBLE,,RUN-PERSISTENT                                               */
/* REPARENT FRAME */
ASSIGN FRAME frmBoutons:FRAME = FRAME frmFond:HANDLE.

/* SETTINGS FOR FRAME frmBoutons
                                                                        */
/* SETTINGS FOR FRAME frmFond
   FRAME-NAME                                                           */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(winPreferences)
THEN winPreferences:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME winPreferences
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL winPreferences winPreferences
ON END-ERROR OF winPreferences /* Gestion des version MaGI : Préférences */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL winPreferences winPreferences
ON WINDOW-CLOSE OF winPreferences /* Gestion des version MaGI : Préférences */
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frmBoutons
&Scoped-define SELF-NAME btnQuitter
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnQuitter winPreferences
ON CHOOSE OF btnQuitter IN FRAME frmBoutons /* X */
DO:
  
    APPLY "CLOSE" TO THIS-PROCEDURE.
    LEAVE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frmFond
&Scoped-define SELF-NAME tglclient
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglclient winPreferences
ON VALUE-CHANGED OF tglclient IN FRAME frmFond /* Client */
DO:
    gSauvePreference("PREF-TGL-CLIENT",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglControle
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglControle winPreferences
ON VALUE-CHANGED OF tglControle IN FRAME frmFond /* Contrôler la présences des moulinettes à la création du fichier de montage */
DO:
    gSauvePreference("PREF-CONTROLEMOULINETTES",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tgldev
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tgldev winPreferences
ON VALUE-CHANGED OF tgldev IN FRAME frmFond /* DEV */
DO:
    gSauvePreference("PREF-TGL-DEV",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglGestion
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglGestion winPreferences
ON VALUE-CHANGED OF tglGestion IN FRAME frmFond /* Gestion */
DO:
    gSauvePreference("PREF-TGL-GESTION",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglHebdo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglHebdo winPreferences
ON VALUE-CHANGED OF tglHebdo IN FRAME frmFond /* Génération automatique de la version hebdomadaire */
DO:
    DEFINE VARIABLE cFichierHebdo AS CHARACTER NO-UNDO.

    gSauvePreference("PREF-HEBDOAUTO",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
    
    /* gestion du fichier de version hebdo pour les autres programmes */
    cFichierHebdo = Reseau + "dev\intf\BloqueVersionHebdo".

    IF SELF:CHECKED THEN DO:
        OS-DELETE VALUE(cFichierHebdo).
    END.
    ELSE DO:
        OUTPUT TO VALUE(cFichierHebdo).
        OUTPUT CLOSE.
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglHref
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglHref winPreferences
ON VALUE-CHANGED OF tglHref IN FRAME frmFond /* HRef */
DO:
    gSauvePreference("PREF-TGL-HREF",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglHvid
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglHvid winPreferences
ON VALUE-CHANGED OF tglHvid IN FRAME frmFond /* HVid */
DO:
    gSauvePreference("PREF-TGL-HVID",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglPME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglPME winPreferences
ON VALUE-CHANGED OF tglPME IN FRAME frmFond /* Pme */
DO:
    gSauvePreference("PREF-TGL-PME",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglSortie
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglSortie winPreferences
ON VALUE-CHANGED OF tglSortie IN FRAME frmFond /* Demander confirmation lors de la sortie de la gestion des versions MaGI */
DO:
    gSauvePreference("PREF-SORTIE",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tgltest
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tgltest winPreferences
ON VALUE-CHANGED OF tgltest IN FRAME frmFond /* Test */
DO:
    gSauvePreference("PREF-TGL-TEST",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tgluref
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tgluref winPreferences
ON VALUE-CHANGED OF tgluref IN FRAME frmFond /* URef */
DO:
    gSauvePreference("PREF-TGL-UREF",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tgluvid
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tgluvid winPreferences
ON VALUE-CHANGED OF tgluvid IN FRAME frmFond /* UVid */
DO:
    gSauvePreference("PREF-TGL-UVID",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglWord
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglWord winPreferences
ON VALUE-CHANGED OF tglWord IN FRAME frmFond /* Passer par Word pour les éditions */
DO:
    gSauvePreference("PREF-EDITIONSWORD",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK winPreferences 


/* ***************************  Main Block  *************************** */


/* Pour les tests */
/*cTests = "AUTO-MUET,11110000,12000000,ADB,PL-Ma_version".*/


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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI winPreferences  _DEFAULT-DISABLE
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
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(winPreferences)
  THEN DELETE WIDGET winPreferences.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI winPreferences  _DEFAULT-ENABLE
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
  DISPLAY tglSortie tglWord tglControle tglHebdo tgldev tgltest tglclient 
          tglGestion tglPME tglHref tglHvid tgluref tgluvid 
      WITH FRAME frmFond IN WINDOW winPreferences.
  ENABLE tglSortie tglWord tglControle tglHebdo tgldev tgltest tglclient 
         tglGestion tglPME tglHref tglHvid tgluref tgluvid 
      WITH FRAME frmFond IN WINDOW winPreferences.
  {&OPEN-BROWSERS-IN-QUERY-frmFond}
  ENABLE btnQuitter 
      WITH FRAME frmBoutons IN WINDOW winPreferences.
  {&OPEN-BROWSERS-IN-QUERY-frmBoutons}
  VIEW winPreferences.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Forcage winPreferences 
PROCEDURE Forcage :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    IF gcRepertoireExecution MATCHES "*sources.dev*" THEN
        gcUtilisateur = gcUtilisateur + ".DEV".
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Initialisation winPreferences 
PROCEDURE Initialisation :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  
  RUN gGereUtilisateurs.
  lModificationsAutorisees = (gcGroupeUtilisateur = "DEV").
  
  /* Gestion des images des boutons */
  DO WITH FRAME frmBoutons:
      btnQuitter:LOAD-IMAGE(gcRepertoireRessourcesPrivees + "sortie.ico").
      btnQuitter:LOAD-IMAGE-INSENSITIVE(gcRepertoireRessourcesPrivees + "sortie-off.ico").
        
  END.

  DO WITH FRAME frmfond:

        tglSortie:CHECKED = (IF gDonnePreference("PREF-SORTIE") = "OUI" THEN TRUE ELSE FALSE).
        tglWord:CHECKED = (IF gDonnePreference("PREF-EDITIONSWORD") = "OUI" THEN TRUE ELSE FALSE).
        tglHebdo:CHECKED = (IF gDonnePreference("PREF-HEBDOAUTO") = "OUI" THEN TRUE ELSE FALSE).
        tglControle:CHECKED = (IF gDonnePreference("PREF-CONTROLEMOULINETTES") = "OUI" THEN TRUE ELSE FALSE).
        tglgestion:CHECKED = (IF gDonnePreference("PREF-TGL-GESTION") = "OUI" THEN TRUE ELSE FALSE).
        tglPME:CHECKED = (IF gDonnePreference("PREF-TGL-PME") = "OUI" THEN TRUE ELSE FALSE).
        tglhref:CHECKED = (IF gDonnePreference("PREF-TGL-HREF") = "OUI" THEN TRUE ELSE FALSE).
        tglhvid:CHECKED = (IF gDonnePreference("PREF-TGL-HVID") = "OUI" THEN TRUE ELSE FALSE).
        tgluref:CHECKED = (IF gDonnePreference("PREF-TGL-UREF") = "OUI" THEN TRUE ELSE FALSE).
        tgluvid:CHECKED = (IF gDonnePreference("PREF-TGL-UVID") = "OUI" THEN TRUE ELSE FALSE).
        tgldev:CHECKED = (IF gDonnePreference("PREF-TGL-DEV") = "OUI" THEN TRUE ELSE FALSE).
        tgltest:CHECKED = (IF gDonnePreference("PREF-TGL-TEST") = "OUI" THEN TRUE ELSE FALSE).
        tglclient:CHECKED = (IF gDonnePreference("PREF-TGL-CLIENT") = "OUI" THEN TRUE ELSE FALSE).

        /* gestion des restrictions */
        IF NOT(lModificationsAutorisees) THEN DO:
            tglSortie:SENSITIVE = FALSE.
            tglHebdo:SENSITIVE = FALSE.
            tglControle:SENSITIVE = FALSE.
            tglgestion:SENSITIVE = FALSE.
            tglPME:SENSITIVE = FALSE.
            tglhref:SENSITIVE = FALSE.
            tglhvid:SENSITIVE = FALSE.
            tgluref:SENSITIVE = FALSE.
            tgluvid:SENSITIVE = FALSE.
            tgldev:SENSITIVE = FALSE.
            tgltest:SENSITIVE = FALSE.
            tglclient:SENSITIVE = FALSE.
        END.
  END.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

