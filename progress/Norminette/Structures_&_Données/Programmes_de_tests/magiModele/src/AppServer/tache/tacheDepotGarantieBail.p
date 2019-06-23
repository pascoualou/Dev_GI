/*-----------------------------------------------------------------------------
File        : tacheDepotGarantieBail.p
Purpose     : Tache Depot de garantie bail
Author(s)   : npo - 2018/02/14
Notes       : a partir de adb/src/tach/prmobdpg.p
-----------------------------------------------------------------------------*/
{preprocesseur/categorie2bail.i}
{preprocesseur/type2tache.i}
{preprocesseur/type2contrat.i}

using parametre.pclie.parametrageDefautBail.
using parametre.pclie.parametrageDefautMandat.
using parametre.pclie.parametrageRelocation.
using parametre.syspg.syspg.
using parametre.syspg.parametrageTache.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{application/include/combo.i}
{application/include/error.i}
{application/include/glbsepar.i}
{tache/include/tacheDepotGarantieBail.i}
{adblib/include/cttac.i}
{bail/include/outilbail.i}   

function verifCompteFournisseur returns logical private():
    /*------------------------------------------------------------------------------
    Purpose: Procedure de controle des modifs de l'info 'Fournisseur'
    Notes  : 
    ------------------------------------------------------------------------------*/
    define buffer garan for garan.

    if ttTacheDepotGarantieBail.lLocaPass then do:
        // Vérifier que l'assureur a été saisi
        if ttTacheDepotGarantieBail.cNumeroFournisseur = ?
        or ttTacheDepotGarantieBail.cNumeroFournisseur = "" then do:
            mError:createError({&error}, 110071).    // Vous n'avez pas saisi le compte fournisseur associé à la garantie Loca-pass
            return false.
        end.
        // Vérifier que l'assureur existe
        if not can-find(first ifour no-lock
                        where ifour.soc-cd = integer(mToken:cRefGerance)
                          and ifour.cpt-cd = ttTacheDepotGarantieBail.cNumeroFournisseur)
        then do:
            mError:createErrorGestion({&error}, 107703, substitute("&1", ttTacheDepotGarantieBail.cNumeroFournisseur)).  // Compte Assureur %1 inexistant en comptabilité
            return false.
        end.
        // Vérifier que l'assureur n'a pas déjà une garantie associée
        for first garan no-lock
            where garan.tpctt = {&TYPECONTRAT-GarantieLoyer}
              and garan.noctt <> ttTacheDepotGarantieBail.iNumeroContrat
              and garan.lbdiv =  ttTacheDepotGarantieBail.cNumeroFournisseur:
            // Le Compte Assureur %1 est déjà associé à la garantie loyer %2
            mError:createErrorGestion({&error}, 107704, substitute("&1&2&3", ttTacheDepotGarantieBail.cNumeroFournisseur, separ[1], string(garan.noctt, ">99"))).
            return false.
        end.
    end.
    return true.
end function.

