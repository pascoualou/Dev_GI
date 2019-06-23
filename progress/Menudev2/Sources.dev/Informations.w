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

DEFINE VARIABLE cFichierNotes AS CHARACTER NO-UNDO.

DEFINE VARIABLE cInfosDate AS CHARACTER NO-UNDO.

DEFINE VARIABLE cSvgMessage AS CHARACTER NO-UNDO.

DEFINE TEMP-TABLE ttUtil    
    FIELD cUtilisateur LIKE utilisateurs.cutilisateur
    FIELD cVraiNom LIKE utilisateurs.cVraiNom
    FIELD lSelection AS LOGICAL
    FIELD lConnecte AS LOGICAL
     INDEX ix01 cUtilisateur
    .

DEFINE BUFFER bttUtil FOR ttUtil.
DEFINE BUFFER butilisateurs FOR utilisateurs.

DEFINE TEMP-TABLE ttMessages
    LIKE ordres
    FIELD cIdMessage AS CHARACTER
    FIELD cLibSens AS CHARACTER
    FIELD cQui AS CHARACTER
    FIELD cVraiQui AS CHARACTER
    FIELD cHeure AS CHARACTER
    
    INDEX ixMessage dDate iordre
    .

DEFINE VARIABLE hColonneEnCours AS HANDLE NO-UNDO.
DEFINE VARIABLE hColonneOld AS HANDLE NO-UNDO.
DEFINE VARIABLE lTriAsc AS LOGICAL NO-UNDO INIT TRUE.
DEFINE VARIABLE iNombreMessages AS INTEGER NO-UNDO INIT 0.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME frmModule
&Scoped-define BROWSE-NAME brwMessages

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ttMessages ttutil

/* Definitions for BROWSE brwMessages                                   */
&Scoped-define FIELDS-IN-QUERY-brwMessages ttMessages.cLibSens ttMessages.dDate ttMessages.cHeure ttMessages.cVraiQui ttMessages.cMessage   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brwMessages ttMessages.cLibSens   
&Scoped-define ENABLED-TABLES-IN-QUERY-brwMessages ttMessages
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-brwMessages ttMessages
&Scoped-define SELF-NAME brwMessages
&Scoped-define QUERY-STRING-brwMessages FOR EACH ttMessages
&Scoped-define OPEN-QUERY-brwMessages OPEN QUERY {&SELF-NAME} FOR EACH ttMessages.
&Scoped-define TABLES-IN-QUERY-brwMessages ttMessages
&Scoped-define FIRST-TABLE-IN-QUERY-brwMessages ttMessages


/* Definitions for BROWSE brwUtilisateurs                               */
&Scoped-define FIELDS-IN-QUERY-brwUtilisateurs ttutil.cVraiNom ttutil.lconnecte ttutil.lselection   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brwUtilisateurs   
&Scoped-define SELF-NAME brwUtilisateurs
&Scoped-define QUERY-STRING-brwUtilisateurs FOR EACH ttutil NO-LOCK     WHERE filRecherche:SCREEN-VALUE IN FRAME frmModule = ""     OR ttutil.cUtilisateur MATCHES "*" + filRecherche:SCREEN-VALUE IN FRAME frmModule + "*"     OR ttutil.cVraiNom MATCHES "*" + filRecherche:SCREEN-VALUE IN FRAME frmModule + "*"     BY ttUtil.cVraiNom     INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-brwUtilisateurs OPEN QUERY {&SELF-NAME} FOR EACH ttutil NO-LOCK     WHERE filRecherche:SCREEN-VALUE IN FRAME frmModule = ""     OR ttutil.cUtilisateur MATCHES "*" + filRecherche:SCREEN-VALUE IN FRAME frmModule + "*"     OR ttutil.cVraiNom MATCHES "*" + filRecherche:SCREEN-VALUE IN FRAME frmModule + "*"     BY ttUtil.cVraiNom     INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-brwUtilisateurs ttutil
&Scoped-define FIRST-TABLE-IN-QUERY-brwUtilisateurs ttutil


/* Definitions for FRAME frmModule                                      */
&Scoped-define OPEN-BROWSERS-IN-QUERY-frmModule ~
    ~{&OPEN-QUERY-brwMessages}~
    ~{&OPEN-QUERY-brwUtilisateurs}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-1 RECT-2 RECT-3 brwMessages ~
tglTousLesMessages TOGGLE-1 btnenvoi brwUtilisateurs TOGGLE-2 filRecherche ~
edtinfos filInfosListe filNombre 
&Scoped-Define DISPLAYED-OBJECTS tglTousLesMessages EDITOR-1 TOGGLE-1 ~
TOGGLE-2 filRecherche edtinfos edtRecherche filInfosListe filNombre 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.

