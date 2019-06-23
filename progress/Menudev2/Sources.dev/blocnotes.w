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
{includes\i_html.i}
{menudev2\includes\menudev2.i}

/* Parameters Definitions ---                                           */

DEFINE INPUT PARAMETER  winGeneral  AS HANDLE NO-UNDO.
DEFINE INPUT PARAMETER  cParametres AS CHARACTER NO-UNDO.

/* Local Variable Definitions ---                                       */
DEFINE VARIABLE cFichierNotes                   AS CHARACTER NO-UNDO.
DEFINE VARIABLE cFichierTempo                   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lChargementEnCours              AS LOGICAL INIT FALSE.
DEFINE VARIABLE lInitFaite                      AS LOGICAL NO-UNDO INIT FALSE.
DEFINE VARIABLE lPremiereRechercheDansCeSens    AS LOGICAL NO-UNDO INIT TRUE.
DEFINE VARIABLE cSensRechercheOld               AS CHARACTER NO-UNDO INIT "".
DEFINE VARIABLE lCreation                       AS LOGICAL NO-UNDO INIT FALSE.

DEFINE TEMP-TABLE ttNotes
    FIELD iOrdre AS INTEGER
    FIELD cIdentfichier AS CHARACTER
    FIELD cUtilisateur AS CHARACTER
    FIELD lPartagee AS LOGICAL

    INDEX cIdentfichier cIdentfichier
    .

DEFINE BUFFER bprefs FOR prefs.
    
DEFINE STREAM sEntree.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME frmModule
&Scoped-define BROWSE-NAME brwNotes

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ttnotes

/* Definitions for BROWSE brwNotes                                      */
&Scoped-define FIELDS-IN-QUERY-brwNotes ttnotes.cIdentFichier   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brwNotes   
&Scoped-define SELF-NAME brwNotes
&Scoped-define QUERY-STRING-brwNotes FOR EACH ttnotes
&Scoped-define OPEN-QUERY-brwNotes OPEN QUERY {&SELF-NAME} FOR EACH ttnotes.
&Scoped-define TABLES-IN-QUERY-brwNotes ttnotes
&Scoped-define FIRST-TABLE-IN-QUERY-brwNotes ttnotes

/* Definitions for FRAME frmModule                                      */
&Scoped-define OPEN-BROWSERS-IN-QUERY-frmModule ~
    ~{&OPEN-QUERY-brwNotes}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-1 filRecherche btnCodePrecedent ~