procedure getDepotGarantieBail:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (beBail.cls)
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcTypeContrat   as character no-undo.
    define output parameter table for ttTacheDepotGarantieBail.

    define buffer tache for tache.
    define buffer ifour for ifour.

    empty temp-table ttTacheDepotGarantieBail.
    if not can-find(first ctrat no-lock
                    where ctrat.tpcon = pcTypeContrat
                      and ctrat.nocon = piNumeroContrat) then do:
        mError:createError({&error}, 100057).
        return.
    end.   
    find last tache no-lock
        where tache.tpcon = pcTypeContrat
          and tache.nocon = piNumeroContrat
          and tache.tptac = {&TYPETACHE-depotGarantieBail} no-error.
    if not available tache then do:
        mError:createError({&error}, 1000471).                             //tache inexistante
        return.
    end.   
    create ttTacheDepotGarantieBail.
    assign
        ttTacheDepotGarantieBail.iNumeroTache           = tache.noita
        ttTacheDepotGarantieBail.cTypeContrat           = tache.tpcon
        ttTacheDepotGarantieBail.iNumeroContrat         = tache.nocon
        ttTacheDepotGarantieBail.cTypeTache             = tache.tptac
        ttTacheDepotGarantieBail.iChronoTache           = tache.notac
        ttTacheDepotGarantieBail.daActivation           = tache.dtdeb
        ttTacheDepotGarantieBail.cNombreMoisLoyer       = tache.tpges
        ttTacheDepotGarantieBail.cTypeDepot             = tache.ntges
        ttTacheDepotGarantieBail.cLibelleDepot          = outilTraduction:getLibelleProgZone2("R_TAG", {&TYPETACHE-depotGarantieBail}, tache.ntges)
        ttTacheDepotGarantieBail.daFin                  = tache.dtfin
        ttTacheDepotGarantieBail.lReactualisationAuto   = (tache.pdges = "00001")   // OUI/NON
        ttTacheDepotGarantieBail.cCodeModeCalcul        = tache.cdreg
        ttTacheDepotGarantieBail.cLibelleModeCalcul     = outilTraduction:getLibelleProgZone2("R_CAL", {&TYPETACHE-depotGarantieBail}, tache.cdreg)
        ttTacheDepotGarantieBail.lReactualisationBaisse = (tache.utreg = "00001")   // OUI/NON
        ttTacheDepotGarantieBail.lFacturationDG         = (tache.tphon = "00001")   // OUI/NON
        ttTacheDepotGarantieBail.lLocaPass              = (tache.ntreg = "yes")
        ttTacheDepotGarantieBail.cNumeroFournisseur     = tache.pdreg
        ttTacheDepotGarantieBail.cCodeRemboursement     = tache.dcreg
        ttTacheDepotGarantieBail.cLibelleRemboursement  = if tache.dcreg = "00019" then "Locataire" else "Fournisseur"
        ttTacheDepotGarantieBail.CRUD                   = 'R'
        ttTacheDepotGarantieBail.dtTimestamp            = datetime(tache.dtmsy, tache.hemsy)
        ttTacheDepotGarantieBail.rRowid                 = rowid(tache)
    .
    for first ifour no-lock
        where ifour.soc-cd = integer(mToken:cRefGerance)
          and ifour.cpt-cd = string(integer(tache.pdreg), "99999"):
        ttTacheDepotGarantieBail.cLibelleFournisseur = substitute("&1 (&2 &3 &4)", trim(ifour.nom), trim(ifour.adr[1]), trim(ifour.cp), trim(ifour.ville)).
    end.
    run infoAutorisationMaj.

end procedure.

procedure setTacheDepotGarantieBail:
    /*------------------------------------------------------------------------------
    Purpose: maj tache
    Notes  : service externe (beBail.cls)
    ------------------------------------------------------------------------------*/
    define input parameter table for ttTacheDepotGarantieBail.
    define input parameter table for ttError.

    define buffer ctrat for ctrat.
    define buffer tache for tache.

    for first ttTacheDepotGarantieBail
        where lookup(ttTacheDepotGarantieBail.CRUD, "C,U,D") > 0:
        find first ctrat no-lock
            where ctrat.tpcon = ttTacheDepotGarantieBail.cTypeContrat
              and ctrat.nocon = ttTacheDepotGarantieBail.iNumeroContrat no-error.
        if not available ctrat then do:
            mError:createError({&error}, 100057).
            return.
        end.
        if lookup(ttTacheDepotGarantieBail.CRUD, "U,D") > 0
        and not can-find(first tache no-lock
                         where tache.tpcon = ttTacheDepotGarantieBail.cTypeContrat
                           and tache.nocon = ttTacheDepotGarantieBail.iNumeroContrat
                           and tache.tptac = {&TYPETACHE-depotGarantieBail})
        then do:
            mError:createError({&error}, 1000413).            // Modification d'une tache inexistante
            return.
        end.
        run verZonSai(ctrat.dtini, ctrat.ntcon).
        if mError:erreur() then return.

        run majTache(ttTacheDepotGarantieBail.iNumeroContrat, ttTacheDepotGarantieBail.cTypeContrat, ttTacheDepotGarantieBail.CRUD).
    end.

