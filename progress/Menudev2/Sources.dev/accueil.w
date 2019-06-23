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
{includes\i_chaine.i}
{menudev2\includes\menudev2.i}


/* Parameters Definitions ---                                           */

DEFINE INPUT PARAMETER  winGeneral  AS HANDLE NO-UNDO.
DEFINE INPUT PARAMETER  cParametres AS CHARACTER NO-UNDO.
/* Local Variable Definitions ---                                       */

DEFINE VARIABLE dSauvegardeDate AS DATE NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME frmPasses
&Scoped-define BROWSE-NAME BROWSE-1

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES Alarmes

/* Definitions for BROWSE BROWSE-1                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-1 Alarmes.dDate substring(string(Alarmes.iHeure,"9999"),1,2) + ":" + substring(string(Alarmes.iHeure,"9999"),3,2) @ Alarmes.iHeure Agenda.cLibelle   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-1   
&Scoped-define SELF-NAME BROWSE-1
&Scoped-define QUERY-STRING-BROWSE-1 FOR EACH Alarmes WHERE Alarmes.cUtilisateur = gcUtilisateur         AND Alarmes.ltraitee = FALSE         AND Alarmes.lEncours = FALSE        , ~
      FIRST agenda WHERE agenda.cIdent = Alarmes.cIdent         BY Alarmes.dDate BY Alarmes.iHeure
&Scoped-define OPEN-QUERY-BROWSE-1 OPEN QUERY {&SELF-NAME}     FOR EACH Alarmes WHERE Alarmes.cUtilisateur = gcUtilisateur         AND Alarmes.ltraitee = FALSE         AND Alarmes.lEncours = FALSE        , ~
      FIRST agenda WHERE agenda.cIdent = Alarmes.cIdent         BY Alarmes.dDate BY Alarmes.iHeure.
&Scoped-define TABLES-IN-QUERY-BROWSE-1 Alarmes agenda
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-1 Alarmes
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-1 agenda


/* Definitions for FRAME frmalertes                                     */
&Scoped-define OPEN-BROWSERS-IN-QUERY-frmalertes ~
    ~{&OPEN-QUERY-BROWSE-1}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS btnmoins btnplus filMaGI btnpp1 filGi-expert ~
btnpp2 
&Scoped-Define DISPLAYED-OBJECTS filMaGI filGi-expert filajustement 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD DonnePasseGI C-Win 
FUNCTION DonnePasseGI RETURNS CHARACTER
  ( iJour AS INTEGER, iMois AS INTEGER, iAnnee AS INTEGER, iHeure AS INTEGER)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD DonneSaint C-Win 
FUNCTION DonneSaint RETURNS CHARACTER
  ( INPUT dDate-in  AS DATE )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE VARIABLE edtAbsFutures AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL NO-BOX
     SIZE 58 BY 4.29
     FGCOLOR 0 FONT 4 NO-UNDO.

DEFINE VARIABLE edtAbsJour AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL NO-BOX
     SIZE 55 BY 4.29
     FGCOLOR 12 FONT 6 NO-UNDO.

DEFINE VARIABLE filDate AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 33 BY .62
     FGCOLOR 12  NO-UNDO.

DEFINE VARIABLE filLibFutures AS CHARACTER FORMAT "X(256)":U INITIAL "Absence(s) des %jours% à venir" 
      VIEW-AS TEXT 
     SIZE 58 BY .71
     BGCOLOR 8  NO-UNDO.

DEFINE VARIABLE filSaint AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 33 BY .62 NO-UNDO.

DEFINE VARIABLE filSemaine AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 33 BY .62
     FGCOLOR 2  NO-UNDO.

DEFINE RECTANGLE RECT-20
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 1 BY 5.24
     BGCOLOR 8 FGCOLOR 8 .

DEFINE RECTANGLE RECT-21
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 1 BY 5.24
     BGCOLOR 8 FGCOLOR 8 .

DEFINE BUTTON btnAlerte  NO-FOCUS FLAT-BUTTON NO-CONVERT-3D-COLORS
     LABEL "X" 
     SIZE 4 BY .95 TOOLTIP "Activer/Désactiver l'alerte horaire pour ce mémo".

DEFINE BUTTON btnPPapier  NO-FOCUS FLAT-BUTTON
     LABEL "X" 
     SIZE 4 BY .95 TOOLTIP "Envoyer le mémo en cours vers le presse-papier".

DEFINE BUTTON btnVider  NO-FOCUS FLAT-BUTTON
     LABEL "X" 
     SIZE 4 BY .95 TOOLTIP "Vider le mémo en cours".

DEFINE BUTTON btnVoirAlertes  NO-FOCUS FLAT-BUTTON NO-CONVERT-3D-COLORS
     LABEL "X" 
     SIZE 4 BY .95 TOOLTIP "Voir les rappels horaires en cours".

DEFINE VARIABLE edtmemo AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL NO-BOX
     SIZE 159 BY 4.05
     BGCOLOR 15 FGCOLOR 0 FONT 8 NO-UNDO.

DEFINE VARIABLE rsTypeMemo AS INTEGER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Général", 0,
"Lundi", 1,
"Mardi", 2,
"Mercredi", 3,
"Jeudi", 4,
"Vendredi", 5,
"Samedi", 6,
"Dimanche", 7
     SIZE 143 BY .95 NO-UNDO.

