/*------------------------------------------------------------------------
File        : expweb.i
Purpose     : procédures communes aux exports vers GINET-DATA
Author(s)   : JR 0408/0042 09/02/24 -  GGA 2017/10/20
Notes       : reprise cadb\comm\expweb.i pour l'instant seulement reprise de comm/expweb.i2 
----------------------------------------------------------------------*/
/*
|======+============+========+==============================================|
|  Nø  |    Date    | Auteur |                  Objet                       |
|======+============+========+==============================================|
| 0001 | 16/09/2013 |  IA    | 0108/0159 Prelèvement en ligne               |
| 0002 | 21/05/2014 |  DM    | 0514/0138 Le caractère O n'est pas valide... |
| 0003 | 06/01/2015 |  DM    | pb buffer                                    |
| 0004 | 03/02/2015 |  DM    | 0115/0253 Tiers representés                  |
| 0005 | 08/12/2015 |  OF    | 1215/0038 récupération email GIExtranet et   |
|      |            |        | mode d'envoi                                 |
| 0006 | 05/01/2016 |  OF    | 0915/0240 Prélèvements web                   |
| 0007 | 26/01/2016 |  DM    | 0915/0110 Documents giextranet lsttiers.txt  |
| 0008 | 06/04/2016 |  OF    | 1215/0038 Mise au point                      |
| 0009 | 12/09/2016 |   NP   | 0516/0125 Add gestion LRE                    |
| 0010 | 23/02/2017 |   SY   | Modification test mandat avec/sans indivision|
|      |            |        | (0217/0117)                                  |
| 0011 | 23/02/2017 |   CC   | Problème web-fgouvert                        |
*/

{adblib/include/expweb2.i}  /* f_ctratactiv  f_ctrat_tiers_actif */

/*gga
FUNCTION f_crypt RETURNS CHAR (INPUT cCle AS CHAR, INPUT cChaine AS CHAR) :

    DEF VAR cTbl AS CHAR INITIAL "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ".
    DEF VAR iLettre AS INT.
    DEF VAR cResult AS CHAR.
    DEF VAR cNewASc AS CHAR.
    
    DEF VAR iNewPos AS INT.
    DEF VAR iTmp AS INT.
    DEF VAR iDebut AS INT.

    iDebut = RANDOM(1,LENGTH(cCle)).
    iLettre = iDebut.

    cResult = SUBSTRING(cTbl,idebut,1).
    
    DO iTmp = 1 TO LENGTH(cChaine):
    
        iLettre = iLettre + 1.
        IF iLettre > LENGTH(cCle)  THEN iLettre = iDebut.
    
        iNewPos = 
                  INDEX(cTbl,SUBSTRING(cCHaine,iTmp,1)) +
                  INDEX(cTbl,SUBSTRING(cCle,iLettre,1)).
                  .
        
        IF iNewPos > LENGTH(cTbl) THEN iNewPos = iNewPos - (LENGTH(cTbl)).

        cResult = cResult + SUBSTRING(cTbl,iNewPos,1).
    
    END.
    
    RETURN cResult.

END.

FUNCTION f_decrypt RETURNS CHAR (INPUT cCle AS CHAR, INPUT cChaine AS CHAR) :

    DEF VAR cTbl AS CHAR INITIAL "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ".

    DEF VAR iLettre AS INT.
    DEF VAR cResult AS CHAR.
    DEF VAR cNewASc AS CHAR.
    DEF VAR iDebut  AS INT.
    
    DEF VAR iNewPos AS INT.
    DEF VAR iTmp AS INT.

    iDebut = INDEX(cTbl,SUBSTRINg(cCHaine,1,1)).
    iLettre = iDebut.
    
    DO iTmp = 2 TO LENGTH(cChaine):
    
        iLettre = iLettre + 1.
        IF iLettre > LENGTH(cCle) THEN iLettre = iDebut.
    
        iNewPos = 
                  INDEX(cTbl,SUBSTRING(cCHaine,iTmp,1)) -
                  INDEX(cTbl,SUBSTRING(cCle,iLettre,1)).
                  .
        
        IF iNewPos < 1 THEN iNewPos = iNewPos + (LENGTH(cTbl)).

        cResult = cResult + SUBSTRING(cTbl,iNewPos,1).
    
    END.
    
    RETURN cResult.

END.


FUNCTION f_cremdp RETURNS CHAR : /* Genere un mot de passe aléatoire de 8 caracteres alphanumériques */

    DEF VAR cLstChar AS CHAR INITIAL "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghkmnopqrstuvwxyz23456789".
    DEF VAR i AS INT.
    DEF VAR cMdp AS CHAR NO-UNDO.
    
    DO i = 1 TO 8 :
        cMdp = cMdp + SUBSTRING(cLstChar,RANDOM(1,LENGTH(cLstChar)),1).            
    END.
    RETURN cMdp.

END.


