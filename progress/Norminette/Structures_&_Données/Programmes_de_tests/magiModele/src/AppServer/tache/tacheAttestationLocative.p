/*-----------------------------------------------------------------------------
File        : tacheAttestationLocative.p
Purpose     : Tâche Attestation Locative dans bail
Author(s)   : npo - 2017/10/30
Notes       : à partir de adb\src\tache\prmsyrxl.p
derniere revue: 2018/03/20
-----------------------------------------------------------------------------*/
using parametre.syspr.syspr.

{preprocesseur/type2contrat.i}
{preprocesseur/type2role.i}
{preprocesseur/type2tache.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{application/include/combo.i}
{tache/include/tacheAttestationLocative.i}
{tache/include/tache.i}
{adblib/include/cttac.i}

procedure getTacheAttestationLocative:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (beBail.cls et bePrebail.cls)
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroContrat as int64     no-undo.
    define input  parameter pcTypeContrat   as character no-undo.
    define output parameter table for ttTacheAttestationLocative.

    define buffer tache for tache.
    define buffer taint for taint.

    empty temp-table ttTacheAttestationLocative.
    if not can-find(first ctrat no-lock
         where ctrat.tpcon = pcTypeContrat
           and ctrat.nocon = piNumeroContrat)
    then do:
        mError:createError({&error}, 100057).
        return.
    end.
    // Gestion du locataire et du/des colocataires(s)
    if not can-find(first tache no-lock
                    where tache.tpcon = pcTypeContrat
                      and tache.nocon = piNumeroContrat
                      and tache.tptac = {&TYPETACHE-attestationsLocatives})
    and not can-find(first taint no-lock
                     where taint.tpcon = pcTypeContrat
                       and taint.nocon = piNumeroContrat
                       and taint.tptac = {&TYPETACHE-attestationsLocatives}) 
    then do:
        mError:createError({&error}, 1000471).  // tache inexistante
        return.
    end.
    // Chargement des attestations du rôle Locataire / Candidat Locataire
    for each tache no-lock
        where tache.tpcon = pcTypeContrat
          and tache.nocon = piNumeroContrat
          and tache.tptac = {&TYPETACHE-attestationsLocatives}:
        create ttTacheAttestationLocative.
        assign
            ttTacheAttestationLocative.iNumeroTache           = tache.noita
            ttTacheAttestationLocative.cTypeContrat           = tache.tpcon
            ttTacheAttestationLocative.iNumeroContrat         = tache.nocon
            ttTacheAttestationLocative.cTypeTache             = tache.tptac
            ttTacheAttestationLocative.cTypeRole              = (if pcTypeContrat = {&TYPECONTRAT-bail} then {&TYPEROLE-locataire} else {&TYPEROLE-candidatLocataire})
            ttTacheAttestationLocative.cLibelleTypeRole       = outilTraduction:getLibelleProg("O_ROL", ttTacheAttestationLocative.cTypeRole)
            ttTacheAttestationLocative.iNumeroRole            = tache.nocon
            ttTacheAttestationLocative.cNomRole               = outilFormatage:getNomTiers(ttTacheAttestationLocative.cTypeRole, tache.nocon)
            ttTacheAttestationLocative.iNumeroTypeAttestation = tache.notac
            ttTacheAttestationLocative.cLibelleAttestation    = outilTraduction:getLibelleParam("TPATT", string(tache.notac, '99999'))
            ttTacheAttestationLocative.cNumeroPolice          = tache.ntges
            ttTacheAttestationLocative.cNomCompagnie          = tache.tpges
            ttTacheAttestationLocative.daReceptionAttestation = tache.dtreg
            ttTacheAttestationLocative.iNombreMois            = tache.duree
            ttTacheAttestationLocative.daValideDu             = tache.dtdeb
            ttTacheAttestationLocative.daValideAu             = tache.dtfin
            // Champs utilisés only if tache.notac = 1 /* Type = Risque locatif */
            ttTacheAttestationLocative.lBrisdeGlace           = (tache.notac = 1 and num-entries(tache.lbdiv, "@") >= 1 and entry(1, tache.lbdiv, "@") = "1")
            ttTacheAttestationLocative.lTempeteOuragan        = (tache.notac = 1 and num-entries(tache.lbdiv, "@") >= 2 and entry(2, tache.lbdiv, "@") = "1")
            ttTacheAttestationLocative.lVolVandalisme         = (tache.notac = 1 and num-entries(tache.lbdiv, "@") >= 3 and entry(3, tache.lbdiv, "@") = "1")
            ttTacheAttestationLocative.lIncendieExplosion     = (tache.notac = 1 and num-entries(tache.lbdiv, "@") >= 4 and entry(4, tache.lbdiv, "@") = "1")
            ttTacheAttestationLocative.lDegatsDesEaux         = (tache.notac = 1 and num-entries(tache.lbdiv, "@") >= 5 and entry(5, tache.lbdiv, "@") = "1")
            ttTacheAttestationLocative.lCatastrophesNat       = (tache.notac = 1 and num-entries(tache.lbdiv, "@") >= 6 and entry(6, tache.lbdiv, "@") = "1")
            ttTacheAttestationLocative.lResponsabiliteCivile  = (tache.notac = 1 and num-entries(tache.lbdiv, "@") >= 7 and entry(7, tache.lbdiv, "@") = "1")
            ttTacheAttestationLocative.dtTimestamp            = datetime(tache.dtmsy, tache.hemsy)
            ttTacheAttestationLocative.CRUD                   = 'R'
            ttTacheAttestationLocative.rRowid                 = rowid(tache)
        .
    end.
    /* Chargement des attestations des rôles Colocataire */
    for each taint no-lock
        where taint.tpcon = pcTypeContrat
          and taint.nocon = piNumeroContrat
          and taint.tptac = {&TYPETACHE-attestationsLocatives} :
        create ttTacheAttestationLocative.
        assign
            ttTacheAttestationLocative.iNumeroTache           = 0 /*taint.noita*/ /* npo ??? */
            ttTacheAttestationLocative.cTypeContrat           = taint.tpcon
            ttTacheAttestationLocative.iNumeroContrat         = taint.nocon
            ttTacheAttestationLocative.cTypeTache             = taint.tptac
            ttTacheAttestationLocative.cTypeRole              = taint.tpidt
            ttTacheAttestationLocative.cLibelleTypeRole       = outilTraduction:getLibelleProg("O_ROL", taint.tpidt)
            ttTacheAttestationLocative.iNumeroRole            = taint.noidt
            ttTacheAttestationLocative.cNomRole               = outilFormatage:getNomTiers(taint.tpidt, taint.noidt)  // npo
            ttTacheAttestationLocative.iNumeroTypeAttestation = taint.notac
            ttTacheAttestationLocative.cLibelleAttestation    = outilTraduction:getLibelleParam("TPATT", string(taint.notac, '99999'))
            ttTacheAttestationLocative.cNumeroPolice          = entry(1, taint.lbdiv, "@")
            ttTacheAttestationLocative.cNomCompagnie          = if num-entries(taint.lbdiv, "@") >= 2 then entry(2, taint.lbdiv, "@") else ""
            ttTacheAttestationLocative.daReceptionAttestation = if num-entries(taint.lbdiv, "@") >= 3 then date(entry(3, taint.lbdiv, "@")) else ?
            ttTacheAttestationLocative.iNombreMois            = if num-entries(taint.lbdiv, "@") >= 6 then integer(entry(6, taint.lbdiv, "@")) else 0
            ttTacheAttestationLocative.daValideDu             = if num-entries(taint.lbdiv, "@") >= 4 then date(entry(4, taint.lbdiv, "@")) else ?
            ttTacheAttestationLocative.daValideAu             = if num-entries(taint.lbdiv, "@") >= 5 then date(entry(5, taint.lbdiv, "@")) else ?
            // Champs utilisés only if tache.notac = 1 /* Type = Risque locatif */
            ttTacheAttestationLocative.lBrisdeGlace           = (taint.notac = 1 and num-entries(taint.lbdiv2, "@") >= 1 and entry(1, taint.lbdiv2, "@") = "1")
            ttTacheAttestationLocative.lTempeteOuragan        = (taint.notac = 1 and num-entries(taint.lbdiv2, "@") >= 2 and entry(2, taint.lbdiv2, "@") = "1")
            ttTacheAttestationLocative.lVolVandalisme         = (taint.notac = 1 and num-entries(taint.lbdiv2, "@") >= 3 and entry(3, taint.lbdiv2, "@") = "1")
            ttTacheAttestationLocative.lIncendieExplosion     = (taint.notac = 1 and num-entries(taint.lbdiv2, "@") >= 4 and entry(4, taint.lbdiv2, "@") = "1")
            ttTacheAttestationLocative.lDegatsDesEaux         = (taint.notac = 1 and num-entries(taint.lbdiv2, "@") >= 5 and entry(5, taint.lbdiv2, "@") = "1")
            ttTacheAttestationLocative.lCatastrophesNat       = (taint.notac = 1 and num-entries(taint.lbdiv2, "@") >= 6 and entry(6, taint.lbdiv2, "@") = "1")
            ttTacheAttestationLocative.lResponsabiliteCivile  = (taint.notac = 1 and num-entries(taint.lbdiv2, "@") >= 7 and entry(7, taint.lbdiv2, "@") = "1")
            ttTacheAttestationLocative.dtTimestamp            = datetime(taint.dtmsy, taint.hemsy)
            ttTacheAttestationLocative.CRUD                   = 'R'
            ttTacheAttestationLocative.rRowid                 = rowid(taint)
        .
    end.
end procedure.

procedure initComboTacheAttestationLocative:
    /*------------------------------------------------------------------------------
    Purpose: appel programme pour creation combo combo Type Attestation
    Notes  : Service externe appelé par beBail.cls
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroContrat as int64     no-undo.
    define input  parameter pcTypeContrat   as character no-undo.
    define output parameter table for ttCombo.

    run chargeCombo(input piNumeroContrat, input pcTypeContrat).

end procedure.

procedure chargeCombo private:
    /*------------------------------------------------------------------------------
    Purpose: Chargement de toutes les combos de l'écran
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcTypeContrat   as character no-undo.

    define variable vcListeRoles as character   no-undo.
    define variable viNumeroItem as integer     no-undo.
    define variable voSyspr      as class syspr no-undo.

    define buffer intnt for intnt.
    assign
        voSyspr      = new syspr()
        viNumeroItem = voSyspr:getComboParametre("TPATT", "TYPEATTESTATIONLOCATIVE", output table ttCombo by-reference)
        vcListeRoles = substitute("&1,&2", if pcTypeContrat = {&TYPECONTRAT-bail} then {&TYPEROLE-locataire} else {&TYPEROLE-candidatLocataire}, {&TYPEROLE-colocataire})
    .
    /* Type de rôle */
    create ttCombo.
    assign
        viNumeroItem      = viNumeroItem + 1
        ttcombo.iSeqId    = viNumeroItem
        ttCombo.cNomCombo = "ATTLOCTYPEROLE"
        ttCombo.cCode     = if pcTypeContrat = {&TYPECONTRAT-bail} then {&TYPEROLE-locataire} else {&TYPEROLE-candidatLocataire}
        ttCombo.cLibelle  = outilTraduction:getLibelleProg('O_ROL', ttCombo.cCode)
    .
    if can-find(first intnt no-lock
                where intnt.tpcon = pcTypeContrat
                  and intnt.nocon = piNumeroContrat
                  and intnt.tpidt = {&TYPEROLE-colocataire}) then do:
        create ttCombo.
        assign
            viNumeroItem      = viNumeroItem + 1
            ttcombo.iSeqId    = viNumeroItem
            ttCombo.cNomCombo = "ATTLOCTYPEROLE"
            ttCombo.cCode     = {&TYPEROLE-colocataire}
            ttCombo.cLibelle  = outilTraduction:getLibelleProg('O_ROL', {&TYPEROLE-colocataire})
        .
    end.
    /* Rôle */
    for each intnt no-lock
        where intnt.tpcon = pcTypeContrat
          and intnt.nocon = piNumeroContrat
          and lookup(intnt.tpidt, vcListeRoles) > 0:
        create ttCombo.
        assign
            viNumeroItem      = viNumeroItem + 1
            ttcombo.iSeqId    = viNumeroItem
            ttCombo.cNomCombo = "ATTLOCNOMROLE"
            ttCombo.cCode     = intnt.tpidt
            ttCombo.cLibelle  = outilFormatage:getNomTiers(intnt.tpidt, intnt.noidt)
        .
    end.
    delete object voSyspr.

end procedure.

procedure initTacheAttestationLocative:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (beBail.cls)
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcTypeContrat   as character no-undo.
    define output parameter table for ttTacheAttestationLocative.

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
                  and tache.tptac = {&TYPETACHE-attestationsLocatives}) then do:
        mError:createError({&error}, 1000410).
        return.
    end.
    run chargeCombo(piNumeroContrat, pcTypeContrat).
    run infoParDefautAttestationLocative(buffer ctrat).

