&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME winaide
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS winaide 
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
{menudev2\includes\menudev2.i NEW}

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
DEFINE VARIABLE lInitialiser    AS LOGICAL  NO-UNDO.
DEFINE VARIABLE lRetour         AS LOGICAL  NO-UNDO.
DEFINE VARIABLE cMenudev        AS CHARACTER    NO-UNDO.
DEFINE VARIABLE cCommande       AS CHARACTER    NO-UNDO.
DEFINE VARIABLE iTemporisation AS INTEGER   NO-UNDO INIT 0.
DEFINE VARIABLE iTemporisation2 AS INTEGER   NO-UNDO INIT 0.
DEFINE VARIABLE iTemporisation3 AS INTEGER   NO-UNDO INIT 3.
DEFINE VARIABLE iTemporisation4 AS INTEGER   NO-UNDO INIT 10.
DEFINE VARIABLE iSynchro AS INTEGER INIT 60.
DEFINE VARIABLE iSynchro2 AS INTEGER INIT 60.
DEFINE VARIABLE hFenetre AS INTEGER NO-UNDO.
DEFINE VARIABLE hFenetreold AS INTEGER NO-UNDO.
DEFINE VARIABLE cTypeApplication AS CHARACTER NO-UNDO.
DEFINE VARIABLE lAction AS LOGICAL NO-UNDO.
DEFINE VARIABLE cFichierInformations AS CHARACTER NO-UNDO.
DEFINE VARIABLE lRecharger AS LOGICAL INIT FALSE /*?*/ NO-UNDO.
DEFINE VARIABLE iX AS INTEGER NO-UNDO.
DEFINE VARIABLE iY AS INTEGER NO-UNDO.
DEFINE VARIABLE lAvertissement AS LOGICAL NO-UNDO INIT TRUE.
DEFINE VARIABLE cProgrammeExterne AS CHARACTER NO-UNDO.
DEFINE VARIABLE lManuel AS LOGICAL  NO-UNDO INIT FALSE.
DEFINE VARIABLE cTempo AS CHARACTER NO-UNDO.
DEFINE VARIABLE iCompteur5m AS INTEGER NO-UNDO INIT 0.
DEFINE VARIABLE lAction5m AS LOGICAL NO-UNDO.
DEFINE VARIABLE iAncienEtime AS INTEGER NO-UNDO.

DEFINE STREAM gstrEntree.
DEFINE STREAM gstrSortie.
DEFINE STREAM stInfos.
DEFINE STREAM stBulle.
DEFINE STREAM stTicket.


    DEFINE VARIABLE cFichierBatchGeneral AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cFichierBatchEntree AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cFichierBatchSortie AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cFichierBatchMinute AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cFichierBulle AS CHARACTER NO-UNDO.

    DEFINE TEMP-TABLE ttModulesUtilisateur
        FIELD cLibelle  AS CHARACTER
        FIELD lFavoris  AS LOGICAL
        FIELD cIdent    AS CHARACTER
        FIELD iOrdre    AS INTEGER
        FIELD lInvisible  AS LOGICAL INIT FALSE
        FIELD iCouleur  AS INTEGER

        INDEX idxModules iOrdre 
        .

    DEFINE TEMP-TABLE ttModulesActifs
        FIELD cIdent    AS CHARACTER
        FIELD cLibelle  AS CHARACTER
        FIELD iOrdre    AS INTEGER
        .


    DEFINE VARIABLE m_ListeActifs AS WIDGET-HANDLE.


    DEFINE VARIABLE hModuleBrouillon     AS HANDLE   NO-UNDO.


    DEFINE TEMP-TABLE ttOrdres LIKE ordres
        .
    DEFINE TEMP-TABLE ttFichiers
        FIELD cNomFichier AS CHARACTER
        FIELD cNomCompletFichier AS CHARACTER.
        .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME frmFond
&Scoped-define BROWSE-NAME brwinfos

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ttordres ttModulesUtilisateur

/* Definitions for BROWSE brwinfos                                      */
&Scoped-define FIELDS-IN-QUERY-brwinfos ttOrdres.cMessageDistribue   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brwinfos   
&Scoped-define SELF-NAME brwinfos
&Scoped-define QUERY-STRING-brwinfos FOR EACH ttordres     BY ttordres.ddate BY ttordres.iOrdre     INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-brwinfos OPEN QUERY {&SELF-NAME} FOR EACH ttordres     BY ttordres.ddate BY ttordres.iOrdre     INDEXED-REPOSITION                                   .
&Scoped-define TABLES-IN-QUERY-brwinfos ttordres
&Scoped-define FIRST-TABLE-IN-QUERY-brwinfos ttordres


/* Definitions for BROWSE brwModules                                    */
&Scoped-define FIELDS-IN-QUERY-brwModules ttModulesUtilisateur.cLibelle   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brwModules   
&Scoped-define SELF-NAME brwModules
&Scoped-define QUERY-STRING-brwModules FOR EACH ttModulesUtilisateur WHERE ttModulesUtilisateur.lInvisible = FALSE BY ttModulesUtilisateur.iOrdre /*clibelle*/
&Scoped-define OPEN-QUERY-brwModules OPEN QUERY {&SELF-NAME} FOR EACH ttModulesUtilisateur WHERE ttModulesUtilisateur.lInvisible = FALSE BY ttModulesUtilisateur.iOrdre /*clibelle*/.
&Scoped-define TABLES-IN-QUERY-brwModules ttModulesUtilisateur
&Scoped-define FIRST-TABLE-IN-QUERY-brwModules ttModulesUtilisateur


/* Definitions for FRAME frmFond                                        */
&Scoped-define OPEN-BROWSERS-IN-QUERY-frmFond ~
    ~{&OPEN-QUERY-brwinfos}~
    ~{&OPEN-QUERY-brwModules}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rctBoutons rctBoutons-3 rctBoutons-5 ~
