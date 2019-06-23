/*------------------------------------------------------------------------
File        : periodeChargesCopro.p
Purpose     : Périodes de charges de copropriété
Author(s)   : OFA  -  2019/01/07
Notes       : reprise du pgm adb/tach/prmobper.p
derniere revue: 2019/01/25 - gga: KO
en attente de reflexion sur code en commentaire    
------------------------------------------------------------------------*/
using parametre.syspr.syspr.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

&SCOPED-DEFINE iNombreMoisMaxiParExercice 23
{application/include/glbsepar.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2role.i}
{preprocesseur/type2tache.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/statut2periode.i}
{preprocesseur/codePeriode.i}
{preprocesseur/typeAppel.i}
{preprocesseur/type2Bien.i}
{application/include/error.i}
{application/include/combo.i}
{mandat/include/periodeChargesCopro.i}
{crud/include/perio.i}
{crud/include/ctrat.i}
{crud/include/budge.i}
{crud/include/ebupr.i}
{crud/include/cttac.i}
{crud/include/apbet.i}
{crud/include/apfet.i}
//{crud/include/ietab.i}
//{crud/include/iprd.i}

define temp-table ttIetab
    field soc-cd      as integer
    field etab-cd     as integer
    field prd-cd-1    as integer
    field dadebex1    as date
    field dafinex1    as date
    field prd-cd-2    as integer
    field dadebex2    as date
    field dafinex2    as date
    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
    .

