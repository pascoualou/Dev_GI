/*------------------------------------------------------------------------
File        : objetBail.p
Purpose     : objet d'un bail
Author(s)   : GGA  -  2018/12/05
Notes       : reprise du pgm adb/cont/gesobj00.p
              mais uniquement le code pour type bail
derniere revue: 2018/12/21 - DMI: OK
------------------------------------------------------------------------*/
{preprocesseur/type2adresse.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2tache.i}
{preprocesseur/unite2duree.i}
{preprocesseur/referenceClient.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2role.i}
{preprocesseur/codePeriode.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/param2locataire.i}
{preprocesseur/mode2reglement.i}
{preprocesseur/etat2renouvellement.i}
{preprocesseur/motif2resiliation.i}
{preprocesseur/phase2renouvellement.i}
{preprocesseur/codeTaciteReconduction.i}
{preprocesseur/comptabilite.i}
{preprocesseur/profil2rubQuit.i}

using parametre.pclie.parametrageFournisseurLoyer.
using parametre.pclie.parametrageDefautBail.
using parametre.pclie.parametrageRelocation.
using parametre.pclie.pclie.
using parametre.syspr.syspr.
using parametre.syspg.syspg.
using parametre.syspg.parametrageNatureContrat.
using parametre.pclie.parametrageProlongationExpiration.
using parametre.pclie.parametrageOrigineClient.
using parametre.pclie.parametrageRubriqueQuittHonoCabinet.
using parametre.pclie.parametrageRenouvellement.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{application/include/glbsepar.i}
{application/include/combo.i}
{application/include/error.i}
{bail/include/objetBail.i}
{bail/include/dateResiliationTriennale.i}
{crud/include/ctrat.i}
{crud/include/restrien.i}
{tache/include/tache.i}
{crud/include/unite.i}
{crud/include/equit.i}
{bail/include/tbtmpqtt.i}
{bail/include/tbtmprub.i}
{crud/include/cttac.i}
{bail/include/tbtmprub.i &nomtable=ttRubriqueRegularisation}
{bail/include/tbtmpqtt.i &nomtable=ttQuittanceEmiseAvance}

{bail/include/outilBail.i}
{bail/quittancement/procedureCommuneQuittance.i}    // procédures chgMoisQuittance, isRubMod
{outils/include/lancementProgramme.i}               // fonctions lancementPgm, suppressionPgmPersistent

define variable ghProc                     as handle    no-undo.
define variable glParamFournisseurLoyer    as logical   no-undo.
define variable glContratFournisseurLoyer  as logical   no-undo.
define variable glInfoMobile               as logical   no-undo.
define variable glRelocation               as logical   no-undo.
define variable glMajQuittancement         as logical   no-undo.
define variable giNumeroMandat             as int64     no-undo.
define variable giNumeroContrat            as int64     no-undo.
define variable gcTypeContrat              as character no-undo.
define variable giNumeroUl                 as integer   no-undo.
define variable giMoisQuittancement        as integer   no-undo.
define variable giMoisModifiable           as integer   no-undo.
define variable giMoisEchu                 as integer   no-undo.
define variable gdaAncienDateExpiration    as date      no-undo.
define variable gdaAncienDateResiliation   as date      no-undo.
define variable glAncienTaciteReconduction as logical   no-undo.
define variable gcTacOld                   as character no-undo.
define variable glIsBailComCiv             as logical   no-undo.
define variable glIsBrwResil               as logical   no-undo.

define variable goSyspr               as class syspr      no-undo.
define variable goCollectionHandlePgm as class collection no-undo.
define variable goCollectionContrat   as class collection no-undo.


function fCalculDateResiliation returns date private(pdaEffet as date, piDureeAn as integer, piDureeMois as integer, piDureeJour as integer) :
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vdaResiliation     as date    no-undo.
    define variable viNombreJour       as integer no-undo.
    define variable viNombreJourFin    as integer no-undo.
    define variable vdaEffetSuivante   as date    no-undo.
    define variable vdaResiliationCalc as date    no-undo.
    define variable vdaFinMois         as date    no-undo.

    if piDureeMois = ? then piDureeMois = 0.
    if piDureeJour = ? then piDureeJour = 0.
    assign
        viNombreJour       = piDureeJour
        vdaEffetSuivante   = add-interval(pdaEffet, (12 * piDureeAn + piDureeMois), "months")
        vdaResiliationCalc = vdaEffetSuivante - 1
    .
    if piDureeJour <> 0
    then do:
        /* Cadrage sur la fin de mois */
        ghProc = lancementPgm("application/l_prgdat.p", goCollectionHandlePgm).
        run DatDerJou in ghProc(vdaResiliationCalc, output vdaFinMois).
        if vdaFinMois > vdaResiliationCalc
        then do:
            /* gestion du dépassement de la fin de mois */
            viNombreJourFin = vdaFinMois - vdaResiliationCalc.
            if piDureeJour > viNombreJourFin then viNombreJour = viNombreJourFin.
        end.
    end.
    assign
        vdaEffetSuivante = vdaEffetSuivante + viNombreJour
        vdaResiliation   = vdaEffetSuivante - 1
    .
    return vdaResiliation.

end function.

function isFournisseurLoyer returns logical private ():
    /*------------------------------------------------------------------------------
    Purpose: Gestion fournisseur Loyer activée
    Notes:
    ------------------------------------------------------------------------------*/
    define variable voParametreFournisseurLoyer as class parametrageFournisseurLoyer no-undo.
    define variable vlFournisseurLoyer as logical no-undo.
    
    voParametreFournisseurLoyer = new parametrageFournisseurLoyer().
    vlFournisseurLoyer = voParametreFournisseurLoyer:isGesFournisseurLoyer().
    delete object voParametreFournisseurLoyer.
    return vlFournisseurLoyer.

end function.

function isInfoMobile returns logical private ():
    /*------------------------------------------------------------------------------
    Purpose: Information Mobile
    Notes:
    ------------------------------------------------------------------------------*/
    define variable voPclie as class pclie no-undo.
    define variable vlInfoMobile as logical no-undo.
    
    voPclie = new pclie("TIER2").
    if voPclie:isDbParameter and integer(voPclie:zon01) = 1
    then vlInfoMobile = yes.
    delete object voPclie.
    return vlInfoMobile.

end function.

function isPrologationBauxApresExpiration returns logical private ():
    /*------------------------------------------------------------------------------
    Purpose: Module Prologation Baux Apres Expiration activé
    Notes:
    ------------------------------------------------------------------------------*/
    define variable voParametrageProlongationExpiration as class parametrageProlongationExpiration no-undo.
    define variable viIsPrologationBauxApresExpiration  as logical no-undo.
    
    voParametrageProlongationExpiration = new parametrageProlongationExpiration().
    viIsPrologationBauxApresExpiration = (voParametrageProlongationExpiration:isDbParameter and voParametrageProlongationExpiration:zon01 = "00001").
    delete object voParametrageProlongationExpiration.
    return viIsPrologationBauxApresExpiration.

end function.

function isRelocation returns logical private ():
    /*------------------------------------------------------------------------------
    Purpose: Module relocation activé
    Notes:
    ------------------------------------------------------------------------------*/
    define variable voParametrageRelocation as class parametrageRelocation no-undo.
    define variable vlRelocation as logical no-undo.
    voParametrageRelocation = new parametrageRelocation().
    vlRelocation = voParametrageRelocation:isActif().
    delete object voParametrageRelocation.
    return vlRelocation.

end function.

procedure getObjet:
    /*------------------------------------------------------------------------------
    Purpose: affichage information objet d'un bail
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeTrt       as character no-undo.
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as int64     no-undo.
    define output parameter table for ttObjetBail.
    define output parameter table for ttDateResiliationTriennale.

    define variable vcTypTacheRenouvDate as character no-undo.

    define buffer ctrat for ctrat.
    define buffer tache for tache.

    empty temp-table ttObjetBail.
    empty temp-table ttDateResiliationTriennale.
    find first ctrat no-lock
        where ctrat.tpcon = pcTypeContrat
          and ctrat.nocon = piNumeroContrat no-error.
    if not available ctrat then do:
        mError:createError({&error}, 100057).
        return.
    end.

    assign
 //     giNumeroContrat         = ttObjetBail.iNumeroContrat
   //   gcTypeContrat           = ttObjetBail.cCodeTypeContrat
        giNumeroMandat          = truncate(ctrat.nocon / 100000, 0)
   //   giNumeroUl              = truncate((ctrat.nocon modulo 100000) / 100, 0)
        goCollectionContrat     = new collection()
 //     goCollectionHandlePgm   = new collection()
        glParamFournisseurLoyer = isFournisseurLoyer()
        glInfoMobile            = isInfoMobile()
        glIsBailComCiv          = isBailComCiv(ctrat.ntcon)   
        glIsBrwResil            = isBrwResil(ctrat.ntcon)      
    .
    run chgMoisQuittance(giNumeroMandat, input-output goCollectionContrat).
    glContratFournisseurLoyer = goCollectionContrat:getLogical("lBailFournisseurLoyer").
    run lectInfoCtrat(pcTypeContrat, piNumeroContrat).

    if pcTypeTrt = "RENOUVELLEMENT" then do:
        /*--> info sur date de renouvellement mais valid impossible si proc de renou */
        find last tache no-lock
            where tache.tpcon = ttObjetBail.cCodeTypeContrat
              and tache.nocon = ttObjetBail.iNumeroContrat
              and tache.tptac = {&TYPETACHE-renouvellement} no-error.
        if available tache then do:                                            // Info date de renouvellement mais validation impossible
            if tache.tpfin = {&ETATPROCRENOU-attenteRenouvellement} then do:
                vcTypTacheRenouvDate = entry(num-entries(tache.cdhon, "#") - 2, tache.cdhon, "#").
                case entry(2, vcTypTacheRenouvDate, "&"):
                    when {&PHASEPROCRENOU-ARenouvellerSurBaseBail}     then ttObjetBail.daDateEffet = tache.dtfin + 1.   // Renouvellement sur la base du bail
                    when {&PHASEPROCRENOU-ARenouvellerSurBaseOffre}    then ttObjetBail.daDateEffet = tache.dtreg.       // Renouvellement sur la base de l'offre
                    when {&PHASEPROCRENOU-ARenouvellerSurBaseJugement} then ttObjetBail.daDateEffet = tache.dtreg.       // Renouvellement sur la base de jugement
                end case.
                run calDtExp(buffer ttObjetBail).
            end.
        end.
        else if ttObjetBail.daDateExpiration < today then do:
            ttObjetBail.daDateEffet = ttObjetBail.daDateExpiration + 1.
            run calDtExp(buffer ttObjetBail).
            if glIsBrwResil and ttObjetBail.lDroitResiliation 
            then run initDroitResiliationPrivate (ttObjetBail.cCodeTypeContrat, ttObjetBail.iNumeroContrat, ttObjetBail.daDateEffet, ttObjetBail.daDateExpiration, ttObjetBail.iDureeAn, ttObjetBail.iDureeMois).
        end.
    end.
end procedure.

