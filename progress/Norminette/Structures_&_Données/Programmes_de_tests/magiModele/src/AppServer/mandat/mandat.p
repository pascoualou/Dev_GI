/*------------------------------------------------------------------------
File        : mandat.p
Purpose     :
Author(s)   : KANTENA - 2016/08/04
derniere revue: 2018/04/18 - phm. KO
            pour un déploiement, enlever les todo
------------------------------------------------------------------------*/
{preprocesseur/nature2cle.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/nature2voie.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2role.i}
{preprocesseur/type2tache.i}
{preprocesseur/type2adresse.i}
{preprocesseur/niveauErreur.i}

using parametre.pclie.pclie.
using parametre.syspg.syspg.
using parametre.pclie.parametrageNumeroRegistreMandat.
using parametre.pclie.parametrageFournisseurLoyer.
using parametre.syspg.parametrageNatureContrat.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{mandat/include/clemi.i}
{mandat/include/mandat.i}
{mandat/include/listeMandat.i}
{application/include/error.i}
{adb/include/majCleAlphaGerance.i}        // procedure majClger
{adblib/include/intnt.i}
{adblib/include/ctrat.i}

function lancementPgm return handle private(pcProgramme as character, pcProcedure as character, table-handle phTable):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhProc as handle no-undo.

    run value(pcProgramme) persistent set vhProc.
    run getTokenInstance in vhProc(mToken:JSessionId).
    run value(pcProcedure) in vhProc(table-handle phTable by-reference).
    run destroy in vhProc.

end function.

function creationTache return handle private(pcTypeContrat as character, piNumeroContrat as int64):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhProc as handle no-undo.

    run mandat/outilMandat.p persistent set vhProc.
    run getTokenInstance in vhProc (mToken:JSessionId).
    run creationAutoTache in vhProc(pcTypeContrat, piNumeroContrat).
    run destroy in vhProc.

end function.

function numeroImmeuble return int64 private(piNumeroContrat as int64, pcTypeContrat as character):
    /*------------------------------------------------------------------------------
    Purpose: recherche immeuble du Contrat
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer intnt for intnt.

    for first intnt no-lock
        where intnt.tpcon = pcTypeContrat
          and intnt.nocon = piNumeroContrat
          and intnt.tpidt = {&TYPEBIEN-immeuble}:
        return intnt.noidt.
    end.
    return 0.

end function.

procedure getMandat:
    /*------------------------------------------------------------------------------
    Purpose: Recherche des infos contrats : mandat de gérance, de syndic et mandat de
    Notes  : service utilisé par baAutoCompleteGeneric.cls, beMandatCommercialisation.cls, ...
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeContrat   as character no-undo.
    define input  parameter piNumeroContrat as int64     no-undo.
    define output parameter table-handle phttMandat.

    define variable vhbttMandat as handle no-undo.
    define buffer ctrat for ctrat.

    vhbttMandat = phttMandat:default-buffer-handle.
    for each ctrat no-lock
        where ctrat.tpcon = pcTypeContrat
          and ctrat.nocon = piNumeroContrat:
        vhbttMandat:buffer-create().
        assign
            vhbttMandat::CRUD                       = 'R'
            vhbttMandat::cCodeTypeContrat           = ctrat.tpcon
            vhbttMandat::iNumeroContrat             = ctrat.nocon
            vhbttMandat::cLibelleTypeContrat        = outilTraduction:getLibelleProg("O_CLC", ctrat.tpcon)
            vhbttMandat::cCodeNatureContrat         = ctrat.ntcon
            vhbttMandat::cLibelleNatureContrat      = outilTraduction:getLibelleProg("O_COT", ctrat.ntcon)
            vhbttMandat::cCodeDevise                = ctrat.cddev
            vhbttMandat::cCodeStatut                = ctrat.cdstatut
           // vhbttMandat::cLibelleStatut             = ''
            vhbttMandat::daDateDebut                = ctrat.dtdeb
            vhbttMandat::daDateFin                  = ctrat.dtfin
            vhbttMandat::daDateInitiale             = ctrat.dtini
            vhbttMandat::daDateLimite               = ctrat.dtmax
            vhbttMandat::daResiliation              = ctrat.dtree
            vhbttMandat::daSignature                = ctrat.dtsig
            vhbttMandat::daDateValidation           = ctrat.dtvaldef
            vhbttMandat::iNbRenouvellementMax       = ctrat.nbrenmax
            vhbttMandat::cNumeroReelRegistre        = ctrat.noree
            vhbttMandat::cCodeTypeRenouvellement    = ctrat.tpren
//          vhbttMandat::cLibelleTypeRenouvellement = outilTraduction:getLibelleParam("TPREN", ctrat.tpren) /* libellé renouvellement */
            vhbttMandat::dtTimestamp                = datetime(ctrat.dtmsy, ctrat.hemsy)
            vhbttMandat::rRowid                     = rowid(ctrat)
        .
    end.

end procedure.

