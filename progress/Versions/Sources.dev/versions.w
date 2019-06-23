&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          gidata           PROGRESS
*/
&Scoped-define WINDOW-NAME winVersions
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS winVersions 
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
IF NOT(PROPATH MATCHES("*" + OS-GETENV("DLC") + "\src*")) THEN DO:
    PROPATH = PROPATH + "," + OS-GETENV("DLC") + "\src".
END.

/* ***************************  Definitions  ************************** */
{includes\i_environnement.i NEW GLOBAL}
{includes\i_api.i NEW}
{includes\i_son.i}
{includes\i_html.i}
{includes\i_fichier.i}
{includes\i_word.i}
{versions\includes\versions.i NEW}


/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
&SCOPED-DEFINE BoutonVisibleEnModeSaisie   "QRFLDM"
&SCOPED-DEFINE BoutonEtatEnModeSaisie   ""
&SCOPED-DEFINE BoutonVisibleEnModeVisu   "QRFLDM"
&SCOPED-DEFINE BoutonEtatEnModeVisu   "QRFLDM"

&SCOPED-DEFINE CouleurSaisie   3
    
DEFINE VARIABLE cModeAffichageEnCours AS CHARACTER NO-UNDO.
DEFINE VARIABLE iCouleurInitiale AS INTEGER NO-UNDO.
DEFINE VARIABLE lModificationsGenerales AS LOGICAL NO-UNDO INIT FALSE.

DEFINE VARIABLE iOrdreVersion AS INTEGER NO-UNDO.
DEFINE BUFFER rversions FOR versions.


DEFINE VARIABLE cVersionEnCours AS CHARACTER NO-UNDO.

DEFINE VARIABLE lModificationsAutorisees AS LOGICAL NO-UNDO INIT TRUE.

DEFINE STREAM sSortie.


DEFINE BUFFER rechMoulinettes FOR moulinettes.
DEFINE BUFFER rechVersions FOR versions.


DEFINE VARIABLE cFichierHebdo AS CHARACTER NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME frmFond
&Scoped-define BROWSE-NAME brwMoulinettes

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES Moulinettes Versions

/* Definitions for BROWSE brwMoulinettes                                */
&Scoped-define FIELDS-IN-QUERY-brwMoulinettes Moulinettes.cRepertoireMoulinette Moulinettes.cNomMoulinette Moulinettes.cAuteurMoulinette Moulinettes.lGestion Moulinettes.lPME Moulinettes.lHREF Moulinettes.lHVid Moulinettes.lURef Moulinettes.lUVid Moulinettes.lDernier Moulinettes.cLibelleMoulinette   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brwMoulinettes   
&Scoped-define SELF-NAME brwMoulinettes
&Scoped-define QUERY-STRING-brwMoulinettes FOR EACH  Moulinettes no-lock     WHERE moulinettes.cNumeroVersion = Versions.cNumeroVersion     BY Moulinettes.cRepertoireMoulinette      BY Moulinettes.cNomMoulinette INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-brwMoulinettes OPEN QUERY {&SELF-NAME} FOR EACH  Moulinettes no-lock     WHERE moulinettes.cNumeroVersion = Versions.cNumeroVersion     BY Moulinettes.cRepertoireMoulinette      BY Moulinettes.cNomMoulinette INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-brwMoulinettes Moulinettes
&Scoped-define FIRST-TABLE-IN-QUERY-brwMoulinettes Moulinettes


/* Definitions for BROWSE brwVersions                                   */
&Scoped-define FIELDS-IN-QUERY-brwVersions Versions.cNumeroVersion Versions.dDateVersion Versions.iCrcSadb Versions.iCrcInter Versions.iCrcCompta Versions.iCrcTransfert Versions.iCrcCadb Versions.iCrcLadb Versions.iCrcWadb Versions.iCrcLcompta Versions.iCrcLtrans Versions.iCrcDwh Versions.lGidev Versions.lGi Versions.lGicli Versions.cRepertoireVersion (Versions.cFiller2 <> "") (Versions.cFiller1 <> "") Versions.lExclusion   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brwVersions   
&Scoped-define SELF-NAME brwVersions
&Scoped-define QUERY-STRING-brwVersions FOR EACH Versions NO-LOCK     BY iOrdre DESCENDING INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-brwVersions OPEN QUERY {&SELF-NAME} FOR EACH Versions NO-LOCK     BY iOrdre DESCENDING INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-brwVersions Versions
&Scoped-define FIRST-TABLE-IN-QUERY-brwVersions Versions


/* Definitions for FRAME frmFond                                        */
&Scoped-define OPEN-BROWSERS-IN-QUERY-frmFond ~
    ~{&OPEN-QUERY-brwMoulinettes}~
    ~{&OPEN-QUERY-brwVersions}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS brwVersions btnAjouterVersion ~
btnValiderVersion btnModifierVersion btnAbandonnerVersion ~
btnSupprimerVersion brwMoulinettes btnAjouterMoulinette ~
btnValiderMoulinette btnModifierMoulinette btnAbandonnerMoulinette ~
btnSupprimerMoulinette 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD AfficheInformations winVersions 
FUNCTION AfficheInformations RETURNS LOGICAL
  (cLibelle-in AS CHARACTER)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD Controle_Abandon winVersions 
