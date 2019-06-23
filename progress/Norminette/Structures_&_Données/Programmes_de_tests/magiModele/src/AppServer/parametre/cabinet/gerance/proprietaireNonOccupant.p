/*-----------------------------------------------------------------------------
File        : proprietaireNonOccupant.p
Purpose     : Paramétrage Proprietaire Non Occupant (PNO) - 01018
Author(s)   : RF - 2017/11/10
Notes       :
derniere revue: 2018/05/04 - phm: OK
-----------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/type2bareme.i}
{preprocesseur/listeRubQuit2TVA.i}
{preprocesseur/periode2garantie.i}
{preprocesseur/mode2saisie.i}
{preprocesseur/prorata2garantie.i}

using parametre.pclie.pclie.
using parametre.syspg.syspg.
using parametre.syspr.syspr.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{compta/include/tva.i}
{parametre/cabinet/gerance/include/garantie.i}
{parametre/cabinet/gerance/include/proprietaireNonOccupant.i}
{parametre/cabinet/gerance/include/baremeGarantieLoyer.i &nomTable=ttbaremePNOCom &serialName=ttbaremePNOCom}
{parametre/cabinet/gerance/include/baremeGarantieLoyer.i &nomTable=ttbaremePNOHab &serialName=ttbaremePNOHab}
{application/include/combo.i}
{application/include/error.i}

procedure getProprietaireNonOccupantByRowid:
    /*-----------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beAssuranceGarantie.cls
    -----------------------------------------------------------------------------*/
    define input  parameter prRowId as rowid no-undo.
    define output parameter table for ttProprietaireNonOccupant.
    define output parameter table for ttbaremePNOCom.
    define output parameter table for ttbaremePNOHab.

    define variable vhoutilGarantieLoyer as handle no-undo.
    define variable vhttBaremeCommercial as handle no-undo.
    define variable vhttBaremeHabitation as handle no-undo.
    define buffer garan for garan.

    assign
        vhttBaremeCommercial = temp-table ttbaremePNOCom:default-buffer-handle
        vhttBaremeHabitation = temp-table ttbaremePNOHab:default-buffer-handle
    .
    for first garan no-lock
        where rowid(garan) = prRowid:
        run createTTProprietaireNonOccupant(buffer garan).
        run parametre/cabinet/gerance/outilGarantieLoyer.p persistent set vhoutilGarantieLoyer.
        run getTokenInstance in vhoutilGarantieLoyer(mToken:JSessionId).
        run loadBaremeGarantie in vhoutilGarantieLoyer(garan.tpctt, garan.noctt, {&TYPEBAREME-Commercial}, vhttBaremeCommercial).
        run loadBaremeGarantie in vhoutilGarantieLoyer(garan.tpctt, garan.noctt, {&TYPEBAREME-Habitation}, vhttBaremeHabitation).
    end.
    run destroy in vhoutilGarantieLoyer.
end procedure.

procedure getProprietaireNonOccupant:
    /*-----------------------------------------------------------------------------
    Purpose: Lecture des informations entête + listes barèmes HAB/COMM pour 1 garantie ou toutes
    Notes  :  service utilisé par beAssuranceGarantie.cls
    -----------------------------------------------------------------------------*/
    define input  parameter piNumeroAssurance as integer   no-undo.
    define output parameter table for ttProprietaireNonOccupant.
    define output parameter table for ttbaremePNOCom.
    define output parameter table for ttbaremePNOHab.

    define variable vhoutilGarantieLoyer as handle no-undo.
    define variable vhttBaremeCommercial as handle no-undo.
    define variable vhttBaremeHabitation as handle no-undo.
    define buffer garan for garan.

    assign
        vhttBaremeCommercial = temp-table ttbaremePNOCom:default-buffer-handle
        vhttBaremeHabitation = temp-table ttbaremePNOHab:default-buffer-handle
    .
    run parametre/cabinet/gerance/outilGarantieLoyer.p persistent set vhoutilGarantieLoyer.
    run getTokenInstance in vhoutilGarantieLoyer(mToken:JSessionId).
    for each garan no-lock
        where garan.tpctt = {&TYPECONTRAT-ProprietaireNonOccupant}
          and garan.noctt = (if piNumeroAssurance > 0 then piNumeroAssurance else garan.noctt)
          and garan.tpbar = "":
        run createTTProprietaireNonOccupant(buffer garan, vhoutilGarantieLoyer).
        run loadBaremeGarantie in vhoutilGarantieLoyer(garan.tpctt,garan.noctt,{&TYPEBAREME-Commercial}, vhttBaremeCommercial).
        run loadBaremeGarantie in vhoutilGarantieLoyer(garan.tpctt,garan.noctt,{&TYPEBAREME-Habitation}, vhttBaremeHabitation).
    end.
    run destroy in vhoutilGarantieLoyer.
