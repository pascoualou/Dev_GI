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

&SCOPED-DEFINE  Caractere_Journee   CHR(197) 
&SCOPED-DEFINE  Caractere_Matin     CHR(186) 
&SCOPED-DEFINE  Caractere_ApresMidi CHR(187) 

&SCOPED-DEFINE  Couleur_Scolaire 14
&SCOPED-DEFINE  Couleur_Ferie 12
&SCOPED-DEFINE  Couleur_Conges 9
&SCOPED-DEFINE  Couleur_FormationGI 10 /*2*/
&SCOPED-DEFINE  Couleur_Autre 4 /*6*/
&SCOPED-DEFINE  Couleur_Maladie 3
&SCOPED-DEFINE  Couleur_FormationClient 2 /*4*/

&SCOPED-DEFINE Couleur_Symbole 15
&SCOPED-DEFINE Couleur_Semaine 16

/* Parameters Definitions ---                                           */

DEFINE INPUT PARAMETER  winGeneral  AS HANDLE NO-UNDO.
DEFINE INPUT PARAMETER  cParametres AS CHARACTER NO-UNDO.
/* Local Variable Definitions ---                                       */

DEFINE BUFFER bprefs FOR prefs.

    DEFINE TEMP-TABLE ttUtils
        FIELD iColonne      AS INTEGER
        FIELD cUtil      AS CHARACTER
        FIELD cVraiNom  AS CHARACTER
        FIELD lAbsence AS LOGICAL
        .

    DEFINE TEMP-TABLE ttAbsences
        FIELD cJour      AS CHARACTER
        FIELD iSemaine   AS INTEGER
        FIELD dDate      AS DATE
        FIELD lFerie     AS LOGICAL
        FIELD lScolaire     AS LOGICAL
        FIELD cAbsence   AS CHARACTER EXTENT 40
        .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME frmModule
&Scoped-define BROWSE-NAME brwAbsences

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ttAbsences

/* Definitions for BROWSE brwAbsences                                   */
&Scoped-define FIELDS-IN-QUERY-brwAbsences ttAbsences.cJour ttAbsences.cAbsence[1] ttAbsences.cAbsence[2] ttAbsences.cAbsence[3] ttAbsences.cAbsence[4] ttAbsences.cAbsence[5] ttAbsences.cAbsence[6] ttAbsences.cAbsence[7] ttAbsences.cAbsence[8] ttAbsences.cAbsence[9] ttAbsences.cAbsence[10] ttAbsences.cAbsence[11] ttAbsences.cAbsence[12] ttAbsences.cAbsence[13] ttAbsences.cAbsence[14] ttAbsences.cAbsence[15] ttAbsences.cAbsence[16] ttAbsences.cAbsence[17] ttAbsences.cAbsence[18] ttAbsences.cAbsence[19] ttAbsences.cAbsence[20] ttAbsences.cAbsence[21] ttAbsences.cAbsence[22] ttAbsences.cAbsence[23] ttAbsences.cAbsence[24] ttAbsences.cAbsence[25] ttAbsences.cAbsence[26] ttAbsences.cAbsence[27] ttAbsences.cAbsence[28] ttAbsences.cAbsence[29] ttAbsences.cAbsence[30] ttAbsences.cAbsence[31] ttAbsences.cAbsence[32] ttAbsences.cAbsence[33] ttAbsences.cAbsence[34] ttAbsences.cAbsence[35] ttAbsences.cAbsence[36] ttAbsences.cAbsence[37] ttAbsences.cAbsence[38] ttAbsences.cAbsence[39] ttAbsences.cAbsence[40]   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brwAbsences   
&Scoped-define SELF-NAME brwAbsences
&Scoped-define QUERY-STRING-brwAbsences FOR EACH ttAbsences
&Scoped-define OPEN-QUERY-brwAbsences OPEN QUERY {&SELF-NAME} FOR EACH ttAbsences.
&Scoped-define TABLES-IN-QUERY-brwAbsences ttAbsences
&Scoped-define FIRST-TABLE-IN-QUERY-brwAbsences ttAbsences


/* Definitions for FRAME frmModule                                      */
&Scoped-define OPEN-BROWSERS-IN-QUERY-frmModule ~
    ~{&OPEN-QUERY-brwAbsences}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rctConges rctAutres rctMaladie rctFerie ~
rctFormationClient rctFormationGI rctScolaires brwAbsences filJournee ~
filMatin filApresMidi 
&Scoped-Define DISPLAYED-OBJECTS filJournee filMatin filApresMidi 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD AfficheInformations C-Win 
FUNCTION AfficheInformations RETURNS LOGICAL
  (cLibelle-in AS CHARACTER,iTemporisation-in AS INTEGER)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD DonneCentrage C-Win 
