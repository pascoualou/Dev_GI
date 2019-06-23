/* EDITION DES PIECES COMPTABLES DE LA PERIODE EN COURS */

DEFINE NEW SHARED VARIABLE giCodeSoc AS INTEGER NO-UNDO.
DEFINE NEW SHARED VARIABLE giCodeEtab AS INTEGER NO-UNDO.

DEFINE VARIABLE Disque AS CHARACTER NO-UNDO.
DEFINE VARIABLE Fichier AS CHARACTER NO-UNDO.
DEFINE VARIABLE dCre AS DECIMAL NO-UNDO.
DEFINE VARIABLE dDeb AS DECIMAL NO-UNDO.
DEFINE VARIABLE dTot AS DECIMAL NO-UNDO.
DEFINE VARIABLE dCreEuro AS DECIMAL NO-UNDO.
DEFINE VARIABLE dDebEuro AS DECIMAL NO-UNDO.
DEFINE VARIABLE iCpt AS INTEGER NO-UNDO.
DEFINE VARIABLE hInstance           AS INTEGER                      NO-UNDO.
DEFINE VARIABLE iLigCecrln AS INTEGER     NO-UNDO.
DEFINE VARIABLE iLigTot AS INTEGER     NO-UNDO.
DEFINE VARIABLE dMtTot AS DECIMAL     NO-UNDO.

DEFINE BUFFER bpregln FOR pregln.
DEFINE BUFFER bcecrln FOR cecrln.
DEFINE BUFFER bmaj FOR maj.


ASSIGN  
    Disque = OS-GETENV("DISQUE")
    Fichier = "tmp\edtpiec.txt"
    .
OUTPUT TO VALUE(Disque + Fichier).

FIND LAST  isoc WHERE isoc.specif-cle = 1000 /*AND isoc.soc-cd = 3080*/ NO-LOCK.
ASSIGN
gicodesoc = isoc.soc-cd
gicodeetab = 8000
.

/*for each agest where agest.soc-cd = isoc.soc-cd
no-lock,
each bmaj where bmaj.soc-cd = isoc.soc-cd
and bmaj.gest-cle = agest.gest-cle
and bmaj.nmtab = "cecrsai"
and bmaj.datecomp > agest.dafin
exclusive-lock,
first cecrsai where cecrsai.soc-cd = bmaj.soc-cd
and cecrsai.etab-cd = int(substring(bmaj.cdenr,6,5) )
and cecrsai.jou-cd = substring(bmaj.cdenr,11,5)
and cecrsai.prd-cd = int(substring(bmaj.cdenr,16,3))
and cecrsai.prd-num = int(substring(bmaj.cdenr,19,4))
and cecrsai.piece-int = int(substring(bmaj.cdenr,23,9))*/


FOR EACH cecrsai WHERE cecrsai.soc-cd = isoc.soc-cd
                    AND cecrsai.etab-cd = 9000
                    AND cecrsai.jou-cd = "PAGCE"
                    AND cecrsai.prd-cd  = 11
                    AND cecrsai.prd-num = 6
                    AND cecrsai.piece-compta = 4060002
/*                    and cecrsai.usrid begins "transpo"*/
    /*AND NOT CAN-FIND(FIRST cecrln WHERE cecrln.soc-cd    = cecrsai.soc-cd
                                  AND cecrln.mandat-cd      = cecrsai.etab-cd
                                  AND cecrln.jou-cd         = cecrsai.jou-cd
                                  AND cecrln.mandat-prd-cd  = cecrsai.prd-cd
                                  AND cecrln.mandat-prd-num = cecrsai.prd-num
                                  AND cecrln.piece-int      = cecrsai.piece-int
                                  )*/
                    EXCLUSIVE-LOCK:
/*Pour generer un fichier d'entree pour l'utilitaire de suppression de piece*
put unformatted 
cecrsai.soc-cd  chr(9) 
cecrsai.etab-cd  chr(9)
cecrsai.jou-cd  chr(9) 
cecrsai.prd-cd  chr(9) 
cecrsai.prd-num  chr(9)
cecrsai.piece-int skip.
next.*/