end procedure.

procedure setProprietaireNonOccupant:
    /*-----------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beAssuranceGarantie.cls
    -----------------------------------------------------------------------------*/
    define input parameter table for ttProprietaireNonOccupant.
    define input parameter table for ttbaremePNOCom.
    define input parameter table for ttbaremePNOHab.
    define input parameter table for ttError.
    run controlesAvantValidation.
    if not mError:erreur() then run miseAJourGarantie.
end procedure.

procedure initProprietaireNonOccupant:
    /*-----------------------------------------------------------------------------
    Purpose: Initialisation pour création d'une nouvelle assurance PNO
    Notes  : service utilisé par beAssuranceGarantie.cls
    -----------------------------------------------------------------------------*/
    define output parameter table for ttProprietaireNonOccupant.
    define output parameter table for ttbaremePNOCom.
    define output parameter table for ttbaremePNOHab.

    define variable viCompteur           as integer no-undo.
    define variable vhoutilGarantieLoyer as handle  no-undo.
    define buffer garan for garan.

    run parametre/cabinet/gerance/outilGarantieLoyer.p persistent set vhoutilGarantieLoyer.
    run getTokenInstance in vhoutilGarantieLoyer(mToken:JSessionId).
    create ttProprietaireNonOccupant.
    assign
        ttProprietaireNonOccupant.cTypeContrat              = {&TYPECONTRAT-ProprietaireNonOccupant}
        ttProprietaireNonOccupant.iNumeroContrat            = 0
        ttProprietaireNonOccupant.cLibelleTypeContrat       = outilTraduction:getLibelleProg("O_CLC", ttProprietaireNonOccupant.cTypeContrat)
        ttProprietaireNonOccupant.cModeComptabilisation     = "00000"  // dépend des garanties existantes
        ttProprietaireNonOccupant.cCodeAssureur             = ""
        ttProprietaireNonOccupant.cCodeTVA                  = {&codeTVA-00000}
        ttProprietaireNonOccupant.cCodeApplicationTVA       = {&TVABAREME-COTIS-ET-HONO}
        ttProprietaireNonOccupant.cCodePeriodicite          = {&PERIODEGARANTIE-mensuel}
        ttProprietaireNonOccupant.cCodeCivilDecale          = {&ANNIVERSAIREGARANTIE-civil}
        ttProprietaireNonOccupant.cCodeSaisieHonoraire      = {&MODESAISIEHONOBAREME-Taux}
        ttProprietaireNonOccupant.cCodePeriodiciteBordereau = {&PERIODEBORDEREAU-mensuel}
        ttProprietaireNonOccupant.cNumeroContratGlobal      = ""
        ttProprietaireNonOccupant.daDebutContratGlobal      = ?
        ttProprietaireNonOccupant.daFinContratGlobal        = ?
        ttProprietaireNonOccupant.cModeProrataCommercial    = {&PRORATAPNO-aucun}
        ttProprietaireNonOccupant.cModeProrataHabitation    = {&PRORATAPNO-aucun}
        ttProprietaireNonOccupant.dtTimestamp               = ?
        ttProprietaireNonOccupant.CRUD                      = ""
    .
    // Type de comptabilisation par défaut -> hérité du premier enregistrement garan
    for first garan no-lock
        where garan.tpctt = {&TYPECONTRAT-ProprietaireNonOccupant}:
        ttProprietaireNonOccupant.cModeComptabilisation = garan.lbdiv2.
    end.
    ttProprietaireNonOccupant.cLibelle2Comptabilisation = dynamic-function("libelleParamComptaAchatOuOd" in vhoutilGarantieLoyer, ttProprietaireNonOccupant.cModeComptabilisation, mtoken:cRefGerance).
    run chargeLibelle.
    do viCompteur = 1 to 10:
        create ttbaremePNOCom.
        assign
            ttbaremePNOCom.cTypeContrat    = {&TYPECONTRAT-ProprietaireNonOccupant}
            ttbaremePNOCom.iNumeroContrat  = 0
            ttbaremePNOCom.cTypeBareme     = {&TYPEBAREME-Commercial}
            ttbaremePNOCom.iNumeroBareme   = viCompteur
            ttbaremePNOCom.dMtCotisation   = 0
            ttbaremePNOCom.dTauxCotisation = 0
            ttbaremePNOCom.dTauxHonoraire  = 0
            ttbaremePNOCom.dTauxResultat   = 0
        .
        create ttbaremePNOHab.
        assign
            ttbaremePNOHab.cTypeContrat    = {&TYPECONTRAT-ProprietaireNonOccupant}
            ttbaremePNOHab.iNumeroContrat  = 0
            ttbaremePNOHab.cTypeBareme     = {&TYPEBAREME-Habitation}
            ttbaremePNOHab.iNumeroBareme   = viCompteur
            ttbaremePNOHab.dMtCotisation   = 0
            ttbaremePNOHab.dTauxCotisation = 0
            ttbaremePNOHab.dTauxHonoraire  = 0
            ttbaremePNOHab.dTauxResultat   = 0
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
        vhttBaremeCommercial = temp-table ttbaremePNOCom:default-buffer-handle
        vhttBaremeHabitation = temp-table ttbaremePNOHab:default-buffer-handle
        vcQueryCommercial    = "for each ttbaremePNOCom no-lock"
        vcQueryHabitation    = "for each ttbaremePNOHab no-lock"
    .
