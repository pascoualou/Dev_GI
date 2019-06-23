/*------------------------------------------------------------------------
File        : objetMandat.p
Purpose     : objet d'un mandat
Author(s)   : GGA  -  2017/08/28
Notes       : reprise du pgm adb/cont/gesobj00.p
              mais uniquement le code pour type mandat gerance
------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/type2role.i}
{preprocesseur/type2tache.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/type2bien.i}
{preprocesseur/codePeriode.i}
{preprocesseur/mode2reglement.i}
{preprocesseur/referenceClient.i}

using parametre.pclie.parametrageFournisseurLoyer.
using parametre.pclie.parametrageDefautMandat.
using parametre.pclie.parametragePayePegase.
using parametre.pclie.parametrageCodeESI.
using parametre.pclie.parametrageOrigineClient.
using parametre.pclie.parametrageNumeroRegistreMandat.
using parametre.pclie.pclie.
using parametre.syspr.syspr.
using parametre.syspg.syspg.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{application/include/glbsepar.i}
{application/include/combo.i}
{application/include/error.i}
{mandat/include/mandat.i}
{mandat/include/objetMandat.i}
{adblib/include/ctrat.i}
{adblib/include/intnt.i}
{immeubleEtLot/include/cpuni.i}

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
         and intnt.tpidt = {&TYPEBIEN-lot}
    , first local no-lock
      where local.noloc = intnt.noidt
    , first cpuni no-lock
      where cpuni.nomdt = piNumeroContrat
        and cpuni.noapp = 998
        and cpuni.nocmp = 10
        and cpuni.nolot = local.nolot:
        if local.fgdiv and cpuni.sflot <> local.sfree then return yes. 
   end.  
   return no.               
                   
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
         and intnt.tpidt = {&TYPEBIEN-lot}
    , first local no-lock
      where local.noloc = intnt.noidt
    , first cpuni no-lock
      where cpuni.nomdt = piNumeroContrat
        and cpuni.noapp = 998
        and cpuni.nocmp = 10
        and cpuni.nolot = local.nolot:
        if (local.fgdiv and cpuni.sflot = local.sfree) or not local.fgdiv
        then do: 
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
   if can-find(first ttIntnt) then return yes.
   return no.               
                                    
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
                      and ctrat.ntcon <> {&NATURECONTRAT-specialVacant}      /* Ajout SY le 29/06/2015 : ignorer bail spécial vacant propriétaire */
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

    define variable vcTypTacheRenouvDate as character no-undo.

    define buffer ctrat for ctrat.
    define buffer tache for tache.

    find first ctrat no-lock
        where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and ctrat.nocon = piNumeroContrat no-error.
    if not available ctrat
    then do:
        mError:createError({&error}, 100057).
        return.
    end.
    empty temp-table ttMandat.
    empty temp-table ttObjetMandatDescriptifGeneral.
    run lectInfoCtrat(piNumeroContrat).

    if pcTypeTrt = "RENOUVELLEMENT"
    then do:
        /*--> info sur date de renouvellement mais valid impossible si proc de renou */
        find last tache no-lock
            where tache.tpcon = ttMandat.cCodeTypeContrat
              and tache.nocon = ttMandat.iNumeroContrat
              and tache.tptac = {&TYPETACHE-renouvellement} no-error.
        if available tache
        then do:                                                                // Info date de renouvellement mais validation impossible
            if tache.tpfin = "30"
            then do:
                vcTypTacheRenouvDate = entry(num-entries(tache.cdhon, "#") - 2, tache.cdhon, "#").
                case entry(2, vcTypTacheRenouvDate, "&"):
                    when "00009" then ttMandat.daDateDebut = tache.dtfin + 1.   // Renouvellement sur la base du bail
                    when "00010" then ttMandat.daDateDebut = tache.dtreg.       // Renouvellement sur la base de l'offre
                    when "00011" then ttMandat.daDateDebut = tache.dtreg.       // Renouvellement sur la base de jugement
                end case.
                run calDtExp(buffer ttMandat).
            end.
        end.
        else if ttMandat.daDateFin < today
        then do:
            ttMandat.daDateDebut = ttMandat.daDateFin + 1.
            run calDtExp(buffer ttMandat).
        end.
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

    find first ttMandat where (ttMandat.CRUD = "C" or ttMandat.CRUD = "U") no-error.
    if not available ttMandat
    then return.
    find first ctrat no-lock
        where ctrat.tpcon = ttMandat.cCodeTypeContrat
          and ctrat.nocon = ttMandat.iNumeroContrat no-error.
    if not available ctrat
    then do:
        mError:createError({&error}, 100057).
        return.
    end.
    goSyspr = new syspr().
    run verZonSai (pcTypeTrt, buffer ctrat, buffer ttMandat).
    delete object goSyspr.
    if mError:erreur() then return.

    run ValMajEcr (pcTypeTrt, buffer ttMandat).
    if mError:erreur() then return.

    run majCtrat (pcTypeTrt, buffer ctrat, buffer ttMandat).

end procedure.

