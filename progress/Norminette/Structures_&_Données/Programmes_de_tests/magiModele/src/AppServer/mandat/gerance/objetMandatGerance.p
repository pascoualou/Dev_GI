/*------------------------------------------------------------------------
File        : objetMandat.p
Purpose     : objet d'un mandat
Author(s)   : GGA  -  2017/08/28
Notes       : reprise du pgm adb/cont/gesobj00.p
              mais uniquement le code pour type mandat gerance
derniere revue: 2018/06/11 - phm: KO
        traiter les todo
------------------------------------------------------------------------*/
{preprocesseur/codePeriode.i}
{preprocesseur/mode2reglement.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/referenceClient.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2adresse.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2role.i}
{preprocesseur/type2tache.i}
{preprocesseur/etat2traitement.i}
{preprocesseur/codeTaciteReconduction.i}
{preprocesseur/type2uniteLocation.i}
{preprocesseur/motif2Resiliation.i}
{preprocesseur/comptabilite.i}

using parametre.pclie.parametrageFournisseurLoyer.
using parametre.pclie.parametrageDefautMandat.
using parametre.pclie.parametragePayePegase.
using parametre.pclie.parametrageCodeESI.
using parametre.pclie.parametrageOrigineClient.
using parametre.pclie.parametrageNumeroRegistreMandat.
using parametre.pclie.pclie.
using parametre.syspr.syspr.
using parametre.syspg.syspg.
using parametre.syspg.parametrageNatureContrat.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{application/include/glbsepar.i}
{application/include/combo.i}
{application/include/error.i}
{mandat/include/mandat.i}
{mandat/include/objetMandat.i}
{crud/include/ctrat.i}
{crud/include/intnt.i}
{immeubleEtLot/include/cpuni.i}
{cadbgestion/include/soldmdt1.i}  // procedure soldmdt1Controle

define variable goSyspr as class syspr no-undo.

function gestionDescriptifGeneral returns logical private():
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    return lookup(left-trim(mtoken:cRefPrincipale, "0"), substitute("&1,&2,&3,&4", {&REFCLIENT-ALLIANZ},
                                                                                   {&REFCLIENT-ALLIANZRECETTE},
                                                                                   {&REFCLIENT-GIDEV},
                                                                                   {&REFCLIENT-GICLI})) > 0.
end function.

