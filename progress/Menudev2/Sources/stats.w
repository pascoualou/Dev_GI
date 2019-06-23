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

DEFINE BUFFER bprefs FOR prefs.

DEFINE TEMP-TABLE ttstats LIKE stats
    INDEX ix-ttstats iReference cNomProgramme
    .

DEFINE STREAM sStats.

DEFINE VARIABLE iReferenceEnCours AS INTEGER NO-UNDO INIT 0.
DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME frmModule
&Scoped-define BROWSE-NAME brwStats

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ttstats

/* Definitions for BROWSE brwStats                                      */
&Scoped-define FIELDS-IN-QUERY-brwStats ttstats.iReference ttstats.cNomProgramme ttstats.cCheminement ttstats.cUtilisateurs ttstats.iCompteur ttstats.dInitialisation ttstats.dDerniereUtilisation ttstats.dFichier ttstats.cFichier   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brwStats   
&Scoped-define TABLES-IN-QUERY-brwStats ttstats
&Scoped-define FIRST-TABLE-IN-QUERY-brwStats ttstats


/* Definitions for FRAME frmModule                                      */
&Scoped-define OPEN-BROWSERS-IN-QUERY-frmModule ~
    ~{&OPEN-QUERY-brwStats}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS cmbReferences filSuivi filRecherche ~
