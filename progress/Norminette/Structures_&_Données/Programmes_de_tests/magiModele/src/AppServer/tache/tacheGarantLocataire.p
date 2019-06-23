/*------------------------------------------------------------------------
File        : tacheGarantLocataire.p
Purpose     : tache garants locataire (redmine #10137)
Author(s)   : SPo - 2018/06/05
Notes       : a partir de adb/src/tach/prmbxgar.p, adb/src/cont/gesanx00.p
derniere revue: 2018/12/20 - DMI: OK
------------------------------------------------------------------------*/
{preprocesseur/type2tache.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2role.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2acte.i}

using parametre.syspr.syspr.
using parametre.pclie.parametrageDefautBail.

{oerealm/include/instanciateTokenOnModel.i} // Doit être positionnée juste après using
{application/include/glbsepar.i}

{crud/include/cttac.i}
{crud/include/intnt.i}
{application/include/combo.i}
{tache/include/tacheGarantLocataire.i}
{outils/include/lancementProgramme.i}       // fonction lancementPgm et suppressionPgmPersistent

procedure getGarantLocataire:
    /*------------------------------------------------------------------------------
    Purpose: readTacheGarantLocataire
    Notes  : service externe (beBail.cls)
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeContrat   as character no-undo.
    define input  parameter piNumeroContrat as int64     no-undo.
    define output parameter table for ttLienGarantLocataire.
    define output parameter table for ttTacheGarantLocataire.

    define buffer intnt  for intnt.
    define buffer tache  for tache.

    empty temp-table ttLienGarantLocataire.
    empty temp-table ttTacheGarantLocataire.
    if not can-find(first ctrat no-lock
                    where ctrat.tpcon = pcTypeContrat
                      and ctrat.nocon = piNumeroContrat) then do:
        mError:createError({&error}, 1000209, substitute( "&1 &2", outilTraduction:getLibelleProg("O_CLC", pcTypeContrat), string(piNumeroContrat))). //contrat &1 inexistant
        return.
    end.
    for each intnt no-lock
        where intnt.tpcon = pcTypeContrat
          and intnt.nocon = piNumeroContrat
          and intnt.tpidt = {&TYPEROLE-garant}
      , first tache no-lock
        where tache.tpcon = intnt.tpcon
          and tache.nocon = intnt.nocon
          and tache.tptac = {&TYPETACHE-garantieLocataire}
          and tache.notac = intnt.noidt:
        create ttLienGarantLocataire.
        outils:copyValidField(buffer intnt:handle, buffer ttLienGarantLocataire:handle).
        run createttTacheGarantLocataire(buffer tache).
    end.
end procedure.

procedure createttTacheGarantLocataire private:
    /*------------------------------------------------------------------------------
    Purpose: création tache garant table physique -> table tempo
    Notes  : service externe (beBail.cls)
    ------------------------------------------------------------------------------*/
    define parameter buffer tache for tache.

    create ttTacheGarantLocataire.
    outils:copyValidField(buffer tache:handle, buffer ttTacheGarantLocataire:handle).
    ttTacheGarantLocataire.cLibelleTypeActe = outilTraduction:getLibelleParam ("TPACT", tache.pdges).
    error-status:error = false no-error.   // reset error-status    
end procedure.

