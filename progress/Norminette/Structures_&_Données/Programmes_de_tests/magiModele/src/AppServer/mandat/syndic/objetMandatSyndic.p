/*------------------------------------------------------------------------
File        : objetMandatSyndic.p
Purpose     : objet du mandat de syndic
Author(s)   : GGA  -  2018/01/07
Notes       : reprise du pgm adb/cont/gesobj00.p
              mais uniquement le code pour type mandat syndic
derniere revue: 2019/01/22 - ofa: KO
        traiter les TODO
        messages debug
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
{preprocesseur/type2acte.i}
{preprocesseur/unite2duree.i}
{preprocesseur/motif2resiliation.i}

using parametre.pclie.parametrageFournisseurLoyer.
using parametre.pclie.parametrageDefautMandat.
using parametre.pclie.parametragePayePegase.
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
{mandat/include/objetMandatSyndic.i}
{crud/include/ctrat.i}
{crud/include/intnt.i}
{immeubleEtLot/include/cpuni.i}
{cadbgestion/include/soldmdt1.i}  // procedure soldmdt1Controle

define variable goSyspr                      as class syspr no-undo.
define variable glNumeroRegistreAuto         as logical no-undo.
define variable glAutorisationModification   as logical no-undo.
define variable glAutorisationRenouvellement as logical no-undo.
define variable glAutorisationResiliation    as logical no-undo.

define temp-table ttIetab
    field soc-cd      as integer
    field etab-cd     as integer
    field fg-cptim    as logical
    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.

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
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeTrt       as character no-undo.
    define input  parameter piNumeroContrat as int64     no-undo.
    define output parameter table for ttObjetMandatSyndic.

    define buffer ctrat for ctrat.
    define buffer tache for tache.

    empty temp-table ttObjetMandatSyndic.
    find first ctrat no-lock
        where ctrat.tpcon = {&TYPECONTRAT-mandat2Syndic}
          and ctrat.nocon = piNumeroContrat no-error.
    if not available ctrat then do:
        mError:createError({&error}, 100057).
        return.
    end.
    run lectInfoCtrat(piNumeroContrat).
    if pcTypeTrt = "RENOUVELLEMENT" then do:
        if ttObjetMandatSyndic.daDateExpiration < today then do:
            ttObjetMandatSyndic.daDateNomination = ttObjetMandatSyndic.daDateExpiration + 1.
            run calculDateExpiration(buffer ttObjetMandatSyndic).
        end.
    end.

end procedure.

procedure setObjet:
    /*------------------------------------------------------------------------------
    Purpose: maj infos objet mandat
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input        parameter pcTypeTrt as character no-undo.
    define input-output parameter table for ttObjetMandatSyndic.
    define input        parameter table for ttError.

    define buffer ctrat for ctrat.

    for first ttObjetMandatSyndic
        where lookup(ttObjetMandatSyndic.CRUD, "C,U") > 0:
        find first ctrat no-lock
            where ctrat.tpcon = ttObjetMandatSyndic.cCodeTypeContrat
              and ctrat.nocon = ttObjetMandatSyndic.iNumeroContrat no-error.
        if not available ctrat then do:
            mError:createError({&error}, 100057).
            return.
        end.
        goSyspr = new syspr().
        run chargeAutorisation (buffer ctrat).
        if pcTypeTrt = "RESILIATION"
        then run verificationResiliation(buffer ctrat, buffer ttObjetMandatSyndic).
        else run verificationNonResiliation(pcTypeTrt, buffer ctrat, buffer ttObjetMandatSyndic).
        delete object goSyspr.
        if not mError:erreur() then run valMajEcr(pcTypeTrt, buffer ttObjetMandatSyndic).
        if not mError:erreur() then run majCtrat(pcTypeTrt, buffer ctrat, buffer ttObjetMandatSyndic).
    end.

//gga mError:createError({&error}, "fin test gg").

end procedure.

procedure lectInfoCtrat private:
    /*------------------------------------------------------------------------------
    Purpose: affichage information objet d'un mandat
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as int64 no-undo.

    define variable vcReferenceVilogia as character no-undo.  // liste des références clients Vilogia

    define buffer ctrat for ctrat.
    define buffer idev  for idev.

    for first ctrat no-lock
        where ctrat.tpcon = {&TYPECONTRAT-mandat2Syndic}
          and ctrat.nocon = piNumeroContrat:
        create ttObjetMandatSyndic.
        assign
            ttObjetMandatSyndic.CRUD                          = 'R'
            ttObjetMandatSyndic.cCodeTypeContrat              = ctrat.tpcon
            ttObjetMandatSyndic.iNumeroContrat                = ctrat.nocon
            ttObjetMandatSyndic.iNumeroDocument               = ctrat.nodoc
            ttObjetMandatSyndic.cLibelleTypeContrat           = outilTraduction:getLibelleProg("O_CLC", ctrat.tpcon)
            ttObjetMandatSyndic.cCodeNatureContrat            = ctrat.ntcon
            ttObjetMandatSyndic.cLibelleNatureContrat         = outilTraduction:getLibelleProg("O_COT", ctrat.ntcon)
            ttObjetMandatSyndic.cCodeDevise                   = ctrat.cddev
            ttObjetMandatSyndic.daDateNomination              = ctrat.dtdeb
            ttObjetMandatSyndic.daDateExpiration              = ctrat.dtfin
            ttObjetMandatSyndic.daDateInitiale                = ctrat.dtini
            ttObjetMandatSyndic.daResiliation                 = ctrat.dtree
            ttObjetMandatSyndic.daSignature                   = ctrat.dtsig
            ttObjetMandatSyndic.cLieuSignature                = ctrat.lisig
            ttObjetMandatSyndic.cNumeroRegistre               = ctrat.noree
            ttObjetMandatSyndic.lTaciteReconduction           = (ctrat.tpren = {&TACITERECONDUCTION-YES})
            ttObjetMandatSyndic.iDuree                        = ctrat.nbdur
            ttObjetMandatSyndic.cUniteDuree                   = ctrat.cddur
            ttObjetMandatSyndic.cLibelleUniteDuree            = outilTraduction:getLibelleParam("UTDUR", ctrat.cddur)
            ttObjetMandatSyndic.iDelaiPreavis                 = ctrat.nbres
            ttObjetMandatSyndic.cUnitePreavis                 = ctrat.utres
            ttObjetMandatSyndic.cLibelleUnitePreavis          = outilTraduction:getLibelleParam("UTDUR", ctrat.utres)
            ttObjetMandatSyndic.cTypeActe                     = ctrat.tpact
            ttObjetMandatSyndic.cLibelleTypeActe              = outilTraduction:getLibelleParam("TPACT", ctrat.tpact)
            ttObjetMandatSyndic.lResiliation                  = ctrat.dtree <> ?
            ttObjetMandatSyndic.cMotifResiliation             = ctrat.tpfin
            ttObjetMandatSyndic.cLibelleMotifResiliation      = outilTraduction:getLibelleParam("TPMOT", ctrat.tpfin)
            ttObjetMandatSyndic.lProvisoire                   = ctrat.fgprov
            ttObjetMandatSyndic.iNumeroBlocNote               = ctrat.noblc
            ttObjetMandatSyndic.iNumeroImmeuble               = getNumeroImmeuble(ctrat.nocon, ctrat.tpcon)
            ttObjetMandatSyndic.dtTimestamp                   = datetime(ctrat.dtmsy, ctrat.hemsy)
            ttObjetMandatSyndic.rRowid                        = rowid(ctrat)
        .
        run soldmdt1Controle(mToken:cRefCopro,
                             ctrat.nocon,
                             output ttObjetMandatSyndic.daOdFinMandat,
                             output ttObjetMandatSyndic.daArchivage).
        for first idev no-lock
            where idev.soc-cd = integer(mtoken:cRefCopro)
              and idev.dev-cd = ttObjetMandatSyndic.cCodeDevise:
            ttObjetMandatSyndic.cLibelleCodeDevise = idev.lib.
        end.
        vcReferenceVilogia = "{&REFCLIENT-3140},{&REFCLIENT-4140},{&REFCLIENT-GIDEV},{&REFCLIENT-GICLI}".
        if lookup(mtoken:cRefPrincipale, vcReferenceVilogia) > 0
        then ttObjetMandatSyndic.cNumeroContratIkos = ctrat.cdusage1.
    end.

end procedure.

procedure initObjet:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define parameter buffer ttCtrat for ttCtrat.

    define variable voNumeroRegistreMandat as class parametrageNumeroRegistreMandat no-undo.

    assign
        ttCtrat.tpren = {&TACITERECONDUCTION-YES}
        ttCtrat.tpact = {&TYPEACTE-neant}
        ttCtrat.cddev = mToken:cDeviseReference
        voNumeroRegistreMandat = new parametrageNumeroRegistreMandat()
    .
    if voNumeroRegistreMandat:isNumeroRegistreAuto() then ttCtrat.noree = "AUTO".
    delete object voNumeroRegistreMandat.

end procedure.

procedure initComboObjet:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :  service externe
    ------------------------------------------------------------------------------*/
    define output parameter table for ttCombo.

    define variable voSyspr as class syspr no-undo.
    define variable voSyspg as class syspg no-undo.

    empty temp-table ttCombo.
    assign
        voSyspg = new syspg()
        voSyspr = new syspr()
    .
    voSyspr:getComboParametre("UTDUR", "CMBUNITEDUREE", output table ttCombo by-reference).
    voSyspr:getComboParametre("TPACT", "CMBTYPEACTE", output table ttCombo by-reference).
    voSyspr:getComboParametre("TPMOT", "CMBMOTIFRESILIATION", output table ttCombo by-reference).
    delete object voSyspr.

    for each ttCombo
        where ttCombo.cNomCombo = "CMBUNITEDUREE"
          and ttCombo.cCode    <> {&UNITE2DUREE-an}:
        voSyspg:creationttCombo("CMBUNITEDELAIRESILIATION", ttCombo.cCode, ttCombo.cLibelle, output table ttCombo by-reference).
    end.
    // supprimer les motifs de resiliation ne concernant pas les Mandats de syndic
    for each ttCombo
       where ttCombo.cNomCombo = "CMBMOTIFRESILIATION":
        if ttCombo.cCode = {&MOTIF2RESILIATION-Aucun}
        or (ttCombo.cCode begins "1" and (ttCombo.cCode < {&MOTIF2RESILIATION-PassageSousLocation} or ttCombo.cCode begins "13"))
        then .
        else delete ttCombo.
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
    define parameter buffer ttObjetMandatSyndic for ttObjetMandatSyndic.

    define variable vhProc             as handle    no-undo.

    define variable vdaEffMin                 as date      no-undo.
    define variable vdaEffMax                 as date      no-undo.
    define variable vdaDtsMin                 as date      no-undo.
    define variable vdaDtsMax                 as date      no-undo.
    define variable vlNumeroRegistreAuto      as logical   no-undo.
    define variable vcAnneeMoisComptableCopro as character no-undo.
    define variable vcAnneeMoisNomination     as character no-undo.
    define variable vcAnneeMoisMax            as character no-undo.
    
    define variable voNumeroRegistreMandat as class parametrageNumeroRegistreMandat no-undo.

    define buffer ctctt   for ctctt.

    assign
        voNumeroRegistreMandat = new parametrageNumeroRegistreMandat().
        vlNumeroRegistreAuto   = voNumeroRegistreMandat:isNumeroRegistreAuto()
    .
    delete object voNumeroRegistreMandat.

    if pcTypeTrt = "RENOUVELLEMENT" then do:
        if not glAutorisationRenouvellement then do:
            mError:createError({&error}, 1000979).            //Renouvellement objet interdit
            return.
        end.
    end.
    else
        if not glAutorisationModification then do:
            mError:createError({&error}, 1000980).            //Mise à jour objet interdite
            return.
        end.

    /*--> Numero Reel de Contrat */
    if ttObjetMandatSyndic.cNumeroRegistre = "" or ttObjetMandatSyndic.cNumeroRegistre = ? then do:
        mError:createError({&error}, 100071).
        return.
    end.
    if vlNumeroRegistreAuto and ttObjetMandatSyndic.cNumeroRegistre <> ctrat.noree then do:
        mError:createError({&error}, 1000981).              //gestion numéro registre AUTO, modification du numéro interdite
        return.
    end.
    
    /*--> Date du 1er contrat */
    if ttObjetMandatSyndic.daDateInitiale = ? then do:
        mError:createError({&error}, 104078).
        return.
    end.
    if ttObjetMandatSyndic.daDateNomination = ? then do:
        mError:createError({&error}, 100072).            /* la date d'effet est obligatoire */
        return.
    end.
    run cadbgestion/moismdt.p persistent set vhProc.
    run getTokenInstance in vhProc(mToken:JSessionId).
    run rechercheAnneeMoisComptableCopro in vhProc(integer(mtoken:cRefGerance), ttObjetMandatSyndic.iNumeroContrat, output vcAnneeMoisComptableCopro).
    run destroy in vhproc.
    if mError:erreur() then return.
    assign
        vcAnneeMoisNomination = string(year(ttObjetMandatSyndic.daDateNomination), "9999") + string(month(ttObjetMandatSyndic.daDateNomination), "99")
        vcAnneeMoisMax = string(integer(substring(vcAnneeMoisComptableCopro, 1 , 4) ) + 1) + substring(vcAnneeMoisComptableCopro, 5 , 2)
    .
    if vcAnneeMoisNomination > vcAnneeMoisMax then do:
        mError:createErrorGestion({&error}, 105590, string(vcAnneeMoisComptableCopro)). //la date d'effet doit être inférieure ou égale au mois comptabme en cours (%1) + 1 an
        return.
    end.
    if ttObjetMandatSyndic.daDateInitiale > ttObjetMandatSyndic.daDateNomination then do:
        mError:createError({&error}, 104079).
        return.
    end.
      
    if pcTypeTrt = "RENOUVELLEMENT"
    and ctrat.dtdeb <> ? and ttObjetMandatSyndic.daDateNomination < ctrat.dtdeb then do:
        mError:createErrorGestion({&error}, 101955, string(ctrat.dtdeb, "99/99/9999")).
        return.
    end.
    assign
        vdaEffMin = add-interval(today, -98, "year")
        vdaEffMax = add-interval(today, 1, "year")
        .
    if ttObjetMandatSyndic.daDateNomination <= vdaEffMin or ttObjetMandatSyndic.daDateNomination >= vdaEffMax then do:
        // Date d'effet incorrecte &1. La date d'effet doit être supérieure au &2 et inférieure au &3
        mError:createError({&error}, 1000430, substitute("&2&1&3&1&4", separ[1], if ttObjetMandatSyndic.daDateNomination <> ? then string(ttObjetMandatSyndic.daDateNomination) else " ", string(vdaEffMin), string(vdaEffMax))).
        return.
    end.
    /*--> Duree du Contrat */
    if ttObjetMandatSyndic.iDuree = ? then do:
        mError:createError({&error}, 100073).
        return.
    end.
    if ttObjetMandatSyndic.iDuree = 0 then do:
        mError:createError({&error}, 101998).
        return.
    end.
    /*--> Unite Duree du Contrat. */
    if not goSyspr:isParamExist("UTDUR", ttObjetMandatSyndic.cUniteDuree) then do:
        mError:createError({&error}, 100074).
        return.
    end.
    /* controle de la durée du contrat */
    run ctlDuCtt(buffer ttObjetMandatSyndic).
    if mError:erreur() then return.
    if ttObjetMandatSyndic.daDateExpiration = ? then do:
        mError:createError({&error}, 100075).
        return.
    end.
    if ttObjetMandatSyndic.daDateExpiration <= ttObjetMandatSyndic.daDateNomination then do:
        mError:createError({&error}, 100076).
        return.
    end.
    /*--> Delai de resiliation*/
    if ttObjetMandatSyndic.iDelaiPreavis = ? then do:
        mError:createError({&error}, 100077).
        return.
    end.
    if ttObjetMandatSyndic.iDelaiPreavis = 0 then do:
        mError:createError({&error}, 102045).
        return.
    end.
    /*--> Unite de Delai de resiliation */
    if not goSyspr:isParamExist("UTDUR", ttObjetMandatSyndic.cUnitePreavis)
    or ttObjetMandatSyndic.cUnitePreavis = {&UNITE2DUREE-an} then do:
        mError:createError({&error}, 100078).
        return.
    end.
    if integer(mtoken:cRefPrincipale) <> {&REFCLIENT-MANPOWER} then do:
        if ttObjetMandatSyndic.daSignature = ? then do:
            mError:createError({&error}, 100079).
            return.
        end.
        assign
            vdaDtsMin = ttObjetMandatSyndic.daDateInitiale
            vdaDtsMin = add-interval(vdaDtsMin, -1, "year")
            vdaDtsMin = date(month(vdaDtsMin), 1, year(vdaDtsMin))
            vdaDtsMax = ttObjetMandatSyndic.daDateInitiale
            vdaDtsMax = add-interval(vdaDtsMax, 13, "month")
            vdaDtsMax = date(month(vdaDtsMax), 1, year(vdaDtsMax)) - 1
        .
        if (ttObjetMandatSyndic.daSignature > vdaDtsMax or ttObjetMandatSyndic.daSignature < vdaDtsMin)
            and outils:questionnaire(107343, table ttError by-reference) <= 2 then return. //La date de signature a plus d'un an d'écart avec la date du 1er contrat, Confirmez vous ?
        if ttObjetMandatSyndic.cLieuSignature = ? or ttObjetMandatSyndic.cLieuSignature = "" then do:
            mError:createError({&error}, 100081).
            return.
        end.
    end.
    if not goSyspr:isParamExist("TPACT", ttObjetMandatSyndic.cTypeActe) then do:
        mError:createError({&error}, 100082).
        return.
    end.