procedure getPeriodesCopro:
    /*------------------------------------------------------------------------------
    Purpose: Récupération de la listes des périodes de copropriété
    Notes  : service externe (beMandatSyndic.cls)
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as int64 no-undo.
    define output parameter table for ttPeriodeChargesCopro.

    define variable vhProc as handle no-undo.
    define buffer ctrat for ctrat.
    define buffer intnt for intnt.
    define buffer trfpm for trfpm.

    empty temp-table ttPeriodeChargesCopro.
    find first ctrat no-lock
        where ctrat.tpcon = {&TYPECONTRAT-mandat2Syndic}
          and ctrat.nocon = piNumeroMandat no-error.
    if not available ctrat then do:
        mError:createError({&error}, 100057).
        return.
    end.

    run crud/perio_CRUD.p persistent set vhProc.
    run getTokenInstance in vhProc(mToken:JSessionId).
    run getPerio in vhProc(ctrat.tpcon, ctrat.nocon, ?, output table ttPeriodeChargesCopro by-reference).
    run destroy in vhProc.

    for each ttPeriodeChargesCopro,
        first intnt no-lock
        where intnt.tpidt = {&TYPEBIEN-immeuble}
        and   intnt.tpcon = {&TYPECONTRAT-mandat2Syndic}
        and   intnt.nocon = ttPeriodeChargesCopro.iNumeroMandat:
        if ttPeriodeChargesCopro.cCodeTraitement = {&STATUTPERIODE-Traite} then
            for first trfpm no-lock
                where trfpm.tptrf = {&TYPEAPPEL-charge}
                and   trfpm.tpapp = ""
                and   trfpm.nomdt = ctrat.nocon
                and   trfpm.noexe = ttPeriodeChargesCopro.iNumeroExercice:
                assign
                    ttPeriodeChargesCopro.cLibelleCodeTraitement = string(trfpm.dttrf, "99/99/9999")
                    ttPeriodeChargesCopro.lIsModifiable = no
                    .
            end.
        else
            assign
                ttPeriodeChargesCopro.cLibelleCodeTraitement = outilTraduction:getLibelleParam("CDTRT", ttPeriodeChargesCopro.cCodeTraitement)
                ttPeriodeChargesCopro.lIsModifiable = not can-find(first ccptmvt no-lock
                                                                   where ccptmvt.soc-cd  = integer(mtoken:cRefCopro)
                                                                   and   ccptmvt.etab-cd = ctrat.nocon
                                                                   and   ccptmvt.prd-cd >= ttPeriodeChargesCopro.iNumeroExercice)
                                                      and not can-find(first lprtb no-lock
                                                                       where lprtb.tpcon = ctrat.tpcon
                                                                       and   lprtb.nocon = ctrat.nocon
                                                                       and   lprtb.noExe = ttPeriodeChargesCopro.iNumeroExercice
                                                                       and   lprtb.tpcpt <> {&TYPECONTRAT-mutation}
                                                                       and   lprtb.cdtrt = {&STATUTPERIODE-EnCours})
                                                      and not can-find(first apbet no-lock
                                                                       where apbet.tpapp = {&TYPEBUDGET-budget}
                                                                       and   apbet.nobud = int64(ctrat.nocon * 100000 + ttPeriodeChargesCopro.iNumeroExercice))
                                                      and not can-find(first apfet no-lock
                                                                       where apfet.noimm = intnt.noidt
                                                                       and   apfet.nofon = int64(ctrat.nocon * 100000 + ttPeriodeChargesCopro.iNumeroExercice)
                                                                       and   apfet.tpapp = {&TYPEBUDGET-fondsTravauxAlur})
            .
    end.

end procedure.

procedure initPeriodesCopro:
    /*------------------------------------------------------------------------------
    Purpose: Initialisation des périodes de copropriété en création
    Notes  : service externe (beMandatSyndic.cls)
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as int64 no-undo.
    define output parameter table for ttPeriodeChargesCopro.

    define variable viNouvelExercice       as integer no-undo.
    define variable vdaFinDernierExercice  as date    no-undo.
    define variable viNombreMois           as integer no-undo.

    define buffer ctrat for ctrat.
    define buffer perio for perio.
    define buffer vbTtPeriodeChargesCopro for ttPeriodeChargesCopro.

    empty temp-table ttPeriodeChargesCopro.
    find first ctrat no-lock
        where ctrat.tpcon = {&TYPECONTRAT-mandat2Syndic}
          and ctrat.nocon = piNumeroMandat no-error.
    if not available ctrat then do:
        mError:createError({&error}, 100057).
        return.
    end.

    for last perio no-lock
        where perio.tpctt = ctrat.tpcon
        and   perio.nomdt = ctrat.nocon
        use-index ix_perio01:
        assign
            viNouvelExercice      = perio.noexo + 1
            vdaFinDernierExercice = perio.dtfin
            viNombreMois          = perio.nbmoi
            .
    end.

    if viNouvelExercice = 0 then
        assign
            viNouvelExercice        = 10
            vdaFinDernierExercice   = ?
            viNombreMois           = 12
            .

    create ttPeriodeChargesCopro.
    assign
        ttPeriodeChargesCopro.cTypeContrat     = ctrat.tpcon
        ttPeriodeChargesCopro.iNumeroMandat    = ctrat.nocon
        ttPeriodeChargesCopro.iNumeroExercice  = viNouvelExercice
        ttPeriodeChargesCopro.iNumeroPeriode   = 0
        ttPeriodeChargesCopro.daDebut          = if vdaFinDernierExercice <> ? then vdaFinDernierExercice + 1
                                                 else if ctrat.ntcon = {&NATURECONTRAT-restaurantInterEntreprise} then date(1, 1, year(ctrat.dtdeb))
                                                 else ?
        ttPeriodeChargesCopro.daFin            = if vdaFinDernierExercice <> ? then add-interval(vdaFinDernierExercice,1,"year")
                                                 else if ctrat.ntcon = {&NATURECONTRAT-restaurantInterEntreprise} then date(12, 31, year(ctrat.dtdeb))
                                                 else ?
        ttPeriodeChargesCopro.cLibellePeriode  = if ttPeriodeChargesCopro.daDebut <> ? then substitute(" &1 &2 - &3", outilTraduction:getLibelle(103053), string(ttPeriodeChargesCopro.daDebut,"99/99/9999"), string(ttPeriodeChargesCopro.dafin,"99/99/9999"))
                                                 else ""
        ttPeriodeChargesCopro.iNombreMois      = 12
        ttPeriodeChargesCopro.cCodePeriodicite = {&CODEPERIODE-annuel}
        ttPeriodeChargesCopro.lIsModifiable    = true
        .
    create vbTtPeriodeChargesCopro.
    buffer-copy ttPeriodeChargesCopro to vbTtPeriodeChargesCopro
    assign
        vbTtPeriodeChargesCopro.iNumeroPeriode         = 1
        vbTtPeriodeChargesCopro.cCodeTraitement        = {&STATUTPERIODE-EnCours}
        vbTtPeriodeChargesCopro.cLibelleCodeTraitement = outilTraduction:getLibelleParam("CDTRT","00001")
        .

end procedure.

procedure getComboPeriodicite:
    /*------------------------------------------------------------------------------
    Purpose: Alimentation combo périodicité des charges du mandat
    Notes  : service externe (beMandatSyndic.cls)
    ------------------------------------------------------------------------------*/
    define input parameter pcNatureMandat as character   no-undo.
    define output parameter table for ttCombo.

    define variable voSyspr        as class syspr no-undo.

    voSyspr = new syspr("", "").
    if pcNatureMandat = {&NATURECONTRAT-restaurantInterEntreprise} then
        voSyspr:getComboParametreListe("TPPER", "00001",  "CMBPERIODICITE", output table ttCombo by-reference). //Seulement périodicité annuelle pour les RIE
    else
        voSyspr:getComboParametre("TPPER", "CMBPERIODICITE", output table ttCombo by-reference).

    delete object voSyspr.