procedure getListeMandat:
    /*------------------------------------------------------------------------------
    Purpose: liste des contrats
    Notes  : service utilisé par baMandatGerance.cls
             a partir de adb/cont/rechct00.p, adb/cont/gesrqmdt.p, adb/cont/exerqctt.p
             comme dans l'existant lecture des tables en fonction des criteres de selection.
             si selection sur immeuble et mandant:
                  lecture table intnt avec tpidt = type bien immeuble, table intnt avec tpidt type role mandant, table ctrat
             si selection sur immeuble mais pas sur mandant:
                  lecture table intnt avec tpidt = type bien immeuble, table ctrat
             si selection sur mandant mais pas sur immeuble:
                  lecture table intnt avec tpidt = type role mandant, table ctrat
             si pas de selection sur immeuble et pas de selection sur mandant:
                  lecture table ctrat
    ------------------------------------------------------------------------------*/
    define input parameter poCollection as collection no-undo.
    define output parameter table for ttListeMandat.

    define variable viNumeroMandat          as integer   no-undo.
    define variable viNumeroMandatDeb       as integer   no-undo.
    define variable viNumeroMandatFin       as integer   no-undo.
    define variable viNumeroMandant         as integer   no-undo.
    define variable viNumeroMandantDeb      as integer   no-undo.
    define variable viNumeroMandantFin      as integer   no-undo.
    define variable viNumeroImmeuble        as integer   no-undo.
    define variable viNumeroImmeubleDeb     as integer   no-undo.
    define variable viNumeroImmeubleFin     as integer   no-undo.
    define variable vcNomMandant            as character no-undo.
    define variable vcNatureMandat          as character no-undo.
    define variable vlActif                 as logical   no-undo.
    define variable vlInactif               as logical   no-undo.
    define variable vlProvisoire            as logical   no-undo.
    define variable vlSelSurEnCoursCreation as logical   no-undo.
    define variable vlStatutEnCoursCreation as logical   no-undo.
    define variable vcWhereClause           as character no-undo.
    define variable vcForClause             as character no-undo.
    define variable vcValQuery              as character no-undo.
    define variable vhQuery                 as handle    no-undo.
    define variable vcClauseContrat         as character no-undo.

    {&_proparse_ prolint-nowarn(bufdbproc)}    // prolint ne voit pas l'utilisation vhQuery:add-buffer(buffer vbintnt:handle).
    define buffer vbintnt  for intnt.
    define buffer vb2intnt for intnt.
    define buffer ctrat    for ctrat.
    define buffer vbctrat  for ctrat.
    define buffer ladrs    for ladrs.
    define buffer adres    for adres.

    assign
        viNumeroMandat          = poCollection:getInteger ("iNumeroMandat")
        viNumeroMandatDeb       = poCollection:getInteger ("iNumeroMandatDeb")
        viNumeroMandatFin       = poCollection:getInteger ("iNumeroMandatFin")
        viNumeroMandant         = poCollection:getInteger ("iNumeroMandant")
        viNumeroMandantDeb      = poCollection:getInteger ("iNumeroMandantDeb")
        viNumeroMandantFin      = poCollection:getInteger ("iNumeroMandantFin")
        viNumeroImmeuble        = poCollection:getInteger ("iNumeroImmeuble")
        viNumeroImmeubleDeb     = poCollection:getInteger ("iNumeroImmeubleDeb")
        viNumeroImmeubleFin     = poCollection:getInteger ("iNumeroImmeubleFin")
        vcNomMandant            = poCollection:getCharacter("cNomMandant")
        vcNatureMandat          = poCollection:getCharacter("cNatureMandat")
        vlActif                 = poCollection:getLogical ("lActif")
        vlInactif               = poCollection:getLogical ("lInactif")
        vlProvisoire            = poCollection:getLogical ("lProvisoire")
        vlSelSurEnCoursCreation = poCollection:getLogical ("lEnCoursCreation")
    .
    {&_proparse_ prolint-nowarn(when)}
    assign
        viNumeroMandat      = 0                when viNumeroMandat = ?
        viNumeroMandatDeb   = viNumeroMandat   when viNumeroMandat > 0
        viNumeroMandatFin   = viNumeroMandat   when viNumeroMandat > 0
        viNumeroMandant     = 0                when viNumeroMandant = ?
        viNumeroMandantDeb  = viNumeroMandant  when viNumeroMandant > 0
        viNumeroMandantFin  = viNumeroMandant  when viNumeroMandant > 0
        viNumeroImmeuble    = 0                when viNumeroImmeuble = ?
        viNumeroImmeubleDeb = viNumeroImmeuble when viNumeroImmeuble > 0
        viNumeroImmeubleFin = viNumeroImmeuble when viNumeroImmeuble > 0
    .
    {&_proparse_ prolint-nowarn(when)}
    assign
        viNumeroMandatDeb   = 0 when viNumeroMandatDeb = ?
        viNumeroMandantDeb  = 0 when viNumeroMandantDeb = ?
        viNumeroImmeubleDeb = 0 when viNumeroImmeubleDeb = ?
    .
    {&_proparse_ prolint-nowarn(when)}
    assign
        viNumeroMandatFin   = 0     when (viNumeroMandatFin = ?   or viNumeroMandatFin = 0)   and viNumeroMandatDeb = 0
        viNumeroMandatFin   = 99999 when (viNumeroMandatFin = ?   or viNumeroMandatFin = 0)   and viNumeroMandatDeb > 0
        viNumeroMandantFin  = 0     when (viNumeroMandantFin = ?  or viNumeroMandantFin = 0)  and viNumeroMandantDeb = 0
        viNumeroMandantFin  = 99999 when (viNumeroMandantFin = ?  or viNumeroMandantFin = 0)  and viNumeroMandantDeb > 0
        viNumeroImmeubleFin = 0     when (viNumeroImmeubleFin = ? or viNumeroImmeubleFin = 0) and viNumeroImmeubleDeb = 0
        viNumeroImmeubleFin = 99999 when (viNumeroImmeubleFin = ? or viNumeroImmeubleFin = 0) and viNumeroImmeubleDeb > 0
    .
    create query vhQuery.
    if viNumeroImmeubleDeb <> 0 or viNumeroImmeubleFin <> 0
    then do:
        assign
            vcWhereClause   = trim(substitute('&1&2&3&4',
                                        if viNumeroImmeubleDeb > 0 then ' and intnt.noidt >= ' + trim(string(viNumeroImmeubleDeb)) else '',
                                        if viNumeroImmeubleFin > 0 then ' and intnt.noidt <= ' + trim(string(viNumeroImmeubleFin)) else '',
                                        if viNumeroMandatDeb > 0   then ' and intnt.nocon >= ' + trim(string(viNumeroMandatDeb))   else '',
                                        if viNumeroMandatFin > 0   then ' and intnt.nocon <= ' + trim(string(viNumeroMandatFin))   else ''))
            vcValQuery      = substitute('for each intnt no-lock where intnt.tpidt = "&1" and intnt.tpcon = "&2" &3',
                                         {&TYPEBIEN-immeuble}, {&TYPECONTRAT-mandat2Gerance}, vcWhereClause)
            vcClauseContrat = 'intnt.nocon'
        .
        vhQuery:add-buffer(buffer intnt:handle).
    end.

    if viNumeroMandantDeb <> 0 or viNumeroMandantFin <> 0 then do:
        assign
            vcWhereClause   = trim(substitute('&1&2&3&4&5',
                                            if viNumeroMandantDeb > 0  then ' and vbintnt.noidt >= ' + trim(string(viNumeroMandantDeb)) else '',
                                            if viNumeroMandantFin > 0  then ' and vbintnt.noidt <= ' + trim(string(viNumeroMandantFin)) else '',
                                            if vcClauseContrat    > '' then ' and vbintnt.nocon = '  + trim(vcClauseContrat)            else '',
                                            if viNumeroMandatDeb  > 0  and vcClauseContrat = ''
                                                                       then ' and vbintnt.nocon >= ' + trim(string(viNumeroMandatDeb))  else '',
                                            if viNumeroMandatFin  > 0  and vcClauseContrat = ''
                                                                       then ' and vbintnt.nocon <= ' + trim(string(viNumeroMandatFin))  else ''))
            vcForClause     = if vcValQuery > '' then ', each' else 'for each'
            vcValQuery      = substitute('&1 &2 vbintnt no-lock where vbintnt.tpidt = "&3" and vbintnt.tpcon = "&4" &5 ',
                                         vcValQuery, vcForClause, {&TYPEROLE-mandant}, {&TYPECONTRAT-mandat2Gerance}, vcWhereClause)
            vcClauseContrat = if vcClauseContrat > "" then vcClauseContrat else 'vbintnt.nocon'
        .
        vhQuery:add-buffer(buffer vbintnt:handle).
    end.
    assign
        vcForClause   = if vcValQuery > "" then ", first" else "for each"
        vcWhereClause = trim(substitute('&1&2&3&4&5',
                                        if vcClauseContrat > ''  then ' and ctrat.nocon = '       + trim(vcClauseContrat)           else "",
                                        if viNumeroMandatDeb > 0 and vcClauseContrat = ''
                                                                 then ' and ctrat.nocon >= '      + trim(string(viNumeroMandatDeb)) else "",
                                        if viNumeroMandatFin > 0 and vcClauseContrat = ''
                                                                 then ' and ctrat.nocon <= '      + trim(string(viNumeroMandatFin)) else "",
                                        if vcNomMandant > ""     then substitute(' and ctrat.lbnom begins "&1"',      trim(vcNomMandant))   else "",
                                        if vcNatureMandat > ""   then substitute(' and lookup(ctrat.ntcon,"&1") > 0', trim(vcNatureMandat)) else ""))
        vcValQuery    = substitute('&1&2 ctrat no-lock where ctrat.tpcon = "&3" &4',
                                   vcValQuery, vcForClause, {&TYPECONTRAT-mandat2Gerance}, vcWhereClause)
    .
    vhQuery:add-buffer(buffer ctrat:handle).
    vhQuery:query-prepare(vcValQuery).
    vhQuery:query-open().
