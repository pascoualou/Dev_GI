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

DEFINE BUFFER GIprefs FOR prefs.
DEFINE BUFFER Persoprefs FOR prefs.
DEFINE VARIABLE cEtatEncours AS CHARACTER NO-UNDO.
DEFINE VARIABLE riSauve AS ROWID NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME frmFonction
&Scoped-define BROWSE-NAME brwTelGI

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES GIPrefs PersoPrefs

/* Definitions for BROWSE brwTelGI                                      */
&Scoped-define FIELDS-IN-QUERY-brwTelGI GIPrefs.cValeur GIPrefs.filler   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brwTelGI GIPrefs.cValeur   
&Scoped-define ENABLED-TABLES-IN-QUERY-brwTelGI GIPrefs
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-brwTelGI GIPrefs
&Scoped-define SELF-NAME brwTelGI
&Scoped-define QUERY-STRING-brwTelGI FOR EACH GIPrefs       WHERE GIPrefs.cUtilisateur = "ADMIN"  AND GIPrefs.cCode = "TEL_GI" NO-LOCK     BY GIPrefs.cValeur INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-brwTelGI OPEN QUERY {&SELF-NAME} FOR EACH GIPrefs       WHERE GIPrefs.cUtilisateur = "ADMIN"  AND GIPrefs.cCode = "TEL_GI" NO-LOCK     BY GIPrefs.cValeur INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-brwTelGI GIPrefs
&Scoped-define FIRST-TABLE-IN-QUERY-brwTelGI GIPrefs


/* Definitions for BROWSE brwTelPerso                                   */
&Scoped-define FIELDS-IN-QUERY-brwTelPerso PersoPrefs.cValeur PersoPrefs.filler   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brwTelPerso PersoPrefs.cValeur   
&Scoped-define ENABLED-TABLES-IN-QUERY-brwTelPerso PersoPrefs
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-brwTelPerso PersoPrefs
&Scoped-define SELF-NAME brwTelPerso
&Scoped-define QUERY-STRING-brwTelPerso FOR EACH PersoPrefs       WHERE PersoPrefs.cUtilisateur = gcUtilisateur  AND PersoPrefs.cCode = "TEL_PERSO" NO-LOCK     BY PersoPrefs.cValeur INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-brwTelPerso OPEN QUERY {&SELF-NAME} FOR EACH PersoPrefs       WHERE PersoPrefs.cUtilisateur = gcUtilisateur  AND PersoPrefs.cCode = "TEL_PERSO" NO-LOCK     BY PersoPrefs.cValeur INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-brwTelPerso PersoPrefs
&Scoped-define FIRST-TABLE-IN-QUERY-brwTelPerso PersoPrefs


/* Definitions for FRAME frmFonction                                    */
&Scoped-define OPEN-BROWSERS-IN-QUERY-frmFonction ~
    ~{&OPEN-QUERY-brwTelGI}~
    ~{&OPEN-QUERY-brwTelPerso}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS filTelGI btnCodePrecedent btnCodeSuivant ~
filTelPerso btnCodePrecedent-2 btnCodeSuivant-2 brwTelGI brwTelPerso ~
filNumero filLibelle 
&Scoped-Define DISPLAYED-OBJECTS filTelGI filTelPerso filNumero filLibelle 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.

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

DEFINE VARIABLE filLibelle AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 50 BY .95 NO-UNDO.

DEFINE VARIABLE filNumero AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 25 BY .95 NO-UNDO.

DEFINE VARIABLE filTelGI AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE-PIXELS 350 BY 20
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE filTelPerso AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE-PIXELS 345 BY 20
     BGCOLOR 15  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brwTelGI FOR 
      GIPrefs SCROLLING.