btnCodePrecedent btnCodeSuivant brwStats btnChargement 
&Scoped-Define DISPLAYED-OBJECTS cmbReferences filSuivi filRecherche ~
filDernierChargement 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD AfficheInformations C-Win 
FUNCTION AfficheInformations RETURNS LOGICAL
  ( cLibelle-in AS CHARACTER,iTemporisation-in AS INTEGER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE VARIABLE edtInformation AS CHARACTER INITIAL "Libelle" 
     VIEW-AS EDITOR NO-BOX
     SIZE 61 BY 1.19
     BGCOLOR 3 FGCOLOR 15 FONT 10 NO-UNDO.

DEFINE IMAGE IMAGE-1
     FILENAME "adeicon/rbuild%.ico":U
     SIZE 8 BY 1.43.

DEFINE BUTTON btnChargement 
     LABEL "(Re)Charger la base des stats" 
     SIZE 46 BY .95.

DEFINE BUTTON btnCodePrecedent 
     LABEL "<" 
     SIZE-PIXELS 20 BY 20 TOOLTIP "Rechercher le précédent".

DEFINE BUTTON btnCodeSuivant  NO-CONVERT-3D-COLORS
     LABEL ">" 
     SIZE-PIXELS 20 BY 20 TOOLTIP "Rechercher le suivant".

DEFINE VARIABLE cmbReferences AS CHARACTER FORMAT "X(256)":U 
     LABEL "Références" 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Item 1" 
     DROP-DOWN-LIST
     SIZE 18 BY 1 NO-UNDO.

DEFINE VARIABLE filDernierChargement AS CHARACTER FORMAT "X(256)":U INITIAL "Dernier chargement de la table des statistiques à partir des fichiers extraits des bases client :" 
      VIEW-AS TEXT 
     SIZE 116 BY .95 NO-UNDO.

DEFINE VARIABLE filRecherche AS CHARACTER FORMAT "X(256)":U 
     LABEL "Recherche" 
     VIEW-AS FILL-IN 
     SIZE 36 BY .95 NO-UNDO.

DEFINE VARIABLE filSuivi AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 74 BY .95 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brwStats FOR 
      ttstats SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brwStats
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brwStats C-Win _FREEFORM
  QUERY brwStats DISPLAY
      ttstats.iReference FORMAT "99999" LABEL "Référence"
      ttstats.cNomProgramme FORMAT "x(32)" LABEL "Programme"
      ttstats.cCheminement FORMAT "x(250)" LABEL "Cheminement"
      ttstats.cUtilisateurs FORMAT "x(150)" LABEL "Utilisateurs"
      ttstats.iCompteur FORMAT ">>>>9" LABEL "Compteur"
      ttstats.dInitialisation FORMAT "99/99/9999" LABEL "Date Init."
      ttstats.dDerniereUtilisation FORMAT "99/99/9999" LABEL "Date D.U."
      ttstats.dFichier FORMAT "99/99/9999" LABEL "Date Export"
      ttstats.cFichier  LABEL "Fichier Export"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 164 BY 16.67
         FONT 1 ROW-HEIGHT-CHARS .6.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME frmModule
     cmbReferences AT ROW 1.24 COL 13 COLON-ALIGNED WIDGET-ID 28
     filSuivi AT ROW 1.24 COL 33 COLON-ALIGNED NO-LABEL WIDGET-ID 36
     filRecherche AT ROW 1.24 COL 110.2 WIDGET-ID 26
     btnCodePrecedent AT Y 5 X 785 WIDGET-ID 22
     btnCodeSuivant AT Y 5 X 805 WIDGET-ID 24
     brwStats AT ROW 2.43 COL 2 WIDGET-ID 100
     btnChargement AT ROW 19.33 COL 2 WIDGET-ID 30
     filDernierChargement AT ROW 19.33 COL 50 NO-LABEL WIDGET-ID 34
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 166.2 BY 20.62
         TITLE BGCOLOR 2 FGCOLOR 15 "Statistiques MaGI".

DEFINE FRAME frmInformation
     edtInformation AT ROW 1.48 COL 13 NO-LABEL WIDGET-ID 2
     IMAGE-1 AT ROW 1.24 COL 3 WIDGET-ID 4
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS TOP-ONLY NO-UNDERLINE THREE-D 
         AT COL 46 ROW 7.67
         SIZE 76 BY 2.14
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
  NOT-VISIBLE,                                                          */
/* REPARENT FRAME */
ASSIGN FRAME frmInformation:FRAME = FRAME frmModule:HANDLE.

/* SETTINGS FOR FRAME frmInformation
                                                                        */
ASSIGN 
       FRAME frmInformation:HIDDEN           = TRUE
       FRAME frmInformation:MOVABLE          = TRUE.

ASSIGN 
       edtInformation:AUTO-RESIZE IN FRAME frmInformation      = TRUE
       edtInformation:READ-ONLY IN FRAME frmInformation        = TRUE.

/* SETTINGS FOR FRAME frmModule
   FRAME-NAME                                                           */

DEFINE VARIABLE XXTABVALXX AS LOGICAL NO-UNDO.

ASSIGN XXTABVALXX = FRAME frmInformation:MOVE-AFTER-TAB-ITEM (brwStats:HANDLE IN FRAME frmModule)
       XXTABVALXX = FRAME frmInformation:MOVE-BEFORE-TAB-ITEM (btnChargement:HANDLE IN FRAME frmModule)
/* END-ASSIGN-TABS */.

/* BROWSE-TAB brwStats btnCodeSuivant frmModule */
ASSIGN 
       brwStats:NUM-LOCKED-COLUMNS IN FRAME frmModule     = 2.

ASSIGN 
       btnCodeSuivant:AUTO-RESIZE IN FRAME frmModule      = TRUE.

/* SETTINGS FOR FILL-IN filDernierChargement IN FRAME frmModule
   NO-ENABLE ALIGN-L                                                    */
ASSIGN 
       filDernierChargement:READ-ONLY IN FRAME frmModule        = TRUE
       filDernierChargement:PRIVATE-DATA IN FRAME frmModule     = 
                "Dernier chargement de la table des statistiques à partir des fichiers extraits des bases client :".

/* SETTINGS FOR FILL-IN filRecherche IN FRAME frmModule
   ALIGN-L                                                              */
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


&Scoped-define SELF-NAME btnChargement
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnChargement C-Win
ON CHOOSE OF btnChargement IN FRAME frmModule /* (Re)Charger la base des stats */
DO:
    DEFINE VARIABLE lRetour AS LOGICAL NO-UNDO INIT TRUE.
    RUN ChargementStats(OUTPUT lRetour).
    IF NOT(lRetour) THEN RETURN NO-APPLY.
    RUN recharger.
    RUN gAfficheMessageTemporaire("Statistiques MaGI","Rechargement des statistiques terminé.",FALSE,5,"OK","MESSAGE-STATS-RECHARGEMENT",FALSE,OUTPUT cRetour).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnCodePrecedent
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnCodePrecedent C-Win
ON CHOOSE OF btnCodePrecedent IN FRAME frmModule /* < */
DO:
    DEFINE VARIABLE cRecherche AS CHARACTER NO-UNDO.

    cRecherche = "*" + filRecherche:SCREEN-VALUE + "*".

    /* Recherche en arriere */
    IF AVAILABLE(ttstats) THEN DO:
        FIND PREV   ttstats
            WHERE   ttstats.cNomProgramme MATCHES cRecherche
            NO-ERROR.
    END.
    IF NOT(AVAILABLE(ttstats)) THEN DO:
        FIND LAST   ttstats
            WHERE   ttstats.cNomProgramme MATCHES cRecherche
            NO-ERROR.
    END.
    IF AVAILABLE(ttstats) THEN DO:
        REPOSITION brwStats TO RECID RECID(ttstats).
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnCodeSuivant
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnCodeSuivant C-Win
ON CHOOSE OF btnCodeSuivant IN FRAME frmModule /* > */
DO:
    DEFINE VARIABLE cRecherche AS CHARACTER NO-UNDO.

    cRecherche = "*" + filRecherche:SCREEN-VALUE + "*".

    /* Recherche en avant */
    IF AVAILABLE(ttstats) THEN DO:
        FIND NEXT   ttstats
            WHERE   ttstats.cNomProgramme MATCHES cRecherche
            NO-ERROR.
    END.
    IF NOT(AVAILABLE(ttstats)) THEN DO:
        FIND FIRST   ttstats
            WHERE   ttstats.cNomProgramme MATCHES cRecherche
            NO-ERROR.
    END.
    IF AVAILABLE(ttstats) THEN DO:
        REPOSITION brwStats TO RECID RECID(ttstats).
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cmbReferences
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cmbReferences C-Win
ON VALUE-CHANGED OF cmbReferences IN FRAME frmModule /* Références */
DO:
  IF self:SCREEN-VALUE = "-" THEN DO:
      EMPTY TEMP-TABLE ttstats.
      iReferenceEnCours = -1.
  END.
  ELSE DO:
     iReferenceEnCours = (IF self:SCREEN-VALUE = "Toutes" THEN ? ELSE INTEGER(SELF:SCREEN-VALUE)).
  END.
  RUN Rafraichir.
  APPLY "ENTRY" TO brwStats.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filRecherche
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filRecherche C-Win
ON RETURN OF filRecherche IN FRAME frmModule /* Recherche */
DO:
  APPLY "CHOOSE" TO BtnCodeSuivant.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brwStats
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ChargementStats C-Win 
PROCEDURE ChargementStats :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE OUTPUT PARAMETER lRetour-ou AS LOGICAL NO-UNDO INIT FALSE.

    DEFINE VARIABLE cTempo AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cTempo2 AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cLigne AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cFichierStats AS CHARACTER NO-UNDO.
    DEFINE VARIABLE dDateFichier AS DATE NO-UNDO.

    /* Vérifier que le chargement n'est pas déjà en cours */
    cTempo2 = gDonnePreference("TRAVAIL-STATS-CHARGEMENT-EN-COURS").
    IF cTempo2 <> "" THEN DO:
        cTempo = "Un chargement est déjà en cours par " + cTempo2 + ".".
        RUN gAfficheMessageTemporaire("Statistiques MaGI",cTempo,FALSE,5,"OK","",FALSE,OUTPUT cRetour).
        RETURN.
    END.

    /* Demande de confirmation */
    cTempo = "Confirmez-vous le (re)chargement des statistiques MaGI".
    RUN gAfficheMessageTemporaire("Statistiques MaGI",cTempo,TRUE,5,"NON","",FALSE,OUTPUT cRetour).
    IF cRetour = "NON" THEN RETURN.

    /* Avertir que le chargement est en cours */
    gSauvePreference("TRAVAIL-STATS-CHARGEMENT-EN-COURS",gcUtilisateur).

    AfficheInformations("Vidage de la table en cours...",0).

    /* vidage de la base */
    CLOSE QUERY brwStats.
    FOR EACH statsGI:
        DELETE statsGI.
    END.

    /* Chargement à partir des fichiers */
    AfficheInformations("Chargement des fichiers en cours...",0).
    INPUT FROM OS-DIR (reseau + "dev\statsGI").
    REPEAT:
        IMPORT cFichierStats.
        IF NOT(cFichierStats BEGINS "statsGI_") THEN NEXT.
        cFichierStats = reseau + "dev\statsGI\" + cFichierStats.
        FILE-INFO:FILE-NAME = cFichierStats.
        dDateFichier = FILE-INFO:FILE-CREATE-DATE.
        INPUT STREAM sStats FROM VALUE(cFichierStats).
        REPEAT:
            CREATE statsGI.
            IMPORT STREAM sStats statsGI.
            statsGI.cFichier = cFichierStats.
            statsGI.dFichier = dDateFichier.
        END.
    END.

    /* Tout est correct : positionnement de la variable de retour */
    lRetour-ou = TRUE.

    /* Avertir que le chargement est terminé */
    gSauvePreference("TRAVAIL-STATS-CHARGEMENT-EN-COURS","").

    AfficheInformations("",0).

    /* Mise à jour de la liste */
    RUN recharger.

    /* Stockage du dernier chargement */
    gSauvePreference("TRAVAIL-STATS-DERNIER-CHARGEMENT","Le " + STRING(TODAY,"99/99/9999") + " à " + STRING(TIME,"HH:MM:SS")).


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
  DISPLAY cmbReferences filSuivi filRecherche filDernierChargement 
      WITH FRAME frmModule IN WINDOW C-Win.
  ENABLE cmbReferences filSuivi filRecherche btnCodePrecedent btnCodeSuivant 
         btnChargement 
      WITH FRAME frmModule IN WINDOW C-Win.
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
                IF gTopRechargeModule("bypass.txt") THEN RUN Recharger.
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
            WHEN "MODIFIER" THEN DO:
                RUN Modification(OUTPUT lRetour-ou).
            END.
            WHEN "RECHERCHE" THEN DO:
                APPLY "entry" TO filRecherche IN FRAME frmModule.
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
    gcAideModifier = "#" + (IF gModificationAutorisee("bypass.txt") THEN "DIRECT" ELSE "INTERDIT") + "#Modifier la liste des ByPass".
    gcAideSupprimer = "#INTERDIT#".
    gcAideImprimer = "#INTERDIT#".
    gcAideRaf = "Recharger la liste des bypass".

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
    DEFINE VARIABLE cLigne AS CHARACTER NO-UNDO.
    
    FRAME frmModule:COLUMN = gdPositionXModule.
    FRAME frmModule:ROW = gdPositionYModule.


    /* Mise a jour de la combo des references */
    DO WITH FRAME frmmodule:
        cmbReferences:LIST-ITEMS = "-,Toutes".
        FOR EACH statsGI
            BREAK BY statsGI.iReference
            :
            IF FIRST-OF(statsGI.iReference) THEN DO:
                cmbReferences:ADD-LAST(STRING(statsGI.ireference,"99999")).    
            END.
        END.
        IF iReferenceEnCours <> 0 THEN 
            cmbreferences:SCREEN-VALUE = STRING(iReferenceEnCours,"99999").
        ELSE
            cmbreferences:SCREEN-VALUE = "-".
    END.

    /* Dernier chargement */
    filDernierChargement:SCREEN-VALUE = filDernierChargement:PRIVATE-DATA + " " + gDonnePreference("TRAVAIL-STATS-DERNIER-CHARGEMENT").

    APPLY "VALUE-CHANGED" TO cmbReferences.

    /* ouverture du query */
    RUN OpenQuery.

    AfficheInformations("",0).
    RUN TopChronoGeneral.
    RUN TopChronoPartiel.
    
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
  ENABLE ALL WITH FRAME frmModule.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenQuery C-Win 
PROCEDURE OpenQuery :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    OPEN QUERY brwstats FOR EACH ttstats WHERE (iReferenceEncours = ? OR ttstats.ireference = iReferenceEncours).

    /* pour synchroniser l'ascenseur */
    DO WITH FRAME frmModule:
        QUERY brwstats:GET-LAST().
        QUERY brwstats:GET-FIRST().
        brwstats:REFRESH() NO-ERROR.
    END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Rafraichir C-Win 
PROCEDURE Rafraichir :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  DO WITH FRAME frmModule:
    FIND FIRST ttstats WHERE (ttstats.ireference = iReferenceEnCours) NO-ERROR.
    IF NOT(AVAILABLE(ttstats)) OR iReferenceEnCours = ? THEN DO:
        FOR EACH statsGI
            WHERE (statsgi.ireference = iReferenceEnCours OR iReferenceEnCours = ?)
            BREAK BY statsgi.ireference
            :
            IF FIRST-OF(statsgi.ireference) THEN filSuivi:SCREEN-VALUE = "Traitement de la référence : " + string(statsgi.ireference,"99999").
            CREATE ttstats.
            BUFFER-COPY statsgi TO ttstats.
        END.
    END.
    filSuivi:SCREEN-VALUE = "...".

    /* ouverture du query */
    RUN OpenQuery.
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE TopChronoGeneral C-Win 
PROCEDURE TopChronoGeneral :
/* Gestion du chrono général */
DEFINE VARIABLE cFichierBP AS CHARACTER NO-UNDO.

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
  ( cLibelle-in AS CHARACTER,iTemporisation-in AS INTEGER ) :
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