boucle:
    repeat:
        vhQuery:get-next().
        if vhQuery:query-off-end then leave boucle.

        //contrat a valider (en cours de creation) si provisoire (exclusion des contrats crees depuis la mutation)
        if ctrat.fgprov
        and not can-find(first vbctrat no-lock
                         where vbctrat.tpcon     = {&TYPECONTRAT-mutationGerance}
                           and vbctrat.nomdt-ach = ctrat.nocon)
        then vlStatutEnCoursCreation = yes.
        else vlStatutEnCoursCreation = no.

        /* si selection sur en cours de creation demandee, on ne tient pas compte des selections
        vlProvisoire, vlActif et vlInactif */
        if vlSelSurEnCoursCreation
        then do:
            if not vlStatutEnCoursCreation then next boucle.
        end.
        else do:
            if (vlProvisoire = no and ctrat.fgprov = yes)
            or (vlActif = no and ctrat.dtree = ?)
            or (vlInactif = no and ctrat.dtree <> ?) then next boucle.
        end.

        create ttListeMandat.
        assign
            ttListeMandat.cCodeTypeContrat      = ctrat.tpcon
            ttListeMandat.cLibelleTypeContrat   = outilTraduction:getLibelleProg("O_CLC", ctrat.tpcon)
            ttListeMandat.iNumeroContrat        = ctrat.nocon
            ttListeMandat.cCodeNatureContrat    = ctrat.ntcon
            ttListeMandat.cLibelleNatureContrat = outilTraduction:getLibelleProg("O_COT", ctrat.ntcon)
            ttListeMandat.iNumeroMandant        = ctrat.norol
            ttListeMandat.cNomMandant           = ctrat.lbnom
            ttListeMandat.cNomCompletMandant    = ctrat.lnom2
            ttListeMandat.lEnCoursCreation      = vlStatutEnCoursCreation
            ttListeMandat.CRUD                  = 'R'
            ttListeMandat.dtTimestamp           = datetime(ctrat.dtmsy, ctrat.hemsy)
            ttListeMandat.rRowid                = rowid(ctrat)
        .
        for first vb2intnt no-lock                                                     // si pas de selection sur immeuble la table n'est pas lu
            where vb2intnt.tpidt = {&TYPEBIEN-immeuble}
              and vb2intnt.tpcon = ctrat.tpcon
              and vb2intnt.nocon = ctrat.nocon:
             ttListeMandat.iNumeroImmeuble = vb2intnt.noidt.
        end.
        for first ladrs no-lock                                                        // adresse immeuble
            where ladrs.tpidt = {&TYPEBIEN-immeuble}
              and ladrs.noidt = ttListeMandat.iNumeroImmeuble
              and ladrs.tpadr = {&TYPEADRESSE-Principale}
          , first adres no-lock
            where adres.noadr = ladrs.noadr:
            assign
                ttListeMandat.cCodePostal     = trim(adres.cdpos)
                ttListeMandat.cVille          = trim(adres.lbvil)
                ttListeMandat.cAdresse        = outilFormatage:formatageAdresse(buffer ladrs, buffer adres, 0 /* ni ville, ni pays */)
                ttListeMandat.cLibelleAdresse = outilFormatage:formatageAdresse(buffer ladrs, buffer adres, 3 /* ville et pays */)
            .
        end.
    end.
    vhQuery:query-close().
    delete object vhQuery.
    error-status:error = false no-error.   // reset error-status:error
    return.                                // reset return-value

