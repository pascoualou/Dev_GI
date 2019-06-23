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

&SCOPED-DEFINE Tabulation 4

/* Parameters Definitions ---                                           */

DEFINE INPUT PARAMETER  winGeneral  AS HANDLE NO-UNDO.
DEFINE INPUT PARAMETER  cParametres AS CHARACTER NO-UNDO.
/* Local Variable Definitions ---                                       */

DEFINE VARIABLE cFichierSession AS CHARACTER NO-UNDO.
DEFINE VARIABLE iTabulation AS INTEGER NO-UNDO INIT 0.
DEFINE STREAM sSession.

DEFINE TEMP-TABLE ttLignes
    FIELD cLigne AS CHARACTER
    .

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
edtnotes 
&Scoped-Define DISPLAYED-OBJECTS filRecherche edtnotes 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD DecoupeLigne C-Win 
FUNCTION DecoupeLigne RETURNS INTEGER
  ( cLigne-in AS CHARACTER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD Ligne C-Win 
FUNCTION Ligne RETURNS logical
    (cInformation-in AS CHARACTER, iSautLigne-in AS INTEGER)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD Tabulation C-Win 
FUNCTION Tabulation RETURNS LOGICAL
  ( iNombre-in AS INTEGER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD Titre C-Win 
FUNCTION Titre RETURNS LOGICAL
    (cInformation-in AS CHARACTER, iSautLigne-in AS INTEGER)  FORWARD.

/* _UIB-CODE-BLOCK-END */
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

DEFINE VARIABLE edtnotes AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 164 BY 17.86
     BGCOLOR 15 FONT 0 NO-UNDO.

DEFINE VARIABLE filRecherche AS CHARACTER FORMAT "X(256)":U 
     LABEL "Recherche" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 58 BY .95 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME frmModule
     filRecherche AT ROW 1.24 COL 88.2 WIDGET-ID 26
     btnCodePrecedent AT Y 5 X 785 WIDGET-ID 22
     btnCodeSuivant AT Y 5 X 805 WIDGET-ID 24
     edtnotes AT ROW 2.43 COL 2 NO-LABEL WIDGET-ID 2
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 166 BY 20.6
         TITLE BGCOLOR 2 FGCOLOR 15 "Information de session".


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
  DISPLAY filRecherche edtnotes 
      WITH FRAME frmModule IN WINDOW C-Win.
  ENABLE filRecherche btnCodePrecedent btnCodeSuivant edtnotes 
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
    gcAideRaf = "Recharger le module".

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

    cFichierSession = gcRepertoireRessourcesPrivees + "Utilisateurs\" + gcUtilisateur + "\session.txt".

    /* Infos */
    Ligne("#VIDE#",1).
    Titre("Environnement :",1).
    Tabulation(1).
    Ligne("VERSION = " + string(giVersionUtilisateur,"999"),1).
    Ligne("DEVUSR = " + gcUtilisateur,1).
    Ligne("DISQUE = " + OS-GETENV("DISQUE"),1).
    Ligne("RESEAU = " + OS-GETENV("RESEAU"),1).
    Ligne("RESEAUBIS = " + (IF OS-GETENV("RESEAUBIS") <> ? THEN OS-GETENV("RESEAUBIS") ELSE ""),1).
    Ligne("PROVERSION = " + PROVERSION,1).
    Ligne("DLC = " + OS-GETENV("DLC"),1).
    Ligne("PROPATH = " + OS-GETENV("PROPATH"),1).
    Ligne("REPGI = " + OS-GETENV("REPGI"),1).
    Ligne("PATH = " + OS-GETENV("PATH"),1).
    Ligne("PROFILE_BLAT = " + (IF OS-GETENV("PROFILE_BLAT") <> ? THEN OS-GETENV("PROFILE_BLAT") ELSE ""),1).
    Tabulation(-1).
                                                                                                     /* Chargement du fichier */
    edtnotes:read-file(cFichierSession).

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

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION DecoupeLigne C-Win 
FUNCTION DecoupeLigne RETURNS INTEGER
  ( cLigne-in AS CHARACTER ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
    DEFINE VARIABLE iRetour AS INTEGER NO-UNDO INIT 0.
    DEFINE VARIABLE iMax AS INTEGER NO-UNDO.
    DEFINE VARIABLE cTempo AS CHARACTER NO-UNDO.

    iMax = 113 - (iTabulation * {&Tabulation}).

    EMPTY TEMP-TABLE ttLignes.
    cTempo = cLigne-in.
    REPEAT:
        IF LENGTH(cTempo) <= iMax THEN LEAVE.
        CREATE ttLignes.
        ttLignes.cLigne = SUBSTRING(cTempo,1,iMax).
        cTempo = SUBSTRING(cTempo,iMax + 1).
        iRetour = iRetour + 1.
    END.
    CREATE ttLignes.
    ttLignes.cLigne = cTempo.
    iRetour = iRetour + 1.
    
    RETURN iRetour.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION Ligne C-Win 
FUNCTION Ligne RETURNS logical
    (cInformation-in AS CHARACTER, iSautLigne-in AS INTEGER) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
    DEFINE VARIABLE cTabulation AS CHARACTER NO-UNDO.
    DEFINE VARIABLE iNombreLignes AS INTEGER NO-UNDO.

    IF iTabulation > 0 THEN cTabulation = FILL(" ",iTabulation * {&Tabulation}).

    IF cInformation-in = "#VIDE#" THEN DO:
        OUTPUT STREAM sSession TO value(cFichierSession).
    END.
    ELSE DO:
        iNombreLignes = DecoupeLigne(cInformation-in).
        OUTPUT STREAM sSession TO value(cFichierSession) APPEND.
        FOR EACH ttLignes:
            PUT STREAM sSession UNFORMATTED cTabulation + ttLignes.cLigne SKIP.
        END.
        IF iSautLigne-in > 1 THEN DO:
            PUT STREAM sSession UNFORMATTED " " SKIP(iSautLigne-in - 1).    
        END.
    END.
    OUTPUT STREAM sSession CLOSE.

    RETURN TRUE.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION Tabulation C-Win 
FUNCTION Tabulation RETURNS LOGICAL
  ( iNombre-in AS INTEGER ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
    iTabulation = iTabulation + iNombre-in.
    IF iTabulation < 0 THEN iTabulation = 0.

  RETURN TRUE.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION Titre C-Win 
FUNCTION Titre RETURNS LOGICAL
    (cInformation-in AS CHARACTER, iSautLigne-in AS INTEGER) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/

    DO WITH FRAME frmModule:
        Ligne(cInformation-in,1).
        Ligne(FILL("-",LENGTH(cInformation-in)),iSautLigne-in).
    END.

    RETURN TRUE.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

