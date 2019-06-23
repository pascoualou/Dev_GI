&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME frmPrefs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS frmPrefs 
/*------------------------------------------------------------------------

  File: 

  Description: 

  Input Parameters:
      

  Output Parameters:
      <none>

  Author: 

  Created: 
------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

    DEFINE INPUT PARAMETER cIdentModule-in AS CHARACTER NO-UNDO.

    {includes\i_environnement.i}
    {includes\i_dialogue.i}
    {menudev2\includes\menudev2.i}

    DEFINE VARIABLE cListeRepertoiresAdb AS CHARACTER NO-UNDO.

    DEFINE VARIABLE lInitialiser    AS LOGICAL  NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME frmPrefs

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_PrefsGenerales Btn_Cancel 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_Cancel AUTO-GO 
     LABEL "Retour" 
     SIZE 133 BY 1.14
     BGCOLOR 8 .

DEFINE BUTTON Btn_PrefsGenerales 
     LABEL "Préférences générales" 
     SIZE 31 BY 1.14
     BGCOLOR 8 .

DEFINE BUTTON BtnFicCli 
     LABEL "..." 
     SIZE 4 BY .95 TOOLTIP "Récupérer les infos d'un fichier".

DEFINE BUTTON BtnFicPrec 
     LABEL "..." 
     SIZE 4 BY .95 TOOLTIP "Récupérer les infos d'un fichier".

DEFINE BUTTON BtnFicSpe 
     LABEL "..." 
     SIZE 4 BY .95 TOOLTIP "Récupérer les infos d'un fichier".

DEFINE BUTTON BtnFicSuiv 
     LABEL "..." 
     SIZE 4 BY .95 TOOLTIP "Récupérer les infos d'un fichier".

DEFINE VARIABLE cmbCompression AS CHARACTER FORMAT "X(256)":U 
     LABEL "Mode de compression 7zip lors des sauvegardes" 
     VIEW-AS COMBO-BOX INNER-LINES 6
     LIST-ITEM-PAIRS "Sans (Stockage)","0",
                     "Faible (Rapide)","1",
                     "Intermédiaire","3",
                     "Normale (Par défaut)","5",
                     "Maximum (Lent)","7",
                     "Ultra (Très lent)","9"
     DROP-DOWN-LIST
     SIZE 30 BY 1 NO-UNDO.

DEFINE VARIABLE edtConnexCli AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 78 BY 3.1 DROP-TARGET NO-UNDO.

DEFINE VARIABLE edtConnexPrec AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 78 BY 3.1 DROP-TARGET NO-UNDO.

DEFINE VARIABLE edtConnexSpe AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 78 BY 3.1 DROP-TARGET NO-UNDO.

DEFINE VARIABLE edtConnexSuiv AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 78 BY 3.1 DROP-TARGET NO-UNDO.

DEFINE VARIABLE filBases AS CHARACTER FORMAT "X(256)":U 
     LABEL "Répertoire de stockage des bases de l'application" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 29 BY .95 NO-UNDO.

DEFINE VARIABLE filMotDePasse AS CHARACTER FORMAT "X(256)":U 
     LABEL "Votre mot de passe..................." 
     VIEW-AS FILL-IN NATIVE 
     SIZE 34 BY 1 NO-UNDO.

DEFINE VARIABLE filParamCadb AS CHARACTER FORMAT "X(256)":U 
     LABEL "Spécifique CADB........." 
     VIEW-AS FILL-IN NATIVE 
     SIZE 42 BY 1 NO-UNDO.

DEFINE VARIABLE filParamCompta AS CHARACTER FORMAT "X(256)":U 
     LABEL "Spécifique COMPTA...." 
     VIEW-AS FILL-IN NATIVE 
     SIZE 42 BY 1 NO-UNDO.

DEFINE VARIABLE filParamDwh AS CHARACTER FORMAT "X(256)":U 
     LABEL "Spécifique DWH.........." 
     VIEW-AS FILL-IN NATIVE 
     SIZE 42 BY 1 NO-UNDO.

DEFINE VARIABLE filParamInter AS CHARACTER FORMAT "X(256)":U 
     LABEL "Spécifique INTER........" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 42 BY 1 NO-UNDO.

DEFINE VARIABLE filParamLadb AS CHARACTER FORMAT "X(256)":U 
     LABEL "Spécifique LADB........." 
     VIEW-AS FILL-IN NATIVE 
     SIZE 42 BY 1 NO-UNDO.

DEFINE VARIABLE filParamLcompta AS CHARACTER FORMAT "X(256)":U 
     LABEL "Spécifique LCOMPTA." 
     VIEW-AS FILL-IN NATIVE 
     SIZE 42 BY 1 NO-UNDO.

DEFINE VARIABLE filParamLtrans AS CHARACTER FORMAT "X(256)":U 
     LABEL "Spécifique LTRANS...." 
     VIEW-AS FILL-IN NATIVE 
     SIZE 42 BY 1 NO-UNDO.

DEFINE VARIABLE filParamSadb AS CHARACTER FORMAT "X(256)":U 
     LABEL "Spécifique SADB........." 
     VIEW-AS FILL-IN NATIVE 
     SIZE 42 BY 1 NO-UNDO.

DEFINE VARIABLE filParamStandard AS CHARACTER FORMAT "X(256)":U 
     LABEL "Standard" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 42 BY 1 NO-UNDO.

DEFINE VARIABLE filParamTransfer AS CHARACTER FORMAT "X(256)":U 
     LABEL "Spécifique TRANSFER" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 42 BY 1 NO-UNDO.

DEFINE VARIABLE filParamWadb AS CHARACTER FORMAT "X(256)":U 
     LABEL "Spécifique WADB......." 
     VIEW-AS FILL-IN NATIVE 
     SIZE 42 BY 1 NO-UNDO.

DEFINE VARIABLE filReseauCli AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 21 BY .95 NO-UNDO.

DEFINE VARIABLE filReseauPrec AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 21 BY .95 NO-UNDO.

DEFINE VARIABLE filReseauSpe AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 21 BY .95 NO-UNDO.

DEFINE VARIABLE filReseauSuiv AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 21 BY .95 NO-UNDO.

DEFINE VARIABLE filUtilisateur AS CHARACTER FORMAT "X(256)":U 
     LABEL "Votre nom d'utilisateur Windows" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 34 BY 1 NO-UNDO.

DEFINE RECTANGLE RECT-10
     EDGE-PIXELS 4 GRAPHIC-EDGE  NO-FILL   
     SIZE 71 BY 3.57.

DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 4 GRAPHIC-EDGE  NO-FILL   
     SIZE 157 BY 16.67.

DEFINE RECTANGLE RECT-9
     EDGE-PIXELS 4 GRAPHIC-EDGE  NO-FILL   
     SIZE 157 BY 9.52.

DEFINE VARIABLE tglclientini AS LOGICAL INITIAL no 
     LABEL "Positionnement de MaGI sur la référence à l'ouverture de la base (client.ini)" 
     VIEW-AS TOGGLE-BOX
     SIZE 80 BY .95 NO-UNDO.

DEFINE VARIABLE tglClientServeur AS LOGICAL INITIAL no 
     LABEL "Mode client serveur pour l'application DEV (disque <> reseau)" 
     VIEW-AS TOGGLE-BOX
     SIZE 66 BY .95 NO-UNDO.

DEFINE VARIABLE tglConnexCli AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .81 NO-UNDO.

DEFINE VARIABLE tglConnexPrec AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .81 NO-UNDO.

DEFINE VARIABLE tglConnexSpe AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .81 NO-UNDO.

DEFINE VARIABLE tglConnexSuiv AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .81 NO-UNDO.

DEFINE VARIABLE tglCouleurProvenance AS LOGICAL INITIAL no 
     LABEL "Gérer la couleur de la base en fonction de sa situation et non en fonction de son état" 
     VIEW-AS TOGGLE-BOX
     SIZE 84 BY .95 NO-UNDO.

DEFINE VARIABLE tglFermerTout AS LOGICAL INITIAL no 
     LABEL "~"Arrêter toutes les bases~" s'applique sur toutes les bases et non seulement celles de la liste en cours" 
     VIEW-AS TOGGLE-BOX
     SIZE 101 BY .95 NO-UNDO.

DEFINE VARIABLE tglFiltreImmediat AS LOGICAL INITIAL no 
     LABEL "Appliquer les filtres immédiatement" 
     VIEW-AS TOGGLE-BOX
     SIZE 79 BY .95 NO-UNDO.

DEFINE VARIABLE tglLibAuto AS LOGICAL INITIAL no 
     LABEL "Ouverture/fermeture automatique des bases libellé" 
     VIEW-AS TOGGLE-BOX
     SIZE 55 BY .95 NO-UNDO.

DEFINE VARIABLE tglLocalCli AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .81 NO-UNDO.

DEFINE VARIABLE tglLocalPrec AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .81 NO-UNDO.

DEFINE VARIABLE tglLocalSPe AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .81 NO-UNDO.

DEFINE VARIABLE tglLocalSuiv AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .81 NO-UNDO.

DEFINE VARIABLE tglPartage AS LOGICAL INITIAL no 
     LABEL "Lancer la vérification du partage à intervalles réguliers" 
     VIEW-AS TOGGLE-BOX
     SIZE 80 BY .95 NO-UNDO.

DEFINE VARIABLE tglPasLocal AS LOGICAL INITIAL no 
     LABEL "Ne pas remplacer les bases libellé dans le fichier cnx pour les bases non locales" 
     VIEW-AS TOGGLE-BOX
     SIZE 79 BY .95 NO-UNDO.

DEFINE VARIABLE tglRafManuel AS LOGICAL INITIAL no 
     LABEL "Rafraîchissement manuel de la liste des bases" 
     VIEW-AS TOGGLE-BOX
     SIZE 67.6 BY .95 NO-UNDO.

DEFINE VARIABLE tglServeurCli AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .81 NO-UNDO.

DEFINE VARIABLE tglServeurPrec AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .81 NO-UNDO.

DEFINE VARIABLE tglServeurSPE AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .81 NO-UNDO.

DEFINE VARIABLE tglServeurSuiv AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .81 NO-UNDO.

DEFINE VARIABLE tglSpecifCadb AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .81 NO-UNDO.

DEFINE VARIABLE tglSpecifCompta AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .81 NO-UNDO.

DEFINE VARIABLE tglSpecifDwh AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .81 NO-UNDO.

DEFINE VARIABLE tglSpecifInter AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .81 NO-UNDO.

DEFINE VARIABLE tglSpecifLadb AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .81 NO-UNDO.

DEFINE VARIABLE tglSpecifLcompta AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .81 NO-UNDO.

DEFINE VARIABLE tglSpecifLtrans AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .81 NO-UNDO.

DEFINE VARIABLE tglSpecifSadb AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .81 NO-UNDO.

DEFINE VARIABLE tglSpecifTransfer AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .81 NO-UNDO.

DEFINE VARIABLE tglSpecifWadb AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .81 NO-UNDO.

DEFINE VARIABLE tglSupprimeCnxAdb AS LOGICAL INITIAL no 
     LABEL "Suppression des fichiers cnx... et adb... à la suppression de la base" 
     VIEW-AS TOGGLE-BOX
     SIZE 80 BY .95 NO-UNDO.

DEFINE VARIABLE tglSupprimeLK AS LOGICAL INITIAL no 
     LABEL "Suppression des fichiers ~".lk~" au démarrage de menudev2" 
     VIEW-AS TOGGLE-BOX
     SIZE 80 BY .95 NO-UNDO.

DEFINE VARIABLE tglUtilisateurs AS LOGICAL INITIAL no 
     LABEL "Permettre aux utilisateurs de récupérer une sauvegarde de base" 
     VIEW-AS TOGGLE-BOX
     SIZE 65 BY .81 NO-UNDO.

DEFINE VARIABLE tglVersionProgress AS LOGICAL INITIAL no 
     LABEL "Calcul de la version Progress des bases au démarrage de menudev2" 
     VIEW-AS TOGGLE-BOX
     SIZE 80 BY .95 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME frmPrefs
     Btn_PrefsGenerales AT ROW 28.38 COL 3 WIDGET-ID 2
     Btn_Cancel AT ROW 28.38 COL 35
     SPACE(1.59) SKIP(0.18)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Préférences xxx".

DEFINE FRAME frmModule
     tglRafManuel AT ROW 1.48 COL 4 WIDGET-ID 52
     filBases AT ROW 1.48 COL 128 COLON-ALIGNED WIDGET-ID 16
     cmbCompression AT ROW 2.67 COL 127 COLON-ALIGNED WIDGET-ID 48
     tglPasLocal AT ROW 4.33 COL 4 WIDGET-ID 106
     tglFermerTout AT ROW 5.29 COL 4 WIDGET-ID 184
     tglFiltreImmediat AT ROW 6.24 COL 4 WIDGET-ID 108
     tglCouleurProvenance AT ROW 7.19 COL 4 WIDGET-ID 114
     tglLibAuto AT ROW 8.14 COL 4 WIDGET-ID 116
     tglclientini AT ROW 9.1 COL 4 WIDGET-ID 242
     tglPartage AT ROW 10.05 COL 4 WIDGET-ID 246
     tglUtilisateurs AT ROW 10.76 COL 88 WIDGET-ID 172
     tglSupprimeLK AT ROW 11 COL 4 WIDGET-ID 276
     tglSupprimeCnxAdb AT ROW 11.95 COL 4 WIDGET-ID 324
     filUtilisateur AT ROW 11.95 COL 119 COLON-ALIGNED WIDGET-ID 164
     tglVersionProgress AT ROW 12.91 COL 4 WIDGET-ID 326
     filMotDePasse AT ROW 13.14 COL 119 COLON-ALIGNED WIDGET-ID 174 PASSWORD-FIELD 
     filReseauPrec AT ROW 17.71 COL 42 COLON-ALIGNED NO-LABEL WIDGET-ID 154
     edtConnexPrec AT ROW 17.71 COL 75 NO-LABEL WIDGET-ID 192
     BtnFicPrec AT ROW 17.71 COL 154 WIDGET-ID 208
     tglLocalPrec AT ROW 17.81 COL 21 WIDGET-ID 136
     tglServeurPrec AT ROW 17.81 COL 34 WIDGET-ID 142
     tglConnexPrec AT ROW 17.81 COL 70 WIDGET-ID 194
     filReseauCli AT ROW 21.29 COL 42 COLON-ALIGNED NO-LABEL WIDGET-ID 158
     edtConnexCli AT ROW 21.29 COL 75 NO-LABEL WIDGET-ID 196
     BtnFicCli AT ROW 21.29 COL 154 WIDGET-ID 210
     tglLocalCli AT ROW 21.38 COL 21 WIDGET-ID 146
     tglServeurCli AT ROW 21.38 COL 34 WIDGET-ID 140
     tglConnexCli AT ROW 21.38 COL 70 WIDGET-ID 198
     filReseauSuiv AT ROW 24.86 COL 42 COLON-ALIGNED NO-LABEL WIDGET-ID 156
     edtConnexSuiv AT ROW 24.86 COL 75 NO-LABEL WIDGET-ID 200
     BtnFicSuiv AT ROW 24.86 COL 154 WIDGET-ID 212
     tglLocalSuiv AT ROW 24.95 COL 21 WIDGET-ID 144
     tglServeurSuiv AT ROW 24.95 COL 34 WIDGET-ID 138
     tglConnexSuiv AT ROW 24.95 COL 70 WIDGET-ID 202
     filReseauSpe AT ROW 28.67 COL 42 COLON-ALIGNED NO-LABEL WIDGET-ID 176
     edtConnexSpe AT ROW 28.67 COL 75 NO-LABEL WIDGET-ID 204
     BtnFicSpe AT ROW 28.67 COL 154 WIDGET-ID 214
     tglLocalSPe AT ROW 28.76 COL 21 WIDGET-ID 180
     tglServeurSPE AT ROW 28.76 COL 34 WIDGET-ID 182
     tglConnexSpe AT ROW 28.76 COL 70 WIDGET-ID 206
     filParamStandard AT ROW 33.38 COL 61 COLON-ALIGNED WIDGET-ID 330
     tglSpecifSadb AT ROW 34.95 COL 5.8 WIDGET-ID 356
     filParamSadb AT ROW 34.86 COL 31 COLON-ALIGNED WIDGET-ID 336
     tglSpecifCompta AT ROW 36.14 COL 5.8 WIDGET-ID 358
     filParamCompta AT ROW 36.05 COL 31 COLON-ALIGNED WIDGET-ID 338
     tglSpecifCadb AT ROW 37.33 COL 5.8 WIDGET-ID 360
     filParamCadb AT ROW 37.24 COL 31 COLON-ALIGNED WIDGET-ID 340
     tglSpecifInter AT ROW 38.52 COL 5.8 WIDGET-ID 362
     filParamInter AT ROW 38.43 COL 31 COLON-ALIGNED WIDGET-ID 342
     tglSpecifTransfer AT ROW 39.71 COL 5.8 WIDGET-ID 364
     filParamTransfer AT ROW 39.62 COL 31 COLON-ALIGNED WIDGET-ID 344
     tglSpecifDwh AT ROW 40.91 COL 5.8 WIDGET-ID 366
     filParamDwh AT ROW 40.81 COL 31 COLON-ALIGNED WIDGET-ID 346
     tglSpecifLadb AT ROW 36.1 COL 87 WIDGET-ID 368
     filParamLadb AT ROW 36 COL 112.4 COLON-ALIGNED WIDGET-ID 348
     tglSpecifLcompta AT ROW 37.29 COL 87 WIDGET-ID 370
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SCROLLABLE SIZE 167 BY 45.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME frmModule
     filParamLcompta AT ROW 37.19 COL 112.4 COLON-ALIGNED WIDGET-ID 350
     tglSpecifLtrans AT ROW 38.48 COL 87 WIDGET-ID 372
     filParamLtrans AT ROW 38.38 COL 112.4 COLON-ALIGNED WIDGET-ID 354
     tglSpecifWadb AT ROW 40.14 COL 87 WIDGET-ID 374
     filParamWadb AT ROW 40.05 COL 112.4 COLON-ALIGNED WIDGET-ID 352
     tglClientServeur AT ROW 14.57 COL 4 WIDGET-ID 382
     "(Sinon, le calcul sera manuel via le menu popup de la liste des bases)" VIEW-AS TEXT
          SIZE 69 BY .71 AT ROW 13.86 COL 7 WIDGET-ID 328
          FGCOLOR 9 
     "Client/Serveur" VIEW-AS TEXT
          SIZE 16 BY .95 AT ROW 16.62 COL 28 WIDGET-ID 128
     "Mode de fonctionnement de l'application MaGI" VIEW-AS TEXT
          SIZE 46 BY .95 AT ROW 15.52 COL 5 WIDGET-ID 334
     "Actif" VIEW-AS TEXT
          SIZE 6 BY .71 AT ROW 34.1 COL 5 WIDGET-ID 378
          FONT 6
     "Actif" VIEW-AS TEXT
          SIZE 6 BY .71 AT ROW 35.29 COL 86 WIDGET-ID 380
          FONT 6
     "SUIV" VIEW-AS TEXT
          SIZE 8 BY .95 AT ROW 24.95 COL 6 WIDGET-ID 152
     "CLI" VIEW-AS TEXT
          SIZE 8 BY .95 AT ROW 21.38 COL 6 WIDGET-ID 150
     "Version" VIEW-AS TEXT
          SIZE 8 BY .95 AT ROW 16.62 COL 5 WIDGET-ID 124
     "Paramètres de démarrage des serveurs" VIEW-AS TEXT
          SIZE 39 BY .95 AT ROW 32.43 COL 4 WIDGET-ID 122
     "Local" VIEW-AS TEXT
          SIZE 8 BY .95 AT ROW 16.62 COL 19 WIDGET-ID 126
     "PREC" VIEW-AS TEXT
          SIZE 8 BY .95 AT ROW 17.81 COL 6 WIDGET-ID 148
     "SPE" VIEW-AS TEXT
          SIZE 8 BY .95 AT ROW 28.76 COL 6 WIDGET-ID 178
     "Toujours utiliser la connexion aux bases libellés suivante :" VIEW-AS TEXT
          SIZE 88 BY .95 AT ROW 16.62 COL 70 WIDGET-ID 188
     "Variable Reseau" VIEW-AS TEXT
          SIZE 16 BY .95 AT ROW 16.62 COL 47 WIDGET-ID 130
     RECT-10 AT ROW 11.24 COL 87 WIDGET-ID 166
     RECT-8 AT ROW 15.91 COL 3 WIDGET-ID 160
     RECT-9 AT ROW 32.91 COL 3 WIDGET-ID 332
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SCROLLABLE SIZE 167 BY 45
         TITLE "Préférences du module : xxx".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* REPARENT FRAME */
