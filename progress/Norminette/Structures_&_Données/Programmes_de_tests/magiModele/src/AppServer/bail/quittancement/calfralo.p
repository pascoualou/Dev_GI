/*-----------------------------------------------------------------------------
File        : calfralo.p
Purpose     : calcul des Franchises Loyer
Author(s)   : AF - 1999/06/04, Kantena - 2017/12/21
Notes       : reprise de adb/src/quit/calfralo.p
derniere revue: 2018/09/13 - phm: OK

01 23/06/1999  AF    Forcer le signe en negatif
02 06/08/1999  AF    Permettre une franchise egale au loyer et avertir si modification de la franchise
03 29/10/1999  AF    incrementation correct sur ttQtt.dMontantQuittance & ttQtt.iNombreRubrique
04 10/02/2000  AF    Fiche 4147: mauvais find sur ttQtt
05 25/04/2000  AF    dev199: franchise proratée
06 06/07/2001  ALF   Fiche 0601/1108: Modif EURO
07 30/09/2004  AF    0904/0337: Ne plus faire une franchise au jour mais ramener le montant de la franchise total à un pourcentage du loyer encours
08 17/08/2007  SY    0807/0052: correction calcul total de loyer pour la période de franchise:
                     ajout recherche dans aquit si franchise sur plusieurs quitt et quitt début période historisé
09 05/03/2010  SY    Gestion franchise sur plusieurs années (5 ans max) en prévision des fiches 1209/0168 et 1009/0179
10 17/03/2010  SY    1209/0168 Adaptations pour pré-bail & PEC Globale
11 10/10/2012  NP    1009/0179 Franchise sur plus d'une année
12 28/11/2017  SY    #9211 ajout NO-UNDO TEMP-TABLE ttEquit
-----------------------------------------------------------------------------*/
{preprocesseur/type2tache.i}
{preprocesseur/param2locataire.i}
{preprocesseur/referenceClient.i}

using parametre.pclie.parametrageRubriqueFranchise.
{oerealm/include/instanciateTokenOnModel.i}  // Doit être positionnée juste après using

{bail/include/tbtmpqtt.i}
{bail/include/tbtmprub.i}
{crud/include/equit.i}

{outils/include/lancementProgramme.i}        // fonctions lancementPgm, suppressionPgmPersistent

define variable goCollectionHandlePgm as class collection                   no-undo.
define variable goRubriqueFranchise   as class parametrageRubriqueFranchise no-undo.
define variable gcTypeBail            as character no-undo.
define variable giNumeroBail          as int64     no-undo.
define variable giNumeroQuittance     as integer   no-undo.
define variable gdaDebutPeriode       as date      no-undo.
define variable gdaFinPeriode         as date      no-undo.
define variable gdaDebutQuittancement as date      no-undo.
define variable gdaFinQuittancement   as date      no-undo.
define variable ghProcDate            as handle    no-undo.

function maxDate returns date(pda1 as date, pda2 as date):
    /*-------------------------------------------------------------------------
    Purpose : maximum de deux dates
    Notes   : problème d'une date ? (maximum(?, d1) --> ?)
    -------------------------------------------------------------------------*/
    if pda2 >= pda1 then return pda2.
    if pda1 >= pda2 then return pda1.
    return if pda1 = ? then pda2 else pda1.
end function.

procedure lancementCalfralo:
    /*------------------------------------------------------------------------
    Purpose :
    Notes   : service externe
    ------------------------------------------------------------------------*/
    define input parameter poCollectionContrat   as class collection no-undo.
    define input parameter poCollectionQuittance as class collection no-undo.
    define input-output parameter table for ttQtt.
    define input-output parameter table for ttRub.

    assign
        gcTypeBail            = poCollectionContrat:getCharacter("cTypeContrat")
        giNumeroBail          = poCollectionContrat:getInt64("iNumeroContrat")
        giNumeroQuittance     = poCollectionQuittance:getInteger("iNumeroQuittance")
        gdaDebutPeriode       = poCollectionQuittance:getDate("daDebutPeriode")
        gdaFinPeriode         = poCollectionQuittance:getDate("daFinPeriode")
        gdaDebutQuittancement = poCollectionQuittance:getDate("daDebutQuittancement")
        gdaFinQuittancement   = poCollectionQuittance:getDate("daFinQuittancement")
        goCollectionHandlePgm = new collection()
        goRubriqueFranchise   = new parametrageRubriqueFranchise()
    .

