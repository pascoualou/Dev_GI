/*------------------------------------------------------------------------
File        : tacheCleRepartition.p
Purpose     : tache Clés de répartition
Author(s)   : DM 20180202
Notes       : à partir de adb/tach/prmmtmil.p
------------------------------------------------------------------------*/
{preprocesseur/type2tache.i}
{preprocesseur/type2contrat.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/type2bien.i}
{preprocesseur/nature2cle.i}

using parametre.syspr.syspr.
using parametre.pclie.pclie.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{adblib/include/cttac.i}
{adblib/include/milli.i}
{mandat/include/clemi.i}
{mandat/include/clemi.i &nomtable=ttCleRepartition &serialName=ttCleRepartition}
{adb/include/majCleAlphaGerance.i}     // procedure majClger
{adb/include/majMilliemeImmeuble.i}    // procedure majLotAjustement4geranceAlpha
{tache/include/tacheCleRepartition.i}
{tache/include/tache.i}
{application/include/glbsepar.i}
{application/include/combo.i}

function fIsNull returns logical private(pcString as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    return pcString = "" or pcString = ?.
end function.

function fTotalMillieme returns decimal private (piNumeroImmeuble as integer, pcCodeCle as character, pcTypeContrat as character , piNumeroContrat as int64) :
    /*------------------------------------------------------------------------------
    Purpose: Total des millièmes pour les autres mandats
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vdeTotalMillieme as decimal no-undo.
    define buffer milli for milli.
    define buffer local for local.

    for each milli no-lock
        where milli.noimm = piNumeroImmeuble
          and milli.nolot > 0
          and milli.cdcle = pcCodeCle
      , first Local no-lock
        where local.noimm = milli.noimm
          and local.nolot = milli.nolot:
        if not can-find(first intnt no-lock      // ne pas sauter les lots du mandat
            where intnt.tpidt = {&TYPEBIEN-lot}
              and intnt.noidt = local.noloc
              and intnt.tpcon = pcTypeContrat
              and intnt.nocon = piNumeroContrat)
        then vdeTotalMillieme = vdeTotalMillieme + milli.nbpar.
    end.
    return vdeTotalMillieme.
end function.

function fTypeMillieme returns integer private (pcNatureCle as character):
    /*------------------------------------------------------------------------------
    Purpose: Type de millieme --> 0 = obligatoire, 1 = Sans millieme, 2 = Libre
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable viTypeMillieme as integer initial ? no-undo.
    define variable voSyspr        as class syspr no-undo.

    voSyspr = new syspr("TPCLE", pcNatureCle).
    if vosyspr:isDbParameter then viTypeMillieme = vosyspr:zone1.
    delete object voSyspr.
    return viTypeMillieme.
end function.

procedure majTache private:
    /*------------------------------------------------------------------------------
    Purpose: Création/ Maj de la tache clés de répartition
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeTache as character no-undo.
    define variable vhProcTache        as handle    no-undo.
    define variable vhProcCttac        as handle    no-undo.

    run tache/tache.p       persistent set vhProcTache.
    run getTokenInstance    in vhProcTache(mToken:JSessionId).
    run adblib/cttac_CRUD.p persistent set vhProcCttac.
    run getTokenInstance    in vhProcCttac(mToken:JSessionId).

    empty temp-table ttTache.
    empty temp-table ttCttac.
    create ttCttac.
    assign
        ttCttac.tpcon       = ttTacheCleRepartition.cTypeContrat
        ttCttac.nocon       = ttTacheCleRepartition.iNumeroContrat
        ttCttac.tptac       = pcTypeTache
        ttCttac.CRUD        = ttTacheCleRepartition.CRUD
        ttCttac.dtTimestamp = ttTacheCleRepartition.dtTimestamp
        ttCttac.rRowid      = ttTacheCleRepartition.rRowid
    .
    if not can-find(first tache no-lock
                    where tache.tpcon = ttTacheCleRepartition.cTypeContrat
                      and tache.nocon = ttTacheCleRepartition.iNumeroContrat
                      and tache.tptac = pcTypeTache)
    then do:
        create ttTache.
        assign
            ttTache.tpcon = ttTacheCleRepartition.cTypeContrat
            ttTache.nocon = ttTacheCleRepartition.iNumeroContrat
            ttTache.tptac = pcTypeTache
            ttTache.CRUD  = "C"
        .
    end.
    run setCttac in vhProcCttac(table ttCttac by-reference).
    run setTache in vhProcTache(table ttTache by-reference).
    run destroy in vhProcTache.
    run destroy in vhProcCttac.
end procedure.

procedure majCle private:
    /*------------------------------------------------------------------------------
    Purpose: Enregistrement des modifications des clés dans les tables clemi et milli
    Notes  : procédure EnrMajCle
    ------------------------------------------------------------------------------*/
    define variable vlCleImmeuble as logical no-undo.
    define variable vhProcMilli   as handle  no-undo.
    define variable vhProcclemi   as handle  no-undo.

    define buffer vbClemi for clemi.
    define buffer clemi   for clemi.
    define buffer intnt   for intnt.
    define buffer ctrat   for ctrat.

    run adblib/milli_CRUD.p persistent set vhProcMilli.
    run getTokenInstance in vhProcMilli(mToken:JSessionId).
    run adblib/clemi_CRUD.p persistent set vhProcclemi.
    run getTokenInstance in vhProcclemi(mToken:JSessionId).

    empty temp-table ttMilli.
    empty temp-table ttClemi.
MajCle:
    do transaction:
        for each ttCleRepartition
            where ttCleRepartition.cTypeContrat   = ttTacheCleRepartition.cTypeContrat
              and ttCleRepartition.iNumeroContrat = ttTacheCleRepartition.iNumeroContrat
              and ttCleRepartition.CRUD           = "D":
            vlCleImmeuble = false.
            for first clemi no-lock
                where clemi.tpcon       = ttTacheCleRepartition.cTypeContrat
                  and clemi.nocon       = ttTacheCleRepartition.iNumeroContrat
                  and trim(clemi.cdcle) = ttCleRepartition.cCodeCle:           // Pratique pas correcte
                create ttclemi.
                outils:copyValidField(buffer clemi:handle, buffer ttclemi:handle).
                assign
                    ttclemi.CRUD        = "D"
                    ttclemi.rRowid      = ttCleRepartition.rRowid
                    ttclemi.dtTimeStamp = ttCleRepartition.dtTimeStamp
                .
                if index("0123456789", substring(ttCleRepartition.cCodeCle, 1, 1, "character") ) = 0 then
boucleIntnt:
                for each intnt no-lock
                    where intnt.tpidt = {&TYPEBIEN-immeuble}
                      and intnt.noidt = ttTacheCleRepartition.iNumeroImmeuble
                      and intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
                  , first vbClemi no-lock
                    where vbClemi.tpcon       = {&TYPECONTRAT-mandat2Gerance}
                      and vbClemi.nocon       = intnt.nocon
                      and vbClemi.nocon      <> ttTacheCleRepartition.iNumeroContrat
                      and trim(vbClemi.cdcle) = ttCleRepartition.cCodeCle : // Pratique pas correcte
                    vlCleImmeuble = true.
                    leave boucleIntnt.
                end.
                if not vlCleImmeuble // Suppression de la clé immeuble
                then for first vbClemi no-lock
                    where vbClemi.noimm       = ttTacheCleRepartition.iNumeroImmeuble
                      and (vbClemi.tpcon     <> {&TYPECONTRAT-mandat2gerance} or vbClemi.nocon = 0) // Pour sélectionner uniquement identifier les clé immeubles
                      and trim(vbClemi.cdcle) = ttCleRepartition.cCodeCle // Pratique pas correcte
                      and rowid(vbClemi)     <> rowid(clemi)
                      and vbClemi.cdeta       = "V" :
                    create ttclemi.
                    outils:copyValidField(buffer vbClemi:handle, buffer ttclemi:handle).
                    assign
                        ttclemi.CRUD        = "D"
                    .
                end.
            end.
        end.
        vlCleImmeuble = false. // Flag pour Maj clé Immeuble des autres mandats de gérance
        for each ttCleRepartition
            where ttCleRepartition.cTypeContrat   = ttTacheCleRepartition.cTypeContrat
              and ttCleRepartition.iNumeroContrat = ttTacheCleRepartition.iNumeroContrat
              and lookup(ttCleRepartition.CRUD,"C,U") > 0 : // Parcours des clés qui ont été modifiées ou créées
            create ttclemi.
            assign // ne pas déplacer sous copyValidField, rRowid/dtTimeStamp/crud écrasés
                ttclemi.CRUD        = ttCleRepartition.CRUD
                ttclemi.rRowid      = ttCleRepartition.rRowid
                ttclemi.dtTimeStamp = ttCleRepartition.dtTimeStamp
            .
            outils:copyValidField(buffer ttclemi:handle, buffer  ttCleRepartition:handle, "", mtoken:cUser).
            assign
                ttClemi.iNumeroImmeuble = 10000 + ttTacheCleRepartition.iNumeroContrat // 10000 + N° Mandat
                ttClemi.cTypeContrat    = ttTacheCleRepartition.cTypeContrat
                ttClemi.iNumeroContrat  = ttTacheCleRepartition.iNumeroContrat
                ttClemi.cCodeEtat       = string(ttCleRepartition.dEcart = 0,"V/F")
            .
            if index("0123456789", substring(ttCleRepartition.cCodeCle, 1, 1, "character")) = 0
            then do: // Création/Maj de l'entete de la clé (Immeuble) si pas clé Alpha numérique
                vlCleImmeuble = true.
                find first clemi no-lock
                    where clemi.noimm       = ttTacheCleRepartition.iNumeroImmeuble
                      and (clemi.tpcon     <> {&TYPECONTRAT-mandat2gerance} or clemi.nocon = 0) // Pour sélectionner uniquement identifier les clé immeubles
                      and trim(clemi.cdcle) = ttCleRepartition.cCodeCle no-error. // Pratique pas correcte
                create ttclemi.
                if available clemi then assign
                    ttclemi.CRUD        = "U"
                    ttclemi.rRowid      = rowid(clemi)
                    ttclemi.dtTimeStamp = datetime(clemi.dtmsy, clemi.hemsy)
                .
                else ttclemi.CRUD        = "C".
                assign
                    ttClemi.cCodeCle        = ttCleRepartition.cCodeCle
                    ttClemi.iNumeroImmeuble = ttTacheCleRepartition.iNumeroImmeuble
                    ttClemi.cNatureCle      = ttCleRepartition.cNatureCle
                    ttClemi.cLibelleCle     = ttCleRepartition.cLibelleCle
                    ttClemi.cCodebatiment   = ttCleRepartition.cCodeBatiment
                    ttClemi.dEcart          = 0
                    ttClemi.dTotal          = ttCleRepartition.dTantiemeImmeuble
                    ttClemi.cCodeEtat       = string(ttCleRepartition.dEcart = 0,"V/F")
                    ttClemi.iNumeroOrdre    = (if available clemi then clemi.noord else 0)
                    ttClemi.cCodeArchivage  = "00000" // code archivage
                .
            end.
        end.
        for each ttDetailCle // Parcours des détails tantièmes
            where ttDetailCle.cTypeContrat = ttTacheCleRepartition.cTypeContrat
              and ttDetailCle.iNumeroContrat =  ttTacheCleRepartition.iNumeroContrat
              and lookup(ttDetailCle.CRUD,"C,U,D") > 0 :
            create ttMilli.
            assign // ne pas déplacer sous copyValidField,  rRowid/dtTimeStamp/crud écrasés
                ttMilli.CRUD        = (if ttDetailCle.dTantieme = 0 and ttDetailCle.CRUD <> "C" then "D" else ttDetailCle.CRUD)
                ttMilli.rRowid      = ttDetailCle.rRowid
                ttMilli.dtTimeStamp = ttDetailCle.dtTimeStamp
            .
            outils:copyValidField(buffer ttMilli:handle, buffer ttDetailCle:handle, "", mtoken:cUser).
            assign
                ttMilli.noimm       = ttTacheCleRepartition.iNumeroImmeuble
            .
        end.
        run setclemi in vhProcclemi (table ttclemi by-reference).
        run setMilli in vhProcMilli (table ttMilli by-reference).
        if vlCleImmeuble
        then do :
            empty temp-table ttClemi.
            for each intnt no-lock
            where intnt.tpidt = {&TYPEBIEN-immeuble}
              and intnt.noidt = ttTacheCleRepartition.iNumeroImmeuble
              and intnt.tpcon = {&TYPECONTRAT-mandat2Gerance }
              and intnt.nocon <> ttTacheCleRepartition.iNumeroContrat
          , first ctrat no-lock
            where ctrat.tpcon = intnt.Tpcon
              and ctrat.nocon = intnt.Nocon
              and lookup(ctrat.ntcon, substitute("&1,&2",{&NATURECONTRAT-mandatSousLocation},{&NATURECONTRAT-mandatSousLocationDelegue})) = 0 // sauf sous-location
              and (ctrat.dtree = ? or ctrat.dtree > today):
                run majClger(intnt.nocon).
            end.
            run setclemi in vhProcclemi (table ttclemi by-reference). // run setclemi une 2eme fois à cause du test d'existence des clés dans la base, procédure majClger   
        end.
        // Mettre à jour les lots d'ajustement de l'immeuble pour les clés Alpha (ajustement à 0 si immeuble de copro)
        run majLotAjustement4geranceAlpha(ttTacheCleRepartition.iNumeroImmeuble).
        if merror:erreur() then undo majcle, leave majcle.
    end.
    run destroy in vhProcclemi.
    run destroy in vhProcMilli.
end procedure.

procedure VerZonSai private:
    /*------------------------------------------------------------------------------
    Purpose: Controle global avant mise à jour
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable viNombreCleRefacturation as integer     no-undo.
    define variable vcListeCleRefacturation  as character   no-undo.
    define variable voPclie                  as class pclie no-undo.

    // Test de l'écart des clés
    for first ttCleRepartition
        where ttCleRepartition.cTypeContrat    = ttTacheCleRepartition.cTypeContrat
          and ttCleRepartition.iNumeroContrat  = ttTacheCleRepartition.iNumeroContrat
          and ttCleRepartition.CRUD           <> "D"
          and ttCleRepartition.dEcart         <> 0:
        mError:createErrorGestion({&error}, 102388, ttCleRepartition.cCodeCle). // La clé ... doit avoir un écart nul
        return.
    end.
    for each ttCleRepartition
        where ttCleRepartition.cTypeContrat   = ttTacheCleRepartition.cTypeContrat
          and ttCleRepartition.iNumeroContrat = ttTacheCleRepartition.iNumeroContrat
          and ttCleRepartition.CRUD  <> "D"
          and ttCleRepartition.cNatureCle = {&NATURECLE-RefacturationLocataire}:
        assign
            viNombreCleRefacturation = viNombreCleRefacturation + 1
            vcListeCleRefacturation  = vcListeCleRefacturation + "," + ttCleRepartition.cNatureCle
        .
    end.
    vcListeCleRefacturation = trim(vcListeCleRefacturation, ",").
    if viNombreCleRefacturation > 1
    then do:
        mError:createError({&error}, 1000544, substitute("&1&2&3",string(viNombreCleRefacturation),separ[1],vcListeCleRefacturation)). // 1000544 0 "Vous avez créé &1 clés de refacturation des dépenses aux locataires (&2) mais une seule est autorisée."
        return.
    end.
    voPclie = new pclie("RFMAN", "00001").
    if voPclie:isDbParameter and voPclie:zon02 > ""
    then for first ttCleRepartition
        where ttCleRepartition.cTypeContrat   =  ttTacheCleRepartition.cTypeContrat
          and ttCleRepartition.iNumeroContrat =  ttTacheCleRepartition.iNumeroContrat
          and ttCleRepartition.cCodeCle       =  voPclie:zon02
          and ttCleRepartition.CRUD           <> "D"
          and ttCleRepartition.cNatureCle <> {&NATURECLE-RefacturationLocataire}:
        mError:createError({&error}, 1000545, voPclie:zon02). // 1000545 "Le code clé <&1> est réservé pour la clé de refacturation manuelle des dépenses aux locataires."
    end.
    delete object voPclie.
end procedure.

procedure setCleRepartition:
    /*------------------------------------------------------------------------------
    Purpose: Mise à jour en base
    Notes  : service utilisé par beMandatGerance.cls
    ------------------------------------------------------------------------------*/
    define input parameter table for ttTacheCleRepartition.
    define input parameter table for ttCleRepartition.
    define input parameter table for ttDetailCle.

    define variable vhProcControleCle as handle no-undo.

    run adblib/controleCle.p persistent set vhProcControleCle.
    run getTokenInstance in vhProcControleCle (mToken:JSessionId).
blocTransaction:
    do transaction:
        find /* unique */ ttTacheCleRepartition where lookup(ttTacheCleRepartition.CRUD, "U,C") > 0 no-error.
        if not available ttTacheCleRepartition then do :
            if ambiguous ttTacheCleRepartition then mError:createError({&error}, 1000589). //Vous ne pouvez traiter en maj qu'un enregistrement à la fois
            return.
        end.                                    
        for each ttCleRepartition
            where ttCleRepartition.cTypeContrat   = ttTacheCleRepartition.cTypeContrat
              and ttCleRepartition.iNumeroContrat = ttTacheCleRepartition.iNumeroContrat
              and lookup(ttCleRepartition.CRUD, "U,C,D") > 0:
            run controle(vhProcControleCle). // controle de chaque clé
            if merror:erreur() then leave blocTransaction.
        end.
        run verZonSai.   // Controle global
        if merror:erreur() then undo blocTransaction, leave blocTransaction.
        run majCle.      // Enregistrement dans clemi et milli
        if merror:erreur() then undo blocTransaction, leave blocTransaction.
        run majTache(if ttTacheCleRepartition.cTypeContrat = {&TYPECONTRAT-mandat2Gerance} then {&TYPETACHE-CleGerance} else {&TYPETACHE-CleCopropriete}).
        if merror:erreur() then undo blocTransaction, leave blocTransaction.
    end.
    run destroy in vhProcControleCle.
end procedure.

procedure controle private:
    /*------------------------------------------------------------------------------
    Purpose: controle des données saisies
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter phProcControleCle as handle no-undo.

    define variable vdTotalMillieme as decimal no-undo.

    if lookup(ttCleRepartition.CRUD,"U,C") > 0 then do:
        if fIsNull(ttCleRepartition.cCodeCle) then do:
            mError:createError({&error}, 101187). // La saisie du code clé est obligatoire
            return.
        end.
        if fIsNull(ttCleRepartition.cNatureCle) then do:
            mError:createError({&error}, 101651). // La saisie de la Nature de la clé est obligatoire
            return.
        end.
        if ttCleRepartition.cCodebatiment > ""
        and not can-find(first batim no-lock
                         where batim.noimm = ttTacheCleRepartition.iNumeroImmeuble
                           and batim.cdbat = ttCleRepartition.cCodebatiment) then do:
            mError:createError({&error}, 108468). // batiment non valide pour cet immeuble.
            return.
        end.
        if fIsNull(ttCleRepartition.cLibelleCle) then do:
            mError:createError({&error}, 101599). // La saisie du libellé de la clé est obligatoire
            return.
        end.
        if fTypeMillieme(ttCleRepartition.cNatureCle) = 0 then do:
            if ttCleRepartition.dtotal = 0 or ttCleRepartition.dtotal = ? then do:
                mError:createError({&error}, 101369). // La saisie du total des tantiŠmes est obligatoire
                return.
            end.
            if ttCleRepartition.cCodeCle >= "A" then do:
                if ttCleRepartition.dTantiemeImmeuble = 0 then do:
                    mError:createError({&error}, 104054). // La saisie du total des tantièmes de l'immeuble est obligatoire
                    return.
                end.
                if ttCleRepartition.dTantiemeImmeuble < ttCleRepartition.dTotal then do:
                    mError:createError({&error}, 104058). /* Le total des tantiŠmes Immeuble doit ˆtre sup‚rieur ou ‚gal au total du mandat */
                    return.
                end.
                if ttTacheCleRepartition.lImmeubleCopro <> true then do: // null ou false
                    vdTotalMillieme = fTotalMillieme(ttTacheCleRepartition.iNumeroImmeuble, ttCleRepartition.cCodeCle, ttTacheCleRepartition.cTypeContrat, ttTacheCleRepartition.iNumeroContrat).
                    if decimal(ttCleRepartition.dTantiemeImmeuble) < vdTotalMillieme + ttCleRepartition.dTotal then do:
                        mError:createError({&error}, 1000541, string(vdTotalMillieme + ttCleRepartition.dTotal)). // 1000541 "Le total immeuble doit être supérieur ou égal au total des millièmes des lots de tous les mandats (&1)"
                        return.
                    end.
                end.
            end.
        end.
        if lookup(ttCleRepartition.CRUD, "C,U") > 0
           and not can-find(first ttdetailCle
                    where ttDetailCle.cTypeContrat   = ttCleRepartition.cTypeContrat
                      and ttDetailCle.iNumeroContrat = ttCleRepartition.iNumeroContrat
                      and ttDetailCle.cCodeCle       = ttCleRepartition.cCodeCle
                      and ttDetailCle.CRUD          <> "D")
        then run chargeDetailCle(ttTacheCleRepartition.cTypeContrat, ttTacheCleRepartition.iNumeroContrat, ttTacheCleRepartition.iNumeroImmeuble, ttCleRepartition.cCodeCle, ttCleRepartition.cCodebatiment).
        if ttCleRepartition.CRUD = "C" and ttCleRepartition.iNumeroOrdre = 0 then ttCleRepartition.iNumeroOrdre = 500.
        run calculEcart.
    end.
    else if ttCleRepartition.CRUD = "D"
    then run controle in phProcControleCle(ttTacheCleRepartition.cTypeContrat,
                                           ttTacheCleRepartition.iNumeroContrat,
                                           ttTacheCleRepartition.iNumeroImmeuble,
                                           ttCleRepartition.cCodeCle,
                                           "").
end procedure.

procedure calculEcart private:
    /*------------------------------------------------------------------------------
    Purpose: Calcul de l'écart des tantiemes
    Notes  :
    ------------------------------------------------------------------------------*/
    ttCleRepartition.dEcart = ttCleRepartition.dTotal.
    for each ttdetailCle
        where ttDetailCle.cTypeContrat = ttCleRepartition.cTypeContrat
          and ttDetailCle.iNumeroContrat = ttCleRepartition.iNumeroContrat
          and ttDetailCle.cCodeCle = ttCleRepartition.cCodeCle
          and ttDetailCle.CRUD <> "D":
        ttCleRepartition.dEcart = ttCleRepartition.dEcart - ttDetailCle.dTantieme.
    end.
end procedure.

procedure verCleRepartition:
    /*------------------------------------------------------------------------------
    Purpose: Controle saisie clé
    Notes  : service utilisé par beMandatGerance.cls
    ------------------------------------------------------------------------------*/
    define input        parameter table for ttTacheCleRepartition.
    define input-output parameter table for ttCleRepartition.
    define input-output parameter table for ttDetailCle.

    define variable vhProcControleCle as handle no-undo.

    run adblib/controleCle.p persistent set vhProcControleCle.
    run getTokenInstance in vhProcControleCle (mToken:JSessionId).

boucle :
    for each ttTacheCleRepartition where lookup(ttTacheCleRepartition.CRUD, "U,C") > 0
      , each ttCleRepartition where lookup(ttCleRepartition.CRUD, "U,C,D") > 0 and ttCleRepartition.lControle:
        run controle(vhProcControleCle).
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
    phTmpAutorisation::iTypeMillieme = fTypeMillieme(pcTypeCle).
end procedure.

procedure initAutorisation:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:   service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeCle    as character    no-undo.
    define output parameter table-handle phttAutorisation.

    define variable vhTmpAutorisation as handle no-undo.

    create temp-table phttAutorisation.
    phttAutorisation:add-new-field ("iTypeMillieme", "integer", 0, "", ?).
    phttAutorisation:temp-table-prepare("ttAutorisation").
    vhTmpAutorisation = phttAutorisation:default-buffer-handle.
    run chargeAutorisation(pcTypeCle, vhTmpAutorisation).
end procedure.

procedure initComboLibelleCle:
    /*------------------------------------------------------------------------------
    Purpose: Combo des libellés de clé sélectionnable
    Notes  : Service externe appelé par beMandatGerance.cls
    ------------------------------------------------------------------------------*/
    define input parameter pcNatureCle as character no-undo.
    define output parameter table for ttCombo.
    define variable viI1    as integer no-undo.
    define variable voSyspr as class syspr no-undo.
    

    define buffer clemi for clemi.

    voSyspr = new syspr().
boucleClemi:
    for each clemi no-lock
        where clemi.TpCle = pcNatureCle
        break by clemi.lbcle:          // index créé tpcle+lbcle créé
        if first-of(clemi.lbcle) 
        then do :
            voSyspr:creationttCombo("LIBELLECLEREPARTITION", trim(clemi.lbcle), trim(clemi.lbcle), output table ttCombo).
            viI1 = viI1 + 1.
            if viI1 > 200 then leave boucleClemi.
        end.
    end.
    delete object voSyspr.
end procedure.

procedure initComboCleRepartition :
    /*------------------------------------------------------------------------------
    Purpose: Chargement combos
    Notes  : Service externe appelé par beMandatGerance.cls
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat   as int64     no-undo.
    define input parameter pcTypeContrat     as character no-undo.
    define output parameter table for ttCombo.
    define output parameter table for ttclemi.

    define variable vhProcclemi as handle      no-undo.
    define variable voSyspr     as class syspr no-undo.

    define buffer intnt for intnt.

    run adblib/clemi_CRUD.p persistent set vhProcclemi.
    run getTokenInstance in vhProcclemi(mToken:JSessionId).
    empty temp-table ttCombo.
    voSyspr = new syspr().
    voSyspr:getComboParametre("TPCLE", "CMBNATURECLE", output table ttCombo by-reference).
    for first ttcombo where ttcombo.cNomCombo = "CMBNATURECLE" and (ttCombo.cCode = "00030" or ttCombo.cCode = "00031"): delete ttCombo. end. // AG / RIE

    for first intnt no-lock
        where intnt.tpidt = {&TYPEBIEN-immeuble}
          and intnt.tpcon = pcTypeContrat
          and intnt.nocon = piNumeroContrat :
        empty temp-table ttclemi.
        run getClemiSansCleMandat in vhProcclemi(pcTypeContrat, piNumeroContrat, intnt.noidt, ?, "TOUT", table ttclemi by-reference).
    end.
    run destroy in vhProcclemi.
    delete object voSyspr.
end procedure.

procedure crettDetailCle private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure de création d'un détail de clé
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcCodeCle       as character no-undo.
    define parameter buffer unite for unite.
    define parameter buffer milli for milli.
    define parameter buffer local for local.

    define variable viNumeroContrat as integer   no-undo.
    define variable vcTypeContrat   as character no-undo.
    define variable viNumeroBail    as integer   no-undo.
    define variable vcNomLocataire  as character no-undo.

    define buffer ctrat for ctrat.

    if available unite then case unite.noapp:
        when 997 then assign    // Cas reserve au mandant
            vcTypeContrat   = {&TYPECONTRAT-mandat2Gerance}
            viNumeroContrat = unite.nomdt
        .
        when 998 then assign    // Cas vacant
            vcTypeContrat   = ""
            viNumeroContrat = 0
        .
        otherwise assign
            viNumeroContrat = unite.norol
            vcTypeContrat   = {&TYPECONTRAT-bail} // Cas d'un locataire
        .
    end case.
    find first ctrat no-lock
        where ctrat.tpcon = vcTypeContrat
          and ctrat.Nocon = viNumeroContrat no-error.
    if available ctrat
    then assign
        viNumeroBail   = ctrat.nocon modulo 100000
        vcNomLocataire = if ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
                         then outilTraduction:getLibelle(700362)   // Réservé au mandant
                         else outilFormatage:getNomTiers(unite.tprol, unite.norol)
    .
    else assign
        viNumeroBail = 0
        vcNomLocataire = outilTraduction:getLibelle(700358) // Vacant
    .
    find first ttDetailCle
        where ttDetailCle.cTypeContrat   = pcTypeContrat
          and ttDetailCle.iNumeroContrat = piNumeroContrat
          and ttDetailCle.cCodeCle       = pcCodeCle
          and ttDetailCle.iNumeroLot     = local.nolot no-error.
    if not available ttDetailCle then do:
        create ttDetailCle.
        assign
            ttDetailCle.cTypeContrat   = pcTypeContrat
            ttDetailCle.iNumeroContrat = piNumeroContrat
            ttDetailCle.cCodeCle       = pcCodeCle
            ttDetailCle.iNumeroBail    = viNumeroBail
            ttDetailCle.iNumeroLot     = local.nolot
            ttDetailCle.cCodeBatiment  = local.CdBat
            ttDetailCle.dTantieme      = if available milli then milli.nbpar else 0
            ttDetailCle.cNomLocataire  = vcNomLocataire
            ttDetailCle.dtTimestamp    = (if milli.dtmsy <> ? then datetime(milli.dtmsy, milli.hemsy) else datetime(milli.dtcsy, milli.hecsy))  when available milli
            ttDetailCle.CRUD           = 'R'
            ttDetailCle.rRowid         = rowid(milli) when available milli
        .
    end.
    else assign
        ttDetailCle.iNumeroBail   = 0
        ttDetailCle.cNomLocataire = outilTraduction:getLibelle(104496) // Lot Divisible
    .
end procedure.

procedure chargeDetailCle private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure de chargement du détail d'une clé (procédure ChgTabDet)
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat    as character no-undo.
    define input parameter piNumeroContrat  as int64     no-undo.
    define input parameter piNumeroImmeuble as integer   no-undo.
    define input parameter pcCodeCle        as character no-undo.
    define input parameter pcCodeBatiment   as character no-undo.

    define buffer vbintnt for intnt.
    define buffer intnt   for intnt.
    define buffer cpuni   for cpuni.
    define buffer local   for local.
    define buffer milli   for milli.
    define buffer unite   for unite.

    for first vbintnt no-lock
        where vbintnt.tpidt = {&TYPEBIEN-immeuble}
          and vbintnt.tpcon = pcTypeContrat
          and vbintnt.nocon = piNumeroContrat :
        if not can-find(ttDetailCle where ttDetailCle.cTypeContrat   = pcTypeContrat
                                      and ttDetailCle.iNumeroContrat = piNumeroContrat
                                      and ttDetailCle.cCodeCle       = pcCodeCle)
        then for each intnt no-lock // Parcours des lots qui ont un millieme
            where intnt.Tpcon = pcTypeContrat
              and intnt.Nocon = piNumeroContrat
              and intnt.Tpidt = {&TYPEBIEN-lot}
          , first local no-lock where local.noloc = intnt.noidt
          , first milli no-lock where milli.noimm = piNumeroImmeuble
                                  and milli.nolot = local.nolot
                                  and milli.cdcle = pcCodeCle
          , each cpuni  no-lock // Recherche du nom locataire
                where cpuni.nomdt = piNumeroContrat
                  and cpuni.nolot = local.nolot
                  and cpuni.noimm = local.noimm
          , first unite no-lock
                where unite.nomdt = cpuni.nomdt
                  and unite.noapp = cpuni.noapp
                  and unite.nocmp = cpuni.nocmp
                  and unite.noact = 0 :
            run crettDetailCle(pcTypeContrat, piNumeroContrat, pcCodeCle, buffer unite, buffer milli, buffer local).
        end.
        if pcCodeBatiment = ? or pcCodeBatiment = ""
        then for each intnt no-lock
            where intnt.Tpidt = {&TYPEBIEN-lot} // Parcours des lots du mandat */
              and intnt.Tpcon = pcTypeContrat
              and intnt.nocon = piNumeroContrat
          , first local no-lock
            where local.noimm = vbintnt.noidt
              and local.Noloc = intnt.noidt:
            if not can-find(ttDetailCle where ttDetailCle.cTypeContrat = pcTypeContrat
                                          and ttDetailCle.iNumeroContrat = piNumeroContrat
                                          and ttDetailCle.iNumeroLot = local.nolot
                                          and ttDetailCle.cCodeCle = pcCodeCle)
            then for each cpuni no-lock // Recherche du nom locataire
                where cpuni.nomdt = piNumeroContrat
                  and cpuni.noimm   = local.noimm
                  and cpuni.nolot   = local.nolot
              , first unite no-lock
                where unite.nomdt = cpuni.nomdt
                  and unite.noapp  = cpuni.noapp
                  and unite.nocmp  = cpuni.nocmp
                  and unite.noact  = 0:
                find first milli no-lock
                    where milli.noimm = vbintnt.noidt
                      and milli.nolot = local.nolot
                      and milli.cdcle = pcCodeCle no-error.
                run crettDetailCle(pcTypeContrat, piNumeroContrat, pcCodeCle, buffer unite, buffer milli, buffer local).
            end.
        end.
        else for each intnt no-lock
            where intnt.Tpidt = {&TYPEBIEN-lot} // Parcours des lots de l'immeuble et du batim
              and intnt.Tpcon = pcTypeContrat
              and intnt.nocon = piNumeroContrat
          , first local no-lock
            where local.noimm = vbintnt.noidt
              and local.Noloc = intnt.noidt
              and local.CdBat = pcCodeBatiment:
            if not can-find(ttDetailCle where ttDetailCle.cTypeContrat   = pcTypeContrat
                                          and ttDetailCle.iNumeroContrat = piNumeroContrat
                                          and ttDetailCle.iNumeroLot     = local.nolot
                                          and ttDetailCle.cCodeCle       = pcCodeCle) // Test si ce lot est deja dans la table
            then for last cpuni no-lock
                where cpuni.nomdt = piNumeroContrat // Recherche du nom locataire
                  and cpuni.nolot = local.nolot:
                find first unite no-lock
                    where unite.nomdt = cpuni.nomdt
                      and unite.noapp = cpuni.noapp
                      and unite.nocmp = cpuni.nocmp
                      and unite.noact = 0 no-error.
                find first milli no-lock
                    where milli.noimm = vbintnt.noidt
                      and milli.nolot = local.nolot
                      and milli.cdcle = pcCodeCle no-error.
                run crettDetailCle(pcTypeContrat, piNumeroContrat, pcCodeCle, buffer unite, buffer milli, buffer local /*, buffer clemi , input-output viNombreLot */).
            end.
        end.
    end.
end procedure.

procedure getDetailCle:
    /*------------------------------------------------------------------------------
    Purpose: Extraction du detail d'une clé
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input  parameter table for ttTacheCleRepartition.
    define input  parameter table for ttCleRepartition.
    define output parameter table for ttDetailCle.

    run chargeDetailCle(ttTacheCleRepartition.cTypeContrat, ttTacheCleRepartition.iNumeroContrat, ttTacheCleRepartition.iNumeroImmeuble, ttCleRepartition.cCodeCle, ttCleRepartition.cCodebatiment).
end procedure.

procedure getCleRepartition:
    /*------------------------------------------------------------------------------
    Purpose: Extraction de la tache clé de répartition
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcTypeContrat   as character no-undo.
    define output parameter table for ttTacheCleRepartition.
    define output parameter table for ttCleRepartition.
    define output parameter table for ttDetailCle.

    define variable vhProcclemi as handle    no-undo.
    define variable vhProcCttac as handle    no-undo.
    define variable vcTypeTache as character no-undo.

    define buffer ctrat   for ctrat.
    define buffer clemi   for clemi.
    define buffer intnt   for intnt.
    define buffer vbintnt for intnt.
    define buffer vbclemi for clemi.

    if not can-find(first ctrat no-lock
         where ctrat.tpcon = pcTypeContrat
           and ctrat.nocon = piNumeroContrat)
    then do:
        mError:createError({&error}, 100057). // 100057 Numéro de Contrat introuvable.
        return.
    end.
    vcTypeTache = (if pcTypeContrat = {&TYPECONTRAT-mandat2Gerance} then {&TYPETACHE-CleGerance} else {&TYPETACHE-CleCopropriete}).
    run adblib/clemi_CRUD.p persistent set vhProcclemi.
    run getTokenInstance in vhProcclemi(mToken:JSessionId).
    run adblib/cttac_CRUD.p persistent set vhProcCttac.
    run getTokenInstance in vhProcCttac(mToken:JSessionId).

    empty temp-table ttTacheCleRepartition.
    empty temp-table ttDetailCle.
    empty temp-table ttCleRepartition.
    run readCttac in vhProcCttac(pcTypeContrat, piNumeroContrat, vcTypeTache, table ttCttac by-reference).
    for last ttCttac
      , first intnt no-lock
        where intnt.tpidt = {&TYPEBIEN-immeuble}
          and intnt.tpcon = pcTypeContrat
          and intnt.nocon = piNumeroContrat :
        create ttTacheCleRepartition.
        outils:copyValidField(buffer ttCttac:handle, buffer ttTacheCleRepartition:handle).
        assign
            ttTacheCleRepartition.rRowid          = ttCttac.rRowid
            ttTacheCleRepartition.lUniteActive    = can-find(first unite where unite.nomdt = piNumeroContrat and unite.noact = 0)
            ttTacheCleRepartition.iNumeroImmeuble = intnt.noidt
        .
        for first vbintnt no-lock
            where vbintnt.tpidt = {&TYPEBIEN-immeuble} // Immeuble aussi en copro ?
              and vbintnt.noidt = intnt.noidt
              and vbintnt.tpcon = {&TYPECONTRAT-mandat2Syndic}
          , first ctrat no-lock
            where ctrat.tpcon = intnt.tpcon
              and ctrat.nocon = intnt.nocon
              and ctrat.dtree = ?:
            ttTacheCleRepartition.lImmeubleCopro = true.
        end.
        run getclemi in vhProcclemi(pcTypeContrat, piNumeroContrat, ?, ?, "TOUT", table ttCleRepartition by-reference).
        for each ttCleRepartition
          , first clemi no-lock
            where clemi.tpcon  = ttCleRepartition.cTypeContrat
              and clemi.nocon  = ttCleRepartition.iNumeroContrat
              and clemi.cdcle  = ttCleRepartition.cCodeCle:
            {&_proparse_ prolint-nowarn(release)}
            release vbclemi.
            if clemi.cdcle >= "A"
            then find first vbclemi no-lock
                where vbclemi.noimm  = intnt.noidt                         // Recherche des millièmes immeuble
                  and trim(vbclemi.cdcle) = trim(clemi.cdcle) no-error.    // todo   revoir index, Pratique pas correcte
            assign
                ttCleRepartition.dTantiemeImmeuble    = (if available vbclemi then vbclemi.nbTot else 0)
                ttCleRepartition.dTantiemeAutreMandat = fTotalMillieme(intnt.noidt, clemi.cdcle, ttCleRepartition.cTypeContrat, ttCleRepartition.iNumeroContrat) when ttTacheCleRepartition.lImmeubleCopro = false and clemi.cdcle >= "A"
            .
            run chargeDetailCle(pcTypeContrat, piNumeroContrat, intnt.noidt, ttCleRepartition.cCodeCle, clemi.cdbat).
        end.
    end.
    run destroy in vhProcclemi.
    run destroy in vhProcCttac.
end procedure.