end procedure.

procedure setPeriodesCopro:
    /*------------------------------------------------------------------------------
    Purpose: Validation des périodes de charges de copropriété
    Notes  : service externe (beMandatSyndic.cls)
    ------------------------------------------------------------------------------*/
    define input-output parameter table for ttPeriodeChargesCopro.
    define input        parameter table for ttError.

    define variable vhProc                  as handle no-undo.
    define variable vhProcIetab             as handle no-undo.
    define variable voCollection            as class collection no-undo.
    define variable viNombreMoisExercice    as integer no-undo.

    empty temp-table ttCtrat.
    empty temp-table ttBudge.
    empty temp-table ttEbupr.
    empty temp-table ttCttac.

    define buffer ietab for ietab.
    define buffer ccptmvt for ccptmvt.
    define buffer ctrat for ctrat.
    define buffer iprd for iprd.

    run crud/ietab_CRUD.p persistent set vhProcIetab.
    run getTokenInstance in vhProcIetab(mToken:JSessionId).
    voCollection = new collection().
    for first ttPeriodeChargesCopro
        where ttPeriodeChargesCopro.iNumeroPeriode = 0
        and   ttPeriodeChargesCopro.CRUD = "U",
        first ietab no-lock
        where  ietab.soc-cd = integer(mtoken:cRefCopro)
        and    ietab.etab-cd = ttPeriodeChargesCopro.iNumeroMandat:
        run readIetab in vhProcIetab(ietab.soc-cd, ietab.etab-cd, table ttIetab by-reference).
        /*for first ccptmvt no-lock
            where ccptmvt.soc-cd  = ietab.soc-cd
            and   ccptmvt.etab-cd = ietab.etab-cd,
            first iprd no-lock
            where iprd.soc-cd = ccptmvt.soc-cd
            and   iprd.etab-cd = ccptmvt.etab-cd
            and   iprd.prd-cd = ccptmvt.prd-cd
            and   iprd.prd-num = ccptmvt.prd-num:
            voCollection:set('iExercicePremierMouvement' , ccptmvt.prd-cd) no-error.
            voCollection:set('iPeriodePremierMouvement' , ccptmvt.prd-num) no-error.
            voCollection:set('daDebutPremierMouvement' , iprd.dadebprd) no-error.
        end.
        voCollection:set('iPremierExerciceCompta' , ietab.prd-cd-1) no-error.
        voCollection:set('iSecondExerciceCompta' , ietab.prd-cd-2) no-error.
        voCollection:set('daFinPremierExerciceModifie' , ttPeriodeChargesCopro.daFin) no-error.*/ //TODO : pour report règles de gestion utilitaire de changement de période
        voCollection:set('iPremierExerciceComptaModifie' , if ttPeriodeChargesCopro.daDebut = ietab.dadebex1 then 1
                                                           else if ttPeriodeChargesCopro.daDebut = ietab.dadebex2 then 2
                                                           else 0) no-error.

        if ttPeriodeChargesCopro.daDebut < ietab.dadebex1 then do:
            //Vous ne pouvez pas modifier l'exercice budget (&1 - &2) car il est antérieur au premier exercice comptable en cours (&3 - &4)
            mError:createError({&error}, substitute("&1&2&3&2&4&2&5", ttPeriodeChargesCopro.daDebut, separ[1], ttPeriodeChargesCopro.daFin, ietab.dadebex1, ietab.dafinex1)).
            run destroy in vhProcIetab.
            delete object voCollection.
            return.
        end.
    end.

    for each ttPeriodeChargesCopro
        where ttPeriodeChargesCopro.iNumeroPeriode = 0
        and   lookup(ttPeriodeChargesCopro.CRUD, "C,U,D") > 0,
        first ctrat no-lock
        where ctrat.tpcon = {&TYPECONTRAT-mandat2Syndic}
        and   ctrat.nocon = ttPeriodeChargesCopro.iNumeroMandat
        by ttPeriodeChargesCopro.daDebut:

        viNombreMoisExercice = interval(ttPeriodeChargesCopro.dafin, ttPeriodeChargesCopro.dadeb, "month") + 1.
        if viNombreMoisExercice > 18 then do:
            if viNombreMoisExercice > {&iNombreMoisMaxiParExercice} then do:
                //La durée de l'exercice ne peut excéder &1 mois
                mError:createError({&error}, 1000974, string({&iNombreMoisMaxiParExercice})).
                run destroy in vhProcIetab.
                delete object voCollection.
                return.
            end.
            //"La durée de l'exercice ne devrait pas dépasser 18 mois (C.F. décret 2005-240 du 14 mars 2005 art.5 :%s...Pour le premier exercice, l'assemblée générale des copropriétaires fixe la date de clôture des comptes et la durée de cet exercice qui ne pourra excéder dix-huit mois.) %s Confirmez-vous votre saisie à &1 mois ?"
            if outils:questionnaire(1000973, table ttError by-reference) <= 2 then do:
                run destroy in vhProcIetab.
                delete object voCollection.
                return.
            end.
        end.
        if viNombreMoisExercice < 1 then do:
            mError:createError({&error}, 102387).
            run destroy in vhProcIetab.
            delete object voCollection.
            return.
        end.
        if ctrat.ntcon = {&NATURECONTRAT-restaurantInterEntreprise}
        and interval(ttPeriodeChargesCopro.dafin + 1, ttPeriodeChargesCopro.dadeb, "month") <> 12
        then do:
            mError:createError({&error}, 1000986). //L'exercice d'un R.I.E. doit être annuel. Dates incorrectes.
            run destroy in vhProcIetab.
            delete object voCollection.
            return.
        end.
        run updateBudget.
        run updateExerciceComptable(voCollection).
        //run updateAppelsDeFonds. -> On bloque pour le moment la modification de périodes ayant des appels de fonds budget ou FTA sinon il faut gérer la renumérotation
    end.

    run crud/perio_CRUD.p persistent set vhProc.
    run getTokenInstance in vhProc(mToken:JSessionId).
    run setPerio in vhProc(table ttPeriodeChargesCopro by-reference).
    run destroy in vhproc.

    run crud/ctrat_CRUD.p persistent set vhProc.
    run getTokenInstance in vhProc(mToken:JSessionId).
    run setCtrat in vhProc(table ttCtrat by-reference).
    run destroy in vhproc.

    run crud/budge_CRUD.p persistent set vhProc.
    run getTokenInstance in vhProc(mToken:JSessionId).
    run setBudge in vhProc(table ttBudge by-reference).
    run destroy in vhproc.

    run crud/ebupr_CRUD.p persistent set vhProc.
    run getTokenInstance in vhProc(mToken:JSessionId).
    run setEbupr in vhProc(table ttEbupr by-reference).
    run destroy in vhproc.

    for first ttIetab:
        for last iprd no-lock
            where iprd.soc-cd = ttIetab.soc-cd
            and   iprd.etab-cd = ttIetab.etab-cd
            and   iprd.prd-cd = ttIetab.prd-cd-1:
            ttIetab.dafinex1 = iprd.daFinprd.
        end.
        for first iprd no-lock
            where iprd.soc-cd = ttIetab.soc-cd
            and   iprd.etab-cd = ttIetab.etab-cd
            and   iprd.prd-cd = ttIetab.prd-cd-2:
            ttIetab.dadebex2 = iprd.dadebprd.
        end.
        for last iprd no-lock
            where iprd.soc-cd = ttIetab.soc-cd
            and   iprd.etab-cd = ttIetab.etab-cd
            and   iprd.prd-cd = ttIetab.prd-cd-2:
            ttIetab.dafinex2 = iprd.daFinprd.
        end.
        ttIetab.crud = "U".
    end.
    run setIetab in vhProcIetab(table ttIetab by-reference).
    run destroy in vhProcIetab.

    delete object voCollection.

