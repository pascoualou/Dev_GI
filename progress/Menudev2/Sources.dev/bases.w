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
{includes\i_api.i}
{menudev2\includes\menudev2.i}
{ prodict/user/uservar.i NEW }
{ prodict/dictvar.i NEW }
{includes\i_Excel.i}

/* Parameters Definitions ---                                           */

DEFINE INPUT PARAMETER  winGeneral  AS HANDLE NO-UNDO.
DEFINE INPUT PARAMETER  cParametres AS CHARACTER NO-UNDO.
/* Local Variable Definitions ---                                       */

DEFINE BUFFER bprefs FOR prefs.

DEFINE STREAM sEntree.
DEFINE STREAM sSortie.

DEFINE TEMP-TABLE ttDroitsTC
    FIELD cServeur AS CHARACTER
    FIELD cBase AS CHARACTER
    FIELD cUtilisateur AS CHARACTER
    .

DEFINE TEMP-TABLE ttBases
    FIELD cServeur  AS CHARACTER
    FIELD cBase  AS CHARACTER
    FIELD lDemarree    AS LOGICAL
    FIELD lBase    AS LOGICAL
    FIELD lsauvegarde    AS LOGICAL
    FIELD cCommentaire    AS CHARACTER
    FIELD cVersion AS CHARACTER
    FIELD cProgress AS CHARACTER
    FIELD dDateSauvegarde AS DATE
    FIELD cOrdre AS CHARACTER
    FIELD cRepertoire AS CHARACTER
    FIELD cTri AS CHARACTER
    FIELD lAuto AS LOGICAL
    FIELD lLib AS LOGICAL
    FIELD lUtil AS LOGICAL /* bases des autres utilisateurs */
    FIELD cURL AS CHARACTER 
    FIELD cMachine AS CHARACTER
    FIELD lNo-Integrity AS LOGICAL
    FIELD cCheminBases AS CHARACTER
    INDEX ttbases01 IS PRIMARY cTri
    .

DEFINE BUFFER bttbases FOR ttbases.
DEFINE TEMP-TABLE ttBasesRef LIKE ttbases.
DEFINE BUFFER bttbasesRef FOR ttbasesRef.
DEFINE BUFFER bOrdres FOR ordres.

DEFINE VARIABLE cRepertoireBases            AS CHARACTER    NO-UNDO.
DEFINE VARIABLE lRecharger                  AS LOGICAL      NO-UNDO.
DEFINE VARIABLE lMenu                       AS LOGICAL      no-undo EXTENT 6.
DEFINE VARIABLE cVersionTempo               AS CHARACTER    NO-UNDO.
DEFINE VARIABLE iDispoDisque                AS INT64        NO-UNDO.
DEFINE VARIABLE iTailleSvg                  AS INT64        NO-UNDO.
DEFINE VARIABLE cLigne                      AS CHARACTER    NO-UNDO.
DEFINE VARIABLE cRetour                     AS CHARACTER    NO-UNDO.
DEFINE VARIABLE cLibelle                    AS CHARACTER    NO-UNDO.
DEFINE VARIABLE iX                          AS INTEGER      NO-UNDO.
DEFINE VARIABLE iY                          AS INTEGER      NO-UNDO.
DEFINE VARIABLE cCommandeShell              AS CHARACTER    NO-UNDO.
DEFINE VARIABLE lActionManuelle             AS LOGICAL      no-undo INIT TRUE.
DEFINE VARIABLE lOuvertesEnPremier          AS LOGICAL      NO-UNDO.
DEFINE VARIABLE cMachineUtilisateur         AS CHARACTER    NO-UNDO.
DEFINE VARIABLE hColonneEnCours             AS HANDLE       NO-UNDO.
DEFINE VARIABLE hColonneOld                 AS HANDLE       NO-UNDO.
DEFINE VARIABLE lTriAsc                     AS LOGICAL      NO-UNDO INIT TRUE.
DEFINE VARIABLE lFiltrePresente             AS LOGICAL      NO-UNDO. 
DEFINE VARIABLE lFiltreAbsente              AS LOGICAL      NO-UNDO.    
DEFINE VARIABLE lFiltreOuverte              AS LOGICAL      NO-UNDO.    
DEFINE VARIABLE lFiltreFermee               AS LOGICAL      NO-UNDO.    
DEFINE VARIABLE lFiltreSauvegardePresente   AS LOGICAL      NO-UNDO.    
DEFINE VARIABLE lFiltreSauvegardeAbsente    AS LOGICAL      NO-UNDO.
DEFINE VARIABLE lFiltreUtil                 AS LOGICAL      NO-UNDO.
DEFINE VARIABLE cFiltreUtil                 AS CHARACTER    NO-UNDO INIT "".
DEFINE VARIABLE lFiltreToutDeSuite          AS LOGICAL      NO-UNDO.
DEFINE VARIABLE lFiltreEt                   AS LOGICAL      NO-UNDO.
DEFINE VARIABLE iNombreFiltres              AS INTEGER      NO-UNDO INIT 0.
DEFINE VARIABLE lPremierPassage             AS LOGICAL      NO-UNDO INIT TRUE.
DEFINE VARIABLE cListeBasesLib              AS CHARACTER    NO-UNDO INIT "CLI,DEV,PREC,SUIV,SPE".
DEFINE VARIABLE cFichierBatch               AS CHARACTER    NO-UNDO.
DEFINE VARIABLE cIbVersion                  AS CHARACTER    NO-UNDO.
DEFINE VARIABLE cIbDate                     AS CHARACTER    NO-UNDO.
DEFINE VARIABLE cIbTypeVersion              AS CHARACTER    NO-UNDO.
DEFINE VARIABLE cIbVersionProgress          AS CHARACTER    NO-UNDO.
DEFINE VARIABLE cIbCommentaire              AS CHARACTER    NO-UNDO.
DEFINE VARIABLE cIbNo-Integrity             AS CHARACTER    NO-UNDO.
DEFINE VARIABLE cIbAuto                     AS CHARACTER    NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME frmFonction
&Scoped-define BROWSE-NAME brwBases

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ttBases

/* Definitions for BROWSE brwBases                                      */
&Scoped-define FIELDS-IN-QUERY-brwBases ttBases.cBase ttBases.cServeur ttBases.lAuto ttBases.ldemarree ttBases.lno-Integrity ttBases.lbase ttBases.lsauvegarde ttBases.cVersion ttBases.cProgress ttBases.cRepertoire ttBases.dDateSauvegarde ttBases.cCommentaire ttbases.cCheminBases   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brwBases ttBases.cVersion   
&Scoped-define ENABLED-TABLES-IN-QUERY-brwBases ttBases
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-brwBases ttBases
&Scoped-define SELF-NAME brwBases
&Scoped-define QUERY-STRING-brwBases FOR EACH ttBases  BY cOrdre
&Scoped-define OPEN-QUERY-brwBases OPEN QUERY {&SELF-NAME} FOR EACH ttBases  BY cOrdre.
&Scoped-define TABLES-IN-QUERY-brwBases ttBases
&Scoped-define FIRST-TABLE-IN-QUERY-brwBases ttBases


/* Definitions for FRAME frmFonction                                    */
&Scoped-define OPEN-BROWSERS-IN-QUERY-frmFonction ~
    ~{&OPEN-QUERY-brwBases}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS tglOuvertes rsChoixBases tglLocal ~
filRecherche btnCodePrecedent btnCodeSuivant btnFiltre btnAnciennes ~
tglRegrouper tglBarbade tglNeptune2 brwBases BUTTON-1 filDispo 
&Scoped-Define DISPLAYED-OBJECTS tglOuvertes rsChoixBases tglLocal ~
filRecherche tglRegrouper tglBarbade tglNeptune2 TOGGLE-1 TOGGLE-2 filDispo 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */
&Scoped-define List-1 TOGGLE-1 TOGGLE-2 

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD AfficheInformations C-Win 
FUNCTION AfficheInformations RETURNS LOGICAL
  (cLibelle-in AS CHARACTER,iTemporisation-in AS INTEGER)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD DonneCouleurLigne C-Win 
FUNCTION DonneCouleurLigne RETURNS INTEGER
  (cSituation-in AS CHARACTER,lDemarree-in AS LOGICAL)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD DonneInfosServeurs C-Win 
