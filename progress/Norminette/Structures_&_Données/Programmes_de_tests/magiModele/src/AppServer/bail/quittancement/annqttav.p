/*-----------------------------------------------------------------------------
File        : annqttav.p
Purpose     : Annulation des quittances �mises � l'avance et non comptabilis�es (suite � r�siliation du bail)
Author(s)   : DMI -  2018/12/18
Notes       : reprise de adb/src/quit/annqttav.p
derniere revue: 2018/12/21 - SPo: OK
-----------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/type2tache.i}
{preprocesseur/type2role.i}
{preprocesseur/mode2reglement.i}
{preprocesseur/profil2rubQuit.i}
{preprocesseur/factureTiers.i}
{preprocesseur/devise.i}
{preprocesseur/codeTraitementTransfert.i}

using parametre.syspr.syspr.

{oerealm/include/instanciateTokenOnModel.i} // Doit �tre positionn�e juste apr�s using //
{application/include/error.i}
{bail/include/tbtmpqtt.i}
{bail/include/tbtmprub.i}
{adb/include/fcttvaru.i}                    // fonctions f_isRubSoumiseTVABail, f_donnerubtva, donneTauxTvaArticleDate, f_donnetauxtvarubqt
{adb/include/cdanarub.i}                    // description cdanaN
{crud/include/iftsai.i}
{crud/include/iftln.i}
{crud/include/aquit.i}

define variable giNumeroContrat as int64 no-undo.

procedure lancementAnnqttav:
    /*------------------------------------------------------------------------
    Purpose :
    Notes   : service externe
    ------------------------------------------------------------------------*/
    define input  parameter piNumeroContrat as int64   no-undo.
    define output parameter plAbandon       as logical no-undo.
    define input  parameter table for ttError.
    define output parameter table for ttQtt.

    assign
        giNumeroContrat       = piNumeroContrat
    .
    run trtAnnQttav(output plAbandon).
end procedure.

procedure trtAnnqttav private:
    /*------------------------------------------------------------------------
    Purpose : Annulation des quittances �mises � l'avance et non comptabilis�es
    Notes   :
    ------------------------------------------------------------------------*/
    define output parameter plAbandon as logical no-undo.

    run getListeQuittance.
boucle :
    for first ttQtt :
        plAbandon = outils:questionnaire(1000952, ttqtt.cLibelleMoisAnnee, table ttError by-reference) <= 2. // 1000952 0 "Il reste des quittances �mises � l'avance et non comptabilis�es (&1). Vous devez les annuler avant de faire une facture de sortie. Confimez l'annulation ?"
        if plAbandon then leave boucle.
        run creationAnnulationQuittance.
    end.
end procedure.

procedure getListeQuittance private:
    /*------------------------------------------------------------------------
    Purpose : Liste des quittances �mises � l'avance et non comptabilis�es
    Notes   : reprise de la proc�dure ChgTabTmp
    ------------------------------------------------------------------------*/
    define variable viMoisQtt    as integer no-undo.
    define variable vhHistorique as handle  no-undo.

    define buffer suivtrf for suivtrf.

    empty temp-table ttQtt.
    empty temp-table ttRub.

    run bail/quittancement/quittanceHistorique.p persistent set vhHistorique.
    run getTokenInstance in vhHistorique(mToken:JSessionId).
    for each suivtrf no-lock
        where suivtrf.soc-cd = integer(mtoken:cRefGerance) // Dernier quitt. comptabilis�
          and lookup suivtrf.cdtrait = {&CDTRAIT-QuittancementReception}
           by suivtrf.nochrodis:
        viMoisQtt = suivtrf.moiscpt.
    end.
    if viMoisQtt ne 0 then viMoisQtt = integer(substitute("&1&2", substring(string(viMoisQtt,"999999"),3,4), substring(string(viMoisQtt,"999999"),1,2))).
    run getListeQuittanceAvanceNonCompta in vhHistorique(giNumeroContrat, viMoisQtt, output table ttQtt by-reference, output table ttRub by-reference).
    run destroy in vhHistorique.
end procedure.

