/*------------------------------------------------------------------------
File        : tacheIRF.p
Purpose     : tache Impot sur les Revenus Fonciers
Author(s)   : DM 20180124
Notes       : a partir de adb/tach/prmobirf.p et synmtirf.p
------------------------------------------------------------------------*/
{preprocesseur/type2tache.i}
{preprocesseur/type2honoraire.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2role.i}
{preprocesseur/nature2contrat.i}

using parametre.syspg.syspg.
using parametre.syspr.syspr.
using parametre.syspg.parametrageTache.
using parametre.pclie.parametrageDefautMandat.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{parametre/cabinet/gerance/include/paramIrf.i}
{application/include/combo.i}
{tache/include/tacheIRF.i}
{tache/include/tache.i}
{adblib/include/cttac.i}

procedure majTache private:
    /*------------------------------------------------------------------------------
    Purpose: maj tache et cttac
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer ttTacheIRF for ttTacheIRF.
    define parameter buffer ctrat      for ctrat.

    define variable vhProcTache        as handle            no-undo.
    define variable vhProcCttac        as handle            no-undo.
    define variable vhProcAlimaj       as handle            no-undo.
    define variable vlRetour           as logical           no-undo.
    define variable vlMicroFoncier     as logical initial ? no-undo.
    define variable vlDeclaraction2072 as logical initial ? no-undo.
    define variable vcListeMandat      as character         no-undo.

    define buffer cttac for cttac.

    run tache/tache.p persistent set vhProcTache.
    run getTokenInstance in vhProcTache(mToken:JSessionId).
    run adblib/cttac_CRUD.p persistent set vhProcCttac.
    run getTokenInstance in vhProcCttac(mToken:JSessionId).
    run application/transfert/gi_alimaj.p persistent set vhProcAlimaj.
    run getTokenInstance in vhProcAlimaj(mToken:JSessionId).

    empty temp-table ttTache.
    empty temp-table ttCttac.

bloc:
    do:
        run getTache in vhProcTache(ttTacheIRF.cTypeContrat, ttTacheIRF.iNumeroContrat, ttTacheIRF.cTypeTache, table ttTache by-reference).
        if ttTacheIRF.crud = "U" then do : // Recuperation du code micro foncier et 2072 avant modif
            run readtache in vhProcTache (ttTacheIRF.cTypeContrat
                                        , ttTacheIRF.iNumeroContrat
                                        , ttTacheIRF.cTypeTache
                                        , ttTacheIRF.iChronoTache
                                        , table ttTache by-reference).
            for first ttTache:
                assign
                    vlMicroFoncier     = (ttTache.pdreg = {&oui})
                    vlDeclaraction2072 = (ttTache.dcreg = {&oui})
                .
            end.
            empty temp-table ttTache.
        end.
        create ttTache.
        assign
            ttTache.noita       = ttTacheIRF.iNumeroTache
            ttTache.tpcon       = ttTacheIRF.cTypeContrat
            ttTache.nocon       = ttTacheIRF.iNumeroContrat
            ttTache.tptac       = ttTacheIRF.cTypeTache
            ttTache.notac       = ttTacheIRF.iChronoTache
            tttache.dtdeb       = ttTacheIRF.daActivation
            tttache.dtfin       = ctrat.dtfin
            tttache.tpges       = ttTacheIRF.cTypeDeclaration
            ttTache.pdges       = "21001" // Reprise impayé = Oui
            ttTache.cdreg       = ""
            ttTache.ntreg       = ""
            ttTache.pdreg       = string(ttTacheIRF.lMicroFoncier,{&ouiNon})
            ttTache.dcreg       = string(ttTacheIRF.lDeclaration2072,{&ouiNon})
            ttTache.tphon       = {&TYPEHONORAIRE-IRF}
            ttTache.cdhon       = string(ttTacheIRF.iCodeHonoraire,"99999")
            ttTache.CRUD        = ttTacheIRF.CRUD
            ttTache.dtTimestamp = ttTacheIRF.dtTimestamp
            ttTache.rRowid      = ttTacheIRF.rRowid
        .
        if mError:erreur() then leave bloc.
        find first cttac no-lock
             where cttac.tpcon = ttTacheIRF.cTypeContrat
               and cttac.nocon = ttTacheIRF.iNumeroContrat
               and cttac.tptac = ttTacheIRF.cTypeTache no-error.
        if available cttac and ttTacheIRF.CRUD = "D"
        then do:
            create ttCttac.
            outils:copyValidLabeledField(buffer cttac:handle, buffer ttCttac:handle).
            ttCttac.CRUD  = "D".
        end.
        else if not available cttac and lookup(ttTacheIRF.CRUD, "C,U") > 0
        then do:
            create ttCttac.
            assign
                ttCttac.tpcon = ttTacheIRF.cTypeContrat
                ttCttac.nocon = ttTacheIRF.iNumeroContrat
                ttCttac.tptac = ttTacheIRF.cTypeTache
                ttCttac.CRUD  = "C"
            .
        end.
        if ttTacheIRF.crud  = "U"
           and (vlMicroFoncier <> ttTacheIRF.lMicroFoncier or vlDeclaraction2072 <> ttTacheIRF.lDeclaration2072)
        then do : // Le microfoncier ou la declaration 2072 ont changés.
            run majMicroFoncier(output vcListeMandat).             // Mise a jour des mandats du mandants sur l'option micro foncier ou declaration 2072
            if mError:erreur() then leave bloc.
            run majTrace in vhProcAlimaj(integer(mToken:cRefGerance), 'SADB', 'ctrat', string(ctrat.nodoc, '>>>>>>>>9')).    // NoRefGer remplacé par
        end.
    end.
    run setTache in vhProcTache(table ttTache by-reference).
    run setCttac in vhProcCttac(table ttCttac by-reference).
    if not mError:erreur() and vcListeMandat <> ""
    then mError:createErrorGestion({&info}, 106458, vcListeMandat). // Nous venons de mettre à jour les options MICRO-FONCIER et DECLARATION 2072 sur l'ensemble des mandats du mandant : %1.
    run destroy in vhProcTache.
    run destroy in vhProcCttac.
    run destroy in vhProcAlimaj.
end procedure.

procedure majMicroFoncier private:
    /*------------------------------------------------------------------------------
    Purpose: Mise a jour des mandats du mandants sur l'option micro foncier ou declaration 2072
    Notes  : de MajMiFon
    ------------------------------------------------------------------------------*/
    define output parameter pcListeMandat as character no-undo.

    define variable viNumeroMandant as int64 no-undo.
    define buffer intnt for intnt.
    define buffer tache for tache.
    define buffer etxdt for etxdt.
    define buffer ctrat for ctrat.