end procedure.

procedure updateBudget private:
    /*------------------------------------------------------------------------------
    Purpose: Création/modification du budget par défaut
    Notes  : Ancienne procédure GesBudDf
    ------------------------------------------------------------------------------*/
    define variable viNumeroBudget as integer no-undo.
    define variable vhProc as handle no-undo.

    define buffer ctrat for ctrat.

    viNumeroBudget = ttPeriodeChargesCopro.iNumeroMandat * 100000 + ttPeriodeChargesCopro.iNumeroExercice.

    if not can-find(first budge no-lock
                    where budge.Tpbud = {&TYPECONTRAT-budget}
                    and   budge.Nobud = viNumeroBudget)
    then do:
        create ttCtrat.
        assign
            ttCtrat.tpcon = {&TYPECONTRAT-budget}
            ttCtrat.nocon = viNumeroBudget
            ttCtrat.dtdeb = ttPeriodeChargesCopro.daDebut
            ttCtrat.ntcon = {&NATURECONTRAT-Budget}
            ttCtrat.dtfin = ttPeriodeChargesCopro.dafin
            ttCtrat.tprol = {&TYPEROLE-syndicat2copro}
            ttCtrat.norol = ttPeriodeChargesCopro.iNumeroMandat
            ttCtrat.CRUD  = "C"
        .

        create ttBudge.
        assign
            ttBudge.tpbud = {&TYPECONTRAT-budget}
            ttBudge.nobud = viNumeroBudget
            ttBudge.lbbud = ttPeriodeChargesCopro.cLibellePeriode
            ttBudge.cdper = ttPeriodeChargesCopro.cCodePeriodicite
            ttBudge.CRUD  = "C"
        .

        create ttEbupr.
        assign
            ttEbupr.nobud = viNumeroBudget
            ttEbupr.dtdeb = ttPeriodeChargesCopro.daDebut
            ttEbupr.dtfin = ttPeriodeChargesCopro.dafin
            ttEbupr.nbmoi = ttPeriodeChargesCopro.iNombreMois
            ttEbupr.CRUD  = "C"
        .

    end.
    else do:
        for first ctrat no-lock
            where ctrat.tpcon = {&TYPECONTRAT-budget}
            and   ctrat.nocon = viNumeroBudget:

            run crud/ctrat_CRUD.p persistent set vhProc.
            run getTokenInstance in vhProc(mToken:JSessionId).
            run readCtrat in vhProc({&TYPECONTRAT-budget}, viNumeroBudget, table ttCtrat by-reference).
            for first ttCtrat
                where ttCtrat.tpcon = {&TYPECONTRAT-budget}
                  and ttCtrat.nocon = viNumeroBudget:
                assign
                    ttCtrat.dtdeb = ttPeriodeChargesCopro.daDebut
                    ttCtrat.dtfin = ttPeriodeChargesCopro.dafin
                    ttCtrat.CRUD  = "U"
                .
            end.
            run destroy in vhproc.

            run crud/budge_CRUD.p persistent set vhProc.
            run getTokenInstance in vhProc(mToken:JSessionId).
            run readBudge in vhProc({&TYPECONTRAT-budget}, viNumeroBudget, table ttBudge by-reference).
            for first ttBudge
                where ttBudge.tpbud = {&TYPECONTRAT-budget}
                  and ttBudge.nobud = viNumeroBudget:
                assign
                    ttBudge.lbbud = ttPeriodeChargesCopro.cLibellePeriode
                    ttBudge.cdper = ttPeriodeChargesCopro.cCodePeriodicite
                    ttBudge.CRUD  = "U"
                .
            end.
            run destroy in vhproc.

            run crud/ebupr_CRUD.p persistent set vhProc.
            run getTokenInstance in vhProc(mToken:JSessionId).
            run readEbupr in vhProc(viNumeroBudget, table ttEbupr by-reference).
            for first ttEbupr
                where ttEbupr.nobud = viNumeroBudget:
                assign
                    ttEbupr.dtdeb = ttPeriodeChargesCopro.daDebut
                    ttEbupr.dtfin = ttPeriodeChargesCopro.dafin
                    ttEbupr.nbmoi = interval(ttPeriodeChargesCopro.dafin, ttPeriodeChargesCopro.dadeb, "month") + 1
                    ttEbupr.CRUD  = "U"
                .
            end.
            run destroy in vhproc.
        end.
    end.

    run updateLienTacheContratBudget (viNumeroBudget).

