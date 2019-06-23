/*-----------------------------------------------------------------------------
File        : protectionJuridique.p
Purpose     : Paramétrage Protection Juridique - 01017
Author(s)   : 2017/11/10 - RF
Notes       :
dernière revue : 2018/04/24 - phm: KO
Modifications SPo -2018/04/26 -
              NB : controlesAvantValidation : toutes les procedures transformées en fonctions et déplacées dans outilGarantieLoyer.p
-----------------------------------------------------------------------------*/
using parametre.pclie.pclie.
using parametre.syspg.syspg.
using parametre.syspr.syspr.

{preprocesseur/type2contrat.i}
{preprocesseur/type2bareme.i}
{preprocesseur/listeRubQuit2TVA.i}
{preprocesseur/periode2garantie.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{compta/include/tva.i}
{parametre/cabinet/gerance/include/garantie.i}
{parametre/cabinet/gerance/include/protectionJuridique.i}
{parametre/cabinet/gerance/include/baremeGarantieLoyer.i &nomTable=ttbaremeProtectionJuridiqueCom &serialName=ttbaremeProtectionJuridiqueCom}
{parametre/cabinet/gerance/include/baremeGarantieLoyer.i &nomTable=ttbaremeProtectionJuridiqueHab &serialName=ttbaremeProtectionJuridiqueHab}
{application/include/combo.i}
{application/include/error.i}

procedure getProtectionJuridiqueByRowid:
    /*-----------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beAssuranceGarantie.cls
    -----------------------------------------------------------------------------*/
    define input  parameter prRowId as rowid no-undo.
    define output parameter table for ttProtectionJuridique.
    define output parameter table for ttbaremeProtectionJuridiqueCom.
    define output parameter table for ttbaremeProtectionJuridiqueHab.

    define variable vhoutilGarantieLoyer as handle no-undo.
    define variable vhttBaremeCommercial as handle no-undo.
    define variable vhttBaremeHabitation as handle no-undo.
    define buffer garan for garan.

    run parametre/cabinet/gerance/outilGarantieLoyer.p persistent set vhoutilGarantieLoyer.
    run getTokenInstance in vhoutilGarantieLoyer(mToken:JSessionId).
    for first garan no-lock
        where rowid(garan) = prRowid:
        run createTTProtectionJuridique(buffer garan, vhoutilGarantieLoyer).
        run loadBaremeGarantie in vhoutilGarantieLoyer(garan.tpctt, garan.noctt, {&TYPEBAREME-Commercial}, vhttBaremeCommercial).
        run loadBaremeGarantie in vhoutilGarantieLoyer(garan.tpctt, garan.noctt, {&TYPEBAREME-Habitation}, vhttBaremeHabitation).
    end.
    run destroy in vhoutilGarantieLoyer.
end procedure.

procedure getProtectionJuridique:
    /*-----------------------------------------------------------------------------
    Purpose: Lecture des informations entête + listes barèmes HAB/COMM pour 1 garantie ou toutes
    Notes  :  service utilisé par beAssuranceGarantie.cls
    -----------------------------------------------------------------------------*/
    define input  parameter piNumeroAssurance as integer   no-undo.
    define output parameter table for ttProtectionJuridique.
    define output parameter table for ttbaremeProtectionJuridiqueCom.
    define output parameter table for ttbaremeProtectionJuridiqueHab.

    define variable vhoutilGarantieLoyer as handle no-undo.
    define variable vhttBaremeCommercial as handle no-undo.
    define variable vhttBaremeHabitation as handle no-undo.
    define buffer garan   for garan.

    assign
        vhttBaremeCommercial = temp-table ttbaremeProtectionJuridiqueCom:default-buffer-handle
        vhttBaremeHabitation = temp-table ttbaremeProtectionJuridiqueHab:default-buffer-handle
    .
    run parametre/cabinet/gerance/outilGarantieLoyer.p persistent set vhoutilGarantieLoyer.
    run getTokenInstance in vhoutilGarantieLoyer(mToken:JSessionId).
    for each garan no-lock
        where garan.tpctt = {&TYPECONTRAT-ProtectionJuridique}
          and garan.noctt = (if piNumeroAssurance > 0 then piNumeroAssurance else garan.noctt)
          and garan.tpbar = "":
        run createTTProtectionJuridique(buffer garan, vhoutilGarantieLoyer).
        run loadBaremeGarantie in vhoutilGarantieLoyer(garan.tpctt, garan.noctt, {&TYPEBAREME-Commercial}, vhttBaremeCommercial).
        run loadBaremeGarantie in vhoutilGarantieLoyer(garan.tpctt, garan.noctt, {&TYPEBAREME-Habitation}, vhttBaremeHabitation).
    end.
    run destroy in vhoutilGarantieLoyer.
end procedure.

procedure setProtectionJuridique:
    /*-----------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beAssuranceGarantie.cls
    -----------------------------------------------------------------------------*/
    define input parameter table for ttProtectionJuridique.
    define input parameter table for ttbaremeProtectionJuridiqueCom.
    define input parameter table for ttbaremeProtectionJuridiqueCom.
    define input parameter table for ttError.
    run controlesAvantValidation.
    if not mError:erreur() then run miseAJourGarantie.
end procedure.

procedure initProtectionJuridique:
    /*-----------------------------------------------------------------------------
    Purpose: Initialisation pour création d'une nouvelle assurance protection juridique
    Notes  : service utilisé par beAssuranceGarantie.cls
    -----------------------------------------------------------------------------*/
    define output parameter table for ttProtectionJuridique.
    define output parameter table for ttbaremeProtectionJuridiqueCom.
    define output parameter table for ttbaremeProtectionJuridiqueHab.

    define variable viCompteur           as integer no-undo.
    define variable vhoutilGarantieLoyer as handle  no-undo.
    define buffer garan for garan.
    run parametre/cabinet/gerance/outilGarantieLoyer.p persistent set vhoutilGarantieLoyer.
    run getTokenInstance in vhoutilGarantieLoyer(mToken:JSessionId).
    create ttProtectionJuridique.
    assign
        ttProtectionJuridique.cTypeContrat          = {&TYPECONTRAT-ProtectionJuridique}
        ttProtectionJuridique.iNumeroContrat        = 0
        ttProtectionJuridique.cLibelleTypeContrat   = outilTraduction:getLibelleProg("O_CLC", ttProtectionJuridique.cTypeContrat)
        ttProtectionJuridique.cModeComptabilisation = "00000"  // dépend des garanties existantes
        ttProtectionJuridique.cCodeAssureur         = ""
        ttProtectionJuridique.cCodeTVA              = {&codeTVA-00000}
        ttProtectionJuridique.cCodeApplicationTVA   = {&TVABAREME-COTIS-ET-HONO}
        ttProtectionJuridique.cCodePeriodicite      = {&PERIODEGARANTIE-mensuel}
        ttProtectionJuridique.dtTimestamp           = ?
        ttProtectionJuridique.CRUD                  = ""
    .
    // Type de comptabilisation par défaut -> hérité du premier enregistrement garan pour ce type d'assurance
    for first garan no-lock
         where garan.tpctt = {&TYPECONTRAT-ProtectionJuridique}:
        ttProtectionJuridique.cModeComptabilisation = garan.lbdiv2.
    end.
    ttProtectionJuridique.cLibelle2Comptabilisation = dynamic-function("libelleParamComptaAchatOuOd" in vhoutilGarantieLoyer, ttProtectionJuridique.cModeComptabilisation, mtoken:cRefGerance).
    run chargeLibelle.
    do viCompteur = 1 to 10:
        create ttbaremeProtectionJuridiqueCom.
        assign
            ttbaremeProtectionJuridiqueCom.cTypeContrat    = {&TYPECONTRAT-ProtectionJuridique}
            ttbaremeProtectionJuridiqueCom.iNumeroContrat  = 0
            ttbaremeProtectionJuridiqueCom.cTypeBareme     = {&TYPEBAREME-Commercial}
            ttbaremeProtectionJuridiqueCom.iNumeroBareme   = viCompteur
            ttbaremeProtectionJuridiqueCom.dMtCotisation   = 0
            ttbaremeProtectionJuridiqueCom.dTauxCotisation = 0
            ttbaremeProtectionJuridiqueCom.dTauxHonoraire  = 0
            ttbaremeProtectionJuridiqueCom.dTauxResultat   = 0
        .
        create ttbaremeProtectionJuridiqueHab.
        assign
            ttbaremeProtectionJuridiqueHab.cTypeContrat    = {&TYPECONTRAT-ProtectionJuridique}
            ttbaremeProtectionJuridiqueHab.iNumeroContrat  = 0
            ttbaremeProtectionJuridiqueHab.cTypeBareme     = {&TYPEBAREME-Habitation}
            ttbaremeProtectionJuridiqueHab.iNumeroBareme   = viCompteur
            ttbaremeProtectionJuridiqueHab.dMtCotisation   = 0
            ttbaremeProtectionJuridiqueHab.dTauxCotisation = 0
            ttbaremeProtectionJuridiqueHab.dTauxHonoraire  = 0
            ttbaremeProtectionJuridiqueHab.dTauxResultat   = 0
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
    define buffer garan                 for garan.

    run parametre/cabinet/gerance/outilGarantieLoyer.p persistent set vhoutilGarantieLoyer.
    run getTokenInstance in vhoutilGarantieLoyer(mToken:JSessionId).
    for each ttProtectionJuridique
        where lookup(ttProtectionJuridique.CRUD, "C,U,D") > 0:
        if ttProtectionJuridique.cTypeContrat ne {&TYPECONTRAT-ProtectionJuridique} then do:
            mError:createError({&error}, 1000688).
            run destroy in vhoutilGarantieLoyer.
            return.
        end.
        else if lookup(ttProtectionJuridique.CRUD, "U,D") > 0
        and not dynamic-function("testGarantieExiste" in vhoutilGarantieLoyer
                                , ttProtectionJuridique.cTypeContrat
                                , ttProtectionJuridique.iNumeroContrat
                                , ttProtectionJuridique.CRUD) then do:
            run destroy in vhoutilGarantieLoyer.
            return.
        end.
        else if not dynamic-function("testAssureurAutorise" in vhoutilGarantieLoyer
                                    , ttProtectionJuridique.cTypeContrat
                                    , ttProtectionJuridique.iNumeroContrat
                                    , ttProtectionJuridique.cCodeAssureur
                                    , ttProtectionJuridique.CRUD) then do:
            run destroy in vhoutilGarantieLoyer.
            return.
        end.
        // Suppression interdite si un bail rattaché à cette garantie
        else if ttProtectionJuridique.CRUD = "D"
        and dynamic-function("testGarantieUtilisee" in vhoutilGarantieLoyer
                            , ttProtectionJuridique.cTypeContrat
                            , ttProtectionJuridique.iNumeroContrat
                            , ttProtectionJuridique.CRUD) then do:
            run destroy in vhoutilGarantieLoyer.
            return.
        end.
        else if ttProtectionJuridique.CRUD = "U"
        and not dynamic-function("testModifPeriodicite" in vhoutilGarantieLoyer
                                , ttProtectionJuridique.cTypeContrat
                                , ttProtectionJuridique.iNumeroContrat
                                , ttProtectionJuridique.cCodePeriodicite) then do:
            run destroy in vhoutilGarantieLoyer.
            return.
        end.
        // Contrôles des baremes
        assign
            vhttBaremeCommercial = temp-table ttbaremeProtectionJuridiqueCom:default-buffer-handle
            vhttBaremeHabitation = temp-table ttbaremeProtectionJuridiqueHab:default-buffer-handle
            vcQueryCommercial    = "for each ttbaremeProtectionJuridiqueCom no-lock"
            vcQueryHabitation    = "for each ttbaremeProtectionJuridiqueHab no-lock"
        .
        if lookup(ttProtectionJuridique.CRUD, "C,U") > 0
        and not dynamic-function("testBareme" in vhoutilGarantieLoyer
                                , ttProtectionJuridique.cCodeTVA
                                , vcQueryCommercial
                                , vcQueryHabitation
                                , vhttBaremeCommercial
                                , vhttBaremeHabitation) then do:
            run destroy in vhoutilGarantieLoyer.
            return.
        end.
        if lookup(ttProtectionJuridique.CRUD, "C,U") > 0
        and not dynamic-function("testModeComptabilisationQuestion" in vhoutilGarantieLoyer
                                , ttProtectionJuridique.cTypeContrat
                                , ttProtectionJuridique.cModeComptabilisation
                                , input table ttError) then do:
            run destroy in vhoutilGarantieLoyer.
            return.
        end.
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
    for first ttProtectionJuridique:
        if ttProtectionJuridique.CRUD = "C" then do:
            viNumeroAssurance = 1.
            for last garan no-lock
                where garan.tpctt = ttProtectionJuridique.cTypeContrat
                use-index ix_garan01:
                viNumeroAssurance = garan.noctt + 1.
            end.
        end.
        else viNumeroAssurance = ttProtectionJuridique.iNumeroContrat.

        create ttGarantie.
        assign
            vcModeComptabilisation = ttProtectionJuridique.cModeComptabilisation
            ttGarantie.tpctt       = ttProtectionJuridique.cTypeContrat
            ttGarantie.noctt       = viNumeroAssurance
            ttGarantie.tpbar       = ""
            ttGarantie.nobar       = 0
            ttGarantie.txcot       = 0
            ttGarantie.txhon       = 0
            ttGarantie.txres       = 0
            ttGarantie.fgtot       = ttProtectionJuridique.cCodeApplicationTVA = {&TVABAREME-COTIS-ET-HONO}
            ttGarantie.cdtva       = ttProtectionJuridique.cCodeTVA
            ttGarantie.cdper       = ttProtectionJuridique.cCodePeriodicite
            ttGarantie.txrec       = 0
            ttGarantie.txnor       = 0
            ttGarantie.lbdiv       = ttProtectionJuridique.cCodeAssureur
            ttGarantie.cddev       = ""
            ttGarantie.lbdiv2      = ttProtectionJuridique.cModeComptabilisation
            ttGarantie.lbdiv3      = ""
            ttGarantie.txcot-dev   = 0
            ttGarantie.tpmnt       = ""
            ttGarantie.mtcot       = 0
            ttGarantie.typefac-cle = ""
            ttGarantie.cdass       = ttProtectionJuridique.cCodeAssureur
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
            ttGarantie.dtTimestamp = ttProtectionJuridique.dtTimestamp
            ttGarantie.CRUD        = ttProtectionJuridique.CRUD
            ttGarantie.rRowid      = ttProtectionJuridique.rRowid
        .
        for each ttbaremeProtectionJuridiqueCom
           where ttbaremeProtectionJuridiqueCom.cTypeContrat   = ttProtectionJuridique.cTypeContrat
             and ttbaremeProtectionJuridiqueCom.iNumeroContrat = ttProtectionJuridique.iNumeroContrat:
            create ttGarantie.
            assign
                ttGarantie.tpctt       = ttbaremeProtectionJuridiqueCom.cTypeContrat
                ttGarantie.noctt       = viNumeroAssurance
                ttGarantie.tpbar       = ttbaremeProtectionJuridiqueCom.cTypeBareme
                ttGarantie.nobar       = ttbaremeProtectionJuridiqueCom.iNumeroBareme
                ttGarantie.txcot       = ttbaremeProtectionJuridiqueCom.dTauxCotisation
                ttGarantie.txhon       = ttbaremeProtectionJuridiqueCom.dTauxHonoraire
                ttGarantie.txres       = ttbaremeProtectionJuridiqueCom.dTauxResultat
                ttGarantie.fgtot       = false
                ttGarantie.cdtva       = ""
                ttGarantie.cdper       = ""
                ttGarantie.txrec       = 0
                ttGarantie.txnor       = 0
                ttGarantie.lbdiv       = (if ttbaremeProtectionJuridiqueCom.dMtCotisation > 0 then "MT@" else "TX@")
                ttGarantie.cddev       = ""
                ttGarantie.lbdiv2      = ""
                ttGarantie.lbdiv3      = ""
                ttGarantie.txcot-dev   = 0
                ttGarantie.tpmnt       = ""
                ttGarantie.mtcot       = ttbaremeProtectionJuridiqueCom.dMtCotisation
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
                ttGarantie.dtTimestamp = ttbaremeProtectionJuridiqueCom.dtTimestamp
                ttGarantie.CRUD        = ttProtectionJuridique.CRUD   // tous les barèmes doivent suivre le CRUD de l'entête
                ttGarantie.rRowid      = ttbaremeProtectionJuridiqueCom.rRowid
            .
        end.
        for each ttbaremeProtectionJuridiqueHab
           where ttbaremeProtectionJuridiqueHab.cTypeContrat   = ttProtectionJuridique.cTypeContrat
             and ttbaremeProtectionJuridiqueHab.iNumeroContrat = ttProtectionJuridique.iNumeroContrat:
            create ttGarantie.
            assign
                ttGarantie.tpctt       = ttbaremeProtectionJuridiqueHab.cTypeContrat
                ttGarantie.noctt       = viNumeroAssurance
                ttGarantie.tpbar       = ttbaremeProtectionJuridiqueHab.cTypeBareme
                ttGarantie.nobar       = ttbaremeProtectionJuridiqueHab.iNumeroBareme
                ttGarantie.txcot       = ttbaremeProtectionJuridiqueHab.dTauxCotisation
                ttGarantie.txhon       = ttbaremeProtectionJuridiqueHab.dTauxHonoraire
                ttGarantie.txres       = ttbaremeProtectionJuridiqueHab.dTauxResultat
                ttGarantie.fgtot       = false
                ttGarantie.cdtva       = ""
                ttGarantie.cdper       = ""
                ttGarantie.txrec       = 0
                ttGarantie.txnor       = 0
                ttGarantie.lbdiv       = (if ttbaremeProtectionJuridiqueHab.dMtCotisation > 0 then {&BAREME-FORFAIT} else {&BAREME-TAUX} ) + "@"
                ttGarantie.cddev       = ""
                ttGarantie.lbdiv2      = ""
                ttGarantie.lbdiv3      = ""
                ttGarantie.txcot-dev   = 0
                ttGarantie.tpmnt       = ""
                ttGarantie.mtcot       = ttbaremeProtectionJuridiqueHab.dMtCotisation
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

                ttGarantie.dtTimestamp = ttbaremeProtectionJuridiqueHab.dtTimestamp
                ttGarantie.CRUD        = ttProtectionJuridique.CRUD   // tous les barèmes doivent suivre le CRUD de l'entête
                ttGarantie.rRowid      = ttbaremeProtectionJuridiqueHab.rRowid
            .
        end.
    end.
    run parametre/cabinet/gerance/garan_CRUD.p persistent set vhGarantie.
    run getTokenInstance in vhGarantie(mToken:JSessionId).
    run setGarantie in vhGarantie (input-output table ttGarantie by-reference).
    if not mError:erreur()
    then run majGarantie_ModeComptabilisation in vhGarantie({&TYPECONTRAT-ProtectionJuridique}, vcModeComptabilisation, viNumeroAssurance ).
    run destroy in vhGarantie.
end procedure.

procedure createTTProtectionJuridique private:
    /*-----------------------------------------------------------------------------
    Purpose:
    Notes  :
    -----------------------------------------------------------------------------*/
    define parameter buffer garan for garan.
    define input parameter phoutilGarantieLoyer as handle no-undo.

    create ttProtectionJuridique.
    assign
        ttProtectionJuridique.cTypeContrat          = garan.tpctt
        ttProtectionJuridique.iNumeroContrat        = garan.noctt
        ttProtectionJuridique.cLibelleTypeContrat   = outilTraduction:getLibelleProg("O_CLC", garan.tpctt)
        ttProtectionJuridique.cModeComptabilisation = garan.lbdiv2
        ttProtectionJuridique.cCodeAssureur         = garan.lbdiv
        ttProtectionJuridique.cCodeTVA              = garan.cdtva
        ttProtectionJuridique.cCodeApplicationTVA   = string(garan.fgtot,substitute("&1/&2",{&TVABAREME-COTIS-ET-HONO},{&TVABAREME-HONORAIRE}))
        ttProtectionJuridique.cCodePeriodicite      = garan.cdper
        ttProtectionJuridique.dtTimestamp           = datetime(garan.dtmsy,garan.hemsy)
        ttProtectionJuridique.CRUD                  = "R"
        ttProtectionJuridique.rRowid                = rowid(garan)
    .
    run nomAdresseAssureur in phoutilGarantieLoyer(
        mtoken:cRefGerance,
        garan.tpctt,
        garan.noctt,
        garan.lbdiv,
        garan.cdass,
        output ttProtectionJuridique.cLibelleNumeroContrat,
        output ttProtectionJuridique.cLibelleAssureur
    ).
    ttProtectionJuridique.cLibelle2Comptabilisation = dynamic-function("libelleParamComptaAchatOuOd" in phoutilGarantieLoyer, ttProtectionJuridique.cModeComptabilisation, mtoken:cRefGerance).
    run chargeLibelle.
end procedure.

procedure initComboProtectionJuridique:
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
    define variable voSyspr      as class   syspr no-undo.
    define buffer garan for garan.

    empty temp-table ttCombo.
    voSyspr = new syspr().
    // Mode comptabilisation
    voSyspr:getComboParametre("CPGAR", "CMBTYPECOMPTABILISATION", output table ttCombo by-reference).
    // exclusion code "00002" - non développé
    for first ttcombo
        where ttCombo.cNomCombo = "CMBTYPECOMPTABILISATION"
          and ttCombo.cCode     = "00002":
        delete ttcombo.
    end.
    // Périodicité
    voSyspr:getComboParametre("PDGAR","CMBPERIODICITE", output table ttCombo by-reference).
    delete object voSyspr.
    for last ttCombo:
        viNumeroItem = ttCombo.iSeqId.
    end.
    // TVA calculée sur
    create ttCombo.
    assign
        viNumeroItem             = viNumeroItem + 1
        ttCombo.iSeqId           = viNumeroItem
        ttCombo.cNomCombo        = "CMBAPPLICATIONTVA"
        ttCombo.cCode            = {&TVABAREME-COTIS-ET-HONO}           // "1"
        ttCombo.cLibelle         = outilTraduction:getLibelle(101560)   // Cotisation et Honoraires
    .
    create ttCombo.
    assign
        viNumeroItem             = viNumeroItem + 1
        ttCombo.iSeqId           = viNumeroItem
        ttCombo.cNomCombo        = "CMBAPPLICATIONTVA"
        ttCombo.cCode            = {&TVABAREME-HONORAIRE}               // "2"
        ttCombo.cLibelle         = outilTraduction:getLibelle(101561)   // Honoraires uniquement
    .
    // protection juridique
    for each garan no-lock
        where garan.tpctt = {&TYPECONTRAT-ProtectionJuridique}
          and garan.tpbar = "":
        create ttCombo.
        assign
            viNumeroItem             = viNumeroItem + 1
            ttCombo.iSeqId           = viNumeroItem
            ttCombo.cNomCombo        = "CMBPROTECTIONJURIDIQUE"
            ttCombo.cCode            = string(garan.noctt,"99999")
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
    run getCodeTVA in vhProcTVA(output table ttTVA).
    for each ttTva by ttTva.iCodeTva :
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
        ttProtectionJuridique.cLibelleComptabilisation = outilTraduction:getLibelleParam("CPGAR",ttProtectionJuridique.cModeComptabilisation)
        ttProtectionJuridique.cLibellePeriodicite      = outilTraduction:getLibelleParam("PDGAR",ttProtectionJuridique.cCodePeriodicite)
        ttProtectionJuridique.cLibelleTVA              = outilTraduction:getLibelleParam("CDTVA",ttProtectionJuridique.cCodeTVA)
    .
    case ttProtectionJuridique.cCodeApplicationTVA:
        when {&TVABAREME-COTIS-ET-HONO} then ttProtectionJuridique.cLibelleApplicationTVA = outilTraduction:getLibelle(101560).
        when {&TVABAREME-HONORAIRE}     then ttProtectionJuridique.cLibelleApplicationTVA = outilTraduction:getLibelle(101561).
    end case.
end procedure.