bloc:
    do :
        if integer(mToken:cRefPrincipale) = 10
        then for first ctrat no-lock
                where ctrat.tpcon = ttTacheIRF.cTypeContrat
                  and ctrat.nocon = ttTacheIRF.iNumeroContrat :
                viNumeroMandant = ctrat.norol.
        end.
        else for first intnt no-lock
                where intnt.tpidt = {&TYPEROLE-mandant}
                  and intnt.tpcon = ttTacheIRF.cTypeContrat
                  and intnt.nocon = ttTacheIRF.iNumeroContrat :
                viNumeroMandant = intnt.noidt.
        end.
        if ttTacheIRF.lMicroFoncier // On verifie que aucun mandat du mandant n'a de lot besson s'il souhaite passer en Microfoncier
        then for each intnt no-lock
                where intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
                  and intnt.tpidt = {&TYPEROLE-mandant}
                  and intnt.noidt = viNumeroMandant
              , first etxdt no-lock where etxdt.notrx = intnt.nocon :
                mError:createError({&error}, 109083). // Le mandant a au moins un mandat avec des lots soumis à une loi Besson/Périssol. Vous ne pouvez pas passer en mode Micro Foncier.
                leave bloc.
        end.
        for each intnt no-lock
            where intnt.tpcon = {&TYPECONTRAT-mandat2Gerance} // Modification des taches du mandant
              and intnt.nocon <> ttTacheIRF.iNumeroContrat
              and intnt.tpidt = {&TYPEROLE-mandant}
              and intnt.noidt = viNumeroMandant
          , last tache no-lock
            where tache.tpcon = intnt.tpcon
              and tache.nocon = intnt.nocon
              and tache.tptac = {&TYPETACHE-ImpotRevenusFonciers} :
            create ttTache.
            outils:copyValidLabeledField(buffer tache:handle, buffer ttTache:handle).
            assign
                ttTache.CRUD  = "U"
                ttTache.pdreg = string(ttTacheIRF.lMicroFoncier,{&ouiNon})
                ttTache.dcreg = string(ttTacheIRF.lDeclaration2072,{&ouiNon})
            .
            pcListeMandat = pcListeMandat + (if pcListeMandat = "" then "" else ", ") + string(tache.nocon).
        end.
    end.
end procedure.

