/*------------------------------------------------------------------------
File        : garantieRisqueLocatif.p
Purpose     : Paramétrage Garantie risque locatif - 01013
Author(s)   : RF - 2017/11/10
Notes       :
derniere revue: 2018/05/03 - phm: OK
  ----------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/type2bareme.i}
{preprocesseur/listeRubQuit2TVA.i}
{preprocesseur/periode2garantie.i}
{preprocesseur/mode2saisie.i}

using parametre.pclie.pclie.
using parametre.syspg.syspg.
using parametre.syspr.syspr.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{compta/include/tva.i}
{parametre/cabinet/gerance/include/garantie.i}
{parametre/cabinet/gerance/include/garantieRisqueLocatif.i}
{parametre/cabinet/gerance/include/baremeGarantieLoyer.i &nomTable=ttbaremeGRLCom &serialName=ttbaremeGRLCom}
{parametre/cabinet/gerance/include/baremeGarantieLoyer.i &nomTable=ttbaremeGRLHab &serialName=ttbaremeGRLHab}
{application/include/combo.i}
{application/include/error.i}

procedure getGarantieRisqueLocatifByRowid:
    /*-----------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beAssuranceGarantie.cls
    -----------------------------------------------------------------------------*/
    define input  parameter prRowId as rowid no-undo.
    define output parameter table for ttGarantieRisqueLocatif.
    define output parameter table for ttbaremeGRLCom.
    define output parameter table for ttbaremeGRLHab.

    define variable vhoutilGarantieLoyer as handle no-undo.
    define variable vhttBaremeCommercial as handle no-undo.
    define variable vhttBaremeHabitation as handle no-undo.
    define buffer garan for garan.

    assign
        vhttBaremeCommercial = temp-table ttbaremeGRLCom:default-buffer-handle
        vhttBaremeHabitation = temp-table ttbaremeGRLHab:default-buffer-handle
    .
    for first garan no-lock
        where rowid(garan) = prRowid:
        run createTTGarantieRisqueLocatif(buffer garan, vhoutilGarantieLoyer).
        run parametre/cabinet/gerance/outilGarantieLoyer.p persistent set vhoutilGarantieLoyer.
        run getTokenInstance in vhoutilGarantieLoyer(mToken:JSessionId).
        run loadBaremeGarantie in vhoutilGarantieLoyer(garan.tpctt, garan.noctt, {&TYPEBAREME-Commercial}, vhttBaremeCommercial).
        run loadBaremeGarantie in vhoutilGarantieLoyer(garan.tpctt, garan.noctt, {&TYPEBAREME-Habitation}, vhttBaremeHabitation).
    end.
    run destroy in vhoutilGarantieLoyer.
end procedure.

procedure getGarantieRisqueLocatif:
    /*-----------------------------------------------------------------------------
    Purpose: Lecture des informations entête + listes barèmes HAB/COMM pour 1 garantie ou toutes
    Notes  :  service utilisé par beAssuranceGarantie.cls
    -----------------------------------------------------------------------------*/
    define input  parameter piNumeroAssurance as integer   no-undo.
    define output parameter table for ttGarantieRisqueLocatif.
    define output parameter table for ttbaremeGRLCom.
    define output parameter table for ttbaremeGRLHab.

    define variable vhoutilGarantieLoyer as handle no-undo.
    define variable vhttBaremeCommercial as handle no-undo.
    define variable vhttBaremeHabitation as handle no-undo.
    define buffer garan    for garan.

    assign
        vhttBaremeCommercial = temp-table ttbaremeGRLCom:default-buffer-handle
        vhttBaremeHabitation = temp-table ttbaremeGRLHab:default-buffer-handle
    .
    run parametre/cabinet/gerance/outilGarantieLoyer.p persistent set vhoutilGarantieLoyer.
    run getTokenInstance in vhoutilGarantieLoyer(mToken:JSessionId).
    for each garan no-lock
        where garan.tpctt = {&TYPECONTRAT-GarantieRisqueLocatif}
          and garan.noctt = (if piNumeroAssurance > 0 then piNumeroAssurance else garan.noctt)
          and garan.tpbar = "":
        run createTTGarantieRisqueLocatif(buffer garan, vhoutilGarantieLoyer).
        run LoadBaremeGarantie in vhoutilGarantieLoyer(garan.tpctt, garan.noctt, {&TYPEBAREME-Commercial}, vhttBaremeCommercial).
        run LoadBaremeGarantie in vhoutilGarantieLoyer(garan.tpctt, garan.noctt, {&TYPEBAREME-Habitation}, vhttBaremeHabitation).
    end.
    run destroy in vhoutilGarantieLoyer.