ASSIGN FRAME frmModule:FRAME = FRAME frmPrefs:HANDLE.

/* SETTINGS FOR FRAME frmModule
   Custom                                                               */
ASSIGN 
       FRAME frmModule:HIDDEN           = TRUE
       FRAME frmModule:HEIGHT           = 26.91
       FRAME frmModule:WIDTH            = 167.

/* SETTINGS FOR DIALOG-BOX frmPrefs
   NOT-VISIBLE FRAME-NAME                                               */

DEFINE VARIABLE XXTABVALXX AS LOGICAL NO-UNDO.

ASSIGN XXTABVALXX = FRAME frmModule:MOVE-BEFORE-TAB-ITEM (Btn_PrefsGenerales:HANDLE IN FRAME frmPrefs)
/* END-ASSIGN-TABS */.

ASSIGN 
       FRAME frmPrefs:SCROLLABLE       = FALSE
       FRAME frmPrefs:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME frmPrefs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL frmPrefs frmPrefs
ON WINDOW-CLOSE OF FRAME frmPrefs /* Préférences xxx */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frmModule
&Scoped-define SELF-NAME BtnFicCli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BtnFicCli frmPrefs
ON CHOOSE OF BtnFicCli IN FRAME frmModule /* ... */
DO:
    DEFINE VARIABLE cResultat AS CHARACTER NO-UNDO.
    RUN ExtractionFichier(OUTPUT cResultat).
    IF cResultat = "" THEN RETURN.
    edtConnexCli:SCREEN-VALUE = cResultat.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BtnFicPrec
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BtnFicPrec frmPrefs
ON CHOOSE OF BtnFicPrec IN FRAME frmModule /* ... */
DO:
    DEFINE VARIABLE cResultat AS CHARACTER NO-UNDO.
    RUN ExtractionFichier(OUTPUT cResultat).
    IF cResultat = "" THEN RETURN.
    edtConnexPrec:SCREEN-VALUE = cResultat.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BtnFicSpe
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BtnFicSpe frmPrefs
ON CHOOSE OF BtnFicSpe IN FRAME frmModule /* ... */
DO:
    DEFINE VARIABLE cResultat AS CHARACTER NO-UNDO.
    RUN ExtractionFichier(OUTPUT cResultat).
    IF cResultat = "" THEN RETURN.
    edtConnexSpe:SCREEN-VALUE = cResultat.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BtnFicSuiv
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BtnFicSuiv frmPrefs
ON CHOOSE OF BtnFicSuiv IN FRAME frmModule /* ... */
DO:
    DEFINE VARIABLE cResultat AS CHARACTER NO-UNDO.
    RUN ExtractionFichier(OUTPUT cResultat).
    IF cResultat = "" THEN RETURN.
    edtConnexSuiv:SCREEN-VALUE = cResultat.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frmPrefs
