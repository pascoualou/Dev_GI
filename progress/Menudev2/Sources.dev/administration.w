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
{includes\i_dialogue.i}
{menudev2\includes\menudev2.i}


/* Parameters Definitions ---                                           */

DEFINE INPUT PARAMETER  winGeneral  AS HANDLE NO-UNDO.
DEFINE INPUT PARAMETER  cParametres AS CHARACTER NO-UNDO.

DEFINE BUFFER bdefs FOR defs.
DEFINE BUFFER butilisateurs FOR utilisateurs.

DEFINE TEMP-TABLE ttUtil    NO-UNDO 
    FIELD cUtilisateur LIKE utilisateurs.cutilisateur
    FIELD lAdmin LIKE utilisateurs.ladmin
    FIELD lconnecte LIKE utilisateurs.lconnecte
    FIELD iNiveau LIKE utilisateurs.iNiveau
    FIELD iVersion LIKE utilisateurs.iVersion
    FIELD cGroupe LIKE utilisateurs.cGroupe
    FIELD lordres AS LOGICAL
    FIELD lDesactive LIKE utilisateurs.lDesactive
    FIELD lNonPhysique LIKE utilisateurs.lNonPhysique
    FIELD cFiller LIKE utilisateurs.cFiller
    INDEX ix01 cUtilisateur
    .


DEFINE VARIABLE cUtilisateur_svg AS CHARACTER NO-UNDO INIT ?.

DEFINE VARIABLE iX AS INTEGER NO-UNDO.
DEFINE VARIABLE iY AS INTEGER NO-UNDO.


DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME frmRepertoires
&Scoped-define BROWSE-NAME brwModules

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES Defs ttutil

/* Definitions for BROWSE brwModules                                    */
&Scoped-define FIELDS-IN-QUERY-brwModules Defs.cCode Defs.cValeur ~
(if lLancer then "X" else "") Defs.cProgramme Defs.cParametres ~
(if Defs.lAdmin then "X" else "") (if Defs.lVisible then "X" else "") ~
(if Defs.lbases then "X" else "") entry(1,defs.filler,"|") ~
(if num-entries(defs.filler,"|") >= 2 then entry(2,defs.filler,"|") else "") 
&Scoped-define ENABLED-FIELDS-IN-QUERY-brwModules 
&Scoped-define QUERY-STRING-brwModules FOR EACH Defs ~
      WHERE Defs.cCle = "MODULE"  NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-brwModules OPEN QUERY brwModules FOR EACH Defs ~
      WHERE Defs.cCle = "MODULE"  NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-brwModules Defs
&Scoped-define FIRST-TABLE-IN-QUERY-brwModules Defs


/* Definitions for BROWSE brwUtilisateurs                               */
&Scoped-define FIELDS-IN-QUERY-brwUtilisateurs ttutil.cUtilisateur ttutil.lAdmin ttutil.lConnecte ttutil.lordres ttutil.iVersion ttutil.iniveau ttutil.cGroupe ttutil.lDesactive ttutil.lNonPhysique ttutil.cFiller   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brwUtilisateurs ttutil.iVersion ttutil.iniveau ttutil.cGroupe ttutil.lDesactive ttutil.lNonPhysique ttutil.lAdmin ttutil.cFiller   
&Scoped-define ENABLED-TABLES-IN-QUERY-brwUtilisateurs ttutil
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-brwUtilisateurs ttutil
&Scoped-define SELF-NAME brwUtilisateurs
&Scoped-define QUERY-STRING-brwUtilisateurs FOR EACH ttutil NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-brwUtilisateurs OPEN QUERY {&SELF-NAME} FOR EACH ttutil NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-brwUtilisateurs ttutil
&Scoped-define FIRST-TABLE-IN-QUERY-brwUtilisateurs ttutil


/* Definitions for FRAME frmModules                                     */
&Scoped-define OPEN-BROWSERS-IN-QUERY-frmModules ~
    ~{&OPEN-QUERY-brwModules}

/* Definitions for FRAME frmUtilisateurs                                */
&Scoped-define OPEN-BROWSERS-IN-QUERY-frmUtilisateurs ~
    ~{&OPEN-QUERY-brwUtilisateurs}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS edtFichiers btnConvAFaire lstFichiers ~
btnFichiersAjouter btnStats btnFichiersSupprimer btnAgenda btnSaints ~
btnVariables 
&Scoped-Define DISPLAYED-OBJECTS edtFichiers lstFichiers 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.

/* Menu Definitions                                                     */
DEFINE MENU POPUP-MENU-brwModules 
       MENU-ITEM m_Ajouter      LABEL "Ajouter"       
       MENU-ITEM m_Modifier     LABEL "Modifier"      
       RULE
       MENU-ITEM m_Supprimer    LABEL "Supprimer"     
       RULE
       MENU-ITEM m_Fermer2      LABEL "Fermer"        .

DEFINE MENU POPUP-MENU-brwUtilisateurs 
       MENU-ITEM m_Passer_en_mode_ADMIN LABEL "Passer en mode ADMIN"
       MENU-ITEM m_Effacer_toutes_les_informat LABEL "Effacer toutes les informations en attente de l'utilisateur"
       RULE
       MENU-ITEM m_Valider_les_modifications LABEL "Valider les modifications"
       RULE
       MENU-ITEM m_Supprimer_lutilisateur LABEL "Supprimer l'utilisateur"
       RULE
       MENU-ITEM m_Raffraichir__Annuler LABEL "Raffraichir / Annuler"
       RULE
       MENU-ITEM m_Fermer       LABEL "Fermer"        .


/* Definitions of the field level widgets                               */
DEFINE BUTTON btnAgenda  NO-FOCUS
     LABEL "Lister Agenda dans le Log de menudev2" 
     SIZE 42 BY .95.

