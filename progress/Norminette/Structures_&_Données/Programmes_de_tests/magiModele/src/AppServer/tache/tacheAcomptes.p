/*------------------------------------------------------------------------
File        : tacheAcompte.p
Purpose     : tache Acompte propriétaires et mandat
Author(s)   : OFA - 2017/10/31
Notes       : a partir de adb/tach/synmtaco.p (propriétaires) et synmtac1.p (mandat)
derniere revue: 2018/05/28 - ofa: OK
  ----------------------------------------------------------------------*/
{preprocesseur/type2tache.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2role.i}
{preprocesseur/nature2contrat.i}

using parametre.syspr.syspr.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{application/include/glbsepar.i}
{tache/include/tacheAcomptes.i}
{application/include/combo.i}
{application/include/error.i}

procedure creationEcheancier private:
/*------------------------------------------------------------------------------
 Purpose: Création de l'échéancier des acomptes sur 1 an à partir du paramétrage des acomptes
 Notes:
------------------------------------------------------------------------------*/
    define variable vhProclaecha        as handle   no-undo.
    define variable vdaDateBoucle       as date     no-undo.
    define variable viMoisAcompte       as integer  no-undo.
    define variable viAnneeAcompte      as integer  no-undo.
    define variable viCompteurMois      as integer  no-undo.
    define variable viMoisComptaEnCours as integer  no-undo.
    define variable vdaDateEcheance     as date     no-undo.

    define buffer ctrat for ctrat.
    define buffer aecha for aecha.
    define buffer acpte for acpte.

    //On part du mois comptable de gérance en cours
    assign
        vdaDateBoucle       = mToken:daDateFinRespGerance
        vdaDateBoucle       = date(month(vdaDateBoucle), 1, year(vdaDateBoucle))
        viMoisComptaEnCours = year(vdaDateBoucle) * 100 + month(vdaDateBoucle)
    .
    //Suppression de l'échéancier existant (échéances à venir)
    if not valid-handle(vhProclaecha) then do:
        run adblib/aecha_CRUD.p persistent set vhProclaecha.
        run getTokenInstance in vhProclaecha(mToken:JSessionId).
    end.
    run deleteAechaMandatEtProprietaire in vhProclaecha(integer(mtoken:cRefGerance), ttTacheAcomptes.iNumeroContrat, string(ttTacheAcomptes.iNumeroProprietaire,"99999"), viMoisComptaEnCours).
    if valid-handle(vhProclaecha) then run destroy in vhProclaecha.

    //On parcourt la table de paramétrage des acomptes
    for first ctrat no-lock
        where ctrat.tpcon = ttTacheAcomptes.cTypeContrat
          and ctrat.nocon = ttTacheAcomptes.iNumeroContrat
      , each acpte no-lock
        where acpte.tpcon = ttTacheAcomptes.cTypeContrat
          and acpte.nocon = ttTacheAcomptes.iNumeroContrat
          and acpte.NoRol = ttTacheAcomptes.iNumeroProprietaire:
        // On parcourt les 12 mois de l'année pour créer l'échéancier sur 1 an à partir du mois comptable en cours
        do viCompteurMois = 1 to 12:
            assign
                viMoisAcompte  = month(vdaDateBoucle)
                viAnneeAcompte = year(vdaDateBoucle)
            .
            if integer(acpte.jrech[viMoisAcompte]) <> 0 then do:    // Si on a saisi un acompte pour le mois concerné
                vdaDateEcheance = date(viMoisAcompte,acpte.jrech[viMoisAcompte],viAnneeAcompte).
                if ctrat.dtree = ? or vdaDateBoucle < date(month(ctrat.dtree), 1, year(ctrat.dtree))
                then do:
                    create aecha.
                    assign
                        aecha.soc-cd      = integer(mToken:cRefGerance)
                        aecha.etab-cd     = acpte.nocon
                        aecha.cpt-cd      = string(acpte.norol, "99999")
                        aecha.mode-gest   = ""
                        aecha.num-ref     = ""
                        aecha.fg-compta   = false
                        aecha.mode-paie   = string(acpte.mdreg[viMoisAcompte] = "00001", "V/C")  //(V)irement/(C)hèque
                        aecha.pourcentage = acpte.txacp[viMoisAcompte]
                        aecha.mt          = acpte.mtacp[viMoisAcompte]
                        aecha.fg-statut   = acpte.mtacp[viMoisAcompte] <> 0
                        aecha.daech       = vdaDateEcheance
                        aecha.mois-cpt    = integer(substitute("&1&2", string(viAnneeAcompte, "9999"), string(viMoisAcompte, "99")))
                        aecha.Heure       = string(time, "hh:mm:ss")
                        aecha.date        = today
                    .
                end.
            end.
            //On passe au mois suivant
            vdaDateBoucle = add-interval(vdaDateBoucle,1,"MONTH").
        end.
    end. //for each acpte