DEFINE RECTANGLE RECT-0
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 5 BY .24.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 5 BY .24.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 5 BY .24.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 5 BY .24.

DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 5 BY .24.

DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 5 BY .24.

DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 5 BY .24.

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 5 BY .24.

DEFINE BUTTON btnLogAgenda  NO-FOCUS FLAT-BUTTON
     LABEL "LA" 
     SIZE 3.6 BY .86 TOOLTIP "Voir le fichier log de l'agenda".

DEFINE RECTANGLE RECT-19
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 163 BY 19.05
     BGCOLOR 8 .

DEFINE BUTTON btnmoins  NO-FOCUS FLAT-BUTTON
     LABEL "-" 
     SIZE 4 BY .95 TOOLTIP "- 1 heure sur l'heure courante".

DEFINE BUTTON btnplus  NO-FOCUS FLAT-BUTTON
     LABEL "+" 
     SIZE 4 BY .95 TOOLTIP "+ 1 heure sur l'heure courante".

DEFINE BUTTON btnpp1  NO-FOCUS FLAT-BUTTON
     LABEL "Btn 1" 
     SIZE 4 BY .95 TOOLTIP "Envoyer vers le presse-papier".

DEFINE BUTTON btnpp2  NO-FOCUS FLAT-BUTTON
     LABEL "Btn 1" 
     SIZE 4 BY .95 TOOLTIP "Envoyer vers le presse-papier".

DEFINE VARIABLE filajustement AS INTEGER FORMAT "-9":U INITIAL 0 
     VIEW-AS FILL-IN NATIVE 
     SIZE 4 BY .95 NO-UNDO.

DEFINE VARIABLE filGi-expert AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 14 BY .95 NO-UNDO.

DEFINE VARIABLE filMaGI AS CHARACTER FORMAT "X(256)":U INITIAL "0000000000" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 14 BY .95 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-1 FOR 
      Alarmes, 
      agenda SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-1 C-Win _FREEFORM
  QUERY BROWSE-1 DISPLAY
      Alarmes.dDate FORMAT "99/99/9999":U WIDTH 12.2 COLUMN-LABEL "Date"
      substring(string(Alarmes.iHeure,"9999"),1,2) + ":" + substring(string(Alarmes.iHeure,"9999"),3,2) @ Alarmes.iHeure COLUMN-LABEL "Heure"
      Agenda.cLibelle FORMAT "X(70)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS NO-COLUMN-SCROLLING SIZE 123.6 BY 3.57 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME frmModule
     btnLogAgenda AT ROW 1.48 COL 160
     RECT-19 AT ROW 1.24 COL 2 WIDGET-ID 2
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE 
         BGCOLOR 7 
         TITLE BGCOLOR 2 FGCOLOR 15 "Accueil".

DEFINE FRAME frmalertes
     BROWSE-1 AT ROW 1 COL 1
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 40 ROW 1.48
         SIZE 124 BY 4.76
         TITLE "Prochaines actions planifiées".

DEFINE FRAME frmmemo
     btnVoirAlertes AT ROW 1.24 COL 145 HELP
          "Envoyer vers le presse-papier" WIDGET-ID 24 NO-TAB-STOP 
     rsTypeMemo AT ROW 1 COL 3 NO-LABEL
     btnAlerte AT ROW 1.24 COL 149 HELP
          "Envoyer vers le presse-papier" WIDGET-ID 22 NO-TAB-STOP 
     btnPPapier AT ROW 1.24 COL 153 HELP
          "Envoyer vers le presse-papier" WIDGET-ID 20 NO-TAB-STOP 
     btnVider AT ROW 1.24 COL 157 HELP
          "Envoyer vers le presse-papier" WIDGET-ID 18 NO-TAB-STOP 
     edtmemo AT ROW 2.43 COL 2 NO-LABEL
     RECT-0 AT ROW 1.95 COL 7 WIDGET-ID 2
     RECT-1 AT ROW 1.95 COL 25 WIDGET-ID 4
     RECT-2 AT ROW 1.95 COL 41 WIDGET-ID 6
     RECT-3 AT ROW 1.95 COL 58 WIDGET-ID 8
     RECT-4 AT ROW 1.95 COL 76 WIDGET-ID 10
     RECT-5 AT ROW 1.95 COL 93 WIDGET-ID 12
     RECT-6 AT ROW 1.95 COL 112 WIDGET-ID 14
     RECT-7 AT ROW 1.95 COL 131 WIDGET-ID 16
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3 ROW 13.14
         SIZE 161 BY 6.91
         BGCOLOR 8 
         TITLE "Mémo".