bouclePNO:
    for each ttProprietaireNonOccupant
        where lookup(ttProprietaireNonOccupant.CRUD, "C,U,D") > 0:
        if ttProprietaireNonOccupant.cTypeContrat <> {&TYPECONTRAT-ProprietaireNonOccupant} then do:
            mError:createError({&error}, 1000688).
            leave bouclePNO.
        end.
        else if (lookup(ttProprietaireNonOccupant.CRUD, "U,D") > 0
        and not dynamic-function("testGarantieExiste" in vhoutilGarantieLoyer,
            ttProprietaireNonOccupant.cTypeContrat,
            ttProprietaireNonOccupant.iNumeroContrat,
            ttProprietaireNonOccupant.CRUD
        ))
        or not dynamic-function("testAssureurAutorise" in vhoutilGarantieLoyer,
            ttProprietaireNonOccupant.cTypeContrat,
            ttProprietaireNonOccupant.iNumeroContrat,
            ttProprietaireNonOccupant.cCodeAssureur,
            ttProprietaireNonOccupant.CRUD)
        or (ttProprietaireNonOccupant.CRUD = "D"         // Suppression interdite si un bail rattaché à cette garantie
        and dynamic-function("testGarantieUtilisee" in vhoutilGarantieLoyer,
            ttProprietaireNonOccupant.cTypeContrat,
            ttProprietaireNonOccupant.iNumeroContrat,
            ttProprietaireNonOccupant.CRUD
        ))
        or (ttProprietaireNonOccupant.CRUD = "U"
        and not dynamic-function("testModifPeriodicite" in vhoutilGarantieLoyer,
            ttProprietaireNonOccupant.cTypeContrat,
            ttProprietaireNonOccupant.iNumeroContrat,
            ttProprietaireNonOccupant.cCodePeriodicite
        ))
        or (lookup(ttProprietaireNonOccupant.CRUD, "C,U") > 0    // Contrôles des baremes
        and not dynamic-function("testBareme" in vhoutilGarantieLoyer,
            ttProprietaireNonOccupant.cCodeTVA,
            vcQueryCommercial,
            vcQueryHabitation,
            vhttBaremeCommercial,
            vhttBaremeHabitation
        ))
        then leave bouclePNO.
        // spécifique PNO: prorata 1ère échéance de la garantie par type de bail
        else if lookup(ttProprietaireNonOccupant.CRUD, "C,U") > 0
        and can-find(first ttbaremePNOCom where ttbaremePNOCom.dTauxResultat > 0)
        and ttProprietaireNonOccupant.cModeProrataCommercial = {&PRORATAPNO-aucun}
        then do:
            mError:createErrorGestion({&error}, 111566, outilTraduction:getLibelle(111567)).
            leave bouclePNO.
        end.
        else if lookup(ttProprietaireNonOccupant.CRUD, "C,U") > 0
        and can-find(first ttbaremePNOHab where ttbaremePNOHab.dTauxResultat > 0) and ttProprietaireNonOccupant.cModeProrataHabitation = {&PRORATAPNO-aucun}
        then do:
            mError:createErrorGestion({&error}, 111566, outilTraduction:getLibelle(111568)).
            leave bouclePNO.
        end.
        else if lookup(ttProprietaireNonOccupant.CRUD, "C,U") > 0
        and not dynamic-function("testModeComptabilisationQuestion" in vhoutilGarantieLoyer
                                , ttProprietaireNonOccupant.cTypeContrat
                                , ttProprietaireNonOccupant.cModeComptabilisation
                                , table ttError by-reference)
        then leave bouclePNO.
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
    for first ttProprietaireNonOccupant:
        if ttProprietaireNonOccupant.CRUD = "C" then do:
            viNumeroAssurance = 1.
            {&_proparse_ prolint-nowarn(use-index)}
            for last garan no-lock
                where garan.tpctt =  ttProprietaireNonOccupant.cTypeContrat
                use-index ix_garan01:
                viNumeroAssurance = garan.noctt + 1.
            end.
        end.
        else viNumeroAssurance = ttProprietaireNonOccupant.iNumeroContrat.
        create ttGarantie.
        assign
            vcModeComptabilisation = ttProprietaireNonOccupant.cModeComptabilisation
            ttGarantie.tpctt       = ttProprietaireNonOccupant.cTypeContrat
            ttGarantie.noctt       = viNumeroAssurance
            ttGarantie.tpbar       = ""
            ttGarantie.nobar       = 0
            ttGarantie.txcot       = 0
            ttGarantie.txhon       = 0
            ttGarantie.txres       = 0
            ttGarantie.fgtot       = ttProprietaireNonOccupant.cCodeApplicationTVA = {&TVABAREME-COTIS-ET-HONO}
            ttGarantie.cdtva       = ttProprietaireNonOccupant.cCodeTVA
            ttGarantie.cdper       = ttProprietaireNonOccupant.cCodePeriodicite
            ttGarantie.txrec       = 0
            ttGarantie.txnor       = 0
            ttGarantie.lbdiv       = ttProprietaireNonOccupant.cCodeAssureur
            ttGarantie.cddev       = ""
            ttGarantie.lbdiv2      = ttProprietaireNonOccupant.cModeComptabilisation
            ttGarantie.txcot-dev   = 0
            ttGarantie.tpmnt       = ""
            ttGarantie.mtcot       = 0
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
            ttGarantie.lbdiv3      = substitute("&1@&2@&3@@",
                                                ttProprietaireNonOccupant.cCodeCivilDecale,
                                                ttProprietaireNonOccupant.cCodeSaisieHonoraire,
                                                ttProprietaireNonOccupant.cNumeroContratGlobal)
            ttGarantie.cdperbord   = ttProprietaireNonOccupant.cCodePeriodiciteBordereau
            ttGarantie.dtTimestamp = ttProprietaireNonOccupant.dtTimestamp
            ttGarantie.CRUD        = ttProprietaireNonOccupant.CRUD
            ttGarantie.rRowid      = ttProprietaireNonOccupant.rRowid
        .
        if ttProprietaireNonOccupant.daDebutContratGlobal <> ?
        then entry(4, ttGarantie.LbDiv3, "@") = string(ttProprietaireNonOccupant.daDebutContratGlobal, "99/99/9999").
        if ttProprietaireNonOccupant.daFinContratGlobal <> ?
        then entry(5, ttGarantie.LbDiv3, "@") = string(ttProprietaireNonOccupant.daFinContratGlobal, "99/99/9999").
        create ttGarantie. /* Bareme "00001" - 0 */
        assign
            ttGarantie.tpctt = {&TYPECONTRAT-ProprietaireNonOccupant}
            ttGarantie.noctt = viNumeroAssurance
            ttGarantie.tpbar = {&TYPEBAREME-Commercial}
            ttGarantie.nobar = 0
            ttGarantie.cdper = ttProprietaireNonOccupant.cModeProrataCommercial
        .
        create ttGarantie. /* Bareme "00002" - 0 */
        assign
            ttGarantie.tpctt = {&TYPECONTRAT-ProprietaireNonOccupant}
            ttGarantie.noctt = viNumeroAssurance
            ttGarantie.tpbar = {&TYPEBAREME-Habitation}
            ttGarantie.nobar = 0
            ttGarantie.cdper = ttProprietaireNonOccupant.cModeProrataHabitation
        .
        for each ttbaremePNOCom
            where ttbaremePNOCom.cTypeContrat   = ttProprietaireNonOccupant.cTypeContrat
              and ttbaremePNOCom.iNumeroContrat = ttProprietaireNonOccupant.iNumeroContrat:
            create ttGarantie.
            assign
                ttGarantie.tpctt       = ttbaremePNOCom.cTypeContrat
                ttGarantie.noctt       = viNumeroAssurance
                ttGarantie.tpbar       = ttbaremePNOCom.cTypeBareme
                ttGarantie.nobar       = ttbaremePNOCom.iNumeroBareme
                ttGarantie.mtcot       = ttbaremePNOCom.dMtCotisation
                ttGarantie.txcot       = ttbaremePNOCom.dMtCotisation
                ttGarantie.txhon       = ttbaremePNOCom.dTauxHonoraire
                ttGarantie.txres       = ttbaremePNOCom.dTauxResultat
                ttGarantie.fgtot       = false
                ttGarantie.cdtva       = ""
                ttGarantie.cdper       = ""
                ttGarantie.txrec       = 0
                ttGarantie.txnor       = 0
                ttGarantie.lbdiv       = "MT@"
                ttGarantie.cddev       = ""
                ttGarantie.lbdiv2      = ""
                ttGarantie.lbdiv3      = ""
                ttGarantie.txcot-dev   = 0
                ttGarantie.tpmnt       = ""
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
                ttGarantie.dtTimestamp = ttbaremePNOCom.dtTimestamp  // ttProprietaireNonOccupant - ce n'est pas une erreur
                ttGarantie.CRUD        = ttProprietaireNonOccupant.CRUD   // tous les barèmes doivent suivre le CRUD de l'entête
                ttGarantie.rRowid      = ttbaremePNOCom.rRowid
            .
        end.
        for each ttbaremePNOHab
           where ttbaremePNOHab.cTypeContrat   = ttProprietaireNonOccupant.cTypeContrat
             and ttbaremePNOHab.iNumeroContrat = ttProprietaireNonOccupant.iNumeroContrat:
            create ttGarantie.
            assign
                ttGarantie.tpctt       = ttbaremePNOHab.cTypeContrat
                ttGarantie.noctt       = viNumeroAssurance
                ttGarantie.tpbar       = ttbaremePNOHab.cTypeBareme
                ttGarantie.nobar       = ttbaremePNOHab.iNumeroBareme
                ttGarantie.mtcot       = ttbaremePNOHab.dMtCotisation
                ttGarantie.txcot       = ttbaremePNOHab.dMtCotisation
                ttGarantie.txhon       = ttbaremePNOHab.dTauxHonoraire
                ttGarantie.txres       = ttbaremePNOHab.dTauxResultat
                ttGarantie.fgtot       = false
                ttGarantie.cdtva       = ""
                ttGarantie.cdper       = ""
                ttGarantie.txrec       = 0
                ttGarantie.txnor       = 0
                ttGarantie.lbdiv       = "MT@"
                ttGarantie.cddev       = ""
                ttGarantie.lbdiv2      = ""
                ttGarantie.lbdiv3      = ""
                ttGarantie.txcot-dev   = 0
                ttGarantie.tpmnt       = ""
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
                ttGarantie.dtTimestamp = ttbaremePNOHab.dtTimestamp
                ttGarantie.CRUD        = ttProprietaireNonOccupant.CRUD   // tous les barèmes doivent suivre le CRUD de l'entête
                ttGarantie.rRowid      = ttbaremePNOHab.rRowid
            .
        end.
    end.
    run parametre/cabinet/gerance/garan_CRUD.p persistent set vhGarantie.
    run getTokenInstance in vhGarantie(mToken:JSessionId).
    run setGarantie in vhGarantie(input-output table ttGarantie by-reference).
    if not mError:erreur()
    then run majGarantie_ModeComptabilisation in vhGarantie({&TYPECONTRAT-ProprietaireNonOccupant}, vcModeComptabilisation, viNumeroAssurance ).
    run destroy in vhGarantie.
