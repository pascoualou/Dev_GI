&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          gidata           PROGRESS
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
    {includes\i_son.i}
    {includes\i_html.i}
{menudev2\includes\menudev2.i}
/*{includes\i_temps.i}*/

/* Parameters Definitions ---                                           */

DEFINE INPUT PARAMETER  winGeneral  AS HANDLE NO-UNDO.
DEFINE INPUT PARAMETER  cParametres AS CHARACTER NO-UNDO.
/* Local Variable Definitions ---                                       */

DEFINE VARIABLE cEtatEncours AS CHARACTER NO-UNDO.
DEFINE VARIABLE cTri AS CHARACTER NO-UNDO INIT "Heure".
    DEFINE VARIABLE riSauve AS ROWID NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME frmModule
&Scoped-define BROWSE-NAME brwAlertes

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES Agenda

/* Definitions for BROWSE brwAlertes                                    */
&Scoped-define FIELDS-IN-QUERY-brwAlertes substring(string(agenda.iHeureDebut,"9999"),1,2) + ":" + substring(string(agenda.iHeureDebut,"9999"),3,2) Agenda.dDate "" + (IF AGENDA.lLundi THEN "L" ELSE " ") + (IF AGENDA.lMardi THEN "M" ELSE " ") + (IF AGENDA.lMercredi THEN "M" ELSE " ") + (IF AGENDA.lJeudi THEN "J" ELSE " ") + (IF AGENDA.lVendredi THEN "V" ELSE " ") + (IF AGENDA.lSamedi THEN "S" ELSE " ") + (IF AGENDA.lDimanche THEN "D" ELSE " ") (IF AGENDA.lWeekEnd THEN " X" ELSE " ") (IF AGENDA.lPeriodique THEN string(AGENDA.iNbPeriode) + " " + DonneUnite(AGENDA.cUnitePeriode) ELSE "") (IF AGENDA.lDelai THEN string(AGENDA.iNbDelai) + " " + DonneUnite(AGENDA.cUniteDelai) ELSE "") Agenda.cLibelle   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brwAlertes Agenda.cLibelle   
&Scoped-define ENABLED-TABLES-IN-QUERY-brwAlertes Agenda
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-brwAlertes Agenda
&Scoped-define SELF-NAME brwAlertes
&Scoped-define QUERY-STRING-brwAlertes FOR EACH Agenda WHERE agenda.cUtilisateur = gcUtilisateur NO-LOCK BY agenda.iHeureDebut BY agenda.ddate INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-brwAlertes OPEN QUERY {&SELF-NAME} FOR EACH Agenda WHERE agenda.cUtilisateur = gcUtilisateur NO-LOCK BY agenda.iHeureDebut BY agenda.ddate INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-brwAlertes Agenda
&Scoped-define FIRST-TABLE-IN-QUERY-brwAlertes Agenda


/* Definitions for FRAME frmModule                                      */
&Scoped-define OPEN-BROWSERS-IN-QUERY-frmModule ~
    ~{&OPEN-QUERY-brwAlertes}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS brwAlertes 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD DonneUnite C-Win 
FUNCTION DonneUnite RETURNS CHARACTER (cCodeUnite-in AS CHARACTER)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON BtnCalendrier  NO-FOCUS
     LABEL "..." 
     SIZE 4 BY .95.

DEFINE BUTTON btnSon  NO-FOCUS
     LABEL ">" 
     SIZE-PIXELS 20 BY 21.

DEFINE BUTTON btnTester  NO-FOCUS
     LABEL "Déclencher l'action maintenant" 
     SIZE 33.4 BY .95.

DEFINE VARIABLE cmbAvertir AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS COMBO-BOX INNER-LINES 6
     LIST-ITEM-PAIRS "-","-",
                     "Heure(s)","H",
                     "Jour(s)","J",
                     "Semaine(s)","S",
                     "Mois","M",
                     "Année(s)","A"
     DROP-DOWN-LIST
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE cmbperiodicite AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS COMBO-BOX INNER-LINES 6
     LIST-ITEM-PAIRS "-","-",
                     "Heure(s)","H",
                     "Jour(s)","J",
                     "Semaine(s)","S",
                     "Mois","M",
                     "Année(s)","A"
     DROP-DOWN-LIST
     SIZE 14.8 BY 1 NO-UNDO.

DEFINE VARIABLE cmbSon AS CHARACTER FORMAT "X(256)":U 
     LABEL "Associer un son à l'action" 
     VIEW-AS COMBO-BOX SORT INNER-LINES 5
     LIST-ITEMS "Item 1" 
     DROP-DOWN-LIST
     SIZE 45.8 BY 1 NO-UNDO.

DEFINE VARIABLE edtTexte AS CHARACTER 
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
     SIZE 148.8 BY 4.14
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE filAction AS CHARACTER FORMAT "X(256)":U 
     LABEL "Programme à lancer" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 136.2 BY .95 NO-UNDO.

DEFINE VARIABLE filHeure AS INTEGER FORMAT "99":U INITIAL 0 
     VIEW-AS FILL-IN NATIVE 
     SIZE 4 BY .95 NO-UNDO.

DEFINE VARIABLE fillDate AS DATE FORMAT "99/99/9999":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 17 BY .95 NO-UNDO.

DEFINE VARIABLE filLibelle AS CHARACTER FORMAT "X(256)":U 
     LABEL "Libellé" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 77.6 BY .95 NO-UNDO.

DEFINE VARIABLE filMinute AS INTEGER FORMAT "99":U INITIAL 0 
     VIEW-AS FILL-IN NATIVE 
     SIZE 4 BY .95 NO-UNDO.

DEFINE VARIABLE filNbAvertir AS INTEGER FORMAT ">9":U INITIAL 0 
     VIEW-AS FILL-IN NATIVE 
     SIZE 4 BY .95 NO-UNDO.