end procedure.

procedure RecupListeEcheances private:
    /*------------------------------------------------------------------------------
     Purpose: Récupération des échéances d'acomptes à venir sur 1 année
     Notes:
    ------------------------------------------------------------------------------*/
    define output parameter pcListeMoisEcheancesLettre  as character no-undo.
    define output parameter pcListeMoisEcheancesChiffre as character no-undo.
    define output parameter pcListeNombreJoursParMois   as character no-undo.

    define variable vdaMoisEnCours  as date      no-undo.
    define variable viMoisEnCours   as integer   no-undo.
    define variable vcAnneeEnCours  as character no-undo.
    define variable viCompteurMois  as integer   no-undo.

    assign
        vdaMoisEnCours = mToken:daDateFinRespGerance
        viMoisEnCours  = month(vdaMoisEnCours)
        vcAnneeEnCours = string(year(vdaMoisEnCours))
    .
    do viCompteurMois = 1 to 13:
        if viMoisEnCours = 13
        then assign
            viMoisEnCours  = 1
            vcAnneeEnCours = string(integer(vcAnneeEnCours) + 1)
        .
        assign
            pcListeNombreJoursParMois   = substitute("&1,&2", pcListeNombreJoursParMois,
                                                              if viMoisEnCours = 12 then "31"
                                                                                    else string(day(date(viMoisEnCours + 1, 1, integer(vcAnneeEnCours)) - 1)))
            pcListeMoisEcheancesLettre  = substitute("&1,&2 &3", pcListeMoisEcheancesLettre,outilTraduction:getLibelleParam("CDMOI", string(viMoisEnCours, "99999")), vcAnneeEnCours)
            pcListeMoisEcheancesChiffre = substitute("&1,&2&3", pcListeMoisEcheancesChiffre, vcAnneeEnCours, string(viMoisEnCours, "99"))
            viMoisEnCours               = viMoisEnCours + 1
        .
    end.
    assign
        pcListeMoisEcheancesLettre  = trim(pcListeMoisEcheancesLettre, ",")
        pcListeMoisEcheancesChiffre = trim(pcListeMoisEcheancesChiffre, ",")
        pcListeNombreJoursParMois   = trim(pcListeNombreJoursParMois, ",")
    .

end procedure.