FUNCTION DonneInfosServeurs RETURNS CHARACTER
  ( cNomBase AS CHARACTER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD IsDroitTC C-Win 
FUNCTION IsDroitTC RETURNS LOGICAL
  ( cServeur-in AS CHARACTER, cBase-in AS CHARACTER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.

/* Menu Definitions                                                     */
DEFINE SUB-MENU m_Version 
       MENU-ITEM m_Pour_savoir  LABEL "Pour savoir sur quel environnement générer le cnx..."
              DISABLED
       RULE
       MENU-ITEM m_Rep_gidev    LABEL "(Dev)eloppement"
       MENU-ITEM m_Rep_nmoins1  LABEL "(Préc)édente"  
       MENU-ITEM m_Rep_n        LABEL "(Cli)ent"      
       MENU-ITEM m_Rep_nplus1   LABEL "(Suiv)ante"    
       MENU-ITEM m_Specifique   LABEL "(Spe)cifique"  .

DEFINE MENU Menubases 
       MENU-ITEM m_-----_Actions_pour_cette_ba LABEL "---------- Actions pour cette base ----------"
              DISABLED
       MENU-ITEM m_Demarrer     LABEL "Démarrer"      
       MENU-ITEM m_Arreter      LABEL "Arrêter"       
       RULE
       MENU-ITEM m_Forcer_larrt_de_la_bases LABEL "Forcer l'arrêt de la bases"
       MENU-ITEM m_lk           LABEL "Supprimer les .lk (en cas d'arrêt violent des bases)"
       RULE
       MENU-ITEM m_Sauvegarder  LABEL "Sauvegarder"   
       MENU-ITEM m_Restaurer    LABEL "Restaurer"     
       MENU-ITEM m_Voir_les_batches_de_prepost LABEL "Voir les batches de pré/post sauvegarde/restauration"
       RULE
       MENU-ITEM m_Copier_la_sauvegarde LABEL "Copier la sauvegarde de l'utilisateur en local"
       RULE
       MENU-ITEM m_SupprimeSVG  LABEL "Supprimer la sauvegarde"
       MENU-ITEM m_SupprimeBase LABEL "Supprimer la base"
       RULE
       MENU-ITEM m_Repair       LABEL "Truncate/Repair"
       MENU-ITEM m_Monter_la_version_de_la_bas LABEL "Monter la version de la base"
       MENU-ITEM m_CRC          LABEL "Calcul du CRC" 
       RULE
       MENU-ITEM m_Nouvelle     LABEL "Nouvelle base" 
       RULE
       MENU-ITEM m_Base_automatique LABEL "Démarrage automatique au lancement de menudev2"
              TOGGLE-BOX
       SUB-MENU  m_Version      LABEL "Type de version"
       MENU-ITEM m_Generation   LABEL "Génération CNX & ADB"
       RULE
       MENU-ITEM m_Editeur      LABEL "Editeur sur cette base"
       MENU-ITEM m_Commentaire  LABEL "Modifier le commentaire de cette base"
       MENU-ITEM m_Date         LABEL "Modifier la date de cette base"
       MENU-ITEM m_Explorer     LABEL "Explorateur sur le répertoire de cette base"
       RULE
       MENU-ITEM m_-----_Actions_globales_à_to LABEL "------- Actions globales à toutes les bases -------"
              DISABLED
       MENU-ITEM m_Tout         LABEL "Arrêter toutes les bases (base + baselib)"
       MENU-ITEM m_Calcul_de_la_version_Progre LABEL "Calcul de la version Progress des bases"
       RULE
       MENU-ITEM m_Fermer       LABEL "Fermer"        .


/* Definitions of the field level widgets                               */
DEFINE BUTTON btnAppliquerFermerFiltres  NO-FOCUS FLAT-BUTTON
     LABEL "et" 
     SIZE 22 BY 3.1.

DEFINE BUTTON btnAppliquerFiltres  NO-FOCUS FLAT-BUTTON
     LABEL "Appliquer les filtres" 
     SIZE 20 BY .95.

DEFINE BUTTON btnFermerFiltres  NO-FOCUS FLAT-BUTTON
     LABEL "Fermer" 
     SIZE 20 BY .95.

DEFINE VARIABLE cmbUtil AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS COMBO-BOX SORT INNER-LINES 5
     LIST-ITEMS "Item 1" 
     DROP-DOWN-LIST
     SIZE 24 BY 1 NO-UNDO.

DEFINE VARIABLE rsFiltreEt AS LOGICAL 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "toutes les conditions", yes,
"au moins 1 condition", no
     SIZE 25.6 BY 1.67 NO-UNDO.

DEFINE VARIABLE tglFiltreAbsente AS LOGICAL INITIAL no 
     LABEL "Base absente" 
     VIEW-AS TOGGLE-BOX
     SIZE 24 BY .71 NO-UNDO.

DEFINE VARIABLE tglFiltreFermee AS LOGICAL INITIAL no 
     LABEL "Base Fermée" 
     VIEW-AS TOGGLE-BOX
     SIZE 25 BY .71 NO-UNDO.

DEFINE VARIABLE tglFiltreOuverte AS LOGICAL INITIAL no 
     LABEL "Base ouverte" 
     VIEW-AS TOGGLE-BOX
     SIZE 25 BY .71 NO-UNDO.

DEFINE VARIABLE tglFiltrePresente AS LOGICAL INITIAL no 
     LABEL "Base présente" 
     VIEW-AS TOGGLE-BOX
     SIZE 24 BY .71 NO-UNDO.

DEFINE VARIABLE tglFiltreSauvegardeAbsente AS LOGICAL INITIAL no 
     LABEL "Sauvegarde Absente" 
     VIEW-AS TOGGLE-BOX
     SIZE 24 BY .71 NO-UNDO.

DEFINE VARIABLE tglFiltreSauvegardePresente AS LOGICAL INITIAL no 
     LABEL "Sauvegarde présente" 
     VIEW-AS TOGGLE-BOX
     SIZE 24 BY .71 NO-UNDO.

DEFINE BUTTON btnAnciennes  NO-CONVERT-3D-COLORS
     LABEL "A" 
     SIZE-PIXELS 20 BY 20 TOOLTIP "Liste des anciennes sauvegardes".

DEFINE BUTTON btnCodePrecedent 
     LABEL "<" 
     SIZE-PIXELS 20 BY 20 TOOLTIP "Rechercher le précédent".

DEFINE BUTTON btnCodeSuivant  NO-CONVERT-3D-COLORS
     LABEL ">" 
     SIZE-PIXELS 20 BY 20 TOOLTIP "Rechercher le suivant".

DEFINE BUTTON btnFiltre  NO-CONVERT-3D-COLORS
     LABEL "Y" 
     SIZE-PIXELS 20 BY 20 TOOLTIP "Filtres sur les bases / Clic droit pour effacer les filtres".

DEFINE BUTTON BUTTON-1 
     LABEL "Export des bases des autres utilisateurs" 
     SIZE 39 BY .91.

DEFINE VARIABLE filDispo AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 19 BY .71 NO-UNDO.

DEFINE VARIABLE filRecherche AS CHARACTER FORMAT "X(256)":U 
     LABEL "Recherche" 
     VIEW-AS FILL-IN 
     SIZE 21 BY .95 NO-UNDO.

DEFINE VARIABLE rsChoixBases AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Bases locales et serveurs", 1,
"Bases libellés", 2,
"Bases des autres utilisateurs", 3
     SIZE 31 BY 2.62 NO-UNDO.

DEFINE VARIABLE tglBarbade AS LOGICAL INITIAL no 
     LABEL "Bases présentes sur Barbade" 
     VIEW-AS TOGGLE-BOX
     SIZE 32 BY .71 NO-UNDO.

DEFINE VARIABLE tglLocal AS LOGICAL INITIAL no 
     LABEL "Bases Locales" 
     VIEW-AS TOGGLE-BOX
     SIZE 19 BY .71 NO-UNDO.

DEFINE VARIABLE tglNeptune2 AS LOGICAL INITIAL no 
     LABEL "Bases présentes sur Neptune2" 
     VIEW-AS TOGGLE-BOX
     SIZE 34 BY .71 NO-UNDO.

DEFINE VARIABLE tglOuvertes AS LOGICAL INITIAL no 
     LABEL "Bases ouvertes en tête de liste" 
     VIEW-AS TOGGLE-BOX
     SIZE 33 BY .71 NO-UNDO.

DEFINE VARIABLE tglRegrouper AS LOGICAL INITIAL no 
     LABEL "Regrouper les bases similaires" 
     VIEW-AS TOGGLE-BOX
     SIZE 33 BY .71 NO-UNDO.

DEFINE VARIABLE TOGGLE-1 AS LOGICAL INITIAL no 
     LABEL "Pause en fin de script" 
     VIEW-AS TOGGLE-BOX
     SIZE 25 BY .71 NO-UNDO.

DEFINE VARIABLE TOGGLE-2 AS LOGICAL INITIAL no 
     LABEL "Démarrage en 'No-Integrity'" 
     VIEW-AS TOGGLE-BOX
     SIZE 30 BY .71 NO-UNDO.

DEFINE VARIABLE edtInformation AS CHARACTER INITIAL "Libelle" 
     VIEW-AS EDITOR NO-BOX
     SIZE 61 BY 1.19
     BGCOLOR 3 FGCOLOR 15 FONT 10 NO-UNDO.

DEFINE IMAGE IMAGE-1
     FILENAME "adeicon/rbuild%.ico":U
     SIZE 8 BY 1.43.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brwBases FOR 
      ttBases SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brwBases
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brwBases C-Win _FREEFORM
  QUERY brwBases DISPLAY
      ttBases.cBase FORMAT "x(15)" WIDTH-PIXELS 50 LABEL "Nom"
          ttBases.cServeur FORMAT "x(15)" WIDTH-PIXELS 75 LABEL "Serveur"
          ttBases.lAuto FORMAT "  A/" LABEL "Auto"
          ttBases.ldemarree FORMAT "Oui/Non" LABEL "Démarrée"
          ttBases.lno-Integrity FORMAT "  -i/" LABEL "  -i"
          ttBases.lbase FORMAT "  B/" LABEL "Base"
          ttBases.lsauvegarde FORMAT "  S/" LABEL "Svg"
          ttBases.cVersion FORMAT "x(10)" WIDTH-PIXELS 50 LABEL "Version"
          ttBases.cProgress FORMAT "x(10)" WIDTH-PIXELS 50 LABEL "Progress"
          ttBases.cRepertoire FORMAT "x(10)"  LABEL "Type"
          ttBases.dDateSauvegarde FORMAT "99/99/9999" WIDTH-PIXELS 75 LABEL "Date"
          ttBases.cCommentaire FORMAT "x(50)" WIDTH-PIXELS 260 LABEL "Commentaire"
          ttbases.cCheminBases FORMAT "x(40)" LABEL "Chemin"
     ENABLE ttBases.cVersion
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS NO-COLUMN-SCROLLING SEPARATORS SIZE 162 BY 13.81 ROW-HEIGHT-CHARS .6.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME frmModule
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 166.2 BY 20.62
         BGCOLOR 7 
         TITLE BGCOLOR 2 FGCOLOR 15 "Bases".

DEFINE FRAME frmInformation
     edtInformation AT ROW 1.48 COL 13 NO-LABEL WIDGET-ID 2
     IMAGE-1 AT ROW 1.24 COL 3 WIDGET-ID 4
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS TOP-ONLY NO-UNDERLINE THREE-D 
         AT COL 46 ROW 7.67
         SIZE 76 BY 2.14
         BGCOLOR 3  WIDGET-ID 700.

DEFINE FRAME frmFonction
     tglOuvertes AT ROW 1.24 COL 3 WIDGET-ID 16
     rsChoixBases AT ROW 1.24 COL 40 NO-LABEL WIDGET-ID 84
     tglLocal AT ROW 1.24 COL 75 WIDGET-ID 10
     filRecherche AT ROW 1.24 COL 111.2 WIDGET-ID 26
     btnCodePrecedent AT Y 5 X 720 WIDGET-ID 22
     btnCodeSuivant AT Y 5 X 740 WIDGET-ID 24
     btnFiltre AT Y 5 X 765 WIDGET-ID 82
     btnAnciennes AT Y 5 X 795 WIDGET-ID 88
     tglRegrouper AT ROW 2.19 COL 3 WIDGET-ID 76
     tglBarbade AT ROW 2.19 COL 75 WIDGET-ID 12
     tglNeptune2 AT ROW 3.14 COL 75 WIDGET-ID 14
     brwBases AT ROW 4.1 COL 2
     BUTTON-1 AT ROW 18 COL 58 WIDGET-ID 6
     TOGGLE-1 AT ROW 18.14 COL 2
     TOGGLE-2 AT ROW 18.14 COL 27 WIDGET-ID 8
     filDispo AT ROW 18.14 COL 142 COLON-ALIGNED NO-LABEL WIDGET-ID 4
     "Place disponible sur le répertoire des bases :" VIEW-AS TEXT
          SIZE 43 BY .71 AT ROW 18.1 COL 100 WIDGET-ID 2
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 2 ROW 1.24
         SIZE 164 BY 19.05
         TITLE "Liste et état des bases disponibles".

DEFINE FRAME frmfiltres
     btnAppliquerFermerFiltres AT ROW 11.48 COL 4 WIDGET-ID 18
     rsFiltreEt AT ROW 1.95 COL 2 NO-LABEL WIDGET-ID 30
     tglFiltrePresente AT ROW 4.57 COL 3 WIDGET-ID 10
     tglFiltreAbsente AT ROW 5.29 COL 3 WIDGET-ID 22
     tglFiltreOuverte AT ROW 6.24 COL 3 WIDGET-ID 6
     tglFiltreFermee AT ROW 6.95 COL 3 WIDGET-ID 20
     tglFiltreSauvegardePresente AT ROW 7.91 COL 3 WIDGET-ID 8
     btnAppliquerFiltres AT ROW 11.71 COL 5 WIDGET-ID 12
     tglFiltreSauvegardeAbsente AT ROW 8.62 COL 3 WIDGET-ID 24
     cmbUtil AT ROW 10.29 COL 1 COLON-ALIGNED NO-LABEL WIDGET-ID 38
     btnFermerFiltres AT ROW 13.38 COL 5 WIDGET-ID 16
     "Utilisateur ..." VIEW-AS TEXT
          SIZE 25 BY .71 AT ROW 9.57 COL 2 WIDGET-ID 40
     "La base valide :" VIEW-AS TEXT
          SIZE 25 BY .71 AT ROW 1 COL 2 WIDGET-ID 34
     "suivante(s)..." VIEW-AS TEXT
          SIZE 25 BY .71 AT ROW 3.62 COL 2 WIDGET-ID 36
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS TOP-ONLY NO-UNDERLINE THREE-D 
         AT COL 131 ROW 2.91
         SIZE 28 BY 14.76
         BGCOLOR 8 
         TITLE "Filtres sur les bases" WIDGET-ID 800.


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
         HEIGHT             = 20.48
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
/* REPARENT FRAME */
ASSIGN FRAME frmfiltres:FRAME = FRAME frmFonction:HANDLE
       FRAME frmFonction:FRAME = FRAME frmModule:HANDLE
       FRAME frmInformation:FRAME = FRAME frmModule:HANDLE.

/* SETTINGS FOR FRAME frmfiltres
                                                                        */
ASSIGN 
       FRAME frmfiltres:HIDDEN           = TRUE
       FRAME frmfiltres:MOVABLE          = TRUE.

/* SETTINGS FOR FRAME frmFonction
   FRAME-NAME                                                           */
/* BROWSE-TAB brwBases tglNeptune2 frmFonction */
ASSIGN 
       brwBases:POPUP-MENU IN FRAME frmFonction             = MENU Menubases:HANDLE
       brwBases:NUM-LOCKED-COLUMNS IN FRAME frmFonction     = 1.

ASSIGN 
       btnCodeSuivant:AUTO-RESIZE IN FRAME frmFonction      = TRUE.

/* SETTINGS FOR FILL-IN filRecherche IN FRAME frmFonction
   ALIGN-L                                                              */
/* SETTINGS FOR TOGGLE-BOX TOGGLE-1 IN FRAME frmFonction
   NO-ENABLE 1                                                          */
/* SETTINGS FOR TOGGLE-BOX TOGGLE-2 IN FRAME frmFonction
   NO-ENABLE 1                                                          */
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

DEFINE VARIABLE XXTABVALXX AS LOGICAL NO-UNDO.

ASSIGN XXTABVALXX = FRAME frmFonction:MOVE-BEFORE-TAB-ITEM (FRAME frmInformation:HANDLE)
/* END-ASSIGN-TABS */.

IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brwBases
/* Query rebuild information for BROWSE brwBases
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH ttBases  BY cOrdre.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE brwBases */
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


&Scoped-define BROWSE-NAME brwBases
&Scoped-define SELF-NAME brwBases
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwBases C-Win
ON DEFAULT-ACTION OF brwBases IN FRAME frmFonction
DO:
  DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO.
  IF ttbases.lbase AND ((ttbases.cProgress <> "" AND gcVersionProgress = ttbases.cProgress) OR ttbases.cProgress = "") THEN DO:
      IF ttBases.lDemarree THEN DO:
          RUN AfficheMessageAvecTemporisation("Confirmation...","Confirmez-vous l'arrêt des serveurs sur la base en cours ?",TRUE,5,"NON","",FALSE,OUTPUT cRetour).
          IF cRetour = "NON" THEN RETURN NO-APPLY.
          APPLY "CHOOSE" TO MENU-ITEM m_Arreter IN MENU Menubases.
      END.
      ELSE
          APPLY "CHOOSE" TO MENU-ITEM m_Demarrer IN MENU Menubases.
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwBases C-Win
ON LEFT-MOUSE-CLICK OF brwBases IN FRAME frmFonction
DO:
    DEFINE VARIABLE h-cell AS WIDGET-HANDLE NO-UNDO.
    DEFINE VARIABLE i-cellHeight AS INTEGER NO-UNDO.
    DEFINE VARIABLE i-lastY AS INTEGER NO-UNDO.
    DEFINE VARIABLE i-row AS INTEGER NO-UNDO.
    DEFINE VARIABLE l-ok AS LOGICAL NO-UNDO.
    
    h-cell = SELF:FIRST-COLUMN.
    
    IF VALID-HANDLE(h-cell) THEN i-cellHeight = h-cell:HEIGHT-PIXELS.
    ELSE i-cellHeight = 20.
    
    i-lastY = LAST-EVENT:Y.
    
    IF i-lastY >= i-cellHeight AND
        i-lastY <= i-cellHeight * (SELF:NUM-ITERATIONS + 1) THEN
        DO:
        i-lastY = i-lastY - i-cellHeight / 2.
        i-row = i-lastY / i-cellHeight.
        l-ok = SELF:SELECT-ROW(i-row).
    END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwBases C-Win
ON MOUSE-MENU-CLICK OF brwBases IN FRAME frmFonction
DO:
    DEFINE VARIABLE h-cell AS WIDGET-HANDLE NO-UNDO.
    DEFINE VARIABLE i-cellHeight AS INTEGER NO-UNDO.
    DEFINE VARIABLE i-lastY AS INTEGER NO-UNDO.
    DEFINE VARIABLE i-row AS INTEGER NO-UNDO.
    DEFINE VARIABLE l-ok AS LOGICAL NO-UNDO.
    
    h-cell = SELF:FIRST-COLUMN.
    
    IF VALID-HANDLE(h-cell) THEN i-cellHeight = h-cell:HEIGHT-PIXELS.
    ELSE i-cellHeight = 20.
    
    i-lastY = LAST-EVENT:Y.
    
    IF i-lastY >= i-cellHeight AND
        i-lastY <= i-cellHeight * (SELF:NUM-ITERATIONS + 1) THEN
        DO:
        i-lastY = i-lastY - i-cellHeight / 2.
        i-row = i-lastY / i-cellHeight.
        l-ok = SELF:SELECT-ROW(i-row).
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwBases C-Win
ON ROW-DISPLAY OF brwBases IN FRAME frmFonction
DO:
  DEFINE VARIABLE iCouleurLigne AS INTEGER NO-UNDO.
  
  iCouleurLigne = DonneCouleurLigne(ttbases.cServeur,ttbases.ldemarree).

  IF iCouleurLigne = 0 THEN RETURN.

  IF ttbases.lNo-Integrity THEN iCouleurLigne = 12.

  ttbases.cbase:BGCOLOR IN BROWSE brwbases = iCouleurLigne.
  ttbases.cServeur:BGCOLOR IN BROWSE brwbases = iCouleurLigne.
  ttbases.lAuto:BGCOLOR IN BROWSE brwbases = iCouleurLigne.
  ttbases.ldemarree:BGCOLOR IN BROWSE brwbases = iCouleurLigne.
  ttbases.lNo-Integrity:BGCOLOR IN BROWSE brwbases = iCouleurLigne.
  ttbases.lbase:BGCOLOR IN BROWSE brwbases = iCouleurLigne.
  ttbases.lsauvegarde:BGCOLOR IN BROWSE brwbases = iCouleurLigne.
  ttbases.cVersion:BGCOLOR IN BROWSE brwbases = iCouleurLigne.
  ttbases.ccommentaire:BGCOLOR IN BROWSE brwbases = iCouleurLigne.
  ttbases.crepertoire:BGCOLOR IN BROWSE brwbases = iCouleurLigne.
  ttbases.dDateSauvegarde:BGCOLOR IN BROWSE brwbases = iCouleurLigne.
  ttbases.cProgress:BGCOLOR IN BROWSE brwbases = iCouleurLigne.
  ttbases.cCheminBases:BGCOLOR IN BROWSE brwbases = iCouleurLigne.

  IF iCouleurLigne = 12 THEN DO:
      ttbases.cbase:FGCOLOR IN BROWSE brwbases = 15.
      ttbases.cServeur:FGCOLOR IN BROWSE brwbases = 15.
      ttbases.lAuto:FGCOLOR IN BROWSE brwbases = 15.
      ttbases.ldemarree:FGCOLOR IN BROWSE brwbases = 15.
      ttbases.lNo-Integrity:FGCOLOR IN BROWSE brwbases = 15.
      ttbases.lbase:FGCOLOR IN BROWSE brwbases = 15.
      ttbases.lsauvegarde:FGCOLOR IN BROWSE brwbases = 15.
      ttbases.cVersion:FGCOLOR IN BROWSE brwbases = 15.
      ttbases.ccommentaire:FGCOLOR IN BROWSE brwbases = 15.
      ttbases.crepertoire:FGCOLOR IN BROWSE brwbases = 15.
      ttbases.dDateSauvegarde:FGCOLOR IN BROWSE brwbases = 15.
      ttbases.cProgress:FGCOLOR IN BROWSE brwbases = 15.
      ttbases.cCheminBases:FGCOLOR IN BROWSE brwbases = 15.
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwBases C-Win
ON START-SEARCH OF brwBases IN FRAME frmFonction
DO:
        /* Récupération de la colonne en cours */       
    hColonneEnCours = brwbases:CURRENT-COLUMN.

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


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwBases C-Win
ON VALUE-CHANGED OF brwBases IN FRAME frmFonction
DO:
    DEFINE VARIABLE lToujoursActif AS LOGICAL NO-UNDO INIT TRUE.
    DEFINE VARIABLE lDemarree AS LOGICAL NO-UNDO.
    DEFINE VARIABLE lLocale AS LOGICAL NO-UNDO.
    DEFINE VARIABLE lBase AS LOGICAL NO-UNDO.
    DEFINE VARIABLE lSauvegarde AS LOGICAL NO-UNDO.
    DEFINE VARIABLE lBaseOuSauvegarde AS LOGICAL NO-UNDO.
    DEFINE VARIABLE lNeptune2 AS LOGICAL NO-UNDO.
    DEFINE VARIABLE lCnxOK AS LOGICAL NO-UNDO.
    DEFINE VARIABLE lBaseLib AS LOGICAL NO-UNDO.
    DEFINE VARIABLE lBaseUtil AS LOGICAL NO-UNDO.
    DEFINE VARIABLE lVersionConnue AS LOGICAL NO-UNDO.
    DEFINE VARIABLE lBaseauto AS LOGICAL NO-UNDO.
    DEFINE VARIABLE lVersionOK AS LOGICAL NO-UNDO.

    IF AVAILABLE(ttbases) THEN DO:
        lDemarree = ttbases.lDemarree.   
        lLocale = (ttbases.cServeur = "Local").
        lBase = ttbases.lBase.
        lSauvegarde = ttbases.lSauvegarde.
        lBaseOuSauvegarde = (lBase OR lSauvegarde).
        lCnxOK = (SEARCH("c:\pfgi\cnx" + ttbases.cbase + ".pf") <> ?).
        lNeptune2 = (ttbases.cServeur = "neptune2").
        lBaseLib = ttbases.lLib.
        lBaseUtil = ttbases.lUtil.
        lVersionConnue = (ttbases.cVersion <> "" AND ttbases.cVersion <> ?).
        lBaseauto = ttbases.lAuto.
        lVersionOK = ((ttbases.cProgress = gcVersionProgress) OR ttbases.cProgress = ? OR ttbases.cProgress = "").

        IF NOT(AVAILABLE(ttbases)) THEN RETURN.

        ASSIGN
            MENU-ITEM m_Demarrer:SENSITIVE IN MENU menubases = (lBase AND NOT(lDemarree) AND NOT(lBaseUtil) AND lVersionOK)
            MENU-ITEM m_Arreter:SENSITIVE IN MENU menubases = (lBase AND lDemarree AND NOT(lBaseUtil) AND lVersionOK)
            MENU-ITEM m_Forcer_larrt_de_la_bases:SENSITIVE IN MENU menubases = (lBase AND lDemarree AND NOT(lBaseUtil) AND lVersionOK)
            MENU-ITEM m_lk:SENSITIVE IN MENU menubases = (lBase  AND lLocale AND NOT(lBaseUtil) AND lVersionOK)
            MENU-ITEM m_sauvegarder:SENSITIVE IN MENU menubases = (lBase AND NOT(lDemarree) AND NOT(lNeptune2) AND NOT(lBaseLib) AND NOT(lBaseUtil) AND lVersionOK)
            MENU-ITEM m_restaurer:SENSITIVE IN MENU menubases =(lSauvegarde AND NOT(lDemarree) AND NOT(lNeptune2) AND NOT(lBaseLib) AND NOT(lBaseUtil AND lVersionOK))
            MENU-ITEM m_SupprimeSvg:SENSITIVE IN MENU menubases = (lSauvegarde AND lLocale AND NOT(lBaseLib) AND NOT(lBaseUtil) AND lVersionOK)
            MENU-ITEM m_SupprimeBase:SENSITIVE IN MENU menubases = (lBase AND NOT(lDemarree) AND lLocale AND NOT(lBaseLib) AND NOT(lBaseUtil AND lVersionOK))
            MENU-ITEM m_crc:SENSITIVE IN MENU menubases = (lBase AND lLocale AND NOT(lBaseLib) AND NOT(lBaseUtil) AND lVersionOK)
            MENU-ITEM m_repair:SENSITIVE IN MENU menubases = (lBase AND NOT(lDemarree) AND lLocale AND NOT(lBaseUtil) AND lVersionOK)
            MENU-ITEM m_Nouvelle:SENSITIVE IN MENU menubases = lToujoursActif AND NOT(lBaseLib) AND NOT(lBaseUtil)
            MENU-ITEM m_Rep_gidev:SENSITIVE IN MENU menubases = (lBase AND NOT(lBaseLib) AND NOT(lBaseUtil))
            MENU-ITEM m_Rep_nMoins1:SENSITIVE IN MENU menubases = (lBase AND NOT(lBaseLib) AND NOT(lBaseUtil))
            MENU-ITEM m_Rep_n:SENSITIVE IN MENU menubases = (lBase AND NOT(lBaseLib) AND NOT(lBaseUtil))
            MENU-ITEM m_Rep_nPlus1:SENSITIVE IN MENU menubases = (lBase AND NOT(lBaseLib) AND NOT(lBaseUtil))
            MENU-ITEM m_Specifique:SENSITIVE IN MENU menubases = (lBase AND NOT(lBaseLib) AND NOT(lBaseUtil))
            MENU-ITEM m_Generation:SENSITIVE IN MENU menubases = (lBase AND NOT(lBaseLib) AND NOT(lBaseUtil))
            MENU-ITEM m_Editeur:SENSITIVE IN MENU menubases = (lBase AND lDemarree AND lCnxOK AND NOT(lBaseLib) AND NOT(lBaseUtil) AND lVersionOK)
            MENU-ITEM m_Commentaire:SENSITIVE IN MENU menubases = (lLocale AND NOT(lBaseLib) AND NOT(lBaseUtil))
            MENU-ITEM m_Date:SENSITIVE IN MENU menubases = lLocale AND NOT(lBaseLib) AND NOT(lBaseUtil)
            MENU-ITEM m_Explorer:SENSITIVE IN MENU menubases = lLocale /*AND NOT(lBaseLib)*/ AND NOT(lBaseUtil)
            MENU-ITEM m_Tout:SENSITIVE IN MENU menubases = lToujoursActif
            MENU-ITEM m_Monter_la_version_de_la_bas:SENSITIVE IN MENU menubases = (lBase AND lDemarree AND lLocale AND NOT(lBaseUtil) AND NOT(lBaseLib) AND lVersionOK)
            MENU-ITEM m_Copier_la_sauvegarde:SENSITIVE IN MENU menubases = (lSauvegarde AND lBaseUtil AND NOT(lBaseLib))
            MENU-ITEM m_Base_Automatique:SENSITIVE IN MENU menubases = (lLocale /*AND NOT(lBaseLib)*/ AND lVersionOK).
            MENU-ITEM m_Base_Automatique:CHECKED IN MENU menubases = (lLocale /*AND NOT(lBaseLib)*/ AND lBaseauto AND lVersionOK).
            MENU-ITEM m_Voir_les_batches_de_prepost:SENSITIVE IN MENU menubases = (lVersionOK).
            .

        /* Sauvegarde de la dernière base utilisée */
        SauvePreference("DERNIERE-BASE",ttbases.cserveur + "," + ttbases.cBase).

    END.   
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnAnciennes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnAnciennes C-Win
ON CHOOSE OF btnAnciennes IN FRAME frmFonction /* A */
DO:
    /* Lancement de la liste des anciennes sauvegardes */
    cCommandeShell = "explorer.exe " + DonnePreferenceGenerale("PREFS-GENE-ANCIENNES-SAUVEGARDES").
    RUN ExecuteCommandeDos(cCommandeShell).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frmfiltres
&Scoped-define SELF-NAME btnAppliquerFermerFiltres
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnAppliquerFermerFiltres C-Win
ON CHOOSE OF btnAppliquerFermerFiltres IN FRAME frmfiltres /* et */
DO:
    APPLY "CHOOSE" TO btnAppliquerFiltres IN FRAME frmFiltres.
    APPLY "CHOOSE" TO btnFermerFiltres IN FRAME frmFiltres.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnAppliquerFiltres
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnAppliquerFiltres C-Win
ON CHOOSE OF btnAppliquerFiltres IN FRAME frmfiltres /* Appliquer les filtres */
DO:
  RUN Recharger.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frmFonction
&Scoped-define SELF-NAME btnCodePrecedent
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnCodePrecedent C-Win
ON CHOOSE OF btnCodePrecedent IN FRAME frmFonction /* < */
DO:
    DEFINE VARIABLE cRecherche AS CHARACTER NO-UNDO.

    cRecherche = "*" + filRecherche:SCREEN-VALUE + "*".

    /* Recherche en arriere */
    IF AVAILABLE(ttbases) THEN DO:
        FIND PREV   ttbases
            WHERE   ttbases.cbase MATCHES cRecherche
            OR      ttbases.cCommentaire MATCHES cRecherche
            NO-ERROR.
    END.
    IF NOT(AVAILABLE(ttbases)) THEN DO:
        FIND LAST   ttbases
            WHERE   ttbases.cbase MATCHES cRecherche
            OR      ttbases.cCommentaire MATCHES cRecherche
            NO-ERROR.
    END.
    IF AVAILABLE(ttbases) THEN DO:
        REPOSITION brwbases TO RECID RECID(ttbases).
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnCodeSuivant
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnCodeSuivant C-Win
ON CHOOSE OF btnCodeSuivant IN FRAME frmFonction /* > */
DO:
    DEFINE VARIABLE cRecherche AS CHARACTER NO-UNDO.

    cRecherche = "*" + filRecherche:SCREEN-VALUE + "*".

    /* Recherche en avant */
    IF AVAILABLE(ttbases) THEN DO:
        FIND NEXT   ttbases
            WHERE   ttbases.cbase MATCHES cRecherche
            OR      ttbases.cCommentaire MATCHES cRecherche
            NO-ERROR.
    END.
    IF NOT(AVAILABLE(ttbases)) THEN DO:
        FIND FIRST   ttbases
            WHERE   ttbases.cbase MATCHES cRecherche
            OR      ttbases.cCommentaire MATCHES cRecherche
            NO-ERROR.
    END.
    IF AVAILABLE(ttbases) THEN DO:
        REPOSITION brwbases TO RECID RECID(ttbases).
        APPLY "VALUE-CHANGED" TO brwbases.
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frmfiltres
&Scoped-define SELF-NAME btnFermerFiltres
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnFermerFiltres C-Win
ON CHOOSE OF btnFermerFiltres IN FRAME frmfiltres /* Fermer */
DO:
    FRAME frmFiltres:VISIBLE = FALSE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frmFonction
&Scoped-define SELF-NAME btnFiltre
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnFiltre C-Win
ON CHOOSE OF btnFiltre IN FRAME frmFonction /* Y */
DO:
    FRAME frmFiltres:VISIBLE = NOT(FRAME frmFiltres:VISIBLE).
    IF FRAME frmfiltres:VISIBLE THEN DO:
        ENABLE ALL WITH FRAME frmfiltres.
        RUN ChargeFiltres.
        btnAppliquerFiltres:MOVE-TO-TOP().
        btnFermerFiltres:MOVE-TO-TOP().
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnFiltre C-Win
ON MOUSE-MENU-CLICK OF btnFiltre IN FRAME frmFonction /* Y */
DO:
    /* Pas de filtre actif...on ne fait rien */
    IF iNombreFiltres = 0  THEN RETURN.

    /* Demande de confirmation */
    cLibelle = "Confirmez vous la suppression des filtres en cours ?".
    RUN AfficheMessageAvecTemporisation("Gestion des bases",cLibelle,TRUE,10,"NON","",FALSE,OUTPUT cRetour).
    IF cRetour = "OUI" THEN DO:
        /* Mise à non de tous les filtres */
        SauvePreference("FILTRE-BASEPRESENTE","NON").
        SauvePreference("FILTRE-BASEABSENTE","NON").
        SauvePreference("FILTRE-BASEOUVERTE","NON").
        SauvePreference("FILTRE-BASEFERMEE","NON").
        SauvePreference("FILTRE-SAUVEGARDEPRESENTE","NON").
        SauvePreference("FILTRE-SAUVEGARDEPRESENTE","NON").
        SauvePreference("FILTRE-UTILISATEUR","-").

        /* Fenetre des filtres invisible */
        FRAME frmFiltres:VISIBLE = FALSE.
        RUN ChargeFiltres.

        /* Mise a jour de la liste des bases */
        RUN recharger.
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-1 C-Win
ON CHOOSE OF BUTTON-1 IN FRAME frmFonction /* Export des bases des autres utilisateurs */
DO:
    RUN BasesUtilisateurs("EXCEL").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-1 C-Win
ON RIGHT-MOUSE-CLICK OF BUTTON-1 IN FRAME frmFonction /* Export des bases des autres utilisateurs */
DO:  
    AssigneParametre("FICHIERS-INFOSFICHIER","bases" + ",VISU").
    RUN DonneOrdre("DONNEORDREAMODULE=FICHIERS|AFFICHE").  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frmfiltres
&Scoped-define SELF-NAME cmbUtil
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cmbUtil C-Win
ON VALUE-CHANGED OF cmbUtil IN FRAME frmfiltres
DO:  
    SauvePreference("FILTRE-UTILISATEUR",SELF:SCREEN-VALUE).
    cFiltreUtil = SELF:SCREEN-VALUE.
    IF lFiltreToutDeSuite THEN RUN recharger.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frmFonction
&Scoped-define SELF-NAME filRecherche
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filRecherche C-Win
ON RETURN OF filRecherche IN FRAME frmFonction /* Recherche */
DO:
  APPLY "CHOOSE" TO BtnCodeSuivant.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Arreter
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Arreter C-Win
ON CHOOSE OF MENU-ITEM m_Arreter /* Arrêter */
DO:
    DEFINE VARIABLE cTempo AS CHARACTER NO-UNDO.


    IF NOT(AVAILABLE(ttBases)) THEN RETURN NO-APPLY.
    ttbases.lNo-Integrity = FALSE.
    IF ttbases.cServeur = "Local" THEN DO:
        IF ttbases.lLib THEN DO:
            cTempo = ttbases.cCheminBases.
            RUN ExecuteCommandeDos(gcRepertoireRessourcesPrivees + "\scripts\serveurs\_GI-FermeLibelles.bat " + cTempo + " " + ttBases.cbase + " " + (IF toggle-1:CHECKED IN FRAME frmFonction THEN "pause" ELSE "")).
        END.
        ELSE DO:
            cTempo = "".
            RUN ExecuteCommandeDos(gcRepertoireRessourcesPrivees + "\scripts\serveurs\_GI-FermeServeurs.bat " + cRepertoireBases + " "  + ttBases.cbase + " " + (IF toggle-1:CHECKED IN FRAME frmfonction THEN "pause" ELSE "")).
        END.
        run SauveInfosBase(ttbases.cbase,cTempo).
    END.
    ELSE DO:
        cTempo = "".
        RUN DemandeDistante("f" + ttbases.cBase).
    END.
    RUN AfficheMessageAvecTemporisation("commande en cours","Un avertissement sera envoyé dans la zone information de menudev2 quand la commande sera terminée.",FALSE,5,"OK","MESSAGE-ARRETER",FALSE,OUTPUT cRetour).
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Base_automatique
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Base_automatique C-Win
ON VALUE-CHANGED OF MENU-ITEM m_Base_automatique /* Démarrage automatique au lancement de menudev2 */
DO:
    DEFINE VARIABLE cTempo AS CHARACTER NO-UNDO.

    ttbases.lAuto = MENU-ITEM m_Base_automatique:CHECKED  IN MENU Menubases.
    IF ttbases.lLib THEN DO:
        cTempo = ttBases.cbase.
        IF cTempo = "CLI" THEN
            cTempo = "gi\".
        ELSE IF cTempo = "DEV" THEN
            cTempo = "gidev\".
        ELSE 
            cTempo = "gi_"+ ttBases.cbase + "\gi\".

        cTempo = disque + cTempo + "baselib".
    END.
    ELSE DO:
        cTempo = cRepertoireBases + "\" + ttbases.cbase.
    END.
    run SauveInfosBase(ttbases.cbase,cTempo).
    brwBases:REFRESH() IN FRAME frmFonction.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Calcul_de_la_version_Progre
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Calcul_de_la_version_Progre C-Win
ON CHOOSE OF MENU-ITEM m_Calcul_de_la_version_Progre /* Calcul de la version Progress des bases */
DO:
    AssigneParametre("AVEC_VERSION_PROGRESS","OUI").
    lActionManuelle = TRUE.
    RUN TopChronoGeneral.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Commentaire
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Commentaire C-Win
ON CHOOSE OF MENU-ITEM m_Commentaire /* Modifier le commentaire de cette base */
DO:
    RUN DonnePositionMessage IN ghGeneral.
    gcAllerRetour = STRING(giPosXMessage)
        + "|" + STRING(giPosYMessage)
        + "|" + "Commentaire de la base"
        + "|" + ttbases.cCommentaire.
    RUN VALUE(gcRepertoireExecution + "saisie2.w") (INPUT-OUTPUT gcAllerRetour).
    IF gcAllerRetour = "" OR ENTRY(4,gcAllerRetour,"|") = ttbases.cCommentaire THEN RETURN.
    ttbases.cCommentaire = ENTRY(4,gcAllerRetour,"|").
    run SauveInfosBase(ttbases.cbase,"").
    
    RUN ChargeBases.
    RUN Recharger /*TopChronoGeneral*/.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Copier_la_sauvegarde
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Copier_la_sauvegarde C-Win
ON CHOOSE OF MENU-ITEM m_Copier_la_sauvegarde /* Copier la sauvegarde de l'utilisateur en local */
DO:
    RUN CopieSauvegardeUtilisateur.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_CRC
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_CRC C-Win
ON CHOOSE OF MENU-ITEM m_CRC /* Calcul du CRC */
DO:
    IF NOT(AVAILABLE(ttBases)) THEN RETURN NO-APPLY.

    AfficheInformations("Calcul du CRC en cours...",0).
    /*RUN ExecuteCommandeDos(gcRepertoireRessourcesPrivees + "\scripts\serveurs\_GI-Lancecrc.bat " + cRepertoireBases + "\" + ttBases.cbase).*/
    RUN CalculeVersion.
    RUN Recharger.
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Date C-Win
ON CHOOSE OF MENU-ITEM m_Date /* Modifier la date de cette base */
DO:
    RUN DonnePositionMessage IN ghGeneral.
    gcAllerRetour = STRING(giPosXMessage)
        + "|" + STRING(giPosYMessage)
        + "|" + "Date de la base"
        + "|" + (IF ttbases.dDateSauvegarde <> ? THEN STRING(ttbases.dDateSauvegarde) ELSE "")
        + "|" + "99/99/9999"
        .
    RUN VALUE(gcRepertoireExecution + "saisie2.w") (INPUT-OUTPUT gcAllerRetour).
    IF gcAllerRetour = "" OR ENTRY(4,gcAllerRetour,"|") = STRING(ttbases.dDateSauvegarde) THEN RETURN.
    ttbases.dDateSauvegarde = DATE(ENTRY(4,gcAllerRetour,"|")).
    run SauveInfosBase(ttbases.cbase,"").
    
    RUN ChargeBases.
    RUN Recharger.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Demarrer
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Demarrer C-Win
ON CHOOSE OF MENU-ITEM m_Demarrer /* Démarrer */
DO:
    DEFINE VARIABLE cTempo AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lVerification AS LOGICAL NO-UNDO INIT FALSE.

    IF NOT(AVAILABLE(ttBases)) THEN RETURN NO-APPLY.

    ttbases.lNo-Integrity = toggle-2:CHECKED IN FRAME frmFonction.
    
    IF ttbases.cServeur = "Local" THEN DO:
        /* génération du batch de création des variables de paramètrage des serveurs */
        RUN CreParamServeurs.

        IF ttbases.lLib THEN DO:
            /*
            cTempo = ttBases.cbase.
            IF cTempo = "CLI" THEN
                cTempo = "gi\".
            ELSE IF cTempo = "DEV" THEN
                cTempo = "gidev\".
            ELSE 
                cTempo = "gi_"+ ttBases.cbase + "\gi\".
            */
            cTempo = ttbases.cCheminBases.
            cCommandeShell = gcRepertoireRessourcesPrivees + "\scripts\serveurs\_GI-LanceLibelles.bat " + cTempo + " " + ttBases.cbase + " " + (IF toggle-1:CHECKED IN FRAME frmFonction THEN "pause" ELSE "rem") + (IF toggle-2:CHECKED IN FRAME frmFonction THEN " -i" ELSE "").
            RUN ExecuteCommandeDos(cCommandeShell).
        END.
        ELSE DO:
            cTempo = "".
            cCommandeShell = gcRepertoireRessourcesPrivees + "\scripts\serveurs\_GI-LanceServeurs.bat " + cRepertoireBases + " " + ttBases.cbase + " " + (IF toggle-1:CHECKED IN FRAME frmFonction THEN "pause" ELSE "rem") + (IF toggle-2:CHECKED IN FRAME frmFonction THEN " -i" ELSE "").
            RUN ExecuteCommandeDos(cCommandeShell).
            lVerification = TRUE.
        END.
        run SauveInfosBase(ttbases.cbase,cTempo).
    END.
    ELSE DO:
        RUN DemandeDistante("o" + ttbases.cBase).
    END.
    RUN AfficheMessageAvecTemporisation("Commande en cours","Un avertissement sera envoyé dans la zone information de menudev2 quand la commande sera terminée.",FALSE,5,"OK","MESSAGE-DEMARRER",FALSE,OUTPUT cRetour).

    IF lVerification THEN RUN VerificationFichiersConnexion(ttBases.cbase,ttbases.cRepertoire).

    /* Préparation du fichier client.ini pour faire monter la référence */
    IF not(ttbases.lLib) AND DonnePreference("PREF-CLIENTINI") = "OUI" THEN DO:
        LOAD "client" DIR "c:\pfgi".
        USE "client".
        PUT-KEY-VALUE SECTION "ACCES" KEY "Derniere_reference" VALUE ttbases.cBase.
        UNLOAD "client".
    END.
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Editeur
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Editeur C-Win
ON CHOOSE OF MENU-ITEM m_Editeur /* Editeur sur cette base */
DO:
    IF NOT(AVAILABLE(ttBases)) THEN RETURN NO-APPLY.
    OS-COMMAND silent value(gcRepertoireRessourcesPrivees + "\scripts\serveurs\_GI-LanceEditeur.bat " + "c:\pfgi\cnx" +  ttbases.cbase + ".pf" + (IF toggle-1:CHECKED IN FRAME frmFonction THEN "pause" ELSE "")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Explorer
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Explorer C-Win
ON CHOOSE OF MENU-ITEM m_Explorer /* Explorateur sur le répertoire de cette base */
DO:
    IF NOT(AVAILABLE(ttBases)) THEN RETURN NO-APPLY.
    IF ttbases.llib THEN DO:
        OS-COMMAND SILENT value("explorer.exe " + ttBases.cCheminBases).
    END.
    ELSE DO:
        OS-COMMAND SILENT value("explorer.exe " + cRepertoireBases + "\" + ttBases.cbase).
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Forcer_larrt_de_la_bases
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Forcer_larrt_de_la_bases C-Win
ON CHOOSE OF MENU-ITEM m_Forcer_larrt_de_la_bases /* Forcer l'arrêt de la bases */
DO:
    DEFINE VARIABLE cTempo AS CHARACTER NO-UNDO.

    IF NOT(AVAILABLE(ttBases)) THEN RETURN NO-APPLY.
    ttbases.lNo-Integrity = FALSE.
    IF ttbases.cServeur = "Local" THEN DO:
        IF ttbases.lLib THEN DO:
            /*
            cTempo = ttBases.cbase.
            IF cTempo = "CLI" THEN
                cTempo = "gi\".
            ELSE IF cTempo = "DEV" THEN
                cTempo = "gidev\".
            ELSE 
                cTempo = "gi_"+ ttBases.cbase + "\gi\".

            cTempo = disque + cTempo + "baselib".
            */
            cTempo = ttbases.cCheminBases.
            RUN ExecuteCommandeDos(gcRepertoireRessourcesPrivees + "\scripts\serveurs\_GI-FermeLibellesForce.bat " + cTempo + " " + ttBases.cbase + " " + (IF toggle-1:CHECKED IN FRAME frmFonction THEN "pause" ELSE "")).
        END.
        ELSE DO:
            RUN ExecuteCommandeDos(gcRepertoireRessourcesPrivees + "\scripts\serveurs\_GI-FermeServeursForce.bat " + cRepertoireBases + " "  + ttBases.cbase + " " + (IF toggle-1:CHECKED IN FRAME frmfonction THEN "pause" ELSE "")).
        END.
        run SauveInfosBase(ttbases.cbase,cTempo).
    END.
    ELSE DO:
        /* on ne fait rien sur les bases serveur */
    END.
    RUN AfficheMessageAvecTemporisation("commande en cours","Un avertissement sera envoyé dans la zone information de menudev2 quand la commande sera terminée.",FALSE,5,"OK","MESSAGE-FORCER-ARRETER",FALSE,OUTPUT cRetour).
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Generation
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Generation C-Win
ON CHOOSE OF MENU-ITEM m_Generation /* Génération CNX  ADB */
DO:
    DEFINE VARIABLE iBoucle AS INTEGER NO-UNDO.
    DEFINE VARIABLE cParam AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cFichierCnx AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cFichierAdb AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cFichierTmp AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cFichierServices AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cFichierAddServices AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lServicesOK AS LOGICAL NO-UNDO.
    DEFINE VARIABLE lBasesLibFixes AS LOGICAL NO-UNDO.
    DEFINE VARIABLE lModificationCnx AS LOGICAL NO-UNDO INIT FALSE.
    DEFINE VARIABLE cLigneTmp AS CHARACTER NO-UNDO INIT "".
    DEFINE VARIABLE lRetour AS LOGICAL NO-UNDO INIT FALSE.
    DEFINE VARIABLE cOuCopier AS CHARACTER NO-UNDO.

    IF NOT(AVAILABLE(ttBases)) THEN RETURN NO-APPLY.

    cFichierCnx = "cnx" + ttbases.cbase + ".pf".
    cFichierAdb = "adb" +  ttbases.cbase.
    cFichierAddServices = "services." +  trim(ttbases.cbase).
    cFichierTmp = replace(cFichierCnx,".pf",".tmp").
    
    cParam = disque + DonneRepertoireApplication(ttbases.cRepertoire).
    message "ttbases.cRepertoire = " + ttbases.cRepertoire + " / cparam = " + cparam view-as alert-box.
    /* Génération de l'entete du fichier cnx */
    OUTPUT STREAM sSortie TO VALUE(loc_tmp + "\" + cFichierCnx).
    put stream sSortie unformatted "# Fichier de connexion généré par menudev2" skip(1).
    put stream sSortie unformatted "# ---- Gestion Double Version Progress" skip(1).
    put stream sSortie unformatted "# ---- Répertoire des bases = " + cRepertoireBases skip.
    put stream sSortie unformatted "# ---- Référence client = " + ttbases.cbase skip.
    put stream sSortie unformatted "# ---- Répertoire des bases libellé = " + cParam skip(1).
    OUTPUT STREAM sSortie close.
    
    IF ttbases.cServeur = "Local" THEN DO:
        /* Génération du fichier adb... */
	    RUN DonnePositionMessage IN ghGeneral.
	    gcAllerRetour = STRING(giPosXMessage)
	        + "|" + STRING(giPosYMessage)
            + "|" + "Nom à reporter dans le fichier adbxxxxx"
            + "|" + ttbases.cCommentaire.
        RUN VALUE(gcRepertoireExecution + "saisie2.w") (INPUT-OUTPUT gcAllerRetour).
        IF gcAllerRetour = "" THEN RETURN.

        AfficheInformations("Génération en cours...",0).
        OUTPUT TO VALUE(loc_tmp + "\" + cFichierAdb).
        PUT UNFORMATTED """" + ENTRY(4,gcAllerRetour,"|") + """" SKIP.
        PUT UNFORMATTED """INS                             |1@0@1@0@0@|MDP_INUTILISE""" SKIP.
        PUT UNFORMATTED """FIN""" SKIP.
        OUTPUT CLOSE.
        
        /* Déplacement du fichier dans pfgi */
        OS-COPY VALUE(loc_tmp + "\" + cFichierCnx) VALUE("c:\pfgi\" + cFichierCnx).

        /* Génération du fichier cnx... */
        RUN ExecuteCommandeDos(gcRepertoireRessourcesPrivees + "\scripts\serveurs\_GenCnx2v.bat " + cRepertoireBases + " "  +  ttbases.cbase + " " + cParam + " " + "TOUT").
        lModificationCnx = FALSE.
    END.
    ELSE DO:
        /* Récupération du fichier cnx depuis le serveur */
        /* Par sécurité, suppression du fichier de la fois d'avant */
        OS-DELETE VALUE(loc_tmp + "\" + cFichierCnx).
        OS-DELETE VALUE(loc_tmp + "\" + cFichierAdb).
        OS-DELETE VALUE(loc_tmp + "\" + cFichierTmp).
        OS-DELETE VALUE(loc_tmp + "\" + cFichierAddServices).

        /* Récupération du fichier par FTP */
        RUN ExecuteCommandeDos(gcRepertoireRessourcesPrivees + "\scripts\ftp\ftpGetCNXADB.bat " + ttbases.cServeur + " " + ttbases.cbase). 

        /* Lecture du fichier si présent */
        IF SEARCH(loc_tmp + "\" + cFichierCnx) = ? THEN RETURN.
        IF SEARCH(loc_tmp + "\" + cFichierAdb) = ? THEN RETURN.
        IF SEARCH(loc_tmp + "\" + cFichierAddServices) = ? THEN RETURN.

        /* Ajout des services si nécessaire */
        cFichierServices = OS-GETENV("WINDIR") + "\system32\drivers\etc\services".
        lServicesOk = FALSE.
        INPUT STREAM sEntree FROM VALUE(cFichierServices).
        REPEAT:
            IMPORT STREAM sEntree UNFORMATTED cLigne.
            IF cLigne MATCHES "*i" + ttbases.cbase + "*" THEN do:
                lServicesOK = TRUE.
                LEAVE.
            END.
        END.
        INPUT STREAM sEntree CLOSE.

        IF NOT(lServicesOK) THEN DO:
            INPUT STREAM sEntree FROM VALUE(loc_tmp + "\" + cFichierAddServices).
            RUN OuvreFichierServices(cFichierServices,OUTPUT lRetour).
            IF NOT(lRetour) THEN DO:
                MESSAGE "Impossible de modifier le fichier services...Essayez de le faire manuellement."
                    VIEW-AS ALERT-BOX WARNING TITLE "Menudev2 : Modification fichier services...".
            END.
            ELSE DO:
                PUT STREAM sSortie UNFORMATTED "#" SKIP.
                PUT STREAM sSortie UNFORMATTED "# Reference " + ttbases.cbase + " : " + ttbases.cCommentaire SKIP.
                REPEAT:
                    IMPORT STREAM sEntree UNFORMATTED cLigne.
                    PUT STREAM sSortie UNFORMATTED cLigne SKIP.
                END.
                OUTPUT STREAM sSortie CLOSE.
            END.
            INPUT STREAM sEntree CLOSE.
        END.

        /* Modification du fichier cnx pour correspondre à la version demandée */
        OS-RENAME VALUE(loc_tmp + "\" + cFichierCnx) VALUE(loc_tmp + "\" + cFichierTmp).
        
        INPUT STREAM sEntree FROM VALUE(loc_tmp + "\" + cFichierTmp).
        REPEAT:
            IMPORT STREAM sEntree UNFORMATTED cLigne.
            IF TRIM(cLigne) = "" THEN NEXT.
            IF cLigne BEGINS "#" THEN NEXT.
            if cLigne MATCHES "*db cadb*"
            OR cLigne MATCHES "*db compta*"
            OR cLigne MATCHES "*db inter*"
            OR cLigne MATCHES "*db sadb*"
            OR cLigne MATCHES "*db dwh*"
            OR cLigne MATCHES "*db trans*"
            THEN PUT STREAM sSortie UNFORMATTED cLigne SKIP.
            IF (DonnePreference("PREF-CNXPASLOCAL") = "OUI") THEN DO:
                IF cLigne MATCHES "*ladb*"
                    OR cLigne MATCHES "*lcompta*"
                    OR cLigne MATCHES "*wadb*"
                    OR cLigne MATCHES "*ltrans*"
                    THEN PUT STREAM sSortie UNFORMATTED cLigne SKIP.
            END.
        END.
        INPUT STREAM sEntree CLOSE.
        PUT STREAM sSortie UNFORMATTED " " SKIP(1).
        OUTPUT STREAM sSortie CLOSE.

        /* Déplacement du fichier dans pfgi */
        OS-COPY VALUE(loc_tmp + "\" + cFichierCnx) VALUE("c:\pfgi\" + cFichierCnx).

        /* Ajout des bases locales */
        IF NOT(DonnePreference("PREF-CNXPASLOCAL") = "OUI") THEN DO:
            RUN ExecuteCommandeDos(gcRepertoireRessourcesPrivees + "\scripts\serveurs\_GenCnx2v.bat " + cRepertoireBases + " "  +  ttbases.cbase + " " + cParam + " " + "QUE_LIB").
        END.
    END.
    
    /* Suppression par défaut dans tous les répertoires */
    OS-DELETE VALUE(disque + DonneRepertoireApplication("DEV")  + "\" + cFichierAdb).
    OS-DELETE VALUE(disque + DonneRepertoireApplication("PREC") + "\" + cFichierAdb).
    OS-DELETE VALUE(disque + DonneRepertoireApplication("CLI")  + "\" + cFichierAdb).
    OS-DELETE VALUE(disque + DonneRepertoireApplication("SUIV") + "\" + cFichierAdb).
    OS-DELETE VALUE(disque + DonneRepertoireApplication("SPE")  + "\" + cFichierAdb).
    
    /* Création dans le bon répertoire */
    cOuCopier = cParam.

    OS-COPY VALUE(loc_tmp + "\" + cFichierAdb)  VALUE(cOuCopier + "\" + cFichierAdb).

    /* Modification du cnx si bases lib fixes */
    IF ttbases.cRepertoire <> "Dev" THEN DO:
        cLigneTmp = "".
        lBasesLibFixes = FALSE
                        OR (ttbases.cRepertoire = "PREC" AND DonnePreference("PREF-MAGICONNEXPREC") = "oui")
                        OR (ttbases.cRepertoire = "CLI" AND DonnePreference("PREF-MAGICONNEXCLI") = "oui")
                        OR (ttbases.cRepertoire = "SUIV" AND DonnePreference("PREF-MAGICONNEXSUIV") = "oui")
                        OR (ttbases.cRepertoire = "SPE" AND DonnePreference("PREF-MAGICONNEXSPE") = "oui")
                        .
        IF lBasesLibFixes THEN DO:
            INPUT STREAM sEntree FROM VALUE("c:\pfgi\" + cFichierCnx).
            OUTPUT STREAM sSortie TO VALUE(loc_tmp + "\" + cFichierCnx).
            REPEAT:
                IMPORT STREAM sEntree UNFORMATTED cLigne.
                
                IF cLigne MATCHES "*ladb*"
                OR cLigne MATCHES "*lcompta*"
                OR cLigne MATCHES "*wadb*"
                OR cLigne MATCHES "*ltrans*"
                THEN do:
                    NEXT.
                END.
                
                IF cLigne MATCHES "*-h *" THEN DO:
                    /* pour le rajouter à la fin */
                    cLigneTmp = cLigne.
                    NEXT.
                END.

                PUT STREAM sSortie UNFORMATTED cLigne SKIP.
            END.
            INPUT STREAM sEntree CLOSE.

            PUT STREAM sSortie UNFORMATTED DonnePreference("PREF-MAGICONNEXLIB" + ttbases.cRepertoire) SKIP.

            IF cLigneTmp <> ""  THEN DO:
                PUT STREAM sSortie UNFORMATTED " " SKIP cLigneTmp SKIP.
            END.
            OUTPUT STREAM sSortie CLOSE.
            lModificationCnx = TRUE.
        END.
    END.

    /* Déplacement du fichier dans pfgi */
    IF lModificationCnx THEN DO:
        OS-COPY VALUE(loc_tmp + "\" + cFichierCnx) VALUE("c:\pfgi\" + cFichierCnx).
    END.


    OS-COMMAND NO-WAIT value("notepad.exe " + "c:\pfgi\" + cFichierCnx).  

    AfficheInformations("",0).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_lk
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_lk C-Win
ON CHOOSE OF MENU-ITEM m_lk /* Supprimer les .lk (en cas d'arrêt violent des bases) */
DO:
    DEFINE VARIABLE cTempo AS CHARACTER NO-UNDO.

    IF NOT(AVAILABLE(ttBases)) THEN RETURN NO-APPLY.
    IF ttbases.cServeur = "Local" THEN DO:
        IF ttbases.lLib THEN DO:
            /*
            cTempo = ttBases.cbase.
            IF cTempo = "CLI" THEN
                cTempo = "gi\".
            ELSE IF cTempo = "DEV" THEN
                cTempo = "gidev\".
            ELSE 
                cTempo = "gi_"+ ttBases.cbase + "\gi\".

            cTempo = disque + cTempo + "baselib".
            */
            cTempo = ttbases.cCheminBases.
            RUN ExecuteCommandeDos(gcRepertoireRessourcesPrivees + "\scripts\serveurs\_GI-SupprimeLKLib.bat " + cTempo + " "  + ttBases.cbase + " " + (IF toggle-1:CHECKED IN FRAME frmfonction THEN "pause" ELSE "")).
        END.
        ELSE DO:
            RUN ExecuteCommandeDos(gcRepertoireRessourcesPrivees + "\scripts\serveurs\_GI-SupprimeLK.bat " + cRepertoireBases + " "  + ttBases.cbase + " " + (IF toggle-1:CHECKED IN FRAME frmfonction THEN "pause" ELSE "")).
        END.
    END.
    RUN AfficheMessageAvecTemporisation("Commande en cours","Un avertissement sera envoyé dans la zone information de menudev2 quand la commande sera terminée.",FALSE,5,"OK","MESSAGE-LK",FALSE,OUTPUT cRetour).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Monter_la_version_de_la_bas
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Monter_la_version_de_la_bas C-Win
ON CHOOSE OF MENU-ITEM m_Monter_la_version_de_la_bas /* Monter la version de la base */
DO:
    /* Passage d'une base d'une version à une autre */

    /* Lancement de l'outil de génération du fichier de montage de version */
    RUN GenereFichierVersion.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Nouvelle
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Nouvelle C-Win
ON CHOOSE OF MENU-ITEM m_Nouvelle /* Nouvelle base */
DO:
    RUN DonnePositionMessage IN ghGeneral.
    gcAllerRetour = STRING(giPosXMessage)
        + "|" + STRING(giPosYMessage)
        + "|" + "Référence de la base"
        + "|" + "".
    RUN VALUE(gcRepertoireExecution + "saisie2.w") (INPUT-OUTPUT gcAllerRetour).
    IF gcAllerRetour = "" THEN RETURN.
    IF LENGTH(ENTRY(4,gcAllerRetour,"|")) > 5 THEN DO:
        MESSAGE "Il est préférable que le nom du répertoire soit sur 5 caractères !"
            VIEW-AS ALERT-BOX ERROR TITLE "Menudev2 : Contrôle saisie".
        RETURN.
    END.
    RUN ExecuteCommandeDos("xCOPY /S /I " + gcRepertoireRessourcesPrivees + "\scripts\serveurs\00000 " + cRepertoireBases + "\" + ENTRY(4,gcAllerRetour,"|")).
    
    /*RUN ChargeBases.*/ /* fait dans topchronogeneral */
    SauvePreference("DERNIERE-BASE","Local" + "," + ENTRY(4,gcAllerRetour,"|")).
    RUN Recharger.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Repair
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Repair C-Win
ON CHOOSE OF MENU-ITEM m_Repair /* Truncate/Repair */
DO:
    DEFINE VARIABLE cTempo AS CHARACTER NO-UNDO.

    IF NOT(AVAILABLE(ttBases)) THEN RETURN NO-APPLY.
    AfficheInformations("Repair en cours...",0).
    IF ttbases.cServeur = "Local" THEN DO:
        IF ttbases.lLib THEN DO:
            /*
            cTempo = ttBases.cbase.
            IF cTempo = "CLI" THEN
                cTempo = "gi\".
            ELSE IF cTempo = "DEV" THEN
                cTempo = "gidev\".
            ELSE 
                cTempo = "gi_"+ ttBases.cbase + "\gi\".

            cTempo = disque + cTempo + "baselib".
            */
            cTempo = ttbases.cCheminBases.
        END.
        ELSE DO:
            cTempo = cRepertoireBases + "\" + ttBases.cbase.
        END.
    END.
    RUN ExecuteCommandeDos(gcRepertoireRessourcesPrivees + "\scripts\serveurs\_GI-LanceRepair.bat " + cTempo).
    AfficheInformations("",0).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Rep_gidev
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Rep_gidev C-Win
ON CHOOSE OF MENU-ITEM m_Rep_gidev /* (Dev)eloppement */
DO:
    DEFINE VARIABLE lMajCNX AS LOGICAL NO-UNDO INIT FALSE.

    IF NOT(AVAILABLE(ttbases)) THEN RETURN NO-APPLY.
    lMajCnx = (ttbases.cRepertoire <> "DEV").
    ttbases.cRepertoire = "DEV".
    IF ttbases.cServeur = "Local" THEN DO:
        run SauveInfosBase(ttbases.cbase,"").
    END.
    ELSE DO:
        RUN MajVersionBase("DEV").
    END.

    RUN Recharger.
    RUN LanceGenerationCNX(lMajCnx).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Rep_n
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Rep_n C-Win
ON CHOOSE OF MENU-ITEM m_Rep_n /* (Cli)ent */
DO:
    DEFINE VARIABLE lMajCNX AS LOGICAL NO-UNDO INIT FALSE.
    
    IF NOT(AVAILABLE(ttbases)) THEN RETURN NO-APPLY.
    lMajCnx = (ttbases.cRepertoire <> "CLI").
    ttbases.cRepertoire = "CLI".
    IF ttbases.cServeur = "Local" THEN DO:
        run SauveInfosBase(ttbases.cbase,"").
    END.
    ELSE DO:
        RUN MajVersionBase("CLI").
    END.
    RUN Recharger.
    RUN LanceGenerationCNX(lMajCnx).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Rep_nmoins1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Rep_nmoins1 C-Win
ON CHOOSE OF MENU-ITEM m_Rep_nmoins1 /* (Préc)édente */
DO:
    DEFINE VARIABLE lMajCNX AS LOGICAL NO-UNDO INIT FALSE.

    IF NOT(AVAILABLE(ttbases)) THEN RETURN NO-APPLY.
    lMajCnx = (ttbases.cRepertoire <> "PREC").
    ttbases.cRepertoire = "PREC".
    IF ttbases.cServeur = "Local" THEN DO:
        run SauveInfosBase(ttbases.cbase,"").
    END.
    ELSE DO:
        RUN MajVersionBase("PREC").
    END.
    RUN Recharger.
    RUN LanceGenerationCNX(lMajCnx).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Rep_nplus1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Rep_nplus1 C-Win
ON CHOOSE OF MENU-ITEM m_Rep_nplus1 /* (Suiv)ante */
DO:
    DEFINE VARIABLE lMajCNX AS LOGICAL NO-UNDO INIT FALSE.
    
    IF NOT(AVAILABLE(ttbases)) THEN RETURN NO-APPLY.
    lMajCnx = (ttbases.cRepertoire <> "SUIV").
    ttbases.cRepertoire = "SUIV".
    IF ttbases.cServeur = "Local" THEN DO:
        run SauveInfosBase(ttbases.cbase,"").
    END.
    ELSE DO:
        RUN MajVersionBase("SUIV").
    END.
    RUN Recharger.
    RUN LanceGenerationCNX(lMajCnx).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Restaurer
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Restaurer C-Win
ON CHOOSE OF MENU-ITEM m_Restaurer /* Restaurer */
DO:
    IF NOT(AVAILABLE(ttBases)) THEN RETURN NO-APPLY.
    IF ttbases.cServeur = "Local" THEN DO:
        /* Controle de la place restante */
        RUN ExecuteCommandeDos(gcRepertoireRessourcesPrivees + "\scripts\serveurs\DonneTailleSvg.bat " + cRepertoireBases + " " + ttBases.cbase).
        INPUT STREAM sEntree FROM VALUE(cRepertoireBases + "\" + ttBases.cbase + "\_Taille.tmpmdev2") /*CONVERT TARGET "IBM850"*/.
        REPEAT:
            IMPORT STREAM sEntree UNFORMATTED cLigne.
            IF cLigne <> "" THEN DO:
                cLigne = SUBSTRING(cLigne,27,13).
                cLigne = trim(replace(cLigne," ","")).
                cLigne = trim(replace(cLigne,"ÿ","")).
                iTailleSvg = INT64(cLigne).
            END.
        END.
        INPUT STREAM sEntree CLOSE.
        /* Suppression du fichier de travail */
        OS-DELETE VALUE(cRepertoireBases + "\" + ttBases.cbase + "\_Taille.tmpmdev2").
        IF iTailleSvg > iDispoDisque THEN DO:
            MESSAGE "Pas assez de place pour décompresser la base"
                VIEW-AS ALERT-BOX INFORMATION TITLE "Menudev2 : Restauration abandonnée".
            RETURN NO-APPLY.
        END.
        cLibelle = "Confirmez-vous la restauration de la base "  + ttBases.cbase
            + CHR(10) + "Cette restauration nécessitera " + formatteTaille(iTailleSvg) + " d'espace disque.".
        RUN AfficheMessageAvecTemporisation("Gestion des bases",cLibelle,TRUE,10,"NON","",FALSE,OUTPUT cRetour).
        IF cRetour = "NON" THEN RETURN NO-APPLY.
        RUN ExecuteCommandeDos(gcRepertoireRessourcesPrivees + "\scripts\serveurs\_GI-restore.bat " + cRepertoireBases + " "  + ttBases.cbase + " " + (IF toggle-1:CHECKED IN FRAME frmfonction THEN "pause" ELSE "")).
    END.
    ELSE DO:
        cLibelle = "Confirmez-vous la restauration de la base "  + ttBases.cbase.
        RUN AfficheMessageAvecTemporisation("Gestion des bases",cLibelle,TRUE,10,"NON","",FALSE,OUTPUT cRetour).
        IF cRetour = "NON" THEN RETURN NO-APPLY.
        RUN DemandeDistante("r" + ttbases.cBase).
    END.
    RUN AfficheMessageAvecTemporisation("Restauration en cours","Un avertissement sera envoyé dans la zone information de menudev2 quand la restauration sera terminée.",FALSE,5,"OK","MESSAGE-RESTAURER",FALSE,OUTPUT cRetour).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Sauvegarder
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Sauvegarder C-Win
ON CHOOSE OF MENU-ITEM m_Sauvegarder /* Sauvegarder */
DO:
    IF NOT(AVAILABLE(ttBases)) THEN RETURN NO-APPLY.
    cLibelle = "Confirmez-vous la sauvegarde de la base "  + ttBases.cbase.
    RUN AfficheMessageAvecTemporisation("Gestion des bases",cLibelle,TRUE,10,"NON","",FALSE,OUTPUT cRetour).
    IF cRetour = "NON" THEN RETURN NO-APPLY.
    IF ttbases.cServeur = "Local" THEN DO:
        RUN ExecuteCommandeDos(gcRepertoireRessourcesPrivees + "\scripts\serveurs\_GI-Sauvegarde.bat " + cRepertoireBases + " "  + ttBases.cbase + " " + (IF toggle-1:CHECKED IN FRAME frmfonction THEN "pause" ELSE "rem") + " -mx" + DonnePreference("PREF-COMPRESSION")).
        RUN AfficheMessageAvecTemporisation("Sauvegarde en cours","Un avertissement sera envoyé dans la zone information de menudev2 quand la sauvegarde sera terminée.",FALSE,5,"OK","MESSAGE-SAUVEGARDER",FALSE,OUTPUT cRetour).
    END.
    ELSE DO:
        RUN DemandeDistante("s" + ttbases.cBase).
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Specifique
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Specifique C-Win
ON CHOOSE OF MENU-ITEM m_Specifique /* (Spe)cifique */
DO:
  
    DEFINE VARIABLE lMajCNX AS LOGICAL NO-UNDO INIT FALSE.
    
    IF NOT(AVAILABLE(ttbases)) THEN RETURN NO-APPLY.
    lMajCnx = (ttbases.cRepertoire <> "SPE").
    ttbases.cRepertoire = "SPE".
    IF ttbases.cServeur = "Local" THEN DO:
        run SauveInfosBase(ttbases.cbase,"").
    END.
    ELSE DO:
        RUN MajVersionBase("SPE").
    END.
    RUN Recharger.
    RUN LanceGenerationCNX(lMajCnx).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_SupprimeBase
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_SupprimeBase C-Win
ON CHOOSE OF MENU-ITEM m_SupprimeBase /* Supprimer la base */
DO:
    IF NOT(AVAILABLE(ttBases)) THEN RETURN NO-APPLY.

    cLibelle = "Confirmez-vous la suppression de la base "  + ttBases.cbase.
    RUN AfficheMessageAvecTemporisation("Gestion des bases",cLibelle,TRUE,10,"NON","",FALSE,OUTPUT cRetour).
    IF cRetour = "NON" THEN RETURN NO-APPLY.

    AfficheInformations("Suppression de la base en cours...",0).
    RUN ExecuteCommandeDos(gcRepertoireRessourcesPrivees + "\scripts\serveurs\_GI-supprime.bat " + cRepertoireBases + " "  + ttBases.cbase + " " + (IF toggle-1:CHECKED IN FRAME frmfonction THEN "pause" ELSE "")).
    
    /* Si demandé dans les préférences, suppression du fichier cnx et adb */
    IF DonnePreference("PREFS-SUPPRIME-CNX-ADB") = "OUI" THEN DO:
        OS-DELETE VALUE("c:\pfgi\cnx" + ttBases.cbase + ".pf").
        OS-DELETE VALUE(disque + "gi\adb" + ttBases.cbase).
        OS-DELETE VALUE(disque + "gi\pme" + ttBases.cbase).
        OS-DELETE VALUE(disque + "gi_prec\gi\adb" + ttBases.cbase).
        OS-DELETE VALUE(disque + "gi_prec\gi\pme" + ttBases.cbase).
        OS-DELETE VALUE(disque + "gi_suiv\gi\adb" + ttBases.cbase).
        OS-DELETE VALUE(disque + "gi_suiv\gi\pme" + ttBases.cbase).
        OS-DELETE VALUE(disque + "gi_spe\gi\adb" + ttBases.cbase).
        OS-DELETE VALUE(disque + "gi_spe\gi\pme" + ttBases.cbase).
    END.

    RUN AfficheMessageAvecTemporisation("Gestion des bases","Suppression effectuée.",FALSE,5,"OK","MESSAGE-SUPPRIMEBASE",FALSE,OUTPUT cRetour).
    RUN Recharger /*TopChronoGeneral*/.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_SupprimeSVG
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_SupprimeSVG C-Win
ON CHOOSE OF MENU-ITEM m_SupprimeSVG /* Supprimer la sauvegarde */
DO:
    IF NOT(AVAILABLE(ttBases)) THEN RETURN NO-APPLY.

    cLibelle = "Confirmez-vous la suppression de la sauvegarde de la base "  + ttBases.cbase.
    RUN AfficheMessageAvecTemporisation("Gestion des bases",cLibelle,TRUE,10,"NON","",FALSE,OUTPUT cRetour).
    IF cRetour = "NON" THEN RETURN NO-APPLY.

    AfficheInformations("Suppression de la sauvegarde en cours...",0).
    RUN ExecuteCommandeDos(gcRepertoireRessourcesPrivees + "\scripts\serveurs\_GI-supprime.bat " + cRepertoireBases + " "  + ttBases.cbase + "\svg " + (IF toggle-1:CHECKED IN FRAME frmfonction THEN "pause" ELSE "")).
    
    RUN AfficheMessageAvecTemporisation("Gestion des bases","Suppression effectuée.",FALSE,5,"OK","MESSAGE-SUPPRIMESAUVEGARDE",FALSE,OUTPUT cRetour).
    RUN Recharger /*TopChronoGeneral*/.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Tout
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Tout C-Win
ON CHOOSE OF MENU-ITEM m_Tout /* Arrêter toutes les bases (base + baselib) */
DO:
    

    DEFINE VARIABLE cTempo AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cCommande AS CHARACTER NO-UNDO.
    
    cLibelle = "Confirmez-vous la fermeture de tous les serveurs actifs ?".
    RUN AfficheMessageAvecTemporisation("Gestion des bases",cLibelle,TRUE,10,"NON","",FALSE,OUTPUT cRetour).
    IF cRetour = "NON" THEN RETURN NO-APPLY.

    IF DonnePreference("PREF-FERMERTOUTES=TOUT") = "OUI" THEN DO:
        FOR EACH bttbasesRef
            WHERE bttbasesRef.ldemarree
            AND (bttbasesRef.cProgress = gcVersionProgress OR bttbasesRef.cProgress = "" OR bttbasesRef.cProgress = "inc.")
            :            
            IF bttbasesRef.cServeur = "Local" THEN DO:
                IF bttbasesRef.lLib THEN DO:
                    cTempo = bttbasesRef.cCheminBases.
                    cCommande = gcRepertoireRessourcesPrivees + "\scripts\serveurs\_GI-FermeLibelles.bat " + cTempo + " "  + bttbasesRef.cbase + " " 
                              + (IF toggle-1:CHECKED IN FRAME frmFonction THEN "pause" ELSE "").
                    OS-COMMAND value(cCommande).
                END.
                ELSE DO:
                    cTempo = "".
                    cCommande = gcRepertoireRessourcesPrivees + "\scripts\serveurs\_GI-FermeServeurs.bat " + cRepertoireBases + " "  + bttbasesRef.cbase + " " 
                              + (IF toggle-1:CHECKED IN FRAME frmFonction THEN "pause" ELSE "").
                    OS-COMMAND value(cCommande).
                END.
            END.
            bttbasesRef.lNo-Integrity = FALSE.
            run SauveInfosBase(bttbasesRef.cbase,cTempo).
        END.
    END.
    ELSE DO:
        FOR EACH bttbases
            WHERE bttbases.ldemarree
            AND (bttbasesRef.cProgress = gcVersionProgress OR bttbasesRef.cProgress = "" OR bttbasesRef.cProgress = "inc.")
            :
            IF bttbases.cServeur = "Local" THEN DO:
                IF bttbases.lLib THEN DO:
                    cTempo = bttbases.cCheminBases.
                    cCommande = gcRepertoireRessourcesPrivees + "\scripts\serveurs\_GI-FermeLibelles.bat " + cTempo + " "  + bttbases.cbase + " " 
                              + (IF toggle-1:CHECKED IN FRAME frmFonction THEN "pause" ELSE "").
                    OS-COMMAND value(cCommande).
                END.
                ELSE DO:
                    cTempo = "".
                    cCommande = gcRepertoireRessourcesPrivees + "\scripts\serveurs\_GI-FermeServeurs.bat " + cRepertoireBases + " "  + bttbases.cbase + " " 
                              + (IF toggle-1:CHECKED IN FRAME frmFonction THEN "pause" ELSE "").
                    OS-COMMAND value(cCommande).
                END.
            END.
            bttbases.lNo-Integrity = FALSE.
            run SauveInfosBase(bttbases.cbase,cTempo).
        END.
    END.
    RUN Recharger.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Voir_les_batches_de_prepost
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Voir_les_batches_de_prepost C-Win
ON CHOOSE OF MENU-ITEM m_Voir_les_batches_de_prepost /* Voir les batches de pré/post sauvegarde/restauration */
DO:

    /* Pré-Restauration */
    cFichierBatch = gcRepertoireRessourcesPrivees + "Utilisateurs\" + gcUtilisateur + "\" + gcUtilisateur + "-PreResto-" + ttbases.cBase + ".bat".   
    IF SEARCH(cFichierBatch) = ? THEN DO:
       OS-COMMAND SILENT VALUE("copy """ + gcRepertoireRessourcesPrivees + "Utilisateurs\_ModelePostPre.bat"" """ + cFichierBatch + """"). 
    END.
    OS-COMMAND SILENT VALUE(gcRepertoireRessourcesPrivees + "\scripts\general\execute2.bat notepad.exe """ + cFichierBatch + """").

    /* Post-Restauration */
    cFichierBatch = gcRepertoireRessourcesPrivees + "Utilisateurs\" + gcUtilisateur + "\" + gcUtilisateur + "-PostResto-" + ttbases.cBase + ".bat".   
    IF SEARCH(cFichierBatch) = ? THEN DO:
       OS-COMMAND SILENT VALUE("copy """ + gcRepertoireRessourcesPrivees + "Utilisateurs\_ModelePostPre.bat"" """ + cFichierBatch + """"). 
    END.
    OS-COMMAND SILENT VALUE(gcRepertoireRessourcesPrivees + "\scripts\general\execute2.bat notepad.exe """ + cFichierBatch + """").
    
    /* Pré-sauvegarde */
    cFichierBatch = gcRepertoireRessourcesPrivees + "Utilisateurs\" + gcUtilisateur + "\" + gcUtilisateur + "-PreSvg-" + ttbases.cBase + ".bat".   
    IF SEARCH(cFichierBatch) = ? THEN DO:
       OS-COMMAND SILENT VALUE("copy """ + gcRepertoireRessourcesPrivees + "Utilisateurs\_ModelePostPre.bat"" """ + cFichierBatch + """"). 
    END.
    OS-COMMAND SILENT VALUE(gcRepertoireRessourcesPrivees + "\scripts\general\execute2.bat notepad.exe """ + cFichierBatch + """").

    /* Post-sauvegarde */
    cFichierBatch = gcRepertoireRessourcesPrivees + "Utilisateurs\" + gcUtilisateur + "\" + gcUtilisateur + "-PostSvg-" + ttbases.cBase + ".bat".   
    IF SEARCH(cFichierBatch) = ? THEN DO:
       OS-COMMAND SILENT VALUE("copy """ + gcRepertoireRessourcesPrivees + "Utilisateurs\_ModelePostPre.bat"" """ + cFichierBatch + """"). 
    END.
    OS-COMMAND SILENT VALUE(gcRepertoireRessourcesPrivees + "\scripts\general\execute2.bat notepad.exe """ + cFichierBatch + """").

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rsChoixBases
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rsChoixBases C-Win
ON VALUE-CHANGED OF rsChoixBases IN FRAME frmFonction
DO:

    SauvePreference("PREF-BASESTYPE",SELF:SCREEN-VALUE).
    RUN GereTglBases.
    RUN recharger.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frmfiltres
&Scoped-define SELF-NAME rsFiltreEt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rsFiltreEt C-Win
ON VALUE-CHANGED OF rsFiltreEt IN FRAME frmfiltres
DO:
    SauvePreference("FILTRE-ET",(IF SELF:SCREEN-VALUE = "YES" THEN "OUI" ELSE "NON")).
    IF lFiltreToutDeSuite THEN RUN recharger.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frmFonction
&Scoped-define SELF-NAME tglBarbade
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglBarbade C-Win
ON VALUE-CHANGED OF tglBarbade IN FRAME frmFonction /* Bases présentes sur Barbade */
DO:
  
    SauvePreference("PREF-BASESBARBADE",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
    lActionManuelle = TRUE.
    RUN Recharger /*TopChronoGeneral*/.
    APPLY "ENTRY" TO brwbases.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frmfiltres
&Scoped-define SELF-NAME tglFiltreAbsente
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglFiltreAbsente C-Win
ON VALUE-CHANGED OF tglFiltreAbsente IN FRAME frmfiltres /* Base absente */
DO:
  
    SauvePreference("FILTRE-BASEABSENTE",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
    IF lFiltreToutDeSuite THEN RUN recharger.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglFiltreFermee
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglFiltreFermee C-Win
ON VALUE-CHANGED OF tglFiltreFermee IN FRAME frmfiltres /* Base Fermée */
DO:
  
    SauvePreference("FILTRE-BASEFERMEE",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
    IF lFiltreToutDeSuite THEN RUN recharger.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglFiltreOuverte
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglFiltreOuverte C-Win
ON VALUE-CHANGED OF tglFiltreOuverte IN FRAME frmfiltres /* Base ouverte */
DO:
  
    SauvePreference("FILTRE-BASEOUVERTE",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
    IF lFiltreToutDeSuite THEN RUN recharger.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglFiltrePresente
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglFiltrePresente C-Win
ON VALUE-CHANGED OF tglFiltrePresente IN FRAME frmfiltres /* Base présente */
DO:
  
    SauvePreference("FILTRE-BASEPRESENTE",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
    IF lFiltreToutDeSuite THEN RUN recharger.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglFiltreSauvegardeAbsente
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglFiltreSauvegardeAbsente C-Win
ON VALUE-CHANGED OF tglFiltreSauvegardeAbsente IN FRAME frmfiltres /* Sauvegarde Absente */
DO:
  
    SauvePreference("FILTRE-SAUVEGARDEABSENTE",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
    IF lFiltreToutDeSuite THEN RUN recharger.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglFiltreSauvegardePresente
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglFiltreSauvegardePresente C-Win
ON VALUE-CHANGED OF tglFiltreSauvegardePresente IN FRAME frmfiltres /* Sauvegarde présente */
DO:
  
    SauvePreference("FILTRE-SAUVEGARDEPRESENTE",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
    IF lFiltreToutDeSuite THEN RUN recharger.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frmFonction
&Scoped-define SELF-NAME tglLocal
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglLocal C-Win
ON VALUE-CHANGED OF tglLocal IN FRAME frmFonction /* Bases Locales */
DO:
  
    SauvePreference("PREF-BASESLOCALES",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
    IF SELF:CHECKED AND DonnePreference("REPERTOIRE-BASES") = "" THEN DO:
        RUN AfficheMessageAvecTemporisation("Contrôles...","Vous n'avez pas précisé de répertoire pour les bases dans les préférences !",FALSE,5,"OK","MESSAGE-BASELOCALE",FALSE,OUTPUT cRetour).
    END.
    lActionManuelle = TRUE.
    RUN Recharger /*TopChronoGeneral*/.
    APPLY "ENTRY" TO brwbases.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglNeptune2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglNeptune2 C-Win
ON VALUE-CHANGED OF tglNeptune2 IN FRAME frmFonction /* Bases présentes sur Neptune2 */
DO:
  
    SauvePreference("PREF-BASESNEPTUNE2",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
    lActionManuelle = TRUE.
    RUN Recharger /*TopChronoGeneral*/.
    APPLY "ENTRY" TO brwbases.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglOuvertes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglOuvertes C-Win
ON VALUE-CHANGED OF tglOuvertes IN FRAME frmFonction /* Bases ouvertes en tête de liste */
DO:
  
    SauvePreference("PREF-BASESOUVERTESENTETE",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
    lActionManuelle = TRUE.
    RUN Recharger /*TopChronoGeneral*/.
    APPLY "ENTRY" TO brwbases.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglRegrouper
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglRegrouper C-Win
ON VALUE-CHANGED OF tglRegrouper IN FRAME frmFonction /* Regrouper les bases similaires */
DO:
    SauvePreference("PREF-REGROUPERBASES",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
    lActionManuelle = TRUE.
    RUN Recharger /*TopChronoGeneral*/.
    APPLY "ENTRY" TO brwbases.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME TOGGLE-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL TOGGLE-2 C-Win
ON VALUE-CHANGED OF TOGGLE-2 IN FRAME frmFonction /* Démarrage en 'No-Integrity' */
DO:
    SELF:BGCOLOR = (IF SELF:CHECKED THEN 12 ELSE ?).
    SELF:FGCOLOR = (IF SELF:CHECKED THEN 15 ELSE ?).
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE BasesUtilisateurs C-Win 
PROCEDURE BasesUtilisateurs :
DEFINE INPUT PARAMETER cAction-in AS CHARACTER NO-UNDO.
    
    DEFINE VARIABLE cFichier AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cFichierXLS AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cFichiertempo AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cFichierMacros AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cLigne AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cTempo AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cTempo2 AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cTempoUtil AS CHARACTER NO-UNDO.

    IF cAction-in = "EXCEL" THEN AfficheInformations("Veuillez patienter...",0).

    /* Génération du fichier temporaire */
    cFichier = LOC_TMP + "\Bases.tmpmdev2".
    cFichierTempo = REPLACE(cFichier,".tmpmdev2",".tmp").
    cFichierXLS = REPLACE(cFichier,".tmpmdev2",".xls").
    cFichierMacros = ser_outils + "\commdev\macros.xls".

    /* Ouverture du fichier de sortie */
    OUTPUT TO VALUE(cFichierTempo).
    PUT UNFORMATTED "PARAM;10;2;2;0;0;0;0;192;192;192;" SKIP.  
    PUT UNFORMATTED "TAILLE;15;20;25;15;10;15;50;15;15;15" SKIP.
    PUT UNFORMATTED "HALIGN;-4131;-4131;-4131;-4131;-4131;-4131;-4131;-4131;-4131;-4131" SKIP.
    PUT UNFORMATTED "FORMAT;C;C;C;C;C;C;C;D;C;C" SKIP.
    PUT UNFORMATTED "ENT1;Liste des bases des utilisateurs de Menudev2" SKIP.

    PUT UNFORMATTED "TIT1;Utilisateur;Repertoire;UNC;Version;Base;Sauvegarde;Commentaire;Date;Machine;Version Progress" SKIP.
    FOR EACH    fichiers    NO-LOCK
        WHERE   fichiers.cTypeFichier = "BASES"
        AND     fichiers.cIdentFichier = "bases"
        :
        cTempo = CHR(10) + fichiers.texte.
        /* remplacement du nom utilisateur du fichier en cours pour avoir toutes les lignes pour le fichier excel */.
        PUT UNFORMATTED replace(cTempo,CHR(10) + fichiers.cUtilisateur + ";",chr(10) + "LIGHYPERLIEN;" + fichiers.cUtilisateur + ";") SKIP.
    END.
    OUTPUT CLOSE.

    /* Relecture du fichier pour enlever les lignes blanches */
    INPUT FROM VALUE(cFichierTempo).
    OUTPUT TO VALUE (cFichier).
    REPEAT:
        IMPORT UNFORMATTED cLigne.
        IF trim(cLigne) = "" THEN NEXT.
        PUT UNFORMATTED cLigne SKIP.
    END.
    INPUT CLOSE.
    OUTPUT CLOSE.

    /*OS-COMMAND NO-WAIT VALUE("%reseau%\dev\outils\progress\Menudev2\Ressources\Scripts\general\execute2.bat /MIN %reseau%\dev\outils\progress\Menudev2\Ressources\Scripts\general\listeBases.bat").*/
    IF cAction-in = "EXCEL" THEN DO:
        MiseEnForme(FALSE,cFichierMacros,cFichierXLS,cFichier,"Liste des bases").
    END.
    ELSE DO:
    
        /* Chargement du browse avec le contenu du fichier */
        INPUT FROM VALUE(cFichier).
        REPEAT:
            IMPORT UNFORMATTED cLigne.
            IF trim(cLigne) = "" THEN NEXT.
            IF NOT(cLigne BEGINS("LIGHYPERLIEN")) THEN NEXT.
            cTempoUtil = ENTRY(2,cLigne,";").
            /* Si l'utilisateur n'existe plus on passe */
            FIND FIRST  Utilisateurs    NO-LOCK
                WHERE  Utilisateurs.cUtilisateur = cTempoUtil
                OR     Utilisateurs.cVraiNom = cTempoUtil 
                NO-ERROR.
            IF NOT AVAILABLE(Utilisateurs) THEN NEXT.
            CREATE ttbases.
            ASSIGN
            ttbases.cServeur = cTempoUtil
            cTempo = IF num-entries(cLigne,";") >= 3 THEN ENTRY(3,cLigne,";") ELSE ""
            ttbases.cbase = ENTRY(NUM-ENTRIES(cTempo,"\"),cTempo,"\")
            ttbases.ldemarree = FALSE
            ttbases.cTri = (IF DonnePreference("PREF-TRIBASES") = "OUI" THEN SUBSTRING(ttbases.cbase,2) ELSE ttbases.cbase)
            ttBases.cCommentaire = IF num-entries(cLigne,";") >= 8 THEN ENTRY(8,cLigne,";") ELSE ?
            ttbases.lbase = (IF num-entries(cLigne,";") >= 6 THEN ENTRY(6,cLigne,";") = "OUI" ELSE ?)
            ttbases.lsauvegarde = (IF num-entries(cLigne,";") >= 7 THEN ENTRY(7,cLigne,";") = "OUI" ELSE ?)
            ttBases.cVersion = IF num-entries(cLigne,";") >= 5 THEN ENTRY(5,cLigne,";") ELSE ?
            ttBases.cURL = IF num-entries(cLigne,";") >= 4 THEN ENTRY(4,cLigne,";") ELSE ?
            ttbases.lUtil = TRUE
            ttbases.dDateSauvegarde = (IF num-entries(cLigne,";") >= 9 THEN DATE(ENTRY(9,cLigne,";")) ELSE ?)
            ttbases.cMachine = (IF num-entries(cLigne,";") >= 10 THEN ENTRY(10,cLigne,";") ELSE ?)
            ttbases.cProgress = (IF num-entries(cLigne,";") >= 11 THEN ENTRY(11,cLigne,";") ELSE "")
            NO-ERROR.
        END.
        INPUT CLOSE.
    
    END.
    
    /* Suppression des fichiers temporaires */
    OS-DELETE VALUE(cFichierTempo).
    OS-DELETE VALUE(cFichier).

    IF cAction-in = "EXCEL" THEN AfficheInformations("",0).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CalculeVersion C-Win 
PROCEDURE CalculeVersion :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE cFichierInfosBases AS CHARACTER NO-UNDO. 

    /*---
    cFichierInfosBases = cRepertoireBases + "\" + ttBases.cbase + "\_Version.tmpmdev2".
    OS-COMMAND SILENT value(gcRepertoireRessourcesPrivees + "\scripts\serveurs\_GI-Lancecrc.bat " + cRepertoireBases + "\" + ttBases.cbase).
    IF  SEARCH(cFichierversion) <> ? THEN DO:
        INPUT STREAM sEntree FROM VALUE(cFichierversion).
        REPEAT:
            IMPORT STREAM sEntree UNFORMATTED cLigne.
            IF cLigne <> "" THEN DO:
                ttBases.cVersion = cLigne.
                LEAVE.
            END.
        END.
        INPUT STREAM sEntree CLOSE.
    END.
    ELSE DO:
        ttBases.cVersion = "".
    END.
    OS-DELETE VALUE(cFichierversion).
    Mlog("Version Application - Recherche version : " + ttbases.cBase + " -> " + cFichierversion + " => " + ttBases.cVersion).
    ----*/
    cFichierInfosBases = cRepertoireBases + "\" + ttBases.cbase + "\_infos.mdev2".
    OS-COMMAND SILENT value(gcRepertoireRessourcesPrivees + "\scripts\serveurs\_GI-Lancecrc.bat " + cRepertoireBases + "\" + ttBases.cbase).
    RUN RecupereInfosBase(cFichierInfosBases).
    IF AVAILABLE ttBases THEN ttBases.cVersion = cIbVersion.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ChargeBases C-Win 
PROCEDURE ChargeBases :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE cFichierBases AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cLigne AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cListe AS CHARACTER NO-UNDO.
    
    
    /* Liste des bases */
    cFichierBases = loc_tmp + "\bases.lst".
    cRepertoireBases = DonnePreference("REPERTOIRE-BASES").
    IF cRepertoireBases = "" THEN RETURN.
    OS-COMMAND SILENT VALUE("dir /b /a:d " + cRepertoireBases + " > " + cFichierBases).
    
    /* Ouverture du fichier */
    INPUT STREAM sEntree FROM VALUE(loc_tmp + "\bases.lst").

    /* Chargement de la table des bases */
    /*EMPTY TEMP-TABLE ttbases.*/
    REPEAT:
        IMPORT STREAM sEntree UNFORMATTED cLigne.
        IF cLigne = "" OR cLigne = "00000" THEN NEXT.
        CREATE ttbases.
        ttbases.cbase = cLigne.
        ttbases.cServeur = "Local".
        ttbases.ldemarree = FALSE.
        ttbases.cTri = (IF DonnePreference("PREF-TRIBASES") = "OUI" THEN SUBSTRING(ttbases.cbase,2) ELSE ttbases.cbase).
        ttbases.lLib = FALSE.
        ttbases.lUtil = FALSE.  
    END.

    /* Fermeture du fichier */
    INPUT STREAM sEntree CLOSE.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ChargeBasesLib C-Win 
PROCEDURE ChargeBasesLib :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE cFichierBases AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cLigne AS CHARACTER NO-UNDO.
    
    /* Ajout des bases libelle sur les environnements de version */
    DO iboucle = 1 TO NUM-ENTRIES(cListeBasesLib):
        cLigne = ENTRY(iboucle,cListeBasesLib).
        CREATE ttbases.
        ttbases.cbase = cLigne.
        ttbases.cServeur = "Local".
        ttbases.ldemarree = FALSE.
        ttbases.cTri = (IF DonnePreference("PREF-TRIBASES") = "OUI" THEN SUBSTRING(ttbases.cbase,2) ELSE ttbases.cbase).
        ttBases.cCommentaire = "Bases libellés de la version : " + ttbases.cbase.
        ttbases.lLib = TRUE.
        ttbases.lUtil = FALSE.  
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ChargeDroitsTC C-Win 
PROCEDURE ChargeDroitsTC :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    /* Ouverture du fichier */
    RUN ExtraitFichierDeLaBase("","tc_droits.lst").
    INPUT FROM VALUE(gcFichierLocal).

    /* Chargement de la table des bypass */
    EMPTY TEMP-TABLE ttDroitsTC.
    REPEAT:
        IMPORT UNFORMATTED cLigne.
        IF cLigne = ""  THEN NEXT.
        CREATE ttDroitsTC.
        ttDroitsTC.cServeur = ENTRY(1,cLigne).
        ttDroitsTC.cBase = ENTRY(2,cLigne).
        ttDroitsTC.cUtilisateur = ENTRY(3,cLigne).
    END.

    /* Fermeture du fichier */
    INPUT CLOSE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ChargeFiltres C-Win 
PROCEDURE ChargeFiltres :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    DO WITH FRAME FrmFiltres:

        tglFiltrePresente:CHECKED = (IF DonnePreference("FILTRE-BASEPRESENTE") = "OUI" THEN TRUE ELSE FALSE).
        tglFiltreAbsente:CHECKED = (IF DonnePreference("FILTRE-BASEABSENTE") = "OUI" THEN TRUE ELSE FALSE).
        tglFiltreOuverte:CHECKED = (IF DonnePreference("FILTRE-BASEOUVERTE") = "OUI" THEN TRUE ELSE FALSE).
        tglFiltreFermee:CHECKED = (IF DonnePreference("FILTRE-BASEFERMEE") = "OUI" THEN TRUE ELSE FALSE).
        tglFiltreSauvegardePresente:CHECKED = (IF DonnePreference("FILTRE-SAUVEGARDEPRESENTE") = "OUI" THEN TRUE ELSE FALSE).
        tglFiltreSauvegardeAbsente:CHECKED = (IF DonnePreference("FILTRE-SAUVEGARDEABSENTE") = "OUI" THEN TRUE ELSE FALSE).
        RsFiltreEt:SCREEN-VALUE = STRING(DonnePreference("FILTRE-ET") = "OUI" ). 
        
       cmbUtil:LIST-ITEMS = "".
       cmbUtil:ADD-LAST("-").
       IF rsChoixBases:SCREEN-VALUE IN FRAME frmFonction = "3" THEN DO:
            IF CAN-FIND(FIRST ttbasesref WHERE ttbasesref.lUtil) THEN DO:
                /* Chargement des utilisateurs ayant des bases */
                FOR EACH ttbasesref NO-LOCK
                    BREAK BY ttbasesref.cServeur
                    :
                    IF first-of(ttbasesref.cServeur) THEN cmbUtil:ADD-LAST(ttbasesref.cServeur).
                END.
                cmbUtil:SENSITIVE = TRUE.
            END.
            ELSE DO:
                FOR EACH Utilisateurs NO-LOCK
                    :
                    cmbUtil:ADD-LAST(Utilisateurs.cUtilisateur).
                END.
            END.
            cmbUtil:SCREEN-VALUE = DonnePreference("FILTRE-UTILISATEUR").
        END.
        ELSE DO:           
            cmbUtil:SENSITIVE = FALSE.
        END.

        lFiltrePresente = tglFiltrePresente:CHECKED.    
        lFiltreAbsente = tglFiltreAbsente:CHECKED.    
        lFiltreOuverte = tglFiltreOuverte:CHECKED.    
        lFiltreFermee = tglFiltreFermee:CHECKED.    
        lFiltreSauvegardePresente = tglFiltreSauvegardePresente:CHECKED.    
        lFiltreSauvegardeAbsente = tglFiltreSauvegardeAbsente:CHECKED.   
        lFiltreEt = (rsFiltreEt:SCREEN-VALUE = "YES").
        lFiltreUtil = (cmbUtil:SCREEN-VALUE <> "-" /*AND cmbUtil:SCREEN-VALUE <> gcUtilisateur*/ AND cmbUtil:SCREEN-VALUE <> ?).
    END.
    
    iNombreFiltres = 0.
    IF lFiltrePresente THEN iNombreFiltres = iNombreFiltres + 1.
    IF lFiltreabsente  THEN iNombreFiltres = iNombreFiltres + 1.
    IF lFiltreouverte  THEN iNombreFiltres = iNombreFiltres + 1.
    IF lFiltrefermee THEN iNombreFiltres = iNombreFiltres + 1.
    IF lFiltreSauvegardePresente  THEN iNombreFiltres = iNombreFiltres + 1.
    IF lFiltreSauvegardeabsente THEN iNombreFiltres = iNombreFiltres + 1.
    IF lFiltreUtil THEN iNombreFiltres = iNombreFiltres + 1.
    
    IF iNombreFiltres > 0 THEN DO WITH FRAME FrmFonction:
        btnFiltre:LOAD-IMAGE(gcRepertoireImages + "FiltreON.bmp").
    END.
    ELSE DO:
        btnFiltre:LOAD-IMAGE(gcRepertoireImages + "FiltreOFF.bmp").
    END.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CopieSauvegardeUtilisateur C-Win 
PROCEDURE CopieSauvegardeUtilisateur :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    DEFINE VARIABLE cTempo AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cRetour AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE cCopie_Utilisateur AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cCopie_MDP AS CHARACTER NO-UNDO.
    
    cTempo = ttbases.cServeur + "/" + ttbases.cbase.

    /* Demande de confirmation */
    RUN AfficheMessageAvecTemporisation("Copie de sauvegarde","Confirmez-vous la copie de la sauvegarde : " + cTempo,TRUE,10,"NON","MESSAGE-COPIE-SAUVEGARDE",FALSE,OUTPUT cRetour).
    IF cRetour = "NON" THEN RETURN.

    /* Récupération des infos de connexion à la machine source */
    IF DonnePreferenceUtilisateur(ttbases.cServeur,"PREF-AUTORISER-UTILISATEURS") <> "OUI" THEN DO:
        RUN AfficheMessageAvecTemporisation("Copie de sauvegarde","L'utilisateur n'a pas autorisé la copie des sauvegardes se trouvant sur sa machine !"
                                       + CHR(10) + "Voulez-vous lui envoyer un message pour lui demander de le faire ?"
                                      ,TRUE,10,"NON","MESSAGE-PAS-AUTORISE",FALSE,OUTPUT cRetour).
        IF cRetour = "OUI" THEN DO:
            cTempo = "Je voudrais récupérer la sauvegarde de votre base " + ttbases.cbase + " mais vous n'avez pas autorisé la copie dans les préférences de menudev2".
            RUN EnvoiOrdre("INFOS",cTempo,ttbases.cServeur,gcUtilisateur,FALSE,FALSE).
            cTempo = "Pouvez-vous le faire et me prévenir quand ce sera bon ?".
            RUN EnvoiOrdre("INFOS",cTempo,ttbases.cServeur,gcUtilisateur,FALSE,FALSE).
        END.
        RETURN.
    END.

    cCopie_Utilisateur = DonnePreferenceUtilisateur(ttbases.cServeur,"PREF-AUTORISER-UTILISATEURS-UTILISATEUR").
    cCopie_MDP = DonnePreferenceUtilisateur(ttbases.cServeur,"PREF-AUTORISER-UTILISATEURS-MDP").
    IF cCopie_Utilisateur = "" OR cCopie_MDP = "" 
        THEN DO:
        RUN AfficheMessageAvecTemporisation("Copie de sauvegarde","L'utilisateur n'a pas saisi son code utilisateur ou son mot de passe pour que vous puissiez vous connecter à sa machine !"
                                       + CHR(10) + "Voulez-vous lui envoyer un message pour lui demander de le faire ?"
                                      ,TRUE,10,"NON","MESSAGE-PAS-AUTORISE2",FALSE,OUTPUT cRetour).
        IF cRetour = "OUI" THEN DO:
            cTempo = "Je voudrais récupérer la sauvegarde de votre base " + ttbases.cbase + " mais vous n'avez pas saisi les infos de connexion à votre machine dans les préférences de menudev2".
            RUN EnvoiOrdre("INFOS",cTempo,ttbases.cServeur,gcUtilisateur,FALSE,FALSE).
            cTempo = "Pouvez-vous le faire et me prévenir quand ce sera bon ?".
            RUN EnvoiOrdre("INFOS",cTempo,ttbases.cServeur,gcUtilisateur,FALSE,FALSE).
        END.
        RETURN.
    END.

    /* Vérification si base déjà présente */
    IF SEARCH(cRepertoireBases + "\" + ttbases.cbase + "\svg\" + ttbases.cbase + ".7z") <> ? THEN DO:
        RUN AfficheMessageAvecTemporisation("Copie de sauvegarde","Une sauvegarde de ce client existe déjà sur votre poste. Elle sera écrasée ! Confirmez-vous la copie ?",TRUE,10,"NON","MESSAGE-EXISTE-DEJA",FALSE,OUTPUT cRetour).
        IF cRetour = "NON" THEN RETURN.
    END.

    cCommandeShell = gcRepertoireRessourcesPrivees + "\scripts\general\_GI-Copiesvg.bat " 
        + ttbases.cMachine + " " 
        + cRepertoireBases + " " 
        + ttbases.cbase + " " 
        + cCopie_Utilisateur + " "
        + cCopie_MDP + " "
        + ttbases.cServeur
        .
    
    cTempo = "Récupération de votre sauvegarde de la base " + ttbases.cbase + " en cours...".
    RUN EnvoiOrdre("INFOS",cTempo,ttbases.cServeur,gcUtilisateur,FALSE,FALSE).
    RUN ExecuteCommandeDos(cCommandeShell).
    RUN AfficheMessageAvecTemporisation("Commande en cours","Un avertissement sera envoyé dans la zone information de menudev2 quand la commande sera terminée.",FALSE,5,"OK","MESSAGE-COPIESVG",FALSE,OUTPUT cRetour).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CreParamServeurs C-Win 
PROCEDURE CreParamServeurs :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE cFichierParams AS CHARACTER NO-UNDO.

    cFichierParams = loc_outils + "\" + "ParamServeurs.bat".

    OUTPUT TO VALUE(cFichierParams).

        PUT UNFORMATTED "REM Batch généré et utilisé par menudev2" SKIP.
        PUT UNFORMATTED "REM Parametres des serveurs" SKIP.
        PUT UNFORMATTED "set PARAM_SADB=" + DonneInfosServeurs("SADB") SKIP.
        PUT UNFORMATTED "set PARAM_COMPTA=" + DonneInfosServeurs("COMPTA") SKIP.
        PUT UNFORMATTED "set PARAM_CADB=" + DonneInfosServeurs("CADB") SKIP.
        PUT UNFORMATTED "set PARAM_INTER=" + DonneInfosServeurs("INTER") SKIP.
        PUT UNFORMATTED "set PARAM_TRANSFER=" + DonneInfosServeurs("TRANSFER") SKIP.
        PUT UNFORMATTED "set PARAM_DWH=" + DonneInfosServeurs("DWH") SKIP.
        PUT UNFORMATTED "set PARAM_LADB=" + DonneInfosServeurs("LADB") SKIP.
        PUT UNFORMATTED "set PARAM_LCOMPTA=" + DonneInfosServeurs("LCOMPTA") SKIP.
        PUT UNFORMATTED "set PARAM_LTRANS=" + DonneInfosServeurs("LTRANS") SKIP.
        PUT UNFORMATTED "set PARAM_WADB=" + DonneInfosServeurs("WADB") SKIP.

    OUTPUT CLOSE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE DemandeDistante C-Win 
PROCEDURE DemandeDistante :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER cDemande-in AS CHARACTER NO-UNDO.

    DEFINE VARIABLE cFichierDemande AS CHARACTER NO-UNDO.

    cFichierDemande = OS-GETENV("USERNAME") + ".dem".

    OUTPUT STREAM sSortie TO VALUE(loc_tmp + "\" + cFichierDemande).
    PUT STREAM sSortie UNFORMATTED cDemande-in + OS-GETENV("USERNAME") skip.
    OUTPUT STREAM sSortie CLOSE.

    /* Envoi via FTP sur barbade (les machine HL pointent sur un h:\ différent */
    OS-COMMAND SILENT VALUE(gcRepertoireRessourcesPrivees + "scripts\ftp\ftpCopyFichier.bat " + ttbases.cServeur + " " + cFichierDemande + " " + "/v/nfsdosh/dev/intf"). 

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
  DISPLAY tglOuvertes rsChoixBases tglLocal filRecherche tglRegrouper tglBarbade 
          tglNeptune2 TOGGLE-1 TOGGLE-2 filDispo 
      WITH FRAME frmFonction IN WINDOW C-Win.
  ENABLE tglOuvertes rsChoixBases tglLocal filRecherche btnCodePrecedent 
         btnCodeSuivant btnFiltre btnAnciennes tglRegrouper tglBarbade 
         tglNeptune2 brwBases BUTTON-1 filDispo 
      WITH FRAME frmFonction IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-frmFonction}
  DISPLAY rsFiltreEt tglFiltrePresente tglFiltreAbsente tglFiltreOuverte 
          tglFiltreFermee tglFiltreSauvegardePresente tglFiltreSauvegardeAbsente 
          cmbUtil 
      WITH FRAME frmfiltres IN WINDOW C-Win.
  ENABLE btnAppliquerFermerFiltres rsFiltreEt tglFiltrePresente 
         tglFiltreAbsente tglFiltreOuverte tglFiltreFermee 
         tglFiltreSauvegardePresente btnAppliquerFiltres 
         tglFiltreSauvegardeAbsente cmbUtil btnFermerFiltres 
      WITH FRAME frmfiltres IN WINDOW C-Win.
  VIEW FRAME frmfiltres IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-frmfiltres}
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
                FRAME frmFiltres:VISIBLE = FALSE.
                RUN MajPreferences.

                /* Affichage de la frame principale */
                VIEW FRAME frmModule.
                FRAME frmModule:MOVE-TO-TOP().

                IF DonneEtSupprimeParametre("BASES-RECHARGER") = "OUI" THEN DO:
                    RUN Recharger.
                END.
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
/*                AssigneParametre("AVEC_VERSION_PROGRESS","OUI").*/
                RUN Initialisation.
            END.
            WHEN "RECHARGE" THEN DO:
                RUN Recharger.
            END.
            WHEN "RECHERCHE" THEN DO:
                APPLY "entry" TO filRecherche IN FRAME frmFonction.
            END.
        END CASE. /* fin du case */
    END. /* fin du do iboucle */

    RUN gereboutons.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE FermeBasesLib C-Win 
PROCEDURE FermeBasesLib :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    DEFINE VARIABLE lLibAuto AS LOGICAL NO-UNDO INIT FALSE.
    DEFINE VARIABLE cFichierLK AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cTempo AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cBaseEnCours AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cCommandeShell AS CHARACTER NO-UNDO.

    DEFINE BUFFER bttbases FOR ttbasesref.

    lLibAuto = (DonnePreference("PREF-LIBAUTO") = "OUI").
    IF NOT(lLibAuto) THEN RETURN.

    /* Vérification des serveurs ouverts */
    FIND FIRST  bttbases
        WHERE   bttbases.lDemarree
        AND     bttbases.llib
        NO-ERROR.
    IF AVAILABLE(bttbases) THEN DO:
        RUN AfficheMessageAvecTemporisation("Confirmation...","Voulez-vous fermer les serveurs sur les bases libellé ?",TRUE,5,"OUI","MESSAGE-SERVEURS-LIBELLE",FALSE,OUTPUT cRetour).
        IF cRetour = "NON" THEN RETURN.
    END.

    /* parcours de la liste des bases */
    DO iboucle = 1 TO NUM-ENTRIES(cListeBasesLib):
        cBaseEnCours = ENTRY(iboucle,cListeBasesLib).
        cTempo = cBaseEnCours.
        IF cTempo = "CLI" THEN
            cTempo = "gi\".
        ELSE IF cTempo = "DEV" THEN
            cTempo = "gidev\".
        ELSE 
            cTempo = "gi_"+ cBaseEnCours  + "\gi\".
    
        cTempo = disque + cTempo + "baselib\".
        cFichierLK = cTempo + "ladb.lk".
        
        /* La base est déjà fermée */
        IF SEARCH(cFichierLK) = ? THEN NEXT.

        /* Lancement de l'ouverture de la base */
        cCommandeShell = gcRepertoireRessourcesPrivees + "\scripts\serveurs\_GI-FermeLibelles.bat " + cTempo + " " + cBaseEnCours + " " + "rem MUET".
        RUN ExecuteCommandeDos(cCommandeShell).

    END.
    

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

    DEFINE BUFFER bttbases FOR ttbasesref.

    /* Vérification des serveurs */
    FIND FIRST bttbases
        WHERE bttbases.lDemarree = TRUE
        AND bttbases.cServeur = "Local"
        AND bttbases.lLib = FALSE
        AND bttbases.cProgress = gcVersionProgress
        NO-ERROR.
    IF AVAILABLE(bttbases) THEN DO:
        RUN AfficheMessageAvecTemporisation("Confirmation...","Des serveurs sur des bases sont encores ouverts.%sConfirmez vous la fermeture de l'application ?",TRUE,5,"OUI","MESSAGE-SERVEURS",FALSE,OUTPUT cRetour).
        IF cRetour = "NON" THEN RETURN.
    END.

    RUN FermeBasesLib.

    lRetour-ou = TRUE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE GenereFichierVersion C-Win 
PROCEDURE GenereFichierVersion :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cRetourQuestion AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cParamMontage AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cRepertoireExecution AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cVersionBase AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cTempo AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE cCommande AS CHARACTER NO-UNDO.

    cRepertoireExecution = REPLACE(gcRepertoireExecution,"menudev2","versions").

    cTempo = ttbases.cVersion.
    cVersionBase = ""
        + STRING(INTEGER(ENTRY(1,cTempo,".")),"99")
        + STRING(INTEGER(ENTRY(2,cTempo,".")),"99")
        + STRING(INTEGER(ENTRY(3,cTempo,".")),"99")
        + "00"
        .

    cParamMontage = "MENUDEV2"
        + "," + cVersionBase /* Version de la base = version de départ */
        + "," + ""
        + "," + ""
        + "," + ""
        .
    /* Lancement du programme de génération du fichier de montage de version */
    RUN VALUE(cRepertoireExecution + "montage.w") (INPUT cParamMontage).
    
    cRetour = DonnePreference("RETOUR-MONTAGE").
    IF cRetour = "" THEN RETURN.
    /* Avertissement */
    RUN AfficheMessageAvecTemporisation("Montage de version en cours","Un avertissement sera envoyé dans la zone information de menudev2 quand le montage de version sera terminée.",FALSE,5,"OK","MESSAGE-MONTAGE",FALSE,OUTPUT cRetourQuestion).
    
    /* copie de la base libellé */
    OUTPUT TO value(disque + "tmp\commande.bat").
    PUT UNFORMATTED "mkdir " + disque + "tmp\dat" SKIP.
    PUT UNFORMATTED "copy " + gcRepertoireRessourcesPrivees + "dat\" + gcVersionProgress + "\*.* " + disque + "tmp\dat" SKIP.
    OUTPUT CLOSE.
    cCommande = gcRepertoireRessourcesPrivees + "scripts\serveurs\_gi-commande.bat".
    RUN ExecuteCommandeDos(cCommande).
    RUN ExecuteCommandeDos(gcRepertoireRessourcesPrivees + "\scripts\serveurs\_GI-LanceRepair.bat " + disque + "tmp\dat").
    /* génération du cnx artificiel */
    INPUT STREAM sEntree FROM VALUE("c:\pfgi\cnx" + ttBases.cbase + ".pf").
    OUTPUT STREAM sSortie TO VALUE("c:\pfgi\cnxmd2_montage.pf").
    REPEAT:
        IMPORT STREAM sEntree UNFORMATTED cLigne.
        IF cLigne = "" OR cLigne BEGINS "#" THEN NEXT.
        IF cLigne MATCHES "*ladb*" THEN NEXT.
        IF cLigne MATCHES "*lcompta*" THEN NEXT.
        IF cLigne MATCHES "*ltrans*" THEN NEXT.
        IF cLigne MATCHES "*wadb*" THEN NEXT.
        PUT STREAM sSortie UNFORMATTED cLigne SKIP.
    END.
    INPUT STREAM sEntree CLOSE.
    /* ajout des bases libellé */
    PUT STREAM sSortie UNFORMATTED "-db " + disque + "tmp\dat\ladb -1" SKIP.
    PUT STREAM sSortie UNFORMATTED "-db " + disque + "tmp\dat\wadb -1" SKIP.
    PUT STREAM sSortie UNFORMATTED "-db " + disque + "tmp\dat\lcompta -1" SKIP.
    PUT STREAM sSortie UNFORMATTED "-db " + disque + "tmp\dat\ltrans -1" SKIP.
    OUTPUT STREAM sSortie CLOSE.

    /* Lancement du montage de version sur la base */
    RUN ExecuteCommandeDos(gcRepertoireRessourcesPrivees + "\scripts\serveurs\_GI-MontageVersion.bat " + cRepertoireBases + " " + ttBases.cbase + " " + ENTRY(1,cRetour,"|")).

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
    gcAideRaf = "Recharger la liste des serveurs".

    /* Au cas ou on a modifié le répertoire des bases */
    IF DonnePreference("REPERTOIRE-BASES") <> cRepertoireBases THEN RUN initialisation.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE GereTglBases C-Win 
PROCEDURE GereTglBases :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DO WITH FRAME frmFonction:
        tglLocal:SENSITIVE = (rsChoixBases:SCREEN-VALUE = "1").
        tglBarbade:SENSITIVE = (rsChoixBases:SCREEN-VALUE = "1").
        tglNeptune2:SENSITIVE = (rsChoixBases:SCREEN-VALUE = "1").
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

    IF lPremierPassage THEN do:
        FRAME frmModule:COLUMN = gdPositionXModule.
        FRAME frmModule:ROW = gdPositionYModule.
        RUN MajPreferences.
    END.

    RUN ChargeFiltres.
    RUN TopChronoGeneral.
    RUN TopChronoPartiel.
    
    IF lPremierPassage THEN do:
        ttBases.cVersion:READ-ONLY IN BROWSE brwbases = TRUE.
        FRAME frmModule:COLUMN = gdPositionXModule.
        FRAME frmModule:ROW = gdPositionYModule.
        FRAME frmFonction:TITLE = "Liste et état des bases disponibles (Local:" + cRepertoireBases + " / Barbade / Neptune)".
        iX = c-win:X + (c-win:WIDTH-PIXELS / 2).
        iY = c-win:Y + (c-win:HEIGHT-PIXELS / 2).
        brwBases:LOAD-MOUSE-POINTER(gcRepertoireRessources + "\curmenu.cur").
        btnAnciennes:LOAD-IMAGE(gcRepertoireImages + "Anciennes.bmp").
        RUN GereTglBases.
        RUN OuvreBasesLib.
        RUN OuvreBasesAuto.
        FRAME frmFiltres:VISIBLE = FALSE.
    END.
    lPremierPassage = FALSE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE LanceGenerationCNX C-Win 
PROCEDURE LanceGenerationCNX :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER lMajCnx-in AS LOGICAL NO-UNDO.

    DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO.

    IF lMajCnx-in  THEN DO: 
        RUN AfficheMessageAvecTemporisation("Changement de type de version","Le fichier CNX va être re-généré suite au changement de type de version...",FALSE,5,"OK","MESSAGE-REGENERECNX",FALSE,OUTPUT cRetour).
        APPLY "CHOOSE" TO MENU-ITEM m_Generation IN MENU Menubases.
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE LectureListeTC C-Win 
PROCEDURE LectureListeTC :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER cServeur-in AS CHARACTER NO-UNDO.

    DEFINE VARIABLE cLigne AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cNomBase AS CHARACTER NO-UNDO.

    /* Par sécurité, suppression du fichier de la foi d'avant */
    OS-DELETE VALUE(loc_tmp + "\tc.lst").

    /* Récupération du fichier par FTP */
    OS-COMMAND SILENT VALUE(gcRepertoireRessourcesPrivees + "\scripts\ftp\ftpGetTC.bat " + cServeur-in). 

    /* Lecture du fichier si présent */
    IF SEARCH(loc_tmp + "\tc.lst") = ? THEN RETURN.
    INPUT STREAM sEntree FROM VALUE(loc_tmp + "\tc.lst").
    REPEAT:
        IMPORT STREAM sEntree UNFORMATTED cLigne.
        IF trim(cLigne) = "" THEN NEXT. /* Ligne vide */
        IF cLigne BEGINS "#" THEN NEXT. /* Commentaire */

        /* Décodage de la ligne */
        cNomBase = ENTRY(1,cLigne).

        /* on ne prend que les bases présentes en (base ou sauvegarde) et pour lesquelles on a les droits */
        IF (ENTRY(9,cLigne) MATCHES "*S*") OR (ENTRY(9,cLigne) MATCHES "*B*") AND isDroitTC(cServeur-in,cNomBase) THEN DO:
            FIND FIRST  ttbases
                WHERE   ttbases.cBase = cNomBase
                AND     ttbases.cServeur = cServeur-in
                NO-ERROR.
            /* Création de la ligne de base si nécessaire */
            IF NOT(AVAILABLE(ttbases)) THEN DO:
                CREATE ttbases.
                ttbases.cServeur = cServeur-in.
                ttbases.cbase = cNomBase.
                ttbases.cTri = SUBSTRING(ttbases.cbase,2).
            END.
            /* Mise à jour de la ligne de base */
            ttbases.lDemarree = (ENTRY(5,cLigne) = "Ouverte").
            ttbases.lBase = (ENTRY(9,cLigne) MATCHES "*B*").
            ttbases.lSauvegarde = (ENTRY(9,cLigne) MATCHES "*S*").
            ttbases.cCommentaire = ENTRY(2,cLigne).
            ttbases.cVersion = (IF ENTRY(4,cLigne) = "Inconnue" THEN "" ELSE ENTRY(4,cLigne)).
            ttbases.dDateSauvegarde = date(ENTRY(8,cLigne)).

            FIND FIRST  details NO-LOCK
                WHERE   details.iddet1 = gcUtilisateur
                AND     details.iddet2 = "BASES-SERVEUR"
                AND     details.iddet3 = ttbases.cbase
                AND     details.iddet4 = ttbases.cServeur
                NO-ERROR.
            ttbases.cRepertoire = (IF available(details) THEN details.vldet1 ELSE "").

            ttbases.cOrdre = (IF lOuvertesEnPremier THEN STRING(NOT(ttBases.ldemarree)) ELSE "") + ttbases.cTri.
        END.
        ELSE DO:
            /* Suppression éventuelle de la ligne de base */
            FIND FIRST  ttbases
                WHERE   ttbases.cBase = cNomBase
                AND     ttbases.cServeur = cServeur-in
                NO-ERROR.
            IF AVAILABLE(ttbases) THEN DELETE ttbases.
        END.
    END.
    INPUT STREAM sEntree CLOSE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MajPreferences C-Win 
PROCEDURE MajPreferences :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    DO WITH FRAME frmFonction:
        tglOuvertes:CHECKED = (DonnePreference("PREF-BASESOUVERTESENTETE") = "OUI").
        tglLocal:CHECKED = (DonnePreference("PREF-BASESLOCALES") = "OUI").
        tglBarbade:CHECKED = (DonnePreference("PREF-BASESBARBADE") = "OUI").
        tglNeptune2:CHECKED = (DonnePreference("PREF-BASESNEPTUNE2") = "OUI").
        rsChoixBases:SCREEN-VALUE = DonnePreference("PREF-BASESTYPE").
    END.

    lFiltreToutDeSuite = (DonnePreference("FILTRE-TOUTDESUITE") = "OUI").

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MajVersionBase C-Win 
PROCEDURE MajVersionBase :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER cVersion-in AS CHARACTER NO-UNDO.

    /* REcherche de la base dabs la table detail */
    FIND FIRST  details EXCLUSIVE-LOCK
        WHERE   details.iddet1 = gcUtilisateur
        AND     details.iddet2 = "BASES-SERVEUR"
        AND     details.iddet3 = ttbases.cbase
        AND     details.iddet4 = ttbases.cServeur
        NO-ERROR.
    IF NOT(AVAILABLE(details)) THEN DO:
        CREATE details.
        ASSIGN
            details.iddet1 = gcUtilisateur
            details.iddet2 = "BASES-SERVEUR"
            details.iddet3 = ttbases.cbase
            details.iddet4 = ttbases.cServeur
            .
    END.
    details.vldet1 = ttbases.cRepertoire.
    RELEASE details.

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
  ENABLE ALL WITH FRAME frmFonction.
  brwbases:popup-MENU  = MENU menubases:HANDLE.
    
    cMachineUtilisateur = OS-GETENV("COMPUTERNAME").
    cRepertoireBases = DonnePreference("REPERTOIRE-BASES").

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OuvreBasesAuto C-Win 
PROCEDURE OuvreBasesAuto :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    DEFINE VARIABLE lAuto AS LOGICAL NO-UNDO INIT FALSE.
    DEFINE VARIABLE cFichierBase AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cFichierLK AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cTempo AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cCommandeShell AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cBaseEnCours AS CHARACTER NO-UNDO.

    DEFINE BUFFER bttbasesRef FOR ttbasesRef.

    /* parcours de la liste des bases */
    FOR EACH bttbasesRef
        WHERE bttbasesRef.lAuto
        :
        IF bttbasesRef.cServeur = "Local" THEN DO:
            IF bttbasesRef.lLib THEN DO:
                cTempo = bttbasesRef.cbase.
                IF cTempo = "CLI" THEN
                    cTempo = "gi\".
                ELSE IF cTempo = "DEV" THEN
                    cTempo = "gidev\".
                ELSE 
                    cTempo = "gi_"+ bttbasesRef.cbase + "\gi\".

                cTempo = disque + cTempo + "baselib".
                cFichierBase = cTempo + "\lcompta.db".
                cFichierLK = cTempo + "\lcompta.lk".
                /* La base n'existe pas : on ne fait rien */
                IF SEARCH(cFichierBase) = ? THEN NEXT.
                /* La base est déjà ouverte */
                IF SEARCH(cFichierLK) <> ? THEN NEXT.

                /* Ne pas traiter les bases lib si la gestion des bases lib est automatique */
                IF not(DonnePreference("PREF-LIBAUTO") = "OUI") THEN DO:
                    cCommandeShell = gcRepertoireRessourcesPrivees + "\scripts\serveurs\_GI-LanceLibelles.bat " + cTempo + " " + bttbasesRef.cbase + " " + (IF toggle-1:CHECKED IN FRAME frmFonction THEN "pause" ELSE "rem") + (IF toggle-2:CHECKED IN FRAME frmFonction THEN " -i" ELSE "").
                    RUN ExecuteCommandeDos(cCommandeShell).
                END.
            END.
            ELSE DO:
                cFichierBase = cRepertoireBases + "\" + bttbasesRef.cbase + "\inter.db".
                cFichierLK = cRepertoireBases + "\" + bttbasesRef.cbase + "\inter.lk".
                /* La base n'existe pas : on ne fait rien */
                IF SEARCH(cFichierBase) = ? THEN NEXT.
                /* La base est déjà ouverte */
                IF SEARCH(cFichierLK) <> ? THEN NEXT.
                cCommandeShell = gcRepertoireRessourcesPrivees + "\scripts\serveurs\_GI-LanceServeurs.bat " + cRepertoireBases + " " + bttbasesRef.cbase + " " + (IF toggle-1:CHECKED IN FRAME frmFonction THEN "pause" ELSE "rem") + (IF toggle-2:CHECKED IN FRAME frmFonction THEN " -i" ELSE "").
                RUN ExecuteCommandeDos(cCommandeShell).
            END.
        END.
    END.
    

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OuvreBasesLib C-Win 
PROCEDURE OuvreBasesLib :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    DEFINE VARIABLE lLibAuto AS LOGICAL NO-UNDO INIT FALSE.
    DEFINE VARIABLE cFichierBase AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cFichierLK AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cTempo AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cCommandeShell AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cBaseEnCours AS CHARACTER NO-UNDO.

    DEFINE BUFFER bttbases FOR ttbases.

    lLibAuto = (DonnePreference("PREF-LIBAUTO") = "OUI").
    IF NOT(lLibAuto) THEN RETURN.

    /* parcours de la liste des bases */
    DO iboucle = 1 TO NUM-ENTRIES(cListeBasesLib):
        cBaseEnCours = ENTRY(iboucle,cListeBasesLib).
        cTempo = cBaseEnCours.
        IF cTempo = "CLI" THEN
            cTempo = "gi\".
        ELSE IF cTempo = "DEV" THEN
            cTempo = "gidev\".
        ELSE 
            cTempo = "gi_"+ cBaseEnCours + "\gi\".
    
        cTempo = disque + cTempo + "baselib\".
        cFichierBase = cTempo + "ladb.db".
        cFichierLK = cTempo + "ladb.lk".
    
        /* La base n'existe pas : on ne fait rien */
        IF SEARCH(cFichierBase) = ? THEN NEXT.


        /* La base est déjà ouverte */
        IF SEARCH(cFichierLK) <> ? THEN NEXT.

        /* Lancement de l'ouverture de la base */
        cCommandeShell = gcRepertoireRessourcesPrivees + "\scripts\serveurs\_GI-LanceLibelles.bat " + cTempo + " " + cBaseEnCours + " " + "rem".
        RUN ExecuteCommandeDos(cCommandeShell).

    END.
    

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OuvreFichierServices C-Win 
PROCEDURE OuvreFichierServices :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER cFichierServices-in AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER lRetour-ou AS LOGICAL NO-UNDO INIT FALSE.
    
    OUTPUT STREAM sSortie TO VALUE(cFichierServices-in) APPEND.

    lRetour-ou = TRUE.

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

    DO WITH FRAME frmFonction:
        /* retravail de la liste des bases en fonctione de la demande */
        IF rsChoixBases:SCREEN-VALUE = "1" THEN DO:
            FOR EACH ttbases
                WHERE (ttbases.cserveur <> "Local" AND ttbases.cserveur <> "Barbade" AND ttbases.cserveur <> "Neptune2")
                OR ttbases.lLib
                :
                DELETE ttbases.
            END.
        END.
    
        IF rsChoixBases:SCREEN-VALUE = "2" THEN DO:
            FOR EACH ttbases
                WHERE NOT(ttbases.lLib)
                :
                DELETE ttbases.
            END.
        END.
    
        IF rsChoixBases:SCREEN-VALUE = "3" THEN DO:
            FOR EACH ttbases
                WHERE NOT(ttbases.lUtil)
                :
                DELETE ttbases.
            END.
        END.
    END.

    IF cLibelleColonne-in = "" THEN DO:
        OPEN QUERY brwbases FOR EACH ttbases BY ttbases.cOrdre.
        lQueryOK = TRUE.
    END.
    ELSE DO:
        IF cLibelleColonne-in = ttbases.cbase:LABEL IN BROWSE brwbases THEN DO:
            IF lTriAsc THEN DO:
                OPEN QUERY brwbases FOR EACH ttbases BY ttbases.cbase.
            END.
            ELSE DO:
                OPEN QUERY brwbases FOR EACH ttbases BY ttbases.cbase DESC.
            END.
            lQueryOK = TRUE.
        END.
        IF cLibelleColonne-in = ttbases.cserveur:LABEL IN BROWSE brwbases THEN DO:
            IF lTriAsc THEN DO:
                OPEN QUERY brwbases FOR EACH ttbases BY ttbases.cserveur.
            END.
            ELSE DO:
                OPEN QUERY brwbases FOR EACH ttbases BY ttbases.cserveur DESC.
            END.
            lQueryOK = TRUE.
        END.
        IF cLibelleColonne-in = ttbases.lDemarree:LABEL IN BROWSE brwbases THEN DO:
            IF lTriAsc THEN DO:
                OPEN QUERY brwbases FOR EACH ttbases BY ttbases.lDemarree.
            END.
            ELSE DO:
                OPEN QUERY brwbases FOR EACH ttbases BY ttbases.lDemarree DESC.
            END.
            lQueryOK = TRUE.
        END.
        IF cLibelleColonne-in = ttbases.lbase:LABEL IN BROWSE brwbases THEN DO:
            IF lTriAsc THEN DO:
                OPEN QUERY brwbases FOR EACH ttbases BY ttbases.lbase.
            END.
            ELSE DO:
                OPEN QUERY brwbases FOR EACH ttbases BY ttbases.lbase DESC.
            END.
            lQueryOK = TRUE.
        END.
        IF cLibelleColonne-in = ttbases.lSauvegarde:LABEL IN BROWSE brwbases THEN DO:
            IF lTriAsc THEN DO:
                OPEN QUERY brwbases FOR EACH ttbases BY ttbases.lSauvegarde.
            END.
            ELSE DO:
                OPEN QUERY brwbases FOR EACH ttbases BY ttbases.lSauvegarde DESC.
            END.
            lQueryOK = TRUE.
        END.
        IF cLibelleColonne-in = ttbases.cCommentaire:LABEL IN BROWSE brwbases THEN DO:
            IF lTriAsc THEN DO:
                OPEN QUERY brwbases FOR EACH ttbases BY ttbases.cCommentaire.
            END.
            ELSE DO:
                OPEN QUERY brwbases FOR EACH ttbases BY ttbases.cCommentaire DESC.
            END.
            lQueryOK = TRUE.
        END.
        IF cLibelleColonne-in = ttbases.ddatesauvegarde:LABEL IN BROWSE brwbases THEN DO:
            IF lTriAsc THEN DO:
                OPEN QUERY brwbases FOR EACH ttbases BY ttbases.ddatesauvegarde.
            END.
            ELSE DO:
                OPEN QUERY brwbases FOR EACH ttbases BY ttbases.ddatesauvegarde DESC.
            END.
            lQueryOK = TRUE.
        END.
        IF cLibelleColonne-in = ttbases.cVersion:LABEL IN BROWSE brwbases THEN DO:
            IF lTriAsc THEN DO:
                OPEN QUERY brwbases FOR EACH ttbases BY ttbases.cVersion.
            END.
            ELSE DO:
                OPEN QUERY brwbases FOR EACH ttbases BY ttbases.cVersion DESC.
            END.
            lQueryOK = TRUE.
        END.
        IF cLibelleColonne-in = ttbases.cRepertoire:LABEL IN BROWSE brwbases THEN DO:
            IF lTriAsc THEN DO:
                OPEN QUERY brwbases FOR EACH ttbases BY ttbases.cRepertoire.
            END.
            ELSE DO:
                OPEN QUERY brwbases FOR EACH ttbases BY ttbases.cRepertoire DESC.
            END.
            lQueryOK = TRUE.
        END.
        IF cLibelleColonne-in = ttbases.cProgress:LABEL IN BROWSE brwbases THEN DO:
            IF lTriAsc THEN DO:
                OPEN QUERY brwbases FOR EACH ttbases BY ttbases.cProgress.
            END.
            ELSE DO:
                OPEN QUERY brwbases FOR EACH ttbases BY ttbases.cProgress DESC.
            END.
            lQueryOK = TRUE.
        END.
    END.

    /* Si la query n'est pas ouverte, on l'ouvre par defaut */
    IF NOT(lQueryOK) THEN DO:
        OPEN QUERY brwbases FOR EACH ttbases BY ttbases.cOrdre.
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
    lActionManuelle = TRUE.
    RUN Initialisation.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE RecupereInfosBase C-Win 
PROCEDURE RecupereInfosBase :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER cFichierInfos-in AS CHARACTER NO-UNDO.

    DEFINE VARIABLE cInfo AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cValeur AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cMessage AS CHARACTER NO-UNDO.

    Mlog("RecupereInfosBase - Fichier infos =  " + cFichierInfos-in).

    cIbVersion = "".
    cIbDate = "".
    cIbTypeVersion = "".
    cIbVersionProgress = "".
    cIbCommentaire = "".
    cIbAuto = "".
    cIbNo-Integrity = "".

    IF SEARCH(cFichierInfos-in) <> ? THEN DO:
        INPUT STREAM sEntree FROM VALUE(cFichierInfos-in).
        REPEAT:
            IMPORT STREAM sEntree UNFORMATTED cLigne.
            IF cLigne = "" THEN NEXT.
            cinfo = ENTRY(1,cLigne,"=").
            cValeur = (IF NUM-ENTRIES(cLigne,"=") > 1 THEN ENTRY(2,cLigne,"=") ELSE "").
            IF cinfo = "Version" THEN cIbVersion = cValeur.
            IF cinfo = "Date" THEN cIbDate = cValeur.
            IF cinfo = "TypeVersion" THEN cIbTypeVersion = cValeur.
            IF cinfo = "VersionProgress" THEN cIbVersionProgress = cValeur.
            IF cinfo = "Commentaire" THEN cIbCommentaire = cValeur.
            IF cinfo = "Auto" THEN cIbAuto = cValeur.
            IF cinfo = "No-Integrity" THEN cIbNo-Integrity = cValeur.
            cMessage = cMessage + (IF cMessage <> "" THEN "%s" ELSE "") + cinfo + " = " + cValeur.
        END.
        INPUT STREAM sEntree CLOSE.
    END.
    Mlog(cMessage).
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE SauveInfosBase C-Win 
PROCEDURE SauveInfosBase :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER cReference-in AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER cRepertoire-in AS CHARACTER NO-UNDO.

    DEFINE VARIABLE lRetour AS LOGICAL NO-UNDO.
    DEFINE VARIABLE cFichierInfos AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cMessage AS CHARACTER NO-UNDO.
    
    DEFINE BUFFER bttbases FOR ttbases.

    IF cRepertoire-in = "" THEN DO:
        cFichierInfos = cRepertoireBases + "\" + cReference-in + "\_infos.mdev2". 
    END.
    ELSE DO:
        cFichierInfos = cRepertoire-in + "\_infos.mdev2". 
    END.
    Mlog("Sauve Info : cFichierInfos = " + cFichierInfos).
    OUTPUT STREAM sSortie TO VALUE(cFichierInfos).
    PUT STREAM sSortie UNFORMATTED "Reference=" + cReference-in SKIP.
    FIND FIRST  bttbases
        WHERE   bttbases.cbase = cReference-in
        NO-ERROR.
    IF AVAILABLE bttbases THEN DO:
        PUT STREAM sSortie UNFORMATTED "Version=" + bttbases.cVersion SKIP.
        PUT STREAM sSortie UNFORMATTED "Date=" + (IF bttbases.dDateSauvegarde <> ? THEN STRING(bttbases.dDateSauvegarde,"99/99/9999") ELSE "") SKIP.
        PUT STREAM sSortie UNFORMATTED "TypeVersion=" + bttbases.cRepertoire SKIP.
        PUT STREAM sSortie UNFORMATTED "VersionProgress=" + bttbases.cProgress SKIP.
        PUT STREAM sSortie UNFORMATTED "Commentaire=" + bttbases.cCommentaire SKIP.
        PUT STREAM sSortie UNFORMATTED "Auto=" + (IF bttbases.lAuto THEN "OUI" ELSE "NON") SKIP.
        PUT STREAM sSortie UNFORMATTED "No-Integrity=" + (IF bttbases.lNo-Integrity THEN "OUI" ELSE "NON") SKIP.
        
        cMessage = "Reference = " + cReference-in
                 + "%sVersion" + " = " + bttbases.cVersion 
                 + "%sDate" + " = " + (IF bttbases.dDateSauvegarde <> ? THEN STRING(bttbases.dDateSauvegarde,"99/99/9999") ELSE "")
                 + "%sTypeVersion" + " = " + bttbases.cRepertoire
                 + "%sVersionProgress" + " = " + bttbases.cProgress
                 + "%sCommentaire" + " = " + bttbases.cCommentaire
                 + "%sAuto" + " = " + (IF bttbases.lAuto THEN "OUI" ELSE "NON")
                 + "%sNo-Integrity" + " = " + (IF bttbases.lNo-Integrity THEN "OUI" ELSE "NON")
                 .
        Mlog(cMessage).
    END. 
    ELSE DO:
        PUT STREAM sSortie UNFORMATTED "Version=" SKIP.
        PUT STREAM sSortie UNFORMATTED "Date=" SKIP.
        PUT STREAM sSortie UNFORMATTED "TypeVersion=" SKIP.
        PUT STREAM sSortie UNFORMATTED "VersionProgress=" SKIP.
        PUT STREAM sSortie UNFORMATTED "Commentaire=" SKIP.
        PUT STREAM sSortie UNFORMATTED "Auto=" SKIP.
        PUT STREAM sSortie UNFORMATTED "No-Integrity=" SKIP.
    END.   
    OUTPUT STREAM sSortie CLOSE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE TopChronoGeneral C-Win 
PROCEDURE TopChronoGeneral :
/*------------------------------------------------------------------------------
  Purpose: Gestion du chrono général    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    DEFINE VARIABLE cFichierbase            AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE cFichierlk              AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE cFichiersvg             AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE cFichierProgress        AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE cLigne                  AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE cDerniereBase           AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE cRepertoireTempo        AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE lGestionFichiersAdb     AS LOGICAL      NO-UNDO.
    DEFINE VARIABLE cFichierAdb             AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE cFichierAdbCopie        AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE iBoucle                 AS INTEGER      NO-UNDO.
    DEFINE VARIABLE cListeRepertoiresAdb    AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE cListeBases             AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE cNomMachine             AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE iFiltresOk              AS INTEGER      NO-UNDO INIT 0.
    DEFINE VARIABLE cTempo                  AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE lBaseLib                AS LOGICAL      NO-UNDO.
    DEFINE VARIABLE cCommande               AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE cFichierInfosBases      AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE cBaseVersion            AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE lDoitChargerAuDemarrage AS LOGICAL      NO-UNDO.
    DEFINE VARIABLE lAvecVersionProgress    AS LOGICAL      NO-UNDO.

    IF not(lActionManuelle) AND DonnePreference("PREF-RAFRAICHISSEMENTMANUELBASES") = "OUI" THEN RETURN.
    
    IF lActionManuelle THEN AfficheInformations("Veuillez patienter...",0).
    
    lGestionFichiersAdb = (DonnePreference("PREF-GESTIONFICHIERSADB") = "OUI").
    lOuvertesEnPremier = (DonnePreference("PREF-BASESOUVERTESENTETE") = "OUI").

    EMPTY TEMP-TABLE ttbases.

    lDoitChargerAuDemarrage = (lPremierPassage AND DonnePreference("PREFS-VERSION-PROGRESS-DEMARRAGE") = "OUI").
    lAvecVersionProgress = (DonneParametre("AVEC_VERSION_PROGRESS") = "OUI").
    Mlog("lDoitChargerAuDemarrage = " + STRING(lDoitChargerAuDemarrage,"OUI/NON") + "%slAvecVersionProgress = " + STRING(lAvecVersionProgress,"OUI/NON")).

    RUN ChargeBasesLib.
    IF (DonnePreference("PREF-BASESLOCALES") = "OUI" AND  cRepertoireBases <> "") OR rsChoixBases:SCREEN-VALUE IN FRAME frmFonction = "2" THEN DO:
        RUN ChargeBases.
    
        /* Recherche des fichier lk */
        ETIME(TRUE).
        Mlog("Debut Chargement de la liste des bases").
        FOR EACH ttBases:
            lBaseLib = ttBases.lLib.
            IF lBaseLib THEN DO:
                /* Gerer la bascule V10-V11 */
                cTempo = disque + DonneRepertoireApplication(ttbases.cbase). /* cRepertoire n'est pas encore renseigné !!! */
                cFichierInfosBases = cTempo + "\baselib\_infos.mdev2".
                cFichierbase = cTempo + "\baselib\ladb.db".
                cFichiersvg = "".
                ttbases.cCheminBases = cTempo + "\baselib".
            END.
            ELSE DO:
                cFichierInfosBases = cRepertoireBases + "\" + ttBases.cbase + "\_infos.mdev2".
                cFichierbase = cRepertoireBases + "\" + ttBases.cbase + "\inter.db".
                cFichiersvg = cRepertoireBases + "\" + ttBases.cbase + "\svg\" + ttBases.cbase + ".7z".
                ttbases.cCheminBases = cRepertoireBases + "\" + ttBases.cbase.
            END.
            
            cFichierlk = REPLACE(cFichierbase,".db",".lk").
            RUN RecupereInfosBase(cFichierInfosBases).
            
            /* Suppression des anciens fichiers d'infos avant la mise en place du fichier .mdev2 */
            IF DonnePreference("PREFS-BASES-FICHIERS-NOUVELLE-GESTION-EFFACER-ANCIENS") <> "OUI" THEN DO:
                OS-COPY VALUE(cRepertoireBases + "\" + ttBases.cbase + "\_date.txt") VALUE(gcRepertoireRessourcesPrivees + "Utilisateurs\" + gcUtilisateur + "\" + ttBases.cbase + "-_date.txt").
                OS-DELETE VALUE(cRepertoireBases + "\" + ttBases.cbase + "\_date.txt").
                OS-COPY VALUE(cRepertoireBases + "\" + ttBases.cbase + "\_commentaire.txt") VALUE(gcRepertoireRessourcesPrivees + "Utilisateurs\" + gcUtilisateur + "\" + ttBases.cbase + "-_commentaire.txt").
                OS-DELETE VALUE(cRepertoireBases + "\" + ttBases.cbase + "\_commentaire.txt").
                OS-COPY VALUE(cRepertoireBases + "\" + ttBases.cbase + "\_progress.txt") VALUE(gcRepertoireRessourcesPrivees + "Utilisateurs\" + gcUtilisateur + "\" + ttBases.cbase + "-_progress.txt").
                OS-DELETE VALUE(cRepertoireBases + "\" + ttBases.cbase + "\_progress.txt").
                OS-COPY VALUE(cRepertoireBases + "\" + ttBases.cbase + "\_repertoire.txt") VALUE(gcRepertoireRessourcesPrivees + "Utilisateurs\" + gcUtilisateur + "\" + ttBases.cbase + "-_repertoire.txt").
                OS-DELETE VALUE(cRepertoireBases + "\" + ttBases.cbase + "\_repertoire.txt").
                OS-COPY VALUE(cRepertoireBases + "\" + ttBases.cbase + "\_version.txt") VALUE(gcRepertoireRessourcesPrivees + "Utilisateurs\" + gcUtilisateur + "\" + ttBases.cbase + "-_version.txt").
                OS-DELETE VALUE(cRepertoireBases + "\" + ttBases.cbase + "\_version.txt").
                OS-COPY VALUE(cRepertoireBases + "\" + ttBases.cbase + "\_auto.txt") VALUE(gcRepertoireRessourcesPrivees + "Utilisateurs\" + gcUtilisateur + "\" + ttBases.cbase + "-_auto.txt").
                OS-DELETE VALUE(cRepertoireBases + "\" + ttBases.cbase + "\_auto.txt").
            END.
            
            /* Pour avoir les informations de suite */
            ttBases.lbase = SEARCH(cFichierbase) <> ?.
            ttBases.lsauvegarde = SEARCH(cFichiersvg) <> ?.
            ttBases.lNo-Integrity = (cIbNo-Integrity = "OUI").
                        
            /* Détemination de la version progress des bases */
            IF ttBases.lbase THEN DO:
                IF (lAvecVersionProgress OR lDoitChargerAuDemarrage) THEN DO:
                    IF ttbases.lLib THEN DO:
                        cBaseVersion = ttbases.cCheminBases + "\lcompta.db".                
                        cFichierProgress = ttbases.cCheminBases + "\" + "_infos.tmpmdev2".
                    END.
                    ELSE DO:
                        cBaseVersion = cRepertoireBases + "\" + ttBases.cbase + "\inter.db".                
                        cFichierProgress = cRepertoireBases + "\" + ttBases.cbase + "\_infos.tmpmdev2".
                    END.

                    cCommande = "proutil " + cBaseVersion + " -C describe > " + cFichierProgress + " && exit".   
                    Mlog("Lancement de la commande : " + cCommande).
                    OS-COMMAND SILENT  VALUE(cCommande).

                    /* analyse du fichier en retour */
                    INPUT STREAM sEntree FROM VALUE(cFichierProgress).
                    ttbases.cProgress = "".
                    REPEAT:
                        IMPORT STREAM sEntree UNFORMATTED cLigne.
                        IF cLigne MATCHES "*150.0*" OR cLigne MATCHES "*64.0*" THEN do:
                            ttbases.cProgress = "V10".
                            LEAVE.
                        END.
                        IF cLigne MATCHES "*173.0*" THEN do:
                            ttbases.cProgress = "V11".
                            LEAVE.
                        END.
                        IF ttbases.cProgress = "" AND cLigne MATCHES "*La version de la base de données est incorrecte.*" THEN DO:
                            IF gcVersionProgress = "V10" THEN ttbases.cProgress = "V11".
                            IF gcVersionProgress = "V11" THEN ttbases.cProgress = "V10".
                        END.
                    END.
                    INPUT STREAM sEntree CLOSE.
                    
                    /* Suppression des fichiers temporaires */
                    OS-DELETE value(cFichierProgress).
                    
                    Mlog(ttBases.cbase + " ---> Version Progress : Calcul = " + ttbases.cProgress).
                END.
                ELSE DO:
                    /* Rechargement depuis le fichier des informations */
                    ttbases.cProgress = cIbVersionProgress.
                    Mlog(ttBases.cbase + " ---> Version Progress : Lecture = " + ttbases.cProgress).
                END.
            END.

            ttBases.cVersion = cIbVersion.
            ttBases.cRepertoire = cIbTypeVersion.
            ttBases.dDateSauvegarde = DATE(cIbDate).
            ttBases.cCommentaire = cIbCommentaire. 
            ttBases.lAuto = (cIbAuto = "OUI").

            ttBases.ldemarree = SEARCH(cFichierlk) <> ?.
            ttbases.cOrdre = (IF lOuvertesEnPremier THEN STRING(NOT(ttBases.ldemarree)) ELSE "") + ttbases.cTri.
            
            IF  ttBases.cVersion = "" AND ttBases.lbase AND not(lbaseLib) AND ttbases.cProgress = gcVersionProgress THEN DO:
                RUN CalculeVersion.
            END.
            
            /* Au passage sauvegarde des infos */
            IF ttBases.lbase THEN DO:
                IF ttbases.lLib THEN DO:
                    run SauveInfosBase(ttBases.cBase,ttbases.cCheminBases).
                END.
                ELSE DO:
                    run SauveInfosBase(ttBases.cBase,"").
                END.
            END.
        END.
        Mlog("Fin Chargement de la liste des bases : " + string(ETIME)).
        SauvePreference("PREFS-BASES-FICHIERS-NOUVELLE-GESTION-EFFACER-ANCIENS","OUI").
    
    END.

    /* Chargement des droits de la TC */
    ETIME(TRUE).
    IF DonnePreference("PREF-BASESBARBADE") = "OUI" 
    OR DonnePreference("PREF-BASESNEPTUNE2") = "OUI" THEN DO:
        RUN ChargeDroitsTC.
    END.
    Mlog("Chargement des droits de la TC : " + string(ETIME)).

    /* Chargement des bases de Barbade */
    ETIME(TRUE).
    IF DonnePreference("PREF-BASESBARBADE") = "OUI" THEN DO:
        RUN LectureListeTC("barbade").
    END.
    Mlog("Chargement des bases de Barbade : " + string(ETIME)).
    
    /* Chargement des bases de Neptune2 */
    ETIME(TRUE).
    IF DonnePreference("PREF-BASESNEPTUNE2") = "OUI" THEN DO:
        RUN LectureListeTC("neptune2").
    END.
    Mlog("Chargement des bases de Neptune2 : " + string(ETIME)).

    /* Chargement des bases des autres utilisateurs */
    ETIME(TRUE).
    RUN BasesUtilisateurs(""). 
    Mlog("Chargement des bases des autres utilisateurs : " + string(ETIME)).
    
    /* Export des bases pour les autres utilisateurs */
    ETIME(TRUE).
    cRepertoireTempo = cRepertoireBases.
    cNomMachine = OS-GETENV("COMPUTERNAME").
    FOR EACH ttBases
        WHERE ttbases.cbase <> "tests"
        AND (ttBases.lbase OR ttBases.lsauvegarde) 
        AND ttbases.cServeur = "Local"
        AND ttbases.lUtil = FALSE
        AND ttbases.lLib = FALSE
        :
        cListeBases = cListeBases + CHR(10) + gcUtilisateur 
            + ";" + cRepertoireTempo + "\" + ttBases.cbase 
            + ";" + (IF cNomMachine <> ? THEN "\\" + cNomMachine + "\Bases\" + ttBases.cbase ELSE "?.?.?")
            + ";" + ttBases.cVersion 
            + ";" + (IF ttBases.lbase THEN "OUI" ELSE "NON")
            + ";" + (IF ttBases.lsauvegarde THEN "OUI" ELSE "NON")
            + ";" + ttBases.cCommentaire 
            + ";" + (IF ttBases.dDateSauvegarde <> ? THEN string(ttBases.dDateSauvegarde,"99/99/9999") ELSE "") 
            + ";" + cNomMachine
            + ";" + ttBases.cProgress
            .
    END.
    
    cListeBases = SUBSTRING(cListeBases,2).
    FIND FIRST  fichiers    EXCLUSIVE-LOCK
        WHERE   fichiers.cUtilisateur = gcUtilisateur
        AND     fichiers.cTypeFichier = "BASES"
        AND     fichiers.cIdentFichier = "bases"
        NO-ERROR.
    IF NOT(AVAILABLE(fichiers)) THEN DO:
        CREATE fichiers.
        ASSIGN
            fichiers.cUtilisateur = gcUtilisateur
            fichiers.cTypeFichier = "BASES"
            fichiers.cIdentFichier = "bases"
            .
    END.
    fichiers.texte = cListeBases.
    release fichiers.
    Mlog("Export des bases : " + string(ETIME)).

    /* Dans tous les cas */
    SupprimeParametre("AVEC_VERSION_PROGRESS").

    /* Sauvegarde de la liste dans l'état avant les filtres et l'ouverture de la query */
    ETIME(TRUE).
    EMPTY TEMP-TABLE ttbasesref.
    FOR EACH ttbases:
        CREATE ttbasesref.
        BUFFER-COPY ttbases TO ttbasesref.
    END.
    Mlog("Sauvegarde de la liste dans l'état avant les filtres et l'ouverture de la query : " + string(ETIME)).

    /* Application des filtres */
    ETIME(TRUE).
    IF iNombreFiltres > 0 THEN DO:
        cFiltreUtil = DonnePreference("FILTRE-UTILISATEUR").
        FOR EACH ttbases:
            iFiltresOk = 0.
            IF lFiltrePresente AND ttbases.lbase THEN iFiltresOk = iFiltresOk + 1.
            IF lFiltreabsente AND not(ttbases.lbase) THEN iFiltresOk = iFiltresOk + 1.
            IF lFiltreouverte AND ttbases.ldemarree THEN iFiltresOk = iFiltresOk + 1.
            IF lFiltrefermee AND ttbases.lbase AND not(ttbases.ldemarree) THEN iFiltresOk = iFiltresOk + 1.
            IF lFiltreSauvegardePresente AND ttbases.lSauvegarde THEN iFiltresOk = iFiltresOk + 1.
            IF lFiltreSauvegardeabsente AND not(ttbases.lSauvegarde) THEN iFiltresOk = iFiltresOk + 1.
            IF lFiltreUtil AND ((ttbases.lUtil AND ttbases.cServeur = cFiltreUtil) OR not(ttbases.lUtil)) THEN iFiltresOk = iFiltresOk + 1.
    
            IF (lFiltreEt AND iFiltresOk = iNombreFiltres) OR (not(lFiltreEt) AND iFiltresOk >= 1) THEN NEXT.
    
            /* Si on arrive ici c'est qu'aucun filtre ne correspond */
            DELETE ttbases.
        END.
    END.
    Mlog("Application des filtres : " + string(ETIME)).

    /* ouverture du query */
    ETIME(TRUE).
    RUN OuvreQuery("").
    Mlog("Ouverture de la Query : " + string(ETIME)).
    
    /* repositionnement sur la dernière base utilisée */
    ETIME(TRUE).
    brwbases:SET-REPOSITIONED-ROW(21,"CONDITIONAL") IN FRAME frmFonction.
    cDerniereBase = DonnePreference("DERNIERE-BASE").
    IF cDerniereBase <> "" AND num-entries(cDerniereBase) = 2 THEN DO:
        FIND FIRST ttbases WHERE ttbases.cserveur = entry(1,cDerniereBase) AND ttbases.cbase = entry(2,cDerniereBase) NO-ERROR.
        IF AVAILABLE(ttbases)  THEN DO:
            REPOSITION brwbases TO RECID RECID(ttbases).
            brwbases:REFRESH() IN FRAME frmFonction.
        END.
    END.
    Mlog("Repositionnement du browse : " + string(ETIME)).

    APPLY "VALUE-CHANGED" TO brwBases IN FRAME frmFonction.   

    /* Taille restante sur le disque */
    ETIME(TRUE).
    OS-COMMAND SILENT value(gcRepertoireRessourcesPrivees + "\scripts\serveurs\DonneTailleDisque.bat " + cRepertoireBases).
    INPUT STREAM sEntree FROM VALUE(cRepertoireBases + "\" + "_Dispo.mdev2") /*CONVERT TARGET "IBM850"*/.
    REPEAT:
        IMPORT STREAM sEntree UNFORMATTED cLigne.
        IF cLigne <> "" THEN DO:
            cLigne = ENTRY(2,cLigne,")").
            cLigne = ENTRY(1,cLigne,"o").
            cLigne = trim(replace(cLigne," ","")).
            cLigne = trim(replace(cLigne,"ÿ","")).
            iDispoDisque = int64(cLigne).
            filDispo:SCREEN-VALUE IN FRAME FrmFonction = FormatteTaille(iDispoDisque).
        END.
    END.
    INPUT STREAM sEntree CLOSE.
    Mlog ("Calcul taille restante sur le disque : " + string(ETIME)).

    IF lActionManuelle THEN AfficheInformations("",0).
    lActionManuelle = FALSE.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE TopChronoPartiel C-Win 
PROCEDURE TopChronoPartiel :
DEFINE VARIABLE cTypeAction AS CHARACTER NO-UNDO.

    /* Gestion du chrono Partiel */

    lRecharger = FALSE.   
    FOR EACH ordres EXCLUSIVE-LOCK
        WHERE ordres.cutilisateur = gcUtilisateur
        AND ordres.cAction BEGINS "BASES-"
        BY ordres.iordre
        :
        cTypeAction = (IF NUM-ENTRIES(ordres.cAction,"-") > 1 THEN ENTRY(2,ordres.cAction,"-") ELSE "INFOS").

        /* Prévenir que l'action a été faite */
        IF cTypeAction MATCHES "*INFOS*" THEN DO:
            RUN EnvoiOrdre("INFOS",ordres.cmessage,ordres.cutilisateur,ordres.filler,false,FALSE).
        END.

        DELETE ordres.
        lRecharger = TRUE.
        IF (cTypeAction MATCHES "*SANSMAJ*" OR FRAME frmModule:VISIBLE = FALSE) THEN do:
            lRecharger = FALSE.
            AssigneParametre("BASES-RECHARGER","OUI").
        END.
    END.

    RELEASE ordres.

    IF lRecharger THEN RUN recharger.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE VerificationFichiersConnexion C-Win 
PROCEDURE VerificationFichiersConnexion :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    DEFINE INPUT PARAMETER cBase-in AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER cVersion-in AS CHARACTER NO-UNDO.

    DEFINE VARIABLE lErreurConnexion AS LOGICAL NO-UNDO INIT FALSE.
    DEFINE VARIABLE lErreurAdb AS LOGICAL NO-UNDO INIT FALSE.
    DEFINE VARIABLE cErreur AS CHARACTER NO-UNDO INIT "".
    DEFINE VARIABLE cFichierConnexion AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cFichierAdb AS CHARACTER NO-UNDO.

    /* Vérification du fichier de connexion */
    cFichierConnexion = "c:\pfgi\cnx" + cBase-in + ".pf".
    IF SEARCH(cFichierConnexion) = ? THEN DO:
        lErreurConnexion = TRUE.
    END.

    /* Vérification du fichier adb */
    IF cVersion-in <> "" THEN DO:
        cFichierAdb = disque.
        IF cVersion-in = "DEV" THEN cFichierAdb = cFichierAdb + "gidev\".
        IF cVersion-in = "CLI" THEN cFichierAdb = cFichierAdb + "gi\".
        IF cVersion-in = "PREC" THEN cFichierAdb = cFichierAdb + "gi_prec\gi\".
        IF cVersion-in = "SUIV" THEN cFichierAdb = cFichierAdb + "gi_suiv\gi\".
        IF cVersion-in = "SPE" THEN cFichierAdb = cFichierAdb + "gi_spe\gi\".
        cFichierAdb = cFichierAdb + "adb" + cBase-in.
        IF SEARCH(cFichierAdb) = ? THEN DO:
            lErreurAdb = TRUE.
        END.
    END.

    IF lErreurConnexion OR lErreurAdb THEN DO:
        cErreur = "Attention :%s"
            + (IF lErreurConnexion THEN "Le fichier de connexion '" + cFichierConnexion + "' est introuvable.%s" ELSE "")
            + (IF lErreurAdb THEN "Le fichier '" + cFichierAdb + "' est introuvable.%s" ELSE "")
            + "Voulez vous générer le ou les fichiers manquants ?"
            .
        RUN AfficheMessageAvecTemporisation("Problème potentiel...",cErreur,TRUE,10,"NON","",FALSE,OUTPUT cRetour).
        IF cRetour = "OUI" THEN DO:
            APPLY "CHOOSE" TO MENU-ITEM m_Generation IN MENU Menubases.
        END.
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION DonneCouleurLigne C-Win 
FUNCTION DonneCouleurLigne RETURNS INTEGER
  (cSituation-in AS CHARACTER,lDemarree-in AS LOGICAL) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
    DEFINE VARIABLE iRetour AS INTEGER NO-UNDO INIT 0.

    IF DonnePreference("BASES-COULEUR-PROVENANCE") = "OUI" THEN DO:
        IF cSituation-in = "local" THEN iRetour = 3.
        IF cSituation-in = "barbade" THEN iRetour = 14.
        IF cSituation-in = "neptune2" THEN iRetour = 11.
        IF cSituation-in BEGINS "util:" THEN iRetour = 13.
    END.
    ELSE DO:
        IF lDemarree-in  THEN iRetour = 10.
    END.


  RETURN iRetour.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION DonneInfosServeurs C-Win 
FUNCTION DonneInfosServeurs RETURNS CHARACTER
  ( cNomBase AS CHARACTER ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
    DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cPrefixe AS CHARACTER NO-UNDO.

    cPrefixe = "PREFS-SERVEURS-" + cNomBase.
    IF DonnePreference(cPrefixe + "-ACTIF") = "OUI" THEN DO:
        cRetour = DonnePreference(cPrefixe).  
    END.
    IF cRetour = "" THEN cRetour = DonnePreference("PREFS-SERVEURS-STANDARD").
    RETURN cRetour.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION IsDroitTC C-Win 
FUNCTION IsDroitTC RETURNS LOGICAL
  ( cServeur-in AS CHARACTER, cBase-in AS CHARACTER ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
    DEFINE VARIABLE lRetour AS LOGICAL NO-UNDO INIT TRUE.

    /* y-a-t-il des droits gérés sur cette base ? */
    FIND FIRST  ttdroitsTC  
        WHERE   ttDroitsTC.cserveur = cServeur-in
        AND     ttDroitsTC.cbase = cbase-in
        NO-ERROR.
    IF AVAILABLE(ttDroitsTC) THEN DO:
        /* Oui, l'utilisateur y-a-t-il droit ?  */
        FIND FIRST  ttdroitsTC  
            WHERE   ttDroitsTC.cserveur = cServeur-in
            AND     ttDroitsTC.cbase = cbase-in
            AND     ttdroitsTC.cUtilisateur = cMachineUtilisateur
            NO-ERROR.
        IF NOT(AVAILABLE(ttDroitsTC)) THEN lRetour = FALSE.
    END.

  RETURN lRetour.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