message "lancementCalfralo " gcTypeBail "/" giNumeroBail "/" giNumeroQuittance "/" gdaDebutPeriode "/" gdaFinPeriode "/" gdaDebutQuittancement "/"
                             gdaFinQuittancement.

    ghProcDate = lancementPgm("application/l_prgdat.p", goCollectionHandlePgm).
    run calfraloPrivate.
    delete object goRubriqueFranchise.
    suppressionPgmPersistent(goCollectionHandlePgm).

end procedure.

procedure calfraloPrivate private:
    /*-------------------------------------------------------------------------
    Purpose :
    Notes   :
    -------------------------------------------------------------------------*/
    define variable vdaDebutEncours     as date      no-undo.
    define variable vdaFinEncours       as date      no-undo.
    define variable vdeLoyerTotal       as decimal   no-undo.
    define variable vdeLoyer            as decimal   no-undo.
    define variable vdeLoyerEncours     as decimal   no-undo.
    define variable vdaDebutProrata     as date      no-undo.
    define variable vdaFinProrata       as date      no-undo.
    define variable vdaFinFranchise     as date      no-undo.
    define variable vdaFinQuittancement as date      no-undo.
    define variable viNombreMoisPeriode as integer   no-undo.
    define variable vcCodePeriode       as character no-undo.
    define variable vcCodeTerme         as character no-undo.
    define variable viDerniereQuittance as integer   no-undo.
    define variable vdeFranchiseTotal   as decimal   no-undo.
    define variable vdeFranchise        as decimal   no-undo.
    define variable vcItemRubrique      as character no-undo.
    define variable viItemRubrique      as integer   no-undo.
    define variable vcListeRubrique     as character no-undo.    /* NP 1009/0179 */
    define variable viCompteur          as integer   no-undo.
    define buffer tache for tache.
    define buffer rubqt for rubqt.
    define buffer aquit for aquit.
    define buffer equit for equit.

    empty temp-table ttEquit.
    /*--> Recherche des rubriques Loyer paramétrées pour le calcul de la franchise 1009/0179 **/
    vcListeRubrique = goRubriqueFranchise:getRubriquesFranchise().
    /*--> Suppression de rubriques */
    find first ttQtt
        where ttQtt.iNumeroLocataire = giNumeroBail
          and ttQtt.iNoQuittance = giNumeroQuittance no-error.
    find first rubqt no-lock
        where rubqt.cdrub = 104
          and rubqt.cdlib = 1 no-error.
    if available rubqt
    then for each ttRub
        where ttRub.iNumeroLocataire = giNumeroBail
          and ttRub.iNoQuittance = giNumeroQuittance
          and ttRub.iFamille = rubqt.cdfam
          and ttRub.iSousFamille = rubqt.cdsfa
          and ttRub.iNorubrique = 104:
        if available ttQtt then assign
            ttQtt.dMontantQuittance = ttQtt.dMontantQuittance - ttRub.dMontantTotal
            ttQtt.iNombreRubrique = ttQtt.iNombreRubrique - 1
        .
        delete ttRub.
    end.
    /* Recuperation du montant du loyer */
    for each ttRub
        where ttRub.iNumeroLocataire = giNumeroBail
          and ttRub.iNoQuittance = giNumeroQuittance
          and ttRub.iFamille = 1
          and ttRub.iSousFamille = 1:
        if lookup(string(ttRub.iNorubrique), vcListeRubrique, ";") > 0     /* NP 1009/0179 */
        then vdeLoyer = vdeLoyer + ttRub.dMontantQuittance.
    end.
    /* Ajout Sy le 04/03/2010: simulation avis d'échéance futur pour reconstituer toute la période de franchise */
    for each equit no-lock
        where equit.noloc = giNumeroBail:
        create ttEquit.
        assign
            ttEquit.noloc = giNumeroBail
            ttEquit.noint = equit.noint
            ttEquit.noqtt = equit.noqtt
            ttEquit.msqtt = equit.msqtt
            ttEquit.msqui = equit.msqui
            ttEquit.dtdeb = equit.dtdeb
            ttEquit.dtfin = equit.dtfin
            ttEquit.dtdpr = equit.dtdpr
            ttEquit.dtfpr = equit.dtfpr
            ttEquit.nbrub = equit.nbrub
            ttEquit.tbrub = equit.tbrub
            ttEquit.tbtot = equit.tbtot
            vdaFinQuittancement = equit.dtfpr
            vcCodePeriode       = equit.PdQtt
            vcCodeTerme         = (if integer(mToken:cRefPrincipale) = {&REFCLIENT-MANPOWER} then {&TERMEQUITTANCEMENT-avance} else equit.cdTer)
            viNombreMoisPeriode = integer(substring(equit.pdqtt, 1, 3, "character"))
            viDerniereQuittance = equit.noqtt
        .
    end.
    /* Ajout SY le 17/03/2010 : si pas de quittances (ex : PEC) => pas de franchise */
    if viDerniereQuittance = 0 then return.

    /* recherche de la date de fin maxi */
    for each tache no-lock
        where tache.tpcon = gcTypeBail
          and tache.nocon = giNumeroBail
          and tache.tptac = {&TYPETACHE-franchise}:
        vdaFinFranchise = maxDate(tache.dtfin, vdaFinFranchise).
    end.
    if vdaFinQuittancement < vdaFinFranchise
    then run genttEquit-Futur(vdaFinFranchise, vdaFinQuittancement, viNombreMoisPeriode, viDerniereQuittance, vcCodeTerme, vcCodePeriode).
    /*--> Cumul des franchises */
