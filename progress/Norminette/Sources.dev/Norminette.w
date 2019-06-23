&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
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
{includes\i_fichier.i}
{includes\i_html.i}
{Norminette\includes\Norminette.i NEW}

/* Parameters Definitions ---                                           */

    &scoped-define  Couleur_General     04 /*03  */
    &scoped-define  Couleur_Code        02  
    &scoped-define  Couleur_Procedure   09  
    &scoped-define  Couleur_Os          12  

/* Local Variable Definitions ---                                       */

DEFINE VARIABLE giCouleur AS INTEGER NO-UNDO.
DEFINE VARIABLE gcFichieraTraiter AS CHARACTER NO-UNDO.
DEFINE VARIABLE gcFichierTempo AS CHARACTER NO-UNDO.
DEFINE VARIABLE gcFichierRsultat AS CHARACTER NO-UNDO.
DEFINE VARIABLE glAuto AS LOGICAL NO-UNDO.
DEFINE VARIABLE glRechercheEnCours AS LOGICAL NO-UNDO.
DEFINE VARIABLE gcFichierDebug AS CHARACTER NO-UNDO.
DEFINE VARIABLE gcOldFichier AS CHARACTER NO-UNDO.
DEFINE VARIABLE ghBrowse AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE gcRepertoireDialog AS CHARACTER NO-UNDO.
DEFINE VARIABLE giCompteurTotal AS INTEGER NO-UNDO.
DEFINE VARIABLE gcseparateur AS CHARACTER NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME frmFond
&Scoped-define BROWSE-NAME brwAnomalies

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES gttAnomalies gttcriteres

/* Definitions for BROWSE brwAnomalies                                  */
&Scoped-define FIELDS-IN-QUERY-brwAnomalies gttAnomalies.iLigne gttAnomalies.cBloc gttAnomalies.cAnomalie   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brwAnomalies   
&Scoped-define SELF-NAME brwAnomalies
&Scoped-define OPEN-QUERY-brwAnomalies     DO WITH FRAME frmFond:         OPEN QUERY brwAnomalies FOR EACH gttAnomalies         WHERE (gttAnomalies.clibelleFiltre = trim(entry(1, ~
      cmbfiltre:SCREEN-VALUE, ~
      gcSeparateur)) OR trim(entry(1, ~
      cmbfiltre:SCREEN-VALUE, ~
      gcSeparateur)) = "-").     END.
&Scoped-define TABLES-IN-QUERY-brwAnomalies gttAnomalies
&Scoped-define FIRST-TABLE-IN-QUERY-brwAnomalies gttAnomalies


/* Definitions for BROWSE brwcritere                                    */
&Scoped-define FIELDS-IN-QUERY-brwcritere gttcriteres.lSelection gttcriteres.cLibelle   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brwcritere   
&Scoped-define SELF-NAME brwcritere
&Scoped-define QUERY-STRING-brwcritere FOR EACH gttcriteres
&Scoped-define OPEN-QUERY-brwcritere OPEN QUERY {&SELF-NAME} FOR EACH gttcriteres.
&Scoped-define TABLES-IN-QUERY-brwcritere gttcriteres
&Scoped-define FIRST-TABLE-IN-QUERY-brwcritere gttcriteres


/* Definitions for FRAME frmFond                                        */
&Scoped-define OPEN-BROWSERS-IN-QUERY-frmFond ~
    ~{&OPEN-QUERY-brwAnomalies}~
    ~{&OPEN-QUERY-brwcritere}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS btnImprimer rctBoutons btnDossier cmbFichier ~
filRecherche btnraz2 btnPrec btnSuiv cmbFiltre btnraz brwcritere ~
brwAnomalies btnLancer edtAide btnQuitter 
&Scoped-Define DISPLAYED-OBJECTS cmbFichier filRecherche cmbFiltre edtAide 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.

/* Menu Definitions                                                     */
DEFINE SUB-MENU m_Fichier 
       MENU-ITEM m_Ouvrir_un_fichier_à_traiter LABEL "Ouvrir un fichier à traiter"
       RULE
       MENU-ITEM m_Quitter      LABEL "Quitter"       .

DEFINE SUB-MENU m_Préférences 
       MENU-ITEM m_Demander_confirmation_avant LABEL "Demander confirmation avant de quitter"
              TOGGLE-BOX
       MENU-ITEM m_Liste_des_critères_avec_cou LABEL "Liste des critères en couleurs"
              TOGGLE-BOX
       MENU-ITEM m_Se_positionner_sur_le_critè LABEL "Se positionner sur le critère correspondant à l'anomalie"
              TOGGLE-BOX
       MENU-ITEM m_Edition_via_Word_au_lieu_du LABEL "Edition via Word au lieu du navigateur"
              TOGGLE-BOX
       MENU-ITEM m_Efacer_les_fichiers_de_trav LABEL "Efacer les fichiers de travail"
              TOGGLE-BOX
       MENU-ITEM m_Générer_le_fichier_de_debug LABEL "Générer le fichier de debug de la norminette"
              TOGGLE-BOX
       MENU-ITEM m_Activer_le_log_au_chargemen LABEL "Activer le log au chargement du fichier"
              TOGGLE-BOX.

DEFINE SUB-MENU m_Admin 
       MENU-ITEM m_Editer_le_fichier_des_critè LABEL "Editer le fichier des critères"
       MENU-ITEM m_Editer_le_fichier_des_param LABEL "Editer le fichier des paramètres"
       RULE
       MENU-ITEM m_Voir_le_fichier_debug_de_la LABEL "Editer le fichier debug de la norminette".

