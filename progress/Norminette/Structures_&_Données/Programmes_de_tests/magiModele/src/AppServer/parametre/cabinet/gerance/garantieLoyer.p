
/*------------------------------------------------------------------------
    File        : garantieLoyer.p
    Purpose     : Paramétrage Garantie Loyer - 01007
    Author(s)   : RF
    Created     : 2017/11/10
    Notes       :
Modifications SPo -2018/04/27 OK pour passage en revue de code PM
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
{parametre/cabinet/gerance/include/garantieLoyer.i}
{parametre/cabinet/gerance/include/baremeGarantieLoyer.i &nomTable=ttbaremeGarantieLoyerCom &serialName=ttbaremeGarantieLoyerCom}
{parametre/cabinet/gerance/include/baremeGarantieLoyer.i &nomTable=ttbaremeGarantieLoyerHab &serialName=ttbaremeGarantieLoyerHab}
{application/include/combo.i}
{application/include/error.i}

procedure getGarantieLoyerByRowid:
    /*-----------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beAssuranceGarantie.cls
    -----------------------------------------------------------------------------*/
    define input  parameter prRowId as rowid no-undo.

    define output parameter table for ttGarantieLoyer.
    define output parameter table for ttbaremeGarantieLoyerCom.
    define output parameter table for ttbaremeGarantieLoyerHab.

    define variable vhoutilGarantieLoyer         as handle no-undo.
    define variable vhttBaremeCommercial as handle no-undo.
    define variable vhttBaremeHabitation as handle no-undo.
    define buffer garan for garan.

    assign
        vhttBaremeCommercial = temp-table ttbaremeGarantieLoyerCom:default-buffer-handle
        vhttBaremeHabitation = temp-table ttbaremeGarantieLoyerHab:default-buffer-handle
        .
    for first garan no-lock
        where rowid(garan) = prRowid:

        run createTTGarantieLoyer(buffer garan, vhoutilGarantieLoyer).

        run parametre/cabinet/gerance/outilGarantieLoyer.p persistent set vhoutilGarantieLoyer.
        run getTokenInstance in vhoutilGarantieLoyer(mToken:JSessionId).
        run loadBaremeGarantie in vhoutilGarantieLoyer(garan.tpctt, garan.noctt, {&TYPEBAREME-Commercial}, vhttBaremeCommercial).
        run loadBaremeGarantie in vhoutilGarantieLoyer(garan.tpctt, garan.noctt, {&TYPEBAREME-Habitation}, vhttBaremeHabitation).
    end.
    run destroy in vhoutilGarantieLoyer.

end procedure.

procedure getGarantieLoyer:
    /*-----------------------------------------------------------------------------
    Purpose: Lecture des informations entête + listes barèmes HAB/COMM pour 1 garantie ou toutes
    Notes  :  service utilisé par beAssuranceGarantie.cls
    -----------------------------------------------------------------------------*/
    define input  parameter piNumeroAssurance as integer   no-undo.

    define output parameter table for ttGarantieLoyer.
    define output parameter table for ttbaremeGarantieLoyerCom.
    define output parameter table for ttbaremeGarantieLoyerHab.

    define buffer garan    for garan.

    define variable vhoutilGarantieLoyer         as handle no-undo.
    define variable vhttBaremeCommercial as handle no-undo.
    define variable vhttBaremeHabitation as handle no-undo.

    assign
        vhttBaremeCommercial = temp-table ttbaremeGarantieLoyerCom:default-buffer-handle
        vhttBaremeHabitation = temp-table ttbaremeGarantieLoyerHab:default-buffer-handle
        .
    run parametre/cabinet/gerance/outilGarantieLoyer.p persistent set vhoutilGarantieLoyer.
    run getTokenInstance in vhoutilGarantieLoyer(mToken:JSessionId).
    for each garan no-lock
        where garan.tpctt = {&TYPECONTRAT-GarantieLoyer}
          and garan.noctt = (if piNumeroAssurance > 0 then piNumeroAssurance else garan.noctt)
          and garan.tpbar = "":
        run createTTGarantieLoyer(buffer garan, vhoutilGarantieLoyer).
        run LoadBaremeGarantie in vhoutilGarantieLoyer(garan.tpctt,garan.noctt,{&TYPEBAREME-Commercial}, vhttBaremeCommercial).
        run LoadBaremeGarantie in vhoutilGarantieLoyer(garan.tpctt,garan.noctt,{&TYPEBAREME-Habitation}, vhttBaremeHabitation).
    end.
    run destroy in vhoutilGarantieLoyer.