boucleTache:
    for each tache no-lock
        where tache.tpcon = gcTypeBail
          and tache.nocon = giNumeroBail
          and tache.tptac = {&TYPETACHE-franchise}:
        if tache.dtfin < gdaDebutPeriode or tache.dtdeb > gdaFinPeriode then next boucleTache.

        /*--> Bornage de la franchise dans la quittance encours */
        assign
            vdaDebutEncours = maximum(tache.dtdeb, gdaDebutPeriode)
            vdaFinEncours   = minimum(tache.dtfin, gdaFinPeriode)
        .
        /* NP 1009/0179 Choix du mode de calcul */
        if tache.cdreg = "POLOY" then assign
            vdeFranchise = tache.mtreg    /* Pourcentage loyer */
            vdeFranchise = (vdeLoyer * vdeFranchise) / 100
        .
        else if tache.cdreg = "MTFIX" then vdeFranchise = tache.mtreg.
        else do:    /* Calc_MTGLB */
            /*--> Calcul du Montant total de loyer pour la période de franchise */
            vdeLoyerTotal = 0.
            /* Ajout SY le 17/08/2007: Franchise sur plusieurs quittances dont la(les) 1ère(s) historisées) */
            for each aquit no-lock
                where aquit.noloc = giNumeroBail
                  and aquit.dtfpr >= tache.DtDeb
                  and aquit.dtdpr <= tache.DtFin
                  and aquit.fgfac = no:
                /*--> Montant du loyer encours */
                vdeLoyerEncours = 0.