DEFINE QUERY brwTelPerso FOR 
      PersoPrefs SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brwTelGI
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brwTelGI C-Win _FREEFORM
  QUERY brwTelGI NO-LOCK DISPLAY
      GIPrefs.cValeur COLUMN-LABEL "N°/Poste" FORMAT "X(50)" WIDTH 11.2
      GIPrefs.filler COLUMN-LABEL "Nom" FORMAT "X(150)"
  
      ENABLE
      GIPrefs.cValeur
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 79 BY 17.38
         TITLE "Téléphones GI" FIT-LAST-COLUMN.

DEFINE BROWSE brwTelPerso
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brwTelPerso C-Win _FREEFORM
  QUERY brwTelPerso NO-LOCK DISPLAY
      PersoPrefs.cValeur COLUMN-LABEL "N°/Poste" FORMAT "X(50)":U WIDTH 24.2
      PersoPrefs.filler COLUMN-LABEL "Nom" FORMAT "X(150)":U
  ENABLE
      PersoPrefs.cValeur
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 79 BY 16.19
         TITLE "Téléphones Perso" ROW-HEIGHT-CHARS .67 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME frmModule
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 166.2 BY 20.62
         BGCOLOR 7 
         TITLE BGCOLOR 2 FGCOLOR 15 "Téléphones".

DEFINE FRAME frmFonction
     filTelGI AT Y 5 X 5 NO-LABEL WIDGET-ID 10
     btnCodePrecedent AT Y 5 X 360 WIDGET-ID 6
     btnCodeSuivant AT Y 5 X 381 WIDGET-ID 8
     filTelPerso AT Y 5 X 420 NO-LABEL WIDGET-ID 16
     btnCodePrecedent-2 AT Y 5 X 770 WIDGET-ID 12
     btnCodeSuivant-2 AT Y 5 X 791 WIDGET-ID 14
     brwTelGI AT ROW 2.43 COL 2 WIDGET-ID 100
     brwTelPerso AT ROW 2.43 COL 85 WIDGET-ID 200
     filNumero AT ROW 18.86 COL 83 COLON-ALIGNED NO-LABEL WIDGET-ID 2
     filLibelle AT ROW 18.86 COL 109 COLON-ALIGNED NO-LABEL WIDGET-ID 4
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
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
  CREATE WINDOW C-Win ASSIGN
         HIDDEN             = YES
         TITLE              = "<insert window title>"
         HEIGHT             = 20.62
         WIDTH              = 166
         MAX-HEIGHT         = 44.76
         MAX-WIDTH          = 256
         VIRTUAL-HEIGHT     = 44.76
         VIRTUAL-WIDTH      = 256
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
ASSIGN FRAME frmFonction:FRAME = FRAME frmModule:HANDLE.

/* SETTINGS FOR FRAME frmFonction
   FRAME-NAME                                                           */
/* BROWSE-TAB brwTelGI btnCodeSuivant-2 frmFonction */
/* BROWSE-TAB brwTelPerso brwTelGI frmFonction */
ASSIGN 
       btnCodeSuivant:AUTO-RESIZE IN FRAME frmFonction      = TRUE.

ASSIGN 
       btnCodeSuivant-2:AUTO-RESIZE IN FRAME frmFonction      = TRUE.

/* SETTINGS FOR FILL-IN filTelGI IN FRAME frmFonction
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN filTelPerso IN FRAME frmFonction
   ALIGN-L                                                              */
/* SETTINGS FOR FRAME frmModule
                                                                        */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brwTelGI
/* Query rebuild information for BROWSE brwTelGI
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH GIPrefs
      WHERE GIPrefs.cUtilisateur = "ADMIN"
 AND GIPrefs.cCode = "TEL_GI" NO-LOCK
    BY GIPrefs.cValeur INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _OrdList          = "menudev2.Prefs.cValeur|yes"
     _Where[1]         = "menudev2.Prefs.cUtilisateur = ""ADMIN""
 AND menudev2.Prefs.cCode = ""TEL_GI"""
     _Query            is OPENED
*/  /* BROWSE brwTelGI */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brwTelPerso
/* Query rebuild information for BROWSE brwTelPerso
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH PersoPrefs
      WHERE PersoPrefs.cUtilisateur = gcUtilisateur
 AND PersoPrefs.cCode = "TEL_PERSO" NO-LOCK
    BY PersoPrefs.cValeur INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _OrdList          = "menudev2.Prefs.cValeur|yes"
     _Where[1]         = "menudev2.Prefs.cUtilisateur = gcUtilisateur
 AND menudev2.Prefs.cCode = ""TEL_PERSO"""
     _Query            is OPENED
*/  /* BROWSE brwTelPerso */
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