PROCEDURE Liste_Tiers_Actifs_Ginet :
    
    DEFINE INPUT PARAMETER RpGic-in     AS CHARACTER    NO-UNDO.
    DEFINE INPUT PARAMETER RpRunTmp-in  AS CHARACTER    NO-UNDO.
        
    DEFINE VARIABLE cFicListeTiersActif AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE cLigne              AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE cchaine             AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE dDate               AS DATE         NO-UNDO. /* DM 0412/0084 */
    DEFINE VARIABLE cDate               AS CHARACTER    NO-UNDO. /* DM 0412/0084 */
    DEFINE VARIABLE cLstAcces           AS CHARACTER    NO-UNDO. /* DM 0412/0084 */
    DEFINE VARIABLE FgTrouve            AS LOGICAL      NO-UNDO. /* DM 0412/0084 */
    DEFINE VARIABLE iTmp                AS INTEGER      NO-UNDO. /* DM 0412/0084 */
    DEFINE VARIABLE cAcces              AS CHARACTER    NO-UNDO. /* DM 0412/0084 */
    DEFINE VARIABLE NoIdent             AS INTEGER      NO-UNDO. /* IA 0108/0159 */
    DEFINE VARIABLE cEmailWeb           AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE cModeEnvoi          AS CHARACTER    NO-UNDO.
    
    DEFINE BUFFER broles FOR ROLES. /* DM 0412/0084 */
    DEFINE BUFFER btiers FOR tiers. /* DM 0412/0084 */
    DEFINE BUFFER bctrat FOR ctrat. /* DM 0412/0084 */
    
    cFicListeTiersActif = RpGic-in + "lsttiers.txt".
    
    FOR EACH TbTiersGinet :     DELETE TbTiersGinet.        END.
    FOR EACH TbCttTiersGinet :  DELETE TbCttTiersGinet.     END.   
    EMPTY TEMP-TABLE TbTiersRep. /* DM 0115/0253 */
    EMPTY TEMP-TABLE TbDoc.      /* DM 0915/0110 */
        
/*    DM 0412/0084
*     IF SEARCH(cFicListeTiersActif) NE ? THEN DO :
*         INPUT /** STREAM stCompta **/ FROM VALUE (cFicListeTiersActif).
*             REPEAT :
*               IMPORT /** STREAM stCompta **/ UNFORMATTED cligne.
*               cligne = TRIM (cligne).
*               IF cligne <> "" AND NUM-ENTRIES (cligne,";") >= 2 THEN DO :
*                   CREATE TbTiersGinet.
*                   ASSIGN
*                       TbTiersGinet.nousr = INTEGER ( TRIM(ENTRY (2,cligne,";")))
*                       TbTiersGinet.cdrgt = TRIM(ENTRY (1,cligne,";"))
*                       .
*               END.
*            END.
*         INPUT /** STREAM StCompta **/ CLOSE.
*     END.     
*  */    

    /* DM 0412/0084 */
    
    
    /* RAZ des tiers représentés 0011 */
    FOR EACH tiers NO-LOCK:
        IF tiers.web-fgouvert AND tiers.web-dateouverture = ? THEN DO:
         FIND btiers WHERE ROWID(btiers) = ROWID(tiers) EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
           IF AVAILABLE btiers THEN btiers.web-fgouvert = FALSE.          
        END.  
    END.  
    
    RELEASE btiers.
    
    
    /* Import des tiers activés */
    IF SEARCH(cFicListeTiersActif) NE ? THEN DO :
        
        INPUT FROM VALUE (cFicListeTiersActif).
        
        REPEAT TRANSACTION :
                
                IMPORT UNFORMATTED cligne.
                cligne = TRIM (cligne).
                
                IF cligne = "" THEN NEXT.
                
                /* IF cligne <> "" AND NUM-ENTRIES (cligne,";") >= 2 AND ENTRY(1,cligne,";")="@USER" THEN DO :  */   /* modif IA 0108/0159 */
                IF ENTRY(1,cligne,";")="@USER" THEN DO :
                    dDate = ?.
                    cDate = TRIM(SUBSTRING(ENTRY (3,cligne,";"),1,10)) NO-ERROR.
                    
                    IF NUM-ENTRIES (cligne,";") <= 2 THEN DO :
                        cDate = "2012-01-01". /* Ancienne version du fichier -> initialisation des tiers actifs */
                    END.
                                        
                    ASSIGN
                    dDate = DATE(INT(ENTRY(2,cDate,"-")),
                                 INT(ENTRY(3,cDate,"-")),
                                 INT(ENTRY(1,cDate,"-"))) NO-ERROR.
                                 
                    /* DM 0115/0253 */
                    IF NUM-ENTRIES(cLigne,";") >= 4 AND ENTRY(4,cligne,";") = "REPRESENTE" THEN DO :
                        FIND tiers WHERE tiers.notie = INTEGER ( TRIM(ENTRY (2,cligne,";"))) NO-LOCK NO-ERROR.
                        IF AVAILABLE tiers THEN DO :
                            FIND TbTiersRep WHERE TbTiersRep.notie = tiers.NOTie NO-ERROR.
                            IF NOT AVAILABLE TbTiersRep THEN DO :
                                CREATE TbTiersRep.
                                TbTiersRep.NOTie = tiers.notie.
                            END.
                        END.                            
                    END.
                    /* FIN DM */

                    /* Maj du tiers dans la base */                     
