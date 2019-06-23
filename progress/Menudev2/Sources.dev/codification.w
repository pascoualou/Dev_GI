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
{includes\i_chaine.i}
{includes\i_html.i}
{menudev2\includes\menudev2.i}
/*{menudev2\includes\bases.i}*/

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER  winGeneral  AS HANDLE NO-UNDO.
DEFINE INPUT PARAMETER  cParametres AS CHARACTER NO-UNDO.


/* Local Variable Definitions ---                                       */
DEFINE VARIABLE lSensType           AS LOGICAL      NO-UNDO INIT TRUE.
DEFINE VARIABLE lSensTable          AS LOGICAL      NO-UNDO INIT ?.
DEFINE VARIABLE lSensLibelleType    AS LOGICAL      NO-UNDO INIT ?.
DEFINE VARIABLE lSensCode           AS LOGICAL      NO-UNDO INIT TRUE.
DEFINE VARIABLE lSensLibelleCode    AS LOGICAL      NO-UNDO INIT ?.
DEFINE VARIABLE lChargeTypes        AS LOGICAL      NO-UNDO INIT TRUE.

DEFINE VARIABLE cCode               AS CHARACTER    NO-UNDO.
DEFINE VARIABLE cLigne              AS CHARACTER    NO-UNDO.
DEFINE VARIABLE cPerso              AS CHARACTER    NO-UNDO.
DEFINE VARIABLE cTypeNew            AS CHARACTER    NO-UNDO.
DEFINE VARIABLE cTypeNewPref        AS CHARACTER    NO-UNDO.
DEFINE VARIABLE cTypeEnCours        AS CHARACTER    NO-UNDO.
DEFINE VARIABLE cCodeEnCours        AS CHARACTER    NO-UNDO.

DEFINE TEMP-TABLE ttCodeLibelle
    FIELD cCode    AS CHARACTER
    FIELD cLibelle   AS CHARACTER
    FIELD cInfos AS CHARACTER
    .

DEFINE TEMP-TABLE ttTypes
    FIELD ctable AS CHARACTER
    FIELD cType AS CHARACTER
    FIELD cLibelle AS CHARACTER
    FIELD cTypePref AS CHARACTER
    INDEX ixType IS PRIMARY ctable cType 
    .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME frmModule
&Scoped-define BROWSE-NAME brwCodes

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ttCodeLibelle ttTypes

/* Definitions for BROWSE brwCodes                                      */
&Scoped-define FIELDS-IN-QUERY-brwCodes ttCodeLibelle.cCode ttCodeLibelle.cLibelle ttCodeLibelle.cInfos   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brwCodes ttCodeLibelle.cCode ttCodeLibelle.cLibelle ttCodeLibelle.cInfos   
&Scoped-define ENABLED-TABLES-IN-QUERY-brwCodes ttCodeLibelle
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-brwCodes ttCodeLibelle
&Scoped-define SELF-NAME brwCodes
&Scoped-define QUERY-STRING-brwCodes FOR EACH ttCodeLibelle
&Scoped-define OPEN-QUERY-brwCodes OPEN QUERY {&SELF-NAME} FOR EACH ttCodeLibelle.
&Scoped-define TABLES-IN-QUERY-brwCodes ttCodeLibelle
&Scoped-define FIRST-TABLE-IN-QUERY-brwCodes ttCodeLibelle


/* Definitions for BROWSE brwTypes                                      */
&Scoped-define FIELDS-IN-QUERY-brwTypes ttTypes.cTable ttTypes.cType ttTypes.cLibelle   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brwTypes ttTypes.ctype ttTypes.cLibelle   
&Scoped-define ENABLED-TABLES-IN-QUERY-brwTypes ttTypes
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-brwTypes ttTypes
&Scoped-define SELF-NAME brwTypes
&Scoped-define QUERY-STRING-brwTypes FOR EACH ttTypes
&Scoped-define OPEN-QUERY-brwTypes OPEN QUERY {&SELF-NAME} FOR EACH ttTypes.
&Scoped-define TABLES-IN-QUERY-brwTypes ttTypes
&Scoped-define FIRST-TABLE-IN-QUERY-brwTypes ttTypes


/* Definitions for FRAME frmModule                                      */
&Scoped-define OPEN-BROWSERS-IN-QUERY-frmModule ~
    ~{&OPEN-QUERY-brwCodes}~
    ~{&OPEN-QUERY-brwTypes}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS filTypeLibelle btnCodePrecedent ~