end procedure.

procedure initCreationDepotGarantieBail:
    /*------------------------------------------------------------------------------
    Purpose: dans les cas de "CREATION BAIL" et "PEC"
    Notes  : service externe (beBail.cls)
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcTypeContrat   as character no-undo.
    define output parameter table for ttTacheDepotGarantieBail.

    define buffer ctrat for ctrat. 

    find first ctrat no-lock
        where ctrat.tpcon = pcTypeContrat
          and ctrat.nocon = piNumeroContrat no-error.
    if not available ctrat then do:
        mError:createError({&error}, 100057).
        return.
    end.   
    if can-find(first tache no-lock
                where tache.tpcon = pcTypeContrat
                  and tache.nocon = piNumeroContrat
                  and tache.tptac = {&TYPETACHE-depotGarantieBail})
    then do:
        mError:createError({&error}, 1000410).          // demande d'initialisation d'une tache existante
        return.
    end.     
    run infoParDefautDepotGarantie(buffer ctrat).

end procedure.

procedure InfoParDefautDepotGarantie private:
    /*------------------------------------------------------------------------------
    Purpose: creation table ttTacheDepotGarantieBail avec les informations par defaut
    Notes  : pour creation de la tache
    ------------------------------------------------------------------------------*/
    define parameter buffer ctrat for ctrat.

    define variable voDefautBail   as class parametrageDefautBail   no-undo.
    define variable voDefautMandat as class parametrageDefautMandat no-undo.
    define variable voSyspg        as class syspg                   no-undo.
    define variable voRelocation   as class parametrageRelocation   no-undo.

    define buffer tache    for tache.
    define buffer location for location.

    empty temp-table ttTacheDepotGarantieBail.
    create ttTacheDepotGarantieBail.
    assign
        ttTacheDepotGarantieBail.iNumeroTache   = 0
        ttTacheDepotGarantieBail.cTypeContrat   = ctrat.tpcon
        ttTacheDepotGarantieBail.iNumeroContrat = ctrat.nocon
        ttTacheDepotGarantieBail.cTypeTache     = {&TYPETACHE-depotGarantieBail}
        ttTacheDepotGarantieBail.iChronoTache   = 0
        ttTacheDepotGarantieBail.daActivation   = ctrat.dtini
        ttTacheDepotGarantieBail.daFin          = ctrat.dtfin
        ttTacheDepotGarantieBail.lLocaPass      = no
        ttTacheDepotGarantieBail.CRUD           = 'C'
        voDefautBail                            = new parametrageDefautBail("")
    .
    // Type de dépôt : Recuperation des parametre du DG mandat ou cabinet
    find last tache no-lock
        where tache.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and tache.nocon = int64(truncate(ctrat.nocon / 100000, 0))
          and tache.tptac = {&TYPETACHE-depotGarantieMandat} no-error.
    if available tache
    then assign
        ttTacheDepotGarantieBail.cTypeDepot    = tache.ntges
        ttTacheDepotGarantieBail.cLibelleDepot = outilTraduction:getLibelleProgZone2("R_TAG", {&TYPETACHE-depotGarantieBail}, ttTacheDepotGarantieBail.cTypeDepot)
    .
    else do:
        assign
            voDefautMandat                         = new parametrageDefautMandat()
            ttTacheDepotGarantieBail.cTypeDepot    = voDefautMandat:getTypeDepot()
            ttTacheDepotGarantieBail.cLibelleDepot = outilTraduction:getLibelleProgZone2("R_TAG", {&TYPETACHE-depotGarantieBail}, ttTacheDepotGarantieBail.cTypeDepot) when ttTacheDepotGarantieBail.cTypeDepot > ""
        .
        delete object voDefautMandat.
    end.
    // Facturation DG en PEC
    assign
        voSyspg = new syspg()
        ttTacheDepotGarantieBail.lFacturationDG = not voSyspg:isParamExist("R_CBA", {&CATEGORIE2BAIL-Commercial}, ctrat.ntcon)
                                                  or (voDefautBail:getFacturationDepotGarantiePEC() = "00001")
    .
    // Reload par nature de bail
    voDefautBail:reload(ctrat.ntcon).
    assign
        ttTacheDepotGarantieBail.cNombreMoisLoyer       = voDefautBail:getNombreMoisLoyer()
        ttTacheDepotGarantieBail.lReactualisationAuto   = (voDefautBail:getReactualisationAutomatique() = "00001")
        ttTacheDepotGarantieBail.cCodeModeCalcul        = voDefautBail:getModeCalcul()
        ttTacheDepotGarantieBail.cLibelleModeCalcul     = outilTraduction:getLibelleProgZone2("R_CAL", {&TYPETACHE-depotGarantieBail}, ttTacheDepotGarantieBail.cCodeModeCalcul)
        ttTacheDepotGarantieBail.lReactualisationBaisse = voDefautBail:getReactualisationBaisse() = "00001"
        voRelocation                                    = new parametrageRelocation()
    .
    // Ajout Sy le 18/02/2009 : AGF RELOCATIONS : initialisation avec Fiche relocation
    if voRelocation:isActif()
    then for last location no-lock        // Recherche fiche de relocation
        where location.tpcon  = {&TYPECONTRAT-mandat2Gerance}
          and location.nocon  = int64(truncate(ctrat.nocon / 100000, 0))
          and location.noapp  = integer(truncate((ctrat.nocon modulo 100000) / 100, 0))
          and location.fgarch = no:
        assign
            ttTacheDepotGarantieBail.cNombreMoisLoyer     = string(location.DG-nbmoi)
            ttTacheDepotGarantieBail.lReactualisationAuto = location.DG-fgrev
        .
    end.
    delete object voSyspg.
    delete object voDefautBail.
    delete object voRelocation.
    run infoAutorisationMaj.