procedure verZonSai private:
    /*------------------------------------------------------------------------------
    Purpose: Vérification des zones saisies
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer ctrat      for ctrat.
    define parameter buffer ttTacheIRF for ttTacheIRF.

    define variable voSyspg as class syspg            no-undo.
    define variable voSyspr as class syspr            no-undo.
    define variable voTache as class parametrageTache no-undo.

    voTache = new parametrageTache().
    voSyspg = new syspg("R_TAG"). // Type de déclaration
    voSyspr = new syspr().

bloc :
    do :
        if ttTacheIRF.CRUD = "D"
        then do:
            if voTache:tacheObligatoire(ttTacheIRF.iNumeroContrat, ttTacheIRF.cTypeContrat, {&TYPETACHE-ImpotRevenusFonciers})
            then do:
                mError:createError({&error}, 100372).
                leave bloc.
            end.
        end.
        else do:
            if ttTacheIRF.daActivation = ?
            then do:
                mError:createError({&error}, 100299).
                leave bloc.
            end.
            if ttTacheIRF.daActivation < ctrat.dtini
            then do:
                mError:createErrorGestion({&error}, 100678, "").
                leave bloc.
            end.
            if not voSyspg:isDbParameter({&TYPETACHE-ImpotRevenusFonciers}, ttTacheIRF.cTypeDeclaration)
            then do :
                mError:createError({&error}, 1000408). // 1000408 "Le type de déclaration n'existe pas"
                leave bloc.
            end.
            if not voSyspr:isParamExist("CDOUI",string(ttTacheIRF.lMicroFoncier,{&ouiNon})) then do :
                mError:createError({&error}, 1000524). // 1000524 "Le champs micro fonctier est incorrect"
                leave bloc.
            end.
            if not voSyspr:isParamExist("CDOUI",string(ttTacheIRF.lDeclaration2072,{&ouiNon})) then do :
                mError:createError({&error}, 1000525). // 1000525 "Le champs déclaration 2072 est incorrect"
                leave bloc.
            end.
            if not can-find(first honor no-lock where honor.tphon = {&TYPEHONORAIRE-IRF}
                                                  and honor.cdhon = ttTacheIRF.iCodeHonoraire)
            then do :
                mError:createError({&error}, 1000409). // 1000409 "Barème d'honoraire inexistant"
                leave bloc.
            end.
        end.

    end.
    delete object voTache.
    delete object voSyspr.
    delete object voSyspg.
end procedure.

procedure setIRF:
    /*------------------------------------------------------------------------------
    Purpose: maj tache
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter table for ttTacheIRF.

    define buffer tache for tache.
    define buffer ctrat for ctrat.

    for first ttTacheIRF where lookup(ttTacheIRF.CRUD, "C,U,D") > 0:
        find first ctrat no-lock
             where ctrat.tpcon = ttTacheIRF.cTypeContrat
               and ctrat.nocon = ttTacheIRF.iNumeroContrat no-error.
        if not available ctrat
        then do:
            mError:createError({&error}, 100057).
            return.
        end.
        find last tache no-lock
        where tache.tpcon = ttTacheIRF.cTypeContrat
          and tache.nocon = ttTacheIRF.iNumeroContrat
          and tache.tptac = {&TYPETACHE-ImpotRevenusFonciers} no-error.
        if not available tache and lookup(ttTacheIRF.CRUD, "U,D") > 0
        then do:
            mError:createError({&error}, 1000413). // modification d'une tache inexistante
            return.
        end.
        if available tache and ttTacheIRF.CRUD = "C"
        then do:
            mError:createError({&error}, 1000412). //création d'une tache existante
            return.
        end.
        run verZonSai (buffer ctrat, buffer ttTacheIRF).
        if mError:erreur() then return.
        run majTache (buffer ttTacheIRF, buffer ctrat).
    end.
end procedure.

procedure initIRF:
    /*------------------------------------------------------------------------------
    Purpose: Initialisation de la tache IRF
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat   as int64     no-undo.
    define input parameter pcTypeMandat     as character no-undo.
    define output parameter table for ttTacheIRF.

    define buffer ctrat for ctrat.

    find first ctrat no-lock
         where ctrat.tpcon = pcTypeMandat
           and ctrat.nocon = piNumeroMandat no-error.
    if not available ctrat
    then do:
        mError:createError({&error}, 100057).
        return.
    end.
    if can-find(last tache no-lock
                where tache.tpcon = pcTypeMandat
                  and tache.nocon = piNumeroMandat
                  and tache.tptac = {&TYPETACHE-ImpotRevenusFonciers})
    then do:
        mError:createError({&error}, 1000410). // 1000410 demande d'initialisation pour une tache deja existante
        return.
    end.
    run InfoParDefautIRF (buffer ctrat).
end procedure.

procedure InfoParDefautIRF private:
    /*------------------------------------------------------------------------------
    Purpose: creation table ttTacheIRF avec les informations par defaut pour creation de la tache
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer ctrat for ctrat.

    define variable vhproc           as handle               no-undo.

    run parametre/cabinet/gerance/defautMandatGerance.p persistent set vhproc.
    run getTokenInstance in vhproc(mToken:JSessionId).

    empty temp-table ttParamIRF.
    run getParamIRF in vhproc (output table ttParamIRF by-reference).
    run destroy in vhproc.

    empty temp-table ttTacheIRF.
    create ttTacheIRF.
    assign
        ttTacheIRF.iNumeroTache     = 0
        ttTacheIRF.cTypeContrat     = ctrat.tpcon
        ttTacheIRF.iNumeroContrat   = ctrat.nocon
        ttTacheIRF.cTypeTache       = {&TYPETACHE-ImpotRevenusFonciers}
        ttTacheIRF.iChronoTache     = 0
        ttTacheIRF.daActivation     = ctrat.dtdeb
        ttTacheIRF.CRUD             = 'C'
    .
    for first ttParamIRF :
        assign
            ttTacheIRF.cTypeDeclaration  = ttParamIRF.cCodeDeclaration
            ttTacheIRF.lMicroFoncier     = ttParamIRF.lMicroFoncier
            ttTacheIRF.lDeclaration2072  = ttParamIRF.lDeclaration2072
            ttTacheIRF.iCodeHonoraire    = integer(ttParamIRF.cCodeHonoraire)
        .
    end.
end procedure.

procedure initComboIRF:
    /*------------------------------------------------------------------------------
    Purpose: Contenu des combos
    Notes  : Service appelé par beMandatGerance.cls
    ------------------------------------------------------------------------------*/
    define output parameter table for ttCombo.

    run chargeCombo.