procedure setObjet:
    /*------------------------------------------------------------------------------
    Purpose: maj infos objet mandat
    Notes  : service externe (beMandatGerance.cls)
    
//gga todo ajouter test pour autorisation maj en fonction tache renouvellement (fait pour table ttAutorisation, mais pas ici)     
    ------------------------------------------------------------------------------*/
    define input        parameter pcTypeTrt as character no-undo.
    define input-output parameter table for ttObjetBail.
    define input        parameter table for ttDateResiliationTriennale.
    define input        parameter table for ttError.
    define output parameter table for ttRubriqueRegularisation.  
    define output parameter table for ttQuittanceEmiseAvance.
    
    define buffer ctrat for ctrat.

    find first ttObjetBail where ttObjetBail.CRUD = "C" or ttObjetBail.CRUD = "U" no-error.
    if not available ttObjetBail then return.

    find first ctrat no-lock
         where ctrat.tpcon = ttObjetBail.cCodeTypeContrat
           and ctrat.nocon = ttObjetBail.iNumeroContrat no-error.
    if not available ctrat then do:
        mError:createError({&error}, 100057).
        return.
    end.
    run initZoneGlobaleAvantTrt (buffer ctrat, buffer ttObjetBail).
    if glIsBailComCiv
    then do:
        if ttObjetBail.iDureeAn > 0
        then assign
                 ttObjetBail.iDuree      = ttObjetBail.iDureeAn
                 ttObjetBail.cUniteDuree = {&UNITE2DUREE-an}
        .
        else
        if ttObjetBail.iDureeMois > 0
        then assign
                 ttObjetBail.iDuree      = ttObjetBail.iDureeMois
                 ttObjetBail.cUniteDuree = {&UNITE2DUREE-mois}
        .
    end.
    else do:
        if ttObjetBail.cUniteDuree = {&UNITE2DUREE-an}
        then ttObjetBail.iDureeAn   = ttObjetBail.iDuree.
        else ttObjetBail.iDureeMois = ttObjetBail.iDuree.
    end.
    if pcTypeTrt = "RESILIATION"
    then run verificationResiliation(buffer ctrat, buffer ttObjetBail).
    else run verificationNonResiliation(pcTypeTrt, buffer ctrat, buffer ttObjetBail).
    if not mError:erreur() then run valMajEcr(pcTypeTrt, buffer ttObjetBail).
    if not mError:erreur() then run majCtrat(pcTypeTrt, buffer ctrat, buffer ttObjetBail).
    delete object goSyspr.
    delete object goCollectionContrat.
    suppressionPgmPersistent(goCollectionHandlePgm).

//mError:createError({&error}, "fin test gg").

end procedure.

procedure lectInfoCtrat private:
    /*------------------------------------------------------------------------------
    Purpose: affichage information objet d'un mandat
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as int64 no-undo.

    define variable voPclie as class pclie no-undo.

    define buffer ctrat    for ctrat.
    define buffer idev     for idev.
    define buffer restrien for restrien.
    define buffer tache    for tache.

    for first ctrat no-lock
        where ctrat.tpcon = pcTypeContrat
          and ctrat.nocon = piNumeroContrat:
        create ttObjetBail.
        assign
            ttObjetBail.CRUD                     = 'R'
            ttObjetBail.cCodeTypeContrat         = ctrat.tpcon
            ttObjetBail.iNumeroContrat           = ctrat.nocon
            ttObjetBail.iNumeroDocument          = ctrat.nodoc
            ttObjetBail.cLibelleTypeContrat      = outilTraduction:getLibelleProg("O_CLC", ctrat.tpcon)
            ttObjetBail.cCodeNatureContrat       = ctrat.ntcon
            ttObjetBail.cLibelleNatureContrat    = outilTraduction:getLibelleProg("O_COT", ctrat.ntcon)
            ttObjetBail.cCodeStatut              = ctrat.cdstatut
            ttObjetBail.daDateEffet              = ctrat.dtdeb
            ttObjetBail.daDateExpiration         = ctrat.dtfin
            ttObjetBail.daDateInitiale           = ctrat.dtini
            ttObjetBail.daResiliation            = ctrat.dtree
            ttObjetBail.daSignature              = ctrat.dtsig
            ttObjetBail.cLieuSignature           = ctrat.lisig
            ttObjetBail.daDateValidation         = ctrat.dtvaldef
            ttObjetBail.cNumeroRegistre          = ctrat.noree
            ttObjetBail.lTaciteReconduction      = (ctrat.tpren = {&TACITERECONDUCTION-YES})
            ttObjetBail.iNbRenouvellement        = ctrat.noren
            ttObjetBail.iDuree                   = ctrat.nbdur
            ttObjetBail.cUniteDuree              = ctrat.cddur
            ttObjetBail.cLibelleUniteDuree       = outilTraduction:getLibelleParam("UTDUR", ctrat.cddur)
            ttObjetBail.iDelaiPreavis            = ctrat.nbres
            ttObjetBail.cUnitePreavis            = ctrat.utres
            ttObjetBail.cLibelleUnitePreavis     = outilTraduction:getLibelleParam("UTDUR", ctrat.utres)
            ttObjetBail.cTypeActe                = ctrat.tpact
            ttObjetBail.cLibelleTypeActe         = outilTraduction:getLibelleParam("TPACT", ctrat.tpact)
            ttObjetBail.cOrigineClient           = ctrat.cdori
            ttObjetBail.lResiliation             = ctrat.dtree <> ?
            ttObjetBail.cMotifResiliation        = ctrat.tpfin
            ttObjetBail.cLibelleMotifResiliation = outilTraduction:getLibelleParam("TPMOT", ctrat.tpfin)
            ttObjetBail.lProvisoire              = ctrat.fgprov
            ttObjetBail.iNumeroBlocNote          = ctrat.noblc
            voPclie                              = new pclie("CDORI", ttObjetBail.cOrigineClient)
            ttObjetBail.cLibelleOrigineClient    = voPclie:zon02
            ttObjetBail.lCatComCiv               = glIsBailComCiv
            ttObjetBail.lBrwResil                = glIsBrwResil
            ttObjetBail.dtTimestamp                   = datetime(ctrat.dtmsy, ctrat.hemsy)
            ttObjetBail.rRowid                        = rowid(ctrat)
        .
        delete object voPclie.
        if glIsBailComCiv then do:
            assign
                ttObjetBail.iDureeAn           = ctrat.nbann1bai
                ttObjetBail.iDureeMois         = ctrat.nbmois1bai
                ttObjetBail.iDureeJour         = ctrat.nbjou1bail
                ttObjetBail.lProlongation      = ctrat.fgprolongation
                ttObjetBail.cMotifProlongation = ctrat.motifprolongation
                ttObjetBail.lDroitResiliation  = ctrat.fgrestrien
            .
            for each restrien no-lock
               where restrien.tpcon = ctrat.tpcon
                 and restrien.nocon = ctrat.nocon:
                create ttDateResiliationTriennale.
                assign
                    ttDateResiliationTriennale.cTypeContrat   = restrien.tpcon
                    ttDateResiliationTriennale.iNumeroContrat = restrien.nocon
                    ttDateResiliationTriennale.daResiliation  = restrien.dtresil
                    ttDateResiliationTriennale.iDureeAn       = restrien.nbanndur
                    ttDateResiliationTriennale.iDureeMois     = restrien.nbmoisdur
                    ttDateResiliationTriennale.iDureeJour     = restrien.nbjoudur
                    ttDateResiliationTriennale.CRUD           = "R"
                .
            end.
        end.
        /* Reference Client - Uniquement pour les Baux Fournisseur de Loyer Credit Lyonnais */
        if glParamFournisseurLoyer and glContratFournisseurLoyer
        then ttObjetBail.cReferenceClient = ctrat.lbdiv.

        if glParamFournisseurLoyer and not glContratFournisseurLoyer and glInfoMobile
        then assign
                 ttObjetBail.cTypeRegime           = string(ctrat.noref, "99999")
                 ttObjetBail.cLibelleTypeRegime    = outilTraduction:getLibelleParam("CLSTA", ttObjetBail.cTypeRegime)
                 ttObjetBail.lAbattementAvecNature = (ctrat.lbdiv2 = "00001")
        .

        for last tache no-lock
           where tache.tpcon = pcTypeContrat
             and tache.nocon = piNumeroContrat
             and tache.tptac = {&TYPETACHE-renouvellement}:
            if tache.tpfin = {&ETATPROCRENOU-procedureEnCours}
            or tache.tpfin = {&ETATPROCRENOU-quittanceAValider}
            or tache.tpfin = {&ETATPROCRENOU-attenteRenouvellement}
            or tache.tpfin = {&ETATPROCRENOU-congeEnCours}
            then assign
                     ttObjetBail.daDateExpirationContractuelle = tache.dtfin
                     ttObjetBail.cTypeDateExpiration           = "contractuel"
            .
        end.
    end.
end procedure.

procedure verificationNonResiliation private:
    /*------------------------------------------------------------------------------
    Purpose: controle infos objet mandat avant maj
    Notes  : ancien (verZonSai, blc-val-menu)
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeTrt as character no-undo.

    define parameter buffer ctrat for ctrat.
    define parameter buffer ttObjetBail for ttObjetBail.

    define variable vdaEffMin               as date    no-undo.
    define variable vdaEffMax               as date    no-undo.
    define variable vdaDtsMin               as date    no-undo.
    define variable vdaDtsMax               as date    no-undo.
    define variable vdaDebTmp               as date    no-undo.
    define variable vdaResCal               as date    no-undo.
    define variable viI                     as integer no-undo.
    define variable viMoisTraitement        as integer no-undo.
    define variable vlCtrlDateQuittancement as logical no-undo.
    define variable voProlongationExpiration as class parametrageProlongationExpiration no-undo.

    define buffer svtrf for svtrf.
    define buffer tache for tache.
    define buffer aquit for aquit.

    /*--> Date du 1er contrat */
    if ttObjetBail.daDateInitiale = ?
    then do:
        mError:createError({&error}, 104078).
        return.
    end.
    if ttObjetBail.daDateEffet = ?
    then do:
        mError:createError({&error}, 100072).            /* la date d'effet est obligatoire */
        return.
    end.
    if ttObjetBail.daDateInitiale > ttObjetBail.daDateEffet
    then do:
        mError:createError({&error}, 104079).
        return.
    end.
    if pcTypeTrt = "RENOUVELLEMENT"
    and ctrat.dtdeb <> ? and ttObjetBail.daDateEffet < ctrat.dtdeb
    then do:
        mError:createErrorGestion({&error}, 101955, string(ctrat.dtdeb, "99/99/9999")).
        return.
    end.
    if day(today) = 29 and month(today) = 2
    then assign
        vdaEffMin = date(3, 1, year(today) - 98) - 1
        vdaEffMax = date(3, 1, year(today) + 1) - 1
    .
    else assign
        vdaEffMin = date(month(today), day(today), year(today) - 98)
        vdaEffMax = date(month(today), day(today), year(today) + 1)
    .
    if ttObjetBail.daDateEffet <= vdaEffMin or ttObjetBail.daDateEffet >= vdaEffMax
    then do:
        /* La date d'effet doit être supérieure au %1 et inférieure au %2   */
        /* Fiche 0314/0106 : La date d'effet doit être supérieure au 01/03/1916 et inférieure au 11/03/2015 */
        /* Fiche 0314/0106 : amélioration message d'anomalie pour savoir la date d'effet utilisée ( c.f. an 3000 dans les procédures de RENOUVELLELEMENT ) */
        // Date d'effet incorrecte &1. La date d'effet doit être supérieure au &2 et inférieure au &3
        mError:createError({&error}, 1000430, substitute("&2&1&3&1&4", separ[1], if ttObjetBail.daDateEffet <> ? then string(ttObjetBail.daDateEffet) else " ", string(vdaEffMin), string(vdaEffMax))).
        return.
    end.
    
    