end procedure.

procedure verificationResiliation private:
    /*------------------------------------------------------------------------------
    Purpose: controle infos objet mandat avant maj
    Notes  : ancien (verZonSai, blc-val-menu)
    ------------------------------------------------------------------------------*/
    define parameter buffer ctrat    for ctrat.
    define parameter buffer ttObjetMandatSyndic for ttObjetMandatSyndic.

    define variable viRetourQuestion   as integer   no-undo.
    define variable vhProcctrconvm     as handle    no-undo.

    define buffer trdos   for trdos.
    define buffer trfpm   for trfpm.

    if not glAutorisationResiliation then do:
        mError:createError({&error}, 1000982).                  //Résiliation ou annulation résiliation interdite
        return.
    end.
    if not ttObjetMandatSyndic.lResiliation then do:
        if ctrat.dtree = ? then do:
            mError:createError({&error}, 1000983).              //demande d'annulation de résiliation pour un mandat non résilié
            return.
        end.
        // en annulation date et motif remis a blanc. On force dans la table sans controle.
        assign
            ttObjetMandatSyndic.daResiliation     = ?
            ttObjetMandatSyndic.cMotifResiliation = "00000"
            ttObjetMandatSyndic.daOdFinMandat     = ?
        .
    end.
    else do:
        if ttObjetMandatSyndic.daResiliation = ? then do:
            mError:createError({&error}, 100083). // La date de résiliation est obligatoire
            return.
        end.
        if ttObjetMandatSyndic.daResiliation < ctrat.dtini then do:
            mError:createError({&error}, 105575). // La date de résiliation doit être postérieure à la date du 1er contrat
            return.
        end.
        if ttObjetMandatSyndic.daResiliation < ctrat.dtsig then do:
            mError:createError({&error}, 102047). // La date de résiliation doit être postérieure à la date de signature !!
            return.
        end.
        if ttObjetMandatSyndic.daResiliation > ctrat.dtfin then do:
            viRetourQuestion = outils:questionnaireGestion(110374, substitute('&2&1', separ[1], string(ttObjetMandatSyndic.daResiliation)), table ttError by-reference). //La date de résiliation devrait être antérieur à la date d'expiration. Confirmez-vous la date de résiliation au %1 ?
            if viRetourQuestion < 2 then return.
            if viRetourQuestion = 2 then do:
                // reponse non. On transforme le type de l'erreur de -4 (question traitee) en 4 (question) si non les tests if mError:erreur() ne 
                // fonctionnent pas alors que dans ce cas on veut quitter le programme (normalement si reponse non l'ihm ne doit pas faire d'appel au pgm)
                mError:chgTypeQuestion(110374).
                return.
            end.
        end.
        if ttObjetMandatSyndic.cMotifResiliation = "" or ttObjetMandatSyndic.cMotifResiliation = ? then do:
            mError:createError({&error}, 100085). //Le motif de résiliation est obligatoire
            return.
        end.
        if not goSyspr:isParamExist("TPMOT", ttObjetMandatSyndic.cMotifResiliation) then do:
            mError:createError({&error}, 1000420). //Motif de résiliation incorrect
            return.
        end.
        if ttObjetMandatSyndic.cMotifResiliation = "00000"
        or (ttObjetMandatSyndic.cMotifResiliation begins "1" and (ttObjetMandatSyndic.cMotifResiliation < "10002" or ttObjetMandatSyndic.cMotifResiliation begins "13"))
        then .
        else do:
            mError:createError({&error}, 1000420). //Motif de résiliation incorrect
            return.
        end.
        /* Controle : Dossier travaux cloturés mais pas transmis à GI */
        for each trdos no-lock
           where trdos.tpcon = ttObjetMandatSyndic.cCodeTypeContrat
             and trdos.nocon = ttObjetMandatSyndic.iNumeroContrat
             and trdos.dtree <> ?:
            find first trfpm no-lock
                 where trfpm.tptrf = "AP"
                   and trfpm.tpapp = "CX"
                   and trfpm.nomdt = trdos.nocon
                   and trfpm.noexe = trdos.nodos no-error.
            if not available trfpm or trfpm.ettrt = {&ETATTRAITEMENT-NonTraite} or trfpm.ettrt = {&ETATTRAITEMENT-RetirageDemande} then do:
                mError:createError({&error}, 1000426, string(trdos.nodos)). // La demande de tirage de clôture travaux n'a pas été traitée pour le dossier travaux n° &1. Résiliation impossible.
                return.
            end.
            if not can-find (first trfpm no-lock
                             where trfpm.tptrf = "AP"
                               and trfpm.tpapp = "CX"
                               and trfpm.nomdt = trdos.nocon
                               and trfpm.noexe = trdos.nodos
                               and (lookup(trfpm.ettrt, substitute('&1,&2,&3', {&ETATTRAITEMENT-Traite}, {&ETATTRAITEMENT-RetirageTraite}, {&ETATTRAITEMENT-TraiteEnExterne})) > 0 ))
            then do:
                mError:createError({&error}, 1000427, string(trdos.nodos)). // La clôture travaux n'a pas été intégrée pour le dossier travaux n° &1. Résiliation impossible !
                return.
            end.
        end.
        if can-find (first trdos no-lock
                     where trdos.tpcon = ttObjetMandatSyndic.cCodeTypeContrat
                       and trdos.nocon = ttObjetMandatSyndic.iNumeroContrat
                       and trdos.dtree = ?) then do:
            viRetourQuestion = outils:questionnaire(1000428, table ttError by-reference). // Il existe des dossiers travaux non clôturés sur ce contrat. Confirmez-vous la résiliation du contrat ?
            if viRetourQuestion < 2 then return.
            else if viRetourQuestion = 2 then do:
                // reponse non. On transforme le type de l'erreur de -4 (question traitee) en 4 (question) si non les tests if mError:erreur() ne 
                // fonctionnent pas alors que dans ce cas on veut quitter le programme (normalement si reponse non l'ihm ne doit pas faire d'appel au pgm)
                mError:chgTypeQuestion(1000428).
                return.
            end.
        end.
        if ttObjetMandatSyndic.daOdFinMandat <> ? then do:
            run adblib/ctrconvm.p persistent set vhProcctrconvm.
            run getTokenInstance in vhProcctrconvm(mToken:JSessionId).
            run ctrconvmControle in vhProcctrconvm (ttObjetMandatSyndic.cCodeTypeContrat, ttObjetMandatSyndic.iNumeroContrat, ttObjetMandatSyndic.daResiliation, ttObjetMandatSyndic.cMotifResiliation, ttObjetMandatSyndic.daOdFinMandat).
            run destroy in vhprocctrconvm.
            if mError:erreur() then return.

            mError:createError({&information}, 1000429). //Attention l'ODFM solde l'intégralité des écritures du mandat, assurez vous que vous avez effectué tous vos traitements comptables sur ce mandat
            viRetourQuestion = outils:questionnaireGestion(107045, substitute('&2&1&3&1&4&1&5', separ[1], string(ttObjetMandatSyndic.iNumeroContrat), outilTraduction:getLibelleProg('O_ROL', ctrat.tprol), string(ctrat.norol,"99999"), ctrat.lnom2),
                                           table ttError by-reference).    //Confirmation de la resiliation avec OD Automatique de Fin de gestion
            if viRetourQuestion < 2 then return.
            else if viRetourQuestion = 2 then do:
                // reponse non. On transforme le type de l'erreur de -4 (question traitee) en 4 (question) si non les tests if mError:erreur() ne 
                // fonctionnent pas alors que dans ce cas on veut quitter le programme (normalement si reponse non l'ihm ne doit pas faire d'appel au pgm)
                mError:chgTypeQuestion(107045).
                return.
            end.
        end.
        if can-find (first maj no-lock
                     where maj.soc-cd = integer(mtoken:cRefCopro)
                       and maj.nmtab  = substitute("CLOTURE&1", string(ttObjetMandatSyndic.iNumeroContrat,">>>>9"))) then do:
            mError:createError({&error}, 1000984).            //Vous devez traiter la comptabilité supplémentaire du mandat avant de résilier (Ecran Comptabilité mandats manuels /Envoi)
            return.
        end.
    end.