DEFINE BUTTON btnConvAFaire  NO-FOCUS
     LABEL "Conversion 'A Faire' (utilisateur sélectionné)" 
     SIZE 42 BY .95.

DEFINE BUTTON btnFichiersAjouter  NO-FOCUS
     LABEL "Ajouter un fichier" 
     SIZE 42 BY .95 TOOLTIP "Ajouter un fichier de paramètres".

DEFINE BUTTON btnFichiersSupprimer  NO-FOCUS
     LABEL "Supprimer le fichier selectionné" 
     SIZE 42 BY .95 TOOLTIP "Supprimer le fichier sélectionné".

DEFINE BUTTON btnSaints  NO-FOCUS
     LABEL "Charger la table des saints" 
     SIZE 42 BY .95.

DEFINE BUTTON btnStats  NO-FOCUS
     LABEL "Débloquer le chargement des stats MaGI" 
     SIZE 42 BY .95.

DEFINE BUTTON btnVariables  NO-FOCUS
     LABEL "Décharger les variables dans un fichier" 
     SIZE 42 BY .95.

DEFINE VARIABLE edtFichiers AS CHARACTER INITIAL "Liste des fichiers de paramètrage (Double clic pour voir / modifier le fichier)" 
     VIEW-AS EDITOR NO-BOX
     SIZE 39 BY 1.43 NO-UNDO.

DEFINE VARIABLE lstFichiers AS CHARACTER 
     VIEW-AS SELECTION-LIST SINGLE SCROLLBAR-VERTICAL 
     SIZE 39 BY 9.29 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brwModules FOR 
      Defs SCROLLING.

DEFINE QUERY brwUtilisateurs FOR 
      ttutil SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brwModules
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brwModules C-Win _STRUCTURED
  QUERY brwModules NO-LOCK DISPLAY
      Defs.cCode COLUMN-LABEL "Code module" FORMAT "X(32)":C WIDTH 23.2
      Defs.cValeur COLUMN-LABEL "Libellé module" FORMAT "X(50)":U
            WIDTH 27.2
      (if lLancer then "X" else "") COLUMN-LABEL "Auto" FORMAT "X":U
            WIDTH 5
      Defs.cProgramme COLUMN-LABEL "Programme" FORMAT "X(32)":U
            WIDTH 24.4
      Defs.cParametres COLUMN-LABEL "Param." FORMAT "X(50)":U WIDTH 18.2
      (if Defs.lAdmin then "X" else "") COLUMN-LABEL "Admin" WIDTH 8.2
      (if Defs.lVisible then "X" else "") COLUMN-LABEL "Visible"
            WIDTH 9.2
      (if Defs.lbases then "X" else "") COLUMN-LABEL "Bases" WIDTH 10.2
      entry(1,defs.filler,"|") COLUMN-LABEL "Niveau"
      (if num-entries(defs.filler,"|") >= 2 then entry(2,defs.filler,"|") else "") COLUMN-LABEL "Groupe"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 161 BY 5.48 FIT-LAST-COLUMN.

DEFINE BROWSE brwUtilisateurs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brwUtilisateurs C-Win _FREEFORM
  QUERY brwUtilisateurs NO-LOCK DISPLAY
      ttutil.cUtilisateur FORMAT "X(20)":U
      ttutil.lAdmin COLUMN-LABEL "Admin" FORMAT "O/N":U 
      ttutil.lConnecte COLUMN-LABEL "Connecté" FORMAT "O/N":U 
      ttutil.lordres COLUMN-LABEL "Ordres" FORMAT "O/N":U
      ttutil.iVersion COLUMN-LABEL "Version" FORMAT "999":U
      ttutil.iniveau COLUMN-LABEL "Niveau" FORMAT ">9":U
      ttutil.cGroupe COLUMN-LABEL "Groupe" 
      ttutil.lDesactive COLUMN-LABEL "Inactif" FORMAT "O/N"
      ttutil.lNonPhysique COLUMN-LABEL "Non Physique" FORMAT "O/N"
      ttutil.cFiller COLUMN-LABEL "Droits utilisateur" FORMAT "x(200)"

          
      ENABLE ttutil.iVersion ttutil.iniveau ttutil.cGroupe ttutil.lDesactive ttutil.lNonPhysique ttutil.lAdmin ttutil.cFiller
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 74 BY 10.48 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME frmModule
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 166.2 BY 20.62
         BGCOLOR 7 
         TITLE BGCOLOR 2 FGCOLOR 15 "Administration".

DEFINE FRAME frmUtilisateurs
     brwUtilisateurs AT ROW 1.24 COL 2
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 89 ROW 8.38
         SIZE 77 BY 11.91
         TITLE "Utilisateurs".

DEFINE FRAME frmRepertoires
     edtFichiers AT ROW 1 COL 2 NO-LABEL WIDGET-ID 32
     btnConvAFaire AT ROW 4.33 COL 43 WIDGET-ID 40
     lstFichiers AT ROW 2.43 COL 2 NO-LABEL WIDGET-ID 28
     btnFichiersAjouter AT ROW 10.76 COL 43 WIDGET-ID 34
     btnStats AT ROW 8.62 COL 43 WIDGET-ID 38
     btnFichiersSupprimer AT ROW 9.81 COL 43 WIDGET-ID 36
     btnAgenda AT ROW 2.19 COL 43
     btnSaints AT ROW 3.14 COL 43 WIDGET-ID 22
     btnVariables AT ROW 1.24 COL 43 WIDGET-ID 18
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 2 ROW 8.38
         SIZE 86 BY 11.91
         TITLE "Paramètrage / Debugging".

