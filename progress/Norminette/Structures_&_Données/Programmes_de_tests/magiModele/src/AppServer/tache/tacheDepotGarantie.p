/*------------------------------------------------------------------------
File        : tacheDepotGarantie.p
Purpose     : tache depot de garantie
Author(s)   : GGA  -  2017/07/31
Notes       : a partir de adb/tach/prmobdpt.p
derniere revue: 2018/04/18 - phm: OK
------------------------------------------------------------------------*/
{preprocesseur/type2tache.i}
{preprocesseur/type2contrat.i}

using parametre.pclie.parametrageDefautMandat.
using parametre.syspg.syspg.
using parametre.syspg.parametrageTache.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{application/include/combo.i}
{application/include/glbsepar.i}
{tache/include/tacheDepotGarantie.i}
{adblib/include/cttac.i}
{adblib/include/dtfinmdt.i}    // procedure dtfinmdt

procedure getDepotGarantie:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as int64     no-undo.
    define input parameter pcTypeMandat   as character no-undo.
    define output parameter table for ttTacheDepotGarantie.

    define buffer tache for tache.

    empty temp-table ttTacheDepotGarantie.
    if not can-find(first ctrat no-lock
        where ctrat.tpcon = pcTypeMandat
          and ctrat.nocon = piNumeroMandat)
    then do:
        mError:createError({&error}, 100057).
        return.
    end.
    find last tache no-lock
        where tache.tpcon = pcTypeMandat
          and tache.nocon = piNumeroMandat
          and tache.tptac = {&TYPETACHE-depotGarantieMandat} no-error.
    if not available tache
    then do:
        mError:createError({&error}, 1000471).                             //tache inexistante
        return.
    end.
    create ttTacheDepotGarantie.
    outils:copyValidField(buffer tache:handle, buffer ttTacheDepotGarantie:handle).
    ttTacheDepotGarantie.cLibelleDepot = outilTraduction:getLibelleProgZone2("R_TAG", {&TYPETACHE-depotGarantieMandat}, tache.ntges).
    run infoAutorisationMaj(buffer ttTacheDepotGarantie).

end procedure.

procedure setDepotGarantie:
    /*------------------------------------------------------------------------------
    Purpose: maj tache
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter table for ttTacheDepotGarantie.

    define buffer vbttTacheDepotGarantie for ttTacheDepotGarantie.

    find first ttTacheDepotGarantie where lookup(ttTacheDepotGarantie.CRUD, "C,U,D") > 0 no-error.
    if not available ttTacheDepotGarantie then return.

    /* on controle qu'il n'y a qu'un seul enregistrement dans la table (cette table est transfere au pgm de maj, donc il faut s'assurer qu'un seul enregistrement) */  
    if can-find(first vbttTacheDepotGarantie
                where lookup(vbttTacheDepotGarantie.CRUD, "C,U,D") > 0
                  and rowid(vbttTacheDepotGarantie) <> rowid(ttTacheDepotGarantie))
    then do:
        mError:createError({&error}, 1000589). //Vous ne pouvez traiter en maj qu'un enregistrement à la fois
        return.
    end.
    run verZonSai.
    if not mError:erreur() then run majTache(ttTacheDepotGarantie.cTypeContrat, ttTacheDepotGarantie.iNumeroContrat).

end procedure.

procedure initDepotGarantie:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as int64     no-undo.
    define input parameter pcTypeMandat   as character no-undo.
    define output parameter table for ttTacheDepotGarantie.

    define buffer ctrat for ctrat.

    find first ctrat no-lock
        where ctrat.tpcon = pcTypeMandat
          and ctrat.nocon = piNumeroMandat no-error.
    if not available ctrat
    then mError:createError({&error}, 100057).
    else if can-find(first tache no-lock
                where tache.tpcon = pcTypeMandat
                  and tache.nocon = piNumeroMandat
                  and tache.tptac = {&TYPETACHE-depotGarantieMandat})
    then mError:createError({&error}, 1000410).          //demande d'initialisation d'une tache existante
    else run infoParDefautDepotGarantie(buffer ctrat).