end procedure.

procedure InfoParDefautAttestationLocative private:
    /*------------------------------------------------------------------------------
    Purpose: creation table ttTacheAttestationLocative avec les informations par defaut pour creation de la tache
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer ctrat for ctrat.

    empty temp-table ttTacheAttestationLocative.
    create ttTacheAttestationLocative.
    assign
        ttTacheAttestationLocative.iNumeroTache           = 0
        ttTacheAttestationLocative.cTypeContrat           = ctrat.tpcon
        ttTacheAttestationLocative.iNumeroContrat         = ctrat.nocon
        ttTacheAttestationLocative.cTypeTache             = {&TYPETACHE-attestationsLocatives}
        ttTacheAttestationLocative.iNumeroTypeAttestation = 1   // risque locatif par défaut
        ttTacheAttestationLocative.cLibelleAttestation    = outilTraduction:getLibelleParam("TPATT", '00001')
        ttTacheAttestationLocative.cTypeRole              = if ctrat.tpcon = {&TYPECONTRAT-bail} then {&TYPEROLE-locataire} else {&TYPEROLE-candidatLocataire}
        ttTacheAttestationLocative.cLibelleTypeRole       = outilTraduction:getLibelleProg('O_ROL', ttTacheAttestationLocative.cTypeRole)
        ttTacheAttestationLocative.iNumeroRole            = ctrat.nocon
        ttTacheAttestationLocative.cNomRole               = outilFormatage:getNomTiers(ttTacheAttestationLocative.cTypeRole, ctrat.nocon)
        ttTacheAttestationLocative.iNombreMois            = 12
        ttTacheAttestationLocative.CRUD                   = 'C'
    .
end procedure.

procedure setTacheAttestationLocative:
    /*------------------------------------------------------------------------------
    Purpose: maj tache (a partir de la table ttTacheAttestationLocative en fonction du CRUD)
    Notes  : service externe (beBail.cls et bePrebail.cls)
    ------------------------------------------------------------------------------*/
    define input parameter table for ttTacheAttestationLocative.
    define buffer ctrat for ctrat.

    for first ttTacheAttestationLocative
        where lookup(ttTacheAttestationLocative.CRUD, "C,U,D") > 0:
        if not can-find(first ctrat no-lock
                        where ctrat.tpcon = ttTacheAttestationLocative.cTypeContrat
                          and ctrat.nocon = ttTacheAttestationLocative.iNumeroContrat)
        then do:
            mError:createError({&error}, 100057).
            return.
        end.
        run chargeCombo(ttTacheAttestationLocative.iNumeroContrat, ttTacheAttestationLocative.cTypeContrat).
    end.

    for each ttTacheAttestationLocative
        where lookup(ttTacheAttestationLocative.CRUD, "C,U,D") > 0:
        if (ttTacheAttestationLocative.cTypeRole = {&TYPEROLE-locataire}
        or ttTacheAttestationLocative.cTypeRole = {&TYPEROLE-candidatLocataire})
        and lookup(ttTacheAttestationLocative.CRUD, "U,D") > 0
        and not can-find(first tache no-lock
                         where tache.tpcon = ttTacheAttestationLocative.cTypeContrat
                           and tache.nocon = ttTacheAttestationLocative.iNumeroContrat
                           and tache.tptac = {&TYPETACHE-attestationsLocatives}
                           and tache.notac = ttTacheAttestationLocative.iNumeroTypeAttestation)
        then do:
            mError:createError({&error}, 1000413).  // modification d'une tache inexistante
            return.
        end.
        if ttTacheAttestationLocative.cTypeRole = {&TYPEROLE-colocataire}
        and lookup(ttTacheAttestationLocative.CRUD, "U,D") > 0
        and can-find(first taint no-lock
                     where taint.tpcon = ttTacheAttestationLocative.cTypeContrat
                       and taint.nocon = ttTacheAttestationLocative.iNumeroContrat
                       and taint.tptac = {&TYPETACHE-attestationsLocatives}
                       and taint.notac = ttTacheAttestationLocative.iNumeroTypeAttestation)
        then do:
            mError:createError({&error}, 1000413).   // modification d'une tache inexistante
            return.
        end.
        run verZonSai(buffer ttTacheAttestationLocative).
        if mError:erreur() then return.
        run majTache(buffer ttTacheAttestationLocative).
    end.

