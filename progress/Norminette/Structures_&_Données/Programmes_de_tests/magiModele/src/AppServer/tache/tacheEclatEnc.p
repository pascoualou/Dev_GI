/*------------------------------------------------------------------------
File        : tacheEclatEnc.p
Purpose     : tache Eclatement des encaissements
Author(s)   : DM 20180124
Notes       : a partir de adb/tach/synmtfam.p
------------------------------------------------------------------------*/
{preprocesseur/type2tache.i}
{preprocesseur/type2contrat.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{tache/include/tacheEclatEnc.i}
{adblib/include/cttac.i}
{adblib/include/afamqtord.i}

procedure majEclatEnc private:
    /*------------------------------------------------------------------------------
    Purpose: maj tache et cttac
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer ttTacheEclatEnc for ttTacheEclatEnc.

    define variable vhProcAfamqtord as handle    no-undo.
    define variable vhProcCttac     as handle    no-undo.
    define variable vcCRUD          as character no-undo.
    define variable vrRowid         as rowid     no-undo.

    run adblib/cttac_CRUD.p persistent set vhProcCttac.
    run getTokenInstance in vhProcCttac(mToken:JSessionId).
    run adblib/afamqtord_CRUD.p persistent set vhProcAfamqtord.
    run getTokenInstance in vhProcAfamqtord(mToken:JSessionId).

    empty temp-table ttCttac.
    empty temp-table ttAfamqtord.

bloc :
    do :
        create ttCttac.
        assign
            ttCttac.tpcon       = {&TYPECONTRAT-mandat2Gerance}
            ttCttac.nocon       = ttTacheEclatEnc.iNumeroContrat
            ttCttac.tptac       = {&TYPETACHE-eclatementEncaissement}
            ttCttac.CRUD        = ttTacheEclatEnc.CRUD
            ttCttac.dtTimestamp = ttTacheEclatEnc.dtTimestamp
            ttCttac.rRowid      = ttTacheEclatEnc.rRowid
        .
        run setCttac in vhProcCttac (table ttCttac by-reference).
        if mError:erreur() then leave bloc.
        for each ttFamilleRubriqueQuitt where lookup(ttFamilleRubriqueQuitt.CRUD,"U,C") > 0 :
            assign 
                vcCRUD       = ttFamilleRubriqueQuitt.CRUD
                vrRowid      = ttFamilleRubriqueQuitt.rRowid
            .
            create ttAfamqtord.
            outils:copyValidLabeledField(buffer ttAfamqtord:handle, buffer ttFamilleRubriqueQuitt:handle, "", mtoken:cUser).
            assign
                ttAfamqtord.soc-cd = integer(mtoken:cRefPrincipale)
                ttAfamqtord.cdsfa  = 0
                ttAfamqtord.CRUD   = vcCRUD       // écrasé par copyvalidlabeledfield
                ttAfamqtord.rRowid = vrRowid      // écrasé par copyvalidlabeledfield
            .
        end.
        for each ttSousFamilleRubriqueQuitt where lookup(ttSousFamilleRubriqueQuitt.CRUD,"U,C") > 0 :
            assign 
                vcCRUD       = ttSousFamilleRubriqueQuitt.CRUD
                vrRowid      = ttSousFamilleRubriqueQuitt.rRowid
            .
            create ttAfamqtord.
            outils:copyValidLabeledField(buffer ttAfamqtord:handle, buffer ttSousFamilleRubriqueQuitt:handle, "", mtoken:cUser).
            assign
                ttAfamqtord.soc-cd  = integer(mtoken:cRefPrincipale)
                ttAfamqtord.CRUD    = vcCRUD       // écrasé par copyvalidlabeledfield
                ttAfamqtord.rRowid  = vrRowid      // écrasé par copyvalidlabeledfield
            .
        end.
        run setAfamqtord in vhProcAfamqtord(table ttAfamqtord by-reference).
        if mError:erreur() then leave bloc.
    end.
    run destroy in vhProcCttac.
    run destroy in vhProcAfamqtord.
end procedure.

procedure setEclatEnc:
    /*------------------------------------------------------------------------------
    Purpose: maj Tache Eclatement des encaissements
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter table for ttTacheEclatEnc.
    define input parameter table for ttFamilleRubriqueQuitt.
    define input parameter table for ttSousFamilleRubriqueQuitt.

    for first ttTacheEclatEnc where lookup(ttTacheEclatEnc.CRUD, "C,U") > 0:
        if not can-find(first ctrat no-lock
             where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
               and ctrat.nocon = ttTacheEclatEnc.iNumeroContrat)
        then do:
            mError:createError({&error}, 100057).
            return.
            
        end.
        run majEclatEnc (buffer ttTacheEclatEnc).
    end.
end procedure.

procedure chargeFamille private:
    /*------------------------------------------------------------------------------
    Purpose: Chargement du paramétrage des familles de rubriques éclatement des enciassements
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as int64   no-undo.

    define variable viNumeroMandatFam   as integer no-undo.
    define variable viNumeroMandatSsFam as integer no-undo.
    define variable viOrdre        as integer no-undo.

    define buffer afamqtord   for afamqtord.
    define buffer vbafamqtord for afamqtord.
    define buffer famqt     for famqt.
    define buffer vbfamqt   for famqt.

    empty temp-table ttFamilleRubriqueQuitt.
    empty temp-table ttSousFamilleRubriqueQuitt.

    if can-find(first afamqtord no-lock
        where afamqtord.soc-cd  = integer(mtoken:cRefPrincipale)
          and afamqtord.etab-cd = piNumeroMandat
          and afamqtord.cdsfa   = 0)
          then viNumeroMandatFam = piNumeroMandat.
          else viNumeroMandatFam = 0.
    viOrdre = 0.          
    for each afamqtord no-lock // Chargement des familles
        where afamqtord.soc-cd  = integer(mtoken:cRefPrincipale)
          and afamqtord.etab-cd = viNumeroMandatFam
          and afamqtord.cdfam  <> 0
          and afamqtord.cdsfa   = 0
      , first famqt no-lock where famqt.cdfam = afamqtord.cdfam and famqt.cdsfa = afamqtord.cdsfa by afamqtord.ordnum:
        viOrdre = viOrdre + 1.
        create ttFamilleRubriqueQuitt.
        outils:copyValidlabeledField(buffer afamqtord:handle, buffer ttFamilleRubriqueQuitt:handle).
        assign
            ttFamilleRubriqueQuitt.iNumeroContrat  = piNumeroMandat
            ttFamilleRubriqueQuitt.cLibelleFamille = outilTraduction:getLibelle(famqt.nome1)
            ttFamilleRubriqueQuitt.iOrdre          = viOrdre
            ttFamilleRubriqueQuitt.CRUD            = (if viNumeroMandatFam = 0 then "C" else "R") // C -> sera créé sur le mandat à la validation
        .    
        if can-find(first afamqtord no-lock
            where afamqtord.soc-cd  = integer(mtoken:cRefPrincipale)
              and afamqtord.etab-cd = piNumeroMandat
              and afamqtord.cdfam   = ttFamilleRubriqueQuitt.iCodeFamille 
              and afamqtord.cdsfa   <> 0)
              then viNumeroMandatSsFam = piNumeroMandat.
              else viNumeroMandatSsFam = 0.
        for each vbafamqtord no-lock // Chargement des sous-familles
            where vbafamqtord.soc-cd  = integer(mtoken:cRefPrincipale)
              and vbafamqtord.etab-cd = viNumeroMandatSsFam
              and vbafamqtord.cdfam   = ttFamilleRubriqueQuitt.iCodeFamille
              and vbafamqtord.cdsfa  <> 0
          , first vbfamqt no-lock where vbfamqt.cdfam = vbafamqtord.cdfam and vbfamqt.cdsfa = vbafamqtord.cdsfa 
            by vbafamqtord.ordnum :
            viOrdre = viOrdre + 1.
            create ttSousFamilleRubriqueQuitt.
            outils:copyValidlabeledField(buffer vbafamqtord:handle, buffer ttSousFamilleRubriqueQuitt:handle).
            assign
                ttSousFamilleRubriqueQuitt.iNumeroContrat      = piNumeroMandat
                ttSousFamilleRubriqueQuitt.cLibelleSousFamille = outilTraduction:getLibelle(vbfamqt.nome1)
                ttSousFamilleRubriqueQuitt.iOrdre              = viOrdre
                ttSousFamilleRubriqueQuitt.CRUD                = (if viNumeroMandatSsFam = 0 then "C" else "R") // C -> sera créé sur le mandat à la validation 
            .
        end.
    end.
    if not can-find(first ttFamilleRubriqueQuitt) then do :
        for each famqt no-lock
            where famqt.cdsfa = 0
             and famqt.cdfam <> 0 :
            if famqt.cdfam = 08 or famqt.cdfam = 09 then next. // On ignore les familles 08 & 09
            viOrdre = viOrdre + 1.
            create ttFamilleRubriqueQuitt.
            assign
                ttFamilleRubriqueQuitt.iNumeroContrat  = piNumeroMandat
                ttFamilleRubriqueQuitt.iOrdre          = viOrdre
                ttFamilleRubriqueQuitt.iCodeFamille    = famqt.cdfam
                ttFamilleRubriqueQuitt.cLibelleFamille = outilTraduction:getLibelle(famqt.nome1)
                ttFamilleRubriqueQuitt.CRUD            = "C" // C -> sera créé sur le mandat à la validation
            .
            for each vbfamqt no-lock
                where vbfamqt.cdfam = famqt.cdfam
                 and vbfamqt.cdsfa <> 0 :
                if vbfamqt.cdfam = 08 or vbfamqt.cdfam = 09 then next. // on ignore les familles 08 & 09
                viOrdre = viOrdre + 1.
                create ttSousFamilleRubriqueQuitt.
                assign
                    ttSousFamilleRubriqueQuitt.iNumeroContrat      = piNumeroMandat
                    ttSousFamilleRubriqueQuitt.iOrdre              = viOrdre
                    ttSousFamilleRubriqueQuitt.iCodeFamille        = vbfamqt.cdfam
                    ttSousFamilleRubriqueQuitt.iCodeSousFamille    = vbfamqt.cdsfa
                    ttSousFamilleRubriqueQuitt.cLibelleSousFamille = outilTraduction:getLibelle(vbfamqt.nome1)
                    ttSousFamilleRubriqueQuitt.CRUD                = "C" // C -> sera créé sur le mandat à la validation
                .
            end.
        end.
    end.
end procedure.

procedure initEclatEnc:
    /*------------------------------------------------------------------------------
    Purpose: Initialisation de la tache Eclatement encaissement
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat   as int64     no-undo.
    define input parameter pcTypeMandat     as character no-undo.
    define output parameter table for ttTacheEclatEnc.
    define output parameter table for ttFamilleRubriqueQuitt.
    define output parameter table for ttSousFamilleRubriqueQuitt.

    define buffer ctrat for ctrat.

    find first ctrat no-lock
         where ctrat.tpcon = pcTypeMandat
           and ctrat.nocon = piNumeroMandat no-error.
    if not available ctrat
    then do:
        mError:createError({&error}, 100057). // 100057 Numéro de Contrat introuvable.
        return.
        
    end.
    if can-find(last cttac no-lock
                where cttac.tpcon = pcTypeMandat
                  and cttac.nocon = piNumeroMandat
                  and cttac.tptac = {&TYPETACHE-ImpotRevenusFonciers})
    then do:
        mError:createError({&error}, 1000410). // 1000410 demande d'initialisation pour une tache deja existante
        return.
        
    end.
    create ttTacheEclatEnc.
    assign
        ttTacheEclatEnc.CRUD           = "C"
        ttTacheEclatEnc.iNumeroContrat = piNumeroMandat
    .
    run chargeFamille(piNumeroMandat).
end procedure.

procedure getEclatEnc:
    /*------------------------------------------------------------------------------
    Purpose: Extraction des familles de rubrique de la tache Eclatement des encaissements
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroMandat as int64     no-undo.
    define input  parameter pcTypeMandat   as character no-undo.
    define output parameter table for ttTacheEclatEnc.
    define output parameter table for ttFamilleRubriqueQuitt.
    define output parameter table for ttSousFamilleRubriqueQuitt.

    define variable vhProcCttac as handle no-undo.

    if not can-find(first ctrat no-lock
         where ctrat.tpcon = pcTypeMandat
           and ctrat.nocon = piNumeroMandat)
    then do:
        mError:createError({&error}, 100057). // 100057 Numéro de Contrat introuvable.
        return.
        
    end.
    empty temp-table ttCttac.
    empty temp-table ttTacheEclatEnc.
    run adblib/cttac_CRUD.p persistent set vhProcCttac.
    run getTokenInstance in vhProcCttac(mToken:JSessionId).
    run readCttac in vhProcCttac (pcTypeMandat, piNumeroMandat, {&TYPETACHE-eclatementEncaissement}, table ttCttac by-reference).
    for last ttCttac :
        create ttTacheEclatEnc.
        outils:copyValidlabeledField(buffer ttCttac:handle, buffer ttTacheEclatEnc:handle).
        ttTacheEclatEnc.rRowid = ttCttac.rRowid.
        run chargeFamille(piNumeroMandat).
    end.
    run destroy in vhProcCttac.
end procedure.