end procedure.

procedure setGarantieLoyer:
    /*-----------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beAssuranceGarantie.cls
    -----------------------------------------------------------------------------*/
    define input parameter table for ttGarantieLoyer.
    define input parameter table for ttbaremeGarantieLoyerCom.
    define input parameter table for ttbaremeGarantieLoyerHab.
    define input parameter table for ttError.
    run controlesAvantValidation.
    if not mError:erreur() then run miseAJourGarantie.
end procedure.

procedure initGarantieLoyer:
    /*-----------------------------------------------------------------------------
    Purpose: Initialisation pour création d'une nouvelle assurance garantie loyer
    Notes  : service utilisé par beAssuranceGarantie.cls
    -----------------------------------------------------------------------------*/
    define output parameter table for ttGarantieLoyer.
    define output parameter table for ttbaremeGarantieLoyerCom.
    define output parameter table for ttbaremeGarantieLoyerHab.

    define variable viCompteur           as integer no-undo.
    define variable vhoutilGarantieLoyer as handle  no-undo.
    define buffer garan for garan.
    run parametre/cabinet/gerance/outilGarantieLoyer.p persistent set vhoutilGarantieLoyer.
    run getTokenInstance in vhoutilGarantieLoyer(mToken:JSessionId).
    create ttGarantieLoyer.
    assign
        ttGarantieLoyer.cTypeContrat          = {&TYPECONTRAT-GarantieLoyer}
        ttGarantieLoyer.iNumeroContrat        = 0
        ttGarantieLoyer.cLibelleTypeContrat   = outilTraduction:getLibelleProg("O_CLC", ttGarantieLoyer.cTypeContrat)
        ttGarantieLoyer.cModeComptabilisation = "00000"  // dépend des garanties existantes
        ttGarantieLoyer.cCodeAssureur         = ""
        ttGarantieLoyer.cCodeTVA              = {&codeTVA-00000}
        ttGarantieLoyer.cCodeApplicationTVA   = {&TVABAREME-COTIS-ET-HONO}
        ttGarantieLoyer.cCodePeriodicite      = {&PERIODEGARANTIE-mensuel}
        ttGarantieLoyer.dTauxRecuperable      = 100
        ttGarantieLoyer.dTauxNonRecuperable   = 0
        ttGarantieLoyer.cCodeCalculSelondate  = {&non}
        ttGarantieLoyer.dNombreMoisCarence    = 0
        ttGarantieLoyer.cModeSaisie           = {&MODESAISIEBAREME-TxCotis-et-TxHono}
        ttGarantieLoyer.dtTimestamp           = ?
        ttGarantieLoyer.CRUD                  = ""
        .
    // Type de comptabilisation par défaut -> hérité du premier enregistrement garan
    for first garan no-lock
         where garan.tpctt = {&TYPECONTRAT-GarantieLoyer}:
        ttGarantieLoyer.cModeComptabilisation = garan.lbdiv2.
    end.
    ttGarantieLoyer.cLibelle2Comptabilisation = dynamic-function("libelleParamComptaAchatOuOd" in vhoutilGarantieLoyer, ttGarantieLoyer.cModeComptabilisation, mtoken:cRefGerance).
    run chargeLibelle.
    do viCompteur = 1 to 10:
        create ttbaremeGarantieLoyerCom.
        assign
            ttbaremeGarantieLoyerCom.cTypeContrat    = {&TYPECONTRAT-GarantieLoyer}
            ttbaremeGarantieLoyerCom.iNumeroContrat  = 0
            ttbaremeGarantieLoyerCom.cTypeBareme     = {&TYPEBAREME-Commercial}
            ttbaremeGarantieLoyerCom.iNumeroBareme   = viCompteur
            ttbaremeGarantieLoyerCom.dMtCotisation   = 0
            ttbaremeGarantieLoyerCom.dTauxCotisation = 0
            ttbaremeGarantieLoyerCom.dTauxHonoraire  = 0
            ttbaremeGarantieLoyerCom.dTauxResultat   = 0
        .

        create ttbaremeGarantieLoyerHab.
        assign
            ttbaremeGarantieLoyerHab.cTypeContrat    = {&TYPECONTRAT-GarantieLoyer}
            ttbaremeGarantieLoyerHab.iNumeroContrat  = 0
            ttbaremeGarantieLoyerHab.cTypeBareme     = {&TYPEBAREME-Habitation}
            ttbaremeGarantieLoyerHab.iNumeroBareme   = viCompteur
            ttbaremeGarantieLoyerHab.dMtCotisation   = 0
            ttbaremeGarantieLoyerHab.dTauxCotisation = 0
            ttbaremeGarantieLoyerHab.dTauxHonoraire  = 0
            ttbaremeGarantieLoyerHab.dTauxResultat   = 0
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

    for each ttGarantieLoyer
        where lookup(ttGarantieLoyer.CRUD, "C,U,D") > 0:
        if ttGarantieLoyer.cTypeContrat ne {&TYPECONTRAT-GarantieLoyer} then do:
            mError:createError({&error}, 1000688).
            run destroy in vhoutilGarantieLoyer.
            return.
        end.
        else if lookup(ttGarantieLoyer.CRUD, "U,D") > 0
        and not dynamic-function("testGarantieExiste" in vhoutilGarantieLoyer
                                , ttGarantieLoyer.cTypeContrat
                                , ttGarantieLoyer.iNumeroContrat
                                , ttGarantieLoyer.CRUD)
        then do:
            run destroy in vhoutilGarantieLoyer.
            return.
        end.
        else if not dynamic-function("testAssureurAutorise" in vhoutilGarantieLoyer
                                    , ttGarantieLoyer.cTypeContrat
                                    , ttGarantieLoyer.iNumeroContrat
                                    , ttGarantieLoyer.cCodeAssureur
                                    , ttGarantieLoyer.CRUD)
        then do:
            run destroy in vhoutilGarantieLoyer.
            return.
        end.
       // Suppression interdite si un bail rattaché à cette garantie
        else if ttGarantieLoyer.CRUD = "D"
        and dynamic-function("testGarantieUtilisee" in vhoutilGarantieLoyer
                            , ttGarantieLoyer.cTypeContrat
                            , ttGarantieLoyer.iNumeroContrat
                            , ttGarantieLoyer.CRUD)
        then do:
            run destroy in vhoutilGarantieLoyer.
            return.
        end.
        else if ttGarantieLoyer.CRUD = "U"
        and not dynamic-function("testModifPeriodicite" in vhoutilGarantieLoyer
                                , ttGarantieLoyer.cTypeContrat
                                , ttGarantieLoyer.iNumeroContrat
                                , ttGarantieLoyer.cCodePeriodicite)
        then do:
            run destroy in vhoutilGarantieLoyer.
            return.
        end.
        else if not dynamic-function("testCarence" in vhoutilGarantieLoyer
                                , ttGarantieLoyer.cCodeCalculSelondate
                                , ttGarantieLoyer.dNombreMoisCarence)
        then do:
            run destroy in vhoutilGarantieLoyer.
            return.
        end.
        // Contrôles des baremes
        assign
            vhttBaremeCommercial = temp-table ttbaremeGarantieLoyerCom:default-buffer-handle
            vhttBaremeHabitation = temp-table ttbaremeGarantieLoyerHab:default-buffer-handle
            vcQueryCommercial    = "for each ttbaremeGarantieLoyerCom no-lock"
            vcQueryHabitation    = "for each ttbaremeGarantieLoyerHab no-lock"
        .
        if lookup(ttGarantieLoyer.CRUD, "C,U") > 0
        and not dynamic-function("testBareme" in vhoutilGarantieLoyer
                                , ttGarantieLoyer.cCodeTVA
                                , vcQueryCommercial
                                , vcQueryHabitation
                                , vhttBaremeCommercial
                                , vhttBaremeHabitation)
        then do:
            run destroy in vhoutilGarantieLoyer.
            return.
        end.
        if lookup(ttGarantieLoyer.CRUD, "C,U") > 0
        and not dynamic-function("testModeComptabilisationQuestion" in vhoutilGarantieLoyer
                                            , ttGarantieLoyer.cTypeContrat
                                            , ttGarantieLoyer.cModeComptabilisation
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
    for first ttGarantieLoyer:
       if ttGarantieLoyer.CRUD = "C" then do:
            viNumeroAssurance = 1.
            for last garan no-lock
                where garan.tpctt = ttGarantieLoyer.cTypeContrat
                use-index ix_garan01:
                viNumeroAssurance = garan.noctt + 1.
            end.
        end.
        else viNumeroAssurance = ttGarantieLoyer.iNumeroContrat.

        create ttGarantie.
        assign
           vcModeComptabilisation = ttGarantieLoyer.cModeComptabilisation
            ttGarantie.tpctt       = ttGarantieLoyer.cTypeContrat
            ttGarantie.noctt       = viNumeroAssurance
            ttGarantie.tpbar       = ""
            ttGarantie.nobar       = 0
            ttGarantie.txcot       = 0
            ttGarantie.txhon       = integer(ttGarantieLoyer.cModeSaisie)
            ttGarantie.txres       = 0
            ttGarantie.fgtot       = ttGarantieLoyer.cCodeApplicationTVA = {&TVABAREME-COTIS-ET-HONO}
            ttGarantie.cdtva       = ttGarantieLoyer.cCodeTVA
            ttGarantie.cdper       = ttGarantieLoyer.cCodePeriodicite
            ttGarantie.txrec       = ttGarantieLoyer.dTauxRecuperable
            ttGarantie.txnor       = ttGarantieLoyer.dTauxNonRecuperable
            ttGarantie.lbdiv       = ttGarantieLoyer.cCodeAssureur
            ttGarantie.cddev       = ""
            ttGarantie.lbdiv2      = ttGarantieLoyer.cModeComptabilisation
            ttGarantie.lbdiv3      = ""
            ttGarantie.txcot-dev   = 0
            ttGarantie.tpmnt       = ""
            ttGarantie.mtcot       = 0
            ttGarantie.typefac-cle = ""
            ttGarantie.cdass       = ""
            ttGarantie.nbmca       = ttGarantieLoyer.dNombreMoisCarence
            ttGarantie.nbmfr       = 0
            ttGarantie.cpgar       = ""
            ttGarantie.fgGRL       = false
            ttGarantie.convention  = ""
            ttGarantie.nocontrat   = ""
            ttGarantie.nompartres  = ""
            ttGarantie.tprolcour   = ""
            ttGarantie.norolcour   = 0
            ttGarantie.CdDebCal    = ttGarantieLoyer.cCodeCalculSelondate
            ttGarantie.CdTriEdi    = ""
            ttGarantie.cdperbord   = ""

            ttGarantie.dtTimestamp = ttGarantieLoyer.dtTimestamp
            ttGarantie.CRUD        = ttGarantieLoyer.CRUD
            ttGarantie.rRowid      = ttGarantieLoyer.rRowid
        .

        for each ttbaremeGarantieLoyerCom
           where ttbaremeGarantieLoyerCom.cTypeContrat   = ttGarantieLoyer.cTypeContrat
             and ttbaremeGarantieLoyerCom.iNumeroContrat = ttGarantieLoyer.iNumeroContrat:

            create ttGarantie.
            assign
                ttGarantie.tpctt       = ttbaremeGarantieLoyerCom.cTypeContrat
                ttGarantie.noctt       = viNumeroAssurance
                ttGarantie.tpbar       = ttbaremeGarantieLoyerCom.cTypeBareme
                ttGarantie.nobar       = ttbaremeGarantieLoyerCom.iNumeroBareme
                ttGarantie.txcot       = ttbaremeGarantieLoyerCom.dTauxCotisation
                ttGarantie.txhon       = ttbaremeGarantieLoyerCom.dTauxHonoraire
                ttGarantie.txres       = ttbaremeGarantieLoyerCom.dTauxResultat
                ttGarantie.fgtot       = false
                ttGarantie.cdtva       = ""
                ttGarantie.cdper       = ""
                ttGarantie.txrec       = 0
                ttGarantie.txnor       = 0
                ttGarantie.lbdiv       = (if ttbaremeGarantieLoyerCom.dMtCotisation > 0 then "MT@" else "TX@")
                ttGarantie.cddev       = ""
                ttGarantie.lbdiv2      = ""
                ttGarantie.lbdiv3      = ""
                ttGarantie.txcot-dev   = 0
                ttGarantie.tpmnt       = ""
                ttGarantie.mtcot       = ttbaremeGarantieLoyerCom.dMtCotisation
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

                ttGarantie.dtTimestamp = ttbaremeGarantieLoyerCom.dtTimestamp
                ttGarantie.CRUD        = ttGarantieLoyer.CRUD   // tous les barèmes doivent suivre le CRUD de l'entête
                ttGarantie.rRowid      = ttbaremeGarantieLoyerCom.rRowid
                .
        end.

        for each ttbaremeGarantieLoyerHab
           where ttbaremeGarantieLoyerHab.cTypeContrat   = ttGarantieLoyer.cTypeContrat
             and ttbaremeGarantieLoyerHab.iNumeroContrat = ttGarantieLoyer.iNumeroContrat:

            create ttGarantie.
            assign
                ttGarantie.tpctt       = ttbaremeGarantieLoyerHab.cTypeContrat
                ttGarantie.noctt       = viNumeroAssurance
                ttGarantie.tpbar       = ttbaremeGarantieLoyerHab.cTypeBareme
                ttGarantie.nobar       = ttbaremeGarantieLoyerHab.iNumeroBareme
                ttGarantie.txcot       = ttbaremeGarantieLoyerHab.dTauxCotisation
                ttGarantie.txhon       = ttbaremeGarantieLoyerHab.dTauxHonoraire
                ttGarantie.txres       = ttbaremeGarantieLoyerHab.dTauxResultat
                ttGarantie.fgtot       = false
                ttGarantie.cdtva       = ""
                ttGarantie.cdper       = ""
                ttGarantie.txrec       = 0
                ttGarantie.txnor       = 0
                ttGarantie.lbdiv       = (if ttbaremeGarantieLoyerHab.dMtCotisation > 0 then "MT@" else "TX@")
                ttGarantie.cddev       = ""
                ttGarantie.lbdiv2      = ""
                ttGarantie.lbdiv3      = ""
                ttGarantie.txcot-dev   = 0
                ttGarantie.tpmnt       = ""
                ttGarantie.mtcot       = ttbaremeGarantieLoyerHab.dMtCotisation
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

                ttGarantie.dtTimestamp = ttbaremeGarantieLoyerHab.dtTimestamp
                ttGarantie.CRUD        = ttGarantieLoyer.CRUD   // tous les barèmes doivent suivre le CRUD de l'entête
                ttGarantie.rRowid      = ttbaremeGarantieLoyerHab.rRowid
                .

        end.
    end.
    run parametre/cabinet/gerance/garan_CRUD.p persistent set vhGarantie.
    run getTokenInstance in vhGarantie(mToken:JSessionId).
    run setGarantie in vhGarantie (input-output table ttGarantie by-reference).
    if not mError:erreur()
    then run majGarantie_ModeComptabilisation in vhGarantie({&TYPECONTRAT-GarantieLoyer}, vcModeComptabilisation, viNumeroAssurance ).
    run destroy in vhGarantie.
end procedure.

procedure createTTGarantieLoyer:
    /*-----------------------------------------------------------------------------
    Purpose:
    Notes  :
    -----------------------------------------------------------------------------*/
    define parameter buffer garan for garan.
    define input parameter phoutilGarantieLoyer as handle no-undo.

    create ttGarantieLoyer.
    assign
        ttGarantieLoyer.cTypeContrat          = garan.tpctt
        ttGarantieLoyer.iNumeroContrat        = garan.noctt
        ttGarantieLoyer.cLibelleTypeContrat   = outilTraduction:getLibelleProg("O_CLC", garan.tpctt)
        ttGarantieLoyer.cModeComptabilisation = garan.lbdiv2
        ttGarantieLoyer.cCodeAssureur         = garan.lbdiv
        ttGarantieLoyer.cCodeTVA              = garan.cdtva
        ttGarantieLoyer.cCodeApplicationTVA   = string(garan.fgtot,substitute("&1/&2",{&TVABAREME-COTIS-ET-HONO},{&TVABAREME-HONORAIRE}))
        ttGarantieLoyer.cCodePeriodicite      = garan.cdper
        ttGarantieLoyer.dTauxRecuperable      = garan.txrec
        ttGarantieLoyer.dTauxNonRecuperable   = garan.txnor
        ttGarantieLoyer.cCodeCalculSelondate  = garan.CdDebCal
        ttGarantieLoyer.dNombreMoisCarence    = garan.nbmca
        ttGarantieLoyer.cModeSaisie           = string(garan.txhon)
        ttGarantieLoyer.dtTimestamp           = datetime(garan.dtmsy,garan.hemsy)
        ttGarantieLoyer.CRUD                  = "R"
        ttGarantieLoyer.rRowid                = rowid(garan)
        .
    run nomAdresseAssureur in phoutilGarantieLoyer(
        mtoken:cRefGerance,
        garan.tpctt,
        garan.noctt,
        garan.lbdiv,
        garan.cdass,
        output ttGarantieLoyer.cLibelleNumeroContrat,
        output ttGarantieLoyer.cLibelleAssureur
    ).

    ttGarantieLoyer.cLibelle2Comptabilisation = dynamic-function("libelleParamComptaAchatOuOd" in phoutilGarantieLoyer, ttGarantieLoyer.cModeComptabilisation, mtoken:cRefGerance).
    run chargeLibelle.
end procedure.

procedure initComboGarantieLoyer:
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
    voSyspr:getComboParametre("CPGAR","CMBTYPECOMPTABILISATION",output table ttCombo by-reference).
    // exclusion code "00002" - non développé */
    for first ttcombo
        where ttCombo.cNomCombo = "CMBTYPECOMPTABILISATION"
          and ttCombo.cCode     = "00002":
        delete ttcombo.
    end.
    // Périodicité
    voSyspr:getComboParametre("PDGAR","CMBPERIODICITE",output table ttCombo by-reference).

    // Calcul de la garantie loyer à partir d'une date
    voSyspr:getComboParametre("CDOUI","CMBCALCULSELONDATE",output table ttCombo by-reference).

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

    // garantie Loyer
    for each garan no-lock
       where garan.tpctt = {&TYPECONTRAT-GarantieLoyer}
         and garan.tpbar = "":

        create ttCombo.
        assign
            viNumeroItem             = viNumeroItem + 1
            ttCombo.iSeqId           = viNumeroItem
            ttCombo.cNomCombo        = "CMBGARANTIELOYER"
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
        ttGarantieLoyer.cLibelleTypeContrat      = outilTraduction:getLibelleProg("O_CLC",ttGarantieLoyer.cTypeContrat)
        ttGarantieLoyer.cLibelleComptabilisation = outilTraduction:getLibelleParam("CPGAR",ttGarantieLoyer.cModeComptabilisation)
        ttGarantieLoyer.cLibellePeriodicite      = outilTraduction:getLibelleParam("PDGAR",ttGarantieLoyer.cCodePeriodicite)
        ttGarantieLoyer.cLibelleCalculSelonDate  = outilTraduction:getLibelleParam("CDOUI",ttGarantieLoyer.cCodeCalculSelonDate)
        ttGarantieLoyer.cLibelleTVA              = outilTraduction:getLibelleParam("CDTVA",ttGarantieLoyer.cCodeTVA)
    .

    case ttGarantieLoyer.cCodeApplicationTVA:
        when {&TVABAREME-COTIS-ET-HONO} then ttGarantieLoyer.cLibelleApplicationTVA = outilTraduction:getLibelle(101560).
        when {&TVABAREME-HONORAIRE}     then ttGarantieLoyer.cLibelleApplicationTVA = outilTraduction:getLibelle(101561).
    end case.

    case ttGarantieLoyer.cModeSaisie:
        when {&MODESAISIEBAREME-TxCotis-et-TxHono}      then ttGarantieLoyer.cLibelleSaisie = outilTraduction:getLibelle(110051).
        when {&MODESAISIEBAREME-TxCotis-et-TxResultant} then ttGarantieLoyer.cLibelleSaisie = outilTraduction:getLibelle(110052).
    end case.
end procedure.
