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

    DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lRepercution AS LOGICAL NO-UNDO INIT FALSE.

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

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_Cancel AUTO-GO 
     LABEL "Retour" 
     SIZE 45 BY 1.14
     BGCOLOR 8 .

DEFINE BUTTON Btn_PrefsGenerales 
     LABEL "Préférences générales" 
     SIZE 31 BY 1.14
     BGCOLOR 8 .

DEFINE BUTTON btnReinitAbsences 
     LABEL "Réinitialiser le flag d'avertissement quotidien des absences" 
     SIZE 72 BY .95.

DEFINE VARIABLE cmbPresentation AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS COMBO-BOX INNER-LINES 2
     LIST-ITEM-PAIRS "Mode = Journée/Matin/Après-midi : ~{Nom (Date - Type)~}","1",
                     "Date : ~{Nom ([Mode = Matin/Après-midi] - Type)~}","2"
     DROP-DOWN-LIST
     SIZE 71 BY 1 NO-UNDO.

DEFINE VARIABLE EDITOR-1 AS CHARACTER INITIAL "Remarque : si vous activez une des deux préférences ci-dessus, vous serez prévenu(e) au démarrage de menudev2, ou une fois en début de journée si menudev2 est en cours d'utilisation" 
     VIEW-AS EDITOR NO-BOX
     SIZE 73 BY 1.91
     FGCOLOR 2  NO-UNDO.

DEFINE VARIABLE filNombreJours AS INTEGER FORMAT ">9":U INITIAL 0 
     LABEL "Afficher les absences futures signalées sur une période de" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .95 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 75 BY 3.1.

DEFINE VARIABLE tglPasAlerteWE AS LOGICAL INITIAL no 
     LABEL "Pas d'avertissement le Week-end" 
     VIEW-AS TOGGLE-BOX
     SIZE 38 BY .95 NO-UNDO.

DEFINE VARIABLE tglPasWE AS LOGICAL INITIAL no 
     LABEL "Ne pas afficher les Week-end dans la liste" 
     VIEW-AS TOGGLE-BOX
     SIZE 65 BY .95 NO-UNDO.

DEFINE VARIABLE tglPrevenirFutures AS LOGICAL INITIAL no 
     LABEL "Etre prévenu des absences futures au lancement de menudev2" 
     VIEW-AS TOGGLE-BOX
     SIZE 65 BY 1.19 NO-UNDO.

DEFINE VARIABLE tglPrevenirJour AS LOGICAL INITIAL no 
     LABEL "Etre prévenu des absences du jour au lancement de menudev2" 
     VIEW-AS TOGGLE-BOX
     SIZE 65 BY 1.19 NO-UNDO.

DEFINE VARIABLE tglPrevenirNouvelle AS LOGICAL INITIAL no 
     LABEL "Etre prévenu des nouvelles absences saisies en cours de journée" 
     VIEW-AS TOGGLE-BOX
     SIZE 65 BY 1.19 NO-UNDO.

DEFINE VARIABLE tglPrevenirNouvelleDeSuite AS LOGICAL INITIAL no 
     LABEL "Etre prévenu immédiatement (Sinon, à l'heure suivante)" 
     VIEW-AS TOGGLE-BOX
     SIZE 64 BY 1.19 NO-UNDO.

DEFINE VARIABLE tglUneParLigne AS LOGICAL INITIAL no 
     LABEL "Une absence par ligne" 
     VIEW-AS TOGGLE-BOX
     SIZE 27 BY .95 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME frmPrefs
     Btn_PrefsGenerales AT ROW 18.14 COL 3 WIDGET-ID 2
     Btn_Cancel AT ROW 18.14 COL 35
     SPACE(1.79) SKIP(0.28)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Préférences xxx".