/*                     IF dDate <> ? 
*                     THEN DO:                      
*                         FIND tiers WHERE tiers.notie = INTEGER ( TRIM(ENTRY (2,cligne,";"))) NO-LOCK NO-ERROR.
*                         IF AVAILABLE tiers AND tiers.web-fgouvert = FALSE THEN DO :
*                             FIND CURRENT tiers EXCLUSIVE-LOCK NO-ERROR.
*                     
*                             tiers.web-fgouvert = TRUE.   /* le tiers a ouvert son acces */
*                             tiers.web-dateouverture = dDate.
*                             
*                             IF cdate = "2012-01-01" THEN DO : /* 1/1/2012 = date d'initialisation, permet d'initialiser tous les contrats des tiers activés */
* 
*                                   FOR EACH  ROLES NO-LOCK WHERE roles.notie = tiers.notie :
*                                       CASE role.tprol :
*                                           WHEN "00008" THEN DO : /* copropriétaire */
*                                               FOR EACH ctrat WHERE ctrat.tprol = role.tprol
*                                                               AND ctrat.norol = role.norol
*                                                               AND ctrat.tpcon = "01004"
*                                                               AND ctrat.ntcon <> "03094"         /* plus de baux "Spécial vacant" */
*                                                               :
*                                                               
*                                                   FIND FIRST tmp-95
*                                                     WHERE tmp-95.etab-cd = INT(SUBSTRING(STRING(ctrat.nocon,"9999999999"),1,5))
*                                                       AND tmp-95.actif = TRUE
*                                                       NO-LOCK NO-ERROR.
*                                                       
*                                                   IF AVAILABLE tmp-95 THEN DO :                                                      
*                                                       /* Est-ce une indivision ? */
*                                                       FgTrouve = FALSE.
*                                                       FOR EACH intnt  WHERE intnt.tpcon = ctrat.tpcon
*                                                                                     AND intnt.nocon = ctrat.nocon
*                                                                                     AND intnt.tpidt = "00016"
*                                                                                     NO-LOCK,
*                                                                     FIRST broles     WHERE broles.tprol = intnt.tpidt
*                                                                                     AND broles.norol = intnt.noidt
*                                                                                     NO-LOCK,
*                                                                     FIRST btiers WHERE btiers.notie = bROLES.notie NO-LOCK :
*                                                         FgTrouve = TRUE.
*                                                       END.
*                                                       IF AVAILABLE tmp-95 
*                                                          AND FgTrouve = FALSE /* DM 0514/0138 */
*                                                         THEN ctrat.web-div = "O". /* Uniquement si l'immeuble est transféré */
*                                                       
*                                                   END.                                                      
*                                               END.
*                                           END.
*                                           WHEN "00019" THEN DO : /* locataire */
*                                               FOR EACH ctrat WHERE ctrat.tprol = role.tprol
*                                                               AND ctrat.norol = role.norol
*                                                               AND ctrat.tpcon = "01033"
*                                                               AND ctrat.ntcon <> "03094"          /* plus de baux "Spécial vacant" */
*                                                                :
*                                                   ctrat.web-div = "O".
*                                               END.
*                                           END.
*                                           WHEN "00022" THEN DO : /* proprietaire */
*                                               FOR EACH ctrat WHERE ctrat.tprol = role.tprol
*                                                               AND ctrat.norol = role.norol
*                                                               AND ctrat.tpcon = "01030"
*                                                               AND ctrat.ntcon <> "03094"          /* plus de baux "Spécial vacant" */
*                                                                  :
*                                                   /* Est-ce une indivision ? */
*                                                   FgTrouve = FALSE.
*                                                   FOR EACH intnt  WHERE intnt.tpcon = ctrat.tpcon
*                                                                                 AND intnt.nocon = ctrat.nocon
*                                                                                 AND intnt.tpidt = "00016"
*                                                                                 NO-LOCK,
*                                                                 FIRST broles     WHERE broles.tprol = intnt.tpidt
*                                                                                 AND broles.norol = intnt.noidt
*                                                                                 NO-LOCK,
*                                                                 FIRST btiers WHERE btiers.notie = bROLES.notie NO-LOCK :
*                                                     FgTrouve = TRUE.
*                                                   END.
*                                                   IF FgTrouve = FALSE THEN ctrat.web-div = "O".
*                                               END.
*                                           END.
*                                           WHEN "00016" THEN DO : /* indivisaire */
*                                            FOR EACH intnt  WHERE intnt.tpidt = ROLES.tprol
*                                                              AND intnt.noidt = role.norol
*                                                              AND intnt.tpidt = "00016" 
*                                                              AND LOOKUP(intnt.tpcon,"01030,01004") > 0
*                                                              NO-LOCK :
*                                              FIND ctrat WHERE ctrat.tpcon = intnt.tpcon
*                                                           AND ctrat.nocon = intnt.nocon
*                                                           EXCLUSIVE-LOCK NO-ERROR.
*                                              IF AVAILABLE ctrat THEN DO :                                                     
*                                                 cLstAcces = ctrat.web-div.
*                                                 
*                                                 FgTrouve = FALSE.
*                                                 DO iTmp = 1 TO NUM-ENTRIES(cLstAcces,"@") :
*                                                     cAcces = ENTRY(iTmp,cLstAcces,"@"). /* 1 indivisaire -> "NoIdt:O/N/ :date desact " */
*                                                     IF INT(ENTRY(1,cAcces,":")) = intnt.noidt
*                                                         THEN  DO :
*                                                             ENTRY(2,cAcces,":") = "O".
*                                                             ENTRY(3,cAcces,":") = "".
*                                                             ENTRY(iTmp,cLstAcces,"@") = cAcces.
*                                                             FgTrouve = TRUE.
*                                                             LEAVE.
*                                                         END.                                        
*                                                 END.
*                                                 
*                                                 IF FgTrouve = FALSE 
*                                                 THEN DO :
*                                                     cLstAcces = cLstAcces + (IF cLstAcces = "" THEN "" ELSE "@") + 
*                                                                             STRING(intnt.noidt) + ":" + "O" + ":" + 
*                                                                                 "" .
*                                                 END.
*                                                 
*                                                 ctrat.web-div = cLstAcces.
* 
*                                              END.                                                    
*                                            END. /* for each intnt */
*                                           END.
*                                       END CASE.
*                                   END. /* for each roles */
*                             
*                             END. /* 1/1/2012 */
*                             
*                         END.
*                         RELEASE tiers.
*                     END. */ /**Modif OF le 08/12/15**/

                    /**Ajout OF le 08/12/15**/
                    cEmailWeb = IF NUM-ENTRIES(cligne,";") > 4 THEN TRIM(ENTRY(5,cligne,";")) ELSE "".
                    cModeEnvoi = IF NUM-ENTRIES(cligne,";") > 5 THEN TRIM(ENTRY(6,cligne,";")) ELSE "".
                    /** **/
                    
                    FIND tiers WHERE tiers.notie = INTEGER ( TRIM(ENTRY (2,cligne,";"))) NO-LOCK NO-ERROR.
                    IF AVAILABLE tiers THEN DO :
                        FIND CURRENT tiers EXCLUSIVE-LOCK NO-ERROR.
                
                        IF tiers.web-fgouvert = FALSE THEN
                            ASSIGN
                            tiers.web-fgouvert = TRUE   /* le tiers a ouvert son acces */
                            tiers.web-dateouverture = dDate
                            .
                        
                          FOR EACH  ROLES NO-LOCK WHERE roles.notie = tiers.notie :
                              CASE role.tprol :
                                  WHEN "00008" THEN DO : /* copropriétaire */
                                      FOR EACH ctrat WHERE ctrat.tprol = role.tprol
                                                       AND ctrat.norol = role.norol
                                                       AND ctrat.tpcon = "01004"
                                                       AND ctrat.ntcon <> "03094"         /* plus de baux "Spécial vacant" */
                                                       EXCLUSIVE-LOCK
                                                       :
                                                      
                                          FIND FIRST tmp-95
                                            WHERE tmp-95.etab-cd = INT(SUBSTRING(STRING(ctrat.nocon,"9999999999"),1,5))
                                              AND tmp-95.actif = TRUE
                                              NO-LOCK NO-ERROR.
                                              
                                              /* Est-ce une indivision ? */
                                              FgTrouve = FALSE.
                                              FOR EACH intnt  WHERE intnt.tpcon = ctrat.tpcon
                                                                AND intnt.nocon = ctrat.nocon
                                                                AND intnt.tpidt = "00016"
                                                                NO-LOCK,
                                                            FIRST broles WHERE broles.tprol = intnt.tpidt
                                                                         AND broles.norol = intnt.noidt
                                                                         NO-LOCK,
                                                            FIRST btiers WHERE btiers.notie = bROLES.notie NO-LOCK :
                                                  FgTrouve = TRUE.
                                                  RUN MajEmail(INPUT broles.tprol,
                                                               INPUT broles.norol,
                                                               INPUT cEmailWeb).
                                                  RUN MajMadisp(INPUT ROWID(intnt),
                                                                INPUT "",
                                                                INPUT 0,
                                                                INPUT cModeEnvoi).
                                              END.
                                              IF AVAILABLE tmp-95 AND FgTrouve = FALSE AND cdate = "2012-01-01"
                                                  THEN ctrat.web-div = "O". /* Uniquement si l'immeuble est transféré */

                                              /*Ce n'est pas une indivision*/
                                              IF NOT FgTrouve THEN DO:
                                                  RUN MajEmail(INPUT ctrat.tprol,
                                                               INPUT ctrat.norol,
                                                               INPUT cEmailWeb).
                                                  RUN MajMadisp(INPUT ROWID(ctrat),
                                                                INPUT "",
                                                                INPUT 0,
                                                                INPUT cModeEnvoi).
                                              END.
                                      END.
                                  END.
                                  WHEN "00019" THEN DO : /* locataire */
                                      FOR EACH ctrat WHERE ctrat.tprol = role.tprol
                                                      AND ctrat.norol = role.norol
                                                      AND ctrat.tpcon = "01033"
                                                      AND ctrat.ntcon <> "03094"          /* plus de baux "Spécial vacant" */
                                                       :
                                          IF cdate = "2012-01-01" THEN ctrat.web-div = "O".
                                          RUN MajEmail(INPUT ctrat.tprol,
                                                       INPUT ctrat.norol,
                                                       INPUT cEmailWeb).
                                          RUN MajMadisp(INPUT ?,
                                                        INPUT ctrat.tpcon,
                                                        INPUT ctrat.nocon,
                                                        INPUT cModeEnvoi).
                                      END.
                                  END.
                                  WHEN "00022" THEN DO : /* proprietaire */
                                      FOR EACH ctrat WHERE ctrat.tprol = role.tprol
                                                      AND ctrat.norol = role.norol
                                                      AND ctrat.tpcon = "01030"                                                 
                                                      EXCLUSIVE-LOCK:

                                          FgTrouve = FALSE.
                                          /* Est-ce une indivision ? */
                                          IF LOOKUP( ctrat.ntcon , "03030,03093") > 0 THEn DO:          /* SY 23/02/2017 */                                   
                                              FOR EACH intnt  WHERE intnt.tpcon = ctrat.tpcon
                                                                AND intnt.nocon = ctrat.nocon
                                                                AND intnt.tpidt = "00016"
                                                                NO-LOCK,
                                                            FIRST broles WHERE broles.tprol = intnt.tpidt
                                                                           AND broles.norol = intnt.noidt
                                                                           NO-LOCK,
                                                            FIRST btiers WHERE btiers.notie = bROLES.notie NO-LOCK :
                                                  FgTrouve = TRUE.
                                                  RUN MajEmail(INPUT broles.tprol,
                                                               INPUT broles.norol,
                                                               INPUT cEmailWeb).
                                                  RUN MajMadisp(INPUT ROWID(intnt),
                                                                INPUT "",
                                                                INPUT 0,
                                                                INPUT cModeEnvoi).
                                              END.
                                          END.
                                          ELSE DO:        /*IF FgTrouve = FALSE THEN DO:*/ /* SY 23/02/2017 */                                                                              
                                              IF cdate = "2012-01-01" THEN ctrat.web-div = "O".
                                              RUN MajEmail(INPUT ctrat.tprol,
                                                           INPUT ctrat.norol,
                                                           INPUT cEmailWeb).
                                              RUN MajMadisp(INPUT ?,
                                                            INPUT ctrat.tpcon,
                                                            INPUT ctrat.nocon,
                                                            INPUT cModeEnvoi).
                                          END.
                                      END.
                                  END.
                                  WHEN "00016" THEN DO : /* indivisaire */
                                        FOR EACH intnt  WHERE intnt.tpidt = ROLES.tprol
                                                         AND intnt.noidt = role.norol
                                                         AND intnt.tpidt = "00016" 
                                                         AND LOOKUP(intnt.tpcon,"01030,01004") > 0
                                                         NO-LOCK :
                                             FIND ctrat WHERE ctrat.tpcon = intnt.tpcon
                                                          AND ctrat.nocon = intnt.nocon
                                                          EXCLUSIVE-LOCK NO-ERROR.
                                             IF AVAILABLE ctrat THEN DO :                                                     
                                                cLstAcces = ctrat.web-div.
                                                
                                                FgTrouve = FALSE.
                                                DO iTmp = 1 TO NUM-ENTRIES(cLstAcces,"@") :
                                                    cAcces = ENTRY(iTmp,cLstAcces,"@"). /* 1 indivisaire -> "NoIdt:O/N/ :date desact " */
                                                    IF INT(ENTRY(1,cAcces,":")) = intnt.noidt
                                                        THEN  DO :
                                                            ENTRY(2,cAcces,":") = "O".
                                                            ENTRY(3,cAcces,":") = "".
                                                            ENTRY(iTmp,cLstAcces,"@") = cAcces.
                                                            FgTrouve = TRUE.
                                                            LEAVE.
                                                        END.                                        
                                                END.
                                                
                                                IF FgTrouve = FALSE AND cdate = "2012-01-01"
                                                THEN DO :
                                                    cLstAcces = cLstAcces + (IF cLstAcces = "" THEN "" ELSE "@") + 
                                                                            STRING(intnt.noidt) + ":" + "O" + ":" + 
                                                                                "" .
                                                END.
                                                
                                                ctrat.web-div = cLstAcces.
                                            
                                             END.
                                             RUN MajEmail(INPUT intnt.tpidt,
                                                          INPUT intnt.noidt,
                                                          INPUT cEmailWeb).
                                             RUN MajMadisp(INPUT ROWID(intnt),
                                                           INPUT "",
                                                           INPUT 0,
                                                           INPUT cModeEnvoi).
                                        END. /* for each intnt */
                                  END. /* WHEN "00016" */
                              END CASE.
                          END. /* for each roles */
                        
                    END.
                    RELEASE tiers.

                END.
                /* DM 0915/0110 */
                ELSE IF ENTRY(1,cligne,";") = "@DOC" THEN DO : /* @DOC;00006/00067/nomdufichier.pdf */
                    CREATE TbDoc.
                    TbDoc.NomDoc = ENTRY(2,cligne,";").
                END.                    
                /* FIN DM 0915/0110 */
                ELSE DO: 
                    
                    /* modif IA 0108/0159 */