procedure setEcheancierAcomptes:
    /*------------------------------------------------------------------------------
    Purpose: Update de l'échéancier des acomptes
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter table for ttTacheAcomptes.
    define input parameter table for ttEcheancierAcomptes.
    define input parameter table for ttError.

    define buffer aecha for aecha.
    define buffer cttac for cttac.

    for each ttTacheAcomptes
        where ttTacheAcomptes.CRUD = "U":           //seulement de l'update pour cette pseudo tache

message "*******************************Tache acomptes, Mandat " ttTacheAcomptes.iNumeroContrat " - Prop " ttTacheAcomptes.iNumeroProprietaire.

        find first cttac exclusive-lock
            where rowid(cttac) = ttTacheAcomptes.rRowid no-wait no-error.
        // On teste le timestamp sur l'enregistrement cttac car il n'y a pas de tâche pour les acomptes
        if outils:isUpdated(buffer cttac:handle, 'cttac ', 'Tâche acomptes', ttTacheAcomptes.dtTimestamp)
        then return.

        //Suppression des acomptes pour les recréer
ValidAcomptes:
        for each aecha exclusive-lock
            where aecha.soc-cd  = integer(mToken:cRefGerance)
              and aecha.etab-cd = ttTacheAcomptes.iNumeroContrat
              and aecha.cpt-cd  = string(ttTacheAcomptes.iNumeroProprietaire, "99999")
              and aecha.fg-compta = false:
            delete aecha no-error.
            if error-status:error then do:
                /* La suppression de l'acompte a échoué */
                mError:createError({&error}, 102686).
                undo ValidAcomptes,leave ValidAcomptes.
            end.
        end.
        //Création des nouveaux acomptes
        for each ttEcheancierAcomptes:
            create aecha.
            assign
                aecha.soc-cd      = integer(mToken:cRefGerance)
                aecha.etab-cd     = ttEcheancierAcomptes.iNumeroContrat
                aecha.cpt-cd      = string(ttEcheancierAcomptes.iNumeroProprietaire, "99999")
                aecha.mode-gest   = substring(ttEcheancierAcomptes.cModeCreation, 1, 1, "character")
                aecha.num-ref     = ""
                aecha.fg-compta   = false
                aecha.mode-paie   = string(ttEcheancierAcomptes.lVirement, "V/C") //(V)irement/(C)hèque
                aecha.pourcentage = ttEcheancierAcomptes.dTaux
                aecha.mt          = ttEcheancierAcomptes.dMontantForfait
                aecha.fg-statut   = ttEcheancierAcomptes.lForfait
                aecha.daech       = date(ttEcheancierAcomptes.iMoisEcheance modulo 100, ttEcheancierAcomptes.iJourEcheance, integer(truncate(ttEcheancierAcomptes.iMoisEcheance / 100, 0)))
                aecha.mois-cpt    = ttEcheancierAcomptes.iMoisEcheance
                aecha.Heure       = string(time,"hh:mm:ss")
                aecha.date        = today
            .
        end.
        assign
            cttac.cdmsy = mToken:cUser
            cttac.dtmsy = today
            cttac.hemsy = mtime
        .
    end.
end procedure.

procedure setParametrageAcomptes:
    /*------------------------------------------------------------------------------
    Purpose: Update du paramétrage des acomptes
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter table for ttTacheAcomptes.
    define input parameter table for ttParametrageAcomptes.
    define input parameter table for ttError.

    define buffer cttac for cttac.
    define buffer acpte for acpte.

message "*******************************setTacheAcompte".

    for each ttTacheAcomptes
        where ttTacheAcomptes.CRUD = "U":           //seulement de l'update pour cette pseudo tache

message "*******************************Tache acomptes, Mandat " ttTacheAcomptes.iNumeroContrat " - Prop " ttTacheAcomptes.iNumeroProprietaire.

        find first cttac exclusive-lock
            where rowid(cttac) = ttTacheAcomptes.rRowid no-wait no-error.
        //On teste le timestamp sur l'enregistrement cttac car il n'y a pas de tâche pour les acomptes
        if outils:isUpdated(buffer cttac:handle, 'cttac ', 'Tâche acomptes', ttTacheAcomptes.dtTimestamp)
        then return.

        //Suppression des acomptes pour les recréer
ValidAcomptes:
        for each acpte exclusive-lock
            where acpte.tpcon = ttTacheAcomptes.cTypeContrat
              and acpte.nocon = ttTacheAcomptes.iNumeroContrat
              and acpte.NoRol = ttTacheAcomptes.iNumeroProprietaire:
            delete acpte no-error.
            if error-status:error then do:
                /* La suppression de l'acompte a échoué */
                mError:createError({&error}, 102686).
                undo ValidAcomptes,leave ValidAcomptes.
            end.
        end.
        //Création du nouveau paramétrage des acomptes
        for each ttParametrageAcomptes:

message "*******************************Parametrage acomptes, Mandat " ttParametrageAcomptes.iNumeroContrat
" - Prop " ttParametrageAcomptes.iNumeroProprietaire " - No acompte " ttParametrageAcomptes.iNumeroAcompte
" - No mois " ttParametrageAcomptes.iNumeroMois.

            if ttParametrageAcomptes.iNumeroMois = 1 then do:
                create acpte.
                assign
                    acpte.tpcon = ttParametrageAcomptes.cTypeContrat
                    acpte.nocon = ttParametrageAcomptes.iNumeroContrat
                    acpte.norol = ttParametrageAcomptes.iNumeroProprietaire
                    acpte.noacp = ttParametrageAcomptes.iNumeroAcompte
                    acpte.dtcsy = today
                    acpte.hecsy = time
                    acpte.cdcsy = mToken:cUser
                .
            end.
            assign
                acpte.jrech[ttParametrageAcomptes.iNumeroMois] = ttParametrageAcomptes.iJourAcompte
                acpte.cdcal[ttParametrageAcomptes.iNumeroMois] = string(ttParametrageAcomptes.lForfait, "00001/00002")
                acpte.mtacp[ttParametrageAcomptes.iNumeroMois] = ttParametrageAcomptes.dMontantForfait
                acpte.txacp[ttParametrageAcomptes.iNumeroMois] = ttParametrageAcomptes.dTaux
                acpte.mdreg[ttParametrageAcomptes.iNumeroMois] = string(ttParametrageAcomptes.lVirement, "00001/00002")
            .
        end.
        run creationEcheancier.
        assign
            cttac.cdmsy = mToken:cUser
            cttac.dtmsy = today
            cttac.hemsy = mtime
        .
    end.
end procedure.

