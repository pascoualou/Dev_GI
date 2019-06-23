
/*------------------------------------------------------------------------
    File        : vacanceLocative.p
    Purpose     : Paramétrage Vacance Locative - 01087
    Author(s)   : RF
    Created     : 2017/11/10
    Notes       :
Modifications SPo -2018/04/27 -
  ----------------------------------------------------------------------*/
using parametre.pclie.pclie.
using parametre.syspg.syspg.
using parametre.syspr.syspr.

{preprocesseur/type2contrat.i}
{preprocesseur/type2bareme.i}
{preprocesseur/listeRubQuit2TVA.i}
{preprocesseur/periode2garantie.i}
{preprocesseur/mode2saisie.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{compta/include/tva.i}
{parametre/cabinet/gerance/include/garantie.i}
{parametre/cabinet/gerance/include/vacanceLocative.i}
{parametre/cabinet/gerance/include/baremeGarantieLoyer.i &nomTable=ttbaremeVacLocCom &serialName=ttbaremeVacLocCom}
{parametre/cabinet/gerance/include/baremeGarantieLoyer.i &nomTable=ttbaremeVacLocHab &serialName=ttbaremeVacLocHab}
{application/include/combo.i}
{application/include/error.i}

procedure getVacanceLocativeByRowid:
    /*-----------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beAssuranceGarantie.cls
    -----------------------------------------------------------------------------*/
    define input  parameter prRowId as rowid no-undo.

    define output parameter table for ttVacanceLocative.
    define output parameter table for ttbaremeVacLocCom.
    define output parameter table for ttbaremeVacLocHab.

    define variable vhoutilGarantieLoyer as handle no-undo.
    define variable vhttBaremeCommercial as handle no-undo.
    define variable vhttBaremeHabitation as handle no-undo.
    define buffer garan for garan.

    run parametre/cabinet/gerance/outilGarantieLoyer.p persistent set vhoutilGarantieLoyer.
    run getTokenInstance in vhoutilGarantieLoyer(mToken:JSessionId).
    for first garan no-lock
        where rowid(garan) = prRowid:

        run createTTVacanceLocative(buffer garan, vhoutilGarantieLoyer).

        run parametre/cabinet/gerance/outilGarantieLoyer.p persistent set vhoutilGarantieLoyer.
        run getTokenInstance in vhoutilGarantieLoyer(mToken:JSessionId).
        run loadBaremeGarantie in vhoutilGarantieLoyer(garan.tpctt, garan.noctt, {&TYPEBAREME-Commercial}, vhttBaremeCommercial).
        run loadBaremeGarantie in vhoutilGarantieLoyer(garan.tpctt, garan.noctt, {&TYPEBAREME-Habitation}, vhttBaremeHabitation).
    end.
    run destroy in vhoutilGarantieLoyer.

end procedure.

procedure getVacanceLocative:
    /*-----------------------------------------------------------------------------
    Purpose: Lecture des informations entête + listes barèmes HAB/COMM pour 1 garantie ou toutes
    Notes  :  service utilisé par beAssuranceGarantie.cls
    -----------------------------------------------------------------------------*/
    define input  parameter piNumeroAssurance as integer   no-undo.
    define output parameter table for ttVacanceLocative.
    define output parameter table for ttbaremeVacLocCom.
    define output parameter table for ttbaremeVacLocHab.

    define variable vhoutilGarantieLoyer as handle no-undo.
    define variable vhttBaremeCommercial as handle no-undo.
    define variable vhttBaremeHabitation as handle no-undo.
    define buffer garan   for garan.

    assign
        vhttBaremeCommercial = temp-table ttbaremeVacLocCom:default-buffer-handle
        vhttBaremeHabitation = temp-table ttbaremeVacLocHab:default-buffer-handle
        .
    run parametre/cabinet/gerance/outilGarantieLoyer.p persistent set vhoutilGarantieLoyer.
    run getTokenInstance in vhoutilGarantieLoyer(mToken:JSessionId).
    for each garan no-lock
        where garan.tpctt = {&TYPECONTRAT-VacanceLocative}
          and garan.noctt = (if piNumeroAssurance > 0 then piNumeroAssurance else garan.noctt)
          and garan.tpbar = "":
        run createTTVacanceLocative(buffer garan, vhoutilGarantieLoyer).
        run loadBaremeGarantie in vhoutilGarantieLoyer(garan.tpctt, garan.noctt, {&TYPEBAREME-Commercial}, vhttBaremeCommercial).
        run loadBaremeGarantie in vhoutilGarantieLoyer(garan.tpctt, garan.noctt, {&TYPEBAREME-Habitation}, vhttBaremeHabitation).
    end.
    run destroy in vhoutilGarantieLoyer.
end procedure.

procedure setVacanceLocative:
    /*-----------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beAssuranceGarantie.cls
    -----------------------------------------------------------------------------*/
    define input parameter table for ttVacanceLocative.
    define input parameter table for ttbaremeVacLocCom.
    define input parameter table for ttbaremeVacLocHab.
    define input parameter table for ttError.
    run controlesAvantValidation.
    if not mError:erreur() then run miseAJourGarantie.
end procedure.

procedure initVacanceLocative:
    /*-----------------------------------------------------------------------------
    Purpose: Initialisation pour création d'une nouvelle assurance vacance locative
    Notes  : service utilisé par beAssuranceGarantie.cls
    -----------------------------------------------------------------------------*/
    define output parameter table for ttVacanceLocative.
    define output parameter table for ttbaremeVacLocCom.
    define output parameter table for ttbaremeVacLocHab.

    define variable viCompteur           as integer no-undo.
    define variable vhoutilGarantieLoyer as handle  no-undo.
    define buffer garan for garan.
    run parametre/cabinet/gerance/outilGarantieLoyer.p persistent set vhoutilGarantieLoyer.
    run getTokenInstance in vhoutilGarantieLoyer(mToken:JSessionId).
    create ttVacanceLocative.
    assign
        ttVacanceLocative.cTypeContrat          = {&TYPECONTRAT-VacanceLocative}
        ttVacanceLocative.iNumeroContrat        = 0
        ttVacanceLocative.cLibelleTypeContrat   = outilTraduction:getLibelleProg("O_CLC", ttVacanceLocative.cTypeContrat)
        ttVacanceLocative.cModeComptabilisation = "00000"  // dépend des garanties existantes
        ttVacanceLocative.cCodeAssureur         = ""
        ttVacanceLocative.cCodeTVA              = {&codeTVA-00000}
        ttVacanceLocative.cCodeApplicationTVA   = {&TVABAREME-COTIS-ET-HONO}
        ttVacanceLocative.cCodePeriodicite      = {&PERIODEGARANTIE-mensuel}
        ttVacanceLocative.iDureeVacanceSortie   = 0
        ttVacanceLocative.iDureeFranchise       = 0
        ttVacanceLocative.iDureeVacanceEntree   = 0
        ttVacanceLocative.cCodeCalculSelondate  = {&non}
        ttVacanceLocative.cModeSaisie           = {&MODESAISIEBAREME-TxCotis-et-TxHono}
        ttVacanceLocative.dtTimestamp           = ?
        ttVacanceLocative.CRUD                  = ""
        .

    // Type de comptabilisation par défaut -> hérité du premier enregistrement garan pour ce type d'assurance
    for first garan no-lock
         where garan.tpctt = {&TYPECONTRAT-VacanceLocative}:
        ttVacanceLocative.cModeComptabilisation = garan.lbdiv2.
    end.
    ttVacanceLocative.cLibelle2Comptabilisation = dynamic-function("libelleParamComptaAchatOuOd" in vhoutilGarantieLoyer, ttVacanceLocative.cModeComptabilisation, mtoken:cRefGerance).
    run chargeLibelle.

    do viCompteur = 1 to 10:
        create ttbaremeVacLocCom.
        assign
            ttbaremeVacLocCom.cTypeContrat    = {&TYPECONTRAT-VacanceLocative}
            ttbaremeVacLocCom.iNumeroContrat  = 0
            ttbaremeVacLocCom.cTypeBareme     = {&TYPEBAREME-Commercial}
            ttbaremeVacLocCom.iNumeroBareme   = viCompteur
            ttbaremeVacLocCom.dMtCotisation   = 0
            ttbaremeVacLocCom.dTauxCotisation = 0
            ttbaremeVacLocCom.dTauxHonoraire  = 0
            ttbaremeVacLocCom.dTauxResultat   = 0
            .

        create ttbaremeVacLocHab.
        assign
            ttbaremeVacLocHab.cTypeContrat    = {&TYPECONTRAT-VacanceLocative}
            ttbaremeVacLocHab.iNumeroContrat  = 0
            ttbaremeVacLocHab.cTypeBareme     = {&TYPEBAREME-Habitation}
            ttbaremeVacLocHab.iNumeroBareme   = viCompteur
            ttbaremeVacLocHab.dMtCotisation   = 0
            ttbaremeVacLocHab.dTauxCotisation = 0
            ttbaremeVacLocHab.dTauxHonoraire  = 0
            ttbaremeVacLocHab.dTauxResultat   = 0
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
    for each ttVacanceLocative
        where lookup(ttVacanceLocative.CRUD, "C,U,D") > 0:
        if ttVacanceLocative.cTypeContrat ne {&TYPECONTRAT-VacanceLocative} then do:
            mError:createError({&error}, 1000688).
            run destroy in vhoutilGarantieLoyer.
            return.
        end.
        else if lookup(ttVacanceLocative.CRUD, "U,D") > 0
        and not dynamic-function("testGarantieExiste" in vhoutilGarantieLoyer
                                , ttVacanceLocative.cTypeContrat
                                , ttVacanceLocative.iNumeroContrat
                                , ttVacanceLocative.CRUD)
        then do:
            run destroy in vhoutilGarantieLoyer.
            return.
        end.
        else if not dynamic-function("testAssureurAutorise" in vhoutilGarantieLoyer
                                    , ttVacanceLocative.cTypeContrat
                                    , ttVacanceLocative.iNumeroContrat
                                    , ttVacanceLocative.cCodeAssureur
                                    , ttVacanceLocative.CRUD)
        then do:
            run destroy in vhoutilGarantieLoyer.
            return.
        end.
       // Suppression interdite si un bail rattaché à cette garantie
        else if ttVacanceLocative.CRUD = "D"
        and dynamic-function("testGarantieUtilisee" in vhoutilGarantieLoyer
                            , ttVacanceLocative.cTypeContrat
                            , ttVacanceLocative.iNumeroContrat
                            , ttVacanceLocative.CRUD)
        then do:
            run destroy in vhoutilGarantieLoyer.
            return.
        end.
        else if ttVacanceLocative.CRUD = "U"
        and not dynamic-function("testModifPeriodicite" in vhoutilGarantieLoyer
                                , ttVacanceLocative.cTypeContrat
                                , ttVacanceLocative.iNumeroContrat
                                , ttVacanceLocative.cCodePeriodicite)
        then do:
            run destroy in vhoutilGarantieLoyer.
            return.
        end.
        else if not dynamic-function("testCarence" in vhoutilGarantieLoyer
                                , ttVacanceLocative.cCodeCalculSelondate
                                , ttVacanceLocative.iDureeVacanceEntree)
        then do:
            run destroy in vhoutilGarantieLoyer.
            return.
        end.
        // Contrôles des baremes
        assign
            vhttBaremeCommercial = temp-table ttbaremeVacLocCom:default-buffer-handle
            vhttBaremeHabitation = temp-table ttbaremeVacLocHab:default-buffer-handle
            vcQueryCommercial    = "for each ttbaremeVacLocCom no-lock"
            vcQueryHabitation    = "for each ttbaremeVacLocHab no-lock"
        .
        if lookup(ttVacanceLocative.CRUD, "C,U") > 0
        and not dynamic-function("testBareme" in vhoutilGarantieLoyer
                                , ttVacanceLocative.cCodeTVA
                                , vcQueryCommercial
                                , vcQueryHabitation
                                , vhttBaremeCommercial
                                , vhttBaremeHabitation)
        then do:
            run destroy in vhoutilGarantieLoyer.
            return.
        end.
        if lookup(ttVacanceLocative.CRUD, "C,U") > 0
        and not dynamic-function("testModeComptabilisationQuestion" in vhoutilGarantieLoyer
                                            , ttVacanceLocative.cTypeContrat
                                            , ttVacanceLocative.cModeComptabilisation
                                            , input table ttError)
        then do:
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
    for first ttVacanceLocative:
       if ttVacanceLocative.CRUD = "C" then do:
            viNumeroAssurance = 1.
            for last garan no-lock
               where garan.tpctt =  ttVacanceLocative.cTypeContrat
               use-index ix_garan01:
               viNumeroAssurance =  garan.noctt + 1.
            end.
        end.
        else viNumeroAssurance = ttVacanceLocative.iNumeroContrat.

        create ttGarantie.
        assign
            ttGarantie.tpctt       = ttVacanceLocative.cTypeContrat
            ttGarantie.noctt       = viNumeroAssurance
            ttGarantie.tpbar       = ""
            ttGarantie.nobar       = 0
            ttGarantie.txcot       = 0
            ttGarantie.txhon       = integer(ttVacanceLocative.cModeSaisie)
            ttGarantie.txres       = 0
            ttGarantie.fgtot       = no
            ttGarantie.cdtva       = ttVacanceLocative.cCodeTVA
            ttGarantie.cdper       = ttVacanceLocative.cCodePeriodicite
            ttGarantie.txrec       = 0
            ttGarantie.txnor       = 0
            ttGarantie.lbdiv       = ""
            ttGarantie.cddev       = string(ttVacanceLocative.iDureeVacanceEntree)
            ttGarantie.lbdiv2      = ""
            ttGarantie.lbdiv3      = ""
            ttGarantie.txcot-dev   = 0
            ttGarantie.tpmnt       = ""
            ttGarantie.mtcot       = 0
            ttGarantie.typefac-cle = ""
            ttGarantie.cdass       = ttVacanceLocative.cCodeAssureur
            ttGarantie.nbmca       = ttVacanceLocative.iDureeVacanceSortie
            ttGarantie.nbmfr       = ttVacanceLocative.iDureeFranchise
            ttGarantie.cpgar       = ttVacanceLocative.cModeComptabilisation
            ttGarantie.fgGRL       = false
            ttGarantie.convention  = ""
            ttGarantie.nocontrat   = ""
            ttGarantie.nompartres  = ""
            ttGarantie.tprolcour   = ""
            ttGarantie.norolcour   = 0
            ttGarantie.CdDebCal    = ttVacanceLocative.cCodeCalculSelondate
            ttGarantie.CdTriEdi    = ""
            ttGarantie.cdperbord   = ""
            ttGarantie.dtTimestamp = ttVacanceLocative.dtTimestamp
	        ttGarantie.CRUD        = ttVacanceLocative.CRUD
            ttGarantie.rRowid      = ttVacanceLocative.rRowid
            .

        for each ttbaremeVacLocCom
           where ttbaremeVacLocCom.cTypeContrat   = ttVacanceLocative.cTypeContrat
             and ttbaremeVacLocCom.iNumeroContrat = ttVacanceLocative.iNumeroContrat:

            create ttGarantie.
            assign
                ttGarantie.tpctt       = ttbaremeVacLocCom.cTypeContrat
                ttGarantie.noctt       = viNumeroAssurance
                ttGarantie.tpbar       = ttbaremeVacLocCom.cTypeBareme
                ttGarantie.nobar       = ttbaremeVacLocCom.iNumeroBareme
                ttGarantie.txcot       = ttbaremeVacLocCom.dTauxCotisation
                ttGarantie.txhon       = ttbaremeVacLocCom.dTauxHonoraire
                ttGarantie.txres       = ttbaremeVacLocCom.dTauxResultat
                ttGarantie.fgtot       = false
                ttGarantie.cdtva       = ""
                ttGarantie.cdper       = ""
                ttGarantie.txrec       = 0
                ttGarantie.txnor       = 0
                ttGarantie.lbdiv       = (if ttbaremeVacLocCom.dMtCotisation > 0 then "MT@" else "TX@")
                ttGarantie.cddev       = ""
                ttGarantie.lbdiv2      = ""
                ttGarantie.lbdiv3      = ""

                ttGarantie.txcot-dev   = 0
                ttGarantie.tpmnt       = ""
                ttGarantie.mtcot       = ttbaremeVacLocCom.dMtCotisation
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

                ttGarantie.dtTimestamp = ttbaremeVacLocCom.dtTimestamp
                ttGarantie.CRUD        = ttVacanceLocative.CRUD   // tous les barèmes doivent suivre le CRUD de l'entête
                ttGarantie.rRowid      = ttbaremeVacLocCom.rRowid
                .

        end.

        for each ttbaremeVacLocHab
           where ttbaremeVacLocHab.cTypeContrat   = ttVacanceLocative.cTypeContrat
             and ttbaremeVacLocHab.iNumeroContrat = ttVacanceLocative.iNumeroContrat:

            create ttGarantie.
            assign
                ttGarantie.tpctt       = ttbaremeVacLocHab.cTypeContrat
                ttGarantie.noctt       = viNumeroAssurance
                ttGarantie.tpbar       = ttbaremeVacLocHab.cTypeBareme
                ttGarantie.nobar       = ttbaremeVacLocHab.iNumeroBareme
                ttGarantie.txcot       = ttbaremeVacLocHab.dTauxCotisation
                ttGarantie.txhon       = ttbaremeVacLocHab.dTauxHonoraire
                ttGarantie.txres       = ttbaremeVacLocHab.dTauxResultat
                ttGarantie.fgtot       = false
                ttGarantie.cdtva       = ""
                ttGarantie.cdper       = ""
                ttGarantie.txrec       = 0
                ttGarantie.txnor       = 0
                ttGarantie.lbdiv       = (if ttbaremeVacLocHab.dMtCotisation > 0 then "MT@" else "TX@")
                ttGarantie.cddev       = ""
                ttGarantie.lbdiv2      = ""
                ttGarantie.lbdiv3      = ""
                ttGarantie.txcot-dev   = 0
                ttGarantie.tpmnt       = ""
                ttGarantie.mtcot       = ttbaremeVacLocHab.dMtCotisation
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

                ttGarantie.dtTimestamp = ttbaremeVacLocHab.dtTimestamp
                ttGarantie.CRUD        = ttVacanceLocative.CRUD   // tous les barèmes doivent suivre le CRUD de l'entête
                ttGarantie.rRowid      = ttbaremeVacLocHab.rRowid
                .

        end.
    end.
    run parametre/cabinet/gerance/garan_CRUD.p persistent set vhGarantie.
    run getTokenInstance in vhGarantie(mToken:JSessionId).
    run setGarantie in vhGarantie (input-output table ttGarantie by-reference).
    if not mError:erreur()
    then run majGarantie_ModeComptabilisation in vhGarantie({&TYPECONTRAT-VacanceLocative}, vcModeComptabilisation, viNumeroAssurance ).
    run destroy in vhGarantie.

end procedure.

procedure createTTVacanceLocative:
    /*-----------------------------------------------------------------------------
    Purpose:
    Notes  :
    -----------------------------------------------------------------------------*/
    define parameter buffer garan for garan.
    define input parameter phoutilGarantieLoyer as handle no-undo.

    create ttVacanceLocative.
    assign
        ttVacanceLocative.cTypeContrat          = garan.tpctt
        ttVacanceLocative.iNumeroContrat        = garan.noctt
        ttVacanceLocative.cLibelleTypeContrat   = outilTraduction:getLibelleProg("O_CLC", garan.tpctt)
        ttVacanceLocative.cModeComptabilisation = garan.cpgar
        ttVacanceLocative.cCodeAssureur         = garan.cdass
        ttVacanceLocative.cCodeTVA              = garan.cdtva
        ttVacanceLocative.cCodeApplicationTVA   = string(garan.fgtot,substitute("&1/&2",{&TVABAREME-COTIS-ET-HONO},{&TVABAREME-HONORAIRE}))
        ttVacanceLocative.cCodePeriodicite      = garan.cdper
        ttVacanceLocative.iDureeVacanceSortie   = garan.nbmca
        ttVacanceLocative.iDureeFranchise       = garan.nbmfr
        ttVacanceLocative.iDureeVacanceEntree   = integer(garan.cddev)
        ttVacanceLocative.cCodeCalculSelondate  = garan.CdDebCal
        ttVacanceLocative.cModeSaisie           = string(garan.txhon)
        ttVacanceLocative.dtTimestamp           = datetime(garan.dtmsy,garan.hemsy)
        ttVacanceLocative.CRUD                  = "R"
        ttVacanceLocative.rRowid                = rowid(garan)
        .
    run nomAdresseAssureur in phoutilGarantieLoyer(
        mtoken:cRefGerance,
        garan.tpctt,
        garan.noctt,
        garan.lbdiv,
        garan.cdass,
        output ttVacanceLocative.cLibelleNumeroContrat,
        output ttVacanceLocative.cLibelleAssureur
    ).
    ttVacanceLocative.cLibelle2Comptabilisation = dynamic-function("libelleParamComptaAchatOuOd" in phoutilGarantieLoyer, ttVacanceLocative.cModeComptabilisation, mtoken:cRefGerance).
    run chargeLibelle.
end procedure.

procedure initComboVacanceLocative:
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
    voSyspr:getComboParametre("CPGAR","CMBTYPECOMPTABILISATION", output table ttCombo by-reference).
    // exclusion code "00002" - non développé */
    for first ttcombo
        where ttCombo.cNomCombo = "CMBTYPECOMPTABILISATION"
          and ttCombo.cCode     = "00002":
        delete ttcombo.
    end.
    // Périodicité
    voSyspr:getComboParametre("PDGAR","CMBPERIODICITE", output table ttCombo by-reference).

    // Calcul de la garantie loyer à partir d'une date
    voSyspr:getComboParametre("CDOUI","CMBCALCULSELONDATE", output table ttCombo by-reference).

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
        ttCombo.cLibelle         = outilTraduction:getLibelle(101561)
    .
    // Mode saisie
    create ttCombo.
        assign
            viNumeroItem             = viNumeroItem + 1
            ttCombo.iSeqId           = viNumeroItem
            ttCombo.cNomCombo        = "CMBMODESAISIE"
            ttCombo.cCode            = {&MODESAISIEBAREME-TxCotis-et-TxHono}
            ttCombo.cLibelle         = outilTraduction:getLibelle(110051)
            .
    create ttCombo.
        assign
            viNumeroItem             = viNumeroItem + 1
            ttCombo.iSeqId           = viNumeroItem
            ttCombo.cNomCombo        = "CMBMODESAISIE"
            ttCombo.cCode            = {&MODESAISIEBAREME-TxCotis-et-TxResultant}
            ttCombo.cLibelle         = outilTraduction:getLibelle(110052)
            .

    // vacance locative
    for each garan no-lock
       where garan.tpctt = {&TYPECONTRAT-VacanceLocative}
         and garan.tpbar = "":
        create ttCombo.
        assign
            viNumeroItem             = viNumeroItem + 1
            ttCombo.iSeqId           = viNumeroItem
            ttCombo.cNomCombo        = "CMBVACANCELOCATIVE"
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
            viNumeroItem             = viNumeroItem + 1
            ttCombo.iSeqId           = viNumeroItem
            ttCombo.cNomCombo        = "CMBTVA"
            ttCombo.cCode            = ttTVA.cCodeTVA
            ttCombo.cLibelle         = ttTVA.cLibelleTVA
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
        ttVacanceLocative.cLibelleTypeContrat      = outilTraduction:getLibelleProg("O_CLC",ttVacanceLocative.cTypeContrat)
        ttVacanceLocative.cLibelleComptabilisation = outilTraduction:getLibelleParam("CPGAR",ttVacanceLocative.cModeComptabilisation)
        ttVacanceLocative.cLibellePeriodicite      = outilTraduction:getLibelleParam("PDGAR",ttVacanceLocative.cCodePeriodicite)
        ttVacanceLocative.cLibelleCalculSelonDate  = outilTraduction:getLibelleParam("CDOUI",ttVacanceLocative.cCodeCalculSelonDate)
        ttVacanceLocative.cLibelleTVA              = outilTraduction:getLibelleParam("CDTVA",ttVacanceLocative.cCodeTVA)
    .
    
    case ttVacanceLocative.cCodeApplicationTVA:
        when {&TVABAREME-COTIS-ET-HONO} then ttVacanceLocative.cLibelleApplicationTVA = outilTraduction:getLibelle(101560).
        when {&TVABAREME-HONORAIRE}     then ttVacanceLocative.cLibelleApplicationTVA = outilTraduction:getLibelle(101561).
    end case.
    
    case ttVacanceLocative.cModeSaisie:
        when {&MODESAISIEBAREME-TxCotis-et-TxHono}      then ttVacanceLocative.cLibelleSaisie = outilTraduction:getLibelle(110051).
        when {&MODESAISIEBAREME-TxCotis-et-TxResultant} then ttVacanceLocative.cLibelleSaisie = outilTraduction:getLibelle(110052).
    end case.

end procedure.
