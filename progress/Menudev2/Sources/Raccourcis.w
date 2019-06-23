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

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME frmBoutons

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME frmModule
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 166.2 BY 20.62
         BGCOLOR 7 
         TITLE BGCOLOR 2 FGCOLOR 15 "Raccourcis (Clique droit sur un bouton pour l'ajouter aux favoris)".

DEFINE FRAME frmBoutons
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 2 ROW 1.48
         SIZE 164 BY 18.81
         FONT 8.


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
         HEIGHT             = 20.62
         WIDTH              = 166
         MAX-HEIGHT         = 35.76
         MAX-WIDTH          = 166.2
         VIRTUAL-HEIGHT     = 35.76
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
  NOT-VISIBLE,,RUN-PERSISTENT                                           */
/* REPARENT FRAME */
ASSIGN FRAME frmBoutons:FRAME = FRAME frmModule:HANDLE.

/* SETTINGS FOR FRAME frmBoutons
   FRAME-NAME                                                           */
/* SETTINGS FOR FRAME frmModule
                                                                        */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



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
    DEFINE VARIABLE cFichier AS CHARACTER NO-UNDO.

    IF hBouton:PRIVATE-DATA = "" THEN RETURN.
    
        /* Informations sur le bouton */
    cFichier = entry(5,hBouton:PRIVATE-DATA,"§").
    IF cFichier <> "" THEN DO:
        /* Affichage des information */
        FIND FIRST  fichiers    NO-LOCK
            WHERE   fichiers.cUtilisateur = ""
            AND     fichiers.cTypeFichier = "SYS"
            AND     fichiers.cIdentFichier = cFichier
            NO-ERROR.
        IF AVAILABLE(fichiers) THEN DO:
            MESSAGE Fichiers.texte VIEW-AS ALERT-BOX INFORMATION
                TITLE "Informations sur l'action demandée..."
                .
        END.
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
            /*MESSAGE "cReponse = " cReponse VIEW-AS ALERT-BOX.*/
            RUN VALUE(gcRepertoireExecution + "saisie2.w") (INPUT-OUTPUT gcAllerRetour).
            IF gcAllerRetour = "" THEN RETURN.
            cValeur = ENTRY(4,gcAllerRetour,"|").
            /* Ajout de l'extension et du préfixe en automatique si nécessaire */
            IF cReponse MATCHES ("*.pf") AND NOT(cValeur MATCHES ("*.pf")) THEN cValeur = cValeur + ".pf".
            IF cReponse BEGINS ("cnx") AND NOT(cValeur BEGINS ("cnx")) THEN cValeur = "cnx" + cValeur.
            cCommande = REPLACE(cCommande,"%" + STRING(iBoucle),cValeur).    
         END.
    END.
    
    /*MESSAGE "cCommande = " ccommande VIEW-AS ALERT-BOX.*/
    gMlog("Lancement de la commande : " + cCommande).
    IF lBatch THEN 
        OS-COMMAND VALUE(cCommande).
    ELSE
        OS-COMMAND NO-WAIT  VALUE(cCommande).

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
  VIEW FRAME frmBoutons IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-frmBoutons}
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
                IF gTopRechargeModule("menudev.inf") THEN RUN Recharger.
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE FavorisBouton C-Win 
PROCEDURE FavorisBouton :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER hBouton AS HANDLE NO-UNDO.

    DEFINE VARIABLE iColonne AS INTEGER NO-UNDO.
    DEFINE VARIABLE iBoucle AS INTEGER  NO-UNDO.
    DEFINE VARIABLE iMaxCol AS INTEGER NO-UNDO.
    DEFINE VARIABLE iMaxColx AS INTEGER NO-UNDO.

    MESSAGE "Voulez-vous ajouter ce bouton aux favoris ?"
        VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
        TITLE "Gestion des favoris..."
        UPDATE lReponse AS LOGICAL.
    IF NOT(lReponse) THEN RETURN NO-APPLY.

    /* Récupération du maximum de boutons par colonne */
    iMaxCol = INTEGER(gDonnePreference("MAXCOL")).
    gMLog("iMaxCol = " + STRING(iMaxCol)).

    /* Recherche de la 1ere colonne disponible */
    iColonne = 0.
    DO iBoucle = 1 TO 4:
        iMaxColx = INTEGER(gDonnePreference("MAXCOL" + STRING(iBoucle))).
        gMLog("iMaxCol" + STRING(iBoucle) + " = " + STRING(iMaxColx)).
        IF iMaxColx <= iMaxCol THEN do:
            iColonne = iBoucle.
            LEAVE.
        END.
    END.

    /* controle */
    IF iColonne = 0 THEN DO:
        MESSAGE "Il n'y a plus de place dans les favoris." VIEW-AS ALERT-BOX ERROR TITLE "Gestion des favoris".
        RETURN.
    END.

    /* Ecriture dans le fichier des favoris */
    OUTPUT STREAM gstrSortie TO VALUE(gcRepertoireRessourcesPrivees + "Utilisateurs\" + gcUtilisateur + "\" + gcUtilisateur + "-Favoris.mdev2") APPEND NO-ECHO.
    PUT STREAM gstrSortie UNFORMATTED "FAV," + STRING(iColonne) + "," + hBouton:LABEL + "," + REPLACE(hBouton:PRIVATE-DATA,"§",",") SKIP.
    OUTPUT STREAM gstrSortie CLOSE.

    /* Trace */
/*    MESSAGE "Bouton ajouté aux favoris." VIEW-AS ALERT-BOX INFORMATION TITLE "Gestion des favoris".*/
    gMLog ("Fichier des favoris : " + gcRepertoireRessourcesPrivees + "Utilisateurs\" + gcUtilisateur + "\" + gcUtilisateur + "-Favoris.mdev2").

    /* Ordre de mise a jour du module favoris */
    RUN DonneOrdre("DONNEORDREAMODULE=Favoris|RECHARGE").

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
    DEFINE VARIABLE iRowInit AS DECIMAL INIT 1.25.
    DEFINE VARIABLE iRow AS DECIMAL EXTENT 4.
    DEFINE VARIABLE iEcartLigne AS DECIMAL   NO-UNDO INIT 1.1 .
    DEFINE VARIABLE iEcartColonne AS INTEGER   NO-UNDO INIT 39 .
    DEFINE VARIABLE iLargeur AS INTEGER NO-UNDO INIT 38.
    DEFINE VARIABLE hBouton AS HANDLE NO-UNDO.
    DEFINE VARIABLE cTempo AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lBoutonsPlats AS LOGICAL NO-UNDO INIT TRUE.
    DEFINE VARIABLE iColonne AS INTEGER NO-UNDO.
   
    FRAME frmModule:COLUMN = gdPositionXModule.
    FRAME frmModule:ROW = gdPositionYModule.

     lBoutonsPlats = (IF gDonnePreference("PREF-BOUTONSNORMAUX") = "OUI" THEN FALSE ELSE TRUE).

    /* ouverture du fichier de configuration */
    irow[1] = iRowInit.
    irow[2] = iRowInit.
    irow[3] = iRowInit.
    irow[4] = iRowInit.

    RUN gDechargeFichierEnLocal("","menudev.inf").

    INPUT STREAM gstrEntree FROM VALUE(gcFichierLocal) NO-ECHO.
    REPEAT:
        IMPORT STREAM gstrEntree UNFORMATTED cTempo1 .
        IF TRIM(ctempo1) <> "" THEN DO:
            IF entry(1,ctempo1) = entry(2,cParametres) AND ENTRY(3,ctempo1) <> "" 
                AND integer(ENTRY(8,ctempo1)) <= giNiveauUtilisateur 
                AND (ENTRY(9,ctempo1) = "" OR  ENTRY(9,ctempo1) = gcGroupeUtilisateur)
                THEN DO WITH FRAME frmgeneral:

                iColonne = integer(ENTRY(2,ctempo1)).
                /* complement des entrée si nécessaire */
                CREATE BUTTON hBouton 
                       ASSIGN 
                       FLAT-BUTTON = lBoutonsPlats
                       FRAME = FRAME frmBoutons:HANDLE
                       ROW = iRow[iColonne]
                       COLUMN = 2 + (iColonne - 1) * iEcartColonne
                       WIDTH = iLargeur
                       HEIGHT = iEcartLigne - 0.1
                       LABEL = ENTRY(3,ctempo1)
                       SENSITIVE = TRUE
                       HIDDEN = FALSE
                       PRIVATE-DATA = ENTRY(4,ctempo1) + "§" + ENTRY(5,ctempo1) + "§" + ENTRY(6,ctempo1) + "§" + ENTRY(7,ctempo1) + "§" + (IF num-entries(cTempo1) >= 9 THEN ENTRY(9,ctempo1) ELSE "")
                       TOOLTIP = ENTRY(4,ctempo1) 
                       FONT = 8
                    TRIGGERS:
                        ON CHOOSE PERSISTENT RUN ChoixBouton IN THIS-PROCEDURE (hBouton) .
                        ON "RIGHT-MOUSE-CLICK" PERSISTENT RUN FavorisBouton IN THIS-PROCEDURE (hBouton).
                    END TRIGGERS
                        .                       
                    iRow[iColonne] = iRow[iColonne] + iEcartLigne.
             END.
        END.
    END.
    INPUT STREAM gstrEntree CLOSE.    

    DO WITH FRAME frmBoutons:   
        VIEW. 
        ENABLE ALL. 
    END.
    FRAME frmModule:TITLE = entry(1,cParametres) +  "  -  (Clique droit sur un bouton pour l'ajouter aux favoris)".

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
    DEFINE VARIABLE htempo AS WIDGET-HANDLE NO-UNDO.
    DEFINE VARIABLE htempo1 AS WIDGET-HANDLE NO-UNDO.


    /* Suppression des boutons */
    htempo = FRAME frmBoutons:FIRST-CHILD.
    htempo = htempo:FIRST-CHILD.
    REPEAT WHILE VALID-HANDLE(htempo):
        IF htempo:TYPE  = "BUTTON" THEN DO:
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