boucleRubrique:
                do viCompteur = 1 to 20:
                    vcItemRubrique = aquit.tbrub[viCompteur].
                    if num-entries(vcItemRubrique, "|") < 13 then next boucleRubrique.

                    viItemRubrique = integer(entry(1, vcItemRubrique, "|")).
                    if viItemRubrique = 0 then leave boucleRubrique.

                    if lookup(string(viItemRubrique), vcListeRubrique, ";") > 0
                    then vdeLoyerEncours = vdeLoyerEncours + decimal(entry(5, vcItemRubrique, "|")).
                end.
                /*--> Determination des dates de prorata. Par defaut, la periode complete */
                assign
                    vdaDebutProrata = if aquit.dtdpr < tache.DtDeb then tache.dtdeb else aquit.dtdpr
                    vdaFinProrata   = if aquit.dtfpr > tache.DtFin then tache.dtfin else aquit.dtfpr
                    vdeLoyerTotal   = vdeLoyerTotal                 /*--> Cumul du loyer */
                                    + vdeLoyerEncours * (vdaFinProrata - vdaDebutProrata + 1) / (aquit.dtfpr - aquit.dtdpr + 1)
                .
            end.
            for each ttEquit
                where ttEquit.noloc = giNumeroBail
                  and ttEquit.dtfpr >= tache.DtDeb
                  and ttEquit.dtdpr <= tache.DtFin:
                /*--> Montant du loyer encours */
                vdeLoyerEncours = 0.
                do viCompteur = 1 to ttEquit.nbrub:
                    if lookup(string(ttEquit.tbrub[viCompteur]), vcListeRubrique, ";") > 0
                    and ttEquit.tbtot[viCompteur] <> ?
                    then vdeLoyerEncours = vdeLoyerEncours + ttEquit.tbtot[viCompteur].
                end.
                /*--> Determination des dates de prorata. Par defaut, la periode complete */
                assign
                    vdaDebutProrata = if ttEquit.dtdpr < tache.dtDeb then tache.dtdeb else ttEquit.dtdpr
                    vdaFinProrata   = if ttEquit.dtfpr > tache.dtFin then tache.dtfin else ttEquit.dtfpr
                    vdeLoyerTotal   = vdeLoyerTotal                 /*--> Cumul du loyer */
                                    + vdeLoyerEncours * (vdaFinProrata - vdaDebutProrata + 1) / (ttEquit.dtfpr - ttEquit.dtdpr + 1)
                .
            end.
            assign
                vdeLoyerTotal = round(vdeLoyerTotal, 2)
                vdeFranchise  = tache.mtreg                               /* Montant de la Franchise total */
                vdeFranchise  = vdeLoyer * (vdeFranchise / vdeLoyerTotal) /* Pourcentage de franchise de loyer a quittancer */
            .
        end.
        /*--> Prorata sur la periode Calcul de la franchise */
        if vdaDebutEncours <> gdaDebutQuittancement or vdaFinEncours <> gdaFinQuittancement
        then vdeFranchise = round((vdeFranchise * (vdaFinEncours - vdaDebutEncours + 1)) / (gdaFinQuittancement - gdaDebutQuittancement + 1), 2).
        vdeFranchiseTotal = vdeFranchiseTotal + vdeFranchise.
    end.
    vdeFranchiseTotal = round(vdeFranchiseTotal, 2).
    if vdeFranchiseTotal = 0 then return.

    if vdeFranchiseTotal > vdeLoyer then vdeFranchiseTotal = vdeLoyer.
    /*--> Creation de la rubrique */
    for first rubqt no-lock
        where rubqt.cdrub = 104
          and rubqt.cdlib = 1
      , first ttQtt
        where ttQtt.iNumeroLocataire = giNumeroBail
          and ttQtt.iNoQuittance = giNumeroQuittance:
        create ttRub.
        assign
            ttRub.iNumeroLocataire = giNumeroBail
            ttRub.iNoQuittance = giNumeroQuittance
            ttRub.iFamille = rubqt.cdfam
            ttRub.iSousFamille = rubqt.cdsfa
            ttRub.iNorubrique = 104
            ttRub.iNoLibelleRubrique = rubqt.cdlib
            ttRub.cCodeGenre = rubqt.cdgen
            ttRub.cCodeSigne = rubqt.cdsig
            ttRub.CdDet = "0"
            ttRub.dQuantite = 0
            ttRub.dPrixunitaire = 0
            ttRub.dMontantTotal = if rubqt.cdsig = "00000" then vdeFranchiseTotal else - vdeFranchiseTotal
            ttRub.iProrata = 0
            ttRub.iNumerateurProrata = 0
            ttRub.iDenominateurProrata = 0
            ttRub.dMontantQuittance = if rubqt.cdsig = "00000" then vdeFranchiseTotal else - vdeFranchiseTotal
            ttRub.daDebutApplication = gdaDebutQuittancement
            ttRub.daFinApplication = gdaFinQuittancement
            ttRub.iNoOrdreRubrique = 0
            ttQtt.dMontantQuittance = ttQtt.dMontantQuittance + ttRub.dMontantTotal
            ttQtt.iNombreRubrique = ttQtt.iNombreRubrique + 1
            ttRub.cLibelleRubrique = outilTraduction:getLibelle(rubqt.nome1)
        .
    end.
