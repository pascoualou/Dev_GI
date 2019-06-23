/*------------------------------------------------------------------------
File        : incchalo.i
Purpose     : Include d'edition des depenses  
Author(s)   : JC 22/10/1998  -  GGA 2018/01/26
Notes       : reprise adb/comm/incchalo.i
              EN CAS DE MODIFICATIONS DANS CE PROGRAMME, LES REPORTER DANS cadb\src\edigene\incchalo.i
variable pré-processeur: {1} = Prefixe du nom de la table.
                             - cecr --> cecrlnana,cecrln,cecrsai
                             - cexm --> cexmlnana,cexmln,cexmsai
01  29/10/1998  JC    Ajout numero de lot
02  05/11/1998  SY    Si clé absente, prendre 1ère clé générale du mandat de gestion ou 1ère clé avec mill.
03  05/11/1998  JC    Mauvaise recuperation du contenu de la toggle-box edition des charges non locatives.
04  16/11/1998  JC    Si la cle = "" on met "" dans la cle et "CLE ABSENTE" dans le libelle.
05  19/11/1998  JC    Si l'ecriture est regroupée on met des "*" dans la date d'ecriture, le numero de piece, le numero de document et le fournisseur
06  30/12/1998  SY    Si la cle n'existe pas, on garde sa valeur avec le libellé "?.?.?"
07  27/10/2000  SL    Gestion de la Devise
08  29/11/2001  NO    Possibilite de regrouper les depenses ventilees par lot
09  29/07/2002  PZ    REPORT DE MODIFICATIONS
                           0601/1160 par JB: format of {1}sai.piece-compta changed because it is sometimes negative
                           0702/0965 par DM: recupérer la rubrique 501
10  20/02/2003  OF    0203/0294: on ne regroupe pas si la 2e ligne de libelle est differente
11  12/02/2004  SG    0104/0451: rajout de la sélection date à date
12  11/02/2008  OF    0208/0162 Specifique Dauchez: On ne prend plus le Quitt ni ODRT
13  18/03/2008  OF    0308/0169 Il faut filtrer les ANC
14  08/02/2010  OF    0408/0029 Edition PDF
15  25/08/2010  OF    0810/0071 Recalcul du montant en fonction des millièmes pour les cexmlnana
16  03/02/2011  OF    0211/0020 Pb regroupement des dépenses
17  07/03/2011  OF    0311/0061 Mise au point modif précédente
18  17/01/2012  NP    0112/0157 Specifique 03110 comme Dauchez: plus le Quitt ni ODRT
19  26/02/2013  DM    0712/0238 Prorata et dossier travaux
20  05/05/2015  DM    0414/0082 Recettes analytiques 
------------------------------------------------------------------------*/