DEFINE FRAME frmModules
     brwModules AT ROW 1.24 COL 2
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 2 ROW 1.24
         SIZE 164 BY 6.91
         TITLE "Modules".


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
/* REPARENT FRAME */
ASSIGN FRAME frmModules:FRAME = FRAME frmModule:HANDLE
       FRAME frmRepertoires:FRAME = FRAME frmModule:HANDLE
       FRAME frmUtilisateurs:FRAME = FRAME frmModule:HANDLE.

/* SETTINGS FOR FRAME frmModule
                                                                        */

DEFINE VARIABLE XXTABVALXX AS LOGICAL NO-UNDO.

ASSIGN XXTABVALXX = FRAME frmRepertoires:MOVE-BEFORE-TAB-ITEM (FRAME frmUtilisateurs:HANDLE)
       XXTABVALXX = FRAME frmModules:MOVE-BEFORE-TAB-ITEM (FRAME frmRepertoires:HANDLE)
/* END-ASSIGN-TABS */.

/* SETTINGS FOR FRAME frmModules
                                                                        */
/* BROWSE-TAB brwModules 1 frmModules */
ASSIGN 
       brwModules:POPUP-MENU IN FRAME frmModules             = MENU POPUP-MENU-brwModules:HANDLE.

/* SETTINGS FOR FRAME frmRepertoires
   FRAME-NAME                                                           */
ASSIGN 
       edtFichiers:READ-ONLY IN FRAME frmRepertoires        = TRUE.

/* SETTINGS FOR FRAME frmUtilisateurs
                                                                        */
/* BROWSE-TAB brwUtilisateurs 1 frmUtilisateurs */
ASSIGN 
       brwUtilisateurs:POPUP-MENU IN FRAME frmUtilisateurs             = MENU POPUP-MENU-brwUtilisateurs:HANDLE
       brwUtilisateurs:NUM-LOCKED-COLUMNS IN FRAME frmUtilisateurs     = 1.

IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brwModules
/* Query rebuild information for BROWSE brwModules
     _TblList          = "gidata.Defs"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Where[1]         = "gidata.Defs.cCle = ""MODULE"" "
     _FldNameList[1]   > gidata.Defs.cCode
"Defs.cCode" "Code module" ? "character" ? ? ? ? ? ? no ? no no "23.2" yes no no "C" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > gidata.Defs.cValeur
"Defs.cValeur" "Libellé module" ? "character" ? ? ? ? ? ? no ? no no "27.2" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   > "_<CALC>"
"(if lLancer then ""X"" else """")" "Auto" "X" ? ? ? ? ? ? ? no ? no no "5" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   > gidata.Defs.cProgramme
"Defs.cProgramme" "Programme" ? "character" ? ? ? ? ? ? no ? no no "24.4" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[5]   > gidata.Defs.cParametres
"Defs.cParametres" "Param." ? "character" ? ? ? ? ? ? no ? no no "18.2" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[6]   > "_<CALC>"
"(if Defs.lAdmin then ""X"" else """")" "Admin" ? ? ? ? ? ? ? ? no ? no no "8.2" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[7]   > "_<CALC>"
"(if Defs.lVisible then ""X"" else """")" "Visible" ? ? ? ? ? ? ? ? no ? no no "9.2" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[8]   > "_<CALC>"
"(if Defs.lbases then ""X"" else """")" "Bases" ? ? ? ? ? ? ? ? no ? no no "10.2" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[9]   > "_<CALC>"
"entry(1,defs.filler,""|"")" "Niveau" ? ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[10]   > "_<CALC>"
"(if num-entries(defs.filler,""|"") >= 2 then entry(2,defs.filler,""|"") else """")" "Groupe" ? ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE brwModules */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brwUtilisateurs
/* Query rebuild information for BROWSE brwUtilisateurs
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH ttutil NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE brwUtilisateurs */
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


&Scoped-define BROWSE-NAME brwModules
&Scoped-define FRAME-NAME frmModules
&Scoped-define SELF-NAME brwModules
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwModules C-Win
ON DEFAULT-ACTION OF brwModules IN FRAME frmModules
DO:
  
    /* Appel de la boite de saisie */
    gcAllerRetour = defs.cCode 
        + "|" + defs.cValeur 
        + "|" + (IF defs.lLancer THEN "X" ELSE "") 
        + "|" + defs.cparametres 
        + "|" + defs.cProgramme 
        + "|" + (IF defs.lAdmin THEN "X" ELSE "") 
        + "|" + (IF defs.lVisible THEN "X" ELSE "")
        + "|" + (IF defs.lbases THEN "X" ELSE "")
        + "|" + ENTRY(1,defs.filler,"|")
        + "|" + (IF num-entries(defs.filler,"|") >= 2 THEN entry(2,defs.filler,"|") ELSE "")
        .
    RUN VALUE(gcRepertoireExecution + "saisie.w") (INPUT "MODULE", INPUT-OUTPUT gcAllerRetour).
    IF gcAllerRetour = "" THEN RETURN NO-APPLY.

    /* Gestion du retour de la saisie */
    FIND CURRENT defs EXCLUSIVE-LOCK NO-ERROR.
    IF NOT(AVAILABLE(defs)) THEN DO:
        msgerreur("Impossible de mettre à jour la table des modules !").
        RETURN NO-APPLY.
    END.
    ASSIGN
        defs.cCode = ENTRY(1,gcAllerRetour,"|")
        defs.cValeur = ENTRY(2,gcAllerRetour,"|")
        defs.lLancer = (IF ENTRY(3,gcAllerRetour,"|") = "X" THEN TRUE ELSE FALSE)
        defs.cParametres = ENTRY(4,gcAllerRetour,"|")
        defs.cProgramme = ENTRY(5,gcAllerRetour,"|")
        defs.lAdmin = (IF ENTRY(6,gcAllerRetour,"|") = "X" THEN TRUE ELSE FALSE)
        defs.lVisible = (IF ENTRY(7,gcAllerRetour,"|") = "X" THEN TRUE ELSE FALSE)
        defs.lbases = (IF ENTRY(8,gcAllerRetour,"|") = "X" THEN TRUE ELSE FALSE)
        defs.filler = ENTRY(9,gcAllerRetour,"|") + "|" + ENTRY(10,gcAllerRetour,"|")
        .
    RELEASE defs.

    /* Maj de l'écran */
    {&OPEN-QUERY-{&BROWSE-NAME}}

    /* Confirmation */
    msgInformation("Module modifié.").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brwUtilisateurs