/*    ASSIGN
         dDeb = 0
         dCre = 0
         .
 
     FOR EACH cecrln WHERE cecrln.soc-cd         = cecrsai.soc-cd
                         AND cecrln.mandat-cd      = cecrsai.etab-cd
                         AND cecrln.jou-cd         = cecrsai.jou-cd
                         AND cecrln.mandat-prd-cd  = cecrsai.prd-cd
                         AND cecrln.mandat-prd-num = cecrsai.prd-num
                         AND cecrln.piece-int      = cecrsai.piece-int
                         NO-LOCK:
 
             IF cecrln.sens then 
                 ASSIGN
                     dDeb = dDeb + cecrln.mt
                     .
             ELSE 
                 ASSIGN
                     dCre = dCre + cecrln.mt
                     .
 
     END. /* FOR EACH cecrln */
     
     IF dDeb = dCre THEN NEXT.*/
    
    FIND ietab OF cecrsai NO-LOCK NO-ERROR.
    FIND FIRST agest WHERE agest.soc-cd = isoc.soc-cd 
                       AND agest.gest-cle = ietab.gest-cle
                       NO-LOCK NO-ERROR.
    FIND FIRST bmaj WHERE bmaj.soc-cd    = cecrsai.soc-cd AND
                         bmaj.nmtab     = (IF cecrsai.usrid-eff = "CLOTURE" THEN "CLOTURE" + STRING(cecrsai.etab-cd,">>>>9")
                                          ELSE "cecrsai")    AND
                         bmaj.gest-cle  = ietab.gest-cle    AND
                         bmaj.cdenr     = STRING(cecrsai.soc-cd,'>>>>9') + 
                                         STRING(cecrsai.etab-cd,'>>>>9') + 
                                         STRING(cecrsai.jou-cd,'x(5)') + 
                                         STRING(cecrsai.prd-cd,'>>9') + 
                                         STRING(cecrsai.prd-num,'>>>9') + 
                                         STRING(cecrsai.piece-int,'>>>>>>>>9') + 
                                         STRING(0,">>>>>9")                          
                        NO-LOCK NO-ERROR.            
    IF cecrsai.usrid BEGINS "FAC. LOC." AND cecrsai.ref-num BEGINS "FL" THEN
        FIND FIRST iftsai WHERE iftsai.soc-cd = cecrsai.soc-cd
                            AND iftsai.fac-num = INT(SUBSTRING(cecrsai.ref-num,3))
                            NO-LOCK NO-ERROR.
    PUT UNFORMATTED "Soc " + STRING(cecrsai.soc-cd,">>>>9") 
    + " - Mdt " TRIM(STRING(cecrsai.etab-cd,">>>>9"))
    " - Piece no " + TRIM(STRING(cecrsai.piece-compta,">>>>>>>>9") )
    + " - Num int " + TRIM(STRING(cecrsai.piece-int,"->>>>>>>9"))
    + " - au " + STRING(cecrsai.dacompta,"99/99/9999") + " - Periode " 
    + STRING(cecrsai.prd-cd) + " " + STRING(cecrsai.prd-num)
    + " - Journal " cecrsai.jou-cd SKIP
    "TpMvt " cecrsai.type-cle 
    + " - N° Doc " + cecrsai.ref-num
    + " - " + STRING(cecrsai.situ,"Définitive/Provisoire")
    + " - Dev " + cecrsai.dev-cd SKIP
    "Piece créée le " + STRING(cecrsai.dacrea,"99/99/9999")
    " à " STRING(cecrsai.ihcre,"hh:mm:ss")
    " par " cecrsai.usrid " - Prog: " cecrsai.nomprog SKIP
    IF cecrsai.damod NE ? THEN "Piece modifiée le " + STRING(cecrsai.damod,"99/99/9999")
        + " à " + STRING(cecrsai.ihmod,"hh:mm:ss")
        + " par " + cecrsai.usridmod
    ELSE "" SKIP
    "Tracée le " IF AVAILABLE bmaj THEN STRING(bmaj.jcremvt,"99/99/9999") ELSE ""
    " à " IF AVAILABLE bmaj THEN SUBSTRING(STRING(bmaj.ihcremvt,"999999"),1,2) + ":"
                               + SUBSTRING(STRING(bmaj.ihcremvt,"999999"),3,2) + ":"
                               + SUBSTRING(STRING(bmaj.ihcremvt,"999999"),5)
          ELSE ""
    IF cecrsai.usrid-eff = "CLOTURE" THEN " (CLOTURE)" ELSE ""
    " - Envoi DPS le " + IF cecrsai.dadoss = ? THEN "" ELSE STRING(cecrsai.dadoss,"99/99/9999") SKIP
/*    "Prog Creation: " cecrsai.nomprog SKIP*/
    "Lib:  " + cecrsai.lib FORMAT "x(80)" 
    SKIP(1).
    

/*    PUT UNFORMATTED "TABLE CECRLN" SKIP.*/
    PUT UNFORMATTED 
    "  MDT    LIG   COMPTE       LIBELLE                              DEBIT          CREDIT         DB TVA         CR TVA" SKIP.

    ASSIGN
        dDeb = 0
        dDebEuro = 0
        dCre = 0
        dCreEuro = 0
        .

    FIND ietab WHERE ietab.soc-cd = cecrsai.soc-cd
                 AND ietab.etab-cd = cecrsai.etab-cd
                 NO-LOCK NO-ERROR.
    FOR EACH cecrln WHERE cecrln.soc-cd         = cecrsai.soc-cd
                        AND cecrln.mandat-cd      = cecrsai.etab-cd
                        AND cecrln.jou-cd         = cecrsai.jou-cd
                        AND cecrln.mandat-prd-cd  = cecrsai.prd-cd
                        AND cecrln.mandat-prd-num = cecrsai.prd-num
                        AND cecrln.piece-int      = cecrsai.piece-int
                        exclusive-LOCK
        /*BREAK /*BY cecrln.etab-cd*/ /*En copro, pas de rupture sur le mandat !*/
              BY cecrln.cpt-cd
              BY cecrln.lig*/
        :
        
        /*Si les cecrln.tot-det servant à regénérer les pregln sont faux*/
        /*IF cecrln.sscoll-cle = "" THEN cecrln.tot-det = 0.
        ELSE IF FIRST-OF(cecrln.cpt-cd) AND LAST-OF(cecrln.cpt-cd) THEN cecrln.tot-det = 0.
        ELSE IF LAST-OF(cecrln.cpt-cd) THEN cecrln.tot-det = 2.
        ELSE /*IF FIRST-OF(cecrln.cpt-cd) THEN*/ cecrln.tot-det = 1.*/
        /*Cas particuliers*/
        /*IF cecrln.lib-ecr[1] BEGINS "V/Chq THIBIERGE CDD" THEN cecrln.tot-det = 0.*/
        /*IF cecrln.lig = 3030 THEN cecrln.tot-det = 1.
        ELSE IF cecrln.lig = 3040 THEN cecrln.tot-det = 1.
        ELSE IF cecrln.lig = 3050 THEN cecrln.tot-det = 2.
        ELSE IF cecrln.lig = 3070 THEN cecrln.tot-det = 0.
        ELSE IF cecrln.lig = 3080 THEN cecrln.tot-det = 0.*/

/*assign cecrln.mt = cecrln.mt / 2.*/
        PUT UNFORMATTED STRING(cecrln.etab-cd,">>>>9")
                        " " + STRING(cecrln.lig,"->>>>9")