procedure lectInfoCtrat private:
    /*------------------------------------------------------------------------------
    Purpose: affichage information objet d'un mandat
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as integer no-undo.

    define variable vcCodCombo as character                no-undo.
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
            ttMandat.lTaciteReconduction           = (ctrat.tpren = "00001")
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
            ttMandat.cDureeMax                     = if ctrat.fgdurmax = no and ctrat.nbrenmax <> 0 then "2" else "1"
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
        for first idev no-lock
            where idev.soc-cd = integer(mtoken:cRefGerance)
              and idev.dev-cd = ttMandat.cCodeDevise: 
            ttMandat.cLibelleCodeDevise = idev.lib.
        end.
        case ttMandat.cDureeMax:
                when "1" then ttMandat.cLibelleDureeMax = outilTraduction:getLibelle(110292).      
                when "2" then ttMandat.cLibelleDureeMax = outilTraduction:getLibelle(110293).  
        end case.    
        voPclie = new pclie("CDORI", ttMandat.cOrigineClient).
        ttMandat.cLibelleOrigineClient = voPclie:zon02.     
        voCodeESI = new parametrageCodeESI().
        if voCodeESI:isDbParameter
        then assign
            ttMandat.iCodeEsi       = ctrat.pcpte
            ttMandat.lSaisieCodeEsi = yes
        .
        delete object voCodeESI.
        
        if gestionDescriptifGeneral ()
        then do:
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
            voPclie:reload("AGF03", cNature).
            ttObjetMandatDescriptifGeneral.cLibelleNature = voPclie:zon02.
            voPclie:reload("AGF04", cUsagePrincipal).
            ttObjetMandatDescriptifGeneral.cLibelleUsagePrincipal = voPclie:zon02.
            voPclie:reload("AGF04", cUsageSecondaire).
            ttObjetMandatDescriptifGeneral.cLibelleUsageSecondaire = voPclie:zon02.            
            voPclie:reload("AGF05", cStatut).
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
    define parameter buffer ttMandat for ttMandat.

    define variable voDefautMandat         as class parametrageDefautMandat         no-undo.
    define variable voNumeroRegistreMandat as class parametrageNumeroRegistreMandat no-undo.    

    assign
        ttMandat.lTaciteReconduction = yes
        ttMandat.cTypeActe           = "00000"
        voDefautMandat               = new parametrageDefautMandat()
    .
    if voDefautMandat:isDbParameter 
    then assign
             ttMandat.iDuree                        = voDefautMandat:getGenerauxDuree()
             ttMandat.cUniteDuree                   = voDefautMandat:getGenerauxUniteDuree()
             ttMandat.iDelaiResiliation             = voDefautMandat:getGenerauxDelaiResiliation()
             ttMandat.cUniteDelaiResiliation        = voDefautMandat:getGenerauxUniteDelaiResiliation()
             ttMandat.cUniteDureeMax                = voDefautMandat:getGenerauxUniteDuree()
             ttMandat.cLibelleUniteDuree            = outilTraduction:getLibelleParam("UTDUR", ttMandat.cUniteDuree)
             ttMandat.cLibelleUniteDelaiResiliation = outilTraduction:getLibelleParam("UTDUR", ttMandat.cUniteDelaiResiliation)
             ttMandat.cLibelleUniteDureeMax         = outilTraduction:getLibelleParam("UTDUR", ttMandat.cUniteDureeMax)
             ttMandat.cCodeTypeRenouvellement       = "00001"
             ttMandat.lTaciteReconduction           = yes
    .
    delete object voDefautMandat.
    voNumeroRegistreMandat = new parametrageNumeroRegistreMandat().
    if voNumeroRegistreMandat:isNumeroRegistreAuto()
    then ttMandat.cNumeroReelRegistre = "AUTO".
    delete object voNumeroRegistreMandat.    

end procedure.

procedure RecVilCab:
    /*------------------------------------------------------------------------------
    Purpose: recuperation de la ville du cabinet/gerant
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define parameter buffer ttMandat for ttMandat.

    define variable vcTypeMandat    as character no-undo.
    define variable vcNatureContrat as character no-undo.
    define variable viNumeroContrat as integer   no-undo.

    define buffer sys_pg for sys_pg.
    define buffer intnt for intnt.
    define buffer ladrs for ladrs.
    define buffer adres for adres.

    for first sys_pg no-lock
        where sys_pg.tppar = "R_CR1"
          and sys_pg.zone1 = ttMandat.cCodeNatureContrat
          and sys_pg.zone7 <> "P"
      , last intnt no-lock
        where intnt.tpcon = ttMandat.cCodeTypeContrat
          and intnt.nocon = ttMandat.iNumeroContrat
          and intnt.tpidt = sys_pg.zone2
      , first ladrs no-lock
        where ladrs.tpidt = sys_pg.zone2
          and ladrs.noidt = intnt.noidt
          and ladrs.tpadr = "00001"
      , first adres no-lock
        where adres.noadr = ladrs.noadr:
        ttMandat.cLieuSignature = adres.lbvil.
    end.

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

    define buffer vbttCombo for ttCombo.

    empty temp-table ttCombo.

    voSyspg = new syspg().
    voSyspr = new syspr().
    voSyspr:getComboParametre("UTDUR", "CMBUNITEDUREE", output table ttCombo by-reference).
    voSyspr:getComboParametre("TPACT", "CMBTYPEACTE", output table ttCombo by-reference).
    voSyspr:getComboParametre("TPMOT", "CMBMOTIFRESILIATION", output table ttCombo by-reference).
    delete object voSyspr.
    voOrigineClient = new parametrageOrigineClient().
    voOrigineClient:getComboParametre("CMBORIGINECLIENT", output table ttCombo by-reference).
    delete object voOrigineClient.  
    voSyspg:creationttCombo("CMBORIGINECLIENT", "", "-", output table ttCombo by-reference).
    
    find last ttCombo no-error.
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
     
    if gestionDescriptifGeneral ()
    then do:
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

procedure verZonSai private:
    /*------------------------------------------------------------------------------
    Purpose: controle infos objet mandat avant maj
    Notes  : ancien (verZonSai, blc-val-menu)
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeTrt as character no-undo.
    define parameter buffer ctrat for ctrat.
    define parameter buffer ttMandat for ttMandat.

    define variable vcLbTmpPdt         as character no-undo.
    define variable viNiveauPaiePegase as integer   no-undo.
    define variable vdaEffMin          as date      no-undo.
    define variable vdaEffMax          as date      no-undo.
    define variable vdaDtsMin          as date      no-undo.
    define variable vdaDtsMax          as date      no-undo.
    define variable viRetourQuestion   as integer   no-undo.
    define variable vhProcctrconvm     as handle    no-undo.
    define variable vcCdRetUse         as character no-undo.
    define variable voPayePegase as class parametragePayePegase no-undo.

    define buffer vbctrat for ctrat.
    define buffer etabl   for etabl.
    define buffer svtrf   for svtrf.
    define buffer ctctt   for ctctt.
    define buffer trdos   for trdos.
    define buffer tache   for tache.
    define buffer trfpm   for trfpm.

    /*--> On teste la partie haute si on n'est pas en resiliation */
    if pcTypeTrt <> "RESILIATION"
    then do:
        /*--> Numero Reel de Contrat. Uniquement si contrat <> bail */
        if ttMandat.cNumeroReelRegistre = "" or ttMandat.cNumeroReelRegistre = ?
        then do:
            mError:createError({&error}, 100071).
            return.
        end.
        /*--> Date du 1er contrat */
        if ttMandat.daDateInitiale = ?
        then do:
            mError:createError({&error}, 104078).
            return.
        end.
        /*--> Date d'Effet. */
        if ttMandat.daDateDebut = ?
        then do:
            /* la date d'effet est obligatoire */
            mError:createError({&error}, 100072).
            return.
        end.
        if ttMandat.daDateInitiale > ttMandat.daDateDebut
        then do:
            mError:createError({&error}, 104079).
            return.
        end.
        /* Date limite de reconduction du mandat */
        if ttMandat.cDureeMax = "1"
        then do:
            if ttMandat.iDureeMax = 0
            then do:
                mError:createError({&error}, 110290).
                return.
            end.
        end.
        else do:
            if ttMandat.iNbRenouvellementMax= 0
            then do:
                mError:createError({&error}, 110291).
                return.
            end.
        end.
        if pcTypeTrt = "RENOUVELLEMENT"
        and ctrat.dtdeb <> ? and ttMandat.daDateDebut < ctrat.dtdeb
        then do:
            mError:createErrorGestion({&error}, 101955, string(ctrat.dtdeb, "99/99/9999")).
            return.
        end.
        if day(today) = 29 and month(today) = 2
        then assign
            vdaEffMin = date(3, 1, year(today) - 98) - 1
            vdaEffMax = date(3, 1, year(today) + 1) - 1.
        else assign
            vdaEffMin = date(month(today), day(today), year(today) - 98)
            vdaEffMax = date(month(today), day(today), year(today) + 1).
        if ttMandat.daDateDebut <= vdaEffMin or ttMandat.daDateDebut >= vdaEffMax
        then do:
            /* La date d'effet doit être supérieure au %1 et inférieure au %2   */
            /* Fiche 0314/0106 : La date d'effet doit être supérieure au 01/03/1916 et inférieure au 11/03/2015 */
            /* Fiche 0314/0106 : amélioration message d'anomalie pour savoir la date d'effet utilisée ( c.f. an 3000 dans les procédures de RENOUVELLELEMENT ) */
            // Date d'effet incorrecte &1. La date d'effet doit être supérieure au &2 et inférieure au &3
            mError:createError({&error}, 1000430, substitute("&2&1&3&1&4", separ[1], if ttMandat.daDateDebut <> ? then string(ttMandat.daDateDebut) else " ", string(vdaEffMin), string(vdaEffMax))).
            return.
        end.
        /*--> Duree du Contrat */
        if ttMandat.iDuree = ?
        then do:
            mError:createError({&error}, 100073).
            return.
        end.
        /*--> Unite Duree du Contrat. */
        if goSyspr:isParamExist("UTDUR", ttMandat.cUniteDuree) = no     
        then do:
            mError:createError({&error}, 100074).
            return.
        end.
        /* controle de la durée du contrat */
        run ctlDuCtt(buffer ttMandat).
        if mError:erreur() then return.

        if ttMandat.daDateFin = ?         /*--> Date d'Expiration. */
        then do:
            mError:createError({&error}, 100075).
            return.
        end.
        if ttMandat.daDateFin <= ttMandat.daDateDebut
        then do:
            mError:createError({&error}, 100076).
            return.
        end.
        /*--> Delai de resiliation*/
        if ttMandat.iDelaiResiliation = ?
        then do:
            mError:createError({&error}, 100077).
            return.
        end.
        if ttMandat.iDelaiResiliation = 0
        then do:
            mError:createError({&error}, 102045).
            return.
        end.
        /*--> Unite de Delai de resiliation */
        if not can-find (first sys_pr no-lock
                         where sys_pr.tppar = "UTDUR"
                           and sys_pr.cdpar = ttMandat.cUniteDelaiResiliation
                           and sys_pr.cdpar <> "00001" )
        then do:
            mError:createError({&error}, 100078).
            return.
        end.
        if integer(mtoken:cRefPrincipale) <> 10    /*--> Date de Signature */
        then do:
            if ttMandat.daSignature = ?
            then do:
                mError:createError({&error}, 100079).
                return.
            end.
            /*--> date de signature à + ou - 1 an de la date du 1er contrat */
            assign
                vdaDtsMin = ttMandat.daDateInitiale
                vdaDtsMin = date( month(vdaDtsMin), 1, year(vdaDtsMin) - 1 )
                vdaDtsMax = ttMandat.daDateInitiale
            .
            if month(vdaDtsMin) = 12
            then vdaDtsMax = date(01, 01, year(vdaDtsMax) + 2) - 1.
            else vdaDtsMax = date(month(vdaDtsMin) + 1, 1, year(vdaDtsMax) + 1) - 1.
            if ttMandat.daSignature > vdaDtsMax or ttMandat.daSignature < vdaDtsMin
            then do:
                if outils:questionnaire(107343, table ttError by-reference) <= 2
                then return.
            end.
            /*--> Lieu de Signature. */
            if ttMandat.cLieuSignature = ? or ttMandat.cLieuSignature = ""
            then do:
                mError:createError({&error}, 100081).
                return.
            end.
        end.
        if goSyspr:isParamExist("TPACT", ttMandat.cTypeActe) = no     
        then do:
            mError:createError({&error}, 100082).
            return.
        end.
        find first ttObjetMandatDescriptifGeneral no-error.
        if gestionDescriptifGeneral ()
        and not available ttObjetMandatDescriptifGeneral 
        then do:
            mError:createError({&error}, "info specifique allianz agf obligatoire").
            return.                
        end.
        else 
        if available ttObjetMandatDescriptifGeneral 
        and ttObjetMandatDescriptifGeneral.cStatut > "" and ttObjetMandatDescriptifGeneral.daEffetStatut = ?
        then do:
            mError:createError({&error}, "La date de statut est obligatoire").
            return.
        end.
    end.
    if pcTypeTrt = "RESILIATION"
    then do:
        /*--> Date de resiliation. */
        if ttMandat.daResiliation = ? and ttMandat.lResiliation = yes
        then do:
            mError:createError({&error}, 100083).
            return.
        end.
        /*--> Date resiliation >= date 1er contrat */
        if ttMandat.daResiliation < ctrat.dtini
        then do:
            mError:createError({&error}, 105575).        /*La date de résiliation doit être postérieure à la date du 1er contrat.*/
            return.
        end.
        /*--> Date resiliation >= date signature */
        if ttMandat.daResiliation < ctrat.dtsig
        then do:
            mError:createError({&error}, 102047).        /*La date de résiliation doit être postérieure à la date de signature !!*/
            return.
        end.
        /*--> Date resiliation <= date expiration */
        if ttMandat.daResiliation > ctrat.dtfin
        and outils:questionnaireGestion(110374, substitute('&2&1', separ[1], string(ttMandat.daResiliation)), table ttError by-reference) <= 2    /*La date de résiliation doit être postérieure à la date de signature !!*/
        then return.

        /*--> Motif de resiliation. */
        if ttMandat.cMotifResiliation = "" or ttMandat.cMotifResiliation = ?
        then do:
            mError:createError({&error}, 100085).        /*La date de résiliation doit être postérieure à la date de signature !!*/
            return.
        end.
        if goSyspr:isParamExist("TPMOT", ttMandat.cMotifResiliation) = no
        or not (ttMandat.cMotifResiliation = "00000" or ttMandat.cMotifResiliation < "10002" or ttMandat.cMotifResiliation begins "12")
        then do:
            mError:createError({&error}, 1000420).                       //Motif de résiliation incorrect
            return.
        end.
        if ttMandat.lResiliation = yes
        then do:
            /*--> ATTENTION  : Interdit de resilier si */
            /*        * contrat principal avec des contrats annexes actifs  */
            /*        * mandat de gerance avec encore des lots rattaches    */
            /*        * mandat de gerance ou syndic avec Paie active ou mois non terminee    */
            /* SY 0114/0244 Si Paie MaGI encore active... */
            voPayePegase = new parametragePayePegase().
            if voPayePegase:isDbParameter then viNiveauPaiePegase = voPayePegase:iNiveauPaiePegase.
            delete object voPayePegase.
            if viNiveauPaiePegase < 2
            then for first etabl no-lock
                where etabl.tpcon = ttMandat.cCodeTypeContrat
                  and etabl.nocon = ttMandat.iNumeroContrat:
                /* recherche si interruption gestion de la paie */
                if etabl.fgint = no
                then do:
                    assign
                        ttMandat.lResiliation      = no
                        ttMandat.daResiliation     = ?
                        ttMandat.cMotifResiliation = ""
                    .
                    mError:createError({&error}, 108809).
                    return.
                end.
                /* Recherche si dernier mois de paie termine */
                for last svtrf no-lock
                    where svtrf.cdtrt = "PAIE":
                    if etabl.msint >= svtrf.mstrt and svtrf.nopha > "00001" and svtrf.nopha < "00019"
                    then do:
                        assign
                            ttMandat.lResiliation      = no
                            ttMandat.daResiliation     = ?
                            ttMandat.cMotifResiliation = ""
                            vcLbTmpPdt                 = substitute("&1/&2", string(svtrf.mstrt modulo 100, "99"), string(truncate(svtrf.mstrt / 100, 0), "9999"))
                        .
                        mError:createErrorGestion({&error}, 108810, vcLbTmpPdt).
                        return.
                    end.
                end.
            end.

            for each ctctt no-lock
                where ctctt.tpct1 = ttMandat.cCodeTypeContrat
                  and ctctt.noCt1 = ttMandat.iNumeroContrat
                  and ctctt.tpct2 = {&TYPECONTRAT-assuranceGerance}:
                if can-find(first vbctrat no-lock
                            where vbctrat.Tpcon = ctctt.tpct2
                              and vbctrat.Nocon = ctctt.noct2
                              and vbctrat.dtree = ?)
                then do:
                    assign
                        ttMandat.lResiliation      = no
                        ttMandat.daResiliation     = ?
                        ttMandat.cMotifResiliation = ""
                    .
                    mError:createError({&error}, 1000421).       //Vous ne pouvez pas résilier ce mandat avant d'avoir résilié les contrats d'assurance associés !!
                    return.
                end.
            end.
            /* 0607/0250 : il ne doit pas y avoir de compensation locataire sur le propriétaire de ce mandat */
            for each tache no-lock
                where tache.tpcon = {&TYPECONTRAT-bail}
                  and tache.tptac = {&TYPETACHE-quittancement}
                  and tache.cdreg = {&MODEREGLEMENT-compensation}
                  and tache.etab-cd = ttMandat.iNumeroContrat
                  and tache.cptg-cd = "4111"
              , first vbctrat no-lock
                where vbctrat.tpcon = tache.tpcon
                  and vbctrat.nocon = tache.nocon
                  and vbctrat.dtree = ?:
                mError:createError({&error}, 1000422, substitute('&2&1&3', separ[1], tache.nocon, outilFormatage:getNomTiers("00019", tache.nocon))).
                return.
            end.

            if bauxActifs (ttMandat.iNumeroContrat, ttMandat.cCodeTypeContrat)
            then do:
                viRetourQuestion = outils:questionnaire(1000423, table ttError by-reference).    //Vous ne pouvez pas résilier ce mandat tant qu'il reste des baux actifs. Voulez-vous accéder aux mutations de gérance ?
                if viRetourQuestion < 2 then return.

                //si on revient la avec oui (3), c'est que l'on est passe par le pgm de mutation et donc il ne devrait plus y avoir de baux actif
                if (viRetourQuestion = 3 and bauxActifs (ttMandat.iNumeroContrat, ttMandat.cCodeTypeContrat))
                or viRetourQuestion = 2
                then do:
                    assign
                        ttMandat.lResiliation      = no
                        ttMandat.daResiliation     = ?
                        ttMandat.cMotifResiliation = ""
                    .
                    mError:createError({&error}, 1000425).  //Vous ne pouvez pas résilier ce mandat, il reste des baux actifs.
                    return.
                end.
            end.

            /* Recherche si lots encore rattaches */
            if resteLotNonLibre (ttMandat.iNumeroContrat, ttMandat.cCodeTypeContrat)
            then do:
                viRetourQuestion = outils:questionnaire(1000431, substitute('&2&1', separ[1], ""), table ttError by-reference).    //Vous ne pouvez pas résilier ce mandat tant qu'il reste des lots rattachés. Voulez-vous accéder aux mutations de gérance ?
                if viRetourQuestion < 2 then return.

                //si on revient la avec oui (3), c'est que l'on est passe par le pgm de mutation et donc il ne devrait plus y avoir de lots rattachés
                if (viRetourQuestion = 3 and resteLotNonLibre (ttMandat.iNumeroContrat, ttMandat.cCodeTypeContrat))
                or viRetourQuestion = 2
                then do:
                    assign
                        ttMandat.lResiliation      = no
                        ttMandat.daResiliation     = ?
                        ttMandat.cMotifResiliation = ""
                    .
                    mError:createError({&error}, 1000424).  //Vous ne pouvez pas résilier ce mandat tant que des lots lui sont rattachés
                    return.
                end.
            end.

            /* si lot libre encore sur le mandat demande de confirmation pour la suppression automatique */
            empty temp-table ttIntnt.
            empty temp-table ttCpuni.
            if resteLotLibre (ttMandat.iNumeroContrat, ttMandat.cCodeTypeContrat)    //la fonction va retourner oui si reste lot libre et faire en meme temps la creation de la temp-table pour suppression de ces lots
            then do:
                viRetourQuestion = outils:questionnaire(1000759, table ttError by-reference).    //il reste des lots libres sur ce mandat, confirmez vous la suppression de ces lots ?
                if viRetourQuestion < 2 then return.                                    //si reponse non on vide la temp-table pour la suppression des lots
                if viRetourQuestion = 2 
                then do:
                    empty temp-table ttIntnt.
                    empty temp-table ttCpuni.
                end.  
            end.

            /* Controle : Dossier travaux cloturés mais pas transmis à GI */
            for each trdos no-lock
               where trdos.tpcon = ttMandat.cCodeTypeContrat
                 and trdos.nocon = ttMandat.iNumeroContrat
                 and trdos.dtree <> ?:
                /*--> Verifier si la cloture n'a pas déjà été traitée */
                find first trfpm no-lock
                     where trfpm.tptrf = "AP"
                       and trfpm.tpapp = "CX"
                       and trfpm.nomdt = trdos.nocon
                       and trfpm.noexe = trdos.nodos no-error.
                if not available trfpm or trfpm.ettrt = "00001" or trfpm.ettrt = "00011"
                then do:
                    mError:createError({&error}, 1000426, string(trdos.nodos)). //La demande de tirage de clôture travaux n'a pas été traitée pour le dossier travaux n° &1. Résiliation impossible.
                    return.
                end.
                /*--> Verifier si la cloture a été traitée mais pas intégrée */
                if not can-find (first trfpm no-lock
                                 where trfpm.tptrf = "AP"
                                   and trfpm.tpapp = "CX"
                                   and trfpm.nomdt = trdos.nocon
                                   and trfpm.noexe = trdos.nodos
                                   and (trfpm.ettrt = "00003" or trfpm.ettrt = "00013" or trfpm.ettrt = "00099"))
                then do:
                    mError:createError({&error}, 1000427, string(trdos.nodos)). //La clôture travaux n'a pas été intégrée pour le dossier travaux n° &1. Résiliation impossible ! 
                    return.
                end.
            end.

            /* Controle : dossiers travaux non clôturés sur ce contrat */
            if can-find (first trdos no-lock
                         where trdos.tpcon = ttMandat.cCodeTypeContrat
                           and trdos.nocon = ttMandat.iNumeroContrat
                           and trdos.dtree = ?)
            and outils:questionnaire(1000428, table ttError by-reference) <= 2 then return. //Il existe des dossiers travaux non clôturés sur ce contrat. Confirmez-vous la résiliation du contrat ?

            if ttMandat.daOdFinMandat <> ?
            then do:
                //transformation du message d'erreur par question avec confirmation pour l'afficher
                if outils:questionnaire(1000429, table ttError by-reference) <= 2    //Attention l'ODFM solde l'intégralité des écritures du mandat, assurez vous que vous avez effectué tous vos traitements comptables sur ce mandat
                then return.

                run adblib/ctrconvm.p persistent set vhProcctrconvm.
                run getTokenInstance in vhProcctrconvm(mToken:JSessionId).
                run ctrconvmControle in vhProcctrconvm (ttMandat.cCodeTypeContrat, ttMandat.iNumeroContrat, ttMandat.daResiliation, ttMandat.cMotifResiliation, ttMandat.daOdFinMandat, output vcCdRetUse).
                run destroy in vhprocctrconvm.
                if vcCdRetUse <> "00" then return.

                if outils:questionnaireGestion(107045, substitute('&2&1&3&1&4&1&5', separ[1], string(ttMandat.iNumeroContrat), outilTraduction:getLibelleProg('O_ROL', ctrat.tprol), string(ctrat.norol,"99999"), ctrat.lnom2),
                                               table ttError by-reference) <= 2    //Confirmation de la resiliation avec OD Automatique de Fin de gestion
                then return.
            end.
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

    ttMandat.cCodeTypeRenouvellement = if ttMandat.lTaciteReconduction then "00001" else "00000".
    if pcTypeTrt = "RESILIATION"  
    then do:
        if ttMandat.lResiliation = no
        then assign
            ttMandat.lResiliation      = no
            ttMandat.daResiliation     = ?
            ttMandat.cMotifResiliation = ""
        .
        else do:
            if ttMandat.daOdFinMandat <> ?
            then do:
                run cadbgestion/soldmdt2.p persistent set vhSoldmdt2.
                run getTokenInstance in vhSoldmdt2(mToken:JSessionId).
                run soldmmdt2Lancement in vhSoldmdt2(integer(mtoken:cRefGerance),
                                                     ttMandat.iNumeroContrat,
                                                     ttMandat.daOdFinMandat,
                                                     ttMandat.daResiliation,
                                                     output viRetPgm).
                if viRetPgm > 0
                then do:
                    case viRetPgm:
                        when 2  then mError:createError({&error}, 105729 ). // Société compta absente
                        when 3  then mError:createErrorGestion({&error}, 102540, string(ttMandat.iNumeroContrat)). // Mandat %1 inexistant en comptabilite (ietab)
                        when 4  then mError:createError({&error}, 000314 ). // Période absente (comptabilité)
                        otherwise mError:createError({&information}, 107052, string(viRetPgm)). // La résiliation avec OD automatique de fin de gestion est incomplète (erreur n°%1)%sVous devrez intervenir manuellement
                    end case.
                end.
            end.
            if mError:erreur() then return.
            /* Ajout SY le 01/04/2008 - 1007/0003 : recherche paramétrage bureautique "Dossier automatique" */