end procedure.

procedure updateExerciceComptable private:
    /*------------------------------------------------------------------------------
    Purpose: Création/modification des périodes en comptabilité pour les aligner sur celles de gestion
    Notes  : Etait géré dans MaGI par la procédure majmdt.p
    ------------------------------------------------------------------------------*/
    define input parameter poCollection   as class collection no-undo.

    define variable vhProc as handle no-undo.
    define buffer ietab for ietab.

    for first ietab no-lock
        where  ietab.soc-cd = integer(mtoken:cRefCopro)
        and    ietab.etab-cd = ttPeriodeChargesCopro.iNumeroMandat:
        if (ttPeriodeChargesCopro.daDebut <> ietab.dadebex1 and ttPeriodeChargesCopro.daDebut <> ietab.dadebex2)
        or (ttPeriodeChargesCopro.daFin <> ietab.dafinex1 and ttPeriodeChargesCopro.daFin <> ietab.dafinex2)
        then do:
            run crud/iprd_CRUD.p persistent set vhProc.
            run getTokenInstance in vhProc(mToken:JSessionId).
            //Si exercice 1 de compta modifié
            if poCollection:getInteger('iPremierExerciceComptaModifie') = 1 then do:
                //Suppression exercice 2 de compta
                run suppressionIprdParExercice in vhProc(ietab.soc-cd, ietab.etab-cd, ietab.prd-cd-2).
                //Suppression périodes entre la date de fin de l'exercice budget et la date de fin de l'exercice 1 de compta
                if ttPeriodeChargesCopro.daFin < ietab.dafinex1 then
                    run suppressionIprdParDate in vhProc(ietab.soc-cd, ietab.etab-cd, ttPeriodeChargesCopro.daFin, ietab.dafinex1).
                //Création périodes entre la date de fin de l'exercice 1 de compta et la date de fin de l'exercice budget
                else if ttPeriodeChargesCopro.daDeb = ietab.dadebex1 then
                    run creationNouvellesPeriodes in vhProc(ietab.soc-cd, ietab.etab-cd, ietab.prd-cd-1, ietab.dafinex1 + 1, ttPeriodeChargesCopro.daFin).
            end.
            //Si exercice 2 de compta modifié
            else do:
                //Suppression périodes entre la date de fin de l'exercice budget et la date de fin de l'exercice 2 de compta
                if ttPeriodeChargesCopro.daFin < ietab.dafinex2 then
                    run suppressionIprdParDate in vhProc(ietab.soc-cd, ietab.etab-cd, ttPeriodeChargesCopro.daFin, ietab.dafinex2).
                //Création périodes entre la date de fin de l'exercice 2 de compta et la date de fin de l'exercice budget
                else if ttPeriodeChargesCopro.daDeb = ietab.dadebex2 then
                    run creationNouvellesPeriodes in vhProc(ietab.soc-cd, ietab.etab-cd, ietab.prd-cd-2, ietab.dafinex2 + 1, ttPeriodeChargesCopro.daFin).
            end.
            //Création des nouvelles périodes comptables
            run creationNouvelExercice in vhProc(ietab.soc-cd, ietab.etab-cd, ttPeriodeChargesCopro.daDebut, ttPeriodeChargesCopro.daFin, ?).
            run destroy in vhProc.
        end.
    end.