DEFINE VARIABLE filNbPeriodes AS INTEGER FORMAT ">9":U INITIAL 0 
     VIEW-AS FILL-IN NATIVE 
     SIZE 4 BY .95 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 70.6 BY 1.57.

DEFINE VARIABLE tglAction AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 3 BY .95 NO-UNDO.

DEFINE VARIABLE tglActivation AS LOGICAL INITIAL no 
     LABEL "Action activée" 
     VIEW-AS TOGGLE-BOX
     SIZE 20 BY .95 NO-UNDO.

DEFINE VARIABLE tglAvertir AS LOGICAL INITIAL no 
     LABEL "Toggle 3" 
     VIEW-AS TOGGLE-BOX
     SIZE 3 BY .95 NO-UNDO.

DEFINE VARIABLE tglDimanche AS LOGICAL INITIAL no 
     LABEL "Dim" 
     VIEW-AS TOGGLE-BOX
     SIZE 9 BY .95 NO-UNDO.

DEFINE VARIABLE tglJeudi AS LOGICAL INITIAL no 
     LABEL "Jeu" 
     VIEW-AS TOGGLE-BOX
     SIZE 8 BY .95 NO-UNDO.

DEFINE VARIABLE tglJours AS LOGICAL INITIAL no 
     LABEL "Ne déclencher l'action que si l'on est un..." 
     VIEW-AS TOGGLE-BOX
     SIZE 42.8 BY .81 NO-UNDO.

DEFINE VARIABLE tglLundi AS LOGICAL INITIAL no 
     LABEL "Lun" 
     VIEW-AS TOGGLE-BOX
     SIZE 9 BY .95 NO-UNDO.

DEFINE VARIABLE tglMardi AS LOGICAL INITIAL no 
     LABEL "Mar" 
     VIEW-AS TOGGLE-BOX
     SIZE 7.2 BY .95 NO-UNDO.

DEFINE VARIABLE tglMercredi AS LOGICAL INITIAL no 
     LABEL "Mer" 
     VIEW-AS TOGGLE-BOX
     SIZE 7.8 BY .95 NO-UNDO.

DEFINE VARIABLE tglPeriodicite AS LOGICAL INITIAL no 
     LABEL "Toggle 2" 
     VIEW-AS TOGGLE-BOX
     SIZE 3 BY .95 NO-UNDO.

DEFINE VARIABLE tglSamedi AS LOGICAL INITIAL no 
     LABEL "Sam" 
     VIEW-AS TOGGLE-BOX
     SIZE 8 BY .95 NO-UNDO.

DEFINE VARIABLE tglVendredi AS LOGICAL INITIAL no 
     LABEL "Ven" 
     VIEW-AS TOGGLE-BOX
     SIZE 8.4 BY .95 NO-UNDO.

DEFINE VARIABLE tglWeekend AS LOGICAL INITIAL no 
     LABEL "Ne pas déclencher le Week-End" 
     VIEW-AS TOGGLE-BOX
     SIZE 36 BY .95 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brwAlertes FOR 
      Agenda SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brwAlertes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brwAlertes C-Win _FREEFORM
  QUERY brwAlertes NO-LOCK DISPLAY
      substring(string(agenda.iHeureDebut,"9999"),1,2) + ":" + substring(string(agenda.iHeureDebut,"9999"),3,2) COLUMN-LABEL "Heure" FORMAT "X(6)":U
      
      Agenda.dDate FORMAT "99/99/9999":U WIDTH 12.2

      ""
      + (IF AGENDA.lLundi THEN "L" ELSE " ")
      + (IF AGENDA.lMardi  THEN "M" ELSE " ")
      + (IF AGENDA.lMercredi THEN "M" ELSE " ") 
      + (IF AGENDA.lJeudi  THEN "J" ELSE " ")
      + (IF AGENDA.lVendredi  THEN "V" ELSE " ")
      + (IF AGENDA.lSamedi THEN "S" ELSE " ") 
      + (IF AGENDA.lDimanche THEN "D" ELSE " ")
           COLUMN-LABEL "Jours" FORMAT "X(10)":U

      (IF AGENDA.lWeekEnd THEN "     X" ELSE "      ")  COLUMN-LABEL "Sauf WE" FORMAT "X(7)":U

      (IF AGENDA.lPeriodique THEN string(AGENDA.iNbPeriode) + " " + DonneUnite(AGENDA.cUnitePeriode)  ELSE "") COLUMN-LABEL "Périodicité" FORMAT "X(14)":U
    
      (IF AGENDA.lDelai THEN string(AGENDA.iNbDelai) + " " + DonneUnite(AGENDA.cUniteDelai) ELSE "") COLUMN-LABEL "Anticipation" FORMAT "X(14)":U
       
      Agenda.cLibelle FORMAT "X(70)":U

          ENABLE Agenda.cLibelle
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 164 BY 7.86
         BGCOLOR 15 
         TITLE BGCOLOR 15 "Liste des actions planifiées" ROW-HEIGHT-CHARS .6 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME frmModule
     brwAlertes AT ROW 1.24 COL 2
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 166.2 BY 20.57
         BGCOLOR 7 
         TITLE BGCOLOR 2 FGCOLOR 15 "Planificateur".