&Scoped-define SELF-NAME Btn_PrefsGenerales
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_PrefsGenerales frmPrefs
ON CHOOSE OF Btn_PrefsGenerales IN FRAME frmPrefs /* Préférences générales */
DO:
  RUN DonneOrdre("PREFS-GENERALES").
  APPLY "CHOOSE" TO Btn_Cancel.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frmModule
&Scoped-define SELF-NAME cmbCompression
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cmbCompression frmPrefs
ON VALUE-CHANGED OF cmbCompression IN FRAME frmModule /* Mode de compression 7zip lors des sauvegardes */
DO:
   SauvePreference("PREF-COMPRESSION",cmbCompression:SCREEN-VALUE).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME edtConnexCli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL edtConnexCli frmPrefs
ON LEAVE OF edtConnexCli IN FRAME frmModule
DO:
  
    RUN SauveZonesSaisie.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME edtConnexPrec
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL edtConnexPrec frmPrefs
ON LEAVE OF edtConnexPrec IN FRAME frmModule
DO:
  
    RUN SauveZonesSaisie.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME edtConnexSpe
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL edtConnexSpe frmPrefs
ON LEAVE OF edtConnexSpe IN FRAME frmModule
DO:
  
    RUN SauveZonesSaisie.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME edtConnexSuiv
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL edtConnexSuiv frmPrefs
ON LEAVE OF edtConnexSuiv IN FRAME frmModule
DO:
  
    RUN SauveZonesSaisie.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filBases
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filBases frmPrefs
ON LEAVE OF filBases IN FRAME frmModule /* Répertoire de stockage des bases de l'application */
DO:
      SauvePreference("REPERTOIRE-BASES",SELF:SCREEN-VALUE).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filMotDePasse
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filMotDePasse frmPrefs
ON LEAVE OF filMotDePasse IN FRAME frmModule /* Votre mot de passe................... */
DO:
  RUN SauveZonesSaisie.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filParamCadb
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filParamCadb frmPrefs
ON LEAVE OF filParamCadb IN FRAME frmModule /* Spécifique CADB......... */
DO:
    SauvePreference("PREFS-SERVEURS-CADB",SELF:SCREEN-VALUE).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filParamCompta
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filParamCompta frmPrefs
ON LEAVE OF filParamCompta IN FRAME frmModule /* Spécifique COMPTA.... */
DO:
    SauvePreference("PREFS-SERVEURS-COMPTA",SELF:SCREEN-VALUE).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filParamDwh
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filParamDwh frmPrefs
ON LEAVE OF filParamDwh IN FRAME frmModule /* Spécifique DWH.......... */
DO:
    SauvePreference("PREFS-SERVEURS-DWH",SELF:SCREEN-VALUE).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filParamInter
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filParamInter frmPrefs
ON LEAVE OF filParamInter IN FRAME frmModule /* Spécifique INTER........ */
DO:
    SauvePreference("PREFS-SERVEURS-INTER",SELF:SCREEN-VALUE).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filParamLadb
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filParamLadb frmPrefs
ON LEAVE OF filParamLadb IN FRAME frmModule /* Spécifique LADB......... */
DO:
    SauvePreference("PREFS-SERVEURS-LADB",SELF:SCREEN-VALUE).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filParamLcompta
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filParamLcompta frmPrefs
ON LEAVE OF filParamLcompta IN FRAME frmModule /* Spécifique LCOMPTA. */
DO:
    SauvePreference("PREFS-SERVEURS-LCOMPTA",SELF:SCREEN-VALUE).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filParamLtrans
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filParamLtrans frmPrefs
ON LEAVE OF filParamLtrans IN FRAME frmModule /* Spécifique LTRANS.... */
DO:
    SauvePreference("PREFS-SERVEURS-LTRANS",SELF:SCREEN-VALUE).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filParamSadb
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filParamSadb frmPrefs
ON LEAVE OF filParamSadb IN FRAME frmModule /* Spécifique SADB......... */
DO:
    SauvePreference("PREFS-SERVEURS-SADB",SELF:SCREEN-VALUE).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filParamStandard
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filParamStandard frmPrefs
ON LEAVE OF filParamStandard IN FRAME frmModule /* Standard */
DO:
    SauvePreference("PREFS-SERVEURS-STANDARD",SELF:SCREEN-VALUE).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filParamTransfer
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filParamTransfer frmPrefs
ON LEAVE OF filParamTransfer IN FRAME frmModule /* Spécifique TRANSFER */
DO:
    SauvePreference("PREFS-SERVEURS-TRANSFER",SELF:SCREEN-VALUE).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filParamWadb
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filParamWadb frmPrefs
ON LEAVE OF filParamWadb IN FRAME frmModule /* Spécifique WADB....... */
DO:
    SauvePreference("PREFS-SERVEURS-WADB",SELF:SCREEN-VALUE).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filReseauCli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filReseauCli frmPrefs