&Scoped-define FRAME-NAME frmUtilisateurs
&Scoped-define SELF-NAME brwUtilisateurs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwUtilisateurs C-Win
ON DEFAULT-ACTION OF brwUtilisateurs IN FRAME frmUtilisateurs
DO:
    /*-----
  IF not(AVAILABLE(ttutil)) THEN RETURN NO-APPLY.
  cUtilisateur_svg = "".
  FIND FIRST butilisateurs EXCLUSIVE-LOCK
      WHERE butilisateurs.cutilisateur = ttutil.cutilisateur
      NO-ERROR.
  IF not(AVAILABLE(butilisateurs)) THEN RETURN NO-APPLY.
  butilisateurs.ladmin = NOT(butilisateurs.ladmin).
  cUtilisateur_svg = ttutil.cutilisateur.
  RELEASE butilisateurs.
  RUN ChargeUtilisateurs.
  {&OPEN-QUERY-brwUtilisateurs}
  brwutilisateurs:REFRESH().
  IF cUtilisateur_svg <> "" THEN DO:
      FIND FIRST ttutil NO-LOCK
          WHERE  ttutil.cUtilisateur = cUtilisateur_svg
          NO-ERROR.
      IF AVAILABLE(ttutil) THEN REPOSITION brwutilisateurs TO ROWID ROWID(ttutil).
  END.
  ---- */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frmRepertoires