DEFINE FRAME frmPasses
     btnmoins AT ROW 3.62 COL 15 HELP
          "Envoyer vers le presse-papier"
     btnplus AT ROW 3.62 COL 23 HELP
          "Envoyer vers le presse-papier"
     filMaGI AT ROW 1.24 COL 28 RIGHT-ALIGNED NO-LABEL
     btnpp1 AT ROW 1.24 COL 30 HELP
          "Envoyer vers le presse-papier"
     filGi-expert AT ROW 2.43 COL 28 RIGHT-ALIGNED NO-LABEL
     btnpp2 AT ROW 2.43 COL 30 HELP
          "Envoyer vers le presse-papier"
     filajustement AT ROW 3.62 COL 22 RIGHT-ALIGNED NO-LABEL
     "MaGI .............." VIEW-AS TEXT
          SIZE 13 BY .95 AT ROW 1.24 COL 2
     "Gi-Expert .............." VIEW-AS TEXT
          SIZE 13 BY .95 AT ROW 2.43 COL 2
     "heure(s)" VIEW-AS TEXT
          SIZE 8 BY .95 AT ROW 3.62 COL 28
     "Ajustement à" VIEW-AS TEXT
          SIZE 13 BY .95 AT ROW 3.62 COL 2
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3 ROW 1.48
         SIZE 36 BY 4.76
         TITLE "Mots de passe".

DEFINE FRAME frmagenda
     edtAbsJour AT ROW 1.95 COL 44 NO-LABEL WIDGET-ID 4
     edtAbsFutures AT ROW 1.95 COL 102 NO-LABEL WIDGET-ID 6
     filLibFutures AT ROW 1 COL 100 COLON-ALIGNED NO-LABEL WIDGET-ID 12
     filDate AT ROW 1.24 COL 3 NO-LABEL
     filSemaine AT ROW 2.19 COL 5 NO-LABEL
     filSaint AT ROW 3.86 COL 5 NO-LABEL
     "Absence(s) du jour" VIEW-AS TEXT
          SIZE 55 BY .71 AT ROW 1 COL 44 WIDGET-ID 8
          BGCOLOR 8 
     RECT-20 AT ROW 1.1 COL 100 WIDGET-ID 14
     RECT-21 AT ROW 1.1 COL 42 WIDGET-ID 16
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3 ROW 6.48
         SIZE 161 BY 6.43
         TITLE "Ephéméride".


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
         WIDTH              = 167.4
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
ASSIGN FRAME frmagenda:FRAME = FRAME frmModule:HANDLE
       FRAME frmalertes:FRAME = FRAME frmModule:HANDLE
       FRAME frmmemo:FRAME = FRAME frmModule:HANDLE
       FRAME frmPasses:FRAME = FRAME frmModule:HANDLE.

/* SETTINGS FOR FRAME frmagenda
                                                                        */
/* SETTINGS FOR FILL-IN filDate IN FRAME frmagenda
   ALIGN-L                                                              */
ASSIGN 
       filLibFutures:READ-ONLY IN FRAME frmagenda        = TRUE.

/* SETTINGS FOR FILL-IN filSaint IN FRAME frmagenda
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN filSemaine IN FRAME frmagenda
   ALIGN-L                                                              */
/* SETTINGS FOR FRAME frmalertes
                                                                        */
/* BROWSE-TAB BROWSE-1 1 frmalertes */
/* SETTINGS FOR FRAME frmmemo
                                                                        */
/* SETTINGS FOR FRAME frmModule
   Size-to-Fit                                                          */
ASSIGN 
       FRAME frmModule:SCROLLABLE       = FALSE.

/* SETTINGS FOR FRAME frmPasses
   FRAME-NAME                                                           */
/* SETTINGS FOR FILL-IN filajustement IN FRAME frmPasses
   NO-ENABLE ALIGN-R                                                    */
ASSIGN 
       filajustement:READ-ONLY IN FRAME frmPasses        = TRUE.

/* SETTINGS FOR FILL-IN filGi-expert IN FRAME frmPasses
   ALIGN-R                                                              */
ASSIGN 
       filGi-expert:READ-ONLY IN FRAME frmPasses        = TRUE.

/* SETTINGS FOR FILL-IN filMaGI IN FRAME frmPasses
   ALIGN-R                                                              */
ASSIGN 
       filMaGI:READ-ONLY IN FRAME frmPasses        = TRUE.

IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-1
/* Query rebuild information for BROWSE BROWSE-1
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
    FOR EACH Alarmes WHERE Alarmes.cUtilisateur = gcUtilisateur
        AND Alarmes.ltraitee = FALSE
        AND Alarmes.lEncours = FALSE
       ,FIRST agenda WHERE agenda.cIdent = Alarmes.cIdent
        BY Alarmes.dDate BY Alarmes.iHeure.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BROWSE-1 */
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


&Scoped-define SELF-NAME frmagenda
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL frmagenda C-Win
ON RIGHT-MOUSE-DBLCLICK OF FRAME frmagenda /* Ephéméride */
DO:
  
  
  /*  */

    DEFINE VARIABLE cAbsJour AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cAbsFutures AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cTempo AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO.

    RUN DonneAbsences(TRUE,OUTPUT cAbsJour, OUTPUT cAbsFutures).
    IF DonnePreference("PREFS-ABSENCES-JOUR-PREVENIR") = "OUI" THEN
        IF cAbsJour <> "" THEN cTempo = cTempo + cAbsJour.
    IF DonnePreference("PREFS-ABSENCES-FUTURES-PREVENIR") = "OUI" THEN
        IF cAbsFutures <> "" THEN cTempo = cTempo + (IF cAbsJour <> "" THEN "%s%s" ELSE "") + "Seront absents dans les " 
            + STRING(INTEGER(DonnePreference("PREFS-ABSENCES-JOURS"))) + " jours à venir :%s"
            + cAbsFutures.
    RUN AfficheMessageAvecTemporisation("Absences",cTempo,FALSE,0,"OK","",FALSE,OUTPUT cRetour).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-1