end procedure.

procedure majTache private:
    /*------------------------------------------------------------------------------
    Purpose: maj tache (creation table ttTache a partir table specifique tache (ici ttTacheDepotGarantieBail)
             et appel du programme commun de maj des taches (tache/tache.p)
             si maj tache correcte appel maj table relation contrat tache (cttac).
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter pcCRUD          as character no-undo.

    define variable vhProcTache as handle  no-undo.
    define variable vhProcCttac as handle  no-undo.
    define buffer cttac for cttac.

    run tache/tache.p persistent set vhProcTache.
    run getTokenInstance in vhProcTache(mToken:JSessionId).
    run setTache in vhProcTache(table ttTacheDepotGarantieBail by-reference).
    run destroy in vhProcTache.
    if mError:erreur() then return.

    run adblib/cttac_CRUD.p persistent set vhProcCttac.
    run getTokenInstance in vhProcCttac(mToken:JSessionId).
    find first cttac no-lock
         where cttac.tpcon = pcTypeContrat
           and cttac.nocon = piNumeroContrat
           and cttac.tptac = {&TYPETACHE-depotGarantieBail} no-error.               
    if available cttac and pcCRUD = "D" then do:
        empty temp-table ttCttac.
        create ttCttac.
        assign
            ttCttac.tpcon       = pcTypeContrat
            ttCttac.nocon       = piNumeroContrat
            ttCttac.tptac       = {&TYPETACHE-depotGarantieBail}
            ttCttac.CRUD        = "D"
            ttCttac.rRowid      = rowid(cttac)
            ttCttac.dtTimestamp = datetime(cttac.dtmsy, cttac.hemsy)
        .
    end. 
    else if not available cttac and lookup(pcCRUD, "C,U") > 0 then do:
        empty temp-table ttCttac.
        create ttCttac.
        assign
            ttCttac.tpcon = pcTypeContrat
            ttCttac.nocon = piNumeroContrat
            ttCttac.tptac = {&TYPETACHE-depotGarantieBail}
            ttCttac.CRUD  = "C"
        .
    end.
    run setCttac in vhProcCttac(table ttCttac by-reference).     
    run destroy  in vhProcCttac.

end procedure.

procedure creationAutoDepotGarantieBail:
    /*------------------------------------------------------------------------------
    Purpose: creation automatique de la tache depot garantie (Relocation ALLZ) 
    Notes  : service externe (beBail.cls)
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroContrat as int64     no-undo.
    define input  parameter pcTypeContrat   as character no-undo.
    define input  parameter table for ttError.
    define output parameter table for ttTacheDepotGarantieBail.

    define buffer ctrat for ctrat.

    if can-find(first tache no-lock
                where tache.tpcon = pcTypeContrat
                  and tache.nocon = piNumeroContrat
                  and tache.tptac = {&TYPETACHE-depotGarantieBail}) then do:
        mError:createError({&error}, 1000412).  // création d'une tache déjà existante
        return.
    end.
    find first ctrat no-lock
        where ctrat.tpcon = pcTypeContrat
          and ctrat.nocon = piNumeroContrat no-error.
    if not available ctrat then do:
        mError:createError({&error}, 100057).
        return.
    end.
    run infoParDefautDepotGarantie(buffer ctrat).
    if mError:erreur() then return.

    run verZonSai(ctrat.dtini, ctrat.ntcon).
    if mError:erreur() then return.

    run majTache(piNumeroContrat, pcTypeContrat, "C").

end procedure.

procedure initComboDepotGarantieBail:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (beBail.cls)
    ------------------------------------------------------------------------------*/
    define output parameter table for ttCombo.

    run chargeCombo. 
