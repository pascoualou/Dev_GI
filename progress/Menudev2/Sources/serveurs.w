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
/* Local Variable Definitions ---                                       */



   DEFINE STREAM sEntree.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME frmFonction
&Scoped-define BROWSE-NAME brwBases

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES serveurs groupesServeurs

/* Definitions for BROWSE brwBases                                      */
&Scoped-define FIELDS-IN-QUERY-brwBases serveurs.cGroupeCode serveurs.cFichier   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brwBases serveurs.cFichier   
&Scoped-define ENABLED-TABLES-IN-QUERY-brwBases serveurs
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-brwBases serveurs
&Scoped-define SELF-NAME brwBases
&Scoped-define QUERY-STRING-brwBases FOR EACH serveurs NO-LOCK       WHERE serveurs.cUtilisateur = gcUtilisateur     BY serveurs.cFichier INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-brwBases OPEN QUERY {&SELF-NAME} FOR EACH serveurs NO-LOCK       WHERE serveurs.cUtilisateur = gcUtilisateur     BY serveurs.cFichier INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-brwBases serveurs
&Scoped-define FIRST-TABLE-IN-QUERY-brwBases serveurs


/* Definitions for BROWSE brwGroupes                                    */
&Scoped-define FIELDS-IN-QUERY-brwGroupes groupesServeurs.cGroupeCode groupesServeurs.cGroupeLibelle   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brwGroupes groupesServeurs.cGroupeCode   
&Scoped-define ENABLED-TABLES-IN-QUERY-brwGroupes groupesServeurs
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-brwGroupes groupesServeurs
&Scoped-define SELF-NAME brwGroupes
&Scoped-define QUERY-STRING-brwGroupes FOR EACH groupesServeurs       WHERE groupesServeurs.cUtilisateur = gcUtilisateur     BY groupesServeurs.cGroupeCode INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-brwGroupes OPEN QUERY {&SELF-NAME} FOR EACH groupesServeurs       WHERE groupesServeurs.cUtilisateur = gcUtilisateur     BY groupesServeurs.cGroupeCode INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-brwGroupes groupesServeurs
&Scoped-define FIRST-TABLE-IN-QUERY-brwGroupes groupesServeurs


/* Definitions for FRAME frmFonction                                    */
&Scoped-define OPEN-BROWSERS-IN-QUERY-frmFonction ~
    ~{&OPEN-QUERY-brwBases}~
    ~{&OPEN-QUERY-brwGroupes}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-1 brwGroupes brwBases 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 1 BY 18.57.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brwBases FOR 
      serveurs SCROLLING.

DEFINE QUERY brwGroupes FOR 
      groupesServeurs SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brwBases
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brwBases C-Win _FREEFORM
  QUERY brwBases NO-LOCK DISPLAY
      serveurs.cGroupeCode COLUMN-LABEL "Groupe" FORMAT "X(20)":U 
          serveurs.cFichier COLUMN-LABEL "Fichier" FORMAT "X(50)":U 
  ENABLE
      serveurs.cFichier
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 80 BY 14.81
         TITLE "Bases" ROW-HEIGHT-CHARS .67 FIT-LAST-COLUMN.

DEFINE BROWSE brwGroupes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brwGroupes C-Win _FREEFORM
  QUERY brwGroupes NO-LOCK DISPLAY
      groupesServeurs.cGroupeCode COLUMN-LABEL "Groupe" FORMAT "X(20)" 
      groupesServeurs.cGroupeLibelle COLUMN-LABEL "Libelle" FORMAT "X(150)"
  
      ENABLE
      groupesServeurs.cGroupeCode
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 80 BY 13.91
         TITLE "Groupes" FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME frmModule
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 166.2 BY 20.62
         BGCOLOR 7 
         TITLE BGCOLOR 2 FGCOLOR 15 "Serveurs sur bases libellé".