DEFINE FRAME frmDetail
     BtnCalendrier AT ROW 1.24 COL 50
     btnSon AT Y 189 X 616
     btnTester AT ROW 10.05 COL 129.6
     filHeure AT ROW 1.24 COL 8 COLON-ALIGNED NO-LABEL
     filMinute AT ROW 1.24 COL 14 COLON-ALIGNED NO-LABEL
     fillDate AT ROW 1.24 COL 31 COLON-ALIGNED NO-LABEL
     filLibelle AT ROW 1.24 COL 60.4 COLON-ALIGNED
     tglActivation AT ROW 1.24 COL 143 WIDGET-ID 2
     edtTexte AT ROW 2.43 COL 14 NO-LABEL
     filAction AT ROW 6.71 COL 25 COLON-ALIGNED
     tglAction AT ROW 6.81 COL 3
     tglJours AT ROW 7.81 COL 54.8
     filNbAvertir AT ROW 8.1 COL 25.2 COLON-ALIGNED NO-LABEL
     cmbAvertir AT ROW 8.1 COL 29.6 COLON-ALIGNED NO-LABEL
     tglAvertir AT ROW 8.19 COL 3
     tglWeekend AT ROW 8.33 COL 125.8
     tglLundi AT ROW 8.57 COL 58.2
     tglMardi AT ROW 8.57 COL 68.6
     tglMercredi AT ROW 8.57 COL 77.4
     tglJeudi AT ROW 8.57 COL 86.4
     tglVendredi AT ROW 8.57 COL 95
     tglSamedi AT ROW 8.57 COL 104.8
     tglDimanche AT ROW 8.57 COL 113.2
     tglPeriodicite AT ROW 9.76 COL 3
     filNbPeriodes AT ROW 9.81 COL 28 COLON-ALIGNED NO-LABEL
     cmbperiodicite AT ROW 9.81 COL 32.2 COLON-ALIGNED NO-LABEL
     cmbSon AT ROW 10 COL 76.4 COLON-ALIGNED
     "h" VIEW-AS TEXT
          SIZE 2 BY .95 AT ROW 1.24 COL 14
     "Avertir / Déclencher" VIEW-AS TEXT
          SIZE 20 BY .95 AT ROW 8.19 COL 7
     "avant" VIEW-AS TEXT
          SIZE 6.2 BY .95 AT ROW 8.14 COL 46
     "Avec une périodicité de" VIEW-AS TEXT
          SIZE 23.2 BY .95 AT ROW 9.81 COL 6.8
     "Message :" VIEW-AS TEXT
          SIZE 11 BY .95 AT ROW 2.43 COL 2.8
     "Heure :" VIEW-AS TEXT
          SIZE 7 BY .95 AT ROW 1.24 COL 3
     "Date :" VIEW-AS TEXT
          SIZE 6 BY .95 AT ROW 1.24 COL 26
     "m" VIEW-AS TEXT
          SIZE 2 BY .95 AT ROW 1.24 COL 20
     RECT-1 AT ROW 8.14 COL 53.4
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 2 ROW 9.33
         SIZE 164 BY 11.19
         TITLE "Détail de l'action planifiée sélectionnée".


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
  NOT-VISIBLE,,RUN-PERSISTENT                                           */
/* REPARENT FRAME */
ASSIGN FRAME frmDetail:FRAME = FRAME frmModule:HANDLE.

/* SETTINGS FOR FRAME frmDetail
                                                                        */
/* SETTINGS FOR FRAME frmModule
   FRAME-NAME                                                           */

DEFINE VARIABLE XXTABVALXX AS LOGICAL NO-UNDO.

ASSIGN XXTABVALXX = FRAME frmDetail:MOVE-AFTER-TAB-ITEM (brwAlertes:HANDLE IN FRAME frmModule)
/* END-ASSIGN-TABS */.

/* BROWSE-TAB brwAlertes 1 frmModule */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brwAlertes
/* Query rebuild information for BROWSE brwAlertes
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH Agenda WHERE agenda.cUtilisateur = gcUtilisateur NO-LOCK BY agenda.iHeureDebut BY agenda.ddate INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE brwAlertes */
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


&Scoped-define BROWSE-NAME brwAlertes
&Scoped-define SELF-NAME brwAlertes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwAlertes C-Win
ON DEFAULT-ACTION OF brwAlertes IN FRAME frmModule /* Liste des actions planifiées */
DO:
  /**/
  RUN DonneOrdre("MODIFIER").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwAlertes C-Win
ON ROW-DISPLAY OF brwAlertes IN FRAME frmModule /* Liste des actions planifiées */
DO:
    Agenda.cLibelle:BGCOLOR IN BROWSE brwalertes = (IF not(agenda.lactivation) THEN 12 ELSE ?). 
    Agenda.cLibelle:FGCOLOR IN BROWSE brwalertes = (IF not(agenda.lactivation) THEN 15 ELSE ?). 
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwAlertes C-Win
ON START-SEARCH OF brwAlertes IN FRAME frmModule /* Liste des actions planifiées */
DO:
  
    DEFINE VARIABLE     hColonneEnCours        AS WIDGET-HANDLE         NO-UNDO.

    hColonneEnCours = {&SELF-NAME}:CURRENT-COLUMN.
    cTri = hColonneEnCours:LABEL.
    
    RUN OuvreQuery.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwAlertes C-Win
ON VALUE-CHANGED OF brwAlertes IN FRAME frmModule /* Liste des actions planifiées */
DO:
  RUN ChargeAlarme.
  riSauve = (IF AVAILABLE(agenda) THEN ROWID(agenda) ELSE ?).
  RUN GereZones.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frmDetail
&Scoped-define SELF-NAME btnSon
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnSon C-Win
ON CHOOSE OF btnSon IN FRAME frmDetail /* > */
DO:
  IF (cmbson:SCREEN-VALUE <> "" AND cmbson:SCREEN-VALUE <> "-") THEN 
      RUN JoueSon(gcRepertoireRessources + cmbson:SCREEN-VALUE + ".wav").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnTester
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnTester C-Win
ON CHOOSE OF btnTester IN FRAME frmDetail /* Déclencher l'action maintenant */
DO:
    AssigneParametre("AGENDA-DECLENCHEMENT_MANUEL","OUI").
    IF available(agenda) THEN RUN DeclencheAgenda(agenda.cIdent,"").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filHeure
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filHeure C-Win
ON LEAVE OF filHeure IN FRAME frmDetail
DO:
  IF INTEGER(SELF:SCREEN-VALUE) > 24 THEN DO:
      MESSAGE "La valeur de l'heure est incorrecte !"
          VIEW-AS ALERT-BOX QUESTION
          BUTTON OK
          TITLE "Contrôles...".
      RETURN NO-APPLY.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fillDate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fillDate C-Win