end procedure.

procedure setGarantieRisqueLocatif:
    /*-----------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beAssuranceGarantie.cls
    -----------------------------------------------------------------------------*/
    define input parameter table for ttGarantieRisqueLocatif.
    define input parameter table for ttbaremeGRLCom.
    define input parameter table for ttbaremeGRLHab.
    define input parameter table for ttError.

    run controlesAvantValidation.
    if not mError:erreur() then run miseAJourGarantie.
end procedure.

procedure initGarantieRisqueLocatif:
    /*-----------------------------------------------------------------------------
    Purpose: Initialisation pour création d'une nouvelle assurance garantie loyer
    Notes  : service utilisé par beAssuranceGarantie.cls
    -----------------------------------------------------------------------------*/
    define output parameter table for ttGarantieRisqueLocatif.
    define output parameter table for ttbaremeGRLCom.
    define output parameter table for ttbaremeGRLHab.

    define variable viCompteur           as integer no-undo.
    define variable vhoutilGarantieLoyer as handle  no-undo.
    define buffer garan for garan.

    run parametre/cabinet/gerance/outilGarantieLoyer.p persistent set vhoutilGarantieLoyer.
    run getTokenInstance in vhoutilGarantieLoyer(mToken:JSessionId).
    create ttGarantieRisqueLocatif.
    assign
        ttGarantieRisqueLocatif.cTypeContrat          = {&TYPECONTRAT-GarantieRisqueLocatif}
        ttGarantieRisqueLocatif.iNumeroContrat        = 0
        ttGarantieRisqueLocatif.cLibelleTypeContrat   = outilTraduction:getLibelleProg("O_CLC", ttGarantieRisqueLocatif.cTypeContrat)
        ttGarantieRisqueLocatif.cModeComptabilisation = "00000"  // dépend des garanties existantes
        ttGarantieRisqueLocatif.cCodeAssureur         = ""
        ttGarantieRisqueLocatif.lContratGRL           = true
        ttGarantieRisqueLocatif.cNumeroConvention     = ""
        ttGarantieRisqueLocatif.cNumeroContratGRL     = ""
        ttGarantieRisqueLocatif.cNomPartenaire        = ""
        ttGarantieRisqueLocatif.cTypeRoleCourtier     = "FOU"
        ttGarantieRisqueLocatif.iNumeroCourtier       = 0
        ttGarantieRisqueLocatif.cCodeTVA              = {&codeTVA-00000}
        ttGarantieRisqueLocatif.cCodeApplicationTVA   = {&TVABAREME-COTIS-ET-HONO}
        ttGarantieRisqueLocatif.cCodePeriodicite      = {&PERIODEGARANTIE-mensuel}
        ttGarantieRisqueLocatif.dTauxRecuperable      = 100
        ttGarantieRisqueLocatif.dTauxNonRecuperable   = 0
        ttGarantieRisqueLocatif.cModeSaisie           = {&MODESAISIEBAREME-TxCotis-et-TxHono}
        ttGarantieRisqueLocatif.dtTimestamp           = ?
        ttGarantieRisqueLocatif.CRUD                  = ""
    .
    // Type de comptabilisation par défaut -> hérité du premier enregistrement garan
    for first garan no-lock
        where garan.tpctt = {&TYPECONTRAT-GarantieRisqueLocatif}:
        ttGarantieRisqueLocatif.cModeComptabilisation = garan.lbdiv2.
    end.
    ttGarantieRisqueLocatif.cLibelle2Comptabilisation = dynamic-function("libelleParamComptaAchatOuOd" in vhoutilGarantieLoyer, ttGarantieRisqueLocatif.cModeComptabilisation, mtoken:cRefGerance).
    run chargeLibelle.
    do viCompteur = 1 to 10:
        create ttbaremeGRLCom.
        assign
            ttbaremeGRLCom.cTypeContrat    = {&TYPECONTRAT-GarantieRisqueLocatif}
            ttbaremeGRLCom.iNumeroContrat  = 0
            ttbaremeGRLCom.cTypeBareme     = {&TYPEBAREME-Commercial}
            ttbaremeGRLCom.iNumeroBareme   = viCompteur
            ttbaremeGRLCom.dMtCotisation   = 0
            ttbaremeGRLCom.dTauxCotisation = 0
            ttbaremeGRLCom.dTauxHonoraire  = 0
            ttbaremeGRLCom.dTauxResultat   = 0
        .
        create ttbaremeGRLHab.
        assign
            ttbaremeGRLHab.cTypeContrat    = {&TYPECONTRAT-GarantieRisqueLocatif}
            ttbaremeGRLHab.iNumeroContrat  = 0
            ttbaremeGRLHab.cTypeBareme     = {&TYPEBAREME-Habitation}
            ttbaremeGRLHab.iNumeroBareme   = viCompteur
            ttbaremeGRLHab.dMtCotisation   = 0
            ttbaremeGRLHab.dTauxCotisation = 0
            ttbaremeGRLHab.dTauxHonoraire  = 0
            ttbaremeGRLHab.dTauxResultat   = 0
        .
    end.
    run destroy in vhoutilGarantieLoyer.