DEFINE SUB-MENU m_item 
       MENU-ITEM m_Aide         LABEL "Aide"          
              DISABLED.

DEFINE MENU MENU-BAR-C-Win MENUBAR
       SUB-MENU  m_Fichier      LABEL "Fichier"       
       SUB-MENU  m_Préférences  LABEL "Préférences"   
       SUB-MENU  m_Admin        LABEL "Admin"         
       SUB-MENU  m_item         LABEL "?"             .

DEFINE MENU POPUP-MENU-brwAnomalies 
       MENU-ITEM m_Désactiver_le_critère_corre LABEL "Positionner la liste des critères sur celui correspondant à cette anomalie"
       RULE
       MENU-ITEM m_Filtrer_la_liste_sur_cette_ LABEL "Filtrer la liste sur cette anomalie"
       RULE
       MENU-ITEM m_Fermer2      LABEL "Fermer"        .

DEFINE MENU POPUP-MENU-cmbFichier 
       MENU-ITEM m_Supprimer_ce_fichier_de_la_ LABEL "Supprimer ce fichier de l'historique des fichiers traités"
       RULE
       MENU-ITEM m_Effacer_lhistorique_des_fic LABEL "Effacer l'historique des fichiers traités"
       RULE
       MENU-ITEM m_Fermer       LABEL "Fermer"        .


/* Definitions of the field level widgets                               */
DEFINE BUTTON btnDossier 
     LABEL "dos" 
     SIZE 5 BY 1.24 TOOLTIP "Recherche du fichier à traiter".

DEFINE BUTTON btnImprimer  NO-FOCUS FLAT-BUTTON
     LABEL "Imp" 
     SIZE-PIXELS 40 BY 40 TOOLTIP "Imprimer les résultats de l'analyse".

DEFINE BUTTON btnLancer  NO-FOCUS FLAT-BUTTON
     LABEL "run" 
     SIZE-PIXELS 40 BY 40 TOOLTIP "Lancer l'analyse".

DEFINE BUTTON btnPrec 
     LABEL "<" 
     SIZE 4 BY 1.24 TOOLTIP "Rechercher l'occurence précédente".

DEFINE BUTTON btnQuitter  NO-FOCUS FLAT-BUTTON
     LABEL "qui" 
     SIZE-PIXELS 40 BY 40 TOOLTIP "Quitter la norminette".

DEFINE BUTTON btnraz 
     LABEL "raz" 
     SIZE 5 BY 1.24 TOOLTIP "Remise à blanc du filtre".

DEFINE BUTTON btnraz2 
     LABEL "raz" 
     SIZE 5 BY 1.24 TOOLTIP "Remise à blanc de la zone de recherche".

DEFINE BUTTON btnSuiv 
     LABEL ">" 
     SIZE 4 BY 1.24 TOOLTIP "Rechercher l'occurence suivante".

DEFINE VARIABLE cmbFichier AS CHARACTER FORMAT "X(256)" 
     VIEW-AS COMBO-BOX INNER-LINES 25
     DROP-DOWN-LIST
     SIZE 200 BY 1
     FONT 10 NO-UNDO.

DEFINE VARIABLE cmbFiltre AS CHARACTER FORMAT "X(256)" 
     VIEW-AS COMBO-BOX SORT INNER-LINES 25
     LIST-ITEMS "Item 1" 
     DROP-DOWN-LIST
     SIZE 145 BY 1
     FONT 10 NO-UNDO.

DEFINE VARIABLE edtAide AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 176 BY 2.14 TOOLTIP "Explication de l'anomalie"
     FGCOLOR 12 FONT 10 NO-UNDO.

DEFINE VARIABLE filRecherche AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 33 BY 1.24
     FONT 10 NO-UNDO.

DEFINE RECTANGLE rctBoutons
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 26 BY 2.71
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brwAnomalies FOR 
      gttAnomalies SCROLLING.

DEFINE QUERY brwcritere FOR 
      gttcriteres SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brwAnomalies
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brwAnomalies C-Win _FREEFORM
  QUERY brwAnomalies DISPLAY
      gttAnomalies.iLigne  FORMAT ">>>>>9" COLUMN-LABEL "Ligne"
gttAnomalies.cBloc   FORMAT "x(32)" COLUMN-LABEL "Bloc"
gttAnomalies.cAnomalie FORMAT "x(135)" COLUMN-LABEL "Anomalie"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 176 BY 25
         FONT 11
         TITLE "Anomalie(s) potentielle(s)" ROW-HEIGHT-CHARS .65 FIT-LAST-COLUMN.

DEFINE BROWSE brwcritere
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brwcritere C-Win _FREEFORM
  QUERY brwcritere DISPLAY
      gttcriteres.lSelection COLUMN-LABEL "X" FORMAT "X/" WIDTH  2
