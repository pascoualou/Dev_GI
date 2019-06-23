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

DEFINE BUFFER bjournal FOR journal.

    DEFINE VARIABLE dDateJournalEnCours AS DATE.
    DEFINE VARIABLE dDateJournalSvg AS DATE INIT ?.


DEFINE VARIABLE lRechercheAffichee AS LOGICAL NO-UNDO INIT FALSE.

    DEFINE VARIABLE cLigne-svg AS CHARACTER NO-UNDO INIT "".

DEFINE TEMP-TABLE ttJournal
    FIELD cLibelle AS CHARACTER
    FIELD date-journal AS DATE
    FIELD lsvg AS LOGICAL

    INDEX date-journal date-journal
    .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME frmModule
&Scoped-define BROWSE-NAME brwJournal

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ttjournal

/* Definitions for BROWSE brwJournal                                    */
&Scoped-define FIELDS-IN-QUERY-brwJournal ttjournal.cLibelle   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brwJournal   
&Scoped-define SELF-NAME brwJournal
&Scoped-define QUERY-STRING-brwJournal FOR EACH ttjournal BY date-journal DESC
&Scoped-define OPEN-QUERY-brwJournal OPEN QUERY {&SELF-NAME} FOR EACH ttjournal BY date-journal DESC.
&Scoped-define TABLES-IN-QUERY-brwJournal ttjournal
&Scoped-define FIRST-TABLE-IN-QUERY-brwJournal ttjournal


/* Definitions for FRAME FRAME-A                                        */
&Scoped-define OPEN-BROWSERS-IN-QUERY-FRAME-A ~
    ~{&OPEN-QUERY-brwJournal}

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE VARIABLE edtjournal AS CHARACTER 
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
     SIZE 133 BY 17.62
     BGCOLOR 15 FONT 8 NO-UNDO.

DEFINE VARIABLE tglTousJournaux AS LOGICAL INITIAL no 
     LABEL "Tous les journaux" 
     VIEW-AS TOGGLE-BOX
     SIZE 27 BY .95 NO-UNDO.

DEFINE BUTTON btnDate  NO-FOCUS
     LABEL "Btn D" 
     SIZE 10 BY .95 TOOLTIP "Ajout d'une nouvelle ligne date et heure dans le journal".

DEFINE BUTTON btnJournal  NO-FOCUS
     LABEL "Journal du jour" 
     SIZE 29 BY .95 TOOLTIP "Afficher le journal du jour".

DEFINE BUTTON btnRecherche  NO-FOCUS
     LABEL ">" 
     SIZE 4 BY .95 TOOLTIP "Lancer la recherche dans les journaux".

DEFINE BUTTON btnTrait  NO-FOCUS
     LABEL "--" 
     SIZE 9 BY .95 TOOLTIP "Insertion d'un trait dans le journal".

DEFINE VARIABLE cmbSvg AS CHARACTER FORMAT "X(256)":U 
     LABEL "Sauvegardes" 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Item 1" 
     DROP-DOWN-LIST
     SIZE 26 BY 1
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE filRecherche AS CHARACTER FORMAT "X(256)":U 
     LABEL "Chercher dans les journaux" 
     VIEW-AS FILL-IN 
     SIZE 30 BY .95
     BGCOLOR 15  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brwJournal FOR 
      ttjournal SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brwJournal
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brwJournal C-Win _FREEFORM
  QUERY brwJournal DISPLAY
      ttjournal.cLibelle FORMAT "x(25)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-LABELS NO-ROW-MARKERS SEPARATORS SIZE 28 BY 16.43
         TITLE "Journaux" FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME frmModule
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 166 BY 20.6
         BGCOLOR 7 
         TITLE BGCOLOR 2 FGCOLOR 15 "Journal".

DEFINE FRAME FRAME-A
     brwJournal AT ROW 2.67 COL 3 WIDGET-ID 300
     edtjournal AT ROW 2.67 COL 32 NO-LABEL WIDGET-ID 8
     tglTousJournaux AT ROW 19.33 COL 3 WIDGET-ID 10
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 165.6 BY 19.52 WIDGET-ID 100.

