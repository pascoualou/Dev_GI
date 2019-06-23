&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME winMontageVersion
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS winMontageVersion 
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

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER cParam-in AS CHARACTER NO-UNDO.
/* Local Variable Definitions ---                                       */


CREATE WIDGET-POOL.
IF NOT(PROPATH MATCHES("*" + OS-GETENV("DLC") + "\src*")) THEN DO:
    PROPATH = PROPATH + "," + OS-GETENV("DLC") + "\src".
END.

/* ***************************  Definitions  ************************** */
{includes\i_environnement.i NEW GLOBAL}
{includes\i_api.i NEW}
{includes\i_son.i}
{versions\includes\versions.i NEW}


/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
&SCOPED-DEFINE BoutonVisibleEnModeSaisie   "QRF"
&SCOPED-DEFINE BoutonVisibleEnModeVisu   "QRF"
&SCOPED-DEFINE BoutonEtatEnModeSaisie   ""
&SCOPED-DEFINE BoutonEtatEnModeVisu   "QRF"
    
DEFINE VARIABLE cModeAffichageEnCours AS CHARACTER NO-UNDO.
DEFINE VARIABLE iCouleurInitiale AS INTEGER NO-UNDO.

DEFINE VARIABLE iOrdreVersion AS INTEGER NO-UNDO.
DEFINE VARIABLE iOrdreVersionSvg AS INTEGER NO-UNDO.
DEFINE BUFFER rversions FOR versions.


    DEFINE VARIABLE cVersionEnCours AS CHARACTER NO-UNDO.
    
    DEFINE VARIABLE ctests AS CHARACTER NO-UNDO INIT "".
    DEFINE VARIABLE cVersionDepartInit AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cVersionArriveeInit AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cApplicationInit AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cNomFichierInit AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lAuto AS LOGICAL NO-UNDO INIT FALSE.
    DEFINE VARIABLE lHebdo AS LOGICAL NO-UNDO INIT FALSE.
    DEFINE VARIABLE lMuet AS LOGICAL NO-UNDO INIT FALSE.
    DEFINE VARIABLE lVisu AS LOGICAL NO-UNDO INIT FALSE.
    DEFINE VARIABLE lRetour AS LOGICAL NO-UNDO INIT FALSE.
    DEFINE VARIABLE lVientDeMenudev2 AS LOGICAL     NO-UNDO INIT FALSE.


    DEFINE STREAM sSortie.
    DEFINE STREAM sSortieLib.
    DEFINE STREAM sEntree.

DEFINE TEMP-TABLE ttMoulinettes LIKE Moulinettes.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME frmFond

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS cmbDepart cmbArrivee cmbApplication ~
filNomFichier filRepertoireFichier btnRepertoire 
&Scoped-Define DISPLAYED-OBJECTS cmbDepart cmbArrivee cmbApplication ~
filNomFichier filRepertoireFichier 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR winMontageVersion AS WIDGET-HANDLE NO-UNDO.

/* Menu Definitions                                                     */
DEFINE MENU MENU-BAR-winMontageVersion MENUBAR
       MENU-ITEM m_Préférences  LABEL "Préférences"   
       MENU-ITEM m_item         LABEL "?"             .


/* Definitions of the field level widgets                               */
DEFINE BUTTON btnQuitter 
     LABEL "X" 
     SIZE 8 BY 1.91 TOOLTIP "Quitter la génération du fichier de montage de version".

DEFINE BUTTON btnValider 
     LABEL "V" 
     SIZE 8 BY 1.91 TOOLTIP "Valider la saisie et lancer la génération du fichier de montage".

DEFINE BUTTON btnRepertoire 
     LABEL "..." 
     SIZE 4 BY .95.

DEFINE VARIABLE cmbApplication AS CHARACTER FORMAT "X(256)":U INITIAL "ADB" 
     VIEW-AS COMBO-BOX INNER-LINES 3
     LIST-ITEM-PAIRS "ADB","ADB",
                     "PME","PME",
                     "Perso","Perso"
     DROP-DOWN-LIST
     SIZE 24 BY 1 TOOLTIP "Sélectionnez le type d'application (ADB/PME)" NO-UNDO.

DEFINE VARIABLE cmbArrivee AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS COMBO-BOX INNER-LINES 15
     LIST-ITEMS "..." 
     DROP-DOWN-LIST
     SIZE 24 BY 1 TOOLTIP "Sélectionnez la version d'arrivée" NO-UNDO.

DEFINE VARIABLE cmbDepart AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS COMBO-BOX INNER-LINES 15
     LIST-ITEMS "Item 1" 
     DROP-DOWN-LIST
     SIZE 24 BY 1 TOOLTIP "Sélectionnez la version de départ" NO-UNDO.

DEFINE VARIABLE filNomFichier AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 30 BY .95 TOOLTIP "En standard, le fichier se nomme 'vnnnnnn'" NO-UNDO.