&Scoped-define SELF-NAME btnAgenda
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnAgenda C-Win
ON CHOOSE OF btnAgenda IN FRAME frmRepertoires /* Lister Agenda dans le Log de menudev2 */
DO:
    
    {includes\vidage.i agenda}

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnConvAFaire
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnConvAFaire C-Win
ON CHOOSE OF btnConvAFaire IN FRAME frmRepertoires /* Conversion 'A Faire' (utilisateur sélectionné) */
DO:
    DEFINE VARIABLE cUtilisateurEnCours AS CHARACTER NO-UNDO.

    cUtilisateurEnCours = ttUtil.cUtilisateur.
    MESSAGE "Confirmez-vous la conversion des listes et action du module 'A Faire' pour l'utilisateur '" + cUtilisateurEnCours + "' ?"
        VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE lReponseConversion AS LOGICAL.
    IF lReponseConversion = FALSE THEN RETURN.
    RUN VALUE(gcRepertoireExecution + "ConvAFaire.p") (cUtilisateurEnCours,FALSE).
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnFichiersAjouter
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnFichiersAjouter C-Win
ON CHOOSE OF btnFichiersAjouter IN FRAME frmRepertoires /* Ajouter un fichier */
DO:

    DEFINE VARIABLE cidReference AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cFichier AS CHARACTER NO-UNDO.

    /* Ajout d'un fichier de paramètres */
    RUN DonnePositionMessage IN ghGeneral.
    gcAllerRetour = STRING(giPosXMessage)
        + "|" + STRING(giPosYMessage)
        + "|" + "Nom du fichier"
        + "|" + ""
        .
    RUN VALUE(gcRepertoireExecution + "saisie2.w") (INPUT-OUTPUT gcAllerRetour).
    IF gcAllerRetour = "" THEN RETURN.

    cidReference = STRING(TODAY,"99/99/9999") + "-" + STRING(TIME,"hh:mm:ss").
    cFichier = ENTRY(4,gcAllerRetour,"|").

    IF cFichier <> "" THEN DO:

        /* vérification que le fichier n'existe pas deja */
        FIND FIRST  fichiers    NO-LOCK
            WHERE   fichiers.cUtilisateur = ""
            AND     fichiers.cTypeFichier = "SYS"
            AND     fichiers.cIdentFichier = cFichier
            NO-ERROR.

        IF AVAILABLE(fichiers) THEN DO:
            MESSAGE "Un fichier avec ce nom existe déjà. Veuillez saisir un autre nom."
                VIEW-AS ALERT-BOX ERROR
                TITLE "Menudev2 : Administration..."
                .
            RETURN NO-APPLY.
        END.

        CREATE fichiers.
        ASSIGN
            fichiers.cUtilisateur = ""
            fichiers.cTypeFichier = "SYS"
            fichiers.cIdentFichier = ENTRY(4,gcAllerRetour,"|")
            fichiers.cCreateur = gcUtilisateur
            fichiers.cModifieur = gcUtilisateur
            fichiers.idModification = cidReference
            .

        RELEASE fichiers.

        /* Recharge la liste */
        RUN ChargeListeFichiers.
        lstFichiers:SCREEN-VALUE = cFichier.

        /* Lancement de la modification du fichier */
        APPLY "DEFAULT-ACTION" TO lstFichiers.
    END.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnFichiersSupprimer
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnFichiersSupprimer C-Win
ON CHOOSE OF btnFichiersSupprimer IN FRAME frmRepertoires /* Supprimer le fichier selectionné */
DO:
    DEFINE VARIABLE cFichier AS CHARACTER NO-UNDO.
    
    cFichier = lstFichiers:SCREEN-VALUE.

    MESSAGE "Confirmez-vous la suppression du fichier sélectionné (" cFichier ") ?"
        VIEW-AS ALERT-BOX QUESTION
        BUTTONS YES-NO
        TITLE "Menudev2 : Administration..."
        UPDATE lReponseSupprimer AS LOGICAL
        .
    IF not(lReponseSupprimer) THEN RETURN.

    FIND FIRST  fichiers    EXCLUSIVE-LOCK
    WHERE   fichiers.cUtilisateur = ""
    AND     fichiers.cTypeFichier = "SYS"
    AND     fichiers.cIdentFichier = cFichier
    NO-ERROR.

    IF NOT AVAILABLE(fichiers) THEN DO:
        MESSAGE "Fichier demandé introuvable"
            VIEW-AS ALERT-BOX ERROR
            TITLE "Menudev2 : Administration..."
            .
    END.
    ELSE DO:
        /* on efface le fichier mais on garde les éventuelles sauvegardes */
        DELETE fichiers.
        PAUSE 3.
        /* Recharge la liste */
        RUN ChargeListeFichiers.
        MESSAGE "Suppression du fichiers effectuée."
            VIEW-AS ALERT-BOX INFORMATION
            TITLE "Menudev2 : Administration..."
            .
    END.
        release fichiers.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnSaints
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnSaints C-Win
ON CHOOSE OF btnSaints IN FRAME frmRepertoires /* Charger la table des saints */
DO:

    RUN ChargeSaints.
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnStats
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnStats C-Win
ON CHOOSE OF btnStats IN FRAME frmRepertoires /* Débloquer le chargement des stats MaGI */
DO:
    IF DonnePreference("TRAVAIL-STATS-CHARGEMENT-EN-COURS") = "" THEN DO:
        RUN AfficheMessageAvecTemporisation("Administration","Il n'y a aucun blocage du chargement des stats",FALSE,5,"OK","",FALSE,OUTPUT cRetour).
        RETURN NO-APPLY.
    END.

    RUN AfficheMessageAvecTemporisation("Administration","Confirmez-vous le déblocage du chargement des stats ?",TRUE,10,"NON","",FALSE,OUTPUT cRetour).
    IF cRetour = "NON" THEN RETURN NO-APPLY.

    SauvePreference("TRAVAIL-STATS-CHARGEMENT-EN-COURS","").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnVariables
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnVariables C-Win
ON CHOOSE OF btnVariables IN FRAME frmRepertoires /* Décharger les variables dans un fichier */
DO:

    RUN DechargeVariablesModule ("FICHIER").

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME lstFichiers
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL lstFichiers C-Win
ON DEFAULT-ACTION OF lstFichiers IN FRAME frmRepertoires
DO:
  
    AssigneParametre("FICHIERS-INFOSFICHIER",lstFichiers:SCREEN-VALUE + ",PARAM").
    RUN DonneOrdre("DONNEORDREAMODULE=FICHIERS|AFFICHE").  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Ajouter
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Ajouter C-Win
ON CHOOSE OF MENU-ITEM m_Ajouter /* Ajouter */
DO:
  
    /* Appel de la boite de saisie */
    gcAllerRetour = "|||||||||||||".
    RUN VALUE(gcRepertoireExecution + "saisie.w") (INPUT "MODULE", INPUT-OUTPUT gcAllerRetour).
    IF gcAllerRetour = "" THEN RETURN NO-APPLY.

    /* Gestion du retour de la saisie */
    CREATE defs.
    ASSIGN
        defs.cCle = "MODULE"
        defs.cCode = ENTRY(1,gcAllerRetour,"|")
        defs.cValeur = ENTRY(2,gcAllerRetour,"|")
        defs.lLancer = (IF ENTRY(3,gcAllerRetour,"|") = "X" THEN TRUE ELSE FALSE)
        defs.cParametres = ENTRY(4,gcAllerRetour,"|")
        defs.cProgramme = ENTRY(5,gcAllerRetour,"|")
        defs.lAdmin = (IF ENTRY(6,gcAllerRetour,"|") = "X" THEN TRUE ELSE FALSE)
        defs.lVisible = (IF ENTRY(7,gcAllerRetour,"|") = "X" THEN TRUE ELSE FALSE)
        defs.lbases = (IF ENTRY(8,gcAllerRetour,"|") = "X" THEN TRUE ELSE FALSE)
        defs.filler = ENTRY(9,gcAllerRetour,"|") + "|" + ENTRY(10,gcAllerRetour,"|")
        .

    /* Maj de l'écran */
    {&OPEN-QUERY-{&BROWSE-NAME}}

    /* Confirmation */
    msgInformation("Nouveau module créé.").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Effacer_toutes_les_informat
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Effacer_toutes_les_informat C-Win
ON CHOOSE OF MENU-ITEM m_Effacer_toutes_les_informat /* Effacer toutes les informations en attente de l'utilisateur */
DO:
  
    FOR EACH ordres EXCLUSIVE-LOCK
        WHERE ordres.cUtilisateur = ttutil.cUtilisateur
        AND  ordres.cAction = "INFOS"
        :
        DELETE ordres.
    END.
    MESSAGE "Ordres Effacés !!" VIEW-AS ALERT-BOX.
    RELEASE ordres.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Modifier
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Modifier C-Win
ON CHOOSE OF MENU-ITEM m_Modifier /* Modifier */
DO:
  
    APPLY "DEFAULT-ACTION" TO brwModules IN FRAME frmModules.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Passer_en_mode_ADMIN
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Passer_en_mode_ADMIN C-Win
ON CHOOSE OF MENU-ITEM m_Passer_en_mode_ADMIN /* Passer en mode ADMIN */
DO:
    IF gcUtilisateur <> "ADMIN" THEN DO:
        MESSAGE "Confirmez-vous le passage en mode 'ADMIN' ?"
            VIEW-AS ALERT-BOX QUESTION
            BUTTON YES-NO
            UPDATE lReponseAdmin AS LOGICAL.

        IF NOT(lReponseAdmin) THEN RETURN NO-APPLY.

        gcUtilisateurInitial = gcUtilisateur.
        gcUtilisateur = "ADMIN".
        MENU-ITEM m_Passer_en_mode_ADMIN:LABEL IN MENU POPUP-MENU-brwUtilisateurs = "Revenir en mode '" + gcUtilisateurInitial + "'".
    END.
    ELSE do:
        gcUtilisateur = gcUtilisateurInitial.
        MENU-ITEM m_Passer_en_mode_ADMIN:LABEL IN MENU POPUP-MENU-brwUtilisateurs = "Passer en mode 'ADMIN'".
    END.

    MESSAGE "Changement d'utilisateur effectué."
        VIEW-AS ALERT-BOX INFORMATION.
         
    Mlog("Changement d'utilisateur : "
         + "%s gcUtilisateur = " + STRING(gcUtilisateur)
         + "%s gcUtilisateurInitial = " + STRING(gcUtilisateurInitial)
         ).

    /* demande au père de se raffraichir */
    RUN DonneOrdre("CHANGE-UTILISATEUR").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Raffraichir__Annuler
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Raffraichir__Annuler C-Win
ON CHOOSE OF MENU-ITEM m_Raffraichir__Annuler /* Raffraichir / Annuler */
DO:
  
    RUN ChargeUtilisateurs.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Supprimer
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Supprimer C-Win
ON CHOOSE OF MENU-ITEM m_Supprimer /* Supprimer */
DO:
  
    /* Controle */    
    IF NOT(AVAILABLE(defs)) THEN RETURN NO-APPLY.

    /* Demande de confirmation */
    IF msgQuestion("Suppression du module : " + defs.cCode) = FALSE THEN RETURN NO-APPLY.
    
    /* Suppression */
    FIND FIRST bdefs EXCLUSIVE-LOCK
        WHERE RECID(bdefs) = RECID(defs)
        NO-ERROR.
    IF NOT(AVAILABLE(bdefs)) THEN DO:
        MsgErreur("Impossible de supprimer le module !").
        RETURN NO-APPLY.
    END.
    DELETE bdefs.
    RELEASE bdefs.

    /* Mise à jour de l'écran */
    {&OPEN-QUERY-{&BROWSE-NAME}}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Supprimer_lutilisateur
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Supprimer_lutilisateur C-Win
ON CHOOSE OF MENU-ITEM m_Supprimer_lutilisateur /* Supprimer l'utilisateur */
DO:
  
    /* Controle */    
    /*IF NOT(AVAILABLE(ttutil)) THEN RETURN NO-APPLY.*/

    /* Demande de confirmation */
    IF msgQuestion("Suppression de l'utilisateur : " + ttutil.cUtilisateur) = FALSE THEN RETURN NO-APPLY.

    RUN SuppressionUtilisateur(ttutil.cUtilisateur).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Valider_les_modifications
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Valider_les_modifications C-Win
ON CHOOSE OF MENU-ITEM m_Valider_les_modifications /* Valider les modifications */
DO:
  
    /* Maj des zones saisissable du browse dans la table temporaire */
    ASSIGN
        ttutil.iVersion = integer(ttutil.iVersion:screen-value in browse brwUtilisateurs)
        ttutil.iniveau = integer(ttutil.iniveau:screen-value in browse brwUtilisateurs)
        ttutil.cGroupe = ttutil.cGroupe:screen-value in browse brwUtilisateurs   
        ttutil.lDesactive = (ttutil.lDesactive:screen-value in browse brwUtilisateurs = "O")  
        ttutil.lNonPhysique = (ttutil.lNonPhysique:screen-value in browse brwUtilisateurs = "O")
        ttutil.lAdmin = (ttutil.lAdmin:screen-value in browse brwUtilisateurs = "O")
        ttutil.cFiller = ttutil.cFiller:screen-value in browse brwUtilisateurs
        .

    cUtilisateur_svg = ttutil.cutilisateur.
    
    FOR EACH ttutil NO-LOCK
        :
        FIND FIRST utilisateurs EXCLUSIVE-LOCK
            WHERE   utilisateurs.cUtilisateur = ttutil.cUtilisateur
            NO-ERROR.
        IF AVAILABLE(utilisateurs) THEN DO :
            ASSIGN

            utilisateurs.iVersion = ttutil.iVersion
            utilisateurs.iniveau = ttutil.iniveau
            utilisateurs.cgroupe = ttutil.cGroupe   
            utilisateurs.lDesactive = ttutil.lDesactive   
            utilisateurs.lNonPhysique = ttutil.lNonPhysique   
            utilisateurs.lAdmin = ttutil.lAdmin   
            utilisateurs.cFiller = ttutil.cFiller  
            
            .
            IF gcUtilisateur = utilisateurs.cUtilisateur THEN do:
                gcDroitsUtilisateur = ttutil.cFiller.
                /* repercution des modifications sur le menu général */
                RUN DonneOrdre("GESTION-VERSIONS").
            END.
        END.
        RELEASE utilisateurs.
    END.

    RUN ChargeUtilisateurs.

    IF cUtilisateur_svg <> "" THEN DO:
        FIND FIRST ttutil NO-LOCK
            WHERE  ttutil.cUtilisateur = cUtilisateur_svg
            NO-ERROR.
        IF AVAILABLE(ttutil) THEN REPOSITION brwutilisateurs TO ROWID ROWID(ttutil).
    END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brwModules
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ChargeListeFichiers C-Win 
PROCEDURE ChargeListeFichiers :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    
    DEFINE VARIABLE cLigne AS CHARACTER NO-UNDO.

    DO WITH FRAME frmRepertoires:
        lstFichiers:LIST-ITEMS = ?.
    
        FOR EACH    fichiers NO-LOCK
            WHERE   fichiers.cUtilisateur = ""
            AND     fichiers.cTypeFichier = "SYS"
            AND     fichiers.idSauvegarde = ""
            :
            lstFichiers:ADD-LAST(fichiers.cIdentFichier).
        END.

    END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ChargeSaints C-Win 