procedure initGarantLocataire:
    /*------------------------------------------------------------------------------
    Purpose: Initialisation ou rechargement des tâches garants du locataire (1 tache par garant)
    Notes  : service externe (beBail.cls)
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeContrat   as character no-undo.
    define input  parameter piNumeroContrat as int64     no-undo.
    define output parameter table for ttLienGarantLocataire.
    define output parameter table for ttTacheGarantLocataire.

    if can-find(first ctrat no-lock
                where ctrat.tpcon = pcTypeContrat
                  and ctrat.nocon = piNumeroContrat)
    then run chargementDesGarantLocataire(pcTypeContrat, piNumeroContrat).
    else  mError:createError({&error}, 1000209, substitute( "&1 &2", outilTraduction:getLibelleProg("O_CLC", pcTypeContrat), string(piNumeroContrat))). //contrat &1 inexistant
end procedure.

procedure ChargementDesGarantLocataire private:
    /*------------------------------------------------------------------------------
    Purpose: creation table ttTacheGarantLocataire
             soit avec les informations de la tache du garant si elle existe
             soit avec les valeurs par defaut pour creation de la tache du garant
             le point de départ est toujours le role annexe "garant" du bail (intnt)
    Notes  : d'après Enawinrch & IniValCtt de prmbxgar.p
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as int64     no-undo.

    define variable voDefautBail                 as class     parametrageDefautBail no-undo.
    define variable vcCodeTypeActe               as character no-undo.
    define variable viNumeroMandat               as int64     no-undo.
    define variable viNombreJoursRelanceDefaut   as integer   no-undo.
    define variable vlIsCautionDureeIndeterminee as logical   no-undo.

    define buffer ctrat for ctrat.
    define buffer tache for tache.
    define buffer intnt for intnt.

    empty temp-table ttLienGarantLocataire.
    empty temp-table ttTacheGarantLocataire.
    // rechercher si garant à durée indéterminée dans la dernière tache garant saisie pour le mandat sur un autre bail
    viNumeroMandat = truncate(piNumeroContrat / 100000, 0).
boucleTacheGarant:
    for each ctrat no-lock
        where ctrat.tpcon = {&TYPECONTRAT-bail}
          and ctrat.nocon >= viNumeroMandat * 100000 + 00101	// UL 001 rang 01
          and ctrat.nocon <= viNumeroMandat * 100000 + 99999	// UL 999 rang 99
          and ctrat.nocon <> piNumeroContrat
      , each tache no-lock
        where tache.tptac = {&TYPETACHE-garantieLocataire}
          and tache.tpcon = ctrat.tpcon
          and tache.nocon = ctrat.nocon
        by tache.noita descending:
        vlIsCautionDureeIndeterminee = (tache.dtFin = ?).
        leave boucleTacheGarant.
    end.
    assign
        voDefautBail               = new parametrageDefautBail("")
        viNombreJoursRelanceDefaut = voDefautBail:getNombreJourRelance()
    .
    for first ctrat no-lock
        where ctrat.tpcon = pcTypeContrat
          and ctrat.nocon = piNumeroContrat
      , each intnt no-lock
        where intnt.tpcon = pcTypeContrat
          and intnt.nocon = piNumeroContrat
          and intnt.tpidt = {&TYPEROLE-garant}:
        vcCodeTypeActe = (if ctrat.tpact > "" then ctrat.tpact else {&TYPEACTE-neant}).
        create ttLienGarantLocataire.
        outils:copyValidField(buffer intnt:handle, buffer ttLienGarantLocataire:handle).
        find first tache no-lock
            where Tache.tpcon = ctrat.tpcon
              and tache.nocon = ctrat.nocon
              and tache.tptac = {&TYPETACHE-garantieLocataire}
              and tache.notac = ttLienGarantLocataire.iNumeroGarant no-error.
        if available tache
        then run createttTacheGarantLocataire(buffer tache).
        else do:
            create ttTacheGarantLocataire.
            assign
                ttTacheGarantLocataire.iNumeroTache          = 0
                ttTacheGarantLocataire.cTypeContrat          = intnt.tpcon
                ttTacheGarantLocataire.iNumeroContrat        = intnt.nocon
                ttTacheGarantLocataire.cTypeTache            = {&TYPETACHE-garantieLocataire}
                ttTacheGarantLocataire.iNumeroGarant         = intnt.noidt
                ttTacheGarantLocataire.daDebutGarant         = ctrat.dtdeb
                ttTacheGarantLocataire.daFinGarant           = (if vlIsCautionDureeIndeterminee then ? else ctrat.dtfin)
                ttTacheGarantLocataire.cNumeroEnregistrement = ""
                ttTacheGarantLocataire.iDelaiPreavis         = 1
                ttTacheGarantLocataire.daSignature           = ctrat.dtsig
                ttTacheGarantLocataire.cLieuSignature        = ctrat.lisig
                ttTacheGarantLocataire.cTypeActe             = vcCodeTypeActe
                ttTacheGarantLocataire.cLibelleTypeActe      = outilTraduction:getLibelleParam ("TPACT", vcCodeTypeActe)
                ttTacheGarantLocataire.iNombreJoursRelance   = viNombreJoursRelanceDefaut
                ttTacheGarantLocataire.dMontantCaution       = 0
                ttTacheGarantLocataire.CRUD                  = 'C'
            .
        end.
    end.
    delete object voDefautBail.
end procedure.

procedure setGarantLocataire:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (beBail.cls)
    ------------------------------------------------------------------------------*/
    define input parameter table for ttLienGarantLocataire.
    define input parameter table for ttTacheGarantLocataire.

    find first ttTacheGarantLocataire
        where lookup(ttTacheGarantLocataire.CRUD, "C,U,D") > 0 no-error.
    find first ttLienGarantLocataire
        where lookup(ttLienGarantLocataire.CRUD, "C,U,D") > 0 no-error.
    if not available ttTacheGarantLocataire
    and not available ttLienGarantLocataire then return.

    run controleTacheGarant.
    if not mError:erreur() then run majTacheGarant.