end procedure.

procedure valMajEcr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeTrt as character no-undo.
    define parameter buffer ttObjetMandatSyndic for ttObjetMandatSyndic.

    define variable vhSoldmdt2 as handle no-undo.
    define variable vhIetab    as handle no-undo.

    define buffer ietab for ietab.

    if pcTypeTrt = "RESILIATION" then do:
        if ttObjetMandatSyndic.lResiliation then do:
            for first ietab no-lock
                where ietab.soc-cd  = integer(mtoken:cRefCopro)
                  and ietab.etab-cd = ttObjetMandatSyndic.iNumeroContrat:
                empty temp-table ttIetab.      
                run crud/ietab_CRUD.p persistent set vhIetab.
                run getTokenInstance in vhIetab(mToken:JSessionId).
                create ttIetab.
                assign ttIetab.soc-cd      = ietab.soc-cd
                       ttIetab.etab-cd     = ietab.etab-cd
                       ttIetab.dtTimestamp = datetime(ietab.damod, ietab.ihmod)
                       ttIetab.CRUD        = "U"
                       ttIetab.rRowid      = rowid(ietab)
                       ttIetab.fg-cptim    = false
                .
                run setIetab in vhIetab(table ttIetab by-reference).
                run destroy in vhIetab.
                if mError:erreur() then return.
            end.
            if ttObjetMandatSyndic.daOdFinMandat <> ? then do:
                run cadbgestion/soldmdt2.p persistent set vhSoldmdt2.
                run getTokenInstance in vhSoldmdt2(mToken:JSessionId).
                run soldmmdt2Lancement in vhSoldmdt2(integer(mtoken:cRefCopro),
                                                     ttObjetMandatSyndic.iNumeroContrat,
                                                     ttObjetMandatSyndic.daOdFinMandat,
                                                     ttObjetMandatSyndic.daResiliation).
                run destroy in vhSoldmdt2.
                if mError:erreur() then return.
            end.
