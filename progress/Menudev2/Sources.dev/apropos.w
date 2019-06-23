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
{menudev2\includes\menudev2.i}

    /* Parameters Definitions ---                                           */

DEFINE INPUT PARAMETER  winGeneral  AS HANDLE NO-UNDO.
DEFINE INPUT PARAMETER  cParametres AS CHARACTER NO-UNDO.
/* Local Variable Definitions ---                                       */


DEFINE STREAM sEntree.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME frmModule

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS filRecherche btnCodePrecedent btnCodeSuivant ~
edtnotes cmbDocumentations btnVoir 
&Scoped-Define DISPLAYED-OBJECTS filRecherche edtnotes cmbDocumentations 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON btnCodePrecedent 
     LABEL "<" 
     SIZE-PIXELS 20 BY 20 TOOLTIP "Rechercher le précédent".

DEFINE BUTTON btnCodeSuivant  NO-CONVERT-3D-COLORS
     LABEL ">" 
     SIZE-PIXELS 20 BY 20 TOOLTIP "Rechercher le suivant".

DEFINE BUTTON btnVoir 
     LABEL "Voir la documentation de la version" 
     SIZE 41 BY 1.

DEFINE VARIABLE cmbDocumentations AS CHARACTER FORMAT "X(256)":U 
     LABEL "Liste des documentations des versions" 
     VIEW-AS COMBO-BOX SORT INNER-LINES 5
     LIST-ITEMS "Item 1" 
     DROP-DOWN-LIST
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE edtnotes AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 164 BY 15.71
     BGCOLOR 15 FONT 0 NO-UNDO.

DEFINE VARIABLE filRecherche AS CHARACTER FORMAT "X(256)":U 
     LABEL "Recherche" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 58 BY .95 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME frmModule
     filRecherche AT ROW 1.24 COL 88.2 WIDGET-ID 34
     btnCodePrecedent AT Y 5 X 785 WIDGET-ID 28
     btnCodeSuivant AT Y 5 X 805 WIDGET-ID 30
     edtnotes AT ROW 2.43 COL 2 NO-LABEL WIDGET-ID 32
     cmbDocumentations AT ROW 18.86 COL 40 COLON-ALIGNED WIDGET-ID 36
     btnVoir AT ROW 18.86 COL 53 WIDGET-ID 38
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 166 BY 20.6
         TITLE BGCOLOR 2 FGCOLOR 15 "A propos de menudev2 (Informations environnement, session et version)".


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
         HEIGHT             = 20.67
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
/* SETTINGS FOR FRAME frmModule
   FRAME-NAME                                                           */
ASSIGN 
       btnCodeSuivant:AUTO-RESIZE IN FRAME frmModule      = TRUE.

ASSIGN 
       edtnotes:READ-ONLY IN FRAME frmModule        = TRUE.

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