end procedure.

procedure updateLienTacheContratBudget private:
    /*------------------------------------------------------------------------------
    Purpose: Génération des liens taches du budget
    Notes  : Ancienne procédure GenTacBud
    ------------------------------------------------------------------------------*/
    define input parameter  piNumeroBudget as integer no-undo.

    define variable vhProc as handle no-undo.
    define buffer   sys_pg for sys_pg.
    define buffer   vbSys_pg for sys_pg.

    //Recherche des tâches du contrat
    for each sys_pg no-lock
        where sys_pg.tppar = 'R_CTA'
          and sys_pg.zone1 = {&NATURECONTRAT-Budget}
          and not can-find(first cttac no-lock
                           where cttac.tpcon = {&TYPECONTRAT-budget}
                           and   cttac.nocon = piNumeroBudget
                           and   cttac.tptac = sys_pg.zone2),
        first vbSys_pg no-lock
            where vbSys_pg.tppar = 'O_TAE'
            and   vbSys_pg.cdpar = sys_pg.zone2:

        if lookup(entry(1, vbSys_pg.zone9, '@'),'C,L') > 0
           or entry(3, vbSys_pg.zone9, '@') begins 'A' //tâches automatiques
           or (sys_pg.zone2 >= {&TYPETACHE-eauChaude} and sys_pg.zone2 <= {&TYPETACHE-uniteEvaporation} //tâches relevés
               and can-find(first Cttac no-lock
                            where Cttac.Tpcon = {&TYPECONTRAT-mandat2Syndic}
                            and   Cttac.Nocon = integer(piNumeroBudget / 100000)
                            and   Cttac.Tptac = sys_pg.zone2))
        then do:
            create ttCttac.
            assign
                ttCttac.Tpcon = {&TYPECONTRAT-budget}
                ttCttac.Nocon = piNumeroBudget
                ttCttac.Tptac = sys_pg.zone2
                ttCttac.CRUD  = "C"
            .
        end.
    end.

    run crud/cttac_CRUD.p persistent set vhProc.
    run getTokenInstance in vhProc(mToken:JSessionId).
    run setCttac in vhProc(table ttCttac by-reference).
    run destroy in vhproc.