/* Menu Definitions                                                     */
DEFINE MENU POPUP-MENU-brwMessages 
       MENU-ITEM m_Supprimer_le_message_en_cou LABEL "Supprimer le(s) message(s) sélectionné(s)"
       RULE
       MENU-ITEM m_Marquer_le_message_comme_Lu LABEL "Marquer le(s) message(s) comme 'Lu' / 'Non lu'"
       RULE
       MENU-ITEM m_Envoyer_le_message_en_cours LABEL "Envoyer le(s) message(s) sélectionné(s) dans le presse-papier"
       RULE
       MENU-ITEM m_Répondre_à_lutilisateur LABEL "Répondre à l'utilisateur"
       RULE
       MENU-ITEM m_Fermer_ce_menu LABEL "Fermer ce menu".


/* Definitions of the field level widgets                               */
DEFINE BUTTON btnenvoi 
     LABEL "Envoyer" 
     SIZE 13 BY 7.38.

DEFINE VARIABLE EDITOR-1 AS CHARACTER INITIAL "Saisissez un message ci dessous, choisissez le ou les destinataires et appuyez sur le bouton 'Envoyer' pour le transmettre. Si un utilisateur sélectionné n'est pas connecté, il aura le message à sa prochaine connexion." 
     VIEW-AS EDITOR NO-BOX
     SIZE 77 BY 2.86
     FGCOLOR 2 FONT 6 NO-UNDO.

DEFINE VARIABLE edtinfos AS CHARACTER 
     VIEW-AS EDITOR MAX-CHARS 256 SCROLLBAR-VERTICAL
     SIZE 76 BY 4.05 NO-UNDO.

DEFINE VARIABLE edtRecherche AS CHARACTER INITIAL "La recherche se fait sur le code utilisateur ainsi que sur le ~"vrai nom~" saisi dans les préférences." 
     VIEW-AS EDITOR NO-BOX
     SIZE 19 BY 3.81
     FGCOLOR 2 FONT 4 NO-UNDO.

DEFINE VARIABLE filInfosListe AS CHARACTER FORMAT "X(256)":U INITIAL "(Par défaut, seuls les messages des 7 derniers jours sont listés. Double clic sur le message pour répondre directement à l'utilisateur)" 
      VIEW-AS TEXT 
     SIZE 132 BY .62
     FGCOLOR 2  NO-UNDO.

DEFINE VARIABLE filNombre AS CHARACTER FORMAT "X(256)":U INITIAL "9999 / 9999" 
     LABEL "Nombre de messages" 
      VIEW-AS TEXT 
     SIZE 13 BY .62 NO-UNDO.

DEFINE VARIABLE filRecherche AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 19 BY .95 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 1 BY 8.81.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 1 BY 8.81.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 163 BY .24.

DEFINE VARIABLE tglTousLesMessages AS LOGICAL INITIAL no 
     LABEL "Afficher tous les messages" 
     VIEW-AS TOGGLE-BOX
     SIZE 30 BY .71 NO-UNDO.

DEFINE VARIABLE TOGGLE-1 AS LOGICAL INITIAL no 
     LABEL "Envoyer le message à tous les utilisateurs" 
     VIEW-AS TOGGLE-BOX
     SIZE 55 BY .95
     FONT 11 NO-UNDO.

DEFINE VARIABLE TOGGLE-2 AS LOGICAL INITIAL no 
     LABEL "Message important (Sera affiché dans une fenêtre)" 
     VIEW-AS TOGGLE-BOX
     SIZE 72 BY .95
     FONT 11 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brwMessages FOR 
      ttMessages SCROLLING.

DEFINE QUERY brwUtilisateurs FOR 
      ttutil SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brwMessages
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brwMessages C-Win _FREEFORM
  QUERY brwMessages DISPLAY
      ttMessages.cLibSens FORMAT "X(3)" LABEL "<>"
    ttMessages.dDate FORMAT "99/99/9999" LABEL "Date"
    ttMessages.cHeure LABEL "Heure"
    ttMessages.cVraiQui FORMAT "X(15)" LABEL "Qui"
    ttMessages.cMessage FORMAT "X(255)" LABEL "Message"
 ENABLE ttMessages.cLibSens
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS MULTIPLE NO-TAB-STOP SIZE 163 BY 7.86 FIT-LAST-COLUMN.

DEFINE BROWSE brwUtilisateurs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brwUtilisateurs C-Win _FREEFORM
  QUERY brwUtilisateurs NO-LOCK DISPLAY
      ttutil.cVraiNom COLUMN-LABEL "Utilisateur" FORMAT "X(30)":U WIDTH 24