//            run GenEvent.     //gga todo
        end.
    end.

end procedure.

procedure majCtrat private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : ValMajEcr-2 dans gesobj00.p
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeTrt as character no-undo.
    define parameter buffer ctrat for ctrat.
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
    if gestionDescriptifGeneral ()
    then for first ttObjetMandatDescriptifGeneral: 
        assign
            ttCtrat.cdetat           = ttObjetMandatDescriptifGeneral.cEtatConstrucRestruc
            ttCtrat.cdconst-rest     = (if ttObjetMandatDescriptifGeneral.lEnConstrucRestruc then "00001" else "00002")  
            ttCtrat.cdclassification = ttObjetMandatDescriptifGeneral.cClassification
            ttCtrat.cdnature         = ttObjetMandatDescriptifGeneral.cNature
            ttCtrat.cdusage1         = ttObjetMandatDescriptifGeneral.cUsagePrincipal
            ttCtrat.cdusage2         = ttObjetMandatDescriptifGeneral.cUsageSecondaire
            ttCtrat.cdstatutventes   = ttObjetMandatDescriptifGeneral.cStatut
            ttCtrat.dtstatutventes   = ttObjetMandatDescriptifGeneral.daEffetStatut
            ttCtrat.tpgerance        = ttObjetMandatDescriptifGeneral.cTypeGerance
        .
    end.

    if pcTypeTrt = "RESILIATION" and ttMandat.daResiliation = ?
    then ttCtrat.dtree = 01/01/0001.                    // outil de copie qui transforme un 01/01/0001 en ?

    run adblib/ctrat_CRUD.p persistent set vhProc.
    run getTokenInstance in vhProc(mToken:JSessionId).
    run setCtrat in vhProc(table ttCtrat by-reference).
    run destroy in vhproc.
    if mError:erreur() then return.

    if can-find (first ttIntnt)          //il y a des lots a supprimer
    then do:
    
        run adblib/intnt_CRUD.p persistent set vhProc.
        run getTokenInstance in vhProc(mToken:JSessionId).
        run setIntnt in vhProc(table ttIntnt by-reference).
        run destroy in vhproc.
        if mError:erreur() then return.   
             
        run immeubleEtLot/cpuni_CRUD.p persistent set vhProc.
        run getTokenInstance in vhProc(mToken:JSessionId).
        run setCpuni in vhProc(table ttCpuni by-reference).
        run destroy in vhproc.
        if mError:erreur() then return.      
          
    end.    

    if pcTypeTrt = "RESILIATION"
    then do:
        if ttMandat.lResiliation = yes
        then do:
            /*==> SG On nettoie les échéanciers des acomptes mandat et propriétaire ==*/
                /*==> N° Compte = N° Role mandant pour acompte propriétaire ==*/
                /*==>           = "00000" pour acompte mandat               ==*/
            for each acpte no-lock     // todo  vérifier pouquoi pas d'index sur acpte
                where acpte.nocon = ttMandat.iNumeroContrat:
                if not valid-handle(vhProclaecha)
                then do:
                    run adblib/aecha_CRUD.p persistent set vhProclaecha.
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
                  and intnt.tpcon = {&TYPECONTRAT-mandat2Syndic}
              , first vbctrat no-lock
                where vbctrat.tpcon = intnt.tpcon
                  and vbctrat.nocon = intnt.nocon
                  and vbctrat.dtree = ?:
                viNoMdtSyn = vbctrat.nocon.
            end.
            for each intnt no-lock
                where intnt.tpcon = ttMandat.cCodeTypeContrat
                  and intnt.nocon = ttMandat.iNumeroContrat
                  and intnt.tpidt = {&TYPEBIEN-lot}
              , first vbintnt no-lock
                where vbintnt.tpcon = {&TYPECONTRAT-acte2propriete}
                  and vbintnt.tpidt = intnt.tpidt
                  and vbintnt.noidt = intnt.noidt:
                assign
                    vcTpRolPro = ""
                    viNoRolPro = 0
                .
                if viNoMdtSyn <> 0
                then for last vb2Intnt no-lock                      /*--> Recherche copropriétaire en cours */
                    where vb2Intnt.tpcon = {&TYPECONTRAT-titre2copro}
                      and vb2Intnt.tpidt = {&TYPEBIEN-lot}
                      and vb2Intnt.noidt = intnt.noidt
                      and vb2Intnt.nbden = 0:
                    assign
                        vcTpRolPro = {&TYPEROLE-coproprietaire}
                        viNoRolPro = vb2Intnt.nocon modulo 100000
                    .
                end.
                run PrcMajprop (vbintnt.tpcon, vbintnt.nocon, vcTpRolPro, viNoRolPro).
                if mError:erreur() 
                then do:
                    /*--> La mise a jour du contrat a echoue */
                    mError:createError({&error}, 101152).
                    return.
                end.
            end.
        end.
        else do:
            /*--> Recuperation mandant */
            for first intnt no-lock
                where intnt.tpcon = ttMandat.cCodeTypeContrat
                  and intnt.nocon = ttMandat.iNumeroContrat
                  and intnt.tpidt = {&TYPEROLE-mandant}:
                assign
                    vcTpRolPro = intnt.tpidt
                    viNoRolPro = intnt.noidt.
            end.
            for each intnt no-lock
               where intnt.tpcon = ttMandat.cCodeTypeContrat
                 and intnt.nocon = ttMandat.iNumeroContrat
                 and intnt.tpidt = {&TYPEBIEN-lot}
            , first vbintnt no-lock
              where vbintnt.tpcon = {&TYPECONTRAT-acte2propriete}
                and vbintnt.tpidt = intnt.tpidt
                and vbintnt.noidt = intnt.noidt:
                run PrcMajprop (vbintnt.tpcon, vbintnt.nocon, vcTpRolPro, viNoRolPro).
                if mError:erreur()
                then do:
                    /*--> La mise a jour du contrat a echoue */
                    mError:createError({&error}, 101152).
                    return.
                end.
            end.
        end.
    end.