//          run GenEvent.     //gga todo pour la reprise de ce module evenement, il faut avant une remise a plat pour reflechir a nouveau fonctionnement
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
    define parameter buffer ttObjetMandatSyndic for ttObjetMandatSyndic.

    define variable vhProc             as handle    no-undo.
    define variable vcReferenceVilogia as character no-undo.  // liste des références clients Vilogia

    empty temp-table ttCtrat.
    create ttCtrat.
    assign
        ttCtrat.nodoc       = ttObjetMandatSyndic.iNumeroDocument
        ttCtrat.tpcon       = ttObjetMandatSyndic.cCodeTypeContrat
        ttCtrat.nocon       = ttObjetMandatSyndic.iNumeroContrat
        ttCtrat.dtdeb       = ttObjetMandatSyndic.daDateNomination
        ttCtrat.ntcon       = ttObjetMandatSyndic.cCodeNatureContrat
        ttCtrat.dtfin       = ttObjetMandatSyndic.daDateExpiration
        ttCtrat.tpfin       = ttObjetMandatSyndic.cMotifResiliation
        ttCtrat.nbdur       = ttObjetMandatSyndic.iDuree
        ttCtrat.cddur       = ttObjetMandatSyndic.cUniteDuree
        ttCtrat.dtsig       = ttObjetMandatSyndic.daSignature
        ttCtrat.lisig       = ttObjetMandatSyndic.cLieuSignature
        ttCtrat.dtree       = ttObjetMandatSyndic.daResiliation
        ttCtrat.noree       = ttObjetMandatSyndic.cNumeroRegistre
        ttCtrat.tpren       = (if ttObjetMandatSyndic.lTaciteReconduction then {&TACITERECONDUCTION-YES} else {&TACITERECONDUCTION-NO})
        ttCtrat.nbres       = ttObjetMandatSyndic.iDelaiPreavis
        ttCtrat.utres       = ttObjetMandatSyndic.cUnitePreavis
        ttCtrat.tpact       = ttObjetMandatSyndic.cTypeActe
        ttCtrat.pcpte       = 0
        ttCtrat.scpte       = 0
        ttCtrat.noave       = 0
        ttCtrat.dtini       = ttObjetMandatSyndic.daDateInitiale
        ttCtrat.cddev       = ttObjetMandatSyndic.cCodeDevise
        ttCtrat.CRUD        = ttObjetMandatSyndic.CRUD
        ttCtrat.dtTimestamp = ttObjetMandatSyndic.dtTimestamp
        ttCtrat.rRowid      = ttObjetMandatSyndic.rRowid
    .