ON + OF fillDate IN FRAME frmDetail
DO:
  SELF:SCREEN-VALUE = STRING(DATE(SELF:SCREEN-VALUE) + 1,"99/99/9999").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fillDate C-Win
ON - OF fillDate IN FRAME frmDetail
DO:
    SELF:SCREEN-VALUE = STRING(DATE(SELF:SCREEN-VALUE) - 1,"99/99/9999").  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filLibelle
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filLibelle C-Win
ON LEAVE OF filLibelle IN FRAME frmDetail /* Libellé */
DO:
  IF DonnePreference("PREF-TITREMESSAGE") = "OUI" AND edttexte:SCREEN-VALUE = "" THEN
      edttexte:SCREEN-VALUE = SELF:SCREEN-VALUE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filMinute
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filMinute C-Win
ON LEAVE OF filMinute IN FRAME frmDetail
DO:
  
    IF INTEGER(SELF:SCREEN-VALUE) > 59 THEN DO:
        MESSAGE "La valeur des minutes est incorrecte !"
            VIEW-AS ALERT-BOX QUESTION
            BUTTON OK
            TITLE "Contrôles...".
        RETURN NO-APPLY.
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglAction
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglAction C-Win
ON VALUE-CHANGED OF tglAction IN FRAME frmDetail
DO:
    filAction:SENSITIVE = SELF:CHECKED.
    APPLY "ENTRY" TO filAction IN FRAME frmdetail.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglAvertir
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglAvertir C-Win
ON VALUE-CHANGED OF tglAvertir IN FRAME frmDetail /* Toggle 3 */
DO:
  RUN GereZones.

  APPLY "ENTRY" TO filNbAvertir IN FRAME frmdetail.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglJours
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglJours C-Win
ON VALUE-CHANGED OF tglJours IN FRAME frmDetail /* Ne déclencher l'action que si l'on est un... */
DO:
  RUN GereJours(TRUE).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglPeriodicite
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglPeriodicite C-Win
ON VALUE-CHANGED OF tglPeriodicite IN FRAME frmDetail /* Toggle 2 */
DO:
  
    RUN GereZones.

    APPLY "ENTRY" TO filNbPeriodes IN FRAME frmdetail.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frmModule
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
  RUN MYenable_UI.
  IF NOT THIS-PROCEDURE:PERSISTENT THEN
    WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Abandon C-Win 
PROCEDURE Abandon :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE OUTPUT PARAMETER lRetour-ou AS LOGICAL NO-UNDO.
    IF cEtatEncours = "CRE" AND AVAILABLE(agenda) THEN do: 
        FIND FIRST agenda EXCLUSIVE-LOCK
            WHERE ROWID(agenda) = risauve
            NO-ERROR.
        DELETE agenda.
        RELEASE agenda.
        risauve = ?.
    END.

    RUN recharger.
    
    RUN GereEtat("VIS").

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Affichage C-Win 
PROCEDURE Affichage :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    /*
    DO WITH FRAME frmAgenda:
        FIND FIRST agenda NO-LOCK 
            WHERE agenda.cUtilisateur = gcUtilisateur 
            AND (agenda.ddate > TODAY 
                OR (agenda.ddate = TODAY AND agenda.iheuredebut >= INTEGER(replace(STRING(TIME,"hh:mm"),":",""))))
            NO-ERROR.
        IF AVAILABLE(agenda) THEN do:
            riSauve = ROWID(agenda).
            RUN GereEtat("VIS").
        END.
    END.
    */
    
    DO WITH FRAME frmmodule :
        APPLY "ENTRY" TO brwalertes.        
    END.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ChargeAlarme C-Win 