end procedure.

procedure chargeCombo private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable voSyspg as class syspg no-undo.

    empty temp-table ttCombo.
    voSyspg = new syspg().
    voSyspg:creationComboSysPgZonXX("R_TAG", "CMBTYPEDEPOT",  "C", {&TYPETACHE-depotGarantieBail}, output table ttCombo by-reference).
    voSyspg:creationComboSysPgZonXX("R_CAL", "CMBMODECALCUL", "C", {&TYPETACHE-depotGarantieBail}, output table ttCombo by-reference).
    delete object voSyspg.
end procedure.

procedure verZonSai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : 
    ------------------------------------------------------------------------------*/
    define input  parameter pdaEffetInitial as date      no-undo.
    define input  parameter pcNatureContrat as character no-undo.

    define variable voTache as class parametrageTache no-undo.
    define variable voSyspg as class syspg            no-undo.
    define buffer tache for tache.

    // Suppression interdite
    if ttTacheDepotGarantieBail.CRUD = "D" then do:
        voTache = new parametrageTache().
        if voTache:tacheObligatoire(ttTacheDepotGarantieBail.iNumeroContrat, ttTacheDepotGarantieBail.cTypeContrat, {&TYPETACHE-depotGarantieBail}) = yes 
        then mError:createError({&error}, 100372).
        delete object voTache no-error.
        return.
    end.
    // Modification interdite qd bail résilié
    if ttTacheDepotGarantieBail.CRUD = "U"
    and ttTacheDepotGarantieBail.cTypeContrat = {&TYPECONTRAT-bail}
    and isBailResilie(ttTacheDepotGarantieBail.cTypeContrat, ttTacheDepotGarantieBail.iNumeroContrat)
    then do:
        mError:createError({&error}, 105997).        // Modification interdite
        return.
    end.
    // Verification de la date d'application
    if ttTacheDepotGarantieBail.daActivation = ? then do:
        mError:createError({&error}, 100299).
        return.
    end.
    // Verification de la date d'application (Bis)
    if ttTacheDepotGarantieBail.daActivation < pdaEffetInitial then do:
        mError:createErrorGestion({&error}, 100678, "").
        return.
    end.
    // Verification du régime de dépot
    voSyspg = new syspg().
    if voSyspg:isParamExist("R_TAG", {&TYPETACHE-depotGarantieBail}, ttTacheDepotGarantieBail.cTypeDepot) = no
    then do:
        mError:createError({&error}, 1000470).    // Type dépôt de garantie invalide
        delete object voSyspg.
        return.
    end.
    delete object voSyspg.
    // Verification du fournisseur
    if ttTacheDepotGarantieBail.lLocaPass
    and not verifCompteFournisseur() then do:
        /* TODO   je fais quoi nath ???? */
        return.
    end.
    // Verification de reactualisation par rapport au nbre de mois
    if decimal(ttTacheDepotGarantieBail.cNombreMoisLoyer) = 0 and ttTacheDepotGarantieBail.lReactualisationAuto 
    then do:
        mError:createError({&error}, 104545).        // Vous devez saisir un nombre de mois.
        return.
    end.
    // Verification de reactualisation
    if not ttTacheDepotGarantieBail.lReactualisationAuto and ttTacheDepotGarantieBail.lReactualisationBaisse
    then do:
        mError:createError({&error}, 1000562).        // Il ne peut y avoir de réactualisation à la baisse sans réactualisation automatique
        return.
    end.
    // Demande de confirmation
    if ttTacheDepotGarantieBail.lReactualisationAuto then do:
        find last tache no-lock
            where tache.tpcon = ttTacheDepotGarantieBail.cTypeContrat
              and tache.nocon = ttTacheDepotGarantieBail.iNumeroContrat
              and tache.tptac = {&TYPETACHE-depotGarantieBail} no-error.
        if available tache
        and tache.pdges <> '00001'
        and not isBailCommercial(pcNatureContrat)
        and outils:questionnaire(1000564, table ttError by-reference) <= 2 then return.  // Confirmez-vous la réactualisation automatique du DG pour ce bail ?
    end.
    // Ajout Sy le 19/05/2008 (non bloquant car en PEC le loyer contractuel n'est pas encore saisi)
    run verifModeCalcul.
    // IF NOT FgExeMth THEN APPLY "ENTRY" TO HwCmbCal.
