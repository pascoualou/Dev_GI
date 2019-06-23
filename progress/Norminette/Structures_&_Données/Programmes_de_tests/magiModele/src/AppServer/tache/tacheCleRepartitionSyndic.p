/*------------------------------------------------------------------------
File        : tacheCleRepartitionSyndic.p
Purpose     : tache Clés de répartition du mandat de syndic
Author(s)   : GGA 2019/01/21
Notes       : à partir de adb/src/tach/prmmtmil.p
derniere revue: 2019/01/22 - ofa: KO
        traiter les TODO
        utiliser directement les tables temporaires pour le crud plutôt que passer par ttClemi et ttMilli ? 
------------------------------------------------------------------------*/
{preprocesseur/nature2cle.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2tache.i}
{preprocesseur/type2role.i}

using parametre.syspr.syspr.
using parametre.pclie.pclie.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{application/include/glbsepar.i}
{crud/include/cttac.i}
{crud/include/milli.i}
{mandat/include/clemi.i}
{mandat/include/clemi.i &nomtable=ttCleRepartition &serialName=ttCleRepartition}
{tache/include/tacheCleRepartition.i &nomTableDetailCle=ttDetailCleCopro   &serialNameDetailCle=ttDetailCleCopro}    //la description de la table est differente si nom de la table contient copro
{tache/include/tacheCleRepartition.i &nomtable=vbttTacheCleRepartition     &serialName=vbttTacheCleRepartition
                                     &nomTableDetailCle=vbttDetailCleCopro &serialNameDetailCle=vbttDetailCleCopro}  //la description de la table est differente si nom de la table contient copro
{tache/include/tache.i}
{application/include/combo.i}
{adb/include/majmilliemeImmeuble.i}    // procedure majLotAjustement4geranceAlpha
{parametre/cabinet/gestionImmobiliere/include/libelleCleRepartition.i &nomtable=ttLibelleCleRepartition &serialName=ttLibelleCleRepartition}