end procedure.

function f_existe_mandat returns logical (piReference as integer, piprofil as integer) :
    /*------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------*/
    return can-find(first ietab no-lock where ietab.soc-cd = piReference and ietab.profil-cd = piprofil and ietab.gest-cle > "").

end function.

procedure createMandat:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table for ttMandat.

    define variable vrRowidTtMandat as rowid no-undo.
    define variable voSyspg as class syspg no-undo.
    define variable vcTypeMandat            as character no-undo.
    define variable viNumeroMandat          as int64     no-undo.
    define variable vhCtrat                 as handle    no-undo.
    define variable vhContractantContrat    as handle    no-undo.
    define variable vhControleNumeroContrat as handle    no-undo.
    define variable vhObjet                 as handle    no-undo.

    find first ttMandat where ttMandat.CRUD = "C" no-error.
    if not available ttMandat
    then do:
        mError:createError({&error}, 1000711).       //Pas d'enregistrement de demande de création de contrat
        return.
    end.
    assign
        vcTypeMandat   = ttMandat.cCodeTypeContrat
        viNumeroMandat = ttMandat.iNumeroContrat
        voSyspg = new syspg()
    .
    if not voSyspg:isParamExist("R_CRC", ttMandat.cCodeTypeContrat, ttMandat.cCodeNatureContrat)
    then do:
        mError:createError({&error}, 1000611, ttMandat.cCodeNatureContrat).   //nature de contrat &1 inconnue
        return.
    end.
    delete object voSyspg.
    if ttMandat.lProvisoire = false then do:
        mError:createError({&error}, 1000712).               //Le mandat doit être provisoire
        return.
    end.

    /* controle numero de mandat saisi */
    run mandat/controleNumeroContrat.p persistent set vhControleNumeroContrat.
    run getTokenInstance in vhControleNumeroContrat(mToken:JSessionId).
    run controleNumeroContrat in vhControleNumeroContrat (ttMandat.cCodeTypeContrat, ttMandat.cCodeNatureContrat, ttMandat.iNumeroContrat).
    run destroy in vhControleNumeroContrat.
    if mError:erreur() then return.

    /* creation contrat */
    vrRowidTtMandat = rowid(ttMandat).
    run adblib/ctrat_CRUD.p persistent set vhCtrat.
    run getTokenInstance in vhCtrat(mToken:JSessionId).
    run setCtrat in vhCtrat(table ttMandat by-reference).
    if mError:erreur() then do:
        run destroy in vhCtrat.
        return.
    end.

    /* creation contractant si contractant par defaut parametre */
    run mandat/contractantContrat.p persistent set vhContractantContrat.
    run getTokenInstance in vhContractantContrat(mToken:JSessionId).
    run creationContrat in vhContractantContrat(vcTypeMandat, viNumeroMandat).
    run destroy in vhContractantContrat.
    if mError:erreur() then return.

    /* apres la creation contractant par defaut on recherche si ville associe pour maj lieu de signature */
    find first ttMandat where rowid(ttMandat) = vrRowidTtMandat.
    run mandat/objetMandat.p persistent set vhObjet.
    run getTokenInstance in vhObjet(mToken:JSessionId).
    run RecVilCab in vhObjet(buffer ttMandat).
    run destroy in vhObjet.
    if ttMandat.cLieuSignature <> ?
    then do:
        ttMandat.CRUD = "U".
        run setCtrat in vhCtrat(table ttMandat by-reference).
    end.
    run destroy in vhCtrat.