ON LEAVE OF filReseauCli IN FRAME frmModule
DO:
  
    RUN SauveZonesSaisie.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filReseauPrec
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filReseauPrec frmPrefs
ON LEAVE OF filReseauPrec IN FRAME frmModule
DO:
  RUN SauveZonesSaisie.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filReseauSpe
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filReseauSpe frmPrefs
ON LEAVE OF filReseauSpe IN FRAME frmModule
DO:
  
    RUN SauveZonesSaisie.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filReseauSuiv
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filReseauSuiv frmPrefs
ON LEAVE OF filReseauSuiv IN FRAME frmModule
DO:
  
    RUN SauveZonesSaisie.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filUtilisateur
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filUtilisateur frmPrefs
ON LEAVE OF filUtilisateur IN FRAME frmModule /* Votre nom d'utilisateur Windows */
DO:
  RUN SauveZonesSaisie.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglclientini
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglclientini frmPrefs
ON VALUE-CHANGED OF tglclientini IN FRAME frmModule /* Positionnement de MaGI sur la référence à l'ouverture de la base (client.ini) */
DO:
    SauvePreference("PREF-CLIENTINI",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglClientServeur
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglClientServeur frmPrefs
ON VALUE-CHANGED OF tglClientServeur IN FRAME frmModule /* Mode client serveur pour l'application DEV (disque <> reseau) */
DO:
    SauvePreference("PREF-MAGICSDEV",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglConnexCli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglConnexCli frmPrefs
ON VALUE-CHANGED OF tglConnexCli IN FRAME frmModule
DO:
  
    SauvePreference("PREF-MAGICONNEXCLI",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
    RUN GereZonesSaisie.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglConnexPrec
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglConnexPrec frmPrefs
ON VALUE-CHANGED OF tglConnexPrec IN FRAME frmModule
DO:
  
    SauvePreference("PREF-MAGICONNEXPREC",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
    
    RUN GereZonesSaisie.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglConnexSpe
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglConnexSpe frmPrefs
ON VALUE-CHANGED OF tglConnexSpe IN FRAME frmModule
DO:
  
    SauvePreference("PREF-MAGICONNEXSPE",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
    RUN GereZonesSaisie.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglConnexSuiv
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglConnexSuiv frmPrefs
ON VALUE-CHANGED OF tglConnexSuiv IN FRAME frmModule
DO:
  
    SauvePreference("PREF-MAGICONNEXSUIV",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
    RUN GereZonesSaisie.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglCouleurProvenance
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglCouleurProvenance frmPrefs
ON VALUE-CHANGED OF tglCouleurProvenance IN FRAME frmModule /* Gérer la couleur de la base en fonction de sa situation et non en fonction de son état */
DO:
    SauvePreference("BASES-COULEUR-PROVENANCE",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
    AssigneParametre("BASES-RECHARGE","OUI").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglFermerTout
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglFermerTout frmPrefs
ON VALUE-CHANGED OF tglFermerTout IN FRAME frmModule /* "Arrêter toutes les bases" s'applique sur toutes les bases et non seulement celles de la liste en cours */
DO:
    SauvePreference("PREF-FERMERTOUTES=TOUT",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglFiltreImmediat
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglFiltreImmediat frmPrefs
ON VALUE-CHANGED OF tglFiltreImmediat IN FRAME frmModule /* Appliquer les filtres immédiatement */
DO:
    SauvePreference("FILTRE-TOUTDESUITE",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglLibAuto
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglLibAuto frmPrefs
ON VALUE-CHANGED OF tglLibAuto IN FRAME frmModule /* Ouverture/fermeture automatique des bases libellé */
DO:
    SauvePreference("PREF-LIBAUTO",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglLocalCli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglLocalCli frmPrefs
ON VALUE-CHANGED OF tglLocalCli IN FRAME frmModule
DO:
  
    SauvePreference("PREF-MAGICSCLI",(IF SELF:CHECKED THEN "NON" ELSE "OUI")).
    tglServeurCli:CHECKED = NOT(SELF:CHECKED).
    RUN GereZonesSaisie.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglLocalPrec
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglLocalPrec frmPrefs
ON VALUE-CHANGED OF tglLocalPrec IN FRAME frmModule
DO:
    SauvePreference("PREF-MAGICSPREC",(IF SELF:CHECKED THEN "NON" ELSE "OUI")).
    tglServeurPrec:CHECKED = NOT(SELF:CHECKED).
    RUN GereZonesSaisie.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglLocalSPe
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglLocalSPe frmPrefs
ON VALUE-CHANGED OF tglLocalSPe IN FRAME frmModule
DO:
  
    SauvePreference("PREF-MAGICSSPE",(IF SELF:CHECKED THEN "NON" ELSE "OUI")).
    tglServeurSpe:CHECKED = NOT(SELF:CHECKED).
    RUN GereZonesSaisie.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglLocalSuiv
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglLocalSuiv frmPrefs
ON VALUE-CHANGED OF tglLocalSuiv IN FRAME frmModule
DO:
  
    SauvePreference("PREF-MAGICSSUIV",(IF SELF:CHECKED THEN "NON" ELSE "OUI")).
    tglServeurSuiv:CHECKED = NOT(SELF:CHECKED).
    RUN GereZonesSaisie.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglPartage
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglPartage frmPrefs
ON VALUE-CHANGED OF tglPartage IN FRAME frmModule /* Lancer la vérification du partage à intervalles réguliers */
DO:
    SauvePreference("PREF-VERIFICATIONPARTAGE",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglPasLocal
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglPasLocal frmPrefs
ON VALUE-CHANGED OF tglPasLocal IN FRAME frmModule /* Ne pas remplacer les bases libellé dans le fichier cnx pour les bases non locales */
DO:
    SauvePreference("PREF-CNXPASLOCAL",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglRafManuel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglRafManuel frmPrefs
ON VALUE-CHANGED OF tglRafManuel IN FRAME frmModule /* Rafraîchissement manuel de la liste des bases */
DO:
    SauvePreference("PREF-RAFRAICHISSEMENTMANUELBASES",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglServeurCli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglServeurCli frmPrefs
ON VALUE-CHANGED OF tglServeurCli IN FRAME frmModule
DO:
  
    SauvePreference("PREF-MAGICSCLI",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
    tglLocalCli:CHECKED = NOT(SELF:CHECKED).
    RUN GereZonesSaisie.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglServeurPrec
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglServeurPrec frmPrefs
ON VALUE-CHANGED OF tglServeurPrec IN FRAME frmModule
DO:
  
    SauvePreference("PREF-MAGICSPREC",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
    tglLocalPrec:CHECKED = NOT(SELF:CHECKED).
    RUN GereZonesSaisie.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglServeurSPE
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglServeurSPE frmPrefs
ON VALUE-CHANGED OF tglServeurSPE IN FRAME frmModule
DO:
  
    SauvePreference("PREF-MAGICSSPE",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
    tglLocalSpe:CHECKED = NOT(SELF:CHECKED).
    RUN GereZonesSaisie.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglServeurSuiv
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglServeurSuiv frmPrefs
ON VALUE-CHANGED OF tglServeurSuiv IN FRAME frmModule
DO:
  
    SauvePreference("PREF-MAGICSSUIV",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
    tglLocalSuiv:CHECKED = NOT(SELF:CHECKED).
    RUN GereZonesSaisie.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglSpecifCadb
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglSpecifCadb frmPrefs
ON VALUE-CHANGED OF tglSpecifCadb IN FRAME frmModule
DO:
    SauvePreference("PREFS-SERVEURS-CADB-ACTIF",STRING(SELF:CHECKED,"OUI/NON")).
    IF SELF:CHECKED THEN APPLY "TAB" TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglSpecifCompta
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglSpecifCompta frmPrefs
ON VALUE-CHANGED OF tglSpecifCompta IN FRAME frmModule
DO:
    SauvePreference("PREFS-SERVEURS-COMPTA-ACTIF",STRING(SELF:CHECKED,"OUI/NON")).
    IF SELF:CHECKED THEN APPLY "TAB" TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglSpecifDwh
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglSpecifDwh frmPrefs
ON VALUE-CHANGED OF tglSpecifDwh IN FRAME frmModule
DO:
    SauvePreference("PREFS-SERVEURS-DWH-ACTIF",STRING(SELF:CHECKED,"OUI/NON")).
    IF SELF:CHECKED THEN APPLY "TAB" TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglSpecifInter
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglSpecifInter frmPrefs
ON VALUE-CHANGED OF tglSpecifInter IN FRAME frmModule
DO:
    SauvePreference("PREFS-SERVEURS-INTER-ACTIF",STRING(SELF:CHECKED,"OUI/NON")).
    IF SELF:CHECKED THEN APPLY "TAB" TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglSpecifLadb
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglSpecifLadb frmPrefs
ON VALUE-CHANGED OF tglSpecifLadb IN FRAME frmModule
DO:
    SauvePreference("PREFS-SERVEURS-LADB-ACTIF",STRING(SELF:CHECKED,"OUI/NON")).
    IF SELF:CHECKED THEN APPLY "TAB" TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglSpecifLcompta
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglSpecifLcompta frmPrefs
ON VALUE-CHANGED OF tglSpecifLcompta IN FRAME frmModule
DO:
    SauvePreference("PREFS-SERVEURS-LCOMPTA-ACTIF",STRING(SELF:CHECKED,"OUI/NON")).
    IF SELF:CHECKED THEN APPLY "TAB" TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglSpecifLtrans
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglSpecifLtrans frmPrefs
ON VALUE-CHANGED OF tglSpecifLtrans IN FRAME frmModule
DO:
    SauvePreference("PREFS-SERVEURS-LTRANS-ACTIF",STRING(SELF:CHECKED,"OUI/NON")).
    IF SELF:CHECKED THEN APPLY "TAB" TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglSpecifSadb
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglSpecifSadb frmPrefs
ON VALUE-CHANGED OF tglSpecifSadb IN FRAME frmModule
DO:
    SauvePreference("PREFS-SERVEURS-SADB-ACTIF",STRING(SELF:CHECKED,"OUI/NON")).
    IF SELF:CHECKED THEN APPLY "TAB" TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglSpecifTransfer
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglSpecifTransfer frmPrefs
ON VALUE-CHANGED OF tglSpecifTransfer IN FRAME frmModule
DO:
    SauvePreference("PREFS-SERVEURS-TRANSFER-ACTIF",STRING(SELF:CHECKED,"OUI/NON")).
    IF SELF:CHECKED THEN APPLY "TAB" TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglSpecifWadb
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglSpecifWadb frmPrefs
ON VALUE-CHANGED OF tglSpecifWadb IN FRAME frmModule
DO:
    SauvePreference("PREFS-SERVEURS-WADB-ACTIF",STRING(SELF:CHECKED,"OUI/NON")).
    IF SELF:CHECKED THEN APPLY "TAB" TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglSupprimeCnxAdb
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglSupprimeCnxAdb frmPrefs
ON VALUE-CHANGED OF tglSupprimeCnxAdb IN FRAME frmModule /* Suppression des fichiers cnx... et adb... à la suppression de la base */
DO:
    SauvePreference("PREFS-SUPPRIME-CNX-ADB",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglSupprimeLK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglSupprimeLK frmPrefs
ON VALUE-CHANGED OF tglSupprimeLK IN FRAME frmModule /* Suppression des fichiers ".lk" au démarrage de menudev2 */
DO:
    SauvePreference("PREF-SUPPRIME-LK",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglUtilisateurs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglUtilisateurs frmPrefs
ON VALUE-CHANGED OF tglUtilisateurs IN FRAME frmModule /* Permettre aux utilisateurs de récupérer une sauvegarde de base */
DO:
  
    SauvePreference("PREF-AUTORISER-UTILISATEURS",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
    RUN GereZonesUtilisateur.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglVersionProgress
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglVersionProgress frmPrefs
ON VALUE-CHANGED OF tglVersionProgress IN FRAME frmModule /* Calcul de la version Progress des bases au démarrage de menudev2 */
DO:
    SauvePreference("PREFS-VERSION-PROGRESS-DEMARRAGE",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frmPrefs
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK frmPrefs 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  RUN Initialisation.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI frmPrefs  _DEFAULT-DISABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide 
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Hide all frames. */
  HIDE FRAME frmModule.
  HIDE FRAME frmPrefs.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE DonneOrdre frmPrefs 
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI frmPrefs  _DEFAULT-ENABLE
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
  ENABLE Btn_PrefsGenerales Btn_Cancel 
      WITH FRAME frmPrefs.
  {&OPEN-BROWSERS-IN-QUERY-frmPrefs}
  DISPLAY tglRafManuel filBases cmbCompression tglPasLocal tglFermerTout 
          tglFiltreImmediat tglCouleurProvenance tglLibAuto tglclientini 
          tglPartage tglUtilisateurs tglSupprimeLK tglSupprimeCnxAdb 
          filUtilisateur tglVersionProgress filMotDePasse filReseauPrec 
          edtConnexPrec tglLocalPrec tglServeurPrec tglConnexPrec filReseauCli 
          edtConnexCli tglLocalCli tglServeurCli tglConnexCli filReseauSuiv 
          edtConnexSuiv tglLocalSuiv tglServeurSuiv tglConnexSuiv filReseauSpe 
          edtConnexSpe tglLocalSPe tglServeurSPE tglConnexSpe filParamStandard 
          tglSpecifSadb filParamSadb tglSpecifCompta filParamCompta 
          tglSpecifCadb filParamCadb tglSpecifInter filParamInter 
          tglSpecifTransfer filParamTransfer tglSpecifDwh filParamDwh 
          tglSpecifLadb filParamLadb tglSpecifLcompta filParamLcompta 
          tglSpecifLtrans filParamLtrans tglSpecifWadb filParamWadb 
          tglClientServeur 
      WITH FRAME frmModule.
  ENABLE tglRafManuel filBases cmbCompression tglPasLocal tglFermerTout 
         tglFiltreImmediat tglCouleurProvenance tglLibAuto tglclientini 
         tglPartage tglUtilisateurs tglSupprimeLK tglSupprimeCnxAdb 
         filUtilisateur tglVersionProgress filMotDePasse filReseauPrec 
         edtConnexPrec BtnFicPrec tglLocalPrec tglServeurPrec tglConnexPrec 
         filReseauCli edtConnexCli BtnFicCli tglLocalCli tglServeurCli 
         tglConnexCli filReseauSuiv edtConnexSuiv BtnFicSuiv tglLocalSuiv 
         tglServeurSuiv tglConnexSuiv filReseauSpe edtConnexSpe BtnFicSpe 
         tglLocalSPe tglServeurSPE tglConnexSpe filParamStandard tglSpecifSadb 
         filParamSadb tglSpecifCompta filParamCompta tglSpecifCadb filParamCadb 
         tglSpecifInter filParamInter tglSpecifTransfer filParamTransfer 
         tglSpecifDwh filParamDwh tglSpecifLadb filParamLadb tglSpecifLcompta 
         filParamLcompta tglSpecifLtrans filParamLtrans tglSpecifWadb 
         filParamWadb tglClientServeur RECT-10 RECT-8 RECT-9 
      WITH FRAME frmModule.
  VIEW FRAME frmModule.
  {&OPEN-BROWSERS-IN-QUERY-frmModule}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE GereZonesSaisie frmPrefs 
PROCEDURE GereZonesSaisie :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    DO WITH FRAME frmModule:
        filReseauPrec:SENSITIVE = tglServeurPrec:CHECKED.
        IF not(filReseauPrec:SENSITIVE) THEN filReseauPrec:SCREEN-VALUE = "".
        filReseauCli:SENSITIVE = tglServeurCli:CHECKED.
        IF not(filReseauCli:SENSITIVE) THEN filReseauCli:SCREEN-VALUE = "".
        filReseauSuiv:SENSITIVE = tglServeurSuiv:CHECKED.
        IF not(filReseauSuiv:SENSITIVE) THEN filReseauSuiv:SCREEN-VALUE = "".
        filReseauSpe:SENSITIVE = tglServeurSpe:CHECKED.
        IF not(filReseauSpe:SENSITIVE) THEN filReseauSpe:SCREEN-VALUE = "".
        
        SauvePreference("PREF-MAGIRESEAUPREC",filReseauPrec:SCREEN-VALUE).
        SauvePreference("PREF-MAGIRESEAUCLI",filReseauCli:SCREEN-VALUE).
        SauvePreference("PREF-MAGIRESEAUSUIV",filReseauSuiv:SCREEN-VALUE).
        SauvePreference("PREF-MAGIRESEAUSPE",filReseauSpe:SCREEN-VALUE).

        edtConnexPrec:SENSITIVE = tglConnexPrec:CHECKED.
        edtConnexCli:SENSITIVE = tglConnexCli:CHECKED.
        edtConnexSuiv:SENSITIVE = tglConnexSuiv:CHECKED.
        edtConnexSpe:SENSITIVE = tglConnexSpe:CHECKED.
        btnFicPrec:SENSITIVE = edtConnexPrec:SENSITIVE.
        btnFicCli:SENSITIVE = edtConnexCli:SENSITIVE.
        btnFicSuiv:SENSITIVE = edtConnexSuiv:SENSITIVE.
        btnFicSpe:SENSITIVE = edtConnexSpe:SENSITIVE.
        SauvePreference("PREF-MAGICONNEXLIBPREC",edtConnexPrec:SCREEN-VALUE).
        SauvePreference("PREF-MAGICONNEXLIBCLI",edtConnexCli:SCREEN-VALUE).
        SauvePreference("PREF-MAGICONNEXLIBSUIV",edtConnexSuiv:SCREEN-VALUE).
        SauvePreference("PREF-MAGICONNEXLIBSPE",edtConnexSpe:SCREEN-VALUE).

    END.

    RUN DonneOrdre("ORDRE-GENERAL=MAJ-PREFERENCES").

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE GereZonesUtilisateur frmPrefs 
PROCEDURE GereZonesUtilisateur :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DO WITH FRAME frmModule:
        IF tglUtilisateurs:CHECKED THEN DO:
            filUtilisateur:SENSITIVE = TRUE.
            filMotDePasse:SENSITIVE = TRUE.
            filUtilisateur:SCREEN-VALUE = DonnePreference("PREF-AUTORISER-UTILISATEURS-UTILISATEUR").
            filMotDePasse:SCREEN-VALUE = DonnePreference("PREF-AUTORISER-UTILISATEURS-MDP").
        END. 
        ELSE DO:        
            filUtilisateur:SENSITIVE = FALSE.
            filMotDePasse:SENSITIVE = FALSE.
            filUtilisateur:SCREEN-VALUE = "".
            filMotDePasse:SCREEN-VALUE = "".
            RUN SauveZonesSaisie.
        END.
    END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Initialisation frmPrefs 
PROCEDURE Initialisation :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    FRAME frmPrefs:TITLE = "Préférences " + DonneNomModule(cIdentModule-in).
    FRAME frmModule:TITLE = "Préférences du module : " + DonneNomModule(cIdentModule-in).
    
    DO WITH FRAME frmModule:
        tglRafManuel:CHECKED = (IF DonnePreference("PREF-RAFRAICHISSEMENTMANUELBASES") = "OUI" THEN TRUE ELSE FALSE).
        tglPasLocal:CHECKED = (IF DonnePreference("PREF-CNXPASLOCAL") = "OUI" THEN TRUE ELSE FALSE).
        tglFermerTout:CHECKED = (IF DonnePreference("PREF-FERMERTOUTES=TOUT") = "OUI" THEN TRUE ELSE FALSE).
        tglFiltreImmediat:CHECKED = (IF DonnePreference("FILTRE-TOUTDESUITE") = "OUI" THEN TRUE ELSE FALSE).
        tglCouleurProvenance:CHECKED = (IF DonnePreference("BASES-COULEUR-PROVENANCE") = "OUI" THEN TRUE ELSE FALSE).
        tglLibAuto:CHECKED = (IF DonnePreference("PREF-LIBAUTO") = "OUI" THEN TRUE ELSE FALSE).

        IF DonnePreference("PREF-CLIENTINI") = "" THEN SauvePreference("PREF-CLIENTINI","OUI").
        tglClientIni:CHECKED = (IF DonnePreference("PREF-CLIENTINI") = "OUI" THEN TRUE ELSE FALSE).
        tglPartage:CHECKED = (IF DonnePreference("PREF-VERIFICATIONPARTAGE") = "OUI" THEN TRUE ELSE FALSE).
        tglPartage:CHECKED = (IF DonnePreference("PREF-VERIFICATIONPARTAGE") = "OUI" THEN TRUE ELSE FALSE).
        tglSupprimeLK:CHECKED = (IF DonnePreference("PREF-SUPPRIME-LK") = "OUI" THEN TRUE ELSE FALSE).
        tglSupprimeCnxAdb:CHECKED = (IF DonnePreference("PREFS-SUPPRIME-CNX-ADB") = "OUI" THEN TRUE ELSE FALSE).
        filBases:SCREEN-VALUE = DonnePreference("REPERTOIRE-BASES").
        cmbCompression:SCREEN-VALUE = DonnePreference("PREF-COMPRESSION").
        tglUtilisateurs:CHECKED = (IF DonnePreference("PREF-AUTORISER-UTILISATEURS") = "OUI" THEN TRUE ELSE FALSE).
    
        tglServeurPrec:CHECKED = (IF DonnePreference("PREF-MAGICSPREC") = "OUI" THEN TRUE ELSE FALSE).
        tglServeurCli:CHECKED = (IF DonnePreference("PREF-MAGICSCLI") = "OUI" THEN TRUE ELSE FALSE).
        tglServeurSuiv:CHECKED = (IF DonnePreference("PREF-MAGICSSUIV") = "OUI" THEN TRUE ELSE FALSE).
        tglServeurSpe:CHECKED = (IF DonnePreference("PREF-MAGICSSPE") = "OUI" THEN TRUE ELSE FALSE).
        tglLocalPrec:CHECKED = NOT(tglServeurPrec:CHECKED).
        tglLocalCli:CHECKED = NOT(tglServeurCli:CHECKED).
        tglLocalSuiv:CHECKED = NOT(tglServeurSuiv:CHECKED).
        tglLocalSpe:CHECKED = NOT(tglServeurSpe:CHECKED).

        filReseauPrec:SCREEN-VALUE = DonnePreference("PREF-MAGIRESEAUPREC").
        filReseauCli:SCREEN-VALUE = DonnePreference("PREF-MAGIRESEAUCLI").
        filReseauSuiv:SCREEN-VALUE = DonnePreference("PREF-MAGIRESEAUSUIV").
        filReseauSpe:SCREEN-VALUE = DonnePreference("PREF-MAGIRESEAUSPE").

        tglConnexPrec:CHECKED = (IF DonnePreference("PREF-MAGICONNEXPREC") = "OUI" THEN TRUE ELSE FALSE).
        tglConnexCli:CHECKED = (IF DonnePreference("PREF-MAGICONNEXCLI") = "OUI" THEN TRUE ELSE FALSE).
        tglConnexSuiv:CHECKED = (IF DonnePreference("PREF-MAGICONNEXSUIV") = "OUI" THEN TRUE ELSE FALSE).
        tglConnexSpe:CHECKED = (IF DonnePreference("PREF-MAGICONNEXSPE") = "OUI" THEN TRUE ELSE FALSE).
        edtConnexPrec:SCREEN-VALUE = DonnePreference("PREF-MAGICONNEXLIBPREC").
        edtConnexCli:SCREEN-VALUE = DonnePreference("PREF-MAGICONNEXLIBCLI").
        edtConnexSuiv:SCREEN-VALUE = DonnePreference("PREF-MAGICONNEXLIBSUIV").
        edtConnexSpe:SCREEN-VALUE = DonnePreference("PREF-MAGICONNEXLIBSPE").

        tglVersionProgress:CHECKED = (IF DonnePreference("PREFS-VERSION-PROGRESS-DEMARRAGE") = "OUI" THEN TRUE ELSE FALSE).
        
        /* Serveurs */
        filParamStandard:SCREEN-VALUE = DonnePreference("PREFS-SERVEURS-STANDARD").
        filParamSADB:SCREEN-VALUE = DonnePreference("PREFS-SERVEURS-SADB").
        filParamCOMPTA:SCREEN-VALUE = DonnePreference("PREFS-SERVEURS-COMPTA").
        filParamCADB:SCREEN-VALUE = DonnePreference("PREFS-SERVEURS-CADB").
        filParamINTER:SCREEN-VALUE = DonnePreference("PREFS-SERVEURS-INTER").
        filParamTRANSFER:SCREEN-VALUE = DonnePreference("PREFS-SERVEURS-TRANSFER").
        filParamDWH:SCREEN-VALUE = DonnePreference("PREFS-SERVEURS-DWH").
        filParamLADB:SCREEN-VALUE = DonnePreference("PREFS-SERVEURS-LADB").
        filParamLCOMPTA:SCREEN-VALUE = DonnePreference("PREFS-SERVEURS-LCOMPTA").
        filParamLTRANS:SCREEN-VALUE = DonnePreference("PREFS-SERVEURS-LTRANS").
        filParamWADB:SCREEN-VALUE = DonnePreference("PREFS-SERVEURS-WADB").

        tglSpecifSADB:CHECKED = (DonnePreference("PREFS-SERVEURS-SADB-ACTIF") = "OUI").
        tglSpecifCOMPTA:CHECKED = (DonnePreference("PREFS-SERVEURS-COMPTA-ACTIF") = "OUI").
        tglSpecifCADB:CHECKED = (DonnePreference("PREFS-SERVEURS-CADB-ACTIF") = "OUI").
        tglSpecifINTER:CHECKED = (DonnePreference("PREFS-SERVEURS-INTER-ACTIF") = "OUI").
        tglSpecifTRANSFER:CHECKED = (DonnePreference("PREFS-SERVEURS-TRANSFER-ACTIF") = "OUI").
        tglSpecifDWH:CHECKED = (DonnePreference("PREFS-SERVEURS-DWH-ACTIF") = "OUI").
        tglSpecifLADB:CHECKED = (DonnePreference("PREFS-SERVEURS-LADB-ACTIF") = "OUI").
        tglSpecifLCOMPTA:CHECKED = (DonnePreference("PREFS-SERVEURS-LCOMPTA-ACTIF") = "OUI").
        tglSpecifLTRANS:CHECKED = (DonnePreference("PREFS-SERVEURS-LTRANS-ACTIF") = "OUI").
        tglSpecifWADB:CHECKED = (DonnePreference("PREFS-SERVEURS-WADB-ACTIF") = "OUI").
        tglClientServeur:CHECKED = (DonnePreference("PREF-MAGICSDEV") = "OUI").

        RUN GereZonesSaisie.
        RUN GereZonesUtilisateur.

    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE SauveZonesSaisie frmPrefs 
PROCEDURE SauveZonesSaisie :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    DO WITH FRAME frmModule:      
        SauvePreference("PREF-MAGIRESEAUPREC",filReseauPrec:SCREEN-VALUE).
        SauvePreference("PREF-MAGIRESEAUCLI",filReseauCli:SCREEN-VALUE).
        SauvePreference("PREF-MAGIRESEAUSUIV",filReseauSuiv:SCREEN-VALUE).
        SauvePreference("PREF-MAGIRESEAUSPE",filReseauSpe:SCREEN-VALUE).
        
        SauvePreference("PREF-MAGICONNEXLIBPREC",edtConnexPrec:SCREEN-VALUE).
        SauvePreference("PREF-MAGICONNEXLIBCLI",edtConnexCli:SCREEN-VALUE).
        SauvePreference("PREF-MAGICONNEXLIBSUIV",edtConnexSuiv:SCREEN-VALUE).
        SauvePreference("PREF-MAGICONNEXLIBSPE",edtConnexSpe:SCREEN-VALUE).
        
        SauvePreference("PREF-AUTORISER-UTILISATEURS-UTILISATEUR",filUtilisateur:SCREEN-VALUE).
        SauvePreference("PREF-AUTORISER-UTILISATEURS-MDP",filMotDePasse:SCREEN-VALUE).
    END.

    RUN DonneOrdre("RAF-PREFERENCES").
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

