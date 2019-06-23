&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
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

{includes\i_environnement.i}
    {includes\i_dialogue.i}
    {includes\i_api.i}
{menudev2\includes\menudev2.i}


/* Parameters Definitions ---                                           */

DEFINE INPUT PARAMETER  winGeneral  AS HANDLE NO-UNDO.
DEFINE INPUT PARAMETER  cParametres AS CHARACTER NO-UNDO.
/* Local Variable Definitions ---                                       */

DEFINE BUFFER bprefs FOR prefs.

    DEFINE VARIABLE cFichierBatchEntree AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cFichierBatchMinute AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cFichierBatchSortie AS CHARACTER NO-UNDO.

DEFINE STREAM sEntree.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME frmFonction

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-2 RECT-12 RECT-13 RECT-14 RECT-15 ~
RECT-16 RECT-9 RECT-17 btnPrefsAbsences btnPrefsActivite btnPrefsAFaire ~
btnPrefsAgenda btnPrefsBases btnPrefsMessages btnPrefsProjets ~
tglPrefsDirect filVraiNom filEmail tglSortie BtnReinitMessages tglPosition ~
BtnReinitBoutons tglModule tglBoutonsNormaux filBrouillons tglMemo ~
filRappelDebut filRappelFin tglMuet tglWord tglBatch Btnbatch filParamRepGi ~
tglBatch2 Btnbatch-2 filParamRepGidev tglMinutes Btnbatch-3 ~
filParamRepGi_prec filParamRepGi_suiv tglVersionManuelle filParamRepGi_spe ~
tglSaisieMasterGI tglSaisieInternet filMastergi filLatenceInternet ~
tglDemonTicket filInternetUtil filInternet filRepertoireScan ~
tglDemonTicketVerbose tglDeveloppeur tglby-pass tglLog tglCommandesDos ~
tglModuleInvisibles tglControle tglControleVoir tglControleMail ~
tglControleQueSiErreur tglControleBases tglControleSvg tglControleBaseEtSvg ~
tglControle7z tglControleExclus tglControleBaseDos tglControleDisponible ~
tglControleDispoQuota filControleQuotaValeur filFeriesFixes ~
filVacancesScolaires filFeriesMobiles filAnciennes 
&Scoped-Define DISPLAYED-OBJECTS tglPrefsDirect filVraiNom filEmail ~
tglSortie tglPosition tglModule tglBoutonsNormaux filBrouillons tglMemo ~
filRappelDebut filRappelFin tglMuet tglWord tglBatch filParamRepGi ~
tglBatch2 filParamRepGidev tglMinutes filParamRepGi_prec filParamRepGi_suiv ~
tglVersionManuelle filParamRepGi_spe tglSaisieMasterGI tglSaisieInternet ~
filMastergi filLatenceInternet tglDemonTicket filInternetUtil filInternet ~
filRepertoireScan tglDemonTicketVerbose tglDeveloppeur tglby-pass tglLog ~
tglCommandesDos tglModuleInvisibles tglControle tglControleVoir ~
tglControleMail tglControleQueSiErreur tglControleBases tglControleSvg ~
tglControleBaseEtSvg tglControle7z tglControleExclus tglControleBaseDos ~
tglControleDisponible tglControleDispoQuota filControleQuotaValeur ~
filFeriesFixes filVacancesScolaires filFeriesMobiles filAnciennes 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */
&Scoped-define List-6 tglControleVoir tglControleMail ~
tglControleQueSiErreur tglControleBases tglControleSvg tglControleBaseEtSvg ~
tglControle7z tglControleExclus tglControleBaseDos tglControleDisponible ~
tglControleDispoQuota 

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD AfficheInformations C-Win 
FUNCTION AfficheInformations RETURNS LOGICAL
  (cLibelle-in AS CHARACTER,iTemporisation-in AS INTEGER)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btnbatch 
     LABEL "Voir le fichier batch" 
     SIZE 22 BY .95.

DEFINE BUTTON Btnbatch-2 
     LABEL "Voir le fichier batch" 
     SIZE 22 BY .95.

DEFINE BUTTON Btnbatch-3 
     LABEL "Voir le fichier batch" 
     SIZE 22 BY .95.

DEFINE BUTTON btnPrefsAbsences 
     LABEL "Absences" 
     SIZE 15 BY 1.19.

DEFINE BUTTON btnPrefsActivite 
     LABEL "Activité" 
     SIZE 15 BY 1.19.

DEFINE BUTTON btnPrefsAFaire 
     LABEL "A Faire" 
     SIZE 15 BY 1.19.

DEFINE BUTTON btnPrefsAgenda 
     LABEL "Planificateur" 
     SIZE 15 BY 1.19.

DEFINE BUTTON btnPrefsBases 
     LABEL "Bases" 
     SIZE 15 BY 1.19.

DEFINE BUTTON btnPrefsMessages 
     LABEL "Messages" 
     SIZE 15 BY 1.19.

DEFINE BUTTON btnPrefsProjets 
     LABEL "Projets" 
     SIZE 15 BY 1.19.

DEFINE BUTTON BtnReinitBoutons 
     LABEL "Réinitialiser les boutons GI Prec, Cli, Suiv et Spe à leurs valeurs d'origine" 
     SIZE 77 BY .95.

DEFINE BUTTON BtnReinitMessages 
     LABEL "Réinitialiser les messages marqués comme ~"Ne plus voir~"" 
     SIZE 77 BY .95.

DEFINE VARIABLE filAnciennes AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 77 BY .95 NO-UNDO.

DEFINE VARIABLE filBrouillons AS CHARACTER FORMAT "9":U 
     LABEL "Nombre de 'Brouillons' à lancer au démarrage : (0-5)" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 5 BY .95 NO-UNDO.

DEFINE VARIABLE filControleQuotaValeur AS INTEGER FORMAT ">9":U INITIAL 10 
     VIEW-AS FILL-IN NATIVE 
     SIZE 5 BY .95 NO-UNDO.

DEFINE VARIABLE filEmail AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 76 BY .95 NO-UNDO.

DEFINE VARIABLE filFeriesFixes AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 77 BY .95 NO-UNDO.

DEFINE VARIABLE filFeriesMobiles AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 77 BY .95 NO-UNDO.

DEFINE VARIABLE filInternet AS CHARACTER FORMAT "x(30)":U 
     LABEL "Mot de passe pour l'accès internet" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 31 BY .95 NO-UNDO.

DEFINE VARIABLE filInternetUtil AS CHARACTER FORMAT "x(30)":U 
     LABEL "Utilisateur pour l'accès internet" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 31 BY .95 NO-UNDO.

DEFINE VARIABLE filLatenceInternet AS INTEGER FORMAT ">9":U INITIAL 0 
     LABEL "Temps de latences avant la saisie (en secondes)" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 5 BY .95 NO-UNDO.

DEFINE VARIABLE filMastergi AS CHARACTER FORMAT "9":U 
     LABEL "Temps de latences lors de la saisie du mastergi (en secondes)" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 5 BY .95 NO-UNDO.

DEFINE VARIABLE filParamRepGi AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 23 BY .95 NO-UNDO.

DEFINE VARIABLE filParamRepGidev AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 23 BY .95 NO-UNDO.

DEFINE VARIABLE filParamRepGi_prec AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 23 BY .95 NO-UNDO.

DEFINE VARIABLE filParamRepGi_spe AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 23 BY .95 NO-UNDO.

DEFINE VARIABLE filParamRepGi_suiv AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 23 BY .95 NO-UNDO.

DEFINE VARIABLE filRappelDebut AS INTEGER FORMAT "99":U INITIAL 9 
     LABEL "Rappels horaires uniquement de" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 5 BY .95 NO-UNDO.

DEFINE VARIABLE filRappelFin AS INTEGER FORMAT "99":U INITIAL 17 
     LABEL "heures à" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 5 BY .95 NO-UNDO.

DEFINE VARIABLE filRepertoireScan AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 78 BY .95 NO-UNDO.

DEFINE VARIABLE filVacancesScolaires AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 77 BY .95 NO-UNDO.

DEFINE VARIABLE filVraiNom AS CHARACTER FORMAT "X(15)":U INITIAL "WWWWWWWWWWWWWWW" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 35 BY .95 NO-UNDO.

DEFINE RECTANGLE RECT-12
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 159 BY 1.19
     BGCOLOR 3 .

DEFINE RECTANGLE RECT-13
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 159 BY 1.19
     BGCOLOR 3 .

DEFINE RECTANGLE RECT-14
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 71 BY 1.43.

DEFINE RECTANGLE RECT-15
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 71 BY 4.52.

DEFINE RECTANGLE RECT-16
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 159 BY 1.19
     BGCOLOR 3 .

DEFINE RECTANGLE RECT-17
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 159 BY 1.19
     BGCOLOR 3 .

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 159 BY 1.19
     BGCOLOR 3 .

DEFINE RECTANGLE RECT-9
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 159 BY 1.19
     BGCOLOR 3 .

DEFINE VARIABLE tglBatch AS LOGICAL INITIAL no 
     LABEL "Executer un fichier batch au démarrage" 
     VIEW-AS TOGGLE-BOX
     SIZE 45 BY .95 NO-UNDO.

DEFINE VARIABLE tglBatch2 AS LOGICAL INITIAL no 
     LABEL "Executer un fichier batch à la fermeture" 
     VIEW-AS TOGGLE-BOX
     SIZE 45 BY .95 NO-UNDO.