//gga todo attention probleme droit pour la maj du numero contrat ikos dans gesobj00.p, test sur table tprofil
    vcReferenceVilogia = "{&REFCLIENT-3140},{&REFCLIENT-4140},{&REFCLIENT-GIDEV},{&REFCLIENT-GICLI}".
    if lookup(mtoken:cRefPrincipale, vcReferenceVilogia) > 0
    then ttCtrat.cdusage1 = ttObjetMandatSyndic.cNumeroContratIkos.

    if pcTypeTrt = "RESILIATION" and ttObjetMandatSyndic.daResiliation = ?
    then ttCtrat.dtree = {&dateNulle}.                    // outil de copie qui transforme un 01/01/0001 en ?

    if pcTypeTrt = "RENOUVELLEMENT"
    then ttCtrat.noren = ctrat.noren + 1.

    run crud/ctrat_CRUD.p persistent set vhProc.
    run getTokenInstance in vhProc(mToken:JSessionId).
    run setCtrat in vhProc(table ttCtrat by-reference).
    run destroy in vhproc.
    if mError:erreur() then return.

end procedure.

procedure ctlDuCtt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer ttObjetMandatSyndic for ttObjetMandatSyndic.

    define variable viNbMoiDur as integer no-undo.
    define variable viNbMoiMin as integer no-undo.
    define variable viNbMoiMax as integer no-undo.
    define variable voNatureContrat as class parametrageNatureContrat no-undo.

    assign
        viNbMoiDur = (if ttObjetMandatSyndic.cUniteDuree = {&CODEPERIODE-annuel} then 12 * ttObjetMandatSyndic.iDuree else ttObjetMandatSyndic.iDuree)
        voNatureContrat = new parametrageNatureContrat()
    .
    voNatureContrat:getDureeContratParNature(ttObjetMandatSyndic.cCodeNatureContrat, output viNbMoiMin, output viNbMoiMax).
    delete object voNatureContrat.
    if (viNbMoiMin <> ? and viNbMoiMax <> ?)
        and (viNbMoiDur < viNbMoiMin or viNbMoiDur > viNbMoiMax)
        then mError:createErrorGestion({&error}, 101142, substitute('&2&1&3', separ[1], string(viNbMoiMin), string(viNbMoiMax))).