/*                        " " + STRING(cecrln.sscoll-cle,"x(4)")
 *                         " " + STRING(cecrln.cpt-cd,"x(9)")*/
                        " " + IF cecrln.sscoll-cle NE "" THEN STRING(cecrln.sscoll-cle,"x(4)")
                              ELSE SUBSTRING(cecrln.cpt-cd,1,4)
                        " " + IF cecrln.sscoll-cle NE "" THEN STRING(cecrln.cpt-cd,"x(5)")
                              ELSE SUBSTRING(cecrln.cpt-cd,5)
                        " " + STRING(cecrln.lib-ecr[1],"x(32)")
                        " " + IF cecrln.sens THEN STRING(cecrln.mt,">>>,>>>,>>9.99")
                              ELSE FILL(" ",14)
                        " " + IF NOT cecrln.sens THEN STRING(cecrln.mt,">>>,>>>,>>9.99")
                              ELSE FILL(" ",14)
/*                        IF cecrsai.dev-cd NE ietab.dev-cd THEN " " + IF cecrln.sens THEN STRING(cecrln.mtdev,">>>,>>>,>>9.99")
 *                                                                      ELSE FILL(" ",14)
 *                         ELSE ""
 *                         IF cecrsai.dev-cd NE ietab.dev-cd THEN " " + IF NOT cecrln.sens THEN STRING(cecrln.mtdev,">>>,>>>,>>9.99")
 *                                                                      ELSE ""
 *                         ELSE ""*/
/*                        " " + IF cecrln.sens THEN STRING(cecrln.mt-euro,">>>,>>>,>>9.99")
 *                               ELSE FILL(" ",14)
 *                         " " + IF NOT cecrln.sens THEN STRING(cecrln.mt-euro,">>>,>>>,>>9.99")
 *                               ELSE ""*/
                        /*IF cecrln.mttva ne 0 THEN " " + STRING(cecrln.mttva,">>>,>>>,>>9.99")
                        ELSE ""*/
                        /*" " + string(cecrln.tot-det)*/
                        " " + IF cecrsai.natjou-cd = 2 THEN STRING(CAN-FIND(FIRST pregln OF cecrln),"Pregln/")
                              ELSE ""
                        /*" " + string(cecrln.prd-cd,">9") + "-" + trim(string(cecrln.prd-num,">9"))
                        " " + string(cecrln.mandat-cd)*/
                        " " + string(cecrln.tot-det)
                        SKIP
                        .
            IF cecrln.tot-det NE 1 THEN PUT UNFORMATTED " " SKIP.

            IF cecrln.sens then 
                ASSIGN
                    dDeb = dDeb + cecrln.mt
                    dDebEuro = dDebEuro + IF cecrsai.dev-cd NE ietab.dev-cd THEN cecrln.mtdev ELSE cecrln.mt-euro
                    .
            ELSE 
                ASSIGN
                    dCre = dCre + cecrln.mt
                    dCreEuro = dCreEuro + IF cecrsai.dev-cd NE ietab.dev-cd THEN cecrln.mtdev ELSE cecrln.mt-euro
                    .

            iLigCecrln = cecrln.lig.

            FOR EACH cecrlnana OF cecrln NO-LOCK:
                PUT UNFORMATTED  "    ANA: "
/*                                 " " + STRING(cecrlnana.etab-cd,">>>>9")
 *                                  " " + STRING(cecrlnana.pos,">>9")*/
                                 "  " + STRING(cecrlnana.ana1-cd,"999")
                                 + "-" + STRING(cecrlnana.ana2-cd,"999")
                                 + "-" + STRING(cecrlnana.ana3-cd,"9")
                                 + IF cecrlnana.ana4-cd NE "" THEN "-" + STRING(cecrlnana.ana4-cd,"x(2)")
                                   ELSE ""  FORMAT "x(15)"
                                 STRING(cecrlnana.lib-ecr[1],"x(32)")
                                 STRING(cecrlnana.mt,"->>>,>>>,>>9.99")
/*                                 IF cecrsai.dev-cd NE ietab.dev-cd THEN " " + STRING(cecrlnana.mtdev,"->>>,>>>,>>9.99") ELSE ""*/
                                SKIP.

    	    END.

            /*IF NOT CAN-FIND(FIRST cecrlnana OF cecrln) THEN DO:
                CREATE cecrlnana.
                BUFFER-COPY cecrln TO cecrlnana
                    ASSIGN
                        cecrlnana.pos           = 10
                        cecrlnana.typeventil    = TRUE
                        cecrlnana.ana1-cd       = "130"
                        cecrlnana.ana2-cd       = "538"
                        cecrlnana.ana3-cd       = "1"
                        cecrlnana.ana4-cd       = ""
                        cecrlnana.ana-cd        = cecrlnana.ana1-cd + cecrlnana.ana2-cd + 
                                                      cecrlnana.ana3-cd + cecrlnana.ana4-cd
                        cecrlnana.pourc         = 100
                        cecrlnana.taux-cle      = 100
                        cecrln.fg-ana100        = TRUE
                        cecrln.analytique       = TRUE
                        .
                RUN alimacpt (cecrlnana.soc-cd,
                              'compta',
                              'cecrlnana',
                              STRING(cecrlnana.soc-cd,'>>>>9') + 
                                     STRING(cecrlnana.etab-cd,'>>>>9') + 
                                     STRING(cecrlnana.jou-cd,'x(5)') + 
                                     STRING(cecrlnana.prd-cd,'>>9') + 
                                     STRING(cecrlnana.prd-num,'>>>9') + 
                                     STRING(cecrlnana.piece-int,'>>>>>>>>9') + 
                                     STRING(cecrlnana.lig,'>>>>>9') + 
                                     STRING(cecrlnana.pos,'>>>>>9'),
                              cecrlnana.dacompta,
                              agest.Gest-Cle,
                              STRING(cecrlnana.etab-cd)
                              ).                       
            END.*/