&Scoped-define FRAME-NAME frmalertes
&Scoped-define SELF-NAME BROWSE-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-1 C-Win
ON ENTRY OF BROWSE-1 IN FRAME frmalertes
DO:
    lTempo1 = BROWSE-1:DESELECT-ROWS() NO-ERROR.
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-1 C-Win
ON ROW-DISPLAY OF BROWSE-1 IN FRAME frmalertes
DO:
  IF Agenda.cIdent BEGINS "ADMIN" THEN DO:
      Alarmes.dDate:BGCOLOR IN BROWSE BROWSE-1 = iCouleurAdmin.
      Alarmes.iheure:BGCOLOR IN BROWSE BROWSE-1 = iCouleurAdmin.
      agenda.clibelle:BGCOLOR IN BROWSE BROWSE-1 = iCouleurAdmin.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-1 C-Win
ON ROW-ENTRY OF BROWSE-1 IN FRAME frmalertes
DO:
  lTempo1 = BROWSE-1:DESELECT-ROWS() NO-ERROR.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frmmemo
&Scoped-define SELF-NAME btnAlerte
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnAlerte C-Win
ON CHOOSE OF btnAlerte IN FRAME frmmemo /* X */
DO:
    DEFINE BUFFER bMemo FOR memo.

    DO WITH FRAME FrmMemo:
        /* Activation/Désactivation de l'alerte horaire sur le mémo */
        APPLY "LEAVE" TO edtmemo.
        FIND FIRST  bmemo    EXCLUSIVE-LOCK
            WHERE   bmemo.cUtilisateur = gcUtilisateur
            AND     bmemo.ctype = gcTypeMemo
            NO-ERROR.
        IF AVAILABLE(bmemo) THEN DO:   
                bmemo.lalerte = NOT(bmemo.lalerte).
                RUN GereMemos.
        END.
        RELEASE bmemo.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frmModule
&Scoped-define SELF-NAME btnLogAgenda
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnLogAgenda C-Win
ON CHOOSE OF btnLogAgenda IN FRAME frmModule /* LA */
DO:
  OS-COMMAND NO-WAIT VALUE(gcFichierAgenda). 
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frmPasses
&Scoped-define SELF-NAME btnmoins
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnmoins C-Win
ON CHOOSE OF btnmoins IN FRAME frmPasses /* - */
DO:
  IF integer(filAjustement:SCREEN-VALUE) > -9 THEN filAjustement:SCREEN-VALUE = STRING(INTEGER(filAjustement:SCREEN-VALUE) - 1,"-9").
  RUN TopChronoGeneral.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnplus
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnplus C-Win
ON CHOOSE OF btnplus IN FRAME frmPasses /* + */
DO:
    IF integer(filAjustement:SCREEN-VALUE) < 9 THEN filAjustement:SCREEN-VALUE = STRING(INTEGER(filAjustement:SCREEN-VALUE) + 1,"-9").
    RUN TopChronoGeneral.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnpp1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnpp1 C-Win
ON CHOOSE OF btnpp1 IN FRAME frmPasses /* Btn 1 */
DO:
  /* envoyer le code vers le presse papier */
    CLIPBOARD:VALUE = filmagi:SCREEN-VALUE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnpp2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnpp2 C-Win
ON CHOOSE OF btnpp2 IN FRAME frmPasses /* Btn 1 */
DO:
  /* envoyer le code vers le presse papier */
    CLIPBOARD:VALUE = filgi-expert:SCREEN-VALUE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frmmemo
&Scoped-define SELF-NAME btnPPapier
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnPPapier C-Win
ON CHOOSE OF btnPPapier IN FRAME frmmemo /* X */
DO:
  DO WITH FRAME FrmMemo:
      /* envoyer le code vers le presse papier */
        CLIPBOARD:VALUE = edtmemo:SCREEN-VALUE.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnVider
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnVider C-Win
ON CHOOSE OF btnVider IN FRAME frmmemo /* X */
DO:
  DEFINE BUFFER bmemo FOR memo.
  DO WITH FRAME FrmMemo:
      IF TRIM(edtmemo:SCREEN-VALUE) = "" THEN RETURN.
      APPLY "LEAVE" TO edtmemo.
      FIND FIRST  bmemo    EXCLUSIVE-LOCK
          WHERE   bmemo.cUtilisateur = gcUtilisateur
          AND     bmemo.ctype = gcTypeMemo
          NO-ERROR.
      IF AVAILABLE(bmemo) THEN DO:   
          MESSAGE "Voulez-vous supprimer le mémo en cours ?"
              VIEW-AS ALERT-BOX QUESTION 
              BUTTON YES-NO
              TITLE "Confirmation..."
              UPDATE lReponsememo AS LOGICAL.
          IF NOT(lreponsememo) THEN RETURN.
          edtmemo:SCREEN-VALUE = "".
          APPLY "LEAVE" TO edtmemo.
      END.
      RELEASE bmemo.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnVoirAlertes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnVoirAlertes C-Win
ON CHOOSE OF btnVoirAlertes IN FRAME frmmemo /* X */
DO:
    DEFINE VARIABLE lOldBy-Pass AS LOGICAL NO-UNDO.
    lOldBy-Pass = glBy-pass.
    glBy-pass = TRUE.
    RUN DonneOrdre("TOP-GENERAL").
    glBy-pass = lOldBy-Pass.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME edtmemo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL edtmemo C-Win
