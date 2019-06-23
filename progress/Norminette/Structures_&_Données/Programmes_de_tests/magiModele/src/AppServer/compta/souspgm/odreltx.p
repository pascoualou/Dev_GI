/*------------------------------------------------------------------------
File        : odreltx.p
Purpose     : OD de comptabilisation des reliquats Dossier travaux après cloture
Author(s)   : JR - 22/08/06  :  gga - 2017/05/15
Notes       : reprise du pgm cadb\src\gestion\odreltx.p

01 | 17/11/2006 |  JR  | 0606/0225 : Modif de comm/suppiece.i
02 | 06/09/2007 |  DM  | 0606/0225 : Modif de comm/suppiece.i
03 | 15/07/2008 |  RF  | 0306/0215 : Bascule sur dossier et gestion du plafond autorisé
04 | 25/01/2010 |  JR  | Modification suppiece.i
05 | 27/10/2011 |  DM  | 1010/0125 : Copros debiteurs
06 | 28/11/2012 |  NP  | 1112/0185 Enlever message Debug
07 | 05/06/2013 |  NP  | 0613/0022 modif suppiece.i
08 | 02/05/2014 |  DM  | 0414/0260 Pb lstop
09 | 02/12/2015 |  NP  | 1215/0002 modif suppiece.i
----------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

/* include pour le lettrage automatique */
/*gga pas de reprise, include vide
{gene/faletaut.def}
gga*/

{compta/include/tbTmpSld.i}
/** Procédure Sup_Comptabilisation **/
{compta/include/suppiece.i}

{travaux/include/suiviFinancier.i}

define variable giNumeroDossierTravaux as integer   no-undo.
define variable giNumeroMandat         as integer   no-undo.
define variable giSocIn                as integer   no-undo.
define variable glPlafondIn            as logical   no-undo.
define variable gdPlafondIn            as decimal   no-undo.
define variable glDebiteur             as logical   no-undo.
define variable gcCollectif01In        as character no-undo.
define variable gcLibIn                as character no-undo.
define variable gcCollectif02In        as character no-undo.
define variable giNoTrdIn              as integer   no-undo.
define variable gdaComptaIn            as date      no-undo.
define variable giErr-Out              as integer   no-undo.
define variable gcRef-Out              as character no-undo.
define variable gdaDatFin              as date      no-undo.
define variable gcJouCd                as character no-undo.
define variable gcDevMdt               as character no-undo.
define variable glValEcr               as logical   no-undo.
define variable gdDevMdtCours          as decimal   no-undo.
define variable gcTypeCle              as character no-undo.
define variable giPrdCd                as integer   no-undo.
define variable giPrdNum               as integer   no-undo.
define variable giNatJouCd             as integer   no-undo.
define variable giTypNatCd             as integer   no-undo.
define variable giProfilCd             as integer   no-undo.
define variable gcFPiece               as character no-undo.
define variable gcDevCab               as character no-undo.
define variable gdTxEuro               as decimal   no-undo.

procedure odreltxComptReliquat:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service appelé par dossierTravaux.p
    ------------------------------------------------------------------------------*/
    define input parameter  poCollection  as collection no-undo.
    define input-output parameter table for ttTmpSld.
    define input-output parameter table for ttListeSuiviFinancierClient.
    define output parameter piErrOut      as integer    no-undo.
    define output parameter pcRefOut      as character  no-undo.

    define variable viSociete       as integer    no-undo.
    define variable vcJournal       as character  no-undo.
    define variable vcTypeMouvement as character  no-undo.
    define variable vlCloture       as logical    no-undo.
    define buffer isoc     for isoc.
    define buffer ietab    for ietab.
    define buffer idev     for idev.
    define buffer ijou     for ijou.
    define buffer iprd     for iprd.
    define buffer itypemvt for itypemvt.
    define buffer agest    for agest.

    assign
        viSociete              = poCollection:getInteger('iSociete')
        vcJournal              = poCollection:getCharacter('cJournal')
        vcTypeMouvement        = poCollection:getCharacter('cTypeMouvement')
        vlCloture              = poCollection:getLogical('lCloture')
        giNumeroMandat         = poCollection:getInteger("iNumeroMandat")
        giNumeroDossierTravaux = poCollection:getInteger("iNumeroDossierTravaux")
        giNoTrdIn              = poCollection:getInteger('iNumDossier')
        gdaComptaIn            = poCollection:getDate('daComptable')
        gcLibIn                = poCollection:getCharacter('cLibelle')
        gcCollectif01In        = poCollection:getCharacter('cCodCollectif01')
        gcCollectif02In        = poCollection:getCharacter('cCodCollectif02')
        glPlafondIn            = poCollection:getLogical('lLimitePlafond')
        gdPlafondIn            = poCollection:getDecimal('dConfirmPlafond')
        glDebiteur             = poCollection:getLogical('lCoproDebUniquement')
    .