ttutil.lconnecte COLUMN-LABEL "Connecté" FORMAT "OUI/":U WIDTH 10
ttutil.lselection COLUMN-LABEL "Sél." FORMAT "X/":U WIDTH 7
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS NO-TAB-STOP SIZE 44 BY 5.24
         BGCOLOR 15  ROW-HEIGHT-CHARS .52 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME frmModule
     brwMessages AT ROW 1.95 COL 2 WIDGET-ID 200
     tglTousLesMessages AT ROW 10.05 COL 2 WIDGET-ID 38 NO-TAB-STOP 
     EDITOR-1 AT ROW 11.48 COL 3 NO-LABEL WIDGET-ID 10 NO-TAB-STOP 
     TOGGLE-1 AT ROW 12.67 COL 85 WIDGET-ID 12 NO-TAB-STOP 
     btnenvoi AT ROW 12.67 COL 151 WIDGET-ID 4 NO-TAB-STOP 
     brwUtilisateurs AT ROW 14.81 COL 103 WIDGET-ID 100
     TOGGLE-2 AT ROW 15.05 COL 3 WIDGET-ID 20 NO-TAB-STOP 
     filRecherche AT ROW 15.29 COL 81 COLON-ALIGNED NO-LABEL WIDGET-ID 46
     edtinfos AT ROW 16.24 COL 3 NO-LABEL WIDGET-ID 32
     edtRecherche AT ROW 16.48 COL 83 NO-LABEL WIDGET-ID 56 NO-TAB-STOP 
     filInfosListe AT ROW 1.24 COL 32 COLON-ALIGNED NO-LABEL WIDGET-ID 44 NO-TAB-STOP 
     filNombre AT ROW 10.05 COL 161 RIGHT-ALIGNED WIDGET-ID 58 NO-TAB-STOP 
     " (double-clic pour sélectionner)" VIEW-AS TEXT
          SIZE 30 BY .95 AT ROW 13.62 COL 118 WIDGET-ID 26
          FGCOLOR 2 FONT 13
     "Historique des messages :" VIEW-AS TEXT
          SIZE 32 BY .95 AT ROW 1 COL 2 WIDGET-ID 34
          FONT 11
     "1 - Saisissez le message......." VIEW-AS TEXT
          SIZE 34 BY .95 AT ROW 14.1 COL 3 WIDGET-ID 18
          FGCOLOR 12 FONT 11
     "2 - Indiquez le ou les destinataires......." VIEW-AS TEXT
          SIZE 47 BY .95 AT ROW 11.48 COL 83 WIDGET-ID 22
          FGCOLOR 12 FONT 11
     "ou aux utilisateurs suivants :" VIEW-AS TEXT
          SIZE 33 BY .95 AT ROW 13.62 COL 85 WIDGET-ID 14
          FONT 11
     "3 - Envoyez" VIEW-AS TEXT
          SIZE 13 BY .95 AT ROW 11.48 COL 151 WIDGET-ID 30
          FGCOLOR 12 FONT 11
     "Recherche..." VIEW-AS TEXT
          SIZE 14 BY .71 AT ROW 14.57 COL 83 WIDGET-ID 48
     RECT-1 AT ROW 11.48 COL 81 WIDGET-ID 24
     RECT-2 AT ROW 11.48 COL 149 WIDGET-ID 28
     RECT-3 AT ROW 11 COL 2 WIDGET-ID 36
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 2 ROW 1.14
         SIZE 166 BY 20.6
         TITLE BGCOLOR 2 FGCOLOR 15 "Envoi de messages".


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
         WIDTH              = 167.8
         MAX-HEIGHT         = 33.95
         MAX-WIDTH          = 204.8
         VIRTUAL-HEIGHT     = 33.95
         VIRTUAL-WIDTH      = 204.8
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
/* SETTINGS FOR FRAME frmModule
   FRAME-NAME                                                           */
/* BROWSE-TAB brwMessages RECT-3 frmModule */
/* BROWSE-TAB brwUtilisateurs btnenvoi frmModule */
ASSIGN 
       brwMessages:POPUP-MENU IN FRAME frmModule             = MENU POPUP-MENU-brwMessages:HANDLE
       brwMessages:COLUMN-RESIZABLE IN FRAME frmModule       = TRUE.

/* SETTINGS FOR EDITOR EDITOR-1 IN FRAME frmModule
   NO-ENABLE                                                            */
ASSIGN 
       EDITOR-1:READ-ONLY IN FRAME frmModule        = TRUE.

/* SETTINGS FOR EDITOR edtRecherche IN FRAME frmModule
   NO-ENABLE                                                            */
ASSIGN 
       edtRecherche:READ-ONLY IN FRAME frmModule        = TRUE.

/* SETTINGS FOR FILL-IN filNombre IN FRAME frmModule
   ALIGN-R                                                              */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brwMessages
/* Query rebuild information for BROWSE brwMessages
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH ttMessages.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE brwMessages */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brwUtilisateurs
/* Query rebuild information for BROWSE brwUtilisateurs
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH ttutil NO-LOCK
    WHERE filRecherche:SCREEN-VALUE IN FRAME frmModule = ""
    OR ttutil.cUtilisateur MATCHES "*" + filRecherche:SCREEN-VALUE IN FRAME frmModule + "*"
    OR ttutil.cVraiNom MATCHES "*" + filRecherche:SCREEN-VALUE IN FRAME frmModule + "*"
    BY ttUtil.cVraiNom
    INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE brwUtilisateurs */
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


