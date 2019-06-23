&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME c-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS c-Win 
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

DEFINE TEMP-TABLE ttRepertoires
    FIELD cRepertoire AS CHARACTER
    FIELD cNom   AS CHARACTER

    INDEX ttRepertoires01 IS PRIMARY cNom 
    .


DEFINE TEMP-TABLE ttFichiers
    FIELD cRepertoire AS CHARACTER
    FIELD cNom   AS CHARACTER

    INDEX ttFichiers01 IS PRIMARY cNom 
    .

DEFINE TEMP-TABLE ttDocuments
    FIELD cRepertoire AS CHARACTER
    FIELD cNom   AS CHARACTER

    INDEX ttDocuments01 IS PRIMARY cNom 
    .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME frmFonction
&Scoped-define BROWSE-NAME brwDocuments

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ttDocuments ttFichiers ttRepertoires

/* Definitions for BROWSE brwDocuments                                  */
&Scoped-define FIELDS-IN-QUERY-brwDocuments ttDocuments.cNom   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brwDocuments   
&Scoped-define SELF-NAME brwDocuments
&Scoped-define QUERY-STRING-brwDocuments FOR EACH ttDocuments     WHERE (tglDocuments:CHECKED = FALSE OR ttDocuments.cRepertoire = ttRepertoires.cRepertoire + "\")
&Scoped-define OPEN-QUERY-brwDocuments OPEN QUERY {&SELF-NAME} FOR EACH ttDocuments     WHERE (tglDocuments:CHECKED = FALSE OR ttDocuments.cRepertoire = ttRepertoires.cRepertoire + "\").
&Scoped-define TABLES-IN-QUERY-brwDocuments ttDocuments
&Scoped-define FIRST-TABLE-IN-QUERY-brwDocuments ttDocuments


/* Definitions for BROWSE brwFichiers                                   */
&Scoped-define FIELDS-IN-QUERY-brwFichiers ttFichiers.cNom   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brwFichiers   
&Scoped-define SELF-NAME brwFichiers
&Scoped-define QUERY-STRING-brwFichiers FOR EACH ttFichiers     WHERE (tglProjets:CHECKED = FALSE OR ttFichiers.cRepertoire = ttRepertoires.cRepertoire + "\")
&Scoped-define OPEN-QUERY-brwFichiers OPEN QUERY {&SELF-NAME} FOR EACH ttFichiers     WHERE (tglProjets:CHECKED = FALSE OR ttFichiers.cRepertoire = ttRepertoires.cRepertoire + "\").
&Scoped-define TABLES-IN-QUERY-brwFichiers ttFichiers
&Scoped-define FIRST-TABLE-IN-QUERY-brwFichiers ttFichiers


/* Definitions for BROWSE brwRepertoires                                */
&Scoped-define FIELDS-IN-QUERY-brwRepertoires ttRepertoires.cNom   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brwRepertoires   
&Scoped-define SELF-NAME brwRepertoires
&Scoped-define QUERY-STRING-brwRepertoires FOR EACH ttRepertoires
&Scoped-define OPEN-QUERY-brwRepertoires OPEN QUERY {&SELF-NAME} FOR EACH ttRepertoires.
&Scoped-define TABLES-IN-QUERY-brwRepertoires ttRepertoires
&Scoped-define FIRST-TABLE-IN-QUERY-brwRepertoires ttRepertoires


/* Definitions for FRAME frmFonction                                    */
&Scoped-define OPEN-BROWSERS-IN-QUERY-frmFonction ~
    ~{&OPEN-QUERY-brwDocuments}~
    ~{&OPEN-QUERY-brwFichiers}~
    ~{&OPEN-QUERY-brwRepertoires}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS filRechercheFichier btnFichierPrecedent ~
btnFichierSuivant filRechercheRepertoire btnRepertoirePrecedent ~
btnRepertoireSuivant brwFichiers brwRepertoires filRechercheDocument ~
btnDocumentPrecedent btnDocumentSuivant brwDocuments tglProjets ~
tgldocuments 
&Scoped-Define DISPLAYED-OBJECTS filRechercheFichier filRechercheRepertoire ~
filRechercheDocument tglProjets tgldocuments 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR c-Win AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON btnDocumentPrecedent 
     LABEL "<" 
     SIZE-PIXELS 20 BY 20 TOOLTIP "Rechercher le précédent".

DEFINE BUTTON btnDocumentSuivant  NO-CONVERT-3D-COLORS
     LABEL ">" 
     SIZE-PIXELS 20 BY 20 TOOLTIP "Rechercher le suivant".

DEFINE BUTTON btnFichierPrecedent 
     LABEL "<" 
     SIZE-PIXELS 20 BY 20 TOOLTIP "Rechercher le précédent".

DEFINE BUTTON btnFichierSuivant  NO-CONVERT-3D-COLORS
     LABEL ">" 
     SIZE-PIXELS 20 BY 20 TOOLTIP "Rechercher le suivant".

DEFINE BUTTON btnRepertoirePrecedent 
     LABEL "<" 
     SIZE-PIXELS 20 BY 20 TOOLTIP "Rechercher le précédent".

DEFINE BUTTON btnRepertoireSuivant  NO-CONVERT-3D-COLORS
     LABEL ">" 
     SIZE-PIXELS 20 BY 20 TOOLTIP "Rechercher le suivant".

DEFINE VARIABLE filRechercheDocument AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE-PIXELS 479 BY 20
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE filRechercheFichier AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE-PIXELS 228 BY 20
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE filRechercheRepertoire AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE-PIXELS 479 BY 20
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE tgldocuments AS LOGICAL INITIAL no 
     LABEL "Voir uniquement les documents du répertoire actif" 
     VIEW-AS TOGGLE-BOX
     SIZE 58.4 BY .67 NO-UNDO.

DEFINE VARIABLE tglProjets AS LOGICAL INITIAL no 
     LABEL "Voir uniquement les projets du répertoire actif" 
     VIEW-AS TOGGLE-BOX
     SIZE 54.8 BY .67 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brwDocuments FOR 
      ttDocuments SCROLLING.

DEFINE QUERY brwFichiers FOR 
      ttFichiers SCROLLING.

DEFINE QUERY brwRepertoires FOR 
      ttRepertoires SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brwDocuments
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brwDocuments c-Win _FREEFORM
  QUERY brwDocuments DISPLAY
      ttDocuments.cNom FORMAT "x(255)" LABEL "Nom du document"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 104.6 BY 7.57
         TITLE "Documents" ROW-HEIGHT-CHARS .76 FIT-LAST-COLUMN TOOLTIP "Liste des documents/ Clique droit pour paramètrer".

DEFINE BROWSE brwFichiers
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brwFichiers c-Win _FREEFORM
  QUERY brwFichiers DISPLAY
      ttFichiers.cNom FORMAT "x(255)" LABEL "Nom du projet"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 55.2 BY 16.81
         TITLE "Fichiers de projet" ROW-HEIGHT-CHARS .76 FIT-LAST-COLUMN TOOLTIP "Liste des projets / Clique droit pour paramètrer".

DEFINE BROWSE brwRepertoires
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brwRepertoires c-Win _FREEFORM
  QUERY brwRepertoires DISPLAY
      ttRepertoires.cNom FORMAT "x(255)" LABEL "Répertoire de projet"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 104.8 BY 7.95
         TITLE "Répertoires de projet" ROW-HEIGHT-CHARS .71 FIT-LAST-COLUMN TOOLTIP "Liste des répertoires de projets / Clique droit pour paramètrer".


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME frmModule
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 166.2 BY 20.62
         BGCOLOR 7 
         TITLE BGCOLOR 2 FGCOLOR 15 "Projets".

DEFINE FRAME frmFonction
     filRechercheFichier AT Y 3 X 537 NO-LABEL
     btnFichierPrecedent AT Y 3 X 768
     btnFichierSuivant AT Y 3 X 789
     filRechercheRepertoire AT Y 5 X 5 NO-LABEL
     btnRepertoirePrecedent AT Y 5 X 487
     btnRepertoireSuivant AT Y 5 X 508
     brwFichiers AT ROW 2.19 COL 108.6
     brwRepertoires AT ROW 2.29 COL 2
     filRechercheDocument AT Y 198 X 6 NO-LABEL
     btnDocumentPrecedent AT Y 198 X 486
     btnDocumentSuivant AT Y 198 X 507
     brwDocuments AT ROW 11.48 COL 2.2
     tglProjets AT ROW 19.1 COL 108.8
     tgldocuments AT ROW 19.14 COL 2.4
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 2 ROW 1.24
         SIZE 164 BY 19.05.


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
  CREATE WINDOW c-Win ASSIGN
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
/* SETTINGS FOR WINDOW c-Win
  NOT-VISIBLE,,RUN-PERSISTENT                                           */
/* REPARENT FRAME */
ASSIGN FRAME frmFonction:FRAME = FRAME frmModule:HANDLE.

/* SETTINGS FOR FRAME frmFonction
   FRAME-NAME                                                           */
/* BROWSE-TAB brwFichiers btnRepertoireSuivant frmFonction */
/* BROWSE-TAB brwRepertoires brwFichiers frmFonction */
/* BROWSE-TAB brwDocuments btnDocumentSuivant frmFonction */
ASSIGN 
       btnDocumentSuivant:AUTO-RESIZE IN FRAME frmFonction      = TRUE.

ASSIGN 
       btnFichierSuivant:AUTO-RESIZE IN FRAME frmFonction      = TRUE.

ASSIGN 
       btnRepertoireSuivant:AUTO-RESIZE IN FRAME frmFonction      = TRUE.

/* SETTINGS FOR FILL-IN filRechercheDocument IN FRAME frmFonction
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN filRechercheFichier IN FRAME frmFonction
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN filRechercheRepertoire IN FRAME frmFonction
   ALIGN-L                                                              */
/* SETTINGS FOR FRAME frmModule
                                                                        */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(c-Win)
THEN c-Win:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brwDocuments
/* Query rebuild information for BROWSE brwDocuments
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH ttDocuments
    WHERE (tglDocuments:CHECKED = FALSE OR ttDocuments.cRepertoire = ttRepertoires.cRepertoire + "\").
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE brwDocuments */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brwFichiers
/* Query rebuild information for BROWSE brwFichiers
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH ttFichiers
    WHERE (tglProjets:CHECKED = FALSE OR ttFichiers.cRepertoire = ttRepertoires.cRepertoire + "\").
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE brwFichiers */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brwRepertoires
/* Query rebuild information for BROWSE brwRepertoires
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH ttRepertoires.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE brwRepertoires */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME c-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-Win c-Win
ON END-ERROR OF c-Win /* <insert window title> */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-Win c-Win
ON WINDOW-CLOSE OF c-Win /* <insert window title> */
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brwDocuments
&Scoped-define SELF-NAME brwDocuments
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwDocuments c-Win
ON DEFAULT-ACTION OF brwDocuments IN FRAME frmFonction /* Documents */
DO:
    OS-COMMAND NO-WAIT VALUE(gcRepertoireRessourcesPrivees + "\scripts\general\execute.bat ~"" + ttDocuments.crepertoire + ttDocuments.cnom + "~"").
    /* sauvegarde du dernier utilisé */
    SauvePreference("PROJETS_DERNIER_DOCUMENT",ttDocuments.crepertoire + "|" + ttDocuments.cnom).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwDocuments c-Win
ON LEFT-MOUSE-CLICK OF brwDocuments IN FRAME frmFonction /* Documents */
DO:
  APPLY "VALUE-CHANGED" TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwDocuments c-Win
ON RIGHT-MOUSE-CLICK OF brwDocuments IN FRAME frmFonction /* Documents */
DO:
    RUN DonnePositionMessage IN ghGeneral.
    gcAllerRetour = STRING(giPosXMessage)
        + "|" + STRING(giPosYMessage)
        + "|" + "Répertoire 'père' des projets"
        + "|" + DonnePreference("PROJETS_REPERTOIRE_PERE").
    RUN VALUE(gcRepertoireExecution + "saisie2.w") (INPUT-OUTPUT gcAllerRetour).
    IF gcAllerRetour = "" THEN RETURN.
    SauvePreference("PROJETS_REPERTOIRE_PERE",ENTRY(4,gcAllerRetour,"|")).
    RUN Initialisation.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwDocuments c-Win
ON VALUE-CHANGED OF brwDocuments IN FRAME frmFonction /* Documents */
DO:
  FIND FIRST ttRepertoires
      WHERE ttRepertoires.cRepertoire = substring(ttDocuments.cRepertoire,1,LENGTH(ttDocuments.cRepertoire) - 1)
      NO-ERROR.

  IF AVAILABLE(ttRepertoires) THEN do:
      REPOSITION brwRepertoires TO ROWID ROWID(ttRepertoires) NO-ERROR.
  END.

  FIND FIRST ttFichiers
      WHERE ttDocuments.cRepertoire = ttFichiers.cRepertoire
      NO-ERROR.

  IF AVAILABLE(ttFichiers) THEN do:
      REPOSITION brwFichiers TO ROWID ROWID(ttFichiers) NO-ERROR.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brwFichiers
&Scoped-define SELF-NAME brwFichiers
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwFichiers c-Win
ON DEFAULT-ACTION OF brwFichiers IN FRAME frmFonction /* Fichiers de projet */
DO:
    OS-COMMAND NO-WAIT VALUE(gcRepertoireRessourcesPrivees + "\scripts\general\execute.bat ~"" + ttFichiers.crepertoire + ttFichiers.cnom + "~"").
    /* sauvegarde du dernier utilisé */
    SauvePreference("PROJETS_DERNIER_FICHIER",ttfichiers.crepertoire + "|" + ttfichiers.cnom).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwFichiers c-Win
ON LEFT-MOUSE-CLICK OF brwFichiers IN FRAME frmFonction /* Fichiers de projet */
DO:
  
    APPLY "VALUE-CHANGED" TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwFichiers c-Win
ON RIGHT-MOUSE-CLICK OF brwFichiers IN FRAME frmFonction /* Fichiers de projet */
DO:
    RUN DonnePositionMessage IN ghGeneral.
    gcAllerRetour = STRING(giPosXMessage)
        + "|" + STRING(giPosYMessage)
        + "|" + "Répertoire 'père' des projets"
        + "|" + DonnePreference("PROJETS_REPERTOIRE_PERE").
    RUN VALUE(gcRepertoireExecution + "saisie2.w") (INPUT-OUTPUT gcAllerRetour).
    IF gcAllerRetour = "" THEN RETURN.
    SauvePreference("PROJETS_REPERTOIRE_PERE",ENTRY(4,gcAllerRetour,"|")).
    RUN Initialisation.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwFichiers c-Win
ON VALUE-CHANGED OF brwFichiers IN FRAME frmFonction /* Fichiers de projet */
DO:
  FIND FIRST ttRepertoires
      WHERE ttRepertoires.crepertoire = substring(ttFichiers.cRepertoire,1,LENGTH(ttFichiers.cRepertoire) - 1)
      NO-ERROR.

  IF AVAILABLE(ttRepertoires) THEN do:
      REPOSITION brwRepertoires TO ROWID ROWID(ttRepertoires) NO-ERROR.
  END.

  IF tglDocuments:CHECKED THEN {&OPEN-QUERY-brwDocuments}
  FIND FIRST ttDocuments
      WHERE ttDocuments.cRepertoire = ttFichiers.cRepertoire
      NO-ERROR.

  IF AVAILABLE(ttDocuments) THEN do:
      REPOSITION brwDocuments TO ROWID ROWID(ttDocuments) NO-ERROR.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brwRepertoires
&Scoped-define SELF-NAME brwRepertoires
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwRepertoires c-Win
ON DEFAULT-ACTION OF brwRepertoires IN FRAME frmFonction /* Répertoires de projet */
DO:
    OS-COMMAND SILENT value("explorer.exe ~"" +  ttrepertoires.cRepertoire + "~"").
    /* sauvegarde du dernier utilisé */
    SauvePreference("PROJETS_DERNIER_REPERTOIRE",ttrepertoires.cRepertoire).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwRepertoires c-Win
ON LEFT-MOUSE-CLICK OF brwRepertoires IN FRAME frmFonction /* Répertoires de projet */
DO:
  
    APPLY "VALUE-CHANGED" TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwRepertoires c-Win
ON RIGHT-MOUSE-CLICK OF brwRepertoires IN FRAME frmFonction /* Répertoires de projet */
DO:
    RUN DonnePositionMessage IN ghGeneral.
    gcAllerRetour = STRING(giPosXMessage)
        + "|" + STRING(giPosYMessage)
        + "|" + "Répertoire 'père' des projets"
        + "|" + DonnePreference("PROJETS_REPERTOIRE_PERE").
    RUN VALUE(gcRepertoireExecution + "saisie2.w") (INPUT-OUTPUT gcAllerRetour).
    IF gcAllerRetour = "" THEN RETURN.
    SauvePreference("PROJETS_REPERTOIRE_PERE",ENTRY(4,gcAllerRetour,"|")).
    RUN Initialisation.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwRepertoires c-Win
ON VALUE-CHANGED OF brwRepertoires IN FRAME frmFonction /* Répertoires de projet */
DO:

    IF tglProjets:CHECKED THEN {&OPEN-QUERY-brwFichiers}
    FIND FIRST ttFichiers
        WHERE substring(ttFichiers.cRepertoire,1,LENGTH(ttFichiers.cRepertoire) - 1) = ttRepertoires.cRepertoire
        NO-ERROR.

    IF AVAILABLE(ttFichiers) THEN do:
        REPOSITION brwFichiers TO ROWID ROWID(ttFichiers) NO-ERROR.
    END.
    IF tglDocuments:CHECKED THEN {&OPEN-QUERY-brwDocuments}
    FIND FIRST ttDocuments
        WHERE substring(ttDocuments.cRepertoire,1,LENGTH(ttDocuments.cRepertoire) - 1) = ttRepertoires.cRepertoire
        NO-ERROR.

    IF AVAILABLE(ttDocuments) THEN do:
        REPOSITION brwDocuments TO ROWID ROWID(ttDocuments) NO-ERROR.
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnDocumentPrecedent
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnDocumentPrecedent c-Win
ON CHOOSE OF btnDocumentPrecedent IN FRAME frmFonction /* < */
DO:
  
    RUN SaisieRecherche3 ("PREV").

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnDocumentSuivant
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnDocumentSuivant c-Win
ON CHOOSE OF btnDocumentSuivant IN FRAME frmFonction /* > */
DO:
    
    RUN SaisieRecherche3 ("NEXT").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnFichierPrecedent
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnFichierPrecedent c-Win
ON CHOOSE OF btnFichierPrecedent IN FRAME frmFonction /* < */
DO:
  
    RUN SaisieRecherche2 ("PREV").

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnFichierSuivant
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnFichierSuivant c-Win
ON CHOOSE OF btnFichierSuivant IN FRAME frmFonction /* > */
DO:
    
    RUN SaisieRecherche2 ("NEXT").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnRepertoirePrecedent
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnRepertoirePrecedent c-Win
ON CHOOSE OF btnRepertoirePrecedent IN FRAME frmFonction /* < */
DO:
  
    RUN SaisieRecherche ("PREV").

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnRepertoireSuivant
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnRepertoireSuivant c-Win
ON CHOOSE OF btnRepertoireSuivant IN FRAME frmFonction /* > */
DO:
    
    RUN SaisieRecherche ("NEXT").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filRechercheDocument
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filRechercheDocument c-Win
ON ANY-PRINTABLE OF filRechercheDocument IN FRAME frmFonction
DO:  
    APPLY  LAST-KEY TO SELF.
    RUN SaisieRecherche3 ("").
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filRechercheDocument c-Win
ON BACKSPACE OF filRechercheDocument IN FRAME frmFonction
DO:
    APPLY  LAST-KEY TO SELF.
    RUN SaisieRecherche2 ("").
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filRechercheDocument c-Win
ON DELETE-CHARACTER OF filRechercheDocument IN FRAME frmFonction
DO:
    APPLY  LAST-KEY TO SELF.
    RUN SaisieRecherche2 ("").
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filRechercheDocument c-Win
ON RETURN OF filRechercheDocument IN FRAME frmFonction
DO:
    APPLY  LAST-KEY TO SELF.
    RUN SaisieRecherche2 ("").
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filRechercheFichier
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filRechercheFichier c-Win
ON ANY-PRINTABLE OF filRechercheFichier IN FRAME frmFonction
DO:  
    APPLY  LAST-KEY TO SELF.
    RUN SaisieRecherche2 ("").
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filRechercheFichier c-Win
ON BACKSPACE OF filRechercheFichier IN FRAME frmFonction
DO:
    APPLY  LAST-KEY TO SELF.
    RUN SaisieRecherche2 ("").
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filRechercheFichier c-Win
ON DELETE-CHARACTER OF filRechercheFichier IN FRAME frmFonction
DO:
    APPLY  LAST-KEY TO SELF.
    RUN SaisieRecherche2 ("").
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filRechercheFichier c-Win
ON RETURN OF filRechercheFichier IN FRAME frmFonction
DO:
    APPLY  LAST-KEY TO SELF.
    RUN SaisieRecherche2 ("").
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filRechercheRepertoire
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filRechercheRepertoire c-Win
ON ANY-PRINTABLE OF filRechercheRepertoire IN FRAME frmFonction
DO:  
    APPLY  LAST-KEY TO SELF.
    RUN SaisieRecherche ("").
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filRechercheRepertoire c-Win
ON BACKSPACE OF filRechercheRepertoire IN FRAME frmFonction
DO:
    APPLY  LAST-KEY TO SELF.
    RUN SaisieRecherche ("").
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filRechercheRepertoire c-Win
ON DELETE-CHARACTER OF filRechercheRepertoire IN FRAME frmFonction
DO:
    APPLY  LAST-KEY TO SELF.
    RUN SaisieRecherche ("").
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filRechercheRepertoire c-Win
ON RETURN OF filRechercheRepertoire IN FRAME frmFonction
DO:
    APPLY  LAST-KEY TO SELF.
    RUN SaisieRecherche ("").
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tgldocuments
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tgldocuments c-Win
ON VALUE-CHANGED OF tgldocuments IN FRAME frmFonction /* Voir uniquement les documents du répertoire actif */
DO:
  SauvePreference("PROJETS_DOCUMENTS_REPERTOIRE",STRING(tglDocuments:CHECKED)).

  {&OPEN-QUERY-brwDocuments}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglProjets
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglProjets c-Win
ON VALUE-CHANGED OF tglProjets IN FRAME frmFonction /* Voir uniquement les projets du répertoire actif */
DO:
  
    SauvePreference("PROJETS_PROJETS_REPERTOIRE",STRING(tglProjets:CHECKED)).

    {&OPEN-QUERY-brwFichiers}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brwDocuments
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK c-Win 


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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI c-Win  _DEFAULT-DISABLE
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
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(c-Win)
  THEN DELETE WIDGET c-Win.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE DonneOrdre c-Win 
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI c-Win  _DEFAULT-ENABLE
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
  VIEW FRAME frmModule IN WINDOW c-Win.
  {&OPEN-BROWSERS-IN-QUERY-frmModule}
  DISPLAY filRechercheFichier filRechercheRepertoire filRechercheDocument 
          tglProjets tgldocuments 
      WITH FRAME frmFonction IN WINDOW c-Win.
  ENABLE filRechercheFichier btnFichierPrecedent btnFichierSuivant 
         filRechercheRepertoire btnRepertoirePrecedent btnRepertoireSuivant 
         brwFichiers brwRepertoires filRechercheDocument btnDocumentPrecedent 
         btnDocumentSuivant brwDocuments tglProjets tgldocuments 
      WITH FRAME frmFonction IN WINDOW c-Win.
  {&OPEN-BROWSERS-IN-QUERY-frmFonction}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ExecuteOrdre c-Win 
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
                APPLY "ENTRY" TO filRechercheFichier IN FRAME frmFonction.
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE GereBoutons c-Win 
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
    gcAideRaf = "Recharger la liste des Projets".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Initialisation c-Win 
PROCEDURE Initialisation :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE cLigne AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cTempo AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cListeFiltres AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cFiltre AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lDocumentOK AS LOGICAL NO-UNDO.
    
    FRAME frmModule:COLUMN = gdPositionXModule.
    FRAME frmModule:ROW = gdPositionYModule.
    
    /* Chargement des repertoires */
    IF DonnePreference("PROJETS_REPERTOIRE_PERE") <> "" THEN DO:
        OS-COMMAND SILENT VALUE(gcRepertoireRessourcesPrivees + "\scripts\general\ListeR.bat ~"" + DonnePreference("PROJETS_REPERTOIRE_PERE") + "~" ~"" + gcRepertoireTempo + "~"").
        INPUT FROM VALUE(gcRepertoireTempo + "listeR.txt") CONVERT SOURCE "ibm850".
        EMPTY TEMP-TABLE ttRepertoires.
        REPEAT:
            IMPORT UNFORMATTED cLigne.
            IF cLigne = ""  THEN NEXT.
            CREATE ttRepertoires.
            ttRepertoires.cRepertoire =cLigne.
            ttRepertoires.cNom = replace(cLigne,DonnePreference("PROJETS_REPERTOIRE_PERE") + "\","").
        END.
        INPUT CLOSE.
    END.

    /* Chargement des Fichiers */
    IF DonnePreference("PROJETS_REPERTOIRE_PERE") <> "" THEN DO:
        OS-COMMAND SILENT VALUE(gcRepertoireRessourcesPrivees + "\scripts\general\ListeF.bat ~"" + DonnePreference("PROJETS_REPERTOIRE_PERE") + "~" ~"" + gcRepertoireTempo + "~" " + "*.prj").
        INPUT FROM VALUE(gcRepertoireTempo + "listeF.txt") CONVERT SOURCE "ibm850".
        EMPTY TEMP-TABLE ttFichiers.
        REPEAT:
            IMPORT UNFORMATTED cLigne.
            IF cLigne = ""  THEN NEXT.
            CREATE ttFichiers.
            ttFichiers.cNom = entry(num-entries(cLigne,"\"),cLigne,"\").
            ttFichiers.cRepertoire = replace(cLigne,ttFichiers.cNom,"").
        END.
        INPUT CLOSE.
    END.

    /* Chargement des documents */
    IF DonnePreference("PROJETS_REPERTOIRE_PERE") <> "" THEN DO:
        cListeFiltres = DonnePreference("PREF-FILTRESPROJETS").
        OS-COMMAND SILENT VALUE(gcRepertoireRessourcesPrivees + "\scripts\general\ListeD.bat ~"" + DonnePreference("PROJETS_REPERTOIRE_PERE") + "~" ~"" + gcRepertoireTempo + "~" " + "*.*").
        INPUT FROM VALUE(gcRepertoireTempo + "listeD.txt") CONVERT SOURCE "ibm850".
        EMPTY TEMP-TABLE ttDocuments.
        REPEAT:
            IMPORT UNFORMATTED cLigne.
            IF cLigne = ""  THEN NEXT.
            cTempo = entry(num-entries(cLigne,"\"),cLigne,"\").
            lDocumentOK = FALSE.
            DO iBoucle = 1 TO NUM-ENTRIES(cListeFiltres):
                cFiltre = ENTRY(iBoucle,cListeFiltres).
                IF cTempo MATCHES cFiltre THEN lDocumentOK = TRUE.
            END.
            IF lDocumentOK = FALSE THEN NEXT.
            CREATE ttDocuments.
            ttDocuments.cNom = cTempo.
            ttDocuments.cRepertoire = replace(cLigne,ttDocuments.cNom,"").
        END.
    END.

    DO WITH FRAME frmFonction:
        tglDocuments:CHECKED = (DonnePreference("PROJETS_DOCUMENTS_REPERTOIRE") = "YES").
        tglProjets:CHECKED = (DonnePreference("PROJETS_PROJETS_REPERTOIRE") = "YES").
    END.

    /* ouverture du query */
    {&OPEN-QUERY-brwRepertoires}
    {&OPEN-QUERY-brwFichiers}
    {&OPEN-QUERY-brwDocuments}

    /* Positionnement sur les derniers utilisés */
    /*{includes\vidage.i ttRepertoires}*/
    cTempo = DonnePreference("PROJETS_DERNIER_REPERTOIRE").
    IF  cTempo <> "" THEN DO:
        FIND FIRST  ttRepertoires NO-LOCK
            WHERE   ttRepertoires.cRepertoire = cTempo
            NO-ERROR.
        IF AVAILABLE(ttRepertoires) THEN REPOSITION brwRepertoires TO ROWID ROWID(ttRepertoires) NO-ERROR.
    END.
    cTempo = DonnePreference("PROJETS_DERNIER_FICHIER").
    IF  cTempo <> "" THEN DO:
        FIND FIRST  ttFichiers NO-LOCK
            WHERE   ttFichiers.crepertoire = entry(1,cTempo,"|")
            and     ttFichiers.cnom = entry(2,cTempo,"|")
            NO-ERROR.
        IF AVAILABLE(ttFichiers) THEN REPOSITION brwFichiers TO ROWID ROWID(ttFichiers) NO-ERROR.
    END.
    cTempo = DonnePreference("PROJETS_DERNIER_DOCUMENT").
    IF  cTempo <> "" THEN DO:
        FIND FIRST  ttDocuments NO-LOCK
            WHERE   ttDocuments.crepertoire = entry(1,cTempo,"|")
            and     ttDocuments.cnom = entry(2,cTempo,"|")
            NO-ERROR.
        IF AVAILABLE(ttDocuments) THEN REPOSITION brwDocuments TO ROWID ROWID(ttDocuments) NO-ERROR.
    END.

    RUN TopChronoGeneral.
    RUN TopChronoPartiel.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MYenable_UI c-Win 
PROCEDURE MYenable_UI :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  VIEW FRAME frmModule IN WINDOW winGeneral.
    {&OPEN-BROWSERS-IN-QUERY-frmModule}
    HIDE c-win.
  ENABLE ALL WITH FRAME frmFonction.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Recharger c-Win 
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE SaisieRecherche c-Win 
PROCEDURE SaisieRecherche :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

DEFINE INPUT PARAMETER cModeRecherche AS CHARACTER NO-UNDO.

    DO WITH FRAME frmFonction:
        
        IF cModeRecherche = "" THEN DO:
            FIND FIRST ttRepertoires
                WHERE ttRepertoires.cnom MATCHES "*" + filRechercheRepertoire:SCREEN-VALUE + "*"
                NO-ERROR.
        END.
        ELSE IF cModeRecherche = "NEXT" THEN DO:
            FIND NEXT ttRepertoires
                WHERE ttRepertoires.cnom MATCHES "*" + filRechercheRepertoire:SCREEN-VALUE + "*"
                NO-ERROR.
        END.
        ELSE DO:
            FIND PREV ttRepertoires
                WHERE ttRepertoires.cnom MATCHES "*" + filRechercheRepertoire:SCREEN-VALUE + "*"
                NO-ERROR.
        END.
        IF AVAILABLE(ttRepertoires) THEN do:
            REPOSITION brwRepertoires TO ROWID ROWID(ttRepertoires) NO-ERROR.
        END.
        ELSE DO:
            BELL.
        END.
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE SaisieRecherche2 c-Win 
PROCEDURE SaisieRecherche2 :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

DEFINE INPUT PARAMETER cModeRecherche AS CHARACTER NO-UNDO.

    DO WITH FRAME frmFonction:
        
        IF cModeRecherche = "" THEN DO:
            FIND FIRST ttFichiers
                WHERE ttFichiers.cnom MATCHES "*" + filRechercheFichier:SCREEN-VALUE + "*"
                NO-ERROR.
        END.
        ELSE IF cModeRecherche = "NEXT" THEN DO:
            FIND NEXT ttFichiers
                WHERE ttFichiers.cnom MATCHES "*" + filRechercheFichier:SCREEN-VALUE + "*"
                NO-ERROR.
        END.
        ELSE DO:
            FIND PREV ttFichiers
                WHERE ttFichiers.cnom MATCHES "*" + filRechercheFichier:SCREEN-VALUE + "*"
                NO-ERROR.
        END.
        IF AVAILABLE(ttFichiers) THEN do:
            REPOSITION brwFichiers TO ROWID ROWID(ttFichiers) NO-ERROR.
        END.
        ELSE DO:
            BELL.
        END.
    END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE SaisieRecherche3 c-Win 
PROCEDURE SaisieRecherche3 :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

DEFINE INPUT PARAMETER cModeRecherche AS CHARACTER NO-UNDO.

    DO WITH FRAME frmFonction:
        
        IF cModeRecherche = "" THEN DO:
            FIND FIRST ttDocuments
                WHERE ttDocuments.cnom MATCHES "*" + filRechercheDocument:SCREEN-VALUE + "*"
                NO-ERROR.
        END.
        ELSE IF cModeRecherche = "NEXT" THEN DO:
            FIND NEXT ttDocuments
                WHERE ttDocuments.cnom MATCHES "*" + filRechercheDocument:SCREEN-VALUE + "*"
                NO-ERROR.
        END.
        ELSE DO:
            FIND PREV ttDocuments
                WHERE ttDocuments.cnom MATCHES "*" + filRechercheDocument:SCREEN-VALUE + "*"
                NO-ERROR.
        END.
        IF AVAILABLE(ttDocuments) THEN do:
            REPOSITION brwDocuments TO ROWID ROWID(ttDocuments) NO-ERROR.
        END.
        ELSE DO:
            BELL.
        END.
    END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE TopChronoGeneral c-Win 
PROCEDURE TopChronoGeneral :
/* Gestion du chrono général */
DEFINE VARIABLE cFichierBP AS CHARACTER NO-UNDO.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE TopChronoPartiel c-Win 
PROCEDURE TopChronoPartiel :
/* Gestion du chrono Partiel */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