PROCEDURE ChargeAlarme :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    
    /* Si pas d'alarme en cours : on ne fait rien */
    IF NOT(AVAILABLE(agenda)) THEN RETURN.
    
    /* Chargement de l'alarme en cours */
    DO WITH FRAME frmDetail:
        fillDate:SCREEN-VALUE = STRING(agenda.ddate).
        filHeure:SCREEN-VALUE = SUBstring(STRING(agenda.iheuredebut,"9999"),1,2).
        filMinute:SCREEN-VALUE = SUBstring(STRING(agenda.iheuredebut,"9999"),3,2).
        filLibelle:SCREEN-VALUE = agenda.cLibelle.
        tglAction:CHECKED = agenda.lAction.
        filAction:SCREEN-VALUE = agenda.cAction.
        edtTexte:SCREEN-VALUE = agenda.ctexte.
        tglAvertir:CHECKED = agenda.lDelai.
        filNbAvertir:SCREEN-VALUE = STRING(agenda.inbdelai).
        cmbavertir:SCREEN-VALUE = (IF agenda.cUniteDelai <> ? THEN agenda.cUniteDelai ELSE "-").
        tglPeriodicite:CHECKED = agenda.lperiodique.
        filnbPeriodes:SCREEN-VALUE = STRING(agenda.inbperiode).
        cmbPeriodicite:SCREEN-VALUE = (IF agenda.cUnitePeriode <> ? THEN agenda.cUnitePeriode ELSE "-").
        tglWeekEnd:CHECKED = agenda.lWeekEnd.
        cmbSon:SCREEN-VALUE = (IF agenda.cSon <> ? THEN agenda.cSon ELSE  "-").
        tglJours:CHECKED = agenda.lJours.
        tglLundi:CHECKED = agenda.lLundi.
        tglMardi:CHECKED = agenda.lMardi.
        tglMercredi:CHECKED = agenda.lMercredi.
        tglJeudi:CHECKED = agenda.lJeudi.
        tglVendredi:CHECKED = agenda.lVendredi.
        tglSamedi:CHECKED = agenda.lSamedi.
        tglDimanche:CHECKED = agenda.lDimanche.
        tglActivation:CHECKED = agenda.lActivation.
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Creation C-Win 
PROCEDURE Creation :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE OUTPUT PARAMETER lRetour-ou AS LOGICAL NO-UNDO.


    /* Création d'un enregistrement courant */
    CREATE agenda.
    ASSIGN
        agenda.cUtilisateur = gcUtilisateur
        agenda.lActivation = TRUE.
        risauve = rowid(agenda).
        .

    /* Rechargement du browse */
    {&OPEN-QUERY-brwAlertes}

    /* on se repositionne */
    FIND FIRST agenda NO-LOCK
        WHERE ROWID(agenda) = risauve
        NO-ERROR.

    IF AVAILABLE(agenda) THEN DO WITH FRAME frmModule :
        REPOSITION brwAlertes TO ROWID ROWID(agenda).
        APPLY "VALUE-CHANGED" TO brwAlertes.
    END.

    RUN GereEtat("CRE").
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
  ENABLE brwAlertes 
      WITH FRAME frmModule IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-frmModule}
  DISPLAY filHeure filMinute fillDate filLibelle tglActivation edtTexte 
          filAction tglAction tglJours filNbAvertir cmbAvertir tglAvertir 
          tglWeekend tglLundi tglMardi tglMercredi tglJeudi tglVendredi 
          tglSamedi tglDimanche tglPeriodicite filNbPeriodes cmbperiodicite 
          cmbSon 
      WITH FRAME frmDetail IN WINDOW C-Win.
  ENABLE BtnCalendrier btnSon btnTester RECT-1 filHeure filMinute fillDate 
         filLibelle tglActivation edtTexte filAction tglAction tglJours 
         filNbAvertir cmbAvertir tglAvertir tglWeekend tglLundi tglMardi 
         tglMercredi tglJeudi tglVendredi tglSamedi tglDimanche tglPeriodicite 
         filNbPeriodes cmbperiodicite cmbSon 
      WITH FRAME frmDetail IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-frmDetail}
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
                /* Affichage de la frame principale */
                VIEW FRAME frmModule.
                FRAME frmModule:MOVE-TO-TOP().
                IF DonneEtSupprimeParametre("AGENDA-RECHARGER") = "OUI" THEN DO:
                    RUN Recharger.
                END.
                RUN Affichage.
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
            WHEN "MODIFIER" THEN DO:
                RUN Modification(OUTPUT lRetour-ou).
            END.
            WHEN "AJOUTER" THEN DO:
                RUN Creation(OUTPUT lRetour-ou).
            END.
            WHEN "SUPPRIMER" THEN DO:
                RUN Suppression(OUTPUT lRetour-ou).
            END.
            WHEN "VALIDATION" THEN DO:
                RUN Validation(OUTPUT lRetour-ou).
            END.
            WHEN "ABANDON" THEN DO:
                RUN Abandon(OUTPUT lRetour-ou).
            END.
            WHEN "RECHARGE" THEN DO:
                RUN Recharger.
            END.
            WHEN "IMPRIME" THEN DO:
                RUN ImpressionModule.
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
    gcAideAjouter = "Ajouter une alerte".
    gcAideModifier = "Modifier une alerte".
    gcAideSupprimer = "Supprimer une alerte".
    gcAideImprimer = "Imprimer la liste de l'agenda".
    gcAideRaf = "Recharger l'agenda".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE GereEtat C-Win 
PROCEDURE GereEtat :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER cEtat-in AS CHARACTER.

    DEFINE VARIABLE lEtat AS LOGICAL NO-UNDO.

    lEtat = NOT(cEtat-in = "VIS").
    
    DO WITH FRAME frmModule :
        brwAlertes:SENSITIVE = NOT(lEtat).
    END.

    DO WITH FRAME frmDetail:
        fillDate:SENSITIVE = lEtat.
        filHeure:SENSITIVE = lEtat.
        filMinute:SENSITIVE = lEtat.
        filLibelle:SENSITIVE = lEtat.
        tglAction:SENSITIVE = lEtat.
        filAction:SENSITIVE = lEtat.
        edtTexte:SENSITIVE = lEtat.
        tglAvertir:SENSITIVE = lEtat.
        filNbAvertir:SENSITIVE = lEtat.
        cmbavertir:SENSITIVE = lEtat.
        tglPeriodicite:SENSITIVE = lEtat.
        filnbPeriodes:SENSITIVE = lEtat.
        cmbPeriodicite:SENSITIVE = lEtat.
        tglWeekEnd:SENSITIVE = lEtat.
        cmbSon:SENSITIVE = lEtat.
        btntester:SENSITIVE = NOT(lEtat).
        tglJours:SENSITIVE = lEtat.
        btnson:SENSITIVE = lEtat.
        tglActivation:SENSITIVE = lEtat.

    END.
    RUN GereJours(lEtat).

    /* Mémorisation de l'état demandé */
    cEtatEnCours = cEtat-in.

    /* Gestion de l'état des zones de saisie */
    RUN GereZones.

    IF NUM-RESULTS("brwAlertes") > 0 THEN  brwAlertes:REFRESH() IN FRAME frmModule.

    IF lEtat THEN APPLY "ENTRY" TO fillDate IN FRAME frmdetail.

    IF cEtatEncours = "VIS" THEN DO WITH FRAME frmModule :
        IF riSauve <> ? THEN
            FIND FIRST agenda NO-LOCK WHERE ROWID(agenda) = riSauve NO-ERROR.
        ELSE 
            FIND FIRST agenda WHERE cUtilisateur = gcUtilisateur NO-LOCK NO-ERROR.
        
        IF AVAILABLE(agenda) THEN do:
            REPOSITION brwAlertes TO ROWID riSauve NO-ERROR.
            APPLY "VALUE-CHANGED" TO brwAlertes.
        END.
        
    END.

    IF cEtatEncours = "CRE" THEN DO WITH FRAME frmModule :
        IF DonnePreference("PREF-ALERTEJOUR") = "OUI" THEN 
            fillDate:SCREEN-VALUE = STRING(TODAY).
    END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE GereJours C-Win 