&Scoped-define BROWSE-NAME brwTelGI
&Scoped-define SELF-NAME brwTelGI
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwTelGI C-Win
ON START-SEARCH OF brwTelGI IN FRAME frmFonction /* Téléphones GI */
DO:
  /* */
    IF brwTelGI:CURRENT-COLUMN:NAME  = "filler" THEN DO:
        OPEN QUERY brwTelGI FOR
            EACH GIPrefs
            WHERE GIPrefs.cUtilisateur = "ADMIN"
            AND GIPrefs.cCode = "TEL_GI" NO-LOCK
            BY GIPrefs.filler INDEXED-REPOSITION.
    END.
    ELSE DO:
        OPEN QUERY brwTelGI FOR
            EACH GIPrefs
            WHERE GIPrefs.cUtilisateur = "ADMIN"
            AND GIPrefs.cCode = "TEL_GI" NO-LOCK
            BY GIPrefs.cValeur INDEXED-REPOSITION.
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brwTelPerso
&Scoped-define SELF-NAME brwTelPerso
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwTelPerso C-Win
ON START-SEARCH OF brwTelPerso IN FRAME frmFonction /* Téléphones Perso */
DO:
  /* */
    RUN OuvreBrowsePerso.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwTelPerso C-Win
ON VALUE-CHANGED OF brwTelPerso IN FRAME frmFonction /* Téléphones Perso */
DO:
  IF available(PersoPrefs) THEN DO WITH FRAME frmFonction:
      filNumero:SCREEN-VALUE = PersoPrefs.cValeur.
      filLibelle:SCREEN-VALUE = PersoPrefs.filler.
      /*IF AVAILABLE(PersoPrefs) THEN risauve = ROWID(PersoPrefs).*/
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnCodePrecedent
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnCodePrecedent C-Win
ON CHOOSE OF btnCodePrecedent IN FRAME frmFonction /* < */
DO:
  
    RUN SaisieGI ("PREV").

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnCodePrecedent-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnCodePrecedent-2 C-Win
ON CHOOSE OF btnCodePrecedent-2 IN FRAME frmFonction /* < */
DO:
  
    RUN SaisiePerso ("PREV").

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnCodeSuivant
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnCodeSuivant C-Win
ON CHOOSE OF btnCodeSuivant IN FRAME frmFonction /* > */
DO:
    
    RUN SaisieGI ("NEXT").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnCodeSuivant-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnCodeSuivant-2 C-Win
