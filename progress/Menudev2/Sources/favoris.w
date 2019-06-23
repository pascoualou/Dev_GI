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

DEFINE BUFFER bprefs FOR prefs.


DEFINE VARIABLE hpers AS HANDLE.


DEFINE VARIABLE iRowInit AS DECIMAL INIT 1.25.

DEFINE VARIABLE iEcartLigne AS DECIMAL   NO-UNDO INIT 1.1 .
DEFINE VARIABLE iEcartColonne AS INTEGER   NO-UNDO INIT 39 .
    DEFINE VARIABLE cFichierFavoris AS CHARACTER NO-UNDO.


DEFINE TEMP-TABLE tttempo
    FIELD ctempo AS CHARACTER
    FIELD itempo AS INTEGER
    INDEX ix_prim itempo
    .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME FRAME-A

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.

/* Definitions of handles for OCX Containers                            */
DEFINE VARIABLE CtrlFrame-2 AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chCtrlFrame-2 AS COMPONENT-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON bntRetour 
     LABEL "<" 
     SIZE 6 BY 2.62 TOOLTIP "Page précédente".

DEFINE BUTTON btnAvance 
     LABEL ">" 
     SIZE 6 BY 2.62 TOOLTIP "Page suivante".

DEFINE BUTTON BTnEdit 
     LABEL "><" 
     SIZE 4 BY 8.1 TOOLTIP ">< = boutons fixes, <> = boutons déplaçables".

DEFINE BUTTON btnHome 
     LABEL "><" 
     SIZE 6 BY 2.62 TOOLTIP "Retour à la page initiale".

DEFINE BUTTON btnmaj 
     LABEL "¤" 
     SIZE 6 BY 3.62 TOOLTIP "Rafraichir".


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME frmModule
     BTnEdit AT ROW 1 COL 162 WIDGET-ID 4
     btnHome AT ROW 9.1 COL 1 WIDGET-ID 6
     bntRetour AT ROW 11.71 COL 1 WIDGET-ID 8
     btnAvance AT ROW 14.33 COL 1 WIDGET-ID 10
     btnmaj AT ROW 16.95 COL 1 WIDGET-ID 12
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 166 BY 20.76
         BGCOLOR 7 
         TITLE BGCOLOR 2 FGCOLOR 15 "Boutons favoris (Clique droit sur un bouton pour le retirer des favoris)".

DEFINE FRAME frmBoutons
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 161 BY 8.1
         FONT 8.

DEFINE FRAME FRAME-A
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 7 ROW 9.1
         SIZE 159 BY 11.67
         BGCOLOR 7 
         TITLE BGCOLOR 2 FGCOLOR 15 "Mes Raccourcis" WIDGET-ID 100.


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
         TITLE              = "Raccourcis"
         HEIGHT             = 20.76
         WIDTH              = 166
         MAX-HEIGHT         = 35.76
         MAX-WIDTH          = 190
         VIRTUAL-HEIGHT     = 35.76
         VIRTUAL-WIDTH      = 190
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
ASSIGN FRAME FRAME-A:FRAME = FRAME frmModule:HANDLE
       FRAME frmBoutons:FRAME = FRAME frmModule:HANDLE.

/* SETTINGS FOR FRAME FRAME-A
   FRAME-NAME                                                           */
/* SETTINGS FOR FRAME frmBoutons
                                                                        */
/* SETTINGS FOR FRAME frmModule
                                                                        */

DEFINE VARIABLE XXTABVALXX AS LOGICAL NO-UNDO.

ASSIGN XXTABVALXX = FRAME frmBoutons:MOVE-BEFORE-TAB-ITEM (BTnEdit:HANDLE IN FRAME frmModule)
       XXTABVALXX = FRAME FRAME-A:MOVE-AFTER-TAB-ITEM (btnHome:HANDLE IN FRAME frmModule)
       XXTABVALXX = FRAME FRAME-A:MOVE-BEFORE-TAB-ITEM (bntRetour:HANDLE IN FRAME frmModule)
/* END-ASSIGN-TABS */.

IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

CREATE CONTROL-FRAME CtrlFrame-2 ASSIGN
       FRAME           = FRAME FRAME-A:HANDLE
       ROW             = 1
       COLUMN          = 1
       HEIGHT          = 10.48
       WIDTH           = 158
       WIDGET-ID       = 6
       HIDDEN          = no
       SENSITIVE       = yes.
/* CtrlFrame-2 OCXINFO:CREATE-CONTROL from: {8856F961-340A-11D0-A96B-00C04FD705A2} type: WebBrowser */