end procedure.

procedure controleTache:
    /*------------------------------------------------------------------------------
    Purpose: Contrôler la tache pour la PEC bail en simulant la mise à jour
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as int64     no-undo.

    empty temp-table ttLienGarantLocataire.
    empty temp-table ttTacheGarantLocataire.
    if not can-find(first ctrat no-lock
                    where ctrat.tpcon = pcTypeContrat
                      and ctrat.nocon = piNumeroContrat) then do:
        mError:createError({&error}, 1000209, substitute( "&1 &2", outilTraduction:getLibelleProg("O_CLC", pcTypeContrat), string(piNumeroContrat))). //contrat &1 inexistant
        return.
    end.
    run getGarantLocataire(pcTypeContrat, piNumeroContrat, output table ttLienGarantLocataire, output table ttTacheGarantLocataire).
    // simuler la mise à jour
    for each ttLienGarantLocataire
        where lookup(ttLienGarantLocataire.CRUD, "C,U") = 0:
        ttLienGarantLocataire.CRUD = "U".
    end.
    for each ttTacheGarantLocataire
        where lookup(ttTacheGarantLocataire.CRUD, "C,U") = 0:
        ttTacheGarantLocataire.CRUD = "U".
    end.
    run controleTacheGarant.

end procedure.

procedure controleTacheGarant private:
    /*------------------------------------------------------------------------------
    Purpose: Contrôle des données avant mise à jour
    Notes  :
    ------------------------------------------------------------------------------*/
    for each ttLienGarantLocataire
        where lookup(ttLienGarantLocataire.CRUD, "C,U,D") > 0:
        if not can-find(first ctrat no-lock
                        where ctrat.tpcon = ttLienGarantLocataire.cTypeContrat
                          and ctrat.nocon = ttLienGarantLocataire.iNumeroContrat) then do:
            mError:createError({&error}, 1000209, substitute( "&1 &2", outilTraduction:getLibelleProg("O_CLC", ttLienGarantLocataire.cTypeContrat), string(ttLienGarantLocataire.iNumeroContrat))). //contrat &1 inexistant
            return.
        end.
        if not can-find(first roles no-lock
                        where roles.tprol = {&TYPEROLE-garant}
                          and roles.norol = ttLienGarantLocataire.iNumeroGarant) then do:
            mError:createError({&error}, 1000768, substitute('&2&1&3', separ[1], outilTraduction:getLibelleProg("O_ROL", ttLienGarantLocataire.cTypeRole), string(ttLienGarantLocataire.iNumeroGarant))).
            return.
        end.
        if ttLienGarantLocataire.CRUD = "D"
        then for each ttTacheGarantLocataire
            where ttTacheGarantLocataire.cTypeContrat   = ttLienGarantLocataire.cTypeContrat
              and ttTacheGarantLocataire.iNumeroContrat = ttLienGarantLocataire.iNumeroContrat
              and ttTacheGarantLocataire.cTypeTache     = {&TYPETACHE-garantieLocataire}
              and ttTacheGarantLocataire.iNumeroGarant  = ttLienGarantLocataire.iNumeroGarant
              and ttTacheGarantLocataire.CRUD          <> "D":
            ttTacheGarantLocataire.CRUD = (if ttTacheGarantLocataire.iNumeroTache > 0 then "D" else "").
        end.
    end.