end procedure.

procedure calculDateExpiration private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer ttObjetMandatSyndic for ttObjetMandatSyndic.

    define variable viNbMoiDur as integer no-undo.

    viNbMoiDur = if ttObjetMandatSyndic.cUniteDuree = {&CODEPERIODE-annuel} then 12 * ttObjetMandatSyndic.iDuree else ttObjetMandatSyndic.iDuree.
    if viNbMoiDur = 0 then return.

    ttObjetMandatSyndic.daDateExpiration = add-interval(ttObjetMandatSyndic.daDateNomination, viNbMoiDur, "months").
    do while ttObjetMandatSyndic.daDateExpiration < today:
        /*--> On boucle jusqu'a obtenir une date d'expiration supérieure à la date du jour */
        ttObjetMandatSyndic.daDateExpiration = add-interval(ttObjetMandatSyndic.daDateExpiration, viNbMoiDur, "months").
    end.
    ttObjetMandatSyndic.daDateExpiration = ttObjetMandatSyndic.daDateExpiration - 1.

end procedure.

procedure initAutorisationObjet:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:   service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as int64 no-undo.
    define output parameter table-handle phttAutorisation.

    define variable vhTmpAutorisation as handle no-undo.

    define buffer ctrat for ctrat.

    find first ctrat no-lock
         where ctrat.tpcon = {&TYPECONTRAT-mandat2Syndic}
           and ctrat.nocon = piNumeroContrat no-error.
    if not available ctrat then do:
        mError:createError({&error}, 100057).
        return.
    end.
    run chargeAutorisation (buffer ctrat).
    create temp-table phttAutorisation.