/*                     IF ENTRY(1,cligne,";")="@PRLV" AND NUM-ENTRIES (cligne,";") = 10 THEN DO :
*                         
*                         FIND prlvnet WHERE prlvnet.soc-cd = GiCodeSoc
*                                        AND prlvnet.noprel = INT(ENTRY(2,cligne,";")) 
*                                        USE-INDEX prlvnet-i NO-ERROR.
*                                        
*                         IF AVAILABLE prlvnet THEN NEXT.
*                         
*                         cchaine = STRING(INT(ENTRY(4,cligne,";")),"9999999999").
*                         cDate   = ENTRY(5,cligne,";").
*                         dDate   = DATE(INT(ENTRY(2,cDate,"-")), INT(ENTRY(3,cDate,"-")), INT(ENTRY(1,cDate,"-"))).
*                     
*                         CREATE prlvnet.
*                         ASSIGN 
*                         prlvnet.soc-cd      = GiCodeSoc
*                         prlvnet.etab-cd     = INT(SUBSTRING(cchaine,1,5))
*                         prlvnet.noprel      = INT(ENTRY(2,cligne,";"))
*                         prlvnet.notie       = INT(ENTRY(3,cligne,";"))       /* notie            */
*                         prlvnet.cpt-cd      = ENTRY(4,cligne,";")            /* nocon            */
*                         prlvnet.dvalid      = dDate                          /* datop            */ 
*                         prlvnet.sscoll-cle  = ENTRY(6,cligne,";")            /* collectif        */
*                         prlvnet.lib-ecr     = ENTRY(7,cligne,";")            /* libelle          */
*                         prlvnet.mtprel      = DECIMAL(ENTRY(8,cligne,";"))   /* Montant prélevé  */
*                         prlvnet.norum       = ENTRY(9,cligne,";")            /* RUM              */
*                         prlvnet.iban        = ENTRY(10,cligne,";")           /* IBAN             */
*                         prlvnet.statut      = 4                              /* statut indiquant l'intégration sur le PC */          
*                         .
*                                            
*                     END. */ /**Modif OF le 05/01/16**/
                    /* fin modif 0108/0159 */              
                    
                END.
             END.  /* end  du repeat */
        INPUT  CLOSE.
    END.     
    
    /* Création des tiers activés */
    
    FOR EACH tiers NO-LOCK : 
        IF f_ctrat_tiers_actif(tiers.notie,TRUE) THEN DO :
            FIND  TbTiersGinet 
                WHERE TbTiersGinet.nousr = tiers.notie
                  AND TbTiersGinet.cdrgt = "@USER"
                  NO-LOCK NO-ERROR.
        
            CREATE TbTiersGinet.
            ASSIGN
                TbTiersGinet.nousr = tiers.notie
                TbTiersGinet.cdrgt = "@USER"
                .
        END.                
        
    END.        
    
    /* FIN DM */
    
    FOR EACH TbTiersGinet :
    
        FOR EACH roles WHERE roles.notie = TbTiersGinet.nousr NO-LOCK:
    
            FOR EACH intnt WHERE intnt.tpidt = roles.tprol
                           AND   intnt.noidt = roles.norol                   
                          /* DM 0412/0084 */
                           AND  LOOKUP(intnt.tpcon + "|" + intnt.tpidt,
                                "01004|00008,01004|00016,01030|00016,01030|00022,01033|00019") > 0
                          /* FIN DM 0412/0084 */
                           NO-LOCK :
                           
                /* tpcon = 01004 tpidt 00008 copropriétaire */
                /* tpcon = 01004 tpidt 00016 copropriétaire indivisaire */
                /* tpcon = 01030 tpidt 00016 proprietaire indivisaire */
                /* tpcon = 01030 tpidt 00022 Proprietaire */
                /* tpcon = 01033 tpidt 00019 locataire */
                           
                FIND bctrat WHERE bctrat.tpcon = intnt.tpcon
                          AND bctrat.nocon = intnt.nocon
                          NO-LOCK NO-ERROR.
                IF NOT AVAILABLE bctrat THEN NEXT.                              

        
                CASE intnt.tpcon :
                    WHEN "01030" THEN DO :
                    
                        IF (IF intnt.tpidt = "00016" /* Indivisaire */
                                        THEN ENTRY(1,f_ctratactiv(ROWID(intnt))) = "O"                                      
                                        ELSE ENTRY(1,f_ctratactiv(ROWID(bctrat))) = "O") = TRUE 
                        THEN DO :                                        
                            CREATE TbCttTiersGinet.
                            ASSIGN 
                                TbCttTiersGinet.nousr = TbTiersGinet.nousr
                                TbCttTiersGinet.cdrgt = TbTiersGinet.cdrgt
                                TbCttTiersGinet.tpcon = intnt.tpcon
                                TbCttTiersGinet.nocon = intnt.nocon
                                
                                TbCttTiersGinet.tpidt = intnt.tpidt
                                TbCttTiersGinet.noidt = intnt.noidt
                                
                                .
                        END.                                
                    END.
                    WHEN "01033" THEN DO :
                    
                        IF ENTRY(1,f_ctratactiv(ROWID(bctrat))) = "O"
                        THEN DO :
                    
                            /** intntn.nocon = XXXXXYYYYY, XXXXX=Mandat , YYYYY=Compte **/
                            cchaine = STRING(intnt.nocon).
                            cchaine = SUBSTRING ( cchaine,1,LENGTH(cchaine) - 5).
                            
                            CREATE TbCttTiersGinet.
                            ASSIGN 
                                TbCttTiersGinet.nousr = TbTiersGinet.nousr
                                TbCttTiersGinet.cdrgt = TbTiersGinet.cdrgt
                                TbCttTiersGinet.tpcon = "01030"
                                TbCttTiersGinet.nocon = INTEGER (cchaine)
                                
                                TbCttTiersGinet.tpidt = intnt.tpidt
                                TbCttTiersGinet.noidt = intnt.noidt
                                .
                        END.                                
                        
                    END.
                    WHEN "01004" THEN DO :
                        IF (IF intnt.tpidt = "00016" /* Indivisaire */
                                        THEN ENTRY(1,f_ctratactiv(ROWID(intnt))) = "O"                                      
                                        ELSE ENTRY(1,f_ctratactiv(ROWID(bctrat))) = "O") = TRUE 
                        THEN DO :                                        

                            /** intntn.nocon = XXXXXYYYYY, XXXXX=Mandat , YYYYY=Compte **/
                            cchaine = STRING(intnt.nocon).
                            cchaine = SUBSTRING ( cchaine,1,LENGTH(cchaine) - 5).
                            
                            CREATE TbCttTiersGinet.
                            ASSIGN 
                                TbCttTiersGinet.nousr = TbTiersGinet.nousr
                                TbCttTiersGinet.cdrgt = TbTiersGinet.cdrgt                    
                                TbCttTiersGinet.tpcon = "01003"
                                TbCttTiersGinet.nocon = INTEGER (cchaine)
                                
                                TbCttTiersGinet.tpidt = intnt.tpidt
                                TbCttTiersGinet.noidt = intnt.noidt.
                        END.                                
                    END.
                END CASE.                        
                    
            END.
            
        END.
        
    END.
    
    /** TEST **/        
    
    OUTPUT TO VALUE ( RpRunTmp-in  + "lstmdt.01").
        FOR EACH TbTiersGinet:
            PUT UNFORMATTED SKIP         
                            "TIERS ACTIVES : "
                            TbTiersGinet.cdrgt " " 
                            TbTiersGinet.nousr .
        END.
        FOR EACH TbCttTiersGinet:
            PUT UNFORMATTED SKIP      
                            "ROLES ACTIVES : "    
                            TbCttTiersGinet.cdrgt " " 
                            TbCttTiersGinet.nousr " "         
                            TbCttTiersGinet.tpcon " " 
                            TbCttTiersGinet.nocon " "
                            TbCttTiersGinet.tpidt " " 
                            TbCttTiersGinet.noidt.
        END.
    OUTPUT CLOSE.
    /**/
    