boucleCtrlTache:
    for each ttTacheGarantLocataire
        where lookup(ttTacheGarantLocataire.CRUD, "C,U") > 0:
        if ttTacheGarantLocataire.daDebutGarant = ? then do:
            mError:createError({&error}, 108772).
            leave boucleCtrlTache.
        end.
        if ttTacheGarantLocataire.daDebutGarant > ttTacheGarantLocataire.daFinGarant then do:
            mError:createError({&error}, 103954).
            leave boucleCtrlTache.
        end.
        if ttTacheGarantLocataire.iDelaiPreavis < 0
        or ttTacheGarantLocataire.iDelaiPreavis > 12
        then do:
            mError:createError({&error}, 1000769).   // Le délai de préavis doit être compris entre 0 et 12 mois
            leave boucleCtrlTache.
        end.
    end.
    if mError:erreur() then return.
    // si demande de suppression garant alors suppression du lien contrat-garant s'il existe (=> CRUD = "D"), s'il n'existe pas ne pas le créer (=> CRUD = "")
    for each ttTacheGarantLocataire
        where ttTacheGarantLocataire.CRUD = "D"
      , first ttLienGarantLocataire
        where ttLienGarantLocataire.cTypeContrat   = ttTacheGarantLocataire.cTypeContrat
          and ttLienGarantLocataire.iNumeroContrat = ttTacheGarantLocataire.iNumeroContrat
          and ttLienGarantLocataire.cTypeRole      = {&TYPEROLE-garant}
          and ttLienGarantLocataire.iNumeroGarant = ttTacheGarantLocataire.iNumeroGarant
          and ttLienGarantLocataire.CRUD <> "D" :
        ttLienGarantLocataire.CRUD = (if ttLienGarantLocataire.rRowid <> ?
                                     and can-find(first intnt no-lock where rowid(intnt) = ttLienGarantLocataire.rRowid)
                                     then "D" else "").
    end.
end procedure.