end procedure.

procedure controlesAvantValidation private:
    /*------------------------------------------------------------------------------
    Purpose: Contrôle des informations saisies par l'utilisateur avant de faire l'update
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhoutilGarantieLoyer as handle    no-undo.
    define variable vhttBaremeCommercial as handle    no-undo.
    define variable vhttBaremeHabitation as handle    no-undo.
    define variable vcQueryCommercial    as character no-undo.
    define variable vcQueryHabitation    as character no-undo.

    run parametre/cabinet/gerance/outilGarantieLoyer.p persistent set vhoutilGarantieLoyer.
    run getTokenInstance in vhoutilGarantieLoyer(mToken:JSessionId).
    assign
        vhttBaremeCommercial = temp-table ttbaremeGRLCom:default-buffer-handle
        vhttBaremeHabitation = temp-table ttbaremeGRLHab:default-buffer-handle
        vcQueryCommercial    = "for each ttbaremeGRLCom"
        vcQueryHabitation    = "for each ttbaremeGRLHab"
    .
boucleGarantie:
    for each ttGarantieRisqueLocatif
        where lookup(ttGarantieRisqueLocatif.CRUD, "C,U,D") > 0:
        if ttGarantieRisqueLocatif.cTypeContrat <> {&TYPECONTRAT-GarantieRisqueLocatif}
        then do:
            mError:createError({&error}, 1000688).
            leave boucleGarantie.
        end.
        if (lookup(ttGarantieRisqueLocatif.CRUD, "U,D") > 0
        and not dynamic-function("testGarantieExiste" in vhoutilGarantieLoyer,
            ttGarantieRisqueLocatif.cTypeContrat,
            ttGarantieRisqueLocatif.iNumeroContrat,
            ttGarantieRisqueLocatif.CRUD))
        or not dynamic-function("testAssureurAutorise" in vhoutilGarantieLoyer,
            ttGarantieRisqueLocatif.cTypeContrat,
            ttGarantieRisqueLocatif.iNumeroContrat,
            ttGarantieRisqueLocatif.cCodeAssureur,
            ttGarantieRisqueLocatif.CRUD
        )
        or not dynamic-function("testCourtier" in vhoutilGarantieLoyer,
            string(ttGarantieRisqueLocatif.iNumeroCourtier, "99999"
        ))
        or (ttGarantieRisqueLocatif.CRUD = "D"        // Suppression interdite si un bail rattaché à cette garantie
        and dynamic-function("testGarantieUtilisee" in vhoutilGarantieLoyer,
            ttGarantieRisqueLocatif.cTypeContrat,
            ttGarantieRisqueLocatif.iNumeroContrat,
            ttGarantieRisqueLocatif.CRUD
        ))
        or (ttGarantieRisqueLocatif.CRUD = "U"
        and not dynamic-function("testModifPeriodicite" in vhoutilGarantieLoyer,
            ttGarantieRisqueLocatif.cTypeContrat,
            ttGarantieRisqueLocatif.iNumeroContrat,
            ttGarantieRisqueLocatif.cCodePeriodicite
        ))
        or (lookup(ttGarantieRisqueLocatif.CRUD, "C,U") > 0        // Contrôles des baremes
        and not dynamic-function("testBareme" in vhoutilGarantieLoyer,
            ttGarantieRisqueLocatif.cCodeTVA,
            vcQueryCommercial,
            vcQueryHabitation,
            vhttBaremeCommercial,
            vhttBaremeHabitation
        ))
        or (lookup(ttGarantieRisqueLocatif.CRUD, "C,U") > 0
        and not dynamic-function("testModeComptabilisationQuestion" in vhoutilGarantieLoyer,
            ttGarantieRisqueLocatif.cTypeContrat,
            ttGarantieRisqueLocatif.cModeComptabilisation,
            table ttError by-reference
        ))
        then leave boucleGarantie.
    end.
    run destroy in vhoutilGarantieLoyer.
end procedure.

procedure miseAJourGarantie private:
    /*------------------------------------------------------------------------------
     Purpose: Mise à jour de la table tache à partir du dataset
     Notes:
    ------------------------------------------------------------------------------*/
    define variable vhGarantie             as handle    no-undo.
    define variable viNumeroAssurance      as integer   no-undo.
    define variable vcModeComptabilisation as character no-undo.
    define buffer garan for garan.

    empty temp-table ttGarantie.
    for first ttGarantieRisqueLocatif:
        if ttGarantieRisqueLocatif.CRUD = "C" then do:
            viNumeroAssurance = 1.
            {&_proparse_ prolint-nowarn(use-index)}
            for last garan no-lock
                where garan.tpctt = ttGarantieRisqueLocatif.cTypeContrat
                use-index ix_garan01:
                viNumeroAssurance = garan.noctt + 1.
            end.
        end.
        else viNumeroAssurance = ttGarantieRisqueLocatif.iNumeroContrat.
        create ttGarantie.
        assign
            vcModeComptabilisation = ttGarantieRisqueLocatif.cModeComptabilisation
            ttGarantie.tpctt       = ttGarantieRisqueLocatif.cTypeContrat
            ttGarantie.noctt       = viNumeroAssurance
            ttGarantie.tpbar       = ""
            ttGarantie.nobar       = 0
            ttGarantie.txcot       = 0
            ttGarantie.txhon       = integer(ttGarantieRisqueLocatif.cModeSaisie)
            ttGarantie.txres       = 0
            ttGarantie.fgtot       = ttGarantieRisqueLocatif.cCodeApplicationTVA = {&TVABAREME-COTIS-ET-HONO}
            ttGarantie.cdtva       = ttGarantieRisqueLocatif.cCodeTVA
            ttGarantie.cdper       = ttGarantieRisqueLocatif.cCodePeriodicite
            ttGarantie.txrec       = ttGarantieRisqueLocatif.dTauxRecuperable
            ttGarantie.txnor       = ttGarantieRisqueLocatif.dTauxNonRecuperable
            ttGarantie.lbdiv       = ttGarantieRisqueLocatif.cCodeAssureur
            ttGarantie.cddev       = ""
            ttGarantie.lbdiv2      = ttGarantieRisqueLocatif.cModeComptabilisation
            ttGarantie.lbdiv3      = ""
            ttGarantie.txcot-dev   = 0
            ttGarantie.tpmnt       = ""
            ttGarantie.mtcot       = 0
            ttGarantie.typefac-cle = ""
            ttGarantie.cdass       = ""
            ttGarantie.nbmca       = 0
            ttGarantie.nbmfr       = 0
            ttGarantie.cpgar       = ""
            ttGarantie.fgGRL       = ttGarantieRisqueLocatif.lContratGR
            ttGarantie.convention  = ttGarantieRisqueLocatif.cNumeroConvention
            ttGarantie.nocontrat   = ttGarantieRisqueLocatif.cNumeroContratGRL
            ttGarantie.nompartres  = ttGarantieRisqueLocatif.cNomPartenaire
            ttGarantie.tprolcour   = ttGarantieRisqueLocatif.cTypeRoleCourtier
            ttGarantie.norolcour   = ttGarantieRisqueLocatif.iNumeroCourtier
            ttGarantie.CdDebCal    = ""
            ttGarantie.CdTriEdi    = ""
            ttGarantie.cdperbord   = ""
            ttGarantie.dtTimestamp = ttGarantieRisqueLocatif.dtTimestamp
            ttGarantie.CRUD        = ttGarantieRisqueLocatif.CRUD
            ttGarantie.rRowid      = ttGarantieRisqueLocatif.rRowid
        .
        for each ttbaremeGRLCom
            where ttbaremeGRLCom.cTypeContrat   = ttGarantieRisqueLocatif.cTypeContrat
              and ttbaremeGRLCom.iNumeroContrat = ttGarantieRisqueLocatif.iNumeroContrat:
            create ttGarantie.
            assign
                ttGarantie.tpctt       = ttbaremeGRLCom.cTypeContrat
                ttGarantie.noctt       = viNumeroAssurance
                ttGarantie.tpbar       = ttbaremeGRLCom.cTypeBareme
                ttGarantie.nobar       = ttbaremeGRLCom.iNumeroBareme
                ttGarantie.txcot       = ttbaremeGRLCom.dTauxCotisation
                ttGarantie.txhon       = ttbaremeGRLCom.dTauxHonoraire
                ttGarantie.txres       = ttbaremeGRLCom.dTauxResultat
                ttGarantie.fgtot       = false
                ttGarantie.cdtva       = ""
                ttGarantie.cdper       = ""
                ttGarantie.txrec       = 0
                ttGarantie.txnor       = 0
                ttGarantie.lbdiv       = (if ttbaremeGRLCom.dMtCotisation > 0 then "MT@" else "TX@")
                ttGarantie.cddev       = ""
                ttGarantie.lbdiv2      = ""
                ttGarantie.lbdiv3      = ""
                ttGarantie.txcot-dev   = 0
                ttGarantie.tpmnt       = ""
                ttGarantie.mtcot       = ttbaremeGRLCom.dMtCotisation
                ttGarantie.typefac-cle = ""
                ttGarantie.cdass       = ""
                ttGarantie.nbmca       = 0
                ttGarantie.nbmfr       = 0
                ttGarantie.cpgar       = ""
                ttGarantie.fgGRL       = false
                ttGarantie.convention  = ""
                ttGarantie.nocontrat   = ""
                ttGarantie.nompartres  = ""
                ttGarantie.tprolcour   = ""
                ttGarantie.norolcour   = 0
                ttGarantie.CdDebCal    = ""
                ttGarantie.CdTriEdi    = ""
                ttGarantie.cdperbord   = ""
                ttGarantie.dtTimestamp = ttbaremeGRLCom.dtTimestamp     // ttGarantieRisqueLocatif - ce n'est pas une erreur
                ttGarantie.CRUD        = ttGarantieRisqueLocatif.CRUD   // tous les barèmes doivent suivre le CRUD de l'entête
                ttGarantie.rRowid      = ttbaremeGRLCom.rRowid
            .
        end.
        for each ttbaremeGRLHab
           where ttbaremeGRLHab.cTypeContrat   = ttGarantieRisqueLocatif.cTypeContrat
             and ttbaremeGRLHab.iNumeroContrat = ttGarantieRisqueLocatif.iNumeroContrat:
            create ttGarantie.
            assign
                ttGarantie.tpctt       = ttbaremeGRLHab.cTypeContrat
                ttGarantie.noctt       = viNumeroAssurance
                ttGarantie.tpbar       = ttbaremeGRLHab.cTypeBareme
                ttGarantie.nobar       = ttbaremeGRLHab.iNumeroBareme
                ttGarantie.txcot       = ttbaremeGRLHab.dTauxCotisation
                ttGarantie.txhon       = ttbaremeGRLHab.dTauxHonoraire
                ttGarantie.txres       = ttbaremeGRLHab.dTauxResultat
                ttGarantie.fgtot       = false
                ttGarantie.cdtva       = ""
                ttGarantie.cdper       = ""
                ttGarantie.txrec       = 0
                ttGarantie.txnor       = 0
                ttGarantie.lbdiv       = (if ttbaremeGRLHab.dMtCotisation > 0 then "MT@" else "TX@")
                ttGarantie.cddev       = ""
                ttGarantie.lbdiv2      = ""
                ttGarantie.lbdiv3      = ""
                ttGarantie.txcot-dev   = 0
                ttGarantie.tpmnt       = ""
                ttGarantie.mtcot       = ttbaremeGRLHab.dMtCotisation
                ttGarantie.typefac-cle = ""
                ttGarantie.cdass       = ""
                ttGarantie.nbmca       = 0
                ttGarantie.nbmfr       = 0
                ttGarantie.cpgar       = ""
                ttGarantie.fgGRL       = false
                ttGarantie.convention  = ""
                ttGarantie.nocontrat   = ""
                ttGarantie.nompartres  = ""
                ttGarantie.tprolcour   = ""
                ttGarantie.norolcour   = 0
                ttGarantie.CdDebCal    = ""
                ttGarantie.CdTriEdi    = ""
                ttGarantie.cdperbord   = ""
                ttGarantie.dtTimestamp = ttbaremeGRLHab.dtTimestamp
                ttGarantie.CRUD        = ttGarantieRisqueLocatif.CRUD   // tous les barèmes doivent suivre le CRUD de l'entête
                ttGarantie.rRowid      = ttbaremeGRLHab.rRowid
            .
        end.
    end.
    run parametre/cabinet/gerance/garan_CRUD.p persistent set vhGarantie.
    run getTokenInstance in vhGarantie(mToken:JSessionId).
    run setGarantie in vhGarantie(input-output table ttGarantie by-reference).
    if not mError:erreur()
    then run majGarantie_ModeComptabilisation in vhGarantie({&TYPECONTRAT-GarantieRisqueLocatif}, vcModeComptabilisation, viNumeroAssurance).
    run destroy in vhGarantie.