ON CTRL-A OF edtmemo IN FRAME frmmemo
DO:
  DO WITH FRAME frmModule:
      edtmemo:SET-SELECTION(1,LENGTH(edtmemo:SCREEN-VALUE) + 100) NO-ERROR.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL edtmemo C-Win
ON LEAVE OF edtmemo IN FRAME frmmemo
DO:
    /* Stockage du memo dans la base */
    FIND FIRST  memo    EXCLUSIVE-LOCK
        WHERE   memo.cUtilisateur = gcUtilisateur
        AND     memo.ctype = gcTypeMemo
        NO-ERROR.
    IF NOT(AVAILABLE(memo)) THEN DO:   
        CREATE memo.
        memo.cUtilisateur = gcUtilisateur.
        memo.ctype = gcTypeMemo.
        
    END.
    memo.cValeur = edtmemo:SCREEN-VALUE.
    IF trim(edtmemo:SCREEN-VALUE) = "" THEN memo.lalerte = FALSE.
    RELEASE memo.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rsTypeMemo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rsTypeMemo C-Win
ON VALUE-CHANGED OF rsTypeMemo IN FRAME frmmemo
DO:
    /* Affichage du memo en fonction du jour sélectionné */
    gcTypeMemo = SELF:SCREEN-VALUE.
    RUN AfficheMemo.

    APPLY "ENTRY" TO edtmemo.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frmPasses
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE AfficheMemo C-Win 
PROCEDURE AfficheMemo :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/   
    DO WITH FRAME frmmemo:
        FIND FIRST  memo    NO-LOCK
            WHERE   memo.cUtilisateur = gcUtilisateur
            AND     memo.cType = gcTypeMemo
            NO-ERROR.
        edtmemo:SCREEN-VALUE = "".
        IF AVAILABLE(memo) THEN DO:
            edtmemo:SCREEN-VALUE = memo.cValeur.
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
  ENABLE btnLogAgenda RECT-19 
      WITH FRAME frmModule IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-frmModule}
  DISPLAY filMaGI filGi-expert filajustement 
      WITH FRAME frmPasses IN WINDOW C-Win.
  ENABLE btnmoins btnplus filMaGI btnpp1 filGi-expert btnpp2 
      WITH FRAME frmPasses IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-frmPasses}
  ENABLE BROWSE-1 
      WITH FRAME frmalertes IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-frmalertes}
  DISPLAY edtAbsJour edtAbsFutures filLibFutures filDate filSemaine filSaint 
      WITH FRAME frmagenda IN WINDOW C-Win.
  ENABLE RECT-20 RECT-21 edtAbsJour edtAbsFutures filLibFutures filDate 
         filSemaine filSaint 
      WITH FRAME frmagenda IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-frmagenda}
  DISPLAY rsTypeMemo edtmemo 
      WITH FRAME frmmemo IN WINDOW C-Win.
  ENABLE btnVoirAlertes rsTypeMemo RECT-0 RECT-1 btnAlerte RECT-2 btnPPapier 
         RECT-3 btnVider RECT-4 RECT-5 RECT-6 RECT-7 edtmemo 
      WITH FRAME frmmemo IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-frmmemo}
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
                RUN Recharger.
                /* Affichage de la frame principale */
                VIEW FRAME frmModule.
                IF DonneEtSupprimeParametre("ACCUEIL-RECHARGER") = "OUI" THEN DO:
                    RUN Recharger.
                END.
                FRAME frmModule:MOVE-TO-TOP().
                RUN GereEcran.
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
            WHEN "MDP-PP" THEN DO:
                CLIPBOARD:VALUE = filmagi:SCREEN-VALUE IN FRAME frmPasses.
            END.
        END CASE. /* fin du case */
    END. /* fin du do iboucle */

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
    DEFINE OUTPUT PARAMETER lRetour-ou AS LOGICAL INIT TRUE.


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
    gcAideRaf = "Recharger l'écran".
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE GereEcran C-Win 
PROCEDURE GereEcran :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    /* Gestion du browse des alertes */
    {&OPEN-QUERY-BROWSE-1}
    lTempo1 = BrOWSE-1:DESELECT-ROWS() IN FRAME frmAlertes NO-ERROR.
    
    /* Gestion du bouton log agenda */
    btnLogAgenda:MOVE-TO-TOP() IN FRAME frmModule.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE GereMemos C-Win 