//gga todo voir appel procedure verdtadte (vu pas repris au moment du dev objetmandatsyndic) 
    
    
    /*--> Duree du Contrat */
    if ttObjetBail.iDuree = ? then do:
        mError:createError({&error}, 100073).
        return.
    end.
    /*--> Unite Duree du Contrat. */
    if not goSyspr:isParamExist("UTDUR", ttObjetBail.cUniteDuree) then do:
        mError:createError({&error}, 100074).
        return.
    end.
    /* controle de la durée du contrat */
    run ctlDuCtt(buffer ttObjetBail).
    if mError:erreur() then return.

    if ttObjetBail.daDateExpiration = ?         /*--> Date d'Expiration. */
    then do:
        if integer(mtoken:cRefPrincipale) = {&REFCLIENT-MANPOWER}
        then mError:createError({&error}, 103406).
        else mError:createError({&error}, 100075).
        return.
    end.
    if ttObjetBail.daDateExpiration <= ttObjetBail.daDateEffet
    then do:
        mError:createError({&error}, 100076).
        return.
    end.
    /*--> Delai de resiliation*/
    if ttObjetBail.iDelaiPreavis = ?
    then do:
        mError:createError({&error}, 100077).
        return.
    end.
    if ttObjetBail.iDelaiPreavis = 0
    then do:
        mError:createError({&error}, 102045).
        return.
    end.
    /*--> Unite de Delai de resiliation */
    if not goSyspr:isParamExist("UTDUR", ttObjetBail.cUnitePreavis) or ttObjetBail.cUnitePreavis = {&UNITE2DUREE-an}    
    then do:
        mError:createError({&error}, 100078).
        return.
    end.
    if integer(mtoken:cRefPrincipale) <> 10 and gcTypeContrat <> {&TYPECONTRAT-preBail}     /*--> Date de Signature */
    then do:
        if ttObjetBail.daSignature = ?
        then do:
            mError:createError({&error}, 100079).
            return.
        end.
        /*--> date de signature à + ou - 1 an de la date du 1er contrat */
        assign
            vdaDtsMin = ttObjetBail.daDateInitiale
            vdaDtsMin = date( month(vdaDtsMin), 1, year(vdaDtsMin) - 1 )
            vdaDtsMax = ttObjetBail.daDateInitiale
        .
        if month(vdaDtsMin) = 12
        then vdaDtsMax = date(01, 01, year(vdaDtsMax) + 2) - 1.
        else vdaDtsMax = date(month(vdaDtsMin) + 1, 1, year(vdaDtsMax) + 1) - 1.
        if ttObjetBail.daSignature > vdaDtsMax or ttObjetBail.daSignature < vdaDtsMin
        then do:
            if outils:questionnaire(107343, table ttError by-reference) <= 2
            then return.
        end.
        /*--> Lieu de Signature. */
        if ttObjetBail.cLieuSignature = ? or ttObjetBail.cLieuSignature = ""
        then do:
            mError:createError({&error}, 100081).
            return.
        end.
    end.
    if not goSyspr:isParamExist("TPACT", ttObjetBail.cTypeActe)
    then do:
        mError:createError({&error}, 100082).
        return.
    end.
    assign
        glMajQuittancement      = no
        vlCtrlDateQuittancement = yes
    .
    if ctrat.noren = 0
    then do:
        MAJ_DTDEB: do:
            /* 1 - le locataire n'a pas encore été quittancé */
            if not can-find(first aquit
                            where aquit.noloc = giNumeroContrat
                              and aquit.fgfac = false)
            then do:
                /* 2 - le bail est issu d'une PEC en global avec une entree locataire dans le futur (que DG et/ou frais dans la facture) */
                /* on cherche une facture d'entrée locataire */
                for first aquit no-lock
                    where aquit.noloc = giNumeroContrat
                      and aquit.fgfac = true:
                    /* on cherche une rubrique autre que DG ou frais */
                    do viI = 1 to aquit.nbrub:
                        if (integer(entry(12, aquit.tbrub[viI], "|")) <> 4
                        and (integer(entry(12, aquit.tbrub[viI], "|")) <> 3 or integer(entry(13, aquit.tbrub[viI], "|")) <> 3))
                        then leave MAJ_DTDEB.
                    end.
                    /* la nouvelle date d'effet doit etre egale a la date de premier contrat */
                    if ttObjetBail.daDateEffet <> ttObjetBail.daDateInitiale
                    then do:
                        mError:createError({&error}, 106149).
                        return.
                    end.
                    for last svtrf no-lock
                       where svtrf.cdtrt = "QUIT":
                        if svtrf.nopha <> "N99"
                        then viMoisTraitement = svtrf.mstrt.
                        else viMoisTraitement = svtrf.mstrt + 1.
                        /* 3 - la nouvelle date d'effet est >= au premier mois de quit modifiable */
                        if integer(year(ttObjetBail.daDateEffet) * 100 + month(ttObjetBail.daDateEffet)) < viMoisTraitement
                        then do:
                            mError:createError({&error}, 104660).
                            return.
                        end.
                    end.
                end.
                assign
                    glMajQuittancement      = true    // mise à jour du quittancement
                    vlCtrlDateQuittancement = false   // dans ce cas, pas de test entre la date d'effet et la date d'application
                .
            end.
        end.
        if vlCtrlDateQuittancement // Recherche de la date d'application de la quittance : la date d'effet doit etre toujours inferieure ou egale a cette date.
        then for last tache no-lock
               where tache.tpcon = gcTypeContrat
                 and tache.nocon = giNumeroContrat
                 and tache.tptac = {&TYPETACHE-quittancement}:
                if ttObjetBail.daDateEffet > tache.dtdeb
                then do:
                    mError:createErrorGestion({&error}, 101715, string(tache.dtdeb)).
                    return.
                end.
        end.
    end.

    /* Ajout SY le 11/01/2011 : Si date d'expiration dépassée et pas l'option prolongation des baux après expiration ni tacite reconduction, alors prévenir que le quittancement s'arretera */
    voProlongationExpiration = new parametrageProlongationExpiration().
    if not voProlongationExpiration:isQuittancementProlonge()
    and not ttObjetBail.lTaciteReconduction
    and ttObjetBail.daDateExpiration < today + 30
    then mError:createError({&information}, 1000954, string(ttObjetBail.daDateExpiration)).
    delete object voProlongationExpiration.

    if glIsBrwResil
    and ttObjetBail.lDroitResiliation
    then do:
        vdaDebTmp = ttObjetBail.daDateEffet.
        for each ttDateResiliationTriennale
           where ttDateResiliationTriennale.cTypeContrat   = ttObjetBail.cCodeTypeContrat
             and ttDateResiliationTriennale.iNumeroContrat = ttObjetBail.iNumeroContrat
             and ttDateResiliationTriennale.daResiliation  > ttObjetBail.daDateEffet
             and ttDateResiliationTriennale.daResiliation  <> ?
        by ttDateResiliationTriennale.daResiliation:
            vdaResCal = fCalculDateResiliation (vdaDebTmp, ttDateResiliationTriennale.iDureeAn, ttDateResiliationTriennale.iDureeMois, ttDateResiliationTriennale.iDureeJour).
            if vdaResCal <> ttDateResiliationTriennale.daResiliation
            then do:
                mError:createError({&error}, 1000955, substitute('&2&1&3&1&4', separ[1], ttDateResiliationTriennale.daResiliation, vdaDebTmp - 1, vdaResCal)). //Dates de résiliation incohérentes. La date de résiliation saisie &1 ne correspond pas à la date précédente &2 plus la durée ans/mois/jour saisie. Date calculée &3"
                return.
            end.
            /* controle si date > date d'effet */
            if ttDateResiliationTriennale.daResiliation <  ttObjetBail.daDateEffet
            then do:
                mError:createError({&error}, 1000956, substitute('&2&1&3', separ[1], ttDateResiliationTriennale.daResiliation, ttObjetBail.daDateEffet)).      //Date de résiliation incorrecte. La date de résiliation &1 doit être supérieure à la date d'effet &2"
                return.
            end.
            /* controle si date < date d'expiration */
            if ttDateResiliationTriennale.daResiliation >= ttObjetBail.daDateExpiration
            then do:
                mError:createError({&error}, 1000957, substitute('&2&1&3', separ[1], ttDateResiliationTriennale.daResiliation, ttObjetBail.daDateExpiration)).  //Date de résiliation incorrecte. La date de résiliation &1 doit être inférieure à la date d'expiration &2
                return.
            end.
            vdaDebTmp = vdaResCal + 1.
        end.
    end.
    if glIsBailComCiv
    and not ttObjetBail.lProlongation
    and ttObjetBail.cMotifProlongation <> ""
    then do:
        mError:createError({&error}, 1000958).      //motif de prolongation doit etre vide si pas de prolongation
        return.
    end.

end procedure.

procedure verificationResiliation private:
    /*------------------------------------------------------------------------------
    Purpose: controle infos objet mandat avant maj
    Notes  : ancien (verZonSai, blc-val-menu)
    ------------------------------------------------------------------------------*/
    define parameter buffer ctrat       for ctrat.
    define parameter buffer ttObjetBail for ttObjetBail.

    define variable vdaEntLoc   as date      no-undo.
    define variable vdaSorLoc   as date      no-undo.
    define variable vdaEntSui   as date      no-undo.
    define variable vcNomLocSui as character no-undo.
    define variable vcCodeTerme as character no-undo.
    define variable vdaMoiMdf   as date      no-undo.

    define buffer vbctrat for ctrat.
    define buffer tache   for tache.
    define buffer unite   for unite.
    define buffer aquit   for aquit.

    /*--> Date de resiliation. */
    if ttObjetBail.daResiliation = ? and ttObjetBail.lResiliation
    then do:
        mError:createError({&error}, 100083).
        return.
    end.
    if ttObjetBail.daResiliation = ? and gdaAncienDateResiliation = ?
    then do:
        mError:createError({&error}, 1000959).          //demande de traitement d'annulation de résiliation pour contrat non résilié
        return.
    end.