ON CHOOSE OF btnCodeSuivant-2 IN FRAME frmFonction /* > */
DO:
    
    RUN SaisiePerso ("NEXT").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filTelGI
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filTelGI C-Win
ON ANY-PRINTABLE OF filTelGI IN FRAME frmFonction
DO:  
    APPLY  LAST-KEY TO SELF.
    RUN SaisieGI ("").
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filTelGI C-Win
ON BACKSPACE OF filTelGI IN FRAME frmFonction
DO:
    APPLY  LAST-KEY TO SELF.
    RUN SaisieGI ("").
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filTelGI C-Win
ON DELETE-CHARACTER OF filTelGI IN FRAME frmFonction
DO:
    APPLY  LAST-KEY TO SELF.
    RUN SaisieGI ("").
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filTelGI C-Win
ON RETURN OF filTelGI IN FRAME frmFonction
DO:
    APPLY  LAST-KEY TO SELF.
    RUN SaisieGI ("").
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filTelPerso
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filTelPerso C-Win
ON ANY-PRINTABLE OF filTelPerso IN FRAME frmFonction
DO:  
    APPLY  LAST-KEY TO SELF.
    RUN SaisiePerso ("").
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filTelPerso C-Win
ON BACKSPACE OF filTelPerso IN FRAME frmFonction
DO:
    APPLY  LAST-KEY TO SELF.
    RUN SaisiePerso ("").
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filTelPerso C-Win
ON DELETE-CHARACTER OF filTelPerso IN FRAME frmFonction
DO:
    APPLY  LAST-KEY TO SELF.
    RUN SaisiePerso ("").
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filTelPerso C-Win
ON RETURN OF filTelPerso IN FRAME frmFonction
DO:
    APPLY  LAST-KEY TO SELF.
    RUN SaisiePerso ("").
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brwTelGI
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
    IF cEtatEncours = "CRE" AND AVAILABLE(Persoprefs) THEN DO TRANSACTION: 
        FIND FIRST Persoprefs EXCLUSIVE-LOCK
            WHERE ROWID(Persoprefs) = risauve
            NO-ERROR.
        DELETE Persoprefs.
        risauve = ?.
    END.
    RELEASE Persoprefs.
    RUN recharger.
    
    RUN GereEtat("VIS").

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
    CREATE PersoPrefs.
    ASSIGN
        PersoPrefs.cUtilisateur = gcUtilisateur
        PersoPrefs.cCode = "TEL_PERSO".
        risauve = rowid(PersoPrefs).
        .

    /* Rechargement du browse */
    RUN OuvreBrowsePerso.

    /* on se repositionne */
    FIND FIRST PersoPrefs NO-LOCK
        WHERE ROWID(PersoPrefs) = risauve
        NO-ERROR.

    IF AVAILABLE(PersoPrefs) THEN DO WITH FRAME frmfonction :
        REPOSITION brwTelPerso TO ROWID ROWID(PersoPrefs).
        APPLY "VALUE-CHANGED" TO brwTelPerso.
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
  VIEW FRAME frmModule IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-frmModule}
  DISPLAY filTelGI filTelPerso filNumero filLibelle 
      WITH FRAME frmFonction IN WINDOW C-Win.
  ENABLE filTelGI btnCodePrecedent btnCodeSuivant filTelPerso 
         btnCodePrecedent-2 btnCodeSuivant-2 brwTelGI brwTelPerso filNumero 
         filLibelle 
      WITH FRAME frmFonction IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-frmFonction}
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE GereBoutons C-Win 
PROCEDURE GereBoutons :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    gcAideAjouter = "Ajouter un numéro perso".
    gcAideModifier = "Modifier un numéro perso".
    gcAideSupprimer = "Supprimer un numéro perso".
    gcAideImprimer = "#INTERDIT#".
    gcAideRaf = "Recharger la liste téléphones".

 
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
    
    DO WITH FRAME frmFonction :
        brwTelPerso:SENSITIVE = NOT(lEtat).
        filNumero:SENSITIVE = lEtat.
        filLibelle:SENSITIVE = lEtat.
    END.

    /* Mémorisation de l'état demandé */
    cEtatEnCours = cEtat-in.

    IF NUM-RESULTS("brwTelPerso") > 0 THEN  brwTelPerso:REFRESH() IN FRAME frmFonction.

    IF lEtat THEN APPLY "ENTRY" TO filNumero IN FRAME frmFonction.

    IF cEtatEncours = "VIS" THEN DO WITH FRAME frmFonction :
        IF riSauve <> ? THEN
            FIND FIRST Persoprefs NO-LOCK WHERE ROWID(Persoprefs) = riSauve NO-ERROR.
        ELSE 
            FIND FIRST Persoprefs WHERE Persoprefs.cUtilisateur = gcUtilisateur AND Persoprefs.cCode = "TEL_PERSO" NO-LOCK NO-ERROR.
        
        IF AVAILABLE(Persoprefs) THEN do:
            REPOSITION brwTelPerso TO ROWID riSauve NO-ERROR.
            APPLY "VALUE-CHANGED" TO brwTelPerso.
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
    
    FRAME frmModule:COLUMN = gdPositionXModule.
    FRAME frmModule:ROW = gdPositionYModule.

    RUN TopChronoGeneral.
    RUN TopChronoPartiel.
    
    APPLY "VALUE-CHANGED" TO brwTelPerso IN FRAME frmFonction.
    RUN GereEtat("VIS").

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

    riSauve = (IF AVAILABLE(PersoPrefs) THEN ROWID(PersoPrefs) ELSE ?).

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
    {&OPEN-BROWSERS-IN-QUERY-frmFonction}
    HIDE c-win.
  ENABLE ALL WITH FRAME frmFonction.
  GIPrefs.cValeur:READ-ONLY IN BROWSE brwTelGI = TRUE.
  PersoPrefs.cValeur:READ-ONLY IN BROWSE brwTelPerso = TRUE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OuvreBrowsePerso C-Win 