PROCEDURE GereMemos :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE BUFFER bmemo FOR memo.
    DEFINE VARIABLE iCouleur AS INTEGER NO-UNDO.

    DO WITH FRAME frmmemo:
        FOR EACH  bmemo    NO-LOCK
            WHERE   bmemo.cUtilisateur = gcUtilisateur
            :
            iCouleur = ?.
            IF TRIM(bmemo.cValeur) <> "" THEN DO:
                iCouleur = 10.
                IF bmemo.lAlerte THEN iCouleur = 12.
            END.
            CASE bmemo.cType :
                WHEN "0" THEN rect-0:BGCOLOR = iCouleur.
                WHEN "1" THEN rect-1:BGCOLOR = iCouleur.
                WHEN "2" THEN rect-2:BGCOLOR = iCouleur.
                WHEN "3" THEN rect-3:BGCOLOR = iCouleur.
                WHEN "4" THEN rect-4:BGCOLOR = iCouleur.
                WHEN "5" THEN rect-5:BGCOLOR = iCouleur.
                WHEN "6" THEN rect-6:BGCOLOR = iCouleur.
                WHEN "7" THEN rect-7:BGCOLOR = iCouleur.
            END CASE.
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
    DEFINE VARIABLE iTempo AS INTEGER NO-UNDO.
    
    Mlog("Initialisation").
    
    /* Positionnement de la fenetre */
    FRAME frmModule:COLUMN = gdPositionXModule.
    FRAME frmModule:ROW = gdPositionYModule.
    FRAME frmModule:HEIGHT = gdHauteur.
    FRAME frmModule:WIDTH = gdLargeur.

    /* Par defaut : memo général */
    gcTypeMemo = "0".
    
    /* Recherche du memo du jour */
    IF not(DonnePreference("PREF-MEMOGENE") = "OUI") THEN gcTypeMemo = STRING(DonneNumeroJour(TODAY)).

    /* Chargement des images */
    DO WITH FRAME frmPasses:
        ENABLE ALL.
        /* Chargement des images */
        btnpp1:LOAD-IMAGE(gcRepertoireRessources + "fleche02.jpg").
        btnpp2:LOAD-IMAGE(gcRepertoireRessources + "fleche02.jpg").
        btnMoins:LOAD-IMAGE(gcRepertoireRessources + "moins.bmp").
        btnPlus:LOAD-IMAGE(gcRepertoireRessources + "plus.bmp").
    END.

    DO WITH FRAME frmmemo: 
        ENABLE ALL.
        /* Chargement des images */
        btnVider:LOAD-IMAGE(gcRepertoireRessources + "Supprime05.bmp").
        btnppapier:LOAD-IMAGE(gcRepertoireRessources + "fleche02.jpg").
        btnAlerte:LOAD-IMAGE(gcRepertoireRessources + "cloche02.jpg").
        btnVoirAlertes:LOAD-IMAGE(gcRepertoireRessources + "loupe.bmp").
        /* Récupération du mémo de l'utilisateur */
        rsTypeMemo:SCREEN-VALUE = gcTypeMemo.
        RUN AfficheMemo.
    END.
    
    /* pour déselectionner le browse des alarmes */
    APPLY "entry" TO BROWSE-1 IN FRAME frmAlertes.


    /* Bouton Log Agenda */
    btnLogAgenda:SENSITIVE = TRUE.
    btnLogAgenda:LOAD-IMAGE(gcRepertoireImages + "infos.jpg").

    DO WITH FRAME frmagenda:
        filLibFutures:SCREEN-VALUE = "Absence(s) des " + DonnePreference("PREFS-ABSENCES-JOURS") + " jours à venir".
        edtAbsJour:SENSITIVE = TRUE.
        edtAbsFutures:SENSITIVE = TRUE.
    END.

    /* Gestion générale de l'écran */
    RUN GereEcran.

    RUN TopChronoGeneral.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MajListeAlarmes C-Win 
PROCEDURE MajListeAlarmes :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DO WITH FRAME frmAlertes:
        /* rechargement de la liste des notifications */
        RUN ChargeAlarmes.
        {&OPEN-QUERY-BROWSE-1}
        lTempo1 = BROWSE-1:DESELECT-ROWS() NO-ERROR.
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
    {&OPEN-BROWSERS-IN-QUERY-frmModule}
    HIDE c-win.

    BROWSE-1:SENSITIVE IN FRAME frmalertes = TRUE .
       
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
    DEFINE VARIABLE cAbsJour AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cAbsFutures AS CHARACTER NO-UNDO.
    
    RUN Initialisation.
    DO WITH FRAME frmAgenda:
        filDate:SCREEN-VALUE = CentreChaine(DonneDateLettre(TODAY),45).
        filSemaine:SCREEN-VALUE = CentreChaine("Semaine : " + string(DonneSemaine(TODAY)),45).
        filSaint:SCREEN-VALUE = CentreChaine("St(e) : " + DonneSaint(TODAY),45).
        
        RUN DonneAbsences(TRUE,OUTPUT cAbsJour, OUTPUT cAbsFutures).
        IF cAbsJour = "" THEN do:
            cAbsJour = "Aucune absence signalée pour aujourd'hui".
            edtAbsJour:FGCOLOR = 2.
        END.
        ELSE DO:
            edtAbsJour:FGCOLOR = 12.
        END.
        IF cAbsFutures = "" THEN do:
            cAbsFutures = "Aucune absence signalée pour les " + string(integer(DonnePreference("PREFS-ABSENCES-JOURS"))) + " prochains jours".
        END.
        edtAbsJour:SCREEN-VALUE = cAbsJour.
        edtAbsFutures:SCREEN-VALUE = cAbsFutures.
    END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE TopChronoGeneral C-Win 