END PROCEDURE. /** Liste_Tiers_Actifs_Ginet **/

PROCEDURE load_95 :

    DEF BUFFER baparm FOR aparm.
    DEF BUFFER bietab FOR ietab.
    DEF BUFFER bisoc  FOR isoc.
    
    DEF VAR i AS INT NO-UNDO.

    EMPTY TEMP-TABLE tmp-95.

    FOR EACH bisoc WHERE bisoc.specif-cle = 1000 NO-LOCK :

        FOR EACH bietab WHERE bietab.soc-cd = bisoc.soc-cd
                         AND bietab.profil-cd = 91 
                       NO-LOCK :
            CREATE tmp-95.
            ASSIGN tmp-95.etab-cd = bietab.etab-cd
                   tmp-95.nom = bietab.nom
                   tmp-95.actif = FALSE 
                   tmp-95.fgLRE = FALSE     /* NP 0516/0125 */
                   .           
        END.
    
    END.        

    FIND FIRST baparm WHERE baparm.soc-cd    = 0
                       AND baparm.etab-cd    = 0
                       AND baparm.tppar      = "TWEB2"
                       AND baparm.cdpar      = "ETAT95"
                     NO-LOCK NO-ERROR.
    IF AVAILABLE baparm THEN
    DO:
        DO i = 1 TO NUM-ENTRIES(baparm.zone2,"@") : 
            FIND FIRST tmp-95 
                WHERE tmp-95.etab-cd = INTEGER(ENTRY(i, baparm.zone2,"@")) NO-ERROR.
            IF AVAILABLE tmp-95 THEN 
                ASSIGN 
                    tmp-95.actif = TRUE
                    tmp-95.fgLRE = TRUE         /* Si un immeuble a GI-Extranet, il a obligatoirement LRE */
                    .
        END.
        /* NP 0516/0125 add LRE */
        DO i = 1 TO NUM-ENTRIES(baparm.zone3,"@") : 
            FIND FIRST tmp-95 
                WHERE tmp-95.etab-cd = INTEGER(ENTRY(i, baparm.zone3,"@")) NO-ERROR.
            IF AVAILABLE tmp-95 THEN 
                ASSIGN tmp-95.fgLRE = TRUE.     /* Immeuble avec LRE seul */
        END.
    END.