end procedure.

procedure chargeCombo private:
    /*------------------------------------------------------------------------------
    Purpose: Chargement des combos
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable voSyspg as class syspg no-undo.
    define variable voSyspr as class syspr no-undo.

    empty temp-table ttCombo.
    voSyspg = new syspg().
    voSyspg:creationComboSysPgZonXX("R_TAG", "TYPEDECLARATION", "L", {&TYPETACHE-ImpotRevenusFonciers}, output table ttCombo by-reference).

    voSyspr = new syspr().
    for last ttCombo :
        voSyspr:setgiNumeroItem(ttCombo.iSeqId).
    end.
    voSyspr:getComboParametre("CDOUI","MICROFONCIER",    output table ttCombo by-reference).
    voSyspr:getComboParametre("CDOUI","DECLARATION2072", output table ttCombo by-reference).
    delete object voSyspg.
    delete object voSyspr.
end procedure.

procedure getIRF:
    /*------------------------------------------------------------------------------
    Purpose: Extraction de la tache IRF
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroMandat as int64     no-undo.
    define input  parameter pcTypeMandat   as character no-undo.
    define output parameter table for ttTacheIRF.

    define buffer ctrat for ctrat.
    define buffer tache for tache.

    empty temp-table ttTacheIRF.

    find first ctrat no-lock
         where ctrat.tpcon = pcTypeMandat
           and ctrat.nocon = piNumeroMandat no-error.
    if not available ctrat
    then do:
        mError:createError({&error}, 100057). // Numéro de contrat introuvable
        return.
    end.
    for last tache no-lock
        where tache.tpcon = pcTypeMandat
          and tache.nocon = piNumeroMandat
          and tache.tptac = {&TYPETACHE-ImpotRevenusFonciers} :
        create ttTacheIRF.
        assign
            ttTacheIRF.iNumeroTache      = tache.noita
            ttTacheIRF.cTypeContrat      = tache.tpcon
            ttTacheIRF.iNumeroContrat    = tache.nocon
            ttTacheIRF.cTypeTache        = tache.tptac
            ttTacheIRF.iChronoTache      = tache.notac
            ttTacheIRF.daActivation      = tache.dtdeb
            ttTacheIRF.cTypeDeclaration  = tache.tpges
            ttTacheIRF.lMicroFoncier     = (tache.pdreg = {&oui})
            ttTacheIRF.lDeclaration2072  = (tache.dcreg = {&oui})
            ttTacheIRF.iCodeHonoraire    = integer(tache.cdhon)
            ttTacheIRF.dtTimestamp       = datetime(tache.dtmsy, tache.hemsy)
            ttTacheIRF.CRUD              = 'R'
            ttTacheIRF.rRowid            = rowid(tache)
        .
    end.
end procedure.

procedure creationAutoTache:
    /*------------------------------------------------------------------------------
    Purpose: creation automatique de la tache irf
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
    run InfoParDefautIRF(buffer ctrat).
    if mError:erreur() then return.
    for first ttTacheIRF where ttTacheIRF.CRUD = "C":
        run verZonSai (buffer ctrat, buffer ttTacheIRF).
        if mError:erreur() then return.
        run majTache (buffer ttTacheIRF, buffer ctrat).
    end.    

end procedure.