end procedure.

procedure verZonSai private:
    /*------------------------------------------------------------------------------
    Purpose: Vérification des zones avant maj
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer ttTacheAttestationLocative for ttTacheAttestationLocative.

    if ttTacheAttestationLocative.iNombreMois = 0
    or ttTacheAttestationLocative.daValideDu = ?
    or ttTacheAttestationLocative.daValideAu = ?
    or ttTacheAttestationLocative.daReceptionAttestation = ?
    then mError:createError({&error}, 104011).   // Vous devez renseigner toutes les dates.
    else if ttTacheAttestationLocative.daValideDu > ttTacheAttestationLocative.daValideAu
    then mError:createError({&error}, 104012).   // La date de début doit être inférieure à la date de fin.
    return.

end procedure.

procedure majTache private:
    /*------------------------------------------------------------------------------
    Purpose: maj tache si rôle locataire/candidat locataire = creation table ttTache
             a partir table specifique tache (ici ttTacheAttestationLocative)
             et appel du programme commun de maj des taches (tache/tache.p)
             maj taint si rôle colocataire
             si maj tache correcte appel maj table relation contrat tache (cttac).
             suppression de cttac ssi plus de tache NI de taint
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer ttTacheAttestationLocative for ttTacheAttestationLocative.

    define variable vhProc               as handle    no-undo.
    define variable vhProcTache          as handle    no-undo.
    define variable vcListeRisqueLocatif as character no-undo.

    define buffer cttac for cttac.
    define buffer taint for taint.

    /* Cas du risque locatif */
    empty temp-table ttCttac.
    if ttTacheAttestationLocative.iNumeroTypeAttestation = 1 then do:
        vcListeRisqueLocatif = "0@0@0@0@0@0@0".
        if ttTacheAttestationLocative.lBrisdeGlace          then entry(1, vcListeRisqueLocatif, "@") = "1".
        if ttTacheAttestationLocative.lTempeteOuragan       then entry(2, vcListeRisqueLocatif, "@") = "1".
        if ttTacheAttestationLocative.lVolVandalisme        then entry(3, vcListeRisqueLocatif, "@") = "1".
        if ttTacheAttestationLocative.lIncendieExplosion    then entry(4, vcListeRisqueLocatif, "@") = "1".
        if ttTacheAttestationLocative.lDegatsDesEaux        then entry(5, vcListeRisqueLocatif, "@") = "1".
        if ttTacheAttestationLocative.lCatastrophesNat      then entry(6, vcListeRisqueLocatif, "@") = "1".
        if ttTacheAttestationLocative.lResponsabiliteCivile then entry(7, vcListeRisqueLocatif, "@") = "1".
    end.
    if ttTacheAttestationLocative.cTypeRole = {&TYPEROLE-locataire}
    or ttTacheAttestationLocative.cTypeRole = {&TYPEROLE-candidatLocataire}
    then do:
        empty temp-table ttTache.
        create ttTache.
        assign
            ttTache.noita = ttTacheAttestationLocative.iNumeroTache
            ttTache.tpcon = ttTacheAttestationLocative.cTypeContrat
            ttTache.nocon = ttTacheAttestationLocative.iNumeroContrat
            ttTache.tptac = ttTacheAttestationLocative.cTypeTache
            ttTache.notac = ttTacheAttestationLocative.iNumeroTypeAttestation
            ttTache.duree = ttTacheAttestationLocative.iNombreMois
            ttTache.dtdeb = ttTacheAttestationLocative.daValideDu
            tttache.dtfin = ttTacheAttestationLocative.daValideAu
            ttTache.ntges = ttTacheAttestationLocative.cNumeroPolice
            ttTache.tpges = ttTacheAttestationLocative.cNomCompagnie
            ttTache.dtreg = ttTacheAttestationLocative.daReceptionAttestation
            ttTache.lbdiv = vcListeRisqueLocatif
            ttTache.CRUD        = ttTacheAttestationLocative.CRUD
            ttTache.dtTimestamp = ttTacheAttestationLocative.dtTimestamp
            ttTache.rRowid      = ttTacheAttestationLocative.rRowid
        .
        run tache/tache.p persistent set vhProcTache.
        run getTokenInstance in vhProcTache(mToken:JSessionId).
        run setTache in vhProcTache(table ttTache by-reference).
        run destroy in vhProcTache.
        if mError:erreur() then return.
    end.
    else do:
        if ttTacheAttestationLocative.crud = 'D'
        then for first taint exclusive-lock
            where taint.tpcon = ttTacheAttestationLocative.cTypeContrat
              and taint.nocon = ttTacheAttestationLocative.iNumeroContrat
              and taint.tptac = ttTacheAttestationLocative.cTypeTache
              and taint.notac = ttTacheAttestationLocative.iNumeroTypeAttestation
              and taint.tpidt = ttTacheAttestationLocative.cTypeRole
              and taint.noidt = ttTacheAttestationLocative.iNumeroRole:
            delete taint.
        end.
        if ttTacheAttestationLocative.crud = 'C' or ttTacheAttestationLocative.crud = 'U' then do:
            find first taint exclusive-lock
                where taint.tpcon = ttTacheAttestationLocative.cTypeContrat
                  and taint.nocon = ttTacheAttestationLocative.iNumeroContrat
                  and taint.tptac = ttTacheAttestationLocative.cTypeTache
                  and taint.notac = ttTacheAttestationLocative.iNumeroTypeAttestation
                  and taint.tpidt = ttTacheAttestationLocative.cTypeRole
                  and taint.noidt = ttTacheAttestationLocative.iNumeroRole no-error.
            if not available taint then do:
                create taint.
                assign
                    taint.tpcon = ttTacheAttestationLocative.cTypeContrat
                    taint.nocon = ttTacheAttestationLocative.iNumeroContrat
                    taint.tptac = ttTacheAttestationLocative.cTypeTache
                    taint.notac = ttTacheAttestationLocative.iNumeroTypeAttestation
                    taint.tpidt = ttTacheAttestationLocative.cTypeRole
                    taint.noidt = ttTacheAttestationLocative.iNumeroRole
                    taint.dtcsy = today
                    taint.hecsy = mtime
                    taint.cdcsy = mToken:cUser
                .
            end.
            assign
                taint.lbdiv  = substitute("&1@&2@&3@&4@&5@&6",
                                          ttTacheAttestationLocative.cNumeroPolice,
                                          ttTacheAttestationLocative.cNomCompagnie,
                                          ttTacheAttestationLocative.daReceptionAttestation,
                                          ttTacheAttestationLocative.daValideDu,
                                          ttTacheAttestationLocative.daValideAu,
                                          ttTacheAttestationLocative.iNombreMois)
                taint.lbdiv2 = vcListeRisqueLocatif
                taint.dtmsy  = today
                taint.hemsy  = mtime
                taint.cdmsy  = mToken:cUser
            .
        end.
    end.
    /*-> Suppression possible de cttac ssi plus de tache NI de taint */
    if ttTacheAttestationLocative.CRUD = "D"
    and not can-find(first tache
                     where tache.tpcon = ttTacheAttestationLocative.cTypeContrat
                       and tache.nocon = ttTacheAttestationLocative.iNumeroContrat
                       and tache.tptac = {&TYPETACHE-attestationsLocatives} no-lock)
    and not can-find(first taint
                     where taint.tpcon = ttTacheAttestationLocative.cTypeContrat
                       and taint.nocon = ttTacheAttestationLocative.iNumeroContrat
                       and taint.tptac = {&TYPETACHE-attestationsLocatives} no-lock)
    then for first cttac no-lock
        where cttac.tpcon = ttTacheAttestationLocative.cTypeContrat
          and cttac.nocon = ttTacheAttestationLocative.iNumeroContrat
          and cttac.tptac = ttTacheAttestationLocative.cTypeTache:
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
    else if lookup(ttTacheAttestationLocative.CRUD, "C,U") > 0
    and not can-find(first cttac no-lock
                     where cttac.tpcon = ttTacheAttestationLocative.cTypeContrat
                       and cttac.nocon = ttTacheAttestationLocative.iNumeroContrat
                       and cttac.tptac = ttTacheAttestationLocative.cTypeTache)
    then do:
        create ttCttac.
        assign
            ttCttac.tpcon = ttTacheAttestationLocative.cTypeContrat
            ttCttac.nocon = ttTacheAttestationLocative.iNumeroContrat
            ttCttac.tptac = ttTacheAttestationLocative.cTypeTache
            ttCttac.CRUD  = "C"
        .
    end.
    if can-find(first ttCttac)
    then do:
        run adblib/cttac_CRUD.p persistent set vhproc.
        run getTokenInstance in vhproc(mToken:JSessionId).
        run setCttac in vhproc(table ttCttac by-reference).
        run destroy in vhproc.
    end.
end procedure.