DEFINE FRAME FRAME-B
     btnDate AT ROW 1.24 COL 36 HELP
          "Envoyer vers le presse-papier" WIDGET-ID 16
     filRecherche AT ROW 1.24 COL 86 COLON-ALIGNED WIDGET-ID 12
     cmbSvg AT ROW 1.24 COL 136 COLON-ALIGNED WIDGET-ID 18
     btnTrait AT ROW 1.24 COL 49 HELP
          "Envoyer vers le presse-papier" WIDGET-ID 22
     btnJournal AT ROW 1.24 COL 2 HELP
          "Envoyer vers le presse-papier" WIDGET-ID 20
     btnRecherche AT ROW 1.24 COL 118 HELP
          "Envoyer vers le presse-papier" WIDGET-ID 4
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1.6 ROW 1.1
         SIZE 164.4 BY 1.33 WIDGET-ID 200.


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
/* REPARENT FRAME */
ASSIGN FRAME FRAME-A:FRAME = FRAME frmModule:HANDLE
       FRAME FRAME-B:FRAME = FRAME FRAME-A:HANDLE.

/* SETTINGS FOR FRAME FRAME-A
                                                                        */

DEFINE VARIABLE XXTABVALXX AS LOGICAL NO-UNDO.

ASSIGN XXTABVALXX = FRAME FRAME-B:MOVE-BEFORE-TAB-ITEM (brwJournal:HANDLE IN FRAME FRAME-A)
/* END-ASSIGN-TABS */.

/* BROWSE-TAB brwJournal FRAME-B FRAME-A */
ASSIGN 
       edtjournal:AUTO-INDENT IN FRAME FRAME-A      = TRUE.

/* SETTINGS FOR FRAME FRAME-B
                                                                        */
/* SETTINGS FOR FRAME frmModule
   FRAME-NAME                                                           */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brwJournal
/* Query rebuild information for BROWSE brwJournal
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH ttjournal BY date-journal DESC.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE brwJournal */
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


&Scoped-define BROWSE-NAME brwJournal
&Scoped-define FRAME-NAME FRAME-A
&Scoped-define SELF-NAME brwJournal
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwJournal C-Win
ON ROW-DISPLAY OF brwJournal IN FRAME FRAME-A /* Journaux */
DO:
  IF ttJournal.lsvg THEN ttjournal.cLibelle:BGCOLOR IN BROWSE brwjournal = 10.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwJournal C-Win
ON VALUE-CHANGED OF brwJournal IN FRAME FRAME-A /* Journaux */
DO:
  
    DO WITH FRAME Frame-A:
    DO WITH FRAME Frame-B:
        dDateJournalEnCours = ttJournal.date-journal.
        FIND FIRST  journal NO-LOCK
            WHERE   journal.cutilisateur = gcUtilisateur
            AND     journal.date-svg = ?
            AND     journal.date-journal = dDateJournalEnCours
            NO-ERROR.
        IF AVAILABLE(journal) THEN DO:
            edtJournal:SCREEN-VALUE = journal.texte.
            edtJournal:READ-ONLY = FALSE.
            FRAME frame-B:BGCOLOR = (IF journal.date-journal < TODAY THEN 3 ELSE ?).
             btndate:VISIBLE = TRUE.
             btntrait:VISIBLE = TRUE.
        END.
    END.
    END.

    /* Chargement des sauvegardes du journal en cours */
    RUN ChargeSauvegardes.
    lRechercheAffichee = FALSE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME FRAME-B