message "gga debut odreltx.p " giNumeroMandat "//" giNumeroDossierTravaux.
/*gga
    if not glNewErgo then
    do:                                                                   /*0108/0218*/
        get-key-value section "COMPTABILITE ADB" key "CheminProg" value RpRunGene. /* gidev\cadb\exe\gene\ */
        cDisque = os-getenv("Disque").

        assign
            tmp-cron     = true
            rpVerStd     = cdisque + REPLACE(Rprungene,"cadb","gest") /* d:\gidev\gest\exe\gene */
            rpVerSpe     = cdisque + Rprungene                        /* d:\gidev\cadb\exe\gene */
            rpRunBatSpe  = replace(rpVerSpe,"gene","batch")        /* d:\gidev\cadb\exe\batch */
            rpRunBatStd  = replace(rpVerStd,"gene","batch")        /* d:\gidev\gest\exe\batch */
            rpRunGestSpe = replace(rpVerSpe,"gene","gestion")
            rpRunBat     = RpRunBatSpe                                /* d:\gidev\cadb\exe\batch */
            .
    end.                                                                                                  /*0108/0218*/
    else assign tmp-cron     = true                                                                           /*0108/0218*/
            rpVerStd     = RpRunGen                                   /* d:\gidev\gest\exe\gene */        /*0108/0218*/
            rpVerSpe     = replace(rpVerStd,"gest","cadb")            /* d:\gidev\cadb\exe\gene */        /*0108/0218*/
            rpRunBatSpe  = replace(rpVerSpe,"gene","batch")        /* d:\gidev\cadb\exe\batch */       /*0108/0218*/
            rpRunBatStd  = replace(rpVerStd,"gene","batch")        /* d:\gidev\gest\exe\batch */       /*0108/0218*/
            rpRunGestSpe = replace(rpVerSpe,"gene","gestion")                                         /*0108/0218*/
            rpRunBat     = RpRunBatSpe                                /* d:\gidev\cadb\exe\batch */       /*0108/0218*/
            .

    /*MESSAGE "00000000000000" rpVerStd "//" rpVerSpe "//" rpRunBatSpe "//" rpRunBatStd "//" rpRunGestSpe "//" rpRunBat
    VIEW-AS ALERT-BOX. */	/* NP 1112/0185 */