DEFINE FRAME frmFonction
     brwGroupes AT ROW 1.38 COL 2 WIDGET-ID 100
     brwBases AT ROW 1.43 COL 84 WIDGET-ID 200
     RECT-1 AT ROW 1.25 COL 82.5 WIDGET-ID 6
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 2 ROW 1.24
         SIZE 164 BY 19.05.


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
         MAX-HEIGHT         = 44.76
         MAX-WIDTH          = 256
         VIRTUAL-HEIGHT     = 44.76
         VIRTUAL-WIDTH      = 256
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
ASSIGN FRAME frmFonction:FRAME = FRAME frmModule:HANDLE.

/* SETTINGS FOR FRAME frmFonction
   FRAME-NAME                                                           */
/* BROWSE-TAB brwGroupes RECT-1 frmFonction */
/* BROWSE-TAB brwBases brwGroupes frmFonction */
/* SETTINGS FOR FRAME frmModule
                                                                        */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brwBases
/* Query rebuild information for BROWSE brwBases
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH serveurs NO-LOCK
      WHERE serveurs.cUtilisateur = gcUtilisateur
    BY serveurs.cFichier INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _OrdList          = "menudev2.Prefs.cValeur|yes"
     _Where[1]         = "menudev2.Prefs.cUtilisateur = gcUtilisateur
 AND menudev2.Prefs.cCode = ""TEL_PERSO"""
     _Query            is OPENED
*/  /* BROWSE brwBases */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brwGroupes
/* Query rebuild information for BROWSE brwGroupes
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH groupesServeurs
      WHERE groupesServeurs.cUtilisateur = gcUtilisateur
    BY groupesServeurs.cGroupeCode INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _OrdList          = "menudev2.Prefs.cValeur|yes"
     _Where[1]         = "menudev2.Prefs.cUtilisateur = ""ADMIN""
 AND menudev2.Prefs.cCode = ""TEL_GI"""
     _Query            is OPENED
*/  /* BROWSE brwGroupes */
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


&Scoped-define BROWSE-NAME brwBases
&Scoped-define SELF-NAME brwBases
&Scoped-define BROWSE-NAME brwGroupes
&Scoped-define SELF-NAME brwGroupes
&Scoped-define BROWSE-NAME brwBases
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Abandon C-Win 
PROCEDURE Abandon :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

DEFINE OUTPUT PARAMETER lRetour-ou AS LOGICAL NO-UNDO.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE AjouteServeur C-Win 
PROCEDURE AjouteServeur :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER cCodeGroupe-in   AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER cLibelleGroupe-in   AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER cFichier-in   AS CHARACTER NO-UNDO.


    /* on commence par chercher si le groupe existe déjà */
    FIND FIRST  GroupesServeurs   NO-LOCK
        WHERE   GroupesServeurs.cUtilisateur = gcUtilisateur
        AND     GroupesServeurs.cGroupeCode = cCodeGroupe-in
        NO-ERROR.
    IF NOT(AVAILABLE(GroupesServeurs)) THEN DO:
        /* il faut le creer */
        CREATE GroupesServeurs.
        ASSIGN
            GroupesServeurs.cUtilisateur = gcUtilisateur
            GroupesServeurs.cGroupeCode = cCodeGroupe-in
            GroupesServeurs.cGroupeLibelle = cLibelleGroupe-in
            .
    END.

    /* de même pour le serveur */
    FIND FIRST  Serveurs   NO-LOCK
        WHERE   Serveurs.cUtilisateur = gcUtilisateur
        AND     Serveurs.cGroupeCode = cCodeGroupe-in
        AND     Serveurs.cFichier = cFichier-in
        NO-ERROR.
    IF NOT(AVAILABLE(Serveurs)) THEN DO:
        /* il faut le creer */
        CREATE Serveurs.
        ASSIGN
            Serveurs.cUtilisateur = gcUtilisateur
            Serveurs.cGroupeCode = cCodeGroupe-in
            Serveurs.cFichier = cFichier-in
            .
    END.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Creation C-Win 
PROCEDURE Creation :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