&Scoped-define SELF-NAME btnDate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnDate C-Win
ON CHOOSE OF btnDate IN FRAME FRAME-B /* Btn D */
DO:
  DO WITH FRAME frame-A:
  DO WITH FRAME frame-B:
      edtjournal:SCREEN-VALUE = edtjournal:SCREEN-VALUE +  CHR(10)
          + (IF dDateJournalEnCours <> TODAY THEN STRING(TODAY,"99/99/9999") + " - " ELSE "")
          + STRING(TIME,"hh:mm") + CHR(10)
          + (IF dDateJournalEnCours <> TODAY THEN FILL("-",27) ELSE FILL("-",8))
          + CHR(10)
          .
      edtjournal:MOVE-TO-EOF().
      APPLY "ENTRY" TO edtjournal.
  END.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnJournal
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnJournal C-Win
ON CHOOSE OF btnJournal IN FRAME FRAME-B /* Journal du jour */
DO:
  DO WITH FRAME frame-B:
  DO WITH FRAME frame-A:
      APPLY "LEAVE" TO edtJournal.
      FIND FIRST    ttjournal 
          WHERE     ttjournal.date-journal = TODAY
          NO-ERROR.
      IF AVAILABLE(ttjournal) THEN DO:
          REPOSITION brwjournal TO RECID RECID(ttJournal).
          APPLY "VALUE-CHANGED" TO brwJournal.
      END.
  END.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnRecherche
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnRecherche C-Win
ON CHOOSE OF btnRecherche IN FRAME FRAME-B /* > */
DO:
  DEFINE VARIABLE lSauvegarde AS LOGICAL NO-UNDO INIT FALSE.
  DEFINE VARIABLE cFichierRecherche AS CHARACTER NO-UNDO.
  DEFINE VARIABLE lTrouve AS LOGICAL NO-UNDO INIT FALSE.

  DO WITH FRAME Frame-A:
  DO WITH FRAME Frame-B:
      lSauvegarde = (DonnePreference("PREF-RECHERCHE-JOURNAL-SAUVEGARDE") = "OUI").
    
      IF filRecherche:SCREEN-VALUE = "" THEN RETURN NO-APPLY.
    
      /* Fichier de recherche */
      cFichierRecherche = loc_tmp + "\RechercheJournal.txt".
      OUTPUT TO VALUE(cFichierRecherche).
      PUT UNFORMATTED "Recherche de '" + filRecherche:SCREEN-VALUE + "' dans les journaux" +
          (IF lSauvegarde THEN " (y-compris les sauvegardes)." ELSE ".")
          SKIP.
    
      /* Recherche */
      FOR EACH    journal NO-LOCK
          WHERE   journal.cutilisateur = gcUtilisateur
          AND     (journal.date-svg = ? OR lSauvegarde)
          BY journal.date-journal DESC
          :
          IF journal.texte MATCHES("*" + filRecherche:SCREEN-VALUE + "*") THEN DO:
              PUT UNFORMATTED 
                  FILL("*",153) + CHR(10)
                  "Journal du : " + STRING(journal.date-Journal,"99/99/9999") + " " + (IF journal.date-svg <> ? THEN "(Sauvegarde du  : " + STRING(journal.date-svg,"99/99/9999") + " à " + STRING(journal.heure-svg,"hh:mm:ss") + ")" ELSE "") + CHR(10)
                  + FILL("*",153) + CHR(10)
                  + journal.texte + CHR(10)
                  + FILL("-",190)
                  SKIP.
              lTrouve = TRUE.
          END.
      END.
    
      OUTPUT CLOSE.
    
      IF lTrouve THEN DO:
          lRechercheAffichee = TRUE.
          edtJournal:READ-FILE(cFichierRecherche).
          FRAME Frame-B:BGCOLOR = 14.
          btnDate:VISIBLE = FALSE.
      END.
  END.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnTrait
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnTrait C-Win
ON CHOOSE OF btnTrait IN FRAME FRAME-B /* -- */
DO:
  DO WITH FRAME frame-A:
  DO WITH FRAME frame-B:
      edtjournal:INSERT-STRING((IF edtjournal:CURSOR-CHAR > 1 THEN CHR(10) ELSE "") 
          + FILL("-",197)
          + CHR(10))
          .
      /*edtjournal:MOVE-TO-EOF().*/
      APPLY "ENTRY" TO edtjournal.
  END.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cmbSvg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cmbSvg C-Win
ON VALUE-CHANGED OF cmbSvg IN FRAME FRAME-B /* Sauvegardes */
DO:
    DEFINE VARIABLE cIdent  AS CHARACTER NO-UNDO.
    DEFINE VARIABLE iHeureSvgEnCours AS INTEGER NO-UNDO.
    DEFINE VARIABLE dDateSvgEnCours AS DATE NO-UNDO.

    DO WITH FRAME Frame-A:
    DO WITH FRAME Frame-B:
        IF SELF:SCREEN-VALUE <> "-" THEN DO:
            cIdent = ENTRY(2,SELF:SCREEN-VALUE,"|").
            dDateSvgEnCours = DATE(ENTRY(2,cIdent,"-")).
            iHeureSvgEnCours = INTEGER(ENTRY(3,cIdent,"-")).
            FIND FIRST  journal NO-LOCK
                WHERE   journal.cutilisateur = gcUtilisateur
                AND     journal.date-journal = dDateJournalEnCours
                AND     journal.date-svg = dDateSvgEnCours
                AND     journal.heure-svg = iHeureSvgEnCours
                NO-ERROR.
            IF AVAILABLE(journal) THEN DO:
                edtJournal:SCREEN-VALUE = journal.texte.
                edtJournal:READ-ONLY = TRUE.
                FRAME frame-B:BGCOLOR = 12.
                btndate:VISIBLE = FALSE.
                btnTrait:VISIBLE = FALSE.
        
            END.
        END.
        ELSE DO:
            APPLY "VALUE-CHANGED" TO brwJournal.
        END.
    END.
    END.
    lRechercheAffichee = FALSE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME FRAME-A