&Scoped-define BROWSE-NAME brwMessages
&Scoped-define SELF-NAME brwMessages
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwMessages C-Win
ON DEFAULT-ACTION OF brwMessages IN FRAME frmModule
DO:
    filRecherche:SCREEN-VALUE = "".
    APPLY "VALUE-CHANGED" TO filRecherche.
    RUN Reponse.  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwMessages C-Win
ON DELETE-CHARACTER OF brwMessages IN FRAME frmModule
DO:
  RUN GereInformations("EFFACE-ORDRE-SELECTIONNE").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwMessages C-Win
ON ROW-DISPLAY OF brwMessages IN FRAME frmModule
DO:
  
  DEFINE VARIABLE iCouleur AS INTEGER NO-UNDO.

  iCouleur = 0.
  IF ttMessages.lprioritaire THEN icouleur = 3.
  IF ttMessages.lErreur THEN icouleur = 12.
  IF (ttMessages.cSens = "R" AND ttMessages.lCollegue AND NOT ttMessages.lLu) THEN iCouleur = 2.

  IF iCouleur <> 0 AND ttMessages.cQui <> ">" THEN DO:
      ttMessages.cLibSens:BGCOLOR IN BROWSE brwMessages = iCouleur.
      ttMessages.cLibSens:FGCOLOR IN BROWSE brwMessages = 15.
      ttMessages.cLibSens:FONT IN BROWSE brwMessages = 6.

      ttMessages.dDate:BGCOLOR IN BROWSE brwMessages = iCouleur.
      ttMessages.dDate:FGCOLOR IN BROWSE brwMessages = 15.
      ttMessages.dDate:FONT IN BROWSE brwMessages = 6.

      ttMessages.cHeure:BGCOLOR IN BROWSE brwMessages = iCouleur.
      ttMessages.cHeure:FGCOLOR IN BROWSE brwMessages = 15.
      ttMessages.cHeure:FONT IN BROWSE brwMessages = 6.

      ttMessages.cVraiQui:BGCOLOR IN BROWSE brwMessages = iCouleur.
      ttMessages.cVraiQui:FGCOLOR IN BROWSE brwMessages = 15.
      ttMessages.cVraiQui:FONT IN BROWSE brwMessages = 6.

      ttMessages.cMessage:BGCOLOR IN BROWSE brwMessages = iCouleur.
      ttMessages.cMessage:FGCOLOR IN BROWSE brwMessages = 15.
      ttMessages.cMessage:FONT IN BROWSE brwMessages = 6.

  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwMessages C-Win
ON START-SEARCH OF brwMessages IN FRAME frmModule
DO:
  
        /* Récupération de la colonne en cours */       
    hColonneEnCours = brwMessages:CURRENT-COLUMN.

    IF hColonneEnCours <> hColonneOld THEN DO:
        lTriAsc = TRUE.
    END.
    ELSE DO:
        lTriAsc = NOT(lTriAsc).
    END.

    RUN OuvreQuery(hColonneEnCours:LABEL).

    /* Sauvegarde de la colonne en cours pour le prochain coup */
    hColonneOld = hColonneEnCours.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwMessages C-Win
ON VALUE-CHANGED OF brwMessages IN FRAME frmModule
DO:
  
  filRecherche:SCREEN-VALUE = "".
  APPLY "VALUE-CHANGED" TO filRecherche.
  RUN GerePopup.
  brwMessages:TOOLTIP = ttMessages.cMessage.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brwUtilisateurs