PROCEDURE GereJours :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER lEtat AS LOGICAL NO-UNDO.

    DO WITH FRAME frmDetail:
        tglLundi:SENSITIVE = lEtat AND tglJours:CHECKED.
        tglMardi:SENSITIVE = lEtat AND tglJours:CHECKED.
        tglMercredi:SENSITIVE = lEtat AND tglJours:CHECKED.
        tglJeudi:SENSITIVE = lEtat AND tglJours:CHECKED.
        tglVendredi:SENSITIVE = lEtat AND tglJours:CHECKED.
        tglSamedi:SENSITIVE = lEtat AND tglJours:CHECKED.
        tglDimanche:SENSITIVE = lEtat AND tglJours:CHECKED.

        IF tglJours:CHECKED = FALSE THEN DO:
            tglLundi:CHECKED = FALSE.
            tglMardi:CHECKED = FALSE.
            tglMercredi:CHECKED = FALSE.
            tglJeudi:CHECKED = FALSE.
            tglVendredi:CHECKED = FALSE.
            tglSamedi:CHECKED = FALSE.
            tglDimanche:CHECKED = FALSE.
        END.
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE GereZones C-Win 
PROCEDURE GereZones :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    /* Avertir et periodicité */
    DO WITH FRAME frmDetail:
        filNbAvertir:SENSITIVE = tglAvertir:CHECKED AND NOT(cEtatEnCours = "VIS").
        cmbAvertir:SENSITIVE = tglAvertir:CHECKED AND NOT(cEtatEnCours = "VIS").

        filNbPeriodes:SENSITIVE = tglPeriodicite:CHECKED AND NOT(cEtatEnCours = "VIS").
        cmbperiodicite:SENSITIVE = tglPeriodicite:CHECKED AND NOT(cEtatEnCours = "VIS").
    
        filAction:SENSITIVE = tglAction:CHECKED AND NOT(cEtatEnCours = "VIS").
    
        IF not(tglAvertir:CHECKED) THEN DO:
            filNbAvertir:PRIVATE-DATA = filNbAvertir:SCREEN-VALUE. 
            cmbAvertir:PRIVATE-DATA = cmbAvertir:SCREEN-VALUE. 
            filNbAvertir:SCREEN-VALUE = STRING(0).
            cmbAvertir:SCREEN-VALUE = "-".
        END.
        ELSE DO:
            filNbAvertir:SCREEN-VALUE = (IF filNbAvertir:SCREEN-VALUE = STRING(0) THEN filNbAvertir:PRIVATE-DATA ELSE filNbAvertir:SCREEN-VALUE).
            cmbAvertir:SCREEN-VALUE = (IF cmbAvertir:SCREEN-VALUE = "-" THEN cmbAvertir:PRIVATE-DATA ELSE cmbAvertir:SCREEN-VALUE).
        END.
        
        IF not(tglPeriodicite:CHECKED) THEN DO:
            filNbPeriodes:PRIVATE-DATA = filNbPeriodes:SCREEN-VALUE. 
            cmbperiodicite:PRIVATE-DATA = cmbperiodicite:SCREEN-VALUE. 
            filNbPeriodes:SCREEN-VALUE = STRING(0).
            cmbperiodicite:SCREEN-VALUE = "-".
        END.
        ELSE DO:
            filNbPeriodes:SCREEN-VALUE = (IF filNbPeriodes:SCREEN-VALUE = STRING(0) THEN filNbPeriodes:PRIVATE-DATA ELSE filNbPeriodes:SCREEN-VALUE).
            cmbperiodicite:SCREEN-VALUE = (IF cmbperiodicite:SCREEN-VALUE = "-" THEN cmbperiodicite:PRIVATE-DATA ELSE cmbperiodicite:SCREEN-VALUE).
        END.

        IF not(tglAction:CHECKED) THEN DO:
            filAction:PRIVATE-DATA = filAction:SCREEN-VALUE.
            filAction:SCREEN-VALUE = "".
        END.
        ELSE DO:
            filAction:SCREEN-VALUE = (IF filAction:SCREEN-VALUE = "" THEN filAction:PRIVATE-DATA ELSE filAction:SCREEN-VALUE).
        END.
    END.



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ImpressionModule C-Win 
PROCEDURE ImpressionModule :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE VARIABLE cLigne AS CHARACTER NO-UNDO.
DEFINE VARIABLE cTempo AS CHARACTER NO-UNDO.


    /* Début de l'édition */
    RUN HTML_OuvreFichier("").
    RUN HTML_TitreEdition("Agenda de : " + gcutilisateur).
    
    RUN HTML_ChargeFormatCellule("E",0,"CF=gris,A=><,T=3").
    RUN HTML_ChargeFormatCellule("L",0,"A=<").
    
    /* Ecriture de l'entete pour le tableau des champs */
    cLigne = "" 
        + "Date"
        + devSeparateurEdition + "Heure"
        + devSeparateurEdition + "Libellé"
        + devSeparateurEdition + "Son"
        + devSeparateurEdition + "Action"
        + devSeparateurEdition + "Délai"
        + devSeparateurEdition + "Périodicité"
        + devSeparateurEdition + "W-E"
        + devSeparateurEdition + "Jours"
        + devSeparateurEdition + "Texte"
        .
    RUN HTML_DebutTableau(cLigne).
    
    /* Balayage de la table des champs */
    FOR EACH Agenda NO-LOCK WHERE agenda.cUtilisateur = gcUtilisateur
        :
        cTempo = ""
            + (IF agenda.lLundi         THEN "L" ELSE "-")
            + (IF agenda.lMardi         THEN "M" ELSE "-")
            + (IF agenda.lMercredi      THEN "M" ELSE "-")
            + (IF agenda.lJeudi         THEN "J" ELSE "-")
            + (IF agenda.lVendredi      THEN "V" ELSE "-")
            + (IF agenda.lSamedi        THEN "S" ELSE "-")
            + (IF agenda.lDimanche      THEN "D" ELSE "-")
            .
        cLigne = "" 
            + STRING(agenda.ddate,"99/99/9999")
            + devSeparateurEdition + substring(string(agenda.iHeureDebut,"9999"),1,2) + ":" + substring(string(agenda.iHeureDebut,"9999"),3,2)
            + devSeparateurEdition + TRIM(agenda.cLibelle)
            + devSeparateurEdition + TRIM(agenda.cson)
            + devSeparateurEdition + TRIM(agenda.caction)
            + devSeparateurEdition + STRING(agenda.inbdelai) + " " + agenda.cunitedelai
            + devSeparateurEdition + STRING(agenda.inbperiode) + " " + agenda.cuniteperiode
            + devSeparateurEdition + (IF agenda.lWeekend THEN "NON" ELSE "OUI")
            + devSeparateurEdition + cTempo
            + devSeparateurEdition + TRIM(agenda.ctexte)
            .
        RUN HTML_LigneTableau(cLigne).
    END.
    
    /* Fin de l'édition des champs */
    RUN HTML_FinTableau.
    
    RUN HTML_FinEdition.
    RUN HTML_FermeFichier.
    RUN ImpressionModule.

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
    DEFINE VARIABLE cFichier AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cLigne AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cListe AS CHARACTER NO-UNDO.

    FRAME frmModule:COLUMN = gdPositionXModule.
    FRAME frmModule:ROW = gdPositionYModule.
    
    /* Chargement des sons */
    cFichier = SESSION:TEMP-DIRECTORY + "menudev.son".
    OS-COMMAND SILENT value("dir /b " + gcRepertoireRessources + "*.wav > " + cFichier).
    INPUT FROM VALUE(cFichier) CONVERT SOURCE "ibm850".
    cListe = "-".
    REPEAT:
        IMPORT UNFORMATTED cLigne.
        IF cLigne = "" THEN NEXT.
        cListe = cListe + "," + REPLACE(cLigne,".wav","").
    END.
    INPUT CLOSE.
    OS-DELETE VALUE(cFichier).
    cmbSon:LIST-ITEMS IN FRAME frmdetail = cListe.

    agenda.clibelle:READ-ONLY IN BROWSE brwalertes = TRUE.

    /* Chargement de l'alerte en cours */
    RUN ChargeAlarme.
    riSauve = (IF AVAILABLE(agenda) THEN ROWID(agenda) ELSE ?).

    RUN TopChronoGeneral.

    RUN GereEtat("VIS").

    /* Chargement des alertes */   
    RUN ChargeAlarmes.

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

    riSauve = (IF AVAILABLE(agenda) THEN ROWID(agenda) ELSE ?).

    RUN GereEtat("MOD").

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
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OuvreQuery C-Win 
PROCEDURE OuvreQuery :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    
    IF cTri = "Date" THEN DO:
        OPEN QUERY brwAlertes FOR EACH Agenda WHERE agenda.cUtilisateur = gcUtilisateur NO-LOCK BY agenda.ddate BY agenda.iHeureDebut INDEXED-REPOSITION.
    END.
        
    IF cTri = "Heure" THEN DO:
        OPEN QUERY brwAlertes FOR EACH Agenda WHERE agenda.cUtilisateur = gcUtilisateur NO-LOCK BY agenda.iHeureDebut BY agenda.ddate INDEXED-REPOSITION.
    END.
        
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

    {&OPEN-QUERY-brwAlertes}

    IF NUM-RESULTS("brwAlertes") > 0 THEN  brwalertes:REFRESH() IN FRAME frmModule.

    RUN ChargeAlarme.


    /* Chargement des alertes */   
    RUN ChargeAlarmes.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Suppression C-Win 