procedure creationAnnulationQuittance:
    /*------------------------------------------------------------------------
    Purpose : cr�ation des annulations de quittances
    Notes   : reprise de la proc�dure SavEcrSai
    ------------------------------------------------------------------------*/
    define variable viLig      as integer     no-undo.
    define variable viNumInt   as integer     no-undo.
    define variable vdMtTVA    as decimal     no-undo.
    define variable vcMois     as character   no-undo.
    define variable vcLstMois  as character   no-undo.
    define variable vdTxTvaUse as decimal     no-undo.
    define variable vhaquit    as handle      no-undo.
    define variable vhaparm    as handle      no-undo.
    define variable vhiftsai   as handle      no-undo.
    define variable vhiftln    as handle      no-undo.
    define variable voSyspr    as class syspr no-undo.

    define buffer tache for tache.
    define buffer itaxe for itaxe.
    define buffer rubqt for rubqt.
    define buffer aquit for aquit.

    empty temp-table ttiftsai.
    empty temp-table ttIftln.

    run crud/aparm_CRUD.p persistent set vhaparm.
    run getTokenInstance in vhaparm(mToken:JSessionId).
    run crud/iftsai_CRUD.p persistent set vhiftsai.
    run getTokenInstance in vhiftsai(mToken:JSessionId).
    run crud/iftln_CRUD.p persistent set vhiftln.
    run getTokenInstance in vhiftln(mToken:JSessionId).
    run crud/aquit_CRUD.p persistent set vhaquit.
    run getTokenInstance in vhaquit(mToken:JSessionId).

    for first tache no-lock
        where tache.tpcon = {&TYPECONTRAT-bail}
          and tache.tptac = {&TYPETACHE-TVABail}
          and tache.nocon = giNumeroContrat:
        voSyspr = new syspr("CDTVA", tache.ntges).
        assign
            vdTxTvaUse = (if voSyspr:isDbParameter then voSyspr:zone1 else 0) // Taux de TVA
        .
        find first itaxe no-lock
            where itaxe.soc-cd = integer(mToken:cRefGerance)
              and itaxe.taux   = vdTxTvaUse
              no-error.
        for each ttQtt where ttQtt.dMontantQuittance ne 0:
            run setNextChronoFact in vhaparm(output viNumInt). // cr�e et renvoie le prochain num�ro interne de facture
            // Entete facture
            create ttiftsai.
            assign
                ttiftsai.soc-cd       = integer(mToken:cRefGerance)
                ttiftsai.etab-cd      = truncate(giNumeroContrat / 100000, 0)
                ttiftsai.sscptg-cd    = string(giNumeroContrat modulo 100000, "99999")
                ttiftsai.tprole       = integer({&TYPEROLE-locataire})
                ttiftsai.type-cle     = {&TYPECLEFACTURETIERS-avoir}
                ttiftsai.typefac-cle  = {&TYPEFACFACTURETIERS-divers}
                ttiftsai.cours        = 1
                ttiftsai.daech        = ttQtt.daDebutQuittancement
                ttiftsai.dafac        = ttQtt.daDebutQuittancement
                ttiftsai.dev-cd       = {&DEVISE-euro}
                ttiftsai.fac-num      = 0
                ttiftsai.fg-edifac    = false
                ttiftsai.gestva-cd    = 0
                ttiftsai.lib          = ""
                ttiftsai.mt           = ttQtt.dMontantQuittance
                ttiftsai.mttva        = 0
                ttiftsai.num-int      = viNumInt
                ttiftsai.regl-cd      = {&MODEREGLEMENTCOMPTA-ChequeComptant}
                ttiftsai.tauxtvaqt    = 0
                ttiftsai.crud         = "C"
                viLig                 = 0
                vcMois                = substitute("&1/&2", string(month(ttiftsai.dafac),"99"), string(year(ttiftsai.dafac))) // respecter l'ordre de l'assign
                vcLstMois             = substitute("&1,&2", vcLstMois, vcMois) when lookup(vcMois, vcLstMois) = 0             // respecter l'ordre de l'assign
            .
            for each ttRub // Lignes facture
                where ttRub.iNumeroLocataire = ttQtt.iNumeroLocataire
                  and ttRub.iNoQuittance     = ttQtt.iNoQuittance :
                find last rubqt no-lock // Recherche de la rubrique Avoir associ�e
                    where rubqt.asrub = ttRub.iNoRubrique
                      and rubqt.aslib = ttRub.iNoLibelleRubrique
                      and rubqt.cdgen < {&GenreRubqt-Resultat}
                      no-error.
                if not available rubqt // S'il n'y en a pas, on garde la m�me rubrique pour l'avoir
                then find rubqt no-lock
                        where rubqt.cdrub = ttRub.iNoRubrique
                          and rubqt.cdlib = ttRub.iNoLibelleRubrique
                          no-error.
                if available rubqt then do :
                    // Calcul de la TVA en fonction du param�trage du bail
                    vdMtTVA = (if f_isRubSoumiseTVABail(input tache.pdges, input rubqt.cdfam, input rubqt.cdsfa, input rubqt.cdrub, integer(rubqt.prg05))
                                then round(ttRub.dMontantTotal * vdTxTvaUse / 100,2)
                                else 0).
                    if rubqt.cdfam ne {&FamilleRubqt-Taxe} then do:
                        create ttiftln.
                        buffer-copy ttiftsai to ttiftln
                            assign
                                viLig              = viLig + 10
                                ttiftln.brwcoll1   = string(rubqt.cdrub)
                                ttiftln.brwcoll2   = string(rubqt.cdlib)
                                ttiftln.fg-auto    = no
                                ttiftln.fg-chgloc  = no
                                ttiftln.fg-FL      = no
                                ttiftln.fg-prorata = no
                                ttiftln.fg-val     = no
                                ttiftln.rub-cd     = ""
                                ttiftln.ssrub-cd   = ""
                                ttiftln.fisc-cle   = ""
                                ttiftln.cleadb     = ""
                                ttiftln.lib-ecr[1] = outilTraduction:getLibelle(rubqt.nome1)
                                ttiftln.lig        = viLig
                                ttiftln.lig-tot    = 10
                                ttiftln.mtcre      = dMontantTotal + vdMtTVA // Montant TTC
                                ttiftln.mtdeb      = 0
                                ttiftln.mtdevcre   = ttiftln.mtcre
                                ttiftln.mtdevdeb   = ttiftln.mtdeb
                                ttiftln.mttva      = - vdMtTVA
                                ttiftln.mtdevtva   = ttiftln.mttva
                                ttiftln.sens       = no
                                ttiftln.sscoll-cle = ""
                                ttiftln.sscpt-cd   = ""
                                ttiftln.tot-det    = no
                                ttiftln.tva-cd     = (if available itaxe and vdMtTVA ne 0 then itaxe.taxe-cd else 0)
                                ttiftln.typecr-cd  = "1"
                                ttiftln.rub-cd     = cdana1[ integer(rubqt.prg05) ]
                                ttiftln.ssrub-cd   = cdana2[ integer(rubqt.prg05) ]
                                ttiftln.fisc-cle   = cdana3[ integer(rubqt.prg05) ]
                                ttiftln.CRUD       = "C"
                                .
                    end.
                end.
            end.
            for first aquit no-lock // Mise � jour de la quittance d'avance annul�e
                where aquit.noloc = ttQtt.iNumeroLocataire
                  and aquit.noqtt = ttQtt.iNoQuittance:
                create ttAquit.
                assign
                    ttaquit.type-fac    = "QTTANNUL"
                    ttaquit.num-int-fac = viNumInt
                    ttAquit.CRUD        = "U"
                    ttAquit.rRowid      = rowid(aquit)
                    ttAquit.dtTimestamp = datetime(aquit.dtmsy, aquit.hemsy)
                .
            end.
        end.
        vcLstMois = trim(vcLstMois,",").
        if vcLstMois ne "" then do:
            if num-entries(vcLstMois) = 1
            then mError:createError({&information}, 1000967, vcLstMois). // 1000967 "Le quittancement d'avance a �t� annul� par un avoir sur le mois de &1. Vous devrez comptabiliser cet avoir lorsque le quittancement correspondant sera lui-m�me comptabilis�."
            else mError:createError({&information}, 1000968, vcLstMois). // 1000968 "Les quittancements d'avance ont �t� annul�s par des avoirs sur les mois de &1. Vous devrez comptabiliser ces avoirs lorsque le quittancement correspondant sera lui-m�me comptabilis�.
        end.
    end.

    run setIftsai in vhiftsai(table ttiftsai by-reference).
    run setIftln  in vhiftln (table ttiftln  by-reference).
    run setAquit  in vhaquit (table ttaquit  by-reference).

    delete object voSyspr.
    run destroy in vhaparm.
    run destroy in vhaquit.
    run destroy in vhiftsai.
    run destroy in vhiftln.

end procedure.