PROCEDURE OuvreBrowsePerso :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE cColonne AS CHARACTER NO-UNDO INIT "".

    DO WITH FRAME frmFonction :
    cColonne = brwTelPerso:CURRENT-COLUMN:NAME NO-ERROR.

    IF cColonne = "filler" THEN DO:
        OPEN QUERY brwTelPerso FOR
            EACH PersoPrefs
            WHERE PersoPrefs.cUtilisateur = gcUtilisateur
            AND PersoPrefs.cCode = "TEL_PERSO" NO-LOCK
            BY PersoPrefs.filler INDEXED-REPOSITION.
    END.
    ELSE DO:
        OPEN QUERY brwTelPerso FOR
            EACH PersoPrefs
            WHERE PersoPrefs.cUtilisateur = gcUtilisateur
            AND PersoPrefs.cCode = "TEL_PERSO" NO-LOCK
            BY PersoPrefs.cValeur INDEXED-REPOSITION.
    END.
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE SaisieGI C-Win 
PROCEDURE SaisieGI :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER cModeRecherche AS CHARACTER NO-UNDO.

    DO WITH FRAME frmFonction:
        
        IF cModeRecherche = "" THEN DO:
            FIND FIRST GIPrefs
                WHERE GIPrefs.cUtilisateur = "ADMIN"
                and   GIPrefs.cCode = "TEL_GI"
                and   (GIPrefs.filler MATCHES "*" + filTelGI:SCREEN-VALUE + "*"
                OR    GIPrefs.cValeur MATCHES "*" + filTelGI:SCREEN-VALUE + "*")
                NO-ERROR.
        END.
        ELSE IF cModeRecherche = "NEXT" THEN DO:
            FIND NEXT GIPrefs
                WHERE GIPrefs.cUtilisateur = "ADMIN"
                and   GIPrefs.cCode = "TEL_GI"
                and   (GIPrefs.filler MATCHES "*" + filTelGI:SCREEN-VALUE + "*"
                OR    GIPrefs.cValeur MATCHES "*" + filTelGI:SCREEN-VALUE + "*")
                NO-ERROR.
        END.
        ELSE DO:
            FIND PREV GIPrefs
                WHERE GIPrefs.cUtilisateur = "ADMIN"
                and   GIPrefs.cCode = "TEL_GI"
                and   (GIPrefs.filler MATCHES "*" + filTelGI:SCREEN-VALUE + "*"
                OR    GIPrefs.cValeur MATCHES "*" + filTelGI:SCREEN-VALUE + "*")
                NO-ERROR.
        END.
        IF AVAILABLE(GIPrefs) THEN do:
            REPOSITION brwTelGI TO ROWID ROWID(GIPrefs).
        END.
        ELSE DO:
            BELL.
        END.
    END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE SaisiePerso C-Win 