DEFINE VARIABLE tglBoutonsNormaux AS LOGICAL INITIAL no 
     LABEL "Boutons normaux (non plats) dans les écrans de raccourcis" 
     VIEW-AS TOGGLE-BOX
     SIZE 67.6 BY .95 NO-UNDO.

DEFINE VARIABLE tglby-pass AS LOGICAL INITIAL no 
     LABEL "Activer le by-pass des rappels horaires" 
     VIEW-AS TOGGLE-BOX
     SIZE 67.6 BY .95 NO-UNDO.

DEFINE VARIABLE tglCommandesDos AS LOGICAL INITIAL no 
     LABEL "Activer les fenêtres DOS lors de leurs executions" 
     VIEW-AS TOGGLE-BOX
     SIZE 67.6 BY .95 NO-UNDO.

DEFINE VARIABLE tglControle AS LOGICAL INITIAL no 
     LABEL "Activer le contrôle périodique de la machine (Création d'une action dans le planificateur que vous pouvez modifier)" 
     VIEW-AS TOGGLE-BOX
     SIZE 156 BY .95 NO-UNDO.

DEFINE VARIABLE tglControle7z AS LOGICAL INITIAL no 
     LABEL "Contrôler si le fichier 7z est valide (Traitement très long : ~~ 1 minute par base)" 
     VIEW-AS TOGGLE-BOX
     SIZE 80 BY .95 NO-UNDO.

DEFINE VARIABLE tglControleBaseDos AS LOGICAL INITIAL no 
     LABEL "Controler le contenu du répertoire bases-dos" 
     VIEW-AS TOGGLE-BOX
     SIZE 48 BY .95 NO-UNDO.

DEFINE VARIABLE tglControleBaseEtSvg AS LOGICAL INITIAL no 
     LABEL "Contrôler si la base est présente en plus de la sauvegarde (spécifique xcompil)" 
     VIEW-AS TOGGLE-BOX
     SIZE 81 BY .95 NO-UNDO.

DEFINE VARIABLE tglControleBases AS LOGICAL INITIAL no 
     LABEL "Controler la cohérence du répertoire des bases" 
     VIEW-AS TOGGLE-BOX
     SIZE 48 BY .95 NO-UNDO.

DEFINE VARIABLE tglControleDisponible AS LOGICAL INITIAL no 
     LABEL "Résumé de la place disponible sur la machine" 
     VIEW-AS TOGGLE-BOX
     SIZE 48 BY .95 NO-UNDO.

DEFINE VARIABLE tglControleDispoQuota AS LOGICAL INITIAL no 
     LABEL "Prévenir si la place disponible est en dessous de :" 
     VIEW-AS TOGGLE-BOX
     SIZE 50 BY .95 NO-UNDO.

DEFINE VARIABLE tglControleExclus AS LOGICAL INITIAL no 
     LABEL "Traiter aussi les répertoires exclus (répertoires de base avec l'extension '.exc')" 
     VIEW-AS TOGGLE-BOX
     SIZE 80 BY .95 NO-UNDO.

DEFINE VARIABLE tglControleMail AS LOGICAL INITIAL no 
     LABEL "Envoyer le log par mail en fin de contrôle  (Implique d'avoir saisi une adresse EMail)" 
     VIEW-AS TOGGLE-BOX
     SIZE 91 BY .95 NO-UNDO.

DEFINE VARIABLE tglControleQueSiErreur AS LOGICAL INITIAL no 
     LABEL "Voir le log ou l'envoyer par mail que si présence d~"erreur(s)" 
     VIEW-AS TOGGLE-BOX
     SIZE 100 BY .95 NO-UNDO.

DEFINE VARIABLE tglControleSvg AS LOGICAL INITIAL no 
     LABEL "Controler que la sauvegarde de la base est présente" 
     VIEW-AS TOGGLE-BOX
     SIZE 56 BY .95 NO-UNDO.

DEFINE VARIABLE tglControleVoir AS LOGICAL INITIAL no 
     LABEL "Voir le log en fin de contrôle" 
     VIEW-AS TOGGLE-BOX
     SIZE 56 BY .95 NO-UNDO.

DEFINE VARIABLE tglDemonTicket AS LOGICAL INITIAL no 
     LABEL "Récupération ticket + référence pour ouverture répertoire ticket" 
     VIEW-AS TOGGLE-BOX
     SIZE 71 BY .95 NO-UNDO.

DEFINE VARIABLE tglDemonTicketVerbose AS LOGICAL INITIAL no 
     LABEL "Traitement en mode 'Verbose'" 
     VIEW-AS TOGGLE-BOX
     SIZE 71 BY .95 NO-UNDO.

DEFINE VARIABLE tglDeveloppeur AS LOGICAL INITIAL no 
     LABEL "Activer l'option 'Développeur' pour faciliter le débug" 
     VIEW-AS TOGGLE-BOX
     SIZE 67.6 BY .95 NO-UNDO.

DEFINE VARIABLE tglLog AS LOGICAL INITIAL no 
     LABEL "Activer le Log de menudev2" 
     VIEW-AS TOGGLE-BOX
     SIZE 67.6 BY .95 NO-UNDO.

DEFINE VARIABLE tglMemo AS LOGICAL INITIAL no 
     LABEL "Se positionner sur le Mémo général et non sur le Mémo du jour" 
     VIEW-AS TOGGLE-BOX
     SIZE 66 BY .95 NO-UNDO.

DEFINE VARIABLE tglMinutes AS LOGICAL INITIAL no 
     LABEL "Executer un fichier batch toutes les minutes" 
     VIEW-AS TOGGLE-BOX
     SIZE 45 BY .95 NO-UNDO.

DEFINE VARIABLE tglModule AS LOGICAL INITIAL no 
     LABEL "Sauvegarde du dernier module utilisé" 
     VIEW-AS TOGGLE-BOX
     SIZE 47 BY .95 NO-UNDO.

DEFINE VARIABLE tglModuleInvisibles AS LOGICAL INITIAL no 
     LABEL "Voir les modules ~"invisibles~" (Administrateurs uniquement)" 
     VIEW-AS TOGGLE-BOX
     SIZE 67.6 BY .95 NO-UNDO.

DEFINE VARIABLE tglMuet AS LOGICAL INITIAL no 
     LABEL "Fonctionner en mode silencieux (Aucun son)" 
     VIEW-AS TOGGLE-BOX
     SIZE 67.6 BY .95 NO-UNDO.

DEFINE VARIABLE tglPosition AS LOGICAL INITIAL no 
     LABEL "Sauvegarde de la position en quittant" 
     VIEW-AS TOGGLE-BOX
     SIZE 47 BY .95 NO-UNDO.

DEFINE VARIABLE tglPrefsDirect AS LOGICAL INITIAL no 
     LABEL "Accèder aux préférence d'un module directement sans passer par les préférences générales" 
     VIEW-AS TOGGLE-BOX
     SIZE 91 BY .95 NO-UNDO.

DEFINE VARIABLE tglSaisieInternet AS LOGICAL INITIAL no 
     LABEL "Saisie automatique du mot de passe d'acces internet" 
     VIEW-AS TOGGLE-BOX
     SIZE 54 BY .95 NO-UNDO.

DEFINE VARIABLE tglSaisieMasterGI AS LOGICAL INITIAL no 
     LABEL "Saisie automatique du mot de passe MasterGI" 
     VIEW-AS TOGGLE-BOX
     SIZE 48 BY .95 NO-UNDO.

DEFINE VARIABLE tglSortie AS LOGICAL INITIAL no 
     LABEL "Demander confirmation lors de la sortie du programme" 
     VIEW-AS TOGGLE-BOX
     SIZE 66 BY .95 NO-UNDO.

DEFINE VARIABLE tglVersionManuelle AS LOGICAL INITIAL no 
     LABEL "Gérer les informations de version manuellement" 
     VIEW-AS TOGGLE-BOX
     SIZE 51 BY .95 NO-UNDO.

DEFINE VARIABLE tglWord AS LOGICAL INITIAL no 
     LABEL "Passer par Word pour les éditions" 
     VIEW-AS TOGGLE-BOX
     SIZE 67.6 BY .95 NO-UNDO.

DEFINE VARIABLE edtInformation AS CHARACTER INITIAL "Libelle" 
     VIEW-AS EDITOR NO-BOX
     SIZE 61 BY 1.19
     BGCOLOR 3 FGCOLOR 15 FONT 10 NO-UNDO.

DEFINE IMAGE IMAGE-1
     FILENAME "adeicon/rbuild%.ico":U
     SIZE 8 BY 1.43.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME frmModule
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 166 BY 20.6
         BGCOLOR 7 
         TITLE BGCOLOR 2 FGCOLOR 15 "Préférences".

DEFINE FRAME frmInformation
     edtInformation AT ROW 1.48 COL 13 NO-LABEL WIDGET-ID 2
     IMAGE-1 AT ROW 1.24 COL 3 WIDGET-ID 4
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS TOP-ONLY NO-UNDERLINE THREE-D 
         AT COL 46 ROW 7.67
         SIZE 76 BY 2.14
         BGCOLOR 3  WIDGET-ID 700.