end procedure.

procedure initMandat:
    /*------------------------------------------------------------------------------
    Purpose: preparation creation mandat
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeMandat   as character no-undo.
    define input parameter pcNatureMandat as character no-undo.
    define output parameter table for ttMandat.

    define variable voSyspg as class syspg no-undo.
    define variable vhProc        as handle    no-undo.
    define variable viNoDocSui    as integer   no-undo.
    define variable viNoConSui    as int64     no-undo.
    define variable vcTypeContrat as character no-undo.

    voSyspg = new syspg().
    if not voSyspg:isParamExist("R_CRC", pcTypeMandat, pcNatureMandat)
    then do:
        mError:createError({&error}, 1000611, pcNatureMandat).   //nature de contrat &1 inconnue
        return.
    end.
    delete object voSyspg.

    /* Recherche du numero de contrat à créer */
    vcTypeContrat = if pcNatureMandat = {&NATURECONTRAT-mandatGestionRevenusGarantis}
                    then substitute('&1@&2', {&TYPECONTRAT-mandat2Gerance}, {&NATURECONTRAT-mandatGestionRevenusGarantis})   //Nouvelle nature de contrat : mandat avec garantie locative
                    else pcTypeMandat.
    run adblib/ctrat_CRUD.p persistent set vhProc.
    run getTokenInstance in vhProc(mToken:JSessionId).
    run getNextContrat in vhProc(vcTypeContrat, 0, 0, output viNoDocSui, output viNoConSui).
    run destroy in vhProc.
    if mError:erreur() then return.

    empty temp-table ttMandat.
    create ttMandat.
    assign
        ttMandat.cCodeTypeContrat      = pcTypeMandat
        ttMandat.cLibelleTypeContrat   = outilTraduction:getLibelleProg("O_CLC", pcTypeMandat)
        ttMandat.cCodeNatureContrat    = pcNatureMandat
        ttMandat.cLibelleNatureContrat = outilTraduction:getLibelleProg("O_COT", pcNatureMandat)
        ttMandat.iNumeroContrat        = viNoConSui
        ttMandat.lProvisoire           = true
        ttMandat.CRUD                  = "C"
    .
    //recherche des parametres par defaut a la creation d'un mandat
    run mandat/objetMandat.p persistent set vhProc.
    run getTokenInstance in vhProc(mToken:JSessionId).
    run initObjet in vhProc(buffer ttMandat).
    run destroy in vhProc.

end procedure.

procedure controleMandat:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeMandat   as character no-undo.
    define input parameter piNumeroMandat as int64     no-undo.

    run controleMandatPrivate(pcTypeMandat, piNumeroMandat).

end procedure.

procedure controleMandatPrivate private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeMandat   as character no-undo.
    define input parameter piNumeroMandat as int64     no-undo.

    define variable vhProc as handle no-undo.
    define variable voSauveHandleError as class errorHandler no-undo.

    define buffer ctrat for ctrat.

    voSauveHandleError = merror.
    find first ctrat no-lock
         where ctrat.tpcon = pcTypeMandat
           and ctrat.nocon = piNumeroMandat no-error.
    if not available ctrat then do:
        mError:createError({&error}, 100057).
        return.
    end.
    if ctrat.fgprov = no then do:
        mError:createError({&error}, 1000712).           //Le mandat doit être provisoire
        return.
    end.

    mError = new outils.errorHandler().
    run mandat/contractantContrat.p persistent set vhProc.
    run getTokenInstance in vhProc(mToken:JSessionId).
    run controleContractant in vhProc(pcTypeMandat, piNumeroMandat).
    run getErrors in vhProc(output table ttError).
    run destroy in vhProc.
    delete object mError.
    for each ttError:
        voSauveHandleError:copyError(ttError.horodate,
                                     ttError.iType,
                                     ttError.iErrorId,
                                     ttError.cError,
                                     ttError.lYesNo,
                                     ttError.cComplement,
                                     ttError.rRowid).
    end.

    mError = new outils.errorHandler().
    run mandat/objetMandat.p persistent set vhProc.
    run getTokenInstance in vhProc(mToken:JSessionId).
    run controleObjet in vhProc(pcTypeMandat, piNumeroMandat).
    run getErrors in vhProc(output table ttError).
    run destroy in vhProc.
    delete object mError.
    for each ttError:
        voSauveHandleError:copyError(ttError.horodate,
                                     ttError.iType,
                                     ttError.iErrorId,
                                     ttError.cError,
                                     ttError.lYesNo,
                                     ttError.cComplement,
                                     ttError.rRowid).
    end.

    mError = new outils.errorHandler().
    run mandat/bienContrat.p persistent set vhProc.
    run getTokenInstance in vhProc(mToken:JSessionId).
    run controleBien in vhProc(pcTypeMandat, piNumeroMandat).
    run getErrors in vhProc(output table ttError).
    run destroy in vhProc.
    delete object mError.
    for each ttError:
        voSauveHandleError:copyError(ttError.horodate,
                                     ttError.iType,
                                     ttError.iErrorId,
                                     ttError.cError,
                                     ttError.lYesNo,
                                     ttError.cComplement,
                                     ttError.rRowid).
    end.

    mError = new outils.errorHandler().
    run mandat/indivisaireContrat.p persistent set vhProc.
    run getTokenInstance in vhProc(mToken:JSessionId).
    run controleIndivisaire in vhProc(pcTypeMandat, piNumeroMandat).
    run getErrors in vhProc(output table ttError).
    run destroy in vhProc.
    delete object mError.
    for each ttError:
        voSauveHandleError:copyError(ttError.horodate,
                                     ttError.iType,
                                     ttError.iErrorId,
                                     ttError.cError,
                                     ttError.lYesNo,
                                     ttError.cComplement,
                                     ttError.rRowid).
    end.
    mError = voSauveHandleError.