end procedure.

procedure InfoParDefautDepotGarantie private:
    /*------------------------------------------------------------------------------
    Purpose: creation table ttTacheDepotGarantie avec les informations par defaut pour creation de la tache
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer ctrat for ctrat.

    define variable voDefautMandat as class parametrageDefautMandat no-undo.
    define variable vczon01  as character no-undo.
    define variable vczon02  as character no-undo.

    empty temp-table ttTacheDepotGarantie.
    create ttTacheDepotGarantie.
    assign
        ttTacheDepotGarantie.iNumeroTache   = 0
        ttTacheDepotGarantie.cTypeContrat   = ctrat.tpcon
        ttTacheDepotGarantie.iNumeroContrat = ctrat.nocon
        ttTacheDepotGarantie.cTypeTache     = {&TYPETACHE-depotGarantieMandat}
        ttTacheDepotGarantie.iChronoTache   = 0
        ttTacheDepotGarantie.daActivation   = ctrat.dtdeb
        ttTacheDepotGarantie.daFin          = ctrat.dtfin
        ttTacheDepotGarantie.CRUD           = 'C'
        voDefautMandat                      = new parametrageDefautMandat()
    .
    if voDefautMandat:isDbParameter
    then assign
        vczon01                            = entry(1, voDefautMandat:zon02, separ[3])
        vczon02                            = if num-entries(vczon01, separ[2]) >= 3 then entry(3, vczon01, separ[1]) else ""
        ttTacheDepotGarantie.cTypeDepot    = if num-entries(vczon02, separ[2]) >= 3 then entry(3, vczon02, separ[2]) else ""
        ttTacheDepotGarantie.cLibelleDepot = outilTraduction:getLibelleProgZone2("R_TAG", {&TYPETACHE-depotGarantieMandat}, ttTacheDepotGarantie.cTypeDepot)
    .
    delete object voDefautMandat.
    run infoAutorisationMaj(buffer ttTacheDepotGarantie).

end procedure.

procedure majTache private:
    /*------------------------------------------------------------------------------
    Purpose: maj tache (creation table ttTache a partir table specifique tache (ici ttTacheDepotGarantie)
             et appel du programme commun de maj des taches (tache/tache.p)
             si maj tache correcte appel maj table relation contrat tache (cttac).
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as int64     no-undo.

    define variable vhTache as handle no-undo.
    define variable vhCttac as handle no-undo.

    define buffer cttac for cttac.

    run tache/tache.p persistent set vhTache.
    run getTokenInstance in vhTache(mToken:JSessionId).
    run setTache in vhTache(table ttTacheDepotGarantie by-reference).
    run destroy in vhTache.
    if mError:erreur() then return.

    empty temp-table ttCttac.
    if can-find(first tache no-lock
                where tache.tpcon = pcTypeContrat
                  and tache.nocon = piNumeroContrat
                  and tache.tptac = {&TYPETACHE-depotGarantieMandat})
    then do:
        if not can-find(first cttac no-lock
                        where cttac.tpcon = pcTypeContrat
                          and cttac.nocon = piNumeroContrat
                          and cttac.tptac = {&TYPETACHE-depotGarantieMandat})
        then do:
            create ttCttac.
            assign
                ttCttac.tpcon = pcTypeContrat
                ttCttac.nocon = piNumeroContrat
                ttCttac.tptac = {&TYPETACHE-depotGarantieMandat}
                ttCttac.CRUD  = "C"
            .
        end.
    end.
    else for first cttac no-lock
        where cttac.tpcon = pcTypeContrat
          and cttac.nocon = piNumeroContrat
          and cttac.tptac = {&TYPETACHE-depotGarantieMandat}:
        create ttCttac.
        assign
            ttCttac.tpcon       = cttac.tpcon
            ttCttac.nocon       = cttac.nocon
            ttCttac.tptac       = cttac.tptac
            ttCttac.CRUD        = "D"
            ttCttac.rRowid      = rowid(cttac)
            ttCttac.dtTimestamp = datetime(cttac.dtmsy, cttac.hemsy)
        .
    end.
    run adblib/cttac_CRUD.p persistent set vhCttac.
    run getTokenInstance in vhCttac(mToken:JSessionId).
    run setCttac in vhCttac(table ttCttac by-reference).
    run destroy in vhCttac.

end procedure.

procedure creationAutoTache:
    /*------------------------------------------------------------------------------
    Purpose: creation automatique de la tache depot garantie
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as integer   no-undo.
    define input parameter pcTypeMandat   as character no-undo.

    define buffer ctrat for ctrat.

    find first ctrat no-lock
        where ctrat.tpcon = pcTypeMandat
          and ctrat.nocon = piNumeroMandat no-error.
    if not available ctrat then do:
        mError:createError({&error}, 100057).
        return.
    end.
    run infoParDefautDepotGarantie(buffer ctrat).
    if mError:erreur() then return.

    run verZonSai.
    if mError:erreur() then return.

    run majTache (ttTacheDepotGarantie.cTypeContrat, ttTacheDepotGarantie.iNumeroContrat).

end procedure.

procedure initComboDepotGarantie:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define output parameter table for ttCombo.
    define variable voSyspg as class syspg no-undo.

    empty temp-table ttCombo.
    voSyspg = new syspg().
    voSyspg:creationComboSysPgZonXX("R_TAG", "TYPEDEPOT", "C", {&TYPETACHE-depotGarantieMandat}, output table ttCombo by-reference).
    delete object voSyspg.

end procedure.

procedure verZonSai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable voTache as class parametrageTache no-undo.
    define variable voSyspg as class syspg            no-undo.

    define buffer ctrat for ctrat.

    find first ctrat no-lock
         where ctrat.tpcon = ttTacheDepotGarantie.cTypeContrat
           and ctrat.nocon = ttTacheDepotGarantie.iNumeroContrat no-error.
    if not available ctrat then do:
        mError:createError({&error}, 100057).
        return.
    end.
    if ttTacheDepotGarantie.CRUD = "D"
    then do:
        voTache = new parametrageTache().
        if voTache:tacheObligatoire(ttTacheDepotGarantie.iNumeroContrat, ttTacheDepotGarantie.cTypeContrat, {&TYPETACHE-depotGarantieMandat}) = yes
        then mError:createError({&error}, 100372).
        delete object voTache.
    end.
    else if ttTacheDepotGarantie.daActivation = ?
    then mError:createError({&error}, 100299).
    else if ttTacheDepotGarantie.daActivation < ctrat.dtini
    then mError:createErrorGestion({&error}, 100678, "").
    else do:
        voSyspg = new syspg().
        if voSyspg:isParamExist("R_TAG", {&TYPETACHE-depotGarantieMandat}, ttTacheDepotGarantie.cTypeDepot) = no
        then mError:createError({&error}, 1000470).                      //type dépôt de garantie invalide
        delete object voSyspg.
    end.
end procedure.

procedure infoAutorisationMaj private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer ttTacheDepotGarantie for ttTacheDepotGarantie.
    define variable vdaResiliation as date no-undo.
    define variable vdaOdfm        as date no-undo.

    run dtfinmdt(ttTacheDepotGarantie.cTypeContrat, ttTacheDepotGarantie.iNumeroContrat, output vdaResiliation, output vdaOdfm).
    if vdaOdfm <> ? or (vdaResiliation <> ? and vdaResiliation < today)
    then assign
        ttTacheDepotGarantie.lModifAutorise = no
        ttTacheDepotGarantie.lSupprAutorise = no
    .
    else assign
        ttTacheDepotGarantie.lModifAutorise = yes
        ttTacheDepotGarantie.lSupprAutorise = yes
    .
end procedure.