end procedure.

procedure createTTProprietaireNonOccupant private:
    /*-----------------------------------------------------------------------------
    Purpose:
    Notes  :
    -----------------------------------------------------------------------------*/
    define parameter buffer garan for garan.
    define input parameter phoutilGarantieLoyer as handle no-undo.

    define buffer vbgaran for garan.

    create ttProprietaireNonOccupant.
    assign
        ttProprietaireNonOccupant.cTypeContrat              = garan.tpctt
        ttProprietaireNonOccupant.iNumeroContrat            = garan.noctt
        ttProprietaireNonOccupant.cLibelleTypeContrat       = outilTraduction:getLibelleProg("O_CLC", garan.tpctt)
        ttProprietaireNonOccupant.cModeComptabilisation     = garan.lbdiv2
        ttProprietaireNonOccupant.cCodeAssureur             = garan.lbdiv
        ttProprietaireNonOccupant.cCodeTVA                  = garan.cdtva
        ttProprietaireNonOccupant.cCodeApplicationTVA       = string(garan.fgtot, substitute("&1/&2", {&TVABAREME-COTIS-ET-HONO}, {&TVABAREME-HONORAIRE}))
        ttProprietaireNonOccupant.cCodePeriodicite          = garan.cdper
        ttProprietaireNonOccupant.cCodeCivilDecale          = entry(1, garan.LbDiv3, "@")
        ttProprietaireNonOccupant.cCodeSaisieHonoraire      = if num-entries(garan.LbDiv3, "@") >= 2 then entry(2, garan.LbDiv3, "@") else "00000"
        ttProprietaireNonOccupant.cCodePeriodiciteBordereau = garan.cdperbord
        ttProprietaireNonOccupant.cNumeroContratGlobal      = if num-entries(garan.LbDiv3, "@") >= 3 then entry(3, garan.LbDiv3, "@") else ""
        ttProprietaireNonOccupant.daDebutContratGlobal      = if num-entries(garan.LbDiv3, "@") >= 4 then date(entry(4, garan.LbDiv3, "@")) else ?
        ttProprietaireNonOccupant.daFinContratGlobal        = if num-entries(garan.LbDiv3, "@") >= 5 then date(entry(5, garan.LbDiv3, "@")) else ?
        ttProprietaireNonOccupant.cModeProrataCommercial    = {&PRORATAPNO-aucun}
        ttProprietaireNonOccupant.cModeProrataHabitation    = {&PRORATAPNO-aucun}
        ttProprietaireNonOccupant.dtTimestamp               = datetime(garan.dtmsy, garan.hemsy)
        ttProprietaireNonOccupant.CRUD                      = "R"
        ttProprietaireNonOccupant.rRowid                    = rowid(garan)
    .
    for first vbgaran no-lock
        where vbgaran.tpctt = garan.tpctt
          and vbgaran.noctt = garan.noctt
          and vbgaran.tpbar = {&TYPEBAREME-Commercial}
          and vbgaran.nobar = 0:
        ttProprietaireNonOccupant.cModeProrataCommercial = vbgaran.cdper.
    end.
    for first vbgaran no-lock
        where vbgaran.tpctt = garan.tpctt
          and vbgaran.noctt = garan.noctt
          and vbgaran.tpbar = {&TYPEBAREME-Habitation}
          and vbgaran.nobar = 0:
        ttProprietaireNonOccupant.cModeProrataHabitation = vbgaran.cdper.
    end.
    run nomAdresseAssureur in phoutilGarantieLoyer(
        mtoken:cRefGerance,
        garan.tpctt,
        garan.noctt,
        garan.lbdiv,
        garan.cdass,
        output ttProprietaireNonOccupant.cLibelleNumeroContrat,
        output ttProprietaireNonOccupant.cLibelleAssureur
    ).
    ttProprietaireNonOccupant.cLibelle2Comptabilisation = dynamic-function("libelleParamComptaAchatOuOd" in phoutilGarantieLoyer, ttProprietaireNonOccupant.cModeComptabilisation, mtoken:cRefGerance).
    run chargeLibelle.