end procedure.

procedure validationMandat:
    /*------------------------------------------------------------------------------
    Purpose:
             a partir de adb/lib/l_pecct.p
                         adb/cont/gesctt01.p
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeMandat   as character no-undo.
    define input parameter piNumeroMandat as int64     no-undo.

    define variable vlMandatCreePourMutation as logical   no-undo.
    define variable vhClemi                  as handle    no-undo.
    define variable vhCtrat                  as handle    no-undo.
    define variable vhOutilMandat            as handle    no-undo.
    define variable vcNumeroRegistre         as character no-undo.
    define variable vhPontCompta             as handle    no-undo.
    define variable viNumeroTiersMandant     as integer   no-undo.
    define variable viNumeroRoleMandant      as integer   no-undo.
    define variable voNumeroRegistreMandat as class parametrageNumeroRegistreMandat no-undo.

    define buffer ctrat   for ctrat.
    define buffer roles   for roles.
    define buffer intnt   for intnt.
    define buffer tiers   for tiers.
    define buffer vbctrat for ctrat.

    run controleMandatPrivate(pcTypeMandat, piNumeroMandat).
    if mError:erreur() then return.

    find first ctrat no-lock
         where ctrat.tpcon = pcTypeMandat
           and ctrat.nocon = piNumeroMandat no-error.
    if not available ctrat then do:
        mError:createError({&error}, 100057).
        return.
    end.

    //vlMandatCreePourMutation correspond au mandat cree depuis la mutation (mandat acheteur mutation)
    vlMandatCreePourMutation = can-find(first vbctrat no-lock
                                        where vbctrat.tpcon     = {&TYPECONTRAT-mutationGerance}
                                          and vbctrat.nomdt-ach = piNumeroMandat).
    run v1030(buffer ctrat).
    if mError:erreur() then return.

    /*--> Gestion des cles de repartition SI LE MANDAT EST GERE EN COPRO. */
    if pcTypeMandat = {&TYPECONTRAT-mandat2Gerance} and not vlMandatCreePourMutation
    then do:
        empty temp-table ttClemi.
        run adblib/clemi_CRUD.p persistent set vhClemi.
        run getTokenInstance in vhClemi(mToken:JSessionId).
        run majClger(piNumeroMandat).                                         // creation de ttClemi
        run setclemi in vhClemi (table ttclemi by-reference).
        run destroy in vhClemi.
        if mError:erreur() then return.
    end.

    //de nouveau lecture pour avoir le bon timestamp si ctrat a ete modifie depuis la lecture precedente
    find first ctrat no-lock
         where ctrat.tpcon = pcTypeMandat
           and ctrat.nocon = piNumeroMandat no-error.
    if not available ctrat then do:
        mError:createError({&error}, 100057).
        return.
    end.

    /* changement statut provisoire du mandat */
    empty temp-table ttCtrat.
    create ttCtrat.
    assign
        ttCtrat.tpcon       = ctrat.tpcon
        ttCtrat.nocon       = ctrat.nocon
        ttCtrat.CRUD        = "U"
        ttCtrat.dtTimestamp = datetime(ctrat.dtmsy, ctrat.hemsy)
        ttCtrat.rRowid      = rowid(ctrat)
        ttCtrat.fgprov      = false
    .
    if vlMandatCreePourMutation
    then ttCtrat.dtvaldef = today.
    /* Si Gestion auto des Registres : afficher No */
    if (pcTypeMandat = {&TYPECONTRAT-mandat2Syndic} or pcTypeMandat = {&TYPECONTRAT-mandat2Gerance})
    and ctrat.noree = "AUTO" then do:
        assign
            voNumeroRegistreMandat = new parametrageNumeroRegistreMandat()
            vcNumeroRegistre       = voNumeroRegistreMandat:calculNumeroRegistre (pcTypeMandat)
        .
        delete object voNumeroRegistreMandat.
        if vcNumeroRegistre > "" then ttCtrat.noree = vcNumeroRegistre.
    end.
    /* on fait la maj de la table ctrat pour avoir ctrat.fprov = no (si non les traitements suivants ne fonctionnent pas) */
    run adblib/ctrat_CRUD.p persistent set vhCtrat.
    run getTokenInstance in vhCtrat(mToken:JSessionId).
    run setCtrat in vhCtrat(table ttCtrat by-reference).
    run destroy in vhCtrat.
    if mError:erreur() then return.

    /* appel creation tache */
    creationTache(ctrat.tpcon, ctrat.nocon).
    if mError:erreur() then return.

    /* test si prevenir compta modification mandat */
    run mandat/outilMandat.p persistent set vhOutilMandat.
    run getTokenInstance in vhOutilMandat(mToken:JSessionId).
    if dynamic-function("GerMdtLoc" in vhOutilMandat, ctrat.ntcon)
    then do:
        run immeubleEtLot/pontImmeubleCompta.p persistent set vhPontCompta.
        run getTokenInstance in vhPontCompta(mToken:JSessionId).
        /*--> Prevenir Compta d'un nouveau Mandant Gerance. */
        run majMandatExterne in vhPontCompta(ctrat.tpcon, ctrat.nocon, numeroImmeuble(ctrat.nocon, ctrat.tpcon), yes).
        for first intnt no-lock
            where intnt.tpcon = pcTypeMandat
              and intnt.nocon = piNumeroMandat
              and intnt.tpidt = {&TYPEROLE-mandant}
          , first roles no-lock
            where roles.tprol = intnt.tpidt
              and roles.norol = intnt.noidt
          , first tiers no-lock
            where tiers.notie = roles.notie:
            assign
                viNumeroTiersMandant = tiers.notie
                viNumeroRoleMandant  = roles.norol
            .
        end.
        /*--> Prevenir Compta d'un nouveau Mandant. */
        run majCompteExterne in vhPontCompta(ctrat.tpcon, ctrat.nocon, viNumeroTiersMandant, {&TYPEROLE-mandant}, viNumeroRoleMandant, 0, 0).
        if ctrat.ntcon = {&NATURECONTRAT-mandatAvecIndivision}
        or ctrat.ntcon = {&NATURECONTRAT-mandatLocationIndivision}
        then for each intnt no-lock
            where intnt.tpcon = pcTypeMandat
              and intnt.nocon = piNumeroMandat
              and intnt.tpidt = {&TYPEROLE-coIndivisaire}
          , first roles no-lock
            where roles.tprol = intnt.tpidt
              and roles.norol = intnt.noidt
          , first tiers no-lock
            where tiers.notie = roles.notie:
            /*--> Prevenir Compta d'une Mise a jour de l'indiv. */
            run majCompteExterne in vhPontCompta(ctrat.tpcon, ctrat.nocon, tiers.notie, {&TYPEROLE-coIndivisaire}, roles.norol, intnt.nbnum, intnt.nbden).
        end.
        /*--> Prevenir Compta d'une Mise a jour du  Mandant en tant qu'indivisaire */
        else run majCompteExterne in vhPontCompta(ctrat.tpcon, ctrat.nocon, viNumeroTiersMandant, {&TYPEROLE-coIndivisaire}, viNumeroRoleMandant, 100, 100).
        run destroy in vhPontCompta.
    end.
    run destroy in vhOutilMandat.