DEFINE FRAME frmFonction
     btnPrefsAbsences AT ROW 1.24 COL 3 WIDGET-ID 346
     btnPrefsActivite AT ROW 1.24 COL 18 WIDGET-ID 372
     btnPrefsAFaire AT ROW 1.24 COL 33 WIDGET-ID 348
     btnPrefsAgenda AT ROW 1.24 COL 48 WIDGET-ID 350
     btnPrefsBases AT ROW 1.24 COL 63 WIDGET-ID 354
     btnPrefsMessages AT ROW 1.24 COL 78 WIDGET-ID 356
     btnPrefsProjets AT ROW 1.24 COL 93 WIDGET-ID 360
     tglPrefsDirect AT ROW 2.91 COL 7 WIDGET-ID 344
     filVraiNom AT ROW 5.76 COL 80 NO-LABEL WIDGET-ID 340
     filEmail AT ROW 7.19 COL 84 NO-LABEL WIDGET-ID 284
     tglSortie AT ROW 10.05 COL 5
     BtnReinitMessages AT ROW 10.29 COL 81 WIDGET-ID 112
     tglPosition AT ROW 11 COL 5
     BtnReinitBoutons AT ROW 11.71 COL 81 WIDGET-ID 68
     tglModule AT ROW 11.95 COL 5
     tglBoutonsNormaux AT ROW 12.91 COL 5 WIDGET-ID 50
     filBrouillons AT ROW 13.14 COL 81.2 WIDGET-ID 66
     tglMemo AT ROW 13.86 COL 5
     filRappelDebut AT ROW 14.33 COL 81.4 WIDGET-ID 36
     filRappelFin AT ROW 14.33 COL 118.6 WIDGET-ID 38
     tglMuet AT ROW 14.81 COL 5 WIDGET-ID 14
     tglWord AT ROW 15.76 COL 5 WIDGET-ID 24
     tglBatch AT ROW 16.71 COL 5 WIDGET-ID 26
     Btnbatch AT ROW 16.71 COL 51 WIDGET-ID 28
     filParamRepGi AT ROW 16.71 COL 112 NO-LABEL WIDGET-ID 400
     tglBatch2 AT ROW 17.67 COL 5 WIDGET-ID 32
     Btnbatch-2 AT ROW 17.67 COL 51 WIDGET-ID 30
     filParamRepGidev AT ROW 17.67 COL 112 NO-LABEL WIDGET-ID 402
     tglMinutes AT ROW 18.62 COL 5 WIDGET-ID 220
     Btnbatch-3 AT ROW 18.62 COL 51 WIDGET-ID 186
     filParamRepGi_prec AT ROW 18.62 COL 112 NO-LABEL WIDGET-ID 404
     filParamRepGi_suiv AT ROW 19.57 COL 112 NO-LABEL WIDGET-ID 406
     tglVersionManuelle AT ROW 19.81 COL 5 WIDGET-ID 322
     filParamRepGi_spe AT ROW 20.52 COL 112 NO-LABEL WIDGET-ID 408
     tglSaisieMasterGI AT ROW 24.1 COL 5 WIDGET-ID 42
     tglSaisieInternet AT ROW 24.33 COL 86 WIDGET-ID 216
     filMastergi AT ROW 24.81 COL 8.6 WIDGET-ID 18
     filLatenceInternet AT ROW 25.29 COL 89.8 WIDGET-ID 226
     tglDemonTicket AT ROW 26.24 COL 5 WIDGET-ID 368
     filInternetUtil AT ROW 26.48 COL 94 WIDGET-ID 366 PASSWORD-FIELD 
     filInternet AT ROW 27.91 COL 90.4 WIDGET-ID 218 PASSWORD-FIELD 
     filRepertoireScan AT ROW 28.14 COL 5 NO-LABEL WIDGET-ID 380
     tglDemonTicketVerbose AT ROW 29.33 COL 5 WIDGET-ID 384
     tglDeveloppeur AT ROW 31.95 COL 5 WIDGET-ID 54
     tglby-pass AT ROW 32.19 COL 85 WIDGET-ID 370
     tglLog AT ROW 32.91 COL 5 WIDGET-ID 6
     tglCommandesDos AT ROW 33.86 COL 5 WIDGET-ID 72
     tglModuleInvisibles AT ROW 35.52 COL 5 WIDGET-ID 12
     tglControle AT ROW 38.14 COL 4 WIDGET-ID 292
     tglControleVoir AT ROW 39.33 COL 7 WIDGET-ID 300
     tglControleMail AT ROW 40.29 COL 7 WIDGET-ID 310
     tglControleQueSiErreur AT ROW 41.24 COL 7 WIDGET-ID 312
     tglControleBases AT ROW 42.19 COL 7 WIDGET-ID 302
     tglControleSvg AT ROW 43.14 COL 12 WIDGET-ID 294
     tglControleBaseEtSvg AT ROW 44.1 COL 12 WIDGET-ID 306
     tglControle7z AT ROW 45.05 COL 12 WIDGET-ID 308
     tglControleExclus AT ROW 46 COL 12 WIDGET-ID 314
     tglControleBaseDos AT ROW 46.95 COL 7 WIDGET-ID 298
     tglControleDisponible AT ROW 47.91 COL 7 WIDGET-ID 296
     tglControleDispoQuota AT ROW 48.86 COL 12 WIDGET-ID 316
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SCROLLABLE SIZE 165 BY 80.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME frmFonction
     filControleQuotaValeur AT ROW 48.86 COL 63 NO-LABEL WIDGET-ID 318
     filFeriesFixes AT ROW 53.62 COL 4 NO-LABEL WIDGET-ID 264
     filVacancesScolaires AT ROW 53.62 COL 84 NO-LABEL WIDGET-ID 362
     filFeriesMobiles AT ROW 55.76 COL 4 NO-LABEL WIDGET-ID 266
     filAnciennes AT ROW 57.91 COL 4 NO-LABEL WIDGET-ID 268
     "Débug et Développement" VIEW-AS TEXT
          SIZE 32 BY .71 AT ROW 30.52 COL 71 WIDGET-ID 236
          BGCOLOR 3 FONT 6
     "%" VIEW-AS TEXT
          SIZE 3 BY .95 AT ROW 48.86 COL 69 WIDGET-ID 320
     "Paramétrage des répertoires applicatifs (Vide = [répertoire] _V[version OE])" VIEW-AS TEXT
          SIZE 80 BY .95 AT ROW 15.52 COL 81 WIDGET-ID 228
     "gi_spe...................." VIEW-AS TEXT
          SIZE 15 BY .71 AT ROW 20.76 COL 96 WIDGET-ID 396
     "gi_suiv......................" VIEW-AS TEXT
          SIZE 15 BY .71 AT ROW 19.81 COL 96 WIDGET-ID 398
     "Utilisateur" VIEW-AS TEXT
          SIZE 14 BY .71 AT ROW 4.33 COL 79 WIDGET-ID 282
          BGCOLOR 3 FONT 6
     "(Attention : Redémarrage de menudev2 nécessaire)" VIEW-AS TEXT
          SIZE 65 BY .71 AT ROW 34.81 COL 8 WIDGET-ID 74
          FGCOLOR 12 
     "Saisies automatiques" VIEW-AS TEXT
          SIZE 32 BY .71 AT ROW 22.67 COL 71 WIDGET-ID 224
          BGCOLOR 3 FONT 6
     "Répertoire de stockage des anciennes sauvegardes" VIEW-AS TEXT
          SIZE 64 BY .95 AT ROW 56.95 COL 4 WIDGET-ID 274
     "Adresse mail à laquelle vous souhaitez être prévenu pour certains traitements" VIEW-AS TEXT
          SIZE 76 BY .95 AT ROW 7.19 COL 6 WIDGET-ID 286
     "Jours fériés fixes (format JJ/MM, séparateur : virgule) :" VIEW-AS TEXT
          SIZE 64 BY .95 AT ROW 52.67 COL 4 WIDGET-ID 270
     "Répertoire à surveiller pour trouver le ticket" VIEW-AS TEXT
          SIZE 64 BY .95 AT ROW 27.19 COL 5 WIDGET-ID 382
     "heures" VIEW-AS TEXT
          SIZE 7 BY .48 AT ROW 14.57 COL 134 WIDGET-ID 40
     "Congés scolaires (debut-fin,début-fin,...) format date : jj/mm/aaaa" VIEW-AS TEXT
          SIZE 64 BY .95 AT ROW 52.67 COL 84 WIDGET-ID 364
     "Jours fériés mobiles (format JJ/MM/AAAA, séparateur : virgule) :" VIEW-AS TEXT
          SIZE 64 BY .95 AT ROW 54.81 COL 4 WIDGET-ID 272
     "Général" VIEW-AS TEXT
          SIZE 11 BY .71 AT ROW 8.86 COL 78 WIDGET-ID 84
          BGCOLOR 3 FONT 6
     "Controle périodique de la machine" VIEW-AS TEXT
          SIZE 49 BY .71 AT ROW 36.95 COL 64 WIDGET-ID 290
          BGCOLOR 3 FONT 6
     "Votre nom (Plus parlant que le code utilisateur pour les autres utilisateurs...)" VIEW-AS TEXT
          SIZE 72 BY .95 AT ROW 5.76 COL 6 WIDGET-ID 342
     "Préférences communes à tous les utilisateurs" VIEW-AS TEXT
          SIZE 55 BY .71 AT ROW 51.24 COL 59 WIDGET-ID 262
          BGCOLOR 3 FONT 6
     "gidev........................" VIEW-AS TEXT
          SIZE 15 BY .71 AT ROW 17.91 COL 96 WIDGET-ID 392
     "gi..........................." VIEW-AS TEXT
          SIZE 15 BY .71 AT ROW 16.95 COL 96 WIDGET-ID 386
     "gi_prec.........................." VIEW-AS TEXT
          SIZE 15 BY .71 AT ROW 18.86 COL 96 WIDGET-ID 394
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SCROLLABLE SIZE 165 BY 80.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME frmFonction
     RECT-2 AT ROW 8.62 COL 2 WIDGET-ID 82
     RECT-12 AT ROW 22.43 COL 3 WIDGET-ID 222
     RECT-13 AT ROW 30.29 COL 3 WIDGET-ID 234
     RECT-14 AT ROW 24.57 COL 4 WIDGET-ID 238
     RECT-15 AT ROW 24.81 COL 85 WIDGET-ID 240
     RECT-16 AT ROW 51 COL 3 WIDGET-ID 260
     RECT-9 AT ROW 4.1 COL 3 WIDGET-ID 280
     RECT-17 AT ROW 36.71 COL 2 WIDGET-ID 288
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SCROLLABLE SIZE 165 BY 80.


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
         HEIGHT             = 20.71
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
ASSIGN FRAME frmFonction:FRAME = FRAME frmModule:HANDLE
       FRAME frmInformation:FRAME = FRAME frmModule:HANDLE.

