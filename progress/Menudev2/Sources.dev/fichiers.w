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
{includes\i_html.i}
{menudev2\includes\menudev2.i}


/* Parameters Definitions ---                                           */

DEFINE INPUT PARAMETER  winGeneral  AS HANDLE NO-UNDO.
DEFINE INPUT PARAMETER  cParametres AS CHARACTER NO-UNDO.
/* Local Variable Definitions ---                                       */

DEFINE VARIABLE cFichier AS CHARACTER NO-UNDO INIT "".
DEFINE VARIABLE lFichierParam AS LOGICAL NO-UNDO INIT ?.
DEFINE VARIABLE lFichierVisu AS LOGICAL NO-UNDO INIT ?.


DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO.
DEFINE VARIABLE cLibelle AS CHARACTER NO-UNDO.
DEFINE VARIABLE iX AS INTEGER NO-UNDO.
DEFINE VARIABLE iY AS INTEGER NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME frmModule

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

DEFINE VARIABLE edtFichier AS CHARACTER 
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
     SIZE 163 BY 16.91
     BGCOLOR 15 FONT 0 NO-UNDO.

DEFINE VARIABLE fildernieremodification AS CHARACTER FORMAT "X(256)":U 
     LABEL "Dernière modification" 
      VIEW-AS TEXT 
     SIZE 34 BY .71 NO-UNDO.

DEFINE VARIABLE filFichier AS CHARACTER FORMAT "X(256)":U 
     LABEL "Fichier" 
     VIEW-AS FILL-IN 
     SIZE 50 BY .95 NO-UNDO.

DEFINE VARIABLE filRecherche AS CHARACTER FORMAT "X(256)":U 
     LABEL "Recherche" 
     VIEW-AS FILL-IN 
     SIZE 58 BY .95 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME frmModule
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 166 BY 20.6
         BGCOLOR 7 
         TITLE BGCOLOR 2 FGCOLOR 15 "Création/Modification d'un fichier".

DEFINE FRAME FRAME-A
     filFichier AT ROW 1.24 COL 8 COLON-ALIGNED WIDGET-ID 12
     filRecherche AT ROW 1.24 COL 87.2 WIDGET-ID 26
     btnCodePrecedent AT Y 5 X 780 WIDGET-ID 22
     btnCodeSuivant AT Y 5 X 800 WIDGET-ID 24
     edtFichier AT ROW 2.43 COL 2 NO-LABEL WIDGET-ID 8
     fildernieremodification AT ROW 19.57 COL 23 COLON-ALIGNED WIDGET-ID 14
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 165.6 BY 19.52 WIDGET-ID 100.


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
/* REPARENT FRAME */
ASSIGN FRAME FRAME-A:FRAME = FRAME frmModule:HANDLE.

/* SETTINGS FOR FRAME FRAME-A
                                                                        */
ASSIGN 
       btnCodeSuivant:AUTO-RESIZE IN FRAME FRAME-A      = TRUE.

ASSIGN 
       fildernieremodification:READ-ONLY IN FRAME FRAME-A        = TRUE.

ASSIGN 
       filFichier:READ-ONLY IN FRAME FRAME-A        = TRUE.

/* SETTINGS FOR FILL-IN filRecherche IN FRAME FRAME-A
   ALIGN-L                                                              */
/* SETTINGS FOR FRAME frmModule
   FRAME-NAME                                                           */
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


&Scoped-define FRAME-NAME FRAME-A
&Scoped-define SELF-NAME btnCodePrecedent
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnCodePrecedent C-Win
ON CHOOSE OF btnCodePrecedent IN FRAME FRAME-A /* < */
DO:
    /* Recherche en arrière avec selection et retour en fin de fichier si  debut de fichier */
    edtFichier:SEARCH(filRecherche:SCREEN-VALUE,50). 
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnCodeSuivant
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnCodeSuivant C-Win
ON CHOOSE OF btnCodeSuivant IN FRAME FRAME-A /* > */
DO:
    /* Recherche en avant avec selection et retour au debut en fin de fichier */
    edtFichier:SEARCH(filRecherche:SCREEN-VALUE,49). 
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME edtFichier
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL edtFichier C-Win
ON CTRL-A OF edtFichier IN FRAME FRAME-A
DO:
  DO WITH FRAME frmModule:
      edtfichier:SET-SELECTION(1,LENGTH(edtfichier:SCREEN-VALUE) + 100) NO-ERROR.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filRecherche
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filRecherche C-Win
ON RETURN OF filRecherche IN FRAME FRAME-A /* Recherche */
DO:
  APPLY "CHOOSE" TO BtnCodeSuivant.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frmModule
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ControlesSortie C-Win 
PROCEDURE ControlesSortie :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE lRetour AS LOGICAL INIT TRUE.
    
    /* vérifier si le fichier à été modifié */
    FIND FIRST  fichiers    NO-LOCK
        WHERE   (fichiers.cUtilisateur = gcUtilisateur OR lFichierParam)
        AND     fichiers.cIdentfichier = cFichier
        NO-ERROR.
    IF NOT(AVAILABLE(fichiers)) THEN RETURN.
    IF fichiers.texte <> edtfichier:SCREEN-VALUE IN FRAME frame-a THEN DO:
        cLibelle = "Vous avez fait des modifications sur ce fichier. Voulez-vous les sauvegarder ?".
        RUN AfficheMessageAvecTemporisation("Gestion des bases",cLibelle,TRUE,15,"NON","",FALSE,OUTPUT cRetour).
        IF cRetour = "NON" THEN do:
            /* annuler les modification */
            edtfichier:SCREEN-VALUE IN FRAME frame-a = fichiers.texte.
            RETURN.
        END.

        RUN Modification(OUTPUT lRetour).
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
  DISPLAY filFichier filRecherche edtFichier fildernieremodification 
      WITH FRAME FRAME-A IN WINDOW C-Win.
  ENABLE filFichier filRecherche btnCodePrecedent btnCodeSuivant edtFichier 
         fildernieremodification 
      WITH FRAME FRAME-A IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-FRAME-A}
  VIEW FRAME frmModule IN WINDOW C-Win.
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
                RUN Recharger.
                VIEW FRAME frmModule.
                FRAME frmModule:MOVE-TO-TOP().
            END.
            WHEN "CACHE" THEN DO:
                RUN ControlesSortie.
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
            WHEN "IMPRIME" THEN DO:
                RUN ImpressionModule.
            END.
            WHEN "AJOUTER" THEN DO:
                RUN Creation(OUTPUT lRetour-ou).
            END.
            WHEN "MODIFIER" THEN DO:
                RUN Modification(OUTPUT lRetour-ou).
            END.
            WHEN "SUPPRIMER" THEN DO:
                RUN Suppression(OUTPUT lRetour-ou).
            END.
            WHEN "RECHERCHE" THEN DO:
                APPLY "entry" TO filRecherche IN FRAME frame-a.
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
    gcAideModifier = (IF lFichierVisu THEN "#INTERDIT#" ELSE "#DIRECT#Enregistrer les modifications du fichier").
    gcAideSupprimer = "#INTERDIT#".
    gcAideImprimer = "Impression du fichier".
    gcAideRaf = "Recharger le fichier".

    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ImpressionModule C-Win 