PROCEDURE ChargeSaints :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/


    RUN ExtraitFichierDeLaBase("","saints.txt").
                                                   
    /* Ouverture du fichier pour controle format */
    INPUT STREAM gstrEntree FROM VALUE(gcFichierLocal).
    REPEAT:
        IMPORT STREAM gstrEntree cTempo1.
        IF NUM-ENTRIES(cTempo1) <> 3 THEN DO:
            msgErreur("Format de fichier incorrect !%sFormat attendu : jour,mois,libellé%s%sAnnulation du traitement").
            RETURN.
        END.
    END.
    INPUT STREAM gstrEntree CLOSE.

    /* Vidage de la table */
    FOR EACH saints EXCLUSIVE-LOCK : DELETE saints. END.
    RELEASE saints.

    /* Ouverture du fichier pour controle format */
    INPUT STREAM gstrEntree FROM VALUE(gcFichierLocal).
    REPEAT:
        IMPORT STREAM gstrEntree UNFORMATTED cTempo1.
        CREATE saints.
        saints.iJour = integer(ENTRY(1,cTempo1)).
        saints.iMois = integer(ENTRY(2,cTempo1)).
        saints.cNom = (ENTRY(3,cTempo1)).
    END.
    INPUT STREAM gstrEntree CLOSE.

    /* Message d'information de fin de traitement */
    MsgInformation("Chargement des Saints effectué.").
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ChargeUtilisateurs C-Win 
PROCEDURE ChargeUtilisateurs :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    EMPTY TEMP-TABLE ttutil.
    FOR EACH utilisateurs NO-LOCK
        :
        CREATE ttutil.
        ASSIGN
        ttutil.cutilisateur = utilisateurs.cutilisateur
        ttutil.ladmin = utilisateurs.ladmin
        ttutil.lconnecte = utilisateurs.lconnecte
        ttutil.lordres = CAN-FIND (FIRST ordres WHERE ordres.cutilisateur = utilisateurs.cutilisateur)
        ttutil.iVersion = utilisateurs.iVersion
        ttutil.iniveau = utilisateurs.iniveau
        ttutil.lDesactive = utilisateurs.lDesactive
        ttutil.lNonPhysique = utilisateurs.lNonPhysique
        ttutil.cGroupe = utilisateurs.cGroupe
        ttutil.cFiller = utilisateurs.cFiller
        .
    END.
    {&OPEN-QUERY-brwUtilisateurs}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE DechargeVariablesModule C-Win 