&Scoped-define SELF-NAME edtjournal
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL edtjournal C-Win
ON CTRL-A OF edtjournal IN FRAME FRAME-A
DO:
  DO WITH FRAME frmModule:
      edtjournal:SET-SELECTION(1,LENGTH(edtjournal:SCREEN-VALUE) + 100) NO-ERROR.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL edtjournal C-Win
ON LEAVE OF edtjournal IN FRAME FRAME-A
DO:

    DEFINE VARIABLE lPasAncien AS LOGICAL NO-UNDO INIT TRUE.
    DEFINE VARIABLE lAvertissement AS LOGICAL NO-UNDO INIT FALSE.
    
    lAvertissement = (DonnePreference("PREF-HISTORIQUE-PREVENIR") = "OUI").

    DO WITH FRAME Frame-A:
    DO WITH FRAME Frame-B:

    /* Si on est sur une sauvegarde : interdit de modifier */
    IF cmbsvg:SCREEN-VALUE = "-"  AND not(lRechercheAffichee) THEN DO:
        /* Sauvegarde du journal */
        /* Positionnement sur le journal en cours */
        FIND FIRST  journal EXCLUSIVE-LOCK
            WHERE   journal.cutilisateur = gcUtilisateur
            AND     journal.date-svg = ?
            AND     journal.date-journal = dDateJournalEnCours
            NO-ERROR.
        IF (AVAILABLE(journal) AND journal.texte <> edtjournal:SCREEN-VALUE) THEN DO:
            lPasAncien = TRUE.
            /* Demande de confirmation si journal passé ssi provient pas du bouton modifier */
            IF lAvertissement AND journal.date-journal < TODAY THEN DO:
                lPasAncien = FALSE.
                MESSAGE "ATTENTION, vous venez de modifier un ancien journal ! Confirmez vous les modifications ?"
                    VIEW-AS ALERT-BOX QUESTION
                    BUTTONS YES-NO
                    TITLE "Demande de confirmation...."
                    UPDATE lReponseAncien AS LOGICAL
                    .
            END.

            IF lReponseAncien OR lPasAncien THEN DO:
                /* Sauvegarde du journal en cours */
                CREATE bjournal.
                BUFFER-COPY journal TO bjournal.
                bjournal.DATE-svg = TODAY.
                bjournal.heure-svg = TIME.
    
                /* Modification du journal en cours */
                journal.texte = edtJournal:SCREEN-VALUE.

            END.
        END.
        RELEASE journal.
        RELEASE bjournal.
        
        /* Rechargement des journaux : pour mettre a jour le screen-value de la combo */
        RUN ChargeJournaux(dDateJournalEnCours). 
        RUN ChargeSauvegardes.
    END.
    END.
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME FRAME-B
&Scoped-define SELF-NAME filRecherche
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filRecherche C-Win
ON RETURN OF filRecherche IN FRAME FRAME-B /* Chercher dans les journaux */
DO:
  APPLY "choose" TO btnRecherche.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME FRAME-A