DEFINE FRAME frmModule
     filNombreJours AT ROW 1.24 COL 57 COLON-ALIGNED WIDGET-ID 12
     tglPasWE AT ROW 2.43 COL 3 WIDGET-ID 26
     tglPrevenirJour AT ROW 3.62 COL 3
     tglPrevenirFutures AT ROW 4.81 COL 3 WIDGET-ID 10
     EDITOR-1 AT ROW 6 COL 3 NO-LABEL WIDGET-ID 18
     tglPasAlerteWE AT ROW 8.14 COL 3 WIDGET-ID 38
     tglPrevenirNouvelle AT ROW 9.33 COL 3 WIDGET-ID 22
     tglPrevenirNouvelleDeSuite AT ROW 10.29 COL 11 WIDGET-ID 24
     cmbPresentation AT ROW 12.91 COL 4 NO-LABEL WIDGET-ID 28
     tglUneParLigne AT ROW 14.1 COL 4 WIDGET-ID 30
     btnReinitAbsences AT ROW 15.52 COL 3 WIDGET-ID 20
     "Présentation des Absences :" VIEW-AS TEXT
          SIZE 29 BY .95 AT ROW 11.71 COL 3 WIDGET-ID 32
     "jour(s)" VIEW-AS TEXT
          SIZE 8 BY .95 AT ROW 1.24 COL 65 WIDGET-ID 14
     RECT-1 AT ROW 12.19 COL 2 WIDGET-ID 34
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3 ROW 1.24
         SIZE 77 BY 16.67
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

/* SETTINGS FOR COMBO-BOX cmbPresentation IN FRAME frmModule
   ALIGN-L                                                              */
/* SETTINGS FOR DIALOG-BOX frmPrefs
   FRAME-NAME                                                           */

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


