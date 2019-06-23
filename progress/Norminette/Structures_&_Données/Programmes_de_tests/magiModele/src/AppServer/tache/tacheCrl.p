/*------------------------------------------------------------------------
File        : tacheCrl.p
Purpose     : tache Contribution Annuelle sur les Revenus Locatifs
Author(s)   : GGA  -  2017/11/08
Notes       : a partir de adb/tach/SynmttTacheCrl.p adb/tach/prmmttac.p adb/tach/prmobstd.p
------------------------------------------------------------------------*/
{preprocesseur/nature2contrat.i}
{preprocesseur/type2tache.i}
{preprocesseur/type2gestion.i}
{preprocesseur/type2contrat.i}
{preprocesseur/codePeriode.i}
{preprocesseur/type2role.i}
{preprocesseur/codeReglement.i}

using parametre.syspg.syspg.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{adblib/include/cttac.i}
{tache/include/tacheCrl.i}
{application/include/combo.i}
{application/include/error.i}
{parametre/cabinet/gerance/include/paramCrl.i}

function f-isNull returns logical private(pcChaine as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    return pcChaine = ? or pcChaine = "".
end function.

procedure getCrl:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as int64     no-undo.
    define input parameter pcTypeMandat   as character no-undo.
    define output parameter table for ttTacheCrl.

    define buffer tache for tache.

    empty temp-table ttTacheCrl.
    if not can-find(first ctrat no-lock
         where ctrat.tpcon = pcTypeMandat
           and ctrat.nocon = piNumeroMandat)
    then do:
        mError:createError({&error}, 100057).
        return.
    end.
    for last tache no-lock
        where tache.tpcon = pcTypeMandat
          and tache.nocon = piNumeroMandat
          and tache.tptac = {&TYPETACHE-CRL}:
        create ttTacheCrl.
        outils:copyValidField(buffer tache:handle, buffer ttTacheCrl:handle).
        assign
            ttTacheCrl.lComptabilisation = (tache.cdreg = {&CODEREGLEMENT-oui})
            ttTacheCrl.cLibEncaissePar   = outilTraduction:getLibelleProgZone2("R_TAG", {&TYPETACHE-CRL}, tache.ntges)
            ttTacheCrl.cLibDeclaration   = outilTraduction:getLibelleProgZone2("R_TAD", {&TYPETACHE-CRL}, tache.tpges)
            ttTacheCrl.cLibPeriode       = outilTraduction:getLibelleProgZone2("R_TPR", {&TYPETACHE-CRL}, tache.pdges)
            ttTacheCrl.cLibTypeHonoraire = outilTraduction:getLibelleProgZone2("R_TTH", {&TYPETACHE-CRL}, tache.tphon, "c")
        .
    end.
end procedure.

procedure initComboCrl:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
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
    voSyspg:creationComboSysPgZonXX("R_TAG", "ENCAISSEPAR"  , "C", {&TYPETACHE-CRL}, output table ttCombo by-reference).
    voSyspg:creationComboSysPgZonXX("R_TAD", "DECLARATION"  , "C", {&TYPETACHE-CRL}, output table ttCombo by-reference).
    voSyspg:creationComboSysPgZonXX("R_TPR", "PERIODE"      , "C", {&TYPETACHE-CRL}, output table ttCombo by-reference).
    voSyspg:creationComboSysPgZonXX("R_TTH", "TYPEHONORAIRE", "C", {&TYPETACHE-CRL}, output table ttCombo by-reference).
    delete object voSyspg.
    for each ttCombo                                                //Période CRL toujours Fiscale (pas de maj possible)
        where ttCombo.cNomCombo = "PERIODE"
          and ttCombo.cCode <> {&PERIODICITEGESTION-fiscale}:
        delete ttCombo.
    end.
    run getComboHonoraire({&TYPETACHE-CRL}, "LISTEHONORAIRE").
end procedure.

procedure setCrl:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter table for ttTacheCrl.
    define input parameter table for ttError.

    define variable voSyspg as class syspg no-undo.
    define buffer vbttTacheCrl for ttTacheCrl.

    find first ttTacheCrl where lookup(ttTacheCrl.CRUD, "C,U,D") > 0 no-error.
    if not available ttTacheCrl then return. 
    if can-find (first vbttTacheCrl
                 where lookup(vbttTacheCrl.CRUD, "C,U,D") > 0
                   and vbttTacheCrl.iNumeroTache <> ttTacheCrl.iNumeroTache)
    then do:
        mError:createError({&error}, 1000589). //Vous ne pouvez traiter en maj qu'un enregistrement à la fois
        return.        
    end.        
    voSyspg = new syspg().        
    run verZonSai(buffer ttTacheCrl, voSyspg).
    delete object voSyspg.
    if not mError:erreur() then run majTacheEtContratCRL (ttTacheCrl.cTypeContrat, ttTacheCrl.iNumeroContrat).
  
end procedure.

procedure verZonSai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer ttTacheCrl for ttTacheCrl.
    define input parameter poSyspg as class syspg no-undo.

    define buffer ctrat for ctrat.
    
    find first ctrat no-lock
         where ctrat.tpcon = ttTacheCrl.cTypeContrat
           and ctrat.nocon = ttTacheCrl.iNumeroContrat no-error.
    if not available ctrat
    then do:
        mError:createError({&error}, 100057).
        return.
    end.
    if ttTacheCrl.daActivation = ?                                                       then mError:createError({&error}, 100299).
    else if ttTacheCrl.daActivation < ctrat.dtini                                        then mError:createErrorGestion({&error}, 100678, "").
         // type encaissé par le invalide
    else if not poSyspg:isParamExist("R_TAG", {&TYPETACHE-CRL}, ttTacheCrl.cEncaissePar) then mError:createError({&error}, 4000293).
         // type déclaration invalide
    else if not poSyspg:isParamExist("R_TAD", {&TYPETACHE-CRL}, ttTacheCrl.cDeclaration) then mError:createError({&error}, 1000458).
         // centre impôt doit être blanc si déclaration partielle
    else if ttTacheCrl.cDeclaration = {&TYPE2GESTION-Partielle}
        and ttTacheCrl.cCentreImpot > ""                                                 then mError:createError({&error}, 1000442).
    else if ttTacheCrl.cDeclaration = {&TYPE2GESTION-Totale}
        and f-isNull(ttTacheCrl.cCentreImpot)                                            then mError:createError({&error}, 100337).
         // Centre des impôts inconnu
    else if ttTacheCrl.cCentreImpot > ""
        and not can-find(first orsoc no-lock
                         where orsoc.tporg = "CDI"
                           and orsoc.ident = ttTacheCrl.cCentreImpot)                    then mError:createError({&error}, 1000443).
         // type période invalide
    else if not poSyspg:isParamExist("R_TPR", {&TYPETACHE-CRL}, ttTacheCrl.cPeriode)     then mError:createError({&error}, 1000456).
         // Comptabilisation doit être non si déclaration partielle
    else if ttTacheCrl.cDeclaration = {&TYPE2GESTION-Partielle}
        and ttTacheCrl.lComptabilisation                                                 then mError:createError({&error}, 1000472).
         // centre recette doit être blanc si règlement est à non
    else if ttTacheCrl.lComptabilisation = no and ttTacheCrl.cCentreRecette > ""         then mError:createError({&error}, 1000448).
    else if ttTacheCrl.lComptabilisation
        and f-isNull(ttTacheCrl.cCentreRecette)                                          then mError:createError({&error}, 100340).
    else if ttTacheCrl.cCentreRecette > ""
        and not can-find(first orsoc no-lock
                         where orsoc.tporg = "ODB"
                           and orsoc.ident = ttTacheCrl.cCentreRecette)                  then mError:createError({&error}, 1000449). //Centre recette inconnu
end procedure.

procedure majTacheEtContratCRL private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as int64     no-undo.

    define variable vhTache as handle no-undo.
    define variable vhCttac as handle no-undo.
    define buffer cttac for cttac.

    run tache/tache.p persistent set vhTache.
    run getTokenInstance in vhTache(mToken:JSessionId).
    run setTache in vhTache(table ttTacheCrl by-reference).
    run destroy in vhTache.
    if mError:erreur() then return.

    empty temp-table ttCttac.
    if can-find (first tache no-lock
                 where tache.tpcon = pcTypeContrat
                   and tache.nocon = piNumeroContrat
                   and tache.tptac = {&TYPETACHE-CRL})
    then do:
        if not can-find (first cttac no-lock
                         where cttac.tpcon = pcTypeContrat
                           and cttac.nocon = piNumeroContrat
                           and cttac.tptac = {&TYPETACHE-CRL})
        then do:
            create ttCttac.
            assign
                ttCttac.tpcon = pcTypeContrat
                ttCttac.nocon = piNumeroContrat
                ttCttac.tptac = {&TYPETACHE-CRL}
                ttCttac.CRUD  = "C"
            .
        end. 
    end.
    else for first cttac no-lock
             where cttac.tpcon = pcTypeContrat
               and cttac.nocon = piNumeroContrat
               and cttac.tptac = {&TYPETACHE-CRL}:
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

procedure initCrl:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroMandat as int64     no-undo.
    define input  parameter pcTypeMandat   as character no-undo.
    define output parameter table for ttTacheCrl.

    define variable vhproc  as handle      no-undo.
    define variable voSyspg as class syspg no-undo.

    define buffer ctrat  for ctrat.

    empty temp-table ttTacheCrl.
    find first ctrat no-lock
         where ctrat.tpcon = pcTypeMandat
           and ctrat.nocon = piNumeroMandat no-error.
    if not available ctrat
    then do:
        mError:createError({&error}, 100057).
        return.
    end.
    if can-find(first tache no-lock
                where tache.tpcon = pcTypeMandat
                  and tache.nocon = piNumeroMandat
                  and tache.tptac = {&TYPETACHE-CRL})
    then do:
        mError:createError({&error}, 1000410).                   // demande d'initialisation d'une tache inexistante
        return.
    end.
    run parametre/cabinet/gerance/defautMandatGerance.p persistent set vhproc.
    run getTokenInstance in vhproc(mToken:JSessionId).
    run getParamCrl in vhproc (output table ttParamCrl by-reference).
    run destroy in vhproc.
    create ttTacheCrl.
    assign
        ttTacheCrl.iNumeroTache   = 0
        ttTacheCrl.cTypeContrat   = pcTypeMandat
        ttTacheCrl.iNumeroContrat = piNumeroMandat
        ttTacheCrl.cTypeTache     = {&TYPETACHE-CRL}
        ttTacheCrl.iChronoTache   = 0
        ttTacheCrl.daActivation   = ctrat.dtdeb
        ttTacheCrl.CRUD           = 'C'
    .
    for first ttParamCrl:
        assign
            ttTacheCrl.cEncaissePar      = ttParamCrl.cCodeEncaissement
            ttTacheCrl.cLibEncaissePar   = outilTraduction:getLibelleProgZone2("R_TAG", {&TYPETACHE-CRL}, ttParamCrl.cCodeEncaissement)
            ttTacheCrl.cDeclaration      = ttParamCrl.cCodeDeclaration
            ttTacheCrl.cLibDeclaration   = outilTraduction:getLibelleProgZone2("R_TAD", {&TYPETACHE-CRL}, ttParamCrl.cCodeDeclaration)
            ttTacheCrl.cPeriode          = ttParamCrl.cCodePeriode
            ttTacheCrl.cLibPeriode       = outilTraduction:getLibelleProgZone2("R_TPR", {&TYPETACHE-CRL}, ttParamCrl.cCodePeriode)
            ttTacheCrl.lComptabilisation = ttParamCrl.lComptabilisation
            ttTacheCrl.cCodeHonoraire    = ttParamCrl.cCodeHonoraire
        .
    end.
    voSyspg = new syspg().
    voSyspg:reloadZone1("R_TTH", {&TYPETACHE-CRL}).
    if voSyspg:isDbParameter
    then assign
        ttTacheCrl.cTypeHonoraire    = voSyspg:zone2
        ttTacheCrl.cLibTypeHonoraire = outilTraduction:getLibelleProgZone2("R_TTH", {&TYPETACHE-CRL}, voSyspg:zone2, "c")
    .
end procedure.

procedure getComboHonoraire private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeTache as character no-undo.
    define input parameter pcNomCombo  as character no-undo.

    define variable vhHonor       as handle no-undo.
    define buffer sys_pg for sys_pg.

    for first sys_pg no-lock
        where sys_pg.tppar = "R_TTH"
          and sys_pg.zone1 = pcTypeTache
          and sys_pg.zone2 > "":
        run tache/baremeHonoraire.p persistent set vhHonor.
        run getTokenInstance in vhHonor(mToken:JSessionId).
        run createComboBaremeHonoraire in vhHonor(sys_pg.zone2, pcNomCombo, output table ttCombo by-reference).
        run destroy in vhHonor.
    end.
end procedure.