end procedure.

procedure createTTGarantieRisqueLocatif private:
    /*-----------------------------------------------------------------------------
    Purpose:
    Notes  :
    -----------------------------------------------------------------------------*/
    define parameter buffer garan for garan.
    define input parameter phoutilGarantieLoyer as handle no-undo.

    create ttGarantieRisqueLocatif.
    assign
        ttGarantieRisqueLocatif.cTypeContrat          = garan.tpctt
        ttGarantieRisqueLocatif.iNumeroContrat        = garan.noctt
        ttGarantieRisqueLocatif.cLibelleTypeContrat   = outilTraduction:getLibelleProg("O_CLC", garan.tpctt)
        ttGarantieRisqueLocatif.cModeComptabilisation = garan.lbdiv2
        ttGarantieRisqueLocatif.cCodeAssureur         = garan.lbdiv
        ttGarantieRisqueLocatif.cCodeTVA              = garan.cdtva
        ttGarantieRisqueLocatif.cCodeApplicationTVA   = string(garan.fgtot, substitute("&1/&2", {&TVABAREME-COTIS-ET-HONO}, {&TVABAREME-HONORAIRE}))
        ttGarantieRisqueLocatif.cCodePeriodicite      = garan.cdper
        ttGarantieRisqueLocatif.dTauxRecuperable      = garan.txrec
        ttGarantieRisqueLocatif.dTauxNonRecuperable   = garan.txnor
        ttGarantieRisqueLocatif.lContratGRL           = garan.fgGRL
        ttGarantieRisqueLocatif.cNumeroConvention     = garan.convention
        ttGarantieRisqueLocatif.cNumeroContratGRL     = garan.nocontrat
        ttGarantieRisqueLocatif.cNomPartenaire        = garan.nompartres
        ttGarantieRisqueLocatif.cTypeRoleCourtier     = garan.tprolcour
        ttGarantieRisqueLocatif.iNumeroCourtier       = garan.norolcour
        ttGarantieRisqueLocatif.cModeSaisie           = string(garan.txhon)
        ttGarantieRisqueLocatif.dtTimestamp           = datetime(garan.dtmsy, garan.hemsy)
        ttGarantieRisqueLocatif.CRUD                  = "R"
        ttGarantieRisqueLocatif.rRowid                = rowid(garan)
    .
    run nomAdresseAssureur in phoutilGarantieLoyer(
        mtoken:cRefGerance,
        garan.tpctt,
        garan.noctt,
        garan.lbdiv,
        garan.cdass,
        output ttGarantieRisqueLocatif.cLibelleNumeroContrat,
        output ttGarantieRisqueLocatif.cLibelleAssureur
    ).
    ttGarantieRisqueLocatif.cLibelle2Comptabilisation = dynamic-function("libelleParamComptaAchatOuOd" in phoutilGarantieLoyer, ttGarantieRisqueLocatif.cModeComptabilisation, mtoken:cRefGerance).
    run chargeLibelle.