gga*/
    find first isoc no-lock
         where isoc.soc-cd = viSociete no-error.
    if not available isoc
    then do:
        piErrOut = 3. /* société compta absente */
        return.
    end.
    find first ietab no-lock
         where ietab.soc-cd = isoc.soc-cd
           and ietab.profil-cd = 10 no-error.
    if not available ietab
    then do:
        piErrOut = 6. /* Mandat 8500 inexistant */
        return.
    end.
    find first idev no-lock
         where idev.soc-cd = isoc.soc-cd
           and idev.dev-cd = ietab.dev-cd no-error.
    if not available idev
    then do:
        piErrOut = 9. /* Devise Cabinet inexistante */
        return.
    end.
    find first ietab no-lock
         where ietab.soc-cd  = isoc.soc-cd
           and ietab.etab-cd = giNumeroMandat no-error.
    if not available ietab
    then do:
        piErrOut = 4. /* Mandat absent */
        return.
    end.
    find first idev no-lock
         where idev.soc-cd = isoc.soc-cd
           and idev.dev-cd = ietab.dev-cd no-error.
    if not available idev
    then do:
        piErrOut = 10. /* Devise Mandat inexistante */
        return.
    end.
    find first agest no-lock
         where agest.soc-cd   = ietab.soc-cd
           and agest.gest-cle = ietab.gest-cle no-error.
    if not available agest
    then do:
        piErrOut = 5. /* Gestionnaire Absent */
        return.
    end.
    find first itypemvt no-lock
         where itypemvt.soc-cd   = isoc.soc-cd
           and itypemvt.etab-cd  = ietab.etab-cd
           and itypemvt.type-cle = vcTypeMouvement no-error.
    if not available itypemvt
    then do:
        piErrOut = 12. /* Type de mouvement Absent */
        return.
    end.
    find first ijou no-lock
         where ijou.soc-cd    = isoc.soc-cd
           and ijou.etab-cd   = ietab.etab-cd
           and ijou.natjou-gi = 46
           and ijou.natjou-cd = itypemvt.natjou-cd
           and ijou.jou-cd    = vcJournal no-error.
    if not available ijou
    then do:
        piErrOut = 13. /* Journal inexistant */
        return.
    end.
    find first iprd no-lock
         where iprd.soc-cd   = isoc.soc-cd
           and iprd.etab-cd  = ietab.etab-cd
           and iprd.dadebprd <= gdaComptaIn
           and iprd.dafinprd >= gdaComptaIn no-error.
    if not available iprd
    then do:
        piErrOut = 14. /* Periode absente */
        return.
    end.
    if gdaComptaIn < if ietab.exercice then ietab.dadebex2 else ietab.dadebex1
    then do:
        piErrOut = 7. /* modif sur une exercice cloturé impossible */
        return.
    end.
    assign
        gdTxEuro      = isoc.tx-euro
        gcDevCab      = idev.dev-cd
        giProfilCd    = ietab.profil-cd
        gcDevMdt      = idev.dev-cd
        gdDevMdtCours = idev.cours
        gdaDatFin     = agest.dafin
        gcTypeCle     = itypemvt.type-cle
        giTypNatCd    = itypemvt.typenat-cd
        gcJouCd       = ijou.jou-cd
        glValEcr      = ijou.valecr
        giNatJouCd    = ijou.natjou-cd
        gcFPiece      = ijou.fpiece
        giPrdCd       = iprd.prd-cd
        giPrdNum      = iprd.prd-num
    .
    /*---------- Comptabilisation de l'OD de régularisation : à partir de apbco-tmp -------------*/
    empty temp-table tmp-cpt.
    
message "gga odreltx avant choix trt " vlCloture.

    if vlCloture
    then run Cre_ODSolde (buffer ietab).
    else run Cre_Comptabilisation (buffer ietab).
    assign
        piErrOut = giErr-Out
        pcRefOut = gcRef-Out
    .
end procedure.

procedure Cre_ODSolde private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer ietab for ietab.

    define variable vhProc     as handle  no-undo.
    define variable vrRecnoSai as rowid   no-undo.
    define variable vdSolde    as decimal no-undo.
    define variable vdTotDeb   as decimal no-undo.
    define variable vdTotCre   as decimal no-undo.

    define buffer cecrsai for cecrsai.

creod:
    do transaction on error undo, leave:

        run Creation-Entete (output vrRecnoSai).
message "gga odreltx avant lecture ttTmpSld".
        for each ttTmpSld:
message "gga odreltx dans lecture ttTmpSld" ttTmpSld.mtodt gdPlafondIn  glPlafondIn glDebiteur .

            /* 0306/0215     - Gestion du plafond */
            if ttTmpSld.mtodt <> 0
            and (absolute(ttTmpSld.mtodt) <= gdPlafondIn or not glPlafondIn)
            and (not glDebiteur or ttTmpSld.mtodt >= 0) /* DM 1010/0125 */
            then do:
