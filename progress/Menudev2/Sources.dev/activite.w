&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
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
{menudev2\includes\menudev2.i}


/* Parameters Definitions ---                                           */

DEFINE INPUT PARAMETER  winGeneral  AS HANDLE NO-UNDO.
DEFINE INPUT PARAMETER  cParametres AS CHARACTER NO-UNDO.
/* Local Variable Definitions ---                                       */

DEFINE BUFFER bprefs FOR prefs.

    DEFINE TEMP-TABLE ttActivites LIKE activite.
    DEFINE TEMP-TABLE ttExtraction LIKE activite.

    DEFINE TEMP-TABLE ttStats 
        FIELD iCodeStat AS INTEGER
        FIELD cRegroupement AS CHARACTER
        FIELD iDureeRegroupement AS INT64
        FIELD iJours AS INTEGER
        FIELD dDate AS DATE
        .

DEFINE BUFFER rActivite FOR activite.

DEFINE VARIABLE iReferenceEnCours AS INTEGER NO-UNDO INIT 0.
DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO.
DEFINE VARIABLE dDate AS DATE NO-UNDO.
DEFINE VARIABLE cEtatEncours AS CHARACTER NO-UNDO.
DEFINE VARIABLE idActiviteEnCours AS INT64 NO-UNDO.
DEFINE VARIABLE lRetourProcedure AS LOGICAL NO-UNDO.
DEFINE VARIABLE lREchercheDescendante AS LOGICAL NO-UNDO.

DEFINE VARIABLE cMessage AS CHARACTER NO-UNDO.

DEFINE STREAM sRecherche.
DEFINE STREAM sEdition.

DEFINE TEMP-TABLE ttResume
    FIELD cCode AS CHARACTER
    FIELD cValeur AS CHARACTER
    .

DEFINE VARIABLE cPredefinis AS CHARACTER NO-UNDO.
DEFINE VARIABLE lPasControle AS LOGICAL NO-UNDO.
DEFINE VARIABLE cSeparateur AS CHARACTER  NO-UNDO INIT "@".

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME frmModule
&Scoped-define BROWSE-NAME brwactivites

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ttActivites ttResume

/* Definitions for BROWSE brwactivites                                  */
&Scoped-define FIELDS-IN-QUERY-brwactivites ttActivites.cTypeActivite ttActivites.cCodeActivite ttActivites.cSousCodeActivite ttActivites.cLibelleActivite string(ttActivites.iHeureDebut,"hh:mm") @ ttActivites.iHeureDebut (IF ttActivites.idureeActivite <> 0 THEN string(ttActivites.idureeActivite,"hh:mm") ELSE "") ttactivites.cCommentaire   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brwactivites   
&Scoped-define SELF-NAME brwactivites
&Scoped-define QUERY-STRING-brwactivites FOR EACH ttActivites
&Scoped-define OPEN-QUERY-brwactivites OPEN QUERY {&SELF-NAME} FOR EACH ttActivites.
&Scoped-define TABLES-IN-QUERY-brwactivites ttActivites
&Scoped-define FIRST-TABLE-IN-QUERY-brwactivites ttActivites


/* Definitions for BROWSE brwResume                                     */
&Scoped-define FIELDS-IN-QUERY-brwResume ttResume.cCode ttResume.cValeur   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brwResume   
&Scoped-define SELF-NAME brwResume
&Scoped-define QUERY-STRING-brwResume FOR EACH ttResume
&Scoped-define OPEN-QUERY-brwResume OPEN QUERY {&SELF-NAME} FOR EACH ttResume.
&Scoped-define TABLES-IN-QUERY-brwResume ttResume
&Scoped-define FIRST-TABLE-IN-QUERY-brwResume ttResume


/* Definitions for FRAME frmModule                                      */
&Scoped-define OPEN-BROWSERS-IN-QUERY-frmModule ~
    ~{&OPEN-QUERY-brwactivites}~
    ~{&OPEN-QUERY-brwResume}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-1 btnMoisPrecedent btnJourPrecedent ~
