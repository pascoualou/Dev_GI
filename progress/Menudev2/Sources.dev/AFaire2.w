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
{includes\i_fichier.i}
{menudev2\includes\menudev2.i}
{ prodict/user/uservar.i NEW }
{ prodict/dictvar.i NEW }
{includes\i_html.i}
{includes\i_api.i}

/* Parameters Definitions ---                                           */

DEFINE INPUT PARAMETER  winGeneral  AS HANDLE NO-UNDO.
DEFINE INPUT PARAMETER  cParametres AS CHARACTER NO-UNDO.
/* Local Variable Definitions ---                                       */

DEFINE VARIABLE iActionSvg AS INTEGER NO-UNDO.
DEFINE VARIABLE cActionSvg AS CHARACTER NO-UNDO.
DEFINE VARIABLE iListeEnCours  AS INTEGER NO-UNDO.
DEFINE VARIABLE iActionEnCours AS INTEGER NO-UNDO.
DEFINE VARIABLE iMaxAction AS INTEGER NO-UNDO.
DEFINE BUFFER bprefs FOR prefs.

DEFINE STREAM sEntree.

DEFINE TEMP-TABLE ttListes
    LIKE AFaire_liste

    FIELD cProjet    AS CHARACTER
    FIELD cCouleur   AS CHARACTER
    .

DEFINE TEMP-TABLE ttActions
    LIKE AFaire_Action

    FIELD iOrdreAction AS INTEGER
    FIELD cCouleur   AS CHARACTER
    FIELD lCommentaire AS LOGICAL
    
    INDEX ix1 IS PRIMARY UNIQUE  iOrdreAction iNumeroAction
    .

DEFINE TEMP-TABLE ttFichiers
    LIKE AFaire_PJ
    
    FIELD iNumeroListe AS INTEGER
    .

DEFINE BUFFER bttListes FOR ttListes.
DEFINE BUFFER bttActions FOR ttActions.
DEFINE BUFFER bttFichiers FOR ttFichiers.

DEFINE VARIABLE cRepertoireProjet AS CHARACTER NO-UNDO.

DEFINE VARIABLE cClauseFichiers AS CHARACTER NO-UNDO.
DEFINE VARIABLE cLigne AS CHARACTER NO-UNDO.

DEFINE VARIABLE iX AS INTEGER NO-UNDO.
DEFINE VARIABLE iY AS INTEGER NO-UNDO.

DEFINE VARIABLE hPopupAction AS WIDGET-HANDLE NO-UNDO.

DEFINE VARIABLE m_Deplacer AS WIDGET-HANDLE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME frmFonction
&Scoped-define BROWSE-NAME brwActions

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ttActions ttFichiers ttListes

/* Definitions for BROWSE brwActions                                    */
&Scoped-define FIELDS-IN-QUERY-brwActions ttActions.cCouleur ttActions.lRappelHoraire ttActions.cLibelleAction   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brwActions   
&Scoped-define SELF-NAME brwActions
&Scoped-define QUERY-STRING-brwActions FOR EACH ttActions
&Scoped-define OPEN-QUERY-brwActions OPEN QUERY {&SELF-NAME} FOR EACH ttActions.
&Scoped-define TABLES-IN-QUERY-brwActions ttActions
&Scoped-define FIRST-TABLE-IN-QUERY-brwActions ttActions


/* Definitions for BROWSE brwFichiers                                   */
&Scoped-define FIELDS-IN-QUERY-brwFichiers ttFichiers.lRepertoire ttFichiers.cNomPJ   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brwFichiers   
&Scoped-define SELF-NAME brwFichiers
&Scoped-define QUERY-STRING-brwFichiers FOR EACH ttFichiers     WHERE (rsFichiersTousAction:SCREEN-VALUE = "T" OR ttFichiers.iNumeroAction = ttActions.iNumeroAction)
&Scoped-define OPEN-QUERY-brwFichiers OPEN QUERY {&SELF-NAME} FOR EACH ttFichiers     WHERE (rsFichiersTousAction:SCREEN-VALUE = "T" OR ttFichiers.iNumeroAction = ttActions.iNumeroAction).
&Scoped-define TABLES-IN-QUERY-brwFichiers ttFichiers
&Scoped-define FIRST-TABLE-IN-QUERY-brwFichiers ttFichiers


/* Definitions for BROWSE brwListes                                     */
&Scoped-define FIELDS-IN-QUERY-brwListes ttListes.cCouleur ttListes.cLibelleListe ttListes.cProjet   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brwListes   
&Scoped-define SELF-NAME brwListes
&Scoped-define QUERY-STRING-brwListes FOR EACH ttListes WHERE not(tglNonTerminees:CHECKED) OR ttListes.iAvancementListe < 100 BY ttListes.cLibelleListe
&Scoped-define OPEN-QUERY-brwListes OPEN QUERY {&SELF-NAME} FOR EACH ttListes WHERE not(tglNonTerminees:CHECKED) OR ttListes.iAvancementListe < 100 BY ttListes.cLibelleListe.
&Scoped-define TABLES-IN-QUERY-brwListes ttListes
&Scoped-define FIRST-TABLE-IN-QUERY-brwListes ttListes


/* Definitions for FRAME frmFonction                                    */
&Scoped-define OPEN-BROWSERS-IN-QUERY-frmFonction ~
    ~{&OPEN-QUERY-brwActions}~
    ~{&OPEN-QUERY-brwFichiers}~
    ~{&OPEN-QUERY-brwListes}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-1 RECT-2 RECT-3 brwListes brwActions ~
rsActionsUrgence btnActionsAjouter btnActionsSupprimer btnActionsAvant ~
btnActionsApres btnActionsCommentaire tglRappelHoraire brwFichiers ~
cmbJoursRappel tglNonTerminees rsFichiersTousAction btnListesAjouter ~
btnListesSupprimer btnProjet btnLanceProjet btnFichiersAjouter ~
btnRepertoireAjouter btnFichiersSupprimer 
&Scoped-Define DISPLAYED-OBJECTS rsActionsUrgence tglRappelHoraire ~
cmbJoursRappel tglNonTerminees rsFichiersTousAction 

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD DonneHistorique C-Win 
FUNCTION DonneHistorique RETURNS CHARACTER
  (  )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD DonneNomCompletFichier C-Win 