message "gga odreltx avant ligne generale ".
                /** Collectif CHB **/
                run ligne-generale ((ttTmpSld.mtodt > 0),
                                    gcCollectif01In,
                                    string(ttTmpSld.nocop,"99999"),
                                    gcLibIn,
                                    "",
                                    absolute(ttTmpSld.mtodt),
                                    "",
                                    giNumeroDossierTravaux,
                                    vrRecnoSai).
                /** Collectif C OU CHB !!**/
                run ligne-generale (not (ttTmpSld.mtodt > 0),
                                    gcCollectif02In,
                                    string(ttTmpSld.nocop,"99999"),
                                    gcLibIn,
                                    "",
                                    absolute(ttTmpSld.mtodt),
                                    "",
                                    giNoTrdIn,
                                    vrRecnoSai).
            end.
        end.
        {&_proparse_ prolint-nowarn(nowait)}
        find first cecrsai exclusive-lock where rowid(cecrsai) = vrRecnoSai no-error.
        /**         cecrsai.situ = TRUE. */
        /*----------------------------------------------*/
        /*         MOUVEMENTS + DISPO                   */
        /*----------------------------------------------*/
        run compta/souspgm/cptmvt.p persistent set vhProc.
        run getTokenInstance in vhProc(mToken:JSessionId).
        run cptmvtMajMvtCpt in vhProc (vrRecnoSai).
        run destroy in vhProc.
        run effaparm (vrRecnoSai, cecrsai.soc-cd).
/*gga
        run difconv-euro.
gga*/
        /*----------------------------------------------*/
        /*        Controle d'equilibre de la piece      */
        /*----------------------------------------------*/
message "gga odreltx avant appel ctrlpiec.p ".
        run compta/souspgm/ctrlpiec.p persistent set vhProc.
        run getTokenInstance in vhProc(mToken:JSessionId).
        run ctrlpiecCtrlEquilibre in vhProc (vrRecnoSai, output vdSolde, output vdTotDeb, output vdTotCre).
        run destroy in vhProc.
message "gga odreltx apres appel ctrlpiec.p " vdSolde "//" vdTotDeb "//" vdTotCre .
        if vdSolde <> 0
        then do:
            giErr-Out = 17. /* Le total au debit est different du total au credit pour la piece : &1 */
            undo creod, return.
        end.
        assign
            cecrsai.mtdev = vdTotDeb
            gcRef-Out = substitute('&1|&2|&3|&4|&5|&6', cecrsai.soc-cd, cecrsai.etab-cd, cecrsai.jou-cd, cecrsai.prd-cd, cecrsai.prd-num, cecrsai.piece-compta)
        .
message "gga odreltx avant lettrage "  .
        run lettrage (giSocIn, giNumeroMandat, if ietab.exercice then ietab.dadebex2 else ietab.dadebex1, gdaDatFin).
        giErr-Out = 0. /* Pas d'erreur */
    end.

end procedure.

procedure Cre_Comptabilisation private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer ietab for ietab.

    define variable vrRecnoSai as rowid   no-undo.
    define variable vdSolde    as decimal no-undo.
    define variable vdTotDeb   as decimal no-undo.
    define variable vdTotCre   as decimal no-undo.
    define variable vhProc     as handle  no-undo.

    define buffer cecrsai for cecrsai.