btnJourSuivant btnMoisSuivant btnAujourdhui filRecherche ~
btnRecherchePrecedent btnRechercheSuivant filDateRecherche btnFichier ~
brwactivites cmbtache cmbCode cmbSousCode cmblibelle filheure ~
edtCommentaire filDate 
&Scoped-Define DISPLAYED-OBJECTS filRecherche filDateRecherche cmbtache ~
cmbCode cmbSousCode cmblibelle filheure edtCommentaire filDate 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD AfficheInformations C-Win 
FUNCTION AfficheInformations RETURNS LOGICAL
  ( cLibelle-in AS CHARACTER,iTemporisation-in AS INTEGER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD DonneHeureInteger C-Win 
FUNCTION DonneHeureInteger RETURNS INTEGER
  ( chms AS CHARACTER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD DonneTempsReel C-Win 
FUNCTION DonneTempsReel RETURNS CHARACTER
  ( iNbJours AS INTEGER, iDuree AS INTEGER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD logDebug C-Win 
FUNCTION logDebug RETURNS LOGICAL
  ( cLibelle AS CHARACTER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.

/* Menu Definitions                                                     */
DEFINE MENU POPUP-MENU-brwactivites 
       MENU-ITEM m_ACTIONS      LABEL ">>>>>>>>>>> ACTIVITES <<<<<<<<<<<"
              DISABLED
       MENU-ITEM m_Début_de_journée LABEL "Début de journée"
       MENU-ITEM m_Fin_de_journée LABEL "Fin de journée"
       RULE
       MENU-ITEM m_Pause        LABEL "Pause"         
       MENU-ITEM m_Déjeuner     LABEL "Déjeuner"      
       MENU-ITEM m_Absence      LABEL "Absence"       
       MENU-ITEM m_Interruption LABEL "Interruption"  
       RULE
       MENU-ITEM m__Sur_le_jour_en_cours_ LABEL ">>>>>> SUR LE RAPPORT DU JOUR <<<<<<"
              DISABLED
       MENU-ITEM m_Reprise_de_la_dernière_acti LABEL "Reprise de la dernière activité"
       MENU-ITEM m_Reprise      LABEL "Reprise de l'activité sélectionnée"
       RULE
       MENU-ITEM m__SUR_LE_JOUR_SELECTIONNE_ LABEL ">>>> SUR LE RAPPORT SELECTIONNE <<<<"
              DISABLED
       MENU-ITEM m_Dupliquer_lactivité_en_cour LABEL "Dupliquer l'activité sélectionnée"
       RULE
       MENU-ITEM m_Ajouter_une_activité LABEL "Ajouter une activité"
       MENU-ITEM m_Modifier_lactivité_en_cours LABEL "Modifier l'activité sélectionnée"
       MENU-ITEM m_Supprimer_lactivité_en_cour LABEL "Supprimer l'activité sélectionnée"
       RULE
       MENU-ITEM m_Rapports     LABEL ">>>>>>>>>>> RAPPORTS <<<<<<<<<<<"
              DISABLED
       MENU-ITEM m_Du_jour      LABEL "Du jour"       
       MENU-ITEM m_De_la_semaine LABEL "De la semaine" 
       MENU-ITEM m_Du_mois      LABEL "Du mois"       
       MENU-ITEM m_Depuis_une_date LABEL "Sur une période"
       RULE
       MENU-ITEM m_Fermer_ce_menu LABEL "Fermer ce menu".


/* Definitions of the field level widgets                               */
DEFINE BUTTON btnAbandonner 
     LABEL "Abandonner" 
     SIZE 21 BY 1.19.

DEFINE BUTTON btnValider 
     LABEL "Valider" 
     SIZE 21 BY 1.19.

DEFINE VARIABLE cmbCritereCode AS CHARACTER 
     LABEL "Code de l'activité" 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Item 1" 
     DROP-DOWN AUTO-COMPLETION
     SIZE 25 BY 1 NO-UNDO.

DEFINE VARIABLE cmbCritereSousCode AS CHARACTER 
     LABEL "Sous-Code de l'activité" 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Item 1" 
     DROP-DOWN AUTO-COMPLETION
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE cmbCriteretache AS CHARACTER 
     LABEL "Type de l'activité" 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Item 1" 
     DROP-DOWN AUTO-COMPLETION
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE filDateDebut AS DATE FORMAT "99/99/9999":U INITIAL 01/01/001 
     LABEL "Depuis le" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 15 BY .95 NO-UNDO.

DEFINE VARIABLE filDateFin AS DATE FORMAT "99/99/9999":U INITIAL 01/01/001 
     LABEL "Jusqu'au" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 15 BY .95 NO-UNDO.

DEFINE VARIABLE edtInformation AS CHARACTER INITIAL "Libelle" 
     VIEW-AS EDITOR NO-BOX
     SIZE 61 BY 1.19
     BGCOLOR 3 FGCOLOR 15 FONT 10 NO-UNDO.

DEFINE IMAGE IMAGE-1
     FILENAME "adeicon/rbuild%.ico":U
     SIZE 8 BY 1.43.

DEFINE BUTTON btnAujourdhui  NO-CONVERT-3D-COLORS
     LABEL "><" 
     SIZE-PIXELS 20 BY 20 TOOLTIP "Positionnement sur le jour actuel".

DEFINE BUTTON btnFichier 
     LABEL "Résultats dans un fichier" 
     SIZE 29 BY .95.

DEFINE BUTTON btnJour  NO-FOCUS FLAT-BUTTON
     LABEL "Button 1" 
     SIZE 14 BY 1
     FONT 6.

DEFINE BUTTON btnJourPrecedent 
     LABEL "<" 
     SIZE-PIXELS 20 BY 20 TOOLTIP "Jour précédent".

DEFINE BUTTON btnJourSuivant  NO-CONVERT-3D-COLORS
     LABEL ">" 
     SIZE-PIXELS 20 BY 20 TOOLTIP "Jour suivant".

DEFINE BUTTON btnMoisPrecedent 
     LABEL "<<" 
     SIZE-PIXELS 20 BY 20 TOOLTIP "Semaine précédente".

DEFINE BUTTON btnMoisSuivant  NO-CONVERT-3D-COLORS
     LABEL ">>" 
     SIZE-PIXELS 20 BY 20 TOOLTIP "Semaine suivante".

DEFINE BUTTON btnRecherchePrecedent 
     LABEL "<" 
     SIZE-PIXELS 20 BY 20 TOOLTIP "Rechercher le précédent".

DEFINE BUTTON btnRechercheSuivant  NO-CONVERT-3D-COLORS
     LABEL ">" 
     SIZE-PIXELS 20 BY 20 TOOLTIP "Rechercher le suivant".

DEFINE VARIABLE cmbCode AS CHARACTER 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Item 1" 
     DROP-DOWN AUTO-COMPLETION
     SIZE 25 BY 1 NO-UNDO.

DEFINE VARIABLE cmblibelle AS CHARACTER 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Item 1" 
     DROP-DOWN AUTO-COMPLETION
     SIZE 58 BY 1 NO-UNDO.

DEFINE VARIABLE cmbSousCode AS CHARACTER 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Item 1" 
     DROP-DOWN AUTO-COMPLETION
     SIZE 17 BY 1 NO-UNDO.

DEFINE VARIABLE cmbtache AS CHARACTER 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Item 1" 
     DROP-DOWN AUTO-COMPLETION
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE edtCommentaire AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 139 BY 3.33 NO-UNDO.

DEFINE VARIABLE filDate AS CHARACTER FORMAT "99/99/9999":U INITIAL "01/01/2018" 
      VIEW-AS TEXT 
     SIZE 15 BY .62
     FONT 6 NO-UNDO.

DEFINE VARIABLE filDateRecherche AS DATE FORMAT "99/99/9999":U INITIAL 01/01/001 
     LABEL "Depuis le" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 15 BY .95 NO-UNDO.

DEFINE VARIABLE filheure AS CHARACTER FORMAT "99:99":U INITIAL "99:99" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 7 BY 1
     FONT 9 NO-UNDO.

DEFINE VARIABLE filRecherche AS CHARACTER FORMAT "X(256)":U 
     LABEL "Recherche" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 36 BY .95 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 18 BY 1.91
     FGCOLOR 0 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brwactivites FOR 
      ttActivites SCROLLING.

DEFINE QUERY brwResume FOR 
      ttResume SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brwactivites
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brwactivites C-Win _FREEFORM
  QUERY brwactivites DISPLAY
      ttActivites.cTypeActivite  WIDTH 23 COLUMN-LABEL "Type"
ttActivites.cCodeActivite  WIDTH 23 COLUMN-LABEL "Code"
ttActivites.cSousCodeActivite  WIDTH 23 COLUMN-LABEL "Sous-Code"
ttActivites.cLibelleActivite WIDTH 61 COLUMN-LABEL "Libellé"
string(ttActivites.iHeureDebut,"hh:mm") @ ttActivites.iHeureDebut WIDTH 6 COLUMN-LABEL "Début"
(IF ttActivites.idureeActivite <> 0 THEN string(ttActivites.idureeActivite,"hh:mm") ELSE "") WIDTH 6 COLUMN-LABEL "Durée"
ttactivites.cCommentaire WIDTH 20 COLUMN-LABEL "Commentaire"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 163 BY 11.67 ROW-HEIGHT-CHARS .62 FIT-LAST-COLUMN.

DEFINE BROWSE brwResume
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brwResume C-Win _FREEFORM
  QUERY brwResume DISPLAY
      ttResume.cCode
 ttResume.cValeur
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-LABELS NO-ROW-MARKERS SEPARATORS NO-SCROLLBAR-VERTICAL SIZE 22 BY 4.52
         FONT 0 ROW-HEIGHT-CHARS .62 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME frmModule
     btnMoisPrecedent AT Y 10 X 10 WIDGET-ID 58
     btnJour AT ROW 1.19 COL 14 WIDGET-ID 98 NO-TAB-STOP 
     btnJourPrecedent AT Y 10 X 30 WIDGET-ID 54
     btnJourSuivant AT Y 10 X 150 WIDGET-ID 56
     btnMoisSuivant AT Y 10 X 170 WIDGET-ID 60
     btnAujourdhui AT Y 10 X 195 WIDGET-ID 90
     filRecherche AT ROW 1.48 COL 51.2 WIDGET-ID 26
     btnRecherchePrecedent AT Y 10 X 495 WIDGET-ID 22
     btnRechercheSuivant AT Y 10 X 515 WIDGET-ID 24
     filDateRecherche AT ROW 1.48 COL 109 WIDGET-ID 80
     btnFichier AT ROW 1.48 COL 135 WIDGET-ID 84
     brwactivites AT ROW 3.14 COL 2 WIDGET-ID 800
     cmbtache AT ROW 15.05 COL 2 NO-LABEL WIDGET-ID 42
     cmbCode AT ROW 15.05 COL 22 NO-LABEL WIDGET-ID 72
     cmbSousCode AT ROW 15.05 COL 47 NO-LABEL WIDGET-ID 102
     cmblibelle AT ROW 15.05 COL 73 COLON-ALIGNED NO-LABEL WIDGET-ID 44
     filheure AT ROW 15.05 COL 132 COLON-ALIGNED NO-LABEL WIDGET-ID 46
     brwResume AT ROW 15.76 COL 143 WIDGET-ID 900
     edtCommentaire AT ROW 16.95 COL 2 NO-LABEL WIDGET-ID 48
     filDate AT ROW 2.19 COL 12 COLON-ALIGNED NO-LABEL WIDGET-ID 36
     "Commentaire" VIEW-AS TEXT
          SIZE 22 BY .71 AT ROW 16.24 COL 2 WIDGET-ID 50
     "Résumé de la journée" VIEW-AS TEXT
          SIZE 22 BY .71 AT ROW 15.05 COL 143 WIDGET-ID 94
     RECT-1 AT ROW 1.14 COL 12 WIDGET-ID 100
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 165.4 BY 20.57
         TITLE BGCOLOR 2 FGCOLOR 15 "Activités".

DEFINE FRAME frmCriteres
     cmbCriteretache AT ROW 1.48 COL 13.8 WIDGET-ID 42
     cmbCritereCode AT ROW 2.91 COL 13.6 WIDGET-ID 72
     cmbCritereSousCode AT ROW 4.33 COL 8.2 WIDGET-ID 88
     filDateDebut AT ROW 5.76 COL 4 WIDGET-ID 80
     filDateFin AT ROW 5.76 COL 35.4 WIDGET-ID 86
     btnValider AT ROW 7.19 COL 8 WIDGET-ID 82
     btnAbandonner AT ROW 7.19 COL 36 WIDGET-ID 84
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 50 ROW 4.33
         SIZE 64 BY 8.81
         TITLE "Critères de l'édition" WIDGET-ID 1000.

DEFINE FRAME frmInformation
     edtInformation AT ROW 1.48 COL 13 NO-LABEL WIDGET-ID 2
     IMAGE-1 AT ROW 1.24 COL 3 WIDGET-ID 4
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS TOP-ONLY NO-UNDERLINE THREE-D 
         AT COL 46 ROW 7.67
         SIZE 76 BY 2.14
         BGCOLOR 3  WIDGET-ID 700.


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
         HEIGHT             = 20.76
         WIDTH              = 166
         MAX-HEIGHT         = 33.95
         MAX-WIDTH          = 167.8
         VIRTUAL-HEIGHT     = 33.95
         VIRTUAL-WIDTH      = 167.8
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
  NOT-VISIBLE,                                                          */
/* REPARENT FRAME */
ASSIGN FRAME frmCriteres:FRAME = FRAME frmModule:HANDLE
       FRAME frmInformation:FRAME = FRAME frmModule:HANDLE.

/* SETTINGS FOR FRAME frmCriteres
                                                                        */
/* SETTINGS FOR COMBO-BOX cmbCritereCode IN FRAME frmCriteres
   ALIGN-L                                                              */
/* SETTINGS FOR COMBO-BOX cmbCritereSousCode IN FRAME frmCriteres
   ALIGN-L                                                              */
/* SETTINGS FOR COMBO-BOX cmbCriteretache IN FRAME frmCriteres
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN filDateDebut IN FRAME frmCriteres
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN filDateFin IN FRAME frmCriteres
   ALIGN-L                                                              */
/* SETTINGS FOR FRAME frmInformation
                                                                        */
ASSIGN 
       FRAME frmInformation:HIDDEN           = TRUE
       FRAME frmInformation:MOVABLE          = TRUE.

ASSIGN 
       edtInformation:AUTO-RESIZE IN FRAME frmInformation      = TRUE
       edtInformation:READ-ONLY IN FRAME frmInformation        = TRUE.

/* SETTINGS FOR FRAME frmModule
   FRAME-NAME                                                           */
/* BROWSE-TAB brwactivites btnFichier frmModule */
/* BROWSE-TAB brwResume filheure frmModule */
ASSIGN 
       brwactivites:POPUP-MENU IN FRAME frmModule             = MENU POPUP-MENU-brwactivites:HANDLE.

/* SETTINGS FOR BROWSE brwResume IN FRAME frmModule
   NO-ENABLE                                                            */
ASSIGN 
       btnAujourdhui:AUTO-RESIZE IN FRAME frmModule      = TRUE.

/* SETTINGS FOR BUTTON btnJour IN FRAME frmModule
   NO-ENABLE                                                            */
ASSIGN 
       btnJour:AUTO-RESIZE IN FRAME frmModule      = TRUE
       btnJour:SELECTABLE IN FRAME frmModule       = TRUE.

ASSIGN 
       btnJourSuivant:AUTO-RESIZE IN FRAME frmModule      = TRUE.

ASSIGN 
       btnMoisSuivant:AUTO-RESIZE IN FRAME frmModule      = TRUE.

ASSIGN 
       btnRechercheSuivant:AUTO-RESIZE IN FRAME frmModule      = TRUE.

/* SETTINGS FOR COMBO-BOX cmbCode IN FRAME frmModule
   ALIGN-L                                                              */
/* SETTINGS FOR COMBO-BOX cmbSousCode IN FRAME frmModule
   ALIGN-L                                                              */
/* SETTINGS FOR COMBO-BOX cmbtache IN FRAME frmModule
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN filDateRecherche IN FRAME frmModule
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN filRecherche IN FRAME frmModule
   ALIGN-L                                                              */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brwactivites
/* Query rebuild information for BROWSE brwactivites
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH ttActivites.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE brwactivites */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brwResume
/* Query rebuild information for BROWSE brwResume
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH ttResume.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE brwResume */
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


&Scoped-define SELF-NAME frmModule
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL frmModule C-Win
ON GO OF FRAME frmModule /* Activités */
DO:
    IF cEtatEnCours = "MOD" THEN DO:
        RUN Validation(OUTPUT lRetourProcedure).
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brwactivites
&Scoped-define SELF-NAME brwactivites
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwactivites C-Win
ON DEFAULT-ACTION OF brwactivites IN FRAME frmModule
DO:
    RUN DonneOrdre("MODIFIER").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwactivites C-Win
ON END-RESIZE OF brwactivites IN FRAME frmModule
DO:
  MESSAGE SELF:WIDTH VIEW-AS ALERT-BOX.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwactivites C-Win
ON VALUE-CHANGED OF brwactivites IN FRAME frmModule
DO:
  IF available(ttactivites) THEN do:
      idActiviteEnCours = ttactivites.idActivite.
      brwActivites:TOOLTIP = (IF ttactivites.cCommentaire <> "" THEN ttactivites.cCommentaire ELSE ?).
  END.
  RUN GereZones.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frmCriteres
&Scoped-define SELF-NAME btnAbandonner
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnAbandonner C-Win
ON CHOOSE OF btnAbandonner IN FRAME frmCriteres /* Abandonner */
DO:
    RUN AfficheFrame("Activites",?).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frmModule
&Scoped-define SELF-NAME btnAujourdhui
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnAujourdhui C-Win
ON CHOOSE OF btnAujourdhui IN FRAME frmModule /* >< */
DO:
    RUN InitRecherche.
    fildate:SCREEN-VALUE = STRING(TODAY,"99/99/9999").
    RUN ChangeDate(0,"").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnFichier
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnFichier C-Win
ON CHOOSE OF btnFichier IN FRAME frmModule /* Résultats dans un fichier */
DO:
    IF filRecherche:SCREEN-VALUE = "" THEN RETURN.

    RUN RechercheDansFichier.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnJourPrecedent
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnJourPrecedent C-Win
ON CHOOSE OF btnJourPrecedent IN FRAME frmModule /* < */
DO:
    RUN InitRecherche.
    RUN ChangeDate(-1,"days").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnJourSuivant
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnJourSuivant C-Win
ON CHOOSE OF btnJourSuivant IN FRAME frmModule /* > */
DO:
    RUN InitRecherche.
    RUN ChangeDate(1,"days").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnMoisPrecedent
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnMoisPrecedent C-Win
ON CHOOSE OF btnMoisPrecedent IN FRAME frmModule /* << */
DO:
    RUN InitRecherche.
    RUN ChangeDate(-1,"weeks").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnMoisSuivant
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnMoisSuivant C-Win
ON CHOOSE OF btnMoisSuivant IN FRAME frmModule /* >> */
DO:
    RUN InitRecherche.
    RUN ChangeDate(1,"weeks").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnRecherchePrecedent
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnRecherchePrecedent C-Win
ON CHOOSE OF btnRecherchePrecedent IN FRAME frmModule /* < */
DO:
    DEFINE VARIABLE cRecherche AS CHARACTER NO-UNDO.
    DEFINE VARIABLE dRecherche AS DATE NO-UNDO.

    IF filRecherche:SCREEN-VALUE = "" THEN RETURN.

    cRecherche = "*" + filRecherche:SCREEN-VALUE + "*".

    dRecherche = DATE(filDateRecherche:SCREEN-VALUE).

    /* Recherche en avant */
    IF AVAILABLE(rActivite) THEN DO:
        FIND PREV   rActivite   NO-LOCK
            WHERE   rActivite.cUtilisateur = gcutilisateur
            AND     rActivite.dDate >= dRecherche
            and     (rActivite.cTypeActivite MATCHES cRecherche
                     OR
                     rActivite.cCodeActivite MATCHES cRecherche
                     OR
                     rActivite.cLibelleActivite MATCHES cRecherche
                     OR
                     rActivite.cCommentaire MATCHES cRecherche)
            NO-ERROR.
    END.
    IF NOT(AVAILABLE(rActivite)) THEN DO:
        FIND LAST   rActivite   NO-LOCK
            WHERE   rActivite.cUtilisateur = gcutilisateur
            AND     rActivite.dDate >= dRecherche
            and     (rActivite.cTypeActivite MATCHES cRecherche
                     OR
                     rActivite.cCodeActivite MATCHES cRecherche
                     OR
                     rActivite.cLibelleActivite MATCHES cRecherche
                     OR
                     rActivite.cCommentaire MATCHES cRecherche)
            NO-ERROR.
    END.
    IF AVAILABLE(rActivite) THEN DO:
        /* positionnement sur le bon jour */
        FilDate:SCREEN-VALUE = string(rActivite.dDate,"99/99/9999").
        RUN ChangeDate(0,"").

        /* Positionnement sur la bonne activite */
        FIND FIRST ttactivites
            WHERE ttactivites.idActivite = rActivite.idActivite
            NO-ERROR.
            .
        IF AVAILABLE(ttactivites) THEN REPOSITION brwActivites TO RECID RECID(ttactivites).
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnRechercheSuivant
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnRechercheSuivant C-Win
ON CHOOSE OF btnRechercheSuivant IN FRAME frmModule /* > */
DO:
    DEFINE VARIABLE cRecherche AS CHARACTER NO-UNDO.
    DEFINE VARIABLE dRecherche AS DATE NO-UNDO.

    IF filRecherche:SCREEN-VALUE = "" THEN RETURN.

    cRecherche = "*" + filRecherche:SCREEN-VALUE + "*".
    
    dRecherche = DATE(filDateRecherche:SCREEN-VALUE).

    /* Recherche en avant */
    IF AVAILABLE(rActivite) THEN DO:
        FIND NEXT   rActivite   NO-LOCK
            WHERE   rActivite.cUtilisateur = gcutilisateur
            AND     rActivite.dDate >= dRecherche
            and     (rActivite.cTypeActivite MATCHES cRecherche
                     OR
                     rActivite.cCodeActivite MATCHES cRecherche
                     OR
                     rActivite.cSousCodeActivite MATCHES cRecherche
                     OR
                     rActivite.cLibelleActivite MATCHES cRecherche
                     OR
                     rActivite.cCommentaire MATCHES cRecherche)
            NO-ERROR.
    END.
    IF NOT(AVAILABLE(rActivite)) THEN DO:
        FIND FIRST  rActivite   NO-LOCK
            WHERE   rActivite.cUtilisateur = gcutilisateur
            AND     rActivite.dDate >= dRecherche
            and     (rActivite.cTypeActivite MATCHES cRecherche
                     OR
                     rActivite.cCodeActivite MATCHES cRecherche
                     OR
                     rActivite.cSousCodeActivite MATCHES cRecherche
                     OR
                     rActivite.cLibelleActivite MATCHES cRecherche
                     OR
                     rActivite.cCommentaire MATCHES cRecherche)
            NO-ERROR.
    END.
    IF AVAILABLE(rActivite) THEN DO:
        /* positionnement sur le bon jour */
        FilDate:SCREEN-VALUE = string(rActivite.dDate,"99/99/9999").
        RUN ChangeDate(0,"").

        /* Positionnement sur la bonne activite */
        FIND FIRST ttactivites
            WHERE ttactivites.idActivite = rActivite.idActivite
            NO-ERROR.
            .
        IF AVAILABLE(ttactivites) THEN do:
            REPOSITION brwActivites TO RECID RECID(ttactivites).
            APPLY "VALUE-CHANGED" TO brwActivites.
        END.

    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frmCriteres
&Scoped-define SELF-NAME btnValider
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnValider C-Win
ON CHOOSE OF btnValider IN FRAME frmCriteres /* Valider */
DO:
    RUN AfficheFrame("Activites",?).
    RUN Rapport (self:private-data,cmbCriteretache:SCREEN-VALUE,cmbCritereCode:SCREEN-VALUE,cmbCritereSousCode:SCREEN-VALUE,date(filDateDebut:SCREEN-VALUE),date(filDateFin:SCREEN-VALUE)).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frmModule
&Scoped-define SELF-NAME cmbCode
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cmbCode C-Win
ON LEAVE OF cmbCode IN FRAME frmModule
DO:
  
    SELF:SCREEN-VALUE = CAPS(SELF:SCREEN-VALUE).

    IF lRechercheDescendante THEN RUN chargeSousCodes.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cmbCode C-Win
ON RETURN OF cmbCode IN FRAME frmModule
DO:
  
    APPLY "TAB" TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frmCriteres
&Scoped-define SELF-NAME cmbCritereCode
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cmbCritereCode C-Win
ON LEAVE OF cmbCritereCode IN FRAME frmCriteres /* Code de l'activité */
DO:
  
    SELF:SCREEN-VALUE = CAPS(SELF:SCREEN-VALUE).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cmbCritereSousCode
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cmbCritereSousCode C-Win
ON LEAVE OF cmbCritereSousCode IN FRAME frmCriteres /* Sous-Code de l'activité */
DO:
  
    SELF:SCREEN-VALUE = CAPS(SELF:SCREEN-VALUE).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cmbCriteretache
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cmbCriteretache C-Win
ON LEAVE OF cmbCriteretache IN FRAME frmCriteres /* Type de l'activité */
DO:
    SELF:SCREEN-VALUE = CAPS(SELF:SCREEN-VALUE).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frmModule
&Scoped-define SELF-NAME cmblibelle
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cmblibelle C-Win
ON RETURN OF cmblibelle IN FRAME frmModule
DO:
  
    APPLY "TAB" TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cmbSousCode
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cmbSousCode C-Win
ON LEAVE OF cmbSousCode IN FRAME frmModule
DO:
  
    SELF:SCREEN-VALUE = CAPS(SELF:SCREEN-VALUE).

    IF lRechercheDescendante THEN RUN chargeLibelles.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cmbSousCode C-Win
ON RETURN OF cmbSousCode IN FRAME frmModule
DO:
  
    APPLY "TAB" TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cmbtache
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cmbtache C-Win
ON LEAVE OF cmbtache IN FRAME frmModule
DO:
  
    SELF:SCREEN-VALUE = CAPS(SELF:SCREEN-VALUE).
    IF LOOKUP(SELF:SCREEN-VALUE,cPredefinis) > 0 THEN DO:
        IF not(lPasControle) THEN DO:
            RUN AfficheMessageAvecTemporisation("Activité","Interdiction de saisir un type d'action prédéfini !%sUtilisez le menu du browse.",FALSE,10,"OK","",FALSE,OUTPUT cRetour).
            RETURN NO-APPLY.
        END.
        lPasControle = FALSE.
    END.
    IF lRechercheDescendante THEN RUN chargeCodes.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cmbtache C-Win
ON RETURN OF cmbtache IN FRAME frmModule
DO:
    APPLY "TAB" TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filDate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filDate C-Win
ON LEAVE OF filDate IN FRAME frmModule
DO:
    RUN InitRecherche.
    RUN ChangeDate(0,"").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filDate C-Win
ON RETURN OF filDate IN FRAME frmModule
DO:
    RUN InitRecherche.
    RUN ChangeDate(0,"").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filDate C-Win
ON TAB OF filDate IN FRAME frmModule
DO:
    RUN InitRecherche.
    RUN ChangeDate(0,"").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filDateRecherche
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filDateRecherche C-Win
ON LEAVE OF filDateRecherche IN FRAME frmModule /* Depuis le */
DO:
    IF DATE(SELF:SCREEN-VALUE) > TODAY THEN DO:
        RUN AfficheMessageAvecTemporisation("Activité","La date de début de recherche ne peut pas être dans le futur",FALSE,10,"OK","",FALSE,OUTPUT cRetour).
        SELF:SCREEN-VALUE = STRING(ADD-INTERVAL(TODAY,-2,"months"),"99/99/9999").
    END.
    IF DATE(SELF:SCREEN-VALUE) = ? THEN DO:
        RUN AfficheMessageAvecTemporisation("Activité","La date de début de recherche est obligatoire",FALSE,10,"OK","",FALSE,OUTPUT cRetour).
        SELF:SCREEN-VALUE = STRING(ADD-INTERVAL(TODAY,-2,"months"),"99/99/9999").
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filheure
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filheure C-Win
ON RETURN OF filheure IN FRAME frmModule
DO:
  
    RUN Validation(OUTPUT lRetourProcedure).
    IF NOT(lRetourProcedure) THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filRecherche
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filRecherche C-Win
ON RETURN OF filRecherche IN FRAME frmModule /* Recherche */
DO:
  APPLY "CHOOSE" TO BtnRechercheSuivant.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Absence
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Absence C-Win
ON CHOOSE OF MENU-ITEM m_Absence /* Absence */
DO:
  
    RUN Predefinies("ABSENCE",?,?,OUTPUT lRetourProcedure).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Ajouter_une_activité
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Ajouter_une_activité C-Win
ON CHOOSE OF MENU-ITEM m_Ajouter_une_activité /* Ajouter une activité */
DO:
  
    RUN DonneOrdre("AJOUTER").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Début_de_journée
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Début_de_journée C-Win
ON CHOOSE OF MENU-ITEM m_Début_de_journée /* Début de journée */
DO:
  
    RUN Predefinies("DDJ",?,?,OUTPUT lRetourProcedure).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Déjeuner
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Déjeuner C-Win
ON CHOOSE OF MENU-ITEM m_Déjeuner /* Déjeuner */
DO:
  
    RUN Predefinies("REPAS",?,?,OUTPUT lRetourProcedure).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Depuis_une_date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Depuis_une_date C-Win
ON CHOOSE OF MENU-ITEM m_Depuis_une_date /* Sur une période */
DO:
    RUN AfficheFrame("Criteres","P").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_De_la_semaine
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_De_la_semaine C-Win
ON CHOOSE OF MENU-ITEM m_De_la_semaine /* De la semaine */
DO:
    RUN AfficheFrame("Criteres","S").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Dupliquer_lactivité_en_cour
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Dupliquer_lactivité_en_cour C-Win
ON CHOOSE OF MENU-ITEM m_Dupliquer_lactivité_en_cour /* Dupliquer l'activité sélectionnée */
DO:
    IF NOT(AVAILABLE(ttActivites)) THEN RETURN.
    IF lookup(ttActivites.cTypeActivite,"DDJ,FDJ,REPAS") <> 0 THEN DO:
        RUN AfficheMessageAvecTemporisation("Activité","Vous ne pouvez pas dupliquer ce type d'activité prédéfinie !",FALSE,10,"OK","",FALSE,OUTPUT cRetour).
        RETURN.
    END.
    RUN Creation(ttActivites.idActivite,OUTPUT lRetourProcedure).
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Du_jour
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Du_jour C-Win
ON CHOOSE OF MENU-ITEM m_Du_jour /* Du jour */
DO:
    RUN AfficheFrame("Criteres","J").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Du_mois
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Du_mois C-Win
ON CHOOSE OF MENU-ITEM m_Du_mois /* Du mois */
DO:
    RUN AfficheFrame("Criteres","M").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Fin_de_journée
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Fin_de_journée C-Win
ON CHOOSE OF MENU-ITEM m_Fin_de_journée /* Fin de journée */
DO:
  
    RUN Predefinies("FDJ",?,?,OUTPUT lRetourProcedure).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Interruption
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Interruption C-Win
ON CHOOSE OF MENU-ITEM m_Interruption /* Interruption */
DO:
  
    RUN Predefinies("INTERRUPTION",?,?,OUTPUT lRetourProcedure).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Modifier_lactivité_en_cours
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Modifier_lactivité_en_cours C-Win
ON CHOOSE OF MENU-ITEM m_Modifier_lactivité_en_cours /* Modifier l'activité sélectionnée */
DO:
    
    IF NOT(AVAILABLE(ttActivites)) THEN RETURN.
    RUN DonneOrdre("MODIFIER").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Pause
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Pause C-Win
ON CHOOSE OF MENU-ITEM m_Pause /* Pause */
DO:
  
    RUN Predefinies("PAUSE",?,?,OUTPUT lRetourProcedure).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Reprise
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Reprise C-Win
ON CHOOSE OF MENU-ITEM m_Reprise /* Reprise de l'activité sélectionnée */
DO:
    
    IF NOT(AVAILABLE(ttActivites)) THEN RETURN.
    IF lookup(ttActivites.cTypeActivite,cPredefinis) <> 0 THEN DO:
        RUN AfficheMessageAvecTemporisation("Activité","Vous ne pouvez pas reprendre une activité prédéfinie !",FALSE,10,"OK","",FALSE,OUTPUT cRetour).
        RETURN.
    END.
    RUN Predefinies("REPRISE",?,ttActivites.idActivite,OUTPUT lRetourProcedure).
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Reprise_de_la_dernière_acti
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Reprise_de_la_dernière_acti C-Win
ON CHOOSE OF MENU-ITEM m_Reprise_de_la_dernière_acti /* Reprise de la dernière activité */
DO:
 DEFINE BUFFER bactivite FOR activite.

    FOR LAST    bactivite NO-LOCK
        WHERE   bactivite.cUtilisateur = gcUtilisateur
        AND     lookup(bactivite.cTypeActivite,cPredefinis) = 0
        BY bactivite.dDate 
        :
        RUN Predefinies("REPRISE",?,bActivite.idActivite,OUTPUT lRetourProcedure).
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Supprimer_lactivité_en_cour
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Supprimer_lactivité_en_cour C-Win
ON CHOOSE OF MENU-ITEM m_Supprimer_lactivité_en_cour /* Supprimer l'activité sélectionnée */
DO:
  
    RUN DonneOrdre("SUPPRIMER").
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
    
    /*logDebug("Abandon (cEtatEncours = " + cEtatEncours + ")").*/
    IF cEtatEncours = "CRE"  THEN do: 
        FIND FIRST activite EXCLUSIVE-LOCK
            WHERE activite.idActivite = idActiviteEnCours
            NO-ERROR.
        IF AVAILABLE(activite) THEN DO:
            DELETE activite.
            RELEASE activite.
        END.
    END.

    RUN OpenQuery.
    RUN GereEtat("VIS").

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE AfficheFrame C-Win 
PROCEDURE AfficheFrame :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER cNomFrame-in AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER cTypeRapport-in AS CHARACTER NO-UNDO.

DEFINE VARIABLE dTempo AS DATE NO-UNDO.

IF cNomFrame-in = "Criteres" THEN DO:
    /*FRAME frmModule:sensitive = FALSE.*/
    FRAME frmCriteres:VISIBLE = TRUE.
    FRAME frmCriteres:SENSITIVE = TRUE.
    ENABLE ALL WITH FRAME frmCriteres.
    DO WITH FRAME frmCriteres:
        IF cTypeRapport-in = "J" THEN DO:
            btnValider:PRIVATE-DATA = "J,ce,jour".
            filDateDebut:SCREEN-VALUE = STRING(dDate,"99/99/9999").
            filDateFin:SCREEN-VALUE = STRING(dDate,"99/99/9999").
        END.
        IF cTypeRapport-in = "S" THEN DO:
           btnValider:PRIVATE-DATA = "S,cette,semaine".
           dTempo = dDate - WEEKDAY(dDate) + 2 .
           filDateDebut:SCREEN-VALUE = STRING(dTempo,"99/99/9999").
           filDateFin:SCREEN-VALUE = STRING(dTempo + 4,"99/99/9999").
        END.
        IF cTypeRapport-in = "M" THEN DO:
          btnValider:PRIVATE-DATA = "M,ce,mois".
          dTempo = DATE(MONTH(dDate),01,YEAR(dDate)).
          filDateDebut:SCREEN-VALUE = STRING(dTempo,"99/99/9999").
          dTempo = ADD-INTERVAL(dTempo,1,"months") - 1.
          filDateFin:SCREEN-VALUE = STRING(dTempo,"99/99/9999").
        END.
        IF cTypeRapport-in = "P" THEN DO:
            btnValider:PRIVATE-DATA = "P,cette,période".
        END.
        IF cTypeRapport-in <> "P" THEN DO:
            filDateDebut:SENSITIVE = FALSE.
            filDateFin:SENSITIVE = FALSE.
        END.
    END.
    
END.

IF cNomFrame-in = "Activites" THEN DO:
    FRAME frmCriteres:VISIBLE = FALSE.
    FRAME frmModule:sensitive = TRUE.
END.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CentreJour C-Win 
PROCEDURE CentreJour :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE iPositionX AS INTEGER NO-UNDO.

    DO WITH FRAME frmModule:
        iPositionX = filDate:X + (filDate:WIDTH-P / 2).
        btnJour:X = iPositionX - (btnJour:WIDTH-P / 2) - 3.
        /*btnJour:SENSITIVE = FALSE.*/
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ChangeDate C-Win 
PROCEDURE ChangeDate :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER iIncrement-in AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER cUnite-in AS CHARACTER NO-UNDO.

DO WITH FRAME frmModule:
    IF iIncrement-in <> 0 THEN DO:
        dDate = DATE(filDate:SCREEN-VALUE).
        dDate = add-interval(dDate,iIncrement-in,cUnite-in).
        filDate:SCREEN-VALUE = STRING(dDate,"99/99/9999").
        
    END.

    /* Raffraichissement de la liste */
    idActiviteEnCours = 0.
    RUN OpenQuery.
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ChargeCodes C-Win 
PROCEDURE ChargeCodes :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE cListe AS CHARACTER NO-UNDO.
    
    DO WITH FRAME frmModule:
        FOR EACH    activite    NO-LOCK
            WHERE   activite.cUtilisateur = gcUtilisateur
            AND     (NOT lRechercheDescendante OR (lRechercheDescendante AND activite.cTypeActivite = cmbtache:SCREEN-VALUE))
            AND     (activite.cCodeActivite <> "")
            BREAK BY activite.cCodeActivite
            :
            IF first-of(activite.cCodeActivite) THEN DO:
                cListe = cListe + (IF cListe <> "" THEN "," ELSE "") + activite.cCodeActivite.
            END.
        END.
        cmbCode:LIST-ITEMS = "," + cListe.

        cmbCode:INNER-LINES = (IF NUM-ENTRIES(cListe) < 10 THEN NUM-ENTRIES(cListe) + 1 ELSE 10).
    END.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ChargeLibelles C-Win 
PROCEDURE ChargeLibelles :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE cListe AS CHARACTER NO-UNDO.
    
    DO WITH FRAME frmModule:
        FOR EACH    activite    NO-LOCK
            WHERE   activite.cUtilisateur = gcUtilisateur
            AND     (
                    NOT lRechercheDescendante 
                    OR (lRechercheDescendante 
                        AND (
                            activite.cTypeActivite = cmbtache:SCREEN-VALUE 
                            AND activite.cCodeActivite = cmbCode:SCREEN-VALUE
                            AND activite.cSousCodeActivite = cmbSousCode:SCREEN-VALUE
                            )
                       )
                    )
            AND     activite.cLibelleActivite <> ""
            BREAK BY activite.cLibelleActivite
            :
            IF first-of(activite.cLibelleActivite) THEN DO:
                cListe = cListe + (IF cListe <> "" THEN cSeparateur ELSE "") + activite.cLibelleActivite.
            END.
        END.
        cmblibelle:LIST-ITEMS = cSeparateur + cListe.
        cmblibelle:INNER-LINES = (IF NUM-ENTRIES(cListe,cSeparateur) < 10 THEN NUM-ENTRIES(cListe,cSeparateur) + 1 ELSE 10).
    END.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ChargeListe C-Win 
PROCEDURE ChargeListe :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE VARIABLE iHeureRef AS INT64 NO-UNDO INIT ?.
DEFINE VARIABLE iDureeTotale AS INT64 NO-UNDO INIT 0.
DEFINE VARIABLE iDureePause AS INT64 NO-UNDO INIT 0.
DEFINE VARIABLE iDureeRepas AS INT64 NO-UNDO INIT 0.
DEFINE VARIABLE iDureeAbsence AS INT64 NO-UNDO INIT 0.
DEFINE VARIABLE iDureeHorsPauses AS INT64 NO-UNDO INIT 0.

    DO WITH FRAME frmModule:
    
        dDate = DATE(filDate:SCREEN-VALUE).

        EMPTY TEMP-TABLE ttActivites.

        FOR EACH    activite   NO-LOCK
            WHERE   ACTIVITE.cUtilisateur = gcUtilisateur
            AND     ACTIVITE.dDate = dDate
            :
            CREATE ttActivites.
            BUFFER-COPY activite TO ttactivites.
        END.
    
        /* Calcul des durées */
        FOR EACH ttactivites
            BREAK BY ttactivites.iHeureDebut DESC
            :
            IF ttactivites.cTypeActivite = "DDJ" THEN NEXT.
            IF iHeureRef <> ? THEN do:
                ttactivites.iduree = iHeureRef - ttactivites.iHeureDebut.
            END.
            ELSE DO:
                IF ttactivites.cTypeActivite <> "FDJ" THEN ttactivites.iduree = 0.
            END.
            iHeureRef = ttactivites.iHeureDebut.
        END.
    
        /* Calcul du total */
        FOR EACH ttactivites
            BY ttactivites.iHeureDebut
            :
            IF ttactivites.cTypeActivite = "PAUSE" THEN iDureePause = iDureePause + ttactivites.iduree.
            IF ttactivites.cTypeActivite = "REPAS" THEN iDureeRepas = iDureeRepas + ttactivites.iduree.
            IF ttactivites.cTypeActivite = "ABSENCE" THEN iDureeAbsence = iDureeAbsence + ttactivites.iduree.
            IF ttactivites.cTypeActivite <> "FDJ" THEN iDureeTotale = iDureeTotale + ttactivites.iduree.
            IF ttactivites.cTypeActivite = "FDJ" THEN do:
                ttactivites.iduree = iDureeTotale.
                iDureeHorsPauses = iDureeTotale - iDureePause - iDureeRepas - iDureeAbsence.
                ttactivites.cCommentaire = "Abs:" + STRING(iDureeAbsence,"hh:mm") + " / Pause:" + STRING(iDureePause,"hh:mm") + " / Repas:" + STRING(iDureeRepas,"hh:mm") + " / Trav:" + STRING(iDureeHorsPauses,"hh:mm").
            END.
            /* maj de la table réelle */
            FIND FIRST  activite EXCLUSIVE-LOCK
                WHERE   activite.idActivite = ttactivites.idActivite
                NO-ERROR.
            activite.iDureeActivite = ttactivites.iduree.
            IF ttactivites.cTypeActivite = "FDJ" THEN activite.cCommentaire = ttactivites.cCommentaire.
    
        END.
        
        iDureeHorsPauses = iDureeTotale - iDureePause - iDureeRepas - iDureeAbsence.
        EMPTY TEMP-TABLE ttResume.
        CREATE ttResume.
        ttResume.cCode = "Total". ttResume.cValeur = STRING(iDureeTotale,"hh:mm").
        CREATE ttResume.
        ttResume.cCode = "Absence". ttResume.cValeur = STRING(iDureeAbsence,"hh:mm").
        CREATE ttResume.
        ttResume.cCode = "Pause". ttResume.cValeur = STRING(iDureePause,"hh:mm").
        CREATE ttResume.
        ttResume.cCode = "Repas". ttResume.cValeur = STRING(iDureeRepas,"hh:mm").
        CREATE ttResume.
        ttResume.cCode = "Travail". ttResume.cValeur = STRING(iDureeHorsPauses,"hh:mm").
        {&OPEN-QUERY-brwResume}
        brwResume:SENSITIVE = FALSE.
    END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ChargeSousCodes C-Win 
PROCEDURE ChargeSousCodes :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE cListe AS CHARACTER NO-UNDO.
    
    DO WITH FRAME frmModule:
        FOR EACH    activite    NO-LOCK
            WHERE   activite.cUtilisateur = gcUtilisateur
            AND     (NOT lRechercheDescendante OR (lRechercheDescendante AND (activite.cTypeActivite = cmbtache:SCREEN-VALUE AND activite.cCodeActivite = cmbCode:SCREEN-VALUE)))
            AND     (activite.cSousCodeActivite <> "")
            BREAK BY activite.cSousCodeActivite
            :
            IF first-of(activite.cSousCodeActivite) THEN DO:
                cListe = cListe + (IF cListe <> "" THEN "," ELSE "") + activite.cSousCodeActivite.
            END.
        END.
        cmbSousCode:LIST-ITEMS = "," + cListe.

        cmbSousCode:INNER-LINES = (IF NUM-ENTRIES(cListe) < 10 THEN NUM-ENTRIES(cListe) + 1 ELSE 10).
    END.
    

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ChargeTaches C-Win 
PROCEDURE ChargeTaches :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE cListe AS CHARACTER NO-UNDO.
    DEFINE VARIABLE iPredefinis AS INTEGER NO-UNDO.

    cPredefinis = "INTERRUPTION,ABSENCE,PAUSE,REPAS,REPRISE,DDJ,FDJ".    
    iPredefinis = NUM-ENTRIES(cPredefinis).

    DO WITH FRAME frmModule:
        FOR EACH    activite    NO-LOCK
            WHERE   activite.cUtilisateur = gcUtilisateur
            AND     (activite.cTypeActivite <> "" AND lookup(activite.cTypeActivite,cPredefinis) = 0)
            BREAK BY activite.cTypeActivite
            :
            IF first-of(activite.cTypeActivite) THEN DO:
                cListe = cListe + (IF cListe <> "" THEN "," ELSE "") + activite.cTypeActivite.
            END.
        END.
        cmbtache:LIST-ITEMS = "," + cListe.

        cmbtache:INNER-LINES = (IF NUM-ENTRIES(cListe) < 10 THEN NUM-ENTRIES(cListe) + iPredefinis ELSE 10).
    END.
    
    RUN ChargeCodes.
    RUN ChargeSousCodes.
    RUN ChargeLibelles.

    DO WITH FRAME frmCriteres:
        cmbCritereTache:LIST-ITEMS = cmbtache:LIST-ITEMS IN FRAME frmModule.
        cmbCritereCode:LIST-ITEMS = cmbCode:LIST-ITEMS IN FRAME frmModule.
        cmbCritereSousCode:LIST-ITEMS = cmbSousCode:LIST-ITEMS IN FRAME frmModule.
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
DEFINE INPUT PARAMETER iidActivite-in AS INTEGER NO-UNDO.
DEFINE OUTPUT PARAMETER lRetour-ou AS LOGICAL NO-UNDO.

    DEFINE VARIABLE idProchaineActivite AS INT64 NO-UNDO INIT 1.
    DEFINE BUFFER bactivite FOR activite.

    /* Si pas encore d'activité, on génère la ligne de ébut de journée */
    FIND FIRST  bactivite NO-LOCK
        WHERE   bactivite.cUtilisateur = gcUtilisateur
        AND     bactivite.dDate = dDate
        NO-ERROR.
    IF NOT AVAILABLE(bactivite) THEN DO:
        RUN predefinies("DDJ",?,?,OUTPUT lRetourProcedure).
        IF NOT(lRetourProcedure) THEN RETURN.
    END.

    /* recherche du prochain numero d'activite */
    FIND LAST   activite USE-INDEX ix_activite02
        EXCLUSIVE-LOCK
        NO-ERROR.
    IF AVAILABLE(activite) THEN DO:
        idProchaineActivite = activite.idActivite + 1.
    END.
    RELEASE activite.

    CREATE activite.
    IF iidActivite-in = 0 THEN DO:
        ASSIGN
            activite.cUtilisateur = gcUtilisateur
            activite.dDate = dDate
            activite.iHeureDebut = DonneHeureInteger(STRING(TIME,"hh:mm"))
            activite.idActivite = idProchaineActivite
            .
    END.
    ELSE DO:
        FIND FIRST  bactivite NO-LOCK
            WHERE   bactivite.cUtilisateur = gcUtilisateur
            AND     bactivite.idActivite = iidActivite-in
            NO-ERROR.
        IF AVAILABLE bactivite THEN DO:
            BUFFER-COPY bactivite EXCEPT bactivite.idActivite TO activite
                ASSIGN activite.idActivite = idProchaineActivite.
        END.
    END.

    idActiviteEnCours = idProchaineActivite.
    RUN OpenQuery.

    IF iidActivite-in = 0 THEN RUN GereEtat("CRE").
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
  DISPLAY filRecherche filDateRecherche cmbtache cmbCode cmbSousCode cmblibelle 
          filheure edtCommentaire filDate 
      WITH FRAME frmModule IN WINDOW C-Win.
  ENABLE RECT-1 btnMoisPrecedent btnJourPrecedent btnJourSuivant btnMoisSuivant 
         btnAujourdhui filRecherche btnRecherchePrecedent btnRechercheSuivant 
         filDateRecherche btnFichier brwactivites cmbtache cmbCode cmbSousCode 
         cmblibelle filheure edtCommentaire filDate 
      WITH FRAME frmModule IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-frmModule}
  DISPLAY cmbCriteretache cmbCritereCode cmbCritereSousCode filDateDebut 
          filDateFin 
      WITH FRAME frmCriteres IN WINDOW C-Win.
  ENABLE cmbCriteretache cmbCritereCode cmbCritereSousCode filDateDebut 
         filDateFin btnValider btnAbandonner 
      WITH FRAME frmCriteres IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-frmCriteres}
  DISPLAY edtInformation 
      WITH FRAME frmInformation IN WINDOW C-Win.
  ENABLE IMAGE-1 edtInformation 
      WITH FRAME frmInformation IN WINDOW C-Win.
  VIEW FRAME frmInformation IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-frmInformation}
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
                IF DonneEtSupprimeParametre("ACTIVITE-RECHARGER") = "OUI" THEN DO:
                    /* mise à jour de la DATE du jour */
                    filDate:SCREEN-VALUE = STRING(TODAY,"99/99/9999").
                    /*RUN Affichage.*/
                    RUN Recharger.
                END.
                RUN ChargeTaches.
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
            WHEN "RECHARGE" THEN DO:
                RUN Recharger.
            END.
            WHEN "IMPRIME" THEN DO:
                RUN Impression.
            END.
            WHEN "RechargeSiVisible" THEN DO:
                IF FRAME frmModule:VISIBLE = TRUE THEN do:
                    RUN Recharger.
                END.
                /*
                ELSE DO:
                    AssigneParametre("ACTIVITE-RECHARGER","OUI").
                END.
                */
            END.
            WHEN "MODIFIER" THEN DO:
                RUN Modification(OUTPUT lRetour-ou).
            END.
            WHEN "AJOUTER" THEN DO:
                RUN Creation(0,OUTPUT lRetour-ou).
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
            WHEN "RECHERCHE" THEN DO:
                APPLY "entry" TO filRecherche IN FRAME frmModule.
            END.
        END CASE. /* fin du case */
    END. /* fin du do iboucle */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE GenerePredefinies C-Win 
PROCEDURE GenerePredefinies :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

DEFINE INPUT PARAMETER cType-in AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER dDate-in AS DATE NO-UNDO.
DEFINE INPUT PARAMETER iIdActivite-in AS INT64 NO-UNDO.
DEFINE OUTPUT PARAMETER lRetour-ou AS LOGICAL NO-UNDO INIT FALSE.

    DEFINE VARIABLE idProchaineActivite AS INT64 NO-UNDO INIT 1.
    DEFINE VARIABLE cLibelle AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cCode AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cSousCode AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cRetourDebut AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cRetourFin AS CHARACTER NO-UNDO.
    DEFINE VARIABLE iHeureEnCours AS INTEGER NO-UNDO.
    DEFINE VARIABLE dDateAUtiliser AS DATE NO-UNDO.
    DEFINE VARIABLE dDateDeRetour AS DATE NO-UNDO.
    DEFINE BUFFER bactivite FOR activite.

    dDateAUtiliser = dDate.
    dDateDeRetour = dDate.
    IF dDate-in <> ? THEN do:
        dDateAUtiliser = dDate-in.
        dDateDeRetour = dDate-in.
    END.
    IF dDate-in = ? AND cType-in = "REPRISE" THEN do:
        dDateAUtiliser = TODAY.
        dDateDeRetour = TODAY.
    END.

    /* recherche du prochain numero d'activite */
    FIND LAST   activite USE-INDEX ix_activite02
        EXCLUSIVE-LOCK
        NO-ERROR.
    IF AVAILABLE(activite) THEN DO:
        idProchaineActivite = activite.idActivite + 1.
    END.
    RELEASE activite.

    iHeureEnCours = DonneHeureInteger(STRING(TIME,"hh:mm")).
    IF dDate-in <> ? AND cType-in = "FDJ" THEN DO:
        iHeureEnCours = DonneHeureInteger("17:45").
        IF WEEKDAY(dDate-in) = 6 THEN iHeureEnCours = DonneHeureInteger("17:00").
    END.

    /* controle et correction du type d'action en entree */
    IF iIdActivite-in = 0 THEN DO:
        IF cType-in = "REPRISE" AND ttactivites.cTypeActivite = "PAUSE" THEN cType-in = "PAUSE".
        IF cType-in = "REPRISE" AND ttactivites.cTypeActivite = "REPAS" THEN cType-in = "REPAS".
        IF cType-in = "REPRISE" AND ttactivites.cTypeActivite = "FDJ" THEN cType-in = "FDJ".
        IF cType-in = "REPRISE" AND ttactivites.cTypeActivite = "DDJ" THEN cType-in = "DDJ".
        IF cType-in = "REPRISE" AND ttactivites.cTypeActivite = "ABSENCE" THEN cType-in = "ABSENCE".
        IF cType-in = "REPRISE" AND ttactivites.cTypeActivite = "INTERRUPTION" THEN RETURN.
    END.

    cLibelle = "".
    cCode = "".
    cSousCode = "".
    IF cType-in = "DDJ" THEN do:
        /* interdire de saisir 2 FDJ dans une journée */
        FIND FIRST  bactivite NO-LOCK
            WHERE   bactivite.cUtilisateur = gcUtilisateur
            AND     bactivite.dDate = dDateAUtiliser
            AND     bactivite.cTypeActivite = "DDJ"
            NO-ERROR.
        IF AVAILABLE(bactivite) THEN DO:
            RUN AfficheMessageAvecTemporisation("Activité","Il ne peut pas y avoir 2 débuts de journée dans la même journée !",FALSE,10,"OK","",FALSE,OUTPUT cRetour).
            RETURN.
        END.
        /* Il ne peut pas y avoir d'activite avant le début de journée */
        FIND FIRST  bactivite NO-LOCK
            WHERE   bactivite.cUtilisateur = gcUtilisateur
            AND     bactivite.dDate = dDateAUtiliser
            AND     bactivite.iHeureDebut < iHeureEnCours
            AND     bactivite.cTypeActivite <> "DDJ"
            NO-ERROR.
        IF AVAILABLE(bactivite) THEN DO:
            RUN AfficheMessageAvecTemporisation("Activité","Attention, il existe des activités saisies avant le début de journée. %sVoulez vous les supprimer ?",TRUE,15,"NON","",FALSE,OUTPUT cRetourDebut).
            /*IF cRetour = "NON" THEN RETURN.*/
        END.
        cLibelle = "Début de journée".
    END.
    IF cType-in = "FDJ" THEN do:
        /* interdire de saisir 2 FDJ dans une journée */
        FIND FIRST  bactivite NO-LOCK
            WHERE   bactivite.cUtilisateur = gcUtilisateur
            AND     bactivite.dDate = dDateAUtiliser
            AND     bactivite.cTypeActivite = "FDJ"
            NO-ERROR.
        IF AVAILABLE(bactivite) THEN DO:
            RUN AfficheMessageAvecTemporisation("Activité","Il ne peut pas y avoir 2 fin de journée dans la même journée !",FALSE,10,"OK","",FALSE,OUTPUT cRetour).
            RETURN.
        END.

        /* Avertir en cas de saisie FDJ et activités après */
        IF dDate-in = ? THEN DO:
            FIND FIRST  bactivite NO-LOCK
                WHERE   bactivite.cUtilisateur = gcUtilisateur
                AND     bactivite.dDate = dDateAUtiliser
                AND     bactivite.iHeureDebut > iHeureEnCours
                AND     bactivite.cTypeActivite <> "FDJ"
                NO-ERROR.
            IF AVAILABLE(bactivite) THEN DO:
                RUN AfficheMessageAvecTemporisation("Activité","Attention, il existe des activités saisies après la fin de journée. %sVoulez vous les supprimer ?",TRUE,15,"NON","",FALSE,OUTPUT cRetourFin).
                /*IF cRetour = "NON" THEN RETURN.*/
            END.
        END.

        cLibelle = "Fin de journée".
    END.

    IF cType-in = "PAUSE" THEN do:
        FIND LAST   bactivite NO-LOCK
            WHERE   bactivite.cUtilisateur = gcUtilisateur
            AND     bactivite.dDate = dDateAUtiliser
            NO-ERROR.
        IF AVAILABLE(bactivite) AND bactivite.cTypeActivite = "PAUSE" THEN DO:
            RUN AfficheMessageAvecTemporisation("Activité","Vous êtes déjà en activité de type 'PAUSE' !",FALSE,10,"OK","",FALSE,OUTPUT cRetour).
            RETURN.
        END.
        cCode = cType-in.
        cSousCode = cType-in.
        cLibelle = "Pause".
    END.

    IF cType-in = "INTERRUPTION" THEN do:
        cLibelle = "Interruption de l'activité en cours : Raison".
    END.

    IF cType-in = "REPAS" THEN do:
        FIND LAST   bactivite NO-LOCK
            WHERE   bactivite.cUtilisateur = gcUtilisateur
            AND     bactivite.dDate = dDateAUtiliser
            AND     bactivite.cTypeActivite = "REPAS"
            NO-ERROR.
        IF AVAILABLE(bactivite) THEN DO:
            RUN AfficheMessageAvecTemporisation("Activité","Vous avez déjà une activité de type 'REPAS' !",FALSE,10,"OK","",FALSE,OUTPUT cRetour).
            RETURN.
        END.
        cCode = cType-in.
        cSousCode = cType-in.
        cLibelle = "Pause déjeuner".
    END.

    CREATE activite.
    ASSIGN
        activite.cUtilisateur = gcUtilisateur
        activite.cTypeActivite = cType-in
        activite.cCodeActivite = cCode
        activite.cSousCodeActivite = cSousCode
        activite.dDate = dDateAUtiliser
        activite.iHeureDebut = iHeureEnCours
        activite.idActivite = idProchaineActivite
        activite.cLibelleActivite = cLibelle
        .
    IF cType-in = "REPRISE" THEN DO:
        IF iIdActivite-in = 0 THEN DO:
            ASSIGN
                activite.cTypeActivite = ttActivites.ctypeactivite
                activite.cCodeActivite = ttActivites.cCodeActivite
                activite.cSousCodeActivite = ttActivites.cSousCodeActivite
                activite.cLibelleActivite = ttActivites.cLibelleActivite
                activite.cCommentaire = ttActivites.cCommentaire
                .
        END.
        ELSE DO:
            FIND FIRST bactivite NO-LOCK
                WHERE bactivite.idActivite = iIdActivite-in
                NO-ERROR.
            IF AVAILABLE(bactivite) THEN DO:
                ASSIGN
                    activite.cTypeActivite = bActivite.ctypeactivite
                    activite.cCodeActivite = bActivite.cCodeActivite
                    activite.cSousCodeActivite = bActivite.cSousCodeActivite
                    activite.cLibelleActivite = bActivite.cLibelleActivite
                    activite.cCommentaire = bActivite.cCommentaire
                    .
            END.
        END.
    END.

    IF cType-in = "FDJ" AND dDate-in = ? AND cRetourFin = "OUI" THEN do:
        /* Supprimer les activités après FDJ : sur demamde !!! */
        FOR EACH    bactivite EXCLUSIVE-LOCK
            WHERE   bactivite.cUtilisateur = gcUtilisateur
            AND     bactivite.dDate = dDateAUtiliser
            AND     bactivite.iHeureDebut > iHeureEnCours
            AND     bactivite.cTypeActivite <> "FDJ"
            :
            DELETE bactivite.
        END.
    END.
    IF cType-in = "DDJ" AND cRetourDebut = "OUI" THEN do:
        /* Supprimer les activités avant DDJ */
        FOR EACH    bactivite EXCLUSIVE-LOCK
            WHERE   bactivite.cUtilisateur = gcUtilisateur
            AND     bactivite.dDate = dDateAUtiliser
            AND     bactivite.iHeureDebut < iHeureEnCours
            AND     bactivite.cTypeActivite <> "DDJ"
            :
            DELETE bactivite.
        END.
    END.



    RELEASE activite NO-ERROR.
    RELEASE bactivite NO-ERROR.
    idActiviteEnCours = idProchaineActivite.
    dDate = dDateDeRetour.
    filDate:SCREEN-VALUE IN FRAME frmModule = STRING(dDate,"99/99/9999").
    RUN OpenQuery.

    lRetour-ou = TRUE.

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
    gcAideAjouter = "Ajouter une activité".
    gcAideModifier = "Modifier une activité".
    gcAideSupprimer = "Supprimer une activité".
    gcAideImprimer = "Imprimer les activités de la semaine en cours".
    gcAideRaf = "Recharger la liste des activités".

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
    DEFINE VARIABLE lPredefini AS LOGICAL NO-UNDO.

    lEtat = (cEtat-in = "VIS").
    
    DO WITH FRAME frmModule :
        /* Zone de saisie */
        cmbTache:SENSITIVE = not(lEtat).
        cmbCode:SENSITIVE = not(lEtat).
        cmbSousCode:SENSITIVE = not(lEtat).
        cmbLibelle:SENSITIVE = not(lEtat).
        filHeure:SENSITIVE = not(lEtat).
        edtCommentaire:SENSITIVE = not(lEtat).

        /* Items du menu popup */
        MENU-ITEM m_Début_de_journée:SENSITIVE IN MENU POPUP-MENU-brwactivites = (lEtat).
        MENU-ITEM m_Fin_de_journée:SENSITIVE IN MENU POPUP-MENU-brwactivites = (lEtat).
        MENU-ITEM m_Pause:SENSITIVE IN MENU POPUP-MENU-brwactivites = (lEtat).
        MENU-ITEM m_Absence:SENSITIVE IN MENU POPUP-MENU-brwactivites = (lEtat).
        MENU-ITEM m_Déjeuner:SENSITIVE IN MENU POPUP-MENU-brwactivites = (lEtat).
        MENU-ITEM m_Reprise:SENSITIVE IN MENU POPUP-MENU-brwactivites = (lEtat).
        
        /* Recherche */
        btnJourPrecedent:SENSITIVE = (lEtat).
        btnJourSuivant:SENSITIVE = (lEtat).
        btnMoisPrecedent:SENSITIVE = (lEtat).
        btnMoisSuivant:SENSITIVE = (lEtat).
        filDate:SENSITIVE = (lEtat).
        filRecherche:SENSITIVE = (lEtat).
        btnRechercheSuivant:SENSITIVE = (lEtat).
        btnRecherchePrecedent:SENSITIVE = (lEtat).
        filDateRecherche:SENSITIVE = (lEtat).
        btnFichier:SENSITIVE = (lEtat).

        /* Rapports */
        MENU-ITEM m_Du_jour:SENSITIVE IN MENU POPUP-MENU-brwactivites = (lEtat).
        MENU-ITEM m_Depuis_une_date:SENSITIVE IN MENU POPUP-MENU-brwactivites = (lEtat).
        MENU-ITEM m_De_la_semaine:SENSITIVE IN MENU POPUP-MENU-brwactivites = (lEtat).
        MENU-ITEM m_Du_mois:SENSITIVE IN MENU POPUP-MENU-brwactivites = (lEtat).

        /* Browse des activités */
        brwActivites:SENSITIVE = (lEtat).

        /* Mémorisation de l'état demandé */
        cEtatEnCours = cEtat-in.
    
        /* Gestion de l'état des zones de saisie */
        RUN GereZones.
    
        /* positionnement sur la bonne zone de saisie */
        lPredefini = (lookup(cmbTache:SCREEN-VALUE,cPredefinis) > 0).
        IF not(lEtat) THEN do:
            APPLY "ENTRY" TO cmbTache IN FRAME frmModule.
        END.
        IF lPredefini THEN DO:
            cmbTache:SENSITIVE = FALSE.
            IF cmbTache:SCREEN-VALUE = "DDJ" OR cmbTache:SCREEN-VALUE = "FDJ" THEN DO:
                cmbCode:SENSITIVE = FALSE.
                cmbSousCode:SENSITIVE = FALSE.
                cmblibelle:SENSITIVE = FALSE.
                APPLY "ENTRY" TO filheure.
            END.
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

    /* ... */
    
    IF AVAILABLE(ttActivites) THEN DO:
        /*logDebug("GereZones").*/
        DO WITH FRAME frmModule:
            cmbTache:SCREEN-VALUE = ttActivites.cTypeActivite.
            cmbCode:SCREEN-VALUE = ttActivites.cCodeActivite.
            cmbSousCode:SCREEN-VALUE = ttActivites.cSousCodeActivite.
            cmbLibelle:SCREEN-VALUE = ttActivites.cLibelleActivite.
            filHeure:SCREEN-VALUE = string(ttActivites.iHeureDebut,"hh:mm").
            edtCommentaire:SCREEN-VALUE = ttactivites.cCommentaire.
        END.
    END.
    ELSE DO:
        DO WITH FRAME frmModule:
            cmbTache:SCREEN-VALUE = "".
            cmbCode:SCREEN-VALUE = "".
            cmbSousCode:SCREEN-VALUE = "".
            cmbLibelle:SCREEN-VALUE = "".
            filHeure:SCREEN-VALUE = "".
            edtCommentaire:SCREEN-VALUE = "".
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
    RUN AfficheFrame("Criteres","S").
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
    DEFINE VARIABLE cLigne AS CHARACTER NO-UNDO.
    DEFINE VARIABLE dDateDeControle AS DATE NO-UNDO.
    DEFINE VARIABLE lFDJTrouve AS LOGICAL NO-UNDO.
    DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cFichier AS CHARACTER NO-UNDO.
    

    DEFINE BUFFER cActivite FOR Activite.
    
    FRAME frmModule:COLUMN = gdPositionXModule.
    FRAME frmModule:ROW = gdPositionYModule.

    RUN AfficheFrame("Activites",?).

    AfficheInformations("Chargement des activités",0).

    /* controle de la présence de FDJ depuis la dernière connexion */
    dDateDeControle = DATE(DonnePreference("DERNIERE_CONNEXION")).
    cMessage = "".
    FOR EACH    cActivite   NO-LOCK
        WHERE   cActivite.cUtilisateur = gcUtilisateur
        AND     cActivite.dDate >= dDateDeControle
        AND     cActivite.dDate < TODAY
        BREAK BY cActivite.dDate
        :
        IF FIRST-OF(cActivite.dDate) THEN lFDJTrouve = FALSE.
        IF cActivite.cTypeActivite = "FDJ" THEN lFDJTrouve = TRUE.
        IF LAST-OF(cActivite.dDate) AND lFDJTrouve = FALSE THEN DO:
            RUN Predefinies("FDJ",cActivite.dDate,?,OUTPUT lRetourProcedure).
            cMessage = cMessage + (IF cMessage <> "" THEN CHR(10) ELSE "")
                + "Génération FDJ pour le : " + STRING(cActivite.dDate,"99/99/9999")
                + (IF lRetourProcedure = FALSE THEN " -> Erreur" ELSE "")
                .
        END.
    END.
    SauvePreference("DERNIERE_CONNEXION",STRING(TODAY,"99/99/9999")).

    lREchercheDescendante = (DonnePreference("PREFS_AFAIRE_RECHERCHE_DESCENDANTE") = "oui").

    IF cMessage <> "" THEN DO:
        cMessage = cMessage + CHR(10) + "Merci de contrôler ces jours pour vérifier si les activités sont correctes.". 
        /*RUN AfficheMessageAvecTemporisation("Activité",cMessage,FALSE,30,"OK","",FALSE,OUTPUT cRetour).*/
        cFichier = OS-GETENV("TMP") + "\Corrections_Activités.txt".
        OUTPUT STREAM sEdition TO VALUE(cFichier).
        PUT STREAM sEdition UNFORMATTED cMessage SKIP.
        OUTPUT STREAM sEdition CLOSE.
        OS-COMMAND NO-WAIT VALUE("notepad.exe """ + cFichier + """"). 
    END.

    RUN ChargeTaches.
    
    AfficheInformations("",0).
    RUN TopChronoGeneral.
    RUN TopChronoPartiel.

    RUN GereEtat("VIS").

    RUN OpenQuery.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE InitRecherche C-Win 
PROCEDURE InitRecherche :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
        /* Initialisation de la recherche */
        FIND FIRST rActivite NO-LOCK
            WHERE   ractivite.dDate = DATE(01,01,0001)
            NO-ERROR.

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
    
    IF NOT(AVAILABLE(ttActivites)) THEN RETURN.
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
  DEFINE VARIABLE iMarge AS INTEGER NO-UNDO.
  DEFINE VARIABLE iRectif AS INTEGER NO-UNDO INIT 4.
  
  VIEW FRAME frmModule IN WINDOW winGeneral.
    {&OPEN-BROWSERS-IN-QUERY-frmModule}
    HIDE c-win.
  ENABLE ALL WITH FRAME frmModule.

  dDate = TODAY.
  filDate:SCREEN-VALUE = STRING(dDate,"99/99/9999").
  filDateRecherche:SCREEN-VALUE = STRING(ADD-INTERVAL(dDate,-2,"month"),"99/99/9999").
  btnJour:SENSITIVE = FALSE.
  cmblibelle:DELIMITER = cSeparateur.

  /*Positioonnement et dimensionnement des zones dee saisie */
  DO WITH FRAME frmModule:
      iMarge = brwActivites:X - (iRectif / 2).

      cmbTache:X = ttActivites.cTypeActivite:X IN BROWSE brwActivites + iMarge.
      cmbTache:WIDTH-PIXELS = ttActivites.cTypeActivite:WIDTH-PIXELS IN BROWSE brwActivites + iRectif.

      cmbCode:X = ttActivites.cCodeActivite:X IN BROWSE brwActivites + iMarge.
      cmbCode:WIDTH-PIXELS = ttActivites.cCodeActivite:WIDTH-PIXELS IN BROWSE brwActivites + iRectif.

      cmbSousCode:X = ttActivites.cSousCodeActivite:X IN BROWSE brwActivites + iMarge.
      cmbSousCode:WIDTH-PIXELS = ttActivites.cSousCodeActivite:WIDTH-PIXELS IN BROWSE brwActivites + iRectif.

      cmbLibelle:X = ttActivites.cLibelleActivite:X IN BROWSE brwActivites + iMarge.
      cmbLibelle:WIDTH-PIXELS = ttActivites.cLibelleActivite:WIDTH-PIXELS IN BROWSE brwActivites + iRectif.

      filHeure:X = ttActivites.iHeureDebut:X IN BROWSE brwActivites + iMarge.
      filHeure:WIDTH-PIXELS = ttActivites.iHeureDebut:WIDTH-PIXELS IN BROWSE brwActivites + iRectif.
  END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenQuery C-Win 
PROCEDURE OpenQuery :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    
    RUN ChargeListe.


    OPEN QUERY brwActivites FOR EACH ttactivites.

    /* pour synchroniser l'ascenseur */
    DO WITH FRAME frmModule:
        btnJour:LABEL = entry(WEEKDAY(date(filDate:SCREEN-VALUE)),cListeJours).
        RUN CentreJour.
        QUERY brwActivites:GET-LAST().
        QUERY brwActivites:GET-FIRST().
        brwActivites:REFRESH() NO-ERROR.
    END.

    /* repositionnement sur la ligne en cours */
    IF idActiviteEnCours <> 0 THEN DO:
        FIND FIRST ttactivites
            WHERE  ttactivites.idActivite = idActiviteEnCours
            NO-ERROR.
        IF AVAILABLE(ttactivites) THEN DO:
            REPOSITION brwActivites TO RECID RECID(ttactivites) NO-ERROR.
        END.
    END.

    APPLY "VALUE-CHANGED" TO brwActivites.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Predefinies C-Win 
PROCEDURE Predefinies :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

DEFINE INPUT PARAMETER cType-in AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER dDate-in AS DATE NO-UNDO.
DEFINE INPUT PARAMETER iIdActivite-in AS INT64 NO-UNDO.
DEFINE OUTPUT PARAMETER lRetour-ou AS LOGICAL NO-UNDO.

    DEFINE VARIABLE idProchaineActivite AS INT64 NO-UNDO INIT 1.
    DEFINE VARIABLE cLibelle AS CHARACTER NO-UNDO.
    DEFINE VARIABLE iHeureEnCours AS INTEGER NO-UNDO.
    DEFINE VARIABLE dDateAUtiliser AS DATE NO-UNDO.
    DEFINE VARIABLE dDateDeRetour AS DATE NO-UNDO.
    DEFINE BUFFER bactivite FOR activite.

    dDateAUtiliser = dDate.
    dDateDeRetour = dDate.
    IF dDate-in <> ? THEN do:
        dDateAUtiliser = dDate-in.
        dDateDeRetour = dDate-in.
    END.
    IF dDate-in = ? AND cType-in = "REPRISE" THEN do:
        dDateAUtiliser = TODAY.
        dDateDeRetour = dDate.
    END.

    /* Si pas encore d'activité, on génère la ligne de début de journée */
    FIND FIRST  bactivite NO-LOCK
        WHERE   bactivite.cUtilisateur = gcUtilisateur
        AND     bactivite.dDate = dDateAUtiliser
        AND     bactivite.cTypeActivite = "DDJ"
        NO-ERROR.
    IF NOT AVAILABLE(bactivite) THEN DO:
        RUN GenerePredefinies("DDJ",dDateAUtiliser,?,OUTPUT lRetour-ou).
        IF NOT(lRetour-ou) THEN RETURN.
    END.

    IF cType-in <> "DDJ" THEN RUN GenerePredefinies(cType-in,dDate-in,iIdActivite-in, OUTPUT lRetour-ou).

    IF cType-in = "ABSENCE" OR cType-in = "INTERRUPTION" THEN DO WITH FRAME frmModule:
        lPasControle = TRUE.
        RUN DonneOrdre("MODIFIER").
        APPLY "entry" TO cmbCode.
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Rafraichir C-Win 
PROCEDURE Rafraichir :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  DO WITH FRAME frmModule:

    /* ouverture du query */
    RUN OpenQuery.
  END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Rapport C-Win 
PROCEDURE Rapport :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER cInfosRapport-in AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER cType-in AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER cCode-in AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER cSousCode-in AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER dDebut-in AS DATE NO-UNDO.
    DEFINE INPUT PARAMETER dFin-in AS DATE NO-UNDO.

    DEFINE VARIABLE cFichier AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lEntete AS LOGICAL NO-UNDO INIT FALSE.
    DEFINE VARIABLE cCommentaireEpure AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cTypeRapport AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cGenreEtType AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cHorodatage AS CHARACTER NO-UNDO.
    DEFINE VARIABLE dTempo as DATE NO-UNDO.
    DEFINE VARIABLE iBoucle AS INTEGER NO-UNDO.
    DEFINE VARIABLE cQuotidien AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cTitreEdition AS CHARACTER NO-UNDO.
        
    DEFINE BUFFER bttstats FOR ttstats.

    cTypeRapport = ENTRY(1,cInfosRapport-in).
    cGenreEtType = ENTRY(2,cInfosRapport-in) +  " " + ENTRY(3,cInfosRapport-in).
    cHorodatage = STRING(YEAR(TODAY),"9999") + STRING(MONTH(TODAY),"99") + STRING(DAY(TODAY),"99")
        + "_" + replace(STRING(TIME,"hh:mm:ss"),":","")
        .

    IF cTypeRapport = "P" THEN DO:
        IF dDebut-in = ? THEN DO:
            RUN AfficheMessageAvecTemporisation("Activité","Merci de saisir une date de début",FALSE,10,"OK","",FALSE,OUTPUT cRetour).
            RETURN.
        END.
        IF dFin-in = ? THEN DO:
            RUN AfficheMessageAvecTemporisation("Activité","Merci de saisir une date de fin",FALSE,10,"OK","",FALSE,OUTPUT cRetour).
            RETURN.
        END.
    END.

    IF dFin-in < dDebut-in THEN DO:
        RUN AfficheMessageAvecTemporisation("Activité","Incohérence dans les dates",FALSE,5,"OK","",FALSE,OUTPUT cRetour).
        RETURN.
    END.


    cTitreEdition = "Activité de " + DonneVraiNomUtilisateur(gcutilisateur)
        + " ( Type : " + (IF cType-in <> ? THEN cType-in ELSE "Tous") 
        + " , Code : " + (IF cCode-in <> ? THEN cCode-in ELSE "Tous") 
        + " , Du : " + string(dDebut-in,"99/99/9999")
        + (IF dDebut-in <> dFin-in THEN " au : " + string(dFin-in,"99/99/9999") else "")
        + " )"
        .

    DO WITH FRAME frmModule:
        cFichier = OS-GETENV("TMP") + "\Rapport_" + cTypeRapport + "_" + cHorodatage + ".csv".
        
        EMPTY TEMP-TABLE ttExtraction.

        /* extraction */
        FOR EACH    rActivite
            WHERE   rActivite.cUtilisateur = gcutilisateur
            AND     rActivite.dDate >= dDebut-in
            AND     rActivite.dDate <= dFin-in
            AND     (cType-in = ? OR rActivite.cTypeActivite = cType-in)
            AND     (cCode-in = ? OR rActivite.cCodeActivite = cCode-in)
            AND     (cSousCode-in = ? OR rActivite.cSousCodeActivite = cSousCode-in)
           :
            CREATE ttExtraction.
            BUFFER-COPY ractivite TO ttExtraction.
            cCommentaireEpure = ttExtraction.cCommentaire.
            cCommentaireEpure = REPLACE(cCommentaireEpure,CHR(10)," ").
            cCommentaireEpure = REPLACE(cCommentaireEpure,CHR(13)," ").
            cCommentaireEpure = REPLACE(cCommentaireEpure,"  "," ").
            ttExtraction.cCommentaire = cCommentaireEpure.
        END.

        FOR EACH ttExtraction
            BREAK BY ttExtraction.dDate
            :
            IF NOT(lEntete) THEN DO:
                OUTPUT STREAM sEdition TO VALUE(cFichier).
                PUT STREAM sEdition UNFORMATTED 
                    ";;;" + cTitreEdition
                    SKIP(1).
                PUT STREAM sEdition UNFORMATTED 
                    "Date"
                    + ";" + "Type d'activité"
                    + ";" + "Code d'activité"
                    + ";" + "Sous-Code d'activité"
                    + ";" + "Libellé d'activité"
                    + ";" + "Début (hh:mm)"
                    + ";" + "Durée (hh:mm)"
                    + ";" + "Commentaire"
                    SKIP.
                lEntete = TRUE.
            END.

            PUT STREAM sEdition UNFORMATTED 
                string(ttExtraction.dDate,"99/99/9999")
                + ";" + ttExtraction.cTypeActivite
                + ";" + ttExtraction.cCodeActivite
                + ";" + ttExtraction.cSousCodeActivite
                + ";" + ttExtraction.cLibelleActivite
                + ";" + string(ttExtraction.iHeureDebut,"hh:mm")
                + ";" + string(ttExtraction.iDureeActivite,"hh:mm")
                + ";" + ttExtraction.cCommentaire
                SKIP.

            IF LAST-OF(ttExtraction.dDate) THEN DO:
                PUT STREAM sEdition UNFORMATTED " " SKIP.
            END.
        END.

    END.

    IF lEntete THEN DO:
        
        /* extraction des stats */
        RUN Statistiques(cTypeRapport,dDebut-in).
    
        PUT STREAM sEdition UNFORMATTED SKIP(1) "Cumuls par Types" SKIP
            "Type d'activité"
            + ";" + "Durée (hh:mm)"
            + ";" + (IF cTypeRapport = "S" THEN "Lundi;Mardi;Mercredi;Jeudi;Vendredi" ELSE "")
            SKIP.
        
        FOR EACH ttstats
            WHERE ttstats.iCodestat = 1
            BY ttstats.cRegroupement
            :
            /* constitution des stats par jour si rapport à la semaine */
            cQuotidien = "".
            IF cTypeRapport = "S" THEN DO:
                DO iBoucle = 0 TO 4:
                    dTempo = dDebut-in + iBoucle.
                    FIND FIRST  bttstats
                        WHERE   bttstats.icodestat = 3
                        AND     bttstats.cRegroupement = ttstats.cRegroupement
                        AND     bttstats.dDate = dTempo
                        NO-ERROR.
                    cQuotidien = cQuotidien + (IF AVAILABLE(bttstats) THEN DonneTempsReel(bttstats.ijours,bttstats.iDureeRegroupement) ELSE "") + ";".
                END.
            END.
            PUT STREAM sEdition UNFORMATTED 
                ttstats.cRegroupement
                + ";" + DonneTempsReel(ttstats.ijours,ttstats.iDureeRegroupement) + ";" + cQuotidien
                SKIP.
        END.
    
        PUT STREAM sEdition UNFORMATTED  SKIP(2) "Cumuls par Codes" SKIP
            "Code d'activité"
            + ";" + "Durée (hh:mm)"
            + ";" + (IF cTypeRapport = "S" THEN "Lundi;Mardi;Mercredi;Jeudi;Vendredi" ELSE "")
            SKIP.
        
        FOR EACH ttstats
            WHERE ttstats.iCodestat = 2
            BY ttstats.cRegroupement
            :
            /* constitution des stats par jour si rapport à la semaine */
            cQuotidien = "".
            IF cTypeRapport = "S" THEN DO:
                DO iBoucle = 0 TO 4:
                    dTempo = dDebut-in + iBoucle. 
                    FIND FIRST  bttstats
                        WHERE   bttstats.icodestat = 4
                        AND     bttstats.cRegroupement = ttstats.cRegroupement
                        AND     bttstats.dDate = dTempo
                        NO-ERROR.
                    cQuotidien = cQuotidien + (IF AVAILABLE(bttstats) THEN DonneTempsReel(bttstats.ijours,bttstats.iDureeRegroupement) ELSE "") + ";".
                END.
            END.
            PUT STREAM sEdition UNFORMATTED 
                ttstats.cRegroupement
                + ";" + DonneTempsReel(ttstats.ijours,ttstats.iDureeRegroupement) + ";" + cQuotidien
                SKIP.
        END.
    
        PUT STREAM sEdition UNFORMATTED  SKIP(2) "Cumuls par Sous-Codes" SKIP
            "Sous-Code d'activité"
            + ";" + "Durée (hh:mm)"
            + ";" + (IF cTypeRapport = "S" THEN "Lundi;Mardi;Mercredi;Jeudi;Vendredi" ELSE "")
            SKIP.
        
        FOR EACH ttstats
            WHERE ttstats.iCodestat = 5
            BY ttstats.cRegroupement
            :
            /* constitution des stats par jour si rapport à la semaine */
            cQuotidien = "".
            IF cTypeRapport = "S" THEN DO:
                DO iBoucle = 0 TO 4:
                    dTempo = dDebut-in + iBoucle. 
                    FIND FIRST  bttstats
                        WHERE   bttstats.icodestat = 6
                        AND     bttstats.cRegroupement = ttstats.cRegroupement
                        AND     bttstats.dDate = dTempo
                        NO-ERROR.
                    cQuotidien = cQuotidien + (IF AVAILABLE(bttstats) THEN DonneTempsReel(bttstats.ijours,bttstats.iDureeRegroupement) ELSE "") + ";".
                END.
            END.
            PUT STREAM sEdition UNFORMATTED 
                ttstats.cRegroupement
                + ";" + DonneTempsReel(ttstats.ijours,ttstats.iDureeRegroupement) + ";" + cQuotidien
                SKIP.
        END.
    
        PUT STREAM sEdition UNFORMATTED  SKIP(2) "Cumuls par Types/Codes/Sous-Codes" SKIP
            "Type/Code/Sous-Code"
            + ";" + "Durée (hh:mm)"
            + ";" + (IF cTypeRapport = "S" THEN "Lundi;Mardi;Mercredi;Jeudi;Vendredi" ELSE "")
            SKIP.
        
        FOR EACH ttstats
            WHERE ttstats.iCodestat = 7
            BY ttstats.cRegroupement
            :
            /* constitution des stats par jour si rapport à la semaine */
            cQuotidien = "".
            IF cTypeRapport = "S" THEN DO:
                DO iBoucle = 0 TO 4:
                    dTempo = dDebut-in + iBoucle. 
                    FIND FIRST  bttstats
                        WHERE   bttstats.icodestat = 8
                        AND     bttstats.cRegroupement = ttstats.cRegroupement
                        AND     bttstats.dDate = dTempo
                        NO-ERROR.
                    cQuotidien = cQuotidien + (IF AVAILABLE(bttstats) THEN DonneTempsReel(bttstats.ijours,bttstats.iDureeRegroupement) ELSE "") + ";".
                END.
            END.
            PUT STREAM sEdition UNFORMATTED 
                ttstats.cRegroupement
                + ";" + DonneTempsReel(ttstats.ijours,ttstats.iDureeRegroupement) + ";" + cQuotidien
                SKIP.
        END.
    
        OUTPUT STREAM sEdition CLOSE.

        OS-COMMAND NO-WAIT VALUE(cFichier).
    END.
    ELSE DO:
        RUN AfficheMessageAvecTemporisation("Activité","Aucune activité pour " + cGenreEtType,FALSE,5,"OK","",FALSE,OUTPUT cRetour).
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
    RUN Initialisation.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE RechercheDansFichier C-Win 
PROCEDURE RechercheDansFichier :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE cRecherche AS CHARACTER NO-UNDO.
    DEFINE VARIABLE dRecherche AS DATE NO-UNDO.
    DEFINE VARIABLE cFichier AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lEntete AS LOGICAL NO-UNDO INIT FALSE.
    DEFINE VARIABLE cCommentaireEpure AS CHARACTER NO-UNDO.

    DO WITH FRAME frmModule:
        cRecherche = "*" + filRecherche:SCREEN-VALUE + "*".
    
        dRecherche = DATE(filDateRecherche:SCREEN-VALUE).
    
        cFichier = OS-GETENV("TMP") + "\Recherche_Activité.csv".
        OUTPUT STREAM sRecherche TO VALUE(cFichier).
    
        /* Recherche tout */
        FOR EACH    rActivite
            WHERE   rActivite.cUtilisateur = gcutilisateur
            AND     rActivite.dDate >= dRecherche
            and     (rActivite.cTypeActivite MATCHES cRecherche
                     OR
                     rActivite.cCodeActivite MATCHES cRecherche
                     OR
                     rActivite.cSousCodeActivite MATCHES cRecherche
                     OR
                     rActivite.cLibelleActivite MATCHES cRecherche
                     OR
                     rActivite.cCommentaire MATCHES cRecherche)
            :
            IF NOT(lEntete) THEN DO:
                PUT STREAM sRecherche UNFORMATTED 
                    "Date"
                    + ";" + "Type d'activité"
                    + ";" + "Code d'activité"
                    + ";" + "Sous-Code d'activité"
                    + ";" + "Libellé d'activité"
                    + ";" + "Début"
                    + ";" + "Durée"
                    + ";" + "Commentaire"
                    SKIP.
                lEntete = TRUE.
            END.

            cCommentaireEpure = rActivite.cCommentaire.
            cCommentaireEpure = REPLACE(cCommentaireEpure,CHR(10)," ").
            cCommentaireEpure = REPLACE(cCommentaireEpure,CHR(13)," ").
            cCommentaireEpure = REPLACE(cCommentaireEpure,"  "," ").

            PUT STREAM sRecherche UNFORMATTED 
                string(rActivite.dDate,"99/99/9999")
                + ";" + rActivite.cTypeActivite
                + ";" + rActivite.cCodeActivite
                + ";" + rActivite.cSousCodeActivite
                + ";" + rActivite.cLibelleActivite
                + ";" + string(rActivite.iHeureDebut,"hh:mm")
                + ";" + string(rActivite.iDureeActivite,"hh:mm")
                + ";" + cCommentaireEpure
                SKIP.
        END.

    END.

    OUTPUT STREAM sRecherche CLOSE.

    IF lEntete THEN DO:
        OS-COMMAND NO-WAIT VALUE(cFichier).
    END.
    ELSE DO:
        RUN AfficheMessageAvecTemporisation("Activité","La recherche n'a donné aucun résultat",FALSE,5,"OK","",FALSE,OUTPUT cRetour).
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Statistiques C-Win 
PROCEDURE Statistiques :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER cTypeRapport-in AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER dDateDepart-in AS DATE NO-UNDO.
    
    DEFINE VARIABLE ivaleur AS INT64 NO-UNDO.
    DEFINE VARIABLE iNbJours AS INT64 NO-UNDO.
    DEFINE VARIABLE iBoucle AS INTEGER NO-UNDO.
    DEFINE VARIABLE dTempo AS DATE NO-UNDO.

    EMPTY TEMP-TABLE ttStats.

    /* stats sur le type d'activite : iCodeStat = 1 */
    FOR EACH ttExtraction
        WHERE (ttExtraction.cTypeActivite <> "FDJ" AND ttExtraction.cTypeActivite <> "DDJ")
        BREAK BY ttExtraction.cTypeActivite
        :
        IF FIRST-OF(ttExtraction.cTypeActivite) THEN DO:
            iValeur = 0.
        END.

        iValeur = iValeur + ttExtraction.idureeActivite.

        IF LAST-OF(ttExtraction.cTypeActivite) THEN DO:
            CREATE ttstats.
            ttstats.iCodestat = 1.
            ttstats.cRegroupement = ttExtraction.cTypeActivite.
            ttstats.iDureeRegroupement = iValeur.
            /* détermination du nombre éventuel de jours */
            iNbJours = trunc(iValeur / (24 * 60 * 60),0).
            ttstats.iJours = iNbJours.
        END.
    END.

    /* stats sur le code d'activite : iCodeStat = 2 */
    FOR EACH ttExtraction
        /*WHERE ttExtraction.cCodeActivite <> ""*/
        WHERE (ttExtraction.cTypeActivite <> "FDJ" AND ttExtraction.cTypeActivite <> "DDJ")
        BREAK BY ttExtraction.cCodeActivite
        :
        IF FIRST-OF(ttExtraction.cCodeActivite) THEN DO:
            iValeur = 0.
        END.

        iValeur = iValeur + ttExtraction.idureeActivite.

        IF LAST-OF(ttExtraction.cCodeActivite) THEN DO:
            CREATE ttstats.
            ttstats.iCodestat = 2.
            ttstats.cRegroupement = ttExtraction.cCodeActivite.
            ttstats.iDureeRegroupement = iValeur.
            /* détermination du nombre éventuel de jours */
            iNbJours = trunc(iValeur / (24 * 60 * 60),0).
            ttstats.iJours = iNbJours.
        END.
    END.

    /* stats sur le sous-code d'activite : iCodeStat = 5 */
    FOR EACH ttExtraction
        WHERE (ttExtraction.cTypeActivite <> "FDJ" AND ttExtraction.cTypeActivite <> "DDJ")
        BREAK BY ttExtraction.cSousCodeActivite
        :
        IF FIRST-OF(ttExtraction.cSousCodeActivite) THEN DO:
            iValeur = 0.
        END.

        iValeur = iValeur + ttExtraction.idureeActivite.

        IF LAST-OF(ttExtraction.cSousCodeActivite) THEN DO:
            CREATE ttstats.
            ttstats.iCodestat = 5.
            ttstats.cRegroupement = ttExtraction.cSousCodeActivite.
            ttstats.iDureeRegroupement = iValeur.
            /* détermination du nombre éventuel de jours */
            iNbJours = trunc(iValeur / (24 * 60 * 60),0).
            ttstats.iJours = iNbJours.
        END.
    END.

    /* Répartition type/code/sousCode : iCodeStat = 7 */
    FOR EACH ttExtraction
        WHERE (ttExtraction.cTypeActivite <> "FDJ" AND ttExtraction.cTypeActivite <> "DDJ")
        :
        FIND FIRST  ttstats
            WHERE   ttstats.icodestat = 7
            AND     ttstats.cRegroupement = ttExtraction.cTypeActivite + "/" + ttExtraction.cCodeActivite + "/" + ttExtraction.cSousCodeActivite
            NO-ERROR.
        IF NOT(AVAILABLE(ttstats)) THEN DO:
            CREATE ttstats.
            ttstats.iCodestat = 7.
            ttstats.cRegroupement = ttExtraction.cTypeActivite + "/" + ttExtraction.cCodeActivite + "/" + ttExtraction.cSousCodeActivite.
        END.
        ttstats.iDureeRegroupement = ttstats.iDureeRegroupement + ttExtraction.idureeActivite.
        /* détermination du nombre éventuel de jours */
        iNbJours = trunc(ttstats.iDureeRegroupement / (24 * 60 * 60),0).
        ttstats.iJours = iNbJours.
    END.

    IF cTypeRapport-in = "S" THEN DO:

        /* stats sur le type par jour : iCodeStat = 3 */
        /* stats sur le code par jour : iCodeStat = 4 */
        /* stats sur le Sous-Code par jour : iCodeStat = 6 */
        /* stats sur type/code/Sous-Code par jour : iCodeStat = 8 */
        DO iBoucle = 0 TO 4:
            dTempo = dDateDepart-in + iBoucle. 
            FOR EACH ttExtraction
                WHERE (ttExtraction.cTypeActivite <> "FDJ" AND ttExtraction.cTypeActivite <> "DDJ")
                AND   ttExtraction.dDate = dTempo
                :
                /* Type */
                FIND FIRST  ttstats
                    WHERE   ttstats.icodestat = 3
                    AND     ttstats.cRegroupement = ttExtraction.cTypeActivite
                    AND     ttstats.dDate = ttExtraction.dDate
                    NO-ERROR.
                IF NOT(AVAILABLE(ttstats)) THEN DO:
                    CREATE ttstats.
                    ttstats.iCodestat = 3.
                    ttstats.cRegroupement = ttExtraction.cTypeActivite.
                    ttstats.dDate = ttExtraction.dDate.
                END.
                ttstats.iDureeRegroupement = ttstats.iDureeRegroupement + ttExtraction.idureeActivite.
                
                /* Code */
                FIND FIRST  ttstats
                   WHERE   ttstats.icodestat = 4
                   AND     ttstats.cRegroupement = ttExtraction.cCodeActivite
                   AND     ttstats.dDate = ttExtraction.dDate
                   NO-ERROR.
               IF NOT(AVAILABLE(ttstats)) THEN DO:
                   CREATE ttstats.
                   ttstats.iCodestat = 4.
                   ttstats.cRegroupement = ttExtraction.cCodeActivite.
                   ttstats.dDate = ttExtraction.dDate.
               END.
               ttstats.iDureeRegroupement = ttstats.iDureeRegroupement + ttExtraction.idureeActivite.
                
               /* Sous-Code */
               FIND FIRST  ttstats
                  WHERE   ttstats.icodestat = 6
                  AND     ttstats.cRegroupement = ttExtraction.cSousCodeActivite
                  AND     ttstats.dDate = ttExtraction.dDate
                  NO-ERROR.
              IF NOT(AVAILABLE(ttstats)) THEN DO:
                  CREATE ttstats.
                  ttstats.iCodestat = 6.
                  ttstats.cRegroupement = ttExtraction.cSousCodeActivite.
                  ttstats.dDate = ttExtraction.dDate.
              END.
              ttstats.iDureeRegroupement = ttstats.iDureeRegroupement + ttExtraction.idureeActivite.

              /* type/code/Sous-Code */
              FIND FIRST  ttstats
                 WHERE   ttstats.icodestat = 8
                 AND     ttstats.cRegroupement = ttExtraction.cTypeActivite + "/" + ttExtraction.cCodeActivite + "/" + ttExtraction.cSousCodeActivite
                 AND     ttstats.dDate = ttExtraction.dDate
                 NO-ERROR.
             IF NOT(AVAILABLE(ttstats)) THEN DO:
                 CREATE ttstats.
                 ttstats.iCodestat = 8.
                 ttstats.cRegroupement = ttExtraction.cTypeActivite + "/" + ttExtraction.cCodeActivite + "/" + ttExtraction.cSousCodeActivite.
                 ttstats.dDate = ttExtraction.dDate.
             END.
             ttstats.iDureeRegroupement = ttstats.iDureeRegroupement + ttExtraction.idureeActivite.
            END.
        END.

    END.

/*
    OUTPUT TO "d:\tmp\azza".
    FOR EACH ttstats BY ttstats.iCodestat 
        :
        EXPORT ttstats.
    END.
    OUTPUT CLOSE.
    */
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

    IF NOT(AVAILABLE(ttActivites)) THEN RETURN.

    RUN AfficheMessageAvecTemporisation("Activité","Confirmez-vous la suppression de la ligne d'activité ?",TRUE,10,"NON","",FALSE,OUTPUT cRetour).
    IF cRetour = "NON"  THEN RETURN.

    /* Prévenir en cas de suppression de la ligne DDJ */
    IF ttActivites.cTypeActivite = "DDJ" THEN DO:
        RUN AfficheMessageAvecTemporisation("Activité","Vous êtes en train de supprimer la ligne de début de journée ! %sConfirmez-vous ?",TRUE,10,"NON","",FALSE,OUTPUT cRetour).
        IF cRetour = "NON" THEN RETURN.
    END.

    DO TRANS:
        FIND FIRST activite WHERE Activite.idActivite = ttActivites.idActivite EXCLUSIVE-LOCK NO-ERROR.
        IF NOT(AVAILABLE(activite)) THEN do:
            RUN AfficheMessageAvecTemporisation("Activité","Ligne d'activité introuvable !",FALSE,5,"OK","",FALSE,OUTPUT cRetour).
            RETURN.
        END.
        DELETE activite.
    END.

    RELEASE activite.
    RUN OpenQuery.
    RUN GereEtat("VIS").

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE TopChronoGeneral C-Win 
PROCEDURE TopChronoGeneral :
/* Gestion du chrono général */

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
    DEFINE VARIABLE cAvertissement AS CHARACTER NO-UNDO.

    DEFINE BUFFER bactivite FOR activite.
    
    /* Controle des zones de saisie */
    DO WITH FRAME frmModule:
        /* Erreur */
        IF (cmbtache:SCREEN-VALUE = "" OR cmbtache:SCREEN-VALUE = ?) THEN cErreur = cErreur + "%s" + "Le type de tache n'est pas renseigné".
        IF trim(filheure:SCREEN-VALUE) = ":" THEN cErreur = cErreur + "%s" + "L'heure de début de la tache n'est pas renseigné".
        
        /* Avertissements */
        IF (cmbCode:SCREEN-VALUE = "" OR cmbCode:SCREEN-VALUE = ?) THEN cAvertissement = cAvertissement + "%s" + "Le code de tache n'est pas renseigné".
        IF (cmbSousCode:SCREEN-VALUE = "" OR cmbSousCode:SCREEN-VALUE = ?) THEN cAvertissement = cAvertissement + "%s" + "Le sous-code de tache n'est pas renseigné".
        IF (cmbLibelle:SCREEN-VALUE = "" OR cmbLibelle:SCREEN-VALUE = ?) THEN cAvertissement = cAvertissement + "%s" + "Le libellé de tache n'est pas renseigné".
    END.
    
    IF cErreur <> "" THEN DO:
        cErreur = "Erreur lors de la saisie : " + replace(cErreur,"%s",CHR(10))
            .
        RUN AfficheMessageAvecTemporisation("Activité",cErreur,FALSE,15,"OK","",FALSE,OUTPUT cRetour).
        lRetour-ou = FALSE.
        RETURN.
    END.

    IF cAvertissement <> "" THEN DO:
        cAvertissement = "Avertissement : " + replace(cAvertissement,"%s",CHR(10)) 
            + CHR(10) + "Il serait plus pratique de renseigner la ou les zones citées pour le suivi des activités."
            .
        RUN AfficheMessageAvecTemporisation("Activité",cAvertissement,FALSE,15,"OK","ACTIVITE-VALIDATION-INFO",FALSE,OUTPUT cRetour).
    END.

    DO TRANS:
    
        FIND FIRST activite WHERE Activite.idActivite = ttActivites.idActivite EXCLUSIVE-LOCK NO-ERROR.
        IF NOT(AVAILABLE(activite)) THEN do:
            RUN AfficheMessageAvecTemporisation("Activité","Ligne d'activité introuvable !",FALSE,0,"OK","",FALSE,OUTPUT cRetour).
            RETURN.
        END.
    
        /* Ecriture dans la base */
        DO WITH FRAME frmdetail:
            activite.cTypeActivite = (IF cmbTache:SCREEN-VALUE <> ? THEN cmbTache:SCREEN-VALUE ELSE "").
            activite.cCodeActivite = (IF cmbCode:SCREEN-VALUE <> ? THEN cmbCode:SCREEN-VALUE ELSE "").
            activite.cSousCodeActivite = (IF cmbSousCode:SCREEN-VALUE <> ? THEN cmbSousCode:SCREEN-VALUE ELSE "").
            activite.cLibelleActivite = (IF cmbLibelle:SCREEN-VALUE <> ? THEN cmbLibelle:SCREEN-VALUE ELSE "").
            activite.iHeureDebut = DonneHeureInteger(filHeure:SCREEN-VALUE).
            activite.cCommentaire = EdtCommentaire:SCREEN-VALUE.
        END.
    
        /* Vérification de l'heure de DDJ */
        FIND FIRST  bactivite   EXCLUSIVE-LOCK
            WHERE   bactivite.cUtilisateur = gcUtilisateur
            AND     bactivite.dDate = dDate
            AND     bactivite.cTypeActivite = "DDJ"
            NO-ERROR.

        IF AVAILABLE(bactivite) AND bactivite.iHeureDebut > activite.iHeureDebut THEN DO:
            bactivite.iHeureDebut = activite.iHeureDebut.
        END.

    END. /* Fin transaction */

    RELEASE activite.
    RUN OpenQuery.
    RUN GereEtat("VIS").
    RUN DonneOrdre("REINIT-BOUTONS").
    RUN ChargeTaches.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION AfficheInformations C-Win 
FUNCTION AfficheInformations RETURNS LOGICAL
  ( cLibelle-in AS CHARACTER,iTemporisation-in AS INTEGER ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
    DO WITH FRAME frmInformation:
        edtInformation:SCREEN-VALUE = cLibelle-in.
        ASSIGN edtInformation.
    END.
    
    IF cLibelle-in = ""  THEN DO:
        FRAME frmInformation:VISIBLE = FALSE.
    END.
    ELSE DO:
        FRAME frmInformation:VISIBLE = TRUE.
        ENABLE ALL WITH FRAME frmInformation.
        IF iTemporisation-in <> 0  THEN DO:
            /* Attente avant d'effacer la fenetre */
            RUN sleep(iTemporisation-in * 1000).
            FRAME frmInformation:VISIBLE = FALSE.
        END.
    END.

  RETURN TRUE.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION DonneHeureInteger C-Win 
FUNCTION DonneHeureInteger RETURNS INTEGER
  ( chms AS CHARACTER ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
    DEFINE VARIABLE iheures as INTEGER NO-UNDO INIT 0.
    DEFINE VARIABLE iminutes as INTEGER NO-UNDO INIT 0.
    DEFINE VARIABLE isecondes as INTEGER NO-UNDO INIT 0.
    DEFINE VARIABLE iRetour AS INTEGER NO-UNDO INIT 0.
    
    IF NUM-ENTRIES(chms,":") = 2 THEN chms = chms + ":00".
    ASSIGN
        iheures = INTEGER(ENTRY(1,chms,":"))
        iminutes = INTEGER(ENTRY(2,chms,":"))
        isecondes = INTEGER(ENTRY(3,chms,":"))
        iRetour = (iheures * 60 * 60) + (iminutes * 60) + isecondes
        .

  RETURN iRetour.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION DonneTempsReel C-Win 
FUNCTION DonneTempsReel RETURNS CHARACTER
  ( iNbJours AS INTEGER, iDuree AS INTEGER ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
    DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO INIT "".
    DEFINE VARIABLE iTempo AS INTEGER NO-UNDO.
    DEFINE VARIABLE iHeures AS INTEGER NO-UNDO.
    DEFINE VARIABLE iMinutes AS INTEGER NO-UNDO.
    DEFINE VARIABLE cTempo AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cDuree AS CHARACTER NO-UNDO.

    cDuree = STRING(iDuree,"hh:mm").
    
    iTempo = iNbJours * 24.
    iHeures = INTEGER(ENTRY(1,cDuree,":")).
    iMinutes = INTEGER(ENTRY(2,cDuree,":")).

    iTempo = iTempo + iHeures.

    cRetour = STRING(itempo,">99") + ":" + STRING(iMinutes,"99").

    RETURN cRetour.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION logDebug C-Win 
FUNCTION logDebug RETURNS LOGICAL
  ( cLibelle AS CHARACTER ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/


    OUTPUT TO VALUE("d:\tmp\debug.txt") APPEND.
    PUT UNFORMATTED cLibelle + " - ".
    EXPORT ttActivites.
    PUT UNFORMATTED " /" SKIP.
    OUTPUT CLOSE.

  RETURN TRUE.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