procedure majTacheGarant private:
    /*------------------------------------------------------------------------------
    Purpose: Mise à jour des liens et informations garants pour 1 locataire
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhtache               as handle           no-undo.
    define variable vhintnt               as handle           no-undo.
    define variable vhcttac               as handle           no-undo.
    define variable vcTypeContrat         as character        no-undo.
    define variable viNumeroContrat       as int64            no-undo.
    define variable vhProc                as handle           no-undo.
    define variable voCollectionHandlePgm as class collection no-undo.
    define variable vclbdiv3              as character        no-undo.

    define buffer cttac for cttac.
    empty temp-table ttIntnt.
    empty temp-table ttcttac.
    run crud/intnt_CRUD.p persistent set vhintnt.
    run getTokenInstance in vhintnt(mToken:JSessionId).

    for each ttLienGarantLocataire
        where lookup(ttLienGarantLocataire.CRUD, "C,U,D") > 0:
        create ttIntnt.
        assign
            ttIntnt.tpcon                = ttLienGarantLocataire.cTypeContrat
            ttIntnt.nocon                = ttLienGarantLocataire.iNumeroContrat
            ttintnt.tpidt                = ttLienGarantLocataire.cTypeRole
            ttintnt.noidt                = ttLienGarantLocataire.iNumeroGarant
            ttIntnt.nbnum                = 0
            ttIntnt.idpre                = 0
            ttIntnt.idsui                = 0
            ttIntnt.nbden                = 0
            ttIntnt.cdreg                = ""
            ttIntnt.lbdiv                = ""
            ttIntnt.lbdiv2               = ""
            vclbdiv3                     = (if ttLienGarantLocataire.clbdiv3 = "" then separ[1] else ttLienGarantLocataire.clbdiv3)
            entry(1, vclbdiv3, separ[1]) = ttLienGarantLocataire.cLibModeReglement
            ttIntnt.lbdiv3               = vclbdiv3
            ttIntnt.lipar                = ttLienGarantLocataire.cLienParente
            ttIntnt.CRUD                 = ttLienGarantLocataire.CRUD
            ttIntnt.dtTimestamp          = ttLienGarantLocataire.dtTimestamp
            ttIntnt.rRowid               = ttLienGarantLocataire.rRowid
            .
    end.
    run setIntnt in vhIntnt(table ttIntnt by-reference).
    run destroy in vhintnt.
    if mError:erreur() then return.

    // suppression Evenementiel lié à la tache garant
    voCollectionHandlePgm = new collection().
    vhProc = lancementPgm("evenementiel/supEvenementiel.p", voCollectionHandlePgm).
    for each ttTacheGarantLocataire
        where ttTacheGarantLocataire.CRUD = "D":
        run supEvenementiel in vhProc(ttTacheGarantLocataire.cTypeTache, ttTacheGarantLocataire.iNumeroTache, input-output voCollectionHandlePgm).
    end.
    suppressionPgmPersistent(voCollectionHandlePgm).    // destroy programmes +  delete object
    if mError:erreur() then return.

    for each ttTacheGarantLocataire
        where lookup(ttTacheGarantLocataire.CRUD, "C,U,D") > 0:
        if ttTacheGarantLocataire.CRUD = "D"
        then assign
            vcTypeContrat   = ttTacheGarantLocataire.cTypeContrat
            viNumeroContrat = ttTacheGarantLocataire.iNumeroContrat
        .
        else if not can-find(first cttac no-lock
                             where cttac.tpcon = ttTacheGarantLocataire.cTypeContrat
                               and cttac.nocon = ttTacheGarantLocataire.iNumeroContrat
                               and cttac.tptac = ttTacheGarantLocataire.cTypeTache)
        then do:
            create ttCttac.
            assign
                ttCttac.tpcon = ttTacheGarantLocataire.cTypeContrat
                ttCttac.nocon = ttTacheGarantLocataire.iNumeroContrat
                ttCttac.tptac = ttTacheGarantLocataire.cTypeTache
                ttCttac.CRUD  = "C"
            .
        end.
    end.
    if mError:erreur() then return.

    run crud/tache_CRUD.p persistent set vhtache.
    run getTokenInstance in vhtache(mToken:JSessionId).
    run settache in vhtache(table ttTacheGarantLocataire by-reference).
    run destroy in vhtache.
    if mError:erreur() then return.

    // Supprimer lien tache si plus aucune tache garant pour le locataire
    if not can-find(first tache no-lock
                    where tache.tpcon = vcTypeContrat
                      and tache.nocon = viNumeroContrat
                      and tache.tptac = {&TYPETACHE-garantieLocataire})
    then for first cttac no-lock
        where cttac.tpcon = vcTypeContrat
          and cttac.nocon = viNumeroContrat
          and cttac.tptac = {&TYPETACHE-garantieLocataire}:
        create ttCttac.
        outils:copyValidField(buffer cttac:handle, buffer ttCttac:handle).
        ttCttac.CRUD = "D".
    end.
    // Mise à jour des liens tache-contrat (cttac)
    run crud/cttac_CRUD.p persistent set vhCttac.
    run getTokenInstance in vhCttac(mToken:JSessionId).
    run setCttac in vhCttac(table ttCttac by-reference).
    run destroy in vhCttac.
end procedure.

procedure initComboGarantLocataire:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define output parameter table for ttCombo.

    define variable voSyspr as class syspr no-undo.

    empty temp-table ttCombo.
    voSyspr = new syspr().
    voSyspr:getComboParametre("TPACT", "TYPEACTE", output table ttCombo by-reference).
    voSyspr:creationttCombo("MODEREGLT", "", "", output table ttCombo by-reference).
    voSyspr:creationttCombo("MODEREGLT", "C", "Chèque", output table ttCombo by-reference).  // ne pas toucher à ce libellé 'Chèque', c'est (malheureusement) celui stocké dans la base
    voSyspr:creationttCombo("MODEREGLT", "V", "Virement", output table ttCombo by-reference).
    delete object voSyspr.

end procedure.