btnCodeSuivant filCodeLibelle brwTypes brwCodes 
&Scoped-Define DISPLAYED-OBJECTS filTypeLibelle filCodeLibelle 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD gDonneValeurCode C-Win 
FUNCTION gDonneValeurCode RETURNS CHARACTER
  (cCode AS CHARACTER,cParametre AS CHARACTER)  FORWARD.

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

DEFINE VARIABLE filCodeLibelle AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 100 BY .95
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE filTypeLibelle AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE-PIXELS 270 BY 20
     BGCOLOR 15  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brwCodes FOR 
      ttCodeLibelle SCROLLING.

DEFINE QUERY brwTypes FOR 
      ttTypes SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brwCodes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brwCodes C-Win _FREEFORM
  QUERY brwCodes DISPLAY
      ttCodeLibelle.cCode FORMAT "999999" LABEL "Code" WIDTH 7 
      ttCodeLibelle.cLibelle  FORMAT "x(120)" LABEL "Libellé" WIDTH 60
      ttCodeLibelle.cInfos  FORMAT "x(255)" LABEL "Informations complémentaires" 
      ENABLE ttCodeLibelle.cCode ttCodeLibelle.cLibelle ttCodeLibelle.cInfos
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 100 BY 18.1
         BGCOLOR 15 
         TITLE BGCOLOR 15 "Codes et valeurs du paramètre" ROW-HEIGHT-CHARS .67.

DEFINE BROWSE brwTypes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brwTypes C-Win _FREEFORM
  QUERY brwTypes DISPLAY
      ttTypes.cTable FORMAT "x(10)" LABEL "Table" WIDTH 8 
      ttTypes.cType FORMAT "x(5)" LABEL "Type" WIDTH 8 
      ttTypes.cLibelle  FORMAT "x(40)" LABEL "Libellé"
      ENABLE ttTypes.ctype ttTypes.cLibelle
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 63 BY 18.1
         BGCOLOR 15 
         TITLE BGCOLOR 15 "Type de paramètre" ROW-HEIGHT-CHARS .6 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME frmModule
     filTypeLibelle AT Y 5 X 5 NO-LABEL
     btnCodePrecedent AT Y 5 X 280
     btnCodeSuivant AT Y 5 X 301
     filCodeLibelle AT ROW 1.24 COL 64 COLON-ALIGNED NO-LABEL
     brwTypes AT ROW 2.43 COL 2
     brwCodes AT ROW 2.43 COL 66
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 166.2 BY 20.62
         BGCOLOR 7 
         TITLE BGCOLOR 2 FGCOLOR 15 "Codification".


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
  NOT-VISIBLE,,RUN-PERSISTENT                                           */
/* SETTINGS FOR FRAME frmModule
   FRAME-NAME                                                           */
/* BROWSE-TAB brwTypes filCodeLibelle frmModule */
/* BROWSE-TAB brwCodes brwTypes frmModule */
ASSIGN 
       brwCodes:COLUMN-RESIZABLE IN FRAME frmModule       = TRUE.

ASSIGN 
       btnCodeSuivant:AUTO-RESIZE IN FRAME frmModule      = TRUE.

/* SETTINGS FOR FILL-IN filTypeLibelle IN FRAME frmModule
   ALIGN-L                                                              */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brwCodes
/* Query rebuild information for BROWSE brwCodes
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH ttCodeLibelle
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE brwCodes */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brwTypes
/* Query rebuild information for BROWSE brwTypes
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH ttTypes.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE brwTypes */
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


&Scoped-define BROWSE-NAME brwCodes
&Scoped-define SELF-NAME brwCodes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwCodes C-Win
ON START-SEARCH OF brwCodes IN FRAME frmModule /* Codes et valeurs du paramètre */
DO: 
    IF BrwCodes:CURRENT-COLUMN:LABEL = "Code" THEN do:
        lSensCode = NOT(lSensCode).
        IF lSensCode = ? THEN lSensCode = TRUE.
        lSensLibelleCode = ?.
    END.
    IF BrwCodes:CURRENT-COLUMN:LABEL = "Libellé" THEN do:
        lSensLibelleCode = NOT(lSensLibelleCode).
        IF lSensLibelleCode = ? THEN lSensLibelleCode = TRUE.
        lSensCode = ?.
    END.
    RUN OuvreQueryCode.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brwTypes
