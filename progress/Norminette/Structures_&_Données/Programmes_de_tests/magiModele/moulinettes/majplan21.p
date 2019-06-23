
/*------------------------------------------------------------------------------+
|                                                                               |
| Application      : GED                                                        |
| Programme        : majplan21.p                                                |
| Objet            : corr_typdoc_magi_gidemat_V21.xlsx                          |
|===============================================================================|
|                                                                               |
| Date de creation : 03/07/2017                                                 |
| Auteur(s)        : DM                                                         |
| Fiche            : GED                                                        |
|                                                                               |
+-------------------------------------------------------------------------------+

+-------------------------------------------------------------------------------+
| Historique des modifications                                                  |
|======+============+========+==================================================|
|  Nø  |    Date    | Auteur |                  Objet                           |
|======+============+========+==================================================|
|      |            |        |                                                  |
+-------------------------------------------------------------------------------*/


/* Activation des types de doc utilisés par un modèle bureautique */
/* Sauf Dauchez */

CURRENT-WINDOW:width-char = 160.

DEFINE VARIABLE cTpparMoulinette AS CHARACTER INIT "MOULINETTES" NO-UNDO. 
DEFINE VARIABLE cNomMoulinette  AS CHARACTER 	NO-UNDO.
DEFINE VARIABLE cLibMoulinette  AS CHARACTER 	NO-UNDO.  
DEFINE VARIABLE cCodeErr        AS CHARACTER 	NO-UNDO.

/** Test si une moulinette a déjà été passée sur la réf **/
FUNCTION TestPassageMoulinettes RETURNS LOGICAL (INPUT iSoc-In   AS INTEGER , 
                                                 INPUT cTppar-in AS CHARACTER , 
                                                 INPUT cCdpar-in AS CHARACTER ) :

    FIND FIRST aparm 
        WHERE aparm.soc-cd  = iSoc-in               
          AND aparm.tppar   = cTppar-in
          AND aparm.cdpar	= cCdPar-in NO-LOCK NO-ERROR.
    IF AVAILABLE aparm	THEN RETURN TRUE.
                        ELSE RETURN FALSE.

END FUNCTION.

/*----------------------------------------------------------------------------------------
                                MAIN-BLOCK
 ----------------------------------------------------------------------------------------*/

ASSIGN 
cNomMoulinette = "majplan21.p"
cLibMoulinette = "Mise à jour plan GED V21"
.

cCodeErr = "1".

IF TestPassageMoulinettes(0,cTpparMoulinette,cNomMoulinette) THEN RETURN cCodeErr.


/** Enregistrement du passage de la moulinette **/
RUN GestionAparmMoulinettes (INPUT 0, 
                             INPUT cTpparMoulinette, 
                             INPUT cNomMoulinette, 
                             INPUT cLibMoulinette, 
                             INPUT FALSE).


/** Code spécifique à la moulinette **/
RUN maj.

IF RETURN-VALUE <> "" THEN cCodeErr = "0".   

/** Enregistrement de l'heure de fin du passage de la moulinette **/
RUN GestionAparmMoulinettes (INPUT 0, 
                             INPUT cTpparMoulinette, 
                             INPUT cNomMoulinette,
                             INPUT "", 
                             INPUT TRUE).

RETURN cCodeErr.        