&Scoped-define SELF-NAME tglTousJournaux
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglTousJournaux C-Win
ON VALUE-CHANGED OF tglTousJournaux IN FRAME FRAME-A /* Tous les journaux */
DO:
  
    RUN Recharger.
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ChargeJournaux C-Win 
PROCEDURE ChargeJournaux :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER dDateEnCours-in AS DATE NO-UNDO.
    
    DEFINE VARIABLE dDateLimite    AS DATE.
    DEFINE VARIABLE cLigne AS CHARACTER NO-UNDO INIT "".
    DEFINE BUFFER bjournal FOR journal.

    EMPTY TEMP-TABLE ttJournal.

    /* Détermination de la date limite de chargement */
    dDateLimite = ADD-INTERVAL(TODAY,-4,"weeks").
    IF DonnePreference("PREF-LIMITE-JOURNAL") = "NON" 
    OR tglTousJournaux:CHECKED in FRAME frame-A THEN do:
        dDateLimite = ?.
    END.
        
    /* Si on ne précise pas de date, on se positionne sur la date du jour */
    IF dDateEnCours-in = ? THEN dDateEnCours-in = TODAY.

    DO WITH FRAME frame-A:
    DO WITH FRAME frame-B:
        FOR EACH    journal NO-LOCK
            WHERE   journal.cutilisateur = gcUtilisateur
            AND     journal.date-svg = ?
            AND     (dDateLimite = ? OR (dDateLimite <> ? AND journal.date-journal >= dDateLimite))
            :
            FIND FIRST  bjournal NO-LOCK
                WHERE   bjournal.cutilisateur = journal.cutilisateur
                AND     bjournal.date-svg <> ?
                AND     bjournal.date-journal = journal.date-journal
                NO-ERROR.
            CREATE ttJournal.
            ttJournal.cLibelle = STRING(journal.date-journal,"99/99/9999") 
                + " (" + ENTRY(WEEKDAY(journal.date-journal),cListeJours) + ")"
                .
            ttJournal.date-journal = journal.date-journal.
            ttJournal.lsvg = AVAILABLE(bjournal).
        END.

        {&OPEN-QUERY-BRWJOURNAL}
    
        FIND FIRST  ttJournal
            WHERE   ttJournal.date-journal = dDateEnCours-in
            NO-ERROR.
        IF NOT(AVAILABLE(ttJournal)) THEN DO:
            FIND LAST  ttJournal
                NO-ERROR.
        END.
        IF AVAILABLE(ttJournal) THEN DO:
            REPOSITION brwJournal TO RECID RECID(ttJournal).
            APPLY "VALUE-CHANGED" TO brwJournal.
        END.

        /* Si date du jour, on recharge le journal */
        /*
        IF dDateEnCours-in = TODAY THEN do:
            APPLY "VALUE-CHANGED" TO brwJournal.
        END.
        */
    END.
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ChargeSauvegardes C-Win 
PROCEDURE ChargeSauvegardes :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE cLigne AS CHARACTER NO-UNDO INIT "".

    DO WITH FRAME Frame-A:
    DO WITH FRAME Frame-B:

        cmbsvg:LIST-ITEMS = "".
        cmbsvg:ADD-LAST("-").
        FOR EACH    journal NO-LOCK
            WHERE   journal.cutilisateur = gcUtilisateur
            AND     journal.date-svg <> ?
            AND     journal.date-journal = dDateJournalEnCours
            BY journal.date-svg DESC BY journal.heure-svg DESC
            :
            cLigne = STRING(date-svg,"99/99/9999") 
                + " - " + STRING(journal.heure-svg,"hh:mm:ss")
                + FILL(" ",100) + "|" + STRING(journal.date-journal,"99/99/9999") + "-" + STRING(date-svg,"99/99/9999") + "-" + STRING(journal.heure-svg)
                .
            cmbsvg:ADD-LAST(cLigne).
        END.
        cmbsvg:SCREEN-VALUE = "-".

    END.
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
  DISPLAY edtjournal tglTousJournaux 
      WITH FRAME FRAME-A IN WINDOW C-Win.
  ENABLE brwJournal edtjournal tglTousJournaux 
      WITH FRAME FRAME-A IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-FRAME-A}
  VIEW FRAME frmModule IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-frmModule}
  DISPLAY filRecherche cmbSvg 
      WITH FRAME FRAME-B IN WINDOW C-Win.
  ENABLE btnDate filRecherche cmbSvg btnTrait btnJournal btnRecherche 
      WITH FRAME FRAME-B IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-FRAME-B}
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
                RUN Recharger.
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
            WHEN "AJOUTER" THEN DO:
                RUN Creation(OUTPUT lRetour-ou).
            END.
            WHEN "MODIFIER" THEN DO:
                RUN Modification(OUTPUT lRetour-ou).
            END.
            WHEN "SUPPRIMER" THEN DO:
                RUN Suppression(OUTPUT lRetour-ou).
            END.

            WHEN "RECHERCHE" THEN DO:
                APPLY "entry" TO filRecherche IN FRAME frame-b.
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
    gcAideModifier = "#DIRECT#Enregistrer les modification du journal".
    gcAideSupprimer = "#INTERDIT#".
    gcAideImprimer = "Impression du journal".
    gcAideRaf = "Recharger le journal".

    
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
DEFINE VARIABLE cFichierEdition AS CHARACTER NO-UNDO INIT "".
   
    DO WITH FRAME Frame-A:
    DO WITH FRAME Frame-B:
        cFichierEdition = loc_tmp + "\EditionJournal.tmp".
        edtJournal:SAVE-FILE(cFichierEdition).
        RUN ImpressionFichier(cFichierEdition,"Journal").
    END.
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
    DEFINE VARIABLE cLigne AS CHARACTER NO-UNDO.

    FRAME frmModule:WIDTH = gdLargeur.
    FRAME frmModule:HEIGHT = gdHauteur.
    FRAME frmModule:COLUMN = gdPositionXModule.
    FRAME frmModule:ROW = gdPositionYModule.

    RUN JournalDuJour.

    DO WITH FRAME frame-A:
    DO WITH FRAME frame-B:
        btnDate:LOAD-IMAGE(gcRepertoireRessources + "fleche01.bmp").
        btnTrait:LOAD-IMAGE(gcRepertoireImages + "flecheTrait.bmp").
        btnDate:MOVE-TO-TOP().
        btntrait:MOVE-TO-TOP().
        tglTousJournaux:SENSITIVE = TRUE.
        IF DonnePreference("PREF-LIMITE-JOURNAL") = "NON"  THEN DO:
            tglTousJournaux:CHECKED = FALSE.
            tglTousJournaux:SENSITIVE = FALSE.
        END.
    END.
    END.
    
    RUN ChargeJournaux(dDateJournalSvg).
    RUN TopChronoGeneral.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE JournalDuJour C-Win 