END PROCEDURE. /* load_95 */ 


/* DM 0412/0084 Fin DM */

PROCEDURE maj_id :
    
    DEF INPUT PARAMETER rRow-In AS ROWID NO-UNDO.
    DEF BUFFER btiers FOR tiers.
    
    DO TRANS :
        FIND btiers WHERE ROWID(btiers) = rRow-In NO-LOCK NO-ERROR.        
        IF AVAILABLE btiers AND btiers.web-id = "" THEN DO :
            FIND CURRENT btiers EXCLUSIVE-LOCK NO-ERROR.
            btiers.web-id  = f_crypt("LAGESTIONINTEGRALE",STRING(GiCodeSoc,"99999") + STRING(/* DM 06/01/2015 tiers.notie */ btiers.notie )).
            btiers.web-mdp = f_cremdp(). /* Stocké en clair */
        END.
        RELEASE btiers.
    END.    

END. /* maj_id */

/* FIN DM */

PROCEDURE MajEmail:

DEFINE INPUT PARAMETER cTpRol AS CHARACTER  NO-UNDO.
DEFINE INPUT PARAMETER iNoRol AS INTEGER    NO-UNDO.
DEFINE INPUT PARAMETER cEmail AS CHARACTER  NO-UNDO.

DEFINE VARIABLE iPos      AS INTEGER    NO-UNDO.
    

    IF cEmail = "" THEN DO:
        /*MLog("Email extranet non renseigné, tpidt = " + cTpRol + " - noidt = " + STRING(iNoRol)).*/
        RETURN.
    END.

    /*On recherche l'email extranet*/
    FIND FIRST telephones WHERE telephones.tpidt = cTpRol
                            AND telephones.noidt = iNoRol
                            AND telephones.tptel = "00003"
                            AND telephones.cdtel = "00025"
                            EXCLUSIVE-LOCK NO-ERROR.
    /*S'il n'a pas changé, on sort*/
    IF AVAILABLE telephones AND telephones.notel = cEmail THEN RETURN.
    /*S'il a pas changé, on le met à jour*/
    ELSE IF AVAILABLE telephones AND telephones.notel NE cEmail THEN DO:
        MLog("Maj email extranet, tpidt = " + cTpRol + " - noidt = " + STRING(iNoRol) + " - Email: " + telephones.notel + " -> " + cEmail).
        ASSIGN
            telephones.notel = cEmail
            telephones.cdmsy = "GIExtranet"
            telephones.dtmsy = TODAY
            telephones.hemsy = TIME
            .
    END.
    /*S'il n'existe pas, on le crée.
      S'il existe mais non typé email giextranet, on met à jour le type*/
    ELSE DO:
        FIND FIRST telephones WHERE telephones.tpidt = cTpRol
                                AND telephones.noidt = iNoRol
                                AND telephones.tptel = "00003"
                                /*AND telephones.cdtel = "00025"*/
                                AND telephones.notel = cEmail
                                EXCLUSIVE-LOCK NO-ERROR.
        IF NOT AVAILABLE telephones THEN DO:
            FIND LAST telephones WHERE telephones.tpidt = cTpRol
                                   AND telephones.noidt = iNoRol
                                   NO-LOCK NO-ERROR.
            iPos = IF AVAILABLE telephones THEN telephones.nopos + 1
                   ELSE 1.
            CREATE telephones.
            ASSIGN
                telephones.tpidt = cTpRol
                telephones.noidt = iNoRol
                telephones.tptel = "00003"
                telephones.cdtel = "00025"
                telephones.notel = cEmail
                telephones.cdcsy = "GIExtranet"
                telephones.dtcsy = TODAY
                telephones.hecsy = TIME
                telephones.nopos = iPos
                .
            MLog("Création email extranet, tpidt = " + cTpRol + " - noidt = " + STRING(iNoRol) + " - Email: " + cEmail).
        END.
        ELSE DO:
            ASSIGN
                telephones.cdtel = "00025"
                .
            MLog("Maj type email extranet, tpidt = " + cTpRol + " - noidt = " + STRING(iNoRol) + " - Email: " + cEmail).
        END.
    END.
    