/* SETTINGS FOR FRAME frmFonction
   FRAME-NAME                                                           */
ASSIGN 
       FRAME frmFonction:HEIGHT           = 19.52
       FRAME frmFonction:WIDTH            = 165.

/* SETTINGS FOR FILL-IN filAnciennes IN FRAME frmFonction
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN filBrouillons IN FRAME frmFonction
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN filControleQuotaValeur IN FRAME frmFonction
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN filEmail IN FRAME frmFonction
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN filFeriesFixes IN FRAME frmFonction
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN filFeriesMobiles IN FRAME frmFonction
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN filInternet IN FRAME frmFonction
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN filInternetUtil IN FRAME frmFonction
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN filLatenceInternet IN FRAME frmFonction
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN filMastergi IN FRAME frmFonction
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN filParamRepGi IN FRAME frmFonction
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN filParamRepGidev IN FRAME frmFonction
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN filParamRepGi_prec IN FRAME frmFonction
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN filParamRepGi_spe IN FRAME frmFonction
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN filParamRepGi_suiv IN FRAME frmFonction
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN filRappelDebut IN FRAME frmFonction
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN filRappelFin IN FRAME frmFonction
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN filRepertoireScan IN FRAME frmFonction
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN filVacancesScolaires IN FRAME frmFonction
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN filVraiNom IN FRAME frmFonction
   ALIGN-L                                                              */
/* SETTINGS FOR TOGGLE-BOX tglControle7z IN FRAME frmFonction
   6                                                                    */
/* SETTINGS FOR TOGGLE-BOX tglControleBaseDos IN FRAME frmFonction
   6                                                                    */
/* SETTINGS FOR TOGGLE-BOX tglControleBaseEtSvg IN FRAME frmFonction
   6                                                                    */
/* SETTINGS FOR TOGGLE-BOX tglControleBases IN FRAME frmFonction
   6                                                                    */
/* SETTINGS FOR TOGGLE-BOX tglControleDisponible IN FRAME frmFonction
   6                                                                    */
/* SETTINGS FOR TOGGLE-BOX tglControleDispoQuota IN FRAME frmFonction
   6                                                                    */
/* SETTINGS FOR TOGGLE-BOX tglControleExclus IN FRAME frmFonction
   6                                                                    */
/* SETTINGS FOR TOGGLE-BOX tglControleMail IN FRAME frmFonction
   6                                                                    */
/* SETTINGS FOR TOGGLE-BOX tglControleQueSiErreur IN FRAME frmFonction
   6                                                                    */
/* SETTINGS FOR TOGGLE-BOX tglControleSvg IN FRAME frmFonction
   6                                                                    */
/* SETTINGS FOR TOGGLE-BOX tglControleVoir IN FRAME frmFonction
   6                                                                    */
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


&Scoped-define SELF-NAME frmFonction
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL frmFonction C-Win
ON LEAVE OF FRAME frmFonction
DO:
  
    RUN SauveZonesSaisie.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btnbatch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btnbatch C-Win