crecompt:
    do transaction on error undo, leave:
        /*---------- Recherche du paramètre Encaissement -------------*/

        /*--> 0306/0215 - RF - Inutile, le plafond autorisé est transmis
        FIND FIRST parenc WHERE parenc.soc-cd  = gicodesoc
                          AND   parenc.etab-cd = gicodeetab
                          NO-LOCK NO-ERROR.
        */
        run Creation-Entete (output vrRecnoSai).
        for each ttListeSuiviFinancierClient:
            /* 0306/0215  - Gestion du plafond */
            if ttListeSuiviFinancierClient.dMontantResteDu <> 0
            and (absolute(ttListeSuiviFinancierClient.dMontantResteDu) <= gdPlafondIn or not glPlafondIn)
            and (not glDebiteur or ttListeSuiviFinancierClient.dMontantResteDu >= 0) /* DM 1010/0125 */
            then do:
                /** Collectif CHB **/
                run ligne-generale (not (ttListeSuiviFinancierClient.dMontantResteDu > 0),    // négatif
                                    gcCollectif01In,
                                    string(ttListeSuiviFinancierClient.iNumeroCoproprietaire, "99999"),
                                    gcLibIn,
                                    "",
                                    absolute(ttListeSuiviFinancierClient.dMontantResteDu),
                                    "",
                                    giNumeroDossierTravaux,
                                    vrRecnoSai).
                /** Collectif C OU CHB !!**/
                run ligne-generale ((ttListeSuiviFinancierClient.dMontantResteDu > 0),        // positif
                                    gcCollectif02In,
                                    string(ttListeSuiviFinancierClient.iNumeroCoproprietaire,"99999"),
                                    gcLibIn,
                                    "",
                                    absolute(ttListeSuiviFinancierClient.dMontantResteDu),
                                    "",
                                    giNoTrdIn,
                                    vrRecnoSai).
                if ttListeSuiviFinancierClient.dMontantResteDu > 0
                then ttListeSuiviFinancierClient.dMontantEncaissement = ttListeSuiviFinancierClient.dMontantEncaissement + absolute(ttListeSuiviFinancierClient.dMontantResteDu).
                else ttListeSuiviFinancierClient.dSommeAppelEmis      = ttListeSuiviFinancierClient.dSommeAppelEmis      + absolute(ttListeSuiviFinancierClient.dMontantResteDu).
                ttListeSuiviFinancierClient.dMontantResteDu = 0.
            end.
        end.
        {&_proparse_ prolint-nowarn(nowait)}
        find first cecrsai exclusive-lock where rowid(cecrsai) = vrRecnoSai no-error.
        /**         cecrsai.situ = TRUE. */
        /*----------------------------------------------*/
        /*         MOUVEMENTS + DISPO                   */
        /*----------------------------------------------*/
        run compta/souspgm/cptmvt.p persistent set vhProc.
        run getTokenInstance in vhProc(mToken:JSessionId).
        run cptmvtMajMvtCpt in vhProc (input rowid(cecrsai)).
        run destroy in vhProc.
        run effaparm (rowid(cecrsai), cecrsai.soc-cd).
/*gga
        run difconv-euro.
gga*/

        /*----------------------------------------------*/
        /*        Controle d'equilibre de la piece      */
        /*----------------------------------------------*/
        run compta/souspgm/ctrlpiec.p (rowid(cecrsai), output vdSolde, output vdTotDeb, output vdTotCre).
        if vdSolde <> 0
        then do:
            giErr-Out = 17. /* Le total au debit est different du total au credit pour la piece : &1 */
            undo crecompt, return.
        end.
        assign
            cecrsai.mtdev = vdTotDeb
            gcRef-Out     = substitute('&1|&2|&3|&4|&5|&6', cecrsai.soc-cd, cecrsai.etab-cd, cecrsai.jou-cd, cecrsai.prd-cd, cecrsai.prd-num, cecrsai.piece-compta)
        .
        run lettrage (giSocIn, giNumeroMandat, if ietab.exercice then ietab.dadebex2 else ietab.dadebex1, gdaDatFin).
        giErr-Out = 0. /* Pas d'erreur */
    end.

end procedure.