function resteLotNonLibre returns logical private(piNumeroContrat as integer, pcTypeContrat as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer intnt for intnt.
    define buffer local for local.
    define buffer cpuni for cpuni.

    for each intnt no-lock
        where intnt.tpcon = pcTypeContrat
          and intnt.nocon = piNumeroContrat
          and intnt.tpidt = {&TYPEBIEN-lot},
        first local no-lock
        where local.noloc = intnt.noidt,
        first cpuni no-lock
        where cpuni.nomdt = piNumeroContrat
          and cpuni.noapp = {&TYPEUL-lotNonAffecte}
          and cpuni.nocmp = 10
          and cpuni.nolot = local.nolot:
        if local.fgdiv and cpuni.sflot <> local.sfree then return true.
   end.
   return false.

end function.

function resteLotLibre returns logical private(piNumeroContrat as integer, pcTypeContrat as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer intnt for intnt.
    define buffer local for local.
    define buffer cpuni for cpuni.

    for each intnt no-lock
        where intnt.tpcon = pcTypeContrat
          and intnt.nocon = piNumeroContrat
          and intnt.tpidt = {&TYPEBIEN-lot},
        first local no-lock
        where local.noloc = intnt.noidt,
        first cpuni no-lock
        where cpuni.nomdt = piNumeroContrat
          and cpuni.noapp = {&TYPEUL-lotNonAffecte}
          and cpuni.nocmp = 10
          and cpuni.nolot = local.nolot:
        if (local.fgdiv and cpuni.sflot = local.sfree) or not local.fgdiv then do:
            /* preparation suppression lot */
            create ttIntnt.
            assign
                ttintnt.tpidt       = intnt.tpidt
                ttintnt.noidt       = intnt.noidt
                ttintnt.tpcon       = intnt.tpcon
                ttintnt.nocon       = intnt.nocon
                ttIntnt.nbnum       = intnt.nbnum
                ttIntnt.idpre       = intnt.idpre
                ttIntnt.idsui       = intnt.idsui
                ttIntnt.rRowid      = rowid(intnt)
                ttIntnt.dtTimestamp = datetime(intnt.dtmsy, intnt.hemsy)
                ttIntnt.CRUD        = "D"
            .
            /* preparation suppression lot dans unite location 998 */
            create ttCpuni.
            assign
                ttCpuni.nomdt       = cpuni.nomdt
                ttCpuni.noimm       = cpuni.noimm
                ttCpuni.nolot       = cpuni.nolot
                ttCpuni.noapp       = cpuni.noapp
                ttCpuni.nocmp       = cpuni.nocmp
                ttCpuni.noord       = cpuni.noord
                ttCpuni.dtTimestamp = datetime(cpuni.dtmsy, cpuni.hemsy)
                ttCpuni.CRUD        = 'D'
                ttCpuni.rRowid      = rowid(cpuni)
            .
        end.
   end.
   return can-find(first ttIntnt).
end function.

function bauxActifs returns logical private (piNumeroContrat as integer, pcTypeContrat as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer ctctt for ctctt.

    for each ctctt no-lock
        where ctctt.tpct1 = pcTypeContrat
          and ctctt.noCt1 = piNumeroContrat
          and ctctt.tpct2 = {&TYPECONTRAT-bail}:
        if can-find(first ctrat no-lock
                    where ctrat.tpcon = ctctt.tpct2
                      and ctrat.nocon = ctctt.noct2
                      and ctrat.ntcon <> {&NATURECONTRAT-specialVacant}
                      and ctrat.fgprov  = false
                      and ctrat.dtree = ?)
        then return true.
    end.
    return false.
end function.

function getNumeroImmeuble return int64 private(piNumeroContrat as int64, pcTypeContrat as character):
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

procedure getObjet:
    /*------------------------------------------------------------------------------
    Purpose: affichage information objet d'un mandat
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeTrt       as character no-undo.
    define input parameter piNumeroContrat as int64     no-undo.
    define output parameter table for ttMandat.
    define output parameter table for ttObjetMandatDescriptifGeneral.

    define buffer ctrat for ctrat.
    define buffer tache for tache.

    empty temp-table ttMandat.
    empty temp-table ttObjetMandatDescriptifGeneral.
    find first ctrat no-lock
        where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and ctrat.nocon = piNumeroContrat no-error.
    if not available ctrat then do:
        mError:createError({&error}, 100057).
        return.
    end.
    run lectInfoCtrat(piNumeroContrat).

    if pcTypeTrt = "RENOUVELLEMENT" and ttMandat.daDateFin < today then do:
        ttMandat.daDateDebut = ttMandat.daDateFin + 1.
        run calDtExp(buffer ttMandat).
    end.

end procedure.

procedure setObjet:
    /*------------------------------------------------------------------------------
    Purpose: maj infos objet mandat
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input        parameter pcTypeTrt as character no-undo.
    define input-output parameter table for ttMandat.
    define input-output parameter table for ttObjetMandatDescriptifGeneral.
    define input        parameter table for ttError.

    define buffer ctrat for ctrat.

    find first ttMandat where ttMandat.CRUD = "C" or ttMandat.CRUD = "U" no-error.
    if not available ttMandat then return.

    find first ctrat no-lock
        where ctrat.tpcon = ttMandat.cCodeTypeContrat
          and ctrat.nocon = ttMandat.iNumeroContrat no-error.
    if not available ctrat then do:
        mError:createError({&error}, 100057).
        return.
    end.
    goSyspr = new syspr().
    if pcTypeTrt = "RESILIATION"
    then run verificationResiliation(buffer ctrat, buffer ttMandat).
    else run verificationNonResiliation(pcTypeTrt, buffer ctrat, buffer ttMandat).
    delete object goSyspr.
    if not mError:erreur() then run valMajEcr(pcTypeTrt, buffer ttMandat).
    if not mError:erreur() then run majCtrat(pcTypeTrt, buffer ctrat, buffer ttMandat).

end procedure.

procedure lectInfoCtrat private:
    /*------------------------------------------------------------------------------
    Purpose: affichage information objet d'un mandat
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as int64 no-undo.

    define variable voCodeESI  as class parametrageCodeESI no-undo.
    define variable voPclie    as class pclie              no-undo.
    define buffer ctrat for ctrat.
    define buffer idev  for idev.

    for first ctrat no-lock
        where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and ctrat.nocon = piNumeroContrat:
        create ttMandat.
        assign
            ttMandat.CRUD                          = 'R'
            ttMandat.cCodeTypeContrat              = ctrat.tpcon
            ttMandat.iNumeroContrat                = ctrat.nocon
            ttMandat.iNumeroDocument               = ctrat.nodoc
            ttMandat.cLibelleTypeContrat           = outilTraduction:getLibelleProg("O_CLC", ctrat.tpcon)
            ttMandat.cCodeNatureContrat            = ctrat.ntcon
            ttMandat.cLibelleNatureContrat         = outilTraduction:getLibelleProg("O_COT", ctrat.ntcon)
            ttMandat.cCodeDevise                   = ctrat.cddev
            ttMandat.cCodeStatut                   = ctrat.cdstatut
            ttMandat.daDateDebut                   = ctrat.dtdeb
            ttMandat.daDateFin                     = ctrat.dtfin
            ttMandat.daDateInitiale                = ctrat.dtini
            ttMandat.daDateLimite                  = ctrat.dtmax
            ttMandat.daResiliation                 = ctrat.dtree
            ttMandat.daSignature                   = ctrat.dtsig
            ttMandat.cLieuSignature                = ctrat.lisig
            ttMandat.daDateValidation              = ctrat.dtvaldef
            ttMandat.iNbrenouvellementMax          = ctrat.nbrenmax
            ttMandat.cNumeroReelRegistre           = ctrat.noree
            ttMandat.cCodeTypeRenouvellement       = ctrat.tpren
            ttMandat.lTaciteReconduction           = (ctrat.tpren = {&TACITERECONDUCTION-YES})
            ttMandat.iDuree                        = ctrat.nbdur
            ttMandat.cUniteDuree                   = ctrat.cddur
            ttMandat.cLibelleUniteDuree            = outilTraduction:getLibelleParam("UTDUR", ctrat.cddur)
            ttMandat.iDelaiResiliation             = ctrat.nbres
            ttMandat.cUniteDelaiResiliation        = ctrat.utres
            ttMandat.cLibelleUniteDelaiResiliation = outilTraduction:getLibelleParam("UTDUR", ctrat.utres)
            ttMandat.cTypeActe                     = ctrat.tpact
            ttMandat.cLibelleTypeActe              = outilTraduction:getLibelleParam("TPACT", ctrat.tpact)
            ttMandat.cOrigineClient                = ctrat.cdori
            ttMandat.iNbRenouvellement             = ctrat.noren
            ttMandat.cDureeMax                     = string(not ctrat.fgdurmax and ctrat.nbrenmax <> 0,"2/1")
            ttMandat.iDureeMax                     = ctrat.nbannmax
            ttMandat.cUniteDureeMax                = ctrat.cddurmax
            ttMandat.cLibelleUniteDureeMax         = outilTraduction:getLibelleParam("UTDUR", ctrat.cddurmax)
            ttMandat.lResiliation                  = ctrat.dtree <> ?
            ttMandat.cMotifResiliation             = ctrat.tpfin
            ttMandat.cLibelleMotifResiliation      = outilTraduction:getLibelleParam("TPMOT", ctrat.tpfin)
            ttMandat.lProvisoire                   = ctrat.fgprov
            ttMandat.iNumeroBlocNote               = ctrat.noblc
            ttMandat.iNumeroImmeuble               = getNumeroImmeuble(ctrat.nocon, ctrat.tpcon)
            ttMandat.dtTimestamp                   = datetime(ctrat.dtmsy, ctrat.hemsy)
            ttMandat.rRowid                        = rowid(ctrat)
        .
        run soldmdt1Controle(mToken:cRefGerance,
                             ctrat.nocon,
                             output ttMandat.daOdFinMandat,
                             output ttMandat.daArchivage).
        for first idev no-lock
            where idev.soc-cd = integer(mtoken:cRefGerance)
              and idev.dev-cd = ttMandat.cCodeDevise:
            ttMandat.cLibelleCodeDevise = idev.lib.
        end.
        case ttMandat.cDureeMax:
            when "1" then ttMandat.cLibelleDureeMax = outilTraduction:getLibelle(110292).
            when "2" then ttMandat.cLibelleDureeMax = outilTraduction:getLibelle(110293).
        end case.
        assign
            voCodeESI                      = new parametrageCodeESI()
            voPclie                        = new pclie("CDORI", ttMandat.cOrigineClient)
            ttMandat.cLibelleOrigineClient = voPclie:zon02
        .
        if voCodeESI:isDbParameter then
            assign
                ttMandat.iCodeEsi       = ctrat.pcpte
                ttMandat.lSaisieCodeEsi = yes
            .
        delete object voCodeESI.

        if gestionDescriptifGeneral () then do:
            create ttObjetMandatDescriptifGeneral.
            assign
                ttObjetMandatDescriptifGeneral.cEtatConstrucRestruc = ctrat.cdetat
                ttObjetMandatDescriptifGeneral.lEnConstrucRestruc   = ctrat.cdconst-rest = "00001"
                ttObjetMandatDescriptifGeneral.cClassification      = ctrat.cdclassification
                ttObjetMandatDescriptifGeneral.cNature              = ctrat.cdnature
                ttObjetMandatDescriptifGeneral.cUsagePrincipal      = ctrat.cdusage1
                ttObjetMandatDescriptifGeneral.cUsageSecondaire     = ctrat.cdusage2
                ttObjetMandatDescriptifGeneral.cStatut              = ctrat.cdstatutventes
                ttObjetMandatDescriptifGeneral.daEffetStatut        = ctrat.dtstatutventes
                ttObjetMandatDescriptifGeneral.cTypeGerance         = ctrat.tpgerance
            .
            voPclie:reload("AGF01", ttObjetMandatDescriptifGeneral.cEtatConstrucRestruc).
            ttObjetMandatDescriptifGeneral.cLibelleEtatConstrucRestruc = voPclie:zon02.
            voPclie:reload("AGF02", ttObjetMandatDescriptifGeneral.cClassification).
            ttObjetMandatDescriptifGeneral.cLibelleClassification = voPclie:zon02.
            voPclie:reload("AGF03", ttObjetMandatDescriptifGeneral.cNature).
            ttObjetMandatDescriptifGeneral.cLibelleNature = voPclie:zon02.
            voPclie:reload("AGF04", ttObjetMandatDescriptifGeneral.cUsagePrincipal).
            ttObjetMandatDescriptifGeneral.cLibelleUsagePrincipal = voPclie:zon02.
            voPclie:reload("AGF04", ttObjetMandatDescriptifGeneral.cUsageSecondaire).
            ttObjetMandatDescriptifGeneral.cLibelleUsageSecondaire = voPclie:zon02.
            voPclie:reload("AGF05", ttObjetMandatDescriptifGeneral.cStatut).
            ttObjetMandatDescriptifGeneral.cLibelleStatut = voPclie:zon02.
            case ttObjetMandatDescriptifGeneral.cTypeGerance:
                when "00001" then ttObjetMandatDescriptifGeneral.cLibelleTypeGerance = outilTraduction:getLibelle(103628).
                when "00002" then ttObjetMandatDescriptifGeneral.cLibelleTypeGerance = outilTraduction:getLibelle(1000493).
                when "00003" then ttObjetMandatDescriptifGeneral.cLibelleTypeGerance = outilTraduction:getLibelle(1000494).
            end case.
        end.
        delete object voPclie.
    end.

end procedure.

procedure initObjet:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define parameter buffer ttCtrat for ttCtrat.

    define variable voDefautMandat         as class parametrageDefautMandat         no-undo.
    define variable voNumeroRegistreMandat as class parametrageNumeroRegistreMandat no-undo.

    assign
        ttCtrat.tpren  = {&TACITERECONDUCTION-YES}
        ttCtrat.tpact  = "00000"
        ttCtrat.cddev  = mToken:cDeviseReference
        voDefautMandat = new parametrageDefautMandat()
    .
    if voDefautMandat:isDbParameter then
        assign
             ttCtrat.nbdur    = voDefautMandat:getGenerauxDuree()
             ttCtrat.cddur    = voDefautMandat:getGenerauxUniteDuree()
             ttCtrat.nbres    = voDefautMandat:getGenerauxDelaiResiliation()
             ttCtrat.utres    = voDefautMandat:getGenerauxUniteDelaiResiliation()
             ttCtrat.cddurmax = voDefautMandat:getGenerauxUniteDuree()
        .
    delete object voDefautMandat.
    voNumeroRegistreMandat = new parametrageNumeroRegistreMandat().
    if voNumeroRegistreMandat:isNumeroRegistreAuto()
    then ttCtrat.noree = "AUTO".
    delete object voNumeroRegistreMandat.

end procedure.

procedure initComboObjet:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :  service externe
    ------------------------------------------------------------------------------*/
    define output parameter table for ttCombo.

    define variable voSyspr         as class syspr                    no-undo.
    define variable voPclie         as class pclie                    no-undo.
    define variable voSyspg         as class syspg                    no-undo.
    define variable voOrigineClient as class parametrageOrigineClient no-undo.

    empty temp-table ttCombo.
    assign
        voSyspg         = new syspg()
        voSyspr         = new syspr()
        voOrigineClient = new parametrageOrigineClient()
    .
    voSyspr:getComboParametre("UTDUR", "CMBUNITEDUREE", output table ttCombo by-reference).
    voSyspr:getComboParametre("TPACT", "CMBTYPEACTE", output table ttCombo by-reference).
    voSyspr:getComboParametre("TPMOT", "CMBMOTIFRESILIATION", output table ttCombo by-reference).
    voOrigineClient:getComboParametre("CMBORIGINECLIENT", output table ttCombo by-reference).
    voSyspg:creationttCombo("CMBORIGINECLIENT", "", "-", output table ttCombo by-reference).
    delete object voSyspr.
    delete object voOrigineClient.

    for each ttCombo
        where ttCombo.cNomCombo = "CMBUNITEDUREE"
          and ttCombo.cCode    <> "00001":
        voSyspg:creationttCombo("CMBUNITEDELAIRESILIATION", ttCombo.cCode, ttCombo.cLibelle, output table ttCombo by-reference).
    end.
    /* supprimer les motifs de resiliation ne concernant pas les Mandats ( - et Chgt societe ) */
    /* 19/03/2002 : Nouveaux motifs differents selon mandat de gerance ou de syndic */
    for each ttCombo
        where ttCombo.cNomCombo = "CMBMOTIFRESILIATION":
        if not (ttCombo.cCode = "00000" or ttCombo.cCode < "10002" or ttCombo.cCode begins "12")
        then delete ttCombo.
    end.
    voSyspg:creationttCombo("DUREEMAXIMALE", "1", outilTraduction:getLibelle(110292), output table ttCombo by-reference).
    voSyspg:creationttCombo("DUREEMAXIMALE", "2", outilTraduction:getLibelle(110293), output table ttCombo by-reference).

    if gestionDescriptifGeneral() then do:
        voPclie = new pclie("AGF01").
        voPclie:getComboParametre("ETATCONSTUCTION", "and pclie.zon01 <> '00000'", "zon01", "zon02", output table ttCombo by-reference).
        voPclie:reload("AGF02").
        voPclie:getComboParametre("CLASSIFICATION" , "and pclie.zon01 <> '00000'", "zon01", "zon02", output table ttCombo by-reference).
        voPclie:reload("AGF03").
        voPclie:getComboParametre("NATURE"         , "and pclie.zon01 <> '00000'", "zon01", "zon02", output table ttCombo by-reference).
        voPclie:reload("AGF04").
        voPclie:getComboParametre("USAGEPRINCIPAL" , "and pclie.zon01 <> '00000'", "zon01", "zon02", output table ttCombo by-reference).
        voPclie:getComboParametre("USAGESECONDAIRE", "and pclie.zon01 <> '00000'", "zon01", "zon02", output table ttCombo by-reference).
        voPclie:reload("AGF05").
        voPclie:getComboParametre("STATUT"         , "and pclie.zon01 <> '00000'", "zon01", "zon02", output table ttCombo by-reference).
        delete object voPclie.
        voSyspg:creationttCombo("TYPEGERANCE", "00001", outilTraduction:getLibelle(103628), output table ttCombo by-reference).
        voSyspg:creationttCombo("TYPEGERANCE", "00002", outilTraduction:getLibelle(1000493), output table ttCombo by-reference).
        voSyspg:creationttCombo("TYPEGERANCE", "00003", outilTraduction:getLibelle(1000494), output table ttCombo by-reference).
    end.
    delete object voSyspg.

end procedure.

procedure verificationNonResiliation private:
    /*------------------------------------------------------------------------------
    Purpose: controle infos objet mandat avant maj
    Notes  : ancien (verZonSai, blc-val-menu)
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeTrt as character no-undo.
    define parameter buffer ctrat    for ctrat.
    define parameter buffer ttMandat for ttMandat.

    define variable vdaEffMin            as date    no-undo.
    define variable vdaEffMax            as date    no-undo.
    define variable vdaDtsMin            as date    no-undo.
    define variable vdaDtsMax            as date    no-undo.
    define variable vlNumeroRegistreAuto as logical no-undo.

    define variable voNumeroRegistreMandat as class parametrageNumeroRegistreMandat no-undo.

    define buffer vbctrat for ctrat.
    define buffer etabl   for etabl.
    define buffer svtrf   for svtrf.
    define buffer ctctt   for ctctt.
    define buffer trdos   for trdos.
    define buffer tache   for tache.
    define buffer trfpm   for trfpm.

    assign
        voNumeroRegistreMandat = new parametrageNumeroRegistreMandat().
        vlNumeroRegistreAuto   = voNumeroRegistreMandat:isNumeroRegistreAuto()
    .
    delete object voNumeroRegistreMandat.

    //On teste la partie haute si on n'est pas en resiliation
    if ttMandat.cNumeroReelRegistre = "" or ttMandat.cNumeroReelRegistre = ? then do:
        mError:createError({&error}, 100071).
        return.
    end.
    if vlNumeroRegistreAuto and ttMandat.cNumeroReelRegistre <> ctrat.noree then do:
        mError:createError({&error}, 1000976). //La gestion du numéro de registre est automatique, vous ne pouvez donc pas modifier le numéro.
        return.
    end.
    if ttMandat.daDateInitiale = ? then do:
        mError:createError({&error}, 104078).
        return.
    end.
    if ttMandat.daDateDebut = ? then do:
        mError:createError({&error}, 100072). //la date d'effet est obligatoire
        return.
    end.
    if ttMandat.daDateInitiale > ttMandat.daDateDebut then do:
        mError:createError({&error}, 104079).
        return.
    end.
    if ttMandat.cDureeMax = "1" then do:
        if ttMandat.iDureeMax = 0 then do:
            mError:createError({&error}, 110290).
            return.
        end.
    end.
    else if ttMandat.iNbRenouvellementMax= 0 then do:
        mError:createError({&error}, 110291).
        return.
    end.
    if pcTypeTrt = "RENOUVELLEMENT" and ctrat.dtdeb <> ? and ttMandat.daDateDebut < ctrat.dtdeb then do:
        mError:createErrorGestion({&error}, 101955, string(ctrat.dtdeb, "99/99/9999")).
        return.
    end.
    assign
        vdaEffMin = add-interval(today, -98, "year")
        vdaEffMax = add-interval(today, 1, "year")
    .
    if ttMandat.daDateDebut <= vdaEffMin or ttMandat.daDateDebut >= vdaEffMax then do:
        // Date d'effet incorrecte &1. La date d'effet doit être supérieure au &2 et inférieure au &3
        mError:createError({&error}, 1000430, substitute("&2&1&3&1&4", separ[1], if ttMandat.daDateDebut <> ? then string(ttMandat.daDateDebut) else " ", string(vdaEffMin), string(vdaEffMax))).
        return.
    end.
    if ttMandat.iDuree = ? then do:
        mError:createError({&error}, 100073).
        return.
    end.
    if ttMandat.iDuree = 0 then do:
        mError:createError({&error}, 101998).
        return.
    end.
    if not goSyspr:isParamExist("UTDUR", ttMandat.cUniteDuree) then do:
        mError:createError({&error}, 100074).
        return.
    end.
    run controleDureeDuContrat(buffer ttMandat).
    if mError:erreur() then return.

    if ttMandat.daDateFin = ? then do:
        mError:createError({&error}, 100075).
        return.
    end.
    if ttMandat.daDateFin <= ttMandat.daDateDebut then do:
        mError:createError({&error}, 100076).
        return.
    end.
    if ttMandat.iDelaiResiliation = ? then do:
        mError:createError({&error}, 100077).
        return.
    end.
    if ttMandat.iDelaiResiliation = 0 then do:
        mError:createError({&error}, 102045).
        return.
    end.
    if not goSyspr:isParamExist("UTDUR", ttMandat.cUniteDelaiResiliation) or ttMandat.cUniteDelaiResiliation = "00001" then do:
        mError:createError({&error}, 100078).
        return.
    end.
    if integer(mtoken:cRefPrincipale) <> {&REFCLIENT-MANPOWER} then do:
        if ttMandat.daSignature = ? then do:
            mError:createError({&error}, 100079).
            return.
        end.
        assign
            vdaDtsMin = ttMandat.daDateInitiale
            vdaDtsMin = add-interval(vdaDtsMin, -1, "year")
            vdaDtsMin = date(month(vdaDtsMin), 1, year(vdaDtsMin))
            vdaDtsMax = ttMandat.daDateInitiale
            vdaDtsMax = add-interval(vdaDtsMax, 13, "month")
            vdaDtsMax = date(month(vdaDtsMax), 1, year(vdaDtsMax)) - 1
        .
        if ttMandat.daSignature > vdaDtsMax or ttMandat.daSignature < vdaDtsMin then do:
            if outils:questionnaire(107343, table ttError by-reference) <= 2 //La date de signature a plus d'un an d'écart avec la date du 1er contrat, Confirmez vous ?
            then return.
        end.
        if ttMandat.cLieuSignature = ? or ttMandat.cLieuSignature = "" then do:
            mError:createError({&error}, 100081).
            return.
        end.
    end.
    if not goSyspr:isParamExist("TPACT", ttMandat.cTypeActe) then do:
        mError:createError({&error}, 100082).
        return.
    end.
    find first ttObjetMandatDescriptifGeneral no-error.
    if not available ttObjetMandatDescriptifGeneral and gestionDescriptifGeneral () then do:
        mError:createError({&error}, 1000858).        //info specifique allianz agf obligatoire
        return.
    end.
    else if available ttObjetMandatDescriptifGeneral and ttObjetMandatDescriptifGeneral.cStatut > "" and ttObjetMandatDescriptifGeneral.daEffetStatut = ? then do:
        mError:createError({&error}, 1000859).        //La date de statut est obligatoire
        return.
    end.

end procedure.

procedure verificationResiliation private:
    /*------------------------------------------------------------------------------
    Purpose: controle infos objet mandat avant maj
    Notes  : ancien (verZonSai, blc-val-menu)
    ------------------------------------------------------------------------------*/
    define parameter buffer ctrat    for ctrat.
    define parameter buffer ttMandat for ttMandat.

    define variable viRetourQuestion   as integer   no-undo.
    define variable vhProcctrconvm     as handle    no-undo.

    define buffer vbctrat for ctrat.
    define buffer etabl   for etabl.
    define buffer svtrf   for svtrf.
    define buffer ctctt   for ctctt.
    define buffer trdos   for trdos.
    define buffer tache   for tache.
    define buffer trfpm   for trfpm.

    if ttMandat.daResiliation = ? and ttMandat.lResiliation then do:
        mError:createError({&error}, 100083).
        return.
    end.
    if ttMandat.daResiliation < ctrat.dtini then do:
        mError:createError({&error}, 105575). //La date de résiliation doit être postérieure à la date du 1er contrat.
        return.
    end.
    if ttMandat.daResiliation < ctrat.dtsig then do:
        mError:createError({&error}, 102047). //La date de résiliation doit être postérieure à la date de signature !!
        return.
    end.
    if ttMandat.daResiliation > ctrat.dtfin
    and outils:questionnaireGestion(110374, substitute('&2&1', separ[1], string(ttMandat.daResiliation)), table ttError by-reference) <= 2 //La date de résiliation doit être postérieure à la date de signature !!
    then return.

    if ttMandat.cMotifResiliation = "" or ttMandat.cMotifResiliation = ? then do:
        mError:createError({&error}, 100085). //Le motif de résiliation est obligatoire
        return.
    end.
    if not goSyspr:isParamExist("TPMOT", ttMandat.cMotifResiliation)
    or not (ttMandat.cMotifResiliation = {&MOTIF2RESILIATION-Aucun} or ttMandat.cMotifResiliation < {&MOTIF2RESILIATION-PassageSousLocation} or ttMandat.cMotifResiliation begins "12") then do:
        mError:createError({&error}, 1000420). //Motif de résiliation incorrect
        return.
    end.
    if ttMandat.lResiliation then do:
        /* ATTENTION  : Interdit de resilier si */
        /*  - contrat principal avec des contrats annexes actifs  */
        /*  - mandat de gerance avec encore des lots rattaches    */
        for each ctctt no-lock
            where ctctt.tpct1 = ttMandat.cCodeTypeContrat
              and ctctt.noCt1 = ttMandat.iNumeroContrat
              and ctctt.tpct2 = {&TYPECONTRAT-assuranceGerance}:
            if can-find(first vbctrat no-lock
                        where vbctrat.Tpcon = ctctt.tpct2
                          and vbctrat.Nocon = ctctt.noct2
                          and vbctrat.dtree = ?) then do:
                assign
                    ttMandat.lResiliation      = no
                    ttMandat.daResiliation     = ?
                    ttMandat.cMotifResiliation = ""
                .
                mError:createError({&error}, 1000421). //Vous ne pouvez pas résilier ce mandat avant d'avoir résilié les contrats d'assurance associés !!
                return.
            end.
        end.
        for each tache no-lock
            where tache.tpcon = {&TYPECONTRAT-bail}
              and tache.tptac = {&TYPETACHE-quittancement}
              and tache.cdreg = {&MODEREGLEMENT-compensation}
              and tache.etab-cd = ttMandat.iNumeroContrat
              and tache.cptg-cd = {&compteCollectif-Proprietaire},
            first vbctrat no-lock
            where vbctrat.tpcon = tache.tpcon
              and vbctrat.nocon = tache.nocon
              and vbctrat.dtree = ?:
            mError:createError({&error}, 1000422, substitute('&2&1&3', separ[1], tache.nocon, outilFormatage:getNomTiers({&TYPEROLE-locataire}, tache.nocon))).
            return.
        end.

        if bauxActifs (ttMandat.iNumeroContrat, ttMandat.cCodeTypeContrat) then do:
            viRetourQuestion = outils:questionnaire(1000423, table ttError by-reference). //Vous ne pouvez pas résilier ce mandat tant qu'il reste des baux actifs. Voulez-vous accéder aux mutations de gérance ?
            if viRetourQuestion < 2 then return.
            //si on revient la avec oui (3), c'est que l'on est passe par le pgm de mutation et donc il ne devrait plus y avoir de baux actif
            if (viRetourQuestion = 3 and bauxActifs (ttMandat.iNumeroContrat, ttMandat.cCodeTypeContrat))
            or viRetourQuestion = 2 then do:
                assign
                    ttMandat.lResiliation      = no
                    ttMandat.daResiliation     = ?
                    ttMandat.cMotifResiliation = ""
                .
                mError:createError({&error}, 1000425).  //Vous ne pouvez pas résilier ce mandat, il reste des baux actifs.
                return.
            end.
        end.

        //Recherche si lots encore rattaches
        if resteLotNonLibre (ttMandat.iNumeroContrat, ttMandat.cCodeTypeContrat) then do:
            viRetourQuestion = outils:questionnaire(1000431, substitute('&2&1', separ[1], ""), table ttError by-reference). //Vous ne pouvez pas résilier ce mandat tant qu'il reste des lots rattachés. Voulez-vous accéder aux mutations de gérance ?
            if viRetourQuestion < 2 then return.
            //si on revient la avec oui (3), c'est que l'on est passe par le pgm de mutation et donc il ne devrait plus y avoir de lots rattachés
            if (viRetourQuestion = 3 and resteLotNonLibre (ttMandat.iNumeroContrat, ttMandat.cCodeTypeContrat))
            or viRetourQuestion = 2 then do:
                assign
                    ttMandat.lResiliation      = no
                    ttMandat.daResiliation     = ?
                    ttMandat.cMotifResiliation = ""
                .
                mError:createError({&error}, 1000424). //Vous ne pouvez pas résilier ce mandat tant que des lots lui sont rattachés
                return.
            end.
        end.

        //si lot libre encore sur le mandat demande de confirmation pour la suppression automatique
        empty temp-table ttIntnt.
        empty temp-table ttCpuni.
        //la fonction va retourner oui si reste lot libre et faire en meme temps la creation de la temp-table pour suppression de ces lots
        if resteLotLibre (ttMandat.iNumeroContrat, ttMandat.cCodeTypeContrat) then do:
            viRetourQuestion = outils:questionnaire(1000759, table ttError by-reference). //il reste des lots libres sur ce mandat, confirmez vous la suppression de ces lots ?
            if viRetourQuestion < 2 then return. //si reponse non on vide la temp-table pour la suppression des lots
            if viRetourQuestion = 2 then do:
                empty temp-table ttIntnt.
                empty temp-table ttCpuni.
            end.
        end.

/*gga todo ajouter ce test (a partir de hesobj00.p/blc-val-menu + modifier la creation de la combo motif resiliation pour prise en compte 10002 (loadcombo):
        /*--> Si resiliation avec passage en sous-location : Demande de confirmation & controles */
        RUN RecItmCmb(HwCmbMot:HANDLE IN FRAME HwFrmRes,HwCmbMot:SCREEN-VALUE IN FRAME HwFrmRes,'L','@',OUTPUT CdMotRes).
        IF HwTglDtR:SCREEN-VALUE = "YES" AND CdMotRes = "10002" THEN
        DO:
            /*--> Confirmation du passage en sous-location */
            LbTmpPdt = STRING(NoCttUse) + "|" + STRING(NoRolUse,"99999") + "|" + Lnom2use.
            RUN GestMess IN HdLibPrc(106431,"",106430,"",LbTmpPdt,"QUESTION",OUTPUT FgRepMes).
            IF NOT FgRepMes THEN
                RETURN NO-APPLY.
            
            /*--> Controles avant passage en sous-location */
            LbTmpPdt = TpCttUse                         + "|" +
                       STRING(NoCttUse)                 + "|" +
                       NtCttSel                         + "|" +
                       STRING(HwDtaDtR:SCREEN-VALUE)    + "|" +
                       CdMotRes                         + "|" +
                       ""                               + "|" +
                       ""                               + "|" +
                       ""                               + "|" +
                       ""                               + "|" +
                       "".
                       
            {RunPgExp.i &Path       = RpRunLibADB
                        &Expert     = Yes
                        &Prog       = "'CtrConvm.p'"
                        &Parameter  = "INPUT-OUTPUT LbTmpPdt,OUTPUT CdRetCtr"}

            IF CdRetCtr <> "00" THEN
            DO:
                APPLY "ENTRY" TO HwCmbMot IN FRAME HwFrmRes.
                RETURN NO-APPLY.
            END.
        END.
gga*/    



        /* Controle : dossiers travaux non clôturés sur ce contrat */
        if can-find (first trdos no-lock
                     where trdos.tpcon = ttMandat.cCodeTypeContrat
                       and trdos.nocon = ttMandat.iNumeroContrat
                       and trdos.dtree = ?)
        and outils:questionnaire(1000428, table ttError by-reference) <= 2 then return. //Il existe des dossiers travaux non clôturés sur ce contrat. Confirmez-vous la résiliation du contrat ?

        if ttMandat.daOdFinMandat <> ? then do:
            //transformation du message d'erreur par question avec confirmation pour l'afficher
            if outils:questionnaire(1000429, table ttError by-reference) <= 2 then return. //Attention l'ODFM solde l'intégralité des écritures du mandat, assurez vous que vous avez effectué tous vos traitements comptables sur ce mandat
            run adblib/ctrconvm.p persistent set vhProcctrconvm.
            run getTokenInstance in vhProcctrconvm(mToken:JSessionId).
            run ctrconvmControle in vhProcctrconvm (ttMandat.cCodeTypeContrat, ttMandat.iNumeroContrat, ttMandat.daResiliation, ttMandat.cMotifResiliation, ttMandat.daOdFinMandat).
            run destroy in vhprocctrconvm.
            if mError:erreur() then return. 
            if outils:questionnaireGestion(107045, substitute('&2&1&3&1&4&1&5', separ[1], string(ttMandat.iNumeroContrat), outilTraduction:getLibelleProg('O_ROL', ctrat.tprol), string(ctrat.norol,"99999"), ctrat.lnom2),
                                           table ttError by-reference) <= 2    //Confirmation de la resiliation avec OD Automatique de Fin de gestion
            then return.
        end.
    end.

end procedure.

procedure valMajEcr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeTrt as character no-undo.
    define parameter buffer ttMandat for ttMandat.

    define variable viRetPgm   as integer no-undo.
    define variable vhSoldmdt2 as handle  no-undo.

    ttMandat.cCodeTypeRenouvellement = string(ttMandat.lTaciteReconduction,"00001/00000").
    if pcTypeTrt = "RESILIATION" then do:
        if not ttMandat.lResiliation then
            assign
                ttMandat.lResiliation      = no
                ttMandat.daResiliation     = ?
                ttMandat.cMotifResiliation = ""
            .
        else do:
/*gga todo            
            ELSE IF CdMotRes = "10002" THEN DO:
            
                /* Generation d'un code transaction unique */
                RUN CodTrans (OUTPUT NoTrsUse-2).
                {SetWait.i  &WAIT = "ON"}
                {RunPgExp.i
                    &Path       = RpRunCtt
                    &Prog       = "'convmd00.p'"
                    &RunPersiste    = YES
                    &Parameter  = "INPUT TpCttUse,
                               INPUT NoCttUse,
                               INPUT NtCttSel,
                               INPUT DATE(HwDtaDtR:SCREEN-VALUE),
                               INPUT CdMotRes,
                               INPUT NoTrsUse-2,
                               INPUT-OUTPUT LbDivPar,
                               OUTPUT CdRetCon"}
        
                {SetWait.i  &WAIT = "OFF"}
                IF CdRetCon <> "00" THEN DO:
                    IF CdRetCon < "50" THEN DO:
                        IF CdRetCon = "01" THEN DO:
                            /* Passage en sous-location abandonn‚  */
                            RUN GestMess IN HdLibPrc(000003,"",106509,"","","ERROR",OUTPUT FgRepMes).
                        END.
                        ELSE DO:
                            /* Le passage en sous-location est impossible (erreur %1) */
                            RUN GestMess IN HdLibPrc(000003,"",106506,"",CdRetCon,"ERROR",OUTPUT FgRepMes).
                        END.
                        FgAbaMaj-OU = YES.
                        RUN blc-val-menu-0.                                                   /*0108/0218*/
                        RETURN.
                    END.
                    ELSE DO:
                        /* Le passage en sous-location est incomplet (erreur %1) */
                        /* Vous devrez intervenir manuellement (erreur %1) */
                        RUN GestMess IN HdLibPrc(000003,"",106507,"",STRING(INT(CdRetCon) - 50),"ERROR",OUTPUT FgRepMes).
                    END.
                END.
            END.
            else  
gga todo*/            
            if ttMandat.daOdFinMandat <> ? then do:
                run cadbgestion/soldmdt2.p persistent set vhSoldmdt2.
                run getTokenInstance in vhSoldmdt2(mToken:JSessionId).
                run soldmmdt2Lancement in vhSoldmdt2(integer(mtoken:cRefGerance),
                                                     ttMandat.iNumeroContrat,
                                                     ttMandat.daOdFinMandat,
                                                     ttMandat.daResiliation,
                                                     output viRetPgm).
                run destroy in vhSoldmdt2.
                if viRetPgm > 0 then
                    case viRetPgm:
                        when 2  then mError:createError({&error}, 105729 ). // Société compta absente
                        when 3  then mError:createErrorGestion({&error}, 102540, string(ttMandat.iNumeroContrat)). // Mandat %1 inexistant en comptabilite (ietab)
                        when 4  then mError:createError({&error}, 000314 ). // Période absente (comptabilité)
                        otherwise    mError:createError({&information}, 107052, string(viRetPgm)). // La résiliation avec OD automatique de fin de gestion est incomplète (erreur n°%1)%sVous devrez intervenir manuellement
                    end case.
            end.
            /* Ajout SY le 01/04/2008 - 1007/0003 : recherche paramétrage bureautique "Dossier automatique" */
//            if mError:erreur() then return.
//            run GenEvent.     //gga todo pour la reprise de ce module evenement, il faut avant une remise a plat pour reflechir a nouveau fonctionnement
        end.
    end.

end procedure.

procedure majCtrat private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : ValMajEcr-2 dans gesobj00.p
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeTrt as character no-undo.
    define parameter buffer ctrat    for ctrat.
    define parameter buffer ttMandat for ttMandat.

    define variable vhProc          as handle    no-undo.
    define variable vhProclaecha    as handle    no-undo.
    define variable vcTpRolPro      as character no-undo.
    define variable viNoRolPro      as integer   no-undo.
    define variable viNoMdtSyn      as integer   no-undo.
    define variable viNoImmUse      as integer   no-undo.
    define variable viMoisComptable as integer   no-undo.

    define buffer acpte    for acpte.
    define buffer intnt    for intnt.
    define buffer vbintnt  for intnt.
    define buffer vb2Intnt for intnt.
    define buffer vbctrat  for ctrat.

    empty temp-table ttCtrat.
    create ttCtrat.
    assign
        ttCtrat.nodoc       = ttMandat.iNumeroDocument
        ttCtrat.tpcon       = ttMandat.cCodeTypeContrat
        ttCtrat.nocon       = ttMandat.iNumeroContrat
        ttCtrat.dtdeb       = ttMandat.daDateDebut
        ttCtrat.ntcon       = ttMandat.cCodeNatureContrat
        ttCtrat.dtfin       = ttMandat.daDateFin
        ttCtrat.tpfin       = ttMandat.cMotifResiliation
        ttCtrat.nbdur       = ttMandat.iDuree
        ttCtrat.cddur       = ttMandat.cUniteDuree
        ttCtrat.dtsig       = ttMandat.daSignature
        ttCtrat.lisig       = ttMandat.cLieuSignature
        ttCtrat.dtree       = ttMandat.daResiliation
        ttCtrat.noree       = ttMandat.cNumeroReelRegistre
        ttCtrat.tpren       = ttMandat.cCodeTypeRenouvellement
        ttCtrat.noren       = ttMandat.iNbRenouvellement
        ttCtrat.nbres       = ttMandat.iDelaiResiliation
        ttCtrat.utres       = ttMandat.cUniteDelaiResiliation
        ttCtrat.tpact       = ttMandat.cTypeActe
        ttCtrat.pcpte       = (if ttMandat.lSaisieCodeEsi then ttMandat.iCodeEsi else 0)
        ttCtrat.scpte       = 0
        ttCtrat.noave       = 0
        ttCtrat.dtini       = ttMandat.daDateInitiale
        ttCtrat.cdori       = ttMandat.cOrigineClient
        ttCtrat.cddev       = ttMandat.cCodeDevise
        ttCtrat.fgdurmax    = logical(ttMandat.cDureeMax, "1/2")
        ttCtrat.nbannmax    = ttMandat.iDureeMax
        ttCtrat.cddurmax    = ttMandat.cUniteDureeMax
        ttCtrat.dtmax       = ttMandat.daDateLimite
        ttCtrat.nbrenmax    = ttMandat.iNbRenouvellementMax
        ttCtrat.CRUD        = ttMandat.CRUD
        ttCtrat.dtTimestamp = ttMandat.dtTimestamp
        ttCtrat.rRowid      = ttMandat.rRowid
    .
    if gestionDescriptifGeneral () then
        for first ttObjetMandatDescriptifGeneral:
            assign
                ttCtrat.cdetat           = ttObjetMandatDescriptifGeneral.cEtatConstrucRestruc
                ttCtrat.cdconst-rest     = string(ttObjetMandatDescriptifGeneral.lEnConstrucRestruc,"00001/00002")
                ttCtrat.cdclassification = ttObjetMandatDescriptifGeneral.cClassification
                ttCtrat.cdnature         = ttObjetMandatDescriptifGeneral.cNature
                ttCtrat.cdusage1         = ttObjetMandatDescriptifGeneral.cUsagePrincipal
                ttCtrat.cdusage2         = ttObjetMandatDescriptifGeneral.cUsageSecondaire
                ttCtrat.cdstatutventes   = ttObjetMandatDescriptifGeneral.cStatut
                ttCtrat.dtstatutventes   = ttObjetMandatDescriptifGeneral.daEffetStatut
                ttCtrat.tpgerance        = ttObjetMandatDescriptifGeneral.cTypeGerance
            .
        end.

    if pcTypeTrt = "RESILIATION" and ttMandat.daResiliation = ? then ttCtrat.dtree = {&dateNulle}. // outil de copie qui transforme un 01/01/0001 en ?

    run crud/ctrat_CRUD.p persistent set vhProc.
    run getTokenInstance in vhProc(mToken:JSessionId).
    run setCtrat in vhProc(table ttCtrat by-reference).
    run destroy in vhproc.
    if mError:erreur() then return.

    //il y a des lots a supprimer
    if can-find (first ttIntnt) then do:
        run crud/intnt_CRUD.p persistent set vhProc.
        run getTokenInstance in vhProc(mToken:JSessionId).
        run setIntnt in vhProc(table ttIntnt by-reference).
        run destroy in vhproc.
        if mError:erreur() then return.

        run crud/cpuni_CRUD.p persistent set vhProc.
        run getTokenInstance in vhProc(mToken:JSessionId).
        run setCpuni in vhProc(table ttCpuni by-reference).
        run destroy in vhproc.
        if mError:erreur() then return.
    end.

    if pcTypeTrt = "RESILIATION" then do:
        if ttMandat.lResiliation then do:
            for each acpte no-lock
                where acpte.tpcon = ttMandat.cCodeTypeContrat
                  and acpte.nocon = ttMandat.iNumeroContrat:
                if not valid-handle(vhProclaecha) then do:
                    run crud/aecha_CRUD.p persistent set vhProclaecha.
                    run getTokenInstance in vhProclaecha(mToken:JSessionId).
                end.
                viMoisComptable = if month(ctrat.dtree) = 12
                                  then ((year(ctrat.dtree) + 1) * 100 + 1)
                                  else (year(ctrat.dtree) * 100 + month(ctrat.dtree)).
                run deleteAechaMandatEtProprietaire in vhProclaecha(integer(mtoken:cRefGerance), ttMandat.iNumeroContrat, "00000", viMoisComptable).
                if mError:erreur() then do:
                    run destroy in vhProclaecha.
                    return.
                end.
                run deleteAechaMandatEtProprietaire in vhProclaecha(integer(mtoken:cRefGerance), acpte.nocon, string(acpte.norol, "99999"), viMoisComptable).
                if mError:erreur() then do:
                    run destroy in vhProclaecha.
                    return.
                end.
            end.
            if valid-handle(vhProclaecha) then run destroy in vhProclaecha.
            for first intnt no-lock
                where intnt.tpidt = {&TYPEBIEN-immeuble}
                  and intnt.tpcon = ttMandat.cCodeTypeContrat
                  and intnt.nocon = ttMandat.iNumeroContrat:
                viNoImmUse = intnt.noidt.
            end.
            for first intnt no-lock
                where intnt.tpidt = {&TYPEBIEN-immeuble}
                  and intnt.noidt = viNoImmUse
                  and intnt.tpcon = {&TYPECONTRAT-mandat2Syndic},
                first vbctrat no-lock
                where vbctrat.tpcon = intnt.tpcon
                  and vbctrat.nocon = intnt.nocon
                  and vbctrat.dtree = ?:
                viNoMdtSyn = vbctrat.nocon.
            end.
            for each intnt no-lock
                where intnt.tpcon = ttMandat.cCodeTypeContrat
                  and intnt.nocon = ttMandat.iNumeroContrat
                  and intnt.tpidt = {&TYPEBIEN-lot},
                first vbintnt no-lock
                where vbintnt.tpcon = {&TYPECONTRAT-acte2propriete}
                  and vbintnt.tpidt = intnt.tpidt
                  and vbintnt.noidt = intnt.noidt:
                assign
                    vcTpRolPro = ""
                    viNoRolPro = 0
                .
                if viNoMdtSyn <> 0 then
                    //Recherche copropriétaire en cours
                    for last vb2Intnt no-lock
                        where vb2Intnt.tpcon = {&TYPECONTRAT-titre2copro}
                          and vb2Intnt.tpidt = {&TYPEBIEN-lot}
                          and vb2Intnt.noidt = intnt.noidt
                          and vb2Intnt.nbden = 0:
                        assign
                            vcTpRolPro = {&TYPEROLE-coproprietaire}
                            viNoRolPro = vb2Intnt.nocon modulo 100000
                        .
                    end.
                run prcMajprop(vbintnt.tpcon, vbintnt.nocon, vcTpRolPro, viNoRolPro).
                if mError:erreur() then do:
                    mError:createError({&error}, 101152). // La mise a jour du contrat a echoue
                    return.
                end.
            end.
        end.
        else do:
            for first intnt no-lock
                where intnt.tpcon = ttMandat.cCodeTypeContrat
                  and intnt.nocon = ttMandat.iNumeroContrat
                  and intnt.tpidt = {&TYPEROLE-mandant}:
                assign
                    vcTpRolPro = intnt.tpidt
                    viNoRolPro = intnt.noidt
                .
            end.
            for each intnt no-lock
               where intnt.tpcon = ttMandat.cCodeTypeContrat
                 and intnt.nocon = ttMandat.iNumeroContrat
                 and intnt.tpidt = {&TYPEBIEN-lot},
               first vbintnt no-lock
               where vbintnt.tpcon = {&TYPECONTRAT-acte2propriete}
                 and vbintnt.tpidt = intnt.tpidt
                 and vbintnt.noidt = intnt.noidt:
               run prcMajprop(vbintnt.tpcon, vbintnt.nocon, vcTpRolPro, viNoRolPro).
               if mError:erreur() then do:
                    mError:createError({&error}, 101152). // La mise a jour du contrat a echoue
                    return.
                end.
            end.
        end.
    end.

end procedure.

procedure controleDureeDuContrat private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer ttMandat for ttMandat.

    define variable viNbMoiDur as integer no-undo.
    define variable viNbMoiMin as integer no-undo.
    define variable viNbMoiMax as integer no-undo.
    define variable voNatureContrat as class parametrageNatureContrat no-undo.

    assign
        viNbMoiDur = (if ttMandat.cUniteDuree = {&CODEPERIODE-annuel} then 12 * ttMandat.iDuree else ttMandat.iDuree)
        voNatureContrat = new parametrageNatureContrat()
    .
    voNatureContrat:getDureeContratParNature(ttMandat.cCodeNatureContrat, output viNbMoiMin, output viNbMoiMax).
    delete object voNatureContrat.
    if viNbMoiMin <> ? and viNbMoiMax <> ? then do:
        if viNbMoiDur < viNbMoiMin or viNbMoiDur > viNbMoiMax then
            mError:createErrorGestion({&error}, 101142, substitute('&2&1&3', separ[1], string(viNbMoiMin), string(viNbMoiMax))).
    end.

end procedure.

procedure calDtExp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer ttMandat for ttMandat.

    define variable viNbMoiDur as integer no-undo.

    viNbMoiDur = if ttMandat.cUniteDuree = {&CODEPERIODE-annuel} then 12 * ttMandat.iDuree else ttMandat.iDuree.
    if viNbMoiDur = 0 then return.

    ttMandat.daDateFin = add-interval(ttMandat.daDateDebut, viNbMoiDur, "months").
    do while ttMandat.daDateFin < today:
        //On boucle jusqu'a obtenir une date d'expiration supérieure à la date du jour
        ttMandat.daDateFin = add-interval(ttMandat.daDateFin, viNbMoiDur, "months").
    end.
    ttMandat.daDateFin = ttMandat.daDateFin - 1.

end procedure.

procedure PrcMajprop private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure de mise à jour du proprietaire dans l'acte (01035)
    Notes:
    ------------------------------------------------------------------------------*/
    define input parameter pcTpConUse-IN  as character no-undo.
    define input parameter piNoConUse-IN  as integer   no-undo.
    define input parameter pcTpRolUse-IN  as character no-undo.
    define input parameter piNoRolUse-IN  as integer   no-undo.

    define variable vcNomTiers      as character no-undo.
    define variable vcCiviliteTiers as character no-undo.
    define variable vhProclctrat    as handle    no-undo.

    define buffer ctrat for ctrat.

    empty temp-table ttCtrat.
    for first ctrat no-lock
        where ctrat.tpcon = pcTpConUse-IN
          and ctrat.nocon = piNoConUse-IN:
        create ttCtrat.
        if piNoRolUse-IN <> 0 then //si non remise a blanc de lbnom et lnom2
            assign
                vcNomTiers      = outilFormatage:getNomTiers(pcTpRolUse-IN, piNoRolUse-IN)
                vcCiviliteTiers = outilFormatage:getCiviliteNomTiers(pcTpRolUse-IN, piNoRolUse-IN, no)
            .
        assign
            ttCtrat.tprol       = pcTpRolUse-IN
            ttCtrat.norol       = piNoRolUse-IN
            ttCtrat.lbnom       = vcNomTiers
            ttCtrat.lnom2       = vcCiviliteTiers
            ttctrat.CRUD        = "U"
            ttCtrat.dtTimestamp = datetime(ctrat.dtmsy, ctrat.hemsy)
            ttCtrat.rRowid      = rowid(ctrat)
        .
        run crud/ctrat_CRUD.p persistent set vhProclctrat.
        run getTokenInstance in vhProclctrat(mToken:JSessionId).
        run setCtrat in vhProclctrat(table ttCtrat by-reference).
        run destroy  in vhproclctrat.
        if mError:erreur() then return.
    end.

end procedure.

procedure initAutorisationObjet:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:   service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as int64 no-undo.
    define output parameter table-handle phttAutorisation.

    define variable vhTmpAutorisation as handle no-undo.

    create temp-table phttAutorisation.
//  phttAutorisation:add-new-field ("nom","type", extent, "format", initialisation).
    phttAutorisation:add-new-field ("lSaisieRegistreAuto"      , "logical", 0, "", ?).
    phttAutorisation:add-new-field ("lGestionDescriptifGeneral", "logical", 0, "", ?).
    phttAutorisation:add-new-field ("lAnnulResiliation"        , "logical", 0, "", ?).
    phttAutorisation:add-new-field ("lModification"            , "logical", 0, "", ?).
    phttAutorisation:add-new-field ("lRenouvellement"          , "logical", 0, "", ?).
    phttAutorisation:add-new-field ("lResiliation"             , "logical", 0, "", ?).
    phttAutorisation:temp-table-prepare("ttAutorisation").
    vhTmpAutorisation = phttAutorisation:default-buffer-handle.
    run chargeAutorisation(piNumeroContrat, vhTmpAutorisation).

end procedure.

procedure chargeAutorisation private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat   as int64  no-undo.
    define input parameter phTmpAutorisation as handle no-undo.

    define variable vdaOdFinMandat as date no-undo.
    define variable vdaArchivage   as date no-undo.

    define variable voNumeroRegistreMandat as class parametrageNumeroRegistreMandat no-undo.

    define buffer ctrat for ctrat.

    find first ctrat no-lock
         where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
           and ctrat.nocon = piNumeroContrat no-error.
    if not available ctrat then do:
        mError:createError({&error}, 100057).
        return.
    end.
    phTmpAutorisation:handle:buffer-create().
    assign
        voNumeroRegistreMandat                       = new parametrageNumeroRegistreMandat()
        phTmpAutorisation::lSaisieRegistreAuto       = voNumeroRegistreMandat:isNumeroRegistreAuto()
        phTmpAutorisation::lGestionDescriptifGeneral = gestionDescriptifGeneral()
    .
    delete object voNumeroRegistreMandat.
    if ctrat.dtree <> ? then do:
        assign
            phTmpAutorisation::lAnnulResiliation = yes
            phTmpAutorisation::lModification     = no
            phTmpAutorisation::lRenouvellement   = no
            phTmpAutorisation::lResiliation      = no
        .
        run soldmdt1Controle(mToken:cRefGerance,
                             ctrat.nocon,
                             output vdaOdFinMandat,
                             output vdaArchivage).
        if vdaOdFinMandat <> ? then phTmpAutorisation::lAnnulResiliation = no.
    end.
    else
        assign
             phTmpAutorisation::lAnnulResiliation = no
             phTmpAutorisation::lModification     = yes
             phTmpAutorisation::lRenouvellement   = yes
             phTmpAutorisation::lResiliation      = yes
        .
end procedure.

procedure controleObjet:
    /*------------------------------------------------------------------------------
    Purpose: controle objet
             pour ce controle, chargement info objet du mandat dans la table ttMandat (comme pour un getObjet)
             et ensuite appel procedure verificationNonResiliation (controle avant maj)
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as int64     no-undo.

    define buffer ctrat for ctrat.

    find first ctrat no-lock
         where ctrat.tpcon = pcTypeContrat
           and ctrat.nocon = piNumeroContrat no-error.
    if not available ctrat then do:
        mError:createError({&error}, 100057).
        return.
    end.
    run getObjet("", piNumeroContrat, output table ttMandat, output table ttObjetMandatDescriptifGeneral).
    if mError:erreur() then return.

    for first ttMandat:
        ttMandat.CRUD = "U".
        goSyspr = new syspr().
        run verificationNonResiliation ("", buffer ctrat, buffer ttMandat).
        delete object goSyspr.
    end.
end procedure.