ON CHOOSE OF Btnbatch IN FRAME frmFonction /* Voir le fichier batch */
DO:
  OS-COMMAND SILENT VALUE(gcRepertoireRessourcesPrivees + "\scripts\general\execute2.bat notepad.exe """ + cFichierBatchEntree + """").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btnbatch-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btnbatch-2 C-Win
ON CHOOSE OF Btnbatch-2 IN FRAME frmFonction /* Voir le fichier batch */
DO:
    OS-COMMAND SILENT VALUE(gcRepertoireRessourcesPrivees + "\scripts\general\execute2.bat notepad.exe """ + cFichierBatchSortie + """").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btnbatch-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btnbatch-3 C-Win
ON CHOOSE OF Btnbatch-3 IN FRAME frmFonction /* Voir le fichier batch */
DO:
    OS-COMMAND SILENT VALUE(gcRepertoireRessourcesPrivees + "\scripts\general\execute2.bat notepad.exe """ + cFichierBatchMinute + """").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnPrefsAbsences
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnPrefsAbsences C-Win
ON CHOOSE OF btnPrefsAbsences IN FRAME frmFonction /* Absences */
DO:
  RUN LancePreferences("Absences").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnPrefsActivite
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnPrefsActivite C-Win
ON CHOOSE OF btnPrefsActivite IN FRAME frmFonction /* Activité */
DO:
  
    RUN LancePreferences("activite").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnPrefsAFaire
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnPrefsAFaire C-Win
ON CHOOSE OF btnPrefsAFaire IN FRAME frmFonction /* A Faire */
DO:
  
    RUN LancePreferences("afaire").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnPrefsAgenda
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnPrefsAgenda C-Win
ON CHOOSE OF btnPrefsAgenda IN FRAME frmFonction /* Planificateur */
DO:
  
    RUN LancePreferences("alertes").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnPrefsBases
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnPrefsBases C-Win
ON CHOOSE OF btnPrefsBases IN FRAME frmFonction /* Bases */
DO:
  
    RUN LancePreferences("serveurs").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnPrefsMessages
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnPrefsMessages C-Win
ON CHOOSE OF btnPrefsMessages IN FRAME frmFonction /* Messages */
DO:
  
    RUN LancePreferences("infos").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnPrefsProjets
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnPrefsProjets C-Win
ON CHOOSE OF btnPrefsProjets IN FRAME frmFonction /* Projets */
DO:
  
    RUN LancePreferences("projets").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BtnReinitBoutons
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BtnReinitBoutons C-Win
ON CHOOSE OF BtnReinitBoutons IN FRAME frmFonction /* Réinitialiser les boutons GI Prec, Cli, Suiv et Spe à leurs valeurs d'origine */
DO:
    DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO.
    SauvePreference("BATCH-CLIENT-PREC","H:\dev\outils\progress\Menudev2\Ressources\Scripts\session\Lancement.bat PREC H:\dev\outils\progress\Menudev2\Ressources\Scripts\session\LanceAppliGI.bat").
    SauvePreference("BATCH-CLIENT","H:\dev\outils\progress\Menudev2\Ressources\Scripts\session\Lancement.bat CLI H:\dev\outils\progress\Menudev2\Ressources\Scripts\session\LanceAppliGI.bat").
    SauvePreference("BATCH-CLIENT-SUIV","H:\dev\outils\progress\Menudev2\Ressources\Scripts\session\Lancement.bat SUIV H:\dev\outils\progress\Menudev2\Ressources\Scripts\session\LanceAppliGI.bat").
    SauvePreference("BATCH-CLIENT-SPE","H:\dev\outils\progress\Menudev2\Ressources\Scripts\session\Lancement.bat SPE H:\dev\outils\progress\Menudev2\Ressources\Scripts\session\LanceAppliGI.bat").
    AfficheInformations("Réinitialisation effectuée",3).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BtnReinitMessages
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BtnReinitMessages C-Win
ON CHOOSE OF BtnReinitMessages IN FRAME frmFonction /* Réinitialiser les messages marqués comme "Ne plus voir" */
DO:
    DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO.
    FOR EACH  Prefs   EXCLUSIVE-LOCK
        WHERE   Prefs.cUtilisateur = gcUtilisateur
        AND     Prefs.cCode BEGINS "MESSAGE-"
        :
        DELETE prefs.
    END.

    AfficheInformations("Réinitialisation effectuée",3).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filAnciennes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filAnciennes C-Win
ON LEAVE OF filAnciennes IN FRAME frmFonction
DO:
    SauvePreferenceGenerale("PREFS-GENE-ANCIENNES-SAUVEGARDES",SELF:SCREEN-VALUE).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filBrouillons
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filBrouillons C-Win
ON LEAVE OF filBrouillons IN FRAME frmFonction /* Nombre de 'Brouillons' à lancer au démarrage : (0-5) */
DO:

    APPLY "VALUE-CHANGED" TO filBrouillons.    

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filBrouillons C-Win
ON VALUE-CHANGED OF filBrouillons IN FRAME frmFonction /* Nombre de 'Brouillons' à lancer au démarrage : (0-5) */
DO:
  
    DEFINE VARIABLE iBrouillons AS INTEGER NO-UNDO.
    
    iBrouillons = INTEGER(SELF:SCREEN-VALUE).
    IF iBrouillons > 5 OR iBrouillons < 0 THEN DO:
        MESSAGE "Le nombre de brouillons doit être compris entre 0 et 5 !"
            VIEW-AS ALERT-BOX ERROR
            TITLE "Contrôle de saisie..."
            .
        RETURN NO-APPLY.
    END.
    
    SauvePreference("PREF-MAX-BROUILLONS",STRING(iBrouillons)).
    SauvePreference("PREF-BROUILLON",(IF iBrouillons > 0 THEN "OUI" ELSE "NON")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filControleQuotaValeur
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filControleQuotaValeur C-Win
ON LEAVE OF filControleQuotaValeur IN FRAME frmFonction
DO:
      SauvePreference("PREF-CONTROLE-QUOTA-VALEUR",SELF:SCREEN-VALUE).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filEmail
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filEmail C-Win
ON LEAVE OF filEmail IN FRAME frmFonction
DO:
      SauvePreference("EMAIL-UTILISATEUR",SELF:SCREEN-VALUE).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filFeriesFixes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filFeriesFixes C-Win
ON LEAVE OF filFeriesFixes IN FRAME frmFonction
DO:
      SauvePreferenceGenerale("JOURSFERIESFIXES",SELF:SCREEN-VALUE).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filFeriesMobiles
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filFeriesMobiles C-Win
ON LEAVE OF filFeriesMobiles IN FRAME frmFonction
DO:
    SauvePreferenceGenerale("JOURSFERIESMOBILES",SELF:SCREEN-VALUE).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filInternet
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filInternet C-Win
ON LEAVE OF filInternet IN FRAME frmFonction /* Mot de passe pour l'accès internet */
DO:

    SauvePreference("PREF-PASSEINTERNET",SELF:SCREEN-VALUE).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filInternetUtil
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filInternetUtil C-Win
ON LEAVE OF filInternetUtil IN FRAME frmFonction /* Utilisateur pour l'accès internet */
DO:

    SauvePreference("PREF-PASSEINTERNETUTIL",SELF:SCREEN-VALUE).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filLatenceInternet
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filLatenceInternet C-Win
ON LEAVE OF filLatenceInternet IN FRAME frmFonction /* Temps de latences avant la saisie (en secondes) */
DO:
      SauvePreference("LATENCE-INTERNET",SELF:SCREEN-VALUE).
      giLatenceInternet = INTEGER(DonnePreference("LATENCE-INTERNET")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filMastergi
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filMastergi C-Win
ON LEAVE OF filMastergi IN FRAME frmFonction /* Temps de latences lors de la saisie du mastergi (en secondes) */
DO:
      SauvePreference("LATENCE-MASTERGI",SELF:SCREEN-VALUE).
      giLatenceMax = INTEGER(DonnePreference("LATENCE-MASTERGI")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filParamRepGi
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filParamRepGi C-Win
ON LEAVE OF filParamRepGi IN FRAME frmFonction
DO:
    IF DonnePreference("PREFS-REPGI") <> SELF:SCREEN-VALUE THEN AssigneParametre("BASES-RECHARGE","OUI").
    SauvePreference("PREFS-REPGI",SELF:SCREEN-VALUE).
      
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filParamRepGidev
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filParamRepGidev C-Win
ON LEAVE OF filParamRepGidev IN FRAME frmFonction
DO:
    IF DonnePreference("PREFS-REPGIDEV") <> SELF:SCREEN-VALUE THEN AssigneParametre("BASES-RECHARGE","OUI").
    SauvePreference("PREFS-REPGIDEV",SELF:SCREEN-VALUE).
      
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filParamRepGi_prec
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filParamRepGi_prec C-Win
ON LEAVE OF filParamRepGi_prec IN FRAME frmFonction
DO:
    IF DonnePreference("PREFS-REPGIPREC") <> SELF:SCREEN-VALUE THEN AssigneParametre("BASES-RECHARGE","OUI").
    SauvePreference("PREFS-REPGIPREC",SELF:SCREEN-VALUE).
      
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filParamRepGi_spe
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filParamRepGi_spe C-Win
ON LEAVE OF filParamRepGi_spe IN FRAME frmFonction
DO:
    IF DonnePreference("PREFS-REPGISPE") <> SELF:SCREEN-VALUE THEN AssigneParametre("BASES-RECHARGE","OUI").
    SauvePreference("PREFS-REPGISPE",SELF:SCREEN-VALUE).
      
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filParamRepGi_suiv
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filParamRepGi_suiv C-Win
ON LEAVE OF filParamRepGi_suiv IN FRAME frmFonction
DO:
    IF DonnePreference("PREFS-REPGISUIV") <> SELF:SCREEN-VALUE THEN AssigneParametre("BASES-RECHARGE","OUI").
    SauvePreference("PREFS-REPGISUIV",SELF:SCREEN-VALUE).
      
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filRappelDebut
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filRappelDebut C-Win
ON LEAVE OF filRappelDebut IN FRAME frmFonction /* Rappels horaires uniquement de */
DO:
      SauvePreference("PREF-DEBUTRAPPELHORAIRE",SELF:SCREEN-VALUE).
      
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filRappelFin
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filRappelFin C-Win
ON LEAVE OF filRappelFin IN FRAME frmFonction /* heures à */
DO:
      SauvePreference("PREF-FINRAPPELHORAIRE",SELF:SCREEN-VALUE).
      
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filRepertoireScan
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filRepertoireScan C-Win
ON LEAVE OF filRepertoireScan IN FRAME frmFonction
DO:
    SauvePreference("PREF-DEMON_TICKETS-REPERTOIRE",SELF:SCREEN-VALUE).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filVacancesScolaires
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filVacancesScolaires C-Win
ON LEAVE OF filVacancesScolaires IN FRAME frmFonction
DO:
      SauvePreferenceGenerale("VACANCES-SCOLAIRES",SELF:SCREEN-VALUE).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filVraiNom
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filVraiNom C-Win
ON LEAVE OF filVraiNom IN FRAME frmFonction
DO:
      SauvePreference("PREF-VRAI-NOM",SELF:SCREEN-VALUE).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglBatch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglBatch C-Win
ON VALUE-CHANGED OF tglBatch IN FRAME frmFonction /* Executer un fichier batch au démarrage */
DO:
    SauvePreference("PREF-EXECUTIONBATCHENTREE",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglBatch2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglBatch2 C-Win
ON VALUE-CHANGED OF tglBatch2 IN FRAME frmFonction /* Executer un fichier batch à la fermeture */
DO:
    SauvePreference("PREF-EXECUTIONBATCHSORTIE",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglBoutonsNormaux
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglBoutonsNormaux C-Win
ON VALUE-CHANGED OF tglBoutonsNormaux IN FRAME frmFonction /* Boutons normaux (non plats) dans les écrans de raccourcis */
DO:
    SauvePreference("PREF-BOUTONSNORMAUX",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglby-pass
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglby-pass C-Win
ON VALUE-CHANGED OF tglby-pass IN FRAME frmFonction /* Activer le by-pass des rappels horaires */
DO:
    SauvePreference("PREF-BY-PASS-HORAIRE",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
    glBy-Pass = SELF:CHECKED.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglCommandesDos
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglCommandesDos C-Win
ON VALUE-CHANGED OF tglCommandesDos IN FRAME frmFonction /* Activer les fenêtres DOS lors de leurs executions */
DO:
    AfficheInformations("Modification du paramétrage en cours...",0).

    SauvePreference("COMMANDESDOSVISIBLES",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
    IF SELF:CHECKED  THEN
        OS-COMMAND SILENT VALUE("setx VOIR_COMMANDES_DOS oui").
    ELSE
        OS-COMMAND SILENT VALUE("setx VOIR_COMMANDES_DOS non").

    AfficheInformations("",0).
    MESSAGE "Il faut relancer le menudev2 pour bénéficier de la modification de ce parametre !!"
        VIEW-AS ALERT-BOX INFORMATION
        TITLE "Modification du parametrage..."
        .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglControle
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglControle C-Win
ON VALUE-CHANGED OF tglControle IN FRAME frmFonction /* Activer le contrôle périodique de la machine (Création d'une action dans le planificateur que vous pouvez modifier) */
DO:

    DEFINE VARIABLE cIdentTache AS CHARACTER NO-UNDO.

    SauvePreference("PREF-CONTROLE-ACTIF",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
    RUN MiseAJourOptionsControle.
    DO WITH FRAME frmfonction:
        IF SELF:CHECKED THEN DO:
            /* création de la tache dans le planificateur */
            CREATE agenda.
            ASSIGN
                agenda.cUtilisateur = gcUtilisateur
                agenda.dDate = TODAY
                agenda.iheuredebut = 0
                agenda.cLibelle = "Controle de la machine"
                agenda.ctexte = ""
                agenda.cSon = "-"
                agenda.laction = TRUE
                agenda.iHeureinitiale = 0
                agenda.cAction = "start """" %dlc%\bin\%PROWIN% -ininame %windir%\outilsgi.ini -p ""%SER_OUTILS%\progress\menudev2\sources.dev\controleMachine.p"" -param ""%CONTROLE-OPTIONS%"""
                agenda.lperiodique = TRUE
                agenda.inbperiode = 1
                agenda.cuniteperiode = "J"
                agenda.lWeekEnd = FALSE
                agenda.ldelai = FALSE
                agenda.inbdelai = 0
                agenda.cunitedelai = "-"
                agenda.cident = (IF agenda.cident = "" THEN 
                        gcUtilisateur 
                        + "-" + STRING(YEAR(TODAY),"9999") 
                        + STRING(MONTH(TODAY),"99") 
                        + STRING(DAY(TODAY),"99") 
                        + "-" + replace(STRING(TIME,"hh:mm:ss"),":","")
                        ELSE agenda.cident)
    
                 agenda.lJours = TRUE
                 agenda.lLundi = TRUE
                 agenda.lMardi = TRUE
                 agenda.lMercredi = TRUE
                 agenda.lJeudi = TRUE
                 agenda.lVendredi = TRUE
                 agenda.lSamedi = FALSE
                 agenda.lDimanche = FALSE
                .
            SauvePreference("PREF-CONTROLE-IDENT-AGENDA",agenda.cident).
        END.
        ELSE DO:
            /* Suppression de la tache de l'agenda */
            cIdentTache = DonnePreference("PREF-CONTROLE-IDENT-AGENDA").
            FIND FIRST  agenda  EXCLUSIVE-LOCK
                WHERE   agenda.cident = cIdentTache
                NO-ERROR.
            IF AVAILABLE(agenda) THEN DELETE agenda.
        END.
    END.
    AssigneParametre("AGENDA-RECHARGER","OUI").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglControle7z
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglControle7z C-Win
ON VALUE-CHANGED OF tglControle7z IN FRAME frmFonction /* Contrôler si le fichier 7z est valide (Traitement très long : ~ 1 minute par base) */
DO:
    SauvePreference("PREF-CONTROLE-7Z",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglControleBaseDos
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglControleBaseDos C-Win
ON VALUE-CHANGED OF tglControleBaseDos IN FRAME frmFonction /* Controler le contenu du répertoire bases-dos */
DO:
    SauvePreference("PREF-CONTROLE-BASEDOS",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglControleBaseEtSvg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglControleBaseEtSvg C-Win
ON VALUE-CHANGED OF tglControleBaseEtSvg IN FRAME frmFonction /* Contrôler si la base est présente en plus de la sauvegarde (spécifique xcompil) */
DO:
    SauvePreference("PREF-CONTROLE-BASE+SVG-PRESENTE",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglControleBases
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglControleBases C-Win
ON VALUE-CHANGED OF tglControleBases IN FRAME frmFonction /* Controler la cohérence du répertoire des bases */
DO:
    SauvePreference("PREF-CONTROLE-BASES",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
    RUN MiseAJourOptionsBases.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglControleDisponible
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglControleDisponible C-Win
ON VALUE-CHANGED OF tglControleDisponible IN FRAME frmFonction /* Résumé de la place disponible sur la machine */
DO:
    SauvePreference("PREF-CONTROLE-DISPONIBLE",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
     RUN MiseAJourOptionsDispo.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglControleDispoQuota
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglControleDispoQuota C-Win
ON VALUE-CHANGED OF tglControleDispoQuota IN FRAME frmFonction /* Prévenir si la place disponible est en dessous de : */
DO:
    SauvePreference("PREF-CONTROLE-QUOTA",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglControleExclus
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglControleExclus C-Win
ON VALUE-CHANGED OF tglControleExclus IN FRAME frmFonction /* Traiter aussi les répertoires exclus (répertoires de base avec l'extension '.exc') */
DO:
    SauvePreference("PREF-CONTROLE-EXCLUS",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglControleMail
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglControleMail C-Win
ON VALUE-CHANGED OF tglControleMail IN FRAME frmFonction /* Envoyer le log par mail en fin de contrôle  (Implique d'avoir saisi une adresse EMail) */
DO:
    SauvePreference("PREF-CONTROLE-MAIL",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglControleQueSiErreur
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglControleQueSiErreur C-Win
ON VALUE-CHANGED OF tglControleQueSiErreur IN FRAME frmFonction /* Voir le log ou l'envoyer par mail que si présence d"erreur(s) */
DO:
    SauvePreference("PREF-CONTROLE-QUE-SI-ERREUR",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglControleSvg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglControleSvg C-Win
ON VALUE-CHANGED OF tglControleSvg IN FRAME frmFonction /* Controler que la sauvegarde de la base est présente */
DO:
    SauvePreference("PREF-CONTROLE-SVG-PRESENTE",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglControleVoir
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglControleVoir C-Win
ON VALUE-CHANGED OF tglControleVoir IN FRAME frmFonction /* Voir le log en fin de contrôle */
DO:
    SauvePreference("PREF-CONTROLE-VISU-LOG",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglDemonTicket
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglDemonTicket C-Win
ON VALUE-CHANGED OF tglDemonTicket IN FRAME frmFonction /* Récupération ticket + référence pour ouverture répertoire ticket */
DO:
    SauvePreference("PREF-DEMON_TICKETS",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglDemonTicketVerbose
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglDemonTicketVerbose C-Win
ON VALUE-CHANGED OF tglDemonTicketVerbose IN FRAME frmFonction /* Traitement en mode 'Verbose' */
DO:
    SauvePreference("PREF-DEMON_TICKETS-VERBOSE",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglDeveloppeur
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglDeveloppeur C-Win
ON VALUE-CHANGED OF tglDeveloppeur IN FRAME frmFonction /* Activer l'option 'Développeur' pour faciliter le débug */
DO:
    SauvePreference("PREF-DEVELOPPEUR",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglLog
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglLog C-Win
ON VALUE-CHANGED OF tglLog IN FRAME frmFonction /* Activer le Log de menudev2 */
DO:
    SauvePreference("PREF-ACTIVELOG",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
    glLogActif = SELF:CHECKED.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglMemo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglMemo C-Win
ON VALUE-CHANGED OF tglMemo IN FRAME frmFonction /* Se positionner sur le Mémo général et non sur le Mémo du jour */
DO:
    SauvePreference("PREF-MEMOGENE",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglMinutes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglMinutes C-Win
ON VALUE-CHANGED OF tglMinutes IN FRAME frmFonction /* Executer un fichier batch toutes les minutes */
DO:
    SauvePreference("PREF-EXECUTIONBATCHMINUTES",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglModule
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglModule C-Win
ON VALUE-CHANGED OF tglModule IN FRAME frmFonction /* Sauvegarde du dernier module utilisé */
DO:
    SauvePreference("PREF-DERNIER-MODULE",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglModuleInvisibles
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglModuleInvisibles C-Win
ON VALUE-CHANGED OF tglModuleInvisibles IN FRAME frmFonction /* Voir les modules "invisibles" (Administrateurs uniquement) */
DO:
    SauvePreference("PREF-VOIRMODULESINVISIBLES",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglMuet
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglMuet C-Win
ON VALUE-CHANGED OF tglMuet IN FRAME frmFonction /* Fonctionner en mode silencieux (Aucun son) */
DO:
    SauvePreference("PREF-MODESILENCIEUX",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglPosition
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglPosition C-Win
ON VALUE-CHANGED OF tglPosition IN FRAME frmFonction /* Sauvegarde de la position en quittant */
DO:
    SauvePreference("PREF-POSITION",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglPrefsDirect
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglPrefsDirect C-Win
ON VALUE-CHANGED OF tglPrefsDirect IN FRAME frmFonction /* Accèder aux préférence d'un module directement sans passer par les préférences générales */
DO:
    SauvePreference("PREFS-MODULE-DIRECT",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglSaisieInternet
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglSaisieInternet C-Win
ON VALUE-CHANGED OF tglSaisieInternet IN FRAME frmFonction /* Saisie automatique du mot de passe d'acces internet */
DO:
    SauvePreference("PREF-SAISIEINTERNET",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
    filLatenceInternet:SENSITIVE = SELF:CHECKED.
    filInternet:SENSITIVE = SELF:CHECKED.
    filInternetUtil:SENSITIVE = SELF:CHECKED.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglSaisieMasterGI
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglSaisieMasterGI C-Win
ON VALUE-CHANGED OF tglSaisieMasterGI IN FRAME frmFonction /* Saisie automatique du mot de passe MasterGI */
DO:
    SauvePreference("PREF-SAISIEMASTERGI",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
    filMastergi:SENSITIVE = SELF:CHECKED.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglSortie
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglSortie C-Win
ON VALUE-CHANGED OF tglSortie IN FRAME frmFonction /* Demander confirmation lors de la sortie du programme */
DO:
    SauvePreference("PREF-SORTIE",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglVersionManuelle
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglVersionManuelle C-Win
ON VALUE-CHANGED OF tglVersionManuelle IN FRAME frmFonction /* Gérer les informations de version manuellement */
DO:
    SauvePreference("AIDE-BOUTON-MANUELLE",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
    RUN DonneOrdre("GESTION-VERSIONS").                                                                             
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tglWord
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tglWord C-Win
ON VALUE-CHANGED OF tglWord IN FRAME frmFonction /* Passer par Word pour les éditions */
DO:
    SauvePreference("PREF-EDITIONSWORD",(IF SELF:CHECKED THEN "OUI" ELSE "NON")).
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
  APPLY "entry" TO FRAME frmfonction.
  IF NOT THIS-PROCEDURE:PERSISTENT THEN
    WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

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
  DISPLAY tglPrefsDirect filVraiNom filEmail tglSortie tglPosition tglModule 
          tglBoutonsNormaux filBrouillons tglMemo filRappelDebut filRappelFin 
          tglMuet tglWord tglBatch filParamRepGi tglBatch2 filParamRepGidev 
          tglMinutes filParamRepGi_prec filParamRepGi_suiv tglVersionManuelle 
          filParamRepGi_spe tglSaisieMasterGI tglSaisieInternet filMastergi 
          filLatenceInternet tglDemonTicket filInternetUtil filInternet 
          filRepertoireScan tglDemonTicketVerbose tglDeveloppeur tglby-pass 
          tglLog tglCommandesDos tglModuleInvisibles tglControle tglControleVoir 
          tglControleMail tglControleQueSiErreur tglControleBases tglControleSvg 
          tglControleBaseEtSvg tglControle7z tglControleExclus 
          tglControleBaseDos tglControleDisponible tglControleDispoQuota 
          filControleQuotaValeur filFeriesFixes filVacancesScolaires 
          filFeriesMobiles filAnciennes 
      WITH FRAME frmFonction IN WINDOW C-Win.
  ENABLE RECT-2 RECT-12 RECT-13 RECT-14 RECT-15 RECT-16 RECT-9 RECT-17 
         btnPrefsAbsences btnPrefsActivite btnPrefsAFaire btnPrefsAgenda 
         btnPrefsBases btnPrefsMessages btnPrefsProjets tglPrefsDirect 
         filVraiNom filEmail tglSortie BtnReinitMessages tglPosition 
         BtnReinitBoutons tglModule tglBoutonsNormaux filBrouillons tglMemo 
         filRappelDebut filRappelFin tglMuet tglWord tglBatch Btnbatch 
         filParamRepGi tglBatch2 Btnbatch-2 filParamRepGidev tglMinutes 
         Btnbatch-3 filParamRepGi_prec filParamRepGi_suiv tglVersionManuelle 
         filParamRepGi_spe tglSaisieMasterGI tglSaisieInternet filMastergi 
         filLatenceInternet tglDemonTicket filInternetUtil filInternet 
         filRepertoireScan tglDemonTicketVerbose tglDeveloppeur tglby-pass 
         tglLog tglCommandesDos tglModuleInvisibles tglControle tglControleVoir 
         tglControleMail tglControleQueSiErreur tglControleBases tglControleSvg 
         tglControleBaseEtSvg tglControle7z tglControleExclus 
         tglControleBaseDos tglControleDisponible tglControleDispoQuota 
         filControleQuotaValeur filFeriesFixes filVacancesScolaires 
         filFeriesMobiles filAnciennes 
      WITH FRAME frmFonction IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-frmFonction}
  VIEW FRAME frmModule IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-frmModule}
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
                RUN RafraichissementPreferences.
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
        END CASE. /* fin du case */
    END. /* fin du do iboucle */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ExtractionFichier C-Win 
PROCEDURE ExtractionFichier :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE OUTPUT PARAMETER cResultat-ou AS CHARACTER NO-UNDO INIT "".

    DEFINE VARIABLE cFichierAction AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cLigne AS CHARACTER NO-UNDO.

    SYSTEM-DIALOG GET-FILE cFichierAction INITIAL-DIR "c:\pfgi" USE-FILENAME FILTERS "Fichiers de connexion" "*.pf".

    IF cFichierAction <> "" THEN DO:
        INPUT STREAM sEntree FROM value(cFichierAction).
        REPEAT:
            IMPORT STREAM sEntree UNFORMATTED cLigne.
            IF cLigne MATCHES "*ladb*"
                OR cLigne MATCHES "*lcompta*"
                OR cLigne MATCHES "*wadb*"
                OR cLigne MATCHES "*ltrans*"
                THEN DO:
                cResultat-ou = cResultat-ou + (IF cResultat-ou <> "" THEN CHR(10) ELSE "") + cLigne.
            END.
        END.
    END.

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
    gcAideRaf = "#INTERDIT#".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE GereZonesAccessibles C-Win 
PROCEDURE GereZonesAccessibles :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    IF NOT glUtilisateurAdmin OR TRUE THEN DO WITH FRAME frmFonction:
        tglDeveloppeur:SENSITIVE = FALSE.
        tglModuleInvisibles:SENSITIVE = FALSE.
        tglBy-Pass:SENSITIVE = FALSE.
        filFeriesFixes:READ-ONLY = TRUE.
        filFeriesMobiles:READ-ONLY = TRUE.
        filAnciennes:READ-ONLY = TRUE.
        filVacancesScolaires:READ-ONLY = TRUE.
    END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE GereZonesSaisie C-Win 
PROCEDURE GereZonesSaisie :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    DO WITH FRAME frmfonction:
    END.

    RUN DonneOrdre("ORDRE-GENERAL=MAJ-PREFERENCES").

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
    
    FRAME frmModule:WIDTH = gdLargeur.
    FRAME frmModule:HEIGHT = gdHauteur.
    FRAME frmModule:COLUMN = gdPositionXModule.
    FRAME frmModule:ROW = gdPositionYModule.

    IF integer(DonnePreference("LATENCE-MASTERGI")) = 0 THEN SauvePreference("LATENCE-MASTERGI","1").
    IF DonnePreference("REPERTOIRES-APPLI") = "" THEN SauvePreference("REPERTOIRES-APPLI",disque + "gidev").
    IF DonnePreference("PREF-DEBUTRAPPELHORAIRE") = "" THEN SauvePreference("PREF-DEBUTRAPPELHORAIRE","09").
    IF DonnePreference("PREF-FINRAPPELHORAIRE") = "" THEN SauvePreference("PREF-FINRAPPELHORAIRE","17").
    IF DonnePreference("PREF-SAISIEMASTERGI") = "" THEN SauvePreference("PREF-SAISIEMASTERGI","OUI").
    IF DonnePreference("PREF-FILTRESPROJETS") = "" THEN SauvePreference("PREF-FILTRESPROJETS","*.doc,*.xls,*.pdf,*.7z,*.zip,*.jpg,*.jpeg,*.txt").
    IF integer(DonnePreference("PREF-MAX-BROUILLONS")) = 0 THEN SauvePreference("PREF-MAX-BROUILLONS","5").
    
    /* Chargement des images */
    
    RUN RafraichissementPreferences.

    cFichierBatchEntree = gcRepertoireRessourcesPrivees + "Utilisateurs\" + gcUtilisateur + "\" + gcUtilisateur + "-Entree.bat".
    cFichierBatchSortie = gcRepertoireRessourcesPrivees + "Utilisateurs\" + gcUtilisateur + "\" + gcUtilisateur + "-Sortie.bat".
    cFichierBatchMinute = gcRepertoireRessourcesPrivees + "Utilisateurs\" + gcUtilisateur + "\" + gcUtilisateur + "-Minute.bat".

    RUN TopChronoGeneral.

    RUN GereZonesAccessibles.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE LancePreferences C-Win 
PROCEDURE LancePreferences :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER cIdentModule-in AS CHARACTER NO-UNDO.

    DEFINE VARIABLE cProgPrefs AS CHARACTER NO-UNDO.

    cProgPrefs = gcRepertoireExecution + "prefs-" + DonneProgramme(cIdentModule-in) + ".w".
         
    /*MESSAGE "cProgPrefs = " cProgPrefs VIEW-AS ALERT-BOX.*/

    IF SEARCH(cProgPrefs) <> ? THEN RUN VALUE(cProgPrefs) (cIdentModule-in).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MiseAJourOptionsBases C-Win 
PROCEDURE MiseAJourOptionsBases :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    DEFINE VARIABLE lValeur AS LOGICAL NO-UNDO INIT FALSE.

    lValeur = DonnePreference("PREF-CONTROLE-BASES") = "OUI".

    DO WITH FRAME frmfonction:
        tglControleSvg:SENSITIVE = lValeur.
        tglControleBaseEtSvg:SENSITIVE = lValeur.
        tglControle7z:SENSITIVE = lValeur.          
        tglControleExclus:SENSITIVE = lValeur.          
    END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MiseAJourOptionsControle C-Win 
PROCEDURE MiseAJourOptionsControle :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE lValeur AS LOGICAL NO-UNDO INIT FALSE.

    lValeur = DonnePreference("PREF-CONTROLE-ACTIF") = "OUI".

    DO WITH FRAME frmfonction:
        tglControleMail:SENSITIVE = lValeur.
        tglControleQueSiErreur:SENSITIVE = lValeur.
        tglControleBases:SENSITIVE = lValeur.
        tglControleBaseDos:SENSITIVE = lValeur.
        tglControleVoir:SENSITIVE = lValeur.
        tglControleDisponible:SENSITIVE = lValeur.
        tglControleSvg:SENSITIVE = lValeur.
        tglControleBaseEtSvg:SENSITIVE = lValeur.
        tglControle7z:SENSITIVE = lValeur.          
        tglControleDispoQuota:SENSITIVE = lValeur.
        tglControleExclus:SENSITIVE = lValeur.
        filControleQuotaValeur:SENSITIVE = lValeur.
    END.

    IF lValeur THEN RUN MiseAJourOptionsBases.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MiseAJourOptionsDispo C-Win 
PROCEDURE MiseAJourOptionsDispo :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    DEFINE VARIABLE lValeur AS LOGICAL NO-UNDO INIT FALSE.

    lValeur = DonnePreference("PREF-CONTROLE-DISPONIBLE") = "OUI".

    DO WITH FRAME frmfonction:
        tglControleDispoQuota:SENSITIVE = lValeur.
        filControleQuotaValeur:SENSITIVE = lValeur.
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

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE RafraichissementPreferences C-Win 
PROCEDURE RafraichissementPreferences :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    DO WITH FRAME frmFonction:   
        ENABLE ALL. 
        
        tglControle:CHECKED = (IF DonnePreference("PREF-CONTROLE-ACTIF") = "OUI" THEN TRUE ELSE FALSE).
        /*RUN MiseAJourOptionsControle.*/
        tglControleMail:CHECKED = (IF DonnePreference("PREF-CONTROLE-MAIL") = "OUI" THEN TRUE ELSE FALSE).
        tglControleQueSiErreur:CHECKED = (IF DonnePreference("PREF-CONTROLE-QUE-SI-ERREUR") = "OUI" THEN TRUE ELSE FALSE).
        tglControleBases:CHECKED = (IF DonnePreference("PREF-CONTROLE-BASES") = "OUI" THEN TRUE ELSE FALSE).
        tglControleBaseDos:CHECKED = (IF DonnePreference("PREF-CONTROLE-BASEDOS") = "OUI" THEN TRUE ELSE FALSE).
        tglControleVoir:CHECKED = (IF DonnePreference("PREF-CONTROLE-VISU-LOG") = "OUI" THEN TRUE ELSE FALSE).
        tglControleDisponible:CHECKED = (IF DonnePreference("PREF-CONTROLE-DISPONIBLE") = "OUI" THEN TRUE ELSE FALSE).
        tglControleSvg:CHECKED = (IF DonnePreference("PREF-CONTROLE-SVG-PRESENTE") = "OUI" THEN TRUE ELSE FALSE).
        tglControleBaseEtSvg:CHECKED = (IF DonnePreference("PREF-CONTROLE-BASE+SVG-PRESENTE") = "OUI" THEN TRUE ELSE FALSE).
        tglControle7z:CHECKED = (IF DonnePreference("PREF-CONTROLE-7Z") = "OUI" THEN TRUE ELSE FALSE).
        tglControleExclus:CHECKED = (IF DonnePreference("PREF-CONTROLE-EXCLUS") = "OUI" THEN TRUE ELSE FALSE).
        tglControleDispoQuota:CHECKED = (IF DonnePreference("PREF-CONTROLE-QUOTA") = "OUI" THEN TRUE ELSE FALSE).
        filControleQuotaValeur:SCREEN-VALUE = DonnePreference("PREF-CONTROLE-QUOTA-VALEUR").
        
        IF integer(filControleQuotaValeur:SCREEN-VALUE) = 0 THEN DO:
            filControleQuotaValeur:SCREEN-VALUE = "10".
            SauvePreference("PREF-CONTROLE-QUOTA-VALEUR",filControleQuotaValeur:SCREEN-VALUE).
        END.
        RUN MiseAJourOptionsControle.

        tglModule:CHECKED = (IF DonnePreference("PREF-DERNIER-MODULE") = "OUI" THEN TRUE ELSE FALSE).
        filEmail:SCREEN-VALUE = DonnePreference("EMAIL-UTILISATEUR").
        filVraiNom:SCREEN-VALUE = DonnePreference("PREF-VRAI-NOM").
        tglPosition:CHECKED = (IF DonnePreference("PREF-POSITION") = "OUI" THEN TRUE ELSE FALSE).
        tglSortie:CHECKED = (IF DonnePreference("PREF-SORTIE") = "OUI" THEN TRUE ELSE FALSE).
        tglMemo:CHECKED = (IF DonnePreference("PREF-MEMOGENE") = "OUI" THEN TRUE ELSE FALSE).
        tglLog:CHECKED = (IF DonnePreference("PREF-ACTIVELOG") = "OUI" THEN TRUE ELSE FALSE).
        tglModuleInvisibles:CHECKED = (IF DonnePreference("PREF-VOIRMODULESINVISIBLES") = "OUI" THEN TRUE ELSE FALSE).
        tglMuet:CHECKED = (IF DonnePreference("PREF-MODESILENCIEUX") = "OUI" THEN TRUE ELSE FALSE).
        tglSaisieMasterGI:CHECKED = (IF DonnePreference("PREF-SAISIEMASTERGI") = "OUI" THEN TRUE ELSE FALSE).
        filmastergi:SCREEN-VALUE = DonnePreference("LATENCE-MASTERGI").
        filMastergi:SENSITIVE = tglSaisieMasterGI:CHECKED.
        /*filrepertoires:SCREEN-VALUE = DonnePreference("REPERTOIRES-APPLI").*/
        tglModuleInvisibles:SENSITIVE = glUtilisateurAdmin.
        tglBatch:CHECKED = (IF DonnePreference("PREF-EXECUTIONBATCHENTREE") = "OUI" THEN TRUE ELSE FALSE).
        tglBatch2:CHECKED = (IF DonnePreference("PREF-EXECUTIONBATCHSORTIE") = "OUI" THEN TRUE ELSE FALSE).
        tglMinutes:CHECKED = (IF DonnePreference("PREF-EXECUTIONBATCHMINUTES") = "OUI" THEN TRUE ELSE FALSE).
        filRappelDebut:SCREEN-VALUE = DonnePreference("PREF-DEBUTRAPPELHORAIRE").
        filRappelFin:SCREEN-VALUE = DonnePreference("PREF-FINRAPPELHORAIRE").
        tglBoutonsNormaux:CHECKED = (IF DonnePreference("PREF-BOUTONSNORMAUX") = "OUI" THEN TRUE ELSE FALSE).
        tglDeveloppeur:CHECKED = (IF DonnePreference("PREF-DEVELOPPEUR") = "OUI" THEN TRUE ELSE FALSE).
        tglWord:CHECKED = (IF DonnePreference("PREF-EDITIONSWORD") = "OUI" THEN TRUE ELSE FALSE).
        filBrouillons:SCREEN-VALUE = DonnePreference("PREF-MAX-BROUILLONS").

        IF OS-GETENV("VOIR_COMMANDES_DOS") = "oui" THEN 
            SauvePreference("COMMANDESDOSVISIBLES","oui").
        ELSE 
            SauvePreference("COMMANDESDOSVISIBLES","non").
        tglCommandesDos:CHECKED = (IF DonnePreference("COMMANDESDOSVISIBLES") = "OUI" THEN TRUE ELSE FALSE).
    
        filInternet:SCREEN-VALUE = DonnePreference("PREF-PASSEINTERNET").
        filInternetUtil:SCREEN-VALUE = DonnePreference("PREF-PASSEINTERNETUTIL").
        tglSaisieInternet:CHECKED = (IF DonnePreference("PREF-SAISIEINTERNET") = "OUI" THEN TRUE ELSE FALSE).
        filLatenceInternet:SCREEN-VALUE = DonnePreference("LATENCE-INTERNET").
        filLatenceInternet:SENSITIVE = tglSaisieInternet:CHECKED.
        filInternet:SENSITIVE = tglSaisieInternet:CHECKED.
        filInternetUtil:SENSITIVE = tglSaisieInternet:CHECKED.
        filFeriesFixes:SCREEN-VALUE = DonnePreferenceGenerale("JOURSFERIESFIXES").
        filFeriesMobiles:SCREEN-VALUE = DonnePreferenceGenerale("JOURSFERIESMOBILES").
        filAnciennes:SCREEN-VALUE = DonnePreferenceGenerale("PREFS-GENE-ANCIENNES-SAUVEGARDES").
        tglVersionManuelle:CHECKED = (IF DonnePreference("AIDE-BOUTON-MANUELLE") = "OUI" THEN TRUE ELSE FALSE).       
        tglPrefsDirect:CHECKED = (IF DonnePreference("PREFS-MODULE-DIRECT") = "OUI" THEN TRUE ELSE FALSE).    
        filVacancesScolaires:SCREEN-VALUE = DonnePreferenceGenerale("VACANCES-SCOLAIRES").
        
        tglDemonTicket:CHECKED = (IF DonnePreference("PREF-DEMON_TICKETS") = "OUI" THEN TRUE ELSE FALSE).    
        tglby-pass:CHECKED = (IF DonnePreference("PREF-BY-PASS-HORAIRE") = "OUI" THEN TRUE ELSE FALSE).

        glBy-Pass = tglby-pass:CHECKED.
        
        filRepertoireScan:SCREEN-VALUE = DonnePreference("PREF-DEMON_TICKETS-REPERTOIRE").
        tglDemonTicketVerbose:CHECKED = (DonnePreference("PREF-DEMON_TICKETS-VERBOSE") = "OUI").

        filParamRepGi:SCREEN-VALUE = DonnePreference("PREFS-REPGI").
        filParamRepGidev:SCREEN-VALUE = DonnePreference("PREFS-REPGIDEV").
        filParamRepGi_prec:SCREEN-VALUE = DonnePreference("PREFS-REPGIPREC").
        filParamRepGi_suiv:SCREEN-VALUE = DonnePreference("PREFS-REPGISUIV").
        filParamRepGi_spe:SCREEN-VALUE = DonnePreference("PREFS-REPGISPE")
            .
        RUN GereZonesSaisie.
    END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE SauveZonesSaisie C-Win 
PROCEDURE SauveZonesSaisie :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    DO WITH FRAME frmfonction:      
    END.

    RUN DonneOrdre("RAF-PREFERENCES").
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