end procedure.

procedure initComboGarantieRisqueLocatif:
    /*------------------------------------------------------------------------------
    Purpose: Chargement des combos de l'écran depuis la vue
    Notes  : service externe (beAssuranceGarantie.cls)
    ------------------------------------------------------------------------------*/
    define output parameter table for ttcombo.
    define variable vhoutilGarantieLoyer as handle no-undo.

    run parametre/cabinet/gerance/outilGarantieLoyer.p persistent set vhoutilGarantieLoyer.
    run getTokenInstance in vhoutilGarantieLoyer(mToken:JSessionId).
    run chargeCombo(vhoutilGarantieLoyer).
    run destroy in vhoutilGarantieLoyer.
end procedure.

procedure chargeCombo private:
    /*------------------------------------------------------------------------------
    Purpose: Chargement de toutes les combos de l'écran
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter phoutilGarantieLoyer as handle no-undo.

    define variable viNumeroItem as integer no-undo.
    define variable vhProcTVA    as handle  no-undo.
    define variable voSyspr      as class syspr no-undo.
    define buffer garan for garan.

    empty temp-table ttCombo.
    voSyspr = new syspr().
    voSyspr:getComboParametre("CPGAR", "CMBTYPECOMPTABILISATION", output table ttCombo by-reference).
    // exclusion code "00002" - non développé */
    for first ttcombo
        where ttCombo.cNomCombo = "CMBTYPECOMPTABILISATION"
          and ttCombo.cCode     = "00002":
        delete ttcombo.
    end.
    voSyspr:getComboParametre("PDGAR", "CMBPERIODICITE", output table ttCombo by-reference).
    delete object voSyspr.
    // TVA calculée sur
    create ttCombo.
    assign
        ttCombo.iSeqId    = 1
        ttCombo.cNomCombo = "CMBAPPLICATIONTVA"
        ttCombo.cCode     = {&TVABAREME-COTIS-ET-HONO}           // "1"
        ttCombo.cLibelle  = outilTraduction:getLibelle(101560)   // Cotisation et Honoraires
    .
    create ttCombo.
    assign
        ttCombo.iSeqId    = 2
        ttCombo.cNomCombo = "CMBAPPLICATIONTVA"
        ttCombo.cCode     = {&TVABAREME-HONORAIRE}               // "2"
        ttCombo.cLibelle  = outilTraduction:getLibelle(101561)   // Honoraires uniquement
    .
    // Mode saisie
    create ttCombo.
    assign
        ttCombo.iSeqId    = 1
        ttCombo.cNomCombo = "CMBMODESAISIE"
        ttCombo.cCode     = {&MODESAISIEBAREME-TxCotis-et-TxHono}
        ttCombo.cLibelle  = outilTraduction:getLibelle(110051)
    .
    create ttCombo.
    assign
        ttCombo.iSeqId    = 2
        ttCombo.cNomCombo = "CMBMODESAISIE"
        ttCombo.cCode     = {&MODESAISIEBAREME-TxCotis-et-TxResultant}
        ttCombo.cLibelle  = outilTraduction:getLibelle(110052)
    .
    // garantie risque locatif
    for each garan no-lock
        where garan.tpctt = {&TYPECONTRAT-GarantieRisqueLocatif}
          and garan.tpbar = "":
        create ttCombo.
        assign
            viNumeroItem      = viNumeroItem + 1
            ttCombo.iSeqId    = viNumeroItem
            ttCombo.cNomCombo = "CMBGARANTIERISQUELOCATIF"
            ttCombo.cCode     = string(garan.noctt, "99999")
        .
        run nomAdresseAssureur in phoutilGarantieLoyer(
            mtoken:cRefGerance,
            garan.tpctt,
            garan.noctt,
            garan.lbdiv,
            garan.cdass,
            output ttCombo.cLibelle,
            output ttCombo.cLibelle2).
    end.
    // Taux de TVA
    run compta/outilsTVA.p persistent set vhProcTVA.
    run getTokenInstance in vhProcTVA(mToken:JSessionId).
    run getCodeTVA in vhProcTVA(output table ttTVA by-reference).
    for each ttTva by ttTva.iCodeTva:
        create ttCombo.
        assign
            viNumeroItem      = viNumeroItem + 1
            ttCombo.iSeqId    = viNumeroItem
            ttCombo.cNomCombo = "CMBTVA"
            ttCombo.cCode     = ttTVA.cCodeTVA
            ttCombo.cLibelle  = ttTVA.cLibelleTVA
        .
    end.
    run destroy in vhProcTVA.