/*if cecrln.etab-cd = cecrsai.etab-cd and cecrln.sscoll-cle = ""
 * and cecrln.cpt-cd = cecrsai.cpt-cd and cecrln.lig < 900000 
 * and not CAN-FIND(FIRST pregln OF cecrln)
 * and cecrln.lig > 2
 * then cecrln.lig = cecrln.lig + 900000.*/
/*if cecrln.lig >= 460 then cecrln.soc-cd = - cecrln.soc-cd.*/
/*IF cecrln.lig < 0 THEN DO:
    FOR EACH cecrlnana OF cecrln:
        cecrlnana.lig = ABS(cecrlnana.lig).
    END.
    cecrln.lig = ABS(cecrln.lig).
END.*/
/*
IF cecrln.lig > 1 AND cecrln.lig < 900000
    AND NOT CAN-FIND(FIRST pregln OF cecrln) THEN DO:
    FIND FIRST bpregln WHERE bpregln.soc-cd         = cecrsai.soc-cd
                         AND bpregln.mandat-cd      = cecrsai.etab-cd
                         AND bpregln.jou-cd         = cecrsai.jou-cd
                         AND bpregln.mandat-prd-cd  = cecrsai.prd-cd
                         AND bpregln.mandat-prd-num = cecrsai.prd-num
                         AND bpregln.piece-int      = cecrsai.piece-int
                         NO-LOCK NO-ERROR.
    IF NOT AVAILABLE bpregln THEN DO:
        FIND aparm WHERE aparm.soc-cd = cecrsai.soc-cd
		    AND  aparm.tppar = "TNUMI" EXCLUSIVE-LOCK NO-ERROR.
        IF AVAILABLE aparm THEN aparm.zone1 = aparm.zone1 + 1.
    END.
    IF AVAILABLE bpregln OR AVAILABLE aparm THEN DO:
        IF cecrln.tot-det = 1 THEN DO:
            FIND FIRST bcecrln WHERE bcecrln.soc-cd         = cecrsai.soc-cd
                                 AND bcecrln.mandat-cd      = cecrsai.etab-cd
                                 AND bcecrln.jou-cd         = cecrsai.jou-cd
                                 AND bcecrln.mandat-prd-cd  = cecrsai.prd-cd
                                 AND bcecrln.mandat-prd-num = cecrsai.prd-num
                                 AND bcecrln.piece-int      = cecrsai.piece-int
                                 AND bcecrln.lig            = cecrln.lig
                                 AND bcecrln.tot-det        = 1
                                 NO-LOCK NO-ERROR.
            FIND NEXT bcecrln WHERE bcecrln.soc-cd         = cecrsai.soc-cd
                                 AND bcecrln.mandat-cd      = cecrsai.etab-cd
                                 AND bcecrln.jou-cd         = cecrsai.jou-cd
                                 AND bcecrln.mandat-prd-cd  = cecrsai.prd-cd
                                 AND bcecrln.mandat-prd-num = cecrsai.prd-num
                                 AND bcecrln.piece-int      = cecrsai.piece-int
                                 AND bcecrln.tot-det        = 2
                                 NO-LOCK NO-ERROR.
            IF AVAILABLE bcecrln THEN iLigTot = bcecrln.lig + 10.
            IF CAN-FIND(FIRST bcecrln WHERE bcecrln.soc-cd         = cecrsai.soc-cd
                                 AND bcecrln.mandat-cd      = cecrsai.etab-cd
                                 AND bcecrln.jou-cd         = cecrsai.jou-cd
                                 AND bcecrln.mandat-prd-cd  = cecrsai.prd-cd
                                 AND bcecrln.mandat-prd-num = cecrsai.prd-num
                                 AND bcecrln.piece-int      = cecrsai.piece-int
                                 AND bcecrln.lig            = iLigTot) THEN iLigTot = bcecrln.lig + 5.
        END.
        ELSE IF cecrln.tot-det = 0 THEN iLigTot = cecrln.lig.
        dMtTot = dMtTot + cecrln.mt * (IF cecrln.sens THEN -1 ELSE 1).
        CREATE pregln.
        BUFFER-COPY cecrln EXCEPT cecrln.lib TO pregln
        ASSIGN
          pregln.tiers-sscoll-cle   = cecrln.sscoll-cle
          pregln.tiers-cpt-cd       = cecrln.cpt-cd
          pregln.lig-reg            = cecrln.lig
          pregln.lig-tot            = iLigTot
          pregln.num-int            = IF AVAILABLE bpregln THEN bpregln.num-int
                                      ELSE aparm.zone1
          pregln.mt                 = cecrln.mt * (IF cecrln.sens THEN -1 ELSE 1) /*Attention: Pour une recette*/
          pregln.mtdev              = cecrln.mtdev 
          pregln.mttva              = cecrln.mttva 
          pregln.valid              = TRUE
          pregln.tot-det            = /*TRUE*/ cecrln.tot-det = 0
          pregln.lib[1]             = cecrln.lib-ecr[1]
          pregln.lib[2]             = cecrln.lib-ecr[2]
          .
        IF cecrln.tot-det = 2 THEN DO:
            CREATE pregln.
            BUFFER-COPY cecrln EXCEPT cecrln.lib TO pregln
            ASSIGN
              pregln.sscoll-cle         = ""
              pregln.cpt-cd             = ""
              pregln.tiers-sscoll-cle   = ""
              pregln.tiers-cpt-cd       = ""
              pregln.coll-cle           = ""
              pregln.tiers-cle          = ""
              pregln.lig                = 0
              pregln.lig-reg            = iLigTot
              pregln.lig-tot            = iLigTot
              pregln.num-int            = IF AVAILABLE bpregln THEN bpregln.num-int
                                          ELSE aparm.zone1
              pregln.mt                 = dMtTot
              pregln.mtdev              = 0 
              pregln.mttva              = 0 
              pregln.valid              = TRUE
              pregln.tot-det            = true
              pregln.lib[1]             = "Total du détail"
              pregln.lib[2]             = ""
              pregln.lib-ecr[1]         = "Total du détail"
              pregln.lib-ecr[2]         = ""
              .
        END.
        /*PUT UNFORMATTED  "    -> CREATE pregln Lig-tot = " iLigTot " Total ? " cecrln.tot-det = 0 SKIP.
        IF cecrln.tot-det = 2 THEN 
            PUT UNFORMATTED  "    -> CREATE TOTAL Lig-tot = " iLigTot " Montant " dMtTot SKIP(2).*/
        IF cecrln.tot-det NE 1 THEN dMtTot = 0.
    END.