PROCEDURE maj :

    DEF VAR cTmp        AS CHAR NO-UNDO.
    DEF VAR cLib        AS CHAR NO-UNDO.
    DEF VAR cDoc        AS CHAR NO-UNDO.
    DEF VAR cDos        AS CHAR NO-UNDO.
    DEF VAR iTypDoc-cd  AS INT NO-UNDO.
    DEF VAR itmp        AS INT NO-UNDO.
    DEF VAR cListTypdoc AS LONGCHAR NO-UNDO.
    DEF VAR cList-sschem AS LONGCHAR NO-UNDO.
    DEF VAR cList        AS LONGCHAR NO-UNDO.
    DEF VAR cLibSSCHem   AS CHAR NO-UNDO.
    DEF VAR cSsChem-cd   AS CHAR NO-UNDO.
    DEF VAR cChem-cd   AS CHAR NO-UNDO.
    DEF VAR isschem AS INT NO-UNDO.

    DO TRANS ON ERROR UNDO, LEAVE :
    
        FOR First igedtypd WHERE igedtypd.typdoc-cd = 5554 :
            igedtypd.lib = "Pièces jointes lot (copro)".
        END.
        FOR First igedtypd WHERE igedtypd.typdoc-cd = 5544 :
            igedtypd.lib = "Pièces jointes lot (gérance)".
        END.
        FOR First igedtypd WHERE igedtypd.typdoc-cd = 5556 :
            igedtypd.lib = "Photos lot (copro)".
        END.
        FOR First igedtypd WHERE igedtypd.typdoc-cd = 5546 :
            igedtypd.lib = "Photos lot (gérance)".
        END.
    END. /* Trans */

END. /* maj */


/** Gestion du passage des moulinettes dans aparm **/  
PROCEDURE GestionAparmMoulinettes :

    DEFINE INPUT PARAMETER iSoc-in    AS INTEGER   NO-UNDO.                    
    DEFINE INPUT PARAMETER cTppar-in  AS CHARACTER NO-UNDO.                
    DEFINE INPUT PARAMETER cCdPar-in  AS CHARACTER NO-UNDO.                
    DEFINE INPUT PARAMETER cLib-in    AS CHARACTER NO-UNDO.                    
    DEFINE INPUT PARAMETER lMaj-in    AS LOGICAL   NO-UNDO.                    

    DEFINE VARIABLE iNumLastAparm     AS INTEGER   NO-UNDO.


    FIND FIRST atabt 
        WHERE atabt.tppar = cTppar-in NO-LOCK NO-ERROR.
    IF NOT AVAILABLE atabt THEN 
    DO :
        CREATE atabt.
        atabt.lib       = "MOULINETTES".
        atabt.par1      = "FAPARMGL.W¤106364¤0¤104558". 
        atabt.statut    = 0.
        atabt.tppar     = cTppar-in.
    END.
    
    iNumLastAparm = 0.
    FOR EACH aparm NO-LOCK
        WHERE aparm.soc-cd  = isoc-in                       
          AND aparm.tppar   = cTppar-in :

        IF iNumLastAparm < aparm.etab-cd THEN iNumLastAparm = aparm.etab-cd.            

    END.                          
    
    /** Nouveau passage d'une moulinette ***/
    IF NOT lMaj-in THEN 
    DO :
        iNumLastAparm = iNumLastAparm + 1.
        CREATE aparm.
        ASSIGN 
            aparm.soc-cd  = iSoc-in
            aparm.etab-cd = iNumLastAparm /** aparm.etab-cd = 2 si la moulinette de nom 'aparm.cdpar' a été passé deux fois **/
            aparm.tppar   = cTppar-in
            aparm.cdpar   = cCdPar-in
            aparm.zone1   = aparm.etab-cd
            .

        ASSIGN 
            aparm.zone2   = STRING(TODAY,"99/99/9999") + " - " + STRING(TIME,"HH:MM:SS") + "@"
            aparm.lib     = clib-in
            .

    END.
    ELSE DO :
        /** Stockage de l'heure de fin d'une moulinette **/
        FIND FIRST aparm 
            WHERE aparm.soc-cd  = iSoc-in
              AND aparm.etab-cd = iNumLastAparm
              AND aparm.tppar   = cTppar-in
              AND aparm.cdpar   = cCdPar-in EXCLUSIVE-LOCK NO-ERROR.
        IF AVAILABLE aparm  
        THEN DO :
            IF NUM-ENTRIES(aparm.zone2,"@") > 1 THEN
                entry(2,aparm.zone2,"@")  = STRING(TODAY,"99/99/9999") + " - " + STRING(TIME,"HH:MM:SS").
            IF clib-in <> "" THEN aparm.lib  = clib-in.
        END.

    END.                            

END PROCEDURE.