DEFINE VARIABLE filRepertoireFichier AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 28 BY .95 TOOLTIP "En standard, le repertoire est %reseau%gi\maj\versions" NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME frmFond
     cmbDepart AT ROW 3.86 COL 45 COLON-ALIGNED NO-LABEL WIDGET-ID 2
     cmbArrivee AT ROW 5.29 COL 45 COLON-ALIGNED NO-LABEL WIDGET-ID 6
     cmbApplication AT ROW 6.71 COL 45 COLON-ALIGNED NO-LABEL WIDGET-ID 20
     filNomFichier AT ROW 8.14 COL 39 COLON-ALIGNED NO-LABEL WIDGET-ID 8
     filRepertoireFichier AT ROW 9.57 COL 37 COLON-ALIGNED NO-LABEL WIDGET-ID 10
     btnRepertoire AT ROW 9.57 COL 67 WIDGET-ID 24
     "Type de version..............................................................." VIEW-AS TEXT
          SIZE 42 BY .71 AT ROW 6.95 COL 5 WIDGET-ID 22
     "Version de départ..............................................................." VIEW-AS TEXT
          SIZE 42 BY .71 AT ROW 4.1 COL 5 WIDGET-ID 12
     "Version d'arrivée..............................................................." VIEW-AS TEXT
          SIZE 42 BY .71 AT ROW 5.52 COL 5 WIDGET-ID 14
     "Nom du fichier..............................................................." VIEW-AS TEXT
          SIZE 36 BY .71 AT ROW 8.38 COL 5 WIDGET-ID 16
     "Répertoire de génération du fichier............................................." VIEW-AS TEXT
          SIZE 34 BY .71 AT ROW 9.81 COL 5 WIDGET-ID 18
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 74.6 BY 9.95 WIDGET-ID 100.

DEFINE FRAME frmBoutons
     btnQuitter AT ROW 1.05 COL 1.2 WIDGET-ID 2
     btnValider AT ROW 1.05 COL 10 WIDGET-ID 6
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1.1
         SIZE 74 BY 2.1 WIDGET-ID 600.


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
  CREATE WINDOW winMontageVersion ASSIGN
         HIDDEN             = YES
         TITLE              = "Génération d'un fichier de montage de version"
         HEIGHT             = 9.91
         WIDTH              = 74.8
         MAX-HEIGHT         = 16
         MAX-WIDTH          = 80
         VIRTUAL-HEIGHT     = 16
         VIRTUAL-WIDTH      = 80
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

ASSIGN {&WINDOW-NAME}:MENUBAR    = MENU MENU-BAR-winMontageVersion:HANDLE.
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW winMontageVersion
  VISIBLE,,RUN-PERSISTENT                                               */
/* REPARENT FRAME */
ASSIGN FRAME frmBoutons:FRAME = FRAME frmFond:HANDLE.

/* SETTINGS FOR FRAME frmBoutons
                                                                        */
/* SETTINGS FOR FRAME frmFond
   FRAME-NAME                                                           */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(winMontageVersion)
THEN winMontageVersion:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME winMontageVersion
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL winMontageVersion winMontageVersion
ON END-ERROR OF winMontageVersion /* Génération d'un fichier de montage de version */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL winMontageVersion winMontageVersion
ON WINDOW-CLOSE OF winMontageVersion /* Génération d'un fichier de montage de version */
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frmBoutons
&Scoped-define SELF-NAME btnQuitter
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnQuitter winMontageVersion
ON CHOOSE OF btnQuitter IN FRAME frmBoutons /* X */
DO:
    APPLY "CLOSE" TO THIS-PROCEDURE.
    IF lAuto THEN QUIT. /*LEAVE.*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frmFond
&Scoped-define SELF-NAME btnRepertoire
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnRepertoire winMontageVersion
ON CHOOSE OF btnRepertoire IN FRAME frmFond /* ... */
DO:
  OS-COMMAND SILENT VALUE("explorer.exe " + filRepertoireFichier:SCREEN-VALUE).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frmBoutons
&Scoped-define SELF-NAME btnValider
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnValider winMontageVersion
ON CHOOSE OF btnValider IN FRAME frmBoutons /* V */
DO:  
    DEFINE VARIABLE lRetour AS LOGICAL NO-UNDO.
    DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO.

    RUN Validation(OUTPUT lRetour).
    
    /* Prevenir l'éventuel programme appelant */
    DO WITH FRAME frmFond:
        IF lRetour THEN do:
            cRetour = ""
                + filNomFichier:SCREEN-VALUE
                + "|" + cmbDepart:SCREEN-VALUE
                + "|" + cmbArrivee:SCREEN-VALUE
                .
            gSauvePreference("RETOUR-MONTAGE",cRetour).
        END.
    END.
    IF lVientDeMenudev2 THEN APPLY "CHOOSE" TO btnQuitter.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frmFond
&Scoped-define SELF-NAME cmbApplication
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cmbApplication winMontageVersion
ON VALUE-CHANGED OF cmbApplication IN FRAME frmFond
DO:
  
    RUN GenereNomFichier.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cmbArrivee
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cmbArrivee winMontageVersion
ON VALUE-CHANGED OF cmbArrivee IN FRAME frmFond
DO:
  RUN GenereNomFichier.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cmbDepart
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cmbDepart winMontageVersion
ON VALUE-CHANGED OF cmbDepart IN FRAME frmFond
DO:
    RUN ChargeComboArrivee(SELF:SCREEN-VALUE).
    RUN GenereNomFichier.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Préférences
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Préférences winMontageVersion
ON CHOOSE OF MENU-ITEM m_Préférences /* Préférences */
DO:
  
    winMontageVersion:SENSITIVE = FALSE.
    RUN VALUE(gcRepertoireExecution + "preferences.w").
    winMontageVersion:SENSITIVE = TRUE.
    RUN ChargePreferences.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK winMontageVersion 


/* ***************************  Main Block  *************************** */


/* Pour les tests */
/*cTests = "AUTO-MUET,11110000,12000000,ADB,PL-Ma_version".*/