//gga todo voir avec sylvie si ordre des controles importants les 2 controles suivant sont dans on leave of date resiliation
    if ttObjetBail.lResiliation
    then do:
        if gdaAncienDateResiliation <> ?
        and ttObjetBail.daResiliation <> gdaAncienDateResiliation
        and ((year(ttObjetBail.daResiliation) * 100 + month(ttObjetBail.daResiliation)) < giMoisQuittancement)
        then do:
            if outils:questionnaireGestion(109702, "", table ttError by-reference) <= 2
            then return.
        end.

        if ttObjetBail.daResiliation <> gdaAncienDateResiliation
        and ((year(ttObjetBail.daResiliation) * 100 + month(ttObjetBail.daResiliation)) < giMoisQuittancement)
        then do:
            run verifRubSup.
            if mError:erreur()
            then return.
        end.

        /*--> Date resiliation >= date 1er contrat */
        if ttObjetBail.daResiliation < ttObjetBail.daDateInitiale
        then do:
            mError:createError({&error}, 105575).        /*La date de résiliation doit être postérieure à la date du 1er contrat.*/
            return.
        end.

        /*--> Date resiliation >= date signature */
        if ttObjetBail.daResiliation < ctrat.dtsig
        then do:
            mError:createError({&error}, 102047).        /*La date de résiliation doit être postérieure à la date de signature !!*/
            return.
        end.

        /*--> Date resiliation <= date expiration */
        if ttObjetBail.daResiliation > ctrat.dtfin
        and outils:questionnaireGestion(110374, substitute('&2&1', separ[1], string(ttObjetBail.daResiliation)), table ttError by-reference) <= 2    /*La date de résiliation doit être postérieure à la date de signature !!*/
        then return.

        /*--> Recherche date d'entree du locataire et du suivant s'il y en a un */
        run iniDatLoc(output vdaEntLoc, output vdaSorLoc, output vdaEntSui, output vcNomLocSui).
        if ttObjetBail.cMotifResiliation = {&MOTIF2RESILIATION-CessionBail}
        then do:
            if vdaEntSui  <> ?
            then do:
                mError:createError({&error}, 109069, string(vdaEntSui,"99/99/9999")).        //le locataire suivant existe (date d'entree %1), le bail ne peut etre cede
                return.
            end.
            if vdaSorLoc  <> ?
            then do:
                mError:createErrorGestion({&error}, 107263, string(vdaSorLoc,"99/99/9999")).  //ce locataire a pour date de sortie %1, le bail ne peut etre cede. Veuillez supprimer cette date
                return.
            end.
        end.
        /* La Date resiliation doit etre >= date d'entree du locataire */
        if vdaEntLoc <> ? and ttObjetBail.daResiliation < vdaEntLoc
        then do:
            /* La date de résiliation doit être supérieure à la date d'entrée du locataire (%1) */
            mError:createError({&error}, 1000960, substitute('&2&1&3&1&4', separ[1], giNumeroContrat, ctrat.lbnom, (if vdaEntLoc <> ? then string(vdaEntLoc,"99/99/9999") else ""))).  //La date de résiliation doit être supérieure à la date d'entrée du locataire &1 &2 (&3)
            return.
        end.
        /* La Date resiliation doit etre < date d'entree du locataire suivant (%1)*/
        if vdaEntSui <> ? and ttObjetBail.daResiliation >= vdaEntSui
        then do:
            mError:createError({&error}, 1000949, substitute('&2&1&3', separ[1], vcNomLocSui, vdaEntSui)). //La date de résiliation doit être inférieure à la date d'entrée du locataire suivant &1 (&2)
            return.
        end.
        /* Controle avec les dates d'indisponibilite de l'UL */
        for first unite no-lock
            where unite.nomdt = giNumeroMandat
              and unite.noapp = giNumeroUl
              and unite.noact = 0:
            if ttObjetBail.daResiliation <> ?
            and ttObjetBail.daResiliation >= unite.dtdebindis
            and ttObjetBail.daResiliation <= unite.dtfinindis
            then do:
                mError:createError({&error}, 1000961).             //Il y a chevauchement entre la date de résiliation et la date d'indisponibilité
                return .
            end.
        end.
        /* 0607/0250 : il ne doit pas y avoir de compensation sur ce locataire */
        for each tache no-lock
           where tache.tpcon    = {&TYPECONTRAT-bail}
             and tache.tptac    = {&TYPETACHE-quittancement}
             and tache.cdreg    = {&MODEREGLEMENT-compensation}
             and tache.etab-cd  = giNumeroMandat
             and tache.cptg-cd  = {&compteCollectif-Locataire}
             and tache.sscpt-cd = substring(string(giNumeroContrat, "9999999999"), 6, 5)
         , first vbctrat no-lock
           where vbctrat.tpcon = tache.tpcon
             and vbctrat.nocon = tache.nocon
             and vbctrat.dtree = ?:
                mError:createError({&error}, 1000962,  substitute('&2&1&3', separ[1], tache.nocon, trim(outilFormatage:getNomTiers("00019", tache.nocon)))).   //Vous ne pouvez pas résilier ce locataire tant qu'il compensera le locataire &1 - &2
                return.
                
        end.
        /* Ajout Sy le 07/07/2011 - fiche 0511/0012 - Ecart entre Date de sortie et quittancement effectif */
        /* Rechercher si date de sortie déjà saisie (sinon date résiliation -> date de sortie) */
        for last tache no-lock
           where tache.tpcon = gcTypeContrat
             and tache.nocon = giNumeroContrat
             and tache.tptac = {&TYPETACHE-quittancement}:
            if tache.dtfin = ?
            then do:
                for last aquit no-lock
                   where aquit.noloc = giNumeroContrat
                     and not aquit.fgfac
                     use-index ix_aquit03:
                    if ttObjetBail.daResiliation < aquit.dtfin
                    then do:
                        //ATTENTION Ce locataire a été quittancé jusqu'au &1 donc après la date de résiliation saisie. Si vous faites une facture de sortie le calcul ne sera correct que si la date de sortie correspond à la date de fin de quittancement réellement effectué. Confirmez-vous la date saisie : &2 ?
                        if outils:questionnaire(1000951, substitute('&2&1&3', separ[1], aquit.dtfin, ttObjetBail.daResiliation), table ttError by-reference) < 2
                        then return.
                    end.
                end.
            end.
        end.

        /*--> Motif de resiliation. */
        if ttObjetBail.cMotifResiliation = "" or ttObjetBail.cMotifResiliation = ?
        then do:
            mError:createError({&error}, 100085).        /*Le motif de résiliation est obligatoire */
            return.
        end.
        if not goSyspr:isParamExist("TPMOT", ttObjetBail.cMotifResiliation)
        or not (ttObjetBail.cMotifResiliation = {&MOTIF2RESILIATION-Aucun} or ttObjetBail.cMotifResiliation < {&MOTIF2RESILIATION-PassageSousLocation}
        or ttObjetBail.cMotifResiliation begins "12")
        then do:
            mError:createError({&error}, 1000420).                       //Motif de résiliation incorrect
            return.
        end.
        vcCodeTerme = {&TERMEQUITTANCEMENT-avance}.
        for last tache no-lock
           where tache.tpcon = gcTypeContrat
             and tache.nocon = giNumeroContrat
              and tache.tptac = {&TYPETACHE-quittancement}:
            vcCodeTerme = tache.ntges.
        end.
        if vcCodeTerme = {&TERMEQUITTANCEMENT-avance} and giMoisModifiable <> 0
        then vdaMoiMdf = date(giMoisModifiable modulo 100, 1, integer(truncate(giMoisModifiable / 100, 0))).
        else do:
            if vcCodeTerme = {&TERMEQUITTANCEMENT-echu} and giMoisEchu <> 0
            then vdaMoiMdf = date(giMoisEchu modulo 100, 1, integer(truncate(giMoisEchu / 100, 0))).
        end.
        if ttObjetBail.daResiliation < vdaMoiMdf
        then do:
            mError:createError({&information}, 103724).      //Attention, la résiliation de ce bail est irreversible
            return.
        end.
    end.

end procedure.

procedure valMajEcr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeTrt as character no-undo.
    define parameter buffer ttObjetBail for ttObjetBail.

    define variable vlAffichageQuestion as logical no-undo.

    if pcTypeTrt = "RESILIATION"
    then do:
        if not ttObjetBail.lResiliation
        then assign
            ttObjetBail.lResiliation      = no
            ttObjetBail.daResiliation     = ?
            ttObjetBail.cMotifResiliation = ""
        .
        else do:
            ghProc = lancementPgm("bail/quittancement/annqttav.p", goCollectionHandlePgm).
            run lancementAnnqttav in ghProc(giNumeroContrat,
                                            output vlAffichageQuestion,
                                            table ttError by-reference,
                                            output table ttQuittanceEmiseAvance by-reference).
            if mError:erreur() 
            or vlAffichageQuestion  
            then return.
            
            if ttObjetBail.cMotifResiliation = {&MOTIF2RESILIATION-CessionBail}
            then do:
                mError:createError({&information}, 109996).      //Vous devez maintenant prendre en charge le locataire repreneur