procedure getEcheancierAcomptes:
    /*------------------------------------------------------------------------------
    Purpose: Récupération de l'échéancier des acomptes (AECHA)
    Notes  : service externe (beMandatGerance.cls)
    @param piNumeroMandat Numero de mandat
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat   as int64     no-undo.
    define output parameter table for ttTacheAcomptes.
    define output parameter table for ttEcheancierAcomptes.

    define variable vhTiers                     as handle    no-undo.
    define variable vcInformationsBancaires     as character no-undo.
    define variable vcListeMoisEcheancesLettre  as character no-undo.
    define variable vcListeMoisEcheancesChiffre as character no-undo.
    define variable vcListeNombreJoursParMois   as character no-undo.
    define variable viMoisResiliationMandat     as integer   no-undo.
    define variable vdaDateResiliationMandat    as date      no-undo.

    define buffer tache for tache.
    define buffer ctrat for ctrat.
    define buffer cttac for cttac.
    define buffer intnt for intnt.
    define buffer aecha for aecha.

message "********getTacheAcompte - piNumeroMandat " piNumeroMandat.

    empty temp-table ttTacheAcomptes.
    empty temp-table ttEcheancierAcomptes.
    run RecupListeEcheances(output vcListeMoisEcheancesLettre, output vcListeMoisEcheancesChiffre, output vcListeNombreJoursParMois).
    for first ctrat no-lock
        where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and ctrat.nocon = piNumeroMandat:
        assign
            viMoisResiliationMandat = 0
            vdaDateResiliationMandat = ctrat.dtree
        .
        if vdaDateResiliationMandat <> ?
        then viMoisResiliationMandat = integer(string(year(vdaDateResiliationMandat) , "9999") +  string(month(vdaDateResiliationMandat), "99")).
        run tiers/tiers.p persistent set vhTiers.
        run getTokenInstance in vhTiers(mToken:JSessionId).

        // Tâche CRG pour la périodicité
        for first tache no-lock
            where tache.tpcon = {&TYPECONTRAT-mandat2Gerance}
              and tache.nocon = piNumeroMandat
              and tache.tptac = {&TYPETACHE-compteRenduGestion}
              and tache.notac = 1
          , first cttac no-lock            // Lien contrat tâche acomptes propriétaires pour le CRUD
            where cttac.tpcon = {&TYPECONTRAT-mandat2Gerance}
              and cttac.nocon = piNumeroMandat
              and cttac.tptac = {&TYPETACHE-acomptesProprietaires}
          , each intnt no-lock             // Récupération du propriétaire ou des indivisaires
            where intnt.tpidt = (if ctrat.ntcon = {&NATURECONTRAT-mandatAvecIndivision} then {&TYPEROLE-coIndivisaire} else {&TYPEROLE-mandant})
              and intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
              and intnt.nocon = piNumeroMandat:
            //Création de la pseudo tâche Acomptes propriétaires
            create ttTacheAcomptes.
            assign
                ttTacheAcomptes.dtTimestamp         = datetime(cttac.dtmsy, cttac.hemsy)
                ttTacheAcomptes.CRUD                = "R"
                ttTacheAcomptes.rRowid              = rowid(cttac)  //Comme il n'y a pas d'enregistrement tache, on va gérer le CRUD sur la table cttac
                ttTacheAcomptes.cTypeContrat        = ctrat.tpcon
                ttTacheAcomptes.iNumeroContrat      = piNumeroMandat
                ttTacheAcomptes.iNumeroProprietaire = intnt.noidt
                ttTacheAcomptes.iNumerateur         = intnt.nbnum
                ttTacheAcomptes.iDenominateur       = intnt.nbden
                ttTacheAcomptes.cNomProprietaire    = outilFormatage:getNomTiers(intnt.tpidt,intnt.noidt)
                ttTacheAcomptes.cPeriodiciteCrg     = outilTraduction:getLibelleProgZone2("R_TPR", tache.tptac, tache.pdges)
                vcInformationsBancaires             = dynamic-function("getInformationsBancairesTiers" in vhTiers
                                                                      , intnt.tpidt, intnt.noidt, intnt.tpcon, intnt.nocon, 0)
                ttTacheAcomptes.cIban               = entry(1, vcInformationsBancaires, separ[1])
            .
            // Récupération de l'échéancier des acomptes propriétaires
boucleEcheancierProprio:
            for each aecha no-lock
                where aecha.soc-cd = integer(mToken:cRefGerance)
                  and aecha.etab-cd = ctrat.nocon
                  and aecha.cpt-cd = STRING(intnt.noidt,"99999")
                  and aecha.fg-compta = false
                  and (vdaDateResiliationMandat = ? or aecha.mois-cpt < viMoisResiliationMandat):
                if lookup(string(year(aecha.daech) * 100 + month(aecha.daech)), vcListeMoisEcheancesChiffre) = 0 then next boucleEcheancierProprio.

                create ttEcheancierAcomptes.
                assign
                    ttEcheancierAcomptes.cTypeContrat        = ctrat.tpcon
                    ttEcheancierAcomptes.iNumeroContrat      = ctrat.nocon
                    ttEcheancierAcomptes.cCodeTypeAcompte    = {&TYPETACHE-acomptesProprietaires}
                    ttEcheancierAcomptes.cLibelleTypeAcompte = outilTraduction:getLibelleProg("O_TAE", ttEcheancierAcomptes.cCodeTypeAcompte)
                    ttEcheancierAcomptes.cCodeTypeRole       = intnt.tpidt
                    ttEcheancierAcomptes.iNumeroProprietaire = intnt.noidt
                    ttEcheancierAcomptes.iMoisEcheance       = year(aecha.daech) * 100 + month(aecha.daech)
                    ttEcheancierAcomptes.iJourEcheance       = day(aecha.daech)
                    ttEcheancierAcomptes.cMoisEcheance       = entry(lookup(string(year(aecha.daech) * 100 + month(aecha.daech)), vcListeMoisEcheancesChiffre), vcListeMoisEcheancesLettre)
                    ttEcheancierAcomptes.lForfait            = (aecha.mt <> 0)
                    ttEcheancierAcomptes.lVirement           = (aecha.mode-paie = "V")
                    ttEcheancierAcomptes.cModeCreation       = (if aecha.mode-gest = "S" then outilTraduction:getLibelle(102643) else "")
                    ttEcheancierAcomptes.dMontantForfait      = (if aecha.mt <> 0 then aecha.mt else 0)
                    ttEcheancierAcomptes.dTaux               = (if aecha.mt = 0 then aecha.pourcentage else 0)
                .
            end.
        end.
        run destroy in vhTiers.
        // Lien contrat tâche acomptes propriétaires pour le CRUD
        for first cttac no-lock
            where cttac.tpcon = {&TYPECONTRAT-mandat2Gerance}
              and cttac.nocon = piNumeroMandat
              and cttac.tptac = {&TYPETACHE-acomptesMandat}:
            //Création de la pseudo tâche Acomptes mandat
            create ttTacheAcomptes.
            assign
                ttTacheAcomptes.dtTimestamp         = datetime(cttac.dtmsy, cttac.hemsy)
                ttTacheAcomptes.CRUD                = "R"
                ttTacheAcomptes.rRowid              = rowid(cttac)  // Comme il n'y a pas d'enregistrement tache, on va gérer le CRUD globalement sur la table cttac
                ttTacheAcomptes.cTypeContrat        = ctrat.tpcon
                ttTacheAcomptes.iNumeroContrat      = piNumeroMandat
                ttTacheAcomptes.iNumeroProprietaire = 0
                ttTacheAcomptes.iNumerateur         = 100
                ttTacheAcomptes.iDenominateur       = 100
                ttTacheAcomptes.cNomProprietaire    = ""
            .
        end.
        // Récupération de l'échéancier des acomptes mandat
boucleEcheancierMandat:
        for each aecha no-lock
            where aecha.soc-cd = integer(mToken:cRefGerance)
              and aecha.etab-cd = ctrat.nocon
              and aecha.cpt-cd = "00000"
              and aecha.fg-compta = false
              and (vdaDateResiliationMandat = ? or aecha.mois-cpt < viMoisResiliationMandat):
            if lookup(string(year(aecha.daech) * 100 + month(aecha.daech)), vcListeMoisEcheancesChiffre) = 0 then next boucleEcheancierMandat.

            create ttEcheancierAcomptes.
            assign
                ttEcheancierAcomptes.cTypeContrat        = ctrat.tpcon
                ttEcheancierAcomptes.iNumeroContrat      = ctrat.nocon
                ttEcheancierAcomptes.cCodeTypeAcompte    = {&TYPETACHE-acomptesMandat}
                ttEcheancierAcomptes.cLibelleTypeAcompte = outilTraduction:getLibelleProg("O_TAE", ttEcheancierAcomptes.cCodeTypeAcompte)
                ttEcheancierAcomptes.cCodeTypeRole       = (if ctrat.ntcon = {&NATURECONTRAT-mandatAvecIndivision} then {&TYPEROLE-coIndivisaire} else {&TYPEROLE-mandant})
                ttEcheancierAcomptes.iNumeroProprietaire = 0
                ttEcheancierAcomptes.iMoisEcheance       = year(aecha.daech) * 100 + month(aecha.daech)
                ttEcheancierAcomptes.iJourEcheance       = day(aecha.daech)
                ttEcheancierAcomptes.cMoisEcheance       = entry(lookup(string(ttEcheancierAcomptes.iMoisEcheance), vcListeMoisEcheancesChiffre), vcListeMoisEcheancesLettre)
                ttEcheancierAcomptes.lForfait            = (aecha.mt <> 0)
                ttEcheancierAcomptes.lVirement           = (aecha.mode-paie = "V")
                ttEcheancierAcomptes.cModeCreation       = (if aecha.mode-gest = "S" then outilTraduction:getLibelle(102643) else "")
                ttEcheancierAcomptes.dMontantForfait     = (if aecha.mt <> 0 then aecha.mt else 0)
                ttEcheancierAcomptes.dTaux               = (if aecha.mt = 0 then aecha.pourcentage else 0)
            .
        end.
    end.
end procedure.

procedure getParametrageAcomptes:
    /*------------------------------------------------------------------------------
    Purpose: Read de la pseudo tâche Acomptes
    Notes  : service externe (beMandatGerance.cls)
    @param piNumeroMandat Numero de mandat
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as int64   no-undo.
    define output parameter table for ttTacheAcomptes.
    define output parameter table for ttParametrageAcomptes.

    define variable vhTiers                     as handle    no-undo.
    define variable vcInformationsBancaires     as character no-undo.
    define variable vcListeMoisEcheancesLettre  as character no-undo.
    define variable vcListeMoisEcheancesChiffre as character no-undo.
    define variable vcListeNombreJoursParMois   as character no-undo.
    define variable viCompteur                  as integer   no-undo.

    define buffer tache for tache.
    define buffer ctrat for ctrat.
    define buffer intnt for intnt.
    define buffer acpte for acpte.
    define buffer cttac for cttac.

message "********getTacheAcompte - piNumeroMandat " piNumeroMandat.

    empty temp-table ttTacheAcomptes.
    empty temp-table ttEcheancierAcomptes.
    empty temp-table ttParametrageAcomptes.
    run RecupListeEcheances(output vcListeMoisEcheancesLettre, output vcListeMoisEcheancesChiffre, output vcListeNombreJoursParMois).
    for first ctrat no-lock
        where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and ctrat.nocon = piNumeroMandat:
        run tiers/tiers.p persistent set vhTiers.
        run getTokenInstance in vhTiers(mToken:JSessionId).

        // Tâche CRG pour la périodicité
        for first tache no-lock
            where tache.tpcon = {&TYPECONTRAT-mandat2Gerance}
              and tache.nocon = piNumeroMandat
              and tache.tptac = {&TYPETACHE-compteRenduGestion}
              and tache.notac = 1
          , first cttac no-lock            // Lien contrat tâche acomptes propriétaires pour le CRUD
            where cttac.tpcon = {&TYPECONTRAT-mandat2Gerance}
              and cttac.nocon = piNumeroMandat
              and cttac.tptac = {&TYPETACHE-acomptesProprietaires}
          , each  intnt no-lock            // Récupération du propriétaire ou des indivisaires
            where intnt.tpidt = (if ctrat.ntcon = {&NATURECONTRAT-mandatAvecIndivision} then {&TYPEROLE-coIndivisaire} else {&TYPEROLE-mandant})
              and intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
              and intnt.nocon = piNumeroMandat:
            //Création de la pseudo tâche Acomptes propriétaires
            create ttTacheAcomptes.
            assign
                ttTacheAcomptes.dtTimestamp         = datetime(cttac.dtmsy, cttac.hemsy)
                ttTacheAcomptes.CRUD                = "R"
                ttTacheAcomptes.rRowid              = rowid(cttac)  //Comme il n'y a pas d'enregistrement tache, on va gérer le CRUD sur la table cttac
                ttTacheAcomptes.cTypeContrat        = {&TYPECONTRAT-mandat2Gerance}
                ttTacheAcomptes.iNumeroContrat      = piNumeroMandat
                ttTacheAcomptes.iNumeroProprietaire = intnt.noidt
                ttTacheAcomptes.iNumerateur         = intnt.nbnum
                ttTacheAcomptes.iDenominateur       = intnt.nbden
                ttTacheAcomptes.cNomProprietaire    = outilFormatage:getNomTiers(intnt.tpidt, intnt.noidt)
                ttTacheAcomptes.cPeriodiciteCrg     = outilTraduction:getLibelleProgZone2("R_TPR", tache.tptac, tache.pdges)
                vcInformationsBancaires             = dynamic-function("getInformationsBancairesTiers" in vhTiers
                                                                     , intnt.tpidt, intnt.noidt, intnt.tpcon, intnt.nocon, 0)
                ttTacheAcomptes.cIban               = entry(1, vcInformationsBancaires, separ[1])
            .
            // Paramétrage des acomptes du propriétaire/indivisaire
            for each acpte no-lock
                where acpte.tpcon = ctrat.tpcon
                  and acpte.nocon = ctrat.nocon
                  and acpte.norol = intnt.noidt:
                do viCompteur = 1 to 12:
                    create ttParametrageAcomptes.
                    assign
                        ttParametrageAcomptes.cTypeContrat        = acpte.tpcon
                        ttParametrageAcomptes.iNumeroContrat      = acpte.nocon
                        ttParametrageAcomptes.cCodeTypeAcompte    = {&TYPETACHE-acomptesMandat}
                        ttParametrageAcomptes.cLibelleTypeAcompte = outilTraduction:getLibelleProg("O_TAE", ttParametrageAcomptes.cCodeTypeAcompte)
                        ttParametrageAcomptes.iNumeroProprietaire = acpte.norol
                        ttParametrageAcomptes.iNumeroAcompte      = acpte.noacp
                        ttParametrageAcomptes.iNumeroMois         = viCompteur
                        ttParametrageAcomptes.cLibelleMois        = entry(viCompteur, outilTraduction:getLibelleCompta(103431))
                        ttParametrageAcomptes.iJourAcompte        = acpte.jrech[viCompteur]
                        ttParametrageAcomptes.dMontantForfait     = acpte.mtacp[viCompteur]
                        ttParametrageAcomptes.dTaux               = acpte.txacp[viCompteur]
                        ttParametrageAcomptes.lForfait            = (acpte.cdcal[viCompteur] = "00001")
                        ttParametrageAcomptes.lVirement           = (acpte.mdreg[viCompteur] = "00001")
                    .
                end.
            end.
        end.
        run destroy in vhTiers.
        // Lien contrat tâche acomptes propriétaires pour le CRUD
        for first cttac no-lock
            where cttac.tpcon = {&TYPECONTRAT-mandat2Gerance}
              and cttac.nocon = piNumeroMandat
              and cttac.tptac = {&TYPETACHE-acomptesMandat}:
            // Création de la pseudo tâche Acomptes mandat
            create ttTacheAcomptes.
            assign
                ttTacheAcomptes.dtTimestamp         = datetime(cttac.dtmsy, cttac.hemsy)
                ttTacheAcomptes.CRUD                = "R"
                ttTacheAcomptes.rRowid              = rowid(cttac)  //Comme il n'y a pas d'enregistrement tache, on va gérer le CRUD globalement sur la table cttac
                ttTacheAcomptes.cTypeContrat        = ctrat.tpcon
                ttTacheAcomptes.iNumeroContrat      = piNumeroMandat
                ttTacheAcomptes.iNumeroProprietaire = 0
                ttTacheAcomptes.iNumerateur         = 100
                ttTacheAcomptes.iDenominateur       = 100
                ttTacheAcomptes.cNomProprietaire    = ""
            .
        end.
        //Paramétrage des acomptes du mandat
        for each acpte no-lock
            where acpte.tpcon = ctrat.tpcon
              and acpte.nocon = ctrat.nocon
              and acpte.norol = 0:
            do viCompteur = 1 to 12:
                create ttParametrageAcomptes.
                assign
                    ttParametrageAcomptes.cTypeContrat        = acpte.tpcon
                    ttParametrageAcomptes.iNumeroContrat      = acpte.nocon
                    ttParametrageAcomptes.cCodeTypeAcompte    = {&TYPETACHE-acomptesMandat}
                    ttParametrageAcomptes.cLibelleTypeAcompte = outilTraduction:getLibelleProg("O_TAE", ttParametrageAcomptes.cCodeTypeAcompte)
                    ttParametrageAcomptes.iNumeroProprietaire = acpte.norol
                    ttParametrageAcomptes.iNumeroAcompte      = acpte.noacp
                    ttParametrageAcomptes.iNumeroMois         = viCompteur
                    ttParametrageAcomptes.cLibelleMois        = entry(viCompteur, outilTraduction:getLibelleCompta(103431))
                    ttParametrageAcomptes.iJourAcompte        = acpte.jrech[viCompteur]
                    ttParametrageAcomptes.dMontantForfait     = acpte.mtacp[viCompteur]
                    ttParametrageAcomptes.dTaux               = acpte.txacp[viCompteur]
                    ttParametrageAcomptes.lForfait            = (acpte.cdcal[viCompteur] = "00001")
                    ttParametrageAcomptes.lVirement           = (acpte.mdreg[viCompteur] = "00001")
                .
            end.
        end.
    end.
end procedure.

procedure initComboTacheAcomptes:
    /*------------------------------------------------------------------------------
    Purpose: Chargement des combos de l'écran depuis la vue
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define output parameter table for ttcombo.

    run chargeCombo.
end procedure.

procedure chargeCombo private:
    /*------------------------------------------------------------------------------
    Purpose: Chargement de toutes les combos de l'écran: Type d'acompte (propriétaire ou mandat)
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer sys_pg for sys_pg.
    for first sys_pg no-lock
        where sys_pg.tppar = "O_TAE"
          and sys_pg.cdpar = {&TYPETACHE-acomptesProprietaires}:
        create ttCombo.
        assign
            ttcombo.iSeqId    = 1
            ttCombo.cNomCombo = "TYPEACOMPTE"
            ttCombo.cCode     = sys_pg.cdpar
            ttCombo.cLibelle  = outilTraduction:getLibelle(sys_pg.nome1)
        .
    end.
    for first sys_pg no-lock
        where sys_pg.tppar = "O_TAE"
          and sys_pg.cdpar = {&TYPETACHE-acomptesMandat}:
        create ttCombo.
        assign
            ttcombo.iSeqId    = 2
            ttCombo.cNomCombo = "TYPEACOMPTE"
            ttCombo.cCode     = sys_pg.cdpar
            ttCombo.cLibelle  = outilTraduction:getLibelle(sys_pg.nome1)
        .
    end.
end procedure.
