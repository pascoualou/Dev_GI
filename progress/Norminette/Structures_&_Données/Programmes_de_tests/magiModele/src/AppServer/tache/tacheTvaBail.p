/*-----------------------------------------------------------------------------
File        : tacheTvaBail.p
Purpose     : Bail - Tache TVA
Author(s)   : npo  -  2018/03/12
Notes       : a partir de  adb\src\tach\prmobtva.p
derniere revue: 2018/05/25 - phm: OK
-----------------------------------------------------------------------------*/
{preprocesseur/listeRubQuit2TVA.i}
{preprocesseur/profil2rubQuit.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2tache.i}
{preprocesseur/type2role.i}

using parametre.pclie.parametrageCodeTVA.
using parametre.pclie.parametrageRelocation.
using parametre.syspg.syspg.
using parametre.syspr.syspr.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{adblib/include/cttac.i}
{application/include/combo.i}
{application/include/glbsepar.i}
{bail/include/equit.i}
{bail/include/libelleRubQuitt.i}
{compta/include/tva.i}
{tache/include/tacheTvaBail.i}

function f-isNull returns logical private(pcChaine as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    return pcChaine = ? or pcChaine = "".
end function.

function donneNatureContrat returns character(piNumeroContrat as int64, pcTypeContrat as character):
    /*------------------------------------------------------------------------
    Purpose : fonction de récupération de la nature du contrat
    Notes   :
    ------------------------------------------------------------------------*/
    define buffer ctrat for ctrat.    
    for first ctrat no-lock
        where ctrat.tpcon = pcTypeContrat
          and ctrat.nocon = piNumeroContrat:
        return ctrat.ntcon.
    end.
    return ''.
end function.

function isDispositifFiscal returns logical(piNumeroContrat as int64):
    /*------------------------------------------------------------------------
    Purpose : fonction de récupération du dispostif fiscal des investisseurs étrangers du bail/prébail
    Notes   : Recherche le lot principal du bail et récupère les infos sur l'investisseur étranger si présentes
    ------------------------------------------------------------------------*/
    define buffer unite for unite.
    define buffer cpuni for cpuni.
    define buffer local for local.

    // Recherche du lot principal du bail
    for first unite no-lock
        where unite.nomdt = integer(truncate(piNumeroContrat / 100000, 0))
          and unite.noapp = integer(truncate((piNumeroContrat modulo 100000) / 100, 0))
          and unite.noact = 0
      , first cpuni no-lock
        where cpuni.nomdt = unite.nomdt
          and cpuni.noapp = unite.noapp
          and cpuni.nocmp = unite.nocmp
          and cpuni.noord = 1
      , first local  no-lock
        where local.noimm = cpuni.noimm
          and local.nolot = cpuni.nolot:
        if trim(replace(local.lbdiv6, separ[1], "")) > ""
        and num-entries(local.lbdiv6, separ[1]) >= 5
        and (entry(1, local.lbdiv6, separ[1]) = "00002" or entry(1, local.lbdiv6, separ[1]) = "00003") // Bail Comm ou Bail Prop
        and entry(2, local.lbdiv6, separ[1]) = "00001" // Soumis à TVA
        and entry(5, local.lbdiv6, separ[1]) > ""
        and entry(5, local.lbdiv6, separ[1]) <> "00001"
        then return true.
    end.
    return false.

end function.

function donneNumeroTVAIntracomm returns character(piNumeroMandant as int64):
    /*------------------------------------------------------------------------
    Purpose : fonction de récupération du numéro TVA Intracomm du mandant
    Notes   : 
    ------------------------------------------------------------------------*/
    define buffer vbRoles for roles.
    define buffer ctanx for ctanx.

    /* Récupération du numero de tiers du role mandant */
    for first vbRoles  no-lock
        where vbRoles.tprol = {&TYPEROLE-mandant}
          and vbRoles.norol = piNumeroMandant
      , first ctanx no-lock
        where ctanx.tpcon = {&TYPECONTRAT-TVAIntracommunautaire}
          and ctanx.tprol = {&TYPEROLE-tiers}       // "99999"
          and ctanx.norol = vbRoles.notie:
        return ctanx.liexe.
    end.
    return ''.

end function.

function recupLibelleRubrique returns character (piNumeroRubrique as integer, piNumeroLibelle as integer):
    /*------------------------------------------------------------------------
    Purpose : fonction de récupération du libellé d'une rubrique
    Notes   :
    ------------------------------------------------------------------------*/
    define buffer rubqt for rubqt.

    for first rubqt no-lock
        where rubqt.cdrub = piNumeroRubrique
          and rubqt.cdlib = piNumeroLibelle:
        return outilTraduction:getLibelle(rubqt.nome1).
    end.
    return ''.
end function.

procedure chercheParametres private:
    /*------------------------------------------------------------------------------
    Purpose: recherche tous les paramètres dont on a besoin
    Notes  : 
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroContrat as int64     no-undo.
    define output parameter poCollection    as class collection no-undo.

    define variable vlExistenceLocation    as logical   no-undo.
    define variable vlGestionTvaEtranger   as logical   no-undo.
    define variable vlBailFournisseurLoyer as logical   no-undo.
    define variable vcFiscCodeCalcul       as character no-undo.
    define variable voRelocation           as class parametrageRelocation no-undo.
    define buffer location for location.

    // Ajout SY le 22/10/2008: Rechercher type du mandat maitre
    vlBailFournisseurLoyer = can-find(first ctrat no-lock
                                      where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
                                        and ctrat.nocon = integer(truncate(piNumeroContrat / 100000, 0))
                                        and ctrat.fgfloy = true).
    // SY 1016/0155 Dispositif fiscal pour bail INVESTISSEUR uniquement (locataire BNPPI RS)
    if vlBailFournisseurLoyer
    then vlGestionTvaEtranger = isDispositifFiscal(piNumeroContrat).

    // Ajout Sy le 19/02/2009 : AGF RELOCATIONS : initialisation avec Fiche relocation
    voRelocation = new parametrageRelocation().
    if voRelocation:isActif()
    then for last location no-lock        // Recherche fiche de relocation (dernier nofiche)
        where location.tpcon  = {&TYPECONTRAT-mandat2Gerance}
          and location.nocon  = int64(truncate(piNumeroContrat / 100000, 0))
          and location.noapp  = integer(truncate((piNumeroContrat modulo 100000) / 100, 0))
          and location.fgarch = no:
        assign
            vlExistenceLocation = true
            vcFiscCodeCalcul    = location.fisc-cdcal
        .
    end.
    delete object voRelocation.
    poCollection = new collection().
    poCollection:set("lExistenceLocation",    vlExistenceLocation).
    poCollection:set("lGestionTvaEtranger",   vlGestionTvaEtranger).
    poCollection:set("lBailFournisseurLoyer", vlBailFournisseurLoyer).
    poCollection:set("cFiscCodeCalcul",       vcFiscCodeCalcul).

end procedure.

procedure getTvaBail:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (beBail.cls)
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcTypeContrat   as character no-undo.
    define output parameter table for ttTacheTvaBail.

    define variable voCollection as class collection no-undo.
    define buffer tache for tache.

    empty temp-table ttTacheTvaBail.
    // Recherche de tous les paramètres dont on a besoin
    run chercheParametres(piNumeroContrat, output voCollection).
    if not can-find(first ctrat no-lock
                    where ctrat.tpcon = pcTypeContrat
                      and ctrat.nocon = piNumeroContrat)
    then mError:createError({&error}, 100057).
    else for last tache no-lock
        where tache.tpcon = pcTypeContrat
          and tache.nocon = piNumeroContrat
          and tache.tptac = {&TYPETACHE-TVABail}:
        create ttTacheTvaBail.
        outils:copyValidField(buffer tache:handle, buffer ttTacheTvaBail:handle).
        assign
            ttTacheTvaBail.cLibelleTauxTVA       = outilTraduction:getLibelleParam("CDTVA", tache.ntges)
            ttTacheTvaBail.cCodeApplicableSur    = tache.pdges
            ttTacheTvaBail.cLibelleApplicableSur = outilTraduction:getLibelleParam("CDCAL", tache.pdges)
            ttTacheTvaBail.iNumeroRubriqueQtt    = integer(entry(1, tache.lbdiv, "#"))
            ttTacheTvaBail.iNumeroLibelleQtt     = integer(entry(2, tache.lbdiv, "#")) when num-entries(tache.lbdiv, "#") > 1
            ttTacheTvaBail.cLibelleRubriqueQtt   = recupLibelleRubrique(ttTacheTvaBail.iNumeroRubriqueQtt, ttTacheTvaBail.iNumeroLibelleQtt)
            ttTacheTvaBail.lNonCommunique        = (ttTacheTvaBail.cNumeroTvaIntraComm = '')
            ttTacheTvaBail.cCodeTauxTVAIntraComm = entry(1, tache.lbdiv2, "#")
            ttTacheTvaBail.cLibelleTVAIntraComm  = entry(2, tache.lbdiv2, "#") when num-entries(tache.lbdiv2, "#") > 1
            // Détermine si partie droite visible ou non pour la vue
            ttTacheTvaBail.lDispositifFiscal = voCollection:getLogical('lGestionTvaEtranger')
        .
    end.

end procedure.

procedure initComboTvaBail:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroContrat as int64     no-undo.
    define input  parameter pcTypeContrat   as character no-undo.
    define output parameter table for ttCombo.

    run chargeCombo(donneNatureContrat(piNumeroContrat, pcTypeContrat)).
end procedure.

procedure chargeCombo private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcNatureContrat as character no-undo.

    define variable vhProcTVA    as handle  no-undo.
    define variable viNumeroItem as integer no-undo.
    define variable voSyspr      as class syspr no-undo.
    define buffer bxrbp for bxrbp.

    empty temp-table ttCombo.
    // Combo Calcul TVA et TVA Intracomm
    voSyspr = new syspr().
    voSyspr:getComboParametre("CDCAL", "CMBCALCULTVA", output table ttCombo by-reference).
    voSyspr:getComboParametreOnlyZone2("CDTVA", "INTRACOMM", "CMBTVAINTRACOMM", output table ttCombo by-reference).
    delete object voSyspr.
    for each ttCombo
        where ttCombo.cNomCombo = "CMBTVAINTRACOMM":
        ttCombo.cLibelle = "T.V.A " + ttCombo.cLibelle.
    end.
    // TVA
    run compta/outilsTVA.p persistent set vhProcTVA.
    run getTokenInstance in vhProcTVA(mToken:JSessionId).
    run getCodeTVA in vhProcTVA(output table ttTVA).
    run destroy in vhProcTVA.
    for each ttTva by ttTva.cCodeTva:
        create ttCombo.
        assign
            viNumeroItem      = viNumeroItem + 1
            ttCombo.iSeqId    = viNumeroItem
            ttCombo.cNomCombo = "CMBTVA"
            ttCombo.cCode     = ttTVA.cCodeTva
            ttCombo.cLibelle  = ttTVA.cLibelleTVA
        .
    end.
    // Combo des rubriques de TVA
    viNumeroItem = 0.
    for each bxrbp no-lock
        where bxrbp.ntbai = pcNatureContrat
          and bxrbp.cdfam = {&FamilleRubqt-Taxe}
          and bxrbp.prg05 = {&TYPETACHE-TVABail}
          and bxrbp.nolib = 0:
        create ttCombo.
        assign
            viNumeroItem      = viNumeroItem + 1
            ttcombo.iSeqId    = viNumeroItem
            ttCombo.cNomCombo = "CMBRUBRIQUETVA"
            ttCombo.cCode     = string(bxrbp.norub)
        .
    end.
end procedure.

procedure setTvaBail:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (beBail.cls)
    ------------------------------------------------------------------------------*/
    define input parameter table for ttTacheTvaBail.

    define variable vhProcEquit as handle no-undo.
    define buffer vbttTacheTvaBail for ttTacheTvaBail.
    define buffer equit for equit.

    find first ttTacheTvaBail 
        where lookup(ttTacheTvaBail.CRUD, "C,U,D") > 0 no-error.
    if not available ttTacheTvaBail then return.

    if can-find(first tache no-lock
                where tache.tpcon = ttTacheTvaBail.cTypeContrat
                  and tache.nocon = ttTacheTvaBail.iNumeroContrat
                  and tache.tptac = {&TYPETACHE-TVABail}) and ttTacheTvaBail.CRUD = "C" then do:
        mError:createError({&error}, 1000410).          // demande d'initialisation d'une tache existante
        return.
    end.
    if can-find(first vbttTacheTvaBail
                where lookup(vbttTacheTvaBail.CRUD, "C,U,D") > 0
                  and vbttTacheTvaBail.iNumeroTache <> ttTacheTvaBail.iNumeroTache)
    then do:
        mError:createError({&error}, 1000589).          // Vous ne pouvez traiter en maj qu'un enregistrement à la fois
        return.
    end.

    run verZonSai.
    if not mError:erreur() then run majTacheTvaBail(ttTacheTvaBail.iNumeroContrat, ttTacheTvaBail.cTypeContrat).

    // On détoppe le premier avis d'échéance pour le retransferer (Utile pour la validation)
    // Dans tous les cas car on ne peut pas savoir simplement si qqchose à été modifié
    run bail/quittancement/equit_CRUD.p persistent set vhProcEquit.
    run getTokenInstance in vhProcEquit(mToken:JSessionId).
    for first equit no-lock
        where equit.noloc = ttTacheTvaBail.iNumeroContrat:
        create ttEquit.
        assign
            ttEquit.noint  = equit.noint
            ttEquit.noloc  = equit.noloc
            ttEquit.noqtt  = equit.noqtt
            ttEquit.fgtrf  = false
            ttEquit.rRowid      = rowid(equit)
            ttEquit.dtTimestamp = datetime(equit.dtmsy, equit.hemsy)
            ttEquit.CRUD        = 'U'
        .
    end.
    run setEquit in vhProcEquit(table ttEquit by-reference).
    run destroy in vhProcEquit.

end procedure.

procedure verZonSai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable voCollection as class collection no-undo.

    // Recherche de tous les paramètres dont on a besoin
    run chercheParametres(ttTacheTvaBail.iNumeroContrat, output voCollection).
    if not can-find(first ctrat no-lock
         where ctrat.tpcon = ttTacheTvaBail.cTypeContrat
           and ctrat.nocon = ttTacheTvaBail.iNumeroContrat) then mError:createError({&error}, 100057).
    else if ttTacheTvaBail.daActivation = ?       then mError:createError({&error}, 100299).
    else if f-isNull(ttTacheTvaBail.cCodeTauxTVA) then mError:createError({&error}, 101082).
    else if voCollection:getLogical('lGestionTvaEtranger') and ttTacheTvaBail.cCodeTauxTVAIntraComm = "00000"
                                                  then mError:createError({&error}, 1000593).
    else if ttTacheTvaBail.iNumeroRubriqueQtt = 0 then mError:createError({&error}, 101080).    // nath ???
    else if ttTacheTvaBail.iNumeroLibelleQtt  = 0 then mError:createError({&error}, 101081).    // nath ???
    else if ttTacheTvaBail.iNumeroRubriqueQtt = 772 and ttTacheTvaBail.cCodeTauxTVA <> {&codeTVA-1} //"00204"
                                                  then mError:createError({&error}, 104891).
end procedure.

procedure majTacheTvaBail private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcTypeContrat   as character no-undo.

    define variable vhProcTache as handle no-undo.
    define variable vhProcCttac as handle no-undo.
    define buffer cttac for cttac.

    empty temp-table ttCttac.
    // Préparatation des champs de travail
    assign
        ttTacheTvaBail.cTravailLbdiv  = substitute("&1#&2", ttTacheTvaBail.iNumeroRubriqueQtt, ttTacheTvaBail.iNumeroLibelleQtt)
        ttTacheTvaBail.cTravailLbdiv2 = substitute("&1#&2", ttTacheTvaBail.cCodeTauxTVAIntraComm, ttTacheTvaBail.cLibelleTVAIntraComm)
    .
    run tache/tache.p persistent set vhProcTache.
    run getTokenInstance in vhProcTache(mToken:JSessionId).
    run setTache in vhProcTache(table ttTacheTvaBail by-reference).
    run destroy in vhProcTache.
    if mError:erreur() then return.

    if can-find(first tache no-lock
                where tache.tpcon = pcTypeContrat
                  and tache.nocon = piNumeroContrat
                  and tache.tptac = {&TYPETACHE-TVABail})
    then do:
        if not can-find(first cttac no-lock
                        where cttac.tpcon = pcTypeContrat
                          and cttac.nocon = piNumeroContrat
                          and cttac.tptac = {&TYPETACHE-TVABail})
        then do:
            create ttCttac.
            assign
                ttCttac.tpcon = pcTypeContrat
                ttCttac.nocon = piNumeroContrat
                ttCttac.tptac = {&TYPETACHE-TVABail}
                ttCttac.CRUD  = "C"
            .
        end. 
    end.
    else for first cttac no-lock
        where cttac.tpcon = pcTypeContrat
          and cttac.nocon = piNumeroContrat
          and cttac.tptac = {&TYPETACHE-TVABail}:
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
    run adblib/cttac_CRUD.p persistent set vhProcCttac.
    run getTokenInstance in vhProcCttac(mToken:JSessionId).        
    run setCttac in vhProcCttac(table ttCttac by-reference).
    run destroy in vhProcCttac.
end procedure.

procedure initTvaBail:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (beBail.cls)
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcTypeContrat   as character no-undo.
    define output parameter table for ttTacheTvaBail.

    define buffer ctrat for ctrat. 

    if can-find(first tache no-lock
                where tache.tpcon = pcTypeContrat
                  and tache.nocon = piNumeroContrat
                  and tache.tptac = {&TYPETACHE-TVABail})
    then do:
        mError:createError({&error}, 1000410).          // demande d'initialisation d'une tache existante
        return.
    end.
    find first ctrat no-lock
        where ctrat.tpcon = pcTypeContrat
          and ctrat.nocon = piNumeroContrat no-error.
    if not available ctrat then do:
        mError:createError({&error}, 100057).
        return.
    end.
    run infoParDefautTvaBail(buffer ctrat).
end procedure.

procedure creationAutoTvaBail:
    /*------------------------------------------------------------------------------
    Purpose: creation automatique de la tache Tva Bail (Relocation ALLZ) 
    Notes  : service externe (beBail.cls)
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroContrat as int64     no-undo.
    define input  parameter pcTypeContrat   as character no-undo.
    define output parameter table for ttTacheTvaBail.

    define buffer ctrat for ctrat.

    if can-find(first tache no-lock
                where tache.tpcon = pcTypeContrat
                  and tache.nocon = piNumeroContrat
                  and tache.tptac = {&TYPETACHE-TVABail}) then do:
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
    run infoParDefautTvaBail(buffer ctrat).
    if mError:erreur() then return.

    run verZonSai.
    if not mError:erreur() then return.

    run majTache(piNumeroContrat, pcTypeContrat).
end procedure.

procedure infoParDefautTvaBail private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (beBail.cls)
    ------------------------------------------------------------------------------*/
    define parameter buffer ctrat for ctrat.

    define variable vdeTauxTva as decimal   no-undo.
    define variable vi         as integer   no-undo.
    define variable viItem     as integer   no-undo.
    define variable voSyspr      as class syspr              no-undo.
    define variable voCodeTVA    as class parametrageCodeTVA no-undo.
    define variable voCollection as class collection         no-undo.

    define buffer rubqt for rubqt.

    empty temp-table ttTacheTvaBail.
    if can-find(first tache no-lock
                where tache.tpcon = ctrat.tpcon
                  and tache.nocon = ctrat.nocon
                  and tache.tptac = {&TYPETACHE-TVABail}) then do:
        mError:createError({&error}, 1000410).                   // demande d'initialisation d'une tache inexistante
        return.
    end.
    create ttTacheTvaBail.
    assign
        ttTacheTvaBail.iNumeroTache          = 0
        ttTacheTvaBail.cTypeContrat          = ctrat.tpcon
        ttTacheTvaBail.iNumeroContrat        = ctrat.nocon
        ttTacheTvaBail.cTypeTache            = {&TYPETACHE-TVABail}
        ttTacheTvaBail.iChronoTache          = 0
        ttTacheTvaBail.daActivation          = ctrat.dtdeb
        ttTacheTvaBail.cCodeApplicableSur    = "00001"
        ttTacheTvaBail.cLibelleApplicableSur = outilTraduction:getLibelleParam("CDCAL", ttTacheTvaBail.cCodeApplicableSur)
        ttTacheTvaBail.lNonCommunique        = f-isNull(ttTacheTvaBail.cNumeroTvaIntraComm) // = "")
        ttTacheTvaBail.CRUD                  = 'C'
        voCodeTVA                            = new parametrageCodeTVA()
        voSyspr                              = new syspr()
        // Initialisation de la combo avec la code TVA par défaut
        ttTacheTvaBail.cCodeTauxTVA          = voCodeTVA:getCodeTVA()
        ttTacheTvaBail.cLibelleTauxTVA       = outilTraduction:getLibelleParam("CDTVA", ttTacheTvaBail.cCodeTauxTVA)
    .
    voSyspr:reload("CDTVA", ttTacheTvaBail.cCodeTauxTVA).
    if voSyspr:isDbParameter then do:
        vdeTauxTva = voSyspr:zone1.
boucleRubtva:
        do vi = 1 to num-entries({&ListeRubqtTVA-Calcul}):
            viItem = integer(entry(vi, {&ListeRubqtTVA-Calcul})).
            for first rubqt no-lock
                where rubqt.cdrub          = viItem
                  and rubqt.cdfam          = {&FamilleRubqt-Taxe}
                  and rubqt.cdsfa          = {&SousFamilleRubqt-ImpotsTaxesFiscaux}
                  and rubqt.cdgen          = {&GenreRubqt-Calcul}  // "00004" calcul
                  and decimal(rubqt.prg04) = vdeTauxTva * 100:
                ttTacheTvaBail.iNumeroRubriqueQtt = rubqt.cdrub.
                run recupLibelleDefautRubrique(
                    ttTacheTvaBail.iNumeroRubriqueQtt,
                    donneNatureContrat(ctrat.nocon, ctrat.tpcon),
                    output ttTacheTvaBail.iNumeroLibelleQtt,
                    output ttTacheTvaBail.cLibelleRubriqueQtt).
                leave boucleRubtva.
            end.
        end.
    end.
    delete object voCodeTVA.
    delete object voSyspr.
    if ttTacheTvaBail.iNumeroRubriqueQtt = ?
    then do:
        mError:createErrorGestion({&error}, 1000595, string(vdeTauxTva, ">>9.99")). // "Aucune rubrique associée au taux de TVA " + STRING(TxTvaRub, ">>9.99")
        return.
    end.

    // Recherche de tous les paramètres dont on a besoin
    run chercheParametres(ctrat.nocon, output voCollection).
    // Ajout Sy le 19/02/2009 : AGF RELOCATIONS : initialisation avec Fiche relocation
    if voCollection:getLogical('lExistenceLocation')
    then assign
        ttTacheTvaBail.cCodeApplicableSur    = voCollection:getCharacter('cFiscCodeCalcul')
        ttTacheTvaBail.cLibelleApplicableSur = outilTraduction:getLibelleParam("CDCAL", ttTacheTvaBail.cCodeApplicableSur)
    .
    // Valeur par défaut mode de calcul TVA =  Total Quittance pour les baux FL
    if voCollection:getLogical('lBailFournisseurLoyer')
    then assign
        ttTacheTvaBail.cCodeApplicableSur    = "00002"
        ttTacheTvaBail.cLibelleApplicableSur = outilTraduction:getLibelleParam("CDCAL", ttTacheTvaBail.cCodeApplicableSur)
    .
    // Champs de travail
    assign
        // Détermine si partie droite visible ou non pour la vue
        ttTacheTvaBail.lDispositifFiscal = voCollection:getLogical('lGestionTvaEtranger')
        ttTacheTvaBail.cTravailLbdiv     = substitute("&1#&2", ttTacheTvaBail.iNumeroRubriqueQtt, ttTacheTvaBail.iNumeroLibelleQtt)
        ttTacheTvaBail.cTravailLbdiv2    = ""
    .
end procedure.