&Scoped-define SELF-NAME brwTypes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwTypes C-Win
ON START-SEARCH OF brwTypes IN FRAME frmModule /* Type de paramètre */
DO:
    IF BrwTypes:CURRENT-COLUMN:LABEL = "Type" THEN do:
        lSensType = NOT(lSensType).
        IF lSensType = ? THEN lSensType = TRUE.
        lSensLibelleType = ?.
        lSensTable = ?.
    END.
    IF BrwTypes:CURRENT-COLUMN:LABEL = "Libellé" THEN do:
        lSensLibelleType = NOT(lSensLibelleType).
        IF lSensLibelleType = ? THEN lSensLibelleType = TRUE.
        lSensType = ?.
        lSensTable = ?.
    END.
    IF BrwTypes:CURRENT-COLUMN:LABEL = "Table" THEN do:
        lSensTable = NOT(lSensTable).
        IF lSensTable = ? THEN lSensTable = TRUE.
        lSensType = ?.
        lSensLibelleType = ?.
    END.
    RUN OuvreQueryType.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwTypes C-Win
ON VALUE-CHANGED OF brwTypes IN FRAME frmModule /* Type de paramètre */
DO:
    filCodeLibelle:SCREEN-VALUE = "".
    filTypeLibelle:SCREEN-VALUE = "".
    
    /* Sauvegarde de la valeur en cours */
    cTypeEnCours = (IF available(ttTypes) THEN ttTypes.ctype ELSE "").
    
    RUN ChargeCodes.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnCodePrecedent
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnCodePrecedent C-Win
ON CHOOSE OF btnCodePrecedent IN FRAME frmModule /* < */
DO:
  
    RUN SaisieType ("PREV").

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btnCodeSuivant
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnCodeSuivant C-Win
ON CHOOSE OF btnCodeSuivant IN FRAME frmModule /* > */
DO:
    
    RUN SaisieType ("NEXT").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filCodeLibelle
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filCodeLibelle C-Win
ON ANY-PRINTABLE OF filCodeLibelle IN FRAME frmModule
DO:  
    APPLY LAST-KEY TO SELF.
    RUN ChargeCodes.
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filCodeLibelle C-Win
ON BACKSPACE OF filCodeLibelle IN FRAME frmModule
DO:
    APPLY LAST-KEY TO SELF.
    APPLY "VALUE-CHANGED" TO brwTypes.
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filCodeLibelle C-Win
ON DELETE-CHARACTER OF filCodeLibelle IN FRAME frmModule
DO:
    APPLY LAST-KEY TO SELF.
    APPLY "VALUE-CHANGED" TO brwTypes.
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filCodeLibelle C-Win
ON RETURN OF filCodeLibelle IN FRAME frmModule
DO:
    APPLY LAST-KEY TO SELF.
    APPLY "VALUE-CHANGED" TO brwTypes.
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME filTypeLibelle
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filTypeLibelle C-Win
ON ANY-PRINTABLE OF filTypeLibelle IN FRAME frmModule
DO:  
    APPLY  LAST-KEY TO SELF.
    RUN SaisieType ("").
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filTypeLibelle C-Win
ON BACKSPACE OF filTypeLibelle IN FRAME frmModule
DO:
    APPLY  LAST-KEY TO SELF.
    RUN SaisieType ("").
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filTypeLibelle C-Win
ON DELETE-CHARACTER OF filTypeLibelle IN FRAME frmModule
DO:
    APPLY  LAST-KEY TO SELF.
    RUN SaisieType ("").
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filTypeLibelle C-Win
ON RETURN OF filTypeLibelle IN FRAME frmModule
DO:
    APPLY  LAST-KEY TO SELF.
    RUN SaisieType ("").
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL filTypeLibelle C-Win
ON VALUE-CHANGED OF filTypeLibelle IN FRAME frmModule
DO:
  filCodeLibelle:SCREEN-VALUE = "".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brwCodes
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ChargeCodes C-Win 
PROCEDURE ChargeCodes :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE cTempo AS CHARACTER NO-UNDO.

    IF NOT(AVAILABLE(tttypes)) THEN RETURN.
    DO WITH FRAME frmModule:
        /* Chargement de la table temporaire */
        
        EMPTY TEMP-TABLE ttCodeLibelle. 
            
        IF ttTypes.cTable <> "pclie" THEN DO:
            /* rendre les colonnes visibles */
            ttCodeLibelle.cCode:VISIBLE IN BROWSE brwcodes = TRUE.
            ttCodeLibelle.cLibelle:VISIBLE IN BROWSE brwcodes = TRUE.

            IF ttTypes.cType BEGINS "O_" OR ttTypes.cType BEGINS "R_" THEN DO:
                FOR EACH    sys_pg NO-LOCK
                    WHERE   sys_pg.tppar = ttTypes.cType
                   ,EACH    sys_lb NO-LOCK
                    WHERE   sys_lb.cdlng = 0
                    AND     sys_lb.nomes = sys_pg.nome1
                    AND     (
                              (sys_lb.lbmes MATCHES "*" + filCodeLibelle:SCREEN-VALUE + "*" 
                               OR sys_pg.cdpar MATCHES "*" + filCodeLibelle:SCREEN-VALUE + "*"
                               OR sys_pg.zone1 MATCHES "*" + filCodeLibelle:SCREEN-VALUE + "*"
                               OR sys_pg.zone2 MATCHES "*" + filCodeLibelle:SCREEN-VALUE + "*"
                               OR sys_pg.zone3 MATCHES "*" + filCodeLibelle:SCREEN-VALUE + "*"
                               OR sys_pg.zone4 MATCHES "*" + filCodeLibelle:SCREEN-VALUE + "*"
                               OR sys_pg.zone5 MATCHES "*" + filCodeLibelle:SCREEN-VALUE + "*"
                               OR sys_pg.zone6 MATCHES "*" + filCodeLibelle:SCREEN-VALUE + "*"
                               OR sys_pg.zone7 MATCHES "*" + filCodeLibelle:SCREEN-VALUE + "*"
                               OR sys_pg.zone8 MATCHES "*" + filCodeLibelle:SCREEN-VALUE + "*"
                               OR sys_pg.zone9 MATCHES "*" + filCodeLibelle:SCREEN-VALUE + "*"
                               OR sys_pg.nmprg MATCHES "*" + filCodeLibelle:SCREEN-VALUE + "*"
                              ) 
                              OR filCodeLibelle:SCREEN-VALUE = ""
                             )
                    :
                    CREATE ttCodeLibelle.
                    ttCodeLibelle.cCode = sys_pg.cdpar.
                    ttCodeLibelle.cLibelle = sys_lb.lbmes.
                    
                    cTempo = "".
                    cTempo = AjouteSiNonVide(sys_pg.zone1,cTempo," / Zone1=").
                    cTempo = AjouteSiNonVide(sys_pg.zone2,cTempo," / Zone2=").
                    cTempo = AjouteSiNonVide(sys_pg.zone3,cTempo," / Zone3=").
                    cTempo = AjouteSiNonVide(sys_pg.zone4,cTempo," / Zone4=").
                    cTempo = AjouteSiNonVide(sys_pg.zone5,cTempo," / Zone5=").
                    cTempo = AjouteSiNonVide(sys_pg.zone6,cTempo," / Zone6=").
                    cTempo = AjouteSiNonVide(sys_pg.zone7,cTempo," / Zone7=").
                    cTempo = AjouteSiNonVide(sys_pg.zone8,cTempo," / Zone8=").
                    cTempo = AjouteSiNonVide(sys_pg.zone9,cTempo," / Zone9=").
                    cTempo = AjouteSiNonVide(sys_pg.RpRun,cTempo," / RpRun=").
                    cTempo = AjouteSiNonVide(sys_pg.NmPrg,cTempo," / NmPrg=").
                    cTempo = AjouteSiNonVide(string(sys_pg.Minim),cTempo," / Minim=").
                    cTempo = AjouteSiNonVide(string(sys_pg.Maxim),cTempo," / Maxim=").
                    ttCodeLibelle.cInfos = substring(cTempo,4).    
                END.
            END.
            ELSE IF ttTypes.cType <> "rubqt" THEN DO:
                FOR EACH    sys_pr NO-LOCK
                    WHERE   sys_pr.tppar = ttTypes.cType
                   ,EACH    sys_lb NO-LOCK
                    WHERE   sys_lb.cdlng = 0
                    AND     sys_lb.nomes = sys_pr.nome1
                    AND     (
                                 (
                                 sys_lb.lbmes MATCHES "*" + filCodeLibelle:SCREEN-VALUE + "*" 
                                 OR sys_pr.cdpar MATCHES "*" + filCodeLibelle:SCREEN-VALUE + "*"
                                 OR string(sys_pr.zone1) MATCHES "*" + filCodeLibelle:SCREEN-VALUE + "*"
                                 OR string(sys_pr.zone2) MATCHES "*" + filCodeLibelle:SCREEN-VALUE + "*"
                                 ) 
                                 OR filCodeLibelle:SCREEN-VALUE = ""
                            )
                    :
                    CREATE ttCodeLibelle.
                    ttCodeLibelle.cCode = sys_pr.cdpar.
                    ttCodeLibelle.cLibelle = sys_lb.lbmes.
                    cTempo = "".
                    cTempo = AjouteSiNonVide(string(sys_pr.zone1),cTempo," / Zone1=").
                    cTempo = AjouteSiNonVide(sys_pr.zone2,cTempo," / Zone2=").
                    ttCodeLibelle.cInfos = substring(cTempo,4).    
                END.
            END.
            ELSE DO:
                FOR EACH    rubqt   NO-LOCK
                    ,EACH    sys_lb NO-LOCK
                     WHERE   sys_lb.cdlng = 0
                     AND     sys_lb.nomes = rubqt.nome1
                    BY rubqt.cdrub BY rubqt.cdlib
                    :
                    cTempo = "".
                    cTempo = AjouteSiNonVide(string(rubqt.cdfam,"99"),cTempo," / Famille=").
                    cTempo = AjouteSiNonVide(string(rubqt.cdsfa),cTempo," / Sous-Famille=").
                    cTempo = AjouteSiNonVide(gDonneValeurCode(rubqt.cdgen,"RUGEN"),cTempo," / Genre=").
                    cTempo = AjouteSiNonVide(gDonneValeurCode(rubqt.cdsig,"RUSIG"),cTempo," / Signe=").
                    IF filCodeLibelle:SCREEN-VALUE <> "" THEN DO:
                        IF not(
                        string(rubqt.cdrub,"999") + "." + string(rubqt.cdlib,"99") MATCHES "*" + filCodeLibelle:SCREEN-VALUE + "*" 
                        OR sys_lb.lbmes MATCHES "*" + filCodeLibelle:SCREEN-VALUE + "*" 
                        OR cTempo MATCHES "*" + filCodeLibelle:SCREEN-VALUE + "*"
                        ) THEN NEXT.
                    END.
                    CREATE ttCodeLibelle.
                    ttCodeLibelle.cCode = string(rubqt.cdrub,"999") + "." + string(rubqt.cdlib,"99").
                    ttCodeLibelle.cLibelle = sys_lb.lbmes.
                    ttCodeLibelle.cInfos = substring(cTempo,4).    
                END.
            END.
        END.
        ELSE DO:
            ttCodeLibelle.cCode:VISIBLE IN BROWSE brwcodes = FALSE.
            ttCodeLibelle.cLibelle:VISIBLE IN BROWSE brwcodes = FALSE.

            FOR EACH    pclie NO-LOCK
                WHERE   pclie.tppar = ttTypes.cType
                :
                CREATE ttCodeLibelle.
                ttCodeLibelle.cCode = "".
                    
                cTempo = "".
                cTempo = AjouteSiNonVide(pclie.zon01,cTempo," / Zon01=").
                cTempo = AjouteSiNonVide(pclie.zon02,cTempo," / Zon02=").
                cTempo = AjouteSiNonVide(pclie.zon03,cTempo," / Zon03=").
                cTempo = AjouteSiNonVide(pclie.zon04,cTempo," / Zon04=").
                cTempo = AjouteSiNonVide(pclie.zon05,cTempo," / Zon05=").
                cTempo = AjouteSiNonVide(pclie.zon06,cTempo," / Zon06=").
                cTempo = AjouteSiNonVide(pclie.zon07,cTempo," / Zon07=").
                cTempo = AjouteSiNonVide(pclie.zon08,cTempo," / Zon08=").
                cTempo = AjouteSiNonVide(pclie.zon09,cTempo," / Zon09=").
                cTempo = AjouteSiNonVide(pclie.zon10,cTempo," / Zon10=").
                cTempo = AjouteSiNonVide(string(pclie.fgact),cTempo," / fgact=").
                cTempo = AjouteSiNonZero(string(pclie.mnt01),cTempo," / mnt01=").
                cTempo = AjouteSiNonZero(string(pclie.mnt02),cTempo," / mnt02=").
                cTempo = AjouteSiNonZero(string(pclie.mnt03),cTempo," / mnt03=").
                cTempo = AjouteSiNonZero(string(pclie.mnt04),cTempo," / mnt04=").
                cTempo = AjouteSiNonZero(string(pclie.mnt05),cTempo," / mnt05=").
                cTempo = AjouteSiNonZero(string(pclie.tau01),cTempo," / tau01=").
                cTempo = AjouteSiNonZero(string(pclie.tau02),cTempo," / tau02=").
                cTempo = AjouteSiNonZero(string(pclie.tau03),cTempo," / tau03=").
                cTempo = AjouteSiNonZero(string(pclie.tau04),cTempo," / tau04=").
                cTempo = AjouteSiNonZero(string(pclie.tau05),cTempo," / tau05=").
                cTempo = AjouteSiNonZero(string(pclie.int01),cTempo," / int01=").
                cTempo = AjouteSiNonZero(string(pclie.int02),cTempo," / int02=").
                cTempo = AjouteSiNonZero(string(pclie.int03),cTempo," / int03=").
                cTempo = AjouteSiNonZero(string(pclie.int04),cTempo," / int04=").
                cTempo = AjouteSiNonZero(string(pclie.int05),cTempo," / int05=").
                ttCodeLibelle.cInfos = substring(cTempo,4).    
            END.
        END.
    END.
    
    RUN OuvreQueryCode.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ChargeTypes C-Win 