end procedure.

procedure v1030 private:
    /*------------------------------------------------------------------------------
    Purpose: a partir de adb/lib/l_pecct.p
                         adb/cont/gesctt01.p
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer ctrat for ctrat.

    define variable voPclie as class pclie no-undo.
    define variable viNumeroMandant      as int64  no-undo.
    define variable viNumeroImmeuble     as int64  no-undo.
    define variable viNumeroMandatSyndic as int64  no-undo.
    define variable viMandatCopro        as int64  no-undo.
    define variable vhProc               as handle no-undo.

    define buffer clemi    for clemi.
    define buffer intnt    for intnt.
    define buffer local    for local.
    define buffer roles    for roles.
    define buffer vbintnt  for intnt.
    define buffer vb2intnt for intnt.
    define buffer vb3intnt for intnt.

    /* Ajout SY le 14/10/2010 : Création automatique de la clé de refacturation manuelle si param existe */
    /* Modif SY le 04/11/2010 - Ajout controle que la clé n'existe pas déjà (tests Eric fiche 0706/0018) */
    voPclie = new pclie("RFMAN", "00001").
    if voPclie:isDbParameter
    and not can-find(first clemi no-lock
                     where clemi.tpcon = ctrat.tpcon
                       and clemi.nocon = ctrat.nocon /* SY 09/02/2018 */
                       and clemi.tpcle = {&NATURECLE-RefacturationLocataire})
    then do:
        empty temp-table ttClemi.
        create ttclemi.
        assign
            ttClemi.CRUD            = "C"
            ttClemi.cTypeContrat    = ctrat.tpcon
            ttClemi.iNumeroContrat  = ctrat.nocon
            ttClemi.iNumeroImmeuble = 10000 + ctrat.nocon
            ttClemi.cCodeCle        = voPclie:zon02
            ttClemi.cLibelleCle     = voPclie:zon03
            ttClemi.cNatureCle      = {&NATURECLE-RefacturationLocataire}
            ttClemi.cCodeEtat       = "V"
            ttClemi.iNumeroOrdre    = 500
            ttClemi.cdmsy           = mtoken:cUser + "@ValEnrPEC"
        .
        run adblib/clemi_CRUD.p persistent set vhProc.
        run getTokenInstance in vhProc(mToken:JSessionId).
        run setclemi in vhProc(table ttclemi by-reference).
        run destroy in vhProc.
    end.

    /* gerer le mandataire en copro.*/
    /* no mandant */
    for first intnt no-lock
        where intnt.tpcon = ctrat.tpcon
          and intnt.nocon = ctrat.nocon
          and intnt.tpidt = {&TYPEROLE-mandant}:
        viNumeroMandant = intnt.noidt.
    end.
    /* Rechercher immeuble du mandat */
    for first intnt no-lock
        where intnt.tpcon = ctrat.tpcon
          and intnt.nocon = ctrat.nocon
          and intnt.tpidt = {&TYPEBIEN-immeuble}:
        viNumeroImmeuble = intnt.noidt.
    end.
    /* Rechercher mandat de syndic de l'immeuble */
    for first intnt no-lock
        where intnt.tpcon = {&TYPECONTRAT-mandat2Syndic}
          and intnt.tpidt = {&TYPEBIEN-immeuble}
          and intnt.noidt = viNumeroImmeuble:
        viNumeroMandatSyndic = intnt.nocon.
    end.
    viMandatCopro = integer( string(viNumeroMandatSyndic,"99999") + string(viNumeroMandant,"99999") ).
    if can-find(first intnt no-lock
                where intnt.tpcon = {&TYPECONTRAT-titre2copro}
                  and intnt.nocon = viMandatCopro
                  and intnt.tpidt = {&TYPEROLE-coproprietaire}
                  and intnt.noidt = viNumeroMandant)
    then do:
        empty temp-table ttIntnt.
        /* Boucle sur les lots du mandat */
        for each vbintnt no-lock
            where vbintnt.tpcon = ctrat.tpcon
              and vbintnt.nocon = ctrat.nocon
              and vbintnt.tpidt = {&TYPEBIEN-lot}:
            if can-find(first vb2intnt no-lock
                        where vb2intnt.tpcon = {&TYPECONTRAT-titre2copro}
                          and vb2intnt.nocon = viMandatCopro
                          and vb2intnt.tpidt = vbintnt.tpidt
                          and vb2intnt.noidt = vbintnt.noidt)
            then do:
                /* Gestion Du Mandataire en copro */
                for first local no-lock
                    where local.noloc = vbintnt.noidt
                      and local.noimm = viNumeroImmeuble
                  , first roles no-lock
                    where roles.tprol = {&TYPEROLE-mandataire}
                      and not can-find(first vb3intnt no-lock
                                       where vb3intnt.tpcon = {&TYPECONTRAT-titre2copro}
                                         and vb3intnt.nocon = viMandatCopro
                                         and vb3intnt.tpidt = roles.tprol
                                         and vb3intnt.noidt = roles.norol):
                    create ttIntnt.
                    assign
                        ttIntnt.tpidt = roles.tprol
                        ttIntnt.noidt = roles.norol
                        ttIntnt.tpcon = {&TYPECONTRAT-titre2copro}
                        ttIntnt.nocon = viMandatCopro
                        ttIntnt.nbnum = 0
                        ttIntnt.idsui = 0
                        ttIntnt.nbden = 0
                        ttIntnt.cdreg = ""
                        ttIntnt.lbdiv = ""
                        ttIntnt.CRUD  = 'C'
                    .
                end.

                /* gestion des coindivisaires */
                if ctrat.ntcon = {&NATURECONTRAT-mandatAvecIndivision}
                or ctrat.ntcon = {&NATURECONTRAT-mandatLocationIndivision}
                then for each vb2intnt no-lock
                    where vb2intnt.tpcon = ctrat.tpcon
                      and vb2intnt.nocon = ctrat.nocon
                      and vb2intnt.tpidt = {&TYPEROLE-coIndivisaire}
                      and not can-find(first vb3intnt no-lock
                                       where vb3intnt.tpcon = {&TYPECONTRAT-titre2copro}
                                         and vb3intnt.nocon = viMandatCopro
                                         and vb3intnt.tpidt = vb2intnt.tpidt
                                         and vb3intnt.noidt = vb2intnt.noidt):
                    create ttIntnt.
                    assign
                        ttIntnt.tpidt = vb2intnt.tpidt
                        ttIntnt.noidt = vb2intnt.noidt
                        ttIntnt.tpcon = {&TYPECONTRAT-titre2copro}
                        ttIntnt.nocon = viMandatCopro
                        ttIntnt.nbnum = 0
                        ttIntnt.idsui = 0
                        ttIntnt.nbden = 0
                        ttIntnt.cdreg = ""
                        ttIntnt.lbdiv = ""
                        ttIntnt.CRUD  = 'C'
                    .
                end.
            end.
        end.
        if can-find(first ttIntnt)
        then lancementPgm ("adblib/intnt_CRUD.p", "setIntnt", table ttIntnt by-reference).
    end.

    /* Mandat de location délégué : Il faut créer le mandat de sous-location associé, si il n'existe pas déjà */
    if ctrat.ntcon = {&NATURECONTRAT-mandatLocationDelegue} then do:
        run adb/pcmdtges.p persistent set vhProc.
        run getTokenInstance in vhProc(mToken:JSessionId).
        run lancementPcmdtges in vhProc(0, viNumeroImmeuble, yes).
        run destroy in vhProc.
    end.

end procedure.