END.
*/
/*IF cecrln.cpt-cd = "467100000" THEN RUN cre-cbap.*/
            /*IF cecrln.lig = 0 THEN cecrln.soc-cd = - cecrln.soc-cd.*/
    END. /* FOR EACH cecrln */

    PUT UNFORMATTED SKIP(1)
                    FILL(" ",47) + STRING("TOTAUX : ","x(13)")
                    " " + STRING(dDeb,">>>,>>>,>>9.99")
                    " " + STRING(dCre,">>>,>>>,>>9.99")
                    SKIP
                    .
    PUT UNFORMATTED SKIP(1)
                    FILL(" ",47) + STRING("SOLDE : ","x(13)")
                    " " + IF dDeb - dCre >= 0 THEN STRING(dDeb - dCre ,">>>,>>>,>>9.99")
                          ELSE FILL(" ",14)
                    " " + IF dDeb - dCre < 0 THEN STRING(dCre - dDeb,">>>,>>>,>>9.99")
                          ELSE FILL(" ",14)
                    SKIP
                    .

      IF AVAILABLE iftsai THEN DO:
          PUT UNFORMATTED "FACTURE LOCATAIRE : " SKIP
          "Soc "  STRING(iftsai.soc-cd,">>>>9") 
          " - Mdt " TRIM(STRING(iftsai.etab-cd,">>>>9"))
          " - Compte " TRIM(STRING(iftsai.sscptg-cd,"x(5)"))
          " - Facture " iftsai.typefac-cle " No "  TRIM(STRING(iftsai.fac-num,">>>>>>>>9") )
          " créée le " STRING(iftsai.dacrea,"99/99/9999")
          " à " STRING(iftsai.ihcre,"hh:mm:ss")
          " par " iftsai.usrid SKIP
          " modifiée le " STRING(iftsai.damod,"99/99/9999")
          " à " STRING(iftsai.ihmod,"hh:mm:ss")
          " par " iftsai.usridmod SKIP
          IF iftsai.fg-edifac = TRUE THEN " comptabilisée le " 
           + (IF iftsai.dacpta = ? THEN "?" ELSE STRING(iftsai.dacpta,"99/99/9999"))
           + " à " + STRING(iftsai.ihcpta,"hh:mm:ss")
          ELSE  "Non comptabilisée" SKIP
          " Lib: " iftsai.lib SKIP
          "Total TTC: " TRIM(STRING(iftsai.mt,"->>>,>>9.99"))
          " - Total TVA: " TRIM(STRING(iftsai.mttva,"->>>,>>9.99")) SKIP
          SKIP(1).
          FOR EACH iftln OF iftsai NO-LOCK:
              PUT UNFORMATTED 
                          "  " STRING(iftln.brwcoll1 + "-" + iftln.brwcoll2 +
                          " " + iftln.rub-cd + "-" + iftln.ssrub-cd,"x(20)")
                          "  " STRING(iftln.lib-ecr[1],"x(32)")
                          " " + IF iftln.mtdeb > 0 THEN STRING(iftln.mtdeb,">>>,>>>,>>9.99")
                                                   ELSE FILL(" ",14)
                          " " + IF iftln.mtcre > 0 THEN STRING(iftln.mtcre,">>>,>>>,>>9.99")
                                                   ELSE FILL(" ",14)
                          SKIP
                          .
          END.
          PUT UNFORMATTED SKIP(1) "LIENS PIECES COMPTABLES : " SKIP.
          DO iCpt = 1 TO EXTENT(iftsai.cdenr):
              IF iftsai.cdenr[iCpt] NE "" THEN
                  PUT UNFORMATTED " " iCpt " : " REPLACE(SUBSTRING(iftsai.cdenr[iCpt],3),"@","-") SKIP.
          END.
          PUT UNFORMATTED " " SKIP.
      END.

      ASSIGN
          dDeb = 0
          .
    IF CAN-FIND(FIRST pregln WHERE pregln.soc-cd         = cecrsai.soc-cd
                        AND pregln.mandat-cd      = cecrsai.etab-cd
                        AND pregln.jou-cd         = cecrsai.jou-cd
                        AND pregln.mandat-prd-cd  = cecrsai.prd-cd
                        AND pregln.mandat-prd-num = cecrsai.prd-num
                        AND pregln.piece-int      = cecrsai.piece-int
                        NO-LOCK) THEN DO:

        PUT UNFORMATTED "TABLE PREGLN (LIEN AVEC PIECE-INT)" SKIP(2).

        FOR EACH pregln WHERE pregln.soc-cd         = cecrsai.soc-cd
                          AND pregln.mandat-cd      = cecrsai.etab-cd
                          AND pregln.jou-cd         = cecrsai.jou-cd
                          AND pregln.mandat-prd-cd  = cecrsai.prd-cd
                          AND pregln.mandat-prd-num = cecrsai.prd-num
                          AND pregln.piece-int      = cecrsai.piece-int
                          exclusive-LOCK:
            PUT UNFORMATTED STRING(pregln.etab-cd,">>>>9")
                            " " + STRING(pregln.lig-reg,">>>>9")
                            " " + STRING(pregln.lig-tot,">>>>9")
                            " " + STRING(pregln.lig,"->>>>9")
                            " " + STRING(pregln.sscoll-cle,"x(4)")
                            " " + STRING(pregln.cpt-cd,"x(9)")
                            " " + STRING(pregln.tot-det,"T/D")
                            " " + STRING(pregln.lib-ecr[1],"x(32)")
                            " " + STRING(pregln.mt,"->>>,>>>,>>9.99")
                            " " + string(pregln.num-int)
                            " " + string(pregln.piece-int)
                            IF pregln.mttva ne 0 THEN " " + STRING(pregln.mttva,">>>,>>>,>>9.99")
                            ELSE ""
