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
{includes\i_chaine.i}
{includes\i_html.i}
{menudev2\includes\menudev2.i}



/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER  winGeneral  AS HANDLE NO-UNDO.
DEFINE INPUT PARAMETER  cParametres AS CHARACTER NO-UNDO.

/* Local Variable Definitions ---                                       */
DEFINE VARIABLE lChargeTables   AS LOGICAL NO-UNDO INIT TRUE.
DEFINE VARIABLE cBaseEnCours    AS CHARACTER    NO-UNDO INIT "sadb".

DEFINE VARIABLE cTri AS CHARACTER NO-UNDO INIT "Ordre".
DEFINE VARIABLE iX AS INTEGER NO-UNDO.
DEFINE VARIABLE iY AS INTEGER NO-UNDO.

/* Pour lire le métaschéma de manière pratique */
{menudev2\includes\tables.i "NEW"}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME frmModule
&Scoped-define BROWSE-NAME brwChamps

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ttChamps ttindexes ttTables

/* Definitions for BROWSE brwChamps                                     */
&Scoped-define FIELDS-IN-QUERY-brwChamps ttchamps.iordre WIDTH-P 25 ttChamps.cNom WIDTH-P 80 ttChamps.clabel WIDTH-P 275 ttchamps.ctype WIDTH-P 55 ttchamps.cformat WIDTH-P 90 ttchamps.cinitial WIDTH-P 20 ttchamps.cRemarque WIDTH-P 600   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brwChamps ttchamps.iordre   
&Scoped-define ENABLED-TABLES-IN-QUERY-brwChamps ttchamps
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-brwChamps ttchamps
&Scoped-define SELF-NAME brwChamps
&Scoped-define QUERY-STRING-brwChamps FOR EACH ttChamps
&Scoped-define OPEN-QUERY-brwChamps OPEN QUERY brwchamps FOR EACH ttChamps.
&Scoped-define TABLES-IN-QUERY-brwChamps ttChamps
&Scoped-define FIRST-TABLE-IN-QUERY-brwChamps ttChamps


/* Definitions for BROWSE brwIndexes                                    */
&Scoped-define FIELDS-IN-QUERY-brwIndexes ttindexes.cNom WIDTH-P 80 ttindexes.cDescription   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brwIndexes   
&Scoped-define SELF-NAME brwIndexes
&Scoped-define QUERY-STRING-brwIndexes FOR EACH ttindexes WHERE ttindexes.ctable = tttables.cnom
&Scoped-define OPEN-QUERY-brwIndexes OPEN QUERY {&SELF-NAME} FOR EACH ttindexes WHERE ttindexes.ctable = tttables.cnom.
&Scoped-define TABLES-IN-QUERY-brwIndexes ttindexes
&Scoped-define FIRST-TABLE-IN-QUERY-brwIndexes ttindexes


/* Definitions for BROWSE brwTables                                     */
&Scoped-define FIELDS-IN-QUERY-brwTables ttTables.cNom WIDTH-P 80 ttTables.cLibelle WIDTH-P 200   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brwTables ttTables.cNom   
&Scoped-define ENABLED-TABLES-IN-QUERY-brwTables ttTables
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-brwTables ttTables
&Scoped-define SELF-NAME brwTables
&Scoped-define QUERY-STRING-brwTables FOR EACH ttTables
&Scoped-define OPEN-QUERY-brwTables OPEN QUERY {&SELF-NAME} FOR EACH ttTables.
&Scoped-define TABLES-IN-QUERY-brwTables ttTables
&Scoped-define FIRST-TABLE-IN-QUERY-brwTables ttTables