PROCEDURE ChargeTypes :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE cLibelleParam AS CHARACTER NO-UNDO.

    /* Vidage des tables */
    EMPTY TEMP-TABLE ttTypes.

    /* Chargement de la Liste des types */
    cPerso = DonnePreference("CODIFICATION-PERSO").

    DO WITH FRAME frmCodification:
        cLigne = DonnePreference("CODIFICATION-SYS_PR").
        FOR EACH    sys_pr  NO-LOCK
            WHERE   sys_pr.tppar = "#####"
            /*AND     (lookup(sys_pr.cdpar,cLigne) <> 0 OR lookup(sys_pr.cdpar,cPerso) <> 0)*/
           ,EACH    sys_lb  NO-LOCK
            WHERE   sys_lb.cdlng = 0
            AND     sys_lb.nomes = sys_pr.nome1
            :
            CREATE ttTypes.
            ttTypes.cTable = "sys_pr".
            ttTypes.cType = sys_pr.cdpar.
            ASSIGN
                ttTypes.cLibelle = sys_lb.lbmes
                ttTypes.cTypePref = "CODIFICATION-SYS_PR"
                .
        END.
        cLigne = DonnePreference("CODIFICATION-SYS_PG").
        FOR EACH    sys_pg  NO-LOCK
            WHERE   sys_pg.tppar = "#####"
            /*AND     (lookup(sys_pg.cdpar,cLigne) <> 0 OR lookup(sys_pg.cdpar,cPerso) <> 0)*/
           ,EACH    sys_lb  NO-LOCK
            WHERE   sys_lb.cdlng = 0
            AND     sys_lb.nomes = sys_pg.nome1
            :
            CREATE ttTypes.
            ttTypes.cTable = "sys_pg".
            ttTypes.cType = sys_pg.cdpar.
            ASSIGN
                ttTypes.cLibelle = sys_lb.lbmes
                ttTypes.cTypePref = "CODIFICATION-SYS_PG"
                .
        END.
        cLigne = DonnePreference("CODIFICATION-PCLIE").
        FOR EACH    pclie  NO-LOCK
            WHERE   TRUE
            BREAK BY pclie.tppar
            :
            IF FIRST-OF(pclie.tppar) THEN DO:
                cLibelleParam = "?.?.?".
                FIND FIRST pclid NO-LOCK
                    WHERE pclid.tppar = pclie.tppar
                    NO-ERROR.
                IF AVAILABLE(pclid) THEN DO:
                    FIND FIRST sys_lb  NO-LOCK
                        WHERE   sys_lb.cdlng = 0
                        AND     sys_lb.nomes = pclid.nomes
                        NO-ERROR.
                    IF AVAILABLE(sys_lb) THEN cLibelleParam = sys_lb.lbmes.
                END.
                CREATE ttTypes.
                ttTypes.cTable = "pclie".
                ttTypes.cType = pclie.tppar.
                ASSIGN
                    ttTypes.cLibelle = cLibelleParam
                    ttTypes.cTypePref = "CODIFICATION-PCLIE"
                    .
            END.
        END.
    
        
        /* Ajout des rubriques de quittancement */
        CREATE ttTypes.
        ttTypes.cTable = "rubqt".
        ttTypes.cType = "rubqt".
        ASSIGN
            ttTypes.cLibelle = "Rubriques de quittancement"
            ttTypes.cTypePref = "CODIFICATION-RUBQT"
            .
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
  DISPLAY filTypeLibelle filCodeLibelle 
      WITH FRAME frmModule IN WINDOW C-Win.
  ENABLE filTypeLibelle btnCodePrecedent btnCodeSuivant filCodeLibelle brwTypes 
         brwCodes 
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
                APPLY "ENTRY" TO filTypeLibelle IN FRAME frmmodule.
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
            WHEN "IMPRIME" THEN DO:
                RUN Impression.
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
    gcAideImprimer = "Imprimer la liste de valeurs sélectionnée".
    gcAideRaf = "#INTERDIT#".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Impression C-Win 