PROCEDURE TopChronoGeneral :
/* Gestion du chrono général */
    DEFINE VARIABLE iJour   AS INTEGER  NO-UNDO.
    DEFINE VARIABLE iNumeroJour AS INTEGER NO-UNDO.
    DEFINE VARIABLE lTopHoraire AS LOGICAL NO-UNDO.
    DEFINE VARIABLE iMois   AS INTEGER  NO-UNDO.
    DEFINE VARIABLE iAnnee2  AS INTEGER  NO-UNDO.
    DEFINE VARIABLE iAnnee4  AS INTEGER  NO-UNDO.
    DEFINE VARIABLE iHeure  AS INTEGER  NO-UNDO.
    DEFINE VARIABLE iDebutRappelHoraire AS INTEGER NO-UNDO.
    DEFINE VARIABLE iFinRappelHoraire AS INTEGER NO-UNDO.
    DEFINE BUFFER bmemo FOR memo.
    DEFINE VARIABLE cMessageAfaire  AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE cMessageActions  AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE lAlertePourCetteListe  AS LOGICAL    NO-UNDO.
    DEFINE VARIABLE lAlerteMemo AS LOGICAL NO-UNDO.
   
    DO WITH FRAME frmPasses:
        iJour = INTEGER(DAY(TODAY)).
        iNumeroJour = INTEGER(WEEKDAY(TODAY)).
        lTopHoraire = (INTEGER(ENTRY(2,STRING(TIME,"hh:mm:ss"),":")) = 0) OR glBy-Pass.
        iMois = INTEGER(MONTH(TODAY)).
        iAnnee2 = INTEGER(ENTRY(3,STRING(TODAY,"99/99/99"),"/")).
        iAnnee4 = INTEGER(ENTRY(3,STRING(TODAY,"99/99/9999"),"/")).
        iHeure = INTEGER(ENTRY(1,STRING(TIME,"hh:mm:ss"),":")) + integer(filAjustement:SCREEN-VALUE).
        
        /* Actualisation des mots de passe */
        cTempo1 = DonnePasseGI(iJour,iMois,iAnnee2,iheure).
        cTempo2 = STRING(iJour * iMois * iAnnee4).
        
        filmagi:SCREEN-VALUE = cTempo1.
        filGi-expert:SCREEN-VALUE = cTempo2.
        
        /* Gestion Ephemeride */    
        IF TODAY <> dSauvegardeDate OR dSauvegardeDate = ? THEN DO WITH FRAME frmAgenda:
            filDate:SCREEN-VALUE = CentreChaine(DonneDateLettre(TODAY),45).
            filSemaine:SCREEN-VALUE = CentreChaine("Semaine : " + string(DonneSemaine(TODAY)),45).
            filSaint:SCREEN-VALUE = CentreChaine("St(e) : " + DonneSaint(TODAY),45).
            /* Gestion du report des memos avec rappel horaire */
            IF dSauvegardeDate <> ? THEN DO:
                /* Recherche d'un memo avec rappel horaire */
                FIND FIRST  memo EXCLUSIVE-LOCK
                    WHERE   memo.cUtilisateur = gcUtilisateur
                    AND     memo.cType = STRING(DonneNumeroJour(dSauvegardeDate))
                    AND     memo.cValeur <> ""
                    AND     memo.lalerte = TRUE                    
                    NO-ERROR.
                IF AVAILABLE(memo) THEN DO:
                    /* Report dans le memo general */
                    FIND FIRST  bmemo EXCLUSIVE-LOCK
                        WHERE   bmemo.cUtilisateur = gcUtilisateur
                        AND     bmemo.cType = "0"
                        NO-ERROR.
                    IF AVAILABLE(bmemo) THEN DO:
                        bmemo.cValeur = "Report Mémo du : " + STRING(dSauvegardeDate,"99/99/9999")
                            + CHR(10) + memo.cvaleur 
                            + CHR(10) + FILL("-",50)
                            + CHR(10) + bmemo.cValeur
                            .
                        bmemo.lalerte = TRUE.
                        memo.cvaleur = "".
                        memo.lalerte = FALSE.
                    END.
                END.
                RELEASE bmemo.
                RELEASE memo.
            END.

            dSauvegardeDate = TODAY.
            /*RUN DonneOrdre("AFFICHE-DATE=" + trim(filDate:SCREEN-VALUE) + " - " + trim(filSemaine:SCREEN-VALUE)).*/
            RUN DonneOrdre("AFFICHE-DATE=" + string(DonneSemaine(TODAY))).
            /* Purge du fichier log */
            MLog("#PURGE#").
        
            /* On change de jour, on repositionne le memo sur le bon jour */
            /* Par defaut : memo général */
            gcTypeMemo = "0".
            /* Recherche du memo du jour */
            IF not(DonnePreference("PREF-MEMOGENE") = "OUI") THEN gcTypeMemo = STRING(DonneNumeroJour(TODAY)).
            rsTypeMemo:SCREEN-VALUE IN FRAME FrmMemo = gcTypeMemo.
            RUN AfficheMemo.

        END.
    
        IF integer(filAjustement:SCREEN-VALUE) <> 0 THEN DO:
            filmagi:BGCOLOR = 14.
        END.
        ELSE DO:
            filmagi:BGCOLOR = ?.
        END.
        filAjustement:BGCOLOR = filmagi:BGCOLOR.
    END.
    RUN MajListeAlarmes.

     /* Gestion des rappel horaires */
     IF lTopHoraire THEN DO:
         iNumeroJour = iNumeroJour - 1.
         IF iNumeroJour = 0 THEN iNumeroJour = 7.

         /* Pas d'alerte horaire avant 09h00 ou après 17h00 ou paramètrage */
         iDebutRappelHoraire = INTEGER(DonnePreference("PREF-DEBUTRAPPELHORAIRE")).
         IF iDebutRappelHoraire = 0 THEN iDebutRappelHoraire = 9.
         iFinRappelHoraire = INTEGER(DonnePreference("PREF-FINRAPPELHORAIRE")).
         IF iFinRappelHoraire = 0 THEN iFinRappelHoraire = 17.

         IF ((INTEGER(ENTRY(1,STRING(TIME,"hh:mm:ss"),":")) >= iDebutRappelHoraire AND INTEGER(ENTRY(1,STRING(TIME,"hh:mm:ss"),":")) <= iFinRappelHoraire)) OR glBy-pass THEN DO:
            /* Memo du jour */
            FIND FIRST  memo    NO-LOCK
                WHERE   memo.cUtilisateur = gcUtilisateur
                AND     memo.ctype = STRING(iNumeroJour)
                AND     memo.lalerte = TRUE
                NO-ERROR.
            IF AVAILABLE(memo) THEN DO:  
                RUN DeclencheRappelHoraire(memo.cValeur).
            END.
            /* Memo général */
            FIND FIRST  memo    NO-LOCK
                WHERE   memo.cUtilisateur = gcUtilisateur
                AND     memo.ctype = "0"
                AND     memo.lalerte = TRUE
                NO-ERROR.
            IF AVAILABLE(memo) THEN DO:  
                RUN DeclencheRappelHoraire(memo.cValeur).
            END.

            /* Memo des 'A Faire' */
            lAlerteMemo = FALSE.
            cMessageAFaire = "".
            Mlog("Jour : " + string(iNumeroJour)).
            FOR EACH    AFaire_Action NO-LOCK
                WHERE   AFaire_Action.cUtilisateur = gcUtilisateur
                AND     AFaire_Action.lRappelHoraire
               ,FIRST   AFaire_Lien NO-LOCK
                WHERE   AFaire_Lien.cUtilisateur = AFaire_Action.cUtilisateur
                AND     AFaire_Lien.iNumeroAction = AFaire_Action.iNumeroAction
               ,FIRST   AFaire_Liste NO-LOCK
                WHERE   AFaire_Liste.cUtilisateur = AFaire_Lien.cUtilisateur
                AND     AFaire_Liste.iNumeroListe = AFaire_Lien.iNumeroListe
                BY AFaire_Liste.cLibelleListe BY AFaire_Lien.iOrdreLien
                :
                Mlog("Action - " + AFaire_Liste.cLibelleListe + "/" + AFaire_Action.cLibelleAction + " : " + AFaire_Liste.cFiller1).
                /* Ne faire le rappel que si il est demandé tous les jours ou si on est le bon jour */
                IF AFaire_Liste.cFiller1 <> "0" AND AFaire_Liste.cFiller1 <> string(iNumeroJour) THEN NEXT.
                Mlog("A rappeler").
                cMessageAFaire = cMessageAFaire + (IF cMessageAFaire <> "" THEN CHR(10) ELSE "") + AFaire_Liste.cLibelleListe + " --> " + AFaire_Action.cLibelleAction.
                
                lAlerteMemo = TRUE.
            END.
            IF lAlerteMemo THEN DO:  
                RUN DeclencheRappelHoraire2(cMessageAFaire).
            END.
         END.
     END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE TopChronoPartiel C-Win 
PROCEDURE TopChronoPartiel :
/* Gestion du chrono Partiel */

    IF glModificationAlarmes THEN DO:
        glModificationAlarmes = FALSE.
        RUN MajListeAlarmes.
    END.
    RUN GereMemos.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION DonnePasseGI C-Win 
FUNCTION DonnePasseGI RETURNS CHARACTER
  ( iJour AS INTEGER, iMois AS INTEGER, iAnnee AS INTEGER, iHeure AS INTEGER) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
    DEFINE VARIABLE cRetour AS CHARACTER    NO-UNDO.

    cTempo1 = STRING(iMois,"99") + STRING(iJour,"99") + STRING(iAnnee,"99") + STRING(iHeure,"99").
    cTempo2 = STRING(99999999 - INTEGER(cTempo1)).
        
    iTempo1 = 0.

    DO iBoucle = 1 TO LENGTH(cTEmpo2):
        iTempo1 = iTempo1 + INTEGER(SUBSTRING(cTempo2,iBoucle,1)).
    END.

    cTempo1 = cTempo2 + STRING(iTempo1,"99").

    RETURN cTempo1.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION DonneSaint C-Win 
FUNCTION DonneSaint RETURNS CHARACTER
  ( INPUT dDate-in  AS DATE ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
    DEFINE VARIABLE iJour   AS INTEGER  NO-UNDO.
    DEFINE VARIABLE iMois   AS INTEGER  NO-UNDO.
    DEFINE VARIABLE cRetour AS CHARACTER    NO-UNDO INIT "".

    iJour = DAY(dDate-in).
    iMois = MONTH(dDate-in).

    FIND FIRST  saints  NO-LOCK
        WHERE   saints.ijour = iJour
        AND     saints.iMois = iMois
        NO-ERROR.
    IF AVAILABLE(saints) THEN cRetour = saints.cNom.
        

    RETURN cRetour.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