PROCEDURE Suppression :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE OUTPUT PARAMETER lRetour-ou AS LOGICAL NO-UNDO INIT TRUE.

    MESSAGE "Confirmez-vous la suppression de la ligne courante de l'agenda ?"
        VIEW-AS ALERT-BOX QUESTION
        BUTTON YES-NO
        TITLE "Demande de confirmation..."
        UPDATE lReponseSuppression AS LOGICAL.
    IF NOT(lReponseSuppression)  THEN RETURN.

    FIND FIRST agenda EXCLUSIVE-LOCK
        WHERE ROWID(agenda) = risauve
        NO-ERROR.
    DELETE agenda.
    RELEASE agenda.
    RUN recharger.
    riSauve = (IF AVAILABLE(agenda) THEN ROWID(agenda) ELSE ?).
    RUN GereEtat("VIS").

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE TopChronoGeneral C-Win 
PROCEDURE TopChronoGeneral :
/* Gestion du chrono général */
    /* activation de l'alerte suivante */
    FOR EACH Alarmes NO-LOCK
        WHERE   Alarmes.cUtilisateur = gcUtilisateur
        AND     Alarmes.ltraitee = FALSE 
        :
        /* date et heure correspond ? */
        IF Alarmes.ddate = TODAY THEN DO:
            IF Alarmes.iheure = giHeure THEN DO:
                RUN DeclencheAgenda(Alarmes.cIdent,Alarmes.cIdentAlarme).
            END.
        END.
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE TopChronoPartiel C-Win 
PROCEDURE TopChronoPartiel :
/* Gestion du chrono Partiel */


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Validation C-Win 
PROCEDURE Validation :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE OUTPUT PARAMETER lRetour-ou AS LOGICAL NO-UNDO INIT TRUE.

    DEFINE VARIABLE cErreur AS CHARACTER NO-UNDO.
    
    DO TRANS:
    
    /* Controle des zones de saisie */
    DO WITH FRAME frmDetail:
        IF fillDate:SCREEN-VALUE = "" THEN cErreur = cErreur + "%s" + "La date de l'alerte n'est pas renseignée".
        IF filLibelle:SCREEN-VALUE = "" THEN cErreur = cErreur + "%s" + "Le libellé de l'alerte n'est pas renseigné".
        IF tglAvertir:CHECKED AND INTEGER(filNbAvertir:SCREEN-VALUE) = 0  THEN cErreur = cErreur + "%s" + "La valeur de l'avertissement est obligatoire".
        IF tglAvertir:CHECKED AND cmbAvertir:SCREEN-VALUE = "-"  THEN cErreur = cErreur + "%s" + "La durée de l'avertissement est obligatoire".
        IF tglPeriodicite:CHECKED AND INTEGER(filNbPeriodes:SCREEN-VALUE) = 0  THEN cErreur = cErreur + "%s" + "La valeur de la période est obligatoire".
        IF tglPeriodicite:CHECKED AND cmbPeriodicite:SCREEN-VALUE = "-"  THEN cErreur = cErreur + "%s" + "La durée de la périodicité est obligatoire".
        IF tglAction:CHECKED AND filAction:SCREEN-VALUE = ""  THEN cErreur = cErreur + "%s" + "La saisie de l'action est obligatoire".
 
    END.
    
    IF cErreur <> "" THEN DO:
        MESSAGE "Une ou plusieurs zones ne sont pas renseignées : " + replace(cErreur,"%s",CHR(10))
            VIEW-AS ALERT-BOX ERROR
            TITLE "Contrôles..."
            .
        lRetour-ou = FALSE.
        RETURN.
    END.

    FIND FIRST agenda WHERE rowid(agenda) = riSauve EXCLUSIVE-LOCK NO-ERROR.
    IF NOT(AVAILABLE(agenda)) THEN RETURN.

    /* Ecriture dans la base */
    DO WITH FRAME frmdetail:
        agenda.dDate = DATE(filldate:SCREEN-VALUE).
        agenda.iheuredebut = integer(filheure:SCREEN-VALUE + filminute:SCREEN-VALUE).
        agenda.cLibelle = fillibelle:SCREEN-VALUE.
        agenda.ctexte = edttexte:SCREEN-VALUE.
        agenda.cSon = cmbson:SCREEN-VALUE.
        agenda.laction = tglAction:CHECKED.
        agenda.iHeureinitiale = (IF agenda.iHeureinitiale = 0 THEN agenda.iheuredebut ELSE agenda.iHeureinitiale).
        agenda.cAction = filAction:SCREEN-VALUE.
        agenda.lperiodique = tglPeriodicite:CHECKED.
        agenda.inbperiode = INTEGER(filnbperiodes:SCREEN-VALUE).
        agenda.cuniteperiode = cmbperiodicite:SCREEN-VALUE.
        agenda.lWeekEnd = tglWeekEnd:CHECKED.
        agenda.ldelai = tglAvertir:CHECKED.
        agenda.inbdelai = INTEGER(filnbavertir:SCREEN-VALUE).
        agenda.cunitedelai = cmbavertir:SCREEN-VALUE.
        agenda.cident = (IF agenda.cident = "" THEN 
                gcUtilisateur 
                + "-" + STRING(YEAR(TODAY),"9999") 
                + STRING(MONTH(TODAY),"99") 
                + STRING(DAY(TODAY),"99") 
                + "-" + replace(STRING(TIME,"hh:mm:ss"),":","")
                ELSE agenda.cident).

         agenda.lJours = tglJours:CHECKED.
         agenda.lLundi = tglLundi:CHECKED.
         agenda.lMardi = tglMardi:CHECKED.
         agenda.lMercredi = tglMercredi:CHECKED.
         agenda.lJeudi = tglJeudi:CHECKED.
         agenda.lVendredi = tglVendredi:CHECKED.
         agenda.lSamedi = tglSamedi:CHECKED.
         agenda.lDimanche = tglDimanche:CHECKED.
         agenda.lactivation = tglActivation:CHECKED.
    END.
    
    END. /* Fin transaction */

    RELEASE agenda.
    {&OPEN-QUERY-brwAlertes}
    RUN GereEtat("VIS").


    /* Chargement des alertes */   
    RUN ChargeAlarmes.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION DonneUnite C-Win 
FUNCTION DonneUnite RETURNS CHARACTER (cCodeUnite-in AS CHARACTER) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/

  DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO.

  CASE cCodeUnite-in:
      WHEN "H" THEN cRetour = "Heure(s)".
      WHEN "J" THEN cRetour = "Jour(s)".
      WHEN "S" THEN cRetour = "Semaine(s)".
      WHEN "M" THEN cRetour = "Mois".
      WHEN "A" THEN cRetour = "Année(s)".
  END CASE.

  RETURN cRetour.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