&ENDIF

&ANALYZE-RESUME /* End of _CREATE-DYNAMIC */


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON END-ERROR OF C-Win /* Raccourcis */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON WINDOW-CLOSE OF C-Win /* Raccourcis */
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frmModule
&Scoped-define SELF-NAME bntRetour
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bntRetour C-Win
ON CHOOSE OF bntRetour IN FRAME frmModule /* < */
DO:
  chCtrlFrame-2:WebBrowser:goback() NO-ERROR.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnAvance
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnAvance C-Win
ON CHOOSE OF btnAvance IN FRAME frmModule /* > */
DO:
  chCtrlFrame-2:WebBrowser:goforward() NO-ERROR.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BTnEdit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BTnEdit C-Win
ON CHOOSE OF BTnEdit IN FRAME frmModule /* >< */
DO:
    btnEdit:LABEL = (IF btnEdit:LABEL = "><" THEN "<>" ELSE "><").
    RUN Recharger.                                                                
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnHome
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnHome C-Win
ON CHOOSE OF btnHome IN FRAME frmModule /* >< */
DO:
  chCtrlFrame-2:WebBrowser:Navigate(gcRepertoireRessourcesPrivees + "Utilisateurs\" + gcUtilisateur + "\Favoris")  NO-ERROR.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnmaj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnmaj C-Win
ON CHOOSE OF btnmaj IN FRAME frmModule /* ¤ */
DO:
  chCtrlFrame-2:WebBrowser:REFRESH() NO-ERROR.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME FRAME-A
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ChoixBouton C-Win 
PROCEDURE ChoixBouton :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER hBouton AS HANDLE NO-UNDO.

    DEFINE VARIABLE cCommande   AS CHARACTER NO-UNDO.
    DEFINE VARIABLE iBoucle AS INTEGER NO-UNDO.
    DEFINE VARIABLE cParametres AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cSilence AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cValeursDefaut AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cReponse AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cMessage AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cLigne AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lBatch AS LOGICAL NO-UNDO INIT FALSE.
    DEFINE VARIABLE cValeur AS CHARACTER NO-UNDO.

    IF hBouton:PRIVATE-DATA = "" THEN RETURN.
    
        /* Informations sur le bouton */
    IF SEARCH(gcRepertoireRessourcesPrivees + hBouton:LABEL + ".txt") <> ? THEN DO:
        /* Affichage des information */
        INPUT FROM VALUE(gcRepertoireRessourcesPrivees + hBouton:LABEL + ".txt").
        REPEAT:
            IMPORT UNFORMATTED cLigne.
            cMessage = cMessage + CHR(10) + cLigne.
        END.
        MESSAGE cMessage VIEW-AS ALERT-BOX INFORMATION
            TITLE "Informations sur l'action demandée..."
            .
    END.

    /* Récupération de la commande du bouton */
    cCommande = entry(1,hBouton:PRIVATE-DATA,"§").

    cCommande = gRemplaceVariables(cCommande,"*",?,0).

    /*
    IF PROVERS MATCHES "*10*" THEN DO:
        cCommande = REPLACE(cCommande,"outilsgi","outilsgi-v10").
        cCommande = REPLACE(cCommande,"outilsg2","outilsg2-v10").
        cCommande = REPLACE(cCommande,"outilsg3","outilsg3-v10").
    END.
    */

    IF cCommande BEGINS "#BAT#" THEN DO:
        cCommande = REPLACE(cCommande,"#BAT#","").
        lBatch = TRUE.
    END.
    
    /* Gestion des paramètres */
    cParametres = entry(2,hBouton:PRIVATE-DATA,"§").
    cSilence = entry(3,hBouton:PRIVATE-DATA,"§").
    cValeursDefaut = entry(4,hBouton:PRIVATE-DATA,"§").
    RUN DonnePositionMessage IN ghGeneral.
    DO iBoucle = 1 TO 9:
        IF cCommande MATCHES "*%" + STRING(iBoucle) + "*" THEN DO:
            cReponse = "".
            cReponse = ENTRY(iboucle,cValeursDefaut,";").
		    gcAllerRetour = STRING(giPosXMessage)
		        + "|" + STRING(giPosYMessage)
                + "|" + ENTRY(iboucle,cParametres,";")
                + "|" + cReponse.
            RUN VALUE(gcRepertoireExecution + "saisie2.w") (INPUT-OUTPUT gcAllerRetour).
            IF gcAllerRetour = "" THEN RETURN.
            cValeur = ENTRY(4,gcAllerRetour,"|").
            /* Ajout de l'extension et du préfixe en automatique si nécessaire */
            IF cReponse MATCHES ("*.pf") AND NOT(cValeur MATCHES ("*.pf")) THEN cValeur = cValeur + ".pf".
            IF cReponse BEGINS ("cnx") AND NOT(cValeur BEGINS ("cnx")) THEN cValeur = "cnx" + cValeur.
            cCommande = REPLACE(cCommande,"%" + STRING(iBoucle),ENTRY(4,gcAllerRetour,"|")).      
         END.
    END.
    
    gMlog("Lancement de la commande : " + cCommande).
    IF lBatch THEN 
        OS-COMMAND VALUE(cCommande).
    ELSE
        OS-COMMAND NO-WAIT  VALUE(cCommande).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control_load C-Win  _CONTROL-LOAD
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

OCXFile = SEARCH( "favoris.wrx":U ).
IF OCXFile = ? THEN
  OCXFile = SEARCH(SUBSTRING(THIS-PROCEDURE:FILE-NAME, 1,
                     R-INDEX(THIS-PROCEDURE:FILE-NAME, ".":U), "CHARACTER":U) + "wrx":U).

IF OCXFile <> ? THEN
DO:
  ASSIGN
    chCtrlFrame-2 = CtrlFrame-2:COM-HANDLE
    UIB_S = chCtrlFrame-2:LoadControls( OCXFile, "CtrlFrame-2":U)
    CtrlFrame-2:NAME = "CtrlFrame-2":U
  .
  RUN initialize-controls IN THIS-PROCEDURE NO-ERROR.
END.
ELSE MESSAGE "favoris.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE DeplaceBouton C-Win 
PROCEDURE DeplaceBouton :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

DEFINE INPUT PARAMETER hBouton AS HANDLE NO-UNDO.

    DEFINE VARIABLE iBoucle AS INTEGER NO-UNDO.
    DEFINE VARIABLE iMaxCol AS INTEGER NO-UNDO.
    DEFINE VARIABLE iMaxColx AS INTEGER NO-UNDO.
    DEFINE VARIABLE iColonneNouvelle AS INTEGER NO-UNDO.
    DEFINE VARIABLE cLigne AS CHARACTER NO-UNDO.

    EMPTY TEMP-TABLE tttempo.
    
    /* nb lignes maxi par colonne */
    iMaxCol = INTEGER(gDonnePreference("MAXCOL")).

    /* calcul de la nouvelle colonne */
    DO iBoucle = 1 TO 4:
        IF hbouton:COL >= 2 + (iBoucle - 1) * iEcartColonne 
        AND hbouton:COL <= 2 + (iBoucle) * iEcartColonne 
            THEN DO:
            iColonneNouvelle = iBoucle.
            LEAVE.
        END.
    END.

    IF iColonneNouvelle = 0 THEN iColonneNouvelle = 1.

    /* calcul de la nouvelle ligne */
    iMaxColx = INTEGER(gDonnePreference("MAXCOL" + STRING(iColonneNouvelle))).
    IF iMaxColx < iMaxCol THEN do:
        hbouton:COL = 2 + (iColonneNouvelle - 1) * iEcartColonne.
        hbouton:ROW = iRowInit + (iMaxColx) * iEcartLigne.
        INPUT STREAM gstrentree FROM VALUE(cFichierFavoris).
        iBoucle = 0.
        REPEAT:
            IMPORT STREAM gstrentree UNFORMATTED cLigne.
            IF cLigne <> "" THEN DO:
                CREATE tttempo.
                iBoucle = iBoucle + 1.
                tttempo.itempo = iBoucle.
                tttempo.cTempo = cLigne.
            END.
        END.
        INPUT STREAM gstrentree CLOSE.

        FIND FIRST tttempo WHERE tttempo.cTempo MATCHES ("*" + hBouton:LABEL + "*") NO-ERROR.
        IF AVAILABLE(tttempo) THEN DO:
            tttempo.itempo = 99.
            tttempo.ctempo = "FAV," + STRING(iColonneNouvelle) + "," + hBouton:LABEL + "," + REPLACE(hBouton:PRIVATE-DATA,"§",",").
        END.
        
        OS-COMMAND SILENT VALUE("copy " + cFichierFavoris + " " 
            + cFichierFavoris + "-"
            + STRING(YEAR(TODAY),"9999") 
            + STRING(MONTH(TODAY),"99") 
            + STRING(DAY(TODAY),"99") 
            + STRING(TIME)
            ).
        /* Sauvegarde de l'état actuel */
        OUTPUT STREAM gstrSortie TO VALUE(cFichierFavoris) NO-ECHO.
        FOR EACH tttempo BY SUBSTRING(tttempo.ctempo,1,5) BY itempo:
            PUT STREAM gstrSortie UNFORMATTED tttempo.ctempo SKIP.
        END.
        OUTPUT STREAM gstrSortie CLOSE.

    END.

    EMPTY TEMP-TABLE tttempo.

    /* Dans tous les cas on recharge */
    RUN recharger.



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
  RUN control_load.
  VIEW FRAME frmBoutons IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-frmBoutons}
  ENABLE BTnEdit btnHome bntRetour btnAvance btnmaj 
      WITH FRAME frmModule IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-frmModule}
  VIEW FRAME FRAME-A IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-FRAME-A}
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
    gcAideRaf = "Recharger les boutons".

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
    DEFINE VARIABLE iRow AS DECIMAL EXTENT 4.
    DEFINE VARIABLE iLargeur AS INTEGER NO-UNDO INIT 38.
    DEFINE VARIABLE hBouton AS HANDLE NO-UNDO.
    DEFINE VARIABLE cTempo AS CHARACTER NO-UNDO.
    DEFINE VARIABLE iColonne AS INTEGER NO-UNDO.
    DEFINE VARIABLE lBoutonsPlats AS LOGICAL NO-UNDO INIT TRUE.
   
    FRAME frmModule:COLUMN = gdPositionXModule.
    FRAME frmModule:ROW = gdPositionYModule.

    lBoutonsPlats = (IF gDonnePreference("PREF-BOUTONSNORMAUX") = "OUI" THEN FALSE ELSE TRUE).

    /* ouverture du fichier de configuration */
    irow[1] = 1.
    irow[2] = 1.
    irow[3] = 1.
    irow[4] = 1.

    cFichierFavoris = gcRepertoireRessourcesPrivees + "Utilisateurs\" + gcUtilisateur + "\" + gcUtilisateur + "-Favoris.mdev2".

    gMLog("Recherche du fichier des favoris : " + cFichierFavoris).
    IF SEARCH(cFichierFavoris) = ? THEN do:
        gMLog ("Fichier des favoris inexistant").
        /*RETURN.*/
    END.
    ELSE DO:
        INPUT STREAM gstrEntree FROM VALUE(cFichierFavoris) NO-ECHO.
        REPEAT:
            IMPORT STREAM gstrEntree UNFORMATTED cTempo1 .
            IF TRIM(ctempo1) <> "" THEN DO:
                IF TRUE /* entry(1,ctempo1) = entry(2,cParametres) AND ENTRY(3,ctempo1) <> "" */ THEN DO WITH FRAME frmgeneral:
                    iColonne = integer(ENTRY(2,ctempo1)).
                    /* complement des entrée si nécessaire */
                    CREATE BUTTON hBouton 
                           ASSIGN 
                           FLAT-BUTTON = lBoutonsPlats
                           FRAME = FRAME frmBoutons:HANDLE
                           ROW = iRowInit + (iRow[iColonne] - 1) * iEcartLigne
                           COLUMN = 2 + (iColonne - 1) * iEcartColonne
                           WIDTH = iLargeur
                           HEIGHT = iEcartLigne - 0.1
                           LABEL = ENTRY(3,ctempo1)
                           SENSITIVE = TRUE
                           HIDDEN = FALSE
                           PRIVATE-DATA = ENTRY(4,ctempo1) + "§" + ENTRY(5,ctempo1) + "§" + ENTRY(6,ctempo1) + "§" + ENTRY(7,ctempo1)
                           TOOLTIP = ENTRY(4,ctempo1) 
                           FONT = 8
                           MOVABLE = (IF btnEdit:LABEL = "<>" THEN TRUE ELSE FALSE)
                           
                                    TRIGGERS:
                                        /*ON CHOOSE PERSISTENT RUN ChoixBouton IN THIS-PROCEDURE (hBouton) .*/
                                        ON "LEFT-MOUSE-CLICK" PERSISTENT RUN ChoixBouton IN THIS-PROCEDURE (hBouton) .
                                        ON "RIGHT-MOUSE-CLICK" PERSISTENT RUN SupprimeBouton IN THIS-PROCEDURE (hBouton).
                                        ON "END-MOVE" PERSISTENT RUN DeplaceBouton IN THIS-PROCEDURE (hBouton).
                                    END TRIGGERS
                            .                       
                        iRow[iColonne] = iRow[iColonne] + 1.
                 END.
            END.
        END.
        INPUT STREAM gstrEntree CLOSE.    

        DO WITH FRAME frmBoutons:   
            /*VIEW. */
            ENABLE ALL. 
        END.
        FRAME frmModule:TITLE = entry(1,cParametres) +  "  -  (Clique droit sur un bouton pour le retirer des favoris)".

        /* Sauvegarde des max des colonnes */
        gSauvePreference("MAXCOL1",string(irow[1])).
        gSauvePreference("MAXCOL2",string(irow[2])).
        gSauvePreference("MAXCOL3",string(irow[3])).
        gSauvePreference("MAXCOL4",string(irow[4])).
        gSauvePreference("MAXCOL","7").

    END.

    os-create-dir VALUE(gcRepertoireRessourcesPrivees + "Utilisateurs\" + gcUtilisateur + "\Favoris"). 
    chCtrlFrame-2:WebBrowser:Navigate(gcRepertoireRessourcesPrivees + "Utilisateurs\" + gcUtilisateur + "\Favoris").
    
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
  RUN control_load.
  VIEW FRAME frmModule IN WINDOW winGeneral.
    {&OPEN-BROWSERS-IN-QUERY-frmModule}
    HIDE c-win.

  ENABLE ALL WITH FRAME frmModule.
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
    DEFINE VARIABLE htempo AS WIDGET-HANDLE NO-UNDO.
    DEFINE VARIABLE htempo1 AS WIDGET-HANDLE NO-UNDO.

    /* Suppression des boutons */
    htempo = FRAME frmBoutons:FIRST-CHILD.
    htempo = htempo:FIRST-CHILD.
    REPEAT WHILE VALID-HANDLE(htempo):
        IF htempo:TYPE  = "BUTTON" AND htempo:PRIVATE-DATA <> "FIXE" THEN DO:
            htempo1 = htempo:NEXT-SIBLING.
            DELETE WIDGET htempo.
        END.
        htempo = htempo1.
    END.


    /* Rechargement de l'écran */
    RUN initialisation.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE SupprimeBouton C-Win 
PROCEDURE SupprimeBouton :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER hBouton AS HANDLE NO-UNDO.


    DEFINE VARIABLE htempo AS WIDGET-HANDLE NO-UNDO.
    DEFINE VARIABLE htempo1 AS WIDGET-HANDLE NO-UNDO.
    DEFINE VARIABLE iColonne AS INTEGER NO-UNDO.
    DEFINE VARIABLE iMaxCol AS INTEGER NO-UNDO.
    DEFINE VARIABLE iBoutonCol AS INTEGER NO-UNDO.
    DEFINE VARIABLE iBoucle AS INTEGER NO-UNDO.
    DEFINE VARIABLE cLigne AS CHARACTER NO-UNDO.
    
    MESSAGE "Voulez-vous Supprimer ce bouton des favoris ?"
        VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
        TITLE "Gestion des favoris..."
        UPDATE lReponse AS LOGICAL.
    IF NOT(lReponse) THEN RETURN.
    
    INPUT STREAM gstrentree FROM VALUE(cFichierFavoris).
    iBoucle = 0.
    REPEAT:
        IMPORT STREAM gstrentree UNFORMATTED cLigne.
        IF cLigne <> "" THEN DO:
            CREATE tttempo.
            iBoucle = iBoucle + 1.
            tttempo.itempo = iBoucle.
            tttempo.cTempo = cLigne.
        END.
    END.
    INPUT STREAM gstrentree CLOSE.

    FIND FIRST tttempo WHERE tttempo.cTempo MATCHES ("*" + hBouton:LABEL + "*") NO-ERROR.
    IF AVAILABLE(tttempo) THEN DO:
        DELETE tttempo.
    END.
    
    OS-COMMAND SILENT VALUE("copy " + cFichierFavoris + " " 
        + cFichierFavoris + "-"
        + STRING(YEAR(TODAY),"9999") 
        + STRING(MONTH(TODAY),"99") 
        + STRING(DAY(TODAY),"99") 
        + STRING(TIME)
        ).
    /* Sauvegarde de l'état actuel */
    OUTPUT STREAM gstrSortie TO VALUE(cFichierFavoris) NO-ECHO.
    FOR EACH tttempo BY SUBSTRING(tttempo.ctempo,1,5) BY itempo:
        PUT STREAM gstrSortie UNFORMATTED tttempo.ctempo SKIP.
    END.
    OUTPUT STREAM gstrSortie CLOSE.

    RUN Recharger.

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