/* Set CURRENT-WINDOW: this will parent dialog-boxes and frames.        */
ASSIGN CURRENT-WINDOW                = {&WINDOW-NAME} 
       THIS-PROCEDURE:CURRENT-WINDOW = {&WINDOW-NAME}.

/* The CLOSE event can be used from inside or outside the procedure to  */
/* terminate it.                                                        */
ON CLOSE OF THIS-PROCEDURE 
   RUN disable_UI.

/* Best default for GUI applications is...                              */
PAUSE 0 BEFORE-HIDE.

  /* Décodage des parametres */
  IF cTests <> "" THEN cParam-in = cTests.
  IF NUM-ENTRIES(cParam-in) >= 1 THEN do:
      lHebdo = (ENTRY(1,cParam-in) MATCHES "*HEBDO*").
      lAuto = ((ENTRY(1,cParam-in) MATCHES "*AUTO*") OR lHebdo).
      lMuet = ((ENTRY(1,cParam-in) MATCHES "*MUET*") OR lHebdo).
      lVisu = (ENTRY(1,cParam-in) MATCHES "*VISU*").
      lVientDeMenudev2 = (ENTRY(1,cParam-in) MATCHES "*MENUDEV2*").
  END.
  IF NUM-ENTRIES(cParam-in) >= 2 THEN cVersionDepartInit = ENTRY(2,cParam-in).
  IF NUM-ENTRIES(cParam-in) >= 3 THEN cVersionArriveeInit = ENTRY(3,cParam-in).
  IF NUM-ENTRIES(cParam-in) >= 4 THEN do:
      cApplicationInit = ENTRY(4,cParam-in).
      IF cApplicationInit = "" THEN cApplicationInit = "ADB".
  END.
  IF NUM-ENTRIES(cParam-in) >= 5 THEN cNomFichierInit = ENTRY(5,cParam-in).

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  RUN Initialisation.
  IF lHebdo THEN do:
      RUN DebutHebdo(OUTPUT lRetour).
      IF NOT(lRetour) THEN LEAVE MAIN-BLOCK.
  END.
  IF lAuto THEN DO:
      RUN Automatique.
      IF lHebdo THEN RUN FinHebdo.
      APPLY "CLOSE" TO THIS-PROCEDURE.
  END.
  ELSE DO:
      IF NOT THIS-PROCEDURE:PERSISTENT THEN
        WAIT-FOR CLOSE OF THIS-PROCEDURE.
  END.
END.

/* Sortie si on est entré directement */
IF lHebdo THEN QUIT.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Automatique winMontageVersion 
PROCEDURE Automatique :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE lRetour AS LOGICAL NO-UNDO.

    /* mise à jour automatique des zones de l'écran */
    DO WITH FRAME frmFond:
        cmbDepart:SCREEN-VALUE = cVersionDepartInit.
        RUN chargeComboArrivee(cVersionDepartInit).
        cmbArrivee:SCREEN-VALUE = cVersionArriveeInit.
        cmbApplication:SCREEN-VALUE = cApplicationInit.
        IF cNomFichierInit ="" THEN
            RUN GenereNomFichier.
        ELSE
            FILNomFichier:SCREEN-VALUE = cNomFichierInit.
    END.

    /*
    MESSAGE "Lancement de la génération automatique..."
        VIEW-AS ALERT-BOX.
    */

    RUN Validation(OUTPUT lRetour).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ChargeComboArrivee winMontageVersion 