gttcriteres.cLibelle COLUMN-LABEL "Action" FORMAT "x(80)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-LABELS NO-ROW-MARKERS SEPARATORS SIZE 80 BY 27.14
         FGCOLOR 15 FONT 6
         TITLE FGCOLOR 15 "Critères" ROW-HEIGHT-CHARS .65 FIT-LAST-COLUMN TOOLTIP "Double-clic pour activer/désactiver ce critère".


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME frmFond
     btnImprimer AT Y 11 X 90 WIDGET-ID 4
     btnDossier AT ROW 1.19 COL 254 WIDGET-ID 14
     cmbFichier AT ROW 1.24 COL 51 COLON-ALIGNED NO-LABEL WIDGET-ID 36
     filRecherche AT ROW 2.67 COL 51 COLON-ALIGNED NO-LABEL WIDGET-ID 18
     btnraz2 AT ROW 2.67 COL 87 WIDGET-ID 34
     btnPrec AT ROW 2.67 COL 92 WIDGET-ID 20
     btnSuiv AT ROW 2.67 COL 96 WIDGET-ID 22
     cmbFiltre AT ROW 2.67 COL 106 COLON-ALIGNED NO-LABEL WIDGET-ID 24
     btnraz AT ROW 2.67 COL 254 WIDGET-ID 26
     brwcritere AT ROW 4.33 COL 3 WIDGET-ID 200
     brwAnomalies AT ROW 4.33 COL 84 WIDGET-ID 300
     btnLancer AT Y 11 X 50 WIDGET-ID 12
     edtAide AT ROW 29.33 COL 84 NO-LABEL WIDGET-ID 32
     btnQuitter AT Y 11 X 10 WIDGET-ID 6
     "Filtre" VIEW-AS TEXT
          SIZE 6 BY .95 AT ROW 2.91 COL 101 WIDGET-ID 42
          FONT 6
     "Rechercher" VIEW-AS TEXT
          SIZE 14 BY .95 AT ROW 2.91 COL 38 WIDGET-ID 40
          FONT 6
     "Fichier à analyser" VIEW-AS TEXT
          SIZE 21 BY .95 AT ROW 1.48 COL 32 WIDGET-ID 38
          FONT 6
     rctBoutons AT ROW 1.14 COL 2 WIDGET-ID 8
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 260.6 BY 30.95 WIDGET-ID 100.


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
         TITLE              = "Norminette - &1 - Recherche du non respect des normes et des défauts récurrents"
         HEIGHT             = 30.62
         WIDTH              = 260.6
         MAX-HEIGHT         = 47.43
         MAX-WIDTH          = 384
         VIRTUAL-HEIGHT     = 47.43
         VIRTUAL-WIDTH      = 384
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

ASSIGN {&WINDOW-NAME}:MENUBAR    = MENU MENU-BAR-C-Win:HANDLE.
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW C-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME frmFond
   FRAME-NAME                                                           */
/* BROWSE-TAB brwcritere btnraz frmFond */
/* BROWSE-TAB brwAnomalies brwcritere frmFond */
ASSIGN 
       brwAnomalies:POPUP-MENU IN FRAME frmFond             = MENU POPUP-MENU-brwAnomalies:HANDLE
       brwAnomalies:COLUMN-RESIZABLE IN FRAME frmFond       = TRUE.

ASSIGN 
       cmbFichier:POPUP-MENU IN FRAME frmFond       = MENU POPUP-MENU-cmbFichier:HANDLE.

IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brwAnomalies
/* Query rebuild information for BROWSE brwAnomalies
     _START_FREEFORM
    DO WITH FRAME frmFond:
        OPEN QUERY brwAnomalies FOR EACH gttAnomalies
        WHERE (gttAnomalies.clibelleFiltre = trim(entry(1,cmbfiltre:SCREEN-VALUE,gcSeparateur)) OR trim(entry(1,cmbfiltre:SCREEN-VALUE,gcSeparateur)) = "-").
    END.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE brwAnomalies */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brwcritere
/* Query rebuild information for BROWSE brwcritere
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH gttcriteres.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE brwcritere */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON END-ERROR OF C-Win /* Norminette - 1 - Recherche du non respect des normes et des défauts récurrents */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON WINDOW-CLOSE OF C-Win /* Norminette - 1 - Recherche du non respect des normes et des défauts récurrents */
DO:
  APPLY "CHOOSE" TO btnQuitter IN FRAME frmfond.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brwAnomalies
&Scoped-define SELF-NAME brwAnomalies
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwAnomalies C-Win
ON VALUE-CHANGED OF brwAnomalies IN FRAME frmFond /* Anomalie(s) potentielle(s) */
DO:
    edtAide:SCREEN-VALUE = "".
    IF AVAILABLE gttAnomalies THEN DO:
        edtAide:SCREEN-VALUE = gttAnomalies.cAide. 
        IF glPositionCritere THEN DO:
            FOR FIRST   gttcriteres
                WHERE   gttcriteres.cCode = gttAnomalies.cCritere
                :
                REPOSITION brwCritere TO RECID RECID(gttCriteres).
            END.
        END.
    END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brwcritere