&Scoped-define SELF-NAME brwUtilisateurs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwUtilisateurs C-Win
ON DEFAULT-ACTION OF brwUtilisateurs IN FRAME frmModule
DO:
  IF not(AVAILABLE(ttutil)) THEN RETURN NO-APPLY.
      
  ttutil.lSelection = NOT(ttutil.lSelection).
  RELEASE ttutil.
  brwUtilisateurs:REFRESH().
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnenvoi
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnenvoi C-Win
ON CHOOSE OF btnenvoi IN FRAME frmModule /* Envoyer */
DO:
  DEFINE VARIABLE cTempo AS CHARACTER NO-UNDO.
  DEFINE VARIABLE lMessageCollegue AS LOGICAL NO-UNDO.
  DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO.

  cTempo = edtinfos:SCREEN-VALUE.
  /*cTempo = REPLACE(cTempo,CHR(10),"%s").*/
  
  lMessageCollegue = TRUE.
  IF toggle-2:CHECKED THEN lMessageCollegue = FALSE.

  IF ctempo = "" THEN DO:
    RUN AfficheMessageAvecTemporisation("Messages","Votre message est vide !",FALSE,0,"OK","",FALSE,OUTPUT cRetour).
    RETURN.
  END.

  FIND FIRST ttutil WHERE ttutil.lselection
      NO-ERROR.
  IF NOT(AVAILABLE(ttutil)) THEN DO:
    RUN AfficheMessageAvecTemporisation("Messages","Veuillez sélectionner au moins un utilisateur !",FALSE,0,"OK","",FALSE,OUTPUT cRetour).
    RETURN.
  END.

  FOR EACH ttutil WHERE ttutil.lselection:
    RUN EnvoiOrdre("INFOS",cTempo,ttutil.cutilisateur,gcUtilisateur,toggle-2:Checked,lMessageCollegue).
  END.
  edtinfos:SCREEN-VALUE = "".

  RUN recharger.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME edtinfos
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL edtinfos C-Win
ON GO OF edtinfos IN FRAME frmModule
DO:
  APPLY "CHOOSE" TO btnenvoi.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filRecherche
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filRecherche C-Win
ON VALUE-CHANGED OF filRecherche IN FRAME frmModule
DO:
  {&OPEN-QUERY-brwUtilisateurs}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Envoyer_le_message_en_cours
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Envoyer_le_message_en_cours C-Win
ON CHOOSE OF MENU-ITEM m_Envoyer_le_message_en_cours /* Envoyer le(s) message(s) sélectionné(s) dans le presse-papier */
DO:
  
    RUN GereInformations("PPAPIER-ORDRE-ENCOURS").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Marquer_le_message_comme_Lu
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Marquer_le_message_comme_Lu C-Win
ON CHOOSE OF MENU-ITEM m_Marquer_le_message_comme_Lu /* Marquer le(s) message(s) comme 'Lu' / 'Non lu' */
DO:
  
    RUN GereInformations("LU-NONLU-ORDRE-ENCOURS").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Répondre_à_lutilisateur
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Répondre_à_lutilisateur C-Win
ON CHOOSE OF MENU-ITEM m_Répondre_à_lutilisateur /* Répondre à l'utilisateur */
DO:
  
    RUN GereInformations("LU-ORDRE-ENCOURS").
    RUN GereInformations("REPONSE").    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Supprimer_le_message_en_cou
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Supprimer_le_message_en_cou C-Win
ON CHOOSE OF MENU-ITEM m_Supprimer_le_message_en_cou /* Supprimer le(s) message(s) sélectionné(s) */
DO:
  
    RUN GereInformations("EFFACE-ORDRE-SELECTIONNE").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglTousLesMessages
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglTousLesMessages C-Win
ON VALUE-CHANGED OF tglTousLesMessages IN FRAME frmModule /* Afficher tous les messages */
DO:
  RUN Recharger.
  APPLY "entry" TO brwMessages.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME TOGGLE-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL TOGGLE-1 C-Win
ON VALUE-CHANGED OF TOGGLE-1 IN FRAME frmModule /* Envoyer le message à tous les utilisateurs */
DO:
  
    filRecherche:SCREEN-VALUE = "".
    APPLY "VALUE-CHANGED" TO filRecherche.
  FOR EACH ttutil:
      ttutil.lselection = SELF:CHECKED.
  END.

  brwutilisateurs:REFRESH().
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brwMessages
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ChargeMessages C-Win 
PROCEDURE ChargeMessages :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE iJours AS INTEGER NO-UNDO.
    
    iJours = integer(DonnePreference("INFOS-JOURS-MAX")).

    EMPTY TEMP-TABLE ttMessages.
    iNombreMessages = 0.
    DO WITH FRAME frmModule:
        FOR EACH ordres NO-LOCK
           WHERE ordres.cutilisateur = gcUtilisateur
           AND ordres.cAction = "INFOS"
           :
            IF ordres.cMessageDistribue = ">" THEN NEXT.
            iNombreMessages = iNombreMessages + 1.
            IF not(tglTousLesMessages:CHECKED) AND ordres.ddate < (TODAY - iJours) THEN NEXT.
            CREATE ttMessages.
            BUFFER-COPY ordres TO ttMessages.
            ASSIGN
                ttMessages.cLibSens = (IF (ordres.cSens = "R" OR ordres.cSens = ? OR ordres.csens = "") THEN "<--" ELSE "-->")
                ttMessages.cHeure = STRING(ordres.iordre,"hh:mm")
                ttMessages.cQui = ordres.filler
                ttMessages.cVraiQui = DonneVraiNomUtilisateur(ttMessages.cQui)
                ttMessages.cIdMessage = ttMessages.cSens + "-" + STRING(ttMessages.dDate,"99/99/9999") + "-" + STRING(ttMessages.iOrdre) + "-" + ttMessages.cQui + "-" + ttMessages.cMessage
                .
        END.
       
        {&OPEN-QUERY-brwMessages}
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ChargeUtilisateurs C-Win 
PROCEDURE ChargeUtilisateurs :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    EMPTY TEMP-TABLE ttutil.
    FOR EACH utilisateurs NO-LOCK
        :
        IF utilisateur.cutilisateur = "ADMIN" THEN NEXT.
        CREATE ttutil.
        ASSIGN
            ttUtil.cVraiNom = DonneVraiNomUtilisateur(utilisateur.cutilisateur)
            ttutil.cutilisateur = utilisateur.cutilisateur
            ttutil.lconnecte = utilisateur.lconnecte
            ttutil.lselection = FALSE.
        .
    END.
    
     {&OPEN-QUERY-brwUtilisateurs}

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
  DISPLAY tglTousLesMessages EDITOR-1 TOGGLE-1 TOGGLE-2 filRecherche edtinfos 
          edtRecherche filInfosListe filNombre 
      WITH FRAME frmModule IN WINDOW C-Win.
  ENABLE RECT-1 RECT-2 RECT-3 brwMessages tglTousLesMessages TOGGLE-1 btnenvoi 
         brwUtilisateurs TOGGLE-2 filRecherche edtinfos filInfosListe filNombre 
      WITH FRAME frmModule IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-frmModule}
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
                IF DonneEtSupprimeParametre("INFOS-RECHARGER") = "OUI" THEN RUN Recharger.
                /* Affichage de la frame principale */
                VIEW FRAME frmModule.
                FRAME frmModule:MOVE-TO-TOP().
                RUN MajInfosFrame.
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
    gcAideModifier = "#INTERDIT#".
    gcAideSupprimer = "#INTERDIT#".
    gcAideImprimer = "#INTERDIT#".
    gcAideRaf = "Recharger le module informations".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE GereInformations C-Win 