/* Definitions for FRAME frmModule                                      */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rsBase btnPPapier txtRecherche ~
btnCodePrecedent-2 btnCodeSuivant-2 filTypeLibelle btnCodePrecedent ~
btnCodeSuivant brwTables brwChamps tglExport brwIndexes 
&Scoped-Define DISPLAYED-OBJECTS rsBase txtRecherche filTypeLibelle ~
tglExport 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD DonneFormatChamp C-Win 
FUNCTION DonneFormatChamp RETURNS CHARACTER
  ( cNomChamp AS character, cFormatInitial AS CHARACTER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.

/* Menu Definitions                                                     */
DEFINE MENU POPUP-MENU-brwChamps 
       MENU-ITEM m_Copier_uniquement_le_nom_de LABEL "Copier uniquement le nom des champs sélectionnés"
       RULE
       MENU-ITEM m_Générer_le_code_pour_WebGI LABEL "Générer le code pour WebGI"
       RULE
       MENU-ITEM m_Fermer       LABEL "Fermer"        .

DEFINE MENU POPUP-MENU-rsBase 
       MENU-ITEM m_Connecter_la_base_en_cours LABEL "Connecter la base en cours"
       MENU-ITEM m_Déconnecter_la_base_en_cour LABEL "Déconnecter la base en cours"
       RULE
       MENU-ITEM m_Editeur_sur_les_bases_conne LABEL "Editeur sur les bases connectées".


/* Definitions of the field level widgets                               */
DEFINE BUTTON btnCodePrecedent 
     LABEL "<" 
     SIZE-PIXELS 20 BY 20 TOOLTIP "Rechercher le précédent".

DEFINE BUTTON btnCodePrecedent-2 
     LABEL "<" 
     SIZE-PIXELS 20 BY 20 TOOLTIP "Rechercher le précédent".

DEFINE BUTTON btnCodeSuivant  NO-CONVERT-3D-COLORS
     LABEL ">" 
     SIZE-PIXELS 20 BY 20 TOOLTIP "Rechercher le suivant".

DEFINE BUTTON btnCodeSuivant-2  NO-CONVERT-3D-COLORS
     LABEL ">" 
     SIZE-PIXELS 20 BY 20 TOOLTIP "Rechercher le suivant".

DEFINE BUTTON btnPPapier  NO-FOCUS FLAT-BUTTON
     LABEL "X" 
     SIZE 4 BY .95 TOOLTIP "Générer la requête avec les champs sélectionnés dans le presse-papier".

DEFINE VARIABLE filTypeLibelle AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE-PIXELS 560 BY 20
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE txtRecherche AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 33 BY .95 TOOLTIP "Saisissez tout ou partie du nom de la table à rechercher..."
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE rsBase AS CHARACTER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Sadb", "sadb",
"Ladb", "ladb",
"Wadb", "wadb",
"Transfer", "transfer",
"Ltrans", "ltrans",
"Compta", "compta",
"Lcompta", "lcompta",
"Cadb", "cadb",
"Inter", "inter",
"Dwh", "dwh",
"Emprunt", "emprunt",
"gidata", "gidata"
     SIZE 161 BY .71 TOOLTIP "Choisissez la base à charger" NO-UNDO.

DEFINE VARIABLE tglExport AS LOGICAL INITIAL no 
     LABEL "Avec export au format csv pour Excel)   >>>>>" 
     VIEW-AS TOGGLE-BOX
     SIZE 47 BY .71 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brwChamps FOR 
      ttChamps SCROLLING.

DEFINE QUERY brwIndexes FOR 
      ttindexes SCROLLING.

DEFINE QUERY brwTables FOR 
      ttTables SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brwChamps
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brwChamps C-Win _FREEFORM
  QUERY brwChamps DISPLAY
      ttchamps.iordre FORMAT ">>>>9" LABEL "Ordre" WIDTH-P 25  
ttChamps.cNom FORMAT "x(20)" LABEL "Nom" WIDTH-P 80
ttChamps.clabel  FORMAT "x(255)" LABEL "Label" WIDTH-P 275
ttchamps.ctype FORMAT "x(11)" LABEL "Type" WIDTH-P 55
ttchamps.cformat FORMAT "x(20)" LABEL "Format" WIDTH-P 90
ttchamps.cinitial FORMAT "x(20)" LABEL "Init." WIDTH-P 20
ttchamps.cRemarque FORMAT "x(250)" LABEL "Description" WIDTH-P 600
ENABLE ttchamps.iordre
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS MULTIPLE SIZE 121 BY 11.67
         BGCOLOR 15 
         TITLE BGCOLOR 15 "Champs" ROW-HEIGHT-CHARS .67.

DEFINE BROWSE brwIndexes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brwIndexes C-Win _FREEFORM
  QUERY brwIndexes DISPLAY
      ttindexes.cNom FORMAT "x(20)" LABEL "Nom" WIDTH-P 80
ttindexes.cDescription  FORMAT "x(255)" LABEL "Composition"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 121 BY 4.52
         BGCOLOR 15 
         TITLE BGCOLOR 15 "Indexes" ROW-HEIGHT-CHARS .62 FIT-LAST-COLUMN.

DEFINE BROWSE brwTables
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brwTables C-Win _FREEFORM
  QUERY brwTables DISPLAY
      ttTables.cNom FORMAT "x(20)" LABEL "Nom" WIDTH-P 80
      ttTables.cLibelle FORMAT "x(255)" LABEL "Détail" WIDTH-P 200
    ENABLE ttTables.cNom
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 42 BY 17.14
         BGCOLOR 15 
         TITLE BGCOLOR 15 "Tables" ROW-HEIGHT-CHARS .62.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME frmModule
     rsBase AT ROW 1.24 COL 5 NO-LABEL
     btnPPapier AT ROW 15.05 COL 162 HELP
          "Envoyer vers le presse-papier" WIDGET-ID 20 NO-TAB-STOP 
     txtRecherche AT ROW 2.19 COL 2 NO-LABEL
     btnCodePrecedent-2 AT Y 25 X 175 WIDGET-ID 32
     btnCodeSuivant-2 AT Y 25 X 195 WIDGET-ID 34
     filTypeLibelle AT Y 25 X 220 NO-LABEL WIDGET-ID 26
     btnCodePrecedent AT Y 25 X 785 WIDGET-ID 22
     btnCodeSuivant AT Y 25 X 805 WIDGET-ID 24
     brwTables AT ROW 3.38 COL 2
     brwChamps AT ROW 3.38 COL 45
     tglExport AT ROW 15.19 COL 114 WIDGET-ID 30
     brwIndexes AT ROW 16 COL 45
     "Générer la requête avec les champs sélectionnés dans le presse-papier (" VIEW-AS TEXT
          SIZE 69 BY .95 AT ROW 15.05 COL 45 WIDGET-ID 28
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 166.2 BY 20.62
         BGCOLOR 7 
         TITLE BGCOLOR 2 FGCOLOR 15 "Dictionnaire".


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
/* SETTINGS FOR FRAME frmModule
   FRAME-NAME                                                           */
/* BROWSE-TAB brwTables btnCodeSuivant frmModule */
/* BROWSE-TAB brwChamps brwTables frmModule */
/* BROWSE-TAB brwIndexes tglExport frmModule */
ASSIGN 
       brwChamps:POPUP-MENU IN FRAME frmModule             = MENU POPUP-MENU-brwChamps:HANDLE
       brwChamps:COLUMN-RESIZABLE IN FRAME frmModule       = TRUE.

ASSIGN 
       brwIndexes:COLUMN-RESIZABLE IN FRAME frmModule       = TRUE
       brwIndexes:COLUMN-MOVABLE IN FRAME frmModule         = TRUE.

ASSIGN 
       brwTables:COLUMN-RESIZABLE IN FRAME frmModule       = TRUE.

ASSIGN 
       btnCodeSuivant:AUTO-RESIZE IN FRAME frmModule      = TRUE.

ASSIGN 
       btnCodeSuivant-2:AUTO-RESIZE IN FRAME frmModule      = TRUE.

/* SETTINGS FOR FILL-IN filTypeLibelle IN FRAME frmModule
   ALIGN-L                                                              */
ASSIGN 
       rsBase:POPUP-MENU IN FRAME frmModule       = MENU POPUP-MENU-rsBase:HANDLE.

/* SETTINGS FOR FILL-IN txtRecherche IN FRAME frmModule
   ALIGN-L                                                              */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brwChamps
/* Query rebuild information for BROWSE brwChamps
     _START_FREEFORM

OPEN QUERY brwchamps FOR EACH ttChamps
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE brwChamps */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brwIndexes
/* Query rebuild information for BROWSE brwIndexes
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH ttindexes WHERE ttindexes.ctable = tttables.cnom
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE brwIndexes */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brwTables
/* Query rebuild information for BROWSE brwTables
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH ttTables.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE brwTables */
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


&Scoped-define BROWSE-NAME brwChamps
&Scoped-define SELF-NAME brwChamps
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwChamps C-Win
ON ALT-CTRL-C OF brwChamps IN FRAME frmModule /* Champs */
DO:
    gAddParam("DICO-CSV","TRUE").
    APPLY "CHOOSE" TO btnPPapier.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwChamps C-Win
ON CTRL-A OF brwChamps IN FRAME frmModule /* Champs */
DO:
  FOR EACH ttChamps
      WHERE ttChamps.cTable = ttTables.cNom:
      REPOSITION brwChamps TO RECID RECID(ttChamps).
      brwChamps:SELECT-FOCUSED-ROW().
  END.
  brwChamps:REFRESH().
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwChamps C-Win
ON CTRL-C OF brwChamps IN FRAME frmModule /* Champs */
DO:
    gSupParam("DICO-CSV").
    APPLY "CHOOSE" TO btnPPapier.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwChamps C-Win
ON START-SEARCH OF brwChamps IN FRAME frmModule /* Champs */
DO:
    DEFINE VARIABLE     hColonneEnCours        AS WIDGET-HANDLE         NO-UNDO.

    hColonneEnCours = brwChamps:CURRENT-COLUMN.
    cTri = hColonneEnCours:LABEL.
    
    RUN OuvreQueryChamps.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwChamps C-Win
ON VALUE-CHANGED OF brwChamps IN FRAME frmModule /* Champs */
DO:
    /* Maj du tooltip champs */
    brwchamps:TOOLTIP IN FRAME frmmodule = ""
        + string(ttchamps.iordre)
        + CHR(10) + ttchamps.cnom
        + CHR(10) + ttchamps.clabel
        + CHR(10) + ttchamps.cType
        + CHR(10) + ttchamps.cFormat
        + CHR(10) + ttchamps.cInitial
        .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brwIndexes
&Scoped-define SELF-NAME brwIndexes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwIndexes C-Win
ON VALUE-CHANGED OF brwIndexes IN FRAME frmModule /* Indexes */
DO:
    /* Maj du tooltip champs */
    brwindexes:TOOLTIP IN FRAME frmmodule = ""
        + ttindexes.cnom
        + CHR(10) + ttindexes.cDescription
        .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brwTables
&Scoped-define SELF-NAME brwTables
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwTables C-Win
ON VALUE-CHANGED OF brwTables IN FRAME frmModule /* Tables */
DO:
    /* Chargement des browse champs et indexes */
    RUN ChargeChamps.
    RUN ChargeIndexes.

    /* Maj du tooltip tables */
    brwtables:TOOLTIP IN FRAME frmmodule = tttables.cnom.
/*
    APPLY "VALUE-CHANGED" TO brwchamps IN FRAME frmmodule.
    APPLY "VALUE-CHANGED" TO brwindexes IN FRAME frmmodule.
*/
    /*APPLY "ENTRY" TO brwchamps IN FRAME frmmodule.*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnCodePrecedent
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnCodePrecedent C-Win
ON CHOOSE OF btnCodePrecedent IN FRAME frmModule /* < */
DO:
  
    RUN Saisie ("PREV").

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnCodePrecedent-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnCodePrecedent-2 C-Win
ON CHOOSE OF btnCodePrecedent-2 IN FRAME frmModule /* < */
DO:
  
    RUN Saisie2 ("PREV").

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnCodeSuivant
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnCodeSuivant C-Win
ON CHOOSE OF btnCodeSuivant IN FRAME frmModule /* > */
DO:
    
    RUN Saisie ("NEXT").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnCodeSuivant-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnCodeSuivant-2 C-Win
ON CHOOSE OF btnCodeSuivant-2 IN FRAME frmModule /* > */
DO:
    
    RUN Saisie2 ("NEXT").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnPPapier
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnPPapier C-Win
ON CHOOSE OF btnPPapier IN FRAME frmModule /* X */
DO:
  DEFINE VARIABLE cFichierModele AS CHARACTER NO-UNDO.
  DEFINE VARIABLE cFichierMoulinette AS CHARACTER NO-UNDO.
  DEFINE VARIABLE cLigne AS CHARACTER NO-UNDO.
  DEFINE VARIABLE cLigneCB AS CHARACTER NO-UNDO.
  DEFINE VARIABLE cChamps AS CHARACTER NO-UNDO.
  DEFINE VARIABLE cChampsExport AS CHARACTER NO-UNDO.
  DEFINE VARIABLE cWhere AS CHARACTER NO-UNDO.
  DEFINE VARIABLE iBoucle AS INTEGER NO-UNDO.
  DEFINE VARIABLE iSelection AS INTEGER NO-UNDO.
  DEFINE VARIABLE lOK AS LOGICAL NO-UNDO.
  DEFINE VARIABLE lParam AS LOGICAL NO-UNDO INIT FALSE.
  DEFINE VARIABLE lCSV AS LOGICAL NO-UNDO INIT FALSE.
  DEFINE VARIABLE cEntete AS CHARACTER NO-UNDO.
  DEFINE VARIABLE cTable AS CHARACTER NO-UNDO.
  DEFINE VARIABLE cFormatChamp AS CHARACTER NO-UNDO.
  DEFINE VARIABLE iBoucleExtent AS INTEGER NO-UNDO.

  lParam = (gGetParam("DICO-CSV") = "TRUE").

  DO WITH FRAME frmModule:

      lCSV = (tglExport:CHECKED OR lParam).

      /* Fichier modèle */
      /*
      cFichierModele = gcRepertoireRessourcesPrivees + "Scripts\general\dico_display.p".
      IF lCSV THEN cFichierModele = gcRepertoireRessourcesPrivees + "Scripts\general\dico_export.p".
      */
      cFichierModele = "dico_display.p".
      IF lCSV THEN cFichierModele = "dico_export.p".


      /* Liste des champs */
      cTable = ttTables.cNom.
      iSelection = 0.
      DO iBoucle = 1 TO brwChamps:NUM-SELECTED-ROWS:
        brwChamps:FETCH-SELECTED-ROW(iBoucle).
        cFormatChamp = DonneFormatChamp(ttChamps.cnom,ttChamps.cFormat).
        IF ttchamps.iextent = 0 THEN DO:
            cWhere =  cWhere + ttTables.cNom + "." + ttChamps.cnom + " = " + ttTables.cNom + "." + ttChamps.cnom + chr(10) + CHR(9) + "AND " + CHR(9).
            cChamps = cChamps + ttTables.cNom + "." + ttChamps.cnom + " " + "FORMAT ~"" + trim(cFormatChamp) + "~"" + CHR(10) + CHR(9).
            cChampsExport = cChampsExport + ttTables.cNom + "." + ttChamps.cnom + " "";"" ".
        END.
        ELSE DO:
            DO iBoucleExtent = 1 TO ttchamps.iextent:
                cWhere =  cWhere + ttTables.cNom + "." + ttChamps.cnom + "[" + string(iBoucleExtent) + "]" + " = " + ttTables.cNom + "." + ttChamps.cnom + "[" + string(iBoucleExtent) + "]" + chr(10) + CHR(9) + "AND " + CHR(9).
                cChamps = cChamps + ttTables.cNom + "." + ttChamps.cnom + "[" + string(iBoucleExtent) + "]" + " " + "FORMAT ~"" + trim(cFormatChamp) + "~"" + CHR(10) + CHR(9).
                cChampsExport = cChampsExport + ttTables.cNom + "." + ttChamps.cnom + "[" + string(iBoucleExtent) + "]" + " "";"" ".
            END.
        END.
        cEntete = cEntete + ttChamps.cnom + ";".
      END.

      cWhere = cWhere + "true".
      cEntete = """" + cEntete + """".

      /* Génération de la requete */
      RUN gDechargeFichierEnLocal("",cFichierModele).
      INPUT FROM VALUE(gcFichierLocal).
      REPEAT:
          IMPORT UNFORMATTED cLigne.
          cLigne = REPLACE(cLigne,"%base%",ttTables.cNom).
          cLigne = REPLACE(cLigne,"%champs%",(IF lCSV THEN cChampsExport ELSE cChamps)).
          cLigne = REPLACE(cLigne,"%where%",cWhere).
          cLigne = REPLACE(cLigne,"%entete%",cEntete).
          cLigne = REPLACE(cLigne,"%table%",cTable).
          cLigneCB = cLigneCB + (IF cLigneCB <> "" THEN CHR(10) ELSE "") + cLigne.
      END.
      INPUT CLOSE.
      
      /* envoyer le code vers le presse papier */
       CLIPBOARD:VALUE = cLigneCB.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filTypeLibelle
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filTypeLibelle C-Win
ON ANY-PRINTABLE OF filTypeLibelle IN FRAME frmModule
DO:  
    APPLY  LAST-KEY TO SELF.
    RUN Saisie ("").
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filTypeLibelle C-Win
ON BACKSPACE OF filTypeLibelle IN FRAME frmModule
DO:
    APPLY  LAST-KEY TO SELF.
    RUN Saisie ("").
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filTypeLibelle C-Win
ON DELETE-CHARACTER OF filTypeLibelle IN FRAME frmModule
DO:
    APPLY  LAST-KEY TO SELF.
    RUN Saisie ("").
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filTypeLibelle C-Win
ON RETURN OF filTypeLibelle IN FRAME frmModule
DO:
    APPLY  LAST-KEY TO SELF.
    RUN Saisie ("").
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Connecter_la_base_en_cours
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Connecter_la_base_en_cours C-Win
ON CHOOSE OF MENU-ITEM m_Connecter_la_base_en_cours /* Connecter la base en cours */
DO:
  DO WITH FRAME frmModule:
    IF CONNECTED(rsBase:SCREEN-VALUE) THEN RETURN.
    CONNECT -pf VALUE(ser_outils + "\Cnx-Menudev2-" + rsBase:SCREEN-VALUE + ".pf"). 
    APPLY "VALUE-CHANGED" TO rsBase.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Copier_uniquement_le_nom_de
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Copier_uniquement_le_nom_de C-Win
ON CHOOSE OF MENU-ITEM m_Copier_uniquement_le_nom_de /* Copier uniquement le nom des champs sélectionnés */
DO:
  RUN CopieNomChamps.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Déconnecter_la_base_en_cour
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Déconnecter_la_base_en_cour C-Win
ON CHOOSE OF MENU-ITEM m_Déconnecter_la_base_en_cour /* Déconnecter la base en cours */
DO:
  DO WITH FRAME frmModule:
    IF not(CONNECTED(rsBase:SCREEN-VALUE)) THEN RETURN.
    DISCONNECT value(rsBase:SCREEN-VALUE). 
    rsBase:SCREEN-VALUE = "sadb".
    APPLY "VALUE-CHANGED" TO rsBase.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Editeur_sur_les_bases_conne
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Editeur_sur_les_bases_conne C-Win
ON CHOOSE OF MENU-ITEM m_Editeur_sur_les_bases_conne /* Editeur sur les bases connectées */
DO:
  RUN _edit.p.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Générer_le_code_pour_WebGI
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Générer_le_code_pour_WebGI C-Win
ON CHOOSE OF MENU-ITEM m_Générer_le_code_pour_WebGI /* Générer le code pour WebGI */
DO:
  RUN GenereCodeWebGI.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rsBase
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rsBase C-Win
ON VALUE-CHANGED OF rsBase IN FRAME frmModule
DO:
    cBaseEnCours = SELF:SCREEN-VALUE.
    
    /* Vérification de presence de la base */
    IF NOT(CONNECTED(cbaseencours)) THEN DO:
        MESSAGE "Cette base n'est pas connectée !" VIEW-AS ALERT-BOX ERROR
            TITLE "Changement de base...".
        RETURN NO-APPLY.
    END.

    /* Chargement de la liste des tables */
    RUN ChargeTables.

    /* Repositionnement dans la zone de saisie */
    txtrecherche:SCREEN-VALUE IN FRAME frmmodule = "".
    APPLY "ENTRY" TO txtrecherche IN FRAME frmmodule.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME txtRecherche
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL txtRecherche C-Win
ON ANY-PRINTABLE OF txtRecherche IN FRAME frmModule
DO:
  
    APPLY  LAST-KEY TO SELF.
    RUN Saisie2 ("").
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL txtRecherche C-Win
ON BACKSPACE OF txtRecherche IN FRAME frmModule
DO:
  
    APPLY  LAST-KEY TO SELF.
    RUN Saisie2 ("").
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL txtRecherche C-Win
ON DELETE-CHARACTER OF txtRecherche IN FRAME frmModule
DO:
  
    APPLY  LAST-KEY TO SELF.
    RUN Saisie2 ("").
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL txtRecherche C-Win
ON RETURN OF txtRecherche IN FRAME frmModule
DO:
  
    APPLY  LAST-KEY TO SELF.
    RUN Saisie2 ("").
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brwChamps
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

ON 'ctrl-c':U OF brwchamps
DO:
    APPLY "CHOOSE" TO btnPPapier IN FRAME frmModule.
END.

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ActiveBase.p C-Win 
PROCEDURE ActiveBase.p :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    
    
    DELETE ALIAS dictdb.
    case cBaseEnCours:
        when "sadb" then create alias dictdb for database sadb.
        when "ladb" then create alias dictdb for database ladb.
        when "wadb" then create alias dictdb for database wadb.
        when "compta" then create alias dictdb for database compta.
        when "lcompta" then create alias dictdb for database lcompta.
        when "inter" then create alias dictdb for database inter.
        when "cadb" then create alias dictdb for database cadb.
        when "transfer" then create alias dictdb for database transfer.
        when "ltrans" then create alias dictdb for database ltrans.
        when "dwh" then create alias dictdb for database dwh.
        when "gidata" then create alias dictdb for database gidata.
        when "emprunt" then create alias dictdb for database emprunt.
    end case.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ChargeChamps C-Win 
PROCEDURE ChargeChamps :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    brwChamps:TITLE IN FRAME frmModule = tttables.cnom + " (" + tttables.clibelle + ")".

    cTri = "Ordre".
    RUN OuvreQueryChamps.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ChargeIndexes C-Win 
PROCEDURE ChargeIndexes :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    OPEN QUERY brwIndexes FOR EACH ttindexes WHERE ttindexes.ctable = tttables.cnom.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ChargeTables C-Win 
PROCEDURE ChargeTables :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE VARIABLE cProgrammeExterne AS CHARACTER  NO-UNDO.
DEFINE VARIABLE iNombreBasesConnectees AS INTEGER NO-UNDO.

    SESSION:SET-WAIT-STATE("GENERAL").    

    EMPTY TEMP-TABLE tttables.
    EMPTY TEMP-TABLE ttchamps.
    EMPTY TEMP-TABLE ttindexes.

    RUN ActiveBase.p.
    
    /* Appel de la routine de chargement de base */
    cProgrammeExterne = gcRepertoireExecution + "ChargeTables.p".
    IF SEARCH(cProgrammeExterne) = ? THEN RETURN.
    COMPILE VALUE(cProgrammeExterne).
    RUN VALUE(cProgrammeExterne).

    /* La base est chargée : ouverture du query */
    RUN OuvreQueryTables.

    /* maj du browse des champs */
    APPLY "VALUE-CHANGED" TO brwTables IN FRAME frmModule.
    
    SESSION:SET-WAIT-STATE("").    


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CopieNomChamps C-Win 
PROCEDURE CopieNomChamps :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
        DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO.
        DEFINE VARIABLE iBoucle AS INTEGER NO-UNDO.
        DEFINE VARIABLE iBoucleExtent AS INTEGER NO-UNDO.
        DEFINE VARIABLE cChampsExport AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cTable AS CHARACTER NO-UNDO.

    DO WITH FRAME frmModule:
        /* Liste des champs */
        cTable = ttTables.cNom.
        DO iBoucle = 1 TO brwChamps:NUM-SELECTED-ROWS:
          brwChamps:FETCH-SELECTED-ROW(iBoucle).
          IF ttchamps.iextent = 0 THEN DO:
              cChampsExport = cChampsExport + ttTables.cNom + "." + ttChamps.cnom + " ".
          END.
          ELSE DO:
              DO iBoucleExtent = 1 TO ttchamps.iextent:
                  cChampsExport = cChampsExport + ttTables.cNom + "." + ttChamps.cnom + "[" + string(iBoucleExtent) + "]" + " ".
              END.
          END.
        END.
    
        CLIPBOARD:VALUE = cChampsExport.
        RUN gAfficheMessageTemporaire("Bases - Gestion Champs","Champs séléctionnés mis en presse-papier",FALSE,2,"OK","MESSAGE-COMMENTAIRE-CHAMPS-1",FALSE,OUTPUT cRetour).
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
  DISPLAY rsBase txtRecherche filTypeLibelle tglExport 
      WITH FRAME frmModule IN WINDOW C-Win.
  ENABLE rsBase btnPPapier txtRecherche btnCodePrecedent-2 btnCodeSuivant-2 
         filTypeLibelle btnCodePrecedent btnCodeSuivant brwTables brwChamps 
         tglExport brwIndexes 
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
                /* Affichage de la frame principale */
                VIEW FRAME frmModule.
                FRAME frmModule:MOVE-TO-TOP().
                APPLY "ENTRY" TO txtrecherche IN FRAME frmmodule.
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
            WHEN "RECHARGE" THEN DO:
                RUN Recharger.
            END.
            WHEN "INIT" THEN DO:
                RUN Initialisation.
            END.
            WHEN "IMPRIME" THEN DO:
                RUN Impression.
            END.
        END CASE. /* fin du case */
    END. /* fin du do iboucle */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE GenereCodeWebGI C-Win 
PROCEDURE GenereCodeWebGI :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO.
    DEFINE VARIABLE iBoucle AS INTEGER NO-UNDO.
    DEFINE VARIABLE iBoucle2 AS INTEGER NO-UNDO.
    DEFINE VARIABLE cChampsTable AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cChampsAssign AS LONGCHAR NO-UNDO.
    DEFINE VARIABLE cNomTable AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cTypeChamp AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cResultat AS LONGCHAR NO-UNDO.

    DEFINE VARIABLE cCodeTable AS LONGCHAR NO-UNDO.
    DEFINE VARIABLE cCodeAssign AS LONGCHAR NO-UNDO.

    DEFINE VARIABLE cFichierCode AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cTempo AS CHARACTER NO-UNDO.
    DEFINE VARIABLE iDebut AS INTEGER NO-UNDO.
    DEFINE VARIABLE iLongueur AS INTEGER NO-UNDO INIT 3000.


    RUN DonnePositionMessage IN ghGeneral.
    gcAllerRetour = STRING(giPosXMessage)
        + "|" + STRING(giPosYMessage)
        + "|" + "Nom table tempo"
        + "|" + "ttttt"
        .

    RUN VALUE(gcRepertoireExecution + "saisie2.w") (INPUT-OUTPUT gcAllerRetour).
    IF gcAllerRetour = "" THEN RETURN.
    cNomTable = ENTRY(4,gcAllerRetour,"|").
    IF cNomTable = "" OR cNomTable = ? THEN cNomTable = "ttttt".

    cCodeTable = "define temp-table " + cNomTable + " no-undo /* ancienne table : xxxxx */".
    cCodeAssign = "assign".
    
    DO WITH FRAME frmModule:
        /* Liste des champs */
        DO iBoucle = 1 TO brwChamps:NUM-SELECTED-ROWS:
          brwChamps:FETCH-SELECTED-ROW(iBoucle).
          cTypeChamp = "?????".
          CASE substring(ttChamps.cType,1,4):
              WHEN "inte" THEN cTypeChamp = "integer".
              WHEN "char" THEN cTypeChamp = "character".
              WHEN "date" THEN cTypeChamp = "date".
              WHEN "deci" THEN cTypeChamp = "decimal".
              WHEN "int6" THEN cTypeChamp = "int64".
              WHEN "logi" THEN cTypeChamp = "logical".
          END CASE.
          IF ttchamps.iextent = 0 THEN DO:
              cChampsTable = chr(9) + string("field xxxxx","x(25)") + "as " + string(cTypeChamp,"x(15)") + fill(" ",15) + "/* " + ttTables.cNom + "." + ttChamps.cnom + " */ ".
              cChampsAssign = chr(9) + cNomTable + STRING(".xxxxx","x(25)") + "= " + ttTables.cNom + "." + ttChamps.cnom.
          END.
          ELSE DO:
              cChampsTable = chr(9) + string("field xxxxx","x(25)") + "as " + string(cTypeChamp,"x(15)") + string("extent " + string(ttchamps.iextent),"x(15)") + "/* " + ttTables.cNom + "." + ttChamps.cnom + " */ ".
              DO iBoucle2 = 1 TO ttchamps.iextent:
                  cChampsAssign = cChampsAssign + (IF cChampsAssign <> "" THEN CHR(10) ELSE "")
                      + chr(9) + cNomTable + string(".xxxxx[" + STRING(iBoucle2) + "]","x(25)") + "= " + ttTables.cNom + "." + ttChamps.cnom + "[" + STRING(iBoucle2) + "]".
              END.
          END.
          cCodeTable = cCodeTable + CHR(10) + cChampsTable.
          cCodeAssign = cCodeAssign + CHR(10) + cChampsAssign.
        END.

        cCodeTable = cCodeTable + CHR(10) + chr(9) + "index NomIndex NomChamp".
        cCodeTable = cCodeTable + CHR(10) + chr(9) + ".".
        cCodeAssign = cCodeAssign + CHR(10) + chr(9) + ".".

        cResultat = cCodeTable + CHR(10) + CHR(10) + cCodeAssign + CHR(10).
        IF LENGTH(cResultat) < 64000 THEN DO:
            CLIPBOARD:VALUE = cResultat.
            RUN gAfficheMessageTemporaire("Bases - Gestion Champs","Code mis en presse-papier",FALSE,2,"OK","MESSAGE-COMMENTAIRE-CHAMPS-WEBGI",FALSE,OUTPUT cRetour).
        END.
        ELSE DO:
            cFichierCode = loc_tmp + "\CodeWebGI.txt".
            OUTPUT TO VALUE(cFichierCode).
            iDebut = 1.
            DECOUPAGE:
            REPEAT:
                cTempo = SUBSTRING(cResultat,iDebut,iLongueur).
                PUT UNFORMATTED cTempo.
                iDebut = iDebut + iLongueur.
                IF iDebut + iLongueur > LENGTH(cResultat) THEN LEAVE DECOUPAGE.
            END.
            cTempo = SUBSTRING(cResultat,iDebut).
            PUT UNFORMATTED cTempo.
            OUTPUT CLOSE.
            RUN gAfficheMessageTemporaire("Bases - Gestion Champs","Trop gros pour le presse-papier. Code sauvé sous %s" + cFichierCode,FALSE,0,"OK","MESSAGE-COMMENTAIRE-CHAMPS-WEBGI-3",FALSE,OUTPUT cRetour).
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
    gcAideImprimer = "Imprimer la table sélectionnée".
    gcAideRaf = "Recharger les informations du dictionnaire".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Impression C-Win 
PROCEDURE Impression :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE VARIABLE cLigne AS CHARACTER NO-UNDO.

    /* Début de l'édition */
    RUN HTML_OuvreFichier("").
    RUN HTML_TitreEdition(brwchamps:TITLE IN FRAME frmmodule).
    
    RUN HTML_ChargeFormatCellule("E",0,"CF=gris,A=><,T=3").
    RUN HTML_ChargeFormatCellule("L",0,"A=<").
    RUN HTML_ChargeFormatCellule("L",1,"A=><").
    RUN HTML_ChargeFormatCellule("L",2,"A=><").
    RUN HTML_ChargeFormatCellule("L",4,"A=><").
    RUN HTML_ChargeFormatCellule("L",6,"A=><").
    
    /* Ecriture de l'entete pour le tableau des champs */
    cLigne = "" 
        + "Ordre"
        + devSeparateurEdition + "Nom"
        + devSeparateurEdition + "Label"
        + devSeparateurEdition + "Type"
        + devSeparateurEdition + "Format"
        + devSeparateurEdition + "Init."
        + devSeparateurEdition + "Description"
        .
    RUN HTML_DebutTableau(cLigne).
    
    /* Balayage de la table des champs */
    FOR EACH ttchamps
        WHERE ttchamps.ctable = tttables.cnom
        BY ttchamps.iOrdre :
        cLigne = "" 
            + string(ttchamps.iordre,"9999")
            + devSeparateurEdition + TRIM(ttchamps.cnom)
            + devSeparateurEdition + TRIM(ttchamps.clabel)
            + devSeparateurEdition + TRIM(ttchamps.ctype)
            + devSeparateurEdition + TRIM(ttchamps.cformat)
            + devSeparateurEdition + TRIM(ttchamps.cinitial)
            + devSeparateurEdition + TRIM(ttchamps.cremarque)
            .
        RUN HTML_LigneTableau(cLigne).
    END.
    
    /* Fin de l'édition des champs */
    RUN HTML_FinTableau.
    
    /* Pour que les 2 tableaux soient l'un au dessus de l'autre
       et non l'un à coté de l'autre */
    RUN HTML_LigneBlanche.

    RUN HTML_VideFormatCellule.

    RUN HTML_ChargeFormatCellule("E",0,"CF=gris,A=><,T=3").
    RUN HTML_ChargeFormatCellule("L",0,"A=<").
    RUN HTML_ChargeFormatCellule("L",1,"A=><").
    
    /* Ecriture de l'entete pour le tableau des indexes */
    cLigne = "" 
        + "Index"
        + devSeparateurEdition + "Description"
        .
    RUN HTML_DebutTableau(cLigne).
    
    /* Balayage de la table des champs */
    FOR EACH ttindexes
        WHERE ttindexes.ctable = tttables.cnom
        :
        cLigne = "" 
            + TRIM(ttindexes.cnom)
            + devSeparateurEdition + TRIM(ttindexes.cdescription)
            .
        RUN HTML_LigneTableau(cLigne).
    END.
    
    /* Fin de l'édition des champs */
    RUN HTML_FinTableau.

    RUN HTML_FinEdition.
    RUN HTML_FermeFichier.
    RUN gImpression.

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

    FRAME frmModule:COLUMN = gdPositionXModule.
    FRAME frmModule:ROW = gdPositionYModule.

    ENABLE ALL WITH FRAME frmModule.

    /* Uniquement sur demande */
    IF lChargeTables THEN DO:
        /* Chargement */
        RUN ChargeTables.
    
        /* Ouverture du qurey */  
        RUN OuvreQueryTables.
    
        DO WITH FRAME frmModule:
            APPLY "VALUE-CHANGED" TO brwTables.
            brwTables:READ-ONLY = TRUE.
            /*brwChamps:READ-ONLY = TRUE.*/
            ttChamps.iordre:READ-ONLY IN BROWSE brwChamps = TRUE.
            btnppapier:LOAD-IMAGE(gcRepertoireRessources + "fleche02.jpg").
            btnppapier:MOVE-TO-TOP().
        END.
    END.
    
    /* On indique que les types sont déjà chargés */
    lChargeTables = FALSE.

    /* se positionner dans la zone de saisie */
    APPLY "ENTRY" TO txtrecherche IN FRAME frmmodule.

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OuvreQueryChamps C-Win 
PROCEDURE OuvreQueryChamps :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    IF cTri = "Ordre" THEN DO:
        OPEN QUERY brwChamps FOR EACH ttChamps WHERE ttchamps.ctable = tttables.cnom BY ttchamps.iordre.
    END.
        
    IF cTri = "Nom" THEN DO:
        OPEN QUERY brwChamps FOR EACH ttChamps WHERE ttchamps.ctable = tttables.cnom BY ttchamps.cNom.
    END.
        
    IF cTri = "Label" THEN DO:
        OPEN QUERY brwChamps FOR EACH ttChamps WHERE ttchamps.ctable = tttables.cnom BY ttchamps.cLabel.
    END.
        
    IF cTri = "Type" THEN DO:
        OPEN QUERY brwChamps FOR EACH ttChamps WHERE ttchamps.ctable = tttables.cnom BY ttchamps.cType.
    END.
        
    IF cTri = "format" THEN DO:
        OPEN QUERY brwChamps FOR EACH ttChamps WHERE ttchamps.ctable = tttables.cnom BY ttchamps.cFormat.
    END.
        
    IF cTri = "init." THEN DO:
        OPEN QUERY brwChamps FOR EACH ttChamps WHERE ttchamps.ctable = tttables.cnom BY ttchamps.cInitial.
    END.
        
   
    IF cTri = "Description" THEN DO:
        OPEN QUERY brwChamps FOR EACH ttChamps WHERE ttchamps.ctable = tttables.cnom BY ttchamps.cRemarque.
    END.
        
   

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OuvreQueryTables C-Win 
PROCEDURE OuvreQueryTables :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    OPEN QUERY brwTables FOR EACH ttTables.
    brwTables:REFRESH() IN FRAME frmModule.
    
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
    lChargeTables = TRUE. /* Pour forcer le rechargement des tables */
    RUN Initialisation.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Saisie C-Win 
PROCEDURE Saisie :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER cModeRecherche AS CHARACTER NO-UNDO.

    DEFINE VARIABLE iPosition AS INTEGER NO-UNDO.

    DO WITH FRAME frmModule:
        
        IF cModeRecherche = "" THEN DO:
            FIND FIRST ttChamps
                WHERE ttchamps.ctable = tttables.cnom
                AND   (ttChamps.cNom MATCHES "*" + filTypeLibelle:SCREEN-VALUE + "*"
                OR    ttChamps.cLabel MATCHES "*" + filTypeLibelle:SCREEN-VALUE + "*")
                NO-ERROR.
        END.
        ELSE IF cModeRecherche = "NEXT" THEN DO:
            FIND NEXT ttChamps
                WHERE ttchamps.ctable = tttables.cnom
                AND   (ttChamps.cNom MATCHES "*" + filTypeLibelle:SCREEN-VALUE + "*"
                OR    ttChamps.cLabel MATCHES "*" + filTypeLibelle:SCREEN-VALUE + "*")
                NO-ERROR.
        END.
        ELSE DO:
            FIND PREV ttChamps
                WHERE ttchamps.ctable = tttables.cnom
                AND   (ttChamps.cNom MATCHES "*" + filTypeLibelle:SCREEN-VALUE + "*"
                OR    ttChamps.cLabel MATCHES "*" + filTypeLibelle:SCREEN-VALUE + "*")
                NO-ERROR.
        END.
        IF AVAILABLE(ttChamps) THEN do:
            REPOSITION brwChamps TO ROWID ROWID(ttChamps).
        END.
        ELSE DO:
            BELL.
        END.
    END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Saisie2 C-Win 
PROCEDURE Saisie2 :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER cModeRecherche AS CHARACTER NO-UNDO.

    DEFINE VARIABLE iPosition AS INTEGER NO-UNDO.

    DO WITH FRAME frmModule:
        
        IF cModeRecherche = "" THEN DO:
            FIND FIRST tttables
                WHERE (tttables.cNom MATCHES "*" + txtRecherche:SCREEN-VALUE + "*")
                NO-ERROR.
        END.
        ELSE IF cModeRecherche = "NEXT" THEN DO:
            FIND NEXT tttables
                WHERE (tttables.cNom MATCHES "*" + txtRecherche:SCREEN-VALUE + "*")
                NO-ERROR.
        END.
        ELSE DO:
            FIND PREV tttables
                WHERE (tttables.cNom MATCHES "*" + txtRecherche:SCREEN-VALUE + "*")
                NO-ERROR.
        END.
        IF AVAILABLE(tttables) THEN do:
            REPOSITION brwTables TO ROWID ROWID(tttables).
            APPLY "VALUE-CHANGED" TO brwtables IN FRAME frmmodule.
        END.
        ELSE DO:
            BELL.
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

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION DonneFormatChamp C-Win 
FUNCTION DonneFormatChamp RETURNS CHARACTER
  ( cNomChamp AS character, cFormatInitial AS CHARACTER ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
  DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO.  

  /* Par défaut, le format issu de la base est correct */
  cRetour = cFormatInitial. 

  /* Sauf... */
  IF cNomChamp = "soc-cd" THEN cRetour = "99999".
  IF cNomChamp = "etab-cd" THEN cRetour = "99999".

  RETURN cRetour.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