/*                            " " + string(pregln.dacompta,"99/99/9999")*/
                            /*" " + string(pregln.prd-cd,"9") + "-" + trim(string(pregln.prd-num,">9"))
                            " " + string(pregln.mandat-cd)*/
                            SKIP
                            .
                IF pregln.cpt-cd NE "" THEN
                ASSIGN
                    dDeb = dDeb + pregln.mt
                    .
/*if pregln.lig = 30 then pregln.lig = 20.*/
/*IF pregln.tot-det = FALSE AND NOT CAN-FIND(FIRST cecrln OF pregln) THEN DO:
    FIND LAST bpregln WHERE bpregln.soc-cd = pregln.soc-cd
                        AND bpregln.mandat-cd = pregln.mandat-cd
                        AND bpregln.num-int = pregln.num-int
                        AND bpregln.tot-det = FALSE
                        AND bpregln.lig-tot = pregln.lig-tot
                        NO-LOCK NO-ERROR.
    iLigCecrln = iLigCecrln + 10.
    MESSAGE pregln.etab-cd pregln.cpt-cd pregln.mt
        IF AVAILABLE bpregln THEN bpregln.lig-reg ELSE 0
            iLigCecrln
        VIEW-AS ALERT-BOX INFO BUTTONS OK.
    /*CREATE cecrln.
    BUFFER-COPY pregln TO cecrln
        ASSIGN
            cecrln.tot-det = IF AVAILABLE bpregln AND pregln.lig-reg = bpregln.lig-reg THEN 2 ELSE 1
            cecrln.sens = pregln.mt < 0
            cecrln.mt = ABS(pregln.mt)
            cecrln.lib = pregln.lib-ecr[1]
            cecrln.TYPE-cle = cecrsai.TYPE-cle
            cecrln.dacompta = cecrsai.dacompta
            cecrln.datecr = cecrsai.daecr
            cecrln.paie-regl   = FALSE
            cecrln.lig = IF pregln.lig = 0 THEN iLigCecrln
                         ELSE pregln.lig
            pregln.lig = cecrln.lig
            .*/
END.*/
            /*Controle des totaux*/
            IF pregln.cpt-cd = "" AND pregln.tot-det = TRUE THEN DO:
                dTot = 0.
                FOR EACH bpregln WHERE bpregln.soc-cd = pregln.soc-cd
                                   AND bpregln.mandat-cd = cecrsai.etab-cd
                                   AND bpregln.jou-cd = cecrsai.jou-cd
                                   AND bpregln.mandat-prd-cd = cecrsai.prd-cd
                                   AND bpregln.mandat-prd-num = cecrsai.prd-num
                                   AND bpregln.piece-int = cecrsai.piece-int
                                   AND bpregln.tot-det = false
                                   AND bpregln.lig-tot = pregln.lig-tot
                                   NO-LOCK:
                    dTot = dTot + bpregln.mt.
                END.
                IF dTot NE pregln.mt THEN 
                    PUT UNFORMATTED "!!!!!! Montant du Total: " STRING(pregln.mt,">>>,>>>,>>9.99")
                        " -> Total des détails: " STRING(dTot,">>>,>>>,>>9.99")
                        SKIP.
            END.
            IF pregln.tot-det = TRUE THEN PUT UNFORMATTED " " SKIP.

        END. /* FOR EACH pregln */

        PUT UNFORMATTED SKIP(1)
                         FILL(" ",62) + STRING("TOTAUX : ","x(13)")
                         " " + STRING(dDeb,">>>,>>>,>>9.99")
                         SKIP
                         .
        ASSIGN
            dDeb = 0
            .

/*********************************
        PUT UNFORMATTED SKIP(1) "TABLE PREGLN (LIEN AVEC NUM-INT)" SKIP(2).
        FIND FIRST bpregln WHERE bpregln.soc-cd         = cecrsai.soc-cd
                             AND bpregln.mandat-cd      = cecrsai.etab-cd
                             AND bpregln.jou-cd         = cecrsai.jou-cd
                             AND bpregln.mandat-prd-cd  = cecrsai.prd-cd
                             AND bpregln.mandat-prd-num = cecrsai.prd-num
                             AND bpregln.piece-int      = cecrsai.piece-int
                             NO-LOCK NO-ERROR.
        FOR EACH pregln WHERE pregln.soc-cd         = bpregln.soc-cd
                            AND pregln.mandat-cd    = bpregln.mandat-cd
                            AND pregln.num-int      = bpregln.num-int
                            NO-LOCK:
            PUT UNFORMATTED STRING(pregln.etab-cd,">>>>9")
                            " " + STRING(pregln.lig-reg,">>>9")
                            " " + STRING(pregln.lig-tot,">>>9")
                            " " + STRING(pregln.lig,">>>9")
                            " " + STRING(pregln.sscoll-cle,"x(4)")
                            " " + STRING(pregln.cpt-cd,"x(9)")
                            " " + STRING(pregln.tot-det,"T/D")
                            " " + STRING(pregln.lib-ecr[1],"x(32)")
                            " " + STRING(pregln.mt,"->>>,>>>,>>9.99")
                            " " + string(pregln.num-int)
                            " " + string(pregln.piece-int)
/*                            " " + STRING(pregln.mt-euro,"->>>,>>>,>>9.99")
 *                             IF pregln.mttva ne 0 THEN " " + STRING(pregln.mttva,">>>,>>>,>>9.99")
 *                             ELSE ""*/
                            SKIP
                            .
                IF pregln.cpt-cd NE "" THEN
                ASSIGN
                    dDeb = dDeb + pregln.mt
                    .
        END. /* FOR EACH pregln */