PROCEDURE DechargeVariablesModule :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    PUT STREAM gstrSortie UNFORMATTED "winGeneral = " + FormateValeur(STRING(winGeneral)) SKIP.
    PUT STREAM gstrSortie UNFORMATTED "cParametres = " + FormateValeur(STRING(cParametres)) SKIP.
    PUT STREAM gstrSortie UNFORMATTED "cUtilisateur_svg = " + FormateValeur(STRING(cUtilisateur_svg)) SKIP.
    PUT STREAM gstrSortie UNFORMATTED "iX = " + FormateValeur(STRING(iX)) SKIP.
    PUT STREAM gstrSortie UNFORMATTED "iY = " + FormateValeur(STRING(iY)) SKIP.

     PUT STREAM gstrSortie UNFORMATTED FILL("-",80) SKIP.
     PUT STREAM gstrSortie UNFORMATTED SKIP "ttUtil = " SKIP.
     FOR EACH ttUtil:
         PUT STREAM gstrSortie UNFORMATTED "    cUtilisateur = " + FormateValeur(string(ttUtil.cUtilisateur)) SKIP.
         PUT STREAM gstrSortie UNFORMATTED "    lAdmin = " + FormateValeur(string(ttUtil.lAdmin)) SKIP.
         PUT STREAM gstrSortie UNFORMATTED "    lconnecte = " + FormateValeur(string(ttUtil.lconnecte)) SKIP.
         PUT STREAM gstrSortie UNFORMATTED "    lOrdres = " + FormateValeur(string(ttUtil.lOrdres)) SKIP.
         PUT STREAM gstrSortie UNFORMATTED "    iNiveau = " + FormateValeur(string(ttUtil.iniveau)) SKIP.
         PUT STREAM gstrSortie UNFORMATTED "    iVersion = " + FormateValeur(string(ttUtil.iVersion)) SKIP.
         PUT STREAM gstrSortie UNFORMATTED "    cGroupe = " + FormateValeur(string(ttUtil.cGroupe)) SKIP.
         PUT STREAM gstrSortie UNFORMATTED "--------------------" SKIP.
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
        /*MESSAGE cOrdre-in VIEW-AS ALERT-BOX.*/
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
  ENABLE brwModules 
      WITH FRAME frmModules IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-frmModules}
  DISPLAY edtFichiers lstFichiers 
      WITH FRAME frmRepertoires IN WINDOW C-Win.
  ENABLE edtFichiers btnConvAFaire lstFichiers btnFichiersAjouter btnStats 
         btnFichiersSupprimer btnAgenda btnSaints btnVariables 
      WITH FRAME frmRepertoires IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-frmRepertoires}
  ENABLE brwUtilisateurs 
      WITH FRAME frmUtilisateurs IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-frmUtilisateurs}
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
    gcAideModifier = "#INTERDIT#".
    gcAideSupprimer = "#INTERDIT#".
    gcAideImprimer = "#INTERDIT#".
    gcAideRaf = "Recharger l'écran".

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

    /* Chargement des images */
    
    DO WITH FRAME frmModules:    
        ENABLE ALL.

        {&OPEN-QUERY-{&BROWSE-NAME}}
    END.

    DO WITH FRAME frmRepertoires:
        edtFichiers:SCREEN-VALUE = ""
            + "Liste des fichiers de paramètrage"
            + chr(10) + "(Double clic pour voir / modifier le fichier)"
            .
    END.

    RUN ChargeListeFichiers.

    /* Chargement des utilisateurs */
    RUN ChargeUtilisateurs.
    DO WITH FRAME frmUtilisateurs:
        ENABLE ALL.
        IF gcUtilisateur = "ADMIN" THEN DO:
            MENU-ITEM m_Passer_en_mode_ADMIN:LABEL IN MENU POPUP-MENU-brwUtilisateurs = "Revenir en mode '" + gcUtilisateurInitial + "'".
        END.
        ELSE do:
            MENU-ITEM m_Passer_en_mode_ADMIN:LABEL IN MENU POPUP-MENU-brwUtilisateurs = "Passer en mode 'ADMIN'".
        END.
        RUN ChargeUtilisateurs.
        {&OPEN-QUERY-brwUtilisateurs}
        brwUtilisateurs:SENSITIVE = TRUE.
    END.

    ttutil.iVersion:READ-ONLY IN browse brwUtilisateurs = FALSE.
    ttutil.iniveau:READ-ONLY IN browse brwUtilisateurs = FALSE.
    ttutil.cGroupe:READ-ONLY IN browse brwUtilisateurs = FALSE.
    ttutil.lDesactive:READ-ONLY IN browse brwUtilisateurs = FALSE.
    ttutil.lNonPhysique:READ-ONLY IN browse brwUtilisateurs = FALSE.
    ttutil.lAdmin:READ-ONLY IN browse brwUtilisateurs = FALSE.

    iX = C-Win:X + (C-Win:WIDTH-PIXELS / 2).
    iY = C-Win:Y + (C-Win:HEIGHT-PIXELS / 2).

    RUN TopChronoGeneral.
    
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

    ENABLE ALL WITH FRAME frmRepertoires.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE recharger C-Win 