end procedure.

procedure chargeLibelle private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    assign
        ttGarantieRisqueLocatif.cLibelleTypeContrat      = outilTraduction:getLibelleProg("O_CLC", ttGarantieRisqueLocatif.cTypeContrat)
        ttGarantieRisqueLocatif.cLibelleComptabilisation = outilTraduction:getLibelleParam("CPGAR", ttGarantieRisqueLocatif.cModeComptabilisation)
        ttGarantieRisqueLocatif.cLibellePeriodicite      = outilTraduction:getLibelleParam("PDGAR", ttGarantieRisqueLocatif.cCodePeriodicite)
        ttGarantieRisqueLocatif.cLibelleTVA              = outilTraduction:getLibelleParam("CDTVA", ttGarantieRisqueLocatif.cCodeTVA)
    .
    case ttGarantieRisqueLocatif.cCodeApplicationTVA:
        when {&TVABAREME-COTIS-ET-HONO} then ttGarantieRisqueLocatif.cLibelleApplicationTVA = outilTraduction:getLibelle(101560).
        when {&TVABAREME-HONORAIRE}     then ttGarantieRisqueLocatif.cLibelleApplicationTVA = outilTraduction:getLibelle(101561).
    end case.
    case ttGarantieRisqueLocatif.cModeSaisie:
        when {&MODESAISIEBAREME-TxCotis-et-TxHono}      then ttGarantieRisqueLocatif.cLibelleSaisie = outilTraduction:getLibelle(110051).
        when {&MODESAISIEBAREME-TxCotis-et-TxResultant} then ttGarantieRisqueLocatif.cLibelleSaisie = outilTraduction:getLibelle(110052).
    end case.
end procedure.