DEFINE OUTPUT PARAMETER lRetour-ou AS LOGICAL NO-UNDO.


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
  VIEW FRAME frmModule IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-frmModule}
  ENABLE RECT-1 brwGroupes brwBases 
      WITH FRAME frmFonction IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-frmFonction}
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
            WHEN "MODIFIER" THEN DO:
                RUN Modification(OUTPUT lRetour-ou).
            END.
            WHEN "AJOUTER" THEN DO:
                RUN Creation(OUTPUT lRetour-ou).
            END.
            WHEN "SUPPRIMER" THEN DO:
                RUN Suppression(OUTPUT lRetour-ou).
            END.
            WHEN "VALIDATION" THEN DO:
                RUN Validation(OUTPUT lRetour-ou).
            END.
            WHEN "ABANDON" THEN DO:
                RUN Abandon(OUTPUT lRetour-ou).
            END.
            WHEN "RECHARGE" THEN DO:
                RUN Recharger.
            END.
        END CASE. /* fin du case */
    END. /* fin du do iboucle */

    RUN gereboutons.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Fermeture C-Win 
PROCEDURE Fermeture :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE OUTPUT PARAMETER lRetour-ou AS LOGICAL INIT FALSE.


    lRetour-ou = TRUE.

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
    gcAideRaf = "Recharger la liste".

 
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE GereEtat C-Win 
PROCEDURE GereEtat :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER cEtat-in AS CHARACTER.

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
   DEFINE VARIABLE cFichier AS CHARACTER NO-UNDO.
   DEFINE VARIABLE cLigne AS CHARACTER NO-UNDO.
   DEFINE VARIABLE lBaseLib AS LOGICAL NO-UNDO INIT FALSE.
   DEFINE VARIABLE cGroupe AS CHARACTER NO-UNDO.
    
    FRAME frmModule:COLUMN = gdPositionXModule.
    FRAME frmModule:ROW = gdPositionYModule.

    /* initialisation de la base avec le contenu du fichier base.log */
    FIND FIRST  GroupesServeurs   NO-LOCK
        WHERE   GroupesServeurs.cUtilisateur = gcUtilisateur
        NO-ERROR.
    IF NOT(AVAILABLE(GroupesServeurs)) THEN DO:
        cFichier = "c:\pfgi\bases.log".
        IF SEARCH(cFichier) <> ? THEN DO:
            INPUT STREAM sEntree FROM VALUE(cFichier).
            REPEAT:
                IMPORT STREAM sEntree UNFORMATTED cLigne.
                IF TRIM(cLigne) = "" THEN NEXT.
                IF cLigne BEGINS("#") THEN NEXT.

                /* s'agit-il d'une base libelle ? */
                lBaselib = (lBaselib OR cLigne MATCHES("*ladb*")).
                lBaselib = (lBaselib OR cLigne MATCHES("*lcompta*")).
                lBaselib = (lBaselib OR cLigne MATCHES("*ltrans*")).
                lBaselib = (lBaselib OR cLigne MATCHES("*wadb*")).
                IF NOT(lBaseLib) THEN NEXT.
                
                /* Sur quel environnement */
                IF cLigne MATCHES("*\gi_PREC\*") THEN
                    RUN AjouteServeur("PREC","Serveurs sur baselib version N-1",cLigne).
                ELSE IF cLigne MATCHES("*\gi_SUIV\*") THEN
                    RUN AjouteServeur("SUIV","Serveurs sur baselib version N+1",cLigne).
                ELSE IF cLigne MATCHES("*\gi\*") THEN
                    RUN AjouteServeur("CLIENT","Serveurs sur baselib version client",cLigne).
                ELSE IF cLigne MATCHES("*\gidev\*") THEN
                    RUN AjouteServeur("DEV","Serveurs sur baselib version développement",cLigne).
                ELSE 
                    RUN AjouteServeur("DIVERS","Autres serveurs",cLigne).
            END.
            INPUT STREAM sEntree CLOSE.
        END.
    END.

    /* Ouverture du query sur les groupes et les serveurs */
    {&OPEN-QUERY-brwGroupes}
    {&OPEN-QUERY-brwBases}

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
    {&OPEN-BROWSERS-IN-QUERY-frmFonction}
    HIDE c-win.
  ENABLE ALL WITH FRAME frmFonction.
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Suppression C-Win 
PROCEDURE Suppression :
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Validation C-Win 
PROCEDURE Validation :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

DEFINE OUTPUT PARAMETER lRetour-ou AS LOGICAL NO-UNDO INIT TRUE.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