*****************************************/

        PUT UNFORMATTED SKIP(1)
                         FILL(" ",56) + STRING("TOTAUX : ","x(13)")
                         " " + STRING(dDeb,">>>,>>>,>>9.99")
                         SKIP
                         .
    END. /* FOR EACH pregln */

    PUT UNFORMATTED SKIP(1) "********************************************************************" SKIP(1).
    
END. /* FOR EACH cecrsai */

/*FIND cecrln 
 *         WHERE cecrln.soc-cd  = INTEGER(SUBSTRING(maj.cdenr,1,5))
 *         AND cecrln.etab-cd   = INTEGER(SUBSTRING(maj.cdenr,6,5))
 *         AND cecrln.jou-cd    = SUBSTRING(maj.cdenr,11,5)
 *         AND cecrln.prd-cd    = INTEGER(SUBSTRING(maj.cdenr,16,1))
 *         AND cecrln.prd-num   = INTEGER(SUBSTRING(maj.cdenr,17,4))
 *         AND cecrln.piece-int = INTEGER(SUBSTRING(maj.cdenr,21,9))
 *         AND cecrln.lig       = INTEGER(SUBSTRING(maj.cdenr,30,6))
 *         NO-LOCK NO-ERROR.
 * 
 * FIND cecrsai WHERE cecrsai.soc-cd    = cecrln.soc-cd           AND
 *                    cecrsai.etab-cd   = cecrln.mandat-cd        AND 
 *                    cecrsai.jou-cd    = cecrln.jou-cd           AND
 *                    cecrsai.prd-cd    = cecrln.mandat-prd-cd    AND
 *                    cecrsai.prd-num   = cecrln.mandat-prd-num   AND
 *                    cecrsai.piece-int = cecrln.piece-int                    
 *                    NO-LOCK NO-ERROR.*/

/*MESSAGE "Fichier dans: " Disque + Fichier VIEW-AS ALERT-BOX.*/
RUN ShellExecuteA(INT(CURRENT-WINDOW:HANDLE), "open", Disque + Fichier, "", "", 1, OUTPUT hInstance).
OUTPUT CLOSE.

PROCEDURE cre-cbap:

DEFINE VARIABLE imanu-int AS INTEGER.

            FIND LAST cbap 
                WHERE cbap.soc-cd = cecrln.soc-cd
                AND   cbap.etab-cd = cecrln.etab-cd
                USE-INDEX cbap-int
                NO-LOCK NO-ERROR.
            IF AVAILABLE cbap THEN 
                imanu-int = cbap.manu-int + 1.
            ELSE 
                imanu-int = 1.

            IF NOT AVAILABLE ietab THEN 
                FIND ietab OF cecrln NO-LOCK NO-ERROR.
            CREATE cbap.
            ASSIGN
                cbap.soc-cd     = cecrln.soc-cd
                cbap.etab-cd    = cecrln.etab-cd
                cbap.coll-cle   = cecrln.coll-cle
                cbap.sscoll-cle = cecrln.sscoll-cle
                cbap.cpt-cd     = cecrln.cpt-cd
                cbap.lib        = cecrln.lib
                cbap.sens       = FALSE
                cbap.mt         = 0
                cbap.mtdev      = cecrln.mt
                cbap.mtdev      = IF cecrln.sens THEN - 1 *  cbap.mtdev ELSE cbap.mtdev 
                cbap.regl-cd    = 700
                cbap.daech      = cecrln.daech
                cbap.paie       = FALSE
                cbap.dev-cd     = ""
                cbap.libtier-cd = 0
                cbap.ref-num    = cecrln.ref-num
                cbap.analytique = FALSE
                cbap.manu-int   = imanu-int
                cbap.gest-cle   = ietab.gest-cle        /* gestionnaire lie au mdt de gerance */
                cbap.lib-ecr[1] = cbap.lib
                cbap.fg-ana100  = FALSE
                cbap.taxe-cd    = 0
                cbap.tiers-sscoll-cle = ""
                cbap.tiers-cpt-cd = ""
                cbap.type-reg   = 0         /* paiement divers */
                cbap.cmpc-mandat-cd = 9003
                .                                               


END PROCEDURE.


PROCEDURE ShellExecuteA EXTERNAL "shell32": 

  DEFINE INPUT  PARAMETER hwnd          AS long.           /* Handle to parent window */
  DEFINE INPUT  PARAMETER lpOperation   AS CHAR.              /* Operation to perform: open, print */
  DEFINE INPUT  PARAMETER lpFile        AS CHAR.              /* Document or executable name */
  DEFINE INPUT  PARAMETER lpParameters  AS CHAR.              /* Command line parameters to executable in lpFile */
  DEFINE INPUT  PARAMETER lpDirectory   AS CHAR.              /* Default directory */
  DEFINE INPUT  PARAMETER nShowCmd      AS long.            /* whether shown when opened:
                                                               0 hidden, 1 normal, minimized 2, maximized 3,
                                                               0 if lpFile is a document */
  DEFINE RETURN PARAMETER hInstance     AS long.           /* Less than or equal to 32 */

END. 