END PROCEDURE.

PROCEDURE MajMadisp:

DEFINE INPUT PARAMETER rEnreg AS ROWID      NO-UNDO.
DEFINE INPUT PARAMETER cTpCon AS CHARACTER  NO-UNDO.
DEFINE INPUT PARAMETER iNoCon AS INTEGER    NO-UNDO.
DEFINE INPUT PARAMETER cMode  AS CHARACTER  NO-UNDO.

DEFINE BUFFER intnt-maj FOR intnt.
DEFINE BUFFER ctrat-maj FOR ctrat.

    IF cMode = "" THEN RETURN.
    
    IF rEnreg = ? THEN DO:
        FIND LAST tache WHERE tache.tpcon = cTpCon
                           AND tache.tptac = (IF cTpCon = "01030" THEN "04008" 
                                              ELSE IF cTpCon = "01033" THEN "04029" 
                                              ELSE "")
                           AND tache.nocon = iNoCon
                           EXCLUSIVE-LOCK NO-ERROR.
        IF AVAILABLE tache THEN 
            ASSIGN 
                tache.tpmadisp = cMode
                /**Ajout OF le 06/04/16**/
                tache.cdmsy = "tpmadisp (EXPWEB.I)"
                tache.dtmsy = TODAY
                tache.hemsy = TIME
                /** **/
                .
    END.
    ELSE DO:
        FIND FIRST intnt-maj WHERE ROWID(intnt-maj) = rEnreg EXCLUSIVE-LOCK NO-ERROR.
        IF AVAILABLE intnt-maj THEN 
            ASSIGN
                intnt-maj.tpmadisp = cMode
                /**Ajout OF le 06/04/16**/
                intnt-maj.cdmsy = "tpmadisp (EXPWEB.I)"
                intnt-maj.dtmsy = TODAY
                intnt-maj.hemsy = TIME
                /** **/
                .
        ELSE DO:
            FIND FIRST ctrat-maj WHERE ROWID(ctrat-maj) = rEnreg EXCLUSIVE-LOCK NO-ERROR.
            IF AVAILABLE ctrat-maj THEN 
                ASSIGN
                    ctrat-maj.tpmadisp = cMode
                    /**Ajout OF le 06/04/16**/
                    ctrat-maj.cdmsy = "tpmadisp (EXPWEB.I)"
                    ctrat-maj.dtmsy = TODAY
                    ctrat-maj.hemsy = TIME
                    /** **/
                    .
        END.
    END.

END PROCEDURE.
gga*/