end procedure.

procedure initComboProprietaireNonOccupant:
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
    voSyspr:getComboParametre("CPGAR", "CMBTYPECOMPTABILISATION", output table ttCombo by-reference).
    // exclusion code "00002" - non développé */
    for first ttcombo
        where ttCombo.cNomCombo = "CMBTYPECOMPTABILISATION"
          and ttCombo.cCode     = "00002":
        delete ttcombo.
    end.
    voSyspr:getComboParametre("PDPNO", "CMBPERIODICITE", output table ttCombo by-reference).
    voSyspr:getComboParametre("PDPNO", "CMBPERIODICITEBO", output table ttCombo by-reference).
    voSyspr:getComboParametre("PRPNO", "CMBPRORATACOMMERCIAL", output table ttCombo by-reference).
    voSyspr:getComboParametre("PRPNO", "CMBPRORATAHABITATION", output table ttCombo by-reference).
    delete object voSyspr.
    create ttCombo.
    assign
        ttCombo.iSeqId    = 1
        ttCombo.cNomCombo = "CMBCIVILEDECALE"
        ttCombo.cCode     = {&ANNIVERSAIREGARANTIE-civil}
        ttCombo.cLibelle  = outilTraduction:getLibelle(111410)
    .
    create ttCombo.
    assign
        ttCombo.iSeqId    = 2
        ttCombo.cNomCombo = "CMBCIVILEDECALE"
        ttCombo.cCode     = {&ANNIVERSAIREGARANTIE-DebutContrat}
        ttCombo.cLibelle  = outilTraduction:getLibelle(111411)
    .
    create ttCombo.
    assign
        ttCombo.iSeqId    = 1
        ttCombo.cNomCombo = "CMBAPPLICATIONTVA"
        ttCombo.cCode     = {&TVABAREME-COTIS-ET-HONO}           // "1"
        ttCombo.cLibelle  = outilTraduction:getLibelle(101560)   // Cotisation et Honoraires
    .
    create ttCombo.
    assign
        ttCombo.iSeqId           = 2
        ttCombo.cNomCombo        = "CMBAPPLICATIONTVA"
        ttCombo.cCode            = {&TVABAREME-HONORAIRE}               // "2"
        ttCombo.cLibelle         = outilTraduction:getLibelle(101561)   // Honoraires uniquement
    .
    create ttCombo.
    assign
        ttCombo.iSeqId    = 1
        ttCombo.cNomCombo = "CMBSAISIEHONORAIRES"
        ttCombo.cCode     = {&MODESAISIEHONOBAREME-Taux}
        ttCombo.cLibelle  = outilTraduction:getLibelle(101922)
    .
    create ttCombo.
    assign
        ttCombo.iSeqId    = 2
        ttCombo.cNomCombo = "CMBSAISIEHONORAIRES"
        ttCombo.cCode     = {&MODESAISIEHONOBAREME-Montant}
        ttCombo.cLibelle  = outilTraduction:getLibelle(100094)
    .
    // propriétaire non occupant
    for each garan no-lock
        where garan.tpctt = {&TYPECONTRAT-ProprietaireNonOccupant}
          and garan.tpbar = "":
        create ttCombo.
        assign
            viNumeroItem      = viNumeroItem + 1
            ttCombo.iSeqId    = viNumeroItem
            ttCombo.cNomCombo = "CMBPROPRIETAIRENONOCCUPANT"
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
        ttProprietaireNonOccupant.cLibelleComptabilisation     = outilTraduction:getLibelleParam("CPGAR", ttProprietaireNonOccupant.cModeComptabilisation)
        ttProprietaireNonOccupant.cLibellePeriodicite          = outilTraduction:getLibelleParam("PDPNO", ttProprietaireNonOccupant.cCodePeriodicite)
        ttProprietaireNonOccupant.cLibellePeriodiciteBordereau = outilTraduction:getLibelleParam("PDPNO", ttProprietaireNonOccupant.cCodePeriodiciteBordereau)
        ttProprietaireNonOccupant.cLibelleProrataCommercial    = outilTraduction:getLibelleParam("PRPNO", ttProprietaireNonOccupant.cModeProrataCommercial)
        ttProprietaireNonOccupant.cLibelleProrataHabitation    = outilTraduction:getLibelleParam("PRPNO", ttProprietaireNonOccupant.cModeProrataHabitation)
        ttProprietaireNonOccupant.cLibelleTVA                  = outilTraduction:getLibelleParam("CDTVA", ttProprietaireNonOccupant.cCodeTVA)
    .
    case ttProprietaireNonOccupant.cCodeCivilDecale:
        when {&ANNIVERSAIREGARANTIE-civil}        then ttProprietaireNonOccupant.cLibelleCivilDecale = outilTraduction:getLibelle(111410).  // 00010
        when {&ANNIVERSAIREGARANTIE-DebutContrat} then ttProprietaireNonOccupant.cLibelleCivilDecale = outilTraduction:getLibelle(111411).  // 00099
    end case.
    case ttProprietaireNonOccupant.cCodeApplicationTVA:
        when {&TVABAREME-COTIS-ET-HONO} then ttProprietaireNonOccupant.cLibelleApplicationTVA = outilTraduction:getLibelle(101560).
        when {&TVABAREME-HONORAIRE}     then ttProprietaireNonOccupant.cLibelleApplicationTVA = outilTraduction:getLibelle(101561).
    end case.
    case ttProprietaireNonOccupant.cCodeSaisieHonoraire:
        when {&MODESAISIEHONOBAREME-Taux}    then ttProprietaireNonOccupant.cLibelleSaisieHonoraire = outilTraduction:getLibelle(101922).
        when {&MODESAISIEHONOBAREME-Montant} then ttProprietaireNonOccupant.cLibelleSaisieHonoraire = outilTraduction:getLibelle(100094).
    end case.
end procedure.