PROCEDURE Impression :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE VARIABLE cLigne AS CHARACTER NO-UNDO.

    /* Début de l'édition */
    RUN HTML_OuvreFichier("").
    cLigne = ttTypes.cType + " - " + ttTypes.cLibelle.
    IF filCodeLibelle:SCREEN-VALUE IN FRAME frmModule <> "" THEN DO:
        cLigne = cLigne + " ( Filtre : '" + filCodeLibelle:SCREEN-VALUE IN FRAME frmModule + "' )".
    END.
    RUN HTML_TitreEdition(cLigne).
    
    RUN HTML_ChargeFormatCellule("E",0,"CF=gris,A=><,T=3").
    RUN HTML_ChargeFormatCellule("L",0,"A=<").
    
    /* Ecriture de l'entete pour le tableau des champs */
    cLigne = "" 
        + "Code"
        + devSeparateurEdition + "Libellé"
        + devSeparateurEdition + "Infos"
        .
    RUN HTML_DebutTableau(cLigne).
    
    /* Balayage de la table des champs */
    FOR EACH ttCodeLibelle
        :
        cLigne = "" 
            + TRIM(ttCodeLibelle.cCode)
            + devSeparateurEdition + TRIM(ttCodeLibelle.cLibelle)
            + devSeparateurEdition + TRIM(ttCodeLibelle.cInfos)
            .
        RUN HTML_LigneTableau(cLigne).
    END.
    
    /* Fin de l'édition des champs */
    RUN HTML_FinTableau.
    
    RUN HTML_FinEdition.
    RUN HTML_FermeFichier.
    RUN Impression.

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

    FRAME frmModule:COLUMN = gdPositionXModule.
    FRAME frmModule:ROW = gdPositionYModule.
    ENABLE ALL WITH FRAME frmModule.

    /* Uniquement sur demande */
    IF lChargeTypes THEN DO:
        /* Chargement */
        RUN ChargeTypes.
    
        /* Ouverture du qurey */  
        RUN OuvreQueryType.
    
        DO WITH FRAME frmCodification:
            APPLY "VALUE-CHANGED" TO brwTypes.
            brwTypes:READ-ONLY = TRUE.
            brwCodes:READ-ONLY = TRUE.
            APPLY "ENTRY" TO filTypeLibelle.
        END.
    END.
    
    /* On indique que les types sont déjà chargés */
    lChargeTypes = FALSE.
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OuvreQueryCode C-Win 
PROCEDURE OuvreQueryCode :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    /* Sauvegarde de la valeur en cours */
    cCodeEnCours = (IF available(ttCodeLibelle) THEN ttCodeLibelle.cCode ELSE "").
    /* On force à pas de sauvegarde */
    cCodeEnCours = "".

    IF lSensCode <> ? THEN DO:
        IF lSensCode THEN        
            OPEN QUERY brwCodes FOR EACH ttCodeLibelle BY ttCodeLibelle.cCode .
        ELSE
            OPEN QUERY brwCodes FOR EACH ttCodeLibelle BY ttCodeLibelle.cCode DESC.
    END.
    IF lSensLibelleCode <> ? THEN DO:
        IF lSensLibelleCode THEN        
            OPEN QUERY brwCodes FOR EACH ttCodeLibelle BY ttCodeLibelle.cLibelle .
        ELSE
            OPEN QUERY brwCodes FOR EACH ttCodeLibelle BY ttCodeLibelle.cLibelle DESC.
    END.

    /* Repositionnement */
    IF cCodeEnCours <> "" THEN DO:
        FIND FIRST ttCodeLibelle WHERE ttCodeLibelle.cCode = cCodeEnCours NO-ERROR.
        REPOSITION brwCodes TO ROWID ROWID(ttCodeLibelle).
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OuvreQueryType C-Win 
PROCEDURE OuvreQueryType :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    Stockdebug("lSensType : " + (IF lSensType <> ? THEN STRING(lSensType) ELSE "?")).
    Stockdebug("lSensLibelleType : " + (IF lSensLibelleType <> ? THEN STRING(lSensLibelleType) ELSE "?")).
    Stockdebug("lSensTable : " + (IF lSensTable <> ? THEN STRING(lSensTable) ELSE "?")).
    Stockdebug("cTypeEnCours : " + cTypeEnCours).
    

    IF lSensType <> ? THEN DO:
        IF lSensType THEN        
            OPEN QUERY brwTypes FOR EACH ttTypes BY ttTypes.cType .
        ELSE
            OPEN QUERY brwTypes FOR EACH ttTypes BY ttTypes.cType DESC.
    END.
    IF lSensLibelleType <> ? THEN DO:
        IF lSensLibelleType THEN        
            OPEN QUERY brwTypes FOR EACH ttTypes BY ttTypes.cLibelle .
        ELSE
            OPEN QUERY brwTypes FOR EACH ttTypes BY ttTypes.cLibelle DESC.
    END.
    IF lSensTable <> ? THEN DO:
        IF lSensTable THEN        
            OPEN QUERY brwTypes FOR EACH ttTypes BY ttTypes.cTable .
        ELSE
            OPEN QUERY brwTypes FOR EACH ttTypes BY ttTypes.cTable DESC.
    END.

    /* Repositionnement */
    IF cTypeEnCours <> "" THEN DO:
        FIND FIRST ttTypes WHERE ttTypes.cType = cTypeEnCours NO-ERROR.
        IF available(ttTypes) THEN REPOSITION brwTypes TO ROWID ROWID(ttTypes).
    END.
    /*ELSE brwTypes:GET-FIRST() IN FRAME frmCodification.*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE SaisieType C-Win 
PROCEDURE SaisieType :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER cModeRecherche AS CHARACTER NO-UNDO.

    DO WITH FRAME frmModule:
        
        IF cModeRecherche = "" THEN DO:
            FIND FIRST ttTypes
                WHERE ttTypes.cType MATCHES "*" + filTypeLibelle:SCREEN-VALUE + "*"
                OR    ttTypes.cLibelle MATCHES "*" + filTypeLibelle:SCREEN-VALUE + "*"
                NO-ERROR.
        END.
        ELSE IF cModeRecherche = "NEXT" THEN DO:
            FIND NEXT ttTypes
                WHERE ttTypes.cType MATCHES "*" + filTypeLibelle:SCREEN-VALUE + "*"
                OR    ttTypes.cLibelle MATCHES "*" + filTypeLibelle:SCREEN-VALUE + "*"
                NO-ERROR.
        END.
        ELSE DO:
            FIND PREV ttTypes
                WHERE ttTypes.cType MATCHES "*" + filTypeLibelle:SCREEN-VALUE + "*"
                OR    ttTypes.cLibelle MATCHES "*" + filTypeLibelle:SCREEN-VALUE + "*"
                NO-ERROR.
        END.
        IF AVAILABLE(ttTypes) THEN do:
            REPOSITION brwTypes TO ROWID ROWID(ttTypes).
            RUN ChargeCodes.
        END.
        ELSE DO:
            BELL.
        END.
    END.
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION gDonneValeurCode C-Win 
FUNCTION gDonneValeurCode RETURNS CHARACTER
  (cCode AS CHARACTER,cParametre AS CHARACTER) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/

    DEFINE VARIABLE cTempo AS CHARACTER NO-UNDO INIT "".
    
    DEFINE BUFFER dvc_sys_pr FOR sys_pr.
    DEFINE BUFFER dvc_sys_lb FOR sys_lb.
    
    FOR EACH    dvc_sys_pr NO-LOCK
        WHERE   dvc_sys_pr.tppar = cParametre
        AND     dvc_sys_pr.cdpar = cCode
       ,FIRST   dvc_sys_lb NO-LOCK
        WHERE   dvc_sys_lb.cdlng = 0
        AND     dvc_sys_lb.nomes = dvc_sys_pr.nome1
        :
        cTempo = dvc_sys_lb.lbmes.
    END.
    
    RETURN cTempo.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