PROCEDURE ChargeComboArrivee :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER cVersionDepart-in AS CHARACTER NO-UNDO.

    DEFINE VARIABLE cListeVersions AS CHARACTER NO-UNDO.

    FOR EACH    versions    NO-LOCK
        WHERE   versions.iordre > INTEGER(cVersionDepart-in)
        BY versions.iordre DESC
        :
        cListeVersions = cListeVersions
            + "," + versions.cNumeroVersion + "," + STRING(versions.iordre).
    END.

    DO WITH FRAME frmFond:
        /*cmbDepart:LIST-ITEM-PAIRS = SUBSTRING(cListeVersions,2).*/
        cmbArrivee:LIST-ITEM-PAIRS = SUBSTRING(cListeVersions,2).
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ChargeComboDepart winMontageVersion 
PROCEDURE ChargeComboDepart :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    DEFINE VARIABLE cListeVersions AS CHARACTER NO-UNDO.

    FOR EACH    versions    NO-LOCK
        BY versions.iordre DESC
        :
        cListeVersions = cListeVersions
            + "," + versions.cNumeroVersion + "," + STRING(versions.iordre).
    END.

    DO WITH FRAME frmFond:
        cmbDepart:LIST-ITEM-PAIRS = SUBSTRING(cListeVersions,2).
        /*cmbArrivee:LIST-ITEM-PAIRS = SUBSTRING(cListeVersions,2).*/
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ChargePreferences winMontageVersion 
PROCEDURE ChargePreferences :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE DebutHebdo winMontageVersion 
PROCEDURE DebutHebdo :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE OUTPUT PARAMETER lRetour-ou AS LOGICAL NO-UNDO INIT FALSE.

    DEFINE BUFFER versions_depart FOR versions.
    DEFINE BUFFER versions_arrivee FOR versions.

        DEFINE VARIABLE cFichier AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cFichierAbandon AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cFichierMaj AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cFichierMagi AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cTempo AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cTempoOrdre AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cTempoVersion AS CHARACTER NO-UNDO.
        DEFINE VARIABLE iTempoRang AS INTEGER NO-UNDO.

    cFichierAbandon = reseau + "dev\intf\AbandonVersionHebdo".
    /* On commence par effacer le fichier d'abandon */
    OS-DELETE VALUE(cFichierAbandon).

    /* Recherche de la dernière version gi livrée */
    FIND LAST   versions_depart NO-LOCK
        WHERE   versions_depart.lGI
        USE-INDEX ixVersions02
        NO-ERROR.
    IF NOT(AVAILABLE(versions_depart)) THEN DO:
        OUTPUT TO VALUE(cFichierAbandon).
        PUT UNFORMATTED "Dernière version GI introuvable !" SKIP. 
        OUTPUT CLOSE.
        RETURN.
    END.

    /* mémorisation de la version de depart */
    cVersionDepartInit = string(versions_depart.iordre).

    /* Recherche de la dernière version saisie */
    FIND LAST   versions_arrivee NO-LOCK
        WHERE   NOT(versions_arrivee.lGI)
        AND     versions_arrivee.lExclusion = FALSE
        AND     versions_arrivee.iordre > versions_depart.iordre
        USE-INDEX ixVersions02
        NO-ERROR.

    IF not(AVAILABLE(versions_arrivee)) THEN DO:
        /*----
        OUTPUT TO VALUE(cFichierAbandon).
        PUT UNFORMATTED "Dernière version Saisie introuvable !" SKIP. 
        OUTPUT CLOSE.
        RETURN.
        ---- */
        /* Génération automatique de la nouvelle version si elle n'existe pas */
        CREATE versions_arrivee.
        BUFFER-COPY versions_depart EXCEPT iOrdre cNumeroVersion dDateVersion cRepertoireVersion cFiller1 cFiller2
            TO versions_arrivee.
        /* Mise à jour des champs de la version */
        cTempoVersion = versions_depart.cNumeroVersion.
        iTempoRang = integer(ENTRY(3,cTempoVersion,".")) + 1.
        cTempoOrdre = ""
            + string(integer(entry(1,cTempoVersion,".")),"99")
            + string(integer(entry(2,cTempoVersion,".")),"99")
            + string(iTempoRang,"99")
            + "00"
            .
        ENTRY(3,cTempoVersion,".") = STRING(iTempoRang).
        versions_arrivee.cNumeroVersion = cTempoVersion.
        versions_arrivee.iOrdre = INTEGER(cTempoOrdre).
        versions_arrivee.dDateVersion = TODAY.
        versions_arrivee.cRepertoireVersion = SUBSTRING(STRING(YEAR(TODAY),"9999"),4,1) + STRING(MONTH(TODAY),"99") + STRING(DAY(TODAY),"99").
        versions_arrivee.lGi = FALSE.
        /* Au passage, création du répertoire si inexistant */
        IF SEARCH(reseau + "gi\maj\delta\" + versions_arrivee.cRepertoireVersion) = ? THEN DO:
            OS-CREATE-DIR VALUE(reseau + "gi\maj\delta\" + versions_arrivee.cRepertoireVersion).
        END.

    END.

    /* mémorisation de la version d'arrivée */
    cVersionArriveeInit = string(versions_arrivee.iordre).
    iOrdreVersionSvg = versions_arrivee.iordre.
    
    /* Test de cohérence entre les 2 versions */
    IF versions_arrivee.iordre <= versions_depart.iordre THEN DO:
        OUTPUT TO VALUE(cFichierAbandon).
        PUT UNFORMATTED "Pas de nouvelle version : La version ne sera pas générée !" SKIP. 
        OUTPUT CLOSE.
        RETURN.
    END.

    /* Nom du fichier de montage */
    cNomFichierInit = "adb." + STRING(versions_depart.iOrdre / 100,"999999").

    /* Génération du fichier version.maj */
    cFichierMaj = disque + "version\gi_image\gi\exe\version.maj".
    OUTPUT TO VALUE(cFichierMaj).
    PUT UNFORMATTED "Version du : " + string(versions_arrivee.dDateVersion,"99/99/9999") SKIP.
    PUT UNFORMATTED "Numéro     : V" + versions_arrivee.cNumeroVersion SKIP.
    OUTPUT CLOSE.

    /* Génération du fichier magi.txt */
    cFichierMagi = disque + "version\majgi.txt".
    OUTPUT TO VALUE(cFichierMagi).
    PUT UNFORMATTED "La Gestion Intégrale V" + versions_arrivee.cNumeroVersion SKIP.
    PUT UNFORMATTED "ADB#Mise à jour depuis la version " + versions_depart.cNumeroVersion + "#adb." + STRING(versions_depart.iOrdre / 100,"999999") SKIP.
    OUTPUT CLOSE.

    /* Copie des fichiers aux bons endroits */
    cFichier = reseau + "gidev\exe\version".
    IF SEARCH(cFichier) <> ? THEN OS-DELETE VALUE(cFichier).
    OS-COPY VALUE(cFichierMaj) VALUE(cFichier).
    cFichier = reseau + "gi\exe\version".
    IF SEARCH(cFichier) <> ? THEN OS-DELETE VALUE(cFichier).
    OS-COPY VALUE(cFichierMaj) VALUE(cFichier).

    /* A ce niveau, tout est bon */
    lRetour-ou = TRUE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI winMontageVersion  _DEFAULT-DISABLE
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
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(winMontageVersion)
  THEN DELETE WIDGET winMontageVersion.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI winMontageVersion  _DEFAULT-ENABLE
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
  DISPLAY cmbDepart cmbArrivee cmbApplication filNomFichier filRepertoireFichier 
      WITH FRAME frmFond IN WINDOW winMontageVersion.
  ENABLE cmbDepart cmbArrivee cmbApplication filNomFichier filRepertoireFichier 
         btnRepertoire 
      WITH FRAME frmFond IN WINDOW winMontageVersion.
  {&OPEN-BROWSERS-IN-QUERY-frmFond}
  ENABLE btnQuitter btnValider 
      WITH FRAME frmBoutons IN WINDOW winMontageVersion.
  {&OPEN-BROWSERS-IN-QUERY-frmBoutons}
  VIEW winMontageVersion.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE FinHebdo winMontageVersion 
PROCEDURE FinHebdo :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE BUFFER versions_Generee FOR versions.
        
    /* Mise en place des fichiers pour la version hebdomadaire */
    FIND LAST   versions_Generee EXCLUSIVE-LOCK
        WHERE   versions_Generee.iordre = iOrdreVersionSvg
        USE-INDEX ixVersions02
        NO-ERROR.
    IF AVAILABLE(versions_Generee) THEN DO:
        versions_Generee.lGI = TRUE.    
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Forcage winMontageVersion 
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE GenereFichierDetail winMontageVersion 
PROCEDURE GenereFichierDetail :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE GenereFichierMontage winMontageVersion 
PROCEDURE GenereFichierMontage :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE OUTPUT PARAMETER lRetour-ou AS LOGICAL INIT FALSE.

    DEFINE BUFFER VersionDepart FOR versions.
    DEFINE BUFFER VersionArrivee FOR versions.
    DEFINE BUFFER pversions FOR versions.
    DEFINE BUFFER bMoulinettes FOR Moulinettes.

    DEFINE VARIABLE cNomVersion AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cFichier AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cFichierLib AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cFichierRectif AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cFichierMoulinette AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cLigne AS CHARACTER NO-UNDO.
    DEFINE VARIABLE iVersionArrivee AS INTEGER NO-UNDO.
    DEFINE VARIABLE iVersionDepart AS INTEGER NO-UNDO.
    DEFINE VARIABLE lVersionAdb AS LOGICAL NO-UNDO.

    DEFINE VARIABLE lControle AS LOGICAL NO-UNDO INIT TRUE.

    DEFINE VARIABLE cTempo AS CHARACTER NO-UNDO.
    DEFINE VARIABLE iBoucle AS INTEGER NO-UNDO.

    DEFINE VARIABLE cSuffixe AS CHARACTER NO-UNDO.

    DO WITH FRAME frmfond:
        iVersionDepart = INTEGER(cmbDepart:SCREEN-VALUE).
        iVersionArrivee = INTEGER(cmbArrivee:SCREEN-VALUE).


        lControle = (gDonnePreference("PREF-CONTROLEMOULINETTES") = "OUI").

        /* Demande de confirmation */
        IF NOT(lMuet) THEN DO:
            MESSAGE "Confirmez-vous la génération du fichier montage :"
                + chr(10) + "'" + string(iVersionDepart) + "' --> '" + STRING(iVersionArrivee) + "'"
                VIEW-AS ALERT-BOX QUESTION BUTTON YES-NO
                TITLE "Génération fichier montage..."
                UPDATE lReponseFichier AS LOGICAL
                .
            IF not(lReponseFichier) THEN RETURN.
        END.
    
        /* Positionnement sur la version départ */
        FIND LAST   VersionDepart  NO-LOCK
            WHERE   VersionDepart.iordre = iVersionDepart
            NO-ERROR.
        IF NOT(AVAILABLE(VersionDepart)) THEN DO:
            MESSAGE "Version de départ '" + string(iVersionDepart) + "' introuvable !!!"
                + CHR(10) 
                + "Abandon de la procédure."
                VIEW-AS ALERT-BOX ERROR
                TITLE "Génération fichier montage..."
                .
            RETURN.
        END.
    
        /* Positionnement sur la version d'arrivée */
        FIND FIRST  VersionArrivee  NO-LOCK
            WHERE   VersionArrivee.iordre = iVersionArrivee
            NO-ERROR.
        IF NOT(AVAILABLE(VersionArrivee)) THEN DO:
            MESSAGE "Version d'arrivée '" + STRING(iVersionArrivee) + "' introuvable !!!"
                + CHR(10) 
                + "Abandon de la procédure."
                VIEW-AS ALERT-BOX ERROR
                TITLE "Génération fichier montage..."
                .
            RETURN.
        END.
    
        /* ouverture du fichier de sortie */
        cNomVersion = filNomFichier:SCREEN-VALUE.
        cFichier =  filRepertoireFichier:SCREEN-VALUE + "\" + cNomVersion.
        IF lHebdo THEN cFichierLib = filRepertoireFichier:SCREEN-VALUE + "\" + ENTRY(1,cNomVersion,".") + "loc." + ENTRY(2,cNomVersion,".").
    END.
    OUTPUT STREAM sSortie TO VALUE(cFichier).
    IF lHebdo THEN OUTPUT STREAM sSortieLib TO VALUE(cFichierLib).

    lVersionAdb = (cmbApplication:SCREEN-VALUE = "ADB" OR cmbApplication:SCREEN-VALUE = "Perso").

    EMPTY TEMP-TABLE ttmoulinettes.

    FOR EACH    versions    NO-LOCK
        WHERE   versions.iOrdre > iVersionDepart
        AND     versions.iordre <= iVersionArrivee
        BY versions.iordre
        :

        /* Positionnement sur la version précédente */
        FIND LAST   pversions   NO-LOCK
            WHERE   pversions.iordre < versions.iordre
            USE-INDEX ixVersions02
            NO-ERROR.
        IF NOT(AVAILABLE(pversions)) THEN NEXT.

        /* Suffixe des lignes */
        cSuffixe = "v" + SUBstring(STRING(versions.iOrdre),1,6).

        /* entete du fichier */
        PUT STREAM sSortie UNFORMATTED QUOTER("1000 0 000 STRUCTURE" + "_" + cSuffixe) SKIP.
        IF lHebdo THEN PUT STREAM sSortieLib UNFORMATTED QUOTER("1000 0 000 STRUCTURE" + "_" + cSuffixe) SKIP.

        /* Structures */
        IF versions.iCrcSadb <> pversions.iCrcSadb AND lVersionAdb THEN DO:
            PUT STREAM sSortie UNFORMATTED QUOTER("1000 1 001 " + versions.cRepertoireVersion + "/sdelta.df") SKIP.
        END.
        IF versions.iCrcInter <> pversions.iCrcInter THEN DO:
            PUT STREAM sSortie UNFORMATTED QUOTER("1000 1 001 " + versions.cRepertoireVersion + "/idelta.df") SKIP.
        END.
        IF versions.iCrcCompta <> pversions.iCrcCompta THEN DO:
            PUT STREAM sSortie UNFORMATTED QUOTER("1000 1 001 " + versions.cRepertoireVersion + "/cdelta.df") SKIP.
        END.
        IF versions.iCrcTransfert <> pversions.iCrcTransfert AND lVersionAdb THEN DO:
            PUT STREAM sSortie UNFORMATTED QUOTER("1000 1 001 " + versions.cRepertoireVersion + "/tdelta.df") SKIP.
        END.
        IF versions.iCrccadb <> pversions.iCrccadb AND lVersionAdb THEN DO:
            PUT STREAM sSortie UNFORMATTED QUOTER("1000 1 001 " + versions.cRepertoireVersion + "/adelta.df") SKIP.
        END.
        IF versions.iCrcdwh <> pversions.iCrcdwh AND lVersionAdb THEN DO:
            PUT STREAM sSortie UNFORMATTED QUOTER("1000 1 001 " + versions.cRepertoireVersion + "/ddelta.df") SKIP.
        END.
        
        /* Si on vient de menudev2, pas besoin de traiter les bases locales qui sont supposées à jour */
        IF NOT lVientDeMenudev2 THEN DO:
            /* Bases libellé */
            IF versions.iCrcLadb <> pversions.iCrcLadb AND lVersionAdb THEN DO:
                IF lHebdo THEN
                    PUT STREAM sSortieLib UNFORMATTED QUOTER("1000 1 001 " + versions.cRepertoireVersion + "/ladelta.df") SKIP.
                ELSE
                    PUT STREAM sSortie UNFORMATTED QUOTER("1000 1 001 " + versions.cRepertoireVersion + "/ladelta.df") SKIP.
            END.
            IF versions.iCrcwadb <> pversions.iCrcwadb AND lVersionAdb THEN DO:
                IF lHebdo THEN
                    PUT STREAM sSortieLib UNFORMATTED QUOTER("1000 1 001 " + versions.cRepertoireVersion + "/lwdelta.df") SKIP.
                ELSE
                    PUT STREAM sSortie UNFORMATTED QUOTER("1000 1 001 " + versions.cRepertoireVersion + "/lwdelta.df") SKIP.
            END.
            IF versions.iCrclCompta <> pversions.iCrclCompta THEN DO:
                IF lHebdo THEN
                    PUT STREAM sSortieLib UNFORMATTED QUOTER("1000 1 001 " + versions.cRepertoireVersion + "/lcdelta.df") SKIP.
                ELSE
                    PUT STREAM sSortie UNFORMATTED QUOTER("1000 1 001 " + versions.cRepertoireVersion + "/lcdelta.df") SKIP.
            END.
            IF versions.iCrcltrans <> pversions.iCrcltrans AND lVersionAdb THEN DO:
                IF lHebdo THEN
                    PUT STREAM sSortieLib UNFORMATTED QUOTER("1000 1 001 " + versions.cRepertoireVersion + "/ltdelta.df") SKIP.
                ELSE
                    PUT STREAM sSortie UNFORMATTED QUOTER("1000 1 001 " + versions.cRepertoireVersion + "/ltdelta.df") SKIP.
            END.
        END.
        
        /* gestion des delta en plus (sdelta2.df par exemple) */
        IF versions.cFiller2 <> "" THEN DO:
            DO iBoucle = 1 TO NUM-ENTRIES(versions.cFiller2):
                /* au passage, controle du format de saisie */
                cTempo = entry(iBoucle,versions.cFiller2).
                IF NUM-ENTRIES(cTempo,"\") <> 2 THEN DO:
                    MESSAGE "Problème de format sur les deltas manuels de la version '" + versions.cNumeroversion + "'"
                        + CHR(10) + "Abandon du traitement !!!"
                        VIEW-AS ALERT-BOX ERROR
                        TITLE "Controle de saisie des deltas manuels..."
                        .
                    OUTPUT STREAM sSortie CLOSE.
                    /* suppression du bout de fichier généré */
                    OS-DELETE VALUE(cFichier).
                    RETURN.
                END.
                IF lVientDeMenudev2 THEN DO:
                    IF cTempo MATCHES "*ladelta*" THEN NEXT.
                    IF cTempo MATCHES "*lcdelta*" THEN NEXT.
                    IF cTempo MATCHES "*ltdelta*" THEN NEXT.
                    IF cTempo MATCHES "*wadelta*" THEN NEXT.
                END.
                PUT STREAM sSortie UNFORMATTED QUOTER("1000 1 001 " + replace(cTempo,"\","/")) SKIP.
            END.
        END.

        /* Données */
        PUT STREAM sSortie UNFORMATTED QUOTER("2000 0 000 DONNEES" + "_" + cSuffixe) SKIP.
        IF lHebdo THEN PUT STREAM sSortieLib UNFORMATTED QUOTER("2000 0 000 DONNEES" + "_" + cSuffixe) SKIP.

        /* Moulinettes */
        PUT STREAM sSortie UNFORMATTED QUOTER("3000 0 000 EXECUTABLES" + "_" + cSuffixe) SKIP.
        IF lHebdo THEN PUT STREAM sSortieLib UNFORMATTED QUOTER("3000 0 000 EXECUTABLES" + "_" + cSuffixe) SKIP.

        FOR EACH    moulinettes NO-LOCK
            WHERE   moulinettes.cNumeroVersion = versions.cNumeroVersion
            AND     moulinettes.lGestion = lVersionAdb
            BY moulinettes.cRepertoireMoulinette
            BY moulinettes.cNomMoulinette
            :
            /* Vérification d'existence de la moulinette */
            cFichierMoulinette = ""
                + OS-GETENV("Reseau") 
                + "gi\maj\delta\"
                + Moulinettes.cRepertoireMoulinette
                + "\" + moulinettes.cNomMoulinette
                .
            IF lControle AND SEARCH(cFichierMoulinette) = ? THEN DO:
                MESSAGE "Le fichier '" + cFichierMoulinette + "' n'existe pas. Merci de corriger !!"
                    + CHR(10) + "Abandon de la procédure !!!"
                    VIEW-AS ALERT-BOX ERROR
                    TITLE "Contrôle de saisie..."
                    .
                OUTPUT STREAM sSortie CLOSE.
                /* suppression du bout de fichier généré */
                OS-DELETE VALUE(cFichier).
                RETURN.
            END.
                
            /* Moulinette à passer en dernier */
                IF moulinettes.ldernier THEN DO:
                    CREATE ttMoulinettes.
                    BUFFER-COPY moulinettes TO ttmoulinettes.
                END.
                ELSE DO:
                    PUT STREAM sSortie UNFORMATTED QUOTER("3000 1 001 " 
                        + Moulinettes.cRepertoireMoulinette + "/" + moulinettes.cNomMoulinette) SKIP.    
                END.
        END.

        /* scripts */
        PUT STREAM sSortie UNFORMATTED QUOTER("4000 0 000 SCRIPTS" + "_" + cSuffixe) SKIP.
        IF lHebdo THEN PUT STREAM sSortieLib UNFORMATTED QUOTER("4000 0 000 SCRIPTS" + "_" + cSuffixe) SKIP.
    END.

    /* Moulinettes à passer en dernier */
    /* entete du fichier */
    PUT STREAM sSortie UNFORMATTED QUOTER("1000 0 000 STRUCTURE" + "_Dernier") SKIP.
    /* Données */
    PUT STREAM sSortie UNFORMATTED QUOTER("2000 0 000 DONNEES" + "_Dernier") SKIP.
    /* Moulinettes */
    PUT STREAM sSortie UNFORMATTED QUOTER("3000 0 000 EXECUTABLES" + "_Dernier") SKIP.
    FOR EACH    ttmoulinettes NO-LOCK
        BY ttmoulinettes.cRepertoireMoulinette
        BY ttmoulinettes.cNomMoulinette
        :
        PUT STREAM sSortie UNFORMATTED QUOTER("3000 1 001 " 
            + ttMoulinettes.cRepertoireMoulinette + "/" + ttmoulinettes.cNomMoulinette) SKIP.    
    END.
    /* scripts */
    PUT STREAM sSortie UNFORMATTED QUOTER("4000 0 000 SCRIPTS" + "_Dernier") SKIP.

    /* Section rectifs générales */
    cFichierRectif = "vrectifg".
    IF NOT(lVersionAdb) THEN cFichierRectif = "vrectifc".
    INPUT STREAM sEntree FROM VALUE(gcRepertoireRessourcesPrivees + "fichiers\" + cFichierRectif).
    REPEAT:
        IMPORT STREAM sEntree UNFORMATTED cLigne.
        PUT STREAM sSortie UNFORMATTED cLigne SKIP.
    END.
    INPUT STREAM sEntree CLOSE.

    /* Fermeture du fichier */
    OUTPUT STREAM sSortie CLOSE.

    /* Avertissement + ouverture du fichier */
    IF NOT(lMuet)  AND NOT(lVientDeMenudev2) THEN DO:
        MESSAGE "Fichier '" + cFichier + "' généré."
            VIEW-AS ALERT-BOX INFORMATION
            TITLE "Génération fichier montage..."
            .
    END.

    IF (not(lAuto) OR (lAuto AND lVisu)) AND NOT(lVientDeMenudev2)  THEN
        OS-COMMAND NO-WAIT VALUE("notepad.exe " + cFichier).

    lRetour-ou = TRUE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE GenereNomFichier winMontageVersion 
PROCEDURE GenereNomFichier :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    
    DEFINE VARIABLE cNomFichier AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cVersionDepart AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cVersionArrivee AS CHARACTER NO-UNDO.

    DO WITH FRAME frmfond:
        IF cmbDepart:SCREEN-VALUE = ? OR cmbDepart:SCREEN-VALUE = "" THEN RETURN.
        IF cmbArrivee:SCREEN-VALUE = ? OR cmbArrivee:SCREEN-VALUE = "" THEN RETURN.
        IF cmbApplication:SCREEN-VALUE = ? OR cmbApplication:SCREEN-VALUE = "" THEN RETURN.
    
        cVersionDepart = SUBSTRING(cmbDepart:SCREEN-VALUE,1,4).
        cVersionArrivee = SUBSTRING(cmbArrivee:SCREEN-VALUE,1,4).

        /* Cas ou on reste dans la meme version de bases */
        IF cVersionArrivee = cVersionDepart THEN DO:
            cVersionDepart = SUBSTRING(cmbDepart:SCREEN-VALUE,1,6).
            cVersionArrivee = SUBSTRING(cmbArrivee:SCREEN-VALUE,1,6).
        END.

        IF cmbApplication:SCREEN-VALUE <> "Perso" THEN DO:
            cNomFichier = ""
                + cmbApplication:SCREEN-VALUE
                + "-"
                + cVersionDepart
                + "-"
                + cVersionArrivee
                .
            filNomFichier:SENSITIVE = TRUE /*FALSE*/.
        END.
        ELSE DO:
            cNomFichier = ""
                + "version"
                .
            filNomFichier:SENSITIVE = TRUE.
        END.

        filNomFichier:SCREEN-VALUE = cNomFichier.
    END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Initialisation winMontageVersion 
PROCEDURE Initialisation :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  
  /* Gestion des images des boutons */
  DO WITH FRAME frmBoutons:
      btnQuitter:LOAD-IMAGE(gcRepertoireRessourcesPrivees + "sortie.ico").
      btnQuitter:LOAD-IMAGE-INSENSITIVE(gcRepertoireRessourcesPrivees + "sortie-off.ico").
      btnValider:LOAD-IMAGE(gcRepertoireRessourcesPrivees + "ok.ico").
      btnValider:LOAD-IMAGE-INSENSITIVE(gcRepertoireRessourcesPrivees + "ok-off.ico").
        
  END.

  /* chargement des 2 combos des versions */
  RUN ChargeComboDepart.

  DO WITH FRAME frmfond:

      /* le répertoire de génération est toujours insensitif */
      filRepertoirefichier:READ-ONLY = TRUE.
      filRepertoirefichier:SCREEN-VALUE = gRemplaceVariables(gcRepertoireMontage).
      filNomFichier:SENSITIVE = FALSE.

      IF lVientDeMenudev2 AND cVersionDepartInit <> "" THEN do:
          /* Vérification d'existence de la version demandée */
          FIND FIRST    versions    NO-LOCK
            WHERE       versions.iordre = INTEGER(cVersionDepartInit)
            NO-ERROR.
          IF NOT(AVAILABLE(versions)) THEN DO:
            MESSAGE "La version de départ '" + cVersionDepartInit + "' est inconnue !!!"
                + CHR(10) + "Veuillez la sélectionner manuellement SVP..."
                VIEW-AS ALERT-BOX ERROR.
          END.
          ELSE DO:
              cmbdepart:SCREEN-VALUE = cVersionDepartInit.
              cmbdepart:SENSITIVE = FALSE.
              IF cmbdepart:SCREEN-VALUE = cmbdepart:ENTRY(1) THEN DO:
                  MESSAGE "Il n'y a pas de version supérieure à la version en cours de la base."
                       VIEW-AS ALERT-BOX INFORMATION.
              END.
              ELSE DO:
                  RUN ChargeComboArrivee(cVersionDepartInit).
              END.
         END.
      END.
  END.


  gSauvePreference("RETOUR-MONTAGE","").

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Validation winMontageVersion 
PROCEDURE Validation :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE OUTPUT PARAMETER lRetour-ou AS LOGICAL INIT FALSE.

    DEFINE VARIABLE iVersionDepart AS INTEGER   NO-UNDO.
    DEFINE VARIABLE iVersionArrivee AS INTEGER   NO-UNDO.

    DEFINE VARIABLE lErreur AS LOGICAL NO-UNDO INIT FALSE.
    DEFINE VARIABLE cErreur AS CHARACTER NO-UNDO INIT "".
    DEFINE VARIABLE lAbandon AS LOGICAL NO-UNDO INIT FALSE.

    DO WITH FRAME frmfond:
        iVersionDepart = INTEGER(cmbDepart:SCREEN-VALUE).
        iVersionArrivee = INTEGER(cmbArrivee:SCREEN-VALUE).
    END.

    IF not(lAbandon) THEN DO:
        IF iVersionDepart = ? THEN DO:
            lErreur = TRUE.
            cErreur = cErreur 
                    + CHR(10) + "- La version de départ est obligatoire."
                    .
        END.
        IF iVersionArrivee = ? THEN DO:
            lErreur = TRUE.
            cErreur = cErreur 
                    + CHR(10) + "- La version d'arrivée est obligatoire."
                    .
        END.
        IF iVersionArrivee <= iVersionDepart THEN DO:
            lErreur = TRUE.
            cErreur = cErreur 
                    + CHR(10) + "- La version d'arrivée doit être supérieure à la version de départ."
                    .
        END.
        IF filNomFichier:SCREEN-VALUE = "" THEN DO:
            lErreur = TRUE.
            cErreur = cErreur 
                    + CHR(10) + "- Vous devez saisir le nom du fichier de montage"
                    .
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
   
    /* ce stade, la génération du fichier peut se faire */
    RUN GenereFichierMontage(OUTPUT lRetour-ou).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