PROCEDURE JournalDuJour :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE dDateDepart AS DATE NO-UNDO INIT ?.
    DEFINE VARIABLE dDateEnCours AS DATE NO-UNDO INIT ?.


    /* recherche de la première date de journal */
    FIND FIRST   journal NO-LOCK
        WHERE   journal.cutilisateur = gcUtilisateur
        AND     journal.date-svg = ?
        NO-ERROR.
    IF AVAILABLE(journal) THEN DO:
        dDateDepart = journal.date-journal.
    END.

    /* si pas trouvé, on génère les 7 dernier jours hors WE et JF */
    IF dDateDepart = ?  THEN DO:
        dDateDepart = TODAY - 7.
    END.

    /* création des journaux manquant sauf pour les WE et JF */
    DO dDateEnCours = dDateDepart TO TODAY:
        /* WE ou JF ? */
        IF (WEEKDAY(dDateEnCours) = 1 OR  WEEKDAY(dDateEnCours) = 7) THEN NEXT.
        IF JourFerie(dDateEnCours) THEN NEXT.
        FIND FIRST  journal NO-LOCK
            WHERE   journal.cutilisateur = gcUtilisateur
            AND     journal.date-svg = ?
            AND     journal.date-journal = dDateEnCours
            NO-ERROR.
        IF NOT(AVAILABLE(journal)) THEN DO:
            CREATE journal.
            ASSIGN
                journal.cutilisateur = gcUtilisateur
                journal.date-svg = ?
                journal.date-journal = dDateEnCours
                Journal.texte = "Journal du : " + STRING(dDateEnCours,"99/99/9999") + chr(10).
                .
        END.
    END.

    RELEASE journal.

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

    DEFINE VARIABLE iOngletSVG AS INTEGER NO-UNDO.

    DO WITH FRAME frame-A:
    DO WITH FRAME frame-B:
        APPLY "LEAVE" TO edtJournal.
        RUN DonneOrdre("REINIT-BOUTONS-2").
    END.
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
    ENABLE ALL WITH FRAME frame-A.
    ENABLE ALL WITH FRAME frame-B.
    {&OPEN-BROWSERS-IN-QUERY-frmModule}
    HIDE c-win.

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
    dDateJournalSvg = (IF AVAILABLE(ttJournal) THEN ttJournal.Date-Journal ELSE ?).
    RUN Initialisation.
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