end procedure.
 
procedure infoAutorisationMaj private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : 
    ------------------------------------------------------------------------------*/
    assign
        ttTacheDepotGarantieBail.lModifAutorise = not isBailResilie(ttTacheDepotGarantieBail.cTypeContrat, ttTacheDepotGarantieBail.iNumeroContrat)
        ttTacheDepotGarantieBail.lSupprAutorise = no
    .
end procedure.

procedure controleDepotGarantieBail:
    /*------------------------------------------------------------------------------
    Purpose: Procedure de controle des modifs des infos 'Mode de calcul' et 'Fournisseur'
    Notes  : service externe (beBail.cls)
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeDetail as character no-undo.
    define input parameter table for ttTacheDepotGarantieBail.

    for first ttTacheDepotGarantieBail
        where lookup(ttTacheDepotGarantieBail.CRUD, "C,U") > 0: 
        if pcTypeDetail = 'MODECALCUL'
        then run verifModeCalcul.
        else verifCompteFournisseur().
    end.

end procedure.

procedure verifModeCalcul private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure de controle des modifs de l'info 'Mode de calcul'
    Notes  : 
    ------------------------------------------------------------------------------*/
    if ttTacheDepotGarantieBail.cCodeModeCalcul = "00002" then do:
        // Recherche si tache loyer contractuel active
        if not can-find(first tache no-lock
                        where tache.tptac = {&TYPETACHE-loyerContractuel}
                          and tache.tpcon = ttTacheDepotGarantieBail.cTypeContrat
                          and tache.nocon = ttTacheDepotGarantieBail.iNumeroContrat)
        then do:
            mError:createError({&information}, 1000563).  // Vous devrez activer la tache Loyer Contractuel pour ce mode de calcul
            return.
        end.
    end.

end procedure.