PROCEDURE alimacpt :
    DEFINE INPUT PARAMETER  iNoRef-In       AS INTEGER      NO-UNDO.
    DEFINE INPUT PARAMETER  cNmLog-In       AS CHARACTER    NO-UNDO.
    DEFINE INPUT PARAMETER  cNmTab-In       AS CHARACTER    NO-UNDO.
    DEFINE INPUT PARAMETER  cCdEnr-In       AS CHARACTER    NO-UNDO.

    DEFINE INPUT PARAMETER  jDateComp-In    AS DATE         NO-UNDO.
    DEFINE INPUT PARAMETER  cGestCd-In      AS CHARACTER    NO-UNDO.
    DEFINE INPUT PARAMETER  cMandatCd-In    AS CHARACTER    NO-UNDO.

    DEFINE VARIABLE iLongCleCom     AS INTEGER      NO-UNDO.
    
    iLongCleCom = LENGTH(STRING(cCdEnr-IN)) - 6.

                /* ------------------------------------------------------- */
                /* On regarde si une trace n'existe pas déjà pour CECRSAI  */
                /* auquel cas on ne fait rien car out sera automatiquement */
                /* retransféré                                             */
                /* ------------------------------------------------------- */
                            
                FIND maj
                    WHERE maj.soc-cd = iNoRef-In
                      AND maj.nmlog  = cNmLog-In
                      AND maj.nmtab  = "CECRSAI"
                      AND maj.cdenr  BEGINS SUBSTRING(cCdEnr-In,1,iLongCleCom - 6)
                    NO-LOCK NO-ERROR.
                IF NOT AVAILABLE maj THEN FIND maj WHERE maj.soc-cd = iNoRef-In
                                                     AND maj.nmlog  = cNmLog-In
                                                     AND maj.nmtab  = "CLOTURE" + SUBSTRING(cCdEnr-In,6,5)
                                                     AND maj.cdenr  BEGINS SUBSTRING(cCdEnr-In,1,iLongCleCom - 6)
                                                   NO-LOCK NO-ERROR.
                IF NOT AVAILABLE maj THEN
                DO :
                    /* ------------------------------------------------------- */
                    /* On teste si un CANA antérieur existe                    */
                    /* ------------------------------------------------------- */
                    FIND maj WHERE maj.soc-cd = iNoRef-In
                                     AND maj.nmlog = cNmLog-In
                                     AND maj.nmtab = "cecrlnana"
                                     AND maj.cdenr = cCdEnr-In NO-LOCK NO-ERROR.
                    IF AVAILABLE maj THEN RETURN. /* inutile de retracer une analytique deja tracée */ /* PS LE 06/05/02 */
                    /* ------------------------------------------------------- */
                    /* On crée si elle n'existe pas déjà une trace pour CECRLN */
                    /* ------------------------------------------------------- */

                    RUN creation-maj ( INPUT iNoRef-In,
                                       INPUT cNmLog-In,
                                       INPUT "cecrlnana",  /* "cecrln" PS LE 06/05/02 */
                                       INPUT cCdEnr-In,
                                       INPUT jDateComp-In,
                                       INPUT cGestCd-In,
                                       INPUT cMandatCd-In).
                                                                                 
                END. /* IF NOT AVAILABLE maj */
                                                            
END PROCEDURE.

PROCEDURE creation-maj :

DEFINE INPUT PARAMETER  iNoRefLoc-In AS INTEGER   NO-UNDO.
DEFINE INPUT PARAMETER  cNmLogLoc-In       AS CHARACTER    NO-UNDO.
DEFINE INPUT PARAMETER  cNmTabLoc-In       AS CHARACTER    NO-UNDO.
DEFINE INPUT PARAMETER  cCdEnrLoc-In       AS CHARACTER    NO-UNDO.

DEFINE INPUT PARAMETER  jDateCompLoc-In    AS DATE         NO-UNDO.
DEFINE INPUT PARAMETER  cGestCdLoc-In      AS CHARACTER    NO-UNDO.
DEFINE INPUT PARAMETER  cMandatCdLoc-In    AS CHARACTER    NO-UNDO.
        
    FIND maj
        WHERE maj.soc-cd = iNoRefLoc-In
          AND maj.nmlog  = cNmLogLoc-In
          AND maj.nmtab  = cNmTabLoc-in
          AND maj.cdenr  = cCdEnrLoc-In
        EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
 
    IF LOCKED maj THEN
    DO :
        /* Conflit de traçage de mise à jour. Réessayez plus tard. */
        /*** Fiche 0201/0333 {mestrans.i "100195" "'I'"} ***/
        RETURN.
    END.
    ELSE
    DO :
        IF NOT AVAILABLE maj THEN
        DO :
            CREATE maj.
            ASSIGN
                maj.soc-cd    = iNoRefLoc-In
                maj.nmlog     = cNmLogLoc-In
                maj.nmtab     = cNmTabLoc-in
                maj.cdenr     = cCdEnrLoc-In
                maj.jcremvt   = TODAY
                maj.ihcremvt  = INTEGER(SUBSTRING(STRING(TIME,"HH:MM:SS"),1,2) 
                                 + SUBSTRING(STRING(TIME,"HH:MM:SS"),4,2) 
                                 + SUBSTRING(STRING(TIME,"HH:MM:SS"),7,2)).                
        END.                         
        ASSIGN
            maj.jmodmvt  = TODAY
            maj.ihmodmvt = INTEGER(SUBSTRING(STRING(TIME,"HH:MM:SS"),1,2) 
                               + SUBSTRING(STRING(TIME,"HH:MM:SS"),4,2) 
                               + SUBSTRING(STRING(TIME,"HH:MM:SS"),7,2))
            maj.DateComp  = jDateCompLoc-In
            maj.Gest-Cle  = cGestCdLoc-In
            maj.Mandat-Cd = cMandatCdLoc-In
            Maj.jTrf  = ?
            Maj.ihTrf = ?.                

    END. 
    
END PROCEDURE.