PROCEDURE ImpressionModule :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE VARIABLE cLigne AS CHARACTER NO-UNDO.
DEFINE VARIABLE cFichierEdition AS CHARACTER NO-UNDO INIT "".
   
    DO WITH FRAME Frame-A:
    DO WITH FRAME Frame-B:
        cFichierEdition = loc_tmp + "\EditionFichier.tmp".
        edtfichier:SAVE-FILE(cFichierEdition).
        RUN ImpressionFichier(cFichierEdition,"Fichier").
    END.
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
    DEFINE VARIABLE cLigne AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cInfosFichier AS CHARACTER NO-UNDO INIT "".

    FRAME frmModule:WIDTH = gdLargeur.
    FRAME frmModule:HEIGHT = gdHauteur.
    FRAME frmModule:COLUMN = gdPositionXModule.
    FRAME frmModule:ROW = gdPositionYModule.


    /* recuperation d'un éventuel parametrage */
    cInfosFichier = DonneParametre("FICHIERS-INFOSFICHIER").
    SupprimeParametre("FICHIERS-INFOSFICHIER").

    IF cInfosFichier <> "" THEN DO:
        cFichier = ENTRY(1,cInfosFichier).
        lFichierParam = (ENTRY(2,cInfosFichier) MATCHES "*PARAM*").
        lFichierVisu = (ENTRY(2,cInfosFichier) MATCHES "*VISU*").
    END.

    filFichier:SCREEN-VALUE IN FRAME frame-A = cFichier.

    /* chargement du fichier */
    FIND FIRST  fichiers    NO-LOCK
        WHERE   (fichiers.cUtilisateur = gcUtilisateur OR lFichierParam)
        AND     fichiers.cIdentfichier = cFichier
        NO-ERROR.
    IF AVAILABLE(fichiers) THEN DO:

        fildernieremodification:SCREEN-VALUE IN FRAME frame-A = fichiers.idModification.
        edtFichier:SCREEN-VALUE IN FRAME frame-A = fichiers.texte.
    END.
    ELSE DO:
        fildernieremodification:SCREEN-VALUE IN FRAME frame-A = "".
        edtFichier:SCREEN-VALUE IN FRAME frame-A = "!!!! FICHIER INTROUVABLE !!!!".
    END.
    
    iX = c-win:X + (c-win:WIDTH-PIXELS / 2).
    iY = c-win:Y + (c-win:HEIGHT-PIXELS / 2).
    
    RUN TopChronoGeneral.

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

DEFINE VARIABLE idReference AS CHARACTER NO-UNDO.
DEFINE VARIABLE idReferenceSvg AS CHARACTER NO-UNDO.
DEFINE BUFFER bfichiers FOR fichiers.


    RUN DonneOrdre("REINIT-BOUTONS-2").
    
    DO WITH FRAME frame-A:
        /* Positionnement sur le fichier en cours */
        FIND FIRST  fichiers    EXCLUSIVE-LOCK
            WHERE   (fichiers.cUtilisateur = gcUtilisateur OR lFichierParam)
            AND     fichiers.cIdentfichier = cFichier
            NO-ERROR.
        
        IF AVAILABLE(fichiers) THEN DO:
            /* Sauvegarde du fichier en cours */
            idReference = STRING(TODAY,"99/99/9999") + "-" + STRING(TIME,"hh:mm:ss").
            idReferenceSvg = idReference + "-" + gcUtilisateur.
            CREATE bfichiers.
            BUFFER-COPY fichiers TO bfichiers.
            bfichiers.idsauvegarde = idReferenceSvg.
        
            /* report des modification dans la base */
            fichiers.texte = edtfichier:SCREEN-VALUE.
            fichiers.cModifieur = gcUtilisateur.
            fichiers.idModification = idReference.
            fildernieremodification:SCREEN-VALUE IN FRAME frame-A = fichiers.idModification.
        END.
   
        RELEASE fichiers.
        RELEASE bfichiers.
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
    ENABLE ALL WITH FRAME frmModule.
    ENABLE ALL WITH FRAME frame-A.
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE suppression C-Win 
PROCEDURE suppression :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE OUTPUT PARAMETER lRetour-ou AS LOGICAL NO-UNDO INIT TRUE.


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