&Scoped-define SELF-NAME btnCodePrecedent
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnCodePrecedent C-Win
ON CHOOSE OF btnCodePrecedent IN FRAME frmModule /* < */
DO:
    /* Recherche en arrière avec selection et retour en fin de fichier si  debut de fichier */
    edtNotes:SEARCH(filRecherche:SCREEN-VALUE,50) in frame frmModule. 
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnCodeSuivant
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnCodeSuivant C-Win
ON CHOOSE OF btnCodeSuivant IN FRAME frmModule /* > */
DO:
    /* Recherche en avant avec selection et retour au debut en fin de fichier */
    edtNotes:SEARCH(filRecherche:SCREEN-VALUE,49) in frame frmModule. 
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnVoir
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnVoir C-Win
ON CHOOSE OF btnVoir IN FRAME frmModule /* Voir la documentation de la version */
DO:
  OS-COMMAND NO-WAIT VALUE(gcRepertoireRessourcesPrivees + "\majs\" + cmbDocumentations:SCREEN-VALUE + "\" + cmbDocumentations:SCREEN-VALUE + ".pdf").
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
  RUN ENABLE_UI.
  RUN MYenable_UI.
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
  DISPLAY filRecherche edtnotes cmbDocumentations 
      WITH FRAME frmModule IN WINDOW C-Win.
  ENABLE filRecherche btnCodePrecedent btnCodeSuivant edtnotes 
         cmbDocumentations btnVoir 
      WITH FRAME frmModule IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-frmModule}
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
    gcAideModifier = "#INTERDIT#".
    gcAideSupprimer = "#INTERDIT#".
    gcAideImprimer = "#INTERDIT#".
    gcAideRaf = "Recharger les informations".

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

    DEFINE VARIABLE cRepertoire AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cNomComplet AS CHARACTER NO-UNDO.
    DEFINE VARIABLE itempo AS INTEGER NO-UNDO.

    FRAME frmModule:WIDTH = gdLargeur.
    FRAME frmModule:HEIGHT = gdHauteur.
    FRAME frmModule:COLUMN = gdPositionXModule.
    FRAME frmModule:ROW = gdPositionYModule.

    cFichierInfos = gcRepertoireRessourcesPrivees + "Utilisateurs\" + gcUtilisateur + "\session.txt".

    /* Infos */
    EcritLigne("#VIDE#",1).
    EcritTitre("Environnement :",1).
    AjouteRetireTabulation(1).
        EcritLigne("VERSION = " + string(giVersionUtilisateur,"999"),1).
        EcritLigne("DEVUSR = " + gcUtilisateur,1).
        EcritLigne("TEMP = " + OS-GETENV("TEMP"),1).
        EcritLigne("TMP = " + OS-GETENV("TMP"),1).
        EcritLigne("DISQUE = " + OS-GETENV("DISQUE"),1).
        EcritLigne("DISQUE-WEB = " + OS-GETENV("DISQUE-WEB"),1).
        EcritLigne("RESEAU = " + OS-GETENV("RESEAU"),1).
        EcritLigne("RESEAUBIS = " + (IF OS-GETENV("RESEAUBIS") <> ? THEN OS-GETENV("RESEAUBIS") ELSE ""),1).
        EcritLigne("PROVERSION = " + PROVERSION,1).
        EcritLigne("DLC = " + OS-GETENV("DLC"),1).
        EcritLigne("DLC_V10 = " + OS-GETENV("DLC_V10"),1).
        EcritLigne("DLC_V11 = " + OS-GETENV("DLC_V11"),1).
        EcritLigne("PROWIN = " + OS-GETENV("PROWIN"),1).
        EcritLigne("PROPATH = " + OS-GETENV("PROPATH"),1).
        EcritLigne("PROPATH-SPECIFIQUE = " + OS-GETENV("PROPATH-SPECIFIQUE"),1).
        EcritLigne("PROBUILD = " + OS-GETENV("PROBUILD"),1).
        EcritLigne("PROMSGS = " + OS-GETENV("PROMSGS"),1).
        EcritLigne("REPGI = " + OS-GETENV("REPGI"),1).
        EcritLigne("PATH = " + OS-GETENV("PATH"),1).
        EcritLigne("PROFILE_BLAT = " + (IF OS-GETENV("PROFILE_BLAT") <> ? THEN OS-GETENV("PROFILE_BLAT") ELSE ""),1).
        EcritLigne("VERSION_OE = " + OS-GETENV("VERSION_OE"),1).
        EcritLigne("SUFFIXE = " + OS-GETENV("SUFFIXE"),1).
        EcritLigne("VERBOSE = " + OS-GETENV("VERBOSE"),1).
    AjouteRetireTabulation(-1).
    
    RUN DechargeVariables("").
    
    /* Chargement du fichier */
    edtnotes:read-file(cFichierInfos).

    OS-DELETE VALUE(cFichierInfos).

    /* Chargement des documentations */
    cmbDocumentations:LIST-ITEMS = "".
    INPUT STREAM sEntree FROM OS-DIR(gcRepertoireRessourcesPrivees + "\majs") NO-ATTR-LIST.
    REPEAT:
        IMPORT STREAM sEntree cRepertoire cNomComplet.  
        IF cRepertoire = "." OR cRepertoire = ".." THEN NEXT.
        iTempo = INTEGER(cRepertoire) NO-ERROR.
        IF ERROR-STATUS:ERROR THEN NEXT.
        IF iTempo = 0 OR iTempo = 999 THEN NEXT.
        cmbDocumentations:ADD-LAST(cRepertoire).
    END.
    INPUT CLOSE.

    /* Positionnement sur la dernière version disponible */
    cmbDocumentations:SCREEN-VALUE = ENTRY(NUM-ENTRIES(cmbDocumentations:LIST-ITEMS),cmbDocumentations:LIST-ITEMS).
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
   

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE TopChronoPartiel C-Win 
PROCEDURE TopChronoPartiel :
/* Gestion du chrono Partiel */


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