function fIsNull returns logical private(pcString as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    return pcString = "" or pcString = ?.
end function.

function fTypeMillieme returns integer private (pcNatureCle as character):
    /*------------------------------------------------------------------------------
    Purpose: Type de millieme --> 0 = obligatoire, 1 = Sans millieme, 2 = Libre
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable viTypemillieme as integer no-undo initial ?.
    define variable voSyspr        as class syspr no-undo.

    voSyspr = new syspr("TPCLE", pcNatureCle).
    if vosyspr:isDbParameter then viTypemillieme = vosyspr:zone1.
    delete object voSyspr.
    return viTypemillieme.
end function.

procedure majTache private:
    /*------------------------------------------------------------------------------
    Purpose: Création tache (cttac et tache) si inexistant
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhProc as handle no-undo.

    empty temp-table ttTache.
    empty temp-table ttCttac.
    if not can-find(first cttac no-lock
                    where cttac.tpcon = ttTacheCleRepartition.cTypeContrat
                      and cttac.nocon = ttTacheCleRepartition.iNumeroContrat
                      and cttac.tptac = {&TYPETACHE-CleCopropriete})
    then do:
        create ttCttac.
        assign
            ttCttac.tpcon = ttTacheCleRepartition.cTypeContrat
            ttCttac.nocon = ttTacheCleRepartition.iNumeroContrat
            ttCttac.tptac = {&TYPETACHE-CleCopropriete}
            ttCttac.CRUD  = "C"
        .
        run crud/cttac_CRUD.p persistent set vhProc.
        run getTokenInstance in vhProc(mToken:JSessionId).
        run setCttac in vhProc(table ttCttac by-reference).
        run destroy in vhProc.
    end.
    if not can-find(first tache no-lock
                    where tache.tpcon = ttTacheCleRepartition.cTypeContrat
                      and tache.nocon = ttTacheCleRepartition.iNumeroContrat
                      and tache.tptac = {&TYPETACHE-CleCopropriete})
    then do:
        create ttTache.
        assign
            ttTache.tpcon = ttTacheCleRepartition.cTypeContrat
            ttTache.nocon = ttTacheCleRepartition.iNumeroContrat
            ttTache.tptac = {&TYPETACHE-CleCopropriete}
            ttTache.CRUD  = "C"
        .
        run crud/tache_CRUD.p persistent set vhProc.
        run getTokenInstance in vhProc(mToken:JSessionId).
        run setTache in vhProc(table ttTache by-reference).
        run destroy in vhProc.
    end.
end procedure.

procedure majCle private:
    /*------------------------------------------------------------------------------
    Purpose: maj table clemi 
             pour la creation ou modification de cle, les tables de travail ttClemi et ttMilli sont renseignees au niveau du controle
             pour la suppression de cle, les tables de travail ttClemi et ttMilli sont crees dans cette procedure 
    Notes  : procédure EnrMajCle
    ------------------------------------------------------------------------------*/
    define variable vhProcmilli   as handle  no-undo.
    define variable vhProcclemi   as handle  no-undo.

    define buffer vbClemi for clemi.
    define buffer clemi   for clemi.
    define buffer intnt   for intnt.
    define buffer ctrat   for ctrat.
    define buffer milli   for milli.

    run crud/milli_CRUD.p persistent set vhProcmilli.
    run getTokenInstance in vhProcmilli(mToken:JSessionId).
    run crud/clemi_CRUD.p persistent set vhProcclemi.
    run getTokenInstance in vhProcclemi(mToken:JSessionId).

MajCle:
    do transaction:
        for each ttCleRepartition
           where ttCleRepartition.cTypeContrat   = ttTacheCleRepartition.cTypeContrat
             and ttCleRepartition.iNumeroContrat = ttTacheCleRepartition.iNumeroContrat
             and ttCleRepartition.CRUD           = "D":
            for first clemi no-lock
                where clemi.tpcon = ttTacheCleRepartition.cTypeContrat
                  and clemi.nocon = ttTacheCleRepartition.iNumeroContrat
                  and clemi.cdcle = ttCleRepartition.cCodeCle:
                create ttClemi.
                outils:copyValidField(buffer clemi:handle, buffer ttClemi:handle).
                assign
                    ttClemi.iNumeroImmeuble    = clemi.noimm
                    ttClemi.iNumeroOrdre       = clemi.noord
                    ttClemi.cCodeCle           = clemi.cdcle
                    ttClemi.iNumeroRepartition = clemi.norep
                    ttClemi.cTypeContrat       = clemi.tpcon
                    ttClemi.iNumeroContrat     = clemi.nocon
                    ttClemi.CRUD        = "D"
                    ttClemi.rRowid      = ttCleRepartition.rRowid
                    ttClemi.dtTimestamp = ttCleRepartition.dtTimestamp
                .
                for each milli no-lock
                   where milli.noimm = clemi.noimm
                     and milli.cdcle = clemi.cdcle
                     and milli.norep = 0:
                    create ttMilli.
                    assign
                        ttMilli.noimm = milli.noimm
                        ttMilli.cdcle = milli.cdcle
                        ttMilli.norep = milli.norep
                        ttMilli.nolot = milli.nolot
                        ttMilli.CRUD        = "D"
                        ttMilli.rRowid      = rowid(milli)
                        ttMilli.dtTimestamp = datetime(milli.dtmsy, milli.hemsy)
                    .
                end.
            end.
        end.
        run setclemi in vhProcclemi(table ttClemi by-reference).
        run setmilli in vhProcmilli(table ttMilli by-reference).
        // Mettre à jour les lots d'ajustement de l'immeuble pour les clés Alpha (ajustement à 0 si immeuble de copro)
        run majLotAjustement4geranceAlpha(ttTacheCleRepartition.iNumeroImmeuble).
        if merror:erreur() then undo majcle, leave majcle.
    end.
    run destroy in vhProcclemi.
    run destroy in vhProcmilli.
end procedure.

procedure setCleRepartition:
    /*------------------------------------------------------------------------------
    Purpose: Mise à jour en base
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table for ttTacheCleRepartition.
    define input parameter table for ttCleRepartition.
    define input parameter table for ttDetailCleCopro.

    define variable vhProcControleCle as handle no-undo.

    empty temp-table ttMilli.
    empty temp-table ttClemi.

    run adblib/controleCle.p persistent set vhProcControleCle.
    run getTokenInstance in vhProcControleCle (mToken:JSessionId).
blocTransaction:
    do transaction:
        find /* unique */ ttTacheCleRepartition where lookup(ttTacheCleRepartition.CRUD, "U,C") > 0 no-error.
        if not available ttTacheCleRepartition then do:
            if ambiguous ttTacheCleRepartition then mError:createError({&error}, 1000589). //Vous ne pouvez traiter en maj qu'un enregistrement à la fois
            return.
        end.
        for each ttCleRepartition
            where ttCleRepartition.cTypeContrat   = ttTacheCleRepartition.cTypeContrat
              and ttCleRepartition.iNumeroContrat = ttTacheCleRepartition.iNumeroContrat
              and lookup(ttCleRepartition.CRUD, "U,C,D") > 0:
            run controleSaisieCle(vhProcControleCle).
            if merror:erreur() then leave blocTransaction.
        end.
        run majCle.      // Enregistrement dans clemi et milli
        if merror:erreur() then undo blocTransaction, leave blocTransaction.
        run majTache.
        if merror:erreur() then undo blocTransaction, leave blocTransaction.
    end.
    run destroy in vhProcControleCle.
//gga mError:createError({&error}, "fin test gg ").

end procedure.

procedure controleSaisieCle private:
    /*------------------------------------------------------------------------------
    Purpose: controle des données saisies
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter phProcControleCle as handle no-undo.

    define variable viTotalTantieme as integer no-undo.

    define buffer vbttCleRepartition for ttCleRepartition.
    define buffer clemi              for clemi.

    find first clemi no-lock
         where clemi.tpcon = ttCleRepartition.cTypeContrat
           and clemi.nocon = ttCleRepartition.iNumeroContrat
           and clemi.cdcle = ttCleRepartition.cCodeCle no-error.
    if ttCleRepartition.CRUD = "C" and available clemi
    then do:
        mError:createError({&error}, 1000977, ttCleRepartition.cCodeCle).   // demande de création d'une clé &1 déjà existante
        return.
    end.
    if lookup(ttCleRepartition.CRUD,"U,D") > 0 and not available clemi
    then do:
        mError:createError({&error}, 1000978, ttCleRepartition.cCodeCle). // demande de modification ou suppression d'une clé &1 inexistante
        return.
    end.
    if lookup(ttCleRepartition.CRUD,"U,C") > 0 then do:
        if fIsNull(ttCleRepartition.cCodeCle) then do:
            mError:createError({&error}, 101187). // La saisie du code clé est obligatoire
            return.
        end.
        for first vbttCleRepartition
            where vbttCleRepartition.cTypeContrat   = ttCleRepartition.cTypeContrat
              and vbttCleRepartition.iNumeroContrat = ttCleRepartition.iNumeroContrat
              and vbttCleRepartition.cCodeCle       = ttCleRepartition.cCodeCle
              and rowid(vbttCleRepartition)         <> rowid(ttCleRepartition)
              and vbttCleRepartition.CRUD           <> "D" :
            mError:createErrorGestion({&error}, 104057, substitute("&1&2&3", ttCleRepartition.cCodeCle, separ[1], ttCleRepartition.iNumeroContrat)). // La clé %1 existe déjà pour le mandat %2
            return.
        end.
        if fIsNull(ttCleRepartition.cNatureCle) then do:
            mError:createError({&error}, 101651). // La saisie de la Nature de la clé est obligatoire
            return.
        end.
        if ttCleRepartition.cCodeBatiment > ""
        and not can-find(first batim no-lock
                         where batim.noimm = ttTacheCleRepartition.iNumeroImmeuble
                           and batim.cdbat = ttCleRepartition.cCodeBatiment) then do:
            mError:createError({&error}, 108468). // batiment non valide pour cet immeuble.
            return.
        end.
        if fIsNull(ttCleRepartition.cLibelleCle) then do:
            mError:createError({&error}, 101599). // La saisie du libellé de la clé est obligatoire
            return.
        end.
        if fTypeMillieme(ttCleRepartition.cNatureCle) = 0
            and (ttCleRepartition.dtotal = 0 or ttCleRepartition.dtotal = ?) then do:
            mError:createError({&error}, 101369). // La saisie du total des tantiŠmes est obligatoire
                return.
            end.
        if ttCleRepartition.CRUD = "U" and ttCleRepartition.dtotal = 0 and clemi.nbtot <> 0
        then do:
            run controle in phProcControleCle(ttTacheCleRepartition.cTypeContrat,
                                              ttTacheCleRepartition.iNumeroContrat,
                                              ttTacheCleRepartition.iNumeroImmeuble,
                                              ttCleRepartition.cCodeCle,
                                              "RAZNBTOT").
            if merror:erreur() then return.
        end.
        create ttClemi.
        buffer-copy ttCleRepartition to ttClemi
             assign
                 ttClemi.cdcsy           = ?
                 ttClemi.cdmsy           = ?
                 ttClemi.cCodeEtat       = string(ttCleRepartition.dEcart = 0,"V/F")
        .
        //appel chargeDetailCle pour obtenir la liste de tous les lots (lot deja attache a la cle avec millieme et lot non attache (sans millieme) pour la cle en cours de controle  
        empty temp-table vbttDetailCleCopro.
        run chargeDetailCle(ttCleRepartition.cTypeContrat, ttCleRepartition.iNumeroContrat, ttCleRepartition.iNumeroImmeuble, ttCleRepartition.cCodeCle, ttCleRepartition.cCodeBatiment, output table vbttDetailCleCopro).
        //boucle sur liste des lots 
        for each vbttDetailCleCopro
           where vbttDetailCleCopro.cTypeContrat   = ttCleRepartition.cTypeContrat
             and vbttDetailCleCopro.iNumeroContrat = ttCleRepartition.iNumeroContrat
             and vbttDetailCleCopro.cCodeCle       = ttCleRepartition.cCodeCle:
            viTotalTantieme = viTotalTantieme + vbttDetailCleCopro.dTantieme.   
            //recherche si modif tantieme du lot dans retour ihm (CRUD de cette table U si modif, pas de gestion du C ou D)  
            find first ttDetailCleCopro
                 where ttDetailCleCopro.cTypeContrat   = ttCleRepartition.cTypeContrat
                   and ttDetailCleCopro.iNumeroContrat = ttCleRepartition.iNumeroContrat
                   and ttDetailCleCopro.cCodeCle       = ttCleRepartition.cCodeCle
                   and ttDetailCleCopro.iNumeroLot     = vbttDetailCleCopro.iNumeroLot
                   and ttDetailCleCopro.dTantieme      <> vbttDetailCleCopro.dTantieme
                   and ttDetailCleCopro.CRUD           = "U" no-error.
            //si modif tantieme du lot dans retour ihm, creation table ttMilli pour la maj et on determine le CRUD   
            if available ttDetailCleCopro
            then do:
                viTotalTantieme = viTotalTantieme - vbttDetailCleCopro.dTantieme + ttDetailCleCopro.dTantieme. 
                create ttMilli.
                outils:copyValidField(buffer ttMilli:handle, buffer ttDetailCleCopro:handle, "", "").
                assign
                    ttMilli.noimm       = ttTacheCleRepartition.iNumeroImmeuble
                    ttMilli.rRowid      = vbttDetailCleCopro.rRowid
                    ttMilli.dtTimestamp = vbttDetailCleCopro.dtTimestamp
                .
                if vbttDetailCleCopro.rRowid = ?                              //detail cle inexistant 
                then ttMilli.CRUD = "C".
                else do:                                                 //detail cle existe
                    if ttDetailCleCopro.dTantieme > 0  
                    then ttMilli.CRUD = "U". 
                    else ttMilli.CRUD = "D".                             //suppression si remise a 0 
                end.
            end.
        end. 
        if viTotalTantieme <> ttCleRepartition.dtotal
        then do:
            mError:createErrorGestion({&error}, 102388, ttCleRepartition.cCodeCle). // La clé ... doit avoir un écart nul
            return.
        end.
    end.
    else if ttCleRepartition.CRUD = "D"
    then run controle in phProcControleCle(ttTacheCleRepartition.cTypeContrat,
                                           ttTacheCleRepartition.iNumeroContrat,
                                           ttTacheCleRepartition.iNumeroImmeuble,
                                           ttCleRepartition.cCodeCle,
                                           "").
end procedure.

procedure verCleRepartition:
    /*------------------------------------------------------------------------------
    Purpose: Controle saisie clé
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input        parameter table for ttTacheCleRepartition.
    define input-output parameter table for ttCleRepartition.
    define input-output parameter table for ttDetailCleCopro.

    define variable vhProcControleCle as handle no-undo.

    empty temp-table ttMilli.
    empty temp-table ttClemi.

    run adblib/controleCle.p persistent set vhProcControleCle.
    run getTokenInstance in vhProcControleCle (mToken:JSessionId).
boucle:
    for each ttTacheCleRepartition where lookup(ttTacheCleRepartition.CRUD, "U,C") > 0,
        each ttCleRepartition where lookup(ttCleRepartition.CRUD, "U,C,D") > 0 and ttCleRepartition.lControle:
        run controleSaisieCle(vhProcControleCle).
        if merror:erreur() then leave boucle.
    end.
    run destroy in vhProcControleCle.
end procedure.

procedure chargeAutorisation private:
    /*------------------------------------------------------------------------------
    Purpose: Type de millieme pour gestion sensitivité
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeCle         as character no-undo.
    define input parameter phTmpAutorisation as handle    no-undo.

    phTmpAutorisation:handle:buffer-create().
    phTmpAutorisation::iTypemillieme = fTypeMillieme(pcTypeCle).
end procedure.

procedure initAutorisation:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:   service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeCle as character no-undo.
    define output parameter table-handle phttAutorisation.

    define variable vhTmpAutorisation as handle no-undo.

    create temp-table phttAutorisation.
    phttAutorisation:add-new-field("iTypemillieme", "integer", 0, "", ?).
    phttAutorisation:temp-table-prepare("ttAutorisation").
    vhTmpAutorisation = phttAutorisation:default-buffer-handle.
    run chargeAutorisation(pcTypeCle, vhTmpAutorisation).
end procedure.

procedure initComboLibelleCle:
    /*------------------------------------------------------------------------------
    Purpose: Combo des libellés de clé sélectionnable
    Notes  : Service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcNatureCle  as character   no-undo.
    define input parameter pcCodeCle    as character   no-undo.
    define input parameter pcFiltre     as character   no-undo.
    define input  parameter table for ttCleRepartition.
    define output parameter table for ttCombo.

    define variable voSyspr     as class syspr no-undo.
    define variable vhProc      as handle      no-undo.
    define variable vcMatch     as character   no-undo.

    define buffer clemi for clemi.

    vcMatch = substitute("*&1*", pcFiltre).
    run parametre/cabinet/gestionImmobiliere/libelleCleRepartition.p persistent set vhProc.
    run getTokenInstance in vhProc(mToken:JSessionId).
    voSyspr = new syspr().
    // Libellés des clés paramétrées
    run getLibelleCleRepartition in vhProc(pcCodeCle, output table ttLibelleCleRepartition).
    for each ttLibelleCleRepartition
    where ttLibelleCleRepartition.lActif
      and ttLibelleCleRepartition.cLibelleCle matches vcMatch :
        voSyspr:creationttCombo("LIBELLECLEREPARTITION", ttLibelleCleRepartition.cLibelleCle, ttLibelleCleRepartition.cLibelleCle, output table ttCombo).
    end.
    // Libellés des autres clés
    for each clemi no-lock
        where clemi.TpCle = pcNatureCle
          and clemi.lbcle matches vcMatch
        break by clemi.lbcle:
        if first-of(clemi.lbcle) and
           not can-find(first ttCombo
                            where ttCombo.cNomCombo = "LIBELLECLEREPARTITION"
                              and ttCombo.cCode     = trim(clemi.lbcle))
        then voSyspr:creationttCombo("LIBELLECLEREPARTITION", trim(clemi.lbcle), trim(clemi.lbcle), output table ttCombo).
    end.
    // Libellé des clés en cours de saisie
    for each ttCleRepartition
    where ttCleRepartition.cNatureCle = pcNatureCle
      and ttCleRepartition.cLibelleCle matches vcMatch
      and not can-find(first ttCombo
                            where ttCombo.cNomCombo = "LIBELLECLEREPARTITION"
                              and ttCombo.cCode     = trim(ttCleRepartition.cLibelleCle)) :
        voSyspr:creationttCombo("LIBELLECLEREPARTITION", ttCleRepartition.cLibelleCle, ttCleRepartition.cLibelleCle, output table ttCombo).
    end.

    run destroy in vhProc.
    delete object voSyspr.
end procedure.

procedure initComboCleRepartition:
    /*------------------------------------------------------------------------------
    Purpose: Chargement combos
    Notes  : Service externe
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroContrat as int64     no-undo.
    define input  parameter pcTypeContrat   as character no-undo.
    define output parameter table for ttCombo.
    define output parameter table for ttClemi.

    define variable voSyspr     as class syspr no-undo.

    define buffer ctrat for ctrat.
    define buffer intnt for intnt.
    define buffer clemi for clemi.
    define buffer vbclemi for clemi.

    empty temp-table ttCombo.
    empty temp-table ttClemi.
    find first ctrat no-lock
         where ctrat.tpcon = pcTypeContrat
           and ctrat.nocon = piNumeroContrat no-error.
    if not available ctrat then do:
        mError:createError({&error}, 100057).
        return.
    end.
    voSyspr = new syspr().
    if ctrat.ntcon = {&NATURECONTRAT-restaurantInterEntreprise}
    then
        voSyspr:creationttCombo("CMBNATURECLE", {&NATURECLE-AssembleeGenerale}, outilTraduction:getLibelleParam("TPCLE", {&NATURECLE-AssembleeGenerale}), output table ttCombo by-reference).
    else
        voSyspr:getComboParametreAvecExclusion("TPCLE", substitute('&1,&2,&3', {&NATURECLE-AssembleeGenerale}, {&NATURECLE-RIE}, {&NATURECLE-RefacturationLocataire}),  "CMBNATURECLE", output table ttCombo by-reference).
    delete object voSyspr.

    if ctrat.ntcon = {&NATURECONTRAT-restaurantInterEntreprise}
    then
        for each clemi no-lock
           where clemi.tpcon = pcTypeContrat
             and clemi.cdcle < "B":
            if can-find(first vbclemi no-lock
                        where vbclemi.tpcon = pcTypeContrat
                          and vbclemi.nocon = piNumeroContrat
                          and vbclemi.cdcle = clemi.cdcle) then next.
            if can-find(first ttClemi no-lock
                        where ttClemi.cCodeCle = clemi.cdcle) then next.
            create ttClemi.
            outils:copyValidField(buffer clemi:handle, buffer ttClemi:handle).
        end.
    else do:
        for each clemi no-lock
           where clemi.tpcon = pcTypeContrat:
            if can-find(first vbclemi no-lock
                        where vbclemi.tpcon = pcTypeContrat
                          and vbclemi.nocon = piNumeroContrat
                          and vbclemi.cdcle = clemi.cdcle) then next.
            if can-find(first ttClemi no-lock
                        where ttClemi.cCodeCle = clemi.cdcle) then next.
            create ttClemi.
            outils:copyValidField(buffer clemi:handle, buffer ttClemi:handle).
        end.
    end.

end procedure.

procedure chargeDetailCle private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure de chargement du détail d'une clé (procédure ChgTabDet)
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat    as character no-undo.
    define input parameter piNumeroContrat  as int64     no-undo.
    define input parameter piNumeroImmeuble as integer   no-undo.
    define input parameter pcCodeCle        as character no-undo.
    define input parameter pcCodeBatiment   as character no-undo.
    define output parameter table for vbttDetailCleCopro.

    define buffer vbintnt for intnt.
    define buffer intnt   for intnt.
    define buffer local   for local.
    define buffer milli   for milli.
    define buffer ctrat   for ctrat.

    empty temp-table vbttDetailCleCopro.
    for each milli no-lock
       where milli.noimm = piNumeroImmeuble
         and milli.cdcle = pcCodeCle
         and milli.norep = 0
             and milli.nolot > 0,
          first local no-lock
      where local.noimm = piNumeroImmeuble
            and local.nolot = milli.nolot,
          first intnt no-lock
      where intnt.tpcon = {&TYPECONTRAT-titre2copro}
        and intnt.tpidt = {&TYPEBIEN-lot}
        and intnt.noidt = local.noloc
            and intnt.nbden = 0,
          first ctrat no-lock
      where ctrat.tpcon = intnt.tpcon
        and ctrat.nocon = intnt.nocon:
        create vbttDetailCleCopro.
        assign
            vbttDetailCleCopro.cTypeContrat     = pcTypeContrat
            vbttDetailCleCopro.iNumeroContrat   = piNumeroContrat
            vbttDetailCleCopro.cCodeCle         = pcCodeCle
            vbttDetailCleCopro.iNumeroLot       = local.nolot
            vbttDetailCleCopro.cCodeBatiment    = local.cdbat
            vbttDetailCleCopro.iNumeroBail      = ctrat.norol
            vbttDetailCleCopro.cNomProprietaire = outilFormatage:getNomTiers({&TYPEROLE-coproprietaire}, ctrat.norol)
            vbttDetailCleCopro.dTantieme        = milli.nbpar
            vbttDetailCleCopro.rRowid           = rowid(milli)
            vbttDetailCleCopro.dtTimestamp      = datetime(milli.dtmsy, milli.hemsy)
        .
    end.
    if fIsNull(pcCodeBatiment)
    then for each local no-lock
            where local.noimm = piNumeroImmeuble:
        run creDetailSansMilli (pcTypeContrat, piNumeroContrat, pcCodeCle, buffer local).
    end.
    else for each local no-lock
            where local.noimm = piNumeroImmeuble
              and local.cdbat = pcCodeBatiment:
        run creDetailSansMilli (pcTypeContrat, piNumeroContrat, pcCodeCle, buffer local).
    end.

end procedure.

procedure getDetailCle:
    /*------------------------------------------------------------------------------
    Purpose: Extraction du detail d'une clé
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input  parameter table for ttTacheCleRepartition.
    define input  parameter table for ttCleRepartition.
    define output parameter table for ttDetailCleCopro.

    run chargeDetailCle(ttTacheCleRepartition.cTypeContrat, ttTacheCleRepartition.iNumeroContrat, ttTacheCleRepartition.iNumeroImmeuble, ttCleRepartition.cCodeCle, ttCleRepartition.cCodeBatiment, output table ttDetailCleCopro).
end procedure.

procedure getCleRepartition:
    /*------------------------------------------------------------------------------
    Purpose: Extraction de la tache clé de répartition
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroContrat as int64     no-undo.
    define input  parameter pcTypeContrat   as character no-undo.
    define output parameter table for ttTacheCleRepartition.
    define output parameter table for ttCleRepartition.
    define output parameter table for ttDetailCleCopro.

    define variable vhProcclemi as handle    no-undo.
    define variable vcTypeTache as character no-undo.

    define buffer cttac   for cttac.
    define buffer ctrat   for ctrat.
    define buffer clemi   for clemi.
    define buffer intnt   for intnt.
    define buffer vbintnt for intnt.

    if not can-find(first ctrat no-lock
         where ctrat.tpcon = pcTypeContrat
           and ctrat.nocon = piNumeroContrat) then do:
        mError:createError({&error}, 100057). // 100057 Numéro de Contrat introuvable.
        return.
    end.
    vcTypeTache = (if pcTypeContrat = {&TYPECONTRAT-mandat2Gerance} then {&TYPETACHE-CleGerance} else {&TYPETACHE-CleCopropriete}).
    run crud/clemi_CRUD.p persistent set vhProcclemi.
    run getTokenInstance in vhProcclemi(mToken:JSessionId).

    empty temp-table ttTacheCleRepartition.
    empty temp-table ttDetailCleCopro.
    empty temp-table ttCleRepartition.
    for first cttac no-lock
        where cttac.tpcon = pcTypeContrat
          and cttac.nocon = piNumeroContrat
          and cttac.tptac = vcTypeTache,
        first intnt no-lock
        where intnt.tpidt = {&TYPEBIEN-immeuble}
          and intnt.tpcon = pcTypeContrat
          and intnt.nocon = piNumeroContrat:
        create ttTacheCleRepartition.
        outils:copyValidField(buffer cttac:handle, buffer ttTacheCleRepartition:handle).
        assign
            ttTacheCleRepartition.rRowid          = rowid(cttac)
            ttTacheCleRepartition.dtTimestamp     = datetime(cttac.dtmsy, cttac.hemsy)
            ttTacheCleRepartition.lUniteActive    = can-find(first unite no-lock
                                                             where unite.nomdt = piNumeroContrat
                                                             and unite.noact = 0)
            ttTacheCleRepartition.iNumeroImmeuble = intnt.noidt
        .
        for first vbintnt no-lock
            where vbintnt.tpidt = {&TYPEBIEN-immeuble} // Immeuble aussi en copro ?
              and vbintnt.noidt = intnt.noidt
              and vbintnt.tpcon = {&TYPECONTRAT-mandat2Syndic},
            first ctrat no-lock
            where ctrat.tpcon = intnt.tpcon
              and ctrat.nocon = intnt.nocon
              and ctrat.dtree = ?:
            ttTacheCleRepartition.lImmeubleCopro = true.
        end.
        run getclemi in vhProcclemi(?, 0, intnt.noidt, ?, "TOUT", table ttCleRepartition by-reference).
        for each ttCleRepartition,
            first clemi no-lock
            where clemi.tpcon = ttCleRepartition.cTypeContrat
              and clemi.nocon = ttCleRepartition.iNumeroContrat
              and clemi.cdcle = ttCleRepartition.cCodeCle:
            run chargeDetailCle(pcTypeContrat, piNumeroContrat, intnt.noidt, ttCleRepartition.cCodeCle, clemi.cdbat, output table ttDetailCleCopro append).
        end.
    end.
    run destroy in vhProcclemi.
end procedure.

procedure creDetailSansMilli private:
    /*------------------------------------------------------------------------------
    Purpose: create table detail pour lot sans millieme
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat    as character no-undo.
    define input parameter piNumeroContrat  as int64     no-undo.
    define input parameter pcCodeCle        as character no-undo.
    define parameter buffer local for local.

    def buffer intnt for intnt.
    def buffer ctrat for ctrat.

    if not can-find(first vbttDetailCleCopro
                    where vbttDetailCleCopro.cTypeContrat   = pcTypeContrat
                      and vbttDetailCleCopro.iNumeroContrat = piNumeroContrat
                      and vbttDetailCleCopro.iNumeroLot     = local.nolot
                      and vbttDetailCleCopro.cCodeCle       = pcCodeCle)
    then for last intnt no-lock
            where intnt.tpidt = {&TYPEBIEN-lot}
              and intnt.noidt = local.noloc
              and intnt.tpcon = {&TYPECONTRAT-titre2copro}
              and intnt.nocon >= piNumeroContrat * 100000 + 1
              and intnt.nocon <= piNumeroContrat * 100000 + 99999
              and intnt.nbden = 0,
            first ctrat no-lock
            where ctrat.tpcon = intnt.tpcon
              and ctrat.nocon = intnt.nocon
              and ctrat.norol <> 0:
        create vbttDetailCleCopro.
        assign
            vbttDetailCleCopro.cTypeContrat     = pcTypeContrat
            vbttDetailCleCopro.iNumeroContrat   = piNumeroContrat
            vbttDetailCleCopro.cCodeCle         = pcCodeCle
            vbttDetailCleCopro.iNumeroLot       = local.nolot
            vbttDetailCleCopro.cCodeBatiment    = local.cdbat
            vbttDetailCleCopro.iNumeroBail      = ctrat.norol
            vbttDetailCleCopro.cNomProprietaire = ctrat.lbnom
            vbttDetailCleCopro.dTantieme        = 0
        .
    end.
    
end procedure.