FUNCTION Controle_Abandon RETURNS LOGICAL
  ( /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR winVersions AS WIDGET-HANDLE NO-UNDO.

/* Menu Definitions                                                     */
DEFINE MENU MENU-BAR-winVersions MENUBAR
       MENU-ITEM m_Préférences  LABEL "Préférences"   
       MENU-ITEM m_item         LABEL "?"             .

DEFINE MENU POPUP-MENU-brwMoulinettes 
       MENU-ITEM m_ModifierMoulinette LABEL "Modifier"      
       RULE
       MENU-ITEM m_OuvrirMoulinette LABEL "Ouvrir"        
       RULE
       MENU-ITEM m_Fermer_ce_menu LABEL "Fermer ce menu".

DEFINE MENU POPUP-MENU-brwVersions 
       MENU-ITEM m_ModifierVersion LABEL "Modifier"      
       RULE
       MENU-ITEM m_Fermer_ce_menu2 LABEL "Fermer ce menu".


/* Definitions of the field level widgets                               */
DEFINE BUTTON btnChargement  NO-FOCUS
     LABEL "Import" 
     SIZE 10 BY .71.

DEFINE BUTTON btnCodePrecedent 
     LABEL "<" 
     SIZE-PIXELS 20 BY 20 TOOLTIP "Rechercher le précédent".

DEFINE BUTTON btnCodeSuivant  NO-CONVERT-3D-COLORS
     LABEL ">" 
     SIZE-PIXELS 20 BY 20 TOOLTIP "Rechercher le suivant".

DEFINE BUTTON btnDetail 
     LABEL "D" 
     SIZE 8 BY 1.91 TOOLTIP "Impression du detail de la version en cours".

DEFINE BUTTON btnFichierVersion 
     LABEL "F" 
     SIZE 8 BY 1.91 TOOLTIP "Générer un fichier de montage de version".

DEFINE BUTTON btnListe 
     LABEL "L" 
     SIZE 8 BY 1.91 TOOLTIP "Impression de la liste des versions".

DEFINE BUTTON btnMajListe 
     LABEL "M" 
     SIZE 8 BY 1.91 TOOLTIP "Mise à jour de la liste des versions sur les serveurs".

DEFINE BUTTON btnQuitter 
     LABEL "X" 
     SIZE 8 BY 1.91 TOOLTIP "Quitter la gestion des versions MaGI".

DEFINE BUTTON btnRafraichir 
     LABEL "R" 
     SIZE 8 BY 1.91 TOOLTIP "Rafraichissement de la liste des versions MaGI".

DEFINE VARIABLE filInfos AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 52 BY .62 NO-UNDO.

DEFINE VARIABLE filRecherche AS CHARACTER FORMAT "X(256)":U 
     LABEL "Recherche Moulinette" 
     VIEW-AS FILL-IN 
     SIZE 21 BY .95 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 1 BY 1.67
     BGCOLOR 7 FGCOLOR 7 .

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 1 BY 1.67
     BGCOLOR 7 FGCOLOR 7 .

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 1 BY 1.67
     BGCOLOR 7 FGCOLOR 7 .

DEFINE VARIABLE tglHebdo AS LOGICAL INITIAL no 
     LABEL "Génération automatique de la version hebdomadaire" 
     VIEW-AS TOGGLE-BOX
     SIZE 64 BY .71
     FGCOLOR 12 FONT 6 NO-UNDO.

DEFINE BUTTON btnAbandonnerMoulinette 
     LABEL "X" 
     SIZE 5 BY .95 TOOLTIP "Abandonner la saisie en cours".

DEFINE BUTTON btnAbandonnerVersion 
     LABEL "X" 
     SIZE 5 BY .95 TOOLTIP "Abandonner la saisie en cours".

DEFINE BUTTON btnAjouterMoulinette 
     LABEL "+" 
     SIZE 5 BY .95 TOOLTIP "Ajouter un nouvelle moulinette".

DEFINE BUTTON btnAjouterVersion 
     LABEL "+" 
     SIZE 5 BY .95 TOOLTIP "Ajouter un nouvelle version".

DEFINE BUTTON btnModifierMoulinette 
     LABEL "#" 
     SIZE 5 BY .95 TOOLTIP "Modifier la moulinette sélectionnée".

DEFINE BUTTON btnModifierVersion 
     LABEL "#" 
     SIZE 5 BY .95 TOOLTIP "Modifier la version sélectionnée".

DEFINE BUTTON btnSupprimerMoulinette 
     LABEL "-" 
     SIZE 5 BY .95 TOOLTIP "Supprimer la moulinette sélectionnée".

DEFINE BUTTON btnSupprimerVersion 
     LABEL "-" 
     SIZE 5 BY .95 TOOLTIP "Supprimer la version sélectionnée".

DEFINE BUTTON btnValiderMoulinette 
     LABEL "Ok" 
     SIZE 5 BY .95 TOOLTIP "Valider la saisie en cours".

DEFINE BUTTON btnValiderVersion 
     LABEL "Ok" 
     SIZE 5 BY .95 TOOLTIP "Valider la saisie en cours".

DEFINE VARIABLE edtInformation AS CHARACTER 
     VIEW-AS EDITOR NO-BOX
     SIZE 61 BY .91
     BGCOLOR 3 FGCOLOR 15 FONT 10 NO-UNDO.

DEFINE IMAGE IMAGE-1
     FILENAME "adeicon/rbuild%.ico":U
     SIZE 8 BY 1.43.

DEFINE VARIABLE filAuteur AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 12 BY .95
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE filLibelleMoulinette AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 12 BY .95
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE filNomMoulinette AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 5 BY .95
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE filRepertoireMoulinette AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 12 BY .95
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE tgldernier AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 3 BY .81 NO-UNDO.

DEFINE VARIABLE tglGestion AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 3 BY .81 NO-UNDO.

DEFINE VARIABLE tglhref AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 3 BY .81 NO-UNDO.

DEFINE VARIABLE tglhvid AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 3 BY .81 NO-UNDO.

DEFINE VARIABLE tglPme AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 3 BY .81 NO-UNDO.

DEFINE VARIABLE tgluref AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 3 BY .81 NO-UNDO.

DEFINE VARIABLE tgluvid AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 3 BY .81 NO-UNDO.

DEFINE VARIABLE edtCommentaire AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 58 BY 1.67
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE edtDeltas AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 52 BY 1.67
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE filCadb AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 12 BY .95
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE filCompta AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 12 BY .95
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE filDate AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 12 BY .95
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE filDwh AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 12 BY .95
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE filInter AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 12 BY .95
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE filLadb AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 12 BY .95
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE filLCompta AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 12 BY .95
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE filLtrans AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 12 BY .95
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE filNumeroVersion AS CHARACTER FORMAT "x(8)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 5 BY .95
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE filRepertoire AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 12 BY .95
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE filSadb AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 12 BY .95
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE filTransfert AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 12 BY .95
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE filWadb AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 12 BY .95
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE tglClient AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 3 BY .81 NO-UNDO.

DEFINE VARIABLE tglDev AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 3 BY .81 NO-UNDO.

DEFINE VARIABLE tglExclusion AS LOGICAL INITIAL no 
     LABEL "Exclusion de la liste des versions" 
     VIEW-AS TOGGLE-BOX
     SIZE 36 BY .95 NO-UNDO.

DEFINE VARIABLE tglTest AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 3 BY .81 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brwMoulinettes FOR 
      Moulinettes SCROLLING.

DEFINE QUERY brwVersions FOR 
      Versions SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brwMoulinettes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brwMoulinettes winVersions _FREEFORM
  QUERY brwMoulinettes NO-LOCK DISPLAY
      Moulinettes.cRepertoireMoulinette COLUMN-LABEL "Répertoire" FORMAT "x(7)":U
      Moulinettes.cNomMoulinette COLUMN-LABEL "Nom" FORMAT "x(32)":U
      Moulinettes.cAuteurMoulinette COLUMN-LABEL "Auteur" FORMAT "x(10)":U
      Moulinettes.lGestion FORMAT "Oui/Non":U
      Moulinettes.lPME FORMAT "Oui/Non":U
      Moulinettes.lHREF FORMAT "Oui/Non":U
      Moulinettes.lHVid FORMAT "Oui/Non":U
      Moulinettes.lURef FORMAT "Oui/Non":U
      Moulinettes.lUVid FORMAT "Oui/Non":U
      Moulinettes.lDernier FORMAT "Oui/Non":U
      Moulinettes.cLibelleMoulinette FORMAT "x(80)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH SEPARATORS SIZE 203 BY 7.76
         FONT 11
         TITLE "Moulinettes de la version sélectionnée" ROW-HEIGHT-CHARS .76 FIT-LAST-COLUMN.

DEFINE BROWSE brwVersions
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brwVersions winVersions _FREEFORM
  QUERY brwVersions NO-LOCK DISPLAY
      Versions.cNumeroVersion COLUMN-LABEL "Version" FORMAT "x(8)":U
      Versions.dDateVersion COLUMN-LABEL "Date" FORMAT "99/99/9999":U
      Versions.iCrcSadb COLUMN-LABEL "Sadb" FORMAT ">>>>>>>9":U
      Versions.iCrcInter COLUMN-LABEL "Inter" FORMAT ">>>>>>>9":U
      Versions.iCrcCompta COLUMN-LABEL "Compta" FORMAT ">>>>>>>9":U
      Versions.iCrcTransfert COLUMN-LABEL "Transfert" FORMAT ">>>>>>>9":U
      Versions.iCrcCadb COLUMN-LABEL "Cadb" FORMAT ">>>>>>>9":U
      Versions.iCrcLadb COLUMN-LABEL "Ladb" FORMAT ">>>>>>>9":U
      Versions.iCrcWadb COLUMN-LABEL "Wadb" FORMAT ">>>>>>>9":U
      Versions.iCrcLcompta COLUMN-LABEL "Lcompta" FORMAT ">>>>>>>9":U
      Versions.iCrcLtrans COLUMN-LABEL "Ltrans" FORMAT ">>>>>>>9":U
      Versions.iCrcDwh COLUMN-LABEL "Dwh" FORMAT ">>>>>>>9":U
      Versions.lGidev COLUMN-LABEL "Dev" FORMAT "Oui/Non":U
      Versions.lGi COLUMN-LABEL "Test" FORMAT "Oui/Non":U
      Versions.lGicli COLUMN-LABEL "Client" FORMAT "Oui/Non":U
      Versions.cRepertoireVersion COLUMN-LABEL "Repert." FORMAT "x(07)":U
      (Versions.cFiller2 <> "") COLUMN-LABEL "Delta+" FORMAT "Oui/":U
      (Versions.cFiller1 <> "") COLUMN-LABEL "Com." FORMAT "Oui/":U
      Versions.lExclusion COLUMN-LABEL "Exc." FORMAT "Oui/":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH SEPARATORS SIZE 203 BY 11.43
         FONT 11
         TITLE "Liste des versions de l'application MaGI" ROW-HEIGHT-CHARS .76 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME frmBoutons
     btnChargement AT ROW 2.19 COL 192 WIDGET-ID 4
     btnQuitter AT ROW 1.05 COL 1.2 WIDGET-ID 2
     btnRafraichir AT ROW 1.05 COL 10 WIDGET-ID 6
     btnFichierVersion AT ROW 1.05 COL 19 WIDGET-ID 8
     btnListe AT ROW 1.05 COL 31 WIDGET-ID 10
     btnDetail AT ROW 1.05 COL 40 WIDGET-ID 12
     btnMajListe AT ROW 1.05 COL 52 WIDGET-ID 16
     tglHebdo AT ROW 1.24 COL 202 RIGHT-ALIGNED WIDGET-ID 36
     filRecherche AT ROW 1.48 COL 83.8 WIDGET-ID 26
     btnCodePrecedent AT Y 10 X 630 WIDGET-ID 22
     btnCodeSuivant AT Y 10 X 650 WIDGET-ID 24
     filInfos AT ROW 2.19 COL 137 COLON-ALIGNED NO-LABEL WIDGET-ID 40
     RECT-1 AT ROW 1.24 COL 29 WIDGET-ID 14
     RECT-2 AT ROW 1.24 COL 50 WIDGET-ID 18
     RECT-3 AT ROW 1.24 COL 136 WIDGET-ID 38
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 2 ROW 1.1
         SIZE 203 BY 2.1 WIDGET-ID 600.

DEFINE FRAME frmFond
     brwVersions AT ROW 1.24 COL 2 WIDGET-ID 200
     btnAjouterVersion AT ROW 13.38 COL 185 WIDGET-ID 4
     btnValiderVersion AT ROW 13.38 COL 188 WIDGET-ID 10
     btnModifierVersion AT ROW 13.38 COL 191 WIDGET-ID 6
     btnAbandonnerVersion AT ROW 13.38 COL 194 WIDGET-ID 12
     btnSupprimerVersion AT ROW 13.38 COL 197 WIDGET-ID 8
     brwMoulinettes AT ROW 16.48 COL 2 WIDGET-ID 300
     btnAjouterMoulinette AT ROW 24.57 COL 186 WIDGET-ID 16
     btnValiderMoulinette AT ROW 24.57 COL 189 WIDGET-ID 22
     btnModifierMoulinette AT ROW 24.57 COL 192 WIDGET-ID 18
     btnAbandonnerMoulinette AT ROW 24.57 COL 195 WIDGET-ID 14
     btnSupprimerMoulinette AT ROW 24.57 COL 198 WIDGET-ID 20
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 3.24
         SIZE 204 BY 24.67 WIDGET-ID 100.

DEFINE FRAME frmMoulinette
     filRepertoireMoulinette AT ROW 1.24 COL 2 NO-LABEL WIDGET-ID 4
     filNomMoulinette AT ROW 1.24 COL 15 NO-LABEL WIDGET-ID 2
     filAuteur AT ROW 1.24 COL 20 NO-LABEL WIDGET-ID 6
     tglGestion AT ROW 1.24 COL 129 WIDGET-ID 36
     tglPme AT ROW 1.24 COL 135 WIDGET-ID 38
     tglhref AT ROW 1.24 COL 140 WIDGET-ID 40
     tglhvid AT ROW 1.24 COL 146 WIDGET-ID 42
     tgluref AT ROW 1.24 COL 152 WIDGET-ID 30
     tgluvid AT ROW 1.24 COL 157 WIDGET-ID 32
     tgldernier AT ROW 1.24 COL 163 WIDGET-ID 34
     filLibelleMoulinette AT ROW 1.24 COL 169 NO-LABEL WIDGET-ID 28
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 2 ROW 24.24
         SIZE 182 BY 1.43 WIDGET-ID 500.

DEFINE FRAME frmVersion
     filNumeroVersion AT ROW 1.24 COL 1 NO-LABEL WIDGET-ID 2
     filDate AT ROW 1.24 COL 14 NO-LABEL WIDGET-ID 4
     filSadb AT ROW 1.24 COL 27 NO-LABEL WIDGET-ID 6
     filInter AT ROW 1.24 COL 39 NO-LABEL WIDGET-ID 8
     filCompta AT ROW 1.24 COL 51 NO-LABEL WIDGET-ID 12
     filTransfert AT ROW 1.24 COL 63 NO-LABEL WIDGET-ID 14
     filCadb AT ROW 1.24 COL 76 NO-LABEL WIDGET-ID 16
     filLadb AT ROW 1.24 COL 88 NO-LABEL WIDGET-ID 18
     filWadb AT ROW 1.24 COL 100 NO-LABEL WIDGET-ID 20
     filLCompta AT ROW 1.24 COL 112 NO-LABEL WIDGET-ID 22
     filLtrans AT ROW 1.24 COL 125 NO-LABEL WIDGET-ID 24
     filDwh AT ROW 1.24 COL 137 NO-LABEL WIDGET-ID 26
     tglDev AT ROW 1.24 COL 152 WIDGET-ID 30
     tglTest AT ROW 1.24 COL 157 WIDGET-ID 32
     tglClient AT ROW 1.24 COL 163 WIDGET-ID 34
     filRepertoire AT ROW 1.24 COL 169 NO-LABEL WIDGET-ID 28
     edtCommentaire AT ROW 2.43 COL 17 NO-LABEL WIDGET-ID 36
     edtDeltas AT ROW 2.43 COL 93 NO-LABEL WIDGET-ID 40
     tglExclusion AT ROW 2.43 COL 147 WIDGET-ID 44
     "Deltas manuels :" VIEW-AS TEXT
          SIZE 16 BY .95 AT ROW 2.43 COL 77 WIDGET-ID 42
     "Commentaires :" VIEW-AS TEXT
          SIZE 15 BY .95 AT ROW 2.43 COL 2 WIDGET-ID 38
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 2 ROW 12.91
         SIZE 182 BY 3.33 WIDGET-ID 400.

DEFINE FRAME frmInformation
     edtInformation AT ROW 1.48 COL 13 NO-LABEL WIDGET-ID 2
     IMAGE-1 AT ROW 1.24 COL 3 WIDGET-ID 4
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 68 ROW 11
         SIZE 76 BY 1.91
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
  CREATE WINDOW winVersions ASSIGN
         HIDDEN             = YES
         TITLE              = "Versions MaGI"
         HEIGHT             = 27.52
         WIDTH              = 204
         MAX-HEIGHT         = 46
         MAX-WIDTH          = 336
         VIRTUAL-HEIGHT     = 46
         VIRTUAL-WIDTH      = 336
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

ASSIGN {&WINDOW-NAME}:MENUBAR    = MENU MENU-BAR-winVersions:HANDLE.
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW winVersions
  VISIBLE,,RUN-PERSISTENT                                               */
/* REPARENT FRAME */
ASSIGN FRAME frmInformation:FRAME = FRAME frmFond:HANDLE
       FRAME frmMoulinette:FRAME = FRAME frmFond:HANDLE
       FRAME frmVersion:FRAME = FRAME frmFond:HANDLE.

/* SETTINGS FOR FRAME frmBoutons
                                                                        */
ASSIGN 
       btnChargement:HIDDEN IN FRAME frmBoutons           = TRUE.

ASSIGN 
       btnCodeSuivant:AUTO-RESIZE IN FRAME frmBoutons      = TRUE.

/* SETTINGS FOR FILL-IN filRecherche IN FRAME frmBoutons
   ALIGN-L                                                              */
/* SETTINGS FOR TOGGLE-BOX tglHebdo IN FRAME frmBoutons
   ALIGN-R                                                              */
/* SETTINGS FOR FRAME frmFond
   FRAME-NAME                                                           */

DEFINE VARIABLE XXTABVALXX AS LOGICAL NO-UNDO.

ASSIGN XXTABVALXX = FRAME frmInformation:MOVE-AFTER-TAB-ITEM (brwVersions:HANDLE IN FRAME frmFond)
       XXTABVALXX = FRAME frmVersion:MOVE-BEFORE-TAB-ITEM (btnAjouterVersion:HANDLE IN FRAME frmFond)
       XXTABVALXX = FRAME frmMoulinette:MOVE-AFTER-TAB-ITEM (brwMoulinettes:HANDLE IN FRAME frmFond)
       XXTABVALXX = FRAME frmMoulinette:MOVE-BEFORE-TAB-ITEM (btnAjouterMoulinette:HANDLE IN FRAME frmFond)
       XXTABVALXX = FRAME frmInformation:MOVE-BEFORE-TAB-ITEM (FRAME frmVersion:HANDLE)
/* END-ASSIGN-TABS */.

/* BROWSE-TAB brwVersions 1 frmFond */
/* BROWSE-TAB brwMoulinettes btnSupprimerVersion frmFond */
ASSIGN 
       brwMoulinettes:POPUP-MENU IN FRAME frmFond             = MENU POPUP-MENU-brwMoulinettes:HANDLE.

ASSIGN 
       brwVersions:POPUP-MENU IN FRAME frmFond             = MENU POPUP-MENU-brwVersions:HANDLE
       brwVersions:ALLOW-COLUMN-SEARCHING IN FRAME frmFond = TRUE.

ASSIGN 
       btnAbandonnerMoulinette:PRIVATE-DATA IN FRAME frmFond     = 
                "SANS-CONTROLE".

ASSIGN 
       btnAbandonnerVersion:PRIVATE-DATA IN FRAME frmFond     = 
                "SANS-CONTROLE".

/* SETTINGS FOR FRAME frmInformation
                                                                        */
ASSIGN 
       FRAME frmInformation:HIDDEN           = TRUE.

ASSIGN 
       edtInformation:AUTO-RESIZE IN FRAME frmInformation      = TRUE
       edtInformation:READ-ONLY IN FRAME frmInformation        = TRUE.

/* SETTINGS FOR FRAME frmMoulinette
                                                                        */
/* SETTINGS FOR FILL-IN filAuteur IN FRAME frmMoulinette
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN filLibelleMoulinette IN FRAME frmMoulinette
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN filNomMoulinette IN FRAME frmMoulinette
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN filRepertoireMoulinette IN FRAME frmMoulinette
   ALIGN-L                                                              */
/* SETTINGS FOR FRAME frmVersion
                                                                        */
ASSIGN 
       FRAME frmVersion:MOVABLE          = TRUE.

/* SETTINGS FOR FILL-IN filCadb IN FRAME frmVersion
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN filCompta IN FRAME frmVersion
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN filDate IN FRAME frmVersion
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN filDwh IN FRAME frmVersion
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN filInter IN FRAME frmVersion
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN filLadb IN FRAME frmVersion
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN filLCompta IN FRAME frmVersion
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN filLtrans IN FRAME frmVersion
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN filNumeroVersion IN FRAME frmVersion
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN filRepertoire IN FRAME frmVersion
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN filSadb IN FRAME frmVersion
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN filTransfert IN FRAME frmVersion
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN filWadb IN FRAME frmVersion
   ALIGN-L                                                              */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(winVersions)
THEN winVersions:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brwMoulinettes
/* Query rebuild information for BROWSE brwMoulinettes
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH  Moulinettes no-lock
    WHERE moulinettes.cNumeroVersion = Versions.cNumeroVersion
    BY Moulinettes.cRepertoireMoulinette
     BY Moulinettes.cNomMoulinette INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _TblOptList       = ","
     _OrdList          = "versions.Moulinettes.cRepertoireMoulinette|yes,versions.Moulinettes.cNomMoulinette|yes"
     _Query            is OPENED
*/  /* BROWSE brwMoulinettes */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brwVersions
/* Query rebuild information for BROWSE brwVersions
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH Versions NO-LOCK
    BY iOrdre DESCENDING INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _OrdList          = "versions.Versions.iOrdre|no"
     _Query            is OPENED
*/  /* BROWSE brwVersions */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME frmMoulinette
/* Query rebuild information for FRAME frmMoulinette
     _Query            is NOT OPENED
*/  /* FRAME frmMoulinette */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME frmVersion
/* Query rebuild information for FRAME frmVersion
     _Query            is NOT OPENED
*/  /* FRAME frmVersion */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME winVersions
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL winVersions winVersions
ON END-ERROR OF winVersions /* Versions MaGI */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL winVersions winVersions
ON WINDOW-CLOSE OF winVersions /* Versions MaGI */
DO:
  /* This event will close the window and terminate the procedure.  */
    /*
    APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
  */

  APPLY "CHOOSE" TO btnQuitter IN FRAME frmboutons.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brwMoulinettes
&Scoped-define SELF-NAME brwMoulinettes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwMoulinettes winVersions
ON DEFAULT-ACTION OF brwMoulinettes IN FRAME frmFond /* Moulinettes de la version sélectionnée */
DO:
    IF lModificationsAutorisees THEN APPLY "CHOOSE" TO btnModifierMoulinette IN FRAME frmFond.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwMoulinettes winVersions
ON VALUE-CHANGED OF brwMoulinettes IN FRAME frmFond /* Moulinettes de la version sélectionnée */
DO:
    DO WITH FRAME frmMoulinette:
        RUN AffecteZone(filNomMoulinette:HANDLE,Moulinettes.cNomMoulinette:HANDLE IN BROWSE brwMoulinettes).
        RUN AffecteZone(filRepertoireMoulinette:HANDLE,Moulinettes.cRepertoireMoulinette:HANDLE IN BROWSE brwMoulinettes).
        RUN AffecteZone(filAuteur:HANDLE,Moulinettes.cAuteurMoulinette:HANDLE IN BROWSE brwMoulinettes).
        RUN AffecteZone(filLibelleMoulinette:HANDLE,Moulinettes.cLibelleMoulinette:HANDLE IN BROWSE brwMoulinettes).

        RUN AffecteToggle(tglGestion:HANDLE,Moulinettes.lGestion:HANDLE IN BROWSE brwMoulinettes).
        RUN AffecteToggle(tglPme:HANDLE,Moulinettes.lPME:HANDLE IN BROWSE brwMoulinettes).
        RUN AffecteToggle(tglhref:HANDLE,Moulinettes.lHREF:HANDLE IN BROWSE brwMoulinettes).
        RUN AffecteToggle(tglhvid:HANDLE,Moulinettes.lHVid:HANDLE IN BROWSE brwMoulinettes).
        RUN AffecteToggle(tgluref:HANDLE,Moulinettes.lURef:HANDLE IN BROWSE brwMoulinettes).
        RUN AffecteToggle(tgluvid:HANDLE,Moulinettes.lUVid:HANDLE IN BROWSE brwMoulinettes).
        RUN AffecteToggle(tgldernier:HANDLE,Moulinettes.lDernier:HANDLE IN BROWSE brwMoulinettes).
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brwVersions
&Scoped-define SELF-NAME brwVersions
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwVersions winVersions
ON DEFAULT-ACTION OF brwVersions IN FRAME frmFond /* Liste des versions de l'application MaGI */
DO:
    
    DEFINE VARIABLE cNomVersion AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cFichier AS CHARACTER NO-UNDO.

    /* --- ancienne action
    cNomVersion = "v" + SUBstring(STRING(versions.iordre,"99999999"),1,6).
    cFichier =  reseau + "dev\versions\" + cNomVersion.

    OS-COMMAND SILENT VALUE("notepad.exe " + cFichier).
    --- */

    IF lModificationsAutorisees THEN APPLY "CHOOSE" TO btnModifierVersion.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwVersions winVersions
ON VALUE-CHANGED OF brwVersions IN FRAME frmFond /* Liste des versions de l'application MaGI */
DO:
  {&OPEN-QUERY-brwMoulinettes}

    DO WITH FRAME frmVersion:
        RUN AffecteZone(filNumeroVersion:HANDLE,Versions.cNumeroVersion:HANDLE IN BROWSE brwVersions).
        RUN AffecteZone(filDate:HANDLE,Versions.dDateVersion:HANDLE IN BROWSE brwVersions).
        RUN AffecteZone(filsadb:HANDLE,Versions.iCrcSadb:HANDLE IN BROWSE brwVersions).
        RUN AffecteZone(filInter:HANDLE,Versions.iCrcInter:HANDLE IN BROWSE brwVersions).
        RUN AffecteZone(filCompta:HANDLE,Versions.iCrcCompta:HANDLE IN BROWSE brwVersions).
        RUN AffecteZone(filTransfert:HANDLE,Versions.iCrcTransfert:HANDLE IN BROWSE brwVersions).
        RUN AffecteZone(filCadb:HANDLE,Versions.iCrcCadb:HANDLE IN BROWSE brwVersions).
        RUN AffecteZone(filLadb:HANDLE,Versions.iCrcLadb:HANDLE IN BROWSE brwVersions).
        RUN AffecteZone(filWadb:HANDLE,Versions.iCrcWadb:HANDLE IN BROWSE brwVersions).
        RUN AffecteZone(fillcompta:HANDLE,Versions.iCrcLcompta:HANDLE IN BROWSE brwVersions).
        RUN AffecteZone(filLtrans:HANDLE,Versions.iCrcLtrans:HANDLE IN BROWSE brwVersions).
        RUN AffecteZone(filDwh:HANDLE,Versions.iCrcDwh:HANDLE IN BROWSE brwVersions).
        RUN AffecteZone(filrepertoire:HANDLE,Versions.cRepertoireVersion:HANDLE IN BROWSE brwVersions).
        edtCommentaire:SCREEN-VALUE = Versions.cFiller1.
        edtDeltas:SCREEN-VALUE = Versions.cFiller2.

        RUN AffecteToggle(tglDev:HANDLE,Versions.lGidev:HANDLE IN BROWSE brwVersions).
        RUN AffecteToggle(tglTest:HANDLE,Versions.lGI:HANDLE IN BROWSE brwVersions).
        RUN AffecteToggle(tglClient:HANDLE,Versions.lGicli:HANDLE IN BROWSE brwVersions).
        RUN AffecteToggle(tglExclusion:HANDLE,Versions.lExclusion:HANDLE IN BROWSE brwVersions).
    END.

    /* Sauvegarde de la version en cours */
    cVersionEnCours = Versions.cNumeroVersion.

    /* Maj des infos sur les moulinettes */
    APPLY "VALUE-CHANGED" TO brwMoulinettes.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnAbandonnerMoulinette
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnAbandonnerMoulinette winVersions
ON CHOOSE OF btnAbandonnerMoulinette IN FRAME frmFond /* X */
DO:
    /* Gestion de l'état des frames de saisie */
    RUN GereFrame("v","OFF").
    RUN GereFrame("m","OFF").
  
    /* Gestion de l'état des browses */
    RUN GereBrowse(BrwVersions:HANDLE,"ON").
    RUN GereBrowse(BrwMoulinettes:HANDLE,"ON").
  
    /* Gestion des boutons de saisie */
    RUN GereBoutons({&BoutonVisibleEnModeVisu},{&BoutonEtatEnModeVisu}).
    RUN GereBoutonsVersion("AMS","AMS").
    RUN GereBoutonsMoulinette("AMS","AMS").

    IF cModeAffichageEnCours = "AM" THEN DO:
        RUN VideZonesMoulinette.
    END.

    cModeAffichageEnCours = "VM".
    APPLY "VALUE-CHANGED" TO BrwMoulinettes.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnAbandonnerVersion
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnAbandonnerVersion winVersions
ON CHOOSE OF btnAbandonnerVersion IN FRAME frmFond /* X */
DO:
    /* Gestion de l'état des frames de saisie */
    RUN GereFrame("v","OFF").
    RUN GereFrame("m","OFF").
  
    /* Gestion de l'état des browses */
    RUN GereBrowse(BrwVersions:HANDLE,"ON").
    RUN GereBrowse(BrwMoulinettes:HANDLE,"ON").
  
    /* Gestion des boutons de saisie */
    RUN GereBoutons({&BoutonVisibleEnModeVisu},{&BoutonEtatEnModeVisu}).
    RUN GereBoutonsVersion("AMS","AMS").
    RUN GereBoutonsMoulinette("AMS","AMS").

    IF cModeAffichageEnCours = "AV" THEN DO:
        RUN VideZonesVersion.
    END.

    cModeAffichageEnCours = "VV".

    /* rafraichissement de l'ecran */
    APPLY "VALUE-CHANGED" TO brwVersions.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnAjouterMoulinette
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnAjouterMoulinette winVersions
ON CHOOSE OF btnAjouterMoulinette IN FRAME frmFond /* + */
DO:
    /* Gestion de l'état des frames de saisie */
    RUN GereFrame("v","OFF").
    RUN GereFrame("m","ON").

    /* Gestion de l'état des browses */
    RUN GereBrowse(BrwVersions:HANDLE,"OFF").
    RUN GereBrowse(BrwMoulinettes:HANDLE,"OFF").
  
    RUN VideZonesMoulinette.

    /* valeurs par defaut */
    DO WITH FRAME frmmoulinette:
        tglgestion:CHECKED = (IF gDonnePreference("PREF-TGL-GESTION") = "OUI" THEN TRUE ELSE FALSE).
        tglPME:CHECKED = (IF gDonnePreference("PREF-TGL-PME") = "OUI" THEN TRUE ELSE FALSE).
        tglhref:CHECKED = (IF gDonnePreference("PREF-TGL-HREF") = "OUI" THEN TRUE ELSE FALSE).
        tglhvid:CHECKED = (IF gDonnePreference("PREF-TGL-HVID") = "OUI" THEN TRUE ELSE FALSE).
        tgluref:CHECKED = (IF gDonnePreference("PREF-TGL-UREF") = "OUI" THEN TRUE ELSE FALSE).
        tgluvid:CHECKED = (IF gDonnePreference("PREF-TGL-UVID") = "OUI" THEN TRUE ELSE FALSE).
    END.
  
    APPLY "ENTRY" TO filrepertoireMoulinette IN FRAME frmMoulinette.

    /* Gestion des boutons de saisie */
    RUN GereBoutons({&BoutonVisibleEnModeSaisie},{&BoutonEtatEnModeSaisie}).
    RUN GereBoutonsMoulinette("VX","VX").
    RUN GereBoutonsVersion("AMS","").

    cModeAffichageEnCours = "AM".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnAjouterVersion
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnAjouterVersion winVersions
ON CHOOSE OF btnAjouterVersion IN FRAME frmFond /* + */
DO:
    /* Gestion de l'état des frames de saisie */
    RUN GereFrame("v","ON").
    RUN GereFrame("m","OFF").

    /* Gestion de l'état des browses */
    RUN GereBrowse(BrwVersions:HANDLE,"OFF").
    RUN GereBrowse(BrwMoulinettes:HANDLE,"OFF").

    RUN VideZonesVersion.
  
    /* valeurs par defaut */
    DO WITH FRAME frmversion:
        tgldev:CHECKED = (IF gDonnePreference("PREF-TGL-DEV") = "OUI" THEN TRUE ELSE FALSE).
        tgltest:CHECKED = (IF gDonnePreference("PREF-TGL-TEST") = "OUI" THEN TRUE ELSE FALSE).
        tglclient:CHECKED = (IF gDonnePreference("PREF-TGL-CLIENT") = "OUI" THEN TRUE ELSE FALSE).
    END.
    
    APPLY "ENTRY" TO filNumeroVersion IN FRAME frmVersion.

    /* Gestion des boutons de saisie */
    RUN GereBoutons({&BoutonVisibleEnModeSaisie},{&BoutonEtatEnModeSaisie}).
    RUN GereBoutonsVersion("VX","VX").
    RUN GereBoutonsMoulinette("AMS","").

    cModeAffichageEnCours = "AV".

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frmBoutons
&Scoped-define SELF-NAME btnChargement
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnChargement winVersions
ON CHOOSE OF btnChargement IN FRAME frmBoutons /* Import */
DO:
    RUN ChargeVersions.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnCodePrecedent
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnCodePrecedent winVersions
ON CHOOSE OF btnCodePrecedent IN FRAME frmBoutons /* < */
DO:
    DEFINE VARIABLE cRecherche AS CHARACTER NO-UNDO.

    cRecherche = "*" + filRecherche:SCREEN-VALUE + "*".

    /* Recherche en avant */
    IF AVAILABLE(rechMoulinettes) THEN DO:
        FIND PREV   rechMoulinettes
            WHERE   rechMoulinettes.cNomMoulinette MATCHES cRecherche
            NO-ERROR.
    END.
    IF NOT(AVAILABLE(rechMoulinettes)) THEN DO:
        FIND LAST   rechMoulinettes
            WHERE   rechMoulinettes.cNomMoulinette MATCHES cRecherche
            NO-ERROR.
    END.
    IF AVAILABLE(rechMoulinettes) THEN DO:
        /* Positionnement sur la version de la moulinette */
        FIND FIRST  RechVersions NO-LOCK
            WHERE   RechVersions.cNumeroVersion = rechMoulinettes.cNumeroVersion
            NO-ERROR.
        IF AVAILABLE(rechversions) THEN DO:
            REPOSITION brwversions TO ROWID ROWID(rechversions).
            APPLY "VALUE-CHANGED" TO brwversions IN FRAME frmfond.
            /* Positionnement sur la bonne moulinette */
            REPOSITION brwmoulinettes TO ROWID ROWID(rechmoulinettes).
        END.
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnCodeSuivant
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnCodeSuivant winVersions
ON CHOOSE OF btnCodeSuivant IN FRAME frmBoutons /* > */
DO:
    DEFINE VARIABLE cRecherche AS CHARACTER NO-UNDO.

    cRecherche = "*" + filRecherche:SCREEN-VALUE + "*".

    /* Recherche en avant */
    IF AVAILABLE(rechMoulinettes) THEN DO:
        FIND NEXT   rechMoulinettes
            WHERE   rechMoulinettes.cNomMoulinette MATCHES cRecherche
            NO-ERROR.
    END.
    IF NOT(AVAILABLE(rechMoulinettes)) THEN DO:
        FIND FIRST   rechMoulinettes
            WHERE   rechMoulinettes.cNomMoulinette MATCHES cRecherche
            NO-ERROR.
    END.
    IF AVAILABLE(rechMoulinettes) THEN DO:
        /* Positionnement sur la version de la moulinette */
        FIND FIRST  RechVersions NO-LOCK
            WHERE   RechVersions.cNumeroVersion = rechMoulinettes.cNumeroVersion
            NO-ERROR.
        IF AVAILABLE(rechversions) THEN DO:
            REPOSITION brwversions TO ROWID ROWID(rechversions).
            APPLY "VALUE-CHANGED" TO brwversions IN FRAME frmfond.
            /* Positionnement sur la bonne moulinette */
            REPOSITION brwmoulinettes TO ROWID ROWID(rechmoulinettes).
        END.
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnDetail
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnDetail winVersions
ON CHOOSE OF btnDetail IN FRAME frmBoutons /* D */
DO:  
    AfficheInformations("Veuillez patienter...").
    RUN ImpressionDetail.
    AfficheInformations("").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnFichierVersion
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnFichierVersion winVersions
ON CHOOSE OF btnFichierVersion IN FRAME frmBoutons /* F */
DO:  
    RUN GenereFichierVersion.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnListe
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnListe winVersions
ON CHOOSE OF btnListe IN FRAME frmBoutons /* L */
DO:  
    AfficheInformations("Veuillez patienter...").
    RUN ImpressionListe.
    AfficheInformations("").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnMajListe
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnMajListe winVersions
ON CHOOSE OF btnMajListe IN FRAME frmBoutons /* M */
DO:  
    AfficheInformations("Veuillez patienter...").
    RUN MajFichierServeurs.
    AfficheInformations("").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frmFond
&Scoped-define SELF-NAME btnModifierMoulinette
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnModifierMoulinette winVersions
ON CHOOSE OF btnModifierMoulinette IN FRAME frmFond /* # */
DO:
    
    IF NOT(AVAILABLE(moulinettes)) THEN RETURN.
    
    /* Gestion de l'état des frames de saisie */
    RUN GereFrame("v","OFF").
    RUN GereFrame("m","ON").

    /* Gestion de l'état des browses */
    RUN GereBrowse(BrwVersions:HANDLE,"OFF").
    RUN GereBrowse(BrwMoulinettes:HANDLE,"OFF").
  
    APPLY "ENTRY" TO filNomMoulinette IN FRAME frmMoulinette.

    /* Gestion des boutons de saisie */
    RUN GereBoutons({&BoutonVisibleEnModeSaisie},{&BoutonEtatEnModeSaisie}).
    RUN GereBoutonsMoulinette("VX","VX").
    RUN GereBoutonsVersion("AMS","").
    cModeAffichageEnCours = "MM".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnModifierVersion
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnModifierVersion winVersions
ON CHOOSE OF btnModifierVersion IN FRAME frmFond /* # */
DO:
    
    IF NOT(AVAILABLE(versions)) THEN RETURN.

    /* Gestion de l'état des frames de saisie */
    RUN GereFrame("v","ON").
    RUN GereFrame("m","OFF").

    /* Gestion de l'état des browses */
    RUN GereBrowse(BrwVersions:HANDLE,"OFF").
    RUN GereBrowse(BrwMoulinettes:HANDLE,"OFF").
  
    APPLY "ENTRY" TO filNumeroVersion IN FRAME frmVersion.

    /* Gestion des boutons de saisie */
    RUN GereBoutons({&BoutonVisibleEnModeSaisie},{&BoutonEtatEnModeSaisie}).
    RUN GereBoutonsVersion("VX","VX").
    RUN GereBoutonsMoulinette("AMS","").

    cModeAffichageEnCours = "MV".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frmBoutons
&Scoped-define SELF-NAME btnQuitter
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnQuitter winVersions
ON CHOOSE OF btnQuitter IN FRAME frmBoutons /* X */
DO:
    IF gDonnePreference("PREF-SORTIE") = "OUI" THEN DO:
        MESSAGE "Confirmez-vous la sortie de la gestion des versions MaGI ?"
            VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
            TITLE "Demande de confirmation..."
            UPDATE lReponseSortie AS LOGICAL.
        IF NOT(lReponseSortie) THEN RETURN /*NO-APPLY*/.
    END.

    /* demande de mise à jour fichier des versions */
    IF lModificationsGenerales THEN DO:
        MESSAGE "Vous avez fait des modifications dans les versions."
            + CHR(10) + "Faut-il regénérer le fichier des versions MaGI sur Barbade et Neptune ?"
            VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
            TITLE "Demande de confirmation..."
            UPDATE lReponseFichier AS LOGICAL.
        IF lReponseFichier THEN RUN MajFichierServeurs.
    END.

    APPLY "CLOSE" TO THIS-PROCEDURE.
    QUIT. /*LEAVE.*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnRafraichir
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnRafraichir winVersions
ON CHOOSE OF btnRafraichir IN FRAME frmBoutons /* R */
DO:  
    RUN Initialisation.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frmFond
&Scoped-define SELF-NAME btnSupprimerMoulinette
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnSupprimerMoulinette winVersions
ON CHOOSE OF btnSupprimerMoulinette IN FRAME frmFond /* - */
DO:
    DEFINE VARIABLE lRetour AS LOGICAL NO-UNDO.

    IF NOT(AVAILABLE(moulinettes)) THEN RETURN.

    RUN SuppressionMoulinette(OUTPUT lRetour).
    cModeAffichageEnCours = "SM".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnSupprimerVersion
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnSupprimerVersion winVersions
ON CHOOSE OF btnSupprimerVersion IN FRAME frmFond /* - */
DO:
    DEFINE VARIABLE lRetour AS LOGICAL NO-UNDO.

    IF NOT(AVAILABLE(versions)) THEN RETURN.

    cModeAffichageEnCours = "SM".

    RUN SuppressionVersion(OUTPUT lRetour).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnValiderMoulinette
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnValiderMoulinette winVersions
ON CHOOSE OF btnValiderMoulinette IN FRAME frmFond /* Ok */
DO:
    /* Gestion de l'état des frames de saisie */
    DEFINE VARIABLE lRetour AS LOGICAL NO-UNDO INIT TRUE.

    /* Validation ou retour si erreur */
    RUN ValidationMoulinettes(OUTPUT lRetour).
    IF NOT(lretour) THEN RETURN NO-APPLY.

    RUN GereFrame("v","OFF").
    RUN GereFrame("m","OFF").
  
    /* Gestion de l'état des browses */
    RUN GereBrowse(BrwVersions:HANDLE,"ON").
    RUN GereBrowse(BrwMoulinettes:HANDLE,"ON").
  
    /* Gestion des boutons de saisie */
    RUN GereBoutons({&BoutonVisibleEnModeVisu},{&BoutonEtatEnModeVisu}).
    RUN GereBoutonsVersion("AMS","AMS").
    RUN GereBoutonsMoulinette("AMS","AMS").
    cModeAffichageEnCours = "VM".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnValiderVersion
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnValiderVersion winVersions
ON CHOOSE OF btnValiderVersion IN FRAME frmFond /* Ok */
DO:
    DEFINE VARIABLE lRetour AS LOGICAL NO-UNDO INIT TRUE.

    /* Validation ou retour si erreur */
    RUN ValidationVersions(OUTPUT lRetour).
    IF NOT(lretour) THEN RETURN NO-APPLY.

    /* Gestion de l'état des frames de saisie */
    RUN GereFrame("v","OFF").
    RUN GereFrame("m","OFF").
  
    /* Gestion de l'état des browses */
    RUN GereBrowse(BrwVersions:HANDLE,"ON").
    RUN GereBrowse(BrwMoulinettes:HANDLE,"ON").
  
    /* Gestion des boutons de saisie */
    RUN GereBoutons({&BoutonVisibleEnModeVisu},{&BoutonEtatEnModeVisu}).
    RUN GereBoutonsVersion("AMS","AMS").
    RUN GereBoutonsMoulinette("AMS","AMS").


    cModeAffichageEnCours = "VV".

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frmVersion
&Scoped-define SELF-NAME edtDeltas
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL edtDeltas winVersions
ON LEAVE OF edtDeltas IN FRAME frmVersion
DO:
  edtDeltas:SCREEN-VALUE = REPLACE(edtDeltas:SCREEN-VALUE,"/","\").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filCadb
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filCadb winVersions
ON LEAVE OF filCadb IN FRAME frmVersion
DO:
  
    IF SELF:SCREEN-VALUE = "" THEN DO:
        SELF:SCREEN-VALUE = STRING(rversions.iCRCCadb).
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filCompta
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filCompta winVersions
ON LEAVE OF filCompta IN FRAME frmVersion
DO:
  
    IF SELF:SCREEN-VALUE = "" THEN DO:
        SELF:SCREEN-VALUE = STRING(rversions.iCRCcompta).
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filDate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filDate winVersions
ON ENTRY OF filDate IN FRAME frmVersion
DO:
  IF cModeAffichageEnCours = "AV" AND (SELF:SCREEN-VALUE = "" OR date(SELF:SCREEN-VALUE) = ?) THEN DO:
      SELF:SCREEN-VALUE = STRING(TODAY,"99/99/9999").
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filDate winVersions
ON LEAVE OF filDate IN FRAME frmVersion
DO:
  DEFINE VARIABLE dTempo AS DATE NO-UNDO.

  /* Controle Abandon */
  IF Controle_Abandon() THEN RETURN.

  IF (SELF:SCREEN-VALUE <> "" AND SELF:SCREEN-VALUE <> ?) THEN DO:
      dTempo = DATE(SELF:SCREEN-VALUE).
      filRepertoire:SCREEN-VALUE = ""
          + SUBSTRING(STRING(YEAR(dTempo),"9999"),4,1)
          + STRING(MONTH(dTempo),"99")
          + STRING(DAY(dTempo),"99")
          .
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filDwh
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filDwh winVersions
ON LEAVE OF filDwh IN FRAME frmVersion
DO:
  
    IF SELF:SCREEN-VALUE = "" THEN DO:
        SELF:SCREEN-VALUE = STRING(rversions.iCRCdwh).
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filInter
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filInter winVersions
ON LEAVE OF filInter IN FRAME frmVersion
DO:
  
    IF SELF:SCREEN-VALUE = "" THEN DO:
        SELF:SCREEN-VALUE = STRING(rversions.iCRCinter).
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filLadb
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filLadb winVersions
ON LEAVE OF filLadb IN FRAME frmVersion
DO:
  
    IF SELF:SCREEN-VALUE = "" THEN DO:
        SELF:SCREEN-VALUE = STRING(rversions.iCRCLadb).
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filLCompta
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filLCompta winVersions
ON LEAVE OF filLCompta IN FRAME frmVersion
DO:
  
    IF SELF:SCREEN-VALUE = "" THEN DO:
        SELF:SCREEN-VALUE = STRING(rversions.iCRClCompta).
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filLtrans
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filLtrans winVersions
ON LEAVE OF filLtrans IN FRAME frmVersion
DO:
  
    IF SELF:SCREEN-VALUE = "" THEN DO:
        SELF:SCREEN-VALUE = STRING(rversions.iCRCltrans).
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frmMoulinette
&Scoped-define SELF-NAME filNomMoulinette
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filNomMoulinette winVersions
ON LEAVE OF filNomMoulinette IN FRAME frmMoulinette
DO:
  DEFINE VARIABLE cFichierMoulinette AS CHARACTER NO-UNDO.

  DO WITH FRAME frmMoulinette:
      
      /* Controle Abandon */
      IF Controle_Abandon() THEN RETURN.
      
      filLibelleMoulinette:SCREEN-VALUE = "Voir fiche...".
      IF NOT(SELF:SCREEN-VALUE) MATCHES ("*.p") THEN SELF:SCREEN-VALUE = SELF:SCREEN-VALUE + ".p".

      /* Vérification d'existence de la moulinette */
      cFichierMoulinette = ""
          + OS-GETENV("Reseau") 
          + "gi\maj\delta\"
          + filRepertoireMoulinette:SCREEN-VALUE
          + "\" + filNomMoulinette:SCREEN-VALUE
          .
      IF SEARCH(cFichierMoulinette) = ? THEN DO:
          MESSAGE "Le fichier '" + cFichierMoulinette + "' n'existe pas. Merci de corriger !!"
              VIEW-AS ALERT-BOX ERROR
              TITLE "Contrôle de saisie..."
              .
          RETURN NO-APPLY.
      END.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frmVersion
&Scoped-define SELF-NAME filNumeroVersion
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filNumeroVersion winVersions
ON LEAVE OF filNumeroVersion IN FRAME frmVersion
DO:
    DEFINE VARIABLE ctempo AS CHARACTER NO-UNDO.
    DEFINE BUFFER bversions FOR versions.

    /* Controle Abandon */
    IF Controle_Abandon() THEN RETURN.

    IF cModeAffichageEnCours = "AV" THEN DO:
        /* verifier que le version n'existe pas déjà */
        FIND FIRST  bversions NO-LOCK
            WHERE   bversions.cnumeroversion = SELF:SCREEN-VALUE
            NO-ERROR.
        IF AVAILABLE(bversions) THEN DO:
            MESSAGE "Ce numéro de version existe déjà."
                VIEW-AS ALERT-BOX ERROR
                TITLE "Contrôle numéro de version...".
            RETURN NO-APPLY.
        END.

        /* positionnement sur la version d'avant pour avoir les crc */
        IF filNumeroVersion:SCREEN-VALUE = "" THEN RETURN.
    
        IF NUM-ENTRIES(filNumeroVersion:SCREEN-VALUE,".") <> 3 THEN DO:
            MESSAGE "Numéro de version incorrect."
                + CHR(10) + "Le format doit-être nn.nn.nn"
                VIEW-AS ALERT-BOX ERROR
                TITLE "Contrôle numéro de version...".
            RETURN NO-APPLY.
        END.
    
        cTempo = ""
            + string(integer(entry(1,filNumeroVersion:SCREEN-VALUE,".")),"99")
            + string(integer(entry(2,filNumeroVersion:SCREEN-VALUE,".")),"99")
            + string(integer(entry(3,filNumeroVersion:SCREEN-VALUE,".")),"99")
            + "00"
            .
        iOrdreVersion = INTEGER(cTEmpo).
        FIND LAST   rversions NO-LOCK
            WHERE   rversions.iordre < iOrdreVersion
            USE-INDEX ixVersions02
            NO-ERROR.
        IF AVAILABLE(rversions) THEN DO:
            MESSAGE "Version précédente trouvée : " + rversions.cNumeroVersion
                VIEW-AS ALERT-BOX INFORMATION 
                TITLE "Confirmation numéro de version..."
                .
            
            /* remplissage automatique des CRC de la version précédente */
            filsadb:SCREEN-VALUE = STRING(rversions.iCRCSadb).
            filinter:SCREEN-VALUE = STRING(rversions.iCRCInter).
            filCompta:SCREEN-VALUE = STRING(rversions.iCRCCompta).
            filTransfert:SCREEN-VALUE = STRING(rversions.iCRCTransfert).
            filcadb:SCREEN-VALUE = STRING(rversions.iCRCcadb).
            filladb:SCREEN-VALUE = STRING(rversions.iCRCladb).
            filwadb:SCREEN-VALUE = STRING(rversions.iCRCwadb).
            fillCompta:SCREEN-VALUE = STRING(rversions.iCRClCompta).
            fillTrans:SCREEN-VALUE = STRING(rversions.iCRClTrans).
            fildwh:SCREEN-VALUE = STRING(rversions.iCRCdwh).
        END.
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frmBoutons
&Scoped-define SELF-NAME filRecherche
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filRecherche winVersions
ON RETURN OF filRecherche IN FRAME frmBoutons /* Recherche Moulinette */
DO:
  APPLY "CHOOSE" TO BtnCodeSuivant.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frmMoulinette
&Scoped-define SELF-NAME filRepertoireMoulinette
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filRepertoireMoulinette winVersions
ON ENTRY OF filRepertoireMoulinette IN FRAME frmMoulinette
DO:
  DEFINE BUFFER bMoulinettes FOR moulinettes.

  DEFINE VARIABLE cTempo AS CHARACTER NO-UNDO.

  IF SELF:SCREEN-VALUE = "" THEN DO:
    FOR EACH    bmoulinettes    NO-LOCK
        WHERE   bmoulinettes.cNumeroVersion = versions.cNumeroVersion
        BY      bmoulinettes.cRepertoireMoulinette
        :
        cTempo = bmoulinettes.cRepertoireMoulinette.
    END.
    SELF:SCREEN-VALUE = cTempo.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frmVersion
&Scoped-define SELF-NAME filSadb
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filSadb winVersions
ON LEAVE OF filSadb IN FRAME frmVersion
DO:
  IF SELF:SCREEN-VALUE = "" THEN DO:
      SELF:SCREEN-VALUE = STRING(rversions.iCRCSadb).
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filTransfert
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filTransfert winVersions
ON LEAVE OF filTransfert IN FRAME frmVersion
DO:
  
    IF SELF:SCREEN-VALUE = "" THEN DO:
        SELF:SCREEN-VALUE = STRING(rversions.iCRCtransfert).
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filWadb
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filWadb winVersions
ON LEAVE OF filWadb IN FRAME frmVersion
DO:
  
    IF SELF:SCREEN-VALUE = "" THEN DO:
        SELF:SCREEN-VALUE = STRING(rversions.iCRCwadb).
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_ModifierMoulinette
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_ModifierMoulinette winVersions
ON CHOOSE OF MENU-ITEM m_ModifierMoulinette /* Modifier */
DO:
  APPLY "CHOOSE" TO btnModifierMoulinette IN FRAME frmFond.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_ModifierVersion
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_ModifierVersion winVersions
ON CHOOSE OF MENU-ITEM m_ModifierVersion /* Modifier */
DO:
  
    APPLY "CHOOSE" TO btnModifierversion IN FRAME frmFond.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_OuvrirMoulinette
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_OuvrirMoulinette winVersions
ON CHOOSE OF MENU-ITEM m_OuvrirMoulinette /* Ouvrir */
DO:
  DEFINE VARIABLE cFichier AS CHARACTER NO-UNDO.

  cFichier = reseau + "gi\maj\delta\" 
      + moulinettes.cRepertoiremoulinette + "\" 
      + moulinettes.cNomMoulinette
      .

  OS-COMMAND SILENT VALUE(cFichier).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Préférences
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Préférences winVersions
ON CHOOSE OF MENU-ITEM m_Préférences /* Préférences */
DO:
    winVersions:SENSITIVE = FALSE.
    RUN VALUE(gcRepertoireExecution + "preferences.w").
    winVersions:SENSITIVE = TRUE.
    RUN ChargePreferences.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frmBoutons
&Scoped-define SELF-NAME tglHebdo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglHebdo winVersions
ON VALUE-CHANGED OF tglHebdo IN FRAME frmBoutons /* Génération automatique de la version hebdomadaire */
DO:
    /* gestion du fichier de version hebdo pour les autres programmes */
    IF SELF:CHECKED THEN DO:
        OS-DELETE VALUE(cFichierHebdo).
    END.
    ELSE DO:
        OUTPUT TO VALUE(cFichierHebdo).
        OUTPUT CLOSE.
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frmFond
&Scoped-define BROWSE-NAME brwMoulinettes
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK winVersions 


/* ***************************  Main Block  *************************** */

/* Set CURRENT-WINDOW: this will parent dialog-boxes and frames.        */
ASSIGN CURRENT-WINDOW                = {&WINDOW-NAME} 
       THIS-PROCEDURE:CURRENT-WINDOW = {&WINDOW-NAME}.

/* The CLOSE event can be used from inside or outside the procedure to  */
/* terminate it.                                                        */
ON CLOSE OF THIS-PROCEDURE 
   RUN disable_UI.

{includes\i_clavier.i}

    ON 'F2':U ANYWHERE 
    DO:
        IF (cModeAffichageEnCours = "AM" OR cModeAffichageEnCours = "MM") THEN APPLY "Choose" TO btnValiderMoulinette IN FRAME frmFond.
    END.

    ON 'F4':U ANYWHERE 
    DO:
        IF (cModeAffichageEnCours = "AM" OR cModeAffichageEnCours = "MM") THEN APPLY "Choose" TO btnAbandonnerMoulinette IN FRAME frmFond.
    END.

    ON 'F3':U ANYWHERE 
    DO:
       IF (cModeAffichageEnCours = "VV" OR cModeAffichageEnCours = "VM" OR cModeAffichageEnCours = "") THEN APPLY "Choose" TO btnModifierMoulinette IN FRAME frmFond.
    END.

    ON 'F5':U ANYWHERE 
    DO:
        IF (cModeAffichageEnCours = "VV" OR cModeAffichageEnCours = "VM" OR cModeAffichageEnCours = "") THEN APPLY "Choose" TO btnAjouterMoulinette IN FRAME frmFond.
    END.

/* Best default for GUI applications is...                              */
PAUSE 0 BEFORE-HIDE.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO /*ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK*/:
  RUN enable_UI.
  RUN Initialisation.
  WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE AffecteToggle winVersions 
PROCEDURE AffecteToggle :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER hToggle-in AS WIDGET-HANDLE.
DEFINE INPUT PARAMETER hColonne-in AS WIDGET-HANDLE.

    hToggle-in:CHECKED = (hColonne-in:SCREEN-VALUE = "OUI").

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE AffecteToggle2 winVersions 
PROCEDURE AffecteToggle2 :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER hToggle-in AS WIDGET-HANDLE.
DEFINE INPUT PARAMETER hColonne-in AS WIDGET-HANDLE.

    hToggle-in:CHECKED = (hColonne-in:CHECKED).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE AffecteZone winVersions 
PROCEDURE AffecteZone :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

DEFINE INPUT PARAMETER hZoneSaisie-in AS WIDGET-HANDLE.
DEFINE INPUT PARAMETER hColonne-in AS WIDGET-HANDLE.

    DEFINE VARIABLE cValeur AS CHARACTER NO-UNDO.

    cValeur = (IF hColonne-in:SCREEN-VALUE <> ? THEN hColonne-in:SCREEN-VALUE ELSE "").

    hZoneSaisie-in:SCREEN-VALUE = cValeur.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ChargePreferences winVersions 
PROCEDURE ChargePreferences :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
      DO WITH FRAME frmBoutons:
          tglHebdo:CHECKED = (IF gDonnePreference("PREF-HEBDOAUTO") = "OUI" THEN TRUE ELSE FALSE).
      END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ChargeVersions winVersions 
PROCEDURE ChargeVersions :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    DEFINE VARIABLE cFichier AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cFichierSortie AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cLigne AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lErreur AS LOGICAL.

    /* Ouverture du fichier en entrée */
    cFichier = gcRepertoireRessourcesPrivees + "versions".
    INPUT STREAM gstrEntree FROM VALUE(cFichier).

    DELETE FROM versions.

    REPEAT:
        IMPORT STREAM gstrEntree UNFORMATTED cLigne.
        IF cLigne = "" THEN NEXT.
        CREATE versions.
        ASSIGN
            versions.cNumeroVersion = ENTRY(1,cLigne,";")
            versions.dDateVersion = date(ENTRY(2,cLigne,";"))
            versions.iCrcSadb = integer(ENTRY(3,cLigne,";"))
            versions.iCrcInter = integer(ENTRY(4,cLigne,";"))
            versions.iCrcCompta = integer(ENTRY(5,cLigne,";"))
            versions.iCrcTransfert = integer(ENTRY(6,cLigne,";"))
            versions.iCrcCadb = integer(ENTRY(7,cLigne,";"))
            versions.iCrcLadb = integer(ENTRY(8,cLigne,";"))
            versions.iCrcWAdb = integer(ENTRY(9,cLigne,";"))
            versions.iCrcLCompta = integer(ENTRY(10,cLigne,";"))
            versions.iCrcLtrans = integer(ENTRY(11,cLigne,";"))
            versions.lGidev = (ENTRY(12,cLigne,";") = "Oui")
            versions.lGI = (ENTRY(13,cLigne,";") = "Oui")
            versions.lGiCli = (ENTRY(14,cLigne,";") = "Oui")
            versions.iOrdre = integer(ENTRY(15,cLigne,";"))
            versions.cRepertoireVersion = ENTRY(16,cLigne,";")
            versions.iCrcDwh = integer(ENTRY(17,cLigne,";"))
            .
    END.
    INPUT STREAM gstrEntree CLOSE.

    /* Ouverture du fichier en entrée */
    cFichier = gcRepertoireRessourcesPrivees + "moulinettes".
    INPUT STREAM gstrEntree FROM VALUE(cFichier).
    cFichierSortie = gcRepertoireRessourcesPrivees + "moulinettes.err".
    OUTPUT STREAM gstrSortie TO VALUE(cFichierSortie).

    DELETE FROM moulinettes.
    lErreur = FALSE.
    REPEAT:
        IMPORT STREAM gstrEntree UNFORMATTED cLigne.
        IF cLigne = "" THEN NEXT.
        IF NUM-ENTRIES(cLigne,";") <> 13 THEN DO:
            PUT STREAM gstrSortie UNFORMATTED cLigne SKIP.
            lErreur = TRUE.
            NEXT.
        END.
        CREATE moulinettes.
        ASSIGN
            moulinettes.cNomMoulinette = ENTRY(1,cLigne,";")
            moulinettes.cLibelleMoulinette = REPLACE(ENTRY(2,cLigne,";"),"%s",CHR(10))
            moulinettes.cRepertoireMoulinette = (ENTRY(3,cLigne,";"))
            moulinettes.cNumeroVersion = (ENTRY(4,cLigne,";"))
            moulinettes.lURef = (ENTRY(5,cLigne,";") = "1")
            moulinettes.lUVid = (ENTRY(6,cLigne,";") = "1")
            moulinettes.lHRef = (ENTRY(7,cLigne,";") = "1")
            moulinettes.lHVid = (ENTRY(8,cLigne,";") = "1")
            moulinettes.cAuteurMoulinette = (ENTRY(9,cLigne,";"))
            moulinettes.iNumero = INTEGER(ENTRY(10,cLigne,";"))
            moulinettes.lPme = (ENTRY(11,cLigne,";") = "1")
            moulinettes.lGestion = (ENTRY(12,cLigne,";") = "1")
            moulinettes.lDernier = (ENTRY(13,cLigne,";") = "1")
            .
    END.
    INPUT STREAM gstrEntree CLOSE.
    OUTPUT STREAM gstrSortie CLOSE.
    
    IF lErreur THEN DO:
        MESSAGE "Importation terminée, mais il y a eu des erreurs..."
            VIEW-AS ALERT-BOX INFORMATION.
    END.
    ELSE DO:
        MESSAGE "Importation terminée."
            VIEW-AS ALERT-BOX INFORMATION.
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI winVersions  _DEFAULT-DISABLE
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
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(winVersions)
  THEN DELETE WIDGET winVersions.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI winVersions  _DEFAULT-ENABLE
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
  DISPLAY tglHebdo filRecherche filInfos 
      WITH FRAME frmBoutons IN WINDOW winVersions.
  ENABLE btnChargement RECT-1 RECT-2 RECT-3 btnQuitter btnRafraichir 
         btnFichierVersion btnListe btnDetail btnMajListe tglHebdo filRecherche 
         btnCodePrecedent btnCodeSuivant filInfos 
      WITH FRAME frmBoutons IN WINDOW winVersions.
  {&OPEN-BROWSERS-IN-QUERY-frmBoutons}
  ENABLE brwVersions btnAjouterVersion btnValiderVersion btnModifierVersion 
         btnAbandonnerVersion btnSupprimerVersion brwMoulinettes 
         btnAjouterMoulinette btnValiderMoulinette btnModifierMoulinette 
         btnAbandonnerMoulinette btnSupprimerMoulinette 
      WITH FRAME frmFond IN WINDOW winVersions.
  {&OPEN-BROWSERS-IN-QUERY-frmFond}
  DISPLAY edtInformation 
      WITH FRAME frmInformation IN WINDOW winVersions.
  ENABLE IMAGE-1 edtInformation 
      WITH FRAME frmInformation IN WINDOW winVersions.
  VIEW FRAME frmInformation IN WINDOW winVersions.
  {&OPEN-BROWSERS-IN-QUERY-frmInformation}
  DISPLAY filNumeroVersion filDate filSadb filInter filCompta filTransfert 
          filCadb filLadb filWadb filLCompta filLtrans filDwh tglDev tglTest 
          tglClient filRepertoire edtCommentaire edtDeltas tglExclusion 
      WITH FRAME frmVersion IN WINDOW winVersions.
  ENABLE filNumeroVersion filDate filSadb filInter filCompta filTransfert 
         filCadb filLadb filWadb filLCompta filLtrans filDwh tglDev tglTest 
         tglClient filRepertoire edtCommentaire edtDeltas tglExclusion 
      WITH FRAME frmVersion IN WINDOW winVersions.
  {&OPEN-BROWSERS-IN-QUERY-frmVersion}
  DISPLAY filRepertoireMoulinette filNomMoulinette filAuteur tglGestion tglPme 
          tglhref tglhvid tgluref tgluvid tgldernier filLibelleMoulinette 
      WITH FRAME frmMoulinette IN WINDOW winVersions.
  ENABLE filRepertoireMoulinette filNomMoulinette filAuteur tglGestion tglPme 
         tglhref tglhvid tgluref tgluvid tgldernier filLibelleMoulinette 
      WITH FRAME frmMoulinette IN WINDOW winVersions.
  {&OPEN-BROWSERS-IN-QUERY-frmMoulinette}
  VIEW winVersions.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Forcage winVersions 
PROCEDURE Forcage :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    IF gcRepertoireExecution MATCHES "*sources.dev*" THEN
        gcUtilisateur = gcUtilisateur + ".DEV".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE GenereFichierVersion winVersions 
PROCEDURE GenereFichierVersion :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE BUFFER VersionPrecedente FOR versions.
    DEFINE BUFFER VersionEnCours FOR versions.
    DEFINE BUFFER bMoulinettes FOR Moulinettes.

    DEFINE VARIABLE cNomVersion AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cFichier AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cParamMontage AS CHARACTER NO-UNDO.

    /* ------
    /* Positionnement sur la version en cours */
    FIND FIRST  VersionEnCours  NO-LOCK
        WHERE   VersionEnCours.cNumeroVersion = cVersionEnCours
        NO-ERROR.
    IF NOT(AVAILABLE(VersionEnCours)) THEN DO:
        MESSAGE "Version en cours '" + cVersionEnCours + "' introuvable !!!"
            + CHR(10) 
            + "Abandon de la procédure."
            VIEW-AS ALERT-BOX ERROR
            TITLE "Génération fichier version..."
            .
        RETURN.
    END.

    /* Positionnement sur la version Prédédente */
    FIND LAST   VersionPrecedente  NO-LOCK
        WHERE   VersionPrecedente.iordre < VersionEnCours.iordre
        NO-ERROR.
    IF NOT(AVAILABLE(VersionPrecedente)) THEN DO:
        MESSAGE "Version Précédente à la version '" + cVersionEnCours + "' introuvable !!!"
            + CHR(10) 
            + "Abandon de la procédure."
            VIEW-AS ALERT-BOX ERROR
            TITLE "Génération fichier version..."
            .
        RETURN.
    END.

    /* Demande de confirmation */
    MESSAGE "Confirmez-vous la génération du fichier version :"
        + chr(10) + "'" + VersionPrecedente.cNumeroVersion + "' --> '" + VersionEnCours.cNumeroVersion + "'"
        VIEW-AS ALERT-BOX QUESTION BUTTON YES-NO
        TITLE "Génération fichier version..."
        UPDATE lReponseFichier AS LOGICAL
        .
    IF not(lReponseFichier) THEN RETURN.
    
    cParamMontage = "AUTO-MUET-VISU"
    + "," + STRING(VersionPrecedente.iordre)
    + "," + STRING(VersionEnCours.iordre)
    + "," + ""
    + "," + "version"
    .

    -----*/

    cParamMontage = ""
        + "," + ""
        + "," + ""
        + "," + ""
        + "," + ""
        .
    RUN VALUE(gcRepertoireExecution + "montage.w") (INPUT cParamMontage).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE GereBoutons winVersions 
PROCEDURE GereBoutons :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/


DEFINE INPUT PARAMETER cVisible-in AS CHARACTER.
DEFINE INPUT PARAMETER cSensitive-in AS CHARACTER.
    
    DO WITH FRAME frmBoutons:
        btnQuitter:VISIBLE = (cVisible-in MATCHES "*Q*").
        btnRafraichir:VISIBLE = (cVisible-in MATCHES "*R*").
        btnFichierVersion:VISIBLE = (cVisible-in MATCHES "*R*").
        btnListe:VISIBLE = (cVisible-in MATCHES "*L*").
        btnDetail:VISIBLE = (cVisible-in MATCHES "*D*").
        btnMajListe:VISIBLE = (cVisible-in MATCHES "*M*").
    
        btnQuitter:SENSITIVE = (cSensitive-in MATCHES "*Q*").
        btnRafraichir:SENSITIVE = (cSensitive-in MATCHES "*R*").
        btnFichierVersion:SENSITIVE = (cSensitive-in MATCHES "*R*").
        btnListe:SENSITIVE = (cSensitive-in MATCHES "*L*").
        btnDetail:SENSITIVE = (cSensitive-in MATCHES "*D*").
        btnMajListe:SENSITIVE = (cSensitive-in MATCHES "*M*").
    
        /* gestion des restrictions */
        IF NOT(lModificationsAutorisees) THEN DO:
            btnMajListe:SENSITIVE = FALSE.
        END.

    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE GereBoutonsMoulinette winVersions 
PROCEDURE GereBoutonsMoulinette :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

DEFINE INPUT PARAMETER cVisible-in AS CHARACTER.
DEFINE INPUT PARAMETER cSensitive-in AS CHARACTER.
    
    DO WITH FRAME frmFond:
        btnAjouterMoulinette:VISIBLE = (cVisible-in MATCHES "*A*").
        btnSupprimerMoulinette:VISIBLE = (cVisible-in MATCHES "*S*").
        btnModifierMoulinette:VISIBLE = (cVisible-in MATCHES "*M*").
        btnValiderMoulinette:VISIBLE = (cVisible-in MATCHES "*V*").
        btnAbandonnerMoulinette:VISIBLE = (cVisible-in MATCHES "*X*").
    
        btnAjouterMoulinette:SENSITIVE = (cSensitive-in MATCHES "*A*").
        btnSupprimerMoulinette:SENSITIVE = (cSensitive-in MATCHES "*S*").
        btnModifierMoulinette:SENSITIVE = (cSensitive-in MATCHES "*M*").
        btnValiderMoulinette:SENSITIVE = (cSensitive-in MATCHES "*V*").
        btnAbandonnerMoulinette:SENSITIVE = (cSensitive-in MATCHES "*X*").
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE GereBoutonsVersion winVersions 
PROCEDURE GereBoutonsVersion :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

DEFINE INPUT PARAMETER cVisible-in AS CHARACTER.
DEFINE INPUT PARAMETER cSensitive-in AS CHARACTER.
    
    DO WITH FRAME frmFond:
        btnAjouterVersion:VISIBLE = (cVisible-in MATCHES "*A*").
        btnSupprimerVersion:VISIBLE = (cVisible-in MATCHES "*S*").
        btnModifierVersion:VISIBLE = (cVisible-in MATCHES "*M*").
        btnValiderVersion:VISIBLE = (cVisible-in MATCHES "*V*").
        btnAbandonnerVersion:VISIBLE = (cVisible-in MATCHES "*X*").
    
        btnAjouterVersion:SENSITIVE = (cSensitive-in MATCHES "*A*").
        btnSupprimerVersion:SENSITIVE = (cSensitive-in MATCHES "*S*").
        btnModifierVersion:SENSITIVE = (cSensitive-in MATCHES "*M*").
        btnValiderVersion:SENSITIVE = (cSensitive-in MATCHES "*V*").
        btnAbandonnerVersion:SENSITIVE = (cSensitive-in MATCHES "*X*").
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE GereBrowse winVersions 
PROCEDURE GereBrowse :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

DEFINE INPUT PARAMETER hBrowse-in AS WIDGET-HANDLE.
DEFINE INPUT PARAMETER cMode-in AS CHARACTER.

    DEFINE VARIABLE lSensitive AS LOGICAL NO-UNDO.

    lSensitive = (cMode-in = "ON").

    hBrowse-in:SENSITIVE = lSensitive.

    hBrowse-in:BGCOLOR = (IF lSensitive THEN 15 ELSE 8).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE GereFrame winVersions 
PROCEDURE GereFrame :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
/*DEFINE INPUT PARAMETER hFrame-in AS WIDGET-HANDLE.*/
DEFINE INPUT PARAMETER cFrame-in AS CHARACTER.
DEFINE INPUT PARAMETER cMode-in AS CHARACTER.

    DEFINE VARIABLE lSensitive AS LOGICAL NO-UNDO.

    lSensitive = (cMode-in = "ON").

    IF cFrame-in = "V" THEN DO WITH FRAME frmVersion.
        IF lSensitive then
            ENABLE ALL WITH FRAME frmVersion.
        ELSE
            DISABLE ALL EXCEPT edtCommentaire edtDeltas WITH FRAME frmVersion.
        edtCommentaire:READ-ONLY = NOT(lSensitive).
        edtDeltas:READ-ONLY = NOT(lSensitive).

        /*hFrame-in:SENSITIVE = lSensitive.*/
         FRAME frmVersion:BGCOLOR = (IF lSensitive THEN {&CouleurSaisie} ELSE iCouleurInitiale).
    END.

    IF cFrame-in = "M" THEN DO WITH FRAME frmMoulinette.
        IF lSensitive then
            ENABLE ALL WITH FRAME frmMoulinette.
        ELSE
            DISABLE ALL WITH FRAME frmMoulinette.

        /*hFrame-in:SENSITIVE = lSensitive.*/
         FRAME frmMoulinette:BGCOLOR = (IF lSensitive THEN {&CouleurSaisie} ELSE iCouleurInitiale).
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ImpressionDetail winVersions 
PROCEDURE ImpressionDetail :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    DEFINE VARIABLE cFichierRemplacements AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cFichierModele AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cFichierVersion AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lRetour AS LOGICAL NO-UNDO INIT TRUE.
    DEFINE VARIABLE cTempo AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cLigneTableau AS CHARACTER NO-UNDO.

    DEFINE BUFFER bVersions FOR versions.
    DEFINE BUFFER bMoulinettes FOR moulinettes.

    /* Positionnement sur la version en cours */
    FIND FIRST  bversions   NO-LOCK
        WHERE   bversions.iOrdre = versions.iOrdre
        NO-ERROR.
    IF NOT(AVAILABLE(bversions)) THEN RETURN.

    /* génération du fichier des remplacements */
    cFichierRemplacements = "d:\tmp\remplacements.lst".
    OUTPUT TO VALUE(cFichierRemplacements).

    cTempo = "" 
        + (IF bversions.lgidev THEN "Gidev" ELSE "-")
        + " / " + (IF bversions.lgi THEN "Gi" ELSE "-")
        + " / " + (IF bversions.lgicli THEN "Gicli" ELSE "-").
    
    PUT UNFORMATTED "%version%#" + bversions.cNumeroVersion SKIP.
    PUT UNFORMATTED "%date%#" + string(bversions.dDateVersion) SKIP.
    PUT UNFORMATTED "%repv%#" + bversions.cRepertoireVersion SKIP.
    PUT UNFORMATTED "%type%#" + cTempo SKIP.
    PUT UNFORMATTED "%sadb%#" + string(bversions.icrcsadb) SKIP.
    PUT UNFORMATTED "%inter%#" + string(bversions.icrcinter) SKIP.
    PUT UNFORMATTED "%compta%#" + string(bversions.icrccompta) SKIP.
    PUT UNFORMATTED "%transfert%#" + string(bversions.icrctransfert) SKIP.
    PUT UNFORMATTED "%cadb%#" + string(bversions.icrccadb) SKIP.
    PUT UNFORMATTED "%ladb%#" + string(bversions.icrcladb) SKIP.
    PUT UNFORMATTED "%wadb%#" + string(bversions.icrcwadb) SKIP.
    PUT UNFORMATTED "%lcompta%#" + string(bversions.icrclcompta) SKIP.
    PUT UNFORMATTED "%ltrans%#" + string(bversions.icrcltrans) SKIP.
    PUT UNFORMATTED "%dwh%#" + string(bversions.icrcdwh) SKIP.
    PUT UNFORMATTED "%deltas%#" + FormatteChaine(bversions.cFiller2) SKIP.
    PUT UNFORMATTED "%commentaires%#" + FormatteChaine(bversions.cFiller1) SKIP.

    cTempo = "".
    cLigneTableau = "%repm%%t%nom%%t%auteur%%t%libelle%".
    PUT UNFORMATTED "%repm%#" + "Répert." SKIP.
    PUT UNFORMATTED "%nom%#" + "Nom" SKIP.
    PUT UNFORMATTED "%auteur%#" + "Auteur" SKIP.
    /* Ajout d'un saut de ligne manuel et d'une ligne de tableau */
    cTempo = "Libellé%s" + cLigneTableau.
    PUT UNFORMATTED "%libelle%#" + FormatteChaine(cTempo) SKIP.

    FOR EACH    bmoulinettes NO-LOCK
        WHERE   bmoulinettes.cNumeroVersion = bversions.cNumeroVersion
        BY bmoulinettes.cRepertoireMoulinette
        :
        cTempo = ""
            + "Passée sur : "
            + (IF bmoulinettes.lUvid THEN "UVid" ELSE "-")
            + " / " + (IF bmoulinettes.lUref THEN "URef" ELSE "-")
            + " / " + (IF bmoulinettes.lHvid THEN "HVid" ELSE "-")
            + " / " + (IF bmoulinettes.lHRef THEN "HRef" ELSE "-")
            + "%s%t%t%t" 
            + (IF bmoulinettes.cLibelleMoulinette <> "" THEN bmoulinettes.cLibelleMoulinette ELSE "Voir fiche...")
            /* Ajout d'un saut de ligne manuel et d'une ligne de tableau */
            + "%s%s" + cLigneTableau
            .
          PUT UNFORMATTED "%repm%#" + FormatteChaine(bmoulinettes.cRepertoireMoulinette) SKIP.
          PUT UNFORMATTED "%nom%#" + FormatteChaine(bmoulinettes.cNomMoulinette) SKIP.
          PUT UNFORMATTED "%auteur%#" + FormatteChaine(bmoulinettes.cAuteurMoulinette) SKIP.
          PUT UNFORMATTED "%libelle%#" + FormatteChaine(cTempo) SKIP.
    END.

    /* suppression de la dernière ligne de detail ajoutée */
    PUT UNFORMATTED "%repm%#" + "" SKIP.
    PUT UNFORMATTED "%nom%#" + "" SKIP.
    PUT UNFORMATTED "%auteur%#" + "" SKIP.
    PUT UNFORMATTED "%libelle%#" + "" SKIP.

    /* Remplacement des tabulations et sauts de ligne manuels */
    PUT UNFORMATTED "%t#^t" SKIP.
    PUT UNFORMATTED "%s#^l" SKIP.

    OUTPUT CLOSE.

    cFichierModele = reseau + "dev\outils\commdev\version_modele.doc".
    cFichierVersion = loc_tmp + "\version.doc".

    IF lRetour THEN lRetour = Word("OUVRIR","").
    IF lRetour THEN lRetour = Fusion(cFichierModele,cFichierVersion,cFichierRemplacements).
    IF lRetour THEN lRetour = Word("FENETRE","NORMAL").
    IF lRetour THEN lRetour = Word("VISIBLE","").
    IF lRetour THEN lRetour = Word("EXECUTER","MiseAuPremierPlan").

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ImpressionListe winVersions 
PROCEDURE ImpressionListe :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

DEFINE VARIABLE cLigne AS CHARACTER NO-UNDO.

    DEFINE BUFFER bversions FOR versions.

    /* Début de l'édition */
    RUN HTML_OuvreFichier("").
    cLigne = "Liste des versions de l'application MaGI".
    RUN HTML_TitreEdition(cLigne).
    
    RUN HTML_ChargeFormatCellule("E",0,"CF=gris,A=><,T=3").
    RUN HTML_ChargeFormatCellule("L",0,"A=><").
    
    /* Ecriture de l'entete pour le tableau des champs */
    cLigne = "" 
        + "Version"
        + devSeparateurEdition + "Répertoire"
        + devSeparateurEdition + "Date"
        + devSeparateurEdition + "Sadb"
        + devSeparateurEdition + "Inter"
        + devSeparateurEdition + "Compta"
        + devSeparateurEdition + "Transfert"
        + devSeparateurEdition + "Cadb"
        + devSeparateurEdition + "Ladb"
        + devSeparateurEdition + "Wadb"
        + devSeparateurEdition + "Lcompta"
        + devSeparateurEdition + "ltrans"
        + devSeparateurEdition + "Dwh"
        + devSeparateurEdition + "Dev"
        + devSeparateurEdition + "Test"
        + devSeparateurEdition + "Client"
        + devSeparateurEdition + "Exclue"
        + devSeparateurEdition + "Delta+"
        + devSeparateurEdition + "Commentaire(s)"
        .
    RUN HTML_DebutTableau(cLigne).
    
    /* Balayage de la table des champs */
    FOR EACH bversions
        BY bversions.iordre DESC
        :
        cLigne = "" 
            + TRIM(bversions.cNumeroVersion)
            + devSeparateurEdition + STRING(bversions.cRepertoireVersion)
            + devSeparateurEdition + STRING(bversions.dDateVersion,"99/99/9999")
            + devSeparateurEdition + STRING(bversions.iCrcSadb)
            + devSeparateurEdition + STRING(bversions.iCrcInter)
            + devSeparateurEdition + STRING(bversions.iCrcCompta)
            + devSeparateurEdition + STRING(bversions.iCrcTransfert)
            + devSeparateurEdition + STRING(bversions.iCrcCadb)
            + devSeparateurEdition + STRING(bversions.iCrcLadb)
            + devSeparateurEdition + STRING(bversions.iCrcWadb)
            + devSeparateurEdition + STRING(bversions.iCrcLcompta)
            + devSeparateurEdition + STRING(bversions.iCrclTrans)
            + devSeparateurEdition + STRING(bversions.iCrcDwh)
            + devSeparateurEdition + (IF bversions.lGidev THEN "Oui" ELSE "Non")
            + devSeparateurEdition + (IF bversions.lGI THEN "Oui" ELSE "Non")
            + devSeparateurEdition + (IF bversions.lGiCli THEN "Oui" ELSE "Non")
            + devSeparateurEdition + (IF bversions.lExclusion THEN "Oui" ELSE "Non")
            /*
            + devSeparateurEdition + (IF bversions.cFiller2 <> "" THEN "Oui" ELSE "Non")
            + devSeparateurEdition + (IF bversions.cFiller1 <> "" THEN "Oui" ELSE "Non")
            */
            + devSeparateurEdition + bversions.cFiller2
            + devSeparateurEdition + bversions.cFiller1
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Initialisation winVersions 
PROCEDURE Initialisation :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE cBoutonsActifs AS CHARACTER NO-UNDO.

    cFichierHebdo = Reseau + "dev\intf\BloqueVersionHebdo".    
    
    RUN gGereUtilisateurs.
    lModificationsAutorisees = (gcGroupeUtilisateur = "DEV").

    RUN ChargePreferences.

    FRAME frmInformation:VISIBLE = FALSE.

  /* Gestion des images des boutons */
  DO WITH FRAME frmBoutons:
      btnQuitter:LOAD-IMAGE(gcRepertoireRessourcesPrivees + "sortie.ico").
      btnQuitter:LOAD-IMAGE-INSENSITIVE(gcRepertoireRessourcesPrivees + "sortie-off.ico").
      btnRafraichir:LOAD-IMAGE(gcRepertoireRessourcesPrivees + "raff.ico").
      btnRafraichir:LOAD-IMAGE-INSENSITIVE(gcRepertoireRessourcesPrivees + "raff-off.ico").
      btnFichierVersion:LOAD-IMAGE(gcRepertoireRessourcesPrivees + "vnnnnnn.ico").
      btnFichierVersion:LOAD-IMAGE-INSENSITIVE(gcRepertoireRessourcesPrivees + "vnnnnnn-off.ico").
      btnListe:LOAD-IMAGE(gcRepertoireRessourcesPrivees + "printL.ico").
      btnListe:LOAD-IMAGE-INSENSITIVE(gcRepertoireRessourcesPrivees + "printL-off.ico").
      btnDetail:LOAD-IMAGE(gcRepertoireRessourcesPrivees + "printD.ico").
      btnDetail:LOAD-IMAGE-INSENSITIVE(gcRepertoireRessourcesPrivees + "printD-off.ico").
      btnMajListe:LOAD-IMAGE(gcRepertoireRessourcesPrivees + "serveurs.ico").
      btnMajListe:LOAD-IMAGE-INSENSITIVE(gcRepertoireRessourcesPrivees + "serveurs-off.ico").
      filinfos:SCREEN-VALUE = "Utilisateur : " + gcUtilisateur 
          + " (" + gcGroupeUtilisateur + "/" + STRING(giNiveauUtilisateur) + ")"
          .
      /* gestion des options */
      tglHebdo:CHECKED = (IF SEARCH(cFichierHebdo) = ? THEN TRUE ELSE FALSE).
      tglHebdo:SENSITIVE = lModificationsAutorisees.

      /* Gestion du bouton de chargement initial des versions et moulinettes */
      btnChargement:VISIBLE = FALSE.
  END.

  
  iCouleurInitiale = FRAME frmfond:BGCOLOR.

  /* positionner et retailler les zones de saisie de la version */
  RUN retailleetpositionne.

  /* Gestion de l'état de la frame de saisie des versions */
  RUN GereFrame("v","OFF").

  /* Gestion de l'état de la frame de saisie des Moulinettes */
  RUN GereFrame("m","OFF").

  /* Rafraichir les zones de saisie avec la versions en cours */
  APPLY "VALUE-CHANGED" TO brwVersions IN FRAME frmfond.

  /* Rafraichir les zones de saisie avec la versions en cours */
  APPLY "VALUE-CHANGED" TO brwMoulinettes IN FRAME frmfond.

  cBoutonsActifs = (IF lModificationsAutorisees THEN "AMS" ELSE "").
  

  /* Gestion des boutons de saisie des versions */
  RUN GereBoutonsVersion("AMS",cBoutonsActifs).

  /* Gestion des boutons de saisie des versions */
  RUN GereBoutonsMoulinette("AMS",cBoutonsActifs).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MajFichierServeurs winVersions 
PROCEDURE MajFichierServeurs :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE cFichier AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cServeur AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cChemin AS CHARACTER NO-UNDO.
    DEFINE BUFFER bversions FOR versions.

    /* Ouverture du fichier en local */
        cFichier = loc_tmp + "\versions.lst".
        OUTPUT STREAM sSortie TO VALUE(cFichier).

    /* génération du fichier liste des version sur barbade et sur neptune */
    /* Format du fichier = Crcs des 5 bases + numéro physique de la version
     avec les bases dans l'ordre d'affichage */
    FOR EACH    bversions
        WHERE   SUBSTRING(STRING(bversions.iordre,"99999999"),5,4) = "0000"
        AND     not(bversions.lExclusion)
        BY bversions.iOrdre DESC
        :
        PUT STREAM sSortie UNFORMATTED 
            string(bversions.icrcSadb)
            + ";" + string(bversions.icrcinter)
            + ";" + string(bversions.icrccompta)
            + ";" + string(bversions.icrctransfert)
            + ";" + string(bversions.icrccadb)
            + ";" + quoter(bversions.cnumeroversion)
            SKIP.
    END.

    /* Fermeture du fichier de sortie */
    OUTPUT STREAM sSortie CLOSE.
    
    /* Copie du fichier sur barbade */
    afficheInformations("Copie sur barbade en cours...").
    OS-COMMAND SILENT VALUE(gcRepertoireRessourcesPrivees + "\scripts\ftpcopyVersions.bat barbade"). 

    /* Copie du fichier sur neptune */
    afficheInformations("Copie sur neptune2 en cours...").
    OS-COMMAND SILENT VALUE(gcRepertoireRessourcesPrivees + "\scripts\ftpcopyVersions.bat neptune2"). 
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE RetailleEtPositionne winVersions 
PROCEDURE RetailleEtPositionne :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DO WITH FRAME frmVersion:
        RUN TraiteZone(filNumeroVersion:HANDLE,Versions.cNumeroVersion:HANDLE IN BROWSE brwVersions,0).
        RUN TraiteZone(filDate:HANDLE,Versions.dDateVersion:HANDLE IN BROWSE brwVersions,0).
        RUN TraiteZone(filsadb:HANDLE,Versions.iCrcSadb:HANDLE IN BROWSE brwVersions,0).
        RUN TraiteZone(filInter:HANDLE,Versions.iCrcInter:HANDLE IN BROWSE brwVersions,0).
        RUN TraiteZone(filCompta:HANDLE,Versions.iCrcCompta:HANDLE IN BROWSE brwVersions,0).
        RUN TraiteZone(filTransfert:HANDLE,Versions.iCrcTransfert:HANDLE IN BROWSE brwVersions,0).
        RUN TraiteZone(filCadb:HANDLE,Versions.iCrcCadb:HANDLE IN BROWSE brwVersions,0).
        RUN TraiteZone(filLadb:HANDLE,Versions.iCrcLadb:HANDLE IN BROWSE brwVersions,0).
        RUN TraiteZone(filWadb:HANDLE,Versions.iCrcWadb:HANDLE IN BROWSE brwVersions,0).
        RUN TraiteZone(fillcompta:HANDLE,Versions.iCrcLcompta:HANDLE IN BROWSE brwVersions,0).
        RUN TraiteZone(filLtrans:HANDLE,Versions.iCrcLtrans:HANDLE IN BROWSE brwVersions,0).
        RUN TraiteZone(filDwh:HANDLE,Versions.iCrcDwh:HANDLE IN BROWSE brwVersions,0).
        RUN TraiteZone(filrepertoire:HANDLE,Versions.cRepertoireVersion:HANDLE IN BROWSE brwVersions,0).

        RUN TraiteToggle(tglDev:HANDLE,Versions.lGidev:HANDLE IN BROWSE brwVersions).
        RUN TraiteToggle(tglTest:HANDLE,Versions.lGI:HANDLE IN BROWSE brwVersions).
        RUN TraiteToggle(tglClient:HANDLE,Versions.lGicli:HANDLE IN BROWSE brwVersions).
    END.

    DO WITH FRAME frmMoulinette:
        RUN TraiteZone(filNomMoulinette:HANDLE,Moulinettes.cNomMoulinette:HANDLE IN BROWSE brwMoulinettes,0).
        RUN TraiteZone(filRepertoireMoulinette:HANDLE,Moulinettes.cRepertoireMoulinette:HANDLE IN BROWSE brwMoulinettes,0).
        RUN TraiteZone(filAuteur:HANDLE,Moulinettes.cAuteurMoulinette:HANDLE IN BROWSE brwMoulinettes,0).
        RUN TraiteZone(filLibelleMoulinette:HANDLE,Moulinettes.cLibelleMoulinette :HANDLE IN BROWSE brwMoulinettes,100).

        RUN TraiteToggle(tglGestion:HANDLE,Moulinettes.lGestion:HANDLE IN BROWSE brwMoulinettes).
        RUN TraiteToggle(tglPme:HANDLE,Moulinettes.lPME:HANDLE IN BROWSE brwMoulinettes).
        RUN TraiteToggle(tglhref:HANDLE,Moulinettes.lHREF:HANDLE IN BROWSE brwMoulinettes).
        RUN TraiteToggle(tglhvid:HANDLE,Moulinettes.lHVid:HANDLE IN BROWSE brwMoulinettes).
        RUN TraiteToggle(tgluref :HANDLE,Moulinettes.lURef:HANDLE IN BROWSE brwMoulinettes).
        RUN TraiteToggle(tgluvid:HANDLE,Moulinettes.lUVid:HANDLE IN BROWSE brwMoulinettes).
        RUN TraiteToggle(tgldernier:HANDLE,Moulinettes.lDernier:HANDLE IN BROWSE brwMoulinettes).
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE SuppressionMoulinette winVersions 
PROCEDURE SuppressionMoulinette :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

DEFINE OUTPUT PARAMETER lRetour-ou AS LOGICAL NO-UNDO INIT FALSE.

    DEFINE VARIABLE lErreur AS LOGICAL NO-UNDO INIT FALSE.
    DEFINE VARIABLE cErreur AS CHARACTER NO-UNDO INIT "".
    DEFINE VARIABLE lAbandon AS LOGICAL NO-UNDO INIT FALSE.
    DEFINE VARIABLE riMoulinettes AS ROWID NO-UNDO.

    DEFINE BUFFER bmoulinettes FOR moulinettes.

    /* DEmande de confirmation */
    MESSAGE "Confirmez-vous la suppression de la Moulinette : " + moulinettes.cNomMoulinette
        VIEW-AS ALERT-BOX QUESTION BUTTON YES-NO
        TITLE "Confirmation suppression de moulinette..."
        UPDATE lreponse_suppression AS LOGICAL.
    IF NOT(lreponse_suppression) THEN RETURN.

    /* controle préliminaires */
    IF NOT(AVAILABLE(moulinettes)) THEN DO:
        lErreur = TRUE.
        lAbandon = TRUE.
        cErreur = cErreur 
                + CHR(10) + "- l'enregistrement de la table 'moulinettes' est indisponible".
                .
    END.

    IF not(lAbandon) THEN DO:
    END.

    /* gestion des erreurs */
    IF lErreur THEN DO:
        cErreur = "Erreur(s) lors de la suppression de la moulinette en cours : " + cErreur.
        MESSAGE cErreur
            VIEW-AS ALERT-BOX ERROR
            TITLE "Contrôle de suppression..."
            .
        RETURN.
    END.

    /* suppression dans la base */
    FIND CURRENT moulinettes EXCLUSIVE-LOCK NO-ERROR.
    IF NOT(AVAILABLE(moulinettes)) THEN DO:
        cErreur = "Impossible de vérouiller l'enregistrement de 'moulinettes' !"
            + CHR(10) + "Suppression impossible !!".
        MESSAGE cErreur
            VIEW-AS ALERT-BOX ERROR
            TITLE "Suppression de moulinette..."
            .
        RETURN.
    END.

    DELETE moulinettes.

    /* mise à jour de la liste */
    {&OPEN-QUERY-brwMoulinettes}


    /* gestion du code retour */
    lRetour-ou = TRUE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE SuppressionVersion winVersions 
PROCEDURE SuppressionVersion :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

DEFINE OUTPUT PARAMETER lRetour-ou AS LOGICAL NO-UNDO INIT FALSE.

    DEFINE VARIABLE lErreur AS LOGICAL NO-UNDO INIT FALSE.
    DEFINE VARIABLE cErreur AS CHARACTER NO-UNDO INIT "".
    DEFINE VARIABLE lAbandon AS LOGICAL NO-UNDO INIT FALSE.
    DEFINE VARIABLE riVersions AS ROWID NO-UNDO.

    DEFINE BUFFER bmoulinettes FOR moulinettes.

    /* DEmande de confirmation */
    MESSAGE "Confirmez-vous la suppression de la version : " + versions.cNumeroVersion
        VIEW-AS ALERT-BOX QUESTION BUTTON YES-NO
        TITLE "Confirmation suppression de version..."
        UPDATE lreponse_suppression AS LOGICAL.
    IF NOT(lreponse_suppression) THEN RETURN.

    /* controle préliminaires */
    IF NOT(AVAILABLE(versions)) THEN DO:
        lErreur = TRUE.
        lAbandon = TRUE.
        cErreur = cErreur 
                + CHR(10) + "- l'enregistrement de la table 'Versions' est indisponible".
                .
    END.

    IF not(lAbandon) THEN DO:
        /* Controle de la présence de moulinettes */
        FIND FIRST  bmoulinettes NO-LOCK
            WHERE   bmoulinettes.cNumeroVersion = versions.cNumeroVersion
            NO-ERROR.
        IF AVAILABLE(bMoulinettes) THEN DO:
            MESSAGE "Cette version comporte des moulinettes !"
                 + chr(10) + "Confirmez-vous la suppression de la version : " + versions.cNumeroVersion
                VIEW-AS ALERT-BOX QUESTION BUTTON YES-NO
                TITLE "Confirmation suppression de version..."
                UPDATE lreponse_suppression2 AS LOGICAL.
            IF NOT(lreponse_suppression2) THEN RETURN.
        END.
    END.

    /* gestion des erreurs */
    IF lErreur THEN DO:
        cErreur = "Erreur(s) lors de la suppression de la version en cours : " + cErreur.
        MESSAGE cErreur
            VIEW-AS ALERT-BOX ERROR
            TITLE "Contrôle de suppression..."
            .
        RETURN.
    END.

    /* suppression dans la base */
    FIND CURRENT versions EXCLUSIVE-LOCK NO-ERROR.
    IF NOT(AVAILABLE(versions)) THEN DO:
        cErreur = "Impossible de vérouiller l'enregistrement de 'versions' !"
            + CHR(10) + "Suppression impossible !!".
        MESSAGE cErreur
            VIEW-AS ALERT-BOX ERROR
            TITLE "Suppression de version..."
            .
        RETURN.
    END.

    /* Suppression des moulinettes */
    FOR EACH    bmoulinettes    EXCLUSIVE-LOCK
        WHERE   bmoulinettes.cNumeroVersion = versions.cNumeroVersion
        :
        DELETE bmoulinettes.
    END.

    DELETE versions.

    /* mise à jour de la liste */
    {&OPEN-QUERY-brwVersions}


    /* gestion du code retour */
    lRetour-ou = TRUE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE TestClavier winVersions 
PROCEDURE TestClavier :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE TraiteToggle winVersions 
PROCEDURE TraiteToggle :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER hToggle-in AS WIDGET-HANDLE.
DEFINE INPUT PARAMETER hColonne-in AS WIDGET-HANDLE.

    hToggle-in:X = hColonne-in:X + (hColonne-in:WIDTH-PIXELS / 2) - (hToggle-in:WIDTH-PIXELS / 2).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE TraiteZone winVersions 
PROCEDURE TraiteZone :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER hZoneSaisie-in AS WIDGET-HANDLE.
DEFINE INPUT PARAMETER hColonne-in AS WIDGET-HANDLE.
DEFINE INPUT PARAMETER iAjustement-in AS INTEGER.

    hZoneSaisie-in:X = hColonne-in:X.
    hZoneSaisie-in:WIDTH-PIXELS = hColonne-in:WIDTH-PIXELS - iAjustement-in.
    IF hColonne-in:DATA-TYPE = "DATE" THEN hZoneSaisie-in:FORMAT = hColonne-in:FORMAT.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ValidationMoulinettes winVersions 
PROCEDURE ValidationMoulinettes :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE OUTPUT PARAMETER lRetour-ou AS LOGICAL NO-UNDO INIT FALSE.

    DEFINE VARIABLE lErreur AS LOGICAL NO-UNDO INIT FALSE.
    DEFINE VARIABLE cErreur AS CHARACTER NO-UNDO INIT "".
    DEFINE VARIABLE lAbandon AS LOGICAL NO-UNDO INIT FALSE.
    DEFINE VARIABLE riMoulinettes AS ROWID NO-UNDO.
    DEFINE BUFFER bmoulinettes FOR moulinettes.

    /* controle préliminaires */
    IF NOT(AVAILABLE(moulinettes)) THEN DO:
        /* il se peut qu'il n"y ait pas du tout de moulinettes */
        IF CAN-FIND(bmoulinettes) THEN DO: 
            lErreur = TRUE.
            lAbandon = TRUE.
            cErreur = cErreur 
                    + CHR(10) + "- l'enregistrement de la table 'Moulinettes' est indisponible".
                    .
        END.
    END.

    IF not(lAbandon) THEN DO:
        DO WITH FRAME frmMoulinette:
            IF filrepertoireMoulinette:SCREEN-VALUE = "" THEN DO:
                lErreur = TRUE.
                cErreur = cErreur 
                        + CHR(10) + "- Le répertoire de la moulinette est obligatoire."
                        .
            END.
            IF filnommoulinette:SCREEN-VALUE = "" THEN DO:
                lErreur = TRUE.
                cErreur = cErreur 
                        + CHR(10) + "- Le nom de la moulinette est obligatoire."
                        .
            END.
            IF filAuteur:SCREEN-VALUE = "" THEN DO:
                lErreur = TRUE.
                cErreur = cErreur 
                        + CHR(10) + "- L'auteur de la moulinette est obligatoire."
                        .
            END.
            IF not(tglGestion:CHECKED) AND not(tglpme:CHECKED) THEN DO:
                lErreur = TRUE.
                cErreur = cErreur 
                        + CHR(10) + "- Vous n'avez pas indiquer le type de la moulinette (Gestion/PME)."
                        .
            END.
            IF not(tglhref:CHECKED) AND not(tglhvid:CHECKED) AND not(tgluvid:CHECKED) AND not(tgluvid:CHECKED) THEN DO:
                lErreur = TRUE.
                cErreur = cErreur 
                        + CHR(10) + "- Vous n'avez pas indiquer sur quelle(s) base appliquer la moulinette (hRef/hVid/uRef/uVid)."
                        .
            END.
        END.
    END.

    /* gestion des erreurs */
    IF lErreur THEN DO:
        cErreur = "Des erreurs de saisie sont présentes : " + cErreur.
        MESSAGE cErreur
            VIEW-AS ALERT-BOX ERROR
            TITLE "Contrôle de la saisie..."
            .
        RETURN.
    END.

    /* a ce niveau, tout est correct */
    IF cModeAffichageEnCours = "AM" THEN CREATE moulinettes.

    /* enregistrement dans la base */
    FIND CURRENT moulinettes EXCLUSIVE-LOCK NO-ERROR.
    IF NOT(AVAILABLE(moulinettes)) THEN DO:
        cErreur = "Impossible de vérouiller l'enregistrement de 'moulinttes' !"
            + CHR(10) + "Validation impossible !!".
        MESSAGE cErreur
            VIEW-AS ALERT-BOX ERROR
            TITLE "Validation de la saisie..."
            .
        RETURN.
    END.


    DO WITH FRAME frmmoulinette:
        ASSIGN
            moulinettes.cNomMoulinette = filNomMoulinette:SCREEN-VALUE
            moulinettes.cRepertoireMoulinette = filRepertoireMoulinette:SCREEN-VALUE
            moulinettes.cAuteur = filAuteur:SCREEN-VALUE
            moulinettes.cLibelleMoulinette = filLibelleMoulinette:SCREEN-VALUE
            moulinettes.lGestion = (tglGestion:CHECKED)
            moulinettes.lpme = (tglPme:CHECKED)
            moulinettes.lhRef = (tglhRef:CHECKED)
            moulinettes.luRef = (tgluRef:CHECKED)
            moulinettes.lhvid = (tglhvid:CHECKED)
            moulinettes.luvid = (tgluvid:CHECKED)
            moulinettes.ldernier = (tgldernier:CHECKED)
            .
        IF cModeAffichageEnCours = "AM" THEN do:
            moulinettes.cNumeroVersion = versions.cNumeroVersion.
        END.
    END.

    /* libération de l'enregistrement */
    FIND CURRENT moulinettes NO-LOCK NO-ERROR.
    IF NOT(AVAILABLE(moulinettes)) THEN DO:
        cErreur = "Impossible de liberer l'enregistrement de 'moulinettes' !"
            + CHR(10) + "Sortez de la gestion des versions et relancez-la !!".
        MESSAGE cErreur
            VIEW-AS ALERT-BOX ERROR
            TITLE "Validation de la saisie..."
            .
        RETURN.
    END.
    
    /* mise à jour de la liste */
    riMoulinettes = rowid(moulinettes).
    {&OPEN-QUERY-brwMoulinettes}
    REPOSITION brwMoulinettes TO ROWID riMoulinettes.


    /* gestion du code retour */
    lRetour-ou = TRUE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ValidationVersions winVersions 
PROCEDURE ValidationVersions :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE OUTPUT PARAMETER lRetour-ou AS LOGICAL NO-UNDO INIT FALSE.

    DEFINE VARIABLE lErreur AS LOGICAL NO-UNDO INIT FALSE.
    DEFINE VARIABLE cErreur AS CHARACTER NO-UNDO INIT "".
    DEFINE VARIABLE lAbandon AS LOGICAL NO-UNDO INIT FALSE.
    DEFINE VARIABLE riVersions AS ROWID NO-UNDO.

    /* controle préliminaires */
    IF NOT(AVAILABLE(versions)) THEN DO:
        lErreur = TRUE.
        lAbandon = TRUE.
        cErreur = cErreur 
                + CHR(10) + "- l'enregistrement de la table 'Versions' est indisponible".
                .
    END.

    IF not(lAbandon) THEN DO:
        DO WITH FRAME frmVersion:
            IF filNumeroVersion:SCREEN-VALUE = "" THEN DO:
                lErreur = TRUE.
                cErreur = cErreur 
                        + CHR(10) + "- Le numéro de la version est obligatoire."
                        .
            END.
            IF filDate:SCREEN-VALUE = "" THEN DO:
                lErreur = TRUE.
                cErreur = cErreur 
                        + CHR(10) + "- La date de la version est obligatoire."
                        .
            END.
            IF filSadb:SCREEN-VALUE = "" THEN DO:
                lErreur = TRUE.
                cErreur = cErreur 
                        + CHR(10) + "- Le CRC de sadb est obligatoire."
                        .
            END.
            IF filInter:SCREEN-VALUE = "" THEN DO:
                lErreur = TRUE.
                cErreur = cErreur 
                        + CHR(10) + "- Le CRC de inter est obligatoire."
                        .
            END.
            IF filCompta:SCREEN-VALUE = "" THEN DO:
                lErreur = TRUE.
                cErreur = cErreur 
                        + CHR(10) + "- Le CRC de compta est obligatoire."
                        .
            END.
            IF filTransfert:SCREEN-VALUE = "" THEN DO:
                lErreur = TRUE.
                cErreur = cErreur 
                        + CHR(10) + "- Le CRC de transfer est obligatoire."
                        .
            END.
            IF filCadb:SCREEN-VALUE = "" THEN DO:
                lErreur = TRUE.
                cErreur = cErreur 
                        + CHR(10) + "- Le CRC de cadb est obligatoire."
                        .
            END.
            IF filLadb:SCREEN-VALUE = "" THEN DO:
                lErreur = TRUE.
                cErreur = cErreur 
                        + CHR(10) + "- Le CRC de ladb est obligatoire."
                        .
            END.
            IF filWadb:SCREEN-VALUE = "" THEN DO:
                lErreur = TRUE.
                cErreur = cErreur 
                        + CHR(10) + "- Le CRC de wadb est obligatoire."
                        .
            END.
            IF filLCompta:SCREEN-VALUE = "" THEN DO:
                lErreur = TRUE.
                cErreur = cErreur 
                        + CHR(10) + "- Le CRC de lcompta est obligatoire."
                        .
            END.
            IF filltrans:SCREEN-VALUE = "" THEN DO:
                lErreur = TRUE.
                cErreur = cErreur 
                        + CHR(10) + "- Le CRC de ltrans est obligatoire."
                        .
            END.
            IF fildwh:SCREEN-VALUE = "" THEN DO:
                lErreur = TRUE.
                cErreur = cErreur 
                        + CHR(10) + "- Le CRC de dwh est obligatoire."
                        .
            END.
            IF filrepertoire:SCREEN-VALUE = "" THEN DO:
                lErreur = TRUE.
                cErreur = cErreur 
                        + CHR(10) + "- Le répertoire de la version est obligatoire."
                        .
            END.
            IF not(tglDev:CHECKED) AND not(tglTest:CHECKED) AND not(tglClient:CHECKED) THEN DO:
                lErreur = TRUE.
                cErreur = cErreur 
                        + CHR(10) + "- Vous n'avez pas indiquer le type de la version (GIDEV,GI,GICLI)."
                        .
            END.
        END.
    END.

    /* gestion des erreurs */
    IF lErreur THEN DO:
        cErreur = "Des erreurs de saisie sont présentes : " + cErreur.
        MESSAGE cErreur
            VIEW-AS ALERT-BOX ERROR
            TITLE "Contrôle de la saisie..."
            .
        RETURN.
    END.

    /* a ce niveau, tout est correct */
    IF cModeAffichageEnCours = "AV" THEN CREATE versions.

    /* enregistrement dans la base */
    FIND CURRENT versions EXCLUSIVE-LOCK NO-ERROR.
    IF NOT(AVAILABLE(versions)) THEN DO:
        cErreur = "Impossible de vérouiller l'enregistrement de 'versions' !"
            + CHR(10) + "Validation impossible !!".
        MESSAGE cErreur
            VIEW-AS ALERT-BOX ERROR
            TITLE "Validation de la saisie..."
            .
        RETURN.
    END.


    DO WITH FRAME frmversion:
        ASSIGN
            versions.cNumeroVersion = filNumeroVersion:SCREEN-VALUE
            versions.dDateVersion = DATE(fildate:SCREEN-VALUE)
            versions.iCrcSadb = INTEGER(filSadb:SCREEN-VALUE)
            versions.iCrcInter = INTEGER(filinter:SCREEN-VALUE)
            versions.iCrcCompta = INTEGER(filcompta:SCREEN-VALUE)
            versions.iCrcTransfert = INTEGER(filtransfert:SCREEN-VALUE)
            versions.iCrcCadb = INTEGER(filcadb:SCREEN-VALUE)
            versions.iCrcLadb = INTEGER(filladb:SCREEN-VALUE)
            versions.iCrcWadb = INTEGER(filwadb:SCREEN-VALUE)
            versions.iCrcLcompta = INTEGER(fillcompta:SCREEN-VALUE)
            versions.iCrcLtrans = INTEGER(filltrans:SCREEN-VALUE)
            versions.iCrcDwh = INTEGER(fildwh:SCREEN-VALUE)
            versions.lGidev = (tgldev:CHECKED)
            versions.lGi = (tgltest:CHECKED)
            versions.lGicli = (tglclient:CHECKED)
            versions.cRepertoireVersion = filrepertoire:SCREEN-VALUE
            versions.cFiller1 = edtCommentaire:SCREEN-VALUE
            versions.cFiller2 = edtDeltas:SCREEN-VALUE
            versions.lExclusion = (tglExclusion:CHECKED)
            .
        IF cModeAffichageEnCours = "AV" THEN versions.iordre = iOrdreVersion.

        /* indication comme quoi il y a eu des modifications */
        lModificationsGenerales = TRUE.
    END.

    /* libération de l'enregistrement */
    FIND CURRENT versions NO-LOCK NO-ERROR.
    IF NOT(AVAILABLE(versions)) THEN DO:
        cErreur = "Impossible de liberer l'enregistrement de 'versions' !"
            + CHR(10) + "Sortez de la gestion des versions et relancez-la !!".
        MESSAGE cErreur
            VIEW-AS ALERT-BOX ERROR
            TITLE "Validation de la saisie..."
            .
        RETURN.
    END.
    
    /* mise à jour de la liste */
    riVersions = rowid(versions).
    {&OPEN-QUERY-brwVersions}
    REPOSITION brwVersions TO ROWID riVersions.


    /* gestion du code retour */
    lRetour-ou = TRUE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE VideZonesMoulinette winVersions 
PROCEDURE VideZonesMoulinette :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/


    DO WITH FRAME frmMoulinette:
        filRepertoireMoulinette:SCREEN-VALUE = "".
        RUN AffecteZone(filNomMoulinette:HANDLE,filRepertoireMoulinette:HANDLE).
        RUN AffecteZone(filAuteur:HANDLE,filRepertoireMoulinette:HANDLE).
        RUN AffecteZone(filLibelleMoulinette:HANDLE,filRepertoireMoulinette:HANDLE).

        tglGestion:CHECKED = FALSE.
        RUN AffecteToggle2(tglpme:HANDLE,tglGestion:HANDLE).
        RUN AffecteToggle2(tglhref:HANDLE,tglGestion:HANDLE).
        RUN AffecteToggle2(tglhvid:HANDLE,tglGestion:HANDLE).
        RUN AffecteToggle2(tgluref:HANDLE,tglGestion:HANDLE).
        RUN AffecteToggle2(tgluvid:HANDLE,tglGestion:HANDLE).
        RUN AffecteToggle2(tgldernier:HANDLE,tglGestion:HANDLE).
    END.
    
   
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE VideZonesVersion winVersions 
PROCEDURE VideZonesVersion :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    DO WITH FRAME frmVersion:
        filNumeroVersion:SCREEN-VALUE = "".
        RUN AffecteZone(filDate:HANDLE,filNumeroVersion:HANDLE).
        RUN AffecteZone(filsadb:HANDLE,filNumeroVersion:HANDLE).
        RUN AffecteZone(filInter:HANDLE,filNumeroVersion:HANDLE).
        RUN AffecteZone(filCompta:HANDLE,filNumeroVersion:HANDLE).
        RUN AffecteZone(filTransfert:HANDLE,filNumeroVersion:HANDLE).
        RUN AffecteZone(filCadb:HANDLE,filNumeroVersion:HANDLE).
        RUN AffecteZone(filLadb:HANDLE,filNumeroVersion:HANDLE).
        RUN AffecteZone(filWadb:HANDLE,filNumeroVersion:HANDLE).
        RUN AffecteZone(fillcompta:HANDLE,filNumeroVersion:HANDLE).
        RUN AffecteZone(filLtrans:HANDLE,filNumeroVersion:HANDLE).
        RUN AffecteZone(filDwh:HANDLE,filNumeroVersion:HANDLE).
        RUN AffecteZone(filrepertoire:HANDLE,filNumeroVersion:HANDLE).

        edtCommentaire:SCREEN-VALUE = "".
        edtDeltas:SCREEN-VALUE = "".

        tgldev:CHECKED = FALSE.
        RUN AffecteToggle2(tglTest:HANDLE,tglDev:HANDLE).
        RUN AffecteToggle2(tglClient:HANDLE,tglDev:HANDLE).
        RUN AffecteToggle2(tglExclusion:HANDLE,tglDev:HANDLE).
    END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION AfficheInformations winVersions 
FUNCTION AfficheInformations RETURNS LOGICAL
  (cLibelle-in AS CHARACTER) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
    SESSION:IMMEDIATE-DISPLAY = TRUE.

    DO WITH FRAME frmInformation:
        edtInformation:SCREEN-VALUE = cLibelle-in.
        ASSIGN edtInformation.
    END.
    
    IF cLibelle-in = ""  THEN DO:
        FRAME frmInformation:VISIBLE = FALSE.
    END.
    ELSE DO:
        FRAME frmInformation:VISIBLE = TRUE.
    END.

  RETURN TRUE.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION Controle_Abandon winVersions 
FUNCTION Controle_Abandon RETURNS LOGICAL
  ( /* parameter-definitions */ ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
    DEFINE VARIABLE lRetour AS LOGICAL NO-UNDO INIT FALSE.
    DEFINE VARIABLE hWidget AS WIDGET-HANDLE NO-UNDO.

    ASSIGN hWidget = LAST-EVENT:WIDGET-ENTER NO-ERROR.
    IF VALID-HANDLE(hWidget) AND hWidget:PRIVATE-DATA MATCHES("*SANS-CONTROLE*") THEN lRetour = TRUE.

    RETURN lRetour.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