FUNCTION DonneCentrage RETURNS INTEGER
  ( cTitreColonne-in AS CHARACTER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD DonneCouleurCelulle C-Win 
FUNCTION DonneCouleurCelulle RETURNS INTEGER
  ( iNumero-in AS INTEGER, dDate-in AS DATE)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD DonneNomColonne C-Win 
FUNCTION DonneNomColonne RETURNS CHARACTER
  ( iNumero-in AS INTEGER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD DonneValeurColonne C-Win 
FUNCTION DonneValeurColonne RETURNS CHARACTER
  ( iNumero-in AS INTEGER, dDate-in AS DATE)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.

/* Menu Definitions                                                     */
DEFINE SUB-MENU m_Conges 
       MENU-ITEM m_Journée_entière_C LABEL "Journée entière"
       MENU-ITEM m_Matin_C      LABEL "Matin"         
       MENU-ITEM m_Après-midi_C LABEL "Après-midi"    .

DEFINE SUB-MENU m_FormationGI 
       MENU-ITEM m_Journée_entière_FG LABEL "Journée entière"
       MENU-ITEM m_Matin_FG     LABEL "Matin"         
       MENU-ITEM m_Après-midi_FG LABEL "Après-midi"    .

DEFINE SUB-MENU m_FormationClient 
       MENU-ITEM m_Journée_entière_FC LABEL "Journée entière"
       MENU-ITEM m_MatinFC      LABEL "Matin"         
       MENU-ITEM m_Après-midi_FC LABEL "Après-midi"    .

DEFINE SUB-MENU m_Autre 
       MENU-ITEM m_Journée_entière_A LABEL "Journée entière"
       MENU-ITEM m_Matin_A      LABEL "Matin"         
       MENU-ITEM m_Après-midi_A LABEL "Après-midi"    .

DEFINE SUB-MENU m_Maladie 
       MENU-ITEM m_Journée_entière_M LABEL "Journée entière"
       MENU-ITEM m_Matin_M      LABEL "Matin"         
       MENU-ITEM m_Après-midi_M LABEL "Après-midi"    
       RULE
       MENU-ITEM m_Annuler_maladie LABEL "Annuler maladie".

DEFINE MENU POPUP-MENU-brwAbsences 
       SUB-MENU  m_Conges       LABEL "Congés"        
       RULE
       SUB-MENU  m_FormationGI  LABEL "Formation (GI)"
       SUB-MENU  m_FormationClient LABEL "Formation (Client)"
       RULE
       SUB-MENU  m_Autre        LABEL "Autre"         
       RULE
       SUB-MENU  m_Maladie      LABEL "Maladie"       
       RULE
       MENU-ITEM m_Présent      LABEL "Présent"       
       RULE
       MENU-ITEM m_Fermer       LABEL "Fermer"        .


/* Definitions of the field level widgets                               */
DEFINE VARIABLE edtInformation AS CHARACTER INITIAL "Libelle" 
     VIEW-AS EDITOR NO-BOX
     SIZE 61 BY 1.19
     BGCOLOR 3 FGCOLOR 15 FONT 10 NO-UNDO.

DEFINE IMAGE IMAGE-1
     FILENAME "adeicon/rbuild%.ico":U
     SIZE 8 BY 1.43.

DEFINE VARIABLE filApresMidi AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 4 BY .95
     BGCOLOR 8 FONT 14 NO-UNDO.

DEFINE VARIABLE filJournee AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 4 BY .95
     BGCOLOR 8 FONT 14 NO-UNDO.

DEFINE VARIABLE filMatin AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 4 BY .95
     BGCOLOR 8 FONT 14 NO-UNDO.

DEFINE RECTANGLE rctAutres
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 2 BY .95
     BGCOLOR 14 .

DEFINE RECTANGLE rctConges
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 2 BY .95
     BGCOLOR 14 .

DEFINE RECTANGLE rctFerie
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 2 BY .95
     BGCOLOR 14 .

DEFINE RECTANGLE rctFormationClient
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 2 BY .95
     BGCOLOR 14 .

DEFINE RECTANGLE rctFormationGI
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 2 BY .95
     BGCOLOR 14 .

DEFINE RECTANGLE rctMaladie
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 2 BY .95
     BGCOLOR 14 .

DEFINE RECTANGLE rctScolaires
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 2 BY .95
     BGCOLOR 14 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brwAbsences FOR 
      ttAbsences SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brwAbsences
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brwAbsences C-Win _FREEFORM
  QUERY brwAbsences DISPLAY
      ttAbsences.cJour FORMAT "x(10)" LABEL "Jours" WIDTH-PIXELS 60
      
      ttAbsences.cAbsence[1] FORMAT "x(15)" LABEL "%1"
      ttAbsences.cAbsence[2] FORMAT "x(15)" LABEL "%1"
      ttAbsences.cAbsence[3] FORMAT "x(15)" LABEL "%1"
      ttAbsences.cAbsence[4] FORMAT "x(15)" LABEL "%1"
      ttAbsences.cAbsence[5] FORMAT "x(15)" LABEL "%1"
      ttAbsences.cAbsence[6] FORMAT "x(15)" LABEL "%1"
      ttAbsences.cAbsence[7] FORMAT "x(15)" LABEL "%1"
      ttAbsences.cAbsence[8] FORMAT "x(15)" LABEL "%1"
      ttAbsences.cAbsence[9] FORMAT "x(15)" LABEL "%1"
      ttAbsences.cAbsence[10] FORMAT "x(15)" LABEL "%1"
      ttAbsences.cAbsence[11] FORMAT "x(15)" LABEL "%1"
      ttAbsences.cAbsence[12] FORMAT "x(15)" LABEL "%1"
      ttAbsences.cAbsence[13] FORMAT "x(15)" LABEL "%1"
      ttAbsences.cAbsence[14] FORMAT "x(15)" LABEL "%1"
      ttAbsences.cAbsence[15] FORMAT "x(15)" LABEL "%1"
      ttAbsences.cAbsence[16] FORMAT "x(15)" LABEL "%1"
      ttAbsences.cAbsence[17] FORMAT "x(15)" LABEL "%1"
      ttAbsences.cAbsence[18] FORMAT "x(15)" LABEL "%1"
      ttAbsences.cAbsence[19] FORMAT "x(15)" LABEL "%1"
      ttAbsences.cAbsence[20] FORMAT "x(15)" LABEL "%1"
      ttAbsences.cAbsence[21] FORMAT "x(15)" LABEL "%1"
      ttAbsences.cAbsence[22] FORMAT "x(15)" LABEL "%1"
      ttAbsences.cAbsence[23] FORMAT "x(15)" LABEL "%1"
      ttAbsences.cAbsence[24] FORMAT "x(15)" LABEL "%1"
      ttAbsences.cAbsence[25] FORMAT "x(15)" LABEL "%1"
      ttAbsences.cAbsence[26] FORMAT "x(15)" LABEL "%1"
      ttAbsences.cAbsence[27] FORMAT "x(15)" LABEL "%1"
      ttAbsences.cAbsence[28] FORMAT "x(15)" LABEL "%1"
      ttAbsences.cAbsence[29] FORMAT "x(15)" LABEL "%1"
      ttAbsences.cAbsence[30] FORMAT "x(15)" LABEL "%1"
      ttAbsences.cAbsence[31] FORMAT "x(15)" LABEL "%1"
      ttAbsences.cAbsence[32] FORMAT "x(15)" LABEL "%1"
      ttAbsences.cAbsence[33] FORMAT "x(15)" LABEL "%1"
      ttAbsences.cAbsence[34] FORMAT "x(15)" LABEL "%1"
      ttAbsences.cAbsence[35] FORMAT "x(15)" LABEL "%1"
      ttAbsences.cAbsence[36] FORMAT "x(15)" LABEL "%1"
      ttAbsences.cAbsence[37] FORMAT "x(15)" LABEL "%1"
      ttAbsences.cAbsence[38] FORMAT "x(15)" LABEL "%1"
      ttAbsences.cAbsence[39] FORMAT "x(15)" LABEL "%1"
      ttAbsences.cAbsence[40] FORMAT "x(15)" LABEL "%1"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS MULTIPLE SIZE 164 BY 17.86
         FONT 1 ROW-HEIGHT-CHARS .81.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME frmModule
     brwAbsences AT ROW 2.43 COL 2 WIDGET-ID 100
     filJournee AT ROW 1.24 COL 116 COLON-ALIGNED NO-LABEL WIDGET-ID 14
     filMatin AT ROW 1.24 COL 137 COLON-ALIGNED NO-LABEL WIDGET-ID 18
     filApresMidi AT ROW 1.24 COL 148 COLON-ALIGNED NO-LABEL WIDGET-ID 22
     "Maladie" VIEW-AS TEXT
          SIZE 8 BY .95 AT ROW 1.24 COL 83 WIDGET-ID 28
     "Férié" VIEW-AS TEXT
          SIZE 6 BY .95 AT ROW 1.24 COL 94 WIDGET-ID 32
     "Journée entière" VIEW-AS TEXT
          SIZE 16 BY .95 AT ROW 1.24 COL 123 WIDGET-ID 16
     "Formation/Assistance (GI)" VIEW-AS TEXT
          SIZE 25 BY .95 AT ROW 1.24 COL 46 WIDGET-ID 40
     "Matin" VIEW-AS TEXT
          SIZE 6 BY .95 AT ROW 1.24 COL 144 WIDGET-ID 20
     "Formation/Assistance (Client)" VIEW-AS TEXT
          SIZE 28 BY .95 AT ROW 1.24 COL 15 WIDGET-ID 36
     "Vac. Scolaires" VIEW-AS TEXT
          SIZE 14 BY .95 AT ROW 1.24 COL 103 WIDGET-ID 44
     "Après-Midi" VIEW-AS TEXT
          SIZE 11 BY .95 AT ROW 1.24 COL 155 WIDGET-ID 24
     "Autres" VIEW-AS TEXT
          SIZE 7 BY .95 AT ROW 1.24 COL 74 WIDGET-ID 12
     "Congés" VIEW-AS TEXT
          SIZE 8 BY .95 AT ROW 1.24 COL 4 WIDGET-ID 4
     rctConges AT ROW 1.24 COL 2 WIDGET-ID 2
     rctAutres AT ROW 1.24 COL 72 WIDGET-ID 10
     rctMaladie AT ROW 1.24 COL 81 WIDGET-ID 26
     rctFerie AT ROW 1.24 COL 92 WIDGET-ID 30
     rctFormationClient AT ROW 1.24 COL 13 WIDGET-ID 34
     rctFormationGI AT ROW 1.24 COL 44 WIDGET-ID 38
     rctScolaires AT ROW 1.24 COL 101 WIDGET-ID 42
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 2 ROW 1.33
         SIZE 166.2 BY 20.62
         TITLE BGCOLOR 2 FGCOLOR 15 "Absences des utilisateurs".

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
         HEIGHT             = 20.91
         WIDTH              = 169.2
         MAX-HEIGHT         = 33.95
         MAX-WIDTH          = 171.8
         VIRTUAL-HEIGHT     = 33.95
         VIRTUAL-WIDTH      = 171.8
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
ASSIGN FRAME frmInformation:FRAME = FRAME frmModule:HANDLE.

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
/* BROWSE-TAB brwAbsences rctScolaires frmModule */
ASSIGN 
       brwAbsences:POPUP-MENU IN FRAME frmModule             = MENU POPUP-MENU-brwAbsences:HANDLE
       brwAbsences:NUM-LOCKED-COLUMNS IN FRAME frmModule     = 2.

ASSIGN 
       filApresMidi:READ-ONLY IN FRAME frmModule        = TRUE.

ASSIGN 
       filJournee:READ-ONLY IN FRAME frmModule        = TRUE.

ASSIGN 
       filMatin:READ-ONLY IN FRAME frmModule        = TRUE.

IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brwAbsences
/* Query rebuild information for BROWSE brwAbsences
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH ttAbsences.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE brwAbsences */
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


&Scoped-define BROWSE-NAME brwAbsences
&Scoped-define SELF-NAME brwAbsences
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwAbsences C-Win
ON ROW-DISPLAY OF brwAbsences IN FRAME frmModule
DO:
    
   

    IF ttAbsences.lFerie THEN DO:
        ttAbsences.cJour:bgcolor IN BROWSE brwAbsences =  {&Couleur_Ferie}.
        ttAbsences.cAbsence[1]:bgcolor IN BROWSE brwAbsences =  {&Couleur_Ferie}.
        ttAbsences.cAbsence[2]:bgcolor IN BROWSE brwAbsences =  {&Couleur_Ferie}. 
        ttAbsences.cAbsence[3]:bgcolor IN BROWSE brwAbsences =  {&Couleur_Ferie}.
        ttAbsences.cAbsence[4]:bgcolor IN BROWSE brwAbsences =  {&Couleur_Ferie}.
        ttAbsences.cAbsence[5]:bgcolor IN BROWSE brwAbsences =  {&Couleur_Ferie}.
        ttAbsences.cAbsence[6]:bgcolor IN BROWSE brwAbsences =  {&Couleur_Ferie}.
        ttAbsences.cAbsence[7]:bgcolor IN BROWSE brwAbsences =  {&Couleur_Ferie}.
        ttAbsences.cAbsence[8]:bgcolor IN BROWSE brwAbsences =  {&Couleur_Ferie}.
        ttAbsences.cAbsence[9]:bgcolor IN BROWSE brwAbsences =  {&Couleur_Ferie}.
        ttAbsences.cAbsence[10]:bgcolor IN BROWSE brwAbsences = {&Couleur_Ferie}.
        ttAbsences.cAbsence[11]:bgcolor IN BROWSE brwAbsences = {&Couleur_Ferie}.
        ttAbsences.cAbsence[12]:bgcolor IN BROWSE brwAbsences = {&Couleur_Ferie}.
        ttAbsences.cAbsence[13]:bgcolor IN BROWSE brwAbsences = {&Couleur_Ferie}.
        ttAbsences.cAbsence[14]:bgcolor IN BROWSE brwAbsences = {&Couleur_Ferie}.
        ttAbsences.cAbsence[15]:bgcolor IN BROWSE brwAbsences = {&Couleur_Ferie}.
        ttAbsences.cAbsence[16]:bgcolor IN BROWSE brwAbsences = {&Couleur_Ferie}.
        ttAbsences.cAbsence[17]:bgcolor IN BROWSE brwAbsences = {&Couleur_Ferie}.
        ttAbsences.cAbsence[18]:bgcolor IN BROWSE brwAbsences = {&Couleur_Ferie}.
        ttAbsences.cAbsence[19]:bgcolor IN BROWSE brwAbsences = {&Couleur_Ferie}.
        ttAbsences.cAbsence[20]:bgcolor IN BROWSE brwAbsences = {&Couleur_Ferie}.
        ttAbsences.cAbsence[21]:bgcolor IN BROWSE brwAbsences = {&Couleur_Ferie}.
        ttAbsences.cAbsence[22]:bgcolor IN BROWSE brwAbsences = {&Couleur_Ferie}.
        ttAbsences.cAbsence[23]:bgcolor IN BROWSE brwAbsences = {&Couleur_Ferie}.
        ttAbsences.cAbsence[24]:bgcolor IN BROWSE brwAbsences = {&Couleur_Ferie}.
        ttAbsences.cAbsence[25]:bgcolor IN BROWSE brwAbsences = {&Couleur_Ferie}.
        ttAbsences.cAbsence[26]:bgcolor IN BROWSE brwAbsences = {&Couleur_Ferie}.
        ttAbsences.cAbsence[27]:bgcolor IN BROWSE brwAbsences = {&Couleur_Ferie}.
        ttAbsences.cAbsence[28]:bgcolor IN BROWSE brwAbsences = {&Couleur_Ferie}.
        ttAbsences.cAbsence[29]:bgcolor IN BROWSE brwAbsences = {&Couleur_Ferie}.
        ttAbsences.cAbsence[30]:bgcolor IN BROWSE brwAbsences = {&Couleur_Ferie}.
        ttAbsences.cAbsence[31]:bgcolor IN BROWSE brwAbsences = {&Couleur_Ferie}.
        ttAbsences.cAbsence[32]:bgcolor IN BROWSE brwAbsences = {&Couleur_Ferie}.
        ttAbsences.cAbsence[33]:bgcolor IN BROWSE brwAbsences = {&Couleur_Ferie}.
        ttAbsences.cAbsence[34]:bgcolor IN BROWSE brwAbsences = {&Couleur_Ferie}.
        ttAbsences.cAbsence[35]:bgcolor IN BROWSE brwAbsences = {&Couleur_Ferie}.
        ttAbsences.cAbsence[36]:bgcolor IN BROWSE brwAbsences = {&Couleur_Ferie}.
        ttAbsences.cAbsence[37]:bgcolor IN BROWSE brwAbsences = {&Couleur_Ferie}.
        ttAbsences.cAbsence[38]:bgcolor IN BROWSE brwAbsences = {&Couleur_Ferie}.
        ttAbsences.cAbsence[39]:bgcolor IN BROWSE brwAbsences = {&Couleur_Ferie}.
        ttAbsences.cAbsence[40]:bgcolor IN BROWSE brwAbsences = {&Couleur_Ferie}.

    END.
    ELSE DO:
        ttAbsences.cAbsence[1]:SCREEN-VALUE IN BROWSE brwAbsences =  DonneValeurColonne(1 ,ttAbsences.ddate).
        ttAbsences.cAbsence[2]:SCREEN-VALUE IN BROWSE brwAbsences =  DonneValeurColonne(2 ,ttAbsences.ddate). 
        ttAbsences.cAbsence[3]:SCREEN-VALUE IN BROWSE brwAbsences =  DonneValeurColonne(3 ,ttAbsences.ddate).
        ttAbsences.cAbsence[4]:SCREEN-VALUE IN BROWSE brwAbsences =  DonneValeurColonne(4 ,ttAbsences.ddate).
        ttAbsences.cAbsence[5]:SCREEN-VALUE IN BROWSE brwAbsences =  DonneValeurColonne(5 ,ttAbsences.ddate).
        ttAbsences.cAbsence[6]:SCREEN-VALUE IN BROWSE brwAbsences =  DonneValeurColonne(6 ,ttAbsences.ddate).
        ttAbsences.cAbsence[7]:SCREEN-VALUE IN BROWSE brwAbsences =  DonneValeurColonne(7 ,ttAbsences.ddate).
        ttAbsences.cAbsence[8]:SCREEN-VALUE IN BROWSE brwAbsences =  DonneValeurColonne(8 ,ttAbsences.ddate).
        ttAbsences.cAbsence[9]:SCREEN-VALUE IN BROWSE brwAbsences =  DonneValeurColonne(9 ,ttAbsences.ddate).
        ttAbsences.cAbsence[10]:SCREEN-VALUE IN BROWSE brwAbsences = DonneValeurColonne(10,ttAbsences.ddate).
        ttAbsences.cAbsence[11]:SCREEN-VALUE IN BROWSE brwAbsences = DonneValeurColonne(11,ttAbsences.ddate).
        ttAbsences.cAbsence[12]:SCREEN-VALUE IN BROWSE brwAbsences = DonneValeurColonne(12,ttAbsences.ddate).
        ttAbsences.cAbsence[13]:SCREEN-VALUE IN BROWSE brwAbsences = DonneValeurColonne(13,ttAbsences.ddate).
        ttAbsences.cAbsence[14]:SCREEN-VALUE IN BROWSE brwAbsences = DonneValeurColonne(14,ttAbsences.ddate).
        ttAbsences.cAbsence[15]:SCREEN-VALUE IN BROWSE brwAbsences = DonneValeurColonne(15,ttAbsences.ddate).
        ttAbsences.cAbsence[16]:SCREEN-VALUE IN BROWSE brwAbsences = DonneValeurColonne(16,ttAbsences.ddate).
        ttAbsences.cAbsence[17]:SCREEN-VALUE IN BROWSE brwAbsences = DonneValeurColonne(17,ttAbsences.ddate).
        ttAbsences.cAbsence[18]:SCREEN-VALUE IN BROWSE brwAbsences = DonneValeurColonne(18,ttAbsences.ddate).
        ttAbsences.cAbsence[19]:SCREEN-VALUE IN BROWSE brwAbsences = DonneValeurColonne(19,ttAbsences.ddate).
        ttAbsences.cAbsence[20]:SCREEN-VALUE IN BROWSE brwAbsences = DonneValeurColonne(20,ttAbsences.ddate).
        ttAbsences.cAbsence[21]:SCREEN-VALUE IN BROWSE brwAbsences = DonneValeurColonne(21,ttAbsences.ddate).
        ttAbsences.cAbsence[22]:SCREEN-VALUE IN BROWSE brwAbsences = DonneValeurColonne(22,ttAbsences.ddate).
        ttAbsences.cAbsence[23]:SCREEN-VALUE IN BROWSE brwAbsences = DonneValeurColonne(23,ttAbsences.ddate).
        ttAbsences.cAbsence[24]:SCREEN-VALUE IN BROWSE brwAbsences = DonneValeurColonne(24,ttAbsences.ddate).
        ttAbsences.cAbsence[25]:SCREEN-VALUE IN BROWSE brwAbsences = DonneValeurColonne(25,ttAbsences.ddate).
        ttAbsences.cAbsence[26]:SCREEN-VALUE IN BROWSE brwAbsences = DonneValeurColonne(26,ttAbsences.ddate).
        ttAbsences.cAbsence[27]:SCREEN-VALUE IN BROWSE brwAbsences = DonneValeurColonne(27,ttAbsences.ddate).
        ttAbsences.cAbsence[28]:SCREEN-VALUE IN BROWSE brwAbsences = DonneValeurColonne(28,ttAbsences.ddate).
        ttAbsences.cAbsence[29]:SCREEN-VALUE IN BROWSE brwAbsences = DonneValeurColonne(29,ttAbsences.ddate).
        ttAbsences.cAbsence[30]:SCREEN-VALUE IN BROWSE brwAbsences = DonneValeurColonne(30,ttAbsences.ddate).
        ttAbsences.cAbsence[31]:SCREEN-VALUE IN BROWSE brwAbsences = DonneValeurColonne(31,ttAbsences.ddate).
        ttAbsences.cAbsence[32]:SCREEN-VALUE IN BROWSE brwAbsences = DonneValeurColonne(32,ttAbsences.ddate).
        ttAbsences.cAbsence[33]:SCREEN-VALUE IN BROWSE brwAbsences = DonneValeurColonne(33,ttAbsences.ddate).
        ttAbsences.cAbsence[34]:SCREEN-VALUE IN BROWSE brwAbsences = DonneValeurColonne(34,ttAbsences.ddate).
        ttAbsences.cAbsence[35]:SCREEN-VALUE IN BROWSE brwAbsences = DonneValeurColonne(35,ttAbsences.ddate).
        ttAbsences.cAbsence[36]:SCREEN-VALUE IN BROWSE brwAbsences = DonneValeurColonne(36,ttAbsences.ddate).
        ttAbsences.cAbsence[37]:SCREEN-VALUE IN BROWSE brwAbsences = DonneValeurColonne(37,ttAbsences.ddate).
        ttAbsences.cAbsence[38]:SCREEN-VALUE IN BROWSE brwAbsences = DonneValeurColonne(38,ttAbsences.ddate).
        ttAbsences.cAbsence[39]:SCREEN-VALUE IN BROWSE brwAbsences = DonneValeurColonne(39,ttAbsences.ddate).
        ttAbsences.cAbsence[40]:SCREEN-VALUE IN BROWSE brwAbsences = DonneValeurColonne(40,ttAbsences.ddate).

        ttAbsences.cAbsence[1]:bgcolor IN BROWSE brwAbsences =  DonneCouleurCelulle(1 ,ttAbsences.ddate).
        ttAbsences.cAbsence[2]:bgcolor IN BROWSE brwAbsences =  DonneCouleurCelulle(2 ,ttAbsences.ddate). 
        ttAbsences.cAbsence[3]:bgcolor IN BROWSE brwAbsences =  DonneCouleurCelulle(3 ,ttAbsences.ddate).
        ttAbsences.cAbsence[4]:bgcolor IN BROWSE brwAbsences =  DonneCouleurCelulle(4 ,ttAbsences.ddate).
        ttAbsences.cAbsence[5]:bgcolor IN BROWSE brwAbsences =  DonneCouleurCelulle(5 ,ttAbsences.ddate).
        ttAbsences.cAbsence[6]:bgcolor IN BROWSE brwAbsences =  DonneCouleurCelulle(6 ,ttAbsences.ddate).
        ttAbsences.cAbsence[7]:bgcolor IN BROWSE brwAbsences =  DonneCouleurCelulle(7 ,ttAbsences.ddate).
        ttAbsences.cAbsence[8]:bgcolor IN BROWSE brwAbsences =  DonneCouleurCelulle(8 ,ttAbsences.ddate).
        ttAbsences.cAbsence[9]:bgcolor IN BROWSE brwAbsences =  DonneCouleurCelulle(9 ,ttAbsences.ddate).
        ttAbsences.cAbsence[10]:bgcolor IN BROWSE brwAbsences = DonneCouleurCelulle(10,ttAbsences.ddate).
        ttAbsences.cAbsence[11]:bgcolor IN BROWSE brwAbsences = DonneCouleurCelulle(11,ttAbsences.ddate).
        ttAbsences.cAbsence[12]:bgcolor IN BROWSE brwAbsences = DonneCouleurCelulle(12,ttAbsences.ddate).
        ttAbsences.cAbsence[13]:bgcolor IN BROWSE brwAbsences = DonneCouleurCelulle(13,ttAbsences.ddate).
        ttAbsences.cAbsence[14]:bgcolor IN BROWSE brwAbsences = DonneCouleurCelulle(14,ttAbsences.ddate).
        ttAbsences.cAbsence[15]:bgcolor IN BROWSE brwAbsences = DonneCouleurCelulle(15,ttAbsences.ddate).
        ttAbsences.cAbsence[16]:bgcolor IN BROWSE brwAbsences = DonneCouleurCelulle(16,ttAbsences.ddate).
        ttAbsences.cAbsence[17]:bgcolor IN BROWSE brwAbsences = DonneCouleurCelulle(17,ttAbsences.ddate).
        ttAbsences.cAbsence[18]:bgcolor IN BROWSE brwAbsences = DonneCouleurCelulle(18,ttAbsences.ddate).
        ttAbsences.cAbsence[19]:bgcolor IN BROWSE brwAbsences = DonneCouleurCelulle(19,ttAbsences.ddate).
        ttAbsences.cAbsence[20]:bgcolor IN BROWSE brwAbsences = DonneCouleurCelulle(20,ttAbsences.ddate).
        ttAbsences.cAbsence[21]:bgcolor IN BROWSE brwAbsences = DonneCouleurCelulle(21,ttAbsences.ddate).
        ttAbsences.cAbsence[22]:bgcolor IN BROWSE brwAbsences = DonneCouleurCelulle(22,ttAbsences.ddate).
        ttAbsences.cAbsence[23]:bgcolor IN BROWSE brwAbsences = DonneCouleurCelulle(23,ttAbsences.ddate).
        ttAbsences.cAbsence[24]:bgcolor IN BROWSE brwAbsences = DonneCouleurCelulle(24,ttAbsences.ddate).
        ttAbsences.cAbsence[25]:bgcolor IN BROWSE brwAbsences = DonneCouleurCelulle(25,ttAbsences.ddate).
        ttAbsences.cAbsence[26]:bgcolor IN BROWSE brwAbsences = DonneCouleurCelulle(26,ttAbsences.ddate).
        ttAbsences.cAbsence[27]:bgcolor IN BROWSE brwAbsences = DonneCouleurCelulle(27,ttAbsences.ddate).
        ttAbsences.cAbsence[28]:bgcolor IN BROWSE brwAbsences = DonneCouleurCelulle(28,ttAbsences.ddate).
        ttAbsences.cAbsence[29]:bgcolor IN BROWSE brwAbsences = DonneCouleurCelulle(29,ttAbsences.ddate).
        ttAbsences.cAbsence[30]:bgcolor IN BROWSE brwAbsences = DonneCouleurCelulle(30,ttAbsences.ddate).
        ttAbsences.cAbsence[31]:bgcolor IN BROWSE brwAbsences = DonneCouleurCelulle(31,ttAbsences.ddate).
        ttAbsences.cAbsence[32]:bgcolor IN BROWSE brwAbsences = DonneCouleurCelulle(32,ttAbsences.ddate).
        ttAbsences.cAbsence[33]:bgcolor IN BROWSE brwAbsences = DonneCouleurCelulle(33,ttAbsences.ddate).
        ttAbsences.cAbsence[34]:bgcolor IN BROWSE brwAbsences = DonneCouleurCelulle(34,ttAbsences.ddate).
        ttAbsences.cAbsence[35]:bgcolor IN BROWSE brwAbsences = DonneCouleurCelulle(35,ttAbsences.ddate).
        ttAbsences.cAbsence[36]:bgcolor IN BROWSE brwAbsences = DonneCouleurCelulle(36,ttAbsences.ddate).
        ttAbsences.cAbsence[37]:bgcolor IN BROWSE brwAbsences = DonneCouleurCelulle(37,ttAbsences.ddate).
        ttAbsences.cAbsence[38]:bgcolor IN BROWSE brwAbsences = DonneCouleurCelulle(38,ttAbsences.ddate).
        ttAbsences.cAbsence[39]:bgcolor IN BROWSE brwAbsences = DonneCouleurCelulle(39,ttAbsences.ddate).
        ttAbsences.cAbsence[40]:bgcolor IN BROWSE brwAbsences = DonneCouleurCelulle(40,ttAbsences.ddate).

        /* Gérer le changement de semaine et les vacances scolaires */

        IF ttAbsences.lScolaire THEN DO:
            ttAbsences.cJour:bgcolor IN BROWSE brwAbsences =  {&Couleur_Scolaire}.
        END.
        ELSE DO:
            IF gDonnePreference("PREFS-ABSENCES-PAS-WE") = "OUI" THEN DO:
                ttAbsences.cJour:bgcolor IN BROWSE brwAbsences = (IF ttAbsences.iSemaine / 2 = INTEGER(ttAbsences.iSemaine / 2) THEN {&Couleur_Semaine} ELSE ?).
            END.
            ELSE DO:
                IF (WEEKDAY(ttAbsences.ddate) = 7 OR WEEKDAY(ttAbsences.ddate) = 1) THEN ttAbsences.cJour:bgcolor IN BROWSE brwAbsences = {&Couleur_Semaine}.
            END.
        END.
    END.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Annuler_maladie
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Annuler_maladie C-Win
ON CHOOSE OF MENU-ITEM m_Annuler_maladie /* Annuler maladie */
DO:
  
    RUN AffecteTypeAbsence("M-A","J").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Après-midi_A
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Après-midi_A C-Win
ON CHOOSE OF MENU-ITEM m_Après-midi_A /* Après-midi */
DO:
  
    RUN AffecteTypeAbsence("A","A").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Après-midi_C
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Après-midi_C C-Win
ON CHOOSE OF MENU-ITEM m_Après-midi_C /* Après-midi */
DO:
  
    RUN AffecteTypeAbsence("C","A").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Après-midi_FC
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Après-midi_FC C-Win
ON CHOOSE OF MENU-ITEM m_Après-midi_FC /* Après-midi */
DO:
  
    RUN AffecteTypeAbsence("FC","A").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Après-midi_FG
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Après-midi_FG C-Win
ON CHOOSE OF MENU-ITEM m_Après-midi_FG /* Après-midi */
DO:
  
    RUN AffecteTypeAbsence("FG","A").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Après-midi_M
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Après-midi_M C-Win
ON CHOOSE OF MENU-ITEM m_Après-midi_M /* Après-midi */
DO:
  
    RUN AffecteTypeAbsence("M","A").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Journée_entière_A
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Journée_entière_A C-Win
ON CHOOSE OF MENU-ITEM m_Journée_entière_A /* Journée entière */
DO:
  
    RUN AffecteTypeAbsence("A","J").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Journée_entière_C
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Journée_entière_C C-Win
ON CHOOSE OF MENU-ITEM m_Journée_entière_C /* Journée entière */
DO:
  RUN AffecteTypeAbsence("C","J").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Journée_entière_FC
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Journée_entière_FC C-Win
ON CHOOSE OF MENU-ITEM m_Journée_entière_FC /* Journée entière */
DO:
  
    RUN AffecteTypeAbsence("FC","J").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Journée_entière_FG
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Journée_entière_FG C-Win
ON CHOOSE OF MENU-ITEM m_Journée_entière_FG /* Journée entière */
DO:
  
    RUN AffecteTypeAbsence("FG","J").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Journée_entière_M
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Journée_entière_M C-Win
ON CHOOSE OF MENU-ITEM m_Journée_entière_M /* Journée entière */
DO:
  
    RUN AffecteTypeAbsence("M","J").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_MatinFC
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_MatinFC C-Win
ON CHOOSE OF MENU-ITEM m_MatinFC /* Matin */
DO:
  
    RUN AffecteTypeAbsence("FC","M").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Matin_A
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Matin_A C-Win
ON CHOOSE OF MENU-ITEM m_Matin_A /* Matin */
DO:
  
    RUN AffecteTypeAbsence("A","M").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Matin_C
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Matin_C C-Win
ON CHOOSE OF MENU-ITEM m_Matin_C /* Matin */
DO:
  
    RUN AffecteTypeAbsence("C","M").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Matin_FG
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Matin_FG C-Win
ON CHOOSE OF MENU-ITEM m_Matin_FG /* Matin */
DO:
  
    RUN AffecteTypeAbsence("FG","M").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Matin_M
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Matin_M C-Win
ON CHOOSE OF MENU-ITEM m_Matin_M /* Matin */
DO:
  
    RUN AffecteTypeAbsence("M","M").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Présent
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Présent C-Win
ON CHOOSE OF MENU-ITEM m_Présent /* Présent */
DO:
  
    RUN AffecteTypeAbsence("P","J").
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE AffecteTypeAbsence C-Win 
PROCEDURE AffecteTypeAbsence :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

  DEFINE INPUT PARAMETER cType-in AS CHARACTER no-undo.
  DEFINE INPUT PARAMETER cQuand-in AS CHARACTER NO-UNDO.

    DEFINE VARIABLE lRetour AS LOGICAL NO-UNDO INIT FALSE.
    DEFINE VARIABLE iSelection AS INTEGER NO-UNDO.
    DEFINE VARIABLE dDateSelection AS DATE NO-UNDO.
    DEFINE VARIABLE cUtilisateur AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO.
    
    DO WITH FRAME frmModule:
    /* si pas de selection, on ne fait rien */
        IF brwAbsences:NUM-SELECTED-ROWS < 1 THEN do:
            RUN gAfficheMessageTemporaire("Absences","Aucune ligne sélectionnée !",FALSE,0,"OK","",FALSE,OUTPUT cRetour).
            RETURN.
        END.
    
        cUtilisateur = gcUtilisateur.
        IF cType-in = "M" OR cType-in = "M-A" THEN DO:
            /* Sélection de l'utilisateur */
		    RUN DonnePositionMessage IN ghGeneral.
		    gcAllerRetour = STRING(giPosXMessage)
		        + "|" + STRING(giPosYMessage)
                + "|" + "Sélectionnez l'utilisateur"
                + "|" + "".
            RUN VALUE(gcRepertoireExecution + "saisie4.w") (INPUT-OUTPUT gcAllerRetour).
            IF gcAllerRetour = "" THEN RETURN.
            cUtilisateur = ENTRY(4,gcAllerRetour,"|").
        END.

        DO iSelection = 1 TO brwAbsences:NUM-SELECTED-ROWS:          
            brwAbsences:FETCH-SELECTED-ROW(iSelection).  
            FIND CURRENT ttAbsences NO-LOCK NO-WAIT NO-ERROR.
            IF NOT AVAILABLE ttAbsences THEN NEXT.
            dDateSelection = ttabsences.ddate.
    
            FIND FIRST  Absence  EXCLUSIVE-LOCK
                WHERE   Absence.cUtilisateur = cUtilisateur
                AND     Absence.dDate = dDateSelection
                NO-ERROR.

            IF cType-in = "P" OR cType-in = "M-A" THEN DO:
                IF AVAILABLE(Absences) THEN DELETE Absences.
            END.
            ELSE DO:
                IF not(AVAILABLE(Absence)) THEN DO:
                    CREATE absence.
                    Absence.cUtilisateur = cUtilisateur.
                    Absence.dDate = dDateSelection.
                END.
                Absence.cTypeAbsence = cType-in.
                Absence.lMatin = (cQuand-in = "J" OR cQuand-in = "M").
                Absence.lApresmidi = (cQuand-in = "J" OR cQuand-in = "A").    
            END.

            /* suppression des flag d'avertissement */
            FOR EACH    utilisateurs    NO-LOCK
               :
                IF gDonnePreferenceUtilisateur(utilisateur.cutilisateur,"PREF-ABSENCES-PREVENIR-NOUVELLE") = "OUI" THEN DO:
                    gSauvePreferenceUtilisateur(utilisateur.cutilisateur,"PREF-ABSENCES-PREVENU","").
                END.
            END.
        END.
    
        /* rafraichissement du browse */
        brwAbsences:REFRESH() IN FRAME frmModule.
    END.

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
  DISPLAY filJournee filMatin filApresMidi 
      WITH FRAME frmModule IN WINDOW C-Win.
  ENABLE rctConges rctAutres rctMaladie rctFerie rctFormationClient 
         rctFormationGI rctScolaires brwAbsences filJournee filMatin 
         filApresMidi 
      WITH FRAME frmModule IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-frmModule}
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
                AfficheInformations("Veuillez patienter...",0).
                FRAME frmModule:MOVE-TO-TOP().
                IF gGetEtSupParam("ABSENCES-RECHARGER") = "OUI" THEN DO:
                    RUN Recharger.
                END.
                AfficheInformations("",0).

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
            WHEN "MODIFIER" THEN DO:
                RUN Modification(OUTPUT lRetour-ou).
            END.
            WHEN "RECHERCHE" THEN DO:
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
    gcAideAjouter = "#INTERDIT#".
    gcAideModifier = "#DIRECT#Sauvegarder les modifications des absences".
    gcAideSupprimer = "#INTERDIT#".
    gcAideImprimer = "#INTERDIT#".
    gcAideRaf = "Recharger la liste des absences".

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
    DEFINE VARIABLE dDateEnCours AS DATE NO-UNDO.
    DEFINE VARIABLE dDateDebut AS DATE NO-UNDO.
    DEFINE VARIABLE dDateFin AS DATE NO-UNDO.
    DEFINE VARIABLE iNumero AS INTEGER NO-UNDO.
    DEFINE VARIABLE iBoucle AS INTEGER NO-UNDO.
    DEFINE VARIABLE cNomColonne AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cExclusions AS CHARACTER NO-UNDO.
    DEFINE VARIABLE iFacteur AS DECIMAL NO-UNDO INIT 1.5.
    DEFINE VARIABLE iVersionMenudev2 AS INTEGER NO-UNDO.
    DEFINE VARIABLE lJourAPrendre AS LOGICAL NO-UNDO.
    
    FRAME frmModule:COLUMN = gdPositionXModule.
    FRAME frmModule:ROW = gdPositionYModule.

    iVersionMenudev2 = gDonneVersionMenudev2().

    /* Chargement des images */
    
    /* Chargement de la table des utilisateurs */
    AfficheInformations("Veuillez patienter...",0).
    EMPTY TEMP-TABLE ttUtils.
    iNumero = 1.
    CREATE ttUtils.
    ttUtils.iColonne = iNumero.
    ttUtils.cUtil = gcUtilisateur.
    ttUtils.cVraiNom = gDonneVraiNomUtilisateur(gcUtilisateur).

    FOR EACH    utilisateurs   NO-LOCK
        :
        /* exclusions */
        IF UTILISATEURS.cUtilisateur = gcUtilisateur THEN NEXT.
        IF UTILISATEURS.lDesactive THEN NEXT.
        IF UTILISATEURS.lNonPhysique THEN NEXT.
        /*IF UTILISATEURS.iVersion < (iVersionMenudev2 - 2) THEN NEXT.*/
        /*iNumero = iNumero + 1.*/
        CREATE ttUtils.
        ttUtils.iColonne = 500. /*iNumero.*/
        ttUtils.cUtil = UTILISATEURS.cUtilisateur.
        ttUtils.cVraiNom = gDonneVraiNomUtilisateur(UTILISATEURS.cUtilisateur).
        
        /* y a t il une absence pour cet utilisateur dans les 20 jours */
        FIND FIRST      absences        NO-LOCK
                WHERE   absences.cUtilisateur = UTILISATEURS.cUtilisateur
                AND     (absences.ddate >= TODAY AND absences.ddate <= TODAY + 20)
                NO-ERROR.
        ttUtils.labsence = AVAILABLE(absences).
    END.

        /* Reclassement des utilisateurs */
    FOR EACH    ttUtils 
        WHERE   ttUtils.iColonne = 500
        BY ttUtils.labsence desc BY ttUtils.cVraiNom
        :
        iNumero = iNumero + 1.
        ttUtils.iColonne = iNumero.
        END.

    /* Gestion des entetes de colonnes */
    ttAbsences.cAbsence[1]:LABEL IN BROWSE brwAbsences = DonneNomColonne(1).
    ttAbsences.cAbsence[2]:LABEL IN BROWSE brwAbsences = DonneNomColonne(2).
    ttAbsences.cAbsence[3]:LABEL IN BROWSE brwAbsences = DonneNomColonne(3).
    ttAbsences.cAbsence[4]:LABEL IN BROWSE brwAbsences = DonneNomColonne(4).
    ttAbsences.cAbsence[5]:LABEL IN BROWSE brwAbsences = DonneNomColonne(5).
    ttAbsences.cAbsence[6]:LABEL IN BROWSE brwAbsences = DonneNomColonne(6).
    ttAbsences.cAbsence[7]:LABEL IN BROWSE brwAbsences = DonneNomColonne(7).
    ttAbsences.cAbsence[8]:LABEL IN BROWSE brwAbsences = DonneNomColonne(8).
    ttAbsences.cAbsence[9]:LABEL IN BROWSE brwAbsences = DonneNomColonne(9).
    ttAbsences.cAbsence[10]:LABEL IN BROWSE brwAbsences = DonneNomColonne(10).
    ttAbsences.cAbsence[11]:LABEL IN BROWSE brwAbsences = DonneNomColonne(11).
    ttAbsences.cAbsence[12]:LABEL IN BROWSE brwAbsences = DonneNomColonne(12).
    ttAbsences.cAbsence[13]:LABEL IN BROWSE brwAbsences = DonneNomColonne(13).
    ttAbsences.cAbsence[14]:LABEL IN BROWSE brwAbsences = DonneNomColonne(14).
    ttAbsences.cAbsence[15]:LABEL IN BROWSE brwAbsences = DonneNomColonne(15).
    ttAbsences.cAbsence[16]:LABEL IN BROWSE brwAbsences = DonneNomColonne(16).
    ttAbsences.cAbsence[17]:LABEL IN BROWSE brwAbsences = DonneNomColonne(17).
    ttAbsences.cAbsence[18]:LABEL IN BROWSE brwAbsences = DonneNomColonne(18).
    ttAbsences.cAbsence[19]:LABEL IN BROWSE brwAbsences = DonneNomColonne(19).
    ttAbsences.cAbsence[20]:LABEL IN BROWSE brwAbsences = DonneNomColonne(20).
    ttAbsences.cAbsence[21]:LABEL IN BROWSE brwAbsences = DonneNomColonne(21).
    ttAbsences.cAbsence[22]:LABEL IN BROWSE brwAbsences = DonneNomColonne(22).
    ttAbsences.cAbsence[23]:LABEL IN BROWSE brwAbsences = DonneNomColonne(23).
    ttAbsences.cAbsence[24]:LABEL IN BROWSE brwAbsences = DonneNomColonne(24).
    ttAbsences.cAbsence[25]:LABEL IN BROWSE brwAbsences = DonneNomColonne(25).
    ttAbsences.cAbsence[26]:LABEL IN BROWSE brwAbsences = DonneNomColonne(26).
    ttAbsences.cAbsence[27]:LABEL IN BROWSE brwAbsences = DonneNomColonne(27).
    ttAbsences.cAbsence[28]:LABEL IN BROWSE brwAbsences = DonneNomColonne(28).
    ttAbsences.cAbsence[29]:LABEL IN BROWSE brwAbsences = DonneNomColonne(29).
    ttAbsences.cAbsence[30]:LABEL IN BROWSE brwAbsences = DonneNomColonne(30).
    ttAbsences.cAbsence[31]:LABEL IN BROWSE brwAbsences = DonneNomColonne(31).
    ttAbsences.cAbsence[32]:LABEL IN BROWSE brwAbsences = DonneNomColonne(32).
    ttAbsences.cAbsence[33]:LABEL IN BROWSE brwAbsences = DonneNomColonne(33).
    ttAbsences.cAbsence[34]:LABEL IN BROWSE brwAbsences = DonneNomColonne(34).
    ttAbsences.cAbsence[35]:LABEL IN BROWSE brwAbsences = DonneNomColonne(35).
    ttAbsences.cAbsence[36]:LABEL IN BROWSE brwAbsences = DonneNomColonne(36).
    ttAbsences.cAbsence[37]:LABEL IN BROWSE brwAbsences = DonneNomColonne(37).
    ttAbsences.cAbsence[38]:LABEL IN BROWSE brwAbsences = DonneNomColonne(38).
    ttAbsences.cAbsence[39]:LABEL IN BROWSE brwAbsences = DonneNomColonne(39).
    ttAbsences.cAbsence[40]:LABEL IN BROWSE brwAbsences = DonneNomColonne(40).

    ttAbsences.cAbsence[1]:column-fgcolor IN BROWSE brwAbsences =  {&Couleur_Symbole}.
    ttAbsences.cAbsence[2]:column-fgcolor IN BROWSE brwAbsences =  {&Couleur_Symbole}. 
    ttAbsences.cAbsence[3]:column-fgcolor IN BROWSE brwAbsences =  {&Couleur_Symbole}.
    ttAbsences.cAbsence[4]:column-fgcolor IN BROWSE brwAbsences =  {&Couleur_Symbole}.
    ttAbsences.cAbsence[5]:column-fgcolor IN BROWSE brwAbsences =  {&Couleur_Symbole}.
    ttAbsences.cAbsence[6]:column-fgcolor IN BROWSE brwAbsences =  {&Couleur_Symbole}.
    ttAbsences.cAbsence[7]:column-fgcolor IN BROWSE brwAbsences =  {&Couleur_Symbole}.
    ttAbsences.cAbsence[8]:column-fgcolor IN BROWSE brwAbsences =  {&Couleur_Symbole}.
    ttAbsences.cAbsence[9]:column-fgcolor IN BROWSE brwAbsences =  {&Couleur_Symbole}.
    ttAbsences.cAbsence[10]:column-fgcolor IN BROWSE brwAbsences = {&Couleur_Symbole}.
    ttAbsences.cAbsence[11]:column-fgcolor IN BROWSE brwAbsences = {&Couleur_Symbole}.
    ttAbsences.cAbsence[12]:column-fgcolor IN BROWSE brwAbsences = {&Couleur_Symbole}.
    ttAbsences.cAbsence[13]:column-fgcolor IN BROWSE brwAbsences = {&Couleur_Symbole}.
    ttAbsences.cAbsence[14]:column-fgcolor IN BROWSE brwAbsences = {&Couleur_Symbole}.
    ttAbsences.cAbsence[15]:column-fgcolor IN BROWSE brwAbsences = {&Couleur_Symbole}.
    ttAbsences.cAbsence[16]:column-fgcolor IN BROWSE brwAbsences = {&Couleur_Symbole}.
    ttAbsences.cAbsence[17]:column-fgcolor IN BROWSE brwAbsences = {&Couleur_Symbole}.
    ttAbsences.cAbsence[18]:column-fgcolor IN BROWSE brwAbsences = {&Couleur_Symbole}.
    ttAbsences.cAbsence[19]:column-fgcolor IN BROWSE brwAbsences = {&Couleur_Symbole}.
    ttAbsences.cAbsence[20]:column-fgcolor IN BROWSE brwAbsences = {&Couleur_Symbole}.
    ttAbsences.cAbsence[21]:column-fgcolor IN BROWSE brwAbsences = {&Couleur_Symbole}.
    ttAbsences.cAbsence[22]:column-fgcolor IN BROWSE brwAbsences = {&Couleur_Symbole}.
    ttAbsences.cAbsence[23]:column-fgcolor IN BROWSE brwAbsences = {&Couleur_Symbole}.
    ttAbsences.cAbsence[24]:column-fgcolor IN BROWSE brwAbsences = {&Couleur_Symbole}.
    ttAbsences.cAbsence[25]:column-fgcolor IN BROWSE brwAbsences = {&Couleur_Symbole}.
    ttAbsences.cAbsence[26]:column-fgcolor IN BROWSE brwAbsences = {&Couleur_Symbole}.
    ttAbsences.cAbsence[27]:column-fgcolor IN BROWSE brwAbsences = {&Couleur_Symbole}.
    ttAbsences.cAbsence[28]:column-fgcolor IN BROWSE brwAbsences = {&Couleur_Symbole}.
    ttAbsences.cAbsence[29]:column-fgcolor IN BROWSE brwAbsences = {&Couleur_Symbole}.
    ttAbsences.cAbsence[30]:column-fgcolor IN BROWSE brwAbsences = {&Couleur_Symbole}.
    ttAbsences.cAbsence[31]:column-fgcolor IN BROWSE brwAbsences = {&Couleur_Symbole}.
    ttAbsences.cAbsence[32]:column-fgcolor IN BROWSE brwAbsences = {&Couleur_Symbole}.
    ttAbsences.cAbsence[33]:column-fgcolor IN BROWSE brwAbsences = {&Couleur_Symbole}.
    ttAbsences.cAbsence[34]:column-fgcolor IN BROWSE brwAbsences = {&Couleur_Symbole}.
    ttAbsences.cAbsence[35]:column-fgcolor IN BROWSE brwAbsences = {&Couleur_Symbole}.
    ttAbsences.cAbsence[36]:column-fgcolor IN BROWSE brwAbsences = {&Couleur_Symbole}.
    ttAbsences.cAbsence[37]:column-fgcolor IN BROWSE brwAbsences = {&Couleur_Symbole}.
    ttAbsences.cAbsence[38]:column-fgcolor IN BROWSE brwAbsences = {&Couleur_Symbole}.
    ttAbsences.cAbsence[39]:column-fgcolor IN BROWSE brwAbsences = {&Couleur_Symbole}.
    ttAbsences.cAbsence[40]:column-fgcolor IN BROWSE brwAbsences = {&Couleur_Symbole}.

    ttAbsences.cAbsence[1]:width IN BROWSE brwAbsences =  length( ttAbsences.cAbsence[1]:label) * iFacteur.
    ttAbsences.cAbsence[2]:width IN BROWSE brwAbsences =  length( ttAbsences.cAbsence[2]:label) * iFacteur.
    ttAbsences.cAbsence[3]:width IN BROWSE brwAbsences =  length( ttAbsences.cAbsence[3]:label) * iFacteur.
    ttAbsences.cAbsence[4]:width IN BROWSE brwAbsences =  length( ttAbsences.cAbsence[4]:label) * iFacteur.
    ttAbsences.cAbsence[5]:width IN BROWSE brwAbsences =  length( ttAbsences.cAbsence[5]:label) * iFacteur.
    ttAbsences.cAbsence[6]:width IN BROWSE brwAbsences =  length( ttAbsences.cAbsence[6]:label) * iFacteur.
    ttAbsences.cAbsence[7]:width IN BROWSE brwAbsences =  length( ttAbsences.cAbsence[7]:label) * iFacteur.
    ttAbsences.cAbsence[8]:width IN BROWSE brwAbsences =  length( ttAbsences.cAbsence[8]:label) * iFacteur.
    ttAbsences.cAbsence[9]:width IN BROWSE brwAbsences =  length( ttAbsences.cAbsence[9]:label) * iFacteur.
    ttAbsences.cAbsence[10]:width IN BROWSE brwAbsences = length(ttAbsences.cAbsence[10]:label) * iFacteur.
    ttAbsences.cAbsence[11]:width IN BROWSE brwAbsences = length(ttAbsences.cAbsence[11]:label) * iFacteur.
    ttAbsences.cAbsence[12]:width IN BROWSE brwAbsences = length(ttAbsences.cAbsence[12]:label) * iFacteur.
    ttAbsences.cAbsence[13]:width IN BROWSE brwAbsences = length(ttAbsences.cAbsence[13]:label) * iFacteur.
    ttAbsences.cAbsence[14]:width IN BROWSE brwAbsences = length(ttAbsences.cAbsence[14]:label) * iFacteur.
    ttAbsences.cAbsence[15]:width IN BROWSE brwAbsences = length(ttAbsences.cAbsence[15]:label) * iFacteur.
    ttAbsences.cAbsence[16]:width IN BROWSE brwAbsences = length(ttAbsences.cAbsence[16]:label) * iFacteur.
    ttAbsences.cAbsence[17]:width IN BROWSE brwAbsences = length(ttAbsences.cAbsence[17]:label) * iFacteur.
    ttAbsences.cAbsence[18]:width IN BROWSE brwAbsences = length(ttAbsences.cAbsence[18]:label) * iFacteur.
    ttAbsences.cAbsence[19]:width IN BROWSE brwAbsences = length(ttAbsences.cAbsence[19]:label) * iFacteur.
    ttAbsences.cAbsence[20]:width IN BROWSE brwAbsences = length(ttAbsences.cAbsence[20]:label) * iFacteur.
    ttAbsences.cAbsence[21]:width IN BROWSE brwAbsences = length(ttAbsences.cAbsence[21]:label) * iFacteur.
    ttAbsences.cAbsence[22]:width IN BROWSE brwAbsences = length(ttAbsences.cAbsence[22]:label) * iFacteur.
    ttAbsences.cAbsence[23]:width IN BROWSE brwAbsences = length(ttAbsences.cAbsence[23]:label) * iFacteur.
    ttAbsences.cAbsence[24]:width IN BROWSE brwAbsences = length(ttAbsences.cAbsence[24]:label) * iFacteur.
    ttAbsences.cAbsence[25]:width IN BROWSE brwAbsences = length(ttAbsences.cAbsence[25]:label) * iFacteur.
    ttAbsences.cAbsence[26]:width IN BROWSE brwAbsences = length(ttAbsences.cAbsence[26]:label) * iFacteur.
    ttAbsences.cAbsence[27]:width IN BROWSE brwAbsences = length(ttAbsences.cAbsence[27]:label) * iFacteur.
    ttAbsences.cAbsence[28]:width IN BROWSE brwAbsences = length(ttAbsences.cAbsence[28]:label) * iFacteur.
    ttAbsences.cAbsence[29]:width IN BROWSE brwAbsences = length(ttAbsences.cAbsence[29]:label) * iFacteur.
    ttAbsences.cAbsence[30]:width IN BROWSE brwAbsences = length(ttAbsences.cAbsence[30]:label) * iFacteur.
    ttAbsences.cAbsence[31]:width IN BROWSE brwAbsences = length(ttAbsences.cAbsence[31]:label) * iFacteur.
    ttAbsences.cAbsence[32]:width IN BROWSE brwAbsences = length(ttAbsences.cAbsence[32]:label) * iFacteur.
    ttAbsences.cAbsence[33]:width IN BROWSE brwAbsences = length(ttAbsences.cAbsence[33]:label) * iFacteur.
    ttAbsences.cAbsence[34]:width IN BROWSE brwAbsences = length(ttAbsences.cAbsence[34]:label) * iFacteur.
    ttAbsences.cAbsence[35]:width IN BROWSE brwAbsences = length(ttAbsences.cAbsence[35]:label) * iFacteur.
    ttAbsences.cAbsence[36]:width IN BROWSE brwAbsences = length(ttAbsences.cAbsence[36]:label) * iFacteur.
    ttAbsences.cAbsence[37]:width IN BROWSE brwAbsences = length(ttAbsences.cAbsence[37]:label) * iFacteur.
    ttAbsences.cAbsence[38]:width IN BROWSE brwAbsences = length(ttAbsences.cAbsence[38]:label) * iFacteur.
    ttAbsences.cAbsence[39]:width IN BROWSE brwAbsences = length(ttAbsences.cAbsence[39]:label) * iFacteur.
    ttAbsences.cAbsence[40]:width IN BROWSE brwAbsences = length(ttAbsences.cAbsence[40]:label) * iFacteur.

    ttAbsences.cAbsence[1]:visible IN BROWSE brwAbsences =   ttAbsences.cAbsence[1]:label <> ".".
    ttAbsences.cAbsence[2]:visible IN BROWSE brwAbsences =   ttAbsences.cAbsence[2]:label <> ".".
    ttAbsences.cAbsence[3]:visible IN BROWSE brwAbsences =   ttAbsences.cAbsence[3]:label <> ".".
    ttAbsences.cAbsence[4]:visible IN BROWSE brwAbsences =   ttAbsences.cAbsence[4]:label <> ".".
    ttAbsences.cAbsence[5]:visible IN BROWSE brwAbsences =   ttAbsences.cAbsence[5]:label <> ".".
    ttAbsences.cAbsence[6]:visible IN BROWSE brwAbsences =   ttAbsences.cAbsence[6]:label <> ".".
    ttAbsences.cAbsence[7]:visible IN BROWSE brwAbsences =   ttAbsences.cAbsence[7]:label <> ".".
    ttAbsences.cAbsence[8]:visible IN BROWSE brwAbsences =   ttAbsences.cAbsence[8]:label <> ".".
    ttAbsences.cAbsence[9]:visible IN BROWSE brwAbsences =   ttAbsences.cAbsence[9]:label <> ".".
    ttAbsences.cAbsence[10]:visible IN BROWSE brwAbsences = ttAbsences.cAbsence[10]:label <> ".".
    ttAbsences.cAbsence[11]:visible IN BROWSE brwAbsences = ttAbsences.cAbsence[11]:label <> ".".
    ttAbsences.cAbsence[12]:visible IN BROWSE brwAbsences = ttAbsences.cAbsence[12]:label <> ".".
    ttAbsences.cAbsence[13]:visible IN BROWSE brwAbsences = ttAbsences.cAbsence[13]:label <> ".".
    ttAbsences.cAbsence[14]:visible IN BROWSE brwAbsences = ttAbsences.cAbsence[14]:label <> ".".
    ttAbsences.cAbsence[15]:visible IN BROWSE brwAbsences = ttAbsences.cAbsence[15]:label <> ".".
    ttAbsences.cAbsence[16]:visible IN BROWSE brwAbsences = ttAbsences.cAbsence[16]:label <> ".".
    ttAbsences.cAbsence[17]:visible IN BROWSE brwAbsences = ttAbsences.cAbsence[17]:label <> ".".
    ttAbsences.cAbsence[18]:visible IN BROWSE brwAbsences = ttAbsences.cAbsence[18]:label <> ".".
    ttAbsences.cAbsence[19]:visible IN BROWSE brwAbsences = ttAbsences.cAbsence[19]:label <> ".".
    ttAbsences.cAbsence[20]:visible IN BROWSE brwAbsences = ttAbsences.cAbsence[20]:label <> ".".
    ttAbsences.cAbsence[21]:visible IN BROWSE brwAbsences = ttAbsences.cAbsence[21]:label <> ".".
    ttAbsences.cAbsence[22]:visible IN BROWSE brwAbsences = ttAbsences.cAbsence[22]:label <> ".".
    ttAbsences.cAbsence[23]:visible IN BROWSE brwAbsences = ttAbsences.cAbsence[23]:label <> ".".
    ttAbsences.cAbsence[24]:visible IN BROWSE brwAbsences = ttAbsences.cAbsence[24]:label <> ".".
    ttAbsences.cAbsence[25]:visible IN BROWSE brwAbsences = ttAbsences.cAbsence[25]:label <> ".".
    ttAbsences.cAbsence[26]:visible IN BROWSE brwAbsences = ttAbsences.cAbsence[26]:label <> ".".
    ttAbsences.cAbsence[27]:visible IN BROWSE brwAbsences = ttAbsences.cAbsence[27]:label <> ".".
    ttAbsences.cAbsence[28]:visible IN BROWSE brwAbsences = ttAbsences.cAbsence[28]:label <> ".".
    ttAbsences.cAbsence[29]:visible IN BROWSE brwAbsences = ttAbsences.cAbsence[29]:label <> ".".
    ttAbsences.cAbsence[30]:visible IN BROWSE brwAbsences = ttAbsences.cAbsence[30]:label <> ".".
    ttAbsences.cAbsence[31]:visible IN BROWSE brwAbsences = ttAbsences.cAbsence[31]:label <> ".".
    ttAbsences.cAbsence[32]:visible IN BROWSE brwAbsences = ttAbsences.cAbsence[32]:label <> ".".
    ttAbsences.cAbsence[33]:visible IN BROWSE brwAbsences = ttAbsences.cAbsence[33]:label <> ".".
    ttAbsences.cAbsence[34]:visible IN BROWSE brwAbsences = ttAbsences.cAbsence[34]:label <> ".".
    ttAbsences.cAbsence[35]:visible IN BROWSE brwAbsences = ttAbsences.cAbsence[35]:label <> ".".
    ttAbsences.cAbsence[36]:visible IN BROWSE brwAbsences = ttAbsences.cAbsence[36]:label <> ".".
    ttAbsences.cAbsence[37]:visible IN BROWSE brwAbsences = ttAbsences.cAbsence[37]:label <> ".".
    ttAbsences.cAbsence[38]:visible IN BROWSE brwAbsences = ttAbsences.cAbsence[38]:label <> ".".
    ttAbsences.cAbsence[39]:visible IN BROWSE brwAbsences = ttAbsences.cAbsence[39]:label <> ".".
    ttAbsences.cAbsence[40]:visible IN BROWSE brwAbsences = ttAbsences.cAbsence[40]:label <> ".".

    ttAbsences.cAbsence[1]:column-font IN BROWSE brwAbsences =  14.
    ttAbsences.cAbsence[2]:column-font IN BROWSE brwAbsences =  14.
    ttAbsences.cAbsence[3]:column-font IN BROWSE brwAbsences =  14.
    ttAbsences.cAbsence[4]:column-font IN BROWSE brwAbsences =  14.
    ttAbsences.cAbsence[5]:column-font IN BROWSE brwAbsences =  14.
    ttAbsences.cAbsence[6]:column-font IN BROWSE brwAbsences =  14.
    ttAbsences.cAbsence[7]:column-font IN BROWSE brwAbsences =  14.
    ttAbsences.cAbsence[8]:column-font IN BROWSE brwAbsences =  14.
    ttAbsences.cAbsence[9]:column-font IN BROWSE brwAbsences =  14.
    ttAbsences.cAbsence[10]:column-font IN BROWSE brwAbsences = 14.
    ttAbsences.cAbsence[11]:column-font IN BROWSE brwAbsences = 14.
    ttAbsences.cAbsence[12]:column-font IN BROWSE brwAbsences = 14.
    ttAbsences.cAbsence[13]:column-font IN BROWSE brwAbsences = 14.
    ttAbsences.cAbsence[14]:column-font IN BROWSE brwAbsences = 14.
    ttAbsences.cAbsence[15]:column-font IN BROWSE brwAbsences = 14.
    ttAbsences.cAbsence[16]:column-font IN BROWSE brwAbsences = 14.
    ttAbsences.cAbsence[17]:column-font IN BROWSE brwAbsences = 14.
    ttAbsences.cAbsence[18]:column-font IN BROWSE brwAbsences = 14.
    ttAbsences.cAbsence[19]:column-font IN BROWSE brwAbsences = 14.
    ttAbsences.cAbsence[20]:column-font IN BROWSE brwAbsences = 14.
    ttAbsences.cAbsence[21]:column-font IN BROWSE brwAbsences = 14.
    ttAbsences.cAbsence[22]:column-font IN BROWSE brwAbsences = 14.
    ttAbsences.cAbsence[23]:column-font IN BROWSE brwAbsences = 14.
    ttAbsences.cAbsence[24]:column-font IN BROWSE brwAbsences = 14.
    ttAbsences.cAbsence[25]:column-font IN BROWSE brwAbsences = 14.
    ttAbsences.cAbsence[26]:column-font IN BROWSE brwAbsences = 14.
    ttAbsences.cAbsence[27]:column-font IN BROWSE brwAbsences = 14.
    ttAbsences.cAbsence[28]:column-font IN BROWSE brwAbsences = 14.
    ttAbsences.cAbsence[29]:column-font IN BROWSE brwAbsences = 14.
    ttAbsences.cAbsence[30]:column-font IN BROWSE brwAbsences = 14.
    ttAbsences.cAbsence[31]:column-font IN BROWSE brwAbsences = 14.
    ttAbsences.cAbsence[32]:column-font IN BROWSE brwAbsences = 14.
    ttAbsences.cAbsence[33]:column-font IN BROWSE brwAbsences = 14.
    ttAbsences.cAbsence[34]:column-font IN BROWSE brwAbsences = 14.
    ttAbsences.cAbsence[35]:column-font IN BROWSE brwAbsences = 14.
    ttAbsences.cAbsence[36]:column-font IN BROWSE brwAbsences = 14.
    ttAbsences.cAbsence[37]:column-font IN BROWSE brwAbsences = 14.
    ttAbsences.cAbsence[38]:column-font IN BROWSE brwAbsences = 14.
    ttAbsences.cAbsence[39]:column-font IN BROWSE brwAbsences = 14.
    ttAbsences.cAbsence[40]:column-font IN BROWSE brwAbsences = 14.

    rctConges:BGCOLOR = {&Couleur_Conges}.
    rctFormationGI:BGCOLOR = {&Couleur_FormationGI}.
    rctAutres:BGCOLOR = {&Couleur_Autre}.
    rctMaladie:BGCOLOR = {&Couleur_Maladie}.
    rctFerie:BGCOLOR = {&Couleur_Ferie}.
    rctFormationClient:BGCOLOR = {&Couleur_FormationClient}.
    rctScolaires:BGCOLOR = {&Couleur_Scolaire}.

    filJournee:SCREEN-VALUE = {&Caractere_Journee}.
    filMatin:SCREEN-VALUE = {&Caractere_Matin}.
    filApresMidi:SCREEN-VALUE = {&Caractere_ApresMidi}.

    filJournee:FGCOLOR = {&Couleur_Symbole}.
    filMatin:FGCOLOR = {&Couleur_Symbole}.
    filApresMidi:FGCOLOR = {&Couleur_Symbole}.

    /* Chargement de la table des congés */
    EMPTY TEMP-TABLE ttAbsences.

    dDateDebut = TODAY.
    dDateFin = ADD-INTERVAL(dDateDebut,1,"years").
    dDateEnCours = dDateDebut.
    REPEAT:
        lJourAPrendre = TRUE.
        /* Ne pas faire apparaitre les samedi et dimanche si demandé */
        IF (gDonnePreference("PREFS-ABSENCES-PAS-WE") = "OUI" AND (WEEKDAY(dDateEnCours) = 7 OR WEEKDAY(dDateEnCours) = 1)) THEN lJourAPrendre = FALSE.
        
        IF lJourAPrendre THEN DO:

            CREATE ttAbsences.
            ttAbsences.ddate = dDateEnCours.
            ttAbsences.cJour = gRemplaceVariables("%j% %jj% %m%","*",dDateEnCours,0).
            ttAbsences.iSemaine = DonneSemaine(dDateEnCours).
            ttAbsences.lFerie = gJourFerie(dDateEnCours).
            ttAbsences.lScolaire = gVacancesScolaires(dDateEnCours).
            /*ttAbsences.cJour = string(dDateEnCours,"99/99/9999").*/
    
        END.
        dDateEnCours = dDateEnCours + 1.
        IF dDateEnCours > dDateFin THEN LEAVE.
    END.

    /* ouverture du query */
    {&OPEN-QUERY-brwAbsences}

    AfficheInformations("",0).

    RUN TopChronoGeneral.
    RUN TopChronoPartiel.
    
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

    FOR EACH    Absence EXCLUSIVE-LOCK
        WHERE   Absence.cUtilisateur = gcUtilisateur
        AND     Absence.dDate >= TODAY
        :
        DELETE Absence.
    END.

    FOR EACH    ttAbsences
        WHERE   ttAbsences.cAbsence[1] <> ""
        :
        CREATE Absence.
        Absence.cUtilisateur = gcUtilisateur.
        Absence.dDate = ttAbsences.dDate.
    END.
    RELEASE Absence.
    RUN gereboutons.
    RUN DonneOrdre("REINIT-BOUTONS-3").
    

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
  ENABLE ALL WITH FRAME frmModule.
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE SaisieUtilisateur C-Win 
PROCEDURE SaisieUtilisateur :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE OUTPUT PARAMETER cUtilisateur-ou AS CHARACTER NO-UNDO.



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
    IF gGetEtSupParam("ABSENCES-RECHARGER") = "OUI" THEN DO:
        RUN Recharger.
    END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION AfficheInformations C-Win 
FUNCTION AfficheInformations RETURNS LOGICAL
  (cLibelle-in AS CHARACTER,iTemporisation-in AS INTEGER) :
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION DonneCentrage C-Win 
FUNCTION DonneCentrage RETURNS INTEGER
  ( cTitreColonne-in AS CHARACTER ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
  DEFINE VARIABLE iRetour AS INTEGER NO-UNDO INIT 0.

  iRetour = TRUNCATE(length(cTitreColonne-in) / 6,0).

  RETURN iRetour.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION DonneCouleurCelulle C-Win 
FUNCTION DonneCouleurCelulle RETURNS INTEGER
  ( iNumero-in AS INTEGER, dDate-in AS DATE) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
    DEFINE VARIABLE iRetour AS INTEGER NO-UNDO INIT ?.
    DEFINE VARIABLE iSemaine AS INTEGER NO-UNDO.


    
    FIND FIRST  ttUtils
        WHERE   ttUtils.iColonne = iNumero-in
        NO-ERROR.
    IF AVAILABLE(ttutils) THEN DO:
        FIND FIRST  Absence  NO-LOCK
            WHERE   Absence.cUtilisateur = ttutils.cUtil
            AND     Absence.dDate = dDate-in
            NO-ERROR.
        IF AVAILABLE(Absence) THEN DO:
                IF Absence.cTypeAbsence = "M" THEN iRetour = {&Couleur_Maladie}.
                IF Absence.cTypeAbsence = "C" THEN iRetour = {&Couleur_Conges}.
                IF Absence.cTypeAbsence = "FG" THEN iRetour = {&Couleur_FormationGI}.
                IF Absence.cTypeAbsence = "A" THEN iRetour = {&Couleur_Autre}.
                IF Absence.cTypeAbsence = "FC" THEN iRetour = {&Couleur_FormationClient}.
        END.
    END.

    IF iRetour = ?  THEN DO:
        IF gDonnePreference("PREFS-ABSENCES-PAS-WE") = "OUI" THEN DO:
            iSemaine = DonneSemaine(dDate-in).
            iRetour = (IF iSemaine / 2 = INTEGER(iSemaine / 2) THEN {&Couleur_Semaine} ELSE ?).
        END.
        ELSE DO:
            IF (WEEKDAY(dDate-in) = 7 OR WEEKDAY(dDate-in) = 1) THEN iRetour = {&Couleur_Semaine}.
        END.
    END.

    RETURN iRetour.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION DonneNomColonne C-Win 
FUNCTION DonneNomColonne RETURNS CHARACTER
  ( iNumero-in AS INTEGER ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
        DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO INIT ".".

        FIND FIRST  ttUtils
            WHERE   ttUtils.iColonne = iNumero-in
            NO-ERROR.
        IF AVAILABLE(ttUtils) THEN cRetour = ttUtils.cVraiNom.
        IF cRetour = "" THEN cRetour = ".".

  RETURN cRetour.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION DonneValeurColonne C-Win 
FUNCTION DonneValeurColonne RETURNS CHARACTER
  ( iNumero-in AS INTEGER, dDate-in AS DATE) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
    DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO INIT "".
    DEFINE VARIABLE iNombre AS INTEGER NO-UNDO INIT 1.
    
    cRetour = "".

    /*IF NOT(gJourFerie(dDate-in)) THEN DO:*/
        FIND FIRST  ttUtils
            WHERE   ttUtils.iColonne = iNumero-in
            NO-ERROR.
        IF AVAILABLE(ttUtils) THEN DO:
            FIND FIRST  Absences  NO-LOCK
                WHERE   Absences.cUtilisateur = ttUtils.cUtil
                AND     Absences.dDate = dDate-in
                NO-ERROR.
            IF AVAILABLE(Absences) THEN DO:
                iNombre = DonneCentrage(DonneNomColonne(iNumero-in)).
                IF absences.lMatin AND absences.lApresMidi THEN
                    cRetour = FILL(" ",iNombre) + {&Caractere_Journee}.
                ELSE IF absences.lMatin THEN
                    cRetour = FILL(" ",iNombre) + {&Caractere_Matin}.
                ELSE IF absences.lApresMidi THEN
                    cRetour = FILL(" ",iNombre) + {&Caractere_ApresMidi}.
            END.
        END.
    /*END.*/

  RETURN cRetour.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