rctBoutons-4 rctRaff rctRaff-2 btnQuitter filBoutonDev filBoutonPrec ~
filBoutongi filBoutonSuiv filBoutonSpe brwModules brwinfos btnPerso-1 ~
btnPerso-2 btnPerso-3 btnPerso-4 btnPerso-5 btnPerso-6 btnCli btnCliPrec ~
btnCliSpe btnCliSuiv btnAssistance btnInternet btnGI btnModifier btnEmprunt ~
btnPutty btnTeamviewer btnAbandon btnAjouter btnImprimer btnRaf ~
btnSupprimer btnValidation 
&Scoped-Define DISPLAYED-OBJECTS filBoutonDev filBoutonPrec filBoutongi ~
filBoutonSuiv filBoutonSpe 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD cFormatteEtime winaide 
FUNCTION cFormatteEtime RETURNS CHARACTER
  ( iEtimeEnCours AS INTEGER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD ChargeToolTip winaide 
FUNCTION ChargeToolTip RETURNS LOGICAL
  ( hObjet AS HANDLE,cChaine AS CHARACTER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD ControleServeurs winaide 
FUNCTION ControleServeurs RETURNS LOGICAL
  ( cVersion-in AS CHARACTER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD DonneImagePerso winaide 
FUNCTION DonneImagePerso RETURNS CHARACTER
  ( cNumeroBouton-in AS CHARACTER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD DonneVersion winaide 
FUNCTION DonneVersion RETURNS CHARACTER
  ( cVersion-in AS CHARACTER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD mLogDebug winaide 
FUNCTION mLogDebug RETURNS LOGICAL
  ( cLibelle-in AS CHARACTER, iEtime-in AS INTEGER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR winaide AS WIDGET-HANDLE NO-UNDO.

/* Menu Definitions                                                     */
DEFINE MENU MENU-BAR-WinAide MENUBAR
       MENU-ITEM m_Préférences  LABEL "Préférences"   
       MENU-ITEM m_Admin        LABEL "Administration"
              DISABLED
       MENU-ITEM m_Brouillon    LABEL "Brouillon"     
       MENU-ITEM m_Informations_de_Debug LABEL "Informations de Debug".

DEFINE MENU POPUP-MENU-brwinfos 
       MENU-ITEM m_Supprimer_le_message_en_cou LABEL "Supprimer le message en cours"
       MENU-ITEM m_Supprimer_tous_les_messages LABEL "Supprimer tous les messages"
       RULE
       MENU-ITEM m_Envoyer_le_message_en_cours LABEL "Envoyer le message en cours dans le presse-papier"
       MENU-ITEM m_Envoyer_tous_les_message_da LABEL "Envoyer tous les messages dans le presse-papier"
       RULE
       MENU-ITEM m_Répondre_à_lutilisateur_du_ LABEL "Répondre à l'utilisateur du message en cours"
       MENU-ITEM m_Marquer_le_message_comme_LU LABEL "Marquer le message comme 'LU'"
       RULE
       MENU-ITEM m_Fermer5      LABEL "Fermer"        .

DEFINE MENU POPUP-MENU-brwModules 
       MENU-ITEM m_Déplacer_haut LABEL "Déplacer le module vers le haut"
       MENU-ITEM m_Déplacer_bas LABEL "Déplacer le module vers le bas"
       RULE
       MENU-ITEM m_Remettre     LABEL "Remettre les modules à leurs positions par défaut"
       RULE
       MENU-ITEM m_Ne_pas_voir_ce_module LABEL "Ne pas voir ce module"
       MENU-ITEM m_Voir_tous_les_modules LABEL "Voir tous les modules"
       RULE
       MENU-ITEM m_Changer_la_couleur_du_modul LABEL "Changer la couleur du module"
       MENU-ITEM m_Réinitialiser_avec_les_coul LABEL "Réinitialiser avec les couleurs d'origine"
       RULE
       MENU-ITEM m_Fermer_ce_menu LABEL "Fermer ce menu".

DEFINE MENU POPUP-MENU-btnAssistance 
       MENU-ITEM m_Paramétrer8  LABEL "Paramétrer"    
       MENU-ITEM m_Modifier_limage8 LABEL "Modifier l'image"
       RULE
       MENU-ITEM m_Remettre_image_par_défaut8 LABEL "Remettre image par défaut"
       RULE
       MENU-ITEM m_Fermer13     LABEL "Fermer"        .

DEFINE SUB-MENU m_Gestion_de_la_version_CLI 
       MENU-ITEM m_Sauvegarder_Cli LABEL "Sauvegarder la version"
       MENU-ITEM m_Restorer_Cli LABEL "Restaurer une version"
       RULE
       MENU-ITEM m_Patch_Cli    LABEL "Passer un patch sur la version"
       RULE
       MENU-ITEM m_Passer_la_version_du_lundi2 LABEL "Passer la version du lundi"
       RULE
       MENU-ITEM m_Créer_les_répertoires_de_tr LABEL "Créer les répertoires de travail et copier les macros Word et Excel"
       RULE
       MENU-ITEM m_Explorateur_CLI LABEL "Explorateur sur le répertoire".

DEFINE MENU POPUP-MENU-btnCli 
       MENU-ITEM m_____Version_Client_ LABEL "   >>> Version Client <<<"
              DISABLED
       RULE
       MENU-ITEM m_Parametrer_Cli LABEL "Paramétrer"    
       RULE
       SUB-MENU  m_Gestion_de_la_version_CLI LABEL "Gestion de la version"
       RULE
       MENU-ITEM m_Fermer2      LABEL "Fermer"        .

DEFINE SUB-MENU m_Gestion_de_la_version_PREC 
       MENU-ITEM m_Sauvegarder_Prec LABEL "Sauvegarder la version"
       MENU-ITEM m_Restorer_Prec LABEL "Restaurer une version"
       RULE
       MENU-ITEM m_Patch_Prec   LABEL "Passer un patch sur la version"
       RULE
       MENU-ITEM m_Passer_la_version_du_lundi LABEL "Passer la version du lundi"
       RULE
       MENU-ITEM m_Créer_les_répertoires_PREC LABEL "Créer les répertoires de travail et copier les macros Word et Excel"
       RULE
       MENU-ITEM m_Explorateur_PREC LABEL "Explorateur sur le répertoire".

DEFINE MENU POPUP-MENU-btnCliPrec 
       MENU-ITEM m_Version_précédente LABEL "  >>> Version précédente <<<"
              DISABLED
       RULE
       MENU-ITEM m_Parametrer_Prec LABEL "Paramétrer"    
       RULE
       SUB-MENU  m_Gestion_de_la_version_PREC LABEL "Gestion de la version"
       RULE
       MENU-ITEM m_Fermer3      LABEL "Fermer"        .

DEFINE SUB-MENU m_Gestion_de_la_version_SPE 
       MENU-ITEM m_Sauvegarder_SPE LABEL "Sauvegarder la version"
       MENU-ITEM m_Restorer_SPE LABEL "Restaurer une version"
       RULE
       MENU-ITEM m_Patch_Spe    LABEL "Passer un patch sur la version"
       RULE
       MENU-ITEM m_Passer_la_version_du_lundi4 LABEL "Passer la version du lundi"
       RULE
       MENU-ITEM m_Créer_les_répertoires_SPE LABEL "Créer les répertoires de travail et copier les macros Word et Excel"
       RULE
       MENU-ITEM m_Explorateur_Spe LABEL "Explorateur sur le répertoire".

DEFINE MENU POPUP-MENU-btnCliSpe 
       MENU-ITEM m_____Version_Specifique LABEL "   >>> Version Spécifique <<<"
              DISABLED
       RULE
       MENU-ITEM m_Parametrer_Spe LABEL "Paramétrer"    
       RULE
       SUB-MENU  m_Gestion_de_la_version_SPE LABEL "Gestion de la version"
       RULE
       MENU-ITEM m_Fermer-2     LABEL "Fermer"        .

DEFINE SUB-MENU m_Gestion_de_la_version_SUIV 
       MENU-ITEM m_Sauvegarder_Suiv LABEL "Sauvegarder la version"
       MENU-ITEM m_Restorer_Suiv LABEL "Restaurer une version"
       RULE
       MENU-ITEM m_Patch_Suiv   LABEL "Passer un patch sur la version"
       RULE
       MENU-ITEM m_Passer_la_version_du_lundi3 LABEL "Passer la version du lundi"
       RULE
       MENU-ITEM m_Créer_les_répertoires_SUIV LABEL "Créer les répertoires de travail et copier les macros Word et Excel"
       RULE
       MENU-ITEM m_Explorateur_SUIV LABEL "Explorateur sur le répertoire".

DEFINE MENU POPUP-MENU-btnCliSuiv 
       MENU-ITEM m_____Version_Suivante_ LABEL "   >>> Version Suivante <<<"
              DISABLED
       RULE
       MENU-ITEM m_Parametrer_Suiv LABEL "Paramétrer"    
       RULE
       SUB-MENU  m_Gestion_de_la_version_SUIV LABEL "Gestion de la version"
       RULE
       MENU-ITEM m_Fermer       LABEL "Fermer"        .

DEFINE SUB-MENU m_Gestion_de_la_version_DEV 
       MENU-ITEM m_Sauvegarde_DEV LABEL "Sauvegarde de la version"
       MENU-ITEM m_Restorer_DEV LABEL "Restaurer une version"
       RULE
       MENU-ITEM m_Explorateur_gidev LABEL "Explorateur sur le répertoire".

DEFINE MENU POPUP-MENU-btnGI 
       MENU-ITEM m_____Version_DEV_ LABEL "   >>> Version DEV <<<"
       RULE
       MENU-ITEM m_ParametrerDev LABEL "Paramétrer"    
       RULE
       SUB-MENU  m_Gestion_de_la_version_DEV LABEL "Gestion de la version"
       RULE
       MENU-ITEM m_Fermer4      LABEL "Fermer"        .

DEFINE MENU POPUP-MENU-btnInternet 
       MENU-ITEM m_Paramétrer7  LABEL "Paramétrer"    
       MENU-ITEM m_Modifier_limage7 LABEL "Modifier l'image"
       RULE
       MENU-ITEM m_Remettre_image_par_défaut7 LABEL "Remettre image par défaut"
       RULE
       MENU-ITEM m_Fermer12     LABEL "Fermer"        .

DEFINE MENU POPUP-MENU-btnPerso-1 
       MENU-ITEM m_Nom_du_bouton LABEL "Nom du bouton" 
       MENU-ITEM m_Paramétrer   LABEL "Paramétrer"    
       MENU-ITEM m_Modifier_limage LABEL "Modifier l'image"
       RULE
       MENU-ITEM m_Remettre_image_par_défaut LABEL "Remettre image par défaut"
       RULE
       MENU-ITEM m_Fermer6      LABEL "Fermer"        .

DEFINE MENU POPUP-MENU-btnPerso-2 
       MENU-ITEM m_Nom_du_bouton2 LABEL "Nom du bouton" 
       MENU-ITEM m_Paramétrer2  LABEL "Paramétrer"    
       MENU-ITEM m_Modifier_limage2 LABEL "Modifier l'image"
       RULE
       MENU-ITEM m_Remettre_image_par_défaut2 LABEL "Remettre image par défaut"
       RULE
       MENU-ITEM m_Fermer7      LABEL "Fermer"        .

DEFINE MENU POPUP-MENU-btnPerso-3 
       MENU-ITEM m_Nom_du_bouton3 LABEL "Nom du bouton" 
       MENU-ITEM m_Paramétrer3  LABEL "Paramétrer"    
       MENU-ITEM m_Modifier_limage3 LABEL "Modifier l'image"
       RULE
       MENU-ITEM m_Remettre_image_par_défaut3 LABEL "Remettre image par défaut"
       RULE
       MENU-ITEM m_Fermer8      LABEL "Fermer"        .

DEFINE MENU POPUP-MENU-btnPerso-4 
       MENU-ITEM m_Nom_du_bouton4 LABEL "Nom du bouton" 
       MENU-ITEM m_Paramétrer4  LABEL "Paramétrer"    
       MENU-ITEM m_Modifier_limage4 LABEL "Modifier l'image"
       RULE
       MENU-ITEM m_Remettre_image_par_défaut4 LABEL "Remettre image par défaut"
       RULE
       MENU-ITEM m_Fermer9      LABEL "Fermer"        .

DEFINE MENU POPUP-MENU-btnPerso-5 
       MENU-ITEM m_Nom_du_bouton5 LABEL "Nom du bouton" 
       MENU-ITEM m_Paramétrer5  LABEL "Paramétrer"    
       MENU-ITEM m_Modifier_limage5 LABEL "Modifier l'image"
       RULE
       MENU-ITEM m_Remettre_image_par_défaut5 LABEL "Remettre image par défaut"
       RULE
       MENU-ITEM m_Fermer10     LABEL "Fermer"        .

DEFINE MENU POPUP-MENU-btnPerso-6 
       MENU-ITEM m_Nom_du_bouton6 LABEL "Nom du bouton" 
       MENU-ITEM m_Paramétrer6  LABEL "Paramétrer"    
       MENU-ITEM m_Modifier_limage6 LABEL "Modifier l'image"
       RULE
       MENU-ITEM m_Remettre_image_par_défaut6 LABEL "Remettre image par défaut"
       RULE
       MENU-ITEM m_Fermer11     LABEL "Fermer"        .

DEFINE MENU POPUP-MENU-btnQuitter 
       MENU-ITEM m_Redémarrer_Menudev2 LABEL "Redémarrer Menudev2".


/* Definitions of handles for OCX Containers                            */
DEFINE VARIABLE Chrono AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chChrono AS COMPONENT-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON btnAbandon  NO-FOCUS FLAT-BUTTON
     LABEL "-" 
     SIZE-PIXELS 40 BY 40 TOOLTIP "Abandon".

DEFINE BUTTON btnAjouter  NO-FOCUS FLAT-BUTTON
     LABEL "+" 
     SIZE-PIXELS 40 BY 40 TOOLTIP "Ajouter".

DEFINE BUTTON btnAssistance  NO-FOCUS FLAT-BUTTON
     LABEL "A" 
     SIZE-PIXELS 40 BY 40 TOOLTIP "Assistance GI / Clic droit pour paramètrer".

DEFINE BUTTON btnCli  NO-FOCUS FLAT-BUTTON
     LABEL "Gi" 
     SIZE-PIXELS 40 BY 40 TOOLTIP "Application GI (Client) / Clic droit pour paramètrer".

DEFINE BUTTON btnCliPrec  NO-FOCUS FLAT-BUTTON
     LABEL "Gi" 
     SIZE-PIXELS 40 BY 40 TOOLTIP "Application GI (Client) / Clic droit pour paramètrer".

DEFINE BUTTON btnCliSpe  NO-FOCUS FLAT-BUTTON
     LABEL "Gi" 
     SIZE-PIXELS 40 BY 40 TOOLTIP "Application GI (Client) / Clic droit pour paramètrer".

DEFINE BUTTON btnCliSuiv  NO-FOCUS FLAT-BUTTON
     LABEL "Gi" 
     SIZE-PIXELS 40 BY 40 TOOLTIP "Application GI (Client) / Clic droit pour paramètrer".

DEFINE BUTTON btnEmprunt  NO-FOCUS FLAT-BUTTON
     LABEL "E" 
     SIZE-PIXELS 40 BY 40 TOOLTIP "Gestion des emprunts".

DEFINE BUTTON btnGI  NO-FOCUS FLAT-BUTTON
     LABEL "Gi" 
     SIZE-PIXELS 40 BY 40 TOOLTIP "Application GI (Développement)".

DEFINE BUTTON btnImprimer  NO-FOCUS FLAT-BUTTON
     LABEL "Imp" 
     SIZE-PIXELS 40 BY 40 TOOLTIP "Imprimer".

DEFINE BUTTON btnInternet  NO-FOCUS FLAT-BUTTON
     LABEL "I" 
     SIZE-PIXELS 40 BY 40 TOOLTIP "Navigateur Internet / Clic droit pour paramètrer".

DEFINE BUTTON btnModifier  NO-FOCUS FLAT-BUTTON
     LABEL "..." 
     SIZE-PIXELS 40 BY 40 TOOLTIP "Modifier".

DEFINE BUTTON btnPerso-1  NO-FOCUS FLAT-BUTTON
     LABEL "BP" 
     SIZE-PIXELS 40 BY 40 TOOLTIP "Bouton perso. / Clic droit pour paramètrer".

DEFINE BUTTON btnPerso-2  NO-FOCUS FLAT-BUTTON
     LABEL "BP" 
     SIZE-PIXELS 40 BY 40 TOOLTIP "Bouton perso. / Clic droit pour paramètrer".

DEFINE BUTTON btnPerso-3  NO-FOCUS FLAT-BUTTON
     LABEL "BP" 
     SIZE-PIXELS 40 BY 40 TOOLTIP "Bouton perso. / Clic droit pour paramètrer".

DEFINE BUTTON btnPerso-4  NO-FOCUS FLAT-BUTTON
     LABEL "BP" 
     SIZE-PIXELS 40 BY 40 TOOLTIP "Bouton perso. / Clic droit pour paramètrer".

DEFINE BUTTON btnPerso-5  NO-FOCUS FLAT-BUTTON
     LABEL "BP" 
     SIZE-PIXELS 40 BY 40 TOOLTIP "Bouton perso. / Clic droit pour paramètrer".

DEFINE BUTTON btnPerso-6  NO-FOCUS FLAT-BUTTON
     LABEL "BP" 
     SIZE-PIXELS 40 BY 40 TOOLTIP "Bouton perso. / Clic droit pour paramètrer".

DEFINE BUTTON btnPutty  NO-FOCUS FLAT-BUTTON
     LABEL "P" 
     SIZE-PIXELS 40 BY 40 TOOLTIP "Putty / Clic droit pour paramètrer".

DEFINE BUTTON btnQuitter  NO-FOCUS FLAT-BUTTON
     LABEL "qui" 
     SIZE-PIXELS 40 BY 40 TOOLTIP "Quitter/Redémarrer l'application".

DEFINE BUTTON btnRaf  NO-FOCUS FLAT-BUTTON
     LABEL "-" 
     SIZE-PIXELS 40 BY 40 TOOLTIP "Supprimer".

DEFINE BUTTON btnServeurs  NO-FOCUS FLAT-BUTTON
     LABEL "S" 
     SIZE-PIXELS 40 BY 40 TOOLTIP "Gestion des serveurs GI (Développement)".

DEFINE BUTTON btnServeurs-2  NO-FOCUS FLAT-BUTTON
     LABEL "S" 
     SIZE-PIXELS 40 BY 40 TOOLTIP "Gestion des serveurs GI (Client) / Clic droit pour paramètrer".

DEFINE BUTTON btnSupprimer  NO-FOCUS FLAT-BUTTON
     LABEL "-" 
     SIZE-PIXELS 40 BY 40 TOOLTIP "Supprimer".

DEFINE BUTTON btnTeamviewer  NO-FOCUS FLAT-BUTTON
     LABEL "T" 
     SIZE-PIXELS 40 BY 40 TOOLTIP "Team Viewer / Clic droit pour paramètrer".

DEFINE BUTTON btnValidation  NO-FOCUS FLAT-BUTTON
     LABEL "-" 
     SIZE-PIXELS 40 BY 40 TOOLTIP "Validation".

DEFINE VARIABLE filBoutonDev AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 9.4 BY .71 TOOLTIP "Saisissez ici la version concernée par le bouton GI PREC"
     FONT 12 NO-UNDO.

DEFINE VARIABLE filBoutongi AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 10 BY .71 TOOLTIP "Saisissez ici la version concernée par le bouton GI CLI"
     FONT 12 NO-UNDO.

DEFINE VARIABLE filBoutonPrec AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 10.4 BY .71 TOOLTIP "Saisissez ici la version concernée par le bouton GI PREC"
     FONT 12 NO-UNDO.

DEFINE VARIABLE filBoutonSpe AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 10 BY .71 TOOLTIP "Saisissez ici la version concernée par le bouton GI SPE"
     FONT 12 NO-UNDO.

DEFINE VARIABLE filBoutonSuiv AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 10 BY .71 TOOLTIP "Saisissez ici la version concernée par le bouton GI SUIV"
     FONT 12 NO-UNDO.

DEFINE RECTANGLE rctBoutons
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 51 BY 2.24
     BGCOLOR 8 .

DEFINE RECTANGLE rctBoutons-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 55 BY 2.24
     BGCOLOR 8 .

DEFINE RECTANGLE rctBoutons-4
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 42 BY 2.24
     BGCOLOR 8 .

DEFINE RECTANGLE rctBoutons-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 55.6 BY 2.24
     BGCOLOR 8 .

DEFINE RECTANGLE rctRaff
     EDGE-PIXELS 1 GRAPHIC-EDGE    
     SIZE 36 BY .19
     BGCOLOR 8 FGCOLOR 8 .

DEFINE RECTANGLE rctRaff-2
     EDGE-PIXELS 1 GRAPHIC-EDGE  NO-FILL   
     SIZE 36.4 BY .29
     BGCOLOR 8 FGCOLOR 7 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brwinfos FOR 
      ttordres SCROLLING.

DEFINE QUERY brwModules FOR 
      ttModulesUtilisateur SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brwinfos
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brwinfos winaide _FREEFORM
  QUERY brwinfos NO-LOCK DISPLAY
      ttOrdres.cMessageDistribue FORMAT "x(255)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-LABELS NO-ROW-MARKERS NO-TAB-STOP SIZE 166 BY 4.76
         FONT 4 ROW-HEIGHT-CHARS .6 FIT-LAST-COLUMN.

DEFINE BROWSE brwModules
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brwModules winaide _FREEFORM
  QUERY brwModules DISPLAY
      ttModulesUtilisateur.cLibelle FORMAT "x(32)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-LABELS NO-ROW-MARKERS DROP-TARGET SIZE 36 BY 25.24
         FGCOLOR 0 FONT 11 ROW-HEIGHT-CHARS .7 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME frmFond
     btnQuitter AT Y 7 X 8
     filBoutonDev AT ROW 2.81 COL 52 COLON-ALIGNED NO-LABEL WIDGET-ID 28
     filBoutonPrec AT ROW 2.81 COL 62 COLON-ALIGNED NO-LABEL WIDGET-ID 18
     filBoutongi AT ROW 2.81 COL 73.4 COLON-ALIGNED NO-LABEL WIDGET-ID 20
     filBoutonSuiv AT ROW 2.81 COL 84.4 COLON-ALIGNED NO-LABEL WIDGET-ID 22
     filBoutonSpe AT ROW 2.81 COL 95 COLON-ALIGNED NO-LABEL WIDGET-ID 26
     brwModules AT ROW 3.86 COL 2 WIDGET-ID 100
     brwinfos AT ROW 24.33 COL 39 WIDGET-ID 200
     btnPerso-1 AT Y 5 X 750
     btnPerso-2 AT Y 5 X 795 WIDGET-ID 14
     btnPerso-3 AT Y 5 X 840 WIDGET-ID 30
     btnPerso-4 AT Y 5 X 885 WIDGET-ID 32
     btnPerso-5 AT Y 5 X 930 WIDGET-ID 34
     btnPerso-6 AT Y 5 X 975 WIDGET-ID 36
     btnCli AT Y 5 X 377
     btnCliPrec AT Y 5 X 322 WIDGET-ID 12
     btnCliSpe AT Y 5 X 485 WIDGET-ID 24
     btnCliSuiv AT Y 5 X 432 WIDGET-ID 16
     btnAssistance AT Y 5 X 620
     btnInternet AT Y 5 X 580
     btnGI AT Y 4 X 268
     btnServeurs AT Y 70 X 290
     btnServeurs-2 AT Y 70 X 335
     btnModifier AT Y 7 X 90
     btnEmprunt AT Y 5 X 540
     btnPutty AT Y 5 X 660
     btnTeamviewer AT Y 5 X 700
     btnAbandon AT Y 7 X 110
     btnAjouter AT Y 7 X 50
     btnImprimer AT Y 7 X 175
     btnRaf AT Y 7 X 215
     btnSupprimer AT Y 7 X 130
     btnValidation AT Y 7 X 70
     rctBoutons AT ROW 1.14 COL 2
     rctBoutons-3 AT ROW 1.14 COL 53
     rctBoutons-5 AT ROW 1.14 COL 150
     rctBoutons-4 AT ROW 1.14 COL 108
     rctRaff AT ROW 3.48 COL 2
     rctRaff-2 AT ROW 3.43 COL 1.8
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 204.6 BY 28.24
         FGCOLOR 0 .


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
  CREATE WINDOW winaide ASSIGN
         HIDDEN             = YES
         TITLE              = "GI"
         HEIGHT-P           = 596
         WIDTH-P            = 1024
         MAX-HEIGHT-P       = 976
         MAX-WIDTH-P        = 1920
         VIRTUAL-HEIGHT-P   = 976
         VIRTUAL-WIDTH-P    = 1920
         MAX-BUTTON         = no
         RESIZE             = no
         SCROLL-BARS        = no
         STATUS-AREA        = no
         BGCOLOR            = 16
         FGCOLOR            = ?
         KEEP-FRAME-Z-ORDER = yes
         THREE-D            = yes
         MESSAGE-AREA       = no
         SENSITIVE          = yes.
ELSE {&WINDOW-NAME} = CURRENT-WINDOW.

ASSIGN {&WINDOW-NAME}:MENUBAR    = MENU MENU-BAR-WinAide:HANDLE.
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR FRAME frmFond
   FRAME-NAME                                                           */
/* BROWSE-TAB brwModules filBoutonSpe frmFond */
/* BROWSE-TAB brwinfos brwModules frmFond */
ASSIGN 
       brwinfos:POPUP-MENU IN FRAME frmFond             = MENU POPUP-MENU-brwinfos:HANDLE.

ASSIGN 
       brwModules:POPUP-MENU IN FRAME frmFond             = MENU POPUP-MENU-brwModules:HANDLE.

ASSIGN 
       btnAbandon:HIDDEN IN FRAME frmFond           = TRUE.

ASSIGN 
       btnAssistance:POPUP-MENU IN FRAME frmFond       = MENU POPUP-MENU-btnAssistance:HANDLE.

ASSIGN 
       btnCli:POPUP-MENU IN FRAME frmFond       = MENU POPUP-MENU-btnCli:HANDLE.

ASSIGN 
       btnCliPrec:POPUP-MENU IN FRAME frmFond       = MENU POPUP-MENU-btnCliPrec:HANDLE.

ASSIGN 
       btnCliSpe:POPUP-MENU IN FRAME frmFond       = MENU POPUP-MENU-btnCliSpe:HANDLE.

ASSIGN 
       btnCliSuiv:POPUP-MENU IN FRAME frmFond       = MENU POPUP-MENU-btnCliSuiv:HANDLE.

ASSIGN 
       btnGI:POPUP-MENU IN FRAME frmFond       = MENU POPUP-MENU-btnGI:HANDLE.

ASSIGN 
       btnInternet:POPUP-MENU IN FRAME frmFond       = MENU POPUP-MENU-btnInternet:HANDLE.

ASSIGN 
       btnModifier:PRIVATE-DATA IN FRAME frmFond     = 
                "BOUTON-MODIFIER".

ASSIGN 
       btnPerso-1:POPUP-MENU IN FRAME frmFond       = MENU POPUP-MENU-btnPerso-1:HANDLE.

ASSIGN 
       btnPerso-2:POPUP-MENU IN FRAME frmFond       = MENU POPUP-MENU-btnPerso-2:HANDLE.

ASSIGN 
       btnPerso-3:POPUP-MENU IN FRAME frmFond       = MENU POPUP-MENU-btnPerso-3:HANDLE.

ASSIGN 
       btnPerso-4:POPUP-MENU IN FRAME frmFond       = MENU POPUP-MENU-btnPerso-4:HANDLE.

ASSIGN 
       btnPerso-5:POPUP-MENU IN FRAME frmFond       = MENU POPUP-MENU-btnPerso-5:HANDLE.

ASSIGN 
       btnPerso-6:POPUP-MENU IN FRAME frmFond       = MENU POPUP-MENU-btnPerso-6:HANDLE.

ASSIGN 
       btnQuitter:POPUP-MENU IN FRAME frmFond       = MENU POPUP-MENU-btnQuitter:HANDLE.

/* SETTINGS FOR BUTTON btnServeurs IN FRAME frmFond
   NO-ENABLE                                                            */
ASSIGN 
       btnServeurs:HIDDEN IN FRAME frmFond           = TRUE.

/* SETTINGS FOR BUTTON btnServeurs-2 IN FRAME frmFond
   NO-ENABLE                                                            */
ASSIGN 
       btnServeurs-2:HIDDEN IN FRAME frmFond           = TRUE.

ASSIGN 
       btnValidation:HIDDEN IN FRAME frmFond           = TRUE.

IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(winaide)
THEN winaide:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brwinfos
/* Query rebuild information for BROWSE brwinfos
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH ttordres
    BY ttordres.ddate BY ttordres.iOrdre
    INDEXED-REPOSITION
                                  .
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Where[1]         = "Ordres.lDistribue
 AND Ordres.cMessageDistribue <> """""""""""""
     _Query            is OPENED
*/  /* BROWSE brwinfos */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brwModules
/* Query rebuild information for BROWSE brwModules
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH ttModulesUtilisateur WHERE ttModulesUtilisateur.lInvisible = FALSE BY ttModulesUtilisateur.iOrdre /*clibelle*/.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE brwModules */
&ANALYZE-RESUME

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

CREATE CONTROL-FRAME Chrono ASSIGN
       FRAME           = FRAME frmFond:HANDLE
       ROW             = 8.62
       COLUMN          = 95
       HEIGHT          = 1.91
       WIDTH           = 8
       HIDDEN          = yes
       SENSITIVE       = yes.
/* Chrono OCXINFO:CREATE-CONTROL from: {F0B88A90-F5DA-11CF-B545-0020AF6ED35A} type: PSTimer */
      Chrono:MOVE-AFTER(brwModules:HANDLE IN FRAME frmFond).

&ENDIF

&ANALYZE-RESUME /* End of _CREATE-DYNAMIC */


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME winaide
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL winaide winaide
ON END-ERROR OF winaide /* GI */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  /*IF THIS-PROCEDURE:PERSISTENT THEN*/ RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL winaide winaide
ON PARENT-WINDOW-CLOSE OF winaide /* GI */
DO:
  MESSAGE "Parent close" VIEW-AS ALERT-BOX.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL winaide winaide
ON WINDOW-CLOSE OF winaide /* GI */
DO:
  /* This event will close the window and terminate the procedure.  */
  /*
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
  */
  APPLY "CHOOSE" TO btnQuitter IN FRAME frmfond.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brwinfos
&Scoped-define SELF-NAME brwinfos
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwinfos winaide
ON DEFAULT-ACTION OF brwinfos IN FRAME frmFond
DO:
  
    APPLY "CHOOSE" to menu-item m_Répondre_à_lutilisateur_du_ IN MENU POPUP-MENU-brwinfos.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwinfos winaide
ON ROW-DISPLAY OF brwinfos IN FRAME frmFond
DO:
  DEFINE VARIABLE iCouleur AS INTEGER NO-UNDO.

  iCouleur = 0.
  IF ttordres.lprioritaire THEN icouleur = 3.
  IF ttordres.lErreur THEN icouleur = 12.
  IF (ttordres.lCollegue AND NOT ttOrdres.lLu) THEN iCouleur = 2.

  IF iCouleur <> 0 AND ttordres.cmessagedistribue <> ">" THEN DO:
    ttordres.cMessageDistribue:BGCOLOR IN BROWSE brwinfos = iCouleur.
    ttordres.cMessageDistribue:FGCOLOR IN BROWSE brwinfos = 15.
    ttordres.cMessageDistribue:FONT IN BROWSE brwinfos = 6.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwinfos winaide
ON VALUE-CHANGED OF brwinfos IN FRAME frmFond
DO:
  brwinfos:TOOLTIP = ttOrdres.cMessageDistribue.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brwModules
&Scoped-define SELF-NAME brwModules
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwModules winaide
ON CTRL-CURSOR-UP OF brwModules IN FRAME frmFond
DO:

    RUN DeplaceModule("HAUT").

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwModules winaide
ON MOUSE-SELECT-CLICK OF brwModules IN FRAME frmFond
DO:
  APPLY "VALUE-CHANGED" TO brwModules.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwModules winaide
ON ROW-DISPLAY OF brwModules IN FRAME frmFond
DO:
    ttmodulesutilisateur.clibelle:FGCOLOR IN BROWSE brwmodules = ttmodulesutilisateur.icouleur.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwModules winaide
ON VALUE-CHANGED OF brwModules IN FRAME frmFond
DO:
    IF not(lManuel) THEN DO:
        RUN AffichageFrames(ttModulesUtilisateur.cIdent).
        
        gcModuleEnCours = ttModulesUtilisateur.cIdent.
        /*MESSAGE gcModuleEnCours VIEW-AS ALERT-BOX.*/
    END.
    lManuel = FALSE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnAbandon
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnAbandon winaide
ON CHOOSE OF btnAbandon IN FRAME frmFond /* - */
DO:
    RUN GereEtat("VIS").
    RUN DonneOrdre(gcModuleEnCours,"ABANDON",OUTPUT lRetour).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnAjouter
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnAjouter winaide
ON CHOOSE OF btnAjouter IN FRAME frmFond /* + */
DO:  
    IF not(SELF:PRIVATE-DATA = "DIRECT") THEN RUN GereEtat("VAL").
    RUN DonneOrdre(gcModuleEnCours,"AJOUTER",OUTPUT lRetour).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnAssistance
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnAssistance winaide
ON CHOOSE OF btnAssistance IN FRAME frmFond /* A */
DO:
    DEFINE VARIABLE cCommande AS CHARACTER NO-UNDO.

    cCommande = gDonnePreference("NAVIGATEUR-2").
    IF cCommande = "" THEN RETURN.
    IF cCommande MATCHES "*.bat*" THEN
        OS-COMMAND NO-WAIT VALUE(gcRepertoireRessourcesPrivees + "\scripts\general\execute2.bat " + cCommande).
    ELSE
        OS-COMMAND NO-WAIT VALUE(cCommande).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnAssistance winaide
ON RIGHT-MOUSE-CLICK OF btnAssistance IN FRAME frmFond /* A */
DO:
  
    RUN DonnePositionMessage IN ghGeneral.
    gcAllerRetour = STRING(giPosXMessage)
        + "|" + STRING(giPosYMessage)
        + "|" + "Assistance GI"
        + "|" + gDonnePreference("ASSISTANCE").
    RUN VALUE(gcRepertoireExecution + "saisie2.w") (INPUT-OUTPUT gcAllerRetour).
    IF gcAllerRetour = "" THEN RETURN.
    gSauvePreference("ASSISTANCE",ENTRY(4,gcAllerRetour,"|")).
     RUN GereTooltipPerso.  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnCli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnCli winaide
ON CHOOSE OF btnCli IN FRAME frmFond /* Gi */
DO:
  DEFINE VARIABLE cParametre AS CHARACTER NO-UNDO.
  DEFINE VARIABLE lContinuer AS LOGICAL NO-UNDO INIT TRUE.

  IF gDonnePreference("BATCH-CLIENT") = "" THEN RETURN.

  /* Récupération d'un éventuel parametre */
  IF gDonnePreference("PREF-MAGICSCLI") = "OUI" THEN
      cParametre = gDonnePreference("PREF-MAGIRESEAUCLI").

  /* Maj des versions */
  IF not(gDonnePreference("AIDE-BOUTON-MANUELLE") = "OUI") THEN DO:
    RUN GereBoutons.
    RUN MessageStructure("CLI",OUTPUT lContinuer).
    IF NOT(lContinuer) THEN RETURN.
  END.

  OS-COMMAND NO-WAIT VALUE("cmd /c """ + gDonnePreference("BATCH-CLIENT") + """ " + cParametre).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnCliPrec
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnCliPrec winaide
ON CHOOSE OF btnCliPrec IN FRAME frmFond /* Gi */
DO:
     DEFINE VARIABLE cParametre AS CHARACTER NO-UNDO.
     DEFINE VARIABLE lContinuer AS LOGICAL NO-UNDO.

    IF gDonnePreference("BATCH-CLIENT-PREC") = "" THEN RETURN.

    /* Récupération d'un éventuel parametre */
    IF gDonnePreference("PREF-MAGICSPREC") = "OUI" THEN
      cParametre = gDonnePreference("PREF-MAGIRESEAUPREC").

    /* Maj des versions */
    IF not(gDonnePreference("AIDE-BOUTON-MANUELLE") = "OUI") THEN DO:
      RUN GereBoutons.
      RUN MessageStructure("PREC",OUTPUT lContinuer).
      IF NOT(lContinuer) THEN RETURN.
    END.


  OS-COMMAND NO-WAIT VALUE("cmd /c """ + gDonnePreference("BATCH-CLIENT-PREC") + """ " + cParametre).
  /*MESSAGE gDonnePreference("BATCH-CLIENT-PREC") VIEW-AS ALERT-BOX.*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnCliSpe
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnCliSpe winaide
ON CHOOSE OF btnCliSpe IN FRAME frmFond /* Gi */
DO:
  DEFINE VARIABLE lContinuer AS LOGICAL NO-UNDO.
    DEFINE VARIABLE cParametre AS CHARACTER NO-UNDO.
    IF gDonnePreference("BATCH-CLIENT-SPE") = "" THEN RETURN.

    /* Récupération d'un éventuel parametre */
    IF gDonnePreference("PREF-MAGICSSPE") = "OUI" THEN
      cParametre = gDonnePreference("PREF-MAGIRESEAUSPE").

 /* Maj des versions */
  IF not(gDonnePreference("AIDE-BOUTON-MANUELLE") = "OUI") THEN DO:
    RUN GereBoutons.
    RUN MessageStructure("SPE",OUTPUT lContinuer).
    IF NOT(lContinuer) THEN RETURN.
  END.
  
  OS-COMMAND NO-WAIT VALUE("cmd /c """ + gDonnePreference("BATCH-CLIENT-SPE") + """ " + cParametre).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnCliSuiv
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnCliSuiv winaide
ON CHOOSE OF btnCliSuiv IN FRAME frmFond /* Gi */
DO:
    DEFINE VARIABLE cParametre AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lContinuer AS LOGICAL NO-UNDO.

    IF gDonnePreference("BATCH-CLIENT-SUIV") = "" THEN RETURN.

    /* Récupération d'un éventuel parametre */
    IF gDonnePreference("PREF-MAGICSSUIV") = "OUI" THEN
      cParametre = gDonnePreference("PREF-MAGIRESEAUSUIV").

     /* Maj des versions */
  IF not(gDonnePreference("AIDE-BOUTON-MANUELLE") = "OUI") THEN DO:
    RUN GereBoutons.
    RUN MessageStructure("SUIV",OUTPUT lContinuer).
    IF NOT(lContinuer) THEN RETURN.
  END.

  OS-COMMAND NO-WAIT VALUE("cmd /c """ + gDonnePreference("BATCH-CLIENT-SUIV") + """ " + cParametre).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnEmprunt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnEmprunt winaide
ON CHOOSE OF btnEmprunt IN FRAME frmFond /* E */
DO:
    /*mdebug("gcRepertoireRessourcesPrivees = " + gcRepertoireRessourcesPrivees).*/
    OS-COMMAND SILENT VALUE(gcRepertoireRessourcesPrivees + "\scripts\general\emprunt.bat").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnGI
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnGI winaide
ON CHOOSE OF btnGI IN FRAME frmFond /* Gi */
DO:

/* ---
    DEFINE VARIABLE Loc_Appli_Dev AS CHARACTER NO-UNDO.
    
    cTypeApplication = gDonnePreference("TYPE-APPLICATION").
    IF cTypeApplication = "" THEN cTypeApplication = "ADB".
    Loc_Appli_dev = REPLACE(Loc_Appli,"\gi\","\gidev\").
    gMLog("Lancement de la commande : " + Loc_Appli_dev + "\exe\gi.exe " + Loc_Appli_dev + "\ress\init\gidevnt.ini " + Loc_Appli_dev + "\ress\init\gidev.pf " + cTypeApplication).
    OS-COMMAND NO-WAIT VALUE(Loc_Appli_dev + "\exe\gi.exe " + Loc_Appli_dev + "\ress\init\gidevnt.ini " + Loc_Appli_dev + "\ress\init\gidev.pf " + cTypeApplication).
--- */

    DEFINE VARIABLE cParametre AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lContinuer AS LOGICAL NO-UNDO INIT TRUE.
    DEFINE VARIABLE cCommande AS CHARACTER NO-UNDO.

    IF gDonnePreference("BATCH-DEV") = "" THEN do:
        RETURN.
    END.

    /* Récupération d'un éventuel parametre */
    IF gDonnePreference("PREF-MAGICSDEV") = "OUI" THEN DO:
        cParametre = "h:\".
    END.

    /* Maj des versions */
    RUN GereBoutons.

    cCommande = "cmd /C """ + gDonnePreference("BATCH-DEV") + """ " + cParametre.
    /*MESSAGE "cCommande = " cCommande.*/
    OS-COMMAND SILENT VALUE(cCommande).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnGI winaide
ON RIGHT-MOUSE-CLICK OF btnGI IN FRAME frmFond /* Gi */
DO:
    RUN DonnePositionMessage IN ghGeneral.
    gcAllerRetour = STRING(giPosXMessage)
        + "|" + STRING(giPosYMessage)
        + "|" + "Type d'application (ADB/PME)"
        + "|" + gDonnePreference("TYPE-APPLICATION").
    RUN VALUE(gcRepertoireExecution + "saisie2.w") (INPUT-OUTPUT gcAllerRetour).
    IF gcAllerRetour = "" THEN RETURN.
    gSauvePreference("TYPE-APPLICATION",ENTRY(4,gcAllerRetour,"|")).

    cTypeApplication = gDonnePreference("TYPE-APPLICATION").
    btnGI:TOOLTIP = "Application GI (Développement) / Clic droit pour paramètrer le type d'application (actuellement : " + cTypeApplication + ")".

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnImprimer
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnImprimer winaide
ON CHOOSE OF btnImprimer IN FRAME frmFond /* Imp */
DO:
    /*RUN DonneOrdre(ENTRY(2,gcModuleEnCours,"|"),"IMPRIME",OUTPUT lRetour).*/
    RUN DonneOrdre(gcModuleEnCours,"IMPRIME",OUTPUT lRetour).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnInternet
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnInternet winaide
ON CHOOSE OF btnInternet IN FRAME frmFond /* I */
DO:
    DEFINE VARIABLE cCommande AS CHARACTER NO-UNDO.

    cCommande = gDonnePreference("NAVIGATEUR-1").
    IF cCommande = "" THEN RETURN.
    IF cCommande MATCHES "*.bat*" THEN
        OS-COMMAND NO-WAIT VALUE(gcRepertoireRessourcesPrivees + "\scripts\general\execute2.bat " + cCommande).
    ELSE
        OS-COMMAND NO-WAIT VALUE(cCommande).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnInternet winaide
ON RIGHT-MOUSE-CLICK OF btnInternet IN FRAME frmFond /* I */
DO:
  
    RUN DonnePositionMessage IN ghGeneral.
    gcAllerRetour = STRING(giPosXMessage)
        + "|" + STRING(giPosYMessage)
        + "|" + "Navigateur Internet"
        + "|" + gDonnePreference("NAVIGATEUR").
    RUN VALUE(gcRepertoireExecution + "saisie2.w") (INPUT-OUTPUT gcAllerRetour).
    IF gcAllerRetour = "" THEN RETURN.
    gSauvePreference("NAVIGATEUR",ENTRY(4,gcAllerRetour,"|")).

    RUN GereTooltipPerso.  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnModifier
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnModifier winaide
ON CHOOSE OF btnModifier IN FRAME frmFond /* ... */
DO:
    RUN GereEtat("VAL").
    RUN DonneOrdre(gcModuleEnCours,"MODIFIER",OUTPUT lRetour).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnPerso-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnPerso-1 winaide
ON CHOOSE OF btnPerso-1 IN FRAME frmFond /* BP */
DO:
    DEFINE VARIABLE cCommande AS CHARACTER NO-UNDO.

    cCommande = gDonnePreference("BTNPERSO-1").
    IF cCommande = "" THEN RETURN.
    /*OS-COMMAND NO-WAIT VALUE(gcRepertoireRessourcesPrivees + "\scripts\general\execute.bat " + gDonnePreference("BTNPERSO")).*/
    IF cCommande MATCHES "*.bat*" THEN
        OS-COMMAND NO-WAIT VALUE(gcRepertoireRessourcesPrivees + "\scripts\general\execute2.bat " + gDonnePreference("BTNPERSO-1")).
    ELSE
        OS-COMMAND NO-WAIT VALUE(cCommande).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnPerso-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnPerso-2 winaide
ON CHOOSE OF btnPerso-2 IN FRAME frmFond /* BP */
DO:
    DEFINE VARIABLE cCommande AS CHARACTER NO-UNDO.

    cCommande = gDonnePreference("BTNPERSO-2").
    IF cCommande = "" THEN RETURN.
    /*OS-COMMAND NO-WAIT VALUE(gcRepertoireRessourcesPrivees + "\scripts\general\execute.bat " + gDonnePreference("BTNPERSO")).*/
    IF cCommande MATCHES "*.bat*" THEN
        OS-COMMAND NO-WAIT VALUE(gcRepertoireRessourcesPrivees + "\scripts\general\execute2.bat " + gDonnePreference("BTNPERSO-2")).
    ELSE
        OS-COMMAND NO-WAIT VALUE(cCommande).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnPerso-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnPerso-3 winaide
ON CHOOSE OF btnPerso-3 IN FRAME frmFond /* BP */
DO:
    DEFINE VARIABLE cCommande AS CHARACTER NO-UNDO.

    cCommande = gDonnePreference("BTNPERSO-3").
    IF cCommande = "" THEN RETURN.
    /*OS-COMMAND NO-WAIT VALUE(gcRepertoireRessourcesPrivees + "\scripts\general\execute.bat " + gDonnePreference("BTNPERSO")).*/
    IF cCommande MATCHES "*.bat*" THEN
        OS-COMMAND NO-WAIT VALUE(gcRepertoireRessourcesPrivees + "\scripts\general\execute2.bat " + gDonnePreference("BTNPERSO-3")).
    ELSE
        OS-COMMAND NO-WAIT VALUE(cCommande).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnPerso-4
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnPerso-4 winaide
ON CHOOSE OF btnPerso-4 IN FRAME frmFond /* BP */
DO:
    DEFINE VARIABLE cCommande AS CHARACTER NO-UNDO.

    cCommande = gDonnePreference("BTNPERSO-4").
    IF cCommande = "" THEN RETURN.
    /*OS-COMMAND NO-WAIT VALUE(gcRepertoireRessourcesPrivees + "\scripts\general\execute.bat " + gDonnePreference("BTNPERSO")).*/
    IF cCommande MATCHES "*.bat*" THEN
        OS-COMMAND NO-WAIT VALUE(gcRepertoireRessourcesPrivees + "\scripts\general\execute2.bat " + gDonnePreference("BTNPERSO-4")).
    ELSE
        OS-COMMAND NO-WAIT VALUE(cCommande).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnPerso-4 winaide
ON RIGHT-MOUSE-CLICK OF btnPerso-4 IN FRAME frmFond /* BP */
DO:
  
    RUN DonnePositionMessage IN ghGeneral.
    gcAllerRetour = STRING(giPosXMessage)
        + "|" + STRING(giPosYMessage)
        + "|" + "Bouton Perso"
        + "|" + gDonnePreference("BTNPERSO-4").
    RUN VALUE(gcRepertoireExecution + "saisie2.w") (INPUT-OUTPUT gcAllerRetour).
    IF gcAllerRetour = "" THEN RETURN.
    gSauvePreference("BTNPERSO-4",ENTRY(4,gcAllerRetour,"|")).
    
    RUN GereTooltipPerso.    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnPerso-5
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnPerso-5 winaide
ON CHOOSE OF btnPerso-5 IN FRAME frmFond /* BP */
DO:
    DEFINE VARIABLE cCommande AS CHARACTER NO-UNDO.

    cCommande = gDonnePreference("BTNPERSO-5").
    IF cCommande = "" THEN RETURN.
    /*OS-COMMAND NO-WAIT VALUE(gcRepertoireRessourcesPrivees + "\scripts\general\execute.bat " + gDonnePreference("BTNPERSO")).*/
    IF cCommande MATCHES "*.bat*" THEN
        OS-COMMAND NO-WAIT VALUE(gcRepertoireRessourcesPrivees + "\scripts\general\execute2.bat " + gDonnePreference("BTNPERSO-5")).
    ELSE
        OS-COMMAND NO-WAIT VALUE(cCommande).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnPerso-6
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnPerso-6 winaide
ON CHOOSE OF btnPerso-6 IN FRAME frmFond /* BP */
DO:
    DEFINE VARIABLE cCommande AS CHARACTER NO-UNDO.

    cCommande = gDonnePreference("BTNPERSO-6").
    IF cCommande = "" THEN RETURN.
    /*OS-COMMAND NO-WAIT VALUE(gcRepertoireRessourcesPrivees + "\scripts\general\execute.bat " + gDonnePreference("BTNPERSO")).*/
    IF cCommande MATCHES "*.bat*" THEN
        OS-COMMAND NO-WAIT VALUE(gcRepertoireRessourcesPrivees + "\scripts\general\execute2.bat " + gDonnePreference("BTNPERSO-6")).
    ELSE
        OS-COMMAND NO-WAIT VALUE(cCommande).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnPutty
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnPutty winaide
ON CHOOSE OF btnPutty IN FRAME frmFond /* P */
DO:
    IF gDonnePreference("PUTTY") = "" THEN RETURN.
    OS-COMMAND NO-WAIT VALUE(gcRepertoireRessourcesPrivees + "\scripts\general\execute.bat " + gDonnePreference("PUTTY")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnPutty winaide
ON RIGHT-MOUSE-CLICK OF btnPutty IN FRAME frmFond /* P */
DO:
  
    RUN DonnePositionMessage IN ghGeneral.
    gcAllerRetour = STRING(giPosXMessage)
        + "|" + STRING(giPosYMessage)
        + "|" + "Putty"
        + "|" + gDonnePreference("PUTTY").
    RUN VALUE(gcRepertoireExecution + "saisie2.w") (INPUT-OUTPUT gcAllerRetour).
    IF gcAllerRetour = "" THEN RETURN.
    gSauvePreference("PUTTY",ENTRY(4,gcAllerRetour,"|")).
     RUN GereTooltipPerso.  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnQuitter
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnQuitter winaide
ON CHOOSE OF btnQuitter IN FRAME frmFond /* qui */
DO:
    DEFINE VARIABLE lMaj AS LOGICAL INIT FALSE NO-UNDO.
    DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO.

    lMaj = (gGetParam("FORCAGE-MAJ") = "TRUE").

    IF gDonnePreference("PREF-POSITION") = "OUI" THEN DO:
        cTempo1 = STRING(WinAide:X) + "|" + STRING(WinAide:Y).
        gSauvePreference("POSITION",cTempo1).
    END.
    ELSE
        gSauvePreference("POSITION","").
    
    IF NOT(lMaj) THEN DO:
        IF gDonnePreference("PREF-SORTIE") = "OUI" THEN DO:
            RUN gAfficheMessageTemporaire("Confirmation...","Confirmez-vous la sortie de menudev ?",TRUE,10,"OUI","",FALSE,OUTPUT cRetour).
            IF cRetour = "NON" THEN RETURN.
        END.
    
        /* on prévient les différentes sections que l'on ferme */
        RUN OrdreGeneral("FERMETURE",OUTPUT lRetour).
        IF NOT(lRetour) THEN DO:
            /*
            MESSAGE "Une erreur s'est produite lors de la fermeture de l'application." SKIP 
                "Fermeture impossible"
                VIEW-AS ALERT-BOX ERROR
                TITLE "GI : Fermeture de l'application"
                .
            */
            RETURN NO-APPLY.
        END.
    END.
    
    /* Gestion de l'utilisateur */
    RUN gGereUtilisateurs("SORTIE").
    RUN Terminaison.
    APPLY "CLOSE" TO THIS-PROCEDURE.
    QUIT. /*LEAVE.*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnRaf
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnRaf winaide
ON CHOOSE OF btnRaf IN FRAME frmFond /* - */
DO:
    RUN DonneOrdre(gcModuleEnCours,"RECHARGE",OUTPUT lRetour).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnServeurs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnServeurs winaide
ON CHOOSE OF btnServeurs IN FRAME frmFond /* S */
DO:
    IF OS-GETENV("W8") = ? THEN 
        OS-COMMAND NO-WAIT VALUE(Loc_appli + "\exe\giserver.exe").
    ELSE 
        OS-COMMAND NO-WAIT VALUE(Loc_appli + "\exe\giserver-w8.exe").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnServeurs-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnServeurs-2 winaide
ON CHOOSE OF btnServeurs-2 IN FRAME frmFond /* S */
DO:
    IF gDonnePreference("REPERTOIRE-CLIENT-PFGI") = "" THEN RETURN.
    /*MESSAGE Loc_appli + "\exe\giserver.exe " + gDonnePreference("REPERTOIRE-CLIENT-PFGI") VIEW-AS ALERT-BOX.*/
    OS-COMMAND NO-WAIT VALUE(Loc_appli + "\exe\giserver.exe " + gDonnePreference("REPERTOIRE-CLIENT-PFGI")).
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnServeurs-2 winaide
ON RIGHT-MOUSE-CLICK OF btnServeurs-2 IN FRAME frmFond /* S */
DO:
    RUN DonnePositionMessage IN ghGeneral.
    gcAllerRetour = STRING(giPosXMessage)
        + "|" + STRING(giPosYMessage)
        + "|" + "Répertoire pfgi client"
        + "|" + gDonnePreference("REPERTOIRE-CLIENT-PFGI").
    RUN VALUE(gcRepertoireExecution + "saisie2.w") (INPUT-OUTPUT gcAllerRetour).
    IF gcAllerRetour = "" THEN RETURN.
    gSauvePreference("REPERTOIRE-CLIENT-PFGI",ENTRY(4,gcAllerRetour,"|")).
     RUN GereTooltipPerso.  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnSupprimer
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnSupprimer winaide
ON CHOOSE OF btnSupprimer IN FRAME frmFond /* - */
DO:
    /*RUN GereEtat("VAL").*/
    RUN DonneOrdre(gcModuleEnCours,"SUPPRIMER",OUTPUT lRetour).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnTeamviewer
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnTeamviewer winaide
ON CHOOSE OF btnTeamviewer IN FRAME frmFond /* T */
DO:
    IF gDonnePreference("TEAMVIEWER") = "" THEN RETURN.
    OS-COMMAND NO-WAIT VALUE(gcRepertoireRessourcesPrivees + "\scripts\general\execute.bat " + gDonnePreference("TEAMVIEWER")).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnTeamviewer winaide
ON RIGHT-MOUSE-CLICK OF btnTeamviewer IN FRAME frmFond /* T */
DO:
  
    RUN DonnePositionMessage IN ghGeneral.
    gcAllerRetour = STRING(giPosXMessage)
        + "|" + STRING(giPosYMessage)
        + "|" + "Team Viewer"
        + "|" + gDonnePreference("TEAMVIEWER").
    RUN VALUE(gcRepertoireExecution + "saisie2.w") (INPUT-OUTPUT gcAllerRetour).
    IF gcAllerRetour = "" THEN RETURN.
    gSauvePreference("TEAMVIEWER",ENTRY(4,gcAllerRetour,"|")).
     RUN GereTooltipPerso.  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnValidation
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnValidation winaide
ON CHOOSE OF btnValidation IN FRAME frmFond /* - */
DO:
    RUN DonneOrdre(gcModuleEnCours,"VALIDATION",OUTPUT lRetour).
    IF lRetour THEN RUN GereEtat("VIS").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Chrono
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Chrono winaide OCX.Tick
PROCEDURE Chrono.PSTimer.Tick .
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  None required for OCX.
  Notes:       
------------------------------------------------------------------------------*/
  DEFINE VARIABLE cTitre AS CHARACTER NO-UNDO.
  DEFINE VARIABLE iLatenceInternet AS INTEGER NO-UNDO.

  IF gDonnePreference("PREF-DEMON_TICKETS") = "OUI" THEN DO:
    RUN TicketAuto.
  END.
  
  IF gDonnePreference("PREF-SAISIEMASTERGI") = "OUI" THEN DO:
      cTitre = "Login".
      hFenetre = DonneHandleFenetre("ProMainWin",cTitre).
      IF hFenetre <> 0 THEN DO : 
            IF itemporisation3 >= giLatenceMax THEN DO:
                /*OS-COMMAND SILENT VALUE(loc_outils + "\MasterGIToWindow.exe """ + cTitre + """" ).*/
                OS-COMMAND SILENT VALUE(loc_outils + "\SaisieAutomatique.exe """ + cTitre + """ ""mastergi%tab%0145183500%return%""" ).
                itemporisation3 = 0.
            END.
            itemporisation3 = iTemporisation3 + 1.
      END.
  END.
  
  itemporisation = iTemporisation + 1.
  itemporisation2 = iTemporisation2 + 1.
  
  IF gDonnePreference("PREF-SAISIEINTERNET") = "OUI" THEN DO:
      /*hFenetre = DonneHandleFenetre("Chrome_WidgetWin_1","Fireware XTM User Authentication - Google Chrome").*/
      cTitre = "LGI - Authentication Portal - Google Chrome".
      hFenetre = DonneHandleFenetre("Chrome_WidgetWin_1",cTitre).
      IF hFenetre = 0 THEN DO:
          cTitre = "User Authentication - Mozilla Firefox".
          hFenetre = DonneHandleFenetre("MozillaWindowClass",cTitre).
      END.
      IF hFenetre <> 0 THEN DO : 
          IF itemporisation4 >= giLatenceInternet THEN DO:
            /*MESSAGE "Passe = " gDonnePreference("PREF-PASSEINTERNET") VIEW-AS ALERT-BOX.*/
              /*OS-COMMAND SILENT VALUE(loc_outils + "\OuvertureInternet.exe """ + cTitre + """ " + gDonnePreference("PREF-PASSEINTERNET") ).*/
              OS-COMMAND SILENT VALUE(loc_outils + "\SaisieAutomatique.exe """ + cTitre + """ """ + gDonnePreference("PREF-PASSEINTERNETUTIL") + "%tab%" + gDonnePreference("PREF-PASSEINTERNET") + "%enter%%ctrl%t""" ).
            itemporisation4 = 0.
          END.
          itemporisation4 = iTemporisation4 + 1.
      END.
  END.
  
  DO WITH FRAME frmFond:
    rctRaff:WIDTH-PIXELS = itemporisation * 3 * (60 / iSynchro). /* * (60 / iSynchro) pour se synchroniser sur le top minute */ 
    rctRaff:TOOLTIP = "Prochain rafraîchissement dans " + STRING(iSynchro - iTemporisation) + " s".
    rctRaff-2:TOOLTIP = rctRaff:TOOLTIP.
  END.
  
  IF iTemporisation2 >= iSynchro2 THEN DO:
      iSynchro2 = 5. /* pour tous les autres ticks sauf le premier qui doit se synchroniser avec l'heure pile */
      itemporisation2 = 0.
      RUN Informations.
      RUN TopChronoPartiel. /* Lancement du partiel + information */
  END.
  ELSE 
      RUN TopChronoPartiel. /* si pas synchro2 on ne fait que lancer le partiel pour ne pas lancer 2 fois le partiel la même seconde */
  
  IF iTemporisation >= iSynchro THEN DO:
      iSynchro = 60. /* pour tous les autres ticks sauf le premier qui doit se synchroniser avec l'heure pile */
      itemporisation = 0.
      itemporisation3 = giLatenceMax.
      itemporisation4 = giLatenceInternet.
      RUN TopChronoGeneral.
  END.


  END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filBoutonDev
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filBoutonDev winaide
ON LEAVE OF filBoutonDev IN FRAME frmFond
DO:
    gSauvePreference("AIDE-BOUTON-DEV",SELF:SCREEN-VALUE).
    RUN GereTooltipPerso.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filBoutongi
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filBoutongi winaide
ON LEAVE OF filBoutongi IN FRAME frmFond
DO:
    gSauvePreference("AIDE-BOUTON-CLI",SELF:SCREEN-VALUE).
    RUN GereTooltipPerso.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filBoutonPrec
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filBoutonPrec winaide
ON LEAVE OF filBoutonPrec IN FRAME frmFond
DO:
    gSauvePreference("AIDE-BOUTON-PREC",SELF:SCREEN-VALUE).
    RUN GereTooltipPerso.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filBoutonSpe
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filBoutonSpe winaide
ON LEAVE OF filBoutonSpe IN FRAME frmFond
DO:
  
    gSauvePreference("AIDE-BOUTON-SPE",SELF:SCREEN-VALUE).
    RUN GereTooltipPerso.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filBoutonSuiv
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filBoutonSuiv winaide
ON LEAVE OF filBoutonSuiv IN FRAME frmFond
DO:
  
    gSauvePreference("AIDE-BOUTON-SUIV",SELF:SCREEN-VALUE).
    RUN GereTooltipPerso.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Admin
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Admin winaide
ON CHOOSE OF MENU-ITEM m_Admin /* Administration */
DO:
  
    /* gestion de l'écran des préférences */
    /* En fait, le module Préférences est non visible. on simule le fait de le choisir */
    
    RUN AffichageFrames("admin").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Brouillon
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Brouillon winaide
ON CHOOSE OF MENU-ITEM m_Brouillon /* Brouillon */
DO:
  RUN LanceBrouillon.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Changer_la_couleur_du_modul
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Changer_la_couleur_du_modul winaide
ON CHOOSE OF MENU-ITEM m_Changer_la_couleur_du_modul /* Changer la couleur du module */
DO:
    DEFINE VARIABLE iCouleur AS INTEGER NO-UNDO INIT 12.
    DEFINE VARIABLE lCouleurChangee AS LOGICAL NO-UNDO INIT FALSE.
    DEFINE VARIABLE hModule AS HANDLE NO-UNDO.
    DEFINE VARIABLE cTempoOrdre AS CHARACTER NO-UNDO INIT "".
    
    /* Sauvegarde du module en cours pour se repositionner dessus à la fin */
    cTempoOrdre = ttModulesUtilisateur.cIdent.    

    IF NOT(AVAILABLE(ttModulesUtilisateur)) THEN RETURN.

    gcAllerRetour = STRING(WinAide:X + (WinAide:WIDTH / 2))
        + "|" + STRING(WinAide:Y + (WinAide:HEIGHT / 2))
        + "|" + ""
        + "|" + string(ttModulesUtilisateur.iCouleur).
    RUN VALUE(gcRepertoireExecution + "couleurs.w") (INPUT-OUTPUT gcAllerRetour).
    IF gcAllerRetour = "" THEN RETURN.
    ttModulesUtilisateur.icouleur = INTEGER(ENTRY(4,gcAllerRetour,"|")).
    gSauvePreference("PREF-COULEUR-MODULE-" + ttModulesUtilisateur.cIdent,STRING(ttModulesUtilisateur.icouleur)).



   /* Raffraichissement de la liste des modules */
   {&OPEN-QUERY-brwModules}

   DO WITH FRAME frmFond:
     /* Positionnement sur le module en cours d'utilisation */
     FIND FIRST ttModulesUtilisateur
         WHERE ttModulesUtilisateur.cident = cTempoOrdre
         NO-ERROR.
     IF AVAILABLE(ttModulesUtilisateur) THEN DO:
         REPOSITION brwModules TO ROWID ROWID(ttModulesUtilisateur).
         APPLY "VALUE-CHANGED" TO brwModules.  
     END.  
   END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Créer_les_répertoires_de_tr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Créer_les_répertoires_de_tr winaide
ON CHOOSE OF MENU-ITEM m_Créer_les_répertoires_de_tr /* Créer les répertoires de travail et copier les macros Word et Excel */
DO:
  
    RUN RepertoiresTravail("CLI").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Créer_les_répertoires_PREC
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Créer_les_répertoires_PREC winaide
ON CHOOSE OF MENU-ITEM m_Créer_les_répertoires_PREC /* Créer les répertoires de travail et copier les macros Word et Excel */
DO:
  
    RUN RepertoiresTravail("PREC").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Créer_les_répertoires_SPE
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Créer_les_répertoires_SPE winaide
ON CHOOSE OF MENU-ITEM m_Créer_les_répertoires_SPE /* Créer les répertoires de travail et copier les macros Word et Excel */
DO:
  RUN RepertoiresTravail("SPE").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Créer_les_répertoires_SUIV
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Créer_les_répertoires_SUIV winaide
ON CHOOSE OF MENU-ITEM m_Créer_les_répertoires_SUIV /* Créer les répertoires de travail et copier les macros Word et Excel */
DO:
  
    RUN RepertoiresTravail("SUIV").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Déplacer_bas
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Déplacer_bas winaide
ON CHOOSE OF MENU-ITEM m_Déplacer_bas /* Déplacer le module vers le bas */
DO:
  
    RUN DeplaceModule("bas").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Déplacer_haut
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Déplacer_haut winaide
ON CHOOSE OF MENU-ITEM m_Déplacer_haut /* Déplacer le module vers le haut */
DO:
  
    RUN DeplaceModule("HAUT").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Envoyer_le_message_en_cours
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Envoyer_le_message_en_cours winaide
ON CHOOSE OF MENU-ITEM m_Envoyer_le_message_en_cours /* Envoyer le message en cours dans le presse-papier */
DO:
  
    RUN GereInformations("PPAPIER-ORDRE-ENCOURS").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Envoyer_tous_les_message_da
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Envoyer_tous_les_message_da winaide
ON CHOOSE OF MENU-ITEM m_Envoyer_tous_les_message_da /* Envoyer tous les messages dans le presse-papier */
DO:
  
    RUN GereInformations("PPAPIER-ORDRE-TOUS").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Explorateur_CLI
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Explorateur_CLI winaide
ON CHOOSE OF MENU-ITEM m_Explorateur_CLI /* Explorateur sur le répertoire */
DO:
    RUN ExplorerVersion("CLI").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Explorateur_gidev
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Explorateur_gidev winaide
ON CHOOSE OF MENU-ITEM m_Explorateur_gidev /* Explorateur sur le répertoire */
DO:
    RUN ExplorerVersion("DEV").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Explorateur_PREC
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Explorateur_PREC winaide
ON CHOOSE OF MENU-ITEM m_Explorateur_PREC /* Explorateur sur le répertoire */
DO:
    RUN ExplorerVersion("PREC").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Explorateur_Spe
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Explorateur_Spe winaide
ON CHOOSE OF MENU-ITEM m_Explorateur_Spe /* Explorateur sur le répertoire */
DO:
    RUN ExplorerVersion("SPE").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Explorateur_SUIV
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Explorateur_SUIV winaide
ON CHOOSE OF MENU-ITEM m_Explorateur_SUIV /* Explorateur sur le répertoire */
DO:
    RUN ExplorerVersion("SUIV").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Informations_de_Debug
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Informations_de_Debug winaide
ON CHOOSE OF MENU-ITEM m_Informations_de_Debug /* Informations de Debug */
DO:
    DEFINE VARIABLE cTemporaire AS CHARACTER NO-UNDO.

    cTemporaire = ""
        + chr(10) + "Position menudev2 : " + string(winaide:X) + " / " + string(winaide:Y)
        .

    mdebug(cTemporaire).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Marquer_le_message_comme_LU
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Marquer_le_message_comme_LU winaide
ON CHOOSE OF MENU-ITEM m_Marquer_le_message_comme_LU /* Marquer le message comme 'LU' */
DO:
  
    RUN GereInformations("LU-ORDRE-ENCOURS").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Modifier_limage
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Modifier_limage winaide
ON CHOOSE OF MENU-ITEM m_Modifier_limage /* Modifier l'image */
DO:
  
    RUN GestionImagePerso(btnPerso-1:HANDLE IN FRAME frmFond,"1",FALSE).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Modifier_limage2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Modifier_limage2 winaide
ON CHOOSE OF MENU-ITEM m_Modifier_limage2 /* Modifier l'image */
DO:
  
    RUN GestionImagePerso(btnPerso-2:handle IN FRAME frmFond,"2",FALSE).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Modifier_limage3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Modifier_limage3 winaide
ON CHOOSE OF MENU-ITEM m_Modifier_limage3 /* Modifier l'image */
DO:
  
    RUN GestionImagePerso(btnPerso-3:handle IN FRAME frmFond,"3",FALSE).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Modifier_limage4
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Modifier_limage4 winaide
ON CHOOSE OF MENU-ITEM m_Modifier_limage4 /* Modifier l'image */
DO:
  
    RUN GestionImagePerso(btnPerso-4:handle IN FRAME frmFond,"4",FALSE).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Modifier_limage5
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Modifier_limage5 winaide
ON CHOOSE OF MENU-ITEM m_Modifier_limage5 /* Modifier l'image */
DO:
  
    RUN GestionImagePerso(btnPerso-5:handle IN FRAME frmFond,"5",FALSE).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Modifier_limage6
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Modifier_limage6 winaide
ON CHOOSE OF MENU-ITEM m_Modifier_limage6 /* Modifier l'image */
DO:
  
    RUN GestionImagePerso(btnPerso-6:handle IN FRAME frmFond,"6",FALSE).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Modifier_limage7
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Modifier_limage7 winaide
ON CHOOSE OF MENU-ITEM m_Modifier_limage7 /* Modifier l'image */
DO:
  
    RUN GestionImagePerso(btnInternet:HANDLE IN FRAME frmFond,"7",FALSE).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Modifier_limage8
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Modifier_limage8 winaide
ON CHOOSE OF MENU-ITEM m_Modifier_limage8 /* Modifier l'image */
DO:
  
    RUN GestionImagePerso(btnAssistance:HANDLE IN FRAME frmFond,"8",FALSE).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Ne_pas_voir_ce_module
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Ne_pas_voir_ce_module winaide
ON CHOOSE OF MENU-ITEM m_Ne_pas_voir_ce_module /* Ne pas voir ce module */
DO:
    DEFINE VARIABLE cTempoOrdre AS CHARACTER NO-UNDO INIT "".
    
    RUN SupprimeModuleActif(ttModulesUtilisateur.cIdent,ttModulesUtilisateur.cLibelle,WinAide:MENU-BAR).


    ttModulesUtilisateur.lInvisible = TRUE.
    gSauvePreference("PREF-VISIBLE-MODULE-" + ttModulesUtilisateur.cIdent,"NON").
    
    /* Sauvegarde du module en cours pour se repositionner dessus à la fin */
    cTempoOrdre = "Accueil".
    
   /* Raffraichissement de la liste des modules */
   {&OPEN-QUERY-brwModules}

   DO WITH FRAME frmFond:
         /* Positionnement sur le module en cours d'utilisation */
         FIND FIRST ttModulesUtilisateur
             WHERE ttModulesUtilisateur.cident = cTempoOrdre
             NO-ERROR.
         IF AVAILABLE(ttModulesUtilisateur) THEN DO:
             REPOSITION brwModules TO ROWID ROWID(ttModulesUtilisateur).
             APPLY "VALUE-CHANGED" TO brwModules.  
         END.  
   END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Nom_du_bouton
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Nom_du_bouton winaide
ON CHOOSE OF MENU-ITEM m_Nom_du_bouton /* Nom du bouton */
DO:
  
    RUN DonnePositionMessage IN ghGeneral.
    gcAllerRetour = STRING(giPosXMessage)
        + "|" + STRING(giPosYMessage)
        + "|" + "Nom du Bouton Perso"
        + "|" + gDonnePreference("BTNPERSO-1-NOM").
    RUN VALUE(gcRepertoireExecution + "saisie2.w") (INPUT-OUTPUT gcAllerRetour).
    IF gcAllerRetour = "" THEN RETURN.
    gSauvePreference("BTNPERSO-1-NOM",ENTRY(4,gcAllerRetour,"|")).
    RUN GereTooltipPerso.    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Nom_du_bouton2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Nom_du_bouton2 winaide
ON CHOOSE OF MENU-ITEM m_Nom_du_bouton2 /* Nom du bouton */
DO:
  
    RUN DonnePositionMessage IN ghGeneral.
    gcAllerRetour = STRING(giPosXMessage)
        + "|" + STRING(giPosYMessage)
        + "|" + "Nom du Bouton Perso"
        + "|" + gDonnePreference("BTNPERSO-2-NOM").
    RUN VALUE(gcRepertoireExecution + "saisie2.w") (INPUT-OUTPUT gcAllerRetour).
    IF gcAllerRetour = "" THEN RETURN.
    gSauvePreference("BTNPERSO-2-NOM",ENTRY(4,gcAllerRetour,"|")).
    RUN GereTooltipPerso.    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Nom_du_bouton3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Nom_du_bouton3 winaide
ON CHOOSE OF MENU-ITEM m_Nom_du_bouton3 /* Nom du bouton */
DO:
  
    RUN DonnePositionMessage IN ghGeneral.
    gcAllerRetour = STRING(giPosXMessage)
        + "|" + STRING(giPosYMessage)
        + "|" + "Nom du Bouton Perso"
        + "|" + gDonnePreference("BTNPERSO-3-NOM").
    RUN VALUE(gcRepertoireExecution + "saisie2.w") (INPUT-OUTPUT gcAllerRetour).
    IF gcAllerRetour = "" THEN RETURN.
    gSauvePreference("BTNPERSO-3-NOM",ENTRY(4,gcAllerRetour,"|")).
    RUN GereTooltipPerso.    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Nom_du_bouton4
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Nom_du_bouton4 winaide
ON CHOOSE OF MENU-ITEM m_Nom_du_bouton4 /* Nom du bouton */
DO:
  
    RUN DonnePositionMessage IN ghGeneral.
    gcAllerRetour = STRING(giPosXMessage)
        + "|" + STRING(giPosYMessage)
        + "|" + "Nom du Bouton Perso"
        + "|" + gDonnePreference("BTNPERSO-4-NOM").
    RUN VALUE(gcRepertoireExecution + "saisie2.w") (INPUT-OUTPUT gcAllerRetour).
    IF gcAllerRetour = "" THEN RETURN.
    gSauvePreference("BTNPERSO-4-NOM",ENTRY(4,gcAllerRetour,"|")).
    RUN GereTooltipPerso.    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Nom_du_bouton5
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Nom_du_bouton5 winaide
ON CHOOSE OF MENU-ITEM m_Nom_du_bouton5 /* Nom du bouton */
DO:
  
    RUN DonnePositionMessage IN ghGeneral.
    gcAllerRetour = STRING(giPosXMessage)
        + "|" + STRING(giPosYMessage)
        + "|" + "Nom du Bouton Perso"
        + "|" + gDonnePreference("BTNPERSO-5-NOM").
    RUN VALUE(gcRepertoireExecution + "saisie2.w") (INPUT-OUTPUT gcAllerRetour).
    IF gcAllerRetour = "" THEN RETURN.
    gSauvePreference("BTNPERSO-5-NOM",ENTRY(4,gcAllerRetour,"|")).
    RUN GereTooltipPerso.    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Nom_du_bouton6
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Nom_du_bouton6 winaide
ON CHOOSE OF MENU-ITEM m_Nom_du_bouton6 /* Nom du bouton */
DO:
  
    RUN DonnePositionMessage IN ghGeneral.
    gcAllerRetour = STRING(giPosXMessage)
        + "|" + STRING(giPosYMessage)
        + "|" + "Nom du Bouton Perso"
        + "|" + gDonnePreference("BTNPERSO-6-NOM").
    RUN VALUE(gcRepertoireExecution + "saisie2.w") (INPUT-OUTPUT gcAllerRetour).
    IF gcAllerRetour = "" THEN RETURN.
    gSauvePreference("BTNPERSO-6-NOM",ENTRY(4,gcAllerRetour,"|")).
    RUN GereTooltipPerso.    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Paramétrer
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Paramétrer winaide
ON CHOOSE OF MENU-ITEM m_Paramétrer /* Paramétrer */
DO:
  
  
    RUN DonnePositionMessage IN ghGeneral.
    gcAllerRetour = STRING(giPosXMessage)
        + "|" + STRING(giPosYMessage)
        + "|" + "Bouton Perso"
        + "|" + gDonnePreference("BTNPERSO-1").
    RUN VALUE(gcRepertoireExecution + "saisie2.w") (INPUT-OUTPUT gcAllerRetour).
    IF gcAllerRetour = "" THEN RETURN.
    gSauvePreference("BTNPERSO-1",ENTRY(4,gcAllerRetour,"|")).
    
    RUN GereTooltipPerso.    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Paramétrer2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Paramétrer2 winaide
ON CHOOSE OF MENU-ITEM m_Paramétrer2 /* Paramétrer */
DO:
  
    RUN DonnePositionMessage IN ghGeneral.
    gcAllerRetour = STRING(giPosXMessage)
        + "|" + STRING(giPosYMessage)
        + "|" + "Bouton Perso"
        + "|" + gDonnePreference("BTNPERSO-2").
    RUN VALUE(gcRepertoireExecution + "saisie2.w") (INPUT-OUTPUT gcAllerRetour).
    IF gcAllerRetour = "" THEN RETURN.
    gSauvePreference("BTNPERSO-2",ENTRY(4,gcAllerRetour,"|")).
    
    RUN GereTooltipPerso.    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Paramétrer3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Paramétrer3 winaide
ON CHOOSE OF MENU-ITEM m_Paramétrer3 /* Paramétrer */
DO:
  
    RUN DonnePositionMessage IN ghGeneral.
    gcAllerRetour = STRING(giPosXMessage)
        + "|" + STRING(giPosYMessage)
        + "|" + "Bouton Perso"
        + "|" + gDonnePreference("BTNPERSO-3").
    RUN VALUE(gcRepertoireExecution + "saisie2.w") (INPUT-OUTPUT gcAllerRetour).
    IF gcAllerRetour = "" THEN RETURN.
    gSauvePreference("BTNPERSO-3",ENTRY(4,gcAllerRetour,"|")).
    
    RUN GereTooltipPerso.    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Paramétrer4
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Paramétrer4 winaide
ON CHOOSE OF MENU-ITEM m_Paramétrer4 /* Paramétrer */
DO:
  
    RUN DonnePositionMessage IN ghGeneral.
    gcAllerRetour = STRING(giPosXMessage)
        + "|" + STRING(giPosYMessage)
        + "|" + "Bouton Perso"
        + "|" + gDonnePreference("BTNPERSO-4").
    RUN VALUE(gcRepertoireExecution + "saisie2.w") (INPUT-OUTPUT gcAllerRetour).
    IF gcAllerRetour = "" THEN RETURN.
    gSauvePreference("BTNPERSO-4",ENTRY(4,gcAllerRetour,"|")).
    
    RUN GereTooltipPerso.    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Paramétrer5
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Paramétrer5 winaide
ON CHOOSE OF MENU-ITEM m_Paramétrer5 /* Paramétrer */
DO:
  
    RUN DonnePositionMessage IN ghGeneral.
    gcAllerRetour = STRING(giPosXMessage)
        + "|" + STRING(giPosYMessage)
        + "|" + "Bouton Perso"
        + "|" + gDonnePreference("BTNPERSO-5").
    RUN VALUE(gcRepertoireExecution + "saisie2.w") (INPUT-OUTPUT gcAllerRetour).
    IF gcAllerRetour = "" THEN RETURN.
    gSauvePreference("BTNPERSO-5",ENTRY(4,gcAllerRetour,"|")).
    
    RUN GereTooltipPerso.    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Paramétrer6
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Paramétrer6 winaide
ON CHOOSE OF MENU-ITEM m_Paramétrer6 /* Paramétrer */
DO:
  
    RUN DonnePositionMessage IN ghGeneral.
    gcAllerRetour = STRING(giPosXMessage)
        + "|" + STRING(giPosYMessage)
        + "|" + "Bouton Perso"
        + "|" + gDonnePreference("BTNPERSO-6").
    RUN VALUE(gcRepertoireExecution + "saisie2.w") (INPUT-OUTPUT gcAllerRetour).
    IF gcAllerRetour = "" THEN RETURN.
    gSauvePreference("BTNPERSO-6",ENTRY(4,gcAllerRetour,"|")).
    
    RUN GereTooltipPerso.    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Paramétrer7
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Paramétrer7 winaide
ON CHOOSE OF MENU-ITEM m_Paramétrer7 /* Paramétrer */
DO:
    RUN DonnePositionMessage IN ghGeneral.
    gcAllerRetour = STRING(giPosXMessage)
        + "|" + STRING(giPosYMessage)
        + "|" + "Raccourci Internet 1"
        + "|" + gDonnePreference("NAVIGATEUR-1").
    RUN VALUE(gcRepertoireExecution + "saisie2.w") (INPUT-OUTPUT gcAllerRetour).
    IF gcAllerRetour = "" THEN RETURN.
    gSauvePreference("NAVIGATEUR-1",ENTRY(4,gcAllerRetour,"|")).
    RUN GereTooltipPerso.  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Paramétrer8
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Paramétrer8 winaide
ON CHOOSE OF MENU-ITEM m_Paramétrer8 /* Paramétrer */
DO:
    RUN DonnePositionMessage IN ghGeneral.
    gcAllerRetour = STRING(giPosXMessage)
        + "|" + STRING(giPosYMessage)
        + "|" + "Raccourci Internet 2"
        + "|" + gDonnePreference("NAVIGATEUR-2").
    RUN VALUE(gcRepertoireExecution + "saisie2.w") (INPUT-OUTPUT gcAllerRetour).
    IF gcAllerRetour = "" THEN RETURN.
    gSauvePreference("NAVIGATEUR-2",ENTRY(4,gcAllerRetour,"|")).
    RUN GereTooltipPerso.  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_ParametrerDev
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_ParametrerDev winaide
ON CHOOSE OF MENU-ITEM m_ParametrerDev /* Paramétrer */
DO:
  
    RUN DonnePositionMessage IN ghGeneral.
    gcAllerRetour = STRING(giPosXMessage)
        + "|" + STRING(giPosYMessage)
        + "|" + "Type d'application (ADB/PME)"
        + "|" + gDonnePreference("TYPE-APPLICATION").
    RUN VALUE(gcRepertoireExecution + "saisie2.w") (INPUT-OUTPUT gcAllerRetour).
    IF gcAllerRetour = "" THEN RETURN.
    gSauvePreference("TYPE-APPLICATION",ENTRY(4,gcAllerRetour,"|")).

    cTypeApplication = gDonnePreference("TYPE-APPLICATION").
    btnGI:TOOLTIP IN FRAME frmFond = "Application GI (Développement) / Clic droit pour paramètrer le type d'application (actuellement : " + cTypeApplication + ")".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Parametrer_Cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Parametrer_Cli winaide
ON CHOOSE OF MENU-ITEM m_Parametrer_Cli /* Paramétrer */
DO:
    RUN DonnePositionMessage IN ghGeneral.
    gcAllerRetour = STRING(giPosXMessage)
        + "|" + STRING(giPosYMessage)
        + "|" + "Nom complet du batch de lancement"
        + "|" + gDonnePreference("BATCH-CLIENT").
    RUN VALUE(gcRepertoireExecution + "saisie2.w") (INPUT-OUTPUT gcAllerRetour).
    IF gcAllerRetour = "" THEN RETURN.
    gSauvePreference("BATCH-CLIENT",ENTRY(4,gcAllerRetour,"|")).
     RUN GereTooltipPerso.
     RUN GereBoutons.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Parametrer_Prec
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Parametrer_Prec winaide
ON CHOOSE OF MENU-ITEM m_Parametrer_Prec /* Paramétrer */
DO:
    RUN DonnePositionMessage IN ghGeneral.
    gcAllerRetour = STRING(giPosXMessage)
        + "|" + STRING(giPosYMessage)
        + "|" + "Nom complet du batch de lancement"
        + "|" + gDonnePreference("BATCH-CLIENT-PREC").
    RUN VALUE(gcRepertoireExecution + "saisie2.w") (INPUT-OUTPUT gcAllerRetour).
    IF gcAllerRetour = "" THEN RETURN.
    gSauvePreference("BATCH-CLIENT-PREC",ENTRY(4,gcAllerRetour,"|")).
    RUN GereTooltipPerso.  
    RUN GereBoutons.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Parametrer_Spe
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Parametrer_Spe winaide
ON CHOOSE OF MENU-ITEM m_Parametrer_Spe /* Paramétrer */
DO:
    RUN DonnePositionMessage IN ghGeneral.
    gcAllerRetour = STRING(giPosXMessage)
        + "|" + STRING(giPosYMessage)
        + "|" + "Nom complet du batch de lancement"
        + "|" + gDonnePreference("BATCH-CLIENT-SPE").
    RUN VALUE(gcRepertoireExecution + "saisie2.w") (INPUT-OUTPUT gcAllerRetour).
    IF gcAllerRetour = "" THEN RETURN.
    gSauvePreference("BATCH-CLIENT-SPE",ENTRY(4,gcAllerRetour,"|")).
     RUN GereTooltipPerso.  
     RUN GereBoutons.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Parametrer_Suiv
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Parametrer_Suiv winaide
ON CHOOSE OF MENU-ITEM m_Parametrer_Suiv /* Paramétrer */
DO:
    RUN DonnePositionMessage IN ghGeneral.
    gcAllerRetour = STRING(giPosXMessage)
        + "|" + STRING(giPosYMessage)
        + "|" + "Nom complet du batch de lancement"
        + "|" + gDonnePreference("BATCH-CLIENT-SUIV").
    RUN VALUE(gcRepertoireExecution + "saisie2.w") (INPUT-OUTPUT gcAllerRetour).
    IF gcAllerRetour = "" THEN RETURN.
    gSauvePreference("BATCH-CLIENT-SUIV",ENTRY(4,gcAllerRetour,"|")).
     RUN GereTooltipPerso.  
     RUN GereBoutons.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Passer_la_version_du_lundi
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Passer_la_version_du_lundi winaide
ON CHOOSE OF MENU-ITEM m_Passer_la_version_du_lundi /* Passer la version du lundi */
DO:
    RUN VersionerVersion("PREC").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Passer_la_version_du_lundi2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Passer_la_version_du_lundi2 winaide
ON CHOOSE OF MENU-ITEM m_Passer_la_version_du_lundi2 /* Passer la version du lundi */
DO:
  
    RUN VersionerVersion("CLI").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Passer_la_version_du_lundi3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Passer_la_version_du_lundi3 winaide
ON CHOOSE OF MENU-ITEM m_Passer_la_version_du_lundi3 /* Passer la version du lundi */
DO:
  
    RUN VersionerVersion("SUIV").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Passer_la_version_du_lundi4
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Passer_la_version_du_lundi4 winaide
ON CHOOSE OF MENU-ITEM m_Passer_la_version_du_lundi4 /* Passer la version du lundi */
DO:
  
    RUN VersionerVersion("SPE").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Patch_Cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Patch_Cli winaide
ON CHOOSE OF MENU-ITEM m_Patch_Cli /* Passer un patch sur la version */
DO:
    RUN PatcherVersion("CLI").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Patch_Prec
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Patch_Prec winaide
ON CHOOSE OF MENU-ITEM m_Patch_Prec /* Passer un patch sur la version */
DO:
    RUN PatcherVersion("PREC").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Patch_Spe
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Patch_Spe winaide
ON CHOOSE OF MENU-ITEM m_Patch_Spe /* Passer un patch sur la version */
DO:
    RUN PatcherVersion("SPE").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Patch_Suiv
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Patch_Suiv winaide
ON CHOOSE OF MENU-ITEM m_Patch_Suiv /* Passer un patch sur la version */
DO:
    RUN PatcherVersion("SUIV").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Préférences
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Préférences winaide
ON CHOOSE OF MENU-ITEM m_Préférences /* Préférences */
DO:
    RUN LancePreferences(FALSE).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Redémarrer_Menudev2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Redémarrer_Menudev2 winaide
ON CHOOSE OF MENU-ITEM m_Redémarrer_Menudev2 /* Redémarrer Menudev2 */
DO:
  RUN reboot.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Réinitialiser_avec_les_coul
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Réinitialiser_avec_les_coul winaide
ON CHOOSE OF MENU-ITEM m_Réinitialiser_avec_les_coul /* Réinitialiser avec les couleurs d'origine */
DO:
  
    DEFINE VARIABLE cTempoOrdre AS CHARACTER NO-UNDO INIT "".
    
    /* Sauvegarde du module en cours pour se repositionner dessus à la fin */
    cTempoOrdre = ttModulesUtilisateur.cIdent.
    
    FOR EACH    PREFS
        WHERE   PREFS.cUtilisateur = gcUtilisateur
            AND     PREFS.cCode BEGINS "PREF-COULEUR-MODULE-"
        :
        DELETE PREFS.
      END.
    
  IF gDonnePreference("PREF-COULEUR-MODULE-" + "Favoris") = "" THEN
      gSauvePreference("PREF-COULEUR-MODULE-" + "Favoris","12").
  IF gDonnePreference("PREF-COULEUR-MODULE-" + "RDev") = "" THEN
      gSauvePreference("PREF-COULEUR-MODULE-" + "RDev","2").
  IF gDonnePreference("PREF-COULEUR-MODULE-" + "ROut") = "" THEN
      gSauvePreference("PREF-COULEUR-MODULE-" + "ROut","9").

   FOR EACH ttModulesUtilisateur:
       ttModulesUtilisateur.iCouleur = INTEGER(gDonnePreference("PREF-COULEUR-MODULE-" + ttModulesUtilisateur.cIdent)).
   END.

   /* Raffraichissement de la liste des modules */
   {&OPEN-QUERY-brwModules}

   DO WITH FRAME frmFond:
     /* Positionnement sur le module en cours d'utilisation */
     FIND FIRST ttModulesUtilisateur
         WHERE ttModulesUtilisateur.cident = cTempoOrdre
         NO-ERROR.
     IF AVAILABLE(ttModulesUtilisateur) THEN DO:
         REPOSITION brwModules TO ROWID ROWID(ttModulesUtilisateur).
         APPLY "VALUE-CHANGED" TO brwModules.  
     END.  
   END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Remettre
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Remettre winaide
ON CHOOSE OF MENU-ITEM m_Remettre /* Remettre les modules à leurs positions par défaut */
DO:
  
    RUN DeplaceModule("init").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Remettre_image_par_défaut
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Remettre_image_par_défaut winaide
ON CHOOSE OF MENU-ITEM m_Remettre_image_par_défaut /* Remettre image par défaut */
DO:
  
    RUN GestionImagePerso(btnPerso-1:HANDLE IN FRAME frmFond,"1",TRUE).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Remettre_image_par_défaut2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Remettre_image_par_défaut2 winaide
ON CHOOSE OF MENU-ITEM m_Remettre_image_par_défaut2 /* Remettre image par défaut */
DO:
  
    RUN GestionImagePerso(btnPerso-2:HANDLE IN FRAME frmFond,"2",TRUE).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Remettre_image_par_défaut3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Remettre_image_par_défaut3 winaide
ON CHOOSE OF MENU-ITEM m_Remettre_image_par_défaut3 /* Remettre image par défaut */
DO:
  
    RUN GestionImagePerso(btnPerso-3:HANDLE IN FRAME frmFond,"3",TRUE).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Remettre_image_par_défaut4
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Remettre_image_par_défaut4 winaide
ON CHOOSE OF MENU-ITEM m_Remettre_image_par_défaut4 /* Remettre image par défaut */
DO:
  
    RUN GestionImagePerso(btnPerso-4:HANDLE IN FRAME frmFond,"4",TRUE).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Remettre_image_par_défaut5
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Remettre_image_par_défaut5 winaide
ON CHOOSE OF MENU-ITEM m_Remettre_image_par_défaut5 /* Remettre image par défaut */
DO:
  
    RUN GestionImagePerso(btnPerso-5:HANDLE IN FRAME frmFond,"5",TRUE).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Remettre_image_par_défaut6
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Remettre_image_par_défaut6 winaide
ON CHOOSE OF MENU-ITEM m_Remettre_image_par_défaut6 /* Remettre image par défaut */
DO:
  
    RUN GestionImagePerso(btnPerso-6:HANDLE IN FRAME frmFond,"6",TRUE).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Remettre_image_par_défaut7
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Remettre_image_par_défaut7 winaide
ON CHOOSE OF MENU-ITEM m_Remettre_image_par_défaut7 /* Remettre image par défaut */
DO:
    RUN GestionImagePerso(btnInternet:HANDLE IN FRAME frmFond,"7",TRUE).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Remettre_image_par_défaut8
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Remettre_image_par_défaut8 winaide
ON CHOOSE OF MENU-ITEM m_Remettre_image_par_défaut8 /* Remettre image par défaut */
DO:
  
    RUN GestionImagePerso(btnAssistance:HANDLE IN FRAME frmFond,"8",TRUE).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Répondre_à_lutilisateur_du_
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Répondre_à_lutilisateur_du_ winaide
ON CHOOSE OF MENU-ITEM m_Répondre_à_lutilisateur_du_ /* Répondre à l'utilisateur du message en cours */
DO:
    DEFINE VARIABLE lRetour AS LOGICAL NO-UNDO.

    RUN GereInformations("REPONSE").    
    RUN GereInformations("LU-ORDRE-ENCOURS").
    RUN DonneOrdre("Infos","Recharge",OUTPUT lretour).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Restorer_Cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Restorer_Cli winaide
ON CHOOSE OF MENU-ITEM m_Restorer_Cli /* Restaurer une version */
DO:
    RUN RestorerVersion("CLI").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Restorer_DEV
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Restorer_DEV winaide
ON CHOOSE OF MENU-ITEM m_Restorer_DEV /* Restaurer une version */
DO:
    RUN RestorerVersion("DEV").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Restorer_Prec
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Restorer_Prec winaide
ON CHOOSE OF MENU-ITEM m_Restorer_Prec /* Restaurer une version */
DO:
    RUN RestorerVersion("PREC").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Restorer_SPE
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Restorer_SPE winaide
ON CHOOSE OF MENU-ITEM m_Restorer_SPE /* Restaurer une version */
DO:
    RUN RestorerVersion("SPE").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Restorer_Suiv
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Restorer_Suiv winaide
ON CHOOSE OF MENU-ITEM m_Restorer_Suiv /* Restaurer une version */
DO:
    RUN RestorerVersion("SUIV").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Sauvegarder_Cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Sauvegarder_Cli winaide
ON CHOOSE OF MENU-ITEM m_Sauvegarder_Cli /* Sauvegarder la version */
DO:
    RUN SauvegarderVersion("CLI").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Sauvegarder_Prec
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Sauvegarder_Prec winaide
ON CHOOSE OF MENU-ITEM m_Sauvegarder_Prec /* Sauvegarder la version */
DO:
  RUN SauvegarderVersion("PREC").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Sauvegarder_SPE
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Sauvegarder_SPE winaide
ON CHOOSE OF MENU-ITEM m_Sauvegarder_SPE /* Sauvegarder la version */
DO:
    RUN SauvegarderVersion("SPE").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Sauvegarder_Suiv
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Sauvegarder_Suiv winaide
ON CHOOSE OF MENU-ITEM m_Sauvegarder_Suiv /* Sauvegarder la version */
DO:
    RUN SauvegarderVersion("SUIV").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Sauvegarde_DEV
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Sauvegarde_DEV winaide
ON CHOOSE OF MENU-ITEM m_Sauvegarde_DEV /* Sauvegarde de la version */
DO:
  RUN SauvegarderVersion("DEV").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Supprimer_le_message_en_cou
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Supprimer_le_message_en_cou winaide
ON CHOOSE OF MENU-ITEM m_Supprimer_le_message_en_cou /* Supprimer le message en cours */
DO:
    RUN GereInformations("EFFACE-ORDRE-ENCOURS").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Supprimer_tous_les_messages
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Supprimer_tous_les_messages winaide
ON CHOOSE OF MENU-ITEM m_Supprimer_tous_les_messages /* Supprimer tous les messages */
DO:
    RUN GereInformations("EFFACE-ORDRE-TOUS").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Voir_tous_les_modules
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Voir_tous_les_modules winaide
ON CHOOSE OF MENU-ITEM m_Voir_tous_les_modules /* Voir tous les modules */
DO:
  
    DEFINE VARIABLE cTempoOrdre AS CHARACTER NO-UNDO INIT "".
    
    /* Sauvegarde du module en cours pour se repositionner dessus à la fin */
    cTempoOrdre = ttModulesUtilisateur.cIdent.
    
    FOR EACH    PREFS
        WHERE   PREFS.cUtilisateur = gcUtilisateur
            AND     PREFS.cCode BEGINS "PREF-VISIBLE-MODULE-"
        :
        DELETE PREFS.
      END.
    
   FOR EACH ttModulesUtilisateur:
       ttModulesUtilisateur.lInvisible = FALSE.
   END.

   /* Raffraichissement de la liste des modules */
   {&OPEN-QUERY-brwModules}

   DO WITH FRAME frmFond:
     /* Positionnement sur le module en cours d'utilisation */
     FIND FIRST ttModulesUtilisateur
         WHERE ttModulesUtilisateur.cident = cTempoOrdre
         NO-ERROR.
     IF AVAILABLE(ttModulesUtilisateur) THEN DO:
         REPOSITION brwModules TO ROWID ROWID(ttModulesUtilisateur).
         APPLY "VALUE-CHANGED" TO brwModules.  
     END.  
   END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brwinfos
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK winaide 


/* ***************************  Main Block  *************************** */

/* Set CURRENT-WINDOW: this will parent dialog-boxes and frames.        */
ASSIGN CURRENT-WINDOW                = {&WINDOW-NAME} 
       THIS-PROCEDURE:CURRENT-WINDOW = {&WINDOW-NAME}.

SESSION:APPL-ALERT-BOXES = TRUE.
/*SESSION:TIME-SOURCE = "gidata".*/

glUtilTrace = (gcUtilisateur = gcUtilTrace).

/* The CLOSE event can be used from inside or outside the procedure to  */
/* terminate it.                                                        */

ON CLOSE OF THIS-PROCEDURE 
   RUN disable_UI.


ON 'CTRL-F':U ANYWHERE  
DO :
    RUN DonneOrdre(gcModuleEnCours,"Recherche",OUTPUT lRetour).  
END.

ON 'CTRL-S':U ANYWHERE  
DO :
    RUN DonneOrdre(gcModuleEnCours,"VALIDATION",OUTPUT lRetour).  
END.

ON '²':U ANYWHERE
DO:
    /* Affichage de l'accueil */
    DO WITH FRAME frmfond.
        FIND FIRST ttModulesUtilisateur
            WHERE ttModulesUtilisateur.cident = "accueil"
            NO-ERROR.
        IF AVAILABLE(ttModulesUtilisateur) THEN DO:
            REPOSITION brwModules TO ROWID ROWID(ttModulesUtilisateur).
            APPLY "VALUE-CHANGED" TO brwModules.  
        END.  
    END.

    /* Mettre le mot de passe dans le presse papier */
    RUN DonneOrdre("accueil","MDP-PP",OUTPUT lRetour).  
END.

ON "CTRL-ALT-V":U ANYWHERE  
DO:
    RUN gDechargeVariables ("FICHIER").
    RETURN.
END.

ON "CTRL-ALT-HOME":U ANYWHERE  
DO:
    WinAide:X = 0.
    WinAide:Y = 0.
    /* Maj des coordonnées */
    RUN DonnePositionMenudev.
    gSauvePreference("POSITION","").

    gSauvePreference("PREF-BROUILLON-X","0").
    gSauvePreference("PREF-BROUILLON-Y","0").
END.

/* Best default for GUI applications is...                              */
PAUSE 0 BEFORE-HIDE.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO /*ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK*/:
    brwinfos:SET-REPOSITIONED-ROW(5,"ALWAYS") IN FRAME frmfond.
     
    /* pré-traitements */
    cProgrammeExterne = gcRepertoireExecution + "Pretraitements.p".
    IF SEARCH(cProgrammeExterne) <> ? THEN DO:
        COMPILE VALUE(cProgrammeExterne).
        RUN VALUE(cProgrammeExterne) (gcUtilisateur).
    END.

    /* Vérifier que menudev2 n'est pas déjà lancé et/ou planté */
    /* --------------- 
    FIND FIRST utilisateurs NO-LOCK
        WHERE utilisateur.cutilisateur = gcUtilisateur
        AND   utilisateur.lConnecte = TRUE
        NO-ERROR.
    IF AVAILABLE(utilisateur) THEN DO:
        MESSAGE "ATTENTION : Une session de Menudev2 est actuellement connectée sur la base."
            + CHR(10) + "Il s'agit peut-être d'un plantage d'une session antérieure, ou bien Menudev2 est déjà en cours d'execution sur votre poste."
            + CHR(10) + "Deux sessions de Menudev2 simultanées risquent de provoquer des locks et des plantages."
            + CHR(10) + CHR(10) + "Pour éviter de lancer 2 fois Menudev2, il faut executer Menudev2 avec 'LanceMenudev2.exe' et non 'LanceMenudev2.bat'."
            + CHR(10) + "Ces 2 fichiers se trouvent sous 'H:\dev\outils\progress\Menudev2'."
            VIEW-AS ALERT-BOX INFORMATION.
    END.
    -------------- */
    /*
    RUN ListeProcesses   .
    IF cMenudev <> "" THEN DO:
        cCommande = Loc_Outils + "\ActiveWindow.exe " + """Menu développeur -""".
        OS-COMMAND SILENT VALUE(cCommande).
        QUIT.    
    END.
*/
    /* Positionnement de la window */
    WinAide:X = 0.
    WinAide:Y = 0.
    IF gDonnePreference("PREF-POSITION") = "OUI" THEN DO:
        cTempo1 = gDonnePreference("POSITION").
        IF NUM-ENTRIES(cTempo1,"|") = 2 THEN DO:
            WinAide:X = INTEGER(ENTRY(1,cTempo1,"|")).
            WinAide:Y = INTEGER(ENTRY(2,cTempo1,"|")).
        END.
    END.

    /* Maj des coordonnées */
    RUN DonnePositionMenudev.

    cTypeApplication = gDonnePreference("TYPE-APPLICATION").
    /*btnGI:TOOLTIP = "Application GI (Développement) / Clic droit pour paramètrer le type d'application (actuellement : " + cTypeApplication + ")".*/

    /* Recherche de la version progress */
    /* Version Progress en cours */
    gcVersionProgress = "V" + ENTRY(1,PROVERSION,".").

    RUN enable_UI.
    RUN Initialisation.
    IF not(gDonnePreference("PREF-MODESILENCIEUX")) = "OUI" THEN do:
        RUN JoueSon(gcRepertoireRessources + "Arpege2.wav"). 
    END.   

    WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.
RUN Terminaison.
QUIT.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE AffichageFrames winaide 
PROCEDURE AffichageFrames :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER cFrame-in    AS CHARACTER   NO-UNDO.
   
    /* on rend les autres frames invisibles */
    FOR EACH gttModules
        WHERE valid-handle(gttModules.hModule):
        IF gttModules.cIdent <> cFrame-in THEN DO:
            RUN DonneOrdre(gttModules.cIdent,"CACHE",OUTPUT lRetour).
        END.
    END.

    /* De manière générale */
    RUN DonneOrdre(cFrame-in,"AFFICHE",OUTPUT lRetour).  

    /* Gestion des boutons */
    /*RUN GereBoutons.*/  /* deplacer dans donneordre */

    /* Si besoin : initialiser */  
    IF lInitialiser THEN RUN DonneOrdre(cFrame-in,"INIT",OUTPUT lRetour).
    

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE AfficheAbsences winaide 
PROCEDURE AfficheAbsences :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE cAbsJour AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cAbsFutures AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cTempo AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO.
    DEFINE VARIABLE dTempo AS DATE NO-UNDO.
    
    /* si WE on ne fait rien */
    IF ((WEEKDAY(TODAY) = 1 OR WEEKDAY(TODAY) = 7) AND gDonnePreference("PREFS-ABSENCES-PAS-AVERTISSEMENT-WE") = "OUI") THEN
        RETURN.

    /* Affichage des absences si demandé */
    ASSIGN dTempo = date(gDonnePreference("PREF-ABSENCES-PREVENU")) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN dTempo = DATE(1,1,2000).
    /*MESSAGE "dTempo = " dTempo VIEW-AS ALERT-BOX.*/
    IF dTempo = ? OR dTempo < TODAY THEN DO:
        cTempo = "".
        IF dTempo <> ? AND dTempo <> DATE(1,1,2000) AND dTempo < TODAY THEN DO:
            gSupprimePreference("ABSENCES-SIGNALEES-*").
        END.
        RUN gDonneAbsences(FALSE,OUTPUT cAbsJour, OUTPUT cAbsFutures).
        IF gDonnePreference("PREFS-ABSENCES-JOUR-PREVENIR") = "OUI" THEN
            IF cAbsJour <> "" THEN cTempo = cTempo + "Seront absents aujourd'hui :%s" + cAbsJour.
        IF gDonnePreference("PREFS-ABSENCES-FUTURES-PREVENIR") = "OUI" THEN
            IF cAbsFutures <> "" THEN cTempo = cTempo + (IF cAbsJour <> "" THEN "%s%s" ELSE "") + "Seront absents dans les " 
                + STRING(INTEGER(gDonnePreference("PREFS-ABSENCES-JOURS"))) + " jours à venir :%s"
                + cAbsFutures.
    
        gSauvePreference("PREF-ABSENCES-PREVENU",STRING(TODAY)).
        IF cTempo <> "" THEN DO:
            RUN JoueSon(gcRepertoireRessources + "Ho-ho.wav").
            RUN gAfficheMessageTemporaire("Absences",cTempo,FALSE,0,"OK","",FALSE,OUTPUT cRetour).
        END.
       
    END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE AjouteModuleActif winaide 
PROCEDURE AjouteModuleActif :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER cIdentModule-in AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER cNomModule-in AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER m_Pere-in AS WIDGET-HANDLE.
    
    DEFINE VARIABLE m_Actif AS WIDGET-HANDLE.
    DEFINE VARIABLE iCompteur AS INTEGER NO-UNDO.

    /* recherche du module en cours dans la liste des modules actifs */
    FIND FIRST  ttModulesActifs
        WHERE   ttModulesActifs.cIdent = cIdentModule-in
        NO-ERROR.
    IF NOT(AVAILABLE(ttModulesActifs)) THEN DO:
        CREATE ttModulesActifs.
        ttModulesActifs.cIdent = cIdentModule-in.
        ttModulesActifs.cLibelle = cNomModule-in.
    END.
    
    /* Mise en haut de la liste du module en cours */
    ttModulesActifs.iOrdre = 0.

    /* renumérotation des modules */
    iCompteur = 1.
    FOR EACH    ttModulesActifs
        BY ttmodulesActifs.iOrdre
        :
        ttModulesActifs.iOrdre = iCompteur.
        iCompteur = iCompteur + 1.
    END.

    /* génération du menu */
    IF VALID-HANDLE(m_ListeActifs) THEN DELETE WIDGET m_ListeActifs.

    /* Création du sous menu */
    CREATE SUB-MENU m_ListeActifs
        ASSIGN 
            PARENT = m_Pere-in 
            LABEL = "Modules actifs"
            PRIVATE-DATA = ""
            .

    FOR EACH ttModulesActifs
        BY ttModulesActifs.iordre
        :  
        CREATE MENU-ITEM m_Actif
            ASSIGN 
                PARENT = m_ListeActifs 
                LABEL = ttModulesActifs.clibelle
                PRIVATE-DATA = ttModulesActifs.cIdent
            TRIGGERS:
                ON "choose" PERSISTENT RUN ChoixModuleActif IN THIS-PROCEDURE (m_Actif:PRIVATE-DATA).
            END TRIGGERS.
    END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ChoixModuleActif winaide 
PROCEDURE ChoixModuleActif :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER cModule-in AS CHARACTER NO-UNDO.

    DEFINE VARIABLE lTempo AS LOGICAL.

    RUN DonneOrdre(cModule-in,"AFFICHE",OUTPUT lTempo).

    /* Repositionnement de la liste des modules */
    lManuel = TRUE.
    FIND FIRST  ttModulesUtilisateur
        WHERE   ttModulesUtilisateur.cident = cModule-in
        NO-ERROR.
    IF AVAILABLE(ttModulesUtilisateur) THEN DO:
        REPOSITION brwModules TO RECID RECID(ttModulesUtilisateur).
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ControlePassageVersion winaide 
PROCEDURE ControlePassageVersion :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cFichierDetail AS CHARACTER NO-UNDO.

    /* existe-t-il le bypass de controle de la version */
    IF SEARCH(gcRepertoireRessourcesPrivees + "Utilisateurs\" + gcUtilisateur + "\bypass\PasControleVersion.on") <> ? THEN DO:
        RETURN.   
    END.
    
    /* vérifie que le passage de la dernière version s'est bien passé */
    IF SEARCH(gcRepertoireRessourcesPrivees + "Majs\" + STRING(giVersionUtilisateur + 1,"999") + "\suivi\" + gcUtilisateur) <> ? 
    OR gcDroitsUtilisateur matches "*simulation_version*" THEN DO:
        /*
        RUN gAfficheMessageTemporaire("Informations","Le passage de la version "
                                    + string(giVersionUtilisateur,"999")
                                    + " à "
                                    + string(giVersionUtilisateur + 1,"999")
                                    + " est fait."
                                    + CHR(10) + "Les modifications/nouveautés de cette version sont dans la section '[ A propos ]'"
                                    ,FALSE,10,"OK","MESSAGE-APRESVERSION",FALSE,OUTPUT cRetour).
        */
        /* mise à jour de la version de l'utilisateur */
        FIND FIRST  Utilisateurs    EXCLUSIVE-LOCK
            WHERE  Utilisateurs.cUtilisateur = gcUtilisateur
            NO-ERROR.
        IF AVAILABLE(Utilisateurs) THEN DO:
            Utilisateurs.iVersion = giVersionUtilisateur + 1.
        END.
        giVersionUtilisateur = giVersionUtilisateur + 1.
        RELEASE utilisateurs.
        
        cFichierDetail = gcRepertoireRessourcesPrivees + "Majs\" + STRING(giVersionUtilisateur,"999") + "\" + STRING(giVersionUtilisateur,"999") + ".pdf".
        IF SEARCH(cFichierDetail) <> ? THEN DO:
            OS-COMMAND SILENT VALUE("start """" " + cFichierDetail).
        END.
        
    END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ControleVersionDisponible winaide 
PROCEDURE ControleVersionDisponible :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO INIT "".
    DEFINE VARIABLE cCommande AS CHARACTER NO-UNDO INIT "".
    DEFINE VARIABLE cFichier AS CHARACTER NO-UNDO INIT "".

    /* existe-t-il le bypass de controle de la version */
    IF SEARCH(gcRepertoireRessourcesPrivees + "Utilisateurs\" + gcUtilisateur + "\bypass\PasControleVersion.on") <> ? THEN DO:
        RETURN.   
    END.
    
    /* vérification d'une version > version en cours */
    IF SEARCH(gcRepertoireRessourcesPrivees + "Majs\" + STRING(giVersionUtilisateur + 1,"999") + "\maj.bat") <> ? THEN DO: 
        RUN gAfficheMessageTemporaire("Informations","Nouvelle version de menudev2 disponible : "
                                        + string(giVersionUtilisateur + 1,"999")
                                        + "%sMenudev2 va se fermer et se relancera après passage de la mise à jour."
                                        ,FALSE,10,"OK","MESSAGE-AVANTVERSION",FALSE,OUTPUT cRetour).
        cCommande = gcRepertoireRessourcesPrivees + "Majs\" 
                                 + "Maj-Menudev2.bat " 
                                 + STRING(giVersionUtilisateur + 1,"999") 
                                 + " "
                                 + gcUtilisateur
                                 + " "
                                 + STRING(giVersionUtilisateur,"999")
                                .
        cFichier = loc_tmp + "\Maj-menudev2-" + gcUtilisateur + ".bat".
        OUTPUT TO value(cFichier).
        PUT UNFORMATTED "start " + cCommande SKIP.
        PUT UNFORMATTED "exit" SKIP.
        OUTPUT CLOSE.
        OS-COMMAND VALUE(cFichier).
        gAddParam("FORCAGE-MAJ","TRUE").

        /* Pour activer l'onglet A propos à la réouverture */
        /*gSauvePreference("DERNIER-MODULE","APropos").*/

        APPLY "CHOOSE" TO btnQuitter IN FRAME frmFond.
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control_load winaide  _CONTROL-LOAD
PROCEDURE control_load :
/*------------------------------------------------------------------------------
  Purpose:     Load the OCXs    
  Parameters:  <none>
  Notes:       Here we load, initialize and make visible the 
               OCXs in the interface.                        
------------------------------------------------------------------------------*/

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN
DEFINE VARIABLE UIB_S    AS LOGICAL    NO-UNDO.
DEFINE VARIABLE OCXFile  AS CHARACTER  NO-UNDO.

OCXFile = SEARCH( "menudev2.wrx":U ).
IF OCXFile = ? THEN
  OCXFile = SEARCH(SUBSTRING(THIS-PROCEDURE:FILE-NAME, 1,
                     R-INDEX(THIS-PROCEDURE:FILE-NAME, ".":U), "CHARACTER":U) + "wrx":U).

IF OCXFile <> ? THEN
DO:
  ASSIGN
    chChrono = Chrono:COM-HANDLE
    UIB_S = chChrono:LoadControls( OCXFile, "Chrono":U)
    Chrono:NAME = "Chrono":U
  .
  RUN initialize-controls IN THIS-PROCEDURE NO-ERROR.
END.
ELSE MESSAGE "menudev2.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE DeplaceModule winaide 
PROCEDURE DeplaceModule :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER cSens-in AS CHARACTER NO-UNDO.
  
    DEFINE VARIABLE cTempoOrdre AS CHARACTER NO-UNDO.
    DEFINE VARIABLE iIncrement AS INTEGER NO-UNDO.
    DEFINE BUFFER bttModulesUtilisateur FOR ttModulesUtilisateur.
    DEFINE VARIABLE iTempoOrdre AS INTEGER NO-UNDO INIT 0.
    
    /* Sauvegarde du module en cours pour se repositionner dessus à la fin */
    cTempoOrdre = ttModulesUtilisateur.cIdent.
    
    IF cSens-in <> "init" THEN DO:
        /* Déplacement physique du module */
        DO WITH FRAME frmFond:
            IF cSens-in = "BAS" THEN DO:
                FIND FIRST bttModulesUtilisateur
                    WHERE bttModulesUtilisateur.iOrdre > ttModulesUtilisateur.iOrdre
                    NO-ERROR.
                IF NOT(AVAILABLE(bttModulesUtilisateur)) THEN RETURN.
                IF bttModulesUtilisateur.iOrdre = 9999 THEN RETURN.
                iIncrement = 11.
            END.
            IF cSens-in = "HAUT" THEN DO:
                FIND LAST bttModulesUtilisateur
                    WHERE bttModulesUtilisateur.iOrdre < ttModulesUtilisateur.iOrdre
                    NO-ERROR.
                IF NOT(AVAILABLE(bttModulesUtilisateur)) THEN RETURN.
                IF bttModulesUtilisateur.iOrdre = 0 THEN RETURN.
                iIncrement = -11.
            END.
        
            ttModulesUtilisateur.iOrdre = ttModulesUtilisateur.iOrdre + iIncrement.
        END.
    END.
  
  /* Annule les préférences d'ordre des modules de l'utilisateur */
  FOR EACH    PREFS
    WHERE   PREFS.cUtilisateur = gcUtilisateur
        AND     PREFS.cCode BEGINS "PREF-ORDRE-MODULE-"
    :
    DELETE PREFS.
  END.
 
  /* Renumérotation temporaire à + 10000 */
  iTempoOrdre = 10000.
  FOR EACH bttModulesUtilisateur
      WHERE bttModulesUtilisateur.iOrdre < 10000
      BY bttModulesUtilisateur.iOrdre:

      iTempoOrdre = iTempoOrdre + 10.    
      bttModulesUtilisateur.iOrdre = iTempoOrdre.
  END.

  iTempoOrdre = 0.
  IF cSens-in <> "init" THEN DO:
       /* Renumérotation de 10 en 10 en fonction de l'ordre actuel et mémorisation de l'ordre */
       FOR EACH bttModulesUtilisateur
           WHERE bttModulesUtilisateur.iOrdre > 10000
           BY bttModulesUtilisateur.iOrdre:

           /* REcherche du numero d'ordre du module */
           IF bttModulesUtilisateur.cIdent = "Accueil" THEN DO:
               bttModulesUtilisateur.iOrdre = 0.
           END.
           ELSE IF bttModulesUtilisateur.cIdent = "APropos" THEN DO:
               bttModulesUtilisateur.iOrdre = 9999.
           END.
           ELSE DO:
               iTempoOrdre = iTempoOrdre + 10.
               bttModulesUtilisateur.iOrdre = iTempoOrdre.
               gSauvePreference("PREF-ORDRE-MODULE-" + bttModulesUtilisateur.cIdent, STRING(bttModulesUtilisateur.iOrdre)).
           END.
      END.
   END.
   ELSE DO:
       /* Remise dans l'ordre alphabétique par défaut */
       FOR EACH bttModulesUtilisateur
           WHERE bttModulesUtilisateur.iOrdre > 10000
           BY bttModulesUtilisateur.cLibelle:

           /* REcherche du numero d'ordre du module */
           IF bttModulesUtilisateur.cIdent = "Accueil" THEN DO:
               bttModulesUtilisateur.iOrdre = 0.
           END.
           ELSE IF bttModulesUtilisateur.cIdent = "APropos" THEN DO:
               bttModulesUtilisateur.iOrdre = 9999.
           END.
           ELSE DO:
               iTempoOrdre = iTempoOrdre + 10.
               bttModulesUtilisateur.iOrdre = iTempoOrdre.
               gSauvePreference("PREF-ORDRE-MODULE-" + bttModulesUtilisateur.cIdent, STRING(bttModulesUtilisateur.iOrdre)).
           END.
      END.
   END.

   /* Raffraichissement de la liste des modules */
   {&OPEN-QUERY-brwModules}

     /* Positionnement sur le module en cours d'utilisation */
     FIND FIRST ttModulesUtilisateur
         WHERE ttModulesUtilisateur.cident = cTempoOrdre
         NO-ERROR.
     IF AVAILABLE(ttModulesUtilisateur) THEN DO:
         REPOSITION brwModules TO ROWID ROWID(ttModulesUtilisateur).
         APPLY "VALUE-CHANGED" TO brwModules.  
     END.  

 END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI winaide  _DEFAULT-DISABLE
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
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(winaide)
  THEN DELETE WIDGET winaide.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE DonneOrdre winaide 
PROCEDURE DonneOrdre :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER  cModule-in  AS CHARACTER    NO-UNDO.
DEFINE INPUT PARAMETER  cOrdre-in   AS CHARACTER    NO-UNDO.
DEFINE OUTPUT PARAMETER  lRetour-ou   AS LOGICAL    NO-UNDO.

    DEFINE VARIABLE hModule     AS HANDLE       NO-UNDO.
    DEFINE VARIABLE cNomModule  AS character    NO-UNDO.
    DEFINE VARIABLE hPopup  AS WIDGET-HANDLE NO-UNDO.

    /* Récupération du handle du module demandé */
    FIND FIRST gttModules
        WHERE   gttModules.cIdent = cModule-in
        NO-ERROR.
    IF NOT(AVAILABLE(gttModules)) THEN RETURN.
    hModule = gttModules.hModule.

    /* Handle valide ? */
    lInitialiser = FALSE.
    IF NOT(VALID-HANDLE(hModule)) THEN DO:
        /* Lancement de l'écran */
        /*MESSAGE "répertoire : " gcRepertoireExecution VIEW-AS ALERT-BOX.*/
        cNomModule = gcRepertoireExecution + gttModules.cProgramme + ".w".
        IF SEARCH(cNomModule) = ? THEN RETURN.
        RUN VALUE(cNomModule) PERSISTENT SET hModule (winAide,gttModules.cLibelle + "," + gttModules.cparametres).
        gttModules.hModule = hModule.
        lInitialiser = TRUE. /* Pour savoir si on doit initialiser apres affichage */
    END.

    /* appel du module */
    RUN ExecuteOrdre IN hModule (cOrdre-in,OUTPUT lRetour-ou).
    IF cOrdre-in = "AFFICHE" THEN do:
        hpopup = WinAide:MENU-BAR.
        RUN AjouteModuleActif(gttmodules.cIdent,gttmodules.cLibelle,hpopup).
        gcModuleEnCours = cModule-in.
        RUN GereBoutons IN hModule.
        RUN GereBoutons.
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE DonnePositionMessage winaide 
PROCEDURE DonnePositionMessage :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    giPosXMessage = WinAide:X + (WinAide:WIDTH-PIXELS / 2).
    giPosYMessage = WinAide:Y + (WinAide:HEIGHT-PIXELS / 2).
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE DonnePositionMessage winaide 
PROCEDURE DonnePositionMenudev :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    giPosXMenudev = WinAide:X.
    giPosYMenudev = WinAide:Y.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI winaide  _DEFAULT-ENABLE
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
  RUN control_load.
  DISPLAY filBoutonDev filBoutonPrec filBoutongi filBoutonSuiv filBoutonSpe 
      WITH FRAME frmFond IN WINDOW winaide.
  ENABLE rctBoutons rctBoutons-3 rctBoutons-5 rctBoutons-4 rctRaff rctRaff-2 
         btnQuitter filBoutonDev filBoutonPrec filBoutongi filBoutonSuiv 
         filBoutonSpe brwModules brwinfos btnPerso-1 btnPerso-2 btnPerso-3 
         btnPerso-4 btnPerso-5 btnPerso-6 btnCli btnCliPrec btnCliSpe 
         btnCliSuiv btnAssistance btnInternet btnGI btnModifier btnEmprunt 
         btnPutty btnTeamviewer btnAbandon btnAjouter btnImprimer btnRaf 
         btnSupprimer btnValidation 
      WITH FRAME frmFond IN WINDOW winaide.
  {&OPEN-BROWSERS-IN-QUERY-frmFond}
  VIEW winaide.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ExecuteOrdre winaide 
PROCEDURE ExecuteOrdre :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER  cOrdre-in   AS CHARACTER    NO-UNDO.

    DEFINE VARIABLE iBoucle AS INTEGER      NO-UNDO.
    DEFINE VARIABLE cOrdre  AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE cAction AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE cValeur AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE lRetour AS LOGICAL      NO-UNDO.

    /* Décomposition de la chaine d'ordre */
    DO iBoucle = 1 TO NUM-ENTRIES(cOrdre-in):
        cOrdre = ENTRY(iBoucle,cOrdre-in).
        cAction = ENTRY(1,cOrdre,"=").
        cValeur = (IF NUM-ENTRIES(cOrdre,"=") = 2 THEN ENTRY(2,cOrdre,"=") ELSE "").
        
   
        /* Lancement de l'action */
        CASE cAction:
            WHEN "AFFICHE-DATE" THEN DO:
/*                winAide:TITLE = "GI - V" + string(giVersionUtilisateur,"999") + " - " + gcUtilisateur + " - Progress : " + PROVERSION + " - Semaine : " + cValeur.*/
                winAide:TITLE = gcUtilisateur + " - OE : " + PROVERSION + " - Semaine : " + cValeur.
            END.
            WHEN "CHANGE-UTILISATEUR" THEN DO:
                RUN Initialisation.
            END.
            WHEN "DONNEORDREAMODULE" THEN DO:
                RUN DonneOrdre(ENTRY(1,cValeur,"|"),ENTRY(2,cValeur,"|"),OUTPUT lRetour).
            END.
            WHEN "MODIFIER" THEN DO:
                APPLY "CHOOSE" TO btnModifier IN FRAME frmFond.
            END.
            WHEN "AJOUTER" THEN DO:
                APPLY "CHOOSE" TO btnAjouter IN FRAME frmFond.
            END.
            WHEN "SUPPRIMER" THEN DO:
                APPLY "CHOOSE" TO btnSupprimer IN FRAME frmFond.
            END.
            WHEN "REINIT-BOUTONS" THEN DO:
                RUN GereEtat("VIS").
            END.
            WHEN "REINIT-BOUTONS-2" THEN DO:
                RUN GereEtat("VIS-2").
            END.
            WHEN "REINIT-BOUTONS-3" THEN DO:
                RUN GereEtat("VIS-3").
            END.
            WHEN "TOP-GENERAL" THEN DO:
                RUN TopChronoGeneral.
            END.
            WHEN "ORDRE-GENERAL" THEN DO:
                RUN OrdreGeneral(cValeur,OUTPUT lRetour).
            END.
            WHEN "GESTION-VERSIONS" THEN DO:
                RUN GereBoutons.
            END.
            WHEN "INFOS-MAJ" THEN DO:
                RUN OuvreQueryInfos.
            END.
            WHEN "PREFS-GENERALES" THEN DO:
                RUN LancePreferences(TRUE).
            END.
        END CASE. /* fin du case */
    END. /* fin du do iboucle */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ExplorerVersion winaide 
PROCEDURE ExplorerVersion :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER cVersion-in AS CHARACTER NO-UNDO.

    DEFINE VARIABLE cRepertoireVersion AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cCommandeShell AS CHARACTER NO-UNDO.

    /* Lancement du batch de sauvegarde */
    CASE cVersion-in:
        WHEN "PREC" OR WHEN "SUIV" OR WHEN "SPE" THEN DO:
            cRepertoireVersion = "gi_" + cVersion-in + "\" + "gi". 
        END.
        WHEN "CLI" THEN DO:
            cRepertoireVersion = "gi". 
        END.
        WHEN "DEV" THEN DO:
            cRepertoireVersion = "gidev". 
        END.
    END CASE.
    cRepertoireVersion = disque + cRepertoireVersion.

    cCommandeShell = "explorer.exe " + cRepertoireVersion.
    RUN ExecuteCommandeDos(cCommandeShell).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Forcage winaide 
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE GereBoutons winaide 
PROCEDURE GereBoutons :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DO WITH FRAME frmFond:
        btnAjouter:SENSITIVE = ChargeTooltip(btnAjouter:HANDLE,gcAideAjouter).
        btnModifier:SENSITIVE = ChargeTooltip(btnModifier:HANDLE,gcAideModifier).
        btnSupprimer:SENSITIVE = ChargeTooltip(btnSupprimer:HANDLE,gcAideSupprimer).
        btnImprimer:SENSITIVE = ChargeTooltip(btnImprimer:HANDLE,gcAideImprimer).
        btnRaf:SENSITIVE = ChargeTooltip(btnRaf:HANDLE,gcAideRaf).
    
        RUN GereTooltipPerso.

        /* Gestion des boutons de version */
        MENU m_Gestion_de_la_version_PREC:SENSITIVE = (gDonnePreference("BATCH-CLIENT-PREC") MATCHES ("*Scripts\session\Lancement.bat*")).
        MENU m_Gestion_de_la_version_CLI:SENSITIVE = (gDonnePreference("BATCH-CLIENT") MATCHES ("*Scripts\session\Lancement.bat*")).
        MENU m_Gestion_de_la_version_SUIV:SENSITIVE = (gDonnePreference("BATCH-CLIENT-SUIV") MATCHES ("*Scripts\session\Lancement.bat*")).
        
        MENU-ITEM m_Passer_la_version_du_lundi:sensitive in MENU POPUP-MENU-btnCliPrec = (gcDroitsUtilisateur matches "*Lundi*").
        MENU-ITEM m_Passer_la_version_du_lundi2:sensitive in MENU POPUP-MENU-btnCli = (gcDroitsUtilisateur matches "*Lundi*").
        MENU-ITEM m_Passer_la_version_du_lundi3:sensitive in MENU POPUP-MENU-btnClisuiv = (gcDroitsUtilisateur matches "*Lundi*").
        MENU-ITEM m_Passer_la_version_du_lundi4:sensitive in MENU POPUP-MENU-btnCliSpe = (gcDroitsUtilisateur matches "*Lundi*").

    END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE GereEtat winaide 
PROCEDURE GereEtat :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER cEtat-in AS CHARACTER.

    DO WITH FRAME frmFond:
        btnAjouter:SENSITIVE = (cEtat-in = "VIS" OR cEtat-in = "VIS-3").
        btnModifier:SENSITIVE = (cEtat-in = "VIS" OR cEtat-in = "VIS-2" OR cEtat-in = "VIS-3").
        btnSupprimer:SENSITIVE = (cEtat-in = "VIS" OR cEtat-in = "VIS-3").
        btnValidation:SENSITIVE = (cEtat-in <> "VIS" AND cEtat-in <> "VIS-3").
        btnAbandon:SENSITIVE = (cEtat-in <> "VIS" AND cEtat-in <> "VIS-3").
        brwModules:SENSITIVE = (cEtat-in = "VIS" OR cEtat-in = "VIS-2" OR cEtat-in = "VIS-3").
    END.

    btnValidation:VISIBLE = btnValidation:SENSITIVE.
    btnAbandon:VISIBLE = btnAbandon:SENSITIVE.
    btnAjouter:VISIBLE = btnAjouter:SENSITIVE OR cEtat-in = "VIS-2" OR cEtat-in = "VIS-3".
    btnModifier:VISIBLE = btnModifier:SENSITIVE OR cEtat-in = "VIS-2" OR cEtat-in = "VIS-3".
    btnSupprimer:VISIBLE = btnSupprimer:SENSITIVE OR cEtat-in = "VIS-2" OR cEtat-in = "VIS-3".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE GereInformations winaide 
PROCEDURE GereInformations :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER cAction-in AS CHARACTER NO-UNDO.

    DEFINE VARIABLE cPressePapier AS CHARACTER NO-UNDO INIT "".
    DEFINE VARIABLE cTempo AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lRetour AS LOGICAL NO-UNDO.
    
    IF (cAction-in = "LU-ORDRE-ENCOURS") THEN DO:
        /* Ne pas supprimer l'enregistrement curseur bidon */
        IF ttordres.cMessageDistribue = ">" THEN RETURN.

        /* Trouver l'ordre en cours */
        FIND FIRST ordres  EXCLUSIVE-LOCK
            WHERE ordres.cutilisateur = ttordres.cutilisateur
            AND ordres.cAction = ttordres.cAction
            AND ordres.lDistribue = ttordres.lDistribue
            AND ordres.cMessageDistribue = ttordres.cMessageDistribue
           NO-ERROR.
        IF AVAILABLE(ordres) THEN ordres.lLu = TRUE.
        RUN OuvreQueryInfos.
    END.
    
    IF cAction-in = "EFFACE-ORDRE-ENCOURS" THEN DO:
        /* Ne pas supprimer l'enregistrement curseur bidon */
        IF ttordres.cMessageDistribue = ">" THEN RETURN.

        /* Trouver l'ordre en cours */
        FIND FIRST ordres  EXCLUSIVE-LOCK
            WHERE ordres.cutilisateur = ttordres.cutilisateur
            AND ordres.cAction = ttordres.cAction
            AND ordres.lDistribue = ttordres.lDistribue
            AND ordres.cMessageDistribue = ttordres.cMessageDistribue
           NO-ERROR.
        IF AVAILABLE(ordres) THEN DELETE ordres.
        RUN OuvreQueryInfos.
    END.
    
    IF cAction-in = "EFFACE-ORDRE-TOUS" THEN DO:
        RUN gAfficheMessageTemporaire("Confirmation","Confirmez-vous la suppression de TOUS LES MESSAGES ?",TRUE,10,"NON","MESSAGE-SUPPRESSION-1",FALSE,OUTPUT cRetour).
        IF cRetour = "NON" THEN RETURN.

        /* Suppression de tous les ordres */
        FOR EACH ordres EXCLUSIVE-LOCK
           WHERE ordres.cutilisateur = gcUtilisateur
           AND ordres.cAction = "INFOS"
           AND ordres.cMessageDistribue <> ">"
           :
           DELETE ordres.
        END.
        RUN OuvreQueryInfos.
    END.

    IF cAction-in = "PPAPIER-ORDRE-ENCOURS" THEN DO:
        /* Ne pas supprimer l'enregistrement curseur bidon */
        IF ttordres.cMessageDistribue = ">" THEN RETURN.
        /* Trouver l'ordre en cours */
        FIND FIRST ordres  NO-LOCK
            WHERE ordres.cutilisateur = ttordres.cutilisateur
            AND ordres.cAction = ttordres.cAction
            AND ordres.lDistribue = ttordres.lDistribue
            AND ordres.cMessageDistribue = ttordres.cMessageDistribue
           NO-ERROR.
        IF AVAILABLE(ordres) THEN DO:
            cPressePapier = ordres.cMessageDistribue.
        END.
        IF cPressePapier <> "" THEN CLIPBOARD:VALUE = cPressePapier.
    END.

    IF cAction-in = "PPAPIER-ORDRE-TOUS" THEN DO:
        /* envoyer le code vers le presse papier */
        FOR EACH ordres NO-LOCK
           WHERE ordres.cutilisateur = gcUtilisateur
           AND ordres.cAction = "INFOS"
           AND ordres.lDistribue = TRUE
           AND ordres.cMessageDistribue <> ">"
           :
           cPressePapier = cPressePapier + (IF cPressePapier <> "" THEN CHR(10) ELSE "") + ordres.cMessageDistribue.
        END.
        IF cPressePapier <> "" THEN CLIPBOARD:VALUE = cPressePapier.
    END.

    IF cAction-in = "REPONSE" THEN DO:
        /* Ne pas reponndre si l'enregistrement curseur bidon */
        IF ttordres.cMessageDistribue = ">" THEN RETURN.

        cTempo = ttOrdres.filler.

        IF cTempo = "Menudev2"  
        OR cTempo = "Barbade"
        OR cTempo = "Neptune2"
        THEN DO:
            RUN gAfficheMessageTemporaire("Informations","Impossible de répondre à cet utilisateur",FALSE,5,"OK","MESSAGE-IMPOSSIBLE",FALSE,OUTPUT cRetour).
            RETURN.
        END.

	    RUN DonnePositionMessage IN ghGeneral.
	    gcAllerRetour = STRING(giPosXMessage)
	        + "|" + STRING(giPosYMessage)
            + "|" + "Votre message"
            + "|" + "".
        RUN VALUE(gcRepertoireExecution + "saisie2.w") (INPUT-OUTPUT gcAllerRetour).
        IF gcAllerRetour = "" THEN RETURN.

        RUN gEnvoiOrdre("INFOS",ENTRY(4,gcAllerRetour,"|"),cTempo,gcUtilisateur,false,TRUE).

    END.

    gAddParam("INFOS-RECHARGER","OUI").
    IF gcModuleEnCours = "INFOS" THEN DO:
        RUN DonneOrdre("Infos","Recharge",OUTPUT lretour).
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE GereTooltipPerso winaide 
PROCEDURE GereTooltipPerso :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE lVersionManuelle AS LOGICAL NO-UNDO INIT FALSE.

    lVersionManuelle = (gDonnePreference("AIDE-BOUTON-MANUELLE") = "OUI").
    
    /* Tooltip du bouton perso */
    DO WITH FRAME frmFond :
        IF gDonnePreference("BTNPERSO-1-NOM") <> "" THEN
            btnPerso-1:TOOLTIP = gDonnePreference("BTNPERSO-1-NOM") + " / Clic droit pour paramètrer".
        ELSE IF gDonnePreference("BTNPERSO-1") <> "" THEN
            btnPerso-1:TOOLTIP = gDonnePreference("BTNPERSO-1") + " / Clic droit pour paramètrer".
        ELSE    
        btnPerso-1:TOOLTIP = "Bouton perso. / Clic droit pour paramètrer".

        IF gDonnePreference("BTNPERSO-2-NOM") <> "" THEN
            btnPerso-2:TOOLTIP = gDonnePreference("BTNPERSO-2-NOM") + " / Clic droit pour paramètrer".
        ELSE IF gDonnePreference("BTNPERSO-2") <> "" THEN
            btnPerso-2:TOOLTIP = gDonnePreference("BTNPERSO-2") + " / Clic droit pour paramètrer".
        ELSE    
            btnPerso-2:TOOLTIP = "Bouton perso. / Clic droit pour paramètrer".

        IF gDonnePreference("BTNPERSO-3-NOM") <> "" THEN
            btnPerso-3:TOOLTIP = gDonnePreference("BTNPERSO-3-NOM") + " / Clic droit pour paramètrer".
        ELSE IF gDonnePreference("BTNPERSO-3") <> "" THEN
            btnPerso-3:TOOLTIP = gDonnePreference("BTNPERSO-3") + " / Clic droit pour paramètrer".
        ELSE    
            btnPerso-3:TOOLTIP = "Bouton perso. / Clic droit pour paramètrer".

        IF gDonnePreference("BTNPERSO-4-NOM") <> "" THEN
            btnPerso-4:TOOLTIP = gDonnePreference("BTNPERSO-4-NOM") + " / Clic droit pour paramètrer".
        ELSE IF gDonnePreference("BTNPERSO-4") <> "" THEN
            btnPerso-4:TOOLTIP = gDonnePreference("BTNPERSO-4") + " / Clic droit pour paramètrer".
        ELSE    
            btnPerso-4:TOOLTIP = "Bouton perso. / Clic droit pour paramètrer".

        IF gDonnePreference("BTNPERSO-5-NOM") <> "" THEN
            btnPerso-5:TOOLTIP = gDonnePreference("BTNPERSO-5-NOM") + " / Clic droit pour paramètrer".
        ELSE IF gDonnePreference("BTNPERSO-5") <> "" THEN
            btnPerso-5:TOOLTIP = gDonnePreference("BTNPERSO-5") + " / Clic droit pour paramètrer".
        ELSE    
            btnPerso-5:TOOLTIP = "Bouton perso. / Clic droit pour paramètrer".

        IF gDonnePreference("BTNPERSO-6-NOM") <> "" THEN
            btnPerso-6:TOOLTIP = gDonnePreference("BTNPERSO-6-NOM") + " / Clic droit pour paramètrer".
        ELSE IF gDonnePreference("BTNPERSO-6") <> "" THEN
            btnPerso-6:TOOLTIP = gDonnePreference("BTNPERSO-6") + " / Clic droit pour paramètrer".
        ELSE    
            btnPerso-6:TOOLTIP = "Bouton perso. / Clic droit pour paramètrer".

        IF gDonnePreference("BATCH-CLIENT") <> "" THEN
            btnCli:TOOLTIP = gDonnePreference("BATCH-CLIENT") + " / Clic droit pour paramètrer".
        ELSE    
            btnCli:TOOLTIP = "Bouton GI (Cli) / Clic droit pour paramètrer".
        
        IF gDonnePreference("BATCH-CLIENT-SUIV") <> "" THEN
            btnCliSuiv:TOOLTIP = gDonnePreference("BATCH-CLIENT-SUIV") + " / Clic droit pour paramètrer".
        ELSE    
            btnCliSuiv:TOOLTIP = "Bouton GI (Suiv) / Clic droit pour paramètrer".
        
        IF gDonnePreference("BATCH-CLIENT-PREC") <> "" THEN
            btnCliPrec:TOOLTIP = gDonnePreference("BATCH-CLIENT-PREC") + " / Clic droit pour paramètrer".
        ELSE    
            btnCliPrec:TOOLTIP = "Bouton GI (Prec)/ Clic droit pour paramètrer".

        IF gDonnePreference("BATCH-CLIENT-SPE") <> "" THEN
            btnCliSpe:TOOLTIP = gDonnePreference("BATCH-CLIENT-SPE") + " / Clic droit pour paramètrer".
        ELSE    
            btnCliSpe:TOOLTIP = "Bouton GI (Spe)/ Clic droit pour paramètrer".
        

        IF gDonnePreference("NAVIGATEUR") <> "" THEN
            btnInternet:TOOLTIP = gDonnePreference("NAVIGATEUR") + " / Clic droit pour paramètrer".
        ELSE    
            btnInternet:TOOLTIP = "Bouton Internet / Clic droit pour paramètrer".

        IF gDonnePreference("ASSISTANCE") <> "" THEN
            btnAssistance:TOOLTIP = gDonnePreference("ASSISTANCE") + " / Clic droit pour paramètrer".
        ELSE    
            btnAssistance:TOOLTIP = "Bouton Assistance. / Clic droit pour paramètrer".

        IF gDonnePreference("PUTTY") <> "" THEN
            btnPutty:TOOLTIP = gDonnePreference("PUTTY") + " / Clic droit pour paramètrer".
        ELSE    
            btnPutty:TOOLTIP = "Bouton Putty / Clic droit pour paramètrer".

        IF gDonnePreference("TEAMVIEWER") <> "" THEN
            btnTeamviewer:TOOLTIP = gDonnePreference("TEAMVIEWER") + " / Clic droit pour paramètrer".
        ELSE    
            btnTeamviewer:TOOLTIP = "Bouton TeamViewer / Clic droit pour paramètrer".

        IF gDonnePreference("REPERTOIRE-CLIENT-PFGI") <> "" THEN
            btnServeurs-2:TOOLTIP = gDonnePreference("REPERTOIRE-CLIENT-PFGI") + " / Clic droit pour paramètrer".
        ELSE    
            btnServeurs-2:TOOLTIP = "Bouton Serveurs GI Client / Clic droit pour paramètrer".
        
        /* Fill-in des versions */
        filBoutonDev:SCREEN-VALUE = DonneVersion("DEV").
        IF filBoutonDev:SCREEN-VALUE <> "" THEN DO:
            filBoutonDev:TOOLTIP = filBoutonDev:SCREEN-VALUE.
        END.
        ELSE DO:
            filBoutonDev:TOOLTIP = "Saisissez ici la version concernée par le bouton GI DEV".
        END.
        filBoutonDev:SENSITIVE = (lVersionManuelle = TRUE).

        filBoutonPrec:SCREEN-VALUE = DonneVersion("PREC").
        IF filBoutonPrec:SCREEN-VALUE <> "" THEN DO:
            filBoutonPrec:TOOLTIP = filBoutonPrec:SCREEN-VALUE.
        END.
        ELSE DO:
            filBoutonPrec:TOOLTIP = "Saisissez ici la version concernée par le bouton GI PREC".
        END.
        filBoutonPrec:SENSITIVE = (lVersionManuelle = TRUE).

        filBoutonGI:SCREEN-VALUE = DonneVersion("CLI").
        IF filBoutonGI:SCREEN-VALUE <> "" THEN DO:
            filBoutonGI:TOOLTIP = filBoutonGI:SCREEN-VALUE.
        END.
        ELSE DO:
            filBoutonGI:TOOLTIP = "Saisissez ici la version concernée par le bouton GI CLI".
        END.
        filBoutonGI:SENSITIVE = (lVersionManuelle = TRUE).
        
        filBoutonSuiv:SCREEN-VALUE = DonneVersion("SUIV").
        IF filBoutonSuiv:SCREEN-VALUE <> "" THEN DO:
            filBoutonSuiv:TOOLTIP = filBoutonSuiv:SCREEN-VALUE.
        END.
        ELSE DO:
            filBoutonSuiv:TOOLTIP = "Saisissez ici la version concernée par le bouton GI SUIV".
        END.
        filBoutonSuiv:SENSITIVE = (lVersionManuelle = TRUE).
        
        filBoutonSpe:SCREEN-VALUE = DonneVersion("SPE").
        IF filBoutonSpe:SCREEN-VALUE <> "" THEN DO:
            filBoutonSpe:TOOLTIP = filBoutonSpe:SCREEN-VALUE.
        END.
        ELSE DO:
            filBoutonSpe:TOOLTIP = "Saisissez ici la version concernée par le bouton GI SPE".
        END.
        filBoutonSpe:SENSITIVE = (lVersionManuelle = TRUE).
    END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE GestionImagePerso winaide 
PROCEDURE GestionImagePerso :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER hBouton-in AS HANDLE NO-UNDO.
    DEFINE INPUT PARAMETER cNumeroBouton-in AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER lReinitialisation-in AS LOGICAL NO-UNDO.

    DEFINE VARIABLE cRepertoireImages AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cFichierImage AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cFichierACharger AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cFichierImageSansRepertoire AS CHARACTER NO-UNDO.
    
    cRepertoireImages = gcRepertoireRessourcesPrivees + "Utilisateurs\" + gcUtilisateur + "\".

    IF NOT lReinitialisation-in THEN DO:
        SYSTEM-DIALOG GET-FILE cFichierImage INITIAL-DIR cRepertoireImages USE-FILENAME FILTERS "Fichiers ico" "*.ico" , "Fichiers bmp" "*.bmp".
        IF cFichierImage = "" THEN RETURN.
    
        /* copie du fichier dans le répertoire "Utilisateurs" */
        cFichierImageSansRepertoire = ENTRY(NUM-ENTRIES(cFichierImage,"\"),cFichierImage,"\").
        IF not(cFichierImage MATCHES "*Utilisateurs*") THEN DO:
            OS-COPY VALUE(cFichierImage) VALUE(cRepertoireImages + cFichierImageSansRepertoire).
        END.  
        gSauvePreference("PREF-BOUTON-PERSO-" + cNumeroBouton-in + "-IMAGE",cFichierImageSansRepertoire).
        cFichierACharger = cRepertoireImages + cFichierImageSansRepertoire.
    END.
    ELSE DO:
        IF gDonnePreference("PREF-BOUTON-PERSO-" + cNumeroBouton-in + "-IMAGE-DEFAUT") = "" THEN DO:
            cFichierImageSansRepertoire = cNumeroBouton-in + ".ico".
            gSauvePreference("PREF-BOUTON-PERSO-" + cNumeroBouton-in + "-IMAGE","").
            cFichierACharger = gcRepertoireImages + cFichierImageSansRepertoire.
        END.
        ELSE DO:
            cFichierACharger = gcRepertoireImages + gDonnePreference("PREF-BOUTON-PERSO-" + cNumeroBouton-in + "-IMAGE-DEFAUT").
        END.
    END.

    hBouton-in:LOAD-IMAGE(cFichierACharger).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Informations winaide 
PROCEDURE Informations :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE VARIABLE cTempo AS CHARACTER NO-UNDO.
DEFINE VARIABLE cLibelleBulle AS CHARACTER NO-UNDO INIT "".
DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO.
DEFINE VARIABLE cLibelleMessage AS CHARACTER NO-UNDO.
DEFINE VARIABLE cLibelleMessage2 AS CHARACTER NO-UNDO.
DEFINE VARIABLE lImportant AS LOGICAL NO-UNDO INIT FALSE.
DEFINE VARIABLE lMessageErreur AS LOGICAL NO-UNDO INIT FALSE.
DEFINE VARIABLE lArret AS LOGICAL NO-UNDO INIT FALSE.
DEFINE VARIABLE lReboot AS LOGICAL NO-UNDO INIT FALSE.
DEFINE VARIABLE lRetour AS LOGICAL NO-UNDO INIT FALSE.
DEFINE VARIABLE cCommande AS CHARACTER NO-UNDO.
DEFINE VARIABLE iJours AS INTEGER NO-UNDO.

    lMessageErreur = FALSE.
     iJours = integer(gDonnePreference("INFOS-JOURS-MAX")).

    /* récupération des ordres & informations */
    FOR EACH ordres EXCLUSIVE-LOCK
       WHERE ordres.cutilisateur = gcUtilisateur
       AND ordres.cAction = "INFOS"
       AND not(ordres.lDistribue)
       AND (cSens = "R" OR cSens = "" OR cSens = ?) /* Pour gérer les anciens messages */
       :
        IF  ordres.cmessage = "<ARRET>" THEN DO:
            lArret = TRUE.
        END.
        ELSE IF  ordres.cmessage = "<REBOOT>" THEN DO:
            lReboot = TRUE.
        END.
        ELSE DO:
            IF ordres.cmessage BEGINS "!" THEN do:
                lMessageErreur = TRUE.
                ordres.lErreur = TRUE.
            END.
            cLibelleMessage = "Le " + string(ordres.ddate,"99/99/9999") + " à " + STRING(ordres.iordre,"hh:mm") 
               + " (" + gDonneVraiNomUtilisateur(ordres.filler) + ")"
               + " > " + ordres.cmessage.
            ordres.cMessageDistribue = cLibelleMessage. 
    
            cLibelleMessage2 = ordres.filler + " : Le " + string(ordres.ddate,"99/99/9999") + " à " + STRING(ordres.iordre,"hh:mm") 
               + chr(10) +  chr(10) + ordres.cmessage.

            IF ordres.lPrioritaire THEN DO:
                lImportant = TRUE.
                RUN gAfficheMessageTemporaire("!!! MESSAGE IMPORTANT !!!",cLibelleMessage2,FALSE,0,"OK","",TRUE,OUTPUT cRetour).
            END.
    
            cLibelleBulle = cLibelleBulle 
                          + (IF cLibelleBulle <> "" THEN "%s" ELSE "")
                          + "(" + gDonneVraiNomUtilisateur(ordres.filler) + ")" + " > " + ordres.cmessage.
    
           lRecharger = TRUE.
        END.
       ordres.ldistribue = TRUE.

   END.
   RELEASE ordres.
   OUTPUT STREAM stBulle CLOSE.

   RELEASE ordres.

   IF lRecharger <> FALSE THEN DO WITH FRAME frmFond:
        RUN OuvreQueryInfos.
             
        IF not(gDonnePreference("PREF-MODESILENCIEUX")) = "OUI" THEN do:
            IF not(lImportant) THEN DO:
                IF lMessageErreur THEN
                    RUN JoueSon(gcRepertoireRessources + "avertissement7.wav").    
                ELSE
                    RUN JoueSon(gcRepertoireRessources + "DingAscenseur.wav").    
            END.
            ELSE
                RUN JoueSon(gcRepertoireRessources + "SireneSousMarin.wav").    
        END.

        /* Lancement de la bulle */
        cLibelleBulle = REPLACE(cLibelleBulle,CHR(10),"%s").
        cTempo = "call " + quoter(loc_outils + "\tooltip.bat") 
                                + " " 
                                + loc_outils + "\"
                                + " "
                                + QUOTER(cLibelleBulle).

        gMLog("Commande DOS : " + cTempo).
        OS-COMMAND SILENT VALUE(cTempo).

        /* Recharger la liste des messages dans l'onglet Messages */
        gAddParam("INFOS-RECHARGER","OUI").
        IF gcModuleEnCours = "INFOS" THEN DO:
            RUN DonneOrdre("Infos","Recharge",OUTPUT lretour).
        END.

   END.

   lRecharger = FALSE. /* la première fois à ? pour charger au démarrage */

   IF lArret THEN DO:
       gAddParam("FORCAGE-MAJ","TRUE").
       APPLY "CHOOSE" TO btnQuitter IN FRAME frmFond.
   END.

   IF lReboot THEN DO:
    RUN reboot.
   END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Initialisation winaide 
PROCEDURE Initialisation :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE iOrdreEnCours AS INTEGER NO-UNDO INIT 0.
    DEFINE VARIABLE iOrdreModule AS INTEGER NO-UNDO.
    DEFINE VARIABLE cFichierImage AS CHARACTER NO-UNDO.
    

    SESSION:DEBUG-ALERT = TRUE.
    ETIME(TRUE).
    
    /* Gestion de l'utilisateur */
    RUN gGereUtilisateurs("ENTREE").
    IF glUtilTrace THEN mLogDebug("gGereUtilisateurs : Fin",ETIME).

    /* Log de l'application */
    glLogActif = (gDonnePreference("PREF-ACTIVELOG") = "OUI").
    giLatenceMax = INTEGER(gDonnePreference("LATENCE-MASTERGI")).
    giLatenceInternet = INTEGER(gDonnePreference("LATENCE-INTERNET")).
    glDeveloppeur = (gDonnePreference("PREF-DEVELOPPEUR") = "OUI").

    SESSION:IMMEDIATE-DISPLAY = TRUE.

    /* Récupération de l'environnement GI */
    /*RUN RecupereEnvironnementGI.*/
    
    /* Positionnement de la window */
    WinAide:WIDTH-PIXELS = 1024.
    WinAide:HEIGHT-PIXELS = 593 /*490*/.
    WinAide:VIRTUAL-WIDTH-PIXELS = WinAide:WIDTH-PIXELS.
    WinAide:VIRTUAL-HEIGHT-PIXELS = WinAide:HEIGHT-PIXELS.
    WinAide:MAX-WIDTH-PIXELS = WinAide:WIDTH-PIXELS.
    WinAide:MAX-HEIGHT-PIXELS = WinAide:HEIGHT-PIXELS.

    /* Mémorisation du handle du menu */
    ghGeneral = THIS-PROCEDURE.
    DO WITH FRAME frmfond:
        gdPositionXModule = 38.80. /*FRAME frmfond:X + cmbModules:X + cmbModules:WIDTH + 0.5.*/
        gdPositionYModule = 3.52. /*FRAME frmfond:Y + cmbModules:Y .*/
    END.

    iX = WinAide:X + (WinAide:WIDTH-PIXELS / 2).
    iY = WinAide:Y + (WinAide:HEIGHT-PIXELS / 2).
    IF glUtilTrace THEN mLogDebug("Position & taile fenêtre : Fin",ETIME).

    /* Chargement des Définitions  */
    /* Connexion aux bases */
    CONNECT -pf "c:\pfgi\cnxmndev.pf" NO-ERROR.
    IF glUtilTrace THEN mLogDebug("Connexion via cnxmndev.pf : Fin",ETIME).

    RUN gChargeDefinitions.
    IF glUtilTrace THEN mLogDebug("gChargeDefinitions : Fin",ETIME).

    OS-COMMAND SILENT VALUE("mkdir """ + gcRepertoireRessourcesPrivees + "Utilisateurs\" + gcUtilisateur + """").

    cFichierBatchGeneral = gcRepertoireRessourcesPrivees + "scripts\general\menudev2.bat".   
    cFichierBatchEntree = gcRepertoireRessourcesPrivees + "Utilisateurs\" + gcUtilisateur + "\" + gcUtilisateur + "-entree.bat".   
    IF SEARCH(cFichierBatchEntree) = ? THEN DO:
       OS-COMMAND SILENT VALUE("copy """ + gcRepertoireRessourcesPrivees + "Utilisateurs\_Modele.bat"" """ + cFichierBatchEntree + """"). 
    END.

    IF glUtilTrace THEN mLogDebug("Création Utilisateurs\[devusr]\[devusr]-entree.bat : Fin",ETIME).
    
    cFichierBatchSortie = gcRepertoireRessourcesPrivees + "Utilisateurs\" + gcUtilisateur + "\" + gcUtilisateur + "-sortie.bat".   
    IF SEARCH(cFichierBatchSortie) = ? THEN DO:
        OS-COMMAND SILENT VALUE("copy """ + gcRepertoireRessourcesPrivees + "Utilisateurs\_Modele.bat"" """ + cFichierBatchSortie + """"). 
    END.
    IF glUtilTrace THEN mLogDebug("Création Utilisateurs\[devusr]\[devusr]-sortie.bat : Fin",ETIME).

    /* Lancement du fichier batch général de menudev2 */
    IF SEARCH(cFichierBatchGeneral) <> ? THEN DO:
        OS-COMMAND SILENT VALUE("call " + quoter(cFichierBatchGeneral) + " " + quoter(gcRepertoireApplication) + " " + quoter(gcUtilisateur)).
    END.
    IF glUtilTrace THEN mLogDebug("Lancement fichier batch général de Menudev2 : Fin",ETIME).

    /*Avant toute chose : execution du batch perso si nécessaire */
    IF gDonnePreference("PREF-EXECUTIONBATCHENTREE") = "OUI" THEN DO:
        /*MESSAGE "Lancement de : " gcRepertoireRessourcesPrivees + "scripts\general\execute2.bat """ + cFichierBatchEntree + """" VIEW-AS ALERT-BOX.*/
        OS-COMMAND SILENT VALUE("""" + cFichierBatchEntree + """").
    END.
    IF glUtilTrace THEN mLogDebug("Lancement fichier batch général de l'utilisateur [devusr] : Fin",ETIME).

    cFichierBatchMinute = gcRepertoireRessourcesPrivees + "Utilisateurs\" + gcUtilisateur + "\" + gcUtilisateur + "-Minute.bat".   
    IF SEARCH(cFichierBatchMinute) = ? THEN DO:
        OS-COMMAND SILENT VALUE("copy """ + gcRepertoireRessourcesPrivees + "Utilisateurs\_Modele.bat"" """ + cFichierBatchMinute + """"). 
    END.
    IF glUtilTrace THEN mLogDebug("Création Utilisateurs\[devusr]\[devusr]-Minute.bat : Fin",ETIME).

    IF gDonnePreference("PREF-COULEUR-MODULE-" + "Favoris") = "" THEN
        gSauvePreference("PREF-COULEUR-MODULE-" + "Favoris","12").
    IF gDonnePreference("PREF-COULEUR-MODULE-" + "RDev") = "" THEN
        gSauvePreference("PREF-COULEUR-MODULE-" + "RDev","2").
    IF gDonnePreference("PREF-COULEUR-MODULE-" + "ROut") = "" THEN
        gSauvePreference("PREF-COULEUR-MODULE-" + "ROut","9").
    IF glUtilTrace THEN mLogDebug("Récupération/Génération des préférences couleurs utilisateur : Fin",ETIME).

    IF gDonnePreference("PREF-REPERTOIRE-COMMENTAIRES") = "" THEN gSauvePreference("PREF-REPERTOIRE-COMMENTAIRES",loc_log).        
    IF gDonnePreference("PREF-CLIENTINI") = "" THEN gSauvePreference("PREF-CLIENTINI","OUI").
    
    /* Chargement des images */
    WinAide:LOAD-ICON(gcRepertoireRessources + "smile01.ico").
    DO WITH FRAME frmfond:
        btnQuitter:LOAD-IMAGE(gcRepertoireImages + "sortie.ico").
        btnimprimer:LOAD-IMAGE(gcRepertoireImages + "print2.ico").
        btnimprimer:LOAD-IMAGE-INSENSITIVE(gcRepertoireImages + "print2-off.ico").
        btnServeurs:LOAD-IMAGE(gcRepertoireImages + "giserv.ico").
        btnServeurs:LOAD-IMAGE-INSENSITIVE(gcRepertoireImages + "giserv-off.ico").
        btnGI:LOAD-IMAGE(gcRepertoireImages + "gi.ico").
        btnGI:LOAD-IMAGE-INSENSITIVE(gcRepertoireImages + "gi-off.ico").
        btnServeurs-2:LOAD-IMAGE(gcRepertoireImages + "giserv.ico").
        btnCli:LOAD-IMAGE(gcRepertoireImages + "gicli.ico").
        btnCliSuiv:LOAD-IMAGE(gcRepertoireImages + "giclisuiv.ico").
        btnCliPrec:LOAD-IMAGE(gcRepertoireImages + "gicliprec.ico").
        btnCliSpe:LOAD-IMAGE(gcRepertoireImages + "gicliSpe.ico").
        btnRaf:LOAD-IMAGE(gcRepertoireImages + "raff.ico").
        btnRaf:LOAD-IMAGE-INSENSITIVE(gcRepertoireImages + "raff-off.ico").
        btnAjouter:LOAD-IMAGE(gcRepertoireImages + "plus.ico"). /* ajout01.ico */
        btnAjouter:LOAD-IMAGE-INSENSITIVE(gcRepertoireImages + "plus-off.ico"). /* ajout01.ico */
        btnModifier:LOAD-IMAGE(gcRepertoireImages + "modif.ico").
        btnModifier:LOAD-IMAGE-INSENSITIVE(gcRepertoireImages + "modif-off.ico").
        btnSupprimer:LOAD-IMAGE(gcRepertoireImages + "moins.ico").
        btnSupprimer:LOAD-IMAGE-INSENSITIVE(gcRepertoireImages + "moins-off.ico").
        btnValidation:LOAD-IMAGE(gcRepertoireImages + "ok.ico").
        btnAbandon:LOAD-IMAGE(gcRepertoireImages + "supprimer.ico").
        btnEmprunt:LOAD-IMAGE(gcRepertoireImages + "emprunt.ico").
        btnEmprunt:LOAD-IMAGE-INSENSITIVE(gcRepertoireImages + "emprunt-off.ico").
        btnPutty:LOAD-IMAGE(gcRepertoireImages + "putty.ico").
        btnTeamviewer:LOAD-IMAGE(gcRepertoireImages + "Teamviewer.ico").

        btnPerso-1:LOAD-IMAGE(DonneImagePerso("1")).
        btnPerso-2:LOAD-IMAGE(DonneImagePerso("2")).
        btnPerso-3:LOAD-IMAGE(DonneImagePerso("3")).
        btnPerso-4:LOAD-IMAGE(DonneImagePerso("4")).
        btnPerso-5:LOAD-IMAGE(DonneImagePerso("5")).
        btnPerso-6:LOAD-IMAGE(DonneImagePerso("6")).
        btnInternet:LOAD-IMAGE(DonneImagePerso("7")).
        btnAssistance:LOAD-IMAGE(DonneImagePerso("8")).
        
    END.
    IF glUtilTrace THEN mLogDebug("Chargement des images : Fin",ETIME).

    /* Gestion des boutons en fonction du groupe de l'utilisateur */
    IF NOT(gcGroupeUtilisateur) = "DEV" THEN DO:
        btnServeurs:SENSITIVE = FALSE.
        btnGI:SENSITIVE = FALSE.
        btnEmprunt:SENSITIVE = FALSE.
    END.
    IF glUtilTrace THEN mLogDebug("Gestion des boutons DEV/UTIL: Fin",ETIME).

    /* Chargement des modules et des modules favoris */
    cTempo1 = "".
    cTempo2 = "".
    FOR EACH gttModules 
         BY gttModules.clibelle:
        /* Gestion de modules administrateur */
        IF gttModules.lAdmin AND not(glUtilisateurAdmin) THEN NEXT.
        
        /* Gestion du niveau de l'utilisateur */
        IF gttModules.iNiveau > giNiveauUtilisateur THEN NEXT.

        /* Gestion de modules invisibles */
        IF not(gttModules.lVisible) AND not(gDonnePreference("PREF-VOIRMODULESINVISIBLES") = "OUI")  THEN NEXT.

        /* traitement du module */
        CREATE ttModulesUtilisateur.
        ttModulesUtilisateur.cIdent = gttModules.cIdent.
        ttModulesUtilisateur.cLibelle = gttModules.cLibelle.
        ttModulesUtilisateur.lFavoris = gttModules.lFavoris.
        iOrdreEnCours = iOrdreEnCours + 10.
        ttModulesUtilisateur.iOrdre = iOrdreEnCours.
        ttModulesUtilisateur.lInvisible = (gDonnePreference("PREF-VISIBLE-MODULE-" + gttModules.cIdent) = "NON").
        ttModulesUtilisateur.iCouleur = INTEGER(gDonnePreference("PREF-COULEUR-MODULE-" + gttModules.cIdent)).

        /* Recherche du numero d'ordre du module */
        IF gttModules.cIdent = "Accueil" THEN DO:
            ttModulesUtilisateur.iOrdre = 0.
        END.
        ELSE IF gttModules.cIdent = "APropos" THEN DO:
            ttModulesUtilisateur.iOrdre = 9999.
        END.
        ELSE DO:
            iOrdreModule = integer(gDonnePreference("PREF-ORDRE-MODULE-" + gttModules.cIdent)).
            IF iOrdreModule <> 0 THEN ttModulesUtilisateur.iOrdre = iOrdreModule.
        END.
    END.
    IF glUtilTrace THEN mLogDebug("Chargement des modules : Fin",ETIME).

    /* Stockage des préférences actuelles pour initialisation la première fois */
    FOR EACH ttModulesUtilisateur
        BY ttModulesUtilisateur.iOrdre
        :
        gSauvePreference("PREF-ORDRE-MODULE-" + ttModulesUtilisateur.cIdent,STRING(ttModulesUtilisateur.iOrdre)).
        gSauvePreference("PREF-VISIBLE-MODULE-" + ttModulesUtilisateur.cIdent,"OUI").
        gSauvePreference("PREF-COULEUR-MODULE-" + ttModulesUtilisateur.cIdent,STRING(ttModulesUtilisateur.iCouleur)).
    END.
    IF glUtilTrace THEN mLogDebug("Préférences Ordre/Visible/Couleur modules - Stockage des préférences actuelles pour initialisation la première fois : Fin",ETIME).

    {&OPEN-QUERY-brwModules}
    IF glUtilTrace THEN mLogDebug("Ouverture de la query Modules : Fin",ETIME).

    /* Chargement des modules automatiques */    
    FOR EACH defs   NO-LOCK
        WHERE   defs.lLancer
        :
        RUN donneOrdre(defs.cCode,"INIT",OUTPUT lRetour).
        RUN donneOrdre(defs.cCode,"CACHE",OUTPUT lRetour).
        IF glUtilTrace THEN mLogDebug("Modules automatiques - " + defs.cCode + " : Fin",ETIME).
    END.
    IF glUtilTrace THEN mLogDebug("Chargement modules automatiques : Fin",ETIME).

    /* Affichage de l'accueil */
    RUN AffichageFrames("Accueil").
    IF glUtilTrace THEN mLogDebug("Affichage accueil : Fin",ETIME).

    /* Positionnement sur le dernier module utilisé */
    cTempo1 = gDonnePreference("DERNIER-MODULE").
    IF cTempo1 <> "" THEN do:
        FIND FIRST ttModulesUtilisateur
            WHERE ttModulesUtilisateur.cident = cTempo1
            NO-ERROR.
        IF AVAILABLE(ttModulesUtilisateur) THEN DO:
            REPOSITION brwModules TO ROWID ROWID(ttModulesUtilisateur).
            APPLY "VALUE-CHANGED" TO brwModules.  
        END.  
    END.
    ELSE DO:
        FIND FIRST ttModulesUtilisateur
            WHERE ttModulesUtilisateur.cident = "Accueil"
            NO-ERROR.
        IF AVAILABLE(ttModulesUtilisateur) THEN DO:
            REPOSITION brwModules TO ROWID ROWID(ttModulesUtilisateur).
            APPLY "VALUE-CHANGED" TO brwModules.  
        END.  
    END.
    IF glUtilTrace THEN mLogDebug("Positionnement sur le dernier module utilisé : Fin",ETIME).

    /* mappage des disques */
    OS-COMMAND SILENT VALUE(gcRepertoireRessourcesPrivees + "\scripts\general\mappage.bat").
    IF glUtilTrace THEN mLogDebug("Mappage des disques : Fin",ETIME).

    RUN GereEtat("VIS").
    IF glUtilTrace THEN mLogDebug("Gestion VISIBLE/SENSITIVE des boutons : Fin",ETIME).

    /* Gestion des boutons */
    RUN GereBoutons.
    IF glUtilTrace THEN mLogDebug("Gestion VISIBLE/SENSITIVE des boutons (suite) & menus popup : Fin",ETIME).

    /* Synchronisation du timer sur le nombre de minutes avant l'heure pile + 1 seconde */
    cTempo1 = STRING(TIME,"hh:mm:ss").
    iSynchro = 60 - INTEGER(ENTRY(3,cTempo1,":")) + 1.
    iSynchro2 = (60 - INTEGER(ENTRY(3,cTempo1,":")) + 1) / 12.

    gMLog("#TITRE#Synchronisation du timer sur la minute exacte :"
         + "%s Heure en cours = cTempo1 = " + STRING(cTempo1)
         + "%s iSynchro = " + STRING(iSynchro)
         ).

    /* copie en local du batch de saisie du mastergi car trop long en execution sur le serveur */
    OS-COMMAND SILENT VALUE("COPY " + gcRepertoireRessourcesPrivees + "\scripts\general\MasterGIToWindow.exe " + loc_outils).
    IF glUtilTrace THEN mLogDebug("Copie en local du batch de saisie du mastergi : Fin",ETIME).

    cFichierInformations = loc_log + "\infos-" + gcUtilisateur + ".txt".

    /* Partage automatique du répertoire des bases */
    OS-COMMAND NO-WAIT VALUE("net share Bases=" + gDonnePreference("REPERTOIRE-BASES")).
    IF glUtilTrace THEN mLogDebug("Partage automatique du répertoire des bases : Fin",ETIME).
    
    RUN ControlePassageVersion.
    IF glUtilTrace THEN mLogDebug("Controle passage de version récent : Fin",ETIME).

    RUN TopChronoGeneral.
    IF glUtilTrace THEN mLogDebug("Simulation TopChronoGeneral : Fin",ETIME).

    RUN Informations.
    IF glUtilTrace THEN mLogDebug("Affichage des informations en attente : Fin",ETIME).

    RUN GereTooltipPerso.  
    IF glUtilTrace THEN mLogDebug("Gestion des ToolTip perso : Fin",ETIME).

    /* gestion du menu administration */
    IF glUtilisateurAdmin THEN MENU-ITEM m_Admin:SENSITIVE IN MENU MENU-BAR-WinAide = TRUE.
    
    IF gDonnePreference("PREF-BROUILLON") = "OUI" THEN RUN LanceBrouillon.
    IF glUtilTrace THEN mLogDebug("Lancement du brouillon si nécessaire : Fin",ETIME).

    /* Controle jour ferie */
    gJourFerie(TODAY).
    IF glUtilTrace THEN mLogDebug("Controle jour ferié : Fin",ETIME).

    RUN MajPreferences.
    IF glUtilTrace THEN mLogDebug("Mise à jour des préférences : Fin",ETIME).

    RUN OuvreQueryInfos.
    IF glUtilTrace THEN mLogDebug("Ouverture de la guery des informations : Fin",ETIME).

    RUN AfficheAbsences.
    IF glUtilTrace THEN mLogDebug("Affichage des absences du jour et des jours à venir : Fin",ETIME).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE LanceBrouillon winaide 
PROCEDURE LanceBrouillon :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE cNomModule     AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE lREtour AS LOGICAL NO-UNDO.

    /* Lancement du brouillon si nécessaire */
    IF VALID-HANDLE(hModuleBrouillon) THEN do:
        RUN RendVisible IN hModuleBrouillon.  
        RETURN.
    END.
    cNomModule = gcRepertoireExecution + "brouillon.w".
    RUN gEcritLogAgenda("Lancement du brouillon").
    RUN VALUE(cNomModule) PERSISTENT SET hModuleBrouillon (INPUT THIS-PROCEDURE).
    

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE LancePreferences winaide 
PROCEDURE LancePreferences :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER lGeneral-in AS LOGICAL NO-UNDO.

    DEFINE VARIABLE cProgPrefs AS CHARACTER NO-UNDO.

    /* gestion de l'écran des préférences */
    /* En fait, le module Préférences est non visible. on simule le fait de le choisir */
    
    IF lGeneral-in OR gDonnePreference("PREFS-MODULE-DIRECT") <> "OUI" THEN DO:
        RUN AffichageFrames("Prefs").
    END.
    ELSE DO:
        /* appel des preferences du module si disponible */
        cProgPrefs = gcRepertoireExecution + "prefs-" + gDonneProgramme(gcModuleEnCours) + ".w".
        
        IF SEARCH(cProgPrefs) <> ? THEN
            RUN VALUE(cProgPrefs) (gcModuleEnCours).
        ELSE
            RUN AffichageFrames("Prefs").
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ListeProcesses winaide 
PROCEDURE ListeProcesses :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE VARIABLE cCommande AS CHARACTER NO-UNDO.

    cCommande = Loc_Outils + "\WindowExiste.exe " + """Menu développeur -""" + " " +  Loc_tmp.
    OS-COMMAND SILENT VALUE(cCommande).

    INPUT STREAM gstrEntree FROM VALUE(Loc_tmp + "\WindowExiste.log").

    IMPORT STREAM gstrEntree UNFORMATTED cMenudev.
    
    INPUT STREAM gstrEntree CLOSE.

    cMenudev = TRIM(cMenudev).
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MajPreferences winaide 
PROCEDURE MajPreferences :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
   MENU-ITEM m_Patch_Suiv:SENSITIVE IN MENU POPUP-MENU-btnCliSuiv = NOT(gDonnePreference("PREF-MAGICSSUIV") = "OUI").
   MENU-ITEM m_Patch_Prec:SENSITIVE IN MENU POPUP-MENU-btnCliPrec = NOT(gDonnePreference("PREF-MAGICSPREC") = "OUI").
   MENU-ITEM m_Patch_Cli:SENSITIVE IN MENU POPUP-MENU-btnCli = NOT(gDonnePreference("PREF-MAGICSCLI") = "OUI").
   MENU-ITEM m_Patch_Spe:SENSITIVE IN MENU POPUP-MENU-btnCliSpe = NOT(gDonnePreference("PREF-MAGICSSPE") = "OUI").

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MessageStructure winaide 
PROCEDURE MessageStructure :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER cVersion-in AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER lContinuer-ou AS LOGICAL NO-UNDO INIT TRUE.

    DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO.

    IF gGetEtSupParam("CHANGEMENT-STRUCTURE-" + cVersion-in) = "OUI" THEN DO:
        RUN gAfficheMessageTemporaire("Informations","ATTENTION : La version de la base a changé pour cette version '" + cVersion-in + "'.%sPensez à monter la version de vos bases concernées.%sVoulez-vous continuer ?",TRUE,10,"OUI","MESSAGE-CHANGEMENT-STRUCTURE",FALSE,OUTPUT cRetour).
        lContinuer-ou = (cRetour = "OUI").
    END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OrdreGeneral winaide 
PROCEDURE OrdreGeneral :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER cOrdre-in AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER lRetour-ou AS LOGICAL NO-UNDO INIT TRUE.

    DEFINE VARIABLE cTempo1 AS CHARACTER NO-UNDO.

    DEFINE BUFFER bgttModules FOR gttModules.
      
   /* Top général */
    FOR EACH bgttModules
        WHERE valid-handle(bgttModules.hModule):

        CASE cOrdre-in:
            WHEN "FERMETURE" THEN DO:
                RUN Fermeture IN bgttModules.hModule (OUTPUT lREtour-ou) NO-ERROR.
            END.
            WHEN "MAJ-PREFERENCES" THEN DO:
                RUN MajPreferences IN bgttModules.hModule NO-ERROR.
                RUN MajPreferences.
                /* Pas de gestion du retour pour cet ordre */
                lRetour-ou = TRUE.
            END.
        END CASE.
        IF lREtour-ou = FALSE  THEN DO WITH FRAME frmFond:
           /* Activation du module en "erreur" */
            FIND FIRST ttModulesUtilisateur
                WHERE ttModulesUtilisateur.cident = bgttModules.cIdent
                NO-ERROR.
            IF AVAILABLE(ttModulesUtilisateur) THEN DO:
                REPOSITION brwModules TO ROWID ROWID(ttModulesUtilisateur).
                APPLY "VALUE-CHANGED" TO brwModules.  
                RETURN.
            END.  
        END.
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OuvreQueryInfos winaide 
PROCEDURE OuvreQueryInfos :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    DEFINE VARIABLE iJours AS INTEGER NO-UNDO.
    DEFINE VARIABLE lSuppressionEffectuee AS LOGICAL NO-UNDO.
    
    DEFINE BUFFER bOrdres FOR ordres.

     iJours = integer(gDonnePreference("INFOS-JOURS-MAX")).

     /* suppression des message d'incorporation sauf le dernier si demandé */
     IF gDonnePreference("PREF-MESSAGES-DERNIER-INCORPORATION") = "OUI" THEN DO:
         lSuppressionEffectuee = FALSE.
         FIND last   bordres   NO-lock
            WHERE   bordres.cutilisateur = gcUtilisateur
            AND     bordres.cAction = "INFOS"
            AND     bordres.cMessage = "Incorporation des programmes empruntés effectuée"
            AND     (bordres.cSens = "R" OR bordres.cSens = "" OR bordres.cSens = ?) /* Pour gérer les anciens messages */
            USE-INDEX ix_ordres02
            NO-ERROR.
        IF AVAILABLE(bordres) THEN DO:
            FOR EACH    ordres   EXCLUSIVE-LOCK
                WHERE   ordres.cutilisateur = gcUtilisateur
                AND     ordres.cAction = "INFOS"
                AND     ordres.cMessage = "Incorporation des programmes empruntés effectuée"
                AND     (ordres.cSens = "R" OR ordres.cSens = "" OR ordres.cSens = ?) /* Pour gérer les anciens messages */
                AND     RECID(ordres) <> RECID(bordres)
                :
                lSuppressionEffectuee = TRUE.
                DELETE ordres.
             END.
        END.
        IF lSuppressionEffectuee THEN DO:
            RUN DonneOrdre("INFOS","RECHARGE",OUTPUT lRetour).
        END.
     END.

    /* Chargement de la table temporaire */
    EMPTY TEMP-TABLE ttordres.
    FOR EACH ordres 
        WHERE   ordres.cutilisateur = gcUtilisateur
        AND     ordres.cAction = "INFOS"
        and     ordres.lDistribue
        AND     ordres.cMessagedistribue <> ""
        AND     (ordres.cSens = "R" OR ordres.cSens = "" OR ordres.cSens = ?) /* Pour gérer les anciens messages */
        AND     ordres.ddate >= (TODAY - iJours)
        :
        CREATE ttordres.
        BUFFER-COPY ordres TO ttordres.
    END.
   
   {&OPEN-QUERY-brwinfos}

   FIND LAST ttordres   NO-LOCK
       WHERE ttordres.cutilisateur = gcUtilisateur
       AND ttordres.cAction = "INFOS"
       AND ttordres.cmessagedistribue = ">"
       NO-ERROR.
   IF AVAILABLE(ttordres) THEN DO WITH FRAME frmfond:
       REPOSITION brwinfos TO ROWID ROWID(ttordres).
   END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PatcherVersion winaide 
PROCEDURE PatcherVersion :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER cVersion-in AS CHARACTER NO-UNDO.

    OS-COMMAND value("%reseau%dev\outils\progress\Menudev2\Ressources\Scripts\session\Lancement.bat " + cVersion-in + " %reseau%dev\outils\progress\Menudev2\Ressources\Scripts\session\LancePatchGI.bat").
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Reboot winaide 
PROCEDURE Reboot :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE cCommande AS CHARACTER NO-UNDO.

       cCommande = gcRepertoireRessourcesPrivees + "Majs\" + "Maj-Relance-Menudev2.bat" .
       OS-COMMAND VALUE(cCommande).
       gAddParam("FORCAGE-MAJ","TRUE").
       APPLY "CHOOSE" TO btnQuitter IN FRAME frmFond.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE RepertoiresTravail winaide 
PROCEDURE RepertoiresTravail :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    DEFINE INPUT PARAMETER cVersion-in AS CHARACTER NO-UNDO.

    OS-COMMAND value("%reseau%dev\outils\progress\Menudev2\Ressources\Scripts\session\Lancement.bat " + cVersion-in + " %reseau%dev\outils\progress\Menudev2\Ressources\Scripts\session\LanceRepMacros.bat").
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE RestorerVersion winaide 
PROCEDURE RestorerVersion :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER cVersion-in AS CHARACTER NO-UNDO.

    DEFINE VARIABLE cFichierSauvegarde AS CHARACTER NO-UNDO INIT "".
    DEFINE VARIABLE cRepertoireSauvegardes AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cRepertoireVersion AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cCommandeShell AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO.

    IF NOT(ControleServeurs(cVersion-in)) THEN RETURN.

    cRepertoireSauvegardes = disque + "Svg-Versions".

    SYSTEM-DIALOG GET-FILE cFichierSauvegarde INITIAL-DIR cRepertoireSauvegardes USE-FILENAME FILTERS "Fichiers sauvegardes de versions" "gi_" + cVersion-in + "*.7z".

    IF cFichierSauvegarde = "" THEN RETURN.

    MESSAGE "Confirmez-vous la restoration de la version : " cFichierSauvegarde
        VIEW-AS ALERT-BOX QUESTION
        BUTTONS YES-NO 
        TITLE "Demande de confirmation..."
        UPDATE lReponseRestoration AS LOGICAL
        .
    IF NOT(lReponseRestoration) THEN RETURN.

    CASE cVersion-in:
        WHEN "PREC" OR WHEN "SUIV" OR WHEN "SPE" THEN DO:
            cRepertoireVersion = "gi_" + cVersion-in + "\" + "gi". 
        END.
        WHEN "CLI" THEN DO:
            cRepertoireVersion = "gi". 
        END.
        WHEN "DEV" THEN DO:
            cRepertoireVersion = "gidev". 
        END.
    END CASE.
    
    
    MESSAGE "Pour des raisons de blocage de fichier, Menudev2 va se fermer le temps de la restauration, pour se rouvrir automatiquement en fin de restauration."
        + CHR(10) + "Il est déconseillé de relancer Menudev2 tant que la restauration n'est pas terminée."
        + CHR(10) + "Confirmez-vous la restauration ?"
        VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
        TITLE "Demande de confirmation..."
        UPDATE lReponseFermeture AS LOGICAL.
    IF NOT(lReponseFermeture) THEN RETURN.

    cCommandeShell = gcRepertoireRessourcesPrivees + "\scripts\serveurs\_GI-RestoreVersion.bat " + cRepertoireVersion + " " + cFichierSauvegarde.
    RUN ExecuteCommandeDos(cCommandeShell).

    /* Fermeture de menudev2 */
    gAddParam("FORCAGE-MAJ","TRUE").
    /* Pour activer l'onglet A propos à la réouverture */
    gSauvePreference("DERNIER-MODULE","APropos").
    APPLY "CHOOSE" TO btnQuitter IN FRAME frmFond.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE SauvegardeOrdreModules winaide 
PROCEDURE SauvegardeOrdreModules :
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE SauvegarderVersion winaide 
PROCEDURE SauvegarderVersion :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER cVersion-in AS CHARACTER NO-UNDO.

    DEFINE VARIABLE cNomDefaut AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cCommandeShell AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cRepertoireVersion AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cPrefixe AS CHARACTER NO-UNDO.
    
    IF NOT(ControleServeurs(cVersion-in)) THEN RETURN.

    /* nom de la sauvegarde */
    cPrefixe = "gi_" + cVersion-in.
    /*IF cVersion-in = "DEV" THEN cPrefixe = "gidev_".*/
    RUN gNomFichierFormate(cPrefixe,"",".7z", OUTPUT cNomDefaut). 
    RUN DonnePositionMessage IN ghGeneral.
    gcAllerRetour = STRING(giPosXMessage)
        + "|" + STRING(giPosYMessage)
        + "|" + "Nom de la sauvegarde"
        + "|" + cNomDefaut.
    RUN VALUE(gcRepertoireExecution + "saisie2.w") (INPUT-OUTPUT gcAllerRetour).
    IF gcAllerRetour = "" THEN RETURN.

    /* Lancement du batch de sauvegarde */
    cNomDefaut = ENTRY(4,gcAllerRetour,"|").
    CASE cVersion-in:
        WHEN "PREC" OR WHEN "SUIV" OR WHEN "SPE" THEN DO:
            cRepertoireVersion = "gi_" + cVersion-in + "\" + "gi". 
        END.
        WHEN "CLI" THEN DO:
            cRepertoireVersion = "gi". 
        END.
        WHEN "DEV" THEN DO:
            cRepertoireVersion = "gidev". 
        END.
    END CASE.

    MESSAGE "Pour des raisons de blocage de fichier, Menudev2 va se fermer le temps de la sauvegarde, pour se rouvrir automatiquement en fin de sauvegarde."
        + CHR(10) + "Il est déconseillé de relancer Menudev2 tant que la sauvegarde n'est pas terminée."
        + CHR(10) + "Confirmez-vous la sauvegarde ?"
        VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
        TITLE "Demande de confirmation..."
        UPDATE lReponseFermeture AS LOGICAL.
    IF NOT(lReponseFermeture) THEN RETURN.

    cCommandeShell = gcRepertoireRessourcesPrivees + "\scripts\serveurs\_GI-SauvegardeVersion.bat " + cRepertoireVersion + " " + cNomDefaut + " -mx" + gDonnePreference("PREF-COMPRESSION").
    RUN ExecuteCommandeDos(cCommandeShell).

    /* Fermeture de menudev2 */
    gAddParam("FORCAGE-MAJ","TRUE").
    APPLY "CHOOSE" TO btnQuitter IN FRAME frmFond.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE SupprimeModuleActif winaide 
PROCEDURE SupprimeModuleActif :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER cIdentModule-in AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER cNomModule-in AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER m_Pere-in AS WIDGET-HANDLE.
    
    DEFINE VARIABLE m_Actif AS WIDGET-HANDLE.
    DEFINE VARIABLE iCompteur AS INTEGER NO-UNDO.

    /* recherche du module en cours dans la liste des modules actifs */
    FIND FIRST  ttModulesActifs
        WHERE   ttModulesActifs.cIdent = cIdentModule-in
        NO-ERROR.
    IF AVAILABLE(ttModulesActifs) THEN DO:
        DELETE ttModulesActifs.
    END.
    
    /* renumérotation des modules */
    
    iCompteur = 1.
    FOR EACH    ttModulesActifs
        BY ttmodulesActifs.iOrdre
        :
        ttModulesActifs.iOrdre = iCompteur.
        iCompteur = iCompteur + 1.
    END.

    /* génération du menu */
    IF VALID-HANDLE(m_ListeActifs) THEN DELETE WIDGET m_ListeActifs.

    /* Création du sous menu */
    CREATE SUB-MENU m_ListeActifs
        ASSIGN 
            PARENT = m_Pere-in 
            LABEL = "Modules actifs"
            PRIVATE-DATA = ""
            .

    FOR EACH ttModulesActifs
        BY ttModulesActifs.iordre
        :  
        CREATE MENU-ITEM m_Actif
            ASSIGN 
                PARENT = m_ListeActifs 
                LABEL = ttModulesActifs.clibelle
                PRIVATE-DATA = ttModulesActifs.cIdent
            TRIGGERS:
                ON "choose" PERSISTENT RUN ChoixModuleActif IN THIS-PROCEDURE (m_Actif:PRIVATE-DATA).
            END TRIGGERS.
    END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Terminaison winaide 
PROCEDURE Terminaison :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    /* Dernière mémorisations */
    IF gDonnePreference("PREF-DERNIER-MODULE") = "OUI" THEN gSauvePreference("DERNIER-MODULE",gcModuleEnCours).

    /* Lancement du batch de fin */
    IF gDonnePreference("PREF-EXECUTIONBATCHSORTIE") = "OUI" THEN DO:
        OS-COMMAND SILENT VALUE("""" + cFichierBatchSortie + """").
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE TicketAuto winaide 
PROCEDURE TicketAuto :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE VARIABLE cTraitement             AS CHARACTER    NO-UNDO.
DEFINE VARIABLE cRepertoireHL           AS CHARACTER    NO-UNDO INIT "\\neptune2\nfsdosg\01-Hotline".
DEFINE VARIABLE cLigne                  AS CHARACTER    NO-UNDO.
DEFINE VARIABLE cTicket                 AS CHARACTER    NO-UNDO.
DEFINE VARIABLE cReference              AS CHARACTER    NO-UNDO.
DEFINE VARIABLE cRecherche              AS CHARACTER    NO-UNDO.
DEFINE VARIABLE iPosition               AS INTEGER      NO-UNDO.
DEFINE VARIABLE cCommande               AS CHARACTER    NO-UNDO.
DEFINE VARIABLE cRetour                 AS CHARACTER    NO-UNDO.
DEFINE VARIABLE RepertoireSurveillance  AS CHARACTER    NO-UNDO.
define variable lVerbose                as logical      no-undo.
    
    /* --------------------------------- MAIN ------------------------------------- */
   
    /* aucun traitement si pas de répertoire à scanner */
    RepertoireSurveillance = gDonnePreference("PREF-DEMON_TICKETS-REPERTOIRE").
    lVerbose = (gDonnePreference("PREF-DEMON_TICKETS-VERBOSE") = "OUI").
    IF RepertoireSurveillance = "" THEN RETURN.
    
    EMPTY TEMP-TABLE ttFichiers.

    /* Balayage du répertoire de traitement */        
    INPUT STREAM stTicket FROM OS-DIR(RepertoireSurveillance) NO-ATTR-LIST.
    REPEAT:
        CREATE ttFichiers.
        IMPORT STREAM stTicket ttFichiers.
    END.
    INPUT STREAM stTicket CLOSE.
    
    /* Suppression de l'enregistrement blanc créé en plus pour le dernier fichier */
    DELETE ttFichiers.
        
    FOR EACH ttFichiers:
        IF TRIM(ttFichiers.cNomFichier) = "." OR TRIM(ttFichiers.cNomFichier) = ".." THEN NEXT.
        FILE-INFO:FILENAME = ttFichiers.cNomCompletFichier.
        IF FILE-INFO:FILE-TYPE BEGINS("D") THEN NEXT.
        IF NUM-ENTRIES(ttFichiers.cNomCompletFichier,".") < 2 THEN NEXT.
        IF ENTRY(NUM-ENTRIES(ttFichiers.cNomCompletFichier,"."),ttFichiers.cNomCompletFichier,".") <> "html" THEN NEXT.
         
        gmlog("TicketAuto - Traitement de : " + ttFichiers.cNomCompletFichier).

        /* Ouverture du fichier pour recherche des éléments */
        INPUT STREAM stTicket FROM VALUE(ttFichiers.cNomCompletFichier).
        REPEAT:
            IMPORT STREAM stTicket UNFORMATTED cLigne. 
            IF TRIM(cLigne) = "" THEN NEXT.  /* lignes blanches */
            cRecherche = "la-gi.myportal.fr/ticket/view/".
            iPosition = INDEX(cLigne,cRecherche).
            IF iPosition > 0 THEN DO:
                cTicket = SUBSTRING(cLigne,iPosition + LENGTH(cRecherche),5).
                cTicket = replace(cTicket,"#","").
            END.
            cRecherche = "account_code_display".
            iPosition = INDEX(cLigne,cRecherche).
            IF iPosition > 0 THEN DO:
                cReference = SUBSTRING(cLigne,iPosition + LENGTH(cRecherche) + 2,5).
            END.
            IF cTicket <> "" AND cReference <> "" THEN LEAVE.
        END.
        INPUT STREAM stTicket CLOSE.
        
        gmlog("TicketAuto - Reference / Ticket : " + cReference + " / " + cTicket).

        /* aucun traitement si pas de répertoire HL */
        FILE-INFO:FILENAME = cRepertoireHL.
        IF FILE-INFO:FILE-TYPE = ? THEN RETURN.

        /* Recherche du répertoire adéquat sur neptune2 */
        INPUT FROM OS-DIR(cRepertoireHL) NO-ATTR-LIST.
        REPEAT:
            IMPORT cLigne. 
            IF cLigne MATCHES "*" + cReference + "*" THEN LEAVE.
        END.       
        INPUT CLOSE.

        gmlog("Répertoire HL : " + cLigne).
        
        FILE-INFO:FILENAME = cRepertoireHL + "\" + cLigne + "\TICKETS\" + cTicket.
        IF FILE-INFO:FILE-TYPE BEGINS("D") THEN DO:
            cCommande = "start """" explorer.exe " + QUOTER(cRepertoireHL + "\" + cLigne + "\TICKETS\" + cTicket)
                        + " && " + "del " + QUOTER(ttFichiers.cNomCompletFichier)
                        + " && " + "rmdir /S /Q " + QUOTER(REPLACE(ttFichiers.cNomCompletFichier,".html","_files"))
                        .
            if lVerbose then do:
                MESSAGE "Référence trouvée : " + cReference + CHR(10)
                      + "Ticket trouvé : " + cTicket + CHR(10)
                      + "Répertoire PJ : " + cLigne + chr(10)
                      + "OK : Ouverture du répertoire"
                      VIEW-AS ALERT-BOX.
            end.
        END.
        ELSE DO:
            cCommande = "del " + QUOTER(ttFichiers.cNomCompletFichier)
                        + " && " + "rmdir /S /Q " + QUOTER(REPLACE(ttFichiers.cNomCompletFichier,".html","_files"))
                        .
            BELL.
            if lVerbose then do:
                MESSAGE "Référence trouvée : " + cReference + CHR(10)
                      + "Ticket trouvé : " + cTicket + CHR(10)
                      + "Répertoire PJ : " + cLigne + chr(10)
                      + "Répertoire inexistant"
                      VIEW-AS ALERT-BOX.
            end.
        END.
        OS-COMMAND SILENT VALUE(cCommande).
    END.        

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE TopChronoGeneral winaide 
PROCEDURE TopChronoGeneral :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE cHeure AS CHARACTER NO-UNDO.
    
    cHeure = STRING(TIME,"hh:mm").
    /* mémorisation de l'heure en cours */
   giHeure = INTEGER(REPLACE(cHeure,":","")).
     
   iCompteur5m = iCompteur5m + 1.
   IF iCompteur5m = 5 THEN DO:
       lAction5m = TRUE.
       iCompteur5m = 0.
   END.

   /* Top général */
   FOR EACH gttModules
       WHERE valid-handle(gttModules.hModule):
       ETIME(TRUE).
       gmLog("TOP général - Début traitement : " + gttModules.cIdent).
       RUN DonneOrdre(gttModules.cIdent,"TOPGENERAL",OUTPUT lRetour).
       gmLog("TOP général - Fin traitement : " + gttModules.cIdent + " (" + STRING(ETIME) + "ms)").
   END.

   RUN ControleVersionDisponible.

   IF gDonnePreference("PREF-EXECUTIONBATCHMINUTES") = "OUI" THEN 
       OS-COMMAND SILENT VALUE("""" + gcRepertoireRessourcesPrivees + "Utilisateurs\" + gcUtilisateur + "\" + gcUtilisateur + "-Minute.bat""").

   IF lAction5m THEN DO:
       IF gDonnePreference("PREF-VERIFICATIONPARTAGE") = "OUI" THEN DO:
           OS-COMMAND SILENT VALUE("""" + gcRepertoireRessourcesPrivees + "scripts\general\" + "VerifiePartage.bat""" 
                                   + " " + SESSION:TEMP-DIRECTORY + "Menudev2.log" 
                                   + " " + gDonnePreference("REPERTOIRE-BASES")
                                   + " " + gcRepertoireExecution + "VerifiePartage.p"
                                   + " " + (IF glLogActif THEN "OUI" ELSE "NON")
                                   ).
       END.
       lAction5m = FALSE.
   END.

   IF giHeure = 0 THEN DO:
       /* Actions faite chaque jour */
       gAddParam("AGENDA-RECHARGER","OUI").
       gAddParam("ABSENCES-RECHARGER","OUI").
       gAddParam("ACCUEIL-RECHARGER","OUI").
       gAddParam("ACTIVITE-RECHARGER","OUI").
       RUN DonneOrdre("Accueil","Recharge",OUTPUT lretour).
       RUN DonneOrdre("Activite","RechargeSiVisible",OUTPUT lretour).

       /* Suppression des flag d'avertissement des absences */
       /*gSupprimePreference("ABSENCES-SIGNALEES-*").*/ /* fait dans AfficheAbsences */
   END.

   IF ENTRY(2,cHeure,":") = "00" OR gDonnePreference("PREF-ABSENCES-PREVENIR-NOUVELLE-DESUITE") = "OUI" THEN DO:
       /* Actions faite chaque heure */
       RUN AfficheAbsences.
   END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE TopChronoPartiel winaide 
PROCEDURE TopChronoPartiel :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
   /* Top général */
       /*MESSAGE "Top Partiel" VIEW-AS ALERT-BOX.*/
       FOR EACH gttModules
       WHERE valid-handle(gttModules.hModule):
       RUN DonneOrdre(gttModules.cIdent,"TOPPARTIEL",OUTPUT lRetour).
   END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE VersionerVersion winaide 
PROCEDURE VersionerVersion :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER cVersion-in AS CHARACTER NO-UNDO.

    OS-COMMAND value("%reseau%dev\outils\progress\Menudev2\Ressources\Scripts\session\Lancement.bat " + cVersion-in + " %reseau%dev\outils\progress\Menudev2\Ressources\Scripts\session\LanceVersionGI.bat").
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION cFormatteEtime winaide 
FUNCTION cFormatteEtime RETURNS CHARACTER
  ( iEtimeEnCours AS INTEGER ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
    DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO.
    DEFINE VARIABLE iminutes AS INTEGER NO-UNDO.
    DEFINE VARIABLE iSecondes AS INTEGER NO-UNDO.
    
    iSecondes = iEtimeEnCours / 1000.
    iMinutes = iSecondes / 60.
    IF iMinutes < 0 THEN iMinutes = 0.
    iSecondes = iSecondes - (60 * iMinutes).
    IF isecondes < 0 THEN isecondes = 0.
    
    cRetour = STRING(iMinutes,"99") + "m, " + STRING(iSecondes,"99") + "s".
    
    RETURN cRetour.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION ChargeToolTip winaide 
FUNCTION ChargeToolTip RETURNS LOGICAL
  ( hObjet AS HANDLE,cChaine AS CHARACTER ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
DEFINE VARIABLE lSensitif AS LOGICAL NO-UNDO INIT TRUE.

    DO WITH FRAME frmFond:
        hObjet:PRIVATE-DATA = "".
        /* Décodage de la chaine */
        IF cChaine MATCHES "*#INTERDIT#*" THEN lSensitif = FALSE.
        IF cChaine MATCHES "*#DIRECT#*" THEN hObjet:PRIVATE-DATA = "DIRECT".

        /* maj du tooltip */
        cChaine = REPLACE(cChaine,"#INTERDIT#","").
        cChaine = REPLACE(cChaine,"#DIRECT#","").
        hObjet:TOOLTIP = cChaine.
    END.

  RETURN lSensitif. 


END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION ControleServeurs winaide 
FUNCTION ControleServeurs RETURNS LOGICAL
  ( cVersion-in AS CHARACTER ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
  DEFINE VARIABLE lRetour AS LOGICAL NO-UNDO INIT TRUE.
  DEFINE VARIABLE cRepertoireVersion AS CHARACTER NO-UNDO.
  DEFINE VARIABLE cRepertoireBaselib AS CHARACTER NO-UNDO.

  CASE cVersion-in:
      WHEN "PREC" OR WHEN "SUIV" THEN DO:
          cRepertoireVersion = "gi_" + cVersion-in + "\" + "gi". 
      END.
      WHEN "CLI" THEN DO:
          cRepertoireVersion = "gi". 
      END.
      WHEN "DEV" THEN DO:
          cRepertoireVersion = "gidev". 
      END.
  END CASE.
  cRepertoireBaselib = disque + cRepertoireVersion + "\baselib".

  /* Controle des serveurs actifs */
  IF SEARCH(cRepertoireBaselib + "\ladb.lk") <> ? THEN lRetour = FALSE.
  IF SEARCH(cRepertoireBaselib + "\wadb.lk") <> ? THEN lRetour = FALSE.
  IF SEARCH(cRepertoireBaselib + "\lcompta.lk") <> ? THEN lRetour = FALSE.
  IF SEARCH(cRepertoireBaselib + "\ltrans.lk") <> ? THEN lRetour = FALSE.

  IF not(lRetour) THEN DO:
      MESSAGE "Des serveurs sont encore actifs sur une ou plusieurs bases libellé !" 
          + CHR(10) + "Il faut les fermer avant de faire une Sauvegarde ou une restoration de version."
          VIEW-AS ALERT-BOX INFORMATION.
  END.

  RETURN lRetour.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION DonneImagePerso winaide 
FUNCTION DonneImagePerso RETURNS CHARACTER
  ( cNumeroBouton-in AS CHARACTER ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
    DEFINE VARIABLE cTempo AS CHARACTER NO-UNDO INIT "".
    DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO INIT "".

    cTempo = gDonnePreference("PREF-BOUTON-PERSO-" + cNumeroBouton-in + "-IMAGE").
    IF cTempo = "" THEN do:
        cRetour = gcRepertoireImages + cNumeroBouton-in + ".ico".
    END.
    ELSE DO:
        cRetour = gcRepertoireRessourcesPrivees + "Utilisateurs\" + gcUtilisateur + "\" + cTempo.
        IF SEARCH(cRetour) = ? THEN DO:
            cRetour = gcRepertoireImages + cTempo.
        END.
    END.
    RETURN cRetour. 

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION DonneVersion winaide 
FUNCTION DonneVersion RETURNS CHARACTER
  ( cVersion-in AS CHARACTER ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/

    DEFINE VARIABLE cRepertoireVersion AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cFichierVersion AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO INIT "?.?.?".
    DEFINE VARIABLE cLigne AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cVersionAvantControle AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cVersionApresControle AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cVersionBaseAvantControle AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cVersionBaseApresControle AS CHARACTER NO-UNDO.

    IF gDonnePreference("AIDE-BOUTON-MANUELLE") = "OUI" THEN DO:
        cRetour = gDonnePreference("AIDE-BOUTON-" + cVersion-in).            
        gmlog("Aide boutons manuelle pour " + cVersion-in + " : cRetour = " + cRetour).
    END.
    ELSE DO:
        gmlog("Aide boutons automatique").
        /* Lancement du batch de sauvegarde */
        CASE cVersion-in:
            WHEN "PREC" OR WHEN "SUIV" OR WHEN "SPE" THEN DO:
                cRepertoireVersion = "gi_" + cVersion-in + "\" + "gi". 
            END.
            WHEN "CLI" THEN DO:
                cRepertoireVersion = "gi". 
            END.
            WHEN "DEV" THEN DO:
                cRepertoireVersion = "gidev". 
            END.
        END CASE.
        cRepertoireVersion = disque + cRepertoireVersion.
        cFichierVersion = cRepertoireVersion + "\exe\version".
    
        /* Ouverture du fichier pour récupérer le numéro de version */
        IF SEARCH(cFichierVersion) <> ? THEN DO:
            INPUT FROM VALUE(cFichierVersion).
            REPEAT:
                IMPORT UNFORMATTED cLigne.
                IF NOT(cLigne BEGINS "Numéro") THEN NEXT.
                cRetour = ENTRY(2,cLigne,"V").
            END.
    
            /* Controler si la version de base a changé */
            cVersionAvantControle = gDonnepreference("AIDE-BOUTON-" + cVersion-in + "-SVG").
            cVersionApresControle = cRetour.
            IF NUM-ENTRIES(cVersionAvantControle,".") >= 2 AND NUM-ENTRIES(cVersionApresControle,".") >= 2 THEN DO:
                cVersionBaseAvantControle = ENTRY(2,cVersionAvantControle,".").
                cVersionBaseApresControle = ENTRY(2,cVersionApresControle,".").
                IF cVersionBaseAvantControle <> cVersionBaseApresControle THEN DO:
                    gAddParam("CHANGEMENT-STRUCTURE-" + cVersion-in,"OUI").
                END.
            END.
    
            /* Sauvegarde de la version actuelle */
            gSauvePreference("AIDE-BOUTON-" + cVersion-in + "-SVG",cRetour).
        END.
    END.
    
    RETURN cRetour.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION mLogDebug winaide 
FUNCTION mLogDebug RETURNS LOGICAL
  ( cLibelle-in AS CHARACTER, iEtime-in AS INTEGER ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
    DEFINE VARIABLE cLibelle AS CHARACTER NO-UNDO.
    
    cLibelle = "***** DEBUG ***** - " + cLibelle-in + " " + cFormatteEtime(iEtime-in).

    MLog(cLibelle).   

    RETURN TRUE.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