/*gga todo
                /* Generation d'un code transaction unique */
                run CodTrans (output NoTrsUse-2).
                LbDivPar = "CESBAI".
                /*MLog ( "ValMajEcr : Avant appel cesbai00.p " + string(NoCttUse) ).*/
                {SetWait.i  &WAIT = "ON"}
                /* modif SY le 23/11/2011 : Ajout &RunWindow = YES et suppression &RunPersiste  = YES */
                glMDI = glNewErgo. /*Lancement de l'écran en mode "Onglet"*/                          /*0108/0218*/
                trt-mdi = yes.                                                                        /*0108/0218*/
                {RunPgExp.i
                    &Path       = RpRunCtt
                    &Prog       = "'cesbai00.p'" &RunWindow = YES
                    &Parameter  = "INPUT NoCttUse ,
                               INPUT NtCttSel,
                               INPUT-OUTPUT NoCttDes,
                               INPUT NoTrsUse-2,
                               INPUT DATE(HwDtaDtR:SCREEN-VALUE),
                               OUTPUT CdRetCes,
                               INPUT-OUTPUT LbDivPar"}
                if glnewergo and VALID-HANDLE(HdTmpRun) and HdTmpRun:PERSISTENT                       /*0108/0218*/
                then subscribe "cesbai00" in HdTmpRun.                                                /*0108/0218*/
                else run cesbai00 (input NoCttDes, input CdRetCes, input LbDivPar).                   /*0108/0218*/
gga todo*/
            end.
/*gga todo
            run GenEvent.     //gga todo pour la reprise de ce module evenement, il faut avant une remise a plat pour reflechir a nouveau fonctionnement
gga todo*/
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
    define parameter buffer ttObjetBail for ttObjetBail.

    define variable viNumeroOrdre      as integer   no-undo.
    define variable vdaFapUse          as date      no-undo.
    define variable vdaDebUse          as date      no-undo.
    define variable vdaFinUse          as date      no-undo.
    define variable vcCodeOccupant     as character no-undo.
    define variable vdaDatSor          as date      no-undo.
    define variable vdaSorLoc          as date      no-undo.
    define variable vlFicLoc           as logical   no-undo.
    define variable viNumeroBailMaxi   as int64     no-undo.
    define variable vdTotMtLoy         as decimal   decimals 2 no-undo.
    define variable vdTotMtPro         as decimal   decimals 2 no-undo.
    define variable viNumeroQuittance  as integer   no-undo.
    define variable vcOrigineQuittance as character no-undo.
    define variable viNoQttAnt         as integer   no-undo.
    define variable viMsQttAnt         as integer   no-undo.

    define buffer acpte    for acpte.
    define buffer intnt    for intnt.
    define buffer vbintnt  for intnt.
    define buffer vb2Intnt for intnt.
    define buffer vbctrat  for ctrat.
    define buffer tache    for tache.
    define buffer equit    for equit.
    define buffer unite    for unite.
    define buffer aquit    for aquit.
    define buffer location for location.

    /*--> PBP 09/12/2002 Recuperation de la date de fin d'application pour le renouvellement d'un bail*/
    /* Recherche de la date de sortie locataire */
    vdaFapUse = gdaAncienDateExpiration.
    for last tache no-lock
       where tache.tptac = {&TYPETACHE-quittancement}
         and tache.tpcon = gcTypeContrat
         and tache.nocon = giNumeroContrat:
        vdaSorLoc = tache.dtfin.  /* Date de sortie du locataire */
    end.
    if vdaSorLoc <> ? and vdaFapUse <> ?
    then vdaFapUse = minimum(vdaSorLoc, vdaFapUse).
    else do:
        if vdaSorLoc <> ?
        then vdaFapUse = vdaSorLoc.
    end.
    vdaFapUse = if vdaFapUse <> ?
                then (if gcTacOld = "00001"
                      then date(12, 31, year(vdaFapUse) + 2)
                      else vdaFapUse)
               else date(12, 31, year(today) + 2).
    if gcTacOld <> "00001" then do:
        if isPrologationBauxApresExpiration()
        then vdaFapUse = if vdaSorLoc <> ? then vdaFapUse else date("31/12/2950").
    end.
    empty temp-table ttCtrat.
    create ttCtrat.
    assign
        ttCtrat.nodoc       = ttObjetBail.iNumeroDocument
        ttCtrat.tpcon       = ttObjetBail.cCodeTypeContrat
        ttCtrat.nocon       = ttObjetBail.iNumeroContrat
        ttCtrat.dtdeb       = ttObjetBail.daDateEffet
        ttCtrat.ntcon       = ttObjetBail.cCodeNatureContrat
        ttCtrat.dtfin       = ttObjetBail.daDateExpiration
        ttCtrat.tpfin       = ttObjetBail.cMotifResiliation
        ttCtrat.nbdur       = ttObjetBail.iDuree
        ttCtrat.cddur       = ttObjetBail.cUniteDuree
        ttCtrat.dtsig       = ttObjetBail.daSignature
        ttCtrat.lisig       = ttObjetBail.cLieuSignature
        ttCtrat.dtree       = ttObjetBail.daResiliation
        ttCtrat.noree       = ttObjetBail.cNumeroRegistre
        ttCtrat.tpren       = (if ttObjetBail.lTaciteReconduction then {&TACITERECONDUCTION-YES} else {&TACITERECONDUCTION-NO})
        ttCtrat.nbres       = ttObjetBail.iDelaiPreavis
        ttCtrat.utres       = ttObjetBail.cUnitePreavis
        ttCtrat.tpact       = ttObjetBail.cTypeActe
        ttCtrat.pcpte       = 0             
        ttCtrat.scpte       = 0
        ttCtrat.noave       = 0
        ttCtrat.dtini       = ttObjetBail.daDateInitiale
        ttCtrat.cdori       = ttObjetBail.cOrigineClient
        ttCtrat.anxeb       = no                                               //gga todo pour le moment specifique ALLIANZ non repris 
        ttCtrat.CRUD        = ttObjetBail.CRUD
        ttCtrat.dtTimestamp = ttObjetBail.dtTimestamp
        ttCtrat.rRowid      = ttObjetBail.rRowid
    .
    if glIsBailComCiv
    then assign        
            ttCtrat.nbann1bai         = ttObjetBail.iDureeAn
            ttCtrat.nbmois1bai        = ttObjetBail.iDureeMois
            ttCtrat.nbjou1bail        = ttObjetBail.iDureeJour
            ttCtrat.fgprolongation    = ttObjetBail.lProlongation
            ttCtrat.motifprolongation = ttObjetBail.cMotifProlongation
             ttCtrat.fgrestrien        = (if glIsBrwResil then ttObjetBail.lDroitResiliation else no)
        .
    if pcTypeTrt = "RESILIATION" and ttObjetBail.daResiliation = ?
    then ttCtrat.dtree = {&dateNulle}.
    if pcTypeTrt = "RENOUVELLEMENT"
    then ttCtrat.noren = ctrat.noren + 1.

    ghProc = lancementPgm("crud/ctrat_CRUD.p", goCollectionHandlePgm).
    run setCtrat in ghProc(table ttCtrat by-reference).
    if mError:erreur() then return.

    find first ctrat no-lock                                                                 //on se repositionne sur contrat apres maj
        where ctrat.tpcon = gcTypeContrat
          and ctrat.nocon = giNumeroContrat no-error.
    if not available ctrat then do:
        mError:createError({&error}, 100057).
        return.
    end.

    if glIsBailComCiv
    and glIsBrwResil
    then do:
        ghProc = lancementPgm("crud/restrien_CRUD.p", goCollectionHandlePgm).
        run deleteRestrienSurContrat in ghProc(gcTypeContrat, giNumeroContrat).
        if mError:erreur() then return.
        if ttObjetBail.lDroitResiliation
        then do:
            empty temp-table ttRestrien.
            for each ttDateResiliationTriennale
               where ttDateResiliationTriennale.daResiliation <> ?
                 and ttDateResiliationTriennale.daResiliation > ttObjetBail.daDateEffet:
                create ttRestrien.
                assign
                    ttRestrien.tpcon     = gcTypeContrat
                    ttRestrien.nocon     = giNumeroContrat
                    viNumeroOrdre        = viNumeroOrdre + 1
                    ttRestrien.noord     = viNumeroOrdre
                    ttRestrien.dtresil   = ttDateResiliationTriennale.daResiliation
                    ttRestrien.nbanndur  = ttDateResiliationTriennale.iDureeAn
                    ttRestrien.nbmoisdur = ttDateResiliationTriennale.iDureeMois
                    ttRestrien.nbjoudur  = ttDateResiliationTriennale.iDureeJour
                    ttRestrien.CRUD      = "C"
                .
            end.
            if can-find (first ttRestrien)
            then do:
                ghProc = lancementPgm("crud/restrien_CRUD.p", goCollectionHandlePgm).
                run setRestrien in ghProc(table ttRestrien by-reference).
                if mError:erreur() then return.
            end.
        end.
    end.

    /*--> Maj date sortie locataire */
    for last tache no-lock
       where tache.tpcon = gcTypeContrat
         and tache.nocon = giNumeroContrat
         and tache.tptac = {&TYPETACHE-quittancement}:
        assign
            vdaDebUse = tache.dtdeb
            vdaFinUse = (if tache.dtfin <> ? then tache.dtfin else ?)
            vcCodeOccupant = "00001".
        .
        /*--> Traitement pour la Date de Sortie
              Si Resiliation Bail et Date Resil < Sortie Loc alors forcer le champ tache.DtFin
              Si d‚-Resiliation Bail raz date sortie Loc ** SAUF SI FICHE RELOCATION ACTIVE (modif SY le 24/11/2011) ** .
              Si d‚-Resiliation Bail code occupant remis. */
        if ttObjetBail.daResiliation <> ?
        then do:
            if vdaFinUse <> ?
            then vdaDatSor = (if ttObjetBail.daResiliation < vdaFinUse then ttObjetBail.daResiliation
                                                                     else vdaFinUse).
            else vdaDatSor = ttObjetBail.daResiliation.
            if pcTypeTrt = "RESILIATION"
            and ttObjetBail.lResiliation
            and ttObjetBail.cMotifResiliation <> {&MOTIF2RESILIATION-CessionBail}
            then vcCodeOccupant = "00002" .
        end.
        else do:
            if pcTypeTrt = "RESILIATION"
            then vdaDatSor = ?.
            else vdaDatSor = vdaFinUse.
            /* Ajout SY le 24/11/2011 : Interdiction de supprimer la date de sortie si relocation en cours */
            if vdaDatSor = ? and glRelocation
            then do:
                /* Recherche fiche de relocation */
                vlFicLoc = no.
                for last location no-lock
                   where location.tpcon  = {&TYPECONTRAT-mandat2Gerance}
                     and location.nocon  = giNumeroMandat
                     and location.noapp  = giNumeroUl:
                    vlFicLoc = yes.
                    /* si fiche validée et pré-bail accepté alors le gestionnaire peut retirer le motif d'indisponibilité */
                    if location.cdstatut = "00090"
                    then do:
                        for first vbctrat no-lock
                            where vbctrat.tpcon = {&TYPECONTRAT-preBail}
                              and vbctrat.nocon >= location.nocon * 100000 + location.noapp * 100 + 1
                              and vbctrat.nocon <= location.nocon * 100000 + location.noapp * 100 + 99
                              and vbctrat.cdstatut = "00099":
                            vlFicLoc = no.
                        end.
                    end.
                end.
                if vlFicLoc = yes
                then vdaDatSor = vdaFinUse. /* date de sortie conservée */
            end.
        end.
        /*--> PBP 07/08/2001 : Maj date debut de quittancement locataire si on a modifie le quittancement du Bail */
        if glMajQuittancement and pcTypeTrt = "MODIFICATION"
        then vdaDebUse = ttObjetBail.daDateEffet.
        // Si Raz date de sortie : calcul proratas rappel sur jours non quittancés (0307/0174)
        if vdaDatSor = ? and tache.dtfin <> ?
        then do:
            ghProc = lancementPgm("bail/quittancement/regulqtt.p", goCollectionHandlePgm).
            run lancementRegulqtt in ghProc(goCollectionContrat, table ttError by-reference, input-output table ttRubriqueRegularisation).
            if mError:erreur() then return.
        end.
        empty temp-table ttTache.
        create tttache.
        assign
            ttTache.tpcon    = tache.tpcon
            ttTache.nocon    = tache.nocon
            ttTache.tptac    = tache.tptac
            ttTache.notac    = tache.notac
            ttTache.dtdeb    = vdaDebUse
            ttTache.dtfin    = (if vdaDatSor = ? then {&dateNulle} else vdaDatSor) 
            ttTache.CRUD        = "U"
            ttTache.rRowid      = rowid(tache)
            ttTache.dtTimestamp = datetime(tache.dtmsy, tache.hemsy)
        .
        ghProc = lancementPgm("crud/tache_CRUD.p", goCollectionHandlePgm).
        run setTache in ghProc(table ttTache by-reference).
        if mError:erreur() then return.
    end.

    /* PL : 24/07/2015 (0715/0154) Mettre à jour le flag de transfert de l'avis d'échéance concernée, si on à touché à la date de résiliation */
    if gdaAncienDateResiliation <> ttObjetBail.daResiliation
    then do:
        empty temp-table ttEquit.
        if ttObjetBail.daResiliation <> ?
        then do:
            /* Recherche de l'AE concerné */
            for first equit no-lock
                where equit.noloc               = giNumeroContrat
                  and ttObjetBail.daResiliation >= equit.dtdpr
                  and ttObjetBail.daResiliation <= equit.dtfpr:
                create ttEquit.
                assign
                    ttEquit.noint       = equit.noint
                    ttEquit.noloc       = equit.noloc
                    ttEquit.noqtt       = equit.noqtt
                    ttEquit.fgtrf       = false
                    ttEquit.rRowid      = rowid(equit)
                    ttEquit.dtTimestamp = datetime(equit.dtmsy, equit.hemsy)
                    ttEquit.CRUD        = 'U'
                .
            end.
        end.
        else do:
            /* Il faut détopper tous les AE car on ne peut pas savoir lequel il faut détopper */
            for each equit no-lock
               where equit.noloc = giNumeroContrat:
                create ttEquit.
                assign
                    ttEquit.noint       = equit.noint
                    ttEquit.noloc       = equit.noloc
                    ttEquit.noqtt       = equit.noqtt
                    ttEquit.fgtrf       = false
                    ttEquit.rRowid      = rowid(equit)
                    ttEquit.dtTimestamp = datetime(equit.dtmsy, equit.hemsy)
                    ttEquit.CRUD        = 'U'
                .
            end.
        end.
        if can-find(first ttEquit)
        then do:
            ghProc = lancementPgm("crud/equit_CRUD.p", goCollectionHandlePgm).
            run setEquit in ghProc(table ttEquit by-reference).
        end.
    end.

    /*--> Mise a Jour de la Table Unite SI ON EST SUR LE DERNIER BAIL UNIQUEMENT */
    viNumeroBailMaxi = giNumeroMandat * 100000 + giNumeroUl * 100 + 99.
    find first vbctrat no-lock
         where vbctrat.tpcon = {&TYPECONTRAT-bail}
           and vbctrat.nocon > giNumeroContrat
           and vbctrat.nocon <= viNumeroBailMaxi no-error.
    if not available vbctrat
    then do:
        find first unite no-lock
             where unite.nomdt = giNumeroMandat
               and unite.noapp = giNumeroUl
               and unite.noact = 0 no-error.
        if not available unite
        then do:
            mError:createError({&error}, 105436). //unite de location inexistante
            return.
        end.
        assign
            vdTotMtLoy = unite.MtLoy
            vdTotMtPro = unite.mtpro
        .
        /*--> Si l'on est en resiliation du Bail, aller chercher les infos sur le Quittancement
             (Somme Rubqriques Loyers & Somme rubriques Charges) */
        if pcTypeTrt = "RESILIATION"
        then do:
            /*--> D'abord rechercher la derniere quittance emise */
            find last aquit where aquit.noloc = ctrat.norol no-lock no-error.
            if available aquit
            then assign
                     viNumeroQuittance  = aquit.NoQtt
                     vcOrigineQuittance = "H"
            .
            else do:
                /*--> Sinon, prochain Avis d'echeance */
                find first equit no-lock
                     where equit.NoLoc = ctrat.norol no-error.
                if available equit
                then assign
                         viNumeroQuittance  = equit.NoQtt
                         vcOrigineQuittance = "E"
                .
                else assign
                         viNumeroQuittance  = 0
                         vcOrigineQuittance = ""
                .
            end.
            // Lancer le module de somme par famille de rubriques
            if viNumeroQuittance <> 0
            then run calculMontantQuittance (vcOrigineQuittance, viNumeroQuittance, output vdTotMtLoy, output vdTotMtPro).
        end.    /* resiliation du Bail : Somme Rubqriques Loyers & Somme rubriques Charges */
        empty temp-table ttUnite.
        create ttUnite.
        assign
            ttUnite.nomdt       = unite.nomdt
            ttUnite.noapp       = unite.noapp
            ttUnite.noact       = unite.noact
            ttUnite.cdOcc       = vcCodeOccupant
            ttUnite.tpRol       = ctrat.tprol
            ttUnite.noRol       = ctrat.norol
            ttUnite.dtent       = unite.dtent
            ttUnite.dtsor       = ttObjetBail.daResiliation
            ttUnite.tpFin       = ttObjetBail.cMotifResiliation
            ttUnite.mtLoy       = vdTotMtLoy
            ttUnite.mtPro       = vdTotMtPro
            ttUnite.CRUD        = "U"
            ttUnite.rRowid      = rowid(unite)
            ttUnite.dtTimestamp = datetime(unite.dtmsy, unite.hemsy)
        .
        ghProc = lancementPgm("crud/unite_CRUD.p", goCollectionHandlePgm).
        run setUnite in ghProc(table ttUnite by-reference).
        if mError:erreur() then return.

    end.    /* Maj unite */

    /*--> Procedure de generation des taches de resiliation de contrats.*/
    if pcTypeTrt = "RESILIATION"
    then do:
/*gga todo
        run GenEvent.     //gga todo pour la reprise de ce module evenement, il faut avant une remise a plat pour reflechir a nouveau fonctionnement
gga todo*/
    end.

    /*--> On verifie la synchronisation entre l'objet et la tache renouvellement */
    run synRenou.
    if mError:erreur()
    then do:
        mError:createError({&error}, 105978).    //erreur sur la synchronisation de la tache renouvellement
        return.
    end.

    /*--> Regeneration de EQUIT si Renouvellement OU si on a modifie la date de fin therorique du Bail */
    if  (pcTypeTrt = "RENOUVELLEMENT"
         or gdaAncienDateExpiration    <> ttObjetBail.daDateExpiration
         or glAncienTaciteReconduction <> ttObjetBail.lTaciteReconduction
        )
    and ctrat.ntcon <> {&NATURECONTRAT-habitationVacant}
    and ctrat.ntcon <> {&NATURECONTRAT-commercialVacant}
    then do:
        /* Modif Sy le 21/11/2007 :ne pas lancer si pas de quittances en cours (Ex : PEC) */
        if can-find(first equit
                    where equit.noloc = giNumeroContrat)
        then do:
            ghProc = lancementPgm("bail/quittancement/genqtren.p", goCollectionHandlePgm).
            run lancementGenqtren in ghProc(giNumeroContrat, vdaFapUse).
            if mError:erreur()
            then do:
                mError:createError({&error}, 103341).    //erreur lors de la génération des avis d'échéances (Genqtren)
                return.
            end.
            /*--> Fermer la procedure de renouvellement encours */
            if pcTypeTrt = "RENOUVELLEMENT"
            then do:
                run majRenou.
                if mError:erreur()
                then do:
                    mError:createError({&error}, 105978).    //erreur sur la synchronisation de la tache renouvellement
                    return.
                end.
            end.
        end.
    end.
    /*--> PBP 07/08/2001 : Regeneration de EQUIT si on a modifie la date d'effet du Bail */
    if glMajQuittancement and pcTypeTrt = "MODIFICATION"
    then do:
        // Accès à la 1ere quittance en cours non proratée
        find first equit no-lock
             where equit.noloc = giNumeroContrat
               and equit.nbden = equit.nbnum no-error.
        if available equit
        then do:
            // Génération a partir de EQUIT de TmQtt / ttRub avec la date d'effet modifiée
            ghProc = lancementPgm("bail/quittancement/genantqt.p", goCollectionHandlePgm).
            run lancementGenAntQt in ghProc(goCollectionContrat,
                                            ttObjetBail.daDateEffet,
                                            '00001',         // copie des rubriques
                                            substitute("&1#&2#E", string(Equit.NoQtt), string(Equit.MsQtt)),
                                            "01",
                                            input-output table ttQtt by-reference,
                                            input-output table ttRub by-reference,
                                            output viNoQttAnt,  // Pas utilisée ici, ne pas supprimer
                                            output viMsQttAnt). // Pas utilisée ici, ne pas supprimer
            if mError:erreur()
            then do:
                mError:createError({&error}, 105195).    //la creation des quittances dans TmQtt a echoué !
                return.
            end.
        end.
        else do:
            mError:createError({&error}, 105208).    //La première quittance en cours n'est pas disponible
            return.
        end.
        // Correction du numéro de la quittance : on génère les quittances suivant la facture.
        for first ttQtt:
            ttQtt.iNoQuittance = 2.
        end.
        for each ttRub:
            ttRub.iNoQuittance = 2.
        end.
        // creation des prochaines quittances dans TmQtt
        ghProc = lancementPgm("bail/quittancement/majpecqt.p", goCollectionHandlePgm).
        run lancementMajQuittancelocataire in ghProc(goCollectionContrat, 2, input-output table ttQtt by-reference, input-output table ttRub by-reference).
        if mError:erreur()
        then do:
            mError:createError({&error}, 105195).    //La création des quittances dans TmQtt a échoué!
            return.
        end.
        // Suppression des Equit
        ghProc = lancementPgm("crud/equit_CRUD.p", goCollectionHandlePgm).
        run deleteEquitSurLocataire in ghProc(giNumeroContrat).
        if mError:erreur() then return.
        // Creation des quit. de Equit a partir de TmQtt
        ghProc = lancementPgm("bail/quittancement/crelocqt.p", goCollectionHandlePgm).
        run lancementCrelocqt in ghProc(giNumeroContrat, input-output table ttQtt by-reference, input-output table ttRub by-reference).
        if mError:erreur()
        then do:
            mError:createError({&error}, 105196).    //La création des quittances dans equit a échoué!
            return.
        end.
        // MAJ Tache revision loyer
        find last tache no-lock
            where tache.tpcon = gcTypeContrat
              and tache.nocon = giNumeroContrat
              and tache.tptac = {&TYPETACHE-revision} no-error.
        if not available tache
        then do:
            mError:createError({&error}, 100350).    //modification non effectuée !!!
            return.
        end.
        create ttTache.
        assign
            ttTache.tpcon       = tache.tpcon
            ttTache.nocon       = tache.nocon
            ttTache.tptac       = tache.tptac
            ttTache.notac       = tache.notac
            ttTache.CRUD        = "U"
            ttTache.rRowid      = rowid(tache)
            ttTache.dtTimestamp = datetime(tache.dtmsy, tache.hemsy)
            ttTache.dtdeb = ttObjetBail.daDateEffet
            ttTache.dtfin = ttObjetBail.daDateEffet + tache.duree
        .
        ghProc = lancementPgm("crud/tache_CRUD.p", goCollectionHandlePgm).
        run setTache in ghProc(table ttTache by-reference).
        if mError:erreur()
        then do:
            mError:createError({&error}, 100350).    //modification non effectuée !!!
            return.
        end.
    end. /* FgMajQtt-IN AND TpActUse = "02" */

end procedure.

procedure ctlDuCtt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer ttObjetBail for ttObjetBail.

    define variable viNbMoiDur as integer no-undo.
    define variable viNbMoiMin as integer no-undo.
    define variable viNbMoiMax as integer no-undo.
    define variable voNatureContrat as class parametrageNatureContrat no-undo.

    assign
        viNbMoiDur = (if ttObjetBail.cUniteDuree = {&UNITE2DUREE-an} then 12 * ttObjetBail.iDuree else ttObjetBail.iDuree)
        voNatureContrat = new parametrageNatureContrat()
    .
    voNatureContrat:getDureeContratParNature(ttObjetBail.cCodeNatureContrat, output viNbMoiMin, output viNbMoiMax).
    delete object voNatureContrat.
    if viNbMoiMin <> ? and viNbMoiMax <> ?
    then do:
        if viNbMoiDur < viNbMoiMin or viNbMoiDur > viNbMoiMax
        then mError:createErrorGestion({&error}, 101142, substitute('&2&1&3', separ[1], string(viNbMoiMin), string(viNbMoiMax))).
    end.

end procedure.

procedure calDtExp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer ttObjetBail for ttObjetBail.

    define variable viNbMoiDur as integer no-undo.

    if ttObjetBail.daDateEffet = ? then return.
    if glIsBailComCiv
    then do:
        viNbMoiDur = 12 * ttObjetBail.iDureeAn + ttObjetBail.iDureeMois.
        if viNbMoiDur = 0 then return.
        ttObjetBail.daDateExpiration = add-interval(ttObjetBail.daDateEffet, viNbMoiDur, "months").
        ttObjetBail.daDateExpiration = ttObjetBail.daDateExpiration + ttObjetBail.iDureeJour - 1 .
    end.
    else do:
        viNbMoiDur = if ttObjetBail.cUniteDuree = {&UNITE2DUREE-an} then 12 * ttObjetBail.iDuree else ttObjetBail.iDuree.
        if viNbMoiDur = 0 then return.
        ttObjetBail.daDateExpiration = add-interval(ttObjetBail.daDateEffet, viNbMoiDur, "months").
        do while ttObjetBail.daDateExpiration < today:
            /*--> On boucle jusqu'a obtenir une date d'expiration supérieure à la date du jour */
            ttObjetBail.daDateExpiration = add-interval(ttObjetBail.daDateExpiration, viNbMoiDur, "months").
        end.
        ttObjetBail.daDateExpiration = ttObjetBail.daDateExpiration - 1.
    end.

end procedure.

procedure initObjet:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define parameter buffer ttObjetBail for ttObjetBail.

    define variable voDefautBail as class parametrageDefautBail no-undo.

    voDefautBail = new parametrageDefautBail(ttObjetBail.cCodeNatureContrat).
    if voDefautBail:isDbParameter
    then assign
         ttObjetBail.iDuree              = voDefautBail:getDuree()
         ttObjetBail.cUniteDuree         = voDefautBail:getUniteDuree()
         ttObjetBail.iDelaiPreavis       = voDefautBail:getDelaiPreavis()
         ttObjetBail.cUnitePreavis       = {&UNITE2DUREE-mois}
         ttObjetBail.lTaciteReconduction = voDefautBail:getTaciteReconduction()

    .

end procedure.

procedure controleObjet:
    /*------------------------------------------------------------------------------
    Purpose: controle objet
             pour ce controle, chargement info objet du bail dans la table ttObjetBail (comme pour un getObjet)
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
    run getObjet("", pcTypeContrat, piNumeroContrat, output table ttObjetBail, output table ttDateResiliationTriennale).
    if mError:erreur() then return.
    for first ttObjetBail:
        ttObjetBail.CRUD = "U".
        run initZoneGlobaleAvantTrt (buffer ctrat, buffer ttObjetBail).
        run verificationNonResiliation ("", buffer ctrat, buffer ttObjetBail).
//gga todo voir si inclure lancement de valMajEcr dans verificationResiliation       
        delete object goSyspr.
        delete object goCollectionContrat. 
        suppressionPgmPersistent(goCollectionHandlePgm).
    end.
    
end procedure.

procedure dateDroitResiliation:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :  service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeTrt as character no-undo.
    define input parameter table for ttObjetBail.
    define input-output parameter table for ttDateResiliationTriennale.

    define buffer ctrat for ctrat.

    find first ttObjetBail no-error.
    if not available ttObjetBail then return.

    find first ctrat no-lock
         where ctrat.tpcon = ttObjetBail.cCodeTypeContrat
           and ctrat.nocon = ttObjetBail.iNumeroContrat no-error.
    if not available ctrat then do:
        mError:createError({&error}, 100057).
        return.
    end.

    if pcTypeTrt = "INITDATEDROITRESILIATION"
    then run initDateDroitResiliation (ttObjetBail.cCodeTypeContrat,
                                       ttObjetBail.iNumeroContrat,
                                       ttObjetBail.daDAteEffet,
                                       ttObjetBail.daDAteExpiration,
                                       ttObjetBail.iDureeAn,
                                       ttObjetBail.iDureeMois).
    else run controleDateDroitResiliation (ttObjetBail.daDateEffet,
                                           ttObjetBail.daDateExpiration).

end procedure.

procedure initDateDroitResiliation private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pdaEffet        as date      no-undo.
    define input parameter pdaExpiration   as date      no-undo.
    define input parameter piDureeAn       as integer   no-undo.
    define input parameter piDureeMois     as integer   no-undo.

    define variable vdaResilationCalcule as date    no-undo.
    define variable vdaEffetSuivante     as date    no-undo.
    define variable viDuree              as integer no-undo.
    define variable viI                  as integer no-undo.

    empty temp-table ttDateResiliationTriennale.

    if pdaEffet <> ?
    and piDureeAn < 99
    and (piDureeAn <> 0 or piDureeMois <> 0)
    then do:
        assign
            vdaEffetSuivante = pdaEffet
            viDuree =  12 * piDureeAn + piDureeMois
        .
        do viI = 1 to viDuree by 12:
            vdaResilationCalcule = fCalculDateResiliation (vdaEffetSuivante, 3, 0, 0).
            if vdaResilationCalcule <> ? and vdaResilationCalcule < pdaExpiration
            then do:
                create ttDateResiliationTriennale.
                assign
                    ttDateResiliationTriennale.cTypeContrat   = pcTypeContrat
                    ttDateResiliationTriennale.iNumeroContrat = piNumeroContrat
                    ttDateResiliationTriennale.daResiliation  = vdaResilationCalcule
                    ttDateResiliationTriennale.iDureeAn       = 3
                    ttDateResiliationTriennale.iDureeMois     = 0
                    ttDateResiliationTriennale.iDureeJour     = 0
                    ttDateResiliationTriennale.CRUD           = "R"
                    vdaEffetSuivante                          = vdaResilationCalcule + 1
                .
            end.
            else leave.
        end.
    end.

end procedure.

procedure controleDateDroitResiliation private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pdaEffet      as date no-undo.
    define input parameter pdaExpiration as date no-undo.

    define variable vdaPrec as date no-undo.

    define buffer vbttDateResiliationTriennale for ttDateResiliationTriennale.

    find first ttDateResiliationTriennale where lookup(ttDateResiliationTriennale.CRUD, "C,D,U") > 0 no-error.
    if not available ttDateResiliationTriennale then return.

    if ttDateResiliationTriennale.daResiliation = ?
    then do:
        mError:createError({&error}, 1000963).                //date obligatoire
        return.
    end.
    if ttDateResiliationTriennale.daResiliation < pdaEffet
    then do:
        mError:createError({&error}, 1000964).                //La date de résiliation doit être supérieure à la date d'effet
        return.
    end.
    if ttDateResiliationTriennale.daResiliation >= pdaExpiration
    then do:
        mError:createError({&error}, 1000965).                //La date de résiliation doit être inférieure à la date d'expiration
        return.
    end.
    if can-find(first vbttDateResiliationTriennale
                where vbttDateResiliationTriennale.daResiliation  = ttDateResiliationTriennale.daResiliation
                  and rowid(vbttDateResiliationTriennale)         <> rowid(ttDateResiliationTriennale))
    then do:
        mError:createError({&error}, 1000966).                //La date de résiliation est deja existante
        return.
    end.
    vdaPrec = pdaEffet.
    for each ttDateResiliationTriennale
       where ttDateResiliationTriennale.daResiliation <> ?
          and ttDateResiliationTriennale.daResiliation > ttObjetBail.daDateEffet
    by ttDateResiliationTriennale.daResiliation:
        run calculAnMoisJour (vdaPrec, ttDateResiliationTriennale.daResiliation,
                              output ttDateResiliationTriennale.iDureeAn, output ttDateResiliationTriennale.iDureeMois, output ttDateResiliationTriennale.iDureeJour).
        vdaPrec = ttDateResiliationTriennale.daResiliation + 1.
    end.

end procedure.

procedure calculAnMoisJour private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure de calcul de la durée An+mois+jour à partir de la date d'effet et de la date d'expiration
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter  pdaDebut    as date    no-undo.
    define input parameter  pdaFin      as date    no-undo.
    define output parameter piDureeAn   as integer no-undo.
    define output parameter piDureeMois as integer no-undo.
    define output parameter piDureeJour as integer no-undo.

    define variable viNbMoisCal as integer no-undo.
    define variable vdaCalTmp   as date    no-undo.
    define variable vdaDatCal   as date    no-undo.
    define variable viI         as integer no-undo.

    if pdaDebut = ? or pdaFin = ? then return.
    if pdaDebut >= pdaFin then return.
    /* calcul nombre de mois de la période saisie */
    vdaCalTmp = pdaDebut.
    boucleCalculDate: do viI = 1 to 3000:
        vdaDatCal = add-interval(vdaCalTmp, 1, "months").
        if vdaDatCal < (pdaFin + 1)
        then do:
            assign
                viNbMoisCal = viNbMoisCal + 1
                vdaCalTmp   = vdaDatCal
            .
            next boucleCalculDate.
        end.
        else do:
            if vdaDatCal = pdaFin + 1
            then assign
                     viNbMoisCal = viNbMoisCal + 1
                     vdaCalTmp   = vdaDatCal
            .
            leave boucleCalculDate.
        end.
    end.
    if viNbMoisCal > 0
    then do:
        assign
            piDureeAn   = truncate(viNbMoisCal / 12, 0)
            piDureeMois = viNbMoisCal - 12 * piDureeAn
        .
        if vdaCalTmp < pdaFin + 1
        then piDureeJour = pdaFin + 1 - vdaCalTmp .
    end.

end procedure.

procedure initComboObjet:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :  service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as int64     no-undo.
    define output parameter table for ttCombo.

    define variable voSyspr         as class syspr                    no-undo.
    define variable voSyspg         as class syspg                    no-undo.
    define variable voOrigineClient as class parametrageOrigineClient no-undo.

    define buffer ctrat for ctrat.

    find first ctrat no-lock
        where ctrat.tpcon = pcTypeContrat
          and ctrat.nocon = piNumeroContrat no-error.
    if not available ctrat then do:
        mError:createError({&error}, 100057).
        return.
    end.

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
    voSyspr:getComboParametre("CLSTA", "CMBTYPEREGIME", output table ttCombo by-reference).
    delete object voSyspr.
    delete object voOrigineClient.

    for each ttCombo
        where ttCombo.cNomCombo = "CMBUNITEDUREE"
          and ttCombo.cCode    <> {&UNITE2DUREE-an}:
        voSyspg:creationttCombo("CMBUNITEDELAIPREAVIS", ttCombo.cCode, ttCombo.cLibelle, output table ttCombo by-reference).
    end.
    /* Supprimer les motifs ne concernant pas les Baux ( - et 0000x ) */
    for each ttCombo
       where ttCombo.cNomCombo = "CMBMOTIFRESILIATION":
        if ttCombo.cCode = {&MOTIF2RESILIATION-Aucun} then next.
        if ttCombo.cCode = {&MOTIF2RESILIATION-CessionBail}
        then do:
            /* Cession autorisée ssi bail commercial */
            if isBailCommercial (ctrat.ntcon) then next.
        end.
        else
        if ttCombo.cCode begins "0" then next.
        delete ttCombo.
    end.
    delete object voSyspg.

end procedure.

procedure initAutorisationObjet:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:   service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as int64     no-undo.
    define output parameter table-handle phttAutorisation.

    define variable vhTmpAutorisation as handle no-undo.

    create temp-table phttAutorisation.
//  phttAutorisation:add-new-field ("nom","type", extent, "format", initialisation).
    phttAutorisation:add-new-field ("lAnnulResiliation"        , "logical", 0, "", ?).
    phttAutorisation:add-new-field ("lModification"            , "logical", 0, "", ?).
    phttAutorisation:add-new-field ("lRenouvellement"          , "logical", 0, "", ?).
    phttAutorisation:add-new-field ("lResiliation"             , "logical", 0, "", ?).
    phttAutorisation:temp-table-prepare("ttAutorisation").
    vhTmpAutorisation = phttAutorisation:default-buffer-handle.
    run chargeAutorisation(pcTypeContrat, piNumeroContrat, vhTmpAutorisation).

end procedure.

procedure chargeAutorisation private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat     as character no-undo.
    define input parameter piNumeroContrat   as int64     no-undo.
    define input parameter phTmpAutorisation as handle    no-undo.

    define buffer ctrat for ctrat.
    define buffer tache for tache.

    find first ctrat no-lock
         where ctrat.tpcon = pcTypeContrat
           and ctrat.nocon = piNumeroContrat no-error.
    if not available ctrat
    then do:
        mError:createError({&error}, 100057).
        return.
    end.
    phTmpAutorisation:handle:buffer-create().
    if ctrat.dtree <> ?
    then assign
        phTmpAutorisation::lAnnulResiliation = yes
        phTmpAutorisation::lModification     = no
        phTmpAutorisation::lRenouvellement   = no
        phTmpAutorisation::lResiliation      = no
    .
    else assign
        phTmpAutorisation::lAnnulResiliation = no
        phTmpAutorisation::lModification     = yes
        phTmpAutorisation::lRenouvellement   = yes
        phTmpAutorisation::lResiliation      = yes
    .
    for last tache no-lock
       where tache.tpcon = pcTypeContrat
         and tache.nocon = piNumeroContrat
         and tache.tptac = {&TYPETACHE-renouvellement}:
        if tache.tpfin <> {&ETATPROCRENOU-aucuneProcedure} 
        then assign
                 phTmpAutorisation::lModification     = no
                 phTmpAutorisation::lRenouvellement   = no
        .
    end.

end procedure.

procedure iniDatLoc private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure de recuperation des dates entree/sortie en cours pour le locataire
    Notes:
    ------------------------------------------------------------------------------*/
    define output parameter pdaEntLoc   as date      no-undo.
    define output parameter pdaSorLoc   as date      no-undo.
    define output parameter pdaEntSui   as date      no-undo.
    define output parameter pcNomLocSui as character no-undo.

    define buffer tache for tache.
    define buffer ctrat for ctrat.

    for last tache no-lock
        where tache.tpcon = gcTypeContrat
          and tache.nocon = giNumeroContrat
          and tache.tptac = {&TYPETACHE-quittancement}:
        assign
            pdaEntLoc = tache.dtdeb
            pdaSorLoc = tache.dtFin
        .
    end.
    for first ctrat no-lock
        where ctrat.tpcon = gcTypeContrat
          and ctrat.nocon = giNumeroContrat + 1:
        pcNomLocSui = ctrat.lbnom.
    end.
    for last tache no-lock
       where tache.tpcon = gcTypeContrat
         and tache.nocon = giNumeroContrat + 1
         and tache.tptac = {&TYPETACHE-quittancement}:
        pdaEntSui = tache.dtdeb.
    end.

end procedure.

procedure calculMontantQuittance private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:   a partir de adb/quit/vueequit_ext.p (pas necessaire de creer un pgm car un seul appel de ce pgm)
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeQuittance   as character          no-undo.
    define input  parameter piNumeroQuittance as integer            no-undo.
    define output parameter pdMtLoy           as decimal decimals 2 no-undo.
    define output parameter pdMtPro           as decimal decimals 2 no-undo.

    empty temp-table ttQtt.
    empty temp-table ttRub.

    if pcTypeQuittance = "H"
    then do:
        ghProc = lancementPgm("bail/quittancement/quittanceHistorique.p", goCollectionHandlePgm).
        run getQuittance in ghProc(giNumeroContrat, piNumeroQuittance, output table ttQtt by-reference, output table ttRub by-reference).
    end.
    else do:
        ghProc = lancementPgm("bail/quittancement/quittanceEncours.p", goCollectionHandlePgm).
        run getQuittance in ghProc(goCollectionContrat, piNumeroQuittance, input-output table ttQtt by-reference, input-output table ttRub by-reference).
    end.
    if mError:erreur() then return.

    // calcul des montants cumules par famille
    if integer(mtoken:cRefPrincipale) = {&REFCLIENT-MANPOWER}
    then do:
        for each ttRub
           where ttRub.iNumeroLocataire = giNumeroContrat
             and ttRub.iNoQuittance     = piNumeroQuittance:
            if not ((ttRub.iNorubrique = 160 and ttRub.iNoLibelleRubrique = 2) or (ttRub.iNorubrique = 200 and ttRub.iNoLibelleRubrique = 2))
            then do:
                if ttRub.iNorubrique = 160
                then pdMtPro = pdMtPro + ttRub.dMontantTotal.                     //gga todo voir avec sylvie a quoi correspond vlmqt ??????????????
                else do:
                    case ttRub.iFamille :
                        when {&FamilleRubqt-Loyer} then
                            pdMtLoy = pdMtLoy + ttRub.dMontantTotal.
                        when {&FamilleRubqt-Charge} then
                            pdMtPro = pdMtPro + ttRub.dMontantTotal.
                    end case.
                end.
            end.
        end.
    end.
    else do:
        for each ttRub
           where ttRub.iNumeroLocataire = giNumeroContrat
             and ttRub.iNoQuittance     = piNumeroQuittance:
            case ttRub.iFamille :
                when {&FamilleRubqt-Loyer} then
                    pdMtLoy = pdMtLoy + ttRub.dMontantTotal.
                when {&FamilleRubqt-Charge} then
                    pdMtPro = pdMtPro + ttRub.dMontantTotal.
            end case.
        end.
    end.

end procedure.

procedure synRenou private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define variable voParametrageRenouvellement as class parametrageRenouvellement no-undo.

    define buffer cttac for cttac.
    define buffer tache for tache.

    empty temp-table ttCttac.
    empty temp-table ttTache.

    voParametrageRenouvellement = new parametrageRenouvellement().
    if voParametrageRenouvellement:isActif()
    then do:
        if ttObjetBail.lTaciteReconduction
        then do:
            /*--> Si en tacite recondution : on supprime la tache renouvellement */
            for each cttac no-lock
               where cttac.tpcon = gcTypeContrat
                 and cttac.nocon = giNumeroContrat
                 and cttac.tptac = {&TYPETACHE-renouvellement}:
                create ttCttac.
                assign
                    ttCttac.tpcon = cttac.tpcon
                    ttCttac.nocon = cttac.nocon
                    ttCttac.tptac = cttac.tptac
                    ttCttac.CRUD        = "D"
                    ttCttac.rRowid      = rowid(cttac)
                    ttCttac.dtTimestamp = datetime(cttac.dtmsy, cttac.hemsy)
                .
            end.
            for each tache no-lock
               where tache.tpcon = gcTypeContrat
                 and tache.nocon = giNumeroContrat
                 and tache.tptac = {&TYPETACHE-renouvellement}:
                create tttache.
                assign
                    ttTache.tpcon = tache.tpcon
                    ttTache.nocon = tache.nocon
                    ttTache.tptac = tache.tptac
                    ttTache.notac = tache.notac
                    ttTache.CRUD        = "D"
                    ttTache.rRowid      = rowid(tache)
                    ttTache.dtTimestamp = datetime(tache.dtmsy, tache.hemsy)
                .
            end.
        end.
        else do:
            find last tache no-lock
                where tache.tpcon = gcTypeContrat
                  and tache.nocon = giNumeroContrat
                  and Tache.tptac = {&TYPETACHE-renouvellement} no-error.
            /*--> Creation de la tache renouvellement si celle-ci n'existe pas */
            if not available tache
            then do:
                if not can-find(first cttac no-lock
                                where cttac.tpcon = gcTypeContrat
                                  and cttac.nocon = giNumeroContrat
                                  and cttac.tptac = {&TYPETACHE-renouvellement})
                then do:
                    create ttCttac.
                    assign
                        ttCttac.tpcon = gcTypeContrat
                        ttCttac.nocon = giNumeroContrat
                        ttCttac.tptac = {&TYPETACHE-renouvellement}
                        ttCttac.CRUD  = "C"
                    .
                end.
                create tttache.
                assign
                    ttTache.tpcon = gcTypeContrat
                    ttTache.nocon = giNumeroContrat
                    ttTache.tptac = {&TYPETACHE-renouvellement}
                    ttTache.noita = 0
                    ttTache.notac = 1
                    ttTache.CRUD  = "C"
                    ttTache.dtdeb = ttObjetBail.daDateEffet
                    ttTache.dtfin = ttObjetBail.daDateExpiration
                    ttTache.tpfin = "00"
                .
            end.
            else do:
                /*--> Si la tache renouvellement est ds son etat initiale on verifie les dates */
                if tache.tpfin = "00"
                then do:
                    create tttache.
                    assign
                        ttTache.tpcon       = tache.tpcon
                        ttTache.nocon       = tache.nocon
                        ttTache.tptac       = tache.tptac
                        ttTache.notac       = tache.notac
                        ttTache.CRUD        = "U"
                        ttTache.rRowid      = rowid(tache)
                        ttTache.dtTimestamp = datetime(tache.dtmsy, tache.hemsy)
                        ttTache.dtdeb       = ttObjetBail.daDateEffet
                        ttTache.dtfin       = ttObjetBail.daDateExpiration
                        ttTache.tpfin       = "00"
                    .
                end.
            end.
        end.
    end.
    delete object voParametrageRenouvellement.
    if can-find (first ttCttac)
    then do:
        ghProc = lancementPgm("crud/cttac_CRUD.p", goCollectionHandlePgm).
        run setCttac in ghProc(table ttCttac by-reference).
        if mError:erreur() then return.
    end.
    if can-find (first ttTache)
    then do:
        ghProc = lancementPgm("crud/tache_CRUD.p", goCollectionHandlePgm).
        run setTache in ghProc(table ttTache by-reference).
        if mError:erreur() then return.
    end.

end procedure.

procedure majRenou private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define buffer tache for tache.

    empty temp-table ttTache.
    for last tache no-lock
       where tache.tpcon = gcTypeContrat
         and tache.nocon = giNumeroContrat
         and tache.tptac = {&TYPETACHE-renouvellement}:
        /*--> Specifier que la procedure de renouvellement est traitée */
        create tttache.
        assign
            ttTache.tpcon       = tache.tpcon
            ttTache.nocon       = tache.nocon
            ttTache.tptac       = tache.tptac
            ttTache.notac       = tache.notac
            ttTache.CRUD        = "U"
            ttTache.rRowid      = rowid(tache)
            ttTache.dtTimestamp = datetime(tache.dtmsy, tache.hemsy)
            ttTache.dtdeb       = ttObjetBail.daDateEffet
            ttTache.dtfin       = ttObjetBail.daDateExpiration
            ttTache.tpfin       = "50"
            ttTache.cdhon       = substitute("&1&2&3&4", tache.cdhon, (if tache.cdhon = "" then "" else "#"), string(today,"99/99/9999"), "&00012")
        .
        /*--> Ouvrir une nv periode de renouvellement */
        create tttache.
        assign
            ttTache.tpcon = gcTypeContrat
            ttTache.nocon = giNumeroContrat
            ttTache.tptac = {&TYPETACHE-renouvellement}
            ttTache.noita = 0
            ttTache.notac = 1
            ttTache.CRUD  = "C"
            ttTache.dtdeb = ttObjetBail.daDateEffet
            ttTache.dtfin = ttObjetBail.daDateExpiration
            ttTache.tpfin = "00"
        .
    end.
    if can-find (first ttTache)
    then do:
        ghProc = lancementPgm("crud/tache_CRUD.p", goCollectionHandlePgm).
        run setTache in ghProc(table ttTache by-reference).
        if mError:erreur() then return.
    end.

end procedure.

procedure verifRubSup private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define variable viI                as integer   no-undo.
    define variable vcLibelleAno       as character no-undo.
    define variable vcNumeroRubrique   as character no-undo.
    define variable vlRubriqueVariable as logical   no-undo.
    define variable viRetourQuestion   as integer   no-undo.

    define buffer equit for equit.

    if not glContratFournisseurLoyer
    then do:
        for each equit no-lock
           where equit.noloc = giNumeroContrat
             and equit.dtdpr > ttObjetBail.daResiliation
             and ((equit.cdter = {&TERMEQUITTANCEMENT-avance} and equit.msqtt >= giMoisModifiable) or (equit.cdter = {&TERMEQUITTANCEMENT-echu} and equit.msqtt >= giMoisEchu)):
            vcLibelleAno = "".
            do viI = 1 to 20:
                if equit.tbrub[viI] > 0 and equit.tbgen[viI] = "00003"
                then do:
                    /* ignorer rub Franchise, DG */
                    vcNumeroRubrique = string(equit.tbrub[viI],"999").
                    if lookup (vcNumeroRubrique, "108,581") = 0
                    then do:
                        if vcLibelleAno = ""
                        then vcLibelleAno = substitute("&1 &2/&3 :", outilTraduction:getLibelle(0101690), substring(string(equit.msqtt, "999999"), 5, 2), substring(string(equit.msqtt, "999999"), 1, 4)).
                        assign
                            vcLibelleAno       = substitute("&1 &2.&3 = &4,", vcLibelleAno, vcNumeroRubrique, string(equit.TbLib[viI], "99"), equit.Tbmtq[viI])
                            vlRubriqueVariable = yes
                        .
                    end.
                end.
            end.
            if vcLibelleAno > "" then mError:createListeErreur(trim(vcLibelleAno, ",")).          //cette table ttListeErreur est recuperee dans beBail.cls comme la table ttError
        end.
        // ATTENTION Rubriques saisies sur quittancement à venir.
        // Des rubriques de régularisation (type variable) sont présentes sur des avis d’échéances postérieurs à la date de résiliation,
        // ces avis d’échéance ainsi que ces rubriques seront supprimés: &1
        // Confirmez-vous cette date de résiliation ?
        if vlRubriqueVariable
        then do:
            viRetourQuestion = outils:questionnaire(1000950, table ttError by-reference).
            if viRetourQuestion < 2 then return.
            if viRetourQuestion = 2
            then do:
                // reponse non. On transforme le type de l'erreur de -4 (question traitee) en 4 (question) si non les tests if mError:erreur() ne 
                // fonctionnent pas alors que dans ce cas on veut quitter le programme (normalement si reponse non l'ihm ne doit pas faire d'appel au pgm)
                mError:chgTypeQuestion(1000950).
                return.
            end.
            mError:purgeListeErreur().               //pas besoin de la liste si on continue le traitement
        end.
    end.

end procedure.

procedure initZoneGlobaleAvantTrt private:
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes:   
    ------------------------------------------------------------------------------*/      
    define parameter buffer ctrat for ctrat.
    define parameter buffer ttObjetBail for ttObjetBail.
      
    assign
        giNumeroContrat            = ttObjetBail.iNumeroContrat
        gcTypeContrat              = ttObjetBail.cCodeTypeContrat
        giNumeroMandat             = truncate(ctrat.nocon / 100000, 0)   
        giNumeroUl                 = truncate((ctrat.nocon modulo 100000) / 100, 0)
        glIsBailComCiv             = isBailComCiv(ctrat.ntcon) 
        glIsBrwResil               = isBrwResil(ctrat.ntcon)              
        glRelocation               = isRelocation()
        goCollectionContrat        = new collection()  
        goCollectionHandlePgm      = new collection()         
        goSyspr                    = new syspr()
        gdaAncienDateExpiration    = ctrat.dtfin
        gdaAncienDateResiliation   = ctrat.dtree
        glAncienTaciteReconduction = (ctrat.tpren = {&TACITERECONDUCTION-YES})  
        gcTacOld                   = ctrat.tpren           
    .
    goCollectionContrat:set("iNumeroRole", int64(ctrat.nocon)) no-error.    //gga todo
//gga a voir    goCollectionContrat:set("cTypeRole", {&TYPEROLE-locataire}).
    goCollectionContrat:set("cTypeContrat", ctrat.tpcon) no-error.
    goCollectionContrat:set("iNumeroContrat", int64(ctrat.nocon)) no-error.
    goCollectionContrat:set("iNumeroMandat", giNumeroMandat).    
    run chgMoisQuittance(giNumeroMandat, input-output goCollectionContrat).
    assign
        giMoisQuittancement       = goCollectionContrat:getInteger("iMoisQuittancement")
        giMoisModifiable          = goCollectionContrat:getInteger("iMoisModifiable")
        giMoisEchu                = goCollectionContrat:getInteger("iMoisEchu")
        glContratFournisseurLoyer = goCollectionContrat:getLogical("lBailFournisseurLoyer")
    .

end procedure.



/*gga todo
/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   Procedure de contr“le de la date de 1er contrat  du bail   /*NO 27/03/2002*/             /*NO 29/03/2002*/
 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
procedure VerDtaDt1:
    define  input parameter DtDatSai-IN     as date         no-undo.
    define output parameter FgVerZon-OU as logical init true    no-undo.

    /*NO 27/03/2002 Contrôle : la date du 1er contrat doit être supérieure à la date de résiliation du bail précédent*/
    /*SY - 14/10/2004 : Sauf si la bail pr‚c‚dent a ‚t‚ c‚d‚                 */
       /*--> Recherche du bail précédent*/
       if TpCttUse = "01033" then do:
            run PrcPreSui("P",output CpUseInc).
            if CpUseInc = 1 and TpMotRes <> "00006" and DtDatSai-IN <= DtFinBai then do:
              /*la date du premier contrat doit être supérieure à la date de résiliation du bail précédent */
              run GestMess in HdLibPrc(000001,"",107066,"",string(DtFinBai),"ERROR",output FgRepMes).
              assign FgVerZon-OU = false.
              return.
        end.
    end.
end procedure.
gga todo*/