&Scoped-define FRAME-NAME frmModule
&Scoped-define SELF-NAME btnReinitAbsences
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnReinitAbsences frmPrefs
ON CHOOSE OF btnReinitAbsences IN FRAME frmModule /* Réinitialiser le flag d'avertissement quotidien des absences */
DO:
    gSauvePreference("PREF-ABSENCES-PREVENU","").
    gSupprimePreference("ABSENCES-SIGNALEES-*").
    RUN gAfficheMessageTemporaire("Absences","Flag réinitialisé !",FALSE,1,"OK","",FALSE,OUTPUT cRetour).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frmPrefs
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
&Scoped-define SELF-NAME cmbPresentation
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cmbPresentation frmPrefs
ON VALUE-CHANGED OF cmbPresentation IN FRAME frmModule
DO:
  
    gSauvePreference("PREFS-ABSENCES-PRESENTATION",cmbPresentation:SCREEN-VALUE).
    lRepercution = TRUE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filNombreJours
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filNombreJours frmPrefs
ON LEAVE OF filNombreJours IN FRAME frmModule /* Afficher les absences futures signalées sur une période de */
DO:
    gSauvePreference("PREFS-ABSENCES-JOURS",SELF:SCREEN-VALUE).
    lRepercution = TRUE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglPasAlerteWE
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglPasAlerteWE frmPrefs
ON VALUE-CHANGED OF tglPasAlerteWE IN FRAME frmModule /* Pas d'avertissement le Week-end */
DO:
    gSauvePreference("PREFS-ABSENCES-PAS-AVERTISSEMENT-WE",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
    lRepercution = TRUE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglPasWE
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglPasWE frmPrefs
ON VALUE-CHANGED OF tglPasWE IN FRAME frmModule /* Ne pas afficher les Week-end dans la liste */
DO:
    gSauvePreference("PREFS-ABSENCES-PAS-WE",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
    lRepercution = TRUE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglPrevenirFutures
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglPrevenirFutures frmPrefs
ON VALUE-CHANGED OF tglPrevenirFutures IN FRAME frmModule /* Etre prévenu des absences futures au lancement de menudev2 */
DO:
    gSauvePreference("PREFS-ABSENCES-FUTURES-PREVENIR",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglPrevenirJour
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglPrevenirJour frmPrefs
ON VALUE-CHANGED OF tglPrevenirJour IN FRAME frmModule /* Etre prévenu des absences du jour au lancement de menudev2 */
DO:
    gSauvePreference("PREFS-ABSENCES-JOUR-PREVENIR",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglPrevenirNouvelle
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglPrevenirNouvelle frmPrefs
ON VALUE-CHANGED OF tglPrevenirNouvelle IN FRAME frmModule /* Etre prévenu des nouvelles absences saisies en cours de journée */
DO:
    gSauvePreference("PREF-ABSENCES-PREVENIR-NOUVELLE",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
    IF not(SELF:CHECKED) THEN tglPrevenirNouvelleDeSuite:CHECKED = FALSE.
    tglPrevenirNouvelleDeSuite:SENSITIVE = SELF:CHECKED.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglPrevenirNouvelleDeSuite
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglPrevenirNouvelleDeSuite frmPrefs
ON VALUE-CHANGED OF tglPrevenirNouvelleDeSuite IN FRAME frmModule /* Etre prévenu immédiatement (Sinon, à l'heure suivante) */
DO:
    gSauvePreference("PREF-ABSENCES-PREVENIR-NOUVELLE-DESUITE",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglUneParLigne
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglUneParLigne frmPrefs
ON VALUE-CHANGED OF tglUneParLigne IN FRAME frmModule /* Une absence par ligne */
DO:
    gSauvePreference("PREFS-ABSENCES-UNE-PAR-LIGNE",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
    lRepercution = TRUE.
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
IF lRepercution THEN RUN RepercuteSurModules.

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
  VIEW FRAME frmPrefs.
  {&OPEN-BROWSERS-IN-QUERY-frmPrefs}
  DISPLAY filNombreJours tglPasWE tglPrevenirJour tglPrevenirFutures EDITOR-1 
          tglPasAlerteWE tglPrevenirNouvelle tglPrevenirNouvelleDeSuite 
          cmbPresentation tglUneParLigne 
      WITH FRAME frmModule.
  ENABLE RECT-1 filNombreJours tglPasWE tglPrevenirJour tglPrevenirFutures 
         EDITOR-1 tglPasAlerteWE tglPrevenirNouvelle tglPrevenirNouvelleDeSuite 
         cmbPresentation tglUneParLigne btnReinitAbsences 
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
        tglPrevenirJour:CHECKED = (IF gDonnePreference("PREFS-ABSENCES-JOUR-PREVENIR") = "OUI" THEN TRUE ELSE FALSE).
        tglPrevenirFutures:CHECKED = (IF gDonnePreference("PREFS-ABSENCES-FUTURES-PREVENIR") = "OUI" THEN TRUE ELSE FALSE).
        filNombreJours:SCREEN-VALUE = gDonnePreference("PREFS-ABSENCES-JOURS").
        tglPrevenirNouvelle:CHECKED = (IF gDonnePreference("PREF-ABSENCES-PREVENIR-NOUVELLE") = "OUI" THEN TRUE ELSE FALSE).
        tglPrevenirNouvelleDeSuite:CHECKED = (IF gDonnePreference("PREF-ABSENCES-PREVENIR-NOUVELLE-DESUITE") = "OUI" THEN TRUE ELSE FALSE).
        tglPasWE:CHECKED = (IF gDonnePreference("PREFS-ABSENCES-PAS-WE") = "OUI" THEN TRUE ELSE FALSE).
        tglUneParLigne:CHECKED = (IF gDonnePreference("PREFS-ABSENCES-UNE-PAR-LIGNE") = "OUI" THEN TRUE ELSE FALSE).
        tglPasAlerteWE:CHECKED = (IF gDonnePreference("PREFS-ABSENCES-PAS-AVERTISSEMENT-WE") = "OUI" THEN TRUE ELSE FALSE).
        cmbPresentation:SCREEN-VALUE = gDonnePreference("PREFS-ABSENCES-PRESENTATION").
        
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE RepercuteSurModules frmPrefs 
PROCEDURE RepercuteSurModules :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
       
       gAddParam("ABSENCES-RECHARGER","OUI").
       gAddParam("ACCUEIL-RECHARGER","OUI").
       

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