end procedure.

procedure genttEquit-Futur private:
    /*-------------------------------------------------------------------------
    Purpose :
    Notes   :
    -------------------------------------------------------------------------*/
    define input  parameter pdaFinFranchise     as date      no-undo.
    define input  parameter pdaFinQuittance     as date      no-undo.
    define input  parameter piNombreMoisPeriode as integer   no-undo.
    define input  parameter piDerniereQuittance as integer   no-undo.
    define input  parameter pcCodeTerme         as character no-undo.
    define input  parameter pcCodePeriode       as character no-undo.

    define variable viMoisQuittancement as integer   no-undo.
    define variable viMoisTraitement    as integer   no-undo.
    define variable vdaDebutPeriode     as date      no-undo.
    define variable vdaFinPeriode       as date      no-undo.
    define variable vdaDebutProchain    as date      no-undo.
    define variable vdaFinProchain      as date      no-undo.
    define variable viNumeroCreation    as integer   no-undo.
    define variable viNouveauEquit      as int64     no-undo.
    define variable viNombreCree        as integer   no-undo.
    define variable vdaFinCreation      as date      no-undo.
    define buffer equit for equit.
    define buffer vbttEquit for ttEquit.

    {&_proparse_ prolint-nowarn(wholeIndex)}
    for last equit no-lock:
        viNouveauEquit = equit.noint.
    end.
    assign
        /* sécurité pour créer Qtt contenant la fin de franchise */
        vdaFinCreation   = add-interval(pdaFinFranchise, piNombreMoisPeriode, "months")
        /* Calcul des dates de la prochaine quittance */
        vdaDebutPeriode  = pdaFinQuittance + 1
        vdaDebutProchain = vdaDebutPeriode
        viNumeroCreation = piDerniereQuittance
    .
    /* Calcul date de fin de période, Calcul mois quitt et mois traitement GI */
    /*--> Calcul mois quittancement et mois traitement GI */
    run calInfPer in ghProcDate(vdaDebutPeriode, pcCodePeriode, pcCodeTerme, output vdaFinProchain, output viMoisQuittancement, output viMoisTraitement).
    vdaFinPeriode = vdaFinProchain.

    /* Création des prochaine quittances: Limitation à 5 ans => 60 qtt. Passage à 9 ans => 108 qtt NP 1009/0179 */
    do while vdaFinProchain <= vdaFinCreation and viNombreCree < 108:
        find first vbttEquit
            where vbttEquit.noloc = giNumeroBail and vbttEquit.noqtt = viNumeroCreation no-error.
        if not available vbttEquit then return.

        create ttEquit.
        assign
            viNouveauEquit   = viNouveauEquit + 1
            viNumeroCreation = vbttEquit.noqtt + 1
            ttEquit.noint    = viNouveauEquit
            ttEquit.noloc    = giNumeroBail
            ttEquit.noqtt    = viNumeroCreation
            ttEquit.msqtt    = viMoisTraitement
            ttEquit.msqui    = viMoisQuittancement
            ttEquit.dtdeb    = vdaDebutProchain
            ttEquit.dtfin    = vdaFinProchain
            ttEquit.dtdpr    = vdaDebutPeriode
            ttEquit.dtfpr    = vdaFinPeriode
            ttEquit.nbrub    = vbttEquit.nbrub
            ttEquit.tbrub    = vbttEquit.tbrub
            ttEquit.tbtot    = vbttEquit.tbtot
            viNombreCree     = viNombreCree + 1 /* Calcul des dates de la prochaine quittance */
            vdaDebutPeriode  = vdaFinPeriode + 1
            vdaDebutProchain = vdaDebutPeriode
        .
        /* Calcul date de fin de période, mois quitt et mois traitement GI */
        run calInfPer in ghProcDate(vdaDebutPeriode, pcCodePeriode, pcCodeTerme, output vdaFinProchain, output viMoisQuittancement, output viMoisTraitement).
        vdaFinPeriode = vdaFinProchain.
    end.

end procedure.