end procedure.

/*pour le moment conserver ce code (On bloque pour le moment la modification de périodes ayant des appels de fonds budget ou FTA sinon il faut gérer la renumérotation)
procedure updateAppelsDeFonds private:
    /*------------------------------------------------------------------------------
    Purpose: Mise à jour des appels de fonds budget et Travaux ALUR en cas de changement de dates d'exercice
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhProc as handle no-undo.

    define buffer perio for perio.
    define buffer intnt for intnt.
    define buffer apfet for apfet.
    define buffer apbet for apbet.

    empty temp-table ttApfet.
    empty temp-table ttApbet.

    for first perio no-lock
        where rowid(perio) = ttPeriodeChargesCopro.rRowid,
        first intnt no-lock
            where intnt.tpidt = {&TYPEBIEN-immeuble}
            and   intnt.tpcon = {&TYPECONTRAT-mandat2Syndic}
            and   intnt.nocon = ttPeriodeChargesCopro.iNumeroMandat:
        if ttPeriodeChargesCopro.daFin < perio.dtfin then do:
            for each apfet no-lock
                where apfet.noimm = intnt.noidt
                and   apfet.nofon = int64(perio.nomdt * 100000 + perio.noexo)
                and   apfet.tpapp = {&TYPEBUDGET-fondsTravauxAlur}:
                if apfet.dtapp < ttPeriodeChargesCopro.daFin then do:
                    if apfet.dttrf <> ? then do:
                        mError:createError({&error}, 1000988, string(apfet.dtapp)). //Le changement de date ne peut pas être validé: il y a un appel de fonds travaux ALUR au &1 déjà traité
                        return.
                    end.
                    else do:
                        create ttApfet.
                        buffer-copy apfet to ttApfet
                        assign
                            ttApfet.CRUD = "U"
                            ttApfet.dtTimestamp = datetime(apfet.dtmsy,apfet.hemsy)
                            .
                    end.
                end.
            end.
            for each apbet no-lock
                where apbet.nobud = int64(perio.nomdt * 100000 + perio.noexo)
                and   apbet.tpapp = {&TYPEBUDGET-budget}:
                if apbet.dtapp < ttPeriodeChargesCopro.daFin then do:
                    if apbet.dttrf <> ? then do:
                        mError:createError({&error}, 1000988, string(apbet.dtapp)). //Le changement de date ne peut pas être validé: il y a un appel de fonds travaux ALUR au &1 déjà traité
                        return.
                    end.
                    else do:
                        create ttApbet.
                        buffer-copy apbet to ttApbet
                        assign
                            ttApbet.CRUD = "U"
                            ttApbet.dtTimestamp = datetime(apbet.dtmsy,apfet.hemsy)
                            .
                    end.
                end.
            end.
        end.
    end.
    if can-find(first ttApfet) then do:
        run crud/apfet_CRUD.p persistent set vhProc.
        run getTokenInstance in vhProc(mToken:JSessionId).
        run setApfet in vhProc(table ttApfet by-reference).
        run destroy in vhproc.
    end.
    if can-find(first ttApbet) then do:
        run crud/apbet_CRUD.p persistent set vhProc.
        run getTokenInstance in vhProc(mToken:JSessionId).
        run setApbet in vhProc(table ttApbet by-reference).
        run destroy in vhproc.
    end.

end procedure.
*/