&Scoped-define SELF-NAME brwcritere
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwcritere C-Win
ON DEFAULT-ACTION OF brwcritere IN FRAME frmFond /* Critères */
DO:
  IF gttcriteres.iordre = 0 THEN RETURN.
  gttcriteres.lselection = NOT gttcriteres.lselection.
  brwCritere:REFRESH().
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwcritere C-Win
ON ROW-DISPLAY OF brwcritere IN FRAME frmFond /* Critères */
DO:
    
    IF glCouleursCritere THEN DO:
        IF gttcriteres.cType = "G" THEN giCouleur = {&Couleur_General}.
        IF gttcriteres.cType = "C" THEN giCouleur = {&Couleur_Code}.
        IF gttcriteres.cType = "P" THEN giCouleur = {&Couleur_Procedure}.
        IF gttcriteres.cType = "O" THEN giCouleur = {&Couleur_Os}.
    END.
    ELSE DO:
        giCouleur = 15.
        IF gttCriteres.iOrdre = 0 THEN do:
            giCouleur = 7.
            ASSIGN
                gttcriteres.lselection:FGCOLOR IN BROWSE brwCritere = 15
                gttcriteres.cLibelle:FGCOLOR IN BROWSE brwCritere = 15
                .
        END.
        ELSE DO:
            ASSIGN
                gttcriteres.lselection:FGCOLOR IN BROWSE brwCritere = 0
                gttcriteres.cLibelle:FGCOLOR IN BROWSE brwCritere = 0
                .
        END.
    END.
    ASSIGN
        gttcriteres.lselection:BGCOLOR IN BROWSE brwCritere = giCouleur
        gttcriteres.cLibelle:BGCOLOR IN BROWSE brwCritere = giCouleur
        .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnDossier
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnDossier C-Win
ON CHOOSE OF btnDossier IN FRAME frmFond /* dos */
DO:
    gcFichierTempo = "".
    gcRepertoireDialog = cmbFichier:SCREEN-VALUE.
    ENTRY(NUM-ENTRIES(gcRepertoireDialog,"\"),gcRepertoireDialog,"\") = "".
    SYSTEM-DIALOG GET-FILE gcFichierTempo INITIAL-DIR gcRepertoireDialog USE-FILENAME FILTERS "Tous les fichiers" "*.*".
    IF gcFichierTempo = "" THEN RETURN.
    gcFichierATraiter = gcFichierTempo.
    cmbFichier:ADD-FIRST(gcFichierATraiter).
    cmbFichier:SCREEN-VALUE = gcFichierATraiter.
    gcFichiersTraites = cmbFichier:list-items.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnImprimer
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnImprimer C-Win
ON CHOOSE OF btnImprimer IN FRAME frmFond /* Imp */
DO:
  RUN impression.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnLancer
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnLancer C-Win
ON CHOOSE OF btnLancer IN FRAME frmFond /* run */
DO:
    IF cmbFichier:SCREEN-VALUE = "" OR cmbFichier:SCREEN-VALUE = ? THEN RETURN.
    filRecherche:SCREEN-VALUE = "".
    cmbFiltre:SCREEN-VALUE = "-".
    RUN SauveCriteresIgnores.
    RUN LanceAnalyse.
    APPLY "ENTRY" TO brwAnomalies.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnPrec
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnPrec C-Win
ON CHOOSE OF btnPrec IN FRAME frmFond /* < */
DO:
  IF glRechercheEnCours THEN 
    RUN Recherche("PREV").
  ELSE
    RUN Recherche("LAST").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnQuitter
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnQuitter C-Win
ON CHOOSE OF btnQuitter IN FRAME frmFond /* qui */
DO:
    IF NOT glAuto AND glConfirmation THEN DO:
        MESSAGE "Confirmez-vous la sortie de la Norminette ?" 
            VIEW-AS ALERT-BOX QUESTION BUTTON YES-NO
            TITLE "Confirmation..."
            UPDATE lRetour AS LOGICAL.
        IF NOT lRetour THEN RETURN.
    END.
    RUN Terminaison.
    APPLY "CLOSE" TO THIS-PROCEDURE.
    QUIT. 
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnraz
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnraz C-Win
ON CHOOSE OF btnraz IN FRAME frmFond /* raz */
DO:
    cmbFiltre:SCREEN-VALUE = "-".
    APPLY "VALUE-CHANGED" TO cmbFiltre.
    APPLY "ENTRY" TO brwAnomalies.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnraz2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnraz2 C-Win
ON CHOOSE OF btnraz2 IN FRAME frmFond /* raz */
DO:
    filRecherche:SCREEN-VALUE = "".
    APPLY "ENTRY" TO filRecherche.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnSuiv
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnSuiv C-Win
ON CHOOSE OF btnSuiv IN FRAME frmFond /* > */
DO:
  IF glRechercheEnCours THEN 
    RUN Recherche("NEXT").
  ELSE
    RUN Recherche("FIRST").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cmbFichier
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cmbFichier C-Win
ON ANY-KEY OF cmbFichier IN FRAME frmFond
DO:
  /*RETURN NO-APPLY.*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cmbFichier C-Win
ON VALUE-CHANGED OF cmbFichier IN FRAME frmFond
DO:
  /* maj de l'ordre de la combo */
  IF (cmbFiltre:SCREEN-VALUE <> "" AND cmbFiltre:SCREEN-VALUE <> ?) THEN DO:
      cmbFichier:PRIVATE-DATA = cmbFichier:SCREEN-VALUE.
      cmbFichier:DELETE(cmbFichier:SCREEN-VALUE).
      cmbFichier:ADD-FIRST(cmbFichier:PRIVATE-DATA).
      cmbFichier:SCREEN-VALUE = cmbFichier:ENTRY(1).
  END.

  IF gcOldFichier <> cmbFichier:SCREEN-VALUE THEN DO:
    EMPTY TEMP-TABLE gttAnomalies.
    brwAnomalies:TITLE = "Anomalie(s) potentielle(s)".
    APPLY "VALUE-CHANGED" TO brwAnomalies.
  END.
  gcOldFichier = cmbFichier:SCREEN-VALUE.

  /* maj de la liste des anomalies */
  {&OPEN-QUERY-brwAnomalies}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cmbFiltre
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cmbFiltre C-Win
ON VALUE-CHANGED OF cmbFiltre IN FRAME frmFond
DO:
  IF cmbFiltre:SCREEN-VALUE = "" OR cmbFiltre:SCREEN-VALUE = ? THEN DO:
    cmbFiltre:SCREEN-VALUE = "-".            
  END.

  {&OPEN-QUERY-brwAnomalies}

  APPLY "VALUE-CHANGED" TO brwAnomalies.

  IF trim(entry(1,cmbfiltre:SCREEN-VALUE,"|")) = "-" THEN DO:
        brwAnomalies:TITLE = STRING(giCompteurTotal) + " Anomalie(s) potentielle(s)".               
  END.
  ELSE DO:
      brwAnomalies:TITLE = trim(entry(2,cmbfiltre:SCREEN-VALUE,gcSeparateur)) + " anomalie(s) potentielle(s) filtrée(s) sur " + STRING(giCompteurTotal) + " Anomalie(s) potentielle(s)".
  END.

  APPLY "ENTRY" TO brwAnomalies.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filRecherche
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filRecherche C-Win
ON LEAVE OF filRecherche IN FRAME frmFond
DO:
    IF filRecherche <> filRecherche:SCREEN-VALUE THEN DO:
        glRechercheEnCours = FALSE.
    END.
    filRecherche = filRecherche:SCREEN-VALUE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filRecherche C-Win
ON RETURN OF filRecherche IN FRAME frmFond
DO:
  IF filRecherche <> filRecherche:SCREEN-VALUE THEN DO:
    glRechercheEnCours = FALSE.
  END.
  ASSIGN filRecherche.
  IF glRechercheEnCours THEN DO:
    RUN Recherche("NEXT").
  END.
  ELSE DO:
    RUN Recherche("FIRST").
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Activer_le_log_au_chargemen
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Activer_le_log_au_chargemen C-Win
ON VALUE-CHANGED OF MENU-ITEM m_Activer_le_log_au_chargemen /* Activer le log au chargement du fichier */
DO:
    glModeDebugChargement = MENU-ITEM m_Activer_le_log_au_chargemen:CHECKED IN MENU MENU-BAR-C-Win.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Demander_confirmation_avant
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Demander_confirmation_avant C-Win
ON VALUE-CHANGED OF MENU-ITEM m_Demander_confirmation_avant /* Demander confirmation avant de quitter */
DO:
    glConfirmation = MENU-ITEM m_Demander_confirmation_avant:CHECKED IN MENU MENU-BAR-C-Win.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Désactiver_le_critère_corre
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Désactiver_le_critère_corre C-Win
ON CHOOSE OF MENU-ITEM m_Désactiver_le_critère_corre /* Positionner la liste des critères sur celui correspondant à cette anomalie */
DO:
  
    IF AVAILABLE gttAnomalies THEN DO WITH FRAME frmFond:
        FOR FIRST   gttcriteres
            WHERE   gttcriteres.cCode = gttAnomalies.cCritere
            :
            REPOSITION brwCritere TO RECID RECID(gttCriteres).
        END.
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Editer_le_fichier_des_critè
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Editer_le_fichier_des_critè C-Win
ON CHOOSE OF MENU-ITEM m_Editer_le_fichier_des_critè /* Editer le fichier des critères */
DO:
  OS-COMMAND SILENT VALUE("start """" excel.exe " + gcFichierCriteresNorminette).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Editer_le_fichier_des_param
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Editer_le_fichier_des_param C-Win
ON CHOOSE OF MENU-ITEM m_Editer_le_fichier_des_param /* Editer le fichier des paramètres */
DO:
    OS-COMMAND SILENT VALUE(gcFichierParametres).
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Edition_via_Word_au_lieu_du
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Edition_via_Word_au_lieu_du C-Win
ON VALUE-CHANGED OF MENU-ITEM m_Edition_via_Word_au_lieu_du /* Edition via Word au lieu du navigateur */
DO:
  glEditionWord = MENU-ITEM m_Edition_via_Word_au_lieu_du:CHECKED IN MENU MENU-BAR-C-Win.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Efacer_les_fichiers_de_trav
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Efacer_les_fichiers_de_trav C-Win
ON CHOOSE OF MENU-ITEM m_Efacer_les_fichiers_de_trav /* Efacer les fichiers de travail */
DO:
    glMenage = MENU-ITEM m_Efacer_les_fichiers_de_trav:CHECKED IN MENU MENU-BAR-C-Win.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Efacer_les_fichiers_de_trav C-Win
ON VALUE-CHANGED OF MENU-ITEM m_Efacer_les_fichiers_de_trav /* Efacer les fichiers de travail */
DO:
  glMenage = MENU-ITEM m_Efacer_les_fichiers_de_trav:CHECKED IN MENU MENU-BAR-C-Win.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Effacer_lhistorique_des_fic
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Effacer_lhistorique_des_fic C-Win
ON CHOOSE OF MENU-ITEM m_Effacer_lhistorique_des_fic /* Effacer l'historique des fichiers traités */
DO:
    DO WITH FRAME frmFond:
        cmbFichier:LIST-ITEMS = ?.
        APPLY "VALUE-CHANGED" TO cmbFichier.
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Filtrer_la_liste_sur_cette_
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Filtrer_la_liste_sur_cette_ C-Win
ON CHOOSE OF MENU-ITEM m_Filtrer_la_liste_sur_cette_ /* Filtrer la liste sur cette anomalie */
DO:
  DEFINE VARIABLE viBoucle AS INTEGER NO-UNDO.
  DEFINE VARIABLE vcTempo AS CHARACTER NO-UNDO.
  DEFINE VARIABLE vlTempo AS LOGICAL NO-UNDO.

  DO WITH FRAME frmFond:
      RECHERCHE:
      DO viBoucle = 1 TO NUM-ENTRIES(cmbfiltre:LIST-ITEMS,";"):
          vcTempo = ENTRY(viBoucle,cmbfiltre:LIST-ITEMS,";").
          IF vcTempo BEGINS gttAnomalies.cLibelleFiltre THEN do:
              vlTempo = TRUE.
              LEAVE.
          END.
      END.
      IF vlTempo THEN DO:
          cmbFiltre:SCREEN-VALUE = vcTempo.
          APPLY "VALUE-CHANGED" TO cmbfiltre.
      END.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Générer_le_fichier_de_debug
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Générer_le_fichier_de_debug C-Win
ON VALUE-CHANGED OF MENU-ITEM m_Générer_le_fichier_de_debug /* Générer le fichier de debug de la norminette */
DO:
  glModeDebug = MENU-ITEM m_Générer_le_fichier_de_debug:CHECKED IN MENU MENU-BAR-C-Win.
  MENU-ITEM m_Voir_le_fichier_debug_de_la:SENSITIVE IN MENU MENU-BAR-C-Win = glModeDebug.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Liste_des_critères_avec_cou
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Liste_des_critères_avec_cou C-Win
ON VALUE-CHANGED OF MENU-ITEM m_Liste_des_critères_avec_cou /* Liste des critères en couleurs */
DO:
    glCouleursCritere = MENU-ITEM m_Liste_des_critères_avec_cou:CHECKED IN MENU MENU-BAR-C-Win.
    {&OPEN-QUERY-brwcritere}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Ouvrir_un_fichier_à_traiter
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Ouvrir_un_fichier_à_traiter C-Win
ON CHOOSE OF MENU-ITEM m_Ouvrir_un_fichier_à_traiter /* Ouvrir un fichier à traiter */
DO:
  APPLY "CHOOSE" TO btnDossier IN FRAME frmFond.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Quitter
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Quitter C-Win
ON CHOOSE OF MENU-ITEM m_Quitter /* Quitter */
DO:
  APPLY "CHOOSE" TO btnQuitter IN FRAME frmFond.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Se_positionner_sur_le_critè
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Se_positionner_sur_le_critè C-Win
ON VALUE-CHANGED OF MENU-ITEM m_Se_positionner_sur_le_critè /* Se positionner sur le critère correspondant à l'anomalie */
DO:
  
    glPositionCritere = MENU-ITEM m_Se_positionner_sur_le_critè:CHECKED IN MENU MENU-BAR-C-Win.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Supprimer_ce_fichier_de_la_
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Supprimer_ce_fichier_de_la_ C-Win
ON CHOOSE OF MENU-ITEM m_Supprimer_ce_fichier_de_la_ /* Supprimer ce fichier de l'historique des fichiers traités */
DO:
    DO WITH FRAME frmFond:
        cmbFichier:DELETE(cmbFichier:SCREEN-VALUE).
        cmbFichier:SCREEN-VALUE = cmbFichier:ENTRY(1).
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Voir_le_fichier_debug_de_la
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Voir_le_fichier_debug_de_la C-Win
ON CHOOSE OF MENU-ITEM m_Voir_le_fichier_debug_de_la /* Editer le fichier debug de la norminette */
DO:
  RUN LanceDbg.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brwAnomalies
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

ON "CTRL-ALT-V":U ANYWHERE  
DO:
    RUN gDechargeVariables.
    RETURN.
END.

/* Best default for GUI applications is...                              */
PAUSE 0 BEFORE-HIDE.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  RUN Initialisation.
  IF glAuto THEN APPLY "CHOOSE" TO btnLancer.
  WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.
RUN Terminaison.

QUIT.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

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
  DISPLAY cmbFichier filRecherche cmbFiltre edtAide 
      WITH FRAME frmFond IN WINDOW C-Win.
  ENABLE btnImprimer rctBoutons btnDossier cmbFichier filRecherche btnraz2 
         btnPrec btnSuiv cmbFiltre btnraz brwcritere brwAnomalies btnLancer 
         edtAide btnQuitter 
      WITH FRAME frmFond IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-frmFond}
  VIEW C-Win.
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

    DO WITH FRAME frmFond:
        /* Début de l'édition */
        RUN HTML_OuvreFichier("").
        RUN HTML_TitreEdition("Norminette : " + cmbFichier:SCREEN-VALUE).
        
        RUN HTML_Ligne(brwAnomalies:TITLE,"><").
        
        RUN HTML_ChargeFormatCellule("E",0,"CF=gris,A=><,T=3").
        RUN HTML_ChargeFormatCellule("L",0,"A=><").
        RUN HTML_ChargeFormatCellule("L",3,"A=<").
       
        /* Ecriture de l'entete pour le tableau des champs */
        cLigne = "" 
            + "Ligne"
            + devSeparateurEdition + "Bloc"
            + devSeparateurEdition + "Libellé"
            .
        RUN HTML_DebutTableau(cLigne).
        
        /* Balayage de la table des champs */
        FOR EACH gttAnomalies:
            cLigne = "" 
                + string(gttAnomalies.iLigne,">>>>9")
                + devSeparateurEdition + TRIM(gttAnomalies.cBloc)
                + devSeparateurEdition + TRIM(gttAnomalies.cAnomalie)
                .
            RUN HTML_LigneTableau(cLigne).
        END.
    END.
    
    /* Fin de l'édition des champs */
    RUN HTML_FinTableau.
    RUN HTML_FinEdition.
    RUN HTML_FermeFichier.
    IF glEditionWord THEN
        RUN HTML_AfficheFichierAvecWord.
    ELSE
        RUN HTML_AfficheFichier.

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
    DEFINE VARIABLE vcLigne         AS CHARACTER NO-UNDO.
    DEFINE VARIABLE gcPrefsCriteres AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vcRecherche     AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vcTempo         AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE viBoucle        AS INTEGER      NO-UNDO.
    
    C-Win:LOAD-ICON(gcRepertoireRessourcesImages + "norminette.ico").
    DO WITH FRAME frmFond:
        btnQuitter:LOAD-IMAGE(gcRepertoireRessourcesImages + "sortie.ico").
        btnLancer:LOAD-IMAGE(gcRepertoireRessourcesImages + "ok.ico").
        btnRaz:LOAD-IMAGE(gcRepertoireRessourcesImages + "Supprime05.bmp").
        btnRaz2:LOAD-IMAGE(gcRepertoireRessourcesImages + "Supprime05.bmp").
        btnDossier:LOAD-IMAGE(gcRepertoireRessourcesImages + "dossier.jpg").
        btnimprimer:LOAD-IMAGE(gcRepertoireRessourcesImages + "print2.ico").
        btnimprimer:LOAD-IMAGE-INSENSITIVE(gcRepertoireRessourcesImages + "print2-off.ico").

        cmbfiltre:DELIMITER = ";".
        gcSeparateur = CHR(187).
    END.

    ASSIGN 
        gcRepertoireTempo = disque + "tmp\"
        gcFichierDebug = gcRepertoireTempo + "\Norminette.dbg"
        gcFichieraTraiter = ENTRY(1,SESSION:PARAMETER,"#").
        gcOldFichier = gcFichierATraiter.
        glAuto = (IF NUM-ENTRIES(SESSION:PARAMETER,"#") > 1 THEN(ENTRY(2,SESSION:PARAMETER,"#") = "AUTO") ELSE FALSE)
        .
     
    RUN gChargeParametres.    
   
    /* Chargement des préférences de l'utilisateur */
    IF gcFichierATraiter <> "" 
    and (cmbFichier:LIST-ITEMS = ? OR LOOKUP(gcFichierATraiter,cmbFichier:LIST-ITEMS) = 0) then DO:
        cmbFichier:ADD-FIRST(gcFichierATraiter).
    END.
    
    DO WITH FRAME frmFond:
        RUN gChargePreferencesUtilisateur.
        IF gcFichiersTraites <> "" THEN DO:
            DO viBoucle = 1 TO NUM-ENTRIES(gcFichiersTraites):
                vcTempo = ENTRY(viBoucle,gcFichiersTraites).
                IF LOOKUP(vcTempo,cmbFichier:LIST-ITEMS) = 0 THEN cmbFichier:ADD-LAST(vcTempo).    
            END.
        END.
    END.

    /* Mise à jour des valeurs */
    IF c-win:TITLE MATCHES "*&1*" THEN c-win:TITLE = REPLACE(c-win:TITLE,"&1",gcUtilisateur).
    MENU-ITEM m_Demander_confirmation_avant:CHECKED IN MENU MENU-BAR-C-Win = glConfirmation.
    MENU-ITEM m_Edition_via_Word_au_lieu_du:CHECKED IN MENU MENU-BAR-C-Win = glEditionWord. 
    MENU-ITEM m_Efacer_les_fichiers_de_trav:CHECKED IN MENU MENU-BAR-C-Win = glMenage. 
    MENU-ITEM m_Générer_le_fichier_de_debug:CHECKED IN MENU MENU-BAR-C-Win = glModeDebug. 
    MENU-ITEM m_Voir_le_fichier_debug_de_la:SENSITIVE IN MENU MENU-BAR-C-Win = glModeDebug.
    MENU-ITEM m_Se_positionner_sur_le_critè:CHECKED IN MENU MENU-BAR-C-Win = glPositionCritere.
    MENU-ITEM m_Liste_des_critères_avec_cou:CHECKED IN MENU MENU-BAR-C-Win = glCouleursCritere.
    MENU-ITEM m_Activer_le_log_au_chargemen:CHECKED IN MENU MENU-BAR-C-Win = glModeDebugChargement.

    RUN gChargeCriteres.

    /* Ouverture de la query */
    {&OPEN-QUERY-brwcritere}

    /* Gestion des combos */    
    cmbFichier:SCREEN-VALUE = gcFichierATraiter.
    cmbfiltre:LIST-ITEMS = "-".
    cmbfiltre:SCREEN-VALUE = cmbfiltre:ENTRY(1).
    gcFichiersTraites = cmbFichier:list-items.
    
    if giVersion > giVersionUtilisateur then do:
        message "Une nouvelle version de la Norminette à été mise en production." 
                + chr(10) + "Appuyez sur 'OK' pour voir le détail de cette nouvelle version"
                view-as alert-box information.
        os-command silent value("start """" " + gcRepertoireRessourcesDocumentations + "V" + string(giVersion) + ".pdf").
        giVersionUtilisateur = giVersion.
        RUN gSauvePreferencesUtilisateur.
    end.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE LanceAnalyse C-Win 
PROCEDURE LanceAnalyse :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE VARIABLE vcligne AS CHARACTER NO-UNDO.
DEFINE VARIABLE vcProgrammeSeul AS CHARACTER NO-UNDO.
DEFINE VARIABLE viCompteurPartiel AS INTEGER NO-UNDO.

    /* Vidage de la table car on peut relancer le traitement ou le lancer sur un autre fichier */
    EMPTY TEMP-TABLE gttAnomalies.

    /* Ouverture de la query : juste pour vider le tableau des anomalies */
    {&OPEN-QUERY-brwAnomalies}

    DO WITH FRAME frmFond:
        gcFichierATraiter = cmbFichier:SCREEN-VALUE.
        
        /* appel de la norminette */
        RUN VALUE(gcRepertoireExecution + "Norminette.p") (gcFichierATraiter + "#" ).

        /* Remplissage de la combo filtre */
        vcLigne = "-".
        cmbfiltre:LIST-ITEMS = ?.
        giCompteurTotal = 0.
        viCompteurPartiel = 0.
        FOR EACH gttAnomalies
            BREAK BY gttAnomalies.cLibelleFiltre
            :
            giCompteurTotal = giCompteurTotal + 1. 
            viCompteurPartiel = viCompteurPartiel + 1. 
            IF LAST-OF(gttAnomalies.cLibelleFiltre) THEN DO:
                vcLigne = vcLigne + (IF vcLigne <> "" THEN ";" ELSE "") + gttAnomalies.cLibelleFiltre + /*FILL(" ",150) +*/ " " + gcSeparateur + " (" + STRING(viCompteurPartiel) + ")".  
                viCompteurPartiel = 0.
             END.
        END.
        cmbfiltre:LIST-ITEMS = vcLigne.
        cmbfiltre:SCREEN-VALUE = "-" /*cmbfiltre:ENTRY(1)*/.
        brwAnomalies:TITLE = STRING(giCompteurTotal) + " Anomalie(s) potentielle(s)".
        
        {&OPEN-QUERY-brwAnomalies}
        APPLY "VALUE-CHANGED" TO brwAnomalies.

        IF giCompteurTotal = 0 THEN DO:
            MESSAGE "Aucune anomalie potentielle détectée !" VIEW-AS ALERT-BOX.
        END.
    END.   

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE LanceDbg C-Win 
PROCEDURE LanceDbg :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE vcFichierDbg AS CHARACTER NO-UNDO.
    
    vcFichierDbg = gcRepertoireTempo + "Norminette.dbg".
    OS-COMMAND NO-WAIT VALUE(vcFichierDbg).

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
DEFINE INPUT PARAMETER pcMode AS CHARACTER no-undo.

    DEFINE VARIABLE vcChaineRecherche AS CHARACTER NO-UNDO.
        
    vcChaineRecherche = "*" + filRecherche + "*".

    /* Recherche en fonction du mode de recherche */
    IF pcMode = "FIRST" THEN DO:
        FIND FIRST  gttAnomalies  
            WHERE   (gttAnomalies.cBloc MATCHES vcChaineRecherche OR gttAnomalies.cLibelle MATCHES vcChaineRecherche)
            NO-ERROR.
    END.
    IF pcMode = "LAST" THEN DO:
        FIND LAST   gttAnomalies  
            WHERE   (gttAnomalies.cBloc MATCHES vcChaineRecherche OR gttAnomalies.cLibelle MATCHES vcChaineRecherche)
            NO-ERROR.
    END.
    IF pcMode = "PREV" THEN DO:
        FIND PREV   gttAnomalies  
            WHERE   (gttAnomalies.cBloc MATCHES vcChaineRecherche OR gttAnomalies.cLibelle MATCHES vcChaineRecherche)
            NO-ERROR.
    END.
    IF pcMode = "NEXT" THEN DO:
        FIND NEXT   gttAnomalies  
            WHERE   (gttAnomalies.cBloc MATCHES vcChaineRecherche OR gttAnomalies.cLibelle MATCHES vcChaineRecherche)
            NO-ERROR.
    END.
    
    /* Positionnement sur le bon enregistrement si nécessaire */ 
    IF AVAILABLE(gttAnomalies) THEN DO:
        REPOSITION brwAnomalies TO RECID RECID(gttAnomalies) NO-ERROR.  
    END.
    ELSE DO:
        BELL.
    END.
    glRechercheEnCours = TRUE.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE SauveCriteresIgnores C-Win 
PROCEDURE SauveCriteresIgnores :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    
    DEFINE VARIABLE vcLigne AS CHARACTER NO-UNDO INIT "".

    FOR EACH    gttcriteres
        WHERE   gttcriteres.iordre <> 0
        AND     NOT gttcriteres.lSelection
        :
        vcLigne = vcLigne + (IF vcLigne <> "" THEN "," ELSE "") + gttcriteres.cType + STRING(gttcriteres.iordre).
    END.

    gcCriteresIgnores = vcLigne.
    
    RUN gSauvePreferencesUtilisateur.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Terminaison C-Win 
PROCEDURE Terminaison :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    RUN SauveCriteresIgnores.
    
    IF glMenage THEN DO:
        OS-DELETE VALUE(gcFichierRsultat).        
        OS-DELETE VALUE(gcFichierDebug).        
    END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