//  phttAutorisation:add-new-field ("nom","type", extent, "format", initialisation).
    phttAutorisation:add-new-field ("lNumeroRegistreAuto", "logical", 0, "", ?).
    phttAutorisation:add-new-field ("lModification"      , "logical", 0, "", ?).
    phttAutorisation:add-new-field ("lRenouvellement"    , "logical", 0, "", ?).
    phttAutorisation:add-new-field ("lResiliation"       , "logical", 0, "", ?).
    phttAutorisation:temp-table-prepare("ttAutorisation").
    vhTmpAutorisation = phttAutorisation:default-buffer-handle.
    vhTmpAutorisation:handle:buffer-create().
    assign
        vhTmpAutorisation::lNumeroRegistreAuto = glNumeroRegistreAuto
        vhTmpAutorisation::lModification       = glAutorisationModification
        vhTmpAutorisation::lRenouvellement     = glAutorisationRenouvellement
        vhTmpAutorisation::lResiliation        = glAutorisationResiliation
    .

end procedure.

procedure chargeAutorisation private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define parameter buffer ctrat for ctrat.

    define variable vdaOdFinMandat as date no-undo.
    define variable vdaArchivage   as date no-undo.
    define variable voNumeroRegistreMandat as class parametrageNumeroRegistreMandat no-undo.
    
    assign
        voNumeroRegistreMandat = new parametrageNumeroRegistreMandat()
        glNumeroRegistreAuto   = voNumeroRegistreMandat:isNumeroRegistreAuto()
    .
    if ctrat.dtree <> ? then do:
        assign
            glAutorisationModification   = no
            glAutorisationRenouvellement = no
            glAutorisationResiliation    = yes
        .
        run soldmdt1Controle(mToken:cRefCopro,
                             ctrat.nocon,
                             output vdaOdFinMandat,
                             output vdaArchivage).
        if vdaOdFinMandat <> ? then glAutorisationResiliation = no.
    end.
    else
        assign
            glAutorisationModification   = yes
            glAutorisationRenouvellement = yes
            glAutorisationResiliation    = yes
        .

end procedure.

procedure controleObjet:
    /*------------------------------------------------------------------------------
    Purpose: controle objet
             pour ce controle, chargement info objet du mandat dans la table ttObjetMandatSyndic (comme pour un getObjet)
             et ensuite appel procedure verificationNonResiliation (controle avant maj)
    Notes  : service externe (mandat.p)
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
    run getObjet("", piNumeroContrat, output table ttObjetMandatSyndic).
    if mError:erreur() then return.
    for first ttObjetMandatSyndic:
        assign
            glAutorisationModification = yes
            ttObjetMandatSyndic.CRUD = "U"
        .
        goSyspr = new syspr().
        run verificationNonResiliation ("", buffer ctrat, buffer ttObjetMandatSyndic).
        delete object goSyspr.
    end.
    
end procedure.