PROCEDURE recharger :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    /* rechargement de la liste des utilisateurs */
    RUN ChargeUtilisateurs.
    {&OPEN-QUERY-brwUtilisateurs}    

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE SuppressionUtilisateur C-Win 
PROCEDURE SuppressionUtilisateur :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER cUtilisateur-in AS CHARACTER NO-UNDO.

    FOR EACH absences EXCLUSIVE-LOCK
        WHERE absences.cUtilisateur = cUtilisateur-in
        :
        DELETE absences.
    END.

    FOR EACH Activite EXCLUSIVE-LOCK
        WHERE Activite.cUtilisateur = cUtilisateur-in
        :
        DELETE Activite.
    END.

    FOR EACH AFaire_Action EXCLUSIVE-LOCK
        WHERE AFaire_Action.cUtilisateur = cUtilisateur-in
        :
        DELETE AFaire_Action.
    END.

    FOR EACH AFaire_Lien EXCLUSIVE-LOCK
        WHERE AFaire_Lien.cUtilisateur = cUtilisateur-in
        :
        DELETE AFaire_Lien.
    END.

    FOR EACH AFaire_Liste EXCLUSIVE-LOCK
        WHERE AFaire_Liste.cUtilisateur = cUtilisateur-in
        :
        DELETE AFaire_Liste.
    END.

    FOR EACH AFaire_PJ EXCLUSIVE-LOCK
        WHERE AFaire_PJ.cUtilisateur = cUtilisateur-in
        :
        DELETE AFaire_PJ.
    END.

    FOR EACH AFaire_Projet EXCLUSIVE-LOCK
        WHERE AFaire_Projet.cUtilisateur = cUtilisateur-in
        :
        DELETE AFaire_Projet.
    END.

    FOR EACH Agenda EXCLUSIVE-LOCK
        WHERE Agenda.cUtilisateur = cUtilisateur-in
        :
        DELETE Agenda.
    END.

    FOR EACH Alarmes EXCLUSIVE-LOCK
        WHERE Alarmes.cUtilisateur = cUtilisateur-in
        :
        DELETE Alarmes.
    END.

    FOR EACH fichiers EXCLUSIVE-LOCK
        WHERE fichiers.cUtilisateur = cUtilisateur-in
        :
        DELETE fichiers.
    END.

    FOR EACH journal EXCLUSIVE-LOCK
        WHERE journal.cUtilisateur = cUtilisateur-in
        :
        DELETE journal.
    END.

    FOR EACH Memo EXCLUSIVE-LOCK
        WHERE Memo.cUtilisateur = cUtilisateur-in
        :
        DELETE Memo.
    END.

    FOR EACH Ordres EXCLUSIVE-LOCK
        WHERE Ordres.cUtilisateur = cUtilisateur-in
        :
        DELETE Ordres.
    END.

    FOR EACH Prefs EXCLUSIVE-LOCK
        WHERE Prefs.cUtilisateur = cUtilisateur-in
        :
        DELETE Prefs.
    END.

    FOR EACH Details EXCLUSIVE-LOCK
        WHERE Details.iddet1 BEGINS cUtilisateur-in
        :
        DELETE Details.
    END.

    FOR EACH Utilisateurs EXCLUSIVE-LOCK
        WHERE Utilisateurs.cUtilisateur = cUtilisateur-in
        :
        DELETE Utilisateurs.
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE TopChronoGeneral C-Win 
PROCEDURE TopChronoGeneral :
/* Gestion du chrono général */
   
    /*RUN recharger.*/
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE TopChronoPartiel C-Win 
PROCEDURE TopChronoPartiel :
/* Gestion du chrono Partiel */


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