btnCodeSuivant edtnotes btnPecedent btnSuivant filSaisieRecherche brwNotes ~
tglPartage filremarque filInfos 
&Scoped-Define DISPLAYED-OBJECTS filRecherche edtnotes filSaisieRecherche ~
tglPartage filremarque filInfos 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD DonneContenu C-Win 
FUNCTION DonneContenu RETURNS CHARACTER
  ( cIdent-in AS CHARACTER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD DonneInfosNote C-Win 
FUNCTION DonneInfosNote RETURNS CHARACTER
  ( cIdent-in AS CHARACTER)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD DonneNomFichier C-Win 
FUNCTION DonneNomFichier RETURNS CHARACTER
  ( /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.

/* Menu Definitions                                                     */
DEFINE MENU POPUP-MENU-brwNotes 
       MENU-ITEM m_Renommer_la_note LABEL "Renommer la note"
       RULE
       MENU-ITEM m_Fermer_ce_menu LABEL "Fermer ce menu".

/* Definitions of the field level widgets                               */
DEFINE BUTTON btnCodePrecedent 
     LABEL "<" 
     SIZE-PIXELS 20 BY 20 TOOLTIP "Rechercher le précédent".

DEFINE BUTTON btnCodeSuivant  NO-CONVERT-3D-COLORS
     LABEL ">" 
     SIZE-PIXELS 20 BY 20 TOOLTIP "Rechercher le suivant".

DEFINE BUTTON btnPecedent 
     LABEL "<" 
     SIZE-PIXELS 20 BY 20 TOOLTIP "Rechercher le précédent".

DEFINE BUTTON btnSuivant  NO-CONVERT-3D-COLORS
     LABEL ">" 
     SIZE-PIXELS 20 BY 20 TOOLTIP "Rechercher le suivant".

DEFINE VARIABLE edtnotes AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 123.6 BY 16.67
     BGCOLOR 15 FONT 8 NO-UNDO.

DEFINE VARIABLE filInfos AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 86 BY .62 NO-UNDO.

DEFINE VARIABLE filRecherche AS CHARACTER FORMAT "X(256)":U 
     LABEL "Recherche" 
     VIEW-AS FILL-IN 
     SIZE 58 BY .95 NO-UNDO.

DEFINE VARIABLE filremarque AS CHARACTER FORMAT "X(256)":U INITIAL "Seules vos notes (partagées ou non) sont modifiables ou supprimables." 
      VIEW-AS TEXT 
     SIZE 83 BY .62
     FGCOLOR 12 FONT 6 NO-UNDO.

DEFINE VARIABLE filSaisieRecherche AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE-PIXELS 144 BY 20
     BGCOLOR 15  NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 165 BY 17.14
     BGCOLOR 7 .

DEFINE VARIABLE tglPartage AS LOGICAL INITIAL no 
     LABEL "Partager cette note avec les autres utilisateurs" 
     VIEW-AS TOGGLE-BOX
     SIZE 71 BY .57 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brwNotes FOR 
      ttnotes SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brwNotes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brwNotes C-Win _FREEFORM
  QUERY brwNotes DISPLAY
      ttnotes.cIdentFichier FORMAT "x(40)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-LABELS NO-ROW-MARKERS SEPARATORS SIZE 38 BY 15.48
         TITLE "Notes" FIT-LAST-COLUMN.

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME frmModule
     filRecherche AT ROW 1.24 COL 88.2 WIDGET-ID 26
     btnCodePrecedent AT Y 5 X 785 WIDGET-ID 22
     btnCodeSuivant AT Y 5 X 805 WIDGET-ID 24
     edtnotes AT ROW 2.67 COL 41 NO-LABEL WIDGET-ID 2
     btnPecedent AT Y 36 X 155 WIDGET-ID 34
     btnSuivant AT Y 36 X 176 WIDGET-ID 36
     filSaisieRecherche AT Y 37 X 6 NO-LABEL WIDGET-ID 38
     brwNotes AT ROW 3.86 COL 2 WIDGET-ID 100
     tglPartage AT ROW 19.81 COL 94 WIDGET-ID 8
     filremarque AT ROW 1.48 COL 2 NO-LABEL WIDGET-ID 30
     filInfos AT ROW 19.81 COL 2 NO-LABEL WIDGET-ID 10
     RECT-1 AT ROW 2.43 COL 1 WIDGET-ID 32
     WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 166 BY 20.6
         TITLE BGCOLOR 2 FGCOLOR 15 "Bloc Notes".

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
         HEIGHT             = 20.67
         WIDTH              = 166
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
/* BROWSE-TAB brwNotes filSaisieRecherche frmModule */
ASSIGN 
       brwNotes:POPUP-MENU IN FRAME frmModule             = MENU POPUP-MENU-brwNotes:HANDLE.

ASSIGN 
       btnCodeSuivant:AUTO-RESIZE IN FRAME frmModule      = TRUE.

ASSIGN 
       btnSuivant:AUTO-RESIZE IN FRAME frmModule      = TRUE.

/* SETTINGS FOR FILL-IN filInfos IN FRAME frmModule
   ALIGN-L                                                              */
ASSIGN 
       filInfos:READ-ONLY IN FRAME frmModule        = TRUE.

/* SETTINGS FOR FILL-IN filRecherche IN FRAME frmModule
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN filremarque IN FRAME frmModule
   ALIGN-L                                                              */
ASSIGN 
       filremarque:READ-ONLY IN FRAME frmModule        = TRUE.

/* SETTINGS FOR FILL-IN filSaisieRecherche IN FRAME frmModule
   ALIGN-L                                                              */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brwNotes
/* Query rebuild information for BROWSE brwNotes
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH ttnotes.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE brwNotes */
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

&Scoped-define BROWSE-NAME brwNotes
&Scoped-define SELF-NAME brwNotes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwNotes C-Win
ON VALUE-CHANGED OF brwNotes IN FRAME frmModule /* Notes */
DO:
    IF not(lChargementEnCours) THEN RUN ChangementOnglet.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&SCOPED-DEFINE SELF-NAME btnCodePrecedent
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnCodePrecedent C-Win
ON CHOOSE OF btnCodePrecedent IN FRAME frmModule /* < */
DO:
    RUN Recherche("PREC").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME btnCodeSuivant
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnCodeSuivant C-Win
ON CHOOSE OF btnCodeSuivant IN FRAME frmModule /* > */
DO:
    RUN Recherche("SUIV").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME btnPecedent
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnPecedent C-Win
ON CHOOSE OF btnPecedent IN FRAME frmModule /* < */
DO: 
    RUN RechercheTitre ("PREV").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME btnSuivant
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnSuivant C-Win
ON CHOOSE OF btnSuivant IN FRAME frmModule /* > */
DO:   
    RUN RechercheTitre ("NEXT").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME edtnotes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL edtnotes C-Win
ON CTRL-A OF edtnotes IN FRAME frmModule
DO:
  DO WITH FRAME frmModule:
      edtnotes:SET-SELECTION(1,LENGTH(edtnotes:SCREEN-VALUE) + 100) NO-ERROR.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL edtnotes C-Win
ON LEAVE OF edtnotes IN FRAME frmModule
DO:
  RUN Sauvegarde(cFichierNotes).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME filRecherche
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filRecherche C-Win
ON RETURN OF filRecherche IN FRAME frmModule /* Recherche */
DO:
  APPLY "CHOOSE" TO BtnCodeSuivant.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME filSaisieRecherche
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filSaisieRecherche C-Win
ON ANY-PRINTABLE OF filSaisieRecherche IN FRAME frmModule
DO:  
    APPLY  LAST-KEY TO SELF.
    RUN RechercheTitre ("").
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filSaisieRecherche C-Win
ON BACKSPACE OF filSaisieRecherche IN FRAME frmModule
DO:
    APPLY  LAST-KEY TO SELF.
    RUN RechercheTitre ("").
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filSaisieRecherche C-Win
ON DELETE-CHARACTER OF filSaisieRecherche IN FRAME frmModule
DO:
    APPLY  LAST-KEY TO SELF.
    RUN RechercheTitre ("").
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filSaisieRecherche C-Win
ON RETURN OF filSaisieRecherche IN FRAME frmModule
DO:
    APPLY  LAST-KEY TO SELF.
    RUN RechercheTitre ("").
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME m_Renommer_la_note
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Renommer_la_note C-Win
ON CHOOSE OF MENU-ITEM m_Renommer_la_note /* Renommer la note */
DO:
  DEFINE VARIABLE cFichierTempo AS CHARACTER NO-UNDO.
  DEFINE VARIABLE cidReference AS CHARACTER NO-UNDO.

  cidReference = STRING(TODAY,"99/99/9999") + "-" + STRING(TIME,"hh:mm:ss").

  REPEAT:
      /* Demande du nom de la note */
	    RUN DonnePositionMessage IN ghGeneral.
	    gcAllerRetour = STRING(giPosXMessage)
	        + "|" + STRING(giPosYMessage)
          + "|" + "Nom de la note"
          + "|" + entry(1,cFichierNotes,"[").
      RUN VALUE(gcRepertoireExecution + "saisie2.w") (INPUT-OUTPUT gcAllerRetour).
      IF gcAllerRetour = "" THEN RETURN.

      cFichierTempo = ENTRY(4,gcAllerRetour,"|").

      IF cFichierTempo MATCHES ("*[*") OR cFichierTempo MATCHES ("*]*") THEN DO:
          MESSAGE "Le nom d'une note ne peut pas contenir les caractères '[' ou ']' (Réservés pour les notes partagées) !!"
              VIEW-AS ALERT-BOX ERROR
              TITLE "Controle..."
              .
          /*RETURN.*/
          NEXT.
      END.

      /* La note existe peut-etre */
      FIND FIRST  fichiers    NO-LOCK
          WHERE   fichiers.cUtilisateur = gcUtilisateur
          AND     fichiers.cTypeFichier = "NOTES"
          AND     fichiers.cIdentFichier = cFichierTempo
          NO-ERROR.
      IF AVAILABLE(fichiers) THEN DO:
          MESSAGE "Une note à vous existe déjà avec ce nom. Création impossible !!"
              VIEW-AS ALERT-BOX ERROR
              TITLE "Controle..."
              .
          NEXT.
      END.

      /* La note existe peut-etre */
      FIND FIRST  fichiers    NO-LOCK
          WHERE   fichiers.cUtilisateur = gcUtilisateur
          AND     fichiers.cTypeFichier = "NOTES"
          AND     (num-entries(fichiers.cIdentFichier,"[") > 1 AND trim(entry(1,fichiers.cIdentFichier,"[")) = cFichierTempo)
          NO-ERROR.
      IF AVAILABLE(fichiers) THEN DO:
          MESSAGE "Une note partagée à vous existe déjà avec ce nom. Si vous conservez ce nom, il sera impossible d'activer le partage de cette note !!"
              + CHR(10) + "Voulez-vous conserver ce nom pour la note ?"
              VIEW-AS ALERT-BOX QUESTION BUTTON YES-NO
              TITLE "Controle..."
              UPDATE lReponse AS LOGICAL
              .
          IF lReponse THEN LEAVE.
          NEXT.
      END.

      /* Si on arrive ici, c'est que le nom est correct */
      LEAVE.
  END.
  /* Modification du fichier note */
  FIND FIRST    fichiers EXCLUSIVE-LOCK
      WHERE     fichiers.cUtilisateur = gcUtilisateur
      AND       fichiers.cTypeFichier = "NOTES"
      AND       fichiers.cIdentfichier = cFichierNotes
      NO-ERROR.
  IF AVAILABLE(fichiers) THEN DO:
    fichiers.cIdentfichier = cFichierTempo.
    fichiers.cModifieur = gcUtilisateur.
    fichiers.idModification = cidReference.
  END.

  release fichiers.

  /* Rechargement de la liste */ 
  RUN RenommeNote(cFichierTempo,tglPartage:CHECKED IN FRAME frmModule).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME tglPartage
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglPartage C-Win
ON VALUE-CHANGED OF tglPartage IN FRAME frmModule /* Partager cette note avec les autres utilisateurs */
DO:
 
    RUN RenommeNote(DonneNomFichier(),SELF:CHECKED).
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ChangementOnglet C-Win 
PROCEDURE ChangementOnglet :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE cTempo AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cInfosTempo AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cInfosCreateur AS CHARACTER NO-UNDO.
    
    DO WITH FRAME frmModule:

        /* Chargement de la note */        
        cFichierNotes = DonneNomFichier().
        
        /* Sauvegarde de la dernière note pour plus tard */
        SauvePreference("NOTES-DERNIERE",cFichierNotes).

        edtnotes:SCREEN-VALUE = DonneContenu(cFichierNotes).

        cTempo = "Dernière modification : %1 par %2".
        cInfosTempo = DonneInfosNote(cFichierNotes).
        
        cInfosCreateur = (IF num-entries(cInfosTempo) >= 3 THEN ENTRY(3,cInfosTempo) ELSE "").

        filInfos:SCREEN-VALUE = "".
        IF trim(replace(cInfosTempo,",","")) <> "" THEN DO:
            cTempo = REPLACE(cTempo,"%1",ENTRY(1,cInfosTempo)).
            cTempo = REPLACE(cTempo,"%2",ENTRY(2,cInfosTempo)).
            filInfos:SCREEN-VALUE = cTempo.
        END.

        IF cFichierNotes = "notes" THEN DO:
            tglPartage:CHECKED = FALSE.
            tglPartage:SENSITIVE = FALSE.
        END.
        ELSE DO:
            tglPartage:CHECKED = cFichiernotes MATCHES ("*[*").

            /* Droit d'activation/Désactivation du partage */
            IF tglPartage:CHECKED THEN DO:
                /* Interdit si une note non partagée porte le même nom */
                FIND FIRST  fichiers    NO-LOCK
                    WHERE   fichiers.cUtilisateur = gcUtilisateur
                    AND     fichiers.cTypeFichier = "NOTES"
                    AND     fichiers.cIdentFichier = trim(entry(1,cFichiernotes,"["))
                    NO-ERROR.
            END.
            ELSE DO:
                /* Interdit si une note partagée porte le même nom */
                FIND FIRST  fichiers    NO-LOCK
                    WHERE   fichiers.cUtilisateur = gcUtilisateur
                    AND     fichiers.cTypeFichier = "NOTES"
                    AND     (num-entries(fichiers.cIdentFichier,"[") > 1 AND trim(entry(1,fichiers.cIdentFichier,"[")) = cFichiernotes)
                    NO-ERROR.
            END.

            tglPartage:SENSITIVE = ((cInfosCreateur = gcUtilisateur) AND NOT(AVAILABLE(fichiers))).
        END.

        edtnotes:READ-ONLY = (cInfosCreateur <> "") AND NOT(cInfosCreateur = gcUtilisateur) AND tglPartage:CHECKED.
   
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

    DEFINE VARIABLE cFichierTempo AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cidReference AS CHARACTER NO-UNDO.

    cidReference = STRING(TODAY,"99/99/9999") + "-" + STRING(TIME,"hh:mm:ss").

    REPEAT:
        /* Demande du nom de la note */
	    RUN DonnePositionMessage IN ghGeneral.
	    gcAllerRetour = STRING(giPosXMessage)
	        + "|" + STRING(giPosYMessage)
            + "|" + "Nom de la note (Sans espace)"
            + "|" + "".
        RUN VALUE(gcRepertoireExecution + "saisie2.w") (INPUT-OUTPUT gcAllerRetour).
        IF gcAllerRetour = "" THEN RETURN.
                
        cFichierTempo = ENTRY(4,gcAllerRetour,"|").

        IF cFichierTempo MATCHES ("*[*") OR cFichierTempo MATCHES ("*]*") THEN DO:
            MESSAGE "Le nom d'une note ne peut pas contenir les caractères '[' ou ']' (Réservés pour les notes partagées) !!"
                VIEW-AS ALERT-BOX ERROR
                TITLE "Controle..."
                .
            /*RETURN.*/
            NEXT.
        END.

        /* La note existe peut-etre */
        FIND FIRST  fichiers    NO-LOCK
            WHERE   fichiers.cUtilisateur = gcUtilisateur
            AND     fichiers.cTypeFichier = "NOTES"
            AND     fichiers.cIdentFichier = cFichierTempo
            NO-ERROR.
        IF AVAILABLE(fichiers) THEN DO:
            MESSAGE "Une note à vous existe déjà avec ce nom. Création impossible !!"
                VIEW-AS ALERT-BOX ERROR
                TITLE "Controle..."
                .
            NEXT.
        END.

        /* La note existe peut-etre */
        FIND FIRST  fichiers    NO-LOCK
            WHERE   fichiers.cUtilisateur = gcUtilisateur
            AND     fichiers.cTypeFichier = "NOTES"
            AND     (num-entries(fichiers.cIdentFichier,"[") > 1 AND trim(entry(1,fichiers.cIdentFichier,"[")) = cFichierTempo)
            NO-ERROR.
        IF AVAILABLE(fichiers) THEN DO:
            MESSAGE "Une note partagée à vous existe déjà avec ce nom. Si vous conservez ce nom, il sera impossible d'activer le partage de cette note !!"
                + CHR(10) + "Voulez-vous conserver ce nom pour la note ?"
                VIEW-AS ALERT-BOX QUESTION BUTTON YES-NO
                TITLE "Controle..."
                UPDATE lReponse AS LOGICAL
                .
            IF lReponse THEN LEAVE.
            NEXT.
        END.

        /* Si on arrive ici, c'est que le nom est correct */
        LEAVE.
    END.

    /* Création du fichier note */
    CREATE fichiers.
    ASSIGN
        fichiers.cUtilisateur = gcUtilisateur
        fichiers.cTypeFichier = "NOTES"
        fichiers.cIdentfichier = cFichierTempo
        fichiers.cCreateur = gcUtilisateur
        fichiers.cModifieur = gcUtilisateur
        fichiers.idModification = cidReference
        .
    
    release fichiers.
    
    /* Rechargement de la liste */
    lCreation = TRUE.
    SauvePreference("NOTES-DERNIERE",cFichierTempo).
    RUN Initialisation.

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
  DISPLAY filRecherche edtnotes filSaisieRecherche tglPartage filremarque 
          filInfos 
      WITH FRAME frmModule IN WINDOW C-Win.
  ENABLE RECT-1 filRecherche btnCodePrecedent btnCodeSuivant edtnotes 
         btnPecedent btnSuivant filSaisieRecherche brwNotes tglPartage 
         filremarque filInfos 
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
                /*MESSAGE "affiche " linitfaite VIEW-AS ALERT-BOX.*/
                IF lInitFaite THEN RUN RechargementDifferentiel.
                /* Affichage de la frame principale */
                VIEW FRAME frmModule.
                FRAME frmModule:MOVE-TO-TOP().
                APPLY "ENTRY" TO filSaisieRecherche.

                lInitFaite = TRUE.
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
                /*MESSAGE "init " linitfaite VIEW-AS ALERT-BOX.*/
                RUN Initialisation.
            END.
            WHEN "RECHARGE" THEN DO:
                RUN Recharger.
            END.
            WHEN "IMPRIME" THEN DO:
                RUN ImpressionModule.
            END.
            WHEN "AJOUTER" THEN DO:
                RUN Creation(OUTPUT lRetour-ou).
            END.
            WHEN "SUPPRIMER" THEN DO:
                RUN Suppression(OUTPUT lRetour-ou).
            END.
            WHEN "MODIFIER" THEN DO:
                RUN Modification(OUTPUT lRetour-ou).
            END.
            WHEN "VALIDATION" THEN DO:
                RUN Modification(OUTPUT lRetour-ou).
            END.
            WHEN "RECHERCHE" THEN DO:
                APPLY "entry" TO filRecherche IN FRAME frmModule.
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
    gcAideAjouter = "#DIRECT#Ajouter une note".
    gcAideModifier = "#DIRECT#Enregistrer les modification faites sur la note en cours".
    gcAideSupprimer = "#DIRECT#Supprimer la note en cours".
    gcAideImprimer = "Impression de la note en cours".
    gcAideRaf = "Recharger le bloc notes".
    
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
DEFINE VARIABLE cUtilisateurNote AS CHARACTER NO-UNDO.
   
    if not(available(ttNotes)) then return.
   
    cTempo = DonneNomFichier().
    cUtilisateurNote = gcUtilisateur.

    IF cTempo MATCHES "*[*" THEN DO:
        cUtilisateurNote = entry(1,ENTRY(2,cTempo,"["),"]").    
    END.

    RUN ExtraitFichierDeLaBase(cUtilisateurNote,cTempo).
    RUN ImpressionFichier(gcFichierLocal,ttNotes.cIdentFichier).

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
    DEFINE VARIABLE iOnglet AS INTEGER NO-UNDO.
    DEFINE VARIABLE riongletsvg AS RECID NO-UNDO INIT ?.
    
    FRAME frmModule:WIDTH = gdLargeur.
    FRAME frmModule:HEIGHT = gdHauteur.
    FRAME frmModule:COLUMN = gdPositionXModule.
    FRAME frmModule:ROW = gdPositionYModule.

    /* Recupération de la dernière note visualisée */
    cFichierNotes = DonnePreference("NOTES-DERNIERE").

    /* Création de la note par défaut */
    lChargementEnCours = TRUE.

    /*cFichierNotes = "".*/
    FIND FIRST  fichiers    NO-LOCK
        WHERE   fichiers.cUtilisateur = gcUtilisateur
        AND     fichiers.cTypeFichier = "NOTES"
        AND     fichiers.cIdentfichier = "notes"
        NO-ERROR.
    IF NOT(AVAILABLE(fichiers)) THEN DO:
        CREATE fichiers.
        ASSIGN
            fichiers.cUtilisateur = gcUtilisateur
            fichiers.cTypeFichier = "NOTES"
            fichiers.cIdentfichier = "notes"
            .
    END.
    release fichiers.

    /* Chargement des notes perso */
    EMPTY TEMP-TABLE ttNotes.
    FOR EACH    fichiers    NO-LOCK
        WHERE   fichiers.cUtilisateur = gcUtilisateur
        AND     fichiers.cTypeFichier = "NOTES"
        :
        CREATE ttnotes.
        ttnotes.iordre = 0.
        ttnotes.cIdentFichier = fichiers.cIdentfichier.
        ttnotes.cUtilisateur = gcUtilisateur.
        ttnotes.lPartagee = (fichiers.cIdentFichier MATCHES ("*[*")).
        IF cFichierNotes = fichiers.cIdentfichier THEN DO:
            riOngletsvg = RECID(ttnotes).
        END.
    END.
    /* chargement des notes partagees */
    FOR EACH    fichiers    NO-LOCK
        WHERE   fichiers.cUtilisateur <> gcUtilisateur
        AND     fichiers.cTypeFichier = "NOTES"
        AND     fichiers.cIdentFichier MATCHES ("*[*")
        :
        CREATE ttnotes.
        ttnotes.iordre = 1.
        ttnotes.cIdentFichier = fichiers.cIdentfichier.
        ttnotes.cUtilisateur = gcUtilisateur.
        ttnotes.lPartagee = (fichiers.cIdentFichier MATCHES ("*[*")).
        IF cFichierNotes = fichiers.cIdentfichier THEN DO:
            riOngletsvg = RECID(ttnotes).
        END.
    END.

    {&OPEN-QUERY-brwNotes}

    IF riongletsvg = ? THEN cFichierNotes = "notes".      

    IF riongletsvg <> ? THEN do:       
        FIND FIRST ttnotes WHERE RECID(ttnotes) = riongletsvg NO-ERROR.
        IF AVAILABLE(ttnotes) THEN REPOSITION brwnotes TO RECID RECID(ttnotes).
    END.
    RUN ChangementOnglet.

    lChargementEnCours = FALSE.
    RELEASE fichiers.
    
    filRemarque:SCREEN-VALUE IN FRAME frmModule = "Seules vos notes (partagées ou non) sont modifiables ou supprimables.".

    APPLY "ENTRY" TO filSaisieRecherche.
    RUN TopChronoGeneral.

    IF lCreation THEN  DO:
        lCreation = FALSE.
        APPLY "ENTRY" TO edtNotes.
    END.
    
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
    
    DO WITH FRAME frmModule:
        APPLY "LEAVE" TO edtnotes.
        RUN gereboutons.
        RUN DonneOrdre("REINIT-BOUTONS-3").
    END.

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
    ENABLE ALL WITH FRAME frmModule.
    {&OPEN-BROWSERS-IN-QUERY-frmModule}
    HIDE c-win.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE RechargementDifferentiel C-Win 
PROCEDURE RechargementDifferentiel :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE iBoucle AS INTEGER NO-UNDO.
    DEFINE VARIABLE lACharger AS LOGICAL NO-UNDO.





   /* ******









    /*MESSAGE "lChargementEnCours = " lChargementEnCours VIEW-AS ALERT-BOX.*/

    IF lChargementEnCours THEN RETURN.

    /* chargement des notes partagees nouvelle et identification des notes 
       partagées modifiées */
    FOR EACH    fichiers    NO-LOCK
        WHERE   fichiers.cUtilisateur <> gcUtilisateur
        AND     fichiers.cTypeFichier = "NOTES"
        AND     fichiers.cIdentFichier MATCHES ("*[*")
        :
        /* la note est peut-etre déjà chargée */
        lACharger = TRUE.
        DO iBoucle = 0 TO chCtrlFrame-2:tabstrip:tabs:COUNT - 1 :
            IF chCtrlFrame-2:tabstrip:TAB(iBoucle):NAME = fichier.cIdentFichier THEN DO:
                lACharger = FALSE.
            END.
        END.
        IF lACharger THEN DO:
            chCtrlFrame-2:tabstrip:tabs:ADD(fichiers.cIdentfichier).
        END.
    END.
    
    
    
    
    
    
    
    
    
    
    
    
    -------------*/

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Recherche C-Win 
PROCEDURE Recherche :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER cSens-in AS CHARACTER NO-UNDO.

    DEFINE VARIABLE cOngletInitial AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lTrouve AS LOGICAL NO-UNDO.
    DEFINE VARIABLE iModeREcherche AS INTEGER NO-UNDO.

    /* repositionnement du BROWSE */
    IF available(ttnotes) THEN DO: 
        FIND CURRENT ttnotes.
        REPOSITION brwnotes TO RECID RECID(ttnotes).
        Mlog("Note en cours = " + ttNotes.cIdentFichier).
        cOngletInitial = ttNotes.cIdentFichier.
    END.
    
    lTrouve = FALSE.

    DO WITH FRAME frmModule:
        REPEAT:
            Mlog("cSens-in = " + cSens-in).
            /* on commence par rechercher dans l'onglet en cours */
            IF cSens-in = "PREC" THEN DO:
                /* Recherche en arrière avec selection  */
                iModeRecherche = 34.
            END.
            IF cSens-in = "SUIV" THEN DO:
                /* Recherche en avant avec selection  */
                iModeRecherche = 33.
            END.
            
            lTrouve = edtnotes:SEARCH(filRecherche:SCREEN-VALUE,iModeRecherche).
            Mlog("lTrouve = " + string(lTrouve)).
            /* Si trouvé : on sort */
            IF lTrouve THEN LEAVE.

            /* Si pas trouver on passe à l'onglet suivant */
            Mlog("avant find : AVAILABLE(ttNotes) = " + string(AVAILABLE(ttNotes))).
            IF cSens-in = "PREC" THEN DO:
                FIND PREV ttNotes NO-ERROR.
            END.
            ELSE DO:
                FIND NEXT ttNotes NO-ERROR.
            END.
            Mlog("apres find : AVAILABLE(ttNotes) = " + string(AVAILABLE(ttNotes))).
            IF NOT(AVAILABLE(ttNotes)) THEN DO:
                IF cSens-in = "PREC" THEN DO:
                    FIND LAST ttNotes NO-ERROR.
                END.
                ELSE DO:
                    FIND FIRST ttNotes NO-ERROR.
                END.
            END.
            /* Activation de l'onglet */
            IF AVAILABLE(ttNotes) THEN DO:
                REPOSITION brwNotes TO RECID RECID(ttNotes).
                RUN ChangementOnglet.

                /* si recherche du precedent, il faut se mettre à la fin du fichier sinon on ne trouve rien */
                IF cSens-in = "PREC" THEN edtNotes:MOVE-TO-EOF().

                Mlog("ttnotes.cIdentFichier = " + ttnotes.cIdentFichier + " - cOngletInitial = " + cOngletInitial).
                IF ttnotes.cIdentFichier = cOngletInitial THEN do:
                    BELL.
                    LEAVE.
                END.
            END.
        END.
    END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE RechercheTitre C-Win 
PROCEDURE RechercheTitre :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

DEFINE INPUT PARAMETER cModeRecherche AS CHARACTER NO-UNDO.

    DO WITH FRAME frmModule:
        
        IF cModeRecherche = "" THEN DO:
            FIND FIRST ttNotes
                WHERE ttNotes.cIdentFichier MATCHES "*" + filSaisieRecherche:SCREEN-VALUE + "*"
                NO-ERROR.
        END.
        ELSE IF cModeRecherche = "NEXT" THEN DO:
            FIND NEXT ttNotes
                WHERE ttNotes.cIdentFichier MATCHES "*" + filSaisieRecherche:SCREEN-VALUE + "*"
                NO-ERROR.
        END.
        ELSE DO:
            FIND PREV ttNotes
                WHERE ttNotes.cIdentFichier MATCHES "*" + filSaisieRecherche:SCREEN-VALUE + "*"
                NO-ERROR.
        END.
        IF AVAILABLE(ttNotes) THEN do:
            REPOSITION brwNotes TO ROWID ROWID(ttNotes).
            APPLY "VALUE-CHANGED" TO brwNotes.
        END.
        ELSE DO:
            BELL.
        END.
    END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE RenommeNote C-Win 
PROCEDURE RenommeNote :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

DEFINE INPUT PARAMETER cIdent-in AS CHARACTER NO-UNDO .
DEFINE INPUT PARAMETER lPartage-in AS LOGICAL NO-UNDO .

    DEFINE VARIABLE cidReference AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cNouveauNom AS CHARACTER NO-UNDO.

    cidReference = STRING(TODAY,"99/99/9999") + "-" + STRING(TIME,"hh:mm:ss").

    IF lPartage-in  THEN DO:
        cNouveauNom = cIdent-in + " [" + gcUtilisateur + "]".
    END.
    ELSE DO:
        cNouveauNom = trim(entry(1,cIdent-in,"[")).
    END.

    /* modification du fichier note */
    FIND FIRST  fichiers    EXCLUSIVE-LOCK
        WHERE   fichiers.cUtilisateur = gcUtilisateur
        AND     fichiers.cTypeFichier = "NOTES"
        AND     fichiers.cIdentFichier = cIdent-in
        NO-ERROR.
    IF AVAILABLE(fichiers) THEN DO:
        fichiers.cIdentFichier = cNouveauNom.
        fichiers.cModifieur = gcUtilisateur.
        fichiers.idModification = cidReference.

        /* rechargement */
        cFichierNotes = cNouveauNom.
        SauvePreference("NOTES-DERNIERE",cFichierNotes).
        RUN recharger.
    END.

    RELEASE fichiers.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Sauvegarde C-Win 
PROCEDURE Sauvegarde :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER cIdent-in AS CHARACTER NO-UNDO .

    DEFINE VARIABLE cidReference AS CHARACTER NO-UNDO.

    cidReference = STRING(TODAY,"99/99/9999") + "-" + STRING(TIME,"hh:mm:ss").
    /* modification du fichier note */
    FIND FIRST  fichiers    EXCLUSIVE-LOCK
        WHERE   fichiers.cUtilisateur = gcUtilisateur
        AND     fichiers.cTypeFichier = "NOTES"
        AND     fichiers.cIdentFichier = cIdent-in
        NO-ERROR.
    IF AVAILABLE(fichiers) THEN DO:
        fichiers.texte = edtnotes:SCREEN-VALUE IN FRAME frmModule.
        fichiers.cModifieur = gcUtilisateur.
        fichiers.idModification = cidReference.
    END.

    RELEASE fichiers.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE suppression C-Win 
PROCEDURE suppression :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE OUTPUT PARAMETER lRetour-ou AS LOGICAL NO-UNDO INIT TRUE.

    DEFINE VARIABLE lAction AS LOGICAL NO-UNDO INIT FALSE.
    DEFINE VARIABLE lOK AS LOGICAL NO-UNDO INIT TRUE.

    /* Récupération du nom du fichier */
    cFichierTempo = DonneNomFichier().

    /* interdiction de supprimer la note par défaut */
    IF cfichierTempo = "notes" THEN DO:
        MESSAGE "Suppression de la note par défaut interdite !"
            VIEW-AS ALERT-BOX ERROR
            TITLE "Suppression d'une note..."
            .
        RETURN.
    END.

    MESSAGE "Confirmez-vous la suppression de la note courante ?"
        VIEW-AS ALERT-BOX QUESTION
        BUTTON YES-NO
        TITLE "Demande de confirmation..."
        UPDATE lReponseSuppression AS LOGICAL.
    IF NOT(lReponseSuppression)  THEN RETURN NO-APPLY.
       
    lChargementEnCours = TRUE.

    /* suppression du fichier note */
    /* Il faut gérer la suppression d'une note partagée ssi j'en suis propriétaire */
    /* de même à l'affichage, il faut gérer la présence des notes partagées et réinitialiser si
    une des notes à disparu  ou a été modifié */

    /* la note est à l'utilisateur ? */
    FIND FIRST  fichiers    NO-LOCK
        WHERE   fichiers.cTypeFichier = "NOTES"
        AND     fichiers.cIdentFichier = cFichierTempo
        NO-ERROR.
    IF AVAILABLE(fichiers) AND fichiers.cUtilisateur <> gcUtilisateur THEN do:
        MESSAGE "Cette note partagée ne vous appartient pas. Vous ne pouvez pas la supprimer."
            VIEW-AS ALERT-BOX ERROR
            TITLE "Suppression d'une note..."
            .
        lOk = FALSE.
    END.

    IF lOk THEN do:
        /* se positionner sur la bonne note afin de la supprimer */
        FIND FIRST  fichiers    EXCLUSIVE-LOCK
            WHERE   fichiers.cUtilisateur = gcUtilisateur
            AND     fichiers.cTypeFichier = "NOTES"
            AND     fichiers.cIdentFichier = cFichierTempo
            NO-ERROR.
        IF AVAILABLE(fichiers) THEN do:
            DELETE fichiers.
            lAction = TRUE.
        END.
    END.

    RELEASE fichiers.
    
    IF lAction THEN DO:
        delete ttNotes.
                RUN Initialisation.
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION DonneContenu C-Win 
FUNCTION DonneContenu RETURNS CHARACTER
  ( cIdent-in AS CHARACTER ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
    DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO INIT "".

    IF num-entries(cIdent-in,"[") > 1 THEN DO:
        FIND FIRST  fichiers    NO-LOCK
            WHERE   fichiers.cTypeFichier = "NOTES"
            AND     fichiers.cIdentfichier = cIdent-in
            NO-ERROR.
    END.
    ELSE DO:
        FIND FIRST  fichiers    EXCLUSIVE-LOCK
            WHERE   fichiers.cUtilisateur = gcUtilisateur
            AND     fichiers.cTypeFichier = "NOTES"
            AND     fichiers.cIdentFichier = cIdent-in
            NO-ERROR.
    END.
    IF AVAILABLE(fichiers) THEN DO:
        cRetour = fichiers.texte.
    END.

    RELEASE fichiers.

    RETURN cRetour.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION DonneInfosNote C-Win 
FUNCTION DonneInfosNote RETURNS CHARACTER
  ( cIdent-in AS CHARACTER) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
    DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO INIT "".

    IF num-entries(cIdent-in,"[") > 1 THEN DO:
        FIND FIRST  fichiers    EXCLUSIVE-LOCK
            WHERE   fichiers.cTypeFichier = "NOTES"
            AND     fichiers.cIdentFichier = cIdent-in
            NO-ERROR.
    END.
    ELSE DO:
        FIND FIRST  fichiers    EXCLUSIVE-LOCK
            WHERE   fichiers.cUtilisateur = gcUtilisateur
            AND     fichiers.cTypeFichier = "NOTES"
            AND     fichiers.cIdentFichier = cIdent-in
            NO-ERROR.
    END.
    IF AVAILABLE(fichiers) THEN DO:
        cRetour = fichiers.idModification + "," + fichiers.cModifieur + "," + fichiers.cCreateur.
    END.

    RELEASE fichiers.

    RETURN cRetour.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION DonneNomFichier C-Win 
FUNCTION DonneNomFichier RETURNS CHARACTER
  ( /* parameter-definitions */ ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
  DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO INIT "".

  IF AVAILABLE(ttnotes) THEN cRetour = ttnotes.cIdentFichier.
  RETURN cRetour.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