PROCEDURE SaisiePerso :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER cModeRecherche AS CHARACTER NO-UNDO.

    DO WITH FRAME frmFonction:
        
        IF cModeRecherche = "" THEN DO:
            FIND FIRST PersoPrefs
                WHERE PersoPrefs.cUtilisateur = gcUtilisateur
                and   PersoPrefs.cCode = "TEL_PERSO"
                and   (PersoPrefs.filler MATCHES "*" + filTelPerso:SCREEN-VALUE + "*"
                OR    PersoPrefs.cValeur MATCHES "*" + filTelPerso:SCREEN-VALUE + "*")
                NO-ERROR.
        END.
        ELSE IF cModeRecherche = "NEXT" THEN DO:
            FIND NEXT PersoPrefs
                WHERE PersoPrefs.cUtilisateur = gcUtilisateur
                and   PersoPrefs.cCode = "TEL_PERSO"
                and   (PersoPrefs.filler MATCHES "*" + filTelPerso:SCREEN-VALUE + "*"
                OR    PersoPrefs.cValeur MATCHES "*" + filTelPerso:SCREEN-VALUE + "*")
                NO-ERROR.
        END.
        ELSE DO:
            FIND PREV PersoPrefs
                WHERE PersoPrefs.cUtilisateur = gcUtilisateur
                and   PersoPrefs.cCode = "TEL_PERSO"
                and   (PersoPrefs.filler MATCHES "*" + filTelPerso:SCREEN-VALUE + "*"
                OR    PersoPrefs.cValeur MATCHES "*" + filTelPerso:SCREEN-VALUE + "*")
                NO-ERROR.
        END.
        IF AVAILABLE(PersoPrefs) THEN do:
            REPOSITION brwTelPerso TO ROWID ROWID(PersoPrefs).
        END.
        ELSE DO:
            BELL.
        END.
    END.
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

    MESSAGE "Confirmez-vous la suppression de la ligne courante des numéros perso ?"
        VIEW-AS ALERT-BOX QUESTION
        BUTTON YES-NO
        TITLE "Demande de confirmation..."
        UPDATE lReponseSuppression AS LOGICAL.
    IF NOT(lReponseSuppression)  THEN RETURN.

    DO TRANSACTION:
        FIND FIRST PersoPrefs EXCLUSIVE-LOCK
            WHERE ROWID(PersoPrefs) = risauve
            NO-ERROR.
        IF available(PersoPrefs) THEN DELETE PersoPrefs.
    END.
    
    RUN recharger.
    riSauve = (IF AVAILABLE(PersoPrefs) THEN ROWID(PersoPrefs) ELSE ?).
    RUN GereEtat("VIS").
    
    RELEASE Persoprefs.

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
    
    
    /* Controle des zones de saisie */
    DO WITH FRAME frmFonction:
        IF filNumero:SCREEN-VALUE = "" THEN cErreur = cErreur + "%s" + "La valeur du numéro n'est pas renseignée".
        IF filLibelle:SCREEN-VALUE = "" THEN cErreur = cErreur + "%s" + "Le libellé du numéro n'est pas renseigné".
    END.
    
    IF cErreur <> "" THEN DO:
        MESSAGE "Une ou plusieurs zones ne sont pas renseignées : " + replace(cErreur,"%s",CHR(10))
            VIEW-AS ALERT-BOX ERROR
            TITLE "Contrôles..."
            .
        lRetour-ou = FALSE.
        RETURN.
    END.

    DO TRANS:
        FIND FIRST PersoPrefs WHERE rowid(PersoPrefs) = riSauve EXCLUSIVE-LOCK NO-ERROR.
        IF AVAILABLE(PersoPrefs) THEN DO:
            
            /* Ecriture dans la base */
            DO WITH FRAME frmFonction:
                
                PersoPrefs.filler = filLibelle:SCREEN-VALUE.
                PersoPrefs.cValeur = filNumero:SCREEN-VALUE.
                
            END.
        END.
    END. /* Fin transaction */
    
    RELEASE Persoprefs.

    RUN OuvreBrowsePerso.

    RUN GereEtat("VIS").


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