end procedure.

procedure ctlDuCtt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer ttMandat for ttMandat.

    define variable viNbMoiDur as integer no-undo.
    define variable viNbMoiMin as integer no-undo.
    define variable viNbMoiMax as integer no-undo.

    define buffer sys_pg for sys_pg.

    viNbMoiDur = if ttMandat.cUniteDuree = {&CODEPERIODE-annuel} then 12 * ttMandat.iDuree else ttMandat.iDuree.
    for first sys_pg no-lock
        where sys_pg.tppar begins "O_COT"
          and sys_pg.cdpar = ttMandat.cCodeNatureContrat
          and sys_pg.zone9 > "":
        assign
            viNbMoiMin = integer(entry(1, sys_pg.zone9, "@"))
            viNbMoiMax = integer(entry(2, sys_pg.zone9, "@"))
        .
        if viNbMoiDur < viNbMoiMin or viNbMoiDur > viNbMoiMax
        then do:
            mError:createErrorGestion({&error}, 101142, substitute('&2&1&3', separ[1], string(viNbMoiMin), string(viNbMoiMax))).
            return.
        end.
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

    ttMandat.daDateFin = add-interval(ttMandat.daDateDebut, viNbMoiDur, "month").
    do while ttMandat.daDateFin < today:
        /*--> On boucle jusqu'a obtenir une date d'expiration supérieure à la date du jour */
        ttMandat.daDateFin = add-interval(ttMandat.daDateFin, viNbMoiDur, "month").
    end.
    ttMandat.daDateFin = ttMandat.daDateFin - 1.