FUNCTION DonneNomCompletFichier RETURNS CHARACTER
  ( cNomListe-in AS CHARACTER, iNumeroListe-in AS INTEGER, iNumeroAction-in AS INTEGER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD ExisteCommentaire C-Win 
FUNCTION ExisteCommentaire RETURNS LOGICAL
  ( iNumeroAction-in AS INTEGER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.

/* Menu Definitions                                                     */
DEFINE MENU POPUP-MENU-brwActions 
       MENU-ITEM m_Actions      LABEL "----- ACTIONS -----"
              DISABLED.


/* Definitions of the field level widgets                               */
DEFINE BUTTON btnActionsAjouter 
     LABEL "Ajouter" 
     SIZE 9 BY 1.43.

DEFINE BUTTON btnActionsApres 
     LABEL "Après" 
     SIZE 8 BY 1.43.

DEFINE BUTTON btnActionsAvant 
     LABEL "Avant" 
     SIZE 8 BY 1.43.

DEFINE BUTTON btnActionsCommentaire 
     LABEL "Commentaire" 
     SIZE 14 BY 1.43.

DEFINE BUTTON btnActionsSupprimer 
     LABEL "Supprimer" 
     SIZE 11 BY 1.43.

DEFINE BUTTON btnFichiersAjouter 
     LABEL "Ajouter un fichier" 
     SIZE 23 BY 1.43.

DEFINE BUTTON btnFichiersSupprimer 
     LABEL "Supprimer" 
     SIZE 12 BY 1.43.

DEFINE BUTTON btnLanceProjet 
     LABEL ">" 
     SIZE 3 BY 1.43.

DEFINE BUTTON btnListesAjouter 
     LABEL "Ajouter" 
     SIZE 10 BY 1.43.

DEFINE BUTTON btnListesSupprimer 
     LABEL "Supprimer" 
     SIZE 12 BY 1.43.

DEFINE BUTTON btnProjet 
     LABEL "prj associé" 
     SIZE 12 BY 1.43.

DEFINE BUTTON btnRepertoireAjouter 
     LABEL "Ajouter un répertoire" 
     SIZE 23 BY 1.43.

DEFINE VARIABLE cmbJoursRappel AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS COMBO-BOX INNER-LINES 8
     LIST-ITEM-PAIRS "Jours","0",
                     "Lundi","1",
                     "Mardi","2",
                     "Mercredi","3",
                     "Jeudi","4",
                     "Vendredi","5",
                     "Samedi","6",
                     "Dimanche","7"
     DROP-DOWN-LIST
     SIZE 21 BY 1 NO-UNDO.

DEFINE VARIABLE rsActionsUrgence AS CHARACTER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "A faire", "AF",
"A tester", "AT",
"Faite", "F",
"Penser à", "PA",
"Abandonnée", "A"
     SIZE 58 BY .71
     BGCOLOR 8  NO-UNDO.

DEFINE VARIABLE rsFichiersTousAction AS CHARACTER INITIAL "A" 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Tous les fichiers associés à la liste", "T",
"Les fichiers associés à l'action en cours", "A"
     SIZE 45 BY 1.67
     BGCOLOR 8  NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 49 BY 18.33
     BGCOLOR 8 .

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 112 BY 10.71
     BGCOLOR 8 .

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 112 BY 7.38
     BGCOLOR 8 .

DEFINE VARIABLE tglNonTerminees AS LOGICAL INITIAL no 
     LABEL "Ne voir que les listes vides ou non terminées" 
     VIEW-AS TOGGLE-BOX
     SIZE 45 BY .95
     BGCOLOR 8  NO-UNDO.

DEFINE VARIABLE tglRappelHoraire AS LOGICAL INITIAL no 
     LABEL "Rappel horaire" 
     VIEW-AS TOGGLE-BOX
     SIZE 18 BY .71
     BGCOLOR 8  NO-UNDO.

DEFINE VARIABLE edtInformation AS CHARACTER INITIAL "Libelle" 
     VIEW-AS EDITOR NO-BOX
     SIZE 61 BY 1.19
     BGCOLOR 3 FGCOLOR 15 FONT 10 NO-UNDO.

DEFINE IMAGE IMAGE-1
     FILENAME "adeicon/rbuild%.ico":U
     SIZE 8 BY 1.43.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brwActions FOR 
      ttActions SCROLLING.

DEFINE QUERY brwFichiers FOR 
      ttFichiers SCROLLING.

DEFINE QUERY brwListes FOR 
      ttListes SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brwActions
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brwActions C-Win _FREEFORM
  QUERY brwActions DISPLAY
      ttActions.cCouleur FORMAT "x(5)"   LABEL "Etat"
          ttActions.lRappelHoraire FORMAT "*/" LABEL "R"
    ttActions.cLibelleAction FORMAT "x(256)" LABEL "Libellé de l'action"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS NO-COLUMN-SCROLLING SEPARATORS SIZE 110 BY 8.33
         TITLE "Actions".

DEFINE BROWSE brwFichiers
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brwFichiers C-Win _FREEFORM
  QUERY brwFichiers DISPLAY
      ttFichiers.lRepertoire  FORMAT "R/F " LABEL ""
        ttFichiers.cNomPJ  FORMAT "x(256)" LABEL "Nom du fichier"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS NO-COLUMN-SCROLLING SEPARATORS SIZE 110 BY 5.24
         TITLE "Fichiers / Répertoires associés" ROW-HEIGHT-CHARS .62 FIT-LAST-COLUMN.

DEFINE BROWSE brwListes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brwListes C-Win _FREEFORM
  QUERY brwListes DISPLAY
      ttListes.cCouleur FORMAT "x(4) " LABEL ""
    ttListes.cLibelleListe FORMAT "x(40)" LABEL "Libellé"
    ttListes.cProjet FORMAT "x(256)" LABEL "Projet associé" WIDTH 256
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 47 BY 13.57
         TITLE "Listes":C FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME frmModule
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 166.2 BY 20.62
         BGCOLOR 7 
         TITLE BGCOLOR 2 FGCOLOR 15 "A faire".

DEFINE FRAME frmFonction
     brwListes AT ROW 1.48 COL 3 WIDGET-ID 100
     brwActions AT ROW 1.48 COL 53
     rsActionsUrgence AT ROW 10.05 COL 105 NO-LABEL WIDGET-ID 12
     btnActionsAjouter AT ROW 10.19 COL 53 WIDGET-ID 18
     btnActionsSupprimer AT ROW 10.19 COL 62 WIDGET-ID 20
     btnActionsAvant AT ROW 10.19 COL 73 WIDGET-ID 22
     btnActionsApres AT ROW 10.19 COL 81 WIDGET-ID 24
     btnActionsCommentaire AT ROW 10.19 COL 89 HELP
          "Création automatique d'un fichier associé au format word" WIDGET-ID 74
     tglRappelHoraire AT ROW 11 COL 105 WIDGET-ID 68
     brwFichiers AT ROW 12.43 COL 53 WIDGET-ID 200
     cmbJoursRappel AT ROW 15.29 COL 27 COLON-ALIGNED NO-LABEL WIDGET-ID 80
     tglNonTerminees AT ROW 16.95 COL 3 WIDGET-ID 72
     rsFichiersTousAction AT ROW 17.67 COL 118 NO-LABEL WIDGET-ID 64
     btnListesAjouter AT ROW 17.91 COL 3 WIDGET-ID 26
     btnListesSupprimer AT ROW 17.91 COL 13 WIDGET-ID 28
     btnProjet AT ROW 17.91 COL 35 WIDGET-ID 54
     btnLanceProjet AT ROW 17.91 COL 47 WIDGET-ID 56
     btnFichiersAjouter AT ROW 17.91 COL 53 WIDGET-ID 60
     btnRepertoireAjouter AT ROW 17.91 COL 77 WIDGET-ID 76
     btnFichiersSupprimer AT ROW 17.91 COL 102 WIDGET-ID 62
     "Pour les actions ayant le rappel horaire activé" VIEW-AS TEXT
          SIZE 45 BY .71 AT ROW 16.24 COL 4 WIDGET-ID 82
          BGCOLOR 8 FGCOLOR 2 FONT 1
     "Rappels horaires tous les" VIEW-AS TEXT
          SIZE 24 BY .95 AT ROW 15.29 COL 4 WIDGET-ID 78
          BGCOLOR 8 
     RECT-1 AT ROW 1.24 COL 2 WIDGET-ID 50
     RECT-2 AT ROW 1.24 COL 52 WIDGET-ID 52
     RECT-3 AT ROW 12.19 COL 52 WIDGET-ID 58
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 2 ROW 1.24
         SIZE 164 BY 19.05.

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
         HEIGHT             = 20.62
         WIDTH              = 166
         MAX-HEIGHT         = 33.95
         MAX-WIDTH          = 273.2
         VIRTUAL-HEIGHT     = 33.95
         VIRTUAL-WIDTH      = 273.2
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
ASSIGN FRAME frmFonction:FRAME = FRAME frmModule:HANDLE
       FRAME frmInformation:FRAME = FRAME frmFonction:HANDLE.

/* SETTINGS FOR FRAME frmFonction
   FRAME-NAME                                                           */
/* BROWSE-TAB brwListes RECT-3 frmFonction */
/* BROWSE-TAB brwActions brwListes frmFonction */
/* BROWSE-TAB brwFichiers tglRappelHoraire frmFonction */
ASSIGN 
       brwActions:POPUP-MENU IN FRAME frmFonction             = MENU POPUP-MENU-brwActions:HANDLE.

/* SETTINGS FOR FRAME frmInformation
                                                                        */
ASSIGN 
       FRAME frmInformation:HIDDEN           = TRUE
       FRAME frmInformation:MOVABLE          = TRUE.

ASSIGN 
       edtInformation:AUTO-RESIZE IN FRAME frmInformation      = TRUE
       edtInformation:READ-ONLY IN FRAME frmInformation        = TRUE.

/* SETTINGS FOR FRAME frmModule
                                                                        */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brwActions
/* Query rebuild information for BROWSE brwActions
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH ttActions.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE brwActions */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brwFichiers
/* Query rebuild information for BROWSE brwFichiers
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH ttFichiers
    WHERE (rsFichiersTousAction:SCREEN-VALUE = "T" OR ttFichiers.iNumeroAction = ttActions.iNumeroAction).
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE brwFichiers */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brwListes
/* Query rebuild information for BROWSE brwListes
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH ttListes WHERE not(tglNonTerminees:CHECKED) OR ttListes.iAvancementListe < 100 BY ttListes.cLibelleListe.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE brwListes */
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


&Scoped-define BROWSE-NAME brwActions
&Scoped-define SELF-NAME brwActions
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwActions C-Win
ON DEFAULT-ACTION OF brwActions IN FRAME frmFonction /* Actions */
DO:
    DEFINE VARIABLE cIdentListe AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cSvgAction AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cIdentAction AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cFichierActionAvant AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cFichierActionApres AS CHARACTER NO-UNDO.

    IF NOT(AVAILABLE(ttActions)) THEN RETURN.
    IF ttActions.iNumeroAction = 0 THEN RETURN.

    /* Ajout d'une action dans la base */
    RUN DonnePositionMessage IN ghGeneral.
    gcAllerRetour = STRING(giPosXMessage)
        + "|" + STRING(giPosYMessage)
        + "|" + "Libellé de l'action"
        + "|" + ttActions.cLibelleAction.
    RUN VALUE(gcRepertoireExecution + "saisie3.w") (INPUT-OUTPUT gcAllerRetour).
    IF gcAllerRetour = "" THEN RETURN.
    IF ENTRY(4,gcAllerRetour,"|") <> "" THEN DO:
        FIND FIRST  AFaire_Action EXCLUSIVE-LOCK 
            WHERE   AFaire_Action.cUtilisateur = gcUtilisateur
            AND     AFaire_Action.iNumeroAction = ttActions.iNumeroAction
            NO-ERROR. 
        IF AVAILABLE(AFaire_Action) THEN DO:
            AFaire_Action.cLibelleAction = ENTRY(4,gcAllerRetour,"|").
        END.
        RELEASE AFaire_Action.
    END.
    RUN ChargeActions.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwActions C-Win
ON LEAVE OF brwActions IN FRAME frmFonction /* Actions */
DO:
   /* MESSAGE "leave" VIEW-AS ALERT-BOX.*/
  /*brwActions:DESELECT-SELECTED-ROW(1).*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwActions C-Win
ON ROW-DISPLAY OF brwActions IN FRAME frmFonction /* Actions */
DO:
    DEFINE VARIABLE iCouleur AS INTEGER NO-UNDO INIT 0.

    IF ttActions.cEtatAction = "AF" THEN iCouleur = 12.
    IF ttActions.cEtatAction = "AT" THEN iCouleur = 14.
    IF ttActions.cEtatAction = "F"  THEN iCouleur = 2 /*10*/.
    IF ttActions.cEtatAction = "PA" THEN iCouleur = 13.
    IF ttActions.cEtatAction = "A"  THEN iCouleur = 6.

    IF iCouleur <> 0 THEN DO WITH FRAME frmFonction :
        IF iCouleur <> 14 THEN ttActions.cCouleur:FGCOLOR IN BROWSE brwActions = 15.
        ttActions.cCouleur:BGCOLOR IN BROWSE brwActions = iCouleur.
    END.

    IF ttActions.lCommentaire THEN DO WITH FRAME frmFonction :
        ttActions.cLibelleAction:FONT IN BROWSE brwActions = 6.
    END.
    ttActions.cCouleur = ttActions.cEtatAction. 
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwActions C-Win
ON VALUE-CHANGED OF brwActions IN FRAME frmFonction /* Actions */
DO:
    IF AVAILABLE(ttActions) THEN DO:
        rsActionsUrgence:SCREEN-VALUE = ttActions.cEtatAction.
        tglRappelHoraire:CHECKED = ttActions.lRappelHoraire.

        SauvePreference("AFAIRE-ACTION",STRING(ttActions.iNumeroAction)).
        {&OPEN-QUERY-brwFichiers}
    END.
    ELSE DO:
        EMPTY TEMP-TABLE ttFichiers.
    END.
    
    RUN gereActions.

    RUN GereCommentaire.

    RUN MajHistorique.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brwFichiers
&Scoped-define SELF-NAME brwFichiers
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwFichiers C-Win
ON DEFAULT-ACTION OF brwFichiers IN FRAME frmFonction /* Fichiers / Répertoires associés */
DO:
    IF NOT(ttFichiers.lRepertoire) THEN
        OS-COMMAND NO-WAIT VALUE("""" + ttFichiers.cNomPJ + """").
    ELSE
        OS-COMMAND NO-WAIT VALUE("explorer """ + ttFichiers.cNomPJ + """").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwFichiers C-Win
ON ROW-DISPLAY OF brwFichiers IN FRAME frmFonction /* Fichiers / Répertoires associés */
DO:
    DEFINE VARIABLE iCouleur AS INTEGER NO-UNDO INIT 0.

    /*
    IF ttFichiers.iNumeroAction = ttActions.iNumeroAction  THEN iCouleur = 10.

    IF iCouleur <> 0 THEN DO WITH FRAME frmFonction :
        ttFichiers.cNomPJ:BGCOLOR IN BROWSE brwFichiers = iCouleur.
    END.
    */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwFichiers C-Win
ON VALUE-CHANGED OF brwFichiers IN FRAME frmFonction /* Fichiers / Répertoires associés */
DO:
    /* Si pas de fichier on ne fait rien */
    IF NOT(AVAILABLE(ttFichiers)) THEN RETURN.
    
    /* Si pas d'action on ne fait rien */
    /*IF ttFichiers.cAction = "" THEN RETURN.*/

    /* Repositionnement sur l'action correspondante */
    FIND FIRST  bttActions
        WHERE   bttActions.iNumeroAction = ttFichiers.iNumeroAction
        NO-ERROR.
    IF NOT(AVAILABLE(bttActions)) THEN RETURN.
    REPOSITION brwActions TO RECID RECID(bttactions).

    RUN gereActions.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brwListes
&Scoped-define SELF-NAME brwListes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwListes C-Win
ON DEFAULT-ACTION OF brwListes IN FRAME frmFonction /* Listes */
DO:
    IF NOT(AVAILABLE(ttListes)) THEN RETURN.
    
    IF ttListes.iNumeroListe = 0 THEN RETURN.

    /* Ajout d'une liste dans la base */
    RUN DonnePositionMessage IN ghGeneral.
    gcAllerRetour = STRING(giPosXMessage)
        + "|" + STRING(giPosYMessage)
        + "|" + "Libellé de la liste"
        + "|" + ttListes.cLibelleListe.
    RUN VALUE(gcRepertoireExecution + "saisie3.w") (INPUT-OUTPUT gcAllerRetour).
    IF gcAllerRetour = "" THEN RETURN.
    IF ENTRY(4,gcAllerRetour,"|") <> "" THEN DO:
        FIND FIRST  AFaire_Liste EXCLUSIVE-LOCK 
            WHERE   AFaire_Liste.cUtilisateur = gcUtilisateur
            AND     AFaire_Liste.iNumeroListe = ttListes.iNumeroListe
            NO-ERROR. 
        IF AVAILABLE(AFaire_Liste) THEN DO:
            AFaire_Liste.cLibelleListe = ENTRY(4,gcAllerRetour,"|").
        END.
        RELEASE AFaire_Liste.
    END.

    RUN chargelistes.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwListes C-Win
ON ROW-DISPLAY OF brwListes IN FRAME frmFonction /* Listes */
DO:
  
    DEFINE VARIABLE iCouleur AS INTEGER NO-UNDO INIT 0.

    /* Calcul du pourcentage de réalisation de la liste */
    IF ttListes.iAvancementListe = 100 THEN iCouleur = 2. /* Vert */
    IF ttListes.iAvancementListe = 0 THEN iCouleur = 2. /* Vert */
    IF ttListes.iAvancementListe < 100 THEN iCouleur = 14. /* Jaune */
    IF ttListes.iAvancementListe < 50 THEN iCouleur = 12. /* Rouge */

    IF iCouleur <> 0  THEN DO:
        IF iCouleur <> 14 THEN ttListes.cCouleur:FGCOLOR IN BROWSE brwListes = 15.
        ttListes.cCouleur:BGCOLOR IN BROWSE brwListes = iCouleur.
    END.

    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwListes C-Win
ON VALUE-CHANGED OF brwListes IN FRAME frmFonction /* Listes */
DO:
    IF AVAILABLE(ttListes) THEN DO:
        /* Sauvegarde de la liste en cours */
        SauvePreference("AFAIRE-LISTE",string(ttListes.iNumeroListe)).

        cmbJoursRappel:SCREEN-VALUE = ttListes.cFiller1.
        
        /* Chargement des actions de la liste sélectionnée */
        RUN ChargeActions.

        /* Gestion des boutons d'action */
        RUN GereActions.

    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnActionsAjouter
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnActionsAjouter C-Win
ON CHOOSE OF btnActionsAjouter IN FRAME frmFonction /* Ajouter */
DO:
    DEFINE VARIABLE iProchaineAction AS INTEGER NO-UNDO.
    DEFINE BUFFER bttActions FOR ttActions.

  /* Ajout d'une action dans la base */
    RUN DonnePositionMessage IN ghGeneral.
    gcAllerRetour = STRING(giPosXMessage)
        + "|" + STRING(giPosYMessage)
        + "|" + "Libellé de l'action"
        + "|" + "".
    RUN VALUE(gcRepertoireExecution + "saisie3.w") (INPUT-OUTPUT gcAllerRetour).
    IF gcAllerRetour = "" THEN RETURN.
    IF ENTRY(4,gcAllerRetour,"|") <> "" THEN DO:
        iProchaineAction = 1.
        FIND LAST   AFaire_Action NO-LOCK 
            WHERE   AFaire_Action.cUtilisateur = gcUtilisateur
            NO-ERROR. 
        IF AVAILABLE(AFaire_Action) THEN iProchaineAction = AFaire_Action.iNumeroAction + 1.
        
        CREATE AFaire_Action.
        AFaire_Action.cUtilisateur = gcUtilisateur.
        AFaire_Action.iNumeroAction = iProchaineAction.
        AFaire_Action.cLibelleAction = ENTRY(4,gcAllerRetour,"|").
        AFaire_Action.cEtatAction = "AF".
        AFaire_Action.cFiller1 = RemplaceVariables("Création le %date% à %heure%","*",?,?).
        
        /* Création du lien Liste-Action */
        CREATE AFaire_Lien.
        AFaire_Lien.cUtilisateur = gcUtilisateur.
        AFaire_Lien.iNumeroListe = ttListes.iNumeroListe.
        AFaire_Lien.iNumeroAction = AFaire_Action.iNumeroAction.
        AFaire_Lien.iOrdreLien = 0.
        
        RUN RenumeroteLiensAction.
    END.

    /* Rechargement de la liste */
    SauvePreference("AFAIRE-ACTION",STRING(AFaire_Action.iNumeroAction)).
    RUN ChargeActions.
    RUN RaffListes.
    RUN MajHistorique.
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnActionsApres
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnActionsApres C-Win
ON CHOOSE OF btnActionsApres IN FRAME frmFonction /* Après */
DO:
  
    DEFINE VARIABLE iOrdreEnCours AS INTEGER NO-UNDO.
    DEFINE BUFFER bAFaire_Lien FOR AFaire_Lien.

    IF NOT(AVAILABLE(ttActions)) THEN RETURN.
    IF ttactions.iOrdreAction >= IMaxAction THEN RETURN.

        FIND FIRST      AFaire_Lien     EXCLUSIVE-LOCK
                WHERE   AFaire_Lien.cUtilisateur = gcUtilisateur
                AND     AFaire_Lien.iNumeroListe = ttListes.iNumeroListe
                AND     AFaire_Lien.iNumeroAction = ttActions.iNumeroAction
                NO-ERROR.
        IF NOT(AVAILABLE(AFaire_Lien)) THEN RETURN.
        
        iOrdreEnCours = AFaire_Lien.iOrdreLien.
        AFaire_Lien.iOrdreLien = 4999.
        
        FIND FIRST      bAFaire_Lien    EXCLUSIVE-LOCK
                WHERE   bAFaire_Lien.cUtilisateur = gcUtilisateur
                AND     bAFaire_Lien.iNumeroListe = ttListes.iNumeroListe
                AND     bAFaire_Lien.iOrdreLien = iOrdreEnCours + 1
                NO-ERROR.
        IF AVAILABLE(bAFaire_Lien) THEN DO:
                bAFaire_Lien.iOrdreLien = iOrdreEnCours.
                AFaire_Lien.iOrdreLien = iOrdreEnCours + 1.     
        END.
        
        SauvePreference("AFAIRE-ACTION",STRING(AFaire_Lien.iNumeroAction)).
        
        /* par précaution */
        RUN RenumeroteLiensAction.
        
    RUN ChargeActions.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnActionsAvant
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnActionsAvant C-Win
ON CHOOSE OF btnActionsAvant IN FRAME frmFonction /* Avant */
DO:
    DEFINE VARIABLE iOrdreEnCours AS INTEGER NO-UNDO.
    DEFINE BUFFER bAFaire_Lien FOR AFaire_Lien.

    IF NOT(AVAILABLE(ttActions)) THEN RETURN.
    IF ttactions.iOrdreAction <= 1 THEN RETURN.

        FIND FIRST      AFaire_Lien     EXCLUSIVE-LOCK
                WHERE   AFaire_Lien.cUtilisateur = gcUtilisateur
                AND     AFaire_Lien.iNumeroListe = ttListes.iNumeroListe
                AND     AFaire_Lien.iNumeroAction = ttActions.iNumeroAction
                NO-ERROR.
        IF NOT(AVAILABLE(AFaire_Lien)) THEN RETURN.
        
        iOrdreEnCours = AFaire_Lien.iOrdreLien.
        AFaire_Lien.iOrdreLien = 4999.
        
        FIND FIRST      bAFaire_Lien    EXCLUSIVE-LOCK
                WHERE   bAFaire_Lien.cUtilisateur = gcUtilisateur
                AND     bAFaire_Lien.iNumeroListe = ttListes.iNumeroListe
                AND     bAFaire_Lien.iOrdreLien = iOrdreEnCours - 1
                NO-ERROR.
        IF AVAILABLE(bAFaire_Lien) THEN DO:
                bAFaire_Lien.iOrdreLien = iOrdreEnCours.
                AFaire_Lien.iOrdreLien = iOrdreEnCours - 1.     
        END.
        
        SauvePreference("AFAIRE-ACTION",STRING(AFaire_Lien.iNumeroAction)).
        
        /* par précaution */
        RUN RenumeroteLiensAction.
        
    RUN ChargeActions.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnActionsCommentaire
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnActionsCommentaire C-Win
ON CHOOSE OF btnActionsCommentaire IN FRAME frmFonction /* Commentaire */
DO:
  
    DEFINE VARIABLE HwComWrd AS COM-HANDLE   NO-UNDO.
    DEFINE VARIABLE HwComDoc AS COM-HANDLE   NO-UNDO.
    DEFINE VARIABLE lErreurWord AS LOGICAL NO-UNDO INIT FALSE.
    DEFINE VARIABLE cErreurWord AS CHARACTER NO-UNDO INIT "".
    DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO INIT "".
    DEFINE VARIABLE lCreerLeFichier AS LOGICAL NO-UNDO.
    DEFINE VARIABLE iBoucle AS INTEGER NO-UNDO.
    DEFINE VARIABLE cTempo AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cFichierAction AS CHARACTER NO-UNDO.

        IF ttActions.lCommentaire THEN DO:
            FIND FIRST  AFaire_PJ NO-LOCK
                WHERE   AFaire_PJ.cUtilisateur = gcUtilisateur
                AND     AFaire_PJ.iNumeroAction = ttActions.iNumeroAction
                AND     AFaire_PJ.lCommentaireAction
                NO-ERROR.
            IF AVAILABLE(AFaire_PJ) THEN DO:
                cFichierAction = AFaire_PJ.cNomPJ.
                END.
        END.
        ELSE DO:
            cFichierAction = DonneNomCompletFichier(ttActions.cLibelleAction, ttListes.iNumeroListe,ttActions.iNumeroAction).

        /* Si le fichier commentaire existe déjà, ce n'est peut-être pas la peine de l'écraser ??? */
        lCreerLeFichier = TRUE.
        IF SEARCH(cFichierAction) <> ? THEN DO:
            MESSAGE "Un fichier commentaire de ce nom existe déjà. Voulez-vous le conserver ?"
                VIEW-AS ALERT-BOX QUESTION 
                BUTTON YES-NO
                TITLE "Confirmation..."
                UPDATE lreponse5 AS LOGICAL.
    
            IF (lReponse5) THEN lCreerLeFichier = FALSE.
        END.
    
        IF lCreerLeFichier THEN DO:
            IF not(lErreurWord) THEN do:
                CREATE "word.Application" HwComWrd NO-ERROR.
                RUN GestionErreurWord(ERROR-STATUS:ERROR,"Problème de communication avec Word (CREATE)",INPUT-OUTPUT lErreurWord,INPUT-OUTPUT cErreurWord).
            END.
        
            /*
            IF not(lErreurWord) THEN do:
                HwComWrd:VISIBLE = TRUE NO-ERROR.
                RUN GestionErreurWord(ERROR-STATUS:ERROR,"Problème de communication avec Word (VISIBLE)",INPUT-OUTPUT lErreurWord,INPUT-OUTPUT cErreurWord).
            END.
        
            IF not(lErreurWord) THEN do:
                HwComWrd:WINDOWSTATE = 1 NO-ERROR.
                RUN GestionErreurWord(ERROR-STATUS:ERROR,"Problème de communication avec Word (WINDOWSTATE)",INPUT-OUTPUT lErreurWord,INPUT-OUTPUT cErreurWord).
            END.
            */
        
            IF not(lErreurWord) THEN do:
                HwComWrd:ACTIVATE() NO-ERROR.
                RUN GestionErreurWord(ERROR-STATUS:ERROR,"Problème de communication avec Word (ACTIVATE)",INPUT-OUTPUT lErreurWord,INPUT-OUTPUT cErreurWord).
            END.
        
            IF not(lErreurWord) THEN do:
                HwComDoc = HwComWrd:DOCUMENTS:ADD() NO-ERROR.
                RUN GestionErreurWord(ERROR-STATUS:ERROR,"Problème de communication avec Word (ADD)",INPUT-OUTPUT lErreurWord,INPUT-OUTPUT cErreurWord).
            END.
        
            IF not(lErreurWord) THEN do:
                HwComDoc:SAVEAS(cFichierAction) NO-ERROR.
                RUN GestionErreurWord(ERROR-STATUS:ERROR,"Problème de communication avec Word (SAVEAS)",INPUT-OUTPUT lErreurWord,INPUT-OUTPUT cErreurWord).
            END.
        
            IF not(lErreurWord) THEN do:
                HwComDoc:CLOSE(0) NO-ERROR.
                RUN GestionErreurWord(ERROR-STATUS:ERROR,"Problème de communication avec Word (CLOSE)",INPUT-OUTPUT lErreurWord,INPUT-OUTPUT cErreurWord).
            END.
        
            IF not(lErreurWord) THEN do:
                HwComWrd:QUIT() NO-ERROR.
                RUN GestionErreurWord(ERROR-STATUS:ERROR,"Problème de communication avec Word (QUIT)",INPUT-OUTPUT lErreurWord,INPUT-OUTPUT cErreurWord).
            END.
        
            IF lErreurWord THEN DO:
                RUN AfficheMessageAvecTemporisation("Bases - Gestion commentaire",cErreurWord,FALSE,5,"OK","MESSAGE-COMMENTAIRE-WORD-1",FALSE,OUTPUT cRetour).
            END.
        END.
    
        IF SEARCH(cFichierAction) <> ? THEN DO:
                FIND FIRST      AFaire_PJ       EXCLUSIVE-LOCK
                        WHERE   AFaire_PJ.cUtilisateur = gcUtilisateur
                AND     AFaire_PJ.iNumeroAction = ttActions.iNumeroAction
                AND             AFaire_PJ.cNomPJ = cFichierAction
                NO-ERROR.
            IF NOT(AVAILABLE(AFaire_PJ)) THEN DO:
                    CREATE AFaire_PJ.
                    AFaire_PJ.cUtilisateur = gcUtilisateur.
                    AFaire_PJ.iNumeroAction = ttActions.iNumeroAction.
                    AFaire_PJ.cNomPJ = cFichierAction.
                END.
                AFaire_PJ.lCommentaireAction = TRUE.
                
            RUN ChargeFichiers.
        END.
    END.

    /* Ouverture du fichier */
    OS-COMMAND NO-WAIT VALUE("""" + cFichierAction + """").

    RUN GereCommentaire.
    RUN MajCommentaireActions.
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnActionsSupprimer
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnActionsSupprimer C-Win
ON CHOOSE OF btnActionsSupprimer IN FRAME frmFonction /* Supprimer */
DO:

    MESSAGE "Confirmez vous la suppression de l'action sélectionnée ?"
        VIEW-AS ALERT-BOX QUESTION 
        BUTTON YES-NO
        TITLE "Confirmation..."
        UPDATE lreponse2 AS LOGICAL.
    
    IF not(lReponse2) THEN RETURN.

    /* Suppression de  l'action */
    FOR EACH    AFaire_Action EXCLUSIVE-LOCK
        WHERE   AFaire_Action.cUtilisateur = gcUtilisateur
        AND     AFaire_Action.iNumeroAction = ttActions.iNumeroAction
        :
        DELETE AFaire_Action.
    END.
    RELEASE AFaire_Action.

    /* Suppression du lien liste-action */
    FOR EACH    AFaire_Lien EXCLUSIVE-LOCK
        WHERE   AFaire_Lien.cUtilisateur = gcUtilisateur
        AND     AFaire_Lien.iNumeroListe = ttListes.iNumeroListe
        AND     AFaire_Lien.iNumeroAction = ttActions.iNumeroAction
        :
        DELETE AFaire_Lien.
    END.
    RELEASE AFaire_Lien.

    /* Suppression des fichiers liées à cette action */
    FOR EACH    AFaire_PJ EXCLUSIVE-LOCK
        WHERE   AFaire_PJ.cUtilisateur = gcUtilisateur
        AND     AFaire_PJ.iNumeroAction = ttActions.iNumeroAction
        :
        DELETE AFaire_PJ.
    END.
    RELEASE AFaire_PJ.
    
    RUN RenumeroteLiensAction.

    SauvePreference("AFAIRE-ACTION","0").
    RUN chargeActions.
    RUN GereActions.
    RUN raffListes.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnFichiersAjouter
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnFichiersAjouter C-Win
ON CHOOSE OF btnFichiersAjouter IN FRAME frmFonction /* Ajouter un fichier */
DO:
    
    DEFINE VARIABLE cFichierAction AS CHARACTER NO-UNDO.

    SYSTEM-DIALOG GET-FILE cFichierAction INITIAL-DIR cRepertoireProjet USE-FILENAME FILTERS "Tous les fichiers" "*.*".
    IF cFichierAction = "" THEN RETURN.

    /* Si le fichier existe déjà pour cette action on ne fait rien */
    FIND FIRST  AFaire_PJ NO-LOCK
        WHERE   AFaire_PJ.cUtilisateur = gcUtilisateur
        AND     AFaire_PJ.iNumeroAction = ttActions.iNumeroAction
        AND     AFaire_PJ.cNomPJ = cFichierAction
        NO-ERROR.    
    IF AVAILABLE(AFaire_PJ) THEN RETURN.
    
    CREATE AFaire_PJ.
    AFaire_PJ.cUtilisateur = gcUtilisateur.
    AFaire_PJ.iNumeroAction = ttActions.iNumeroAction.
    AFaire_PJ.cNomPJ = cFichierAction.
    AFaire_PJ.lRepertoire = FALSE.

    RUN ChargeFichiers.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnFichiersSupprimer
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnFichiersSupprimer C-Win
ON CHOOSE OF btnFichiersSupprimer IN FRAME frmFonction /* Supprimer */
DO:
    DEFINE VARIABLE cTypeSelection AS CHARACTER NO-UNDO.

    cTypeSelection = (IF ttFichiers.lRepertoire THEN "répertoire" ELSE "fichier").

    MESSAGE "Confirmez vous la suppression de l'association avec le " + cTypeSelection + " sélectionné ?"
        VIEW-AS ALERT-BOX QUESTION 
        BUTTON YES-NO
        TITLE "Confirmation..."
        UPDATE lreponse3 AS LOGICAL.
    
    IF not(lReponse3) THEN RETURN.

    FOR EACH    AFaire_PJ EXCLUSIVE-LOCK
        WHERE   AFaire_PJ.cUtilisateur = gcUtilisateur
        AND     AFaire_PJ.iNumeroAction = ttActions.iNumeroAction
        AND     AFaire_PJ.cNomPJ = ttFichiers.cNomPJ
        :
        
        /* On ne supprimme pas les répertoires */
        IF NOT(AFaire_PJ.lRepertoire) THEN DO:
            MESSAGE "Voulez-vous aussi supprimer physiquement le fichier sélectionné ?"
                VIEW-AS ALERT-BOX QUESTION 
                BUTTON YES-NO
                TITLE "Confirmation..."
                UPDATE lreponse4 AS LOGICAL.
    
            IF lReponse4 THEN DO:
                OS-DELETE VALUE(AFaire_PJ.cNomPJ).
            END.

        END.
        DELETE AFaire_PJ.
    END.
    RELEASE AFaire_PJ.

    RUN chargeFichiers.
    RUN GereCommentaire.
    RUN MajCommentaireActions.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnLanceProjet
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnLanceProjet C-Win
ON CHOOSE OF btnLanceProjet IN FRAME frmFonction /* > */
DO:
    IF ttListes.cProjet = "" THEN RETURN NO-APPLY.
    OS-COMMAND NO-WAIT VALUE(gcRepertoireRessourcesPrivees + "\scripts\general\execute.bat " + """" + ttListes.cProjet + """").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnListesAjouter
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnListesAjouter C-Win
ON CHOOSE OF btnListesAjouter IN FRAME frmFonction /* Ajouter */
DO:
    DEFINE VARIABLE iProchaineListe AS INTEGER NO-UNDO.
  /* Ajout d'une liste dans la base */
    RUN DonnePositionMessage IN ghGeneral.
    gcAllerRetour = STRING(giPosXMessage)
        + "|" + STRING(giPosYMessage)
        + "|" + "Libellé de la liste"
        + "|" + ""
        .
    RUN VALUE(gcRepertoireExecution + "saisie3.w") (INPUT-OUTPUT gcAllerRetour).
    IF gcAllerRetour = "" THEN RETURN.
    IF ENTRY(4,gcAllerRetour,"|") <> "" THEN DO:
        /* Prochain numero de liste */
        iProchaineListe = 1.
        FIND LAST   AFaire_Liste NO-LOCK 
            WHERE   AFaire_Liste.cUtilisateur = gcUtilisateur
            NO-ERROR. 
        IF AVAILABLE(AFaire_Liste) THEN iProchaineListe = AFaire_Liste.iNumeroListe + 1.
        
        CREATE AFaire_Liste.
        AFaire_Liste.cUtilisateur = gcUtilisateur.
        AFaire_Liste.iNumeroListe = iProchaineListe.
        AFaire_Liste.cLibelleListe = ENTRY(4,gcAllerRetour,"|").
        AFaire_Liste.iOrdreListe = iProchaineListe.
        AFaire_Liste.iAvancementListe = 0.
        AFaire_Liste.cFiller1 = "0".
            
    END.
    /* Rechargement de la liste */
    SauvePreference("AFAIRE-LISTE",STRING(AFaire_Liste.iNumeroListe)).
    RELEASE AFaire_Liste.
    RUN ChargeListes.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnListesSupprimer
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnListesSupprimer C-Win
ON CHOOSE OF btnListesSupprimer IN FRAME frmFonction /* Supprimer */
DO:

    MESSAGE "Confirmez vous la suppression de la liste sélectionnée ?"
        VIEW-AS ALERT-BOX QUESTION 
        BUTTON YES-NO
        TITLE "Confirmation..."
        UPDATE lreponse1 AS LOGICAL.
    
    IF not(lReponse1) THEN RETURN.

    /* Suppression des actions liées à cette liste */
    FOR EACH    AFaire_Liste EXCLUSIVE-LOCK
        WHERE   AFaire_Liste.cUtilisateur = gcUtilisateur
        AND     AFaire_Liste.iNumeroListe = ttListes.iNumeroListe
        :
        /* Suppression des action liées à cette liste ET cette action */
        FOR EACH    AFaire_Lien EXCLUSIVE-LOCK
            WHERE   AFaire_Lien.cUtilisateur = gcUtilisateur
            AND     AFaire_Lien.iNumeroListe = AFaire_Liste.iNumeroListe
            :
            FOR EACH    AFaire_Action EXCLUSIVE-LOCK
                WHERE   AFaire_Action.cUtilisateur = gcUtilisateur
                AND     AFaire_Action.iNumeroAction = AFaire_Lien.iNumeroAction
                :
                /* Suppression des PJ des Actions */
                FOR EACH    AFaire_PJ EXCLUSIVE-LOCK
                    WHERE   AFaire_PJ.cUtilisateur = gcUtilisateur
                    AND     AFaire_PJ.iNumeroAction = AFaire_Action.iNumeroAction
                    :
                    DELETE AFaire_PJ.
                END.
                DELETE AFaire_Action.
            END.
            DELETE AFaire_Lien.
        END.
        /* Suppression des projets liés à la liste */
        FOR EACH    AFaire_Projet EXCLUSIVE-LOCK
            WHERE   AFaire_Projet.cUtilisateur = gcUtilisateur
            AND     AFaire_Projet.iNumeroListe = AFaire_Liste.iNumeroListe
            :
            DELETE AFaire_Projet.
        END.
        DELETE AFaire_Liste.
    END.

    RELEASE AFaire_Liste.
    RELEASE AFaire_Lien.
    RELEASE AFaire_Action.
    RELEASE AFaire_PJ.
    RELEASE AFaire_Projet.
    
    RUN ChargeListes.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnProjet
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnProjet C-Win
ON CHOOSE OF btnProjet IN FRAME frmFonction /* prj associé */
DO:
    
    DEFINE VARIABLE cFichierProjet AS CHARACTER NO-UNDO.

    cRepertoireProjet = DonnePreference("PROJETS_REPERTOIRE_PERE").
    cFichierProjet = ttListes.cProjet.
    SYSTEM-DIALOG GET-FILE cFichierProjet INITIAL-DIR cRepertoireProjet USE-FILENAME FILTERS "Projets UE32" "*.prj",
                "Tous les fichiers" "*.*".

    IF cFichierProjet = "" THEN RETURN.

    ttListes.cProjet = cFichierProjet.
    FIND FIRST  AFaire_Projet EXCLUSIVE-LOCK
        WHERE   AFaire_Projet.cUtilisateur = gcUtilisateur
        AND     AFaire_Projet.iNumeroListe = ttListes.iNumeroListe
        NO-ERROR.
    IF NOT(AVAILABLE(AFaire_Projet)) THEN DO:
        CREATE AFaire_Projet.
        AFaire_Projet.cUtilisateur = gcUtilisateur.
        AFaire_Projet.iNumeroListe = ttListes.iNumeroListe.
    END.
    AFaire_Projet.cNomProjet = cFichierProjet.
    RELEASE AFaire_Projet.
    
    brwListes:REFRESH() IN FRAME frmFonction NO-ERROR.
    
    RUN gereActions.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnRepertoireAjouter
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnRepertoireAjouter C-Win
ON CHOOSE OF btnRepertoireAjouter IN FRAME frmFonction /* Ajouter un répertoire */
DO:
    DEFINE VARIABLE cFichierAction AS CHARACTER NO-UNDO.

    SYSTEM-DIALOG GET-DIR cFichierAction INITIAL-DIR cRepertoireProjet.
    IF cFichierAction = "" THEN RETURN.

    /* Si le fichier existe déjà pour cette action on ne fait rien */
    FIND FIRST  AFaire_PJ NO-LOCK
        WHERE   AFaire_PJ.cUtilisateur = gcUtilisateur
        AND     AFaire_PJ.iNumeroAction = ttActions.iNumeroAction
        AND     AFaire_PJ.cNomPJ = cFichierAction
        NO-ERROR.    
    IF AVAILABLE(AFaire_PJ) THEN RETURN.
    
    CREATE AFaire_PJ.
    AFaire_PJ.cUtilisateur = gcUtilisateur.
    AFaire_PJ.iNumeroAction = ttActions.iNumeroAction.
    AFaire_PJ.cNomPJ = cFichierAction.
    AFaire_PJ.lRepertoire = TRUE.

    RUN ChargeFichiers.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cmbJoursRappel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cmbJoursRappel C-Win
ON VALUE-CHANGED OF cmbJoursRappel IN FRAME frmFonction
DO:
    ttListes.cFiller1 = cmbJoursRappel:SCREEN-VALUE.
    FOR FIRST   AFaire_Liste EXCLUSIVE-LOCK
        WHERE   AFaire_Liste.cUtilisateur = gcUtilisateur
        AND     AFaire_Liste.iNumeroListe = ttListes.iNumeroListe
        :
        AFaire_Liste.cFiller1 = ttListes.cFiller1.
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rsActionsUrgence
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rsActionsUrgence C-Win
ON VALUE-CHANGED OF rsActionsUrgence IN FRAME frmFonction
DO:
  
    DEFINE VARIABLE cIdentListe AS CHARACTER NO-UNDO.
    DEFINE VARIABLE iTempo AS INTEGER NO-UNDO.
    DEFINE BUFFER bttactions FOR ttactions.
    DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cLibelle AS CHARACTER NO-UNDO.

  IF NOT(AVAILABLE(ttActions)) THEN RETURN.
  
  ttActions.cEtatAction = rsActionsUrgence:SCREEN-VALUE.
  IF ttActions.cEtatAction = "F" THEN ttActions.lRappelHoraire = FALSE.
  IF ttActions.cEtatAction = "A" THEN ttActions.lRappelHoraire = FALSE.

  /* si action faite */
  IF ttActions.cEtatAction = "F" THEN DO:

  END.
  
  /* Génération du libellé de suivi */
  IF ttActions.cEtatAction = "A" THEN cLibelle = "Abandonné".
  IF ttActions.cEtatAction = "AF" THEN cLibelle = "A faire".
  IF ttActions.cEtatAction = "AT" THEN cLibelle = "A tester".
  IF ttActions.cEtatAction = "F" THEN cLibelle = "Fait".
  IF ttActions.cEtatAction = "PA" THEN cLibelle = "Penser à".

      /* Sauvegarde de l'action */
    FIND FIRST  AFaire_Action   EXCLUSIVE-LOCK
        WHERE   AFaire_Action.cUtilisateur = gcUtilisateur
        AND     AFaire_Action.iNumeroAction = ttActions.iNumeroAction
        NO-ERROR.
    IF AVAILABLE(AFaire_Action) THEN DO:
        AFaire_Action.cEtatAction = ttActions.cEtatAction.
        AFaire_Action.lRappelHoraire = ttActions.lRappelHoraire.
        AFaire_Action.cFiller1 = AFaire_Action.cFiller1 + "§" + cLibelle + RemplaceVariables(" le %date% à %heure%","*",?,?).
    END.
    
    /* Une action faite passe en fin de la liste */
    /* Une action à faire passe en debut de la liste */
    IF (ttActions.cEtatAction = "F" 
    OR ttActions.cEtatAction = "AF" 
    OR ttActions.cEtatAction = "A")
    AND DonnePreference("PREF-ACTION-DEBUT-FIN") = "OUI"
    THEN DO: 
        FIND FIRST      AFaire_Lien     EXCLUSIVE-LOCK
                WHERE   AFaire_Lien.cUtilisateur = gcUtilisateur
                AND     AFaire_Lien.iNumeroListe = ttListes.iNumeroListe
                AND     AFaire_Lien.iNumeroAction = ttActions.iNumeroAction
                NO-ERROR.
        IF NOT(AVAILABLE(AFaire_Lien)) THEN RETURN.
        AFaire_Lien.iOrdreLien = (IF ttActions.cEtatAction = "AF" THEN 0 ELSE 4999).
        SauvePreference("AFAIRE-ACTION",STRING(AFaire_Lien.iNumeroAction)).
        RUN RenumeroteLiensAction.
    END.
    
    /* Cas particulier de retour au debut de la liste si action faite */
    IF ttActions.cEtatAction = "F" AND DonnePreference("PREF-ACTION-RETOUR-DEBUT") = "OUI" THEN DO:
        SauvePreference("AFAIRE-ACTION",STRING(0)).
    END.

    RUN ChargeActions.
    RUN RaffListes.
    RUN MajHistorique.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rsFichiersTousAction
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rsFichiersTousAction C-Win
ON VALUE-CHANGED OF rsFichiersTousAction IN FRAME frmFonction
DO:
    SauvePreference("PREF-AFAIRE-FICHIERS-TOUS-ACTION",SELF:SCREEN-VALUE).
    {&OPEN-QUERY-brwFichiers}
    RUN gereActions.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglNonTerminees
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglNonTerminees C-Win
ON VALUE-CHANGED OF tglNonTerminees IN FRAME frmFonction /* Ne voir que les listes vides ou non terminées */
DO:
  SauvePreference("PREF-NONTERMINEES",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
  {&OPEN-QUERY-brwListes}
  APPLY "VALUE-CHANGED" TO brwListes.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglRappelHoraire
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglRappelHoraire C-Win
ON VALUE-CHANGED OF tglRappelHoraire IN FRAME frmFonction /* Rappel horaire */
DO:
    IF NOT(AVAILABLE(ttActions)) THEN RETURN.
    
    ttActions.lRappelHoraire = SELF:CHECKED.
    /* Sauvegarde de l'action */
    FIND FIRST  AFaire_Action   EXCLUSIVE-LOCK
        WHERE   AFaire_Action.cUtilisateur = gcUtilisateur
        AND     AFaire_Action.iNumeroAction = ttActions.iNumeroAction
        NO-ERROR.
    IF AVAILABLE(AFaire_Action) THEN DO:
        AFaire_Action.lRappelHoraire = ttActions.lRappelHoraire.
    END.
    
    RUN ChargeActions.
    RUN RaffListes.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brwActions
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ChargeActions C-Win 
PROCEDURE ChargeActions :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    
    DO WITH FRAME frmFonction:
        EMPTY TEMP-TABLE ttActions.
        FOR EACH    AFaire_Lien NO-LOCK
            WHERE   AFaire_Lien.cUtilisateur = gcUtilisateur
            AND     AFaire_Lien.iNumeroListe = ttListes.iNumeroListe
           ,EACH    AFaire_Action NO-LOCK
            WHERE   AFaire_Action.cUtilisateur = gcUtilisateur
            AND     AFaire_Action.iNumeroAction = AFaire_Lien.iNumeroAction
            BY AFaire_Lien.iOrdreLien
            :
            CREATE ttActions.
            BUFFER-COPY AFaire_Action TO ttActions.

            ttactions.iOrdreAction = AFaire_Lien.iOrdreLien.
            ttActions.lCommentaire = ExisteCommentaire(ttActions.iNumeroAction).
            iMaxAction = ttactions.iOrdreAction.
        END.

        {&OPEN-QUERY-brwActions}
    
        /* Repositionnement sur la dernière action utilisée */
        iActionEnCours = INTEGER(DonnePreference("AFAIRE-ACTION")).
        FIND FIRST ttActions 
            WHERE   ttActions.iNumeroAction = iActionEnCours
            NO-ERROR.
        IF not(AVAILABLE(ttActions)) THEN do:
            FIND FIRST ttActions NO-ERROR.
        END.
        IF AVAILABLE(ttActions) THEN DO:
            REPOSITION brwActions TO RECID RECID(ttActions). 
        END.
    
        RUN chargeFichiers.
    
        APPLY "VALUE-CHANGED" TO brwActions.
        
        /* Creation du popup sur les actions */
        RUN CreMenuListes(brwActions:POPUP-MENU).
    END.   
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ChargeFichiers C-Win 
PROCEDURE ChargeFichiers :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    DO WITH FRAME frmFonction:
        EMPTY TEMP-TABLE ttFichiers.
        IF ttListes.iNumeroListe <> 0 THEN DO:
            FOR EACH    AFaire_Lien NO-LOCK
                WHERE   AFaire_Lien.cUtilisateur = gcUtilisateur
                AND     AFaire_Lien.iNumeroListe = ttListes.iNumeroListe
               ,EACH    AFaire_PJ NO-LOCK
                WHERE   AFaire_PJ.cUtilisateur = gcUtilisateur
                AND     AFaire_PJ.iNumeroAction = AFaire_Lien.iNumeroAction
                :
                CREATE ttFichiers.
                BUFFER-COPY AFaire_PJ TO ttFichiers.
                ttFichiers.iNumeroListe = ttListes.iNumeroListe.
            END.
        END.
    END.

    {&OPEN-QUERY-brwFichiers}

    RUN gereActions.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ChargeListes C-Win 
PROCEDURE ChargeListes :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    
    /* Savoir s'il faut convertir les anciennes listes et actions au nouveau format */
    IF DonnePreference("PREF-AFAIRE-CONVERSION-FAITE") <> "OUI" THEN DO:
        MESSAGE "Les listes et actions actuelles doivent être converties pour repecter un nouveau mode de stockage dans la base."
            + CHR(10) + "Cette conversion ne sera faite qu'une fois, vous n'aurez plus ce message."
            VIEW-AS ALERT-BOX.
        FIND FIRST  AFaire_Liste NO-LOCK
            WHERE   AFaire_Liste.cUtilisateur = gcUtilisateur
            NO-ERROR.
        IF NOT(AVAILABLE(AFaire_Liste)) THEN DO:
            RUN VALUE(gcRepertoireExecution + "ConvAFaire.p") (gcUtilisateur,FALSE).
        END.
    END.
    
    DO WITH FRAME frmFonction:
        /* Chargement de la liste des listes */
        EMPTY TEMP-TABLE ttListes.
        FOR EACH    AFaire_Liste NO-LOCK
            WHERE   AFaire_Liste.cUtilisateur = gcUtilisateur
            :
            CREATE ttListes.
            BUFFER-COPY AFaire_Liste TO ttListes.
            RUN RaffListes.
        END.
        
        {&OPEN-QUERY-brwListes}

        /* Repositionnement sur la dernière liste utilisée */
        iListeEnCours = INTEGER(DonnePreference("AFAIRE-LISTE")).
        FIND FIRST  ttListes 
            WHERE   ttListes.iNumeroListe = iListeEncours
            NO-ERROR.
        IF not(AVAILABLE(ttListes)) THEN do:
            FIND FIRST ttListes NO-ERROR.
        END.

        /* Chargement des actions de cette liste */
        IF AVAILABLE(ttListes) THEN do:
            REPOSITION brwListes TO RECID RECID(ttListes) NO-ERROR.
            APPLY "Value-changed" TO brwListes.
        END.
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ControleActions C-Win 
PROCEDURE ControleActions :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE cIdentListe AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cSvgAction AS CHARACTER NO-UNDO.
    DEFINE VARIABLE iCompteur AS INTEGER NO-UNDO INIT 0.
    DEFINE VARIABLE iCompteurFait AS INTEGER NO-UNDO INIT 0.

    IF NOT(AVAILABLE(ttListes)) THEN RETURN.

    FOR EACH    AFaire_Lien NO-LOCK
        WHERE   AFaire_Lien.cUtilisateur = gcUtilisateur
        AND     AFaire_Lien.iNumeroListe = ttListes.iNumeroListe
       ,FIRST   AFaire_Action NO-LOCK
        WHERE   AFaire_Action.cUtilisateur = gcUtilisateur       
        AND     AFaire_Action.iNumeroAction = AFaire_Lien.iNumeroAction 
        :
        iCompteur = iCompteur + 1.
        IF AFaire_Action.cEtatAction = "F"  /* Fait */ OR AFaire_Action.cEtatAction = "A"  /* Abandonné */ THEN DO:
            iCompteurFait = iCompteurFait + 1.
        END.
    END.

    IF iCompteur <> 0 THEN do:
        ttListes.iAvancementListe = trunc((iCompteurFait / iCompteur) * 100,0).
    END.
    ELSE DO:
        ttListes.iAvancementListe = 0.
    END.

    ttListes.cCouleur = string(ttListes.iAvancementListe) + "%".
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CreMenuListes C-Win 
PROCEDURE CreMenuListes :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER m_Actions-in AS WIDGET-HANDLE.
    
    DEFINE BUFFER bttlistes FOR ttlistes.
    DEFINE VARIABLE m_liste AS WIDGET-HANDLE.

    IF VALID-HANDLE(m_Deplacer) THEN DELETE WIDGET m_Deplacer.

    /* Création du sous menu */
    CREATE SUB-MENU m_Deplacer
        ASSIGN 
            PARENT = m_Actions-in 
            LABEL = "Déplacer l'action vers..."
            PRIVATE-DATA = ""
            .

    FOR EACH bttlistes :  
        /* Toutes les listes sauf celle en cours */
        IF bttlistes.iNumeroListe = ttlistes.iNumeroListe THEN NEXT.
        
        CREATE MENU-ITEM m_liste
            ASSIGN 
                PARENT = m_Deplacer 
                LABEL = bttlistes.cLibelleListe
                PRIVATE-DATA = STRING(bttlistes.iNumeroListe)
            TRIGGERS:
                ON "choose" PERSISTENT RUN Deplacer IN THIS-PROCEDURE (m_liste:PRIVATE-DATA).
            END TRIGGERS.
    END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Deplacer C-Win 
PROCEDURE Deplacer :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    
    DEFINE INPUT PARAMETER cCodeListe-in AS CHARACTER NO-UNDO.

    /* Modification de l'action en cours */
    FOR EACH AFaire_Lien EXCLUSIVE-LOCK  
        WHERE   AFaire_Lien.cUtilisateur = gcUtilisateur
        AND     AFaire_Lien.iNumeroListe = ttListes.iNumeroListe
        AND     AFaire_Lien.iNumeroAction = ttActions.iNumeroAction
        :
        AFaire_Lien.iNumeroListe = INTEGER(cCodeListe-in).
    END.

    RUN ChargeListes.
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
  VIEW FRAME frmModule IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-frmModule}
  DISPLAY rsActionsUrgence tglRappelHoraire cmbJoursRappel tglNonTerminees 
          rsFichiersTousAction 
      WITH FRAME frmFonction IN WINDOW C-Win.
  ENABLE RECT-1 RECT-2 RECT-3 brwListes brwActions rsActionsUrgence 
         btnActionsAjouter btnActionsSupprimer btnActionsAvant btnActionsApres 
         btnActionsCommentaire tglRappelHoraire brwFichiers cmbJoursRappel 
         tglNonTerminees rsFichiersTousAction btnListesAjouter 
         btnListesSupprimer btnProjet btnLanceProjet btnFichiersAjouter 
         btnRepertoireAjouter btnFichiersSupprimer 
      WITH FRAME frmFonction IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-frmFonction}
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
                /* Cacher la frame d'info au cas ou */
                AfficheInformations("",0).
                
                /* Affichage de la frame principale */
                VIEW FRAME frmModule.
                FRAME frmModule:MOVE-TO-TOP().
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
                RUN ImpressionModule.
            END.
        END CASE. /* fin du case */
    END. /* fin du do iboucle */

    RUN gereboutons.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Fermeture C-Win 
PROCEDURE Fermeture :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE OUTPUT PARAMETER lRetour-ou AS LOGICAL INIT FALSE.

    lRetour-ou = TRUE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE GereActions C-Win 
PROCEDURE GereActions :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DO WITH FRAME frmFonction:
    
        /* Sensitives par défaut */
        btnListesAjouter:SENSITIVE = TRUE.
        btnListesSupprimer:SENSITIVE = TRUE.
        btnActionsSupprimer:SENSITIVE = TRUE.
        btnActionsCommentaire:SENSITIVE = TRUE.
        btnActionsAjouter:SENSITIVE = TRUE.
        btnActionsAvant:SENSITIVE = TRUE.
        btnActionsApres:SENSITIVE = TRUE.
        btnProjet:SENSITIVE = TRUE.
        btnLanceProjet:SENSITIVE = TRUE.
        rsActionsUrgence:SENSITIVE = TRUE.
        btnFichiersAjouter:SENSITIVE = TRUE.
        btnRepertoireAjouter:SENSITIVE = TRUE.
        btnFichiersSupprimer:SENSITIVE = TRUE.
        rsFichiersTousAction:SENSITIVE = TRUE.
        tglRappelHoraire:SENSITIVE = TRUE.
    
        IF (NOT(AVAILABLE(ttListes)) OR (AVAILABLE(ttListes) AND ttListes.iNumeroListe = 0)) THEN do:
            btnListesSupprimer:SENSITIVE = FALSE.
            btnActionsAjouter:SENSITIVE = FALSE.
            btnActionsSupprimer:SENSITIVE = FALSE.
            btnActionsCommentaire:SENSITIVE = FALSE.
            btnActionsAvant:SENSITIVE = FALSE.
            btnActionsApres:SENSITIVE = FALSE.
            rsActionsUrgence:SENSITIVE = FALSE.
            btnProjet:SENSITIVE = FALSE.
            btnLanceProjet:SENSITIVE = FALSE.
            btnFichiersAjouter:SENSITIVE = FALSE.
            btnRepertoireAjouter:SENSITIVE = FALSE.
            btnFichiersSupprimer:SENSITIVE = FALSE.
            rsFichiersTousAction:SENSITIVE = FALSE.
            tglRappelHoraire:SENSITIVE = FALSE.
        END.
        IF (NOT(AVAILABLE(ttActions)) OR (AVAILABLE(ttActions) AND ttActions.iNumeroAction = 0)) THEN do:
            btnFichiersAjouter:SENSITIVE = FALSE.
            btnRepertoireAjouter:SENSITIVE = FALSE.
            btnActionsSupprimer:SENSITIVE = FALSE.
            btnActionsCommentaire:SENSITIVE = FALSE.
            btnActionsAvant:SENSITIVE = FALSE.
            btnActionsApres:SENSITIVE = FALSE.
            rsActionsUrgence:SENSITIVE = FALSE.
            tglRappelHoraire:SENSITIVE = FALSE.
        END.
        IF NOT(available(ttFichiers)) THEN do:
            btnFichiersSupprimer:SENSITIVE = FALSE.
        END.
        IF AVAILABLE(ttListes) AND ttListes.cProjet = "" THEN DO:
            btnLanceProjet:SENSITIVE = FALSE.
        END.
        IF AVAILABLE(ttActions) AND (ttActions.cEtatAction = "F" OR ttActions.cEtatAction = "A") THEN DO:
            tglRappelHoraire:SENSITIVE = FALSE.
        END.
    END.
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
    gcAideImprimer = "Imprimer les actions de la liste sélectionnée".
    gcAideRaf = "Recharger la liste des 'A faire'".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE GereCommentaire C-Win 
PROCEDURE GereCommentaire :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE iCouleurFond AS INTEGER NO-UNDO.
    
    iCouleurFond = ?.
    IF AVAILABLE(ttActions) AND ExisteCommentaire(ttActions.iNumeroAction) THEN iCouleurFond = 12.
    btnActionsCommentaire:BGCOLOR IN FRAME frmFonction = iCouleurFond.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE GestionErreurWord C-Win 
PROCEDURE GestionErreurWord :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER lErreur-in AS LOGICAL NO-UNDO.
    DEFINE INPUT PARAMETER cLibelle-in AS CHARACTER NO-UNDO.
    DEFINE INPUT-OUTPUT PARAMETER lErreurWord-ou as LOGICAL NO-UNDO.
    DEFINE INPUT-OUTPUT PARAMETER cErreur-ou AS CHARACTER NO-UNDO.

    IF NOT(lErreur-in) THEN RETURN.
    lErreurWord-ou = (lErreurWord-ou AND lErreur-in).
    IF lErreur-in THEN cErreur-ou = cErreur-ou + (IF cErreur-ou <> "" THEN CHR(10) ELSE "") + cLibelle-in.

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
    DEFINE VARIABLE cEtat AS CHARACTER NO-UNDO.
    /* Début de l'édition */
    RUN HTML_OuvreFichier("").
    cLigne = ttListes.cLibelleListe.
    IF ttListes.cProjet <> "" THEN DO:
        cLigne = cLigne + " ( Projet : '" + ttListes.cProjet + "' )".
    END.
    RUN HTML_TitreEdition(cLigne).
    
    RUN HTML_ChargeFormatCellule("E",0,"CF=gris,A=><,T=3").
    RUN HTML_ChargeFormatCellule("L",0,"A=<").
    
    /* Ecriture de l'entete pour le tableau des champs */
    cLigne = "" 
        + "Action"
        + devSeparateurEdition + "Etat"
        .
    RUN HTML_DebutTableau(cLigne).
    
    /* Balayage de la table des champs */
    FOR EACH ttActions
        WHERE ttActions.iNumeroAction > 0
        BY ttActions.iOrdreAction
        :
        IF ttActions.cEtatAction = "AF" THEN cEtat = "A faire".
        IF ttActions.cEtatAction = "AT" THEN cEtat = "A tester".
        IF ttActions.cEtatAction = "F" THEN cEtat = "Fait".
        IF ttActions.cEtatAction = "PA" THEN cEtat = "Penser à".
        IF ttActions.cEtatAction = "A" THEN cEtat = "Abandonné".
        
        cLigne = "" 
            + TRIM(ttActions.cLibelleAction)
            + devSeparateurEdition + TRIM(cEtat)
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
    DEFINE VARIABLE cValeurTousAction AS CHARACTER NO-UNDO.
    
    FRAME frmModule:COLUMN = gdPositionXModule.
    FRAME frmModule:ROW = gdPositionYModule.

    IF DonnePreference("REPERTOIRES-APPLI") = "" THEN SauvePreference("REPERTOIRES-APPLI",disque + "gidev").
    IF DonnePreference("PREF-COMPRESSION") = "" THEN SauvePreference("PREF-COMPRESSION","5").
    cRepertoireProjet = DonnePreference("PROJETS_REPERTOIRE_PERE").
    ASSIGN
        iListeEnCours = INTEGER(DonnePreference("AFAIRE-LISTE"))
        NO-ERROR.
    /* Car mode de stockage était xxxx/yyyy avant */
    IF ERROR-STATUS:ERROR THEN DO:
        SauvePreference("AFAIRE-LISTE","0").
        iListeEnCours = 0.
    END.

    iX = c-win:X + (c-win:WIDTH-PIXELS / 2).
    iY = c-win:Y + (c-win:HEIGHT-PIXELS / 2).

    cValeurTousAction = DonnePreference("PREF-AFAIRE-FICHIERS-TOUS-ACTION").
    IF cValeurTousAction = "" THEN cValeurTousAction = "T".

    DO WITH FRAME frmFonction:
        brwActions:LOAD-MOUSE-POINTER(gcRepertoireRessources + "\curmenu.cur").
        tglNonTerminees:CHECKED = (IF DonnePreference("PREF-NONTERMINEES") = "OUI" THEN TRUE ELSE FALSE).
        rsFichiersTousAction:SCREEN-VALUE = cValeurTousAction.
    END.

    hPopupAction = brwActions:POPUP-MENU.

    RUN chargelistes.

    RUN TopChronoGeneral.
    RUN TopChronoPartiel.

    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MajCommentaireActions C-Win 
PROCEDURE MajCommentaireActions :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE BUFFER bttActions FOR ttActions.

    FOR EACH    bttActions
        :
        bttActions.lCommentaire = ExisteCommentaire(bttActions.iNumeroAction).
    END.
    brwActions:REFRESH() IN FRAME frmFonction.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MajHistorique C-Win 
PROCEDURE MajHistorique :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    /* Mise a jour du tooltip text */
    brwActions:TOOLTIP IN FRAME frmFonction = DonneHistorique().

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
  IF not(glDeveloppeur) THEN DO WITH FRAME frmFonction:
      brwActions:SET-REPOSITIONED-ROW(4,"CONDITIONAL").
  END.
  ENABLE ALL WITH FRAME frmFonction.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE RaffListes C-Win 
PROCEDURE RaffListes :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    IF NOT(AVAILABLE(ttListes)) THEN RETURN.
    IF ttListes.iNumeroListe = 0 THEN RETURN.

    RUN ControleActions.
    
    brwListes:REFRESH() IN FRAME frmFonction NO-ERROR.

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE RenumeroteLiensAction C-Win 
PROCEDURE RenumeroteLiensAction :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

        DEFINE VARIABLE iOrdre AS INTEGER NO-UNDO.
        
    /* renumérotation des liens en 2 passes pour conserver l'ordre */
    iOrdre = 5000.
    FOR EACH    AFaire_Lien
        WHERE   AFaire_Lien.cUtilisateur = gcUtilisateur
        AND     AFaire_Lien.iNumeroListe = ttListes.iNumeroListe
        AND     AFaire_Lien.iOrdreLien < 5000
        BY AFaire_Lien.iOrdreLien 
        :
        iOrdre = iOrdre + 1.
        AFaire_Lien.iOrdreLien = iOrdre.
    END.
    iOrdre = 0.
    FOR EACH    AFaire_Lien
        WHERE   AFaire_Lien.cUtilisateur = gcUtilisateur
        AND     AFaire_Lien.iNumeroListe = ttListes.iNumeroListe
        AND     AFaire_Lien.iOrdreLien > 5000
        BY AFaire_Lien.iOrdreLien 
        :
        iOrdre = iOrdre + 1.
        AFaire_Lien.iOrdreLien = iOrdre.
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION DonneHistorique C-Win 
FUNCTION DonneHistorique RETURNS CHARACTER
  (  ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
    DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO.

    IF AVAILABLE(ttActions) THEN cRetour = REPLACE(ttActions.cFiller1,"§",CHR(10)).

    RETURN cRetour.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION DonneNomCompletFichier C-Win 
FUNCTION DonneNomCompletFichier RETURNS CHARACTER
  ( cNomListe-in AS CHARACTER, iNumeroListe-in AS INTEGER, iNumeroAction-in AS INTEGER ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/

    DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cTempo AS CHARACTER NO-UNDO.

        IF DonnePreference("PREF-ACTION-COMMENTAIRE-NOM") = "OUI" THEN DO:
            cTempo = REPLACE(cNomListe-in,"~"","'"). 
            DO iBoucle = 1 TO LENGTH(gcCaracteresInterdits):
                cTempo = REPLACE(cTempo,SUBSTRING(gcCaracteresInterdits,iBoucle,1),"_").
            END.
        END.
        ELSE DO:
            cTempo = "L" + STRING(iNumeroListe-in,"99999") + "-A" + STRING(iNumeroAction-in,"99999"). 
        END.
    cRetour = DonnePreference("PREF-REPERTOIRE-COMMENTAIRES") + "\C_" + cTempo + ".doc".


  RETURN cRetour.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION ExisteCommentaire C-Win 
FUNCTION ExisteCommentaire RETURNS LOGICAL
  ( iNumeroAction-in AS INTEGER ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
    
DEFINE VARIABLE lRetour AS LOGICAL NO-UNDO INIT FALSE.

    FIND FIRST  AFaire_PJ NO-LOCK
        WHERE AFaire_PJ.cUtilisateur = gcUtilisateur
        AND AFaire_PJ.iNumeroAction = iNumeroAction-in
        AND AFaire_PJ.lCommentaireAction /*AFaire_PJ.cNomPJ = cFichierAction*/
        NO-ERROR.
    lRetour = AVAILABLE(AFaire_PJ).

  RETURN lRetour.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