procedure creation-entete private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define output parameter prRecnoSai as rowid no-undo.

    define buffer cecrsai  for cecrsai.
    define buffer cnumpiec for cnumpiec.

    create cecrsai.
    assign
        cecrsai.soc-cd     = giSocIn
        cecrsai.etab-cd    = giNumeroMandat
        cecrsai.jou-cd     = gcJouCd
        cecrsai.daecr      = gdaComptaIn
        cecrsai.lib        = "Comptabilisation des reliquats"
        cecrsai.dacrea     = today
        cecrsai.dev-cd     = gcDevMdt
        cecrsai.usrid      = "odreltx.p"
        cecrsai.consol     = false
        cecrsai.bonapaye   = true
        cecrsai.situ       = glValEcr
        cecrsai.cours      = gdDevMdtCours
        cecrsai.mtregl     = 0
        cecrsai.type-cle   = gcTypeCle
        cecrsai.prd-cd     = giPrdCd
        cecrsai.prd-num    = giPrdNum
        cecrsai.mtdev      = 0
        cecrsai.natjou-cd  = giNatJouCd
        cecrsai.dadoss     = ? /* TODAY */
        cecrsai.dacompta   = gdaComptaIn
        cecrsai.ref-num    = ""
        cecrsai.coll-cle   = ""
        cecrsai.mtimput    = 0
        cecrsai.acompte    = false
        cecrsai.adr-cd     = 0
        cecrsai.typenat-cd = giTypNatCd
        cecrsai.profil-cd  = giProfilCd
        prRecnoSai         = rowid (cecrsai)
    .

    /****************************************
       AFFECTATION piece-int et piece-compta    (Ajout OF le 28/05/99 pour Avance/echu)
    *****************************************/
    {&_proparse_ prolint-nowarn(nowait)}
    find first cnumpiec exclusive-lock
         where cnumpiec.soc-cd  = giSocIn
           and cnumpiec.etab-cd = giNumeroMandat
           and cnumpiec.jou-cd  = cecrsai.jou-cd
           and cnumpiec.prd-cd  = cecrsai.prd-cd
           and cnumpiec.prd-num = cecrsai.prd-num no-error.
    if available cnumpiec
    then assign
             cecrsai.piece-int     = cnumpiec.piece-int + 1
             cnumpiec.piece-int    = cecrsai.piece-int
             cnumpiec.piece-compta = cnumpiec.piece-compta + 1
             cecrsai.piece-compta  = cnumpiec.piece-compta
    .
    else do:
        create cnumpiec.
        assign
            cnumpiec.soc-cd       = giSocIn
            cnumpiec.etab-cd      = giNumeroMandat
            cnumpiec.jou-cd       = cecrsai.jou-cd
            cnumpiec.prd-cd       = cecrsai.prd-cd
            cnumpiec.prd-num      = cecrsai.prd-num
            cnumpiec.piece-compta = inumpiecNumerotationPiece(gcFPiece, cecrsai.dacompta) + 1
            cnumpiec.piece-int    = 1
            cecrsai.piece-int     = 1
            cecrsai.piece-compta  = cnumpiec.piece-compta
        .
    end.

end procedure.