end procedure.

procedure PrcMajprop private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure de mise … jour du proprietaire dans l'acte (01035)
    Notes:
    ------------------------------------------------------------------------------*/
    define input parameter  pcTpConUse-IN  as character no-undo.
    define input parameter  piNoConUse-IN  as integer   no-undo.
    define input parameter  pcTpRolUse-IN  as character no-undo.
    define input parameter  piNoRolUse-IN  as integer   no-undo.

    define variable vcLbnomUse as character no-undo.
    define variable vcLnom2Use as character no-undo.
    define variable vhProclctrat as handle no-undo.

    define buffer ctrat for ctrat.

    for first ctrat no-lock
        where ctrat.tpcon = pcTpConUse-IN
          and ctrat.nocon = piNoConUse-IN:
        if piNoRolUse-IN <> 0
        then assign
            vcLbnomUse = outilFormatage:getNomTiers(pcTpRolUse-IN, piNoRolUse-IN)                   //remplace appel formtie0.p
            vcLnom2Use = outilFormatage:getCiviliteNomTiers(pcTpRolUse-IN, piNoRolUse-IN, no)       //remplace appel formTie9.p
        .
        empty temp-table ttCtrat.
        create ttCtrat.
        assign
            ttCtrat.tprol       = pcTpRolUse-IN
            ttCtrat.norol       = piNoRolUse-IN
            ttCtrat.lbnom       = vcLbnomUse
            ttCtrat.lnom2       = vcLnom2Use
            ttctrat.CRUD        = "U"
            ttCtrat.dtTimestamp = datetime(ctrat.dtmsy, ctrat.hemsy)
            ttCtrat.rRowid      = rowid(ctrat)
        .
        run adblib/ctrat_CRUD.p persistent set vhProclctrat.
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
    define input parameter piNumeroContrat as int64 no-undo.    
    define input parameter vhTmpAutorisation as handle no-undo.
     
    define variable voNumeroRegistreMandat as class parametrageNumeroRegistreMandat no-undo.    

    define buffer ctrat for ctrat.

    find first ctrat no-lock
         where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
           and ctrat.nocon = piNumeroContrat no-error.
    if not available ctrat
    then do:
        mError:createError({&error}, 100057).
        return.
    end.

    vhTmpAutorisation:handle:buffer-create().

    voNumeroRegistreMandat = new parametrageNumeroRegistreMandat().
    vhTmpAutorisation::lSaisieRegistreAuto = voNumeroRegistreMandat:isNumeroRegistreAuto().
    delete object voNumeroRegistreMandat.

    vhTmpAutorisation::lGestionDescriptifGeneral = gestionDescriptifGeneral ().

    if ctrat.dtree <> ? 
    then assign
             vhTmpAutorisation::lAnnulResiliation = yes 
             vhTmpAutorisation::lModification     = no 
             vhTmpAutorisation::lRenouvellement   = no
             vhTmpAutorisation::lResiliation      = no
    . 
    else assign
             vhTmpAutorisation::lAnnulResiliation = no 
             vhTmpAutorisation::lModification     = yes 
             vhTmpAutorisation::lRenouvellement   = yes
             vhTmpAutorisation::lResiliation      = yes
    . 
                
end procedure.

procedure controleObjet:
    /*------------------------------------------------------------------------------
    Purpose: controle objet
             pour ce controle, chargement info objet du mandat dans la table ttMandat (comme pour un getObjet)
             et ensuite appel procedure verZonSai (controle avant maj)  
    Notes  : 
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as int64     no-undo.

    define buffer ctrat for ctrat.
    
    find first ctrat no-lock
         where ctrat.tpcon = pcTypeContrat
           and ctrat.nocon = piNumeroContrat no-error.
    if not available ctrat
    then do:
        mError:createError({&error}, 100057).
        return.
    end.
    run getObjet (pcTypeContrat, piNumeroContrat, output table ttMandat, output table ttObjetMandatDescriptifGeneral).
    if mError:erreur() then return.
    find first ttMandat.
    ttMandat.CRUD = "U".
    goSyspr = new syspr().
    run verZonSai ("", buffer ctrat, buffer ttMandat).
    delete object goSyspr.

end procedure.