PROCEDURE GereInformations :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    DEFINE INPUT PARAMETER cAction-in AS CHARACTER NO-UNDO.

    DEFINE BUFFER bOrdres FOR Ordres.

    DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO.
    DEFINE VARIABLE iTempo AS INTEGER NO-UNDO.
    DEFINE VARIABLE iLigne AS INTEGER NO-UNDO.
    DEFINE VARIABLE lOK AS LOGICAL NO-UNDO.
    DEFINE VARIABLE cPressePapier AS CHARACTER NO-UNDO.
    DEFINE VARIABLE iSelection AS INTEGER NO-UNDO.
    
    IF NOT(AVAILABLE(ttMessages)) THEN RETURN.

    IF cAction-in = "REPONSE" THEN DO:
        RUN reponse.
    END.
    ELSE DO WITH FRAME frmModule:
        DO iSelection = 1 TO brwMessages:NUM-SELECTED-ROWS:          
            brwMessages:FETCH-SELECTED-ROW(iSelection).  
            FIND CURRENT ttMessages NO-LOCK NO-WAIT NO-ERROR.
            IF NOT AVAILABLE ttMessages THEN NEXT.

            IF (cAction-in = "LU-NONLU-ORDRE-ENCOURS") THEN DO:
                /* Trouver l'ordre en cours */
                FIND FIRST ordres  EXCLUSIVE-LOCK
                    WHERE ordres.cutilisateur = gcUtilisateur
                    AND ordres.cAction = "INFOS"
                    AND ordres.ddate = ttMessages.ddate
                    AND ordres.iOrdre = ttMessages.iOrdre
                    AND ordres.filler = ttMessages.cQui
                    AND ordres.cMessage = ttMessages.cMessage
                    AND ordres.cSens = ttmessages.cSens
                   NO-ERROR.
                IF AVAILABLE(ordres) THEN do:
                    ordres.lLu = NOT(ordres.lLu).
                END.
            END.
            
            IF cAction-in = "EFFACE-ORDRE-SELECTIONNE" THEN DO:
                /* Trouver l'ordre en cours */
                FIND FIRST ordres  EXCLUSIVE-LOCK
                    WHERE ordres.cutilisateur = gcUtilisateur
                    AND ordres.cAction = "INFOS"
                    AND ordres.ddate = ttMessages.ddate
                    AND ordres.iOrdre = ttMessages.iOrdre
                    AND ordres.filler = ttMessages.cQui
                    AND ordres.cMessage = ttMessages.cMessage
                    AND ordres.cSens = ttmessages.cSens
                   NO-ERROR.
                IF AVAILABLE(ordres) THEN do:
                    DELETE ordres.
                END.
            END.
        
            IF cAction-in = "PPAPIER-ORDRE-ENCOURS" THEN DO:
                /* envoyer le code vers le presse papier */
                FOR EACH ordres NO-LOCK
                    WHERE ordres.cutilisateur = gcUtilisateur
                    AND ordres.cAction = "INFOS"
                    AND ordres.ddate = ttMessages.ddate
                    AND ordres.iOrdre = ttMessages.iOrdre
                    AND ordres.filler = ttMessages.cQui
                    AND ordres.cMessage = ttMessages.cMessage
                    AND ordres.cSens = ttmessages.cSens
                   :
                   cPressePapier = cPressePapier + (IF cPressePapier <> "" THEN CHR(10) ELSE "")
                       + (IF ordres.cSens = "E" THEN "-->" ELSE "<--")  
                       + " - " + STRING(ordres.ddate,"99/99/9999")
                       + " - " + STRING(ordres.iOrdre,"HH:MM:SS")
                       + " - " + ordres.filler
                       + " - " + ordres.cMessage
                       .
                END.
                IF cPressePapier <> "" THEN CLIPBOARD:VALUE = cPressePapier.
            END.
        END.
        RUN recharger.
        RUN DonneOrdre("INFOS-MAJ").
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE GerePopup C-Win 
PROCEDURE GerePopup :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE lSupprime1 AS LOGICAL INIT TRUE.
    DEFINE VARIABLE lLuNonLu AS LOGICAL INIT TRUE.
    DEFINE VARIABLE lRepondre AS LOGICAL INIT TRUE.
    DEFINE VARIABLE iSelection AS INTEGER NO-UNDO.

    DO WITH FRAME frmModule:

        /* si plusieurs ligne sélectionnées, activer uniquement la suppression */
        IF brwMessages:NUM-SELECTED-ROWS > 1 THEN DO:
            /*lLuNonLu = FALSE.*/ 
            lRepondre = FALSE.
        END.

        DO iSelection = 1 TO brwMessages:NUM-SELECTED-ROWS:          
            brwMessages:FETCH-SELECTED-ROW(iSelection).  
            FIND CURRENT ttMessages NO-LOCK NO-WAIT NO-ERROR.
            IF NOT AVAILABLE ttMessages THEN NEXT.

            /* Si expediteur du message non physique, on ne repond pas */
            FIND FIRST  Utilisateurs NO-LOCK
                WHERE   Utilisateurs.cUtilisateur = ttMessages.cQui
                NO-ERROR.
            IF NOT(AVAILABLE(Utilisateurs)) OR Utilisateurs.lNonPhysique THEN DO:
                lRepondre = FALSE.
            END.
        END.

        ASSIGN
            MENU-ITEM m_Supprimer_le_message_en_cou:SENSITIVE IN MENU POPUP-MENU-brwMessages = lSupprime1  
            MENU-ITEM m_Marquer_le_message_comme_Lu:SENSITIVE IN MENU POPUP-MENU-brwMessages = lLuNonLu 
            MENU-ITEM m_Répondre_à_lutilisateur:SENSITIVE IN MENU POPUP-MENU-brwMessages = lRepondre  
            .
    END.

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
    FRAME frmModule:WIDTH = gdLargeur.
    FRAME frmModule:HEIGHT = gdHauteur.
    FRAME frmModule:COLUMN = gdPositionXModule.
    FRAME frmModule:ROW = gdPositionYModule.


    ttMessages.cLibSens:READ-ONLY IN BROWSE brwmessages = TRUE.

    IF (DonnePreference("INFOS-JOURS-MAX") = "" OR DonnePreference("INFOS-JOURS-MAX") = ?) THEN DO:
        SauvePreference("INFOS-JOURS-MAX","7").
    END.
    
    DO WITH FRAME frmFonction:  
        edtinfos:SENSITIVE = TRUE.
        btnenvoi:SENSITIVE = TRUE.
        editor-1:SENSITIVE = TRUE.
        brwutilisateurs:SENSITIVE = TRUE.
        brwMessages:SENSITIVE = TRUE.
        filRecherche:SENSITIVE = TRUE.
        toggle-1:SENSITIVE = TRUE.
        toggle-1:CHECKED = FALSE.
        tglTousLesMessages:SENSITIVE = TRUE.
        edtRecherche:SENSITIVE = TRUE.
        edtRecherche:SCREEN-VALUE = "La recherche se fait sur le code utilisateur ainsi que sur le 'vrai nom' saisi dans les préférences.".
        EDITOR-1:SCREEN-VALUE = "Saisissez un message ci dessous, choisissez le ou les destinataires et appuyez sur le bouton 'Envoyer' pour le transmettre. Si un utilisateur sélectionné n'est pas connecté, il aura le message à sa prochaine connexion.".
    END.

    RUN ChargeUtilisateurs.

    RUN ChargeMessages.

    RUN TopChronoGeneral.
    
    RUN OuvreQuery("").

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MajInfosFrame C-Win 
PROCEDURE MajInfosFrame :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    DEFINE VARIABLE lDernierMessage AS LOGICAL NO-UNDO INIT FALSE.
    lDernierMessage = (DonnePreference("PREF-MESSAGES-DERNIER") = "OUI").

    DO WITH FRAME frmModule:
        filInfosListe:SCREEN-VALUE = "(Par défaut, seuls les messages des " + DonnePreference("INFOS-JOURS-MAX") + " derniers jours sont listés. Double clic sur le message pour répondre directement à l'utilisateur)".
    END.

    IF lDernierMessage THEN FIND LAST ttMessages NO-ERROR.
    IF AVAILABLE(ttMessages) THEN REPOSITION brwMessages TO RECID RECID(ttMessages).

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
    TOGGLE-2:SENSITIVE IN FrAME frmModule = TRUE.
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

    DEFINE INPUT PARAMETER cLibelleColonne-in AS CHARACTER NO-UNDO.

    DEFINE VARIABLE lQueryOK AS LOGICAL NO-UNDO INIT FALSE.
    DEFINE VARIABLE lDecroissant AS LOGICAL NO-UNDO INIT FALSE.

    lDecroissant = (DonnePreference("PREF-MESSAGES-DECROISSANT") = "OUI").

    IF cLibelleColonne-in = "" THEN DO:
        IF lDecroissant THEN
            OPEN QUERY brwMessages FOR EACH ttMessages BY ttMessages.dDate DESC BY ttMessages.cHeure DESC.
        ELSE    
            OPEN QUERY brwMessages FOR EACH ttMessages BY ttMessages.dDate BY ttMessages.cHeure.
        lQueryOK = TRUE.
    END.
    ELSE DO:
        IF cLibelleColonne-in = ttMessages.cLibSens:LABEL IN BROWSE brwMessages THEN DO:
            IF lTriAsc THEN DO:
                OPEN QUERY brwMessages FOR EACH ttMessages BY ttMessages.cLibSens.
            END.
            ELSE DO:
                OPEN QUERY brwMessages FOR EACH ttMessages BY ttMessages.cLibSens DESC.
            END.
            lQueryOK = TRUE.
        END.
        IF cLibelleColonne-in = ttMessages.dDate:LABEL IN BROWSE brwMessages 
        OR cLibelleColonne-in = ttMessages.cHeure:LABEL IN BROWSE brwMessages 
            THEN DO:
            IF lTriAsc THEN DO:
                OPEN QUERY brwMessages FOR EACH ttMessages BY ttMessages.dDate BY ttMessages.cHeure.
            END.
            ELSE DO:
                OPEN QUERY brwMessages FOR EACH ttMessages BY ttMessages.dDate DESC BY ttMessages.cHeure DESC.
            END.
            lQueryOK = TRUE.
        END.
        IF cLibelleColonne-in = ttMessages.cVraiQui:LABEL IN BROWSE brwMessages THEN DO:
            IF lTriAsc THEN DO:
                OPEN QUERY brwMessages FOR EACH ttMessages BY ttMessages.cVraiQui.
            END.
            ELSE DO:
                OPEN QUERY brwMessages FOR EACH ttMessages BY ttMessages.cVraiQui DESC.
            END.
            lQueryOK = TRUE.
        END.
        IF cLibelleColonne-in = ttMessages.cMessage:LABEL IN BROWSE brwMessages THEN DO:
            IF lTriAsc THEN DO:
                OPEN QUERY brwMessages FOR EACH ttMessages BY ttMessages.cMessage.
            END.
            ELSE DO:
                OPEN QUERY brwMessages FOR EACH ttMessages BY ttMessages.cMessage DESC.
            END.
            lQueryOK = TRUE.
        END.
    END.

    /* Si la query n'est pas ouverte, on l'ouvre par defaut */
    IF NOT(lQueryOK) THEN DO:
        IF lDecroissant THEN
            OPEN QUERY brwMessages FOR EACH ttMessages BY ttMessages.dDate DESC BY ttMessages.cHeure DESC.
        ELSE    
            OPEN QUERY brwMessages FOR EACH ttMessages BY ttMessages.dDate BY ttMessages.cHeure.
    END.

    filNombre:SCREEN-VALUE IN FRAME frmModule = string(QUERY brwMessages:NUM-RESULTS,">>>9") + " / " + STRING(iNombreMessages,">>>9").

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
    DEFINE BUFFER bttMessages FOR ttMessages.

    /* mémorisation de la position dans la liste */
    IF available(ttMessages) THEN cSvgMessage = ttMessages.cIdMessage.

    RUN Initialisation.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Reponse C-Win 
PROCEDURE Reponse :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE BUFFER bttutil FOR ttutil.

    DO WITH FRAME frmModule:
    
        FIND FIRST bttUtil WHERE bttUtil.cUtilisateur = ttMessages.cQui
            NO-ERROR.
        IF AVAILABLE(bttUtil) THEN do:
            /* Repositionner le browse des utilisateurs sur l'utilisateur du message */
            REPOSITION brwUtilisateurs TO RECID RECID(bttutil).
    
            /* Déselectionner tous les utilisateurs */
            FOR EACH bttutil:
                bttutil.lselection = FALSE.
            END.
    
            /* Ne selectionner que l'utilisateur du message */
            ttUtil.lSelection = TRUE.
    
            /* Rafraichir le browse */
            brwUtilisateurs:REFRESH().
    
            /* Entre dans la zone de saisie du message */
            APPLY "Entry" TO edtinfos.
        END.
    END.

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