procedure ligne-generale private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter plSnsIn        as logical   no-undo.
    define input parameter pcColIn        as character no-undo.
    define input parameter pcCptIn        as character no-undo.
    define input parameter pcLibIn        as character no-undo.
    define input parameter pcLib2In       as character no-undo.
    define input parameter pdMtIn         as decimal   no-undo.
    define input parameter pcRefNumIn     as character no-undo.
    define input parameter piAffairNumIn  as integer   no-undo.
    define input parameter prRecnoSai      as rowid     no-undo.

    define variable viLig as integer no-undo.

    define buffer csscpt  for csscpt.
    define buffer cecrsai for cecrsai.
    define buffer cecrln  for cecrln.
    define buffer ccpt    for ccpt.

    find first csscpt no-lock
         where csscpt.soc-cd   = giSocIn
           and csscpt.etab-cd    = giNumeroMandat
           and csscpt.sscoll-cle = pcColIn
           and csscpt.cpt-cd     = pcCptIn no-error.
    if not available csscpt then return.
    find first ccpt no-lock
         where ccpt.soc-cd = giSocIn
           and ccpt.coll-cle = csscpt.coll-cle
           and ccpt.cpt-cd   = csscpt.cpt-cd no-error.
    if not available ccpt then return.
    find first cecrsai no-lock
    where rowid(cecrsai) = prRecnoSai no-error.
    if not available cecrsai then return.

    viLig = viLig + 1.
    create cecrln.
    assign
        cecrln.soc-cd         = giSocIn
        cecrln.etab-cd        = giNumeroMandat
        cecrln.jou-cd         = cecrsai.jou-cd
        cecrln.piece-int      = cecrsai.piece-int
        cecrln.sscoll-cle     = csscpt.sscoll-cle
        cecrln.cpt-cd         = csscpt.cpt-cd
        cecrln.lib            = pcLibIn
        cecrln.lib-ecr[1]     = pcLibIn
        cecrln.lib-ecr[2]     = pcLib2In
        cecrln.sens           = plSnsIn
        cecrln.analytique     = false
        cecrln.type-cle       = cecrsai.type-cle
        cecrln.datecr         = cecrsai.daecr
        cecrln.prd-cd         = giPrdCd
        cecrln.prd-num        = giPrdNum
        cecrln.lig            = viLig
        cecrln.dev-cd         = gcDevCab
        cecrln.devetr-cd      = if gcDevMdt <> gcDevCab
                                then gcDevMdt
                                else ""
        cecrln.mtdev          = if cecrln.devetr-cd > ""
                                then if gdTxEuro = 1
                                     then pdMtIn * cecrsai.cours
                                     else pdMtIn / cecrsai.cours
                                else 0   /* en devise d'entrée   */
        cecrln.mt             = pdMtIn  /* en devise du Cabinet */
        cecrln.taux           = 0
        cecrln.coll-cle       = ccpt.coll-cle
        cecrln.paie-regl      = false
        cecrln.taxe-cd        = if ccpt.libcat-cd = 2 then 9 else 0
        cecrln.tva-enc-deb    = false
        cecrln.dacompta       = cecrsai.dacompta
        cecrln.ref-num        = pcRefNumIn
        cecrln.affair-num     = piAffairNumIn
        cecrln.flag-lettre    = false
        cecrln.daech          = ?
        cecrln.type-ecr       = 1
        cecrln.mandat-cd      = giNumeroMandat
        cecrln.mandat-prd-cd  = cecrsai.prd-cd
        cecrln.mandat-prd-num = cecrsai.prd-num
        cecrln.fg-ana100      = false
        cecrln.profil-cd      = giProfilCd
    .
    find first tmp-cpt
         where tmp-cpt.cpt-cd = cecrln.cpt-cd
           and tmp-cpt.sscoll-cle = cecrln.sscoll-cle no-error.
    if not available tmp-cpt
    then do:
        create tmp-cpt.
        assign
            tmp-cpt.sscoll-cle = cecrln.sscoll-cle
            tmp-cpt.coll-cle   = cecrln.coll-cle
            tmp-cpt.cpt-cd     = cecrln.cpt-cd
            tmp-cpt.etab-cd    = cecrln.etab-cd
        .
    end.

end procedure. /* procedure ligne-generale : */

/*gga todo a voir pourquoi cette procedure
procedure difconv-euro private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/

    define variable dsolde as decimal no-undo.
    define variable ilig   as integer no-undo.

    for each cecrln no-lock
    where cecrln.soc-cd         = cecrsai.soc-cd
        and cecrln.mandat-cd      = cecrsai.etab-cd
        and cecrln.jou-cd         = cecrsai.jou-cd
        and cecrln.mandat-prd-cd  = cecrsai.prd-cd
        and cecrln.mandat-prd-num = cecrsai.prd-num
        and cecrln.piece-int      = cecrsai.piece-int
        by cecrln.soc-cd
        by cecrln.mandat-cd
        by cecrln.jou-cd
        by cecrln.mandat-prd-cd
        by cecrln.mandat-prd-num
        by cecrln.piece-int
        by cecrln.lig
        :
        assign
            dSolde = dSolde + cecrln.mt-euro * (if cecrln.sens then 1 else -1)
            iLig   = cecrln.lig.
    end.
    if dSolde ne 0 then run VALUE( rpRunBatSpe + "otelocka.p") (input (string(dsolde) + "|" + string(ilig))+ "| ",
            input recno-sai).

end procedure.
gga*/