for each {1}lnana no-lock 
   where {1}lnana.soc-cd     = giReferenceSociete 
     and {1}lnana.etab-cd    = giNumeroMandat
     and {1}lnana.sscoll-cle = vcCodeCollectif4110
     and {1}lnana.cpt-cd     = vcCompte4110
 , first alrub no-lock
   where alrub.soc-cd   = {1}lnana.soc-cd
     and alrub.rub-cd   = {1}lnana.ana1-cd
     and alrub.ssrub-cd = {1}lnana.ana2-cd
    break by {1}lnana.soc-cd
          by {1}lnana.etab-cd
          by {1}lnana.sscoll-cle
          by {1}lnana.cpt-cd
          by {1}lnana.ana1-cd
          by {1}lnana.ana2-cd
          by {1}lnana.ana3-cd
          by {1}lnana.ana4-cd 
          by {1}lnana.lig 
          by {1}lnana.pos:
          
    if "{1}" = "cexm" and cexmlnana.nolot <> 0 and cexmlnana.nbpar <> 0 and cexmlnana.nbtot <> 0 and cexmlnana.mttot <> 0
    then assign
            vdeDepenseTTC = round(cexmlnana.mttot    * cexmlnana.nbpar / cexmlnana.nbtot, 2)
            vdeDepenseTVA = round(cexmlnana.mttvatot * cexmlnana.nbpar / cexmlnana.nbtot, 2)
            vlSensDepense = cexmlnana.sens-tot
            .
    else assign 
            vdeDepenseTTC = {1}lnana.mt
            vdeDepenseTVA = {1}lnana.mttva
            vlSensDepense = {1}lnana.sens
            .
    vdeTauxProrata = 100.
    if vlDebour 
    and not can-find(first aparm no-lock 
                     where aparm.tppar = "TVACOL"
                       and aparm.cdpar = {1}lnana.ana1-cd + "-" + {1}lnana.ana2-cd)
    then do:
        /* Prorata de TVA */
        if available {1}lnana and {1}lnana.tx-recuptva <> ? 
        then assign
                 vdeNumerateur   = {1}lnana.tx-recuptva
                 vdeDenominateur = 100
        .
        else run getRatioCleRepartion in vhOutilsTva(giNumeroMandat, year({1}lnana.dacompta), output vdeNumerateur, output vdeDenominateur).
        vdeTauxProrata = (vdeNumerateur / vdeDenominateur) * 100.
        if vdeTauxProrata = ? then vdeTauxProrata = 100.
        if glAvecProrataTva then vdeDepenseTVA = round(vdeDepenseTVA * vdeTauxProrata / 100, 2).
    end.
    
    if first-of({1}lnana.ana4-cd) 
    then do:             /* Recherche du libelle de la cle */
        vcCodeCle = {1}lnana.ana4-cd.
        find first clemi no-lock
             where clemi.noimm = 10000 + giNumeroMandat
               and clemi.cdcle = {1}lnana.ana4-cd no-error.
        vcLibelleCle = if available clemi then clemi.lbcle else if vcCodeCle > "" then "?.?.?" else vcLbCleAbsente.
    end.
 
    //Recherche du libelle de la rubrique
    if first-of({1}lnana.ana1-cd) 
    then vcLibelleRubrique = libelleRubrique ({1}lnana.ana1-cd).
          
    // 1) On ignore les rubriques 500                               
    // 2) Code fiscalite =  2 : charges locatives                
    //                   <> 2 : charges non locatives            
    if (   (giNumeroPeriode = 0 and {1}lnana.noexo = 0)
        or (     giNumeroPeriode <> 0 
            and (   ({1}lnana.noexo <> 0 and {1}lnana.noexo = giNumeroPeriode)
                 or ({1}lnana.noexo = 0 and {1}lnana.datecr <> ? and {1}lnana.datecr >= gdaDebutPeriode and {1}lnana.datecr <= gdaFinPeriode)
                )
           )
        )
    and integer({1}lnana.ana1-cd) <> 500
    and (   (glEditionChargeNonLocative = no and integer({1}lnana.ana3-cd) = 2 and not integer({1}lnana.ana1-cd) = 501)
         or (glEditionChargeNonLocative = yes)
        )
    and (if gcPeriodeOuDate = "date" then {1}lnana.datecr >= gdaDebutPeriode and {1}lnana.datecr <= gdaFinPeriode
                                     else true )
    then do:
        for first {1}ln no-lock
            where {1}ln.soc-cd    = {1}lnana.soc-cd
              and {1}ln.etab-cd   = {1}lnana.etab-cd
              and {1}ln.jou-cd    = {1}lnana.jou-cd
              and {1}ln.prd-cd    = {1}lnana.prd-cd
              and {1}ln.prd-num   = {1}lnana.prd-num
              and {1}ln.piece-int = {1}lnana.piece-int
              and {1}ln.lig       = {1}lnana.lig
          , first {1}sai no-lock
            where {1}sai.soc-cd    = giReferenceSociete 
              and {1}sai.etab-cd   = {1}ln.mandat-cd
              and {1}sai.jou-cd    = {1}ln.jou-cd
              and {1}sai.prd-cd    = {1}ln.mandat-prd-cd
              and {1}sai.prd-num   = {1}ln.mandat-prd-num
              and {1}sai.piece-int = {1}ln.piece-int:

            if  ({1}sai.type-cle = "ODQTT" or {1}sai.type-cle = "ODRT")
            and (giReferenceSociete = 03073 or giReferenceSociete = 03110) then next.
                  
            find first ijou no-lock
                 where ijou.soc-cd  = {1}sai.soc-cd
                   and ijou.etab-cd = {1}sai.etab-cd
                   and ijou.jou-cd  = {1}sai.jou-cd no-error.
            if not available ijou or ijou.natjou-gi = 42 then next.  /* Nature du journal = compensation */
                   
            vcCompteFournisseur = "".
            for first csscptcol no-lock                   /* Recherche du compte fournisseur */
                where csscptcol.soc-cd     = giReferenceSociete
                  and csscptcol.etab-cd    = giNumeroMandat
                  and csscptcol.sscoll-cle = {1}ln.fourn-sscoll-cle
              , first ccptcol no-lock
                where ccptcol.soc-cd   = giReferenceSociete
                  and ccptcol.coll-cle = csscptcol.coll-cle
                  and ccptcol.tprole = 12:
                vcCompteFournisseur = {1}ln.fourn-cpt-cd.
            end.
            /*-- Difference de conversion DM 8/11/01 --*/
            if ({1}lnana.ana1-cd = vcRubDebit or {1}lnana.ana1-cd = vcRubCredit) and {1}lnana.ana2-cd = vcSousRub
            then do:
                if not can-find(first ttTempo)
                then do:
                    create ttTempo.
                    buffer-copy {1}lnana to ttTempo.
                    assign 
                        vdeListeTotalTTC = 0
                        vdeListeTotalTVA = 0
                    .
                end.
                assign 
                    vdeListeTotalTTC = vdeListeTotalTTC    + (if vlSensDepense then vdeDepenseTTC else - vdeDepenseTTC)
                    vdeListeTotalTVA = vdeListeTotalTVA + (if vlSensDepense then vdeDepenseTVA else - vdeDepenseTVA)
                .
            end.
            else do:
                if {1}lnana.regrp-dep = ? or {1}lnana.regrp-dep = ""
                then do : 
                    if glExportPdfOuXls 
                    then do:
                        &IF "{1}" = "cexm" &THEN 
                        find first ttExport
                            where ttExport.cTri = string(vcCodeCle,"X(2)")
                            + string({1}lnana.ana1-cd, "999")
                            + string({1}lnana.ana2-cd, "999")
                            + string({1}lnana.ana3-cd, "9") /**Ajout OF le 03/02/11**/
                            + (if {1}lnana.datecr <> ?
                            then string(year({1}lnana.datecr), "9999") + string(month({1}lnana.datecr), "99") + string(day({1}lnana.datecr), "99")
                            else "00000000")
                            + fill(" ",5)
                            + string({1}sai.piece-compta, "-999999999")
                            + string({1}lnana.lib-ecr[1], "X(32)")
                            + string({1}lnana.lib-ecr[2], "X(32)")
                            + string({1}lnana.mttot, "-999999999.99") no-error.
                        if not available ttExport or not plDepenseCumule
                            then 
                        do:
                        &ENDIF
                            create ttExport.
                            assign
                                ttExport.rRowAna      = rowid({1}lnana) /* DM 0712/0238 */
                                ttExport.iNomdt       = giNumeroMandat
                                ttExport.iNoExo       = giNumeroPeriode
                                ttExport.cCle         = {1}lnana.ana4-cd
                                ttExport.cLbCle       = vcLibelleCle
                                ttExport.cRubCd       = string({1}lnana.ana1-cd, "999")
                                ttExport.cLbRub       = string(vcLibelleRubrique, "X(32)")
                                ttExport.cSsRubCd     = string({1}lnana.ana2-cd, "999")
                                ttExport.cFisc        = string({1}lnana.ana3-cd, "9")
                                ttExport.daEcr        = {1}lnana.datecr
                                ttExport.iPieceCompta = {1}sai.piece-compta
                                ttExport.cNoDoc       = string({1}ln.ref-num, "X(9)")
                                ttExport.cFourn       = string(vcCompteFournisseur,"X(15)")
                                ttExport.iNoLot       = if "{1}" = "cexm" then cexmlnana.nolot else 0
                                ttExport.dMt          = if vlSensDepense then vdeDepenseTTC else - vdeDepenseTTC
                                ttExport.dMtTva       = if vlSensDepense then vdeDepenseTVA else - vdeDepenseTVA
                                ttExport.cLibEcr[1]   = string(gcLbTotalReleve + " " + vcLibelleCompteur, "X(32)")
                                ttExport.lLoc         = integer({1}lnana.ana3-cd) = 2 and not integer({1}lnana.ana1-cd) = 501
                                ttExport.iLig         = {1}lnana.lig
                                ttExport.iPos         = {1}lnana.pos
                                ttExport.iAffairNum   = {1}ln.affair-num /* DM 0712/0238 */
                                ttExport.dTxProrata   = vdeTauxProrata /* DM 0712/0238 */
                                ttExport.cTri         = string(vcCodeCle, "X(2)")
                                                        + string({1}lnana.ana1-cd, "999")
                                                        + string({1}lnana.ana2-cd, "999")
                                                        &IF "{1}" = "cexm" &THEN 
                                                        + string({1}lnana.ana3-cd,"9")
                                                        &ENDIF
                              + (if {1}lnana.datecr <> ?
                                 then string(year({1}lnana.datecr), "9999") + string(month({1}lnana.datecr), "99") + string(day({1}lnana.datecr), "99")
                                                                                   else "00000000")
                                                        &IF "{1}" = "cexm" &THEN
                                                        + fill(" ",5)
                                                        + string({1}sai.piece-compta, "-999999999")
                                                        + string({1}lnana.lib-ecr[1], "X(32)")
                              + string({1}lnana.lib-ecr[2], "X(32)")
                                                        + string({1}lnana.mttot, "-999999999.99")
                                                        &ENDIF
                                .
                            do viCpt = 1 to 9:
                                ttExport.cLibEcr[viCpt]  = {1}lnana.lib-ecr[viCpt].
                            end.
                        &IF "{1}" = "cexm" &THEN
                        end.
                        else if available ttExport and plDepenseCumule then assign
                                    ttExport.dMtTva = ttExport.dMtTva + (if vlSensDepense then vdeDepenseTVA else - vdeDepenseTVA)
                                    ttExport.dMt    = ttExport.dMt    + (if vlSensDepense then vdeDepenseTTC  else - vdeDepenseTTC )
                                    ttExport.iNoLot = 0
                                    .
                        &ENDIF
                    end. /* IF glExportPdfOuXls */
                    else do:
                        /*Ajout NO 29/11/2001*/
                        &IF "{1}" = "cexm" &THEN 
                        find first ttImpression
                            where ttImpression.cClass = string(vcCodeCle, "X(2)")
                            + string({1}lnana.ana1-cd, "999")
                            + string({1}lnana.ana2-cd, "999")
                            + string({1}lnana.ana3-cd, "9")
                            + (if {1}lnana.datecr <> ?
                            then string(year({1}lnana.datecr),"9999") + string(month({1}lnana.datecr),"99") + string(day({1}lnana.datecr),"99")
                            else "00000000")
                            + fill(" ", 5)
                            + string({1}sai.piece-compta, "-999999999")
                            + string({1}lnana.lib-ecr[1], "X(32)")
                            + string({1}lnana.lib-ecr[2],"X(32)")
                            + string({1}lnana.mttot, "-999999999.99") no-error.
                        if not available ttImpression or not plDepenseCumule
                            then 
                        do:
                        &ENDIF
                            /*NO 29/11/2001*/
                            create ttImpression.
                            assign 
                                ttImpression.cClass = string(vcCodeCle, "X(2)")
                                                      + string({1}lnana.ana1-cd, "999")
                                                      + string({1}lnana.ana2-cd, "999")
                                                      &IF "{1}" = "cexm" &THEN 
                                                      + string({1}lnana.ana3-cd, "9")
                                                      &ENDIF
                            + (if {1}lnana.datecr <> ?
                               then string(year({1}lnana.datecr), "9999") + string(month({1}lnana.datecr), "99") + string(day({1}lnana.datecr), "99")
                                                                                 else "00000000")
                                                      &IF "{1}" = "cexm" &THEN
                                                      + fill(" ", 5)
                                                      + string({1}sai.piece-compta, "-999999999")
                                                      + string({1}lnana.lib-ecr[1], "X(32)")
                            + string({1}lnana.lib-ecr[2], "X(32)")
                                                      + string({1}lnana.mttot, "-999999999.99")
                                                      &ENDIF
                                ttImpression.cRefer = if integer({1}lnana.ana3-cd) = 2 and not integer({1}lnana.ana1-cd) = 501 then "2" else "1"
                                ttImpression.cLigne = vcLibelleCle + separ[1]                      /* libelle de la cle */
                            + string(vcLibelleRubrique,"X(32)") + separ[1] /* libelle de la rubrique */
                            + (if {1}lnana.datecr <> ? then string({1}lnana.datecr, "99/99/9999") else "") + separ[1]
                            + (if {1}sai.piece-compta < 0
                               then string({1}sai.piece-compta, "->>>>>>>>") 
                               else string({1}sai.piece-compta, "ZZZZZZZZZ")) + separ[1]      
                            + string({1}lnana.ana3-cd, "9") + separ[1]
                            + string({1}ln.ref-num, "X(9)") + separ[1]
                            + string(vcCompteFournisseur, "X(15)") + separ[1] /* code fournisseur */
                            + "" + separ[1]
                            + (if vdeDepenseTVA <> 0
                               then string(if vlSensDepense then vdeDepenseTVA else - vdeDepenseTVA, "->>>>>>>>>9.99")
                               else "") + separ[1]
                            + (if vdeDepenseTTC <> 0
                               then string(if vlSensDepense then vdeDepenseTTC else - vdeDepenseTTC, "->>>>>>>>>9.99")
                               else "") + separ[1]
                            + string({1}lnana.lib-ecr[1], "X(32)") + separ[1]
                            + string({1}lnana.lib-ecr[2], "X(32)") + separ[1]
                            + string({1}lnana.lib-ecr[3], "X(32)") + separ[1]
                            + string({1}lnana.lib-ecr[4], "X(32)") + separ[1]
                            + string({1}lnana.lib-ecr[5], "X(32)") + separ[1]
                            + string({1}lnana.lib-ecr[6], "X(32)") + separ[1]
                            + string({1}lnana.lib-ecr[7], "X(32)") + separ[1]
                            + string({1}lnana.lib-ecr[8], "X(32)") + separ[1]
                            + string({1}lnana.lib-ecr[9], "X(32)") + separ[1]
                            + (if "{1}" = "cexm" then string(cexmlnana.nolot, ">>>>>") else "") + separ[1]                                           
                            + string({1}ln.affair-num, ">>>>>") + separ[1]
                            + (if vdeTauxProrata <> 0 then string(vdeTauxProrata, ">>9.99") else "")
                                .
                        &IF "{1}" = "cexm" &THEN
                        end.
                        else if available ttImpression and plDepenseCumule then assign
                                    vdeMontantDepenseTVA                     = decimal(entry(9, ttImpression.cLigne, separ[1]))  + (if vlSensDepense then vdeDepenseTVA else - vdeDepenseTVA)
                                    vdeMontantDepenseTTC                     = decimal(entry(10, ttImpression.cLigne, separ[1])) + (if vlSensDepense then vdeDepenseTTC else - vdeDepenseTTC)
                                    entry(9, ttImpression.cLigne, separ[1])  = string(vdeMontantDepenseTVA, "->>>>>>>>>9.99")
                                    entry(10, ttImpression.cLigne, separ[1]) = string(vdeMontantDepenseTTC, "->>>>>>>>>9.99")
                                    entry(20, ttImpression.cLigne, separ[1]) = ""
                                    .
                    &ENDIF
                    /*NO 29/11/2001*/
                    end. /* ELSE du IF glExportPdfOuXls */
                end.
                /* Code regroupement <> "" */
                else do:
                    if glExportPdfOuXls 
                    then do:
                        find first ttExport where ttExport.cRegrpDep = {1}lnana.regrp-dep no-error.
                        if not available ttExport 
                        then do:
                            create ttExport.
                            assign
                                ttExport.rRowAna      = rowid({1}lnana) /* DM 0712/0238 */
                                ttExport.iNomdt       = giNumeroMandat
                                ttExport.iNoExo       = giNumeroPeriode
                                ttExport.cCle         = {1}lnana.ana4-cd
                                ttExport.cLbCle       = vcLibelleCle
                                ttExport.cRubCd       = string({1}lnana.ana1-cd, "999")
                                ttExport.cLbRub       = string(vcLibelleRubrique, "X(32)")
                                ttExport.cSsRubCd     = string({1}lnana.ana2-cd, "999")
                                ttExport.cFisc        = string({1}lnana.ana3-cd, "9")
                                ttExport.daEcr        = {1}lnana.datecr
                                ttExport.iAffairNum   = {1}ln.affair-num /* DM 0712/0238 */                                
                                ttExport.dTxProrata   = vdeTauxProrata       /* DM 0712/0238 */
                                ttExport.iPieceCompta = 0
                                ttExport.cNoDoc       = fill("*", 9)
                                ttExport.cFourn       = fill("*", 5)
                                ttExport.iNoLot       = if "{1}" = "cexm" then cexmlnana.nolot else 0
                                ttExport.dMt          = if vlSensDepense then vdeDepenseTTC else - vdeDepenseTTC
                                ttExport.dMtTva       = if vlSensDepense then vdeDepenseTVA else - vdeDepenseTVA
                                ttExport.cLibEcr[1]   = string(gcLbTotalReleve + " " + vcLibelleCompteur, "X(32)")
                                ttExport.lLoc         = integer({1}lnana.ana3-cd) = 2 and not integer({1}lnana.ana1-cd) = 501
                                ttExport.cRegrpDep    = {1}lnana.regrp-dep
                                ttExport.iLig         = {1}lnana.lig
                                ttExport.iPos         = {1}lnana.pos
                                ttExport.cTri         = string(vcCodeCle, "X(2)")
                                                        + string({1}lnana.ana1-cd, "999")
                                                        + string({1}lnana.ana2-cd, "999")
                                  + (if {1}lnana.datecr <> ?
                                     then string(year({1}lnana.datecr), "9999") + string(month({1}lnana.datecr), "99") + string(day({1}lnana.datecr), "99")
                                                                                   else "00000000")
                                                        + string({1}lnana.regrp-dep,"X(5)")
                                .
                            do viCpt = 1 to 9:
                                ttExport.cLibEcr[viCpt]  = {1}lnana.lib-ecr[viCpt].
                            end.
                        end.
                        else assign 
                                ttExport.dMtTva = ttExport.dMtTva + (if vlSensDepense then vdeDepenseTVA else - vdeDepenseTVA)
                                ttExport.dMt    = ttExport.dMt    + (if vlSensDepense then vdeDepenseTTC else - vdeDepenseTTC)
                                .
                    end. /* IF glExportPdfOuXls */
                    else do:
                        find first ttImpression 
                            where substring(ttImpression.cClass, 17, 5, "character") = string({1}lnana.regrp-dep, "X(5)") no-error.
                        if not available ttImpression 
                        then do:
                            create ttImpression.
                            assign 
                                ttImpression.cClass = string(vcCodeCle, "X(2)")
                                                      + string({1}lnana.ana1-cd,"999")
                                                      + string({1}lnana.ana2-cd,"999")
                                + (if {1}lnana.datecr <> ?
                                   then string(year({1}lnana.datecr), "9999") + string(month({1}lnana.datecr), "99") + string(day({1}lnana.datecr), "99")
                                                                                 else "00000000")
                                                      + string({1}lnana.regrp-dep, "X(5)")
                                ttImpression.cRefer = if integer({1}lnana.ana3-cd) = 2 and not integer({1}lnana.ana1-cd) = 501 then "2" else "1"
                                ttImpression.cLigne = vcLibelleCle + separ[1] /* libelle de la cle */
                                + string(vcLibelleRubrique,"X(32)") + separ[1] /* libelle de la rubrique */
                                + fill("*", 10) + separ[1]
                                + fill("*", 9) + separ[1]
                                + string({1}lnana.ana3-cd,"9") + separ[1]
                                + fill("*", 9) + separ[1]
                                + fill("*", 5) + separ[1] /* code fournisseur */
                                + "" + separ[1]
                                + (if vdeDepenseTVA <> 0
                                   then string(if vlSensDepense then vdeDepenseTVA else - vdeDepenseTVA, "->>>>>>>>>9.99")
                                   else "") + separ[1]
                                + (if vdeDepenseTTC <> 0
                                   then string(if vlSensDepense then vdeDepenseTTC else - vdeDepenseTTC, "->>>>>>>>>9.99")
                                   else "") + separ[1]
                                + string({1}lnana.lib-ecr[1], "X(32)") + separ[1]
                                + string({1}lnana.lib-ecr[2], "X(32)") + separ[1]
                                + string({1}lnana.lib-ecr[3], "X(32)") + separ[1]
                                + string({1}lnana.lib-ecr[4], "X(32)") + separ[1]
                                + string({1}lnana.lib-ecr[5], "X(32)") + separ[1]
                                + string({1}lnana.lib-ecr[6], "X(32)") + separ[1]
                                + string({1}lnana.lib-ecr[7], "X(32)") + separ[1]
                                + string({1}lnana.lib-ecr[8], "X(32)") + separ[1]
                                + string({1}lnana.lib-ecr[9], "X(32)") + separ[1]
                                + (if "{1}" = "cexm" then string(cexmlnana.nolot, ">>>>>") else "") + separ[1]
                                + string({1}ln.affair-num,">>>>>") + separ[1]
                                + (if vdeTauxProrata <> 0 then string(vdeTauxProrata, ">>9.99") else "")
                                .
                        end.
                        else assign 
                                vdeMontantDepenseTVA                    = decimal(entry(9, ttImpression.cLigne, separ[1]))  + (if vlSensDepense then vdeDepenseTVA else - vdeDepenseTVA)
                                vdeMontantDepenseTTC                    = decimal(entry(10, ttImpression.cLigne, separ[1])) + (if vlSensDepense then vdeDepenseTTC else - vdeDepenseTTC)
                                entry(9, ttImpression.cLigne,separ[1])  = string(vdeMontantDepenseTVA, "->>>>>>>>>9.99")
                                entry(10, ttImpression.cLigne,separ[1]) = string(vdeMontantDepenseTTC, "->>>>>>>>>9.99")
                                .
                    end.
                end.
            end. 
        end.
    end.
end